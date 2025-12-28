import 'dart:math';

import 'package:Visir/config/providers.dart';
import 'package:Visir/dependency/contextmenu/contextmenu.dart';
import 'package:Visir/dependency/modal_bottom_sheet/src/utils/modal_scroll_controller.dart';
import 'package:Visir/dependency/omni_datetime_picker/omni_datetime_picker.dart';
import 'package:Visir/dependency/omni_datetime_picker/src/omni_datetime_picker.dart';
import 'package:Visir/dependency/rrule/rrule.dart';
import 'package:Visir/dependency/showcase_tutorial/src/enum.dart';
import 'package:Visir/dependency/super_tag_editor/tag_editor.dart';
import 'package:Visir/dependency/toasty_box/model/toast_model.dart';
import 'package:Visir/features/auth/application/auth_controller.dart';
import 'package:Visir/features/calendar/actions.dart';
import 'package:Visir/features/calendar/application/calendar_list_controller.dart';
import 'package:Visir/features/calendar/domain/entities/calendar_entity.dart';
import 'package:Visir/features/calendar/domain/entities/event_attachment_entity.dart';
import 'package:Visir/features/calendar/domain/entities/event_attendee_entity.dart';
import 'package:Visir/features/calendar/domain/entities/event_entity.dart';
import 'package:Visir/features/calendar/domain/entities/event_reminder_entity.dart';
import 'package:Visir/features/calendar/presentation/widgets/calendar_desktop_date_field.dart';
import 'package:Visir/features/calendar/presentation/widgets/calendar_desktop_time_field.dart';
import 'package:Visir/features/calendar/presentation/widgets/calendar_reminder_edit_widget.dart';
import 'package:Visir/features/calendar/presentation/widgets/calendar_rrule_edit_widget.dart';
import 'package:Visir/features/calendar/presentation/widgets/calendar_simple_create_widget.dart';
import 'package:Visir/features/calendar/presentation/widgets/location_search_field.dart';
import 'package:Visir/features/calendar/providers.dart';
import 'package:Visir/features/common/domain/entities/linked_item_entity.dart';
import 'package:Visir/features/common/presentation/utils/constants.dart';
import 'package:Visir/features/common/presentation/utils/extensions/color_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/list_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/common/presentation/widgets/collapse_text_field.dart';
import 'package:Visir/features/common/presentation/widgets/custom_circualr_loading_indicator.dart';
import 'package:Visir/features/common/presentation/widgets/popup_menu.dart';
import 'package:Visir/features/common/presentation/widgets/selection_widget.dart';
import 'package:Visir/features/common/presentation/widgets/showcase_wrapper.dart';
import 'package:Visir/features/common/presentation/widgets/visir_app_bar.dart';
import 'package:Visir/features/common/presentation/widgets/visir_button.dart';
import 'package:Visir/features/common/presentation/widgets/visir_icon.dart';
import 'package:Visir/features/common/provider.dart';
import 'package:Visir/features/inbox/presentation/widgets/mobile_linked_message_mail_section.dart';
import 'package:Visir/features/preference/application/connection_list_controller.dart';
import 'package:Visir/features/preference/application/local_pref_controller.dart';
import 'package:Visir/features/preference/domain/entities/local_pref_entity.dart';
import 'package:Visir/features/preference/domain/entities/oauth_entity.dart';
import 'package:Visir/features/task/actions.dart';
import 'package:Visir/features/task/domain/entities/task_entity.dart';
import 'package:Visir/features/time_saved/actions.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';

class MobileCalendarEditWidget extends ConsumerStatefulWidget {
  final EventEntity? event;

  final String? initialTitle;
  final String? initialDescription;
  final String? initialLocation;
  final CalendarEntity? initialCalendar;
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;
  final bool? initialIsAllDay;
  final String? titleHintText;
  final LinkedMessageEntity? originalTaskMessage;
  final LinkedMailEntity? originalTaskMail;
  final List<LinkedMessageEntity>? linkedMessages;
  final List<LinkedMailEntity>? linkedMails;
  final CalendarTaskEditSourceType calendarTaskEditSourceType;

  final bool? isAllDay;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime selectedDate;
  final TabType tabType;

  final Widget? eventTaskSwitcher;
  final void Function(String title)? onTitleChanged;
  final void Function(String description)? onDescriptionChanged;
  final void Function(DateTime startDate)? onStartDateChanged;
  final void Function(DateTime endDate)? onEndDateChanged;
  final void Function(bool isAllDay)? onIsAllDayChanged;
  final void Function(CalendarEntity calendar)? onCalendarChanged;

  final Color? backgroundColor;

  const MobileCalendarEditWidget({
    super.key,
    required this.event,
    this.isAllDay,
    this.startDate,
    this.endDate,
    required this.selectedDate,
    this.initialTitle,
    this.initialDescription,
    this.originalTaskMessage,
    this.originalTaskMail,
    this.linkedMessages,
    this.linkedMails,
    this.initialLocation,
    this.initialCalendar,
    this.initialStartDate,
    this.initialEndDate,
    this.initialIsAllDay,
    this.titleHintText,
    required this.tabType,
    this.eventTaskSwitcher,
    this.onTitleChanged,
    this.onDescriptionChanged,
    this.onStartDateChanged,
    this.onEndDateChanged,
    this.onIsAllDayChanged,
    required this.calendarTaskEditSourceType,
    this.backgroundColor,
    this.onCalendarChanged,
  });

  @override
  ConsumerState createState() => _CalendarEditState();
}

class _CalendarEditState extends ConsumerState<MobileCalendarEditWidget> {
  EventAttendeeResponseStatus? loadingState;

  RruleL10n? rruleL10n;

  String? titleHintText;

  RecurrenceRule? rrule;
  String? title;
  String? description;
  String? location;
  CalendarEntity? calendar;
  List<CalendarEntity> calendars = [];

  List<EventAttendeeEntity> attendee = [];
  List<EventAttendeeEntity> suggestion = [];
  List<EventReminderEntity> reminders = [];
  List<EventAttachmentEntity> attachments = [];

  String? conferenceLink;
  final String tempConferenceLink = 'added';

  late DateTime initialStartDate;
  late DateTime initialEndDate;

  late DateTime startDate;
  late DateTime endDate;
  late DateTime savedStartDate;
  late DateTime savedEndDate;
  late bool isAllDay;
  late bool isAllDayInitial;

  bool isSetDifferentEndDate = false;

  bool attendeeExpanded = false;

  bool isCopy = false;

  GlobalKey<CalendarDesktopDateFieldState> desktopStartDateField = GlobalKey<CalendarDesktopDateFieldState>();
  GlobalKey<CalendarDesktopTimeFieldState> desktopStartTimeField = GlobalKey<CalendarDesktopTimeFieldState>();
  GlobalKey<CalendarDesktopDateFieldState> desktopEndDateField = GlobalKey<CalendarDesktopDateFieldState>();
  GlobalKey<CalendarDesktopTimeFieldState> desktopEndTimeField = GlobalKey<CalendarDesktopTimeFieldState>();

  RecurrenceOptionType get recurrenceOptionType =>
      RecurrenceOptionType.values.firstWhereOrNull((e) => e.getRecurrenceRule(startDate) == rrule) ?? RecurrenceOptionType.doesNotRepeat;

