"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const node_fetch_1 = __importDefault(require("node-fetch"));
const ws_1 = require("ws");
const supabase_js_1 = require("@supabase/supabase-js");
const admin = __importStar(require("firebase-admin"));
const serviceAccount = require('../firebase.json');
const PORT = process.env.PORT || 8080;
const PROJECT_ID = process.env.PROJECT_ID;
const activeConnections = new Map();
admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
});
const db = admin.firestore();
clearCollection('slackconnection');
async function clearCollection(collectionPath, batchSize = 500) {
    const collectionRef = db.collection(collectionPath);
    const query = collectionRef.limit(batchSize);
    return new Promise((resolve, reject) => {
        deleteQueryBatch(query, resolve).catch(reject);
    });
}
async function deleteQueryBatch(query, resolve) {
    const snapshot = await query.get();
    if (snapshot.empty) {
        resolve();
        return;
    }
    const batch = db.batch();
    snapshot.docs.forEach(doc => {
        batch.delete(doc.ref);
    });
    await batch.commit();
    process.nextTick(() => {
        deleteQueryBatch(query, resolve);
    });
}
const chunkArray = (array, chunkSize) => {
    if (chunkSize <= 0)
        throw new Error('Chunk size must be greater than 0.');
    const results = [];
    for (let i = 0; i < array.length; i += chunkSize) {
        const chunk = array.slice(i, i + chunkSize);
        results.push(chunk);
    }
    return results;
};
const isDesktopData = (data) => {
    if (data.platform == 'windows')
        return true;
    if (data.platform == 'macos')
        return true;
    if (data.platform == 'linux')
        return true;
    return false;
};
const sendFcmWithData = async (data) => {
    const desktopData = data.filter((e) => isDesktopData(e));
    const notApnsData = data.filter((e) => !isDesktopData(e));
    const notApnsChunk = chunkArray(notApnsData.filter((e) => e.fcmToken), 500);
    await Promise.all([
        sendSupabaseMessage(desktopData),
        ...notApnsChunk.map((chunk) => sendFcm(chunk)),
    ]);
};
const sendSupabaseMessage = async (data) => {
    const supabase = (0, supabase_js_1.createClient)(process.env.SUPABASE_URL, process.env.SUPABASE_ANON_KEY);
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
const sendFcm = async (data) => {
    const result = await admin.messaging().sendEach(data.map((d) => {
        const message = {
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
    }));
    console.log('####### sendFcmResult:', result.responses.map((e) => e.error?.message));
};
function generateConnectionKey(userId, workspaceId) {
    return `${userId}|${workspaceId}`;
}
const app = (0, express_1.default)();
app.use(express_1.default.json());
app.post('/connect', async (req, res) => {
    const { userId, workspaceId, authorizationHeaders } = req.body;
    if (!authorizationHeaders) {
        return res.status(400).send('Missing authorization headers');
    }
    try {
        await connectSlack(userId, workspaceId, authorizationHeaders);
        res.status(200).send(`Connecting to Slack for ${userId}@${workspaceId}`);
    }
    catch (err) {
        console.error(err);
        res.status(500).send('Failed to connect');
    }
});
app.all('*', (req, res) => {
    res.status(404).send('Not Found');
});
async function connectSlack(userId, workspaceId, authorizationHeaders) {
    const connectionKey = generateConnectionKey(userId, workspaceId);
    if (activeConnections.has(connectionKey)) {
        console.log(`Already connected: ${userId}@${workspaceId}`);
        return;
    }
    const rtmResp = await (0, node_fetch_1.default)('https://slack.com/api/rtm.connect', {
        method: 'POST',
        headers: {
            ...authorizationHeaders,
            'Content-Type': 'application/x-www-form-urlencoded',
        },
    });
    const rtmData = await rtmResp.json();
    console.log('rtmResp:', rtmData);
    console.log('authorizationHeaders:', authorizationHeaders);
    if (!rtmData.ok) {
        console.error(`Failed to connect: ${rtmData.error}`);
        await updateFirestoreStatus(userId, workspaceId, 'error');
        return;
    }
    const wsUrl = rtmData.url;
    const ws = new ws_1.WebSocket(wsUrl, {
        headers: {
            ...authorizationHeaders,
            'Origin': 'https://api.slack.com',
        },
    });
    activeConnections.set(connectionKey, ws);
    console.log(`Connected WebSocket for ${userId}@${workspaceId}`);
    ws.on('message', async (data) => {
        console.log(`Message for ${userId}@${workspaceId}: ${data}`);
        const text = data.toString('utf-8');
        try {
            const json = JSON.parse(text);
            console.log('Parsed JSON:', json);
            handleslacknotificationcore({ event: json, rtm: true });
        }
        catch (error) {
            console.error('Error parsing WebSocket message:', text, error);
        }
    });
    ws.on('close', async () => {
        console.log(`Connection closed for ${userId}@${workspaceId}`);
        activeConnections.delete(connectionKey);
        await updateFirestoreStatus(userId, workspaceId, 'disconnected');
    });
    ws.on('error', async (error) => {
        console.error(`Connection error for ${userId}@${workspaceId}:`, error);
        activeConnections.delete(connectionKey);
        await updateFirestoreStatus(userId, workspaceId, 'error');
    });
    await updateFirestoreStatus(userId, workspaceId, 'connected');
}
async function updateFirestoreStatus(userId, workspaceId, status) {
    await admin.firestore().collection('slackconnection').doc(`${userId}_${workspaceId}`).set({
        status: status,
        updatedAt: new Date().toISOString(),
    });
}
app.listen(PORT, () => {
    console.log(`Listening on port ${PORT}`);
});
const handleslacknotificationcore = async (body) => {
    const supabase = (0, supabase_js_1.createClient)(process.env.SUPABASE_URL, process.env.SUPABASE_ANON_KEY);
    if (typeof body['event'] === 'string') {
        body['event'] = JSON.parse(body['event']);
    }
    const channel_id = body['event']['channel'];
    const type = body['event']['type'];
    const subtype = body['event']['subtype'];
    const text = body['event']['text'];
    const files = body['event']['files'] || [];
    const blocks = body['event']['blocks'] || [];
    const attachments = body['event']['attachments'] || [];
    const ts = body['event']['ts'];
    const team_id = body['event']['team'] ||
        ((body['event']['files'] || [])[0] || {})['user_team'];
    const user_id = body['event']['user'];
    const eventTs = body['event']['event_ts'];
    const threadTs = body['event']['thread_ts'];
    if (type == 'message' &&
        subtype != 'message_changed' &&
        subtype != 'message_deleted') {
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
    }
    console.log('team_id: ', team_id);
    let result = await supabase
        .rpc('get_slack_linked_user', { 'team_id': team_id })
        .returns();
    const sentToken = [];
    const sentUser = [];
    const notificationImage = {};
    const notificationBadge = {};
    const newNotificationData = [];
    const notificationApnsToken = {};
    const notificationUserId = {};
    const notificationPlatform = {};
    // 'channel_id': e.id,
    // 'channel_name': e.displayName,
    // 'filter': pref.prefMessageChannelNotificationFilterTypes['${key}${me?.email}']?.name,
    // 'team_id': key,
    // 'members': e.members.map((e) => {'id': e.id, 'name': e.displayName, 'image': e.profileImageLarge}).toList(),
    // 'me': me?.id,
    let title = '';
    let snippet = '';
    let subtitle;
    console.log('result: ', result);
    if (result.data && Array.isArray(result.data) && result.data.length > 0) {
        const mailLinkedUsers = result.data;
        mailLinkedUsers.forEach((user) => {
            if (!sentUser.includes(user.n.user_id)) {
                sentUser.push(user.n.user_id);
                newNotificationData.push({
                    id: user.n.user_id,
                    badge: (user.u.badge || 0) + 1,
                });
            }
            if (type == 'message' &&
                subtype != 'message_changed' &&
                subtype != 'message_deleted') {
                if (user.n.slack_data[team_id]) {
                    const slackData = user.n.slack_data[team_id];
                    const channelData = slackData.find((e) => e.channel_id.toLowerCase() == channel_id.toLowerCase());
                    if (channelData && channelData['me'] != user_id) {
                        const isChannel = channelData['is_channel'];
                        const channelName = isChannel
                            ? '#' + channelData['channel_name']
                            : channelData['channel_name'];
                        const userName = channelData['members'].find((e) => e.id.toLowerCase() == user_id.toLowerCase())['name'];
                        if (channelName == userName) {
                            title = channelName;
                        }
                        else {
                            title = channelName;
                            subtitle = userName;
                        }
                        const getRichTextSnippet = (element, channels, channelData) => {
                            if (element.type == null)
                                return '';
                            let strings = [];
                            switch (element.type) {
                                case 'channel':
                                    const channel = channels.find((e) => e.id == element['channel_id']);
                                    if (channel != null) {
                                        strings.push('#' + channel.name);
                                    }
                                    else {
                                        strings.push('#' + element['channel_id']);
                                    }
                                    break;
                                case 'emoji':
                                    if (element.unicode != null) {
                                        strings.push(String.fromCodePoint(parseInt(element.unicode, 16)));
                                    }
                                    else {
                                        strings.push(`:${element.name}:`);
                                    }
                                    break;
                                case 'link':
                                    strings.push(element.text ?? element.url ?? '');
                                    break;
                                case 'text':
                                    strings.push(element.text ?? '');
                                    break;
                                case 'user':
                                    const member = channelData.members.find((m) => m.id == element['user_id']);
                                    if (member != null) {
                                        strings.push('@' + member.name);
                                    }
                                    break;
                                case 'usergroup':
                                    const group = channelData.groups.find((m) => m.id == element['usergroup_id']);
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
                        const getOrdinalSuffix = (day) => {
                            if (!(day >= 1 && day <= 31)) {
                                throw new Error('Invalid day of the month');
                            }
                            if (day >= 11 && day <= 13)
                                return 'th';
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
                        const slackPretextToStringConverter = (channelId, text, showMentionTag) => {
                            const strings = [];
                            let lastMatchEnd = 0;
                            const combinedRegex = new RegExp('\\*<((?:https?:\\/\\/[^\\s|>]+))(?:\\|([^>]*))?>\\*' + // 링크 굵게
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
                            'g');
                            // Process text using regular expressions
                            const matches = [
                                ...text.matchAll(combinedRegex),
                            ];
                            for (const match of matches) {
                                if (match.index > lastMatchEnd) {
                                    const substring = text.substring(lastMatchEnd, match.index);
                                    strings.push(substring);
                                }
                                if (match[1] !== undefined &&
                                    match[2] !== undefined) {
                                    // Bold link processing
                                    const displayText = match[2];
                                    strings.push(displayText);
                                }
                                else if (match[3] !== undefined &&
                                    match[4] !== undefined) {
                                    // Link processing
                                    const displayText = match[4];
                                    strings.push(displayText);
                                }
                                else if (match[5] !== undefined &&
                                    match[6] !== undefined) {
                                    // Code block processing
                                    const displayText = match[6];
                                    strings.push(displayText);
                                }
                                else if (match[7] !== undefined) {
                                    // Emoji processing
                                    const emojiText = match[7];
                                    strings.push(emojiText);
                                }
                                else if (match[8] !== undefined) {
                                    // Italic processing
                                    const italicText = match[8];
                                    strings.push(italicText);
                                }
                                else if (match[9] !== undefined) {
                                    // Bold processing
                                    const boldText = match[9];
                                    strings.push(boldText);
                                }
                                else if (match[10] !== undefined) {
                                    // Strikethrough processing
                                    const strikeText = match[10];
                                    strings.push(strikeText);
                                }
                                else if (match[11] !== undefined) {
                                    // Mention processing
                                    const mentionText = match[11];
                                    const channel = slackData.find((e) => e.id === channelId);
                                    const member = channel.members.find((m) => m.id === mentionText);
                                    strings.push(`${showMentionTag ? '@' : ''}${member?.displayName}`);
                                }
                                else if (match[12] !== undefined &&
                                    match[13] !== undefined &&
                                    match[14] !== undefined) {
                                    const timestamp = parseInt(match[12]);
                                    const formatString = match[13];
                                    const fallbackText = match[14];
                                    const isTime = formatString === 'time';
                                    const isDateShort = formatString ===
                                        'date_short_pretty';
                                    const isDateLong = formatString === 'date_long_pretty';
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
                                                })} ${getOrdinalSuffix(date.getDate())}`
                                                : fallbackText;
                                    strings.push(` ${formattedDate} `);
                                }
                                else if (match[15] !== undefined) {
                                    // Markdown processing
                                    const displayText = match[15];
                                    strings.push(displayText);
                                }
                                else if (match[16] !== undefined) {
                                    // Channel mention processing
                                    const channelText = match[16];
                                    const channel = slackData.find((e) => e.id === channelText);
                                    strings.push(`${showMentionTag ? '#' : ''}${channel.name}`);
                                }
                                lastMatchEnd =
                                    match.index + match[0].length;
                            }
                            // Process text after the last match
                            if (lastMatchEnd < text.length) {
                                strings.push(text.substring(lastMatchEnd));
                            }
                            return strings.join('');
                        };
                        let strings = [];
                        if (blocks.isEmpty) {
                            switch (subtype) {
                                case 'channel_join':
                                case 'group_join':
                                    strings.push('joined #' + channelName);
                                    break;
                                case 'channel_archive':
                                case 'group_archive':
                                    strings.push('archived #' +
                                        channelName +
                                        '. The contents will still be browsable and available in search.');
                                    break;
                                case 'channel_name':
                                case 'channel_topic':
                                case 'channel_purpose':
                                case 'group_topic':
                                case 'group_name':
                                case 'group_purpose':
                                    if (text?.isNotEmpty == true)
                                        strings.push(text);
                                    break;
                                case 'channel_unarchive':
                                case 'group_unarchive':
                                    strings.push('unarchived #' + channelName);
                                    break;
                                case 'channel_leave':
                                case 'group_leave':
                                    strings.push('left #' + channelName);
                                    break;
                                default:
                                    if (text?.isNotEmpty == true) {
                                        strings.push(text);
                                    }
                                    else {
                                        const fileNames = files?.map((e) => e.name);
                                        strings = strings.concat(fileNames);
                                    }
                                    break;
                            }
                        }
                        else {
                            blocks.forEach((block) => {
                                switch (block.type) {
                                    case 'divider':
                                        break;
                                    case 'rich_text': {
                                        block.elements.forEach((richText) => {
                                            let inlineSpans = [];
                                            switch (richText['type']) {
                                                case 'rich_text_section':
                                                    richText.elements.forEach((element) => {
                                                        inlineSpans.push(getRichTextSnippet(element, slackData, channelData));
                                                    });
                                                    break;
                                                case 'rich_text_list':
                                                    let _blockInlineSpan = [];
                                                    let indent = richText.indent;
                                                    let indentWidth = indent * 16;
                                                    let sectionIndex = 0;
                                                    richText.elements.forEach((section) => {
                                                        let offset = richText.offset;
                                                        let _prevList = block.elements
                                                            .where((r) => r.indent ==
                                                            richText.indent)
                                                            .toList();
                                                        let _prevSubListSum = _prevList
                                                            .sublist(0, _prevList.indexOf(richText))
                                                            .map((e) => e
                                                            .elements
                                                            .length)
                                                            .toList().sum;
                                                        let order = indentWidth ==
                                                            0
                                                            ? _prevSubListSum +
                                                                sectionIndex
                                                            : offset +
                                                                sectionIndex;
                                                        if (sectionIndex !=
                                                            0) {
                                                            _blockInlineSpan.push('\n');
                                                        }
                                                        let orderString = '';
                                                        if (richText.style ==
                                                            'bullet') {
                                                            if (indent %
                                                                3 ==
                                                                0) {
                                                                orderString =
                                                                    '●  ';
                                                            }
                                                            else if (indent %
                                                                3 ==
                                                                1) {
                                                                orderString =
                                                                    '○  ';
                                                            }
                                                            else {
                                                                orderString =
                                                                    '■  ';
                                                            }
                                                        }
                                                        else {
                                                            if (indent %
                                                                3 ==
                                                                0) {
                                                                orderString =
                                                                    '${order + 1}. ';
                                                            }
                                                            else if (indent %
                                                                3 ==
                                                                1) {
                                                                let alphabets = [
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
                                                                let number = order;
                                                                let numbers = [];
                                                                if (number ==
                                                                    0)
                                                                    numbers.push(0);
                                                                while (number !=
                                                                    0) {
                                                                    let remain = number %
                                                                        26;
                                                                    numbers.push(numbers.length ==
                                                                        0
                                                                        ? remain
                                                                        : remain -
                                                                            1);
                                                                    number =
                                                                        Math.floor(number /
                                                                            26);
                                                                }
                                                                let reversed = numbers.reverse();
                                                                reversed.forEach((n) => {
                                                                    orderString +=
                                                                        alphabets[n %
                                                                            26];
                                                                });
                                                                orderString +=
                                                                    '. ';
                                                            }
                                                            else {
                                                                orderString =
                                                                    '${order.toRomanNumeralString()?.toLowerCase()}. ';
                                                            }
                                                        }
                                                        _blockInlineSpan.push(orderString);
                                                        section.elements.forEach((element) => {
                                                            _blockInlineSpan.push(getRichTextSnippet(element, slackData, channelData));
                                                        });
                                                        sectionIndex += 1;
                                                    });
                                                    inlineSpans =
                                                        inlineSpans.concat(_blockInlineSpan);
                                                    break;
                                                case 'rich_text_preformatted':
                                                case 'rich_text_quote':
                                                case 'mrkdwn':
                                                    inlineSpans =
                                                        inlineSpans.concat(richText.elements
                                                            .map((element) => getRichTextSnippet(element, slackData, channelData))
                                                            .toList());
                                                    break;
                                                case 'image':
                                                case null:
                                                    break;
                                            }
                                            strings =
                                                strings.concat(inlineSpans);
                                        });
                                        break;
                                    }
                                    case 'context':
                                        block.elements.forEach((e) => {
                                            if (e.elementType == 'image') {
                                                strings.push('(image)');
                                            }
                                            else {
                                                strings.push(e.text);
                                            }
                                        });
                                        break;
                                    case 'header':
                                        strings.push(block.text?.text ?? '');
                                        break;
                                    case 'section':
                                        strings.push(block.text?.text ?? '');
                                        break;
                                    case 'image':
                                        strings.push('(image)');
                                        break;
                                    case 'video':
                                        strings = strings.concat([
                                            getRichTextSnippet({
                                                type: 'text',
                                                text: block.description['text'] + '\n',
                                            }, slackData, channelData),
                                            getRichTextSnippet({
                                                type: 'link',
                                                text: block.title ?? [
                                                    'text',
                                                ],
                                                url: block.videoUrl,
                                            }, slackData, channelData),
                                        ]);
                                        break;
                                    default:
                                        break;
                                }
                            });
                        }
                        attachments.forEach((attachment) => {
                            strings = strings.concat([
                                attachment.pretext ? attachment.pretext + ' ' : '',
                                attachment.title ? attachment.title + ' ' : '',
                                attachment.text ? attachment.text + ' ' : '',
                            ]);
                        });
                        const pre = slackPretextToStringConverter(channelData['channel_id'], strings.join(''), true);
                        if (pre)
                            snippet = pre;
                        if (channelData['filter'] == 'all' ||
                            (channelData['filter'] == 'mentions' &&
                                text.includes('<@' + channelData['me'] + '>'))) {
                            if (ts == eventTs) {
                                const token = user.n.fcm_token || user.n.device_id;
                                if (!sentToken.includes(token)) {
                                    sentToken.push(token);
                                    notificationImage[token] =
                                        user.n.slack_notification_image[team_id];
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
    console.log('sentUser: ', sentUser);
    if (newNotificationData.length > 0) {
        await supabase.from('users').upsert(newNotificationData);
    }
    if (title && snippet) {
        await sendFcmWithData(sentToken.map((token) => {
            let data = {
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
        }));
    }
};
