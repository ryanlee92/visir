import 'package:Visir/config/providers.dart';
import 'package:Visir/features/auth/application/auth_controller.dart';
import 'package:Visir/features/chat/application/chat_channel_list_controller.dart';
import 'package:Visir/features/chat/domain/entities/message_channel_entity.dart';
import 'package:Visir/features/chat/providers.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/mail/application/mail_list_controller.dart';
import 'package:Visir/features/preference/application/local_pref_controller.dart';
import 'package:Visir/features/preference/domain/entities/oauth_entity.dart';
import 'package:Visir/features/time_saved/application/total_user_action_switch_list_controller.dart';
import 'package:Visir/features/time_saved/application/user_action_switch_list_controller.dart';
import 'package:Visir/features/time_saved/application/user_last_action_controller.dart';
import 'package:Visir/features/time_saved/domain/entities/user_action_entity.dart';
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

class UserActionSwtichAction {
  static onSwtichTab({required TabType targetTab}) {
    switch (targetTab) {
      case TabType.home:
      case TabType.calendar:
        onCalendarAction();
        break;
      case TabType.task:
        onTaskAction();
        break;
      case TabType.mail:
        final mailOAuths = Utils.ref.read(localPrefControllerProvider).value?.mailOAuths ?? [];
        if (mailOAuths.isNotEmpty) {
          final mails = Utils.ref.read(mailListControllerProvider.select((v) => v.list));
          final firstMailHost = mails.firstOrNull?.hostEmail ?? mailOAuths.first.email;
          onOpenMail(mailHost: firstMailHost);
        }
        break;
      case TabType.chat:
        onOpenMessageChannel();
        break;
    }
  }

  static onOpenMessageChannel() async {
    final messageOAuths = Utils.ref.read(localPrefControllerProvider).value?.messengerOAuths ?? [];
    MessageChannelEntity? messageTabCurrentChannel = Utils.ref.read(chatConditionProvider(TabType.chat).select((v) => v.channel));
    bool isChannelOpened = messageTabCurrentChannel != null;

    final teams = Utils.ref.read(chatChannelListControllerProvider.select((v) => v.entries.map((e) => MapEntry(e.key, e.value.team)).toList()));

    if (messageOAuths.isNotEmpty && isChannelOpened) {
      String? teamName = teams.firstWhereOrNull((e) => e.key == messageTabCurrentChannel.teamId)?.value.name;
      final targetOAuth = messageOAuths.firstWhereOrNull((e) => e.teamId == messageTabCurrentChannel.teamId);
      if (targetOAuth != null && teamName != null) {
        final lastUserAction = Utils.ref.read(userLastActionControllerProvider).value;
        final action = UserActionEntity(
          id: Uuid().v4(),
          createdAt: DateTime.now(),
          type: UserActionType.message,
          oAuthType: targetOAuth.type,
          identifier: teamName,
        );

        if (lastUserAction == null) {
          Utils.ref.read(userLastActionControllerProvider.notifier).saveUserLastAction(lastAction: action);
          return;
        }

        final result = await Utils.ref
            .read(defaultUserActionSwitchListControllerProvider.notifier)
            .saveUserActionSwtich(nextAction: action, prevAction: lastUserAction);
        if (result != null) {
          Utils.ref.read(totalUserActionSwitchListControllerProvider.notifier).updateUserActionSwitch(switchAction: result);
          Utils.ref.read(userLastActionControllerProvider.notifier).saveUserLastAction(lastAction: action);
        }
      }
    }
  }

