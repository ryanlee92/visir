import { PubSub } from '@google-cloud/pubsub';
import { createClient } from '@supabase/supabase-js';
import { ApnsClient, Notification, NotificationOptions } from 'apns2';
import express from 'express';
import * as admin from 'firebase-admin';
import { Message } from 'firebase-admin/messaging';
import fetch from 'node-fetch';
import { createClient as createRedisClient } from 'redis';
import { v4 as uuid, v4 as uuidv4 } from 'uuid';
import { WebSocket } from 'ws';

const PORT = process.env.PORT || 8080;
const REDIS_URL = process.env.REDIS_URL!;
const PROJECT_ID = process.env.GCP_PROJECT_ID!;
const INSTANCE_ID = process.env.FLY_MACHINE_ID || uuid();

const redis = createRedisClient({ url: REDIS_URL });
redis.connect();

const pubsub = new PubSub({
  projectId: PROJECT_ID,
  credentials: {
    client_email: process.env.GCP_CLIENT_EMAIL,
    private_key: process.env.GCP_PRIVATE_KEY!.replace(/\\n/g, '\n'),
  },
});

const supabase = createClient(
  process.env.SUPABASE_URL!,
  process.env.SUPABASE_ANON_KEY!,
);

const app = express();
app.use(express.json());

const activeConnections = new Map<string, { ws: WebSocket; heartbeat: NodeJS.Timer }>();
const TTL_2WEEKS = 14 * 24 * 60 * 60 * 1000;

setInterval(() => {
  redis.set(`slack:instance-heartbeat:${INSTANCE_ID}`, Date.now().toString(), { EX: 90 });
}, 30000);

app.post('/connect', async (req, res) => {
  const { userId, workspaceId, authorizationHeaders } = req.body;
  if (!authorizationHeaders) return res.status(400).send('Missing authorization headers');

  const key = `${userId}|${workspaceId}`;
  const redisKey = `slack:connection:${key}`;
  const ownerKey = `slack:connection-owner:${key}`;

  const ownerInstanceId = await redis.get(ownerKey);
  if (ownerInstanceId) {
    const isAlive = await redis.exists(`slack:instance-heartbeat:${ownerInstanceId}`);
    if (!isAlive) {
      await redis.del(ownerKey);
    }
  }

  const ownerSet = await redis.set(ownerKey, INSTANCE_ID, { NX: true, EX: 14 * 24 * 3600 });
  if (!ownerSet) {
    return res.status(409).send('Another instance owns this connection');
  }

  const createdAt = Date.now();
  await redis.set(redisKey, JSON.stringify({ userId, workspaceId, authorizationHeaders, createdAt }));
  await connectSlack(userId, workspaceId, authorizationHeaders, redisKey);
  return res.status(200).send(`Connected: ${key}`);
});

app.get('/ping', (_, res) => res.send('pong'));

app.post('/presence/update', async (req, res) => {
  const { workspaceId, users, presence } = req.body;
  if (!workspaceId || !users || !presence) return res.status(400).send('Missing fields');

  for (const userId of users) {
    const key = `slack:presence:${workspaceId}:${userId}`;
    console.log(`[Presence] Updating ${key} to ${presence}`);
    await redis.set(key, JSON.stringify({
      presence,
      last_updated: Date.now(),
    }), { EX: 60 * 60 });
  }

  return res.status(200).send('Updated');
});

app.get('/presence/:workspaceId', async (req, res) => {
  const { workspaceId } = req.params;
  const pattern = `slack:presence:${workspaceId}:*`;
  const keys = await redis.keys(pattern);

  const results: Record<string, any> = {};
  for (const key of keys) {
    const raw = await redis.get(key);
    if (raw) {
      const [, , , userId] = key.split(':');
      results[userId] = JSON.parse(raw);
    }
  }

  return res.status(200).json(results);
});

