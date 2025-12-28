import 'package:Visir/dependency/master_detail_flow/src/details_item.dart';
import 'package:Visir/dependency/modal_bottom_sheet/src/utils/modal_scroll_controller.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/common/presentation/widgets/visir_icon.dart';
import 'package:Visir/features/common/presentation/widgets/visir_list_item.dart';
import 'package:Visir/features/common/presentation/widgets/visir_list_section.dart';
import 'package:Visir/features/preference/application/calendar_integration_list_controller.dart';
import 'package:Visir/features/preference/application/mail_integration_list_controller.dart';
import 'package:Visir/features/preference/application/messenger_integration_list_controller.dart';
import 'package:Visir/features/preference/presentation/widgets/notification/calendar_notification_preference_widget.dart';
import 'package:Visir/features/preference/presentation/widgets/notification/mail_notification_preference_widget.dart';
import 'package:Visir/features/preference/presentation/widgets/notification/chat_notification_preference_widget.dart';
import 'package:Visir/features/preference/presentation/widgets/notification/task_notification_preference_widget.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum NotificationPrefType { task, calendar, email, chat }

extension NotificationPrefTypeX on NotificationPrefType {
  Widget get widget {
    switch (this) {
      case NotificationPrefType.task:
        return TaskNotificationPreferenceWidget();
      case NotificationPrefType.calendar:
        return CalendarNotificationPreferenceWidget();
      case NotificationPrefType.email:
        return MailNotificationPreferenceWidget();
      case NotificationPrefType.chat:
        return ChatNotificationPreferenceWidget();
    }
  }

  String get title {
    switch (this) {
      case NotificationPrefType.task:
        return Utils.mainContext.tr.tab_task;
      case NotificationPrefType.calendar:
        return Utils.mainContext.tr.tab_calendar;
      case NotificationPrefType.email:
        return Utils.mainContext.tr.tab_mail;
      case NotificationPrefType.chat:
        return Utils.mainContext.tr.tab_chat;
    }
  }
}

class NotificationPrefScreen extends ConsumerStatefulWidget {
  final bool isSmall;
  final VoidCallback? onClose;

  const NotificationPrefScreen({super.key, required this.isSmall, this.onClose});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _NotificationPrefScreenState();
}

class _NotificationPrefScreenState extends ConsumerState<NotificationPrefScreen> {
  ScrollController? _scrollController;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _scrollController?.dispose();

    widget.onClose?.call();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _scrollController ??= ModalScrollController.ofSyncGroup(context)?.addAndGet() ?? ScrollController();
    List<NotificationPrefType> notificationPrefTypes = [...NotificationPrefType.values];
    final calendarIntegrationList = ref.watch(calendarIntegrationListControllerProvider).value ?? [];
    final mailIntegrationList = ref.watch(mailIntegrationListControllerProvider).value ?? [];
    final messengerIntegrationList = ref.watch(messengerIntegrationListControllerProvider).value ?? [];

    if (calendarIntegrationList.isEmpty) notificationPrefTypes.remove(NotificationPrefType.calendar);
    if (mailIntegrationList.isEmpty) notificationPrefTypes.remove(NotificationPrefType.email);
    if (messengerIntegrationList.isEmpty) notificationPrefTypes.remove(NotificationPrefType.chat);

    return DetailsItem(
      title: widget.isSmall ? context.tr.notification_pref_title : null,
      hideBackButton: !widget.isSmall,
      scrollController: _scrollController,
      scrollPhysics: Utils.getScrollPhysicsForBottomSheet(context, _scrollController),
      appbarColor: context.background,
      bodyColor: context.background,
      children: [
        VisirListItem(
          detailsBuilder: (height, baseStyle, subStyle, horizontalSpacing) {
            return Text.rich(
              TextSpan(
                children: [
                  WidgetSpan(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 6.0, bottom: 3),
                      child: VisirIcon(type: VisirIconType.caution, size: height, isSelected: true, color: context.error),
                    ),
                  ),
                  TextSpan(text: '\n', style: baseStyle),
                  TextSpan(text: context.tr.notification_pref_description, style: baseStyle),
                ],
              ),
            );
          },
        ),
        ...notificationPrefTypes
            .map((type) {
              return [
                VisirListSection(
                  titleBuilder: (height, baseStyle, subStyle, horizontalSpacing) => TextSpan(text: type.title, style: baseStyle),
                ),
                type.widget,
              ];
            })
            .expand((e) => e)
            .toList(),
      ],
    );
  }
}
