import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:Visir/features/auth/application/notification_controller.dart';
import 'package:Visir/features/auth/domain/entities/notification_entity.dart';
import 'package:Visir/features/auth/domain/entities/subscription/lemon_squeezy/lemon_squeezy_customer_entity.dart';
import 'package:Visir/features/auth/domain/entities/subscription/lemon_squeezy/lemon_squeezy_discount_entity.dart';
import 'package:Visir/features/auth/domain/entities/subscription/lemon_squeezy/lemon_squeezy_product_entity.dart';
import 'package:Visir/features/auth/domain/entities/subscription/lemon_squeezy/lemon_squeezy_variant_entity.dart';
import 'package:Visir/features/auth/domain/entities/subscription/user_subscription_update_attributes_entity.dart';
import 'package:Visir/features/auth/domain/entities/user_entity.dart';
import 'package:Visir/features/auth/domain/repositories/auth_repository_interface.dart';
import 'package:Visir/features/common/domain/failures/failure.dart';
import 'package:Visir/features/common/infrastructure/entities/environment.dart';
import 'package:Visir/features/common/presentation/utils/constants.dart';
import 'package:Visir/features/common/presentation/utils/extensions/platform_extension.dart';
import 'package:Visir/features/common/presentation/utils/log_event.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/inbox/domain/entities/inbox_config_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_event_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_unread_entity.dart';
import 'package:Visir/features/task/domain/entities/task_entity.dart';
import 'package:easy_debounce/easy_throttle.dart';
import 'package:flutter/services.dart';
import 'package:fpdart/fpdart.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

StreamSubscription? authListener;

/// Repository that handles authorization and persists session
class AuthRepository implements AuthRepositoryInterface {
  final String _tableUser = 'users';
  final String _tableNotification = 'notifications';
  final String _taskDatabaseTable = 'tasks';
  final String _inboxConfigDatabaseTable = 'inbox_config';
  final String _messageUnreadDatabaseTable = 'message_unread';
  final String _tableMessageMemberInfo = 'message_member_info';

  AuthRepository();

  SupabaseClient get client => Supabase.instance.client;

  String? get provider => client.auth.currentUser?.appMetadata['provider'];
  String? get currentUserId => client.auth.currentUser?.id;

  @override
  void authStateChange(void Function(String? userId) callback) async {
    await authListener?.cancel();
    authListener = client.auth.onAuthStateChange.listen((data) async {
      switch (data.event) {
        case AuthChangeEvent.signedIn:
          callback(currentUserId);
          if (currentUserId == null) return;
          String? createdAt = client.auth.currentUser?.createdAt;
          String? lastSignInAt = client.auth.currentUser?.lastSignInAt;
          if (createdAt == null || lastSignInAt == null) return;
          bool isFirstLogin = DateTime.parse(lastSignInAt).difference(DateTime.parse(createdAt)).inSeconds < 10;
          logAnalyticsEvent(eventName: '${isFirstLogin ? 'signup_${provider}_success' : 'login_${provider}_success'}');
          if (!isFirstLogin) return;
          final _afterLoginTasks = afterLoginTasks(now: DateTime.now(), context: Utils.mainContext, ownerId: currentUserId!);
          final _nearTrialEndTasks = nearTrialEndTasks(now: DateTime.now().add(Duration(days: 7)), context: Utils.mainContext, ownerId: currentUserId!);
          await Future.delayed(Duration(seconds: 3));
          await client.from(_taskDatabaseTable).upsert([..._afterLoginTasks, ..._nearTrialEndTasks].map((e) => e.toJson()).toList());
          break;
        case AuthChangeEvent.signedOut:
          logAnalyticsEvent(eventName: 'sign_out');
          client.realtime.disconnect();
          callback(null);
          break;
        case AuthChangeEvent.userUpdated:
          break;
        case AuthChangeEvent.passwordRecovery:
        case AuthChangeEvent.mfaChallengeVerified:
          break;
        case AuthChangeEvent.userDeleted:
          client.realtime.disconnect();
          callback(null);
          break;
        case AuthChangeEvent.initialSession:
          callback(currentUserId);
          break;
        case AuthChangeEvent.tokenRefreshed:
      }
    });

    authListener?.onError((error) {
      if (error is AuthSessionMissingException) {
        client.auth.reauthenticate();
      }
    });
  }