async function connectSlack(userId: string, workspaceId: string, headers: any, redisKey: string) {
  const key = `${userId}|${workspaceId}`;
  if (activeConnections.has(key)) return;

  console.log(`[Leader] Connecting ${key} to Slack for real`);

  const resp = await fetch('https://slack.com/api/rtm.connect', {
    method: 'POST',
    headers: {
      ...headers,
      'Content-Type': 'application/x-www-form-urlencoded',
    },
  });

  const rtm = await resp.json();
  if (!rtm.ok) {
    console.error(`RTM connect failed: ${rtm.error}`);
    return;
  }

  const ws = new WebSocket(rtm.url, {
    headers: { ...headers, Origin: 'https://api.slack.com' },
  });

  const heartbeat = setInterval(() => {
    if (ws.readyState === WebSocket.OPEN) {
      redis.expire(redisKey, 14 * 24 * 3600);
    }
  }, 30000);

  activeConnections.set(key, { ws, heartbeat });
  await redis.set(`slack:connection-owned-live:${INSTANCE_ID}:${key}`, '1', { EX: 14 * 24 * 3600 });

  ws.on('message', async (data) => {
    const text = data.toString('utf-8');
    try {
      const json = JSON.parse(text);

      const isMessageEvent = json.type == 'message' || json.type == 'reaction_added' || json.type == 'reaction_removed';
      if (isMessageEvent) {
        await publishToPubSub({ event: { ...json, 'team': workspaceId }, rtm: true }, userId, workspaceId);
      }


      // await handleslacknotificationcore({ event: { ...json, 'team': workspaceId }, rtm: true });

      if (json.type === 'presence_change') {
        const { user, presence } = json;
        const presenceKey = `slack:presence:${workspaceId}:${user}`;
        await redis.set(presenceKey, JSON.stringify({
          presence,
          last_updated: Date.now(),
        }), { EX: 60 * 60 });
      }

      console.log(`[Leader] Message send to pubsub`, json);
    } catch (e) {
      console.error('Invalid JSON:', text);
    }
  });

  ws.on('close', async () => {
    clearInterval(heartbeat);
    activeConnections.delete(key);
    await redis.del(redisKey);
    await redis.del(`slack:connection-owner:${key}`);
    await redis.del(`slack:connection-owned-live:${INSTANCE_ID}:${key}`);
  });

  ws.on('error', async (err) => {
    console.error(`WS error: ${key}`, err);
    clearInterval(heartbeat);
    activeConnections.delete(key);
    await redis.del(redisKey);
    await redis.del(`slack:connection-owner:${key}`);
    await redis.del(`slack:connection-owned-live:${INSTANCE_ID}:${key}`);
  });
}

async function tryReconnectAsLeader() {
  const lockKey = 'slack:rtm-reconnect-lock';

  const existingOwner = await redis.get(lockKey);
  if (existingOwner && existingOwner !== INSTANCE_ID) {
    console.log(`[Leader] Lock held by another instance (${existingOwner}), skipping reconnect.`);
    return;
  }

  const lock = await redis.set(lockKey, INSTANCE_ID, { NX: true, PX: 120_000 });
  if (!lock && existingOwner !== INSTANCE_ID) return;

  console.log(`[Leader] Restoring RTM connections...`);
  const keys = await redis.keys('slack:connection:*');

  for (const redisKey of keys) {
    const value = await redis.get(redisKey);
    if (!value) continue;

    const { userId, workspaceId, authorizationHeaders } = JSON.parse(value);
    const key = `${userId}|${workspaceId}`;
    const ownerKey = `slack:connection-owner:${key}`;

    const currentOwner = await redis.get(ownerKey);
    if (currentOwner && currentOwner !== INSTANCE_ID) {
      const isAlive = await redis.exists(`slack:instance-heartbeat:${currentOwner}`);
      const isHolding = await redis.exists(`slack:connection-owned-live:${currentOwner}:${key}`);

      if (isAlive && isHolding) {
        continue; // 실제로 살아있는 인스턴스가 유지 중
      }

      console.log(`[Leader] Previous owner ${currentOwner} is stale. Taking over ${key}`);
    }

    await redis.set(ownerKey, INSTANCE_ID, { EX: 14 * 24 * 3600 });

    console.log(`[Leader] Connecting ${key}`);
    if (!activeConnections.has(key)) {
      console.log(`[Leader] Connecting ${key} to Slack`);
      await connectSlack(userId, workspaceId, authorizationHeaders, redisKey);
    }
  }
}

setInterval(async () => {
  const now = Date.now();
  const keys = await redis.keys('slack:connection:*');
  for (const redisKey of keys) {
    const raw = await redis.get(redisKey);
    if (!raw) continue;

    const { createdAt, userId, workspaceId } = JSON.parse(raw);
    const key = `${userId}|${workspaceId}`;

    if (now - createdAt > TTL_2WEEKS) {
      console.log(`[Expire] ${key} exceeded 2 weeks, closing`);
      const connection = activeConnections.get(key);
      connection?.ws?.close();
      activeConnections.delete(key);
      await redis.del(redisKey);
      await redis.del(`slack:connection-owner:${key}`);
      await redis.del(`slack:connection-owned-live:${INSTANCE_ID}:${key}`);
    }
  }
}, 600000);

async function publishToPubSub(message: any, userId: string, workspaceId: string) {
  const topic = 'slack-notification';
  const data = Buffer.from(JSON.stringify({
    ...message,
    userId,
    workspaceId,
    timestamp: new Date().toISOString()
  }));
  console.log(`[Leader] Message tried published to pubsub`);
  await pubsub.topic(topic).publishMessage({ data }).catch((err) => {
    console.error(`[Leader] Message failed to publish to pubsub`, err);
  });

  console.log(`[Leader] Message published to pubsub`);
}

app.listen(PORT, async () => {
  console.log(`✅ Slack RTM server running on port ${PORT} (ID: ${INSTANCE_ID})`);
  await tryReconnectAsLeader();
});