  bool get isRequest => widget.event != null && (widget.event?.isRequest ?? false);

  bool get isModifiable => widget.event == null || (widget.event != null && (widget.event?.isModifiable ?? false) && (widget.event?.calendar.owned ?? false));

  bool get isOrganizer => widget.event == null || (widget.event?.organizer == calendar?.email);

  bool get canSeeOtherGuests => widget.event == null || (widget.event != null && (widget.event?.canSeeOtherGuests ?? true));

  bool get canInviteOthers => widget.event == null || (widget.event != null && (widget.event?.canInviteOthers ?? true));

  bool get isSavable => widget.titleHintText != null || title?.isNotEmpty == true;

  bool get isIncludeConferenceLink {
    final user = ref.read(authControllerProvider).requireValue;
    return widget.tabType == TabType.calendar ? (user.userIncludeConferenceLinkOnCalendarTab) : (user.userIncludeConferenceLinkOnHomeTab);
  }

  ScrollController? _scrollController;

  @override
  void initState() {
    super.initState();

    if (widget.titleHintText != null) {
      titleHintText = widget.titleHintText;
    }

    rruleL10n = ref.read(rruleL10nEnProvider).asData?.value;
    final user = ref.read(authControllerProvider).requireValue;

    rrule = widget.event?.rrule == null ? null : RecurrenceRule.fromString(widget.event!.rrule!);
    title = widget.initialTitle ?? widget.event?.title;
    description = widget.initialDescription ?? widget.event?.description;
    location = widget.initialLocation ?? widget.event?.location;

    isAllDay = widget.initialIsAllDay ?? widget.event?.isAllDay ?? widget.isAllDay ?? false;
    isAllDayInitial = isAllDay;

    final now = DateTime.now();
    startDate =
        widget.initialStartDate ?? widget.startDate ?? widget.event?.startDate ?? DateTime(now.year, now.month, now.day, now.hour, (now.minute ~/ 15 + 1) * 15);
    endDate =
        widget.initialEndDate ??
        widget.endDate ??
        widget.event?.endDate ??
        startDate.add(isAllDay ? Duration(days: 1) : Duration(minutes: user.defaultDurationInMinutes ?? 60));

    conferenceLink = widget.event?.conferenceLink;

    if (isIncludeConferenceLink && (title ?? '').isEmpty) {
      conferenceLink = tempConferenceLink;
    }
    attachments = widget.event?.attachments ?? [];

    final newStartDate = widget.selectedDate;
    final newEndDate = widget.selectedDate.add(Duration(minutes: endDate.difference(startDate).inMinutes));

    if (!isAllDay) {
      startDate = startDate.add(Duration(days: newStartDate.difference(DateUtils.dateOnly(startDate)).inDays));
    } else {
      startDate = newStartDate;
    }

    if (!isAllDay) {
      endDate = endDate.add(Duration(days: newEndDate.difference(DateUtils.dateOnly(endDate)).inDays));
    } else {
      endDate = newEndDate;
    }

    if (isAllDay) {
      if (!DateUtils.isSameDay(endDate, startDate)) {
        endDate = endDate.subtract(Duration(days: 1));
      }
    }

    final calendarMap = ref.read(calendarListControllerProvider);
    final calendarHide = ref.read(calendarHideProvider(widget.tabType));
    final lastUsedCalendarIds = ref.read(lastUsedCalendarIdProvider);
    calendars = calendarMap.values.expand((e) => e).toList()
      ..removeWhere(
        (c) =>
            c.modifiable != true || calendarHide.contains(c.uniqueId) == true && c.uniqueId != (user.userDefaultCalendarId ?? lastUsedCalendarIds.firstOrNull),
      )
      ..unique((element) => element.uniqueId);

    calendar =
        widget.initialCalendar ??
        widget.event?.calendar ??
        (calendars
                .where((e) => e.uniqueId == (widget.event?.calendarUniqueId ?? user.userDefaultCalendarId ?? lastUsedCalendarIds.firstOrNull))
                .toList()
                .firstOrNull ??
            calendars.firstOrNull);

    if (calendar != null) {
      final sortedOrder = (calendars.where((e) => e.uniqueId != calendar!.uniqueId).toList()
        ..sort((a, b) => (a.email ?? '').compareTo(b.email ?? ''))
        ..sort((b, a) => (lastUsedCalendarIds.indexOf(a.uniqueId)).compareTo(lastUsedCalendarIds.indexOf(b.uniqueId))));
      calendars = [calendar!, ...sortedOrder];
    }

    attendee = widget.event?.attendees ?? [];
    reminders = isAllDay ? [] : [...(widget.event?.reminders ?? calendar?.defaultReminders ?? [])];

    initialStartDate = startDate;
    initialEndDate = endDate;
    savedStartDate = startDate;
    savedEndDate = endDate;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      UserActionSwtichAction.onCalendarAction();
    });
  }

  @override
  void dispose() {
    _scrollController?.dispose();
    super.dispose();
  }

  void updateCalendar(CalendarEntity calendar) {
    this.calendar = calendar;
    reminders = [...(calendar.defaultReminders ?? [])];
    setState(() {});
    if (widget.onCalendarChanged != null) {
      widget.onCalendarChanged!(calendar);
    }
  }

  void setStartDateTime(DateTime dateTime) {
    final diff = endDate.difference(startDate);
    if (isAllDay) {
      startDate = dateTime;
      endDate = dateTime;
    } else {
      startDate = dateTime;
      endDate = dateTime.add(diff);

      savedStartDate = startDate;
      savedEndDate = endDate;
    }
    if (widget.onStartDateChanged != null) {
      widget.onStartDateChanged!(startDate);
    }
    setState(() {});
  }

  void setEndDateTime(DateTime dateTime) {
    if (isAllDay) {
      endDate = dateTime;
      if (startDate.compareTo(dateTime) > 0) {
        startDate = dateTime;
      }
    } else {
      final user = ref.read(authControllerProvider).requireValue;

      endDate = dateTime;
      if (startDate.isAfter(dateTime)) {
        startDate = dateTime.subtract(
          Duration(minutes: (widget.tabType == TabType.home ? user.userDefaultDurationInMinutes : user.defaultDurationInMinutes) ?? 60),
        );
      }

      savedStartDate = startDate;
      savedEndDate = endDate;
    }
    if (widget.onEndDateChanged != null) {
      widget.onEndDateChanged!(endDate);
    }
    setState(() {});
  }

  Future<void> save() async {
    final user = ref.read(authControllerProvider).requireValue;

    if (calendar == null) return;
    if (widget.titleHintText != null && (title ?? '').isEmpty) {
      title = widget.titleHintText;
    }
    if (title?.isNotEmpty != true) return;
    attendee.removeWhere((e) => e.email == calendar!.email);

    final newEvent = EventEntity(
      calendarType: widget.event?.calendarType ?? calendar?.type ?? CalendarEntityType.google,
      eventId: isCopy ? Utils.generateBase32HexStringFromTimestamp() : widget.event?.eventId ?? Utils.generateBase32HexStringFromTimestamp(),
      title: title,
      description: description,
      rrule: isCopy ? null : rrule,
      location: location,
      isAllDay: isAllDay,
      startDate: startDate,
      endDate: endDate.add(Duration(days: isAllDay ? 1 : 0)),
      timezone: widget.event?.timezone ?? ref.read(timezoneProvider).value,
      attendees: [
        if (attendee.isNotEmpty &&
            attendee.where((e) => e.email == calendar!.email).isEmpty &&
            calendar!.email == calendar!.id &&
            (calendar!.type == CalendarEntityType.google || calendar!.type == null))
          EventAttendeeEntity(email: calendar!.email, organizer: true, responseStatus: EventAttendeeResponseStatus.accepted),
        ...attendee,
      ],
      reminders: reminders,
      attachments: attachments,
      conferenceLink: conferenceLink,
      modifiedEvent: widget.event,
      calendar: calendar!,
      sequence: (widget.event?.sequence ?? 0) + 1,
      doNotApplyDateOffset: true,
    );

    if (rrule == null || widget.event == null || widget.event?.recurrence == null) {
      Navigator.of(Utils.mainContext).popUntil((route) => route.isFirst);
    }

    ref.read(inboxLastCreateEventTypeProvider.notifier).update(InboxLastCreateEventType.calendar);
    ref.read(lastUsedCalendarIdProvider.notifier).set(calendar!.uniqueId);

    if (widget.originalTaskMail != null || widget.originalTaskMessage != null) {
      final task = TaskEntity(
        id: Uuid().v4(),
        ownerId: user.id,
        title: title,
        description: description,
        startAt: startDate,
        endAt: endDate.add(Duration(days: isAllDay ? 1 : 0)),
        isAllDay: isAllDay,
        rrule: isCopy ? null : rrule,
        excludedRecurrenceDate: isCopy ? null : [],
        recurrenceEndAt: isCopy ? null : endDate,
        linkedMails: widget.originalTaskMail == null ? [] : [widget.originalTaskMail!],
        linkedMessages: widget.originalTaskMessage == null ? [] : [widget.originalTaskMessage!],
        reminders: reminders,
        createdAt: DateTime.now(),
        status: TaskStatus.none,
        linkedEvent: newEvent,
      );

      await TaskAction.upsertTask(
        task: task,
        originalTask: task,
        calendarTaskEditSourceType: widget.calendarTaskEditSourceType,
        tabType: widget.tabType,
        selectedStartDate: initialStartDate,
        selectedEndDate: initialEndDate.add(Duration(days: isAllDayInitial ? 1 : 0)),
      );
    }

    await CalendarAction.editCalendarEvent(
      calendarTaskEditSourceType: widget.calendarTaskEditSourceType,
      tabType: widget.tabType,
      originalEvent: isCopy ? null : widget.event,
      newEvent: newEvent,
      selectedEndDate: initialEndDate.add(Duration(days: isAllDayInitial ? 1 : 0)),
      selectedStartDate: initialStartDate,
      isCreate: widget.event == null || isCopy,
      isLinkedWithMessages: widget.originalTaskMessage != null,
      isLinkedWithMails: widget.originalTaskMail != null,
      isChannel: (widget.originalTaskMessage?.isChannel ?? false),
      isRepeat: rrule != null,
      startDate: startDate,
    );

    if (widget.originalTaskMail != null || widget.originalTaskMessage != null) {
      Utils.showToast(
        ToastModel(
          message: TextSpan(text: Utils.mainContext.tr.event_created),
          buttons: [
            ToastButton(
              color: Utils.mainContext.primary,
              textColor: Utils.mainContext.onPrimary,
              text: Utils.mainContext.tr.event_created_undo,
              onTap: (item) {
                CalendarAction.editCalendarEvent(
                  tabType: widget.tabType,
                  originalEvent: newEvent,
                  newEvent: null,
                  selectedEndDate: initialEndDate.add(Duration(days: isAllDayInitial ? 1 : 0)),
                  selectedStartDate: initialStartDate,
                  isCreate: false,
                );
              },
            ),
          ],
        ),
      );
    }
  }

  Future<void> delete() async {
    if (widget.event == null) return;
    CalendarAction.editCalendarEvent(
      tabType: widget.tabType,
      originalEvent: widget.event,
      newEvent: null,
      selectedEndDate: initialEndDate.add(Duration(days: isAllDayInitial ? 1 : 0)),
      selectedStartDate: initialStartDate,
      isCreate: false,
    );
    if (rrule == null) Navigator.of(Utils.mainContext).popUntil((route) => route.isFirst);
  }

  Widget bodyDivider() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Divider(height: 1, thickness: 1, color: context.surface),
  );

  Widget allDayButton() {
    return VisirButton(
      type: VisirButtonAnimationType.scaleAndOpacity,
      style: VisirButtonStyle(
        margin: EdgeInsets.symmetric(horizontal: 4),
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        backgroundColor: isAllDay ? context.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isAllDay ? Colors.transparent : context.surface, width: 1),
      ),
      onTap: () {
        isAllDay = !isAllDay;
        reminders = [];

        if (isAllDay) {
          final startDateTime = DateUtils.dateOnly(startDate);
          final endDateTime = DateUtils.dateOnly(endDate.compareTo(startDateTime) < 0 ? startDateTime : endDate);

          startDate = DateUtils.dateOnly(startDateTime);
          endDate = DateUtils.dateOnly(endDateTime);
        } else {
          final startDateTime = DateTime(startDate.year, startDate.month, startDate.day, savedStartDate.hour, savedStartDate.minute);
          final endDateTime = DateTime(endDate.year, endDate.month, endDate.day, savedEndDate.hour, savedEndDate.minute);

          startDate = startDateTime;
          endDate = endDateTime;
          savedStartDate = startDate;
          savedEndDate = endDate;
        }
        if (widget.onIsAllDayChanged != null) {
          widget.onIsAllDayChanged!(isAllDay);
        }
        setState(() {});
      },
      child: Text(context.tr.all_day, style: context.titleSmall?.textColor(isAllDay ? context.onPrimary : context.outlineVariant)),
    );
  }

  Widget repeatButton() {
    return PopupMenu(
      beforePopup: () => FocusScope.of(context).unfocus(),
      forcePopup: true,
      location: PopupMenuLocation.bottom,
      width: 240,
      borderRadius: 6,
      type: ContextMenuActionType.tap,
      popup: SelectionWidget<RecurrenceOptionType>(
        current: recurrenceOptionType,
        items: RecurrenceOptionType.values,
        getTitle: (rruleOptionType) => rruleOptionType.getSelectionOptionTitle(rruleL10n, startDate, context),
        getChildIsPopup: (rruleOptionType) => rruleOptionType == RecurrenceOptionType.custom,
        getChildPopup: (rruleOptionType) => CalendarRruleEditWidget(
          initialRrule: this.rrule,
          startDate: startDate,
          onRruleChanged: (rrule) {
            this.rrule = rrule;
            setState(() {});

            WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
              if (Navigator.of(Utils.mainContext).canPop()) Navigator.of(Utils.mainContext).pop();
            });
          },
        ),
        onSelect: (rruleOptionType) {
          switch (rruleOptionType) {
            case RecurrenceOptionType.doesNotRepeat:
              this.rrule = null;
              setState(() {});
            case RecurrenceOptionType.daily:
            case RecurrenceOptionType.weeklyByWeekDay:
            case RecurrenceOptionType.monthlyByWeekDay:
            case RecurrenceOptionType.monthlyByMonthDay:
            case RecurrenceOptionType.annualy:
            case RecurrenceOptionType.weekdays:
              this.rrule = rruleOptionType.getRecurrenceRule(startDate);
              setState(() {});
            case RecurrenceOptionType.custom:
              break;
          }
        },
      ),
      style: VisirButtonStyle(
        backgroundColor: !(rruleL10n == null || rrule == null) ? context.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: !(rruleL10n == null || rrule == null) ? Colors.transparent : context.surface, width: 1),
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      ),
      child: Container(
        child: Text(
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          rruleL10n == null || rrule == null
              ? context.tr.calendar_event_edit_repeat
              : recurrenceOptionType == RecurrenceOptionType.annualy || recurrenceOptionType == RecurrenceOptionType.weekdays
              ? recurrenceOptionType.getSelectionOptionTitle(rruleL10n, startDate, context)
              : rrule!.toText(l10n: rruleL10n!),
          style: context.titleSmall?.textColor(!(rruleL10n == null || rrule == null) ? context.onPrimary : context.outlineVariant),
        ),
      ),
    );
  }

  Widget timeSection() {
    List<Widget> optionButtons = [];

    if (isModifiable) optionButtons.add(allDayButton());
    if (isModifiable || recurrenceOptionType != RecurrenceOptionType.doesNotRepeat) optionButtons.add(repeatButton());

    return Column(
      children: [
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 36,
                alignment: Alignment.centerLeft,
                child: VisirIcon(type: VisirIconType.clock, size: 20, isSelected: true),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    PopupMenu(
                      beforePopup: () => FocusScope.of(context).unfocus(),
                      enabled: isModifiable,
                      width: 296,
                      height: 300,
                      forcePopup: true,
                      location: PopupMenuLocation.bottom,
                      type: ContextMenuActionType.tap,
                      popup: OmniDateTimePicker(
                        type: OmniDateTimePickerType.date,
                        initialDate: startDate,
                        backgroundColor: context.surfaceVariant,
                        onDateChanged: setStartDateTime,
                      ),
                      style: VisirButtonStyle(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                        backgroundColor: context.surface,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(EventEntity.getDateForEditSimple(startDate), style: context.titleSmall?.textColor(context.outlineVariant)),
                    ),
                    if (!isAllDay)
                      PopupMenu(
                        beforePopup: () => FocusScope.of(context).unfocus(),
                        enabled: isModifiable,
                        width: 248,
                        height: 156,
                        forcePopup: true,
                        location: PopupMenuLocation.bottom,
                        type: ContextMenuActionType.tap,
                        popup: OmniDateTimePicker(
                          type: OmniDateTimePickerType.time,
                          initialDate: startDate,
                          onDateChanged: setStartDateTime,
                          minutesInterval: 5,
                        ),
                        style: VisirButtonStyle(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                          backgroundColor: context.surface,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(EventEntity.getTimeForEditWithMinutes(startDate), style: context.titleSmall!.textColor(context.outlineVariant)),
                      ),
                    if (isSetDifferentEndDate || isAllDay) ...[
                      if (isSetDifferentEndDate) SizedBox(width: double.infinity),
                      PopupMenu(
                        beforePopup: () => FocusScope.of(context).unfocus(),
                        enabled: isModifiable,
                        width: 296,
                        height: 300,
                        forcePopup: true,
                        location: PopupMenuLocation.bottom,
                        type: ContextMenuActionType.tap,
                        popup: OmniDateTimePicker(
                          type: OmniDateTimePickerType.date,
                          initialDate: endDate,
                          backgroundColor: context.surface,
                          onDateChanged: setEndDateTime,
                        ),
                        style: VisirButtonStyle(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                          backgroundColor: context.surface,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(EventEntity.getDateForEditSimple(endDate), style: context.titleSmall?.textColor(context.outlineVariant)),
                      ),
                    ],
                    if (!isAllDay)
                      PopupMenu(
                        beforePopup: () => FocusScope.of(context).unfocus(),
                        enabled: isModifiable,
                        width: 248,
                        height: 156 + 8 + 42,
                        forcePopup: true,
                        location: PopupMenuLocation.bottom,
                        type: ContextMenuActionType.tap,
                        backgroundColor: Colors.transparent,
                        popup: Column(
                          children: [
                            Container(
                              margin: EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(color: context.surface, borderRadius: BorderRadius.circular(12)),
                              child: OmniDateTimePicker(
                                type: OmniDateTimePickerType.time,
                                initialDate: endDate,
                                onDateChanged: setEndDateTime,
                                minutesInterval: 5,
                              ),
                            ),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: VisirButton(
                                type: VisirButtonAnimationType.scaleAndOpacity,
                                style: VisirButtonStyle(
                                  backgroundColor: context.tertiary,
                                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.25), blurRadius: 12, offset: Offset(0, 4))],
                                  height: 42,
                                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                onTap: () {
                                  setState(() {
                                    isSetDifferentEndDate = true;
                                    context.pop();
                                  });
                                },
                                child: Row(
                                  children: [
                                    VisirIcon(type: VisirIconType.calendar, size: 20, color: context.onTertiary, isSelected: true),
                                    const SizedBox(width: 10),
                                    Text(context.tr.set_different_end_date, style: context.titleMedium?.textColor(context.onTertiary)),
                                    Expanded(child: Container()),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        style: VisirButtonStyle(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                          backgroundColor: context.surface,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(EventEntity.getTimeForEditWithMinutes(endDate), style: context.titleSmall!.textColor(context.outlineVariant)),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!isAllDay && isModifiable)
          Container(
            width: double.maxFinite,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: EdgeInsets.only(left: 44, top: 12, right: 12),
                child: Row(
                  children: [15, 30, 45, 60, 75, 90, 120].map((e) {
                    final selected = e == endDate.difference(startDate).inMinutes;
                    return VisirButton(
                      type: VisirButtonAnimationType.scaleAndOpacity,
                      style: VisirButtonStyle(
                        margin: EdgeInsets.symmetric(horizontal: 4),
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                        backgroundColor: selected ? context.primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: selected ? Colors.transparent : context.surface, width: 1),
                      ),
                      onTap: () {
                        endDate = startDate.add(Duration(minutes: e));
                        savedEndDate = endDate;
                        setState(() {});
                      },
                      child: Text(
                        e < 60
                            ? '${e}m'
                            : e % 60 == 0
                            ? '${e ~/ 60}h'
                            : '${e ~/ 60}h ${e % 60}m',
                        style: context.titleSmall?.textColor(selected ? context.onPrimary : context.outlineVariant),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        if (optionButtons.isNotEmpty)
          Container(
            width: double.maxFinite,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: EdgeInsets.only(left: 44, top: 12, right: 16),
                child: Row(children: [allDayButton(), SizedBox(width: 4), repeatButton()]),
              ),
            ),
          ),
        const SizedBox(height: 16),
        bodyDivider(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    _scrollController ??= ModalScrollController.ofSyncGroup(context)?.addAndGet() ?? ScrollController();
    double borderRaidus = 8;

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Material(
        color: context.background,
        child: FocusTraversalGroup(
          child: Column(
            children: [
              VisirAppBar(
                title: widget.event == null
                    ? context.tr.calendar_event_create_title
                    : isModifiable
                    ? context.tr.calendar_event_edit_title
                    : context.tr.inbox_drag_event,
                leadings: [
                  VisirAppBarButton(
                    icon: VisirIconType.close,
                    onTap: Utils.mainContext.pop,
                    options: VisirButtonOptions(
                      tooltipLocation: VisirButtonTooltipLocation.right,
                      shortcuts: [
                        VisirButtonKeyboardShortcut(message: context.tr.close, keys: [LogicalKeyboardKey.escape]),
                      ],
                    ),
                  ),
                ],
                trailings: [
                  if (widget.event != null && isModifiable)
                    VisirAppBarButton(
                      onTap: () {
                        if (rrule == null) {
                          Utils.showMobileConfirmPopup(
                            title: context.tr.delete_event_confirm_popup_title,
                            description: context.tr.delete_event_confirm_popup_description,
                            cancelString: context.tr.delete_event_confirm_popup_cancel,
                            confirmString: context.tr.delete_event_confirm_popup_delete,
                            isWarning: true,
                            onPressConfirm: delete,
                          );
                        } else {
                          delete();
                        }
                      },
                      icon: VisirIconType.trash,
                    ),
                  if (widget.eventTaskSwitcher != null) VisirAppBarButton(child: widget.eventTaskSwitcher!, isContainer: true),
                  if (widget.event != null)
                    VisirAppBarButton(
                      onTap: () {
                        if (widget.event == null) return;
                        isCopy = true;
                        save();
                      },
                      icon: VisirIconType.copy,
                    ),
                  if (isModifiable) VisirAppBarButton(onTap: isSavable == true ? save : null, icon: VisirIconType.check),
                ],
              ),

              (_scrollController == null)
                  ? SizedBox.shrink()
                  : Expanded(
                      child: ShowcaseWrapper(
                        showcaseKey: taskLinkedChatShowcaseKeyString,
                        onBeforeShowcase: () async {
                          await Future.delayed(Duration(milliseconds: 1000));
                        },
                        tooltipPosition: TooltipPosition.top,
                        child: SingleChildScrollView(
                          physics: Utils.getScrollPhysicsForBottomSheet(context, _scrollController),
                          controller: _scrollController,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: CollapsingTextFormField(
                                  enabled: isModifiable,
                                  initialValue: title ?? '',
                                  textInputAction: TextInputAction.go,
                                  autofocus: widget.event == null,
                                  collapsedLines: 2,
                                  style: context.titleMedium?.textColor(context.outlineVariant),
                                  decoration: InputDecoration(
                                    hintText: titleHintText ?? context.tr.event_title,
                                    hintStyle: context.titleMedium?.textColor(context.surfaceTint),
                                    fillColor: Colors.transparent,
                                    contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 13),
                                    hoverColor: Colors.transparent,
                                    border: InputBorder.none,
                                    isCollapsed: true,
                                  ),
                                  onChanged: (text) {
                                    if (text.isEmpty) {
                                      titleHintText = widget.titleHintText ?? context.tr.event_title;
                                    } else {
                                      titleHintText = '';
                                    }

                                    title = text;
                                    if (widget.onTitleChanged != null) {
                                      widget.onTitleChanged!(title ?? text);
                                    }
                                    setState(() {});
                                  },
                                ),
                              ),
                              bodyDivider(),
                              if (isModifiable || location != null) ...[
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(top: context.textFieldPadding(16)),
                                        child: VisirIcon(type: VisirIconType.location, size: 20, isSelected: (location ?? '').isNotEmpty),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: LocationSearchField(
                                          enabled: isModifiable,
                                          initialValue: location,
                                          onSearchTextChanged: (text) {
                                            location = text;
                                            setState(() {});
                                          },
                                          decoration: InputDecorationTheme(
                                            contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 16),
                                            border: OutlineInputBorder(borderSide: BorderSide.none),
                                            fillColor: Colors.transparent,
                                            filled: true,
                                            isDense: true,
                                            hintStyle: context.titleMedium?.copyWith(color: context.surfaceTint),
                                            hoverColor: Colors.transparent,
                                          ),
                                          searchStyle: context.titleMedium?.textColor(context.outlineVariant),
                                          suggestionStyle: context.titleSmall?.textColor(context.outlineVariant),
                                          hint: context.tr.location,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                bodyDivider(),
                              ],
                              if (isModifiable || description != null) ...[
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(top: context.textFieldPadding(16)),
                                        child: VisirIcon(type: VisirIconType.description, size: 20, isSelected: (description ?? '').isNotEmpty),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: CollapsingTextFormField(
                                          enabled: isModifiable,
                                          initialValue: description ?? '',
                                          textInputAction: TextInputAction.newline,
                                          style: context.titleMedium?.copyWith(color: context.outlineVariant),
                                          collapsedLines: 5,
                                          decoration: InputDecoration(
                                            constraints: BoxConstraints(minHeight: 44),
                                            hintText: context.tr.description,
                                            contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 16),
                                            border: OutlineInputBorder(borderSide: BorderSide.none),
                                            fillColor: Colors.transparent,
                                            hoverColor: Colors.transparent,
                                            filled: true,
                                            isDense: true,
                                            hintStyle: context.titleMedium?.copyWith(color: context.surfaceTint),
                                          ),
                                          onChanged: (text) {
                                            description = text;
                                            if (widget.onDescriptionChanged != null) {
                                              widget.onDescriptionChanged!(description ?? text);
                                            }
                                            setState(() {});
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                bodyDivider(),
                              ],
                              MobileLinkedMessageMailSection(
                                bodyDivider: bodyDivider(),
                                originalTaskMessage: widget.originalTaskMessage,
                                originalTaskMail: widget.originalTaskMail,
                                tabType: widget.tabType,
                                linkedMails: widget.linkedMails,
                                linkedMessages: widget.linkedMessages,
                                isEvent: true,
                              ),
                              timeSection(),
                              if (calendars.isNotEmpty && calendar != null)
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    const SizedBox(height: 8),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 20,
                                            height: 20,
                                            decoration: BoxDecoration(color: ColorX.fromHex(calendar!.backgroundColor), borderRadius: BorderRadius.circular(6)),
                                          ),
                                          SizedBox(width: 12),
                                          Expanded(
                                            child: LayoutBuilder(
                                              builder: (context, constraints) {
                                                return PopupMenu(
                                                  beforePopup: () => FocusScope.of(context).unfocus(),
                                                  enabled: isModifiable,
                                                  forcePopup: true,
                                                  location: PopupMenuLocation.bottom,
                                                  width: constraints.maxWidth,
                                                  borderRadius: 6,
                                                  type: ContextMenuActionType.tap,
                                                  popup: SelectionWidget<CalendarEntity>(
                                                    current: calendar!,
                                                    items: [calendar!, ...calendars.where((e) => e.uniqueId != calendar!.uniqueId)],
                                                    getChild: (calendar) {
                                                      return Row(
                                                        children: [
                                                          SizedBox(width: 12),
                                                          Container(
                                                            width: 16,
                                                            height: 16,
                                                            decoration: BoxDecoration(
                                                              color: ColorX.fromHex(calendar.backgroundColor),
                                                              borderRadius: BorderRadius.circular(4),
                                                            ),
                                                          ),
                                                          SizedBox(width: 10),
                                                          Expanded(
                                                            child: Text(
                                                              calendar.name,
                                                              style: context.bodyLarge!.textColor(context.outlineVariant),
                                                              maxLines: 1,
                                                              overflow: TextOverflow.ellipsis,
                                                            ),
                                                          ),
                                                          SizedBox(width: 12),
                                                        ],
                                                      );
                                                    },
                                                    onSelect: updateCalendar,
                                                  ),
                                                  style: VisirButtonStyle(
                                                    height: 28,
                                                    width: double.maxFinite,
                                                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                    borderRadius: BorderRadius.circular(6),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Expanded(child: Text(calendar!.name, style: context.titleMedium?.textColor(context.outlineVariant))),
                                                      if (isModifiable) VisirIcon(type: VisirIconType.arrowDown, size: 12),
                                                      SizedBox(width: 8),
                                                    ],
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (isModifiable)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 10),
                                        child: SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: Padding(
                                            padding: const EdgeInsets.only(left: 44, right: 16),
                                            child: Row(
                                              children: calendars
                                                  .sublist(0, calendars.length)
                                                  .map(
                                                    (e) => IntrinsicWidth(
                                                      child: VisirButton(
                                                        type: VisirButtonAnimationType.scaleAndOpacity,
                                                        style: VisirButtonStyle(
                                                          margin: EdgeInsets.symmetric(horizontal: 4),
                                                          alignment: Alignment.centerLeft,
                                                          height: 36,
                                                          backgroundColor: e.uniqueId == calendar!.uniqueId
                                                              ? ColorX.fromHex(e.backgroundColor)
                                                              : Colors.transparent,
                                                          borderRadius: BorderRadius.circular(borderRaidus),
                                                          border: Border.all(
                                                            color: e.uniqueId == calendar!.uniqueId ? Colors.transparent : context.surface,
                                                            width: 1,
                                                          ),
                                                          padding: EdgeInsets.symmetric(horizontal: 8),
                                                        ),
                                                        onTap: () => updateCalendar(e),
                                                        child: Text(
                                                          e.name,
                                                          style: context.titleSmall?.textColor(
                                                            e.uniqueId == calendar!.uniqueId ? ColorX.fromHex(e.foregroundColor) : context.outlineVariant,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                  .toList(),
                                            ),
                                          ),
                                        ),
                                      ),
                                    SizedBox(height: 16),
                                    bodyDivider(),
                                  ],
                                ),
                              if (isModifiable || (canSeeOtherGuests && attendee.isNotEmpty)) ...[
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(top: context.textFieldPadding(16)),
                                        child: VisirIcon(type: VisirIconType.attendee, size: 20, isSelected: attendee.isNotEmpty),
                                      ),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            if (attendee.length > 5)
                                              VisirButton(
                                                type: VisirButtonAnimationType.scaleAndOpacity,
                                                style: VisirButtonStyle(
                                                  alignment: Alignment.centerLeft,
                                                  hoverColor: Colors.transparent,
                                                  margin: EdgeInsets.only(top: 8, bottom: 8),
                                                ),
                                                onTap: () {
                                                  setState(() {
                                                    attendeeExpanded = !attendeeExpanded;
                                                  });
                                                },
                                                child: Row(
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: [
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          Text(
                                                            '${attendee.length} ${context.tr.guests}',
                                                            style: context.titleSmall?.textColor(context.outlineVariant),
                                                            maxLines: 1,
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                          const SizedBox(height: 4),
                                                          Text(
                                                            '${attendee.where((e) => e.responseStatus == EventAttendeeResponseStatus.accepted).length} ${context.tr.yes}, '
                                                            '${attendee.where((e) => e.responseStatus == EventAttendeeResponseStatus.declined).length} ${context.tr.no}, '
                                                            '${attendee.where((e) => e.responseStatus == EventAttendeeResponseStatus.needsAction).length} ${context.tr.awaiting}',
                                                            style: context.bodyLarge?.textColor(context.surfaceTint),
                                                            maxLines: 1,
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    const SizedBox(width: 12),
                                                    AnimatedRotation(
                                                      duration: Duration(milliseconds: 150),
                                                      turns: attendeeExpanded ? 0.5 : 0,
                                                      child: VisirIcon(type: VisirIconType.arrowDown, size: 16),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            if (attendeeExpanded || attendee.length <= 5)
                                              Padding(
                                                padding: EdgeInsets.only(
                                                  top: attendee.length > 5 ? 0 : (attendee.isEmpty ? 8 : 10),
                                                  bottom: attendee.isEmpty ? 8 : 10,
                                                ),
                                                child: TagEditor<EventAttendeeEntity>(
                                                  enabled: isModifiable,
                                                  offset: 10,
                                                  length: attendee.length,
                                                  delimiters: [',', ' '],
                                                  hasAddButton: false,
                                                  borderRadius: 6,
                                                  suggestionsBoxRadius: 6,
                                                  keyboardType: TextInputType.emailAddress,
                                                  onTagChanged: (newValue) {
                                                    attendee.add(EventAttendeeEntity(email: newValue));
                                                    setState(() {});
                                                  },
                                                  padding: EdgeInsets.zero,
                                                  borderColor: Colors.transparent,
                                                  backgroundColor: Colors.transparent,
                                                  inputDecoration: InputDecoration(
                                                    hintText: context.tr.add_guest,
                                                    contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                                                    border: OutlineInputBorder(borderSide: BorderSide.none),
                                                    fillColor: Colors.transparent,
                                                    hoverColor: Colors.transparent,
                                                    filled: true,
                                                    isDense: true,
                                                    hintStyle: context.titleMedium?.copyWith(color: context.surfaceTint),
                                                  ),
                                                  textStyle: context.titleMedium?.textColor(context.outlineVariant),
                                                  tagBuilder: (context, index) {
                                                    return Container(
                                                      height: 32,
                                                      decoration: BoxDecoration(color: context.surface, borderRadius: BorderRadius.circular(borderRaidus)),
                                                      padding: EdgeInsets.only(left: 10, right: 2),
                                                      margin: EdgeInsets.only(right: 8, top: max(0, context.textFieldPadding(16) - 14)),
                                                      child: IntrinsicWidth(
                                                        child: Row(
                                                          children: [
                                                            if (attendee[index].responseStatus == EventAttendeeResponseStatus.accepted)
                                                              VisirIcon(
                                                                type: VisirIconType.checkWithCircle,
                                                                size: 14,
                                                                color: context.errorContainer,
                                                                isSelected: true,
                                                              ),
                                                            if (attendee[index].responseStatus == EventAttendeeResponseStatus.tentative)
                                                              VisirIcon(
                                                                type: VisirIconType.helpWithCircle,
                                                                size: 14,
                                                                color: context.secondaryContainer,
                                                                isSelected: true,
                                                              ),
                                                            if (attendee[index].responseStatus == EventAttendeeResponseStatus.declined)
                                                              VisirIcon(
                                                                type: VisirIconType.closeWithCircle,
                                                                size: 14,
                                                                color: context.error,
                                                                isSelected: true,
                                                              ),
                                                            if (attendee[index].responseStatus == EventAttendeeResponseStatus.needsAction)
                                                              VisirIcon(
                                                                type: VisirIconType.unknownWithCircle,
                                                                size: 14,
                                                                color: context.onBackground,
                                                                isSelected: true,
                                                              ),
                                                            if (attendee[index].responseStatus != null) SizedBox(width: 6),
                                                            Expanded(
                                                              child: Padding(
                                                                padding: const EdgeInsets.only(bottom: 2),
                                                                child: Text(
                                                                  '${attendee[index].email ?? attendee[index].displayName ?? ''}${attendee[index].organizer == true ? ' (${context.tr.mail_organizer})' : ''}',
                                                                  style: context.titleSmall?.textColor(context.outlineVariant),
                                                                ),
                                                              ),
                                                            ),
                                                            isModifiable && !isRequest && isOrganizer
                                                                ? VisirButton(
                                                                    type: VisirButtonAnimationType.scaleAndOpacity,
                                                                    style: VisirButtonStyle(padding: EdgeInsets.all(borderRaidus)),
                                                                    onTap: () {
                                                                      attendee.removeAt(index);
                                                                      setState(() {});
                                                                    },
                                                                    child: VisirIcon(type: VisirIconType.closeWithCircle, size: 16, isSelected: true),
                                                                  )
                                                                : SizedBox(width: borderRaidus, height: 16 + 2 * borderRaidus),
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                  onDeleteTagAction: () {
                                                    if (attendee.isEmpty) return;
                                                    attendee.removeLast();
                                                    setState(() {});
                                                  },
                                                  suggestionsBoxBackgroundColor: context.surfaceVariant,
                                                  suggestionItemHeight: 46,
                                                  suggestionPadding: EdgeInsets.symmetric(vertical: 6),
                                                  suggestionMargin: EdgeInsets.symmetric(vertical: 8),
                                                  suggestionBuilder: (context, state, data, index, length, highlight, suggestionValid) => Container(
                                                    width: double.maxFinite,
                                                    height: 46,
                                                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                    child: suggestion.length > index
                                                        ? Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                            children: [
                                                              Text(
                                                                suggestion[index].email!,
                                                                style: context.bodyLarge?.textColor(context.outlineVariant),
                                                                maxLines: 1,
                                                                overflow: TextOverflow.ellipsis,
                                                              ),
                                                              if (suggestion[index].displayName != null && suggestion[index].displayName!.isNotEmpty)
                                                                Padding(
                                                                  padding: const EdgeInsets.only(top: 4.0),
                                                                  child: Text(
                                                                    suggestion[index].displayName!,
                                                                    style: context.bodySmall?.textColor(context.onInverseSurface),
                                                                    maxLines: 1,
                                                                    overflow: TextOverflow.ellipsis,
                                                                  ),
                                                                ),
                                                            ],
                                                          )
                                                        : SizedBox.shrink(),
                                                  ),
                                                  onSelectOptionAction: (value) {
                                                    attendee.add(value);
                                                    suggestion.clear();
                                                    setState(() {});
                                                  },
                                                  suggestionsBoxElevation: 0,
                                                  findSuggestions: (String query) async {
                                                    if (query.isEmpty) return [];

                                                    List<EventAttendeeEntity> tempList = [];
                                                    final email = calendar?.email;

                                                    final oauth = ref
                                                        .read(localPrefControllerProvider)
                                                        .value
                                                        ?.calendarOAuths
                                                        ?.firstWhereOrNull((e) => e.email == email && e.type.calendarType == calendar?.type);

                                                    if (oauth == null) return [];

                                                    final emailConnections = await ref
                                                        .read(connectionListControllerProvider.notifier)
                                                        .search(provider: oauth.uniqueId, query: query);

                                                    emailConnections.removeWhere(
                                                      (p) => attendee.map((e) => e.email ?? '').toSet().intersection(([p.email]).toSet()).isNotEmpty,
                                                    );
                                                    emailConnections.forEach((p) {
                                                      final email = p.email;
                                                      final name = p.name;
                                                      if (email?.contains(query) == true || name?.contains(query) == true) {
                                                        tempList.add(EventAttendeeEntity(email: email, displayName: name));
                                                      }
                                                    });

                                                    tempList.sort((a, b) {
                                                      if (a.email == null) return -1;
                                                      if (b.email == null) return -1;

                                                      final aEmailIndex = a.email?.indexOf(query);
                                                      final bEmailIndex = b.email?.indexOf(query);

                                                      final aNameIndex = a.displayName?.indexOf(query);
                                                      final bNameIndex = b.displayName?.indexOf(query);

                                                      final aIndex = aNameIndex == null
                                                          ? aEmailIndex
                                                          : aEmailIndex == null
                                                          ? aNameIndex
                                                          : aNameIndex < 0
                                                          ? aEmailIndex
                                                          : aEmailIndex < 0
                                                          ? aNameIndex
                                                          : min(aNameIndex, aEmailIndex);

                                                      final bIndex = bNameIndex == null
                                                          ? bEmailIndex
                                                          : bEmailIndex == null
                                                          ? bNameIndex
                                                          : bNameIndex < 0
                                                          ? bEmailIndex
                                                          : bEmailIndex < 0
                                                          ? bNameIndex
                                                          : min(bNameIndex, bEmailIndex);

                                                      return aIndex! < bIndex! ? -1 : 1;
                                                    });

                                                    List<EventAttendeeEntity> list = Map.fromEntries(tempList.map((e) => MapEntry(e.email, e))).values.toList();

                                                    suggestion = list.sublist(0, list.length > 5 ? 5 : list.length);
                                                    setState(() {});
                                                    return suggestion;
                                                  },
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                bodyDivider(),
                              ],
                              if (reminders.isNotEmpty) ...[
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.symmetric(vertical: 16),
                                        child: VisirIcon(type: VisirIconType.notification, size: 20, isSelected: reminders.isNotEmpty),
                                      ),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 10),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Wrap(
                                                spacing: 8,
                                                runSpacing: 8,
                                                children: reminders.map((e) {
                                                  return Container(
                                                    height: 32,
                                                    decoration: BoxDecoration(color: context.surface, borderRadius: BorderRadius.circular(borderRaidus)),
                                                    padding: EdgeInsets.only(left: 10, right: 2),
                                                    child: IntrinsicWidth(
                                                      child: Row(
                                                        children: [
                                                          Text(
                                                            getReminderString(context: context, isAllDay: isAllDay, minute: e.minutes ?? 0),
                                                            style: context.titleSmall?.textColor(context.outlineVariant),
                                                          ),
                                                          VisirButton(
                                                            type: VisirButtonAnimationType.scaleAndOpacity,
                                                            style: VisirButtonStyle(padding: EdgeInsets.all(borderRaidus)),
                                                            onTap: () {
                                                              reminders.remove(e);
                                                              setState(() {});
                                                            },
                                                            child: VisirIcon(type: VisirIconType.closeWithCircle, size: 16, isSelected: true),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                }).toList(),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                bodyDivider(),
                              ],
                              if (conferenceLink != null && conferenceLink != tempConferenceLink) ...[
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.symmetric(vertical: 16),
                                        child: VisirIcon(type: VisirIconType.videoCall, size: 20, isSelected: conferenceLink != null),
                                      ),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: VisirButton(
                                          type: VisirButtonAnimationType.scaleAndOpacity,
                                          style: VisirButtonStyle(alignment: Alignment.centerLeft),
                                          onTap: () => Utils.launchUrlExternal(url: conferenceLink),
                                          child: Text(
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            (conferenceLink ?? '').replaceFirst('https://', '').replaceFirst('http://', ''),
                                            style: context.titleMedium?.textColor(context.primary),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      IntrinsicWidth(
                                        child: VisirButton(
                                          type: VisirButtonAnimationType.scaleAndOpacity,
                                          style: VisirButtonStyle(
                                            borderRadius: BorderRadius.circular(borderRaidus),
                                            border: Border.all(color: context.surface, width: 1),
                                            padding: EdgeInsets.all(9),
                                          ),
                                          onTap: () {
                                            if (conferenceLink == null) return;
                                            Share.shareUri(Uri.parse(conferenceLink!));
                                          },
                                          child: VisirIcon(type: VisirIconType.share, size: 16),
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      IntrinsicWidth(
                                        child: VisirButton(
                                          type: VisirButtonAnimationType.scaleAndOpacity,
                                          style: VisirButtonStyle(
                                            borderRadius: BorderRadius.circular(borderRaidus),
                                            border: Border.all(color: context.surface, width: 1),
                                            padding: EdgeInsets.all(9),
                                          ),
                                          onTap: () {
                                            conferenceLink = null;
                                            setState(() {});
                                          },
                                          child: VisirIcon(type: VisirIconType.trash, size: 16),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                bodyDivider(),
                              ],
                              SizedBox(height: 12),
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  return SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: [
                                        SizedBox(width: 16),
                                        if (isModifiable)
                                          PopupMenu(
                                            beforePopup: () => FocusScope.of(context).unfocus(),
                                            enabled: isModifiable,
                                            forcePopup: true,
                                            location: PopupMenuLocation.bottom,
                                            width: min(240, constraints.maxWidth),
                                            type: ContextMenuActionType.tap,
                                            popup: SelectionWidget<int>(
                                              current: 0,
                                              items: isAllDay ? [-1, 0, 5, 10, 60 * 13, 60 * 24] : [-1, 0, 5, 10, 30, 60, 60 * 24],
                                              getTitle: (minute) {
                                                return getReminderString(context: context, isAllDay: isAllDay, minute: minute);
                                              },
                                              getChildIsPopup: (minute) => minute == -1,
                                              getChildPopup: (type) => CalendarReminderEditWidget(
                                                initialReminder: EventReminderEntity(minutes: 10, method: 'popup'),
                                                isAllDay: isAllDay,
                                                onReminderChanged: (reminder) {
                                                  if (!reminders.contains(reminder)) {
                                                    reminders.add(reminder);
                                                    setState(() {});
                                                  }

                                                  WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                                                    if (Navigator.of(Utils.mainContext).canPop()) Navigator.of(Utils.mainContext).pop();
                                                  });
                                                },
                                              ),
                                              onSelect: (minute) {
                                                if (minute >= 0) {
                                                  if (!reminders.contains(EventReminderEntity(minutes: minute, method: 'popup'))) {
                                                    reminders.add(EventReminderEntity(minutes: minute, method: 'popup'));
                                                    setState(() {});
                                                  }
                                                }
                                              },
                                            ),
                                            style: VisirButtonStyle(
                                              margin: EdgeInsets.only(right: 8),
                                              borderRadius: BorderRadius.circular(borderRaidus),
                                              border: Border.all(color: context.surface, width: 1),
                                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                                            ),
                                            child: Row(
                                              children: [
                                                VisirIcon(type: VisirIconType.notification, size: 16, isSelected: true),
                                                SizedBox(width: 10),
                                                Text(context.tr.reminder, style: context.titleSmall?.textColor(context.outlineVariant)),
                                              ],
                                            ),
                                          ),
                                        if (widget.event == null
                                            ? true
                                            : (isModifiable || conferenceLink != null) && (conferenceLink == null || conferenceLink == tempConferenceLink))
                                          IntrinsicWidth(
                                            child: VisirButton(
                                              type: VisirButtonAnimationType.scaleAndOpacity,
                                              style: VisirButtonStyle(
                                                backgroundColor: conferenceLink != null ? context.primary : Colors.transparent,
                                                borderRadius: BorderRadius.circular(borderRaidus),
                                                border: Border.all(color: conferenceLink != null ? Colors.transparent : context.surface, width: 1),
                                                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                                              ),
                                              onTap: () {
                                                if (conferenceLink == null) {
                                                  conferenceLink = widget.event?.conferenceLink ?? tempConferenceLink;
                                                } else {
                                                  conferenceLink = null;
                                                }
                                                setState(() {});
                                              },
                                              child: Row(
                                                children: [
                                                  VisirIcon(type: VisirIconType.videoCall, size: 16, isSelected: conferenceLink != null),
                                                  SizedBox(width: 10),
                                                  Text(
                                                    context.tr.conference,
                                                    style: context.titleSmall?.textColor(
                                                      conferenceLink != null ? context.onPrimary : VisirIcon.disabledColor(context),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  );
                                },
                              ),

                              SizedBox(height: scrollViewBottomPadding.bottom + context.viewInset.bottom),
                            ],
                          ),
                        ),
                      ),
                    ),
              if (attendee.any((e) => e.email == calendar?.email))
                Container(
                  padding: EdgeInsets.only(top: 12, bottom: max(12, context.padding.bottom), left: 16, right: 16),
                  decoration: BoxDecoration(color: context.surface, borderRadius: BorderRadius.circular(12), boxShadow: PopupMenu.popupShadow),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(child: Text(context.tr.going_question, style: context.titleMedium?.textColor(context.outlineVariant))),
                      SizedBox(width: 48),
                      ...[EventAttendeeResponseStatus.accepted, EventAttendeeResponseStatus.declined, EventAttendeeResponseStatus.tentative].map<Widget>((e) {
                          final myStatus = attendee.firstWhere((e) => e.email == calendar?.email).responseStatus;
                          return Expanded(
                            child: VisirButton(
                              type: VisirButtonAnimationType.scaleAndOpacity,
                              style: VisirButtonStyle(
                                cursor: SystemMouseCursors.click,
                                backgroundColor: e == myStatus ? context.tertiary : Colors.transparent,
                                // backgroundColor: e.getBackgroundColor(context),
                                borderRadius: BorderRadius.circular(19),
                                border: e == myStatus ? null : Border.all(color: context.onBackground.withValues(alpha: 0.5), width: 1),
                                width: double.maxFinite,
                                height: 38,
                                alignment: Alignment.center,
                              ),
                              onTap: () async {
                                if (widget.event == null) return;
                                loadingState = e;
                                setState(() {});
                                await CalendarAction.responseCalendarInvitation(status: e, event: widget.event!, context: context, tabType: widget.tabType);
                                loadingState = null;
                                setState(() {});
                                Navigator.of(Utils.mainContext).popUntil((route) => route.isFirst);
                              },
                              child: loadingState == e
                                  ? CustomCircularLoadingIndicator(size: 20, color: e.getForegroundColor(context))
                                  : Text(
                                      e.getTitle(context),
                                      style: context.titleSmall
                                          ?.copyWith(color: e == myStatus ? context.onTertiary : context.onBackground.withValues(alpha: 0.5))
                                          .appFont(context),
                                    ),
                            ),
                          );
                        }).toList()
                        ..insert(1, SizedBox(width: 8))
                        ..insert(3, SizedBox(width: 8)),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