  /// Signs in user to the application
  @override
  Future<Either<Failure, UserEntity?>> onSignInSuccess() async {
    return right(client.auth.currentUser == null ? null : UserEntity.fromJson(client.auth.currentUser!.toJson()));
  }

  @override
  Future<Either<Failure, UserEntity?>> onSignInFailed(Object error) async {
    return Utils.debugLeft(error);
  }

  /// Signs out user from the application
  @override
  Future<Either<Failure, UserEntity?>> signOut() async {
    try {
      await client.auth.signOut();
      if (PlatformX.isGoogleSignInSupported) await GoogleSignIn.instance.disconnect();
      return right(client.auth.currentUser == null ? null : UserEntity.fromJson(client.auth.currentUser!.toJson()));
    } catch (e) {
      return Utils.debugLeft(e);
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> deleteUser(String userId) async {
    try {
      await client.functions.invoke('delete_user', body: {'from_id': client.auth.currentUser!.id});
      await client.auth.signOut();
      if (PlatformX.isGoogleSignInSupported) await GoogleSignIn.instance.disconnect();
      return right(null);
    } catch (e) {
      return Utils.debugLeft(e);
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> updateUser({required UserEntity user}) async {
    try {
      if (client.auth.currentUser?.id != user.id) throw UnimplementedError('auth id and user id do not match');

      user = user.copyWith(badge: 0);

      final _udpateUser = () async {
        await client.from(_tableUser).upsert(user.toJson()).eq('id', currentUserId!);
      };

      EasyThrottle.throttle('update_user', const Duration(seconds: 1), _udpateUser, onAfter: _udpateUser);
      return right(user);
    } catch (e) {
      return Utils.debugLeft(e);
    }
  }

  Future<Either<Failure, UserEntity>> getUser({required String userId}) async {
    try {
      final response = await client.from(_tableUser).select().eq('id', userId).maybeSingle();

      // If user doesn't exist in database, create a new user record from auth data
      if (response == null) {
        final authUser = client.auth.currentUser;
        if (authUser == null) {
          return left(Failure.empty(StackTrace.current, 'Auth user not found'));
        }

        // Create new user with data from auth
        final newUser = UserEntity(
          id: userId,
          email: authUser.email,
          name: authUser.userMetadata?['name'] as String? ?? authUser.email?.split('@').first,
          avatarUrl: authUser.userMetadata?['avatar_url'] as String?,
          createdAt: DateTime.parse(authUser.createdAt),
          aiCredits: 2.0,
        );

        // Insert the new user into database
        await client.from(_tableUser).upsert(newUser.toJson());

        return right(newUser);
      }

      return right(UserEntity.fromJson(response));
    } catch (e) {
      return Utils.debugLeft(e);
    }
  }

  Future<Either<Failure, NotificationEntity>> getNotification({required String userId, required String deviceId}) async {
    try {
      final response = await client
          .from(_tableNotification)
          .select(
            'id, device_id, user_id, platform, fcm_token, apns_token, show_task_notification, show_calendar_notification, show_gmail_notification, show_outlook_mail_notification, linked_gmails, linked_google_calendars, linked_slack_teams, linked_outlook_mails, gmail_server_code, gcal_server_code, slack_server_code, gmail_notification_image, gcal_notification_image, slack_notification_image, outlook_mail_server_code, outlook_mail_notification_image',
          )
          .eq('id', '${userId}-${deviceId}')
          .maybeSingle();
      if (response == null) {
        return left(Failure.empty(StackTrace.current, 'Notification not found'));
      }
      return right(NotificationEntity.fromJson(response));
    } catch (e) {
      return Utils.debugLeft(e);
    }
  }

  Future<Either<Failure, NotificationEntity?>> saveNotification({required NotificationEntity notification}) async {
    final _saveNotification = () async {
      if (notification.fcmToken != null) await client.from(_tableNotification).delete().eq('fcm_token', notification.fcmToken!).neq('id', notification.id);
      await client.from(_tableNotification).upsert(notification.toJson());
    };

    try {
      EasyThrottle.throttle('save_notification', const Duration(seconds: 1), _saveNotification, onAfter: _saveNotification);
      return right(notification);
    } catch (e) {
      return Utils.debugLeft(e);
    }
  }

  Future<Either<Failure, bool?>> updateLinkedGmail({
    required String notificationId,
    required List<String> linkedGmails,
    required Map<String, String> gmailServerCode,
    required Map<String, String> gmailNotificationImage,
  }) async {
    final _updateLinkedGmail = () async {
      await client
          .from(_tableNotification)
          .update({'linked_gmails': linkedGmails, 'gmail_server_code': gmailServerCode, 'gmail_notification_image': gmailNotificationImage})
          .eq('id', notificationId);
    };

    try {
      await _updateLinkedGmail();
      return right(true);
    } catch (e) {
      return Utils.debugLeft(e);
    }
  }

  Future<Either<Failure, bool?>> updateLinkedMsMail({
    required String notificationId,
    required List<String> linkedOutlookMails,
    required Map<String, String> outlookMailServerCode,
    required Map<String, String> outlookMailNotificationImage,
  }) async {
    final _updateLinkedOutlookMail = () async {
      await client
          .from(_tableNotification)
          .update({'linked_outlook_mails': linkedOutlookMails, 'outlook_mail_server_code': outlookMailServerCode, 'outlook_mail_notification_image': outlookMailNotificationImage})
          .eq('id', notificationId);
    };

    try {
      await _updateLinkedOutlookMail();
      return right(true);
    } catch (e) {
      return Utils.debugLeft(e);
    }
  }

  Future<Either<Failure, bool?>> updateLinkedCalendar({
    required String notificationId,
    required List<String> linkedCalendars,
    required Map<String, String> calServerCode,
    required Map<String, String> calNotificationImage,
  }) async {
    final _updateLinkedCalendar = () async {
      await client
          .from(_tableNotification)
          .update({'linked_google_calendars': linkedCalendars, 'gcal_server_code': calServerCode, 'gcal_notification_image': calNotificationImage})
          .eq('id', notificationId);
    };

    try {
      await _updateLinkedCalendar();
      return right(true);
    } catch (e) {
      return Utils.debugLeft(e);
    }
  }

  Future<Either<Failure, bool?>> updateLinkedSlackTeam({
    required String notificationId,
    required List<String> linkedSlackTeams,
    required List<String> tokenSlackTeams,
    required Map<String, String> slackNotificationImage,
    required Map<String, String> showSlackNotification,
  }) async {
    final _updateLinkedSlackTeam = () async {
      await client
          .from(_tableNotification)
          .update({'linked_slack_teams': linkedSlackTeams, 'slack_notification_image': slackNotificationImage, 'show_slack_notification': showSlackNotification})
          .eq('id', notificationId);
    };

    try {
      await _updateLinkedSlackTeam();
      return right(true);
    } catch (e) {
      return Utils.debugLeft(e);
    }
  }

  Future<Either<Failure, bool?>> updateShowTaskNotification({required String notificationId, required bool showTaskNotification}) async {
    final _updateShowTaskNotification = () async {
      await client.from(_tableNotification).update({'show_task_notification': showTaskNotification}).eq('id', notificationId);
    };

    try {
      await _updateShowTaskNotification();
      return right(true);
    } catch (e) {
      return Utils.debugLeft(e);
    }
  }

  Future<Either<Failure, bool?>> updateMessageInfos({required List<dynamic> data, required String userId, required List<String> teamIds}) async {
    if (data.isEmpty) return right(true);
    // await client.from(_tableMessageMemberInfo).delete().eq('user_id', userId).inFilter('team_id', teamIds);
    await client.from(_tableMessageMemberInfo).upsert(data);
    return right(true);
  }

  Future<Either<Failure, String>> uploadUserImage({required String path, required String userId}) async {
    try {
      final bytes = await File(path).readAsBytes();
      final imageUrl = await client.storage.from('users').uploadBinary('${userId}/${path}', bytes, fileOptions: const FileOptions(cacheControl: '3600', upsert: true));
      final String publicUrl = client.storage.from('users').getPublicUrl(imageUrl.split('users/')[1]);
      return right(publicUrl);
    } catch (e) {
      return Utils.debugLeft(e);
    }
  }

  Future<void> refreshSession() async {
    if (client.auth.currentSession?.isExpired ?? false) {
      await client.auth.refreshSession();
    }
  }

  bool get isUserListenerConnected => client.realtime.isConnected && userChannel != null;

  bool get isNotiListenerConnected => client.realtime.isConnected && notiChannel != null;

  RealtimeChannel? userChannel;

  void attachUserChannelListener({
    required void Function(UserEntity user) onUpdate,
    required void Function(String calendarId) onGcalChanged,
    required void Function(String eventId) onOutlookCalChanged,
    required void Function(String historyId, String email) onGmailChanged,
    required void Function(String messageId, String email, String changeType) onOutlookMailChanged,
    required void Function(MessageEventEntity event) onSlackChanged,
    required void Function(TaskEntity task) onUpdateTask,
    required void Function(String taskId) onDeleteTask,
    required void Function(InboxConfigEntity config) onUpdateInboxConfig,
    required void Function(String configId) onDeleteInboxConfig,
    required void Function(MessageUnreadEntity unread) onUpdateMessageUnread,
  }) async {
    if (client.auth.currentUser == null) return;

    String id = client.auth.currentUser!.id;
    await userChannel?.unsubscribe();
    userChannel = client.realtime
        .channel(id)
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: _tableUser,
          filter: PostgresChangeFilter(type: PostgresChangeFilterType.eq, column: 'id', value: id),
          callback: (payload) {
            try {
              print('DEBUG: User table update received via realtime');
              UserEntity user = UserEntity.fromJson(payload.newRecord);
              print('DEBUG: User parsed, subscription: ${user.subscription != null ? "present" : "null"}');
              onUpdate(user);
            } catch (e) {
              print('ERROR: Failed to process user update from realtime: $e');
            }
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: _taskDatabaseTable,
          filter: PostgresChangeFilter(type: PostgresChangeFilterType.eq, column: 'owner_id', value: id),
          callback: (payload) {
            try {
              TaskEntity task = TaskEntity.fromJson(payload.newRecord);
              onUpdateTask(task);
            } catch (e) {}
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: _taskDatabaseTable,
          filter: PostgresChangeFilter(type: PostgresChangeFilterType.eq, column: 'owner_id', value: id),
          callback: (payload) {
            try {
              TaskEntity task = TaskEntity.fromJson(payload.newRecord);
              onUpdateTask(task);
            } catch (e) {}
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.delete,
          schema: 'public',
          table: _taskDatabaseTable,
          callback: (payload) {
            try {
              String? taskId = payload.oldRecord['id'];
              if (taskId != null) onDeleteTask(taskId);
            } catch (e) {}
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: _inboxConfigDatabaseTable,
          filter: PostgresChangeFilter(type: PostgresChangeFilterType.eq, column: 'user_id', value: id),
          callback: (payload) {
            try {
              InboxConfigEntity config = InboxConfigEntity.fromJson(payload.newRecord);
              onUpdateInboxConfig(config);
            } catch (e) {}
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: _inboxConfigDatabaseTable,
          filter: PostgresChangeFilter(type: PostgresChangeFilterType.eq, column: 'user_id', value: id),
          callback: (payload) {
            try {
              InboxConfigEntity config = InboxConfigEntity.fromJson(payload.newRecord);
              onUpdateInboxConfig(config);
            } catch (e) {}
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.delete,
          schema: 'public',
          table: _inboxConfigDatabaseTable,
          callback: (payload) {
            try {
              String? configId = payload.oldRecord['id'];
              if (configId != null) onDeleteInboxConfig(configId);
            } catch (e) {}
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: _messageUnreadDatabaseTable,
          filter: PostgresChangeFilter(type: PostgresChangeFilterType.eq, column: 'user_id', value: id),
          callback: (payload) {
            try {
              MessageUnreadEntity unread = MessageUnreadEntity.fromJson(payload.newRecord);
              onUpdateMessageUnread(unread);
            } catch (e) {}
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: _messageUnreadDatabaseTable,
          filter: PostgresChangeFilter(type: PostgresChangeFilterType.eq, column: 'user_id', value: id),
          callback: (payload) {
            try {
              MessageUnreadEntity unread = MessageUnreadEntity.fromJson(payload.newRecord);
              onUpdateMessageUnread(unread);
            } catch (e) {}
          },
        )
        .onBroadcast(
          event: 'gcal_changed',
          callback: (payload) {
            String calendarId = payload['payload']['calendarId'];
            onGcalChanged(calendarId);
          },
        )
        .onBroadcast(
          event: 'gmail_changed',
          callback: (payload) {
            String historyId = payload['payload']['historyId'];
            String email = payload['payload']['email'];
            onGmailChanged(historyId, email);
          },
        )
        .onBroadcast(
          event: 'outlook_cal_changed',
          callback: (payload) {
            String eventId = payload['payload']['eventId'];
            onOutlookCalChanged(eventId);
          },
        )
        .onBroadcast(
          event: 'outlook_mail_changed',
          callback: (payload) {
            String messageId = payload['payload']['messageId'];
            String email = payload['payload']['email'];
            String changeType = payload['payload']['changeType'];
            onOutlookMailChanged(messageId, email, changeType);
          },
        )
        .onBroadcast(
          event: 'slack_changed',
          callback: (payload) {
            Map<String, dynamic> body = payload['payload']['body'];
            String teamId = payload['payload']['teamId'];
            final _eventData = body['event'];
            _eventData['team'] = teamId;
            final type = _eventData['type'];

            if (type == 'message' || type == 'reaction_added' || type == 'reaction_removed') {
              MessageEventEntity _event = MessageEventEntity.fromJson({'messageEventType': 'slack', '_messageEvent': _eventData});
              onSlackChanged(_event);
            }
          },
        )
        .subscribe((status, err) async {
          if (status == RealtimeSubscribeStatus.subscribed) {
          } else if (status == RealtimeSubscribeStatus.closed) {
            userChannel = null;
          } else {
            userChannel = null;
            attachUserChannelListener(
              onGcalChanged: onGcalChanged,
              onGmailChanged: onGmailChanged,
              onOutlookCalChanged: onOutlookCalChanged,
              onOutlookMailChanged: onOutlookMailChanged,
              onSlackChanged: onSlackChanged,
              onDeleteTask: onDeleteTask,
              onUpdateTask: onUpdateTask,
              onDeleteInboxConfig: onDeleteInboxConfig,
              onUpdateInboxConfig: onUpdateInboxConfig,
              onUpdateMessageUnread: onUpdateMessageUnread,
              onUpdate: onUpdate,
            );
          }
        });
  }

  RealtimeChannel? notiChannel;

  void attachNotiChannelListener({required String deviceId}) async {
    if (!PlatformX.isDesktop) return;
    await notiChannel?.unsubscribe();
    notiChannel = client.realtime
        .channel(deviceId)
        .onBroadcast(
          event: 'notification_sent',
          callback: (payload) {
            final title = payload['payload']['title'];
            final subtitle = payload['payload']['subtitle'];
            final body = payload['payload']['body'];
            final image = payload['payload']['image'];
            final thread = payload['payload']['thread'];
            final badge = payload['payload']['badge'];
            final data = payload['payload']['data'] ?? {};

            Map<String, dynamic> _notificationData = {};

            if (data['type'] == 'slack_notification') {
              String? threadId = data['thread_id'];
              String messageId = data['event_id'];
              String channelId = data['channel_id'];

              _notificationData = {'type': 'slack', 'channelId': channelId.toUpperCase(), 'messageId': messageId, 'threadId': threadId ?? ''};
            } else if (data['type'] == 'calendar_reminder') {
              final reminder = jsonDecode(data['reminder']);
              String type = 'task';
              switch (reminder['provider']) {
                case 'google':
                  type = 'gcal';
                  break;
              }
              _notificationData = {'type': type, 'eventId': reminder['event_id'], 'date': reminder['date'].toString()};
            } else if (data['type'] == 'gmail_notification') {
              _notificationData = {'type': 'gmail', 'threadId': data['threadId'], 'mailId': data['messageId']};
            }

            sendLocalNotificationCore(
              id: Random().nextInt(10000),
              title: title,
              subtitle: subtitle,
              body: body,
              imagePath: image,
              threadId: thread,
              payload: _notificationData,
              badge: badge,
            );
          },
        )
        .subscribe((status, err) async {
          if (status == RealtimeSubscribeStatus.subscribed) {
          } else if (status == RealtimeSubscribeStatus.closed) {
            notiChannel = null;
          } else {
            notiChannel = null;
            attachNotiChannelListener(deviceId: deviceId);
          }
        });
  }

  Future<Either<Failure, bool>> checkUserExistByEmail({required String email}) async {
    try {
      await client.from(_tableUser).select().eq('email', email).single().withConverter(UserEntity.fromJson);
      return right(true);
    } catch (e) {
      return Utils.debugLeft(e);
    }
  }

  @override
  Future<Either<Failure, String?>> getSubscriptionCheckoutUrl({required bool isTestMode, required String productId, required String variantId, String? discountCode}) async {
    final configFile = await rootBundle.loadString('assets/config/config.json');
    final env = Environment.fromJson(json.decode(configFile) as Map<String, dynamic>);

    try {
      final response = await client.functions.invoke(
        'get_lemon_squeezy_checkout_url',
        body: {
          'user_id': client.auth.currentUser!.id,
          'product_id': productId,
          'variant_id': variantId,
          'store_id': env.lemonSqueezyStoreId,
          'user_email': client.auth.currentUser?.email,
          'discount_code': discountCode,
          'is_test_mode': isTestMode,
        },
      );

      if (response.status == 200) {
        final data = response.data as Map<String, dynamic>;
        final url = data['url'] as String?;
        return right(url);
      } else {
        return left(Failure.empty(StackTrace.current, 'Failed to get checkout URL'));
      }
    } catch (e) {
      return Utils.debugLeft(e);
    }
  }

  @override
  Future<Either<Failure, bool?>> restoreSubscription({required bool isTestMode, required int lemonSqueezyCustomerId}) async {
    try {
      final response = await client.functions.invoke(
        'restore_lemon_squeezy_subscription',
        body: {'user_id': client.auth.currentUser!.id, 'customer_id': lemonSqueezyCustomerId.toString(), 'is_test_mode': isTestMode},
      );

      if (response.status == 200) {
        final data = response.data as Map<String, dynamic>;
        final subscriptionId = data['subscription_id'] as String?;

        return right(subscriptionId != null);
      } else {
        return left(Failure.empty(StackTrace.current, 'Failed to get subscription'));
      }
    } catch (e) {
      if (e is FunctionException && e.status == 404) {
        return right(false);
      }
      return Utils.debugLeft(e);
    }
  }

  @override
  Future<Either<Failure, bool?>> updateSubscription({required bool isTestMode, required String subscriptionId, required UserSubscriptionUpdateAttributesEntity attributes}) async {
    try {
      final response = await client.functions.invoke(
        'update_lemon_squeezy_subscription',
        body: {'user_id': client.auth.currentUser!.id, 'subscription_id': subscriptionId, 'attributes': attributes.toJson(), 'is_test_mode': isTestMode},
      );

      if (response.status == 200) {
        return right(true);
      } else if (response.status == 404) {
        return right(false);
      } else {
        return left(Failure.empty(StackTrace.current, 'Failed to cacnel subscription'));
      }
    } catch (e) {
      return Utils.debugLeft(e);
    }
  }

  @override
  Future<Either<Failure, List<LemonSqueezyProductEntity>>> getLemonSqueezyProducts({required bool isTestMode}) async {
    try {
      final response = await client.functions.invoke('get_lemon_squeezy_products', body: {'is_test_mode': isTestMode});
      if (response.status == 200) {
        final data = response.data as List<dynamic>;
        final products = data.map((e) {
          return LemonSqueezyProductEntity.fromJson({'id': e['id'], ...e['attributes']});
        }).toList();
        return right(products);
      } else {
        return left(Failure.empty(StackTrace.current, 'Failed to get products'));
      }
    } catch (e) {
      return Utils.debugLeft(e);
    }
  }

  @override
  Future<Either<Failure, List<LemonSqueezyVariantEntity>>> getLemonSqueezyVariants({required bool isTestMode, required String productId}) async {
    try {
      final response = await client.functions.invoke('get_lemon_squeezy_variants', body: {'product_id': productId, 'is_test_mode': isTestMode});
      if (response.status == 200) {
        final data = response.data as List<dynamic>;
        final variants = data.map((e) {
          return LemonSqueezyVariantEntity.fromJson({'id': e['id'], 'product_id': productId, ...e['attributes']});
        }).toList();
        return right(variants);
      } else {
        return left(Failure.empty(StackTrace.current, 'Failed to get products'));
      }
    } catch (e) {
      return Utils.debugLeft(e);
    }
  }

  @override
  Future<Either<Failure, LemonSqueezyCustomerEntity>> getLemonSqueezyCustomer({required bool isTestMode, required String customerId}) async {
    try {
      final response = await client.functions.invoke('get_lemon_squeezy_customer', body: {'customer_id': customerId, 'is_test_mode': isTestMode});
      if (response.status == 200) {
        final data = response.data as Map<String, dynamic>;
        final customer = LemonSqueezyCustomerEntity.fromJson({'id': data['id'], ...data['attributes']});
        return right(customer);
      } else {
        return left(Failure.empty(StackTrace.current, 'Failed to get customer'));
      }
    } catch (e) {
      return Utils.debugLeft(e);
    }
  }

  @override
  Future<Either<Failure, List<LemonSqueezyDiscountEntity>>> getLemonSqueezyDiscounts({required bool isTestMode, required String storeId}) async {
    try {
      final response = await client.functions.invoke('get_lemon_squeezy_discounts', body: {'store_id': storeId, 'is_test_mode': isTestMode});
      if (response.status == 200) {
        final data = response.data as List<dynamic>;
        final variants = data.map((e) {
          return LemonSqueezyDiscountEntity.fromJson({'id': e['id'], ...e['attributes'], 'variants': e['relationships']['variants']['data']?.map((e) => e['id']).toList()});
        }).toList();
        return right(variants);
      } else {
        return left(Failure.empty(StackTrace.current, 'Failed to get products'));
      }
    } catch (e) {
      return Utils.debugLeft(e);
    }
  }

  @override
  Future<Either<Failure, double>> getAiCredits({required String userId}) async {
    try {
      final response = await client.from(_tableUser).select('ai_credits').eq('id', userId).single();
      final credits = (response['ai_credits'] as num?)?.toDouble() ?? 0.0;
      return right(credits);
    } catch (e) {
      return Utils.debugLeft(e);
    }
  }

  @override
  Future<Either<Failure, double>> updateAiCredits({required String userId, required double amount}) async {
    try {
      // 현재 크레딧 조회
      final currentCreditsResult = await getAiCredits(userId: userId);
      final currentCredits = currentCreditsResult.fold((failure) => 0.0, (credits) => credits);

      final newCredits = currentCredits + amount;

      // 크레딧이 음수가 되지 않도록 보호
      if (newCredits < 0) {
        return left(Failure.empty(StackTrace.current, 'Insufficient credits'));
      }

      // 크레딧 업데이트
      await client.from(_tableUser).update({'ai_credits': newCredits, 'ai_credits_updated_at': DateTime.now().toIso8601String()}).eq('id', userId);

      return right(newCredits);
    } catch (e) {
      return Utils.debugLeft(e);
    }
  }
}