// 👇 여기에 추가!
setInterval(async () => {
  const keys = await redis.keys('slack:connection:*');

  for (const redisKey of keys) {
    const value = await redis.get(redisKey);
    if (!value) continue;

    const { userId, workspaceId, authorizationHeaders } = JSON.parse(value);
    const key = `${userId}|${workspaceId}`;
    const ownerKey = `slack:connection-owner:${key}`;

    const currentOwner = await redis.get(ownerKey);
    if (currentOwner && currentOwner !== INSTANCE_ID) {
      const isAlive = await redis.exists(`slack:instance-heartbeat:${currentOwner}`);
      const isHolding = await redis.exists(`slack:connection-owned-live:${currentOwner}:${key}`);

      if (isAlive && isHolding) {
        continue; // 실제로 살아있는 인스턴스가 유지 중
      }

      console.log(`[Leader] Previous owner ${currentOwner} is stale. Taking over ${key}`);
    }

    await redis.set(ownerKey, INSTANCE_ID, { EX: 14 * 24 * 3600 });

    console.log(`[Leader] Connecting ${key}`);
    if (!activeConnections.has(key)) {
      console.log(`[Leader] Connecting ${key} to Slack`);
      await connectSlack(userId, workspaceId, authorizationHeaders, redisKey);
    }
  }
}, 30_000); // ✅ every 30 seconds



const serviceAccount = require('../firebase.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const prodClient = new ApnsClient({
  team: 'V4MN45XSYF',
  keyId: '7LHHJRX2UF',
  signingKey: process.env.APNS_KEY!.replace(/\\n/g, '\n'),
  defaultTopic: `com.wavetogether.fillin`,
  requestTimeout: 0, // optional, Default: 0 (without timeout)
  keepAlive: true, // optional, Default: 5000
});

const devClient = new ApnsClient({
  host: 'api.sandbox.push.apple.com',
  team: 'V4MN45XSYF',
  keyId: '7LHHJRX2UF',
  signingKey: process.env.APNS_KEY!.replace(/\\n/g, '\n'),
  defaultTopic: `com.wavetogether.fillin`,
  requestTimeout: 0, // optional, Default: 0 (without timeout)
  keepAlive: true, // optional, Default: 5000
});

type sendFcmData = {
  apnsToken: string | undefined;
  fcmToken: string;
  userId: string;
  platform: string;
  threadId: string;
  data: { [key: string]: string };
  notification: { title: string; body: string; imageUrl?: string };
  subtitle?: string;
  subtitleSeparator?: string;
  badge?: number;
};

const chunkArray = <T>(array: T[], chunkSize: number): T[][] => {
  if (chunkSize <= 0) throw new Error('Chunk size must be greater than 0.');

  const results: T[][] = [];
  for (let i = 0; i < array.length; i += chunkSize) {
    const chunk: T[] = array.slice(i, i + chunkSize);
    results.push(chunk);
  }
  return results;
};

const isDesktopData = (data: sendFcmData) => {
  if (data.platform == 'windows') return true;
  if (data.platform == 'macos') return true;
  if (data.platform == 'linux') return true;
  return false;
}

const sendFcmWithData = async (data: sendFcmData[]) => {
  const desktopData = data.filter((e) => isDesktopData(e));
  const apnsData = data.filter((e) => e.apnsToken && !isDesktopData(e) && false);
  const notApnsData = data.filter((e) => !isDesktopData(e));
  const apnsChunk = chunkArray(
    apnsData.filter((e) => e.apnsToken),
    500,
  );
  const notApnsChunk = chunkArray(
    notApnsData.filter((e) => e.fcmToken),
    500,
  );
  await Promise.all([
    sendSupabaseMessage(desktopData),
    ...notApnsChunk.map((chunk) => sendFcm(chunk)),
    ...apnsChunk.map((chunk) => sendApns(chunk)),
    ...apnsChunk.map((chunk) => sendDevApns(chunk)),
  ]);
};

const sendSupabaseMessage = async (data: sendFcmData[]) => {
  data.forEach(async (d) => {
    const channel = supabase.channel(d.fcmToken);
    await channel.send({
      type: 'broadcast',
      event: 'notification_sent',
      payload: {
        title: d.notification.title,
        subtitle: d.subtitle,
        body: d.notification.body,
        image: d.notification.imageUrl,
        thread: d.threadId,
        badge: d.badge,
        data: d.data,
      },
    });
  });
};

const sendApns = async (data: sendFcmData[]) => {
  const notifications = data.map((d) => {
    const options: NotificationOptions = {
      mutableContent: true,
      badge: d.platform == 'macos' ? 0 : d.badge,
      sound: 'default',
      threadId: d.threadId,
      expiration: Math.floor(Date.now() / 1000) + 3600,
      alert: {
        title: d.notification.title,
        body: d.notification.body,
        subtitle: d.subtitle,
      },
      data: {
        'gcm.message_id': uuidv4(),
        fcm_options: {
          image: d.notification.imageUrl,
        },
        badge: d.badge,
        ...d.data,
      },
    };
    const message = new Notification(d.apnsToken!, options);
    return message;
  });

  notifications.forEach(async (n) => {
    try {
      await prodClient.send(n);
      console.log('###### success apns prod', n);
    } catch (err: any) {
      console.log('###### failed apns prod', err);
    }
  });
};

const sendDevApns = async (data: sendFcmData[]) => {
  const notifications = data.map((d) => {
    const options: NotificationOptions = {
      mutableContent: true,
      badge: d.platform == 'macos' ? 0 : d.badge,
      sound: 'default',
      threadId: d.threadId,
      expiration: Math.floor(Date.now() / 1000) + 3600,
      alert: {
        title: d.notification.title,
        body: d.notification.body,
        subtitle: d.subtitle,
      },
      data: {
        'gcm.message_id': uuidv4(),
        fcm_options: {
          image: d.notification.imageUrl,
        },
        badge: d.badge,
        ...d.data,
      },
    };
    const message = new Notification(d.apnsToken!, options);
    return message;
  });

  notifications.forEach(async (n) => {
    try {
      await devClient.send(n);
      console.log('###### success apns dev', n);
    } catch (err: any) {
      console.log('###### failed apns dev', err);
    }
  });
};

const sendFcm = async (data: sendFcmData[]) => {
  const result = await admin.messaging().sendEach(
    data.map((d) => {
      const message: Message = {
        token: d.fcmToken,
        notification: {
          title: d.notification.title,
          body: d.notification.body,
          imageUrl: d.notification.imageUrl,
        },
        data: d.data,
        android: {
          priority: 'high',
          collapseKey: d.threadId,
          notification: {
            imageUrl: d.notification.imageUrl,
            channelId: 'taskey_notification',
            priority: 'max',
            body: d.subtitle
              ? d.subtitle +
              d.subtitleSeparator +
              d.notification.body
              : d.notification.body,
          },
        },
        apns: {
          payload: {
            aps: {
              mutableContent: true,
              sound: 'default',
              threadId: d.threadId,
              badge: d.badge,
              alert: {
                subtitle: d.subtitle,
              },
            },
          },
          fcmOptions: {
            imageUrl: d.notification.imageUrl,
          },
        },
        // webpush: {
        //     headers: {
        //         image: d.notification.imageUrl!,
        //     },
        // },
      };
      return message;
    }),
  );
  console.log(
    '####### sendFcmResult:',
    result.responses.map((e) => e.error?.message),
  );
};


type NotificationUser = {
  u: {
    id: string;
    badge: number;
    last_gmail_history_ids: { [key: string]: string };
  };
  n: {
    id: string;
    fcm_token: string;
    apns_token: string | undefined;
    device_id: string;
    user_id: string;
    platform: string;
    gmail_server_code: { [key: string]: string };
    slack_data: { [key: string]: any };
    gmail_notification_image: { [key: string]: string };
    gcal_notification_image: { [key: string]: string };
    slack_notification_image: { [key: string]: string };
    show_gmail_notification: { [key: string]: string[] };
  };
};

export const handleslacknotificationcore = async (body: any) => {
  if (typeof body['event'] === 'string') {
    body['event'] = JSON.parse(body['event']);
  }

  const isRtm = body['rtm'] || false;

  const channel_id = body['event']['channel'];
  const type = body['event']['type'];
  const subtype = body['event']['subtype'];
  const text = body['event']['text'];
  const files = body['event']['files'] || [];
  const blocks = body['event']['blocks'] || [];
  const attachments = body['event']['attachments'] || [];
  const ts = body['event']['ts'];
  const team_id =
    body['event']['team'] ||
    ((body['event']['files'] || [])[0] || {})['user_team'];
  const user_id = body['event']['user'];
  const eventTs = body['event']['event_ts'];
  const threadTs = body['event']['thread_ts'];

  const channels: string[] = [];
  const users: string[] = [];
  const groups: string[] = [];

  if (
    type == 'message' &&
    subtype != 'message_changed' &&
    subtype != 'message_deleted'
  ) {
    const timestamp = parseFloat(ts) * 1000;
    const μsec = ts.slice(-3);
    const createdAt = new Date(timestamp);
    const isoDatePlus = createdAt.toISOString().replace('Z', μsec + 'Z');

    await supabase.from('message_channel_last').upsert({
      id: team_id + channel_id,
      team_id: team_id,
      channel_id: channel_id,
      last_message_created_at: isoDatePlus,
    });


    const getRichTextFetchData = (
      element: any,
    ) => {
      const channels = [];
      const users = [];
      const groups = [];
      if (element.type == null) return { channels: [], users: [], groups: [] };
      switch (element.type) {
        case 'channel':
          channels.push(element['channel_id']);
          break;
        case 'user':
          users.push(element['user_id']);
          break;
        case 'usergroup':
          groups.push(element['usergroup_id']);
          break;
        default:
          break;
      }
      return {
        channels: channels,
        users: users,
        groups: groups,
      };
    };


    if (!blocks.isEmpty) {
      blocks.forEach((block: any) => {
        switch (block.type) {
          case 'rich_text': {
            block.elements.forEach(
              (richText: any) => {
                let inlineSpans: string[] =
                  [];
                switch (richText['type']) {
                  case 'rich_text_section':
                    richText.elements.forEach(
                      (
                        element: any,
                      ) => {
                        const data = getRichTextFetchData(element);
                        channels.push(...data.channels);
                        users.push(...data.users);
                        groups.push(...data.groups);
                      },
                    );
                    break;
                  case 'rich_text_list':
                    richText.elements.forEach(
                      (
                        section: any,
                      ) => {
                        section.elements.forEach(
                          (
                            element: any,
                          ) => {
                            const data = getRichTextFetchData(element);
                            channels.push(...data.channels);
                            users.push(...data.users);
                            groups.push(...data.groups);
                          },
                        );

                      },
                    );
                    break;

                  case 'rich_text_preformatted':
                  case 'rich_text_quote':
                  case 'mrkdwn':
                    inlineSpans =
                      inlineSpans.concat(
                        richText.elements
                          .map(
                            (
                              element: any,
                            ) => {
                              const data = getRichTextFetchData(element);
                              channels.push(...data.channels);
                              users.push(...data.users);
                              groups.push(...data.groups);
                            },
                          )
                          .toList(),
                      );
                    break;
                  case 'image':
                  case null:
                    break;
                }
              },
            );
            break;
          }
          case 'video':
            const data = getRichTextFetchData({
              type: 'text',
              text:
                block.description[
                'text'
                ] + '\n',
            });
            channels.push(...data.channels);
            users.push(...data.users);
            groups.push(...data.groups);


            const data2 = getRichTextFetchData({
              type: 'link',
              text: block.title ?? [
                'text',
              ],
              url: block.videoUrl,
            },);
            channels.push(...data2.channels);
            users.push(...data2.users);
            groups.push(...data2.groups);
            break;
          default:
            break;
        }
      });
    }
  }

  console.log('###### get_slack_linked_user');
  let result = await supabase
    .rpc('get_slack_linked_user', {
      slack_team_id: team_id,
      slack_user_ids: [...new Set([user_id, ...users])],
      slack_channel_ids: [...new Set([channel_id, ...channels])],
      slack_usergroup_ids: [...new Set(groups)],
    });

  console.log('###### get_slack_linked_user done', result);

  const sentToken: string[] = [];
  const sentUser: string[] = [];
  const notificationImage: { [key: string]: string } = {};
  const notificationBadge: { [key: string]: number } = {};
  const newNotificationData: { [key: string]: any }[] = [];
  const notificationApnsToken: { [key: string]: string | undefined } = {};
  const notificationUserId: { [key: string]: string } = {};
  const notificationPlatform: { [key: string]: string } = {};

  // 'channel_id': e.id,
  // 'channel_name': e.displayName,
  // 'filter': pref.prefMessageChannelNotificationFilterTypes['${key}${me?.email}']?.name,
  // 'team_id': key,
  // 'members': e.members.map((e) => {'id': e.id, 'name': e.displayName, 'image': e.profileImageLarge}).toList(),
  // 'me': me?.id,

  let title = '';
  let snippet = '';
  let subtitle: string | undefined;

  if (result.data && result.data.length > 0) {
    const mailLinkedUsers = result.data;
    mailLinkedUsers.forEach((user: NotificationUser) => {
      if (!sentUser.includes(user.n.user_id)) {
        sentUser.push(user.n.user_id);
      }

      if (
        type == 'message' &&
        subtype != 'message_changed' &&
        subtype != 'message_deleted'
      ) {
        if (user.n.slack_data[team_id]) {
          const slackData = user.n.slack_data[team_id];
          const channelData = slackData.find(
            (e: any) => e.channel_id.toLowerCase() == channel_id.toLowerCase(),
          );

          if (channelData && !isRtm == (channelData['is_app_auth'] === false || channelData['is_app_auth'] === 'false' ? false : true)) {
            if (!newNotificationData.find(e => e.id == user.n.user_id)) {
              newNotificationData.push({
                id: user.n.user_id,
                badge: (user.u.badge || 0) + 1,
              });
            }
          }
        }
      }

      if (
        type == 'message' &&
        subtype != 'message_changed' &&
        subtype != 'message_deleted'
      ) {

        if (user.n.slack_data[team_id]) {
          const slackData = user.n.slack_data[team_id];
          const channelData = slackData.find(
            (e: any) => e.channel_id.toLowerCase() == channel_id.toLowerCase(),
          );

          if (channelData && channelData['me'] != user_id && !isRtm == (channelData['is_app_auth'] === false || channelData['is_app_auth'] === 'false' ? false : true)) {
            const isChannel = channelData['is_channel'];
            const channelName = isChannel
              ? '#' + channelData['channel_name']
              : channelData['channel_name'];
            const userName = channelData['members'].find(
              (e: any) => e.id.toLowerCase() == user_id.toLowerCase(),
            )['name'];
            if (channelName == userName) {
              title = channelName;
            } else {
              title = channelName;
              subtitle = userName;
            }

            const getRichTextSnippet = (
              element: any,
              channels: any,
              channelData: any,
            ) => {
              if (element.type == null) return '';
              let strings: string[] = [];
              switch (element.type) {
                case 'channel':
                  const channel = channels.find(
                    (e: any) =>
                      e.id == element['channel_id'],
                  );
                  if (channel != null) {
                    strings.push('#' + channel.name);
                  } else {
                    strings.push(
                      '#' + element['channel_id'],
                    );
                  }
                  break;
                case 'emoji':
                  if (element.unicode != null) {
                    strings.push(String.fromCodePoint(parseInt(element.unicode, 16)));
                  } else {
                    strings.push(`:${element.name}:`);
                  }
                  break;
                case 'link':
                  strings.push(
                    element.text ?? element.url ?? '',
                  );
                  break;
                case 'text':
                  strings.push(element.text ?? '');
                  break;
                case 'user':
                  const member = channelData.members.find(
                    (m: any) =>
                      m.id == element['user_id'],
                  );
                  if (member != null) {
                    strings.push('@' + member.name);
                  }
                  break;
                case 'usergroup':
                  const group = channelData.groups.find(
                    (m: any) =>
                      m.id == element['usergroup_id'],
                  );
                  strings.push('@' + group.name);
                  break;
                case 'broadcast':
                  strings.push('@' + element.range);
                  break;
                case 'rich_text_section':
                  strings.push(element.text ?? '');
                  break;
                case 'date':
                  strings.push(element.fallback ?? '');
                  break;
                case 'color':
                  strings.push(element.value ?? '');
                  break;
                default:
                  break;
              }
              return strings.join('');
            };

            const getOrdinalSuffix = (day: number) => {
              if (!(day >= 1 && day <= 31)) {
                throw new Error('Invalid day of the month');
              }
              if (day >= 11 && day <= 13) return 'th';
              switch (day % 10) {
                case 1:
                  return 'st';
                case 2:
                  return 'nd';
                case 3:
                  return 'rd';
                default:
                  return 'th';
              }
            };

            const slackPretextToStringConverter = (
              channelId: string,
              text: string,
              showMentionTag: boolean,
            ) => {
              const strings = [];
              let lastMatchEnd = 0;

              const combinedRegex = new RegExp(
                '\\*<((?:https?:\\/\\/[^\\s|>]+))(?:\\|([^>]*))?>\\*' + // 링크 굵게
                '|<((?:https?:\\/\\/[^\\s|>]+))\\s*(?:\\|([^>]*)\\s*)?>' + // 링크
                '|`<([^|>]+)\\|([^>]+)>`' + // 코드 블럭
                '|:([^:\\s]+):\\s*' + // 이모지
                '|_(.*?)_' + // 이탤릭
                '|\\*(.*?)\\*' + // 굵게
                '|~(.*?)~' + // 취소선
                '|<@([^>]+)>' + // 멘션
                '|<!date\\^(\\d+)\\^{([^>]+)}\\|([^>]+)>' + // 날짜
                '|`([^`]+)`' + // 마크 다운
                '|<#([^>]+)\\|>', //채널 멘션
                'g',
              );

              // Process text using regular expressions
              const matches = [
                ...text.matchAll(combinedRegex),
              ];

              for (const match of matches) {
                if (match.index! > lastMatchEnd) {
                  const substring = text.substring(
                    lastMatchEnd,
                    match.index!,
                  );
                  strings.push(substring);
                }

                if (
                  match[1] !== undefined &&
                  match[2] !== undefined
                ) {
                  // Bold link processing
                  const displayText = match[2];
                  strings.push(displayText);
                } else if (
                  match[3] !== undefined &&
                  match[4] !== undefined
                ) {
                  // Link processing
                  const displayText = match[4];
                  strings.push(displayText);
                } else if (
                  match[5] !== undefined &&
                  match[6] !== undefined
                ) {
                  // Code block processing
                  const displayText = match[6];
                  strings.push(displayText);
                } else if (match[7] !== undefined) {
                  // Emoji processing
                  const emojiText = match[7];
                  strings.push(emojiText);
                } else if (match[8] !== undefined) {
                  // Italic processing
                  const italicText = match[8];
                  strings.push(italicText);
                } else if (match[9] !== undefined) {
                  // Bold processing
                  const boldText = match[9];
                  strings.push(boldText);
                } else if (match[10] !== undefined) {
                  // Strikethrough processing
                  const strikeText = match[10];
                  strings.push(strikeText);
                } else if (match[11] !== undefined) {
                  // Mention processing
                  const mentionText = match[11];
                  const channel = slackData.find(
                    (e: any) => e.id === channelId,
                  );
                  const member = channel.members.find(
                    (m: any) => m.id === mentionText,
                  );
                  strings.push(
                    `${showMentionTag ? '@' : ''}${member?.displayName
                    }`,
                  );
                } else if (
                  match[12] !== undefined &&
                  match[13] !== undefined &&
                  match[14] !== undefined
                ) {
                  const timestamp = parseInt(match[12]);
                  const formatString = match[13];
                  const fallbackText = match[14];

                  const isTime = formatString === 'time';
                  const isDateShort =
                    formatString ===
                    'date_short_pretty';
                  const isDateLong =
                    formatString === 'date_long_pretty';

                  // Convert Unix timestamp to Date
                  const date = new Date(timestamp * 1000);

                  // Format date according to the specified format
                  const formattedDate = isTime
                    ? date.toLocaleTimeString([], {
                      hour: '2-digit',
                      minute: '2-digit',
                    })
                    : isDateShort
                      ? date.toLocaleDateString([], {
                        month: 'short',
                        day: 'numeric',
                      })
                      : isDateLong
                        ? `${date.toLocaleDateString([], {
                          weekday: 'long',
                          month: 'long',
                          day: 'numeric',
                        })} ${getOrdinalSuffix(
                          date.getDate(),
                        )}`
                        : fallbackText;

                  strings.push(` ${formattedDate} `);
                } else if (match[15] !== undefined) {
                  // Markdown processing
                  const displayText = match[15];
                  strings.push(displayText);
                } else if (match[16] !== undefined) {
                  // Channel mention processing
                  const channelText = match[16];
                  const channel = slackData.find(
                    (e: any) => e.id === channelText,
                  );
                  strings.push(
                    `${showMentionTag ? '#' : ''}${channel.name
                    }`,
                  );
                }

                lastMatchEnd =
                  match.index! + match[0].length;
              }

              // Process text after the last match
              if (lastMatchEnd < text.length) {
                strings.push(text.substring(lastMatchEnd));
              }

              return strings.join('');
            };

            let strings: string[] = [];

            if (blocks.isEmpty) {
              switch (subtype) {
                case 'channel_join':
                case 'group_join':
                  strings.push('joined #' + channelName);
                  break;
                case 'channel_archive':
                case 'group_archive':
                  strings.push(
                    'archived #' +
                    channelName +
                    '. The contents will still be browsable and available in search.',
                  );
                  break;
                case 'channel_name':
                case 'channel_topic':
                case 'channel_purpose':
                case 'group_topic':
                case 'group_name':
                case 'group_purpose':
                  if (text?.isNotEmpty == true)
                    strings.push(text!);
                  break;
                case 'channel_unarchive':
                case 'group_unarchive':
                  strings.push(
                    'unarchived #' + channelName,
                  );
                  break;
                case 'channel_leave':
                case 'group_leave':
                  strings.push('left #' + channelName);
                  break;
                default:
                  if (text?.isNotEmpty == true) {
                    strings.push(text!);
                  } else {
                    const fileNames = files?.map(
                      (e: any) => e.name,
                    );
                    strings = strings.concat(fileNames);
                  }
                  break;
              }
            } else {
              blocks.forEach((block: any) => {
                switch (block.type) {
                  case 'divider':
                    break;
                  case 'rich_text': {
                    block.elements.forEach(
                      (richText: any) => {
                        let inlineSpans: string[] =
                          [];
                        switch (richText['type']) {
                          case 'rich_text_section':
                            richText.elements.forEach(
                              (
                                element: any,
                              ) => {
                                inlineSpans.push(
                                  getRichTextSnippet(
                                    element,
                                    slackData,
                                    channelData,
                                  ),
                                );
                              },
                            );
                            break;
                          case 'rich_text_list':
                            let _blockInlineSpan: string[] =
                              [];
                            let indent =
                              richText.indent;
                            let indentWidth =
                              indent * 16;
                            let sectionIndex = 0;
                            richText.elements.forEach(
                              (
                                section: any,
                              ) => {
                                let offset =
                                  richText.offset;
                                let _prevList =
                                  block.elements
                                    .where(
                                      (
                                        r: any,
                                      ) =>
                                        r.indent ==
                                        richText.indent,
                                    )
                                    .toList();
                                let _prevSubListSum =
                                  _prevList
                                    .sublist(
                                      0,
                                      _prevList.indexOf(
                                        richText,
                                      ),
                                    )
                                    .map(
                                      (
                                        e: any,
                                      ) =>
                                        e
                                          .elements
                                          .length,
                                    )
                                    .toList().sum;
                                let order =
                                  indentWidth ==
                                    0
                                    ? _prevSubListSum +
                                    sectionIndex
                                    : offset +
                                    sectionIndex;
                                if (
                                  sectionIndex !=
                                  0
                                ) {
                                  _blockInlineSpan.push(
                                    '\n',
                                  );
                                }
                                let orderString =
                                  '';
                                if (
                                  richText.style ==
                                  'bullet'
                                ) {
                                  if (
                                    indent %
                                    3 ==
                                    0
                                  ) {
                                    orderString =
                                      '●  ';
                                  } else if (
                                    indent %
                                    3 ==
                                    1
                                  ) {
                                    orderString =
                                      '○  ';
                                  } else {
                                    orderString =
                                      '■  ';
                                  }
                                } else {
                                  if (
                                    indent %
                                    3 ==
                                    0
                                  ) {
                                    orderString =
                                      '${order + 1}. ';
                                  } else if (
                                    indent %
                                    3 ==
                                    1
                                  ) {
                                    let alphabets: string[] =
                                      [
                                        'a',
                                        'b',
                                        'c',
                                        'd',
                                        'e',
                                        'f',
                                        'g',
                                        'h',
                                        'i',
                                        'j',
                                        'k',
                                        'l',
                                        'm',
                                        'n',
                                        'o',
                                        'p',
                                        'q',
                                        'r',
                                        's',
                                        't',
                                        'u',
                                        'v',
                                        'w',
                                        'x',
                                        'y',
                                        'z',
                                      ];
                                    let number =
                                      order;
                                    let numbers: number[] =
                                      [];
                                    if (
                                      number ==
                                      0
                                    )
                                      numbers.push(
                                        0,
                                      );
                                    while (
                                      number !=
                                      0
                                    ) {
                                      let remain =
                                        number %
                                        26;
                                      numbers.push(
                                        numbers.length ==
                                          0
                                          ? remain
                                          : remain -
                                          1,
                                      );
                                      number =
                                        Math.floor(
                                          number /
                                          26,
                                        );
                                    }

                                    let reversed =
                                      numbers.reverse();
                                    reversed.forEach(
                                      (
                                        n,
                                      ) => {
                                        orderString +=
                                          alphabets[
                                          n %
                                          26
                                          ];
                                      },
                                    );
                                    orderString +=
                                      '. ';
                                  } else {
                                    orderString =
                                      '${order.toRomanNumeralString()?.toLowerCase()}. ';
                                  }
                                }
                                _blockInlineSpan.push(
                                  orderString,
                                );

                                section.elements.forEach(
                                  (
                                    element: any,
                                  ) => {
                                    _blockInlineSpan.push(
                                      getRichTextSnippet(
                                        element,
                                        slackData,
                                        channelData,
                                      ),
                                    );
                                  },
                                );

                                sectionIndex += 1;
                              },
                            );
                            inlineSpans =
                              inlineSpans.concat(
                                _blockInlineSpan,
                              );
                            break;

                          case 'rich_text_preformatted':
                          case 'rich_text_quote':
                          case 'mrkdwn':
                            inlineSpans =
                              inlineSpans.concat(
                                richText.elements
                                  .map(
                                    (
                                      element: any,
                                    ) =>
                                      getRichTextSnippet(
                                        element,
                                        slackData,
                                        channelData,
                                      ),
                                  )
                                  .toList(),
                              );
                            break;
                          case 'image':
                          case null:
                            break;
                        }

                        strings =
                          strings.concat(
                            inlineSpans,
                          );
                      },
                    );
                    break;
                  }
                  case 'context':
                    block.elements.forEach((e: any) => {
                      if (e.elementType == 'image') {
                        strings.push('(image)');
                      } else {
                        strings.push(e.text);
                      }
                    });
                    break;
                  case 'header':
                    strings.push(
                      block.text?.text ?? '',
                    );
                    break;
                  case 'section':
                    strings.push(
                      block.text?.text ?? '',
                    );
                    break;
                  case 'image':
                    strings.push('(image)');
                    break;
                  case 'video':
                    strings = strings.concat([
                      getRichTextSnippet(
                        {
                          type: 'text',
                          text:
                            block.description[
                            'text'
                            ] + '\n',
                        },
                        slackData,
                        channelData,
                      ),
                      getRichTextSnippet(
                        {
                          type: 'link',
                          text: block.title ?? [
                            'text',
                          ],
                          url: block.videoUrl,
                        },
                        slackData,
                        channelData,
                      ),
                    ]);
                    break;
                  default:
                    break;
                }
              });
            }

            attachments.forEach((attachment: any) => {
              strings = strings.concat([
                attachment.pretext ? attachment.pretext + ' ' : '',
                attachment.title ? attachment.title + ' ' : '',
                attachment.text ? attachment.text + ' ' : '',
              ]);
            });

            const pre = slackPretextToStringConverter(
              channelData['channel_id'],
              strings.join(''),
              true,
            );
            if (pre) snippet = pre;

            if (
              channelData['filter'] == 'all' ||
              (channelData['filter'] == 'mentions' &&
                text.includes(
                  '<@' + channelData['me'] + '>',
                ))
            ) {
              if (ts == eventTs) {
                const token =
                  user.n.fcm_token || user.n.device_id;
                if (channelData['me'].toLowerCase() != user_id.toLowerCase()) {
                  if (!sentToken.includes(token)) {
                    sentToken.push(token);
                    notificationImage[token] =
                      user.n.slack_notification_image[
                      team_id
                      ];
                    notificationBadge[token] =
                      (user.u.badge || 0) + 1;
                    notificationApnsToken[token] =
                      user.n.apns_token;
                    notificationUserId[token] =
                      user.n.user_id;
                    notificationPlatform[token] =
                      user.n.platform;
                  }
                }

              }
            }
          }
        }
      }
    });
  }

  for (let userId of sentUser) {
    const channel = supabase.channel(userId);
    await channel.send({
      type: 'broadcast',
      event: 'slack_changed',
      payload: { body, teamId: team_id },
    });
  }

  if (newNotificationData.length > 0) {
    await supabase.from('users').upsert(newNotificationData);
  }

  if (title && snippet) {
    await sendFcmWithData(
      sentToken.map((token) => {
        let data: sendFcmData = {
          fcmToken: token,
          apnsToken: notificationApnsToken[token],
          threadId: 'slack' + channel_id,
          userId: notificationUserId[token],
          platform: notificationPlatform[token],
          data: {
            type: 'slack_notification',
            event_id: ts,
            thread_id: threadTs || '',
            channel_id,
            team_id,
            imageUrl: notificationImage[token],
          },
          notification: {
            title: title,
            body: snippet,
            imageUrl: notificationImage[token],
          },
          subtitle: subtitle,
          subtitleSeparator: ': ',
          badge: notificationBadge[token] || 0,
        };
        return data;
      }),
    );
  }
}

