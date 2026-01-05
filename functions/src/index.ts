import { createClient } from '@supabase/supabase-js';
import { Buffer } from 'node:buffer';
import * as crypto from 'node:crypto';

import { PubSub } from '@google-cloud/pubsub';
import { ApnsClient, Notification, NotificationOptions } from 'apns2';
import dayjs from 'dayjs';
import * as admin from 'firebase-admin';
import { defineString } from 'firebase-functions/params';
import * as v2 from 'firebase-functions/v2';
import { unescape } from 'html-escaper';
import { parse } from 'node:url';
import { v4 as uuidv4 } from 'uuid';

const serviceAccount = require('./firebase.json');
const gmail = require('@googleapis/gmail');

admin.initializeApp({
	credential: admin.credential.cert(serviceAccount),
});

const prodClient = new ApnsClient({
	team: 'V4MN45XSYF',
	keyId: '7LHHJRX2UF',
	signingKey: defineString('APNS_KEY').value(),
	defaultTopic: `com.wavetogether.fillin`,
	requestTimeout: 0, // optional, Default: 0 (without timeout)
	keepAlive: true, // optional, Default: 5000
});

const devClient = new ApnsClient({
	host: 'api.sandbox.push.apple.com',
	team: 'V4MN45XSYF',
	keyId: '7LHHJRX2UF',
	signingKey: defineString('APNS_KEY').value(),
	defaultTopic: `com.wavetogether.fillin`,
	requestTimeout: 0, // optional, Default: 0 (without timeout)
	keepAlive: true, // optional, Default: 5000
});

