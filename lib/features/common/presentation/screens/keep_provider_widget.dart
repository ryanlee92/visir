import 'package:Visir/config/providers.dart';
import 'package:Visir/features/auth/application/auth_controller.dart';
import 'package:Visir/features/auth/application/notification_controller.dart';
import 'package:Visir/features/calendar/application/calendar_event_list_controller.dart';
import 'package:Visir/features/calendar/application/calendar_list_controller.dart';
import 'package:Visir/features/chat/application/chat_channel_list_controller.dart';
import 'package:Visir/features/mail/application/mail_label_list_controller.dart';
import 'package:Visir/features/mail/application/mail_list_controller.dart';
import 'package:Visir/features/preference/application/connection_list_controller.dart';
import 'package:Visir/features/preference/application/local_pref_controller.dart';
import 'package:Visir/features/task/application/calendar_task_list_controller.dart';
import 'package:Visir/features/task/application/task_list_controller.dart';
import 'package:Visir/features/time_saved/application/total_user_action_switch_list_controller.dart';
import 'package:Visir/features/time_saved/application/user_last_action_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class KeepProviderWidget extends ConsumerWidget {
  const KeepProviderWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(localPrefControllerProvider);
    ref.watch(authControllerProvider);
    ref.watch(mailListControllerProvider);
    ref.watch(mailLabelListControllerProvider);
    ref.watch(taskListControllerProvider);
    ref.watch(chatChannelListControllerProvider);
    ref.watch(calendarListControllerProvider);
    ref.watch(calendarEventListControllerProvider(tabType: TabType.home));
    ref.watch(calendarTaskListControllerProvider(tabType: TabType.home));
    ref.watch(calendarEventListControllerProvider(tabType: TabType.calendar));
    ref.watch(calendarTaskListControllerProvider(tabType: TabType.calendar));
    ref.watch(connectionListControllerProvider);
    ref.watch(notificationControllerProvider);
    final isSignedIn = ref.watch(authControllerProvider.select((value) => value.requireValue.isSignedIn));
    if (!isSignedIn) return SizedBox.shrink();
    ref.watch(notificationControllerProvider);
    ref.watch(totalUserActionSwitchListControllerProvider);
    ref.watch(userLastActionControllerProvider);
    return SizedBox.shrink();
  }
}