  static onOpenExternalMessageLink({required String teamId}) async {
    final messageOAuths = Utils.ref.read(localPrefControllerProvider).value?.messengerOAuths ?? [];
    final targetOAuth = messageOAuths.firstWhereOrNull((e) => e.teamId == teamId);
    if (targetOAuth != null) {
      final lastUserAction = Utils.ref.read(userLastActionControllerProvider).value;

      final action = UserActionEntity(
        id: Uuid().v4(),
        createdAt: DateTime.now(),
        type: UserActionType.message,
        oAuthType: targetOAuth.type,
        identifier: targetOAuth.teamName,
      );

      if (lastUserAction == null) {
        Utils.ref.read(userLastActionControllerProvider.notifier).saveUserLastAction(lastAction: action);
        return;
      }

      final result = await Utils.ref
          .read(defaultUserActionSwitchListControllerProvider.notifier)
          .saveUserActionSwtich(nextAction: action, prevAction: lastUserAction);
      if (result != null) {
        Utils.ref.read(totalUserActionSwitchListControllerProvider.notifier).updateUserActionSwitch(switchAction: result);
        Utils.ref.read(userLastActionControllerProvider.notifier).saveUserLastAction(lastAction: action);
      }
    }
  }

  static onOpenMail({required String mailHost}) async {
    final mailOAuths = Utils.ref.read(localPrefControllerProvider).value?.mailOAuths ?? [];
    final targetOAuth = mailOAuths.firstWhereOrNull((e) => e.email == mailHost && e.team == null);
    if (targetOAuth != null) {
      final lastUserAction = Utils.ref.read(userLastActionControllerProvider).value;

      final action = UserActionEntity(id: Uuid().v4(), createdAt: DateTime.now(), type: UserActionType.mail, oAuthType: targetOAuth.type, identifier: mailHost);

      if (lastUserAction == null) {
        Utils.ref.read(userLastActionControllerProvider.notifier).saveUserLastAction(lastAction: action);
        return;
      }

      final result = await Utils.ref
          .read(defaultUserActionSwitchListControllerProvider.notifier)
          .saveUserActionSwtich(nextAction: action, prevAction: lastUserAction);
      if (result != null) {
        Utils.ref.read(totalUserActionSwitchListControllerProvider.notifier).updateUserActionSwitch(switchAction: result);
        Utils.ref.read(userLastActionControllerProvider.notifier).saveUserLastAction(lastAction: action);
      }
    }
  }

  static onTaskAction() async {
    final user = Utils.ref.read(authControllerProvider).requireValue;
    final lastUserAction = Utils.ref.read(userLastActionControllerProvider).value;

    final action = UserActionEntity(id: Uuid().v4(), createdAt: DateTime.now(), type: UserActionType.task, oAuthType: null, identifier: user.email);

    if (lastUserAction == null) {
      Utils.ref.read(userLastActionControllerProvider.notifier).saveUserLastAction(lastAction: action);
      return;
    }

    final result = await Utils.ref
        .read(defaultUserActionSwitchListControllerProvider.notifier)
        .saveUserActionSwtich(nextAction: action, prevAction: lastUserAction);
    if (result != null) {
      Utils.ref.read(totalUserActionSwitchListControllerProvider.notifier).updateUserActionSwitch(switchAction: result);
      Utils.ref.read(userLastActionControllerProvider.notifier).saveUserLastAction(lastAction: action);
    }
  }

  static onCalendarAction() async {
    final calendarOAuths = Utils.ref.read(localPrefControllerProvider).value?.calendarOAuths ?? [];
    if (calendarOAuths.isNotEmpty) {
      final lastUserAction = Utils.ref.read(userLastActionControllerProvider).value;
      final action = UserActionEntity(
        id: Uuid().v4(),
        createdAt: DateTime.now(),
        type: UserActionType.calendar,
        oAuthType: calendarOAuths.first.type,
        identifier: null,
      );

      if (lastUserAction == null) {
        Utils.ref.read(userLastActionControllerProvider.notifier).saveUserLastAction(lastAction: action);
        return;
      }

      final result = await Utils.ref
          .read(defaultUserActionSwitchListControllerProvider.notifier)
          .saveUserActionSwtich(nextAction: action, prevAction: lastUserAction);
      if (result != null) {
        Utils.ref.read(totalUserActionSwitchListControllerProvider.notifier).updateUserActionSwitch(switchAction: result);
        Utils.ref.read(userLastActionControllerProvider.notifier).saveUserLastAction(lastAction: action);
      }
    }
  }
}