type sendFcmData = {
	apnsToken: string | undefined;
	fcmToken: string;
	userId: string;
	platform: string;
	threadId?: string | undefined;
	data: { [key: string]: string };
	notification?: { title: string; body: string; imageUrl?: string } | undefined;
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

// Decrypt AES CryptoJS format (compatible with Dart implementation)
const decryptAESCryptoJS = (encrypted: string, passphrase: string): string => {
	try {
		// Base64 decode
		const encryptedBytesWithSalt = Buffer.from(encrypted, 'base64');
		
		// Check for "Salted__" header (8 bytes)
		const header = encryptedBytesWithSalt.subarray(0, 8);
		if (header.toString('ascii') !== 'Salted__') {
			throw new Error('Invalid encrypted data format');
		}
		
		// Extract salt (8-16 bytes)
		const salt = encryptedBytesWithSalt.subarray(8, 16);
		
		// Extract encrypted data (16 bytes onwards)
		const encryptedBytes = encryptedBytesWithSalt.subarray(16);
		
		// Derive key and IV using MD5 (same as Dart implementation)
		const { key, iv } = deriveKeyAndIV(passphrase, salt);
		
		// Decrypt using AES CBC mode
		const decipher = crypto.createDecipheriv('aes-256-cbc', key as any, iv as any);
		decipher.setAutoPadding(true); // PKCS7 padding
		
		let decrypted = decipher.update(encryptedBytes as any);
		decrypted = Buffer.concat([decrypted, decipher.final() as any]);
		
		return decrypted.toString('utf8');
	} catch (error) {
		throw error;
	}
};

// Derive key and IV from passphrase and salt (same as Dart implementation)
const deriveKeyAndIV = (passphrase: string, salt: Buffer): { key: Buffer; iv: Buffer } => {
	const password = Buffer.from(passphrase, 'utf8');
	let concatenatedHashes = Buffer.alloc(0);
	let currentHash = Buffer.alloc(0);
	let enoughBytesForKey = false;
	
	while (!enoughBytesForKey) {
		let preHash: Buffer;
		if (currentHash.length > 0) {
			preHash = Buffer.concat([currentHash, password, salt] as any);
		} else {
			preHash = Buffer.concat([password, salt] as any);
		}
		
		currentHash = crypto.createHash('md5').update(preHash as any).digest() as Buffer;
		concatenatedHashes = Buffer.concat([concatenatedHashes, currentHash] as any);
		
		if (concatenatedHashes.length >= 48) {
			enoughBytesForKey = true;
		}
	}
	
	const keyBytes = concatenatedHashes.subarray(0, 32);
	const ivBytes = concatenatedHashes.subarray(32, 48);
	
	return { key: keyBytes, iv: ivBytes };
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
	const supabase = createClient(
		defineString('SUPABASE_URL').value(),
		defineString('SUPABASE_ANON_KEY').value(),
	);
	data.forEach(async (d) => {
		if (d.notification) {
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
		}

	});
};

const sendApns = async (data: sendFcmData[]) => {
	const notifications = data.filter((e) => e.notification).map((d) => {
		const options: NotificationOptions = {
			mutableContent: true,
			badge: d.platform == 'macos' ? 0 : d.badge,
			sound: 'default',
			threadId: d.threadId,
			expiration: Math.floor(Date.now() / 1000) + 3600,
			alert: {
				title: d.notification!.title,
				body: d.notification!.body,
				subtitle: d.subtitle,
			},
			data: {
				'gcm.message_id': uuidv4(),
				fcm_options: {
					image: d.notification!.imageUrl,
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
		} catch (err: any) {
			// Error handled silently
		}
	});
};

const sendDevApns = async (data: sendFcmData[]) => {
	const notifications = data.filter((e) => e.notification).map((d) => {
		const options: NotificationOptions = {
			mutableContent: true,
			badge: d.platform == 'macos' ? 0 : d.badge,
			sound: 'default',
			threadId: d.threadId,
			expiration: Math.floor(Date.now() / 1000) + 3600,
			alert: {
				title: d.notification!.title,
				body: d.notification!.body,
				subtitle: d.subtitle,
			},
			data: {
				'gcm.message_id': uuidv4(),
				fcm_options: {
					image: d.notification!.imageUrl,
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
		} catch (err: any) {
			// Error handled silently
		}
	});
};

const sendFcm = async (data: sendFcmData[]) => {
	await admin.messaging().sendEach(
		data.map((d) => {
			if (d.notification) {
				return {
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
				};
			}

			// silent push
			return {
				token: d.fcmToken,
				data: d.data,
				android: {
					priority: 'high',
				},
				apns: {
					headers: {
						'apns-priority': '10',
						'apns-push-type': 'background',
					},
					payload: {
						aps: {
							contentAvailable: true,
						},
					},
				},
			};

		}),
	);
};

export const handlegooglecalendarnotification = v2.https.onRequest(
	{
		minInstances: 1,
	},
	async (request, response) => {
		const supabase = createClient(
			defineString('SUPABASE_URL').value(),
			defineString('SUPABASE_ANON_KEY').value(),
		);

		const calendarId = request.header('x-goog-channel-token');
		const channelId = request.header('x-goog-channel-id');
		const userId = channelId?.substring(0, 36).split('_').join('-');

		if (userId && calendarId) {
			const channel = supabase.channel(userId);
			await channel.send({
				type: 'broadcast',
				event: 'gcal_changed',
				payload: { calendarId: calendarId, userId: userId },
			});
		}

		response.send(
			JSON.stringify({
				type: 'broadcast',
				event: 'gcal_changed',
				payload: { calendarId: calendarId, userId: userId },
			}),
		);
	},
);


export const handleoutlookcalendarnotification = v2.https.onRequest(
	{
		minInstances: 1,
	},
	async (req, res) => {
		const url = parse(req.url, true); // parse full URL including query
		const token = url.query.validationToken as string | undefined;


		if (token) {
			// 필수! Content-Type 반드시 text/plain
			res.set("Content-Type", "text/plain");
			res.status(200).send(token);
			return;
		}


		const supabase = createClient(
			defineString('SUPABASE_URL').value(),
			defineString('SUPABASE_ANON_KEY').value(),
		);

		const resource: string = req.body['value'][0]['resource'];
		const userId: string = req.body['value'][0]['clientState'];
		const eventId: string = resource.split('/Events/')[1];

		if (userId && eventId) {
			const channel = supabase.channel(userId);
			await channel.send({
				type: 'broadcast',
				event: 'outlook_cal_changed',
				payload: { eventId: eventId, userId: userId },
			});
		}

		res.sendStatus(202);
	},
);

type Reminders = {
	id: string;
	title: string;
	minutes: number;
	u: {
		id: string;
		badge: number;
	};
	n: {
		id: string;
		fcm_token: string;
		apns_token: string | undefined;
		device_id: string;
		user_id: string;
		platform: string;
		linked_google_calendars: string[];
		gmail_server_code: { [key: string]: string };
		gmail_notification_image: { [key: string]: string };
		gcal_notification_image: { [key: string]: string };
		slack_notification_image: { [key: string]: string };
		show_task_notification: boolean;
		show_calendar_notification: { [key: string]: boolean };
		show_gmail_notification: { [key: string]: string[] };
	};
	calendar_id: string;
	calendar_name: string;
	provider: string;
	target_date_time: string;
	locale: string;
	event_id: string;
	device_id: string;
	start_date: string;
	end_date: string;
	is_all_day: boolean;
	is_encrypted: boolean;
	iv: string;
};

export const scheduledfcmcalendargoogle = v2.scheduler.onSchedule(
	'* * * * *',
	async (_) => {
		fetch('https://slack-rtm-server.fly.dev/ping');

		const supabase = createClient(
			defineString('SUPABASE_URL').value(),
			defineString('SUPABASE_ANON_KEY').value(),
		);

		const reminderResponse = await supabase
			.rpc('get_this_minutes_notification')
			.returns<Reminders[]>();
		const sentReminders: Reminders[] = [];
		if (reminderResponse.data && reminderResponse.data.length > 0) {
			const reminders = reminderResponse.data;
			const notificationImage: { [key: string]: string } = {};
			const notificationBadge: { [key: string]: number } = {};
			const newNotificationData: { [key: string]: any }[] = [];
			const sentUser: string[] = [];

			reminders.forEach((reminder) => {
				const token = reminder.n.fcm_token || reminder.n.device_id;

				if (
					!sentReminders
						.map((p) => {
							const _token = p.n.fcm_token || p.n.device_id;
							return _token + p.event_id + p.calendar_id;
						})
						.includes(
							token + reminder.event_id + reminder.calendar_id,
						)
				) {
					if (
						(reminder.calendar_id == 'taskCalendarId' &&
							reminder.n.show_task_notification != false) ||
						(reminder.n.linked_google_calendars &&
							reminder.n.linked_google_calendars.includes(
								reminder.calendar_id,
							) &&
							reminder.n.show_calendar_notification[
							reminder.calendar_id
							] != false)
					) {
						if (reminder.start_date != reminder.end_date) {
							if (!sentUser.includes(reminder.n.user_id)) {
								sentUser.push(reminder.n.user_id);

								newNotificationData.push({
									id: reminder.n.user_id,
									badge: (reminder.u.badge || 0) + 1,
									token: token,
								});
							}

							sentReminders.push(reminder);
							notificationImage[token] =
								reminder.n.gcal_notification_image[
								reminder.calendar_id
								];
							notificationBadge[token] = (reminder.u.badge || 0) + 1;
						}
					}
				}
			});

			const filteredNewNotificationData = newNotificationData.filter(e => sentReminders.map(r => r.n.fcm_token || r.n.device_id).includes(e.token));
			if (filteredNewNotificationData.length > 0) {
				await supabase.from('users').upsert(filteredNewNotificationData);
			}

			const aesKey = defineString('AES_KEY').value();
			await sendFcmWithData(
				sentReminders.map((r) => {
					var title: string = r.title;
					if (r.is_encrypted) {
						try {
							title = decryptAESCryptoJS(r.title, aesKey);
							
							// If decryption failed (empty string), use calendar name as fallback
							if (!title || title.trim() === '') {
								title = r.calendar_name || 'Event';
							}
						} catch (e) {
							// Decryption error, use calendar name as fallback
							title = r.calendar_name || 'Event';
						}
					} else {
						// Not encrypted, but check if empty
						if (!title || title.trim() === '') {
							title = r.calendar_name || 'Event';
						}
					}

					const startDate = dayjs(r.start_date);
					const endDate = dayjs(r.end_date);


					var body = `${r.minutes} min later`;
					if (r.is_all_day) {
						if (startDate.isSame(endDate, 'day')) {
							body = startDate.format('MMM D');
						} else {
							body = `${startDate.format(
								'MMM D',
							)} - ${endDate.format('MMM D')}`;
						}
					} else {
						if (r.minutes == 0) {
							body = ``;
						} else if (r.minutes < 60) {
							body = `Starts in ${r.minutes} minutes!`;
						} else if (r.minutes == 60) {
							body = `Starts in 1 hour!`;
						} else if (r.minutes < 60 * 24 && r.minutes % 60 == 0) {
							body = `Starts in ${Math.floor(
								r.minutes / 60,
							)} hours!`;
						} else if (r.minutes < 60 * 24) {
							body = `Starts in ${Math.floor(
								r.minutes / 60,
							)} hours ${r.minutes % 60} minutes!`;
						} else if (r.minutes == 60 * 24) {
							body = `Starts in 1 day!`;
						} else if (
							r.minutes < 60 * 24 * 2 &&
							r.minutes % 60 == 0
						) {
							if (r.minutes - 60 * 24 == 60) {
								body = `Starts in 1 day 1 hours!`;
							} else {
								body = `Starts in 1 day ${Math.floor(
									(r.minutes - 60 * 24) / 60,
								)} hours!`;
							}
						} else if (r.minutes < 60 * 24 * 2) {
							body = `Starts in 1 day ${Math.floor(
								(r.minutes - 60 * 24) / 60,
							)} hours ${(r.minutes - 60 * 24) % 60} minutes!`;
						} else if (r.minutes % (60 * 24) == 0) {
							body = `Starts in ${Math.floor(
								r.minutes / 60 / 24,
							)} days!`;
						} else if (r.minutes % (60 * 24) == 60) {
							body = `Starts in ${Math.floor(
								r.minutes / 60 / 24,
							)} days 1 hour!`;
						} else if (r.minutes % (60 * 24) < 120) {
							body = `Starts in ${Math.floor(
								r.minutes / 60 / 24,
							)} days 1 hour ${Math.floor(
								(r.minutes % (60 * 24)) % 60,
							)} minutes!`;
						} else if (r.minutes % 60 == 0) {
							body = `Starts in ${Math.floor(
								r.minutes / 60 / 24,
							)} days ${Math.floor(
								(r.minutes % (60 * 24)) / 60,
							)} hours!`;
						} else {
							body = `Starts in ${Math.floor(
								r.minutes / 60 / 24,
							)} days ${Math.floor(
								(r.minutes % (60 * 24)) / 60,
							)} hours ${(r.minutes % (60 * 24)) % 60} minutes!`;
						}

						if (startDate.isSame(endDate, 'day')) {
							body = `${body ? body + '\n' : body
								}${startDate.format(
									`MMM D, h${startDate.minute() == 0 ? '' : ':mm'} A`,
								)} – ${endDate.format(`h${endDate.minute() == 0 ? '' : ':mm'} A`)}`;
						} else {
							body = `${body ? body + '\n' : body
								}${startDate.format(
									`MMM D, h${startDate.minute() == 0 ? '' : ':mm'} A`,
								)} – ${endDate.format(`MMM D, h${endDate.minute() == 0 ? '' : ':mm'} A`)}`;
						}
					}

					const token = r.n.fcm_token || r.n.device_id;
					// Use the notification image for this specific calendar_id, not just the token
					const notificationImageUrl = r.n.gcal_notification_image?.[r.calendar_id];
					let data: sendFcmData = {
						apnsToken: r.n.apns_token,
						fcmToken: token,
						threadId: 'calendar' + r.calendar_id,
						userId: r.n.user_id,
						platform: r.n.platform,
						data: {
							type: 'calendar_reminder',
							reminder: JSON.stringify({
								provider: r.provider,
								event_id: r.event_id,
								date:
									Date.parse(r.target_date_time) +
									r.minutes * 60 * 1000,
								calendar_id: r.calendar_id,
							}),
						},
						notification: {
							title: title,
							body: body,
							imageUrl: notificationImageUrl,
						},
						subtitle: undefined,
						subtitleSeparator: undefined,
						badge: notificationBadge[token] || 0,
					};
					return data;
				}),
			);

			await supabase
				.from('calendar_reminder')
				.delete()
				.in(
					'id',
					reminders.map((reminder) => reminder.id),
				);
		}
	},
);

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
		outlook_mail_server_code: { [key: string]: string };
		gmail_notification_image: { [key: string]: string };
		gcal_notification_image: { [key: string]: string };
		slack_notification_image: { [key: string]: string };
		outlook_mail_notification_image: { [key: string]: string };
		show_gmail_notification: { [key: string]: string[] };
		show_outlook_mail_notification: { [key: string]: string[] };
		show_slack_notification: { [key: string]: string };
		token_slack_teams: string[];
	};
};

export const handleslacknotification = v2.https.onRequest(
	{
		timeoutSeconds: 2,
		memory: '512MiB',
		minInstances: 1,
	},
	async (request, response) => {
		new PubSub().topic('slack-notification').publishJSON({
			...request.body,
			'event': {
				...request.body.event,
				'team': request.body.event.team || request.body.team_id,
			}
		});

		if (request.body.event.type === 'presence_change') {
			const presenceUpdateUrl = 'https://slack-rtm-server.fly.dev/presence/update';
			if (request.body.event.user) {
				const body = {
					workspaceId: request.body.team_id,
					users: [request.body.event.user],
					presence: request.body.event.presence,
				};
				await fetch(presenceUpdateUrl, {
					method: 'POST',
					body: JSON.stringify(body),
				});
			} else if (request.body.event.users) {
				const body = {
					workspaceId: request.body.team_id,
					users: request.body.event.users,
					presence: request.body.event.presence,
				};
				await fetch(presenceUpdateUrl, {
					method: 'POST',
					body: JSON.stringify(body),
				});
			}
		}
		response.sendStatus(200);
	},
);


export const handleoutlookmailnotification = v2.https.onRequest(
	{
		memory: '512MiB',
		minInstances: 1,
	},
	async (req, res) => {
		const url = parse(req.url, true); // parse full URL including query
		const token = url.query.validationToken as string | undefined;

		if (token) {
			// 필수! Content-Type 반드시 text/plain
			res.set("Content-Type", "text/plain");
			res.status(200).send(token);
			return;
		}

		const changeType = req.body['value'][0]['changeType'];
		const isCreated = changeType === 'created';
		const user_mail = req.body['value'][0]['clientState'];
		const messageId = req.body['value'][0]['resourceData']['id'];

		const supabase = createClient(
			defineString('SUPABASE_URL').value(),
			defineString('SUPABASE_ANON_KEY').value(),
		);

		let response = await supabase
			.rpc('get_outlook_mail_linked_user', { user_mail })
			.returns<NotificationUser[]>();


		const sentToken: string[] = [];
		const sentUser: string[] = [];
		const notificationImage: { [key: string]: string } = {};
		const notificationApnsToken: { [key: string]: string | undefined } =
			{};
		const notificationBadge: { [key: string]: number } = {};
		const notificationLabels: { [key: string]: string[] } = {};
		const notificationUserId: { [key: string]: string } = {};
		const notificationPlatform: { [key: string]: string } = {};

		let serverCode: string | null = null;
		let serverRedirectUrl: string | null = null;
		let serverCodeNotificationId: string | null = null;
		let serverCodeFullData: { [key: string]: string } = {};
		const newNotificationData: { [key: string]: any }[] = [];

		if (response.data && response.data.length > 0) {
			const mailLinkedUsers = response.data;
			mailLinkedUsers.forEach((user) => {
				const token = user.n.fcm_token || user.n.device_id;
				if (!sentToken.includes(token)) {
					try {
						notificationImage[token] =
							user.n.outlook_mail_notification_image[user_mail];
						notificationBadge[token] = (user.u.badge || 0) + 1;
						notificationLabels[token] =
							user.n.show_outlook_mail_notification[user_mail];
						notificationApnsToken[token] = user.n.apns_token;
						notificationUserId[token] = user.n.user_id;
						notificationPlatform[token] = user.n.platform;
						sentToken.push(token);
					} catch (e) {
						// Error handled silently
					}
				}

				if (!sentUser.includes(user.n.user_id)) {
					sentUser.push(user.n.user_id);

					newNotificationData.push({
						id: user.n.user_id,
						badge: (user.u.badge || 0) + 1,
						token: token,
					});
				}

				try {
					if (user.n.outlook_mail_server_code[user_mail] && user.n.platform != 'web') {
						serverCode = user.n.outlook_mail_server_code[user_mail];
						serverCodeNotificationId = user.n.id;
						serverCodeFullData = user.n.outlook_mail_server_code;
						serverRedirectUrl = user.n.platform == 'windows' ? 'https://azukhxinzrivjforwnsc.supabase.co/functions/v1/microsoft_auth' : 'com.wavetogether.fillin://auth';
					}
				} catch (e) {
					// Error handled silently
				}

			});
		}

		for (let userId of sentUser) {
			const channel = supabase.channel(userId);
			await channel.send({
				type: 'broadcast',
				event: 'outlook_mail_changed',
				payload: { messageId: messageId, email: user_mail, changeType: changeType },
			});
		}



		if (!isCreated) {
			res.sendStatus(202);
			return;
		}

		if (!serverCode) {
			res.sendStatus(400);
			return;
		}

		try {
			const credentialsData =
				typeof serverCode === 'string' ? JSON.parse(serverCode) : serverCode;
			const credentials = credentialsData.data ?? credentialsData;
			var accessToken = credentials.accessToken;
			var refreshToken = credentials.refreshToken;


			// ✅ 만료 확인: expiry_date가 없거나, 현재 시각보다 과거면 만료로 간주
			const isExpired =
				!credentials.expiry ||
				Date.parse(credentials.expiry) <= Date.now();

			if (isExpired) {
				const tokenUrl = 'https://login.microsoftonline.com/common/oauth2/v2.0/token'; // 예시 URL
				const clientId = defineString('OUTLOOK_CLIENT_ID').value();
				const redirectUrl = serverRedirectUrl || defineString('OUTLOOK_REDIRECT_URL').value();
				const scope = ['openid', 'profile', 'offline_access', 'User.Read', 'Mail.ReadWrite', 'Mail.Send'];

				const params = new URLSearchParams();
				params.append('client_id', clientId);
				params.append('grant_type', 'refresh_token');
				params.append('refresh_token', refreshToken);
				params.append('redirect_uri', redirectUrl);
				params.append('scope', scope.join(' '));

				const response = await fetch(tokenUrl, {
					method: 'POST',
					headers: {
						'Content-Type': 'application/x-www-form-urlencoded'
					},
					body: params.toString()
				});

				if (response.ok) {
					const data = await response.json();
					const newAccessToken = data['access_token'];
					const type = data['token_type'];
					const expiresIn = data['expires_in'];
					const newRefreshToken = data['refresh_token'];
					const now = new Date();
					const expiresAt = new Date(now.getTime() + expiresIn * 1000);

					accessToken = {
						type,
						data: newAccessToken,
						expiry: expiresAt.toISOString()
					};
					refreshToken = newRefreshToken;
				} else {
					return;
				}


				try {
					await supabase
						.from('notification')
						.update({
							outlook_mail_server_code: {
								...serverCodeFullData,
								[user_mail]: JSON.stringify({
									'accessToken': accessToken,
									'refreshToken': refreshToken,
								}),
							},
						})
						.eq('id', serverCodeNotificationId);
				} catch (updateErr) {
					// Error handled silently
				}
			}
		} catch (error) {
			return;
		}

		const inboxFolderIdRes = await fetch(`https://graph.microsoft.com/v1.0/me/mailFolders/inbox`, {
			headers: {
				'Authorization': `Bearer ${accessToken.data}`,
			},
		});
		const inboxFolderIdData = await inboxFolderIdRes.json();
		const inboxFolderId = inboxFolderIdData.id;

		const messageRes = await fetch(`https://graph.microsoft.com/v1.0/me/messages/${messageId}`, {
			headers: {
				'Authorization': `Bearer ${accessToken.data}`,
			},
		});
		const messageData = await messageRes.json();

		function isLikelyNewMessage(
			created: Date,
			modified: Date,
			toleranceMs: number = 5000
		): boolean {
			const diff = Math.abs(created.getTime() - modified.getTime());
			return diff <= toleranceMs;
		}

		const isNew = isLikelyNewMessage(new Date(messageData.createdDateTime), new Date(messageData.lastModifiedDateTime)); // true

		if (!isNew) {
			res.sendStatus(202);
			return;
		}

		const subject = messageData.subject;
		const fromName = messageData.from.emailAddress.name;
		const fromEmail = messageData.from.emailAddress.address;
		const fromString = fromName != '' ? fromName || fromEmail : fromEmail;
		const snippet = messageData.bodyPreview;
		const unescapedString = unescape(snippet);
		const body = unescapedString ?? snippet;
		const labelIds = messageData.parentFolderId == inboxFolderId || messageData.parentFolderId == 'INBOX'
			? ['INBOX']
			: [messageData.parentFolderId];

		const filteredNewNotificationData = newNotificationData.filter(e => sentToken.includes(e.token));
		if (filteredNewNotificationData.length > 0) {
			await supabase.from('users').upsert(filteredNewNotificationData);
		}

		await sendFcmWithData(
			sentToken.map((token) => {
				const filterLabelIds = notificationLabels[
					token
				] || ['INBOX'];
				let enabled = false;
				filterLabelIds.forEach((id) => {
					if (labelIds.includes(id)) {
						enabled = true;
					}
				});

				let data: sendFcmData = {
					fcmToken: enabled ? token : '',
					apnsToken: enabled
						? notificationApnsToken[token]
						: undefined,
					threadId: 'outlook_mail' + user_mail,
					userId: notificationUserId[token],
					platform: notificationPlatform[token],
					data: {
						type: 'outlook_mail_notification',
						email: user_mail,
						messageId: messageData.id,
						threadId: messageData.conversationId,
						imageUrl: notificationImage[token],
					},
					notification: {
						title: fromString,
						body: body,
						imageUrl: notificationImage[token],
					},
					subtitle: subject,
					subtitleSeparator: '\n',
					badge: notificationBadge[token] || 0,
				};
				return data;
			}),
		);

		res.sendStatus(202);
	},
);

type MemberInfo = {
	id: string;
	member_id: string;
	channel_id: string;
	channel_name: string;
	team_id: string;
	member_name: string;
	is_channel: boolean;
	is_dm: boolean;
	member_ids: string[] | undefined;
	user_id: string;
};

export const handleslacknotificationcore = v2.pubsub.onMessagePublished(
	{
		topic: 'slack-notification',
		// memory: '2GiB',
		memory: '512MiB',
		minInstances: 1,
	},
	async (event) => {
		const supabase = createClient(
			defineString('SUPABASE_URL').value(),
			defineString('SUPABASE_ANON_KEY').value(),
		);

		const body = JSON.parse(
			Buffer.from(event.data.message.data, 'base64').toString(),
		);

		if (typeof body['event'] === 'string') {
			body['event'] = JSON.parse(body['event']);
		}

		const isRtm = body['rtm'] || false;
		const rtmServerUserId = body['userId'];

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

		if (type != 'message' && type != 'reaction_added' && type != 'reaction_removed') {
			return;
		}

		const isMessageCreate = type == 'message' &&
			subtype != 'message_changed' &&
			subtype != 'message_deleted';


		if (isMessageCreate) {
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

			if (blocks && Array.isArray(blocks)) {
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

			if (attachments && Array.isArray(attachments)) {
				attachments.forEach((attachment: any) => {
					const blocks = attachment && Array.isArray(attachment.blocks) ? attachment.blocks : [];
					if (blocks.length > 0) {
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
				});
			}
		}

		const response = await Promise.all([
			supabase.from('message_member_info').select('*').in('member_id', [...new Set([...users, ...groups, user_id])]).in('channel_id', [...new Set([...channels, channel_id])]).returns<MemberInfo[]>(),
			supabase
				.rpc('get_slack_linked_user', {
					slack_team_id: team_id,
					slack_user_ids: [...new Set([user_id, ...users])],
					slack_channel_ids: [...new Set([channel_id, ...channels])],
					slack_usergroup_ids: [...new Set(groups)],
				})
				.returns<NotificationUser[]>()
		]);

		const memberInfoRes = response[0];
		const memberInfo = memberInfoRes.data ?? [];
		const result = response[1];

		const sentToken: string[] = [];
		const sentUser: string[] = [];
		const notificationImage: { [key: string]: string } = {};
		const notificationBadge: { [key: string]: number } = {};
		const newNotificationData: { [key: string]: any }[] = [];
		const notificationApnsToken: { [key: string]: string | undefined } = {};
		const notificationUserId: { [key: string]: string } = {};
		const notificationPlatform: { [key: string]: string } = {};
		const mentionedUsers: string[] = [];
		let containsBroadcast: boolean = false;

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

				const channelInfo = memberInfo.find(e => e.channel_id == channel_id && e.member_id == user_id);

				if (isMessageCreate) {
					if (channelInfo) {
						const channelInfoIsRtm = (user.n.token_slack_teams ?? []).includes(team_id);
						if (channelInfoIsRtm == isRtm) {
							if (!(isRtm && rtmServerUserId != user.n.user_id)) {
								if (!newNotificationData.find(e => e.id == user.n.user_id)) {
									const token = user.n.fcm_token || user.n.device_id;
									newNotificationData.push({
										id: user.n.user_id,
										badge: (user.u.badge || 0) + 1,
										token: token,
									});
								}
							}
						}
					}
				}


				if (isMessageCreate) {
					if (channelInfo) {
						const channelInfoIsRtm = (user.n.token_slack_teams || []).includes(team_id);
						if (channelInfoIsRtm == isRtm) {
							var channelName = '';
							const isChannel = channelInfo.is_channel;
							channelName = isChannel
								? '#' + channelInfo.channel_name
								: channelInfo.channel_name;
							const userName = channelInfo.member_name;
							if (channelName == userName || channelInfo.is_dm) {
								title = userName;
							} else {
								title = channelName;
								subtitle = userName;
							}

							const getRichTextSnippet = (
								element: any,
								memberInfo: MemberInfo[] | undefined,
							) => {
								if (element.type == null) return '';
								let strings: string[] = [];
								switch (element.type) {
									case 'channel':
										const channelInfo = memberInfo?.find((e) => e.channel_id == element['channel_id']);
										if (channelInfo) {
											strings.push('#' + channelInfo.channel_name);
										} else {
											strings.push('#' + element['channel_id']);
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
										mentionedUsers.push(element['user_id']);
										const userInfo = memberInfo?.find((e) => e.member_id == element['user_id'] && e.id.startsWith('member'));
										if (userInfo) {
											strings.push('@' + userInfo.member_name);
										} else {
											strings.push('@' + element['user_id']);
										}

										break;
									case 'usergroup':
										const groupInfo = memberInfo?.find((e) => e.member_id == element['usergroup_id'] && e.id.startsWith('group'));
										if (groupInfo) {
											strings.push('@' + groupInfo.member_name);
											mentionedUsers.push(...(groupInfo.member_ids ?? []));
										} else {
											strings.push('@' + element['usergroup_id']);
										}
										break;
									case 'broadcast':
										strings.push('@' + element.range);
										if (element.range == 'channel') {
											containsBroadcast = true;
										} else if (element.range == 'here') {
											containsBroadcast = true;
										}
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
										const userInfo = memberInfo?.find((e) => e.member_id == mentionText);
										if (mentionText == 'channel') {
											containsBroadcast = true;
										} else if (mentionText == 'here') {
											containsBroadcast = true;
										} else {
											mentionedUsers.push(mentionText);
										}

										if (userInfo) {
											strings.push(`${showMentionTag ? '@' : ''}${userInfo.member_name}`);
											mentionedUsers.push(...(userInfo.member_ids ?? []));
										} else {
											strings.push(`${showMentionTag ? '@' : ''}${mentionText}`);
										}

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
										const channelInfo = memberInfo?.find((e) => e.channel_id == channelText);
										if (channelInfo) {
											strings.push(`${showMentionTag ? '#' : ''}${channelInfo.channel_name}`);
										} else {
											strings.push(`${showMentionTag ? '#' : ''}${channelText}`);
										}
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
																			memberInfo,
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
																					memberInfo,
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
																					memberInfo,
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
													memberInfo,
												),
												getRichTextSnippet(
													{
														type: 'link',
														text: block.title ?? [
															'text',
														],
														url: block.videoUrl,
													},
													memberInfo,
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
								channelInfo?.channel_id,
								strings.join(''),
								true,
							);
							if (pre) snippet = pre;

							const filterTypes = ['none', 'mentions', 'all'];

							var filter = channelInfo?.is_channel ? 'mentions' : 'all';
							var fetchedUserId = '';
							if (channelInfo) {
								const fetchedUserIdKeys = Object.keys(user.n.show_slack_notification || {}).filter(e => e.includes(`${channelInfo?.is_channel ? 'channel' : 'dm'}-${team_id}`));

								for (const key of fetchedUserIdKeys) {
									fetchedUserId = key.split('-')[2];

									const newFilter = user.n.show_slack_notification[key] ?? (channelInfo?.is_channel ? 'mentions' : 'all');
									if ((!filter || filterTypes.indexOf(filter) < filterTypes.indexOf(newFilter)) && fetchedUserId != user_id) {
										filter = newFilter;
									}
								}
							}


							if (user_id && fetchedUserId && fetchedUserId.toLowerCase() != user_id.toLowerCase() &&
								(filter == 'all' ||
									(filter == 'mentions' &&
										(mentionedUsers.includes(fetchedUserId) || containsBroadcast))) && fetchedUserId.length > 0
							) {
								if (!(isRtm && rtmServerUserId != user.n.user_id)) {
									if (ts == eventTs) {
										const token = user.n.fcm_token || user.n.device_id;

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

		for (let userId of [...new Set(sentUser)]) {
			const channel = supabase.channel(userId);
			channel.send({
				type: 'broadcast',
				event: 'slack_changed',
				payload: { body, teamId: team_id },
			});
		}

		const filteredNewNotificationData = newNotificationData.filter(e => sentToken.includes(e.token));
		if (filteredNewNotificationData.length > 0) {
			supabase.from('users').upsert(filteredNewNotificationData);
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
	},
);

export const handlegmailnotification = v2.pubsub.onMessagePublished(
	{
		topic: 'taskey-gmail-pubsub',
		memory: '512MiB',
		minInstances: 1,
	},
	async (event) => {
		const supabase = createClient(
			defineString('SUPABASE_URL').value(),
			defineString('SUPABASE_ANON_KEY').value(),
		);
		const googleClientId = defineString('GOOGLE_CLIENT_ID').value();
		const googleClientSecret = defineString('GOOGLE_CLIENT_SECRET').value();

		const type = event.type;

		if (type.includes('messagePublished')) {
			const messageData = Buffer.from(
				event.data.message.data,
				'base64',
			).toString();
			const user_mail = JSON.parse(messageData).emailAddress.toString();
			const historyId = JSON.parse(messageData).historyId.toString();

			let response = await supabase
				.rpc('get_gmail_linked_user', { user_mail })
				.returns<NotificationUser[]>();

			const sentToken: string[] = [];
			const sentUser: string[] = [];
			const notificationImage: { [key: string]: string } = {};
			const notificationApnsToken: { [key: string]: string | undefined } =
				{};
			const notificationBadge: { [key: string]: number } = {};
			const notificationLabels: { [key: string]: string[] } = {};
			const notificationUserId: { [key: string]: string } = {};
			const notificationPlatform: { [key: string]: string } = {};

			let serverCode: string | null = null;
			let serverCodeNotificationId: string | null = null;
			let serverCodeFullData: { [key: string]: string } = {};
			let targetHistoryId: string | null = null;
			const newNotificationData: { [key: string]: any }[] = [];

			if (response.data && response.data.length > 0) {
				const mailLinkedUsers = response.data;
				mailLinkedUsers.forEach((user) => {
					const token = user.n.fcm_token || user.n.device_id;
					if (!sentUser.includes(user.n.user_id)) {
						sentUser.push(user.n.user_id);

						if (user.u.last_gmail_history_ids[user_mail]) {
							if (targetHistoryId == null) {
								targetHistoryId =
									user.u.last_gmail_history_ids[user_mail];
							} else if (
								targetHistoryId <
								user.u.last_gmail_history_ids[user_mail]
							) {
								targetHistoryId =
									user.u.last_gmail_history_ids[user_mail];
							}
						}

						newNotificationData.push({
							id: user.n.user_id,
							token: token,
							last_gmail_history_ids: {
								...user.u.last_gmail_history_ids,
								[user_mail]: historyId,
							},
							badge: (user.u.badge || 0) + 1,
						});
					}

					if (!sentToken.includes(token)) {
						try {
							notificationImage[token] =
								user.n.gmail_notification_image[user_mail];
							notificationBadge[token] = (user.u.badge || 0) + 1;
							notificationLabels[token] =
								user.n.show_gmail_notification[user_mail];
							notificationApnsToken[token] = user.n.apns_token;
							notificationUserId[token] = user.n.user_id;
							notificationPlatform[token] = user.n.platform;

							if (user.n.gmail_server_code[user_mail]) {
								serverCode = user.n.gmail_server_code[user_mail];
								serverCodeNotificationId = user.n.id;
								serverCodeFullData = user.n.gmail_server_code;
							}

							sentToken.push(token);
						} catch (e) {
							// Error handled silently
						}
					}
				});
			}

			for (let userId of sentUser) {
				const channel = supabase.channel(userId);
				await channel.send({
					type: 'broadcast',
					event: 'gmail_changed',
					payload: { historyId: targetHistoryId, email: user_mail },
				});
			}


			if (!serverCode) return;

			const oauth2Client = new gmail.auth.OAuth2(
				googleClientId,
				googleClientSecret,
				''
			);

			try {
				const credentialsData =
					typeof serverCode === 'string' ? JSON.parse(serverCode) : serverCode;
				const credentials = credentialsData.data ?? credentialsData;

				oauth2Client.setCredentials(credentials);

				// ✅ 만료 확인: expiry_date가 없거나, 현재 시각보다 과거면 만료로 간주
				const isExpired =
					!credentials.expiry_date ||
					credentials.expiry_date <= Date.now();

				if (isExpired) {
					const refreshed = await oauth2Client.getAccessToken();

					if (!refreshed?.token) {
						return;
					}

					try {
						await supabase
							.from('notification')
							.update({
								gmail_server_code: {
									...serverCodeFullData,
									[user_mail]: JSON.stringify({
										data: oauth2Client.credentials,
									}),
								},
							})
							.eq('id', serverCodeNotificationId);
					} catch (updateErr) {
						// Error handled silently
					}
				}
			} catch (error) {
				return;
			}


			const gmailApi = gmail.gmail({ version: 'v1', auth: oauth2Client });
			const result = await gmailApi.users.history.list({
				userId: 'me',
				historyTypes: ['messageAdded', 'messageDeleted', 'labelAdded', 'labelRemoved'],
				labelId: 'INBOX',
				startHistoryId: targetHistoryId,
			});

			let latestMessageId: string | null = null;
			const historyList = result.data.history || [];
			const history = historyList.reverse()[0];
			const added = history?.messagesAdded?.[0]?.message?.id;
			if (added) {
				latestMessageId = added;
			}

			if (!latestMessageId) return;

			const message = await gmailApi.users.messages.get({
				userId: 'me',
				id: latestMessageId,
				format: 'metadata',
			});

			const subject = message.data.payload.headers.find(
				(h: any) => h.name === 'Subject',
			).value;
			const from = message.data.payload.headers.find(
				(h: any) => h.name === 'From',
			).value;
			const fromName = from
				.split('<')[0]
				.trim()
				.replace(/"/g, '');
			const fromEmail = from
				.split('<')[1]
				.replace('>', '')
				.trim();
			const fromString = fromName != '' ? fromName : fromEmail;
			const snippet = message.data.snippet;
			const unescapedString = unescape(snippet);
			const body = unescapedString ?? snippet;
			const labelIds = message.data.labelIds;

			const filteredNewNotificationData = newNotificationData.filter(e => sentToken.includes(e.token));
			if (filteredNewNotificationData.length > 0) {
				await supabase.from('users').upsert(filteredNewNotificationData.map((e) => {
					return {
						id: e.id,
						last_gmail_history_ids: e.last_gmail_history_ids,
						badge: e.badge,
					};
				}));
			} else {
				await supabase.from('users').upsert(newNotificationData.map((e) => {
					return {
						id: e.id,
						last_gmail_history_ids: e.last_gmail_history_ids,
					};
				}));

			}

			return sendFcmWithData(
				sentToken.map((token) => {
					const filterLabelIds = notificationLabels[
						token
					] || ['INBOX'];
					let enabled = false;
					filterLabelIds.forEach((id) => {
						if (labelIds.includes(id)) {
							enabled = true;
						}
					});

					let data: sendFcmData = {
						fcmToken: enabled ? token : '',
						apnsToken: enabled
							? notificationApnsToken[token]
							: undefined,
						threadId: 'gmail' + user_mail,
						userId: notificationUserId[token],
						platform: notificationPlatform[token],
						data: {
							type: 'gmail_notification',
							historyId,
							email: user_mail,
							messageId: message.data.id,
							threadId: message.data.threadId,
							imageUrl: notificationImage[token],
						},
						notification: {
							title: fromString,
							body: body,
							imageUrl: notificationImage[token],
						},
						subtitle: subject,
						subtitleSeparator: '\n',
						badge: notificationBadge[token] || 0,
					};
					return data;
				}),
			);
		}
	},
);


export const sendtaskoreventchangenotificationforwidgets = v2.https.onRequest(
	{
		minInstances: 0,
	},
	async (request, response) => {
		const supabase = createClient(
			defineString('SUPABASE_URL').value(),
			defineString('SUPABASE_ANON_KEY').value(),
		);

		const { userId, data, type, action } = request.body;


		const notifications = await supabase.from('notifications').select('*').eq('user_id', userId).in('platform', ['ios', 'android']);
		const sendFcmData: sendFcmData[] = [];
		notifications.data?.forEach((notification) => {
			let fcmData: sendFcmData = {
				fcmToken: notification.fcm_token,
				apnsToken: notification.apns_token,
				userId: notification.user_id,
				platform: notification.platform,
				data: {
					'type': type,
					'data': JSON.stringify(data),
					'action': action,
				},
			};
			sendFcmData.push(fcmData);
		});


		await sendFcmWithData(sendFcmData);
		response.send(JSON.stringify({ success: true }));
	},
);

export const redirecttaskeytowork = v2.https.onRequest(
	{
		minInstances: 0,
	},
	async (request, response) => {
		const url = parse(request.url, true);
		const path = url.pathname || '/';
		const query = url.search || '';
		
		const redirectUrl = `https://visir.pro${path}${query}`;
		response.redirect(301, redirectUrl);
	},
);