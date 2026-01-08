import 'dart:math';

import 'package:Visir/config/providers.dart';
import 'package:Visir/dependency/contextmenu/contextmenu.dart';
import 'package:Visir/features/common/provider.dart';
import 'package:Visir/dependency/omni_datetime_picker/omni_datetime_picker.dart';
import 'package:Visir/dependency/omni_datetime_picker/src/omni_datetime_picker.dart';
import 'package:Visir/dependency/rrule/rrule.dart';
import 'package:Visir/dependency/rrule/src/utils.dart';
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
import 'package:Visir/features/calendar/presentation/widgets/calendar_desktop_time_field_simple_create.dart';
import 'package:Visir/features/calendar/presentation/widgets/calendar_reminder_edit_widget.dart';
import 'package:Visir/features/calendar/presentation/widgets/calendar_rrule_edit_widget.dart';
import 'package:Visir/features/calendar/presentation/widgets/location_search_field.dart';
import 'package:Visir/features/calendar/providers.dart';
import 'package:Visir/features/common/domain/entities/linked_item_entity.dart';
import 'package:Visir/features/common/presentation/utils/constants.dart';
import 'package:Visir/features/common/presentation/utils/extensions/color_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/list_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/platform_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/common/presentation/widgets/collapse_text_field.dart';
import 'package:Visir/features/common/presentation/widgets/custom_circualr_loading_indicator.dart';
import 'package:Visir/features/common/presentation/widgets/desktop_scaffold.dart';
import 'package:Visir/features/common/presentation/widgets/popup_menu.dart';
import 'package:Visir/features/common/presentation/widgets/popup_menu_container.dart';
import 'package:Visir/features/common/presentation/widgets/popup_menu_theme.dart';
import 'package:Visir/features/common/presentation/widgets/selection_widget.dart';
import 'package:Visir/features/common/presentation/widgets/showcase_wrapper.dart';
import 'package:Visir/features/common/presentation/widgets/visir_button.dart';
import 'package:Visir/features/common/presentation/widgets/visir_icon.dart';
import 'package:Visir/features/inbox/presentation/widgets/simple_linked_message_mail_section.dart';
import 'package:Visir/features/inbox/presentation/widgets/agent_input_field.dart';
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
import 'package:intl/intl.dart';
import 'package:super_clipboard/super_clipboard.dart';
import 'package:time/time.dart';
import 'package:uuid/uuid.dart';

enum RecurrenceOptionType { custom, doesNotRepeat, daily, weeklyByWeekDay, monthlyByWeekDay, monthlyByMonthDay, annualy, weekdays }

extension RecurrenceOptionTypeX on RecurrenceOptionType {
  RecurrenceRule? getRecurrenceRule(DateTime startDate) {
    switch (this) {
      case RecurrenceOptionType.doesNotRepeat:
        return null;
      case RecurrenceOptionType.daily:
        return RecurrenceRule(frequency: Frequency.daily);
      case RecurrenceOptionType.weeklyByWeekDay:
        return RecurrenceRule(frequency: Frequency.weekly, byWeekDays: [ByWeekDayEntry(startDate.weekday)]);
      case RecurrenceOptionType.monthlyByWeekDay:
        return RecurrenceRule(frequency: Frequency.monthly, byWeekDays: [ByWeekDayEntry(startDate.weekday, startDate.weekOfMonth)]);
      case RecurrenceOptionType.monthlyByMonthDay:
        return RecurrenceRule(frequency: Frequency.monthly, byMonthDays: [startDate.day]);
      case RecurrenceOptionType.annualy:
        return RecurrenceRule(frequency: Frequency.yearly, byMonths: [startDate.month], byMonthDays: [startDate.day]);
      case RecurrenceOptionType.weekdays:
        return RecurrenceRule(
          frequency: Frequency.weekly,
          byWeekDays: startDate.weekday == 6 || startDate.weekday == 7
              ? [ByWeekDayEntry(6), ByWeekDayEntry(7)]
              : [ByWeekDayEntry(1), ByWeekDayEntry(2), ByWeekDayEntry(3), ByWeekDayEntry(4), ByWeekDayEntry(5)],
        );
      case RecurrenceOptionType.custom:
        return null;
    }
  }

  String getSelectionOptionTitle(RruleL10n? rruleL10n, DateTime startDate, BuildContext context) {
    switch (this) {
      case RecurrenceOptionType.doesNotRepeat:
        return context.tr.does_not_repeat;
      case RecurrenceOptionType.custom:
        return context.tr.custom_reminder;
      case RecurrenceOptionType.weekdays:
        return startDate.weekday == 6 || startDate.weekday == 7 ? context.tr.every_weekend_saturday_to_sunday : context.tr.every_weekday_monday_to_friday;
      case RecurrenceOptionType.annualy:
        return '${context.tr.annualy_on} ${DateFormat('MMM d').format(startDate)}';
      case RecurrenceOptionType.monthlyByMonthDay:
      case RecurrenceOptionType.daily:
      case RecurrenceOptionType.weeklyByWeekDay:
      case RecurrenceOptionType.monthlyByWeekDay:
        return getRecurrenceRule(startDate)?.toText(l10n: rruleL10n!) ?? '';
    }
  }
}

enum ReminderOptionType { none, atTheStart, fiveMinutesBefore, tenMinutesBefore, thirtyMinutesBefore, hourBefore, thirteenHourBefore, dayBefore, custom }

extension ReminderOptionTypeX on ReminderOptionType {
  int minutes() {
    switch (this) {
      case ReminderOptionType.none:
      case ReminderOptionType.custom:
        return -1;
      case ReminderOptionType.atTheStart:
        return 0;
      case ReminderOptionType.fiveMinutesBefore:
        return 5;
      case ReminderOptionType.tenMinutesBefore:
        return 10;
      case ReminderOptionType.thirtyMinutesBefore:
        return 30;
      case ReminderOptionType.hourBefore:
        return 60;
      case ReminderOptionType.thirteenHourBefore:
        return 60 * 13;
      case ReminderOptionType.dayBefore:
        return 60 * 24;
    }
  }

  String getSelectionOptionTitle(BuildContext context, bool isAllDay) {
    if (isAllDay) {
      final interval = this.minutes();

      int days = interval ~/ (60 * 24);
      if (days != interval / 60 / 24) days += 1;

      final minutesInDay = interval % (60 * 24);
      final isWeek = days % 7 == 0;
      final count = isWeek ? days ~/ 7 : days;
      final minutes = minutesInDay == 0 ? 0 : 60 * 24 - minutesInDay;
      final hour = minutes ~/ 60;
      final min = minutes % 60;

      switch (this) {
        case ReminderOptionType.none:
          return context.tr.none;
        case ReminderOptionType.custom:
          return context.tr.custom_reminder;
        case ReminderOptionType.atTheStart:
          return context.tr.at_start_event;
        case ReminderOptionType.fiveMinutesBefore:
        case ReminderOptionType.tenMinutesBefore:
        case ReminderOptionType.thirtyMinutesBefore:
        case ReminderOptionType.hourBefore:
        case ReminderOptionType.thirteenHourBefore:
        case ReminderOptionType.dayBefore:
          return isWeek
              ? context.tr.week_before_at(count, hour == 24 && min == 0 ? 'midnight' : TimeOfDay(hour: hour, minute: min).format(context))
              : context.tr.day_before_at(count, hour == 0 && min == 0 ? 'midnight' : TimeOfDay(hour: hour, minute: min).format(context));
      }
    } else {
      final interval = this.minutes();
      final hourDiff = interval ~/ 60;
      final minDiff = interval % 60;
      switch (this) {
        case ReminderOptionType.none:
          return context.tr.none;
        case ReminderOptionType.custom:
          return context.tr.custom_reminder;
        case ReminderOptionType.atTheStart:
          return context.tr.at_start_event;
        case ReminderOptionType.fiveMinutesBefore:
        case ReminderOptionType.tenMinutesBefore:
        case ReminderOptionType.thirtyMinutesBefore:
        case ReminderOptionType.hourBefore:
        case ReminderOptionType.thirteenHourBefore:
        case ReminderOptionType.dayBefore:
          return '${hourDiff == 0
                  ? ''
                  : hourDiff == 1
                  ? context.tr.reminder_hour
                  : context.tr.reminder_hours(hourDiff)} ${minDiff == 0
                  ? ''
                  : minDiff == 1
                  ? context.tr.reminder_minute
                  : context.tr.reminder_minutes(minDiff)} ${context.tr.before}'
              .trim();
      }
    }
  }
}

enum CalendarTaskEditSourceType { drag, doubleClick, fab, message, mail, addTaskTop, addTaskOnDate, inboxDrag, inboxSuggestion, editOriginal, commandBarEdit, commandBarDetail }

extension CalendarTaskEditSourceTypeX on CalendarTaskEditSourceType {
  String getAnalyticsEventTitle({required TabType tabType, required bool isEvent, required bool isLinkedWithMessages, required bool isLinkedWithMails, required bool isChannel}) {
    switch (this) {
      case CalendarTaskEditSourceType.drag:
        if (tabType == TabType.calendar) return 'calendar_drag_${isEvent ? 'event' : 'task'}';
        if (tabType == TabType.home) return 'home_drag_${isEvent ? 'event' : 'task'}';
        return '';
      case CalendarTaskEditSourceType.doubleClick:
        if (tabType == TabType.calendar) return 'calendar_double_click_${isEvent ? 'event' : 'task'}';
        if (tabType == TabType.home) return 'home_double_click_${isEvent ? 'event' : 'task'}';
        return '';
      case CalendarTaskEditSourceType.fab:
        if (tabType == TabType.task) return 'task_add_fab';
        if (tabType == TabType.home) return 'home_fab_${isEvent ? 'event' : 'task'}';
        return '';
      case CalendarTaskEditSourceType.message:
        if (tabType == TabType.chat) return 'chat_${isChannel ? 'channel' : 'dm'}_create_${isEvent ? 'event' : 'task'}';
        return '';
      case CalendarTaskEditSourceType.mail:
        if (tabType == TabType.mail) return 'mail_create_${isEvent ? 'event' : 'task'}';
        return '';
      case CalendarTaskEditSourceType.addTaskTop:
        if (tabType == TabType.task) return 'task_add_top';
        return '';
      case CalendarTaskEditSourceType.addTaskOnDate:
        if (tabType == TabType.task) return 'task_add_date';
        return '';
      case CalendarTaskEditSourceType.inboxDrag:
        if (tabType == TabType.home)
          return isLinkedWithMessages
              ? 'inbox_slack_drag_${isEvent ? 'event' : 'task'}'
              : isLinkedWithMails
              ? 'inbox_gmail_drag_${isEvent ? 'event' : 'task'}'
              : '';
        return '';
      case CalendarTaskEditSourceType.inboxSuggestion:
        if (tabType == TabType.home)
          return isLinkedWithMessages
              ? 'inbox_slack_suggestion_${isEvent ? 'event' : 'task'}'
              : isLinkedWithMails
              ? 'inbox_gmail_suggestion_${isEvent ? 'event' : 'task'}'
              : '';
        return '';
      case CalendarTaskEditSourceType.editOriginal:
        return '';
      case CalendarTaskEditSourceType.commandBarEdit:
        return 'calendar_command_bar_create_${isEvent ? 'event' : 'task'}';
      case CalendarTaskEditSourceType.commandBarDetail:
        return 'calendar_command_bar_detail_${isEvent ? 'event' : 'task'}';
    }
  }

  Map<String, dynamic>? getAnalyticsEventProperties({required TabType tabType, required bool isChannel, required bool isRepeat, required DateTime startAt}) {
    switch (this) {
      case CalendarTaskEditSourceType.drag:
      case CalendarTaskEditSourceType.doubleClick:
      case CalendarTaskEditSourceType.fab:
        if (tabType == TabType.calendar || tabType == TabType.home) return {'is_repeat': isRepeat.toString()};
        return null;
      case CalendarTaskEditSourceType.addTaskTop:
        if (tabType == TabType.task) return {'is_repeat': isRepeat.toString()};
        return null;
      case CalendarTaskEditSourceType.addTaskOnDate:
        DateTime today = DateTime.now().toLocal();
        today = DateTime(today.year, today.month, today.day);
        DateTime targetDate = DateTime(startAt.year, startAt.month, startAt.day);
        if (tabType == TabType.task) return {'is_repeat': isRepeat.toString(), 'date_after': targetDate.difference(today).inDays.toString()};
        return null;
      case CalendarTaskEditSourceType.inboxDrag:
      case CalendarTaskEditSourceType.inboxSuggestion:
      case CalendarTaskEditSourceType.message:
      case CalendarTaskEditSourceType.mail:
      case CalendarTaskEditSourceType.editOriginal:
      case CalendarTaskEditSourceType.commandBarEdit:
      case CalendarTaskEditSourceType.commandBarDetail:
        return null;
    }
  }
}

class CalenderSimpleCreateWidget extends ConsumerStatefulWidget {
  final EventEntity? event;
  final bool? isAllDay;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime selectedDate;
  final TabType tabType;
  final CalendarTaskEditSourceType calendarTaskEditSourceType;
  final DateTime? savedStartDate;
  final DateTime? savedEndDate;
  final String? titleHintText;
  final String? description;
  final LinkedMessageEntity? originalTaskMessage;
  final LinkedMailEntity? originalTaskMail;
  final List<LinkedMessageEntity>? linkedMessages;
  final List<LinkedMailEntity>? linkedMails;

  final void Function()? onRemoveCreateShadow;
  final void Function()? onSaved;
  final void Function(String? title)? onTitleChanged;
  final void Function(Color? color)? onColorChanged;
  final void Function(DateTime startTime, DateTime endTime, bool isAllDay)? onTimeChanged;
  final void Function(EventEntity event)? onEventChanged;
  final bool? forceCreate;
  final bool? isEdited;
  final bool? isCommandResult;

  final Color? backgroundColor;

  const CalenderSimpleCreateWidget({
    super.key,
    this.event,
    this.isAllDay,
    this.startDate,
    this.endDate,
    required this.tabType,
    required this.selectedDate,
    required this.calendarTaskEditSourceType,
    this.onRemoveCreateShadow,
    this.onTitleChanged,
    this.onColorChanged,
    this.onSaved,
    this.onTimeChanged,
    this.onEventChanged,
    this.forceCreate,
    this.savedStartDate,
    this.savedEndDate,
    this.isEdited,
    this.titleHintText,
    this.description,
    this.originalTaskMessage,
    this.originalTaskMail,
    this.linkedMessages,
    this.linkedMails,
    this.backgroundColor,
    this.isCommandResult,
  });

  @override
  ConsumerState createState() => CalenderSimpleCreateWidgetState();
}

class CalenderSimpleCreateWidgetState extends ConsumerState<CalenderSimpleCreateWidget> {
  String? titleHintText;

  EventAttendeeResponseStatus? loadingState;

  RruleL10n? rruleL10n;

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

  final FocusNode locationSearchFieldFocusNode = FocusNode();
  final FocusNode titleFocusNode = FocusNode();
  final FocusNode descriptionFocusNode = FocusNode();
  final FocusNode attendeeFocusNode = FocusNode();

  late DateTime initialStartDate;
  late DateTime initialEndDate;

  late DateTime startDate;
  late DateTime endDate;
  late bool isAllDay;
  late bool isAllDayInitial;

  late DateTime savedStartDate;
  late DateTime savedEndDate;
  late bool isEdited;

  bool doNotSave = false;
  bool isCopy = false;

  bool get isOwned => widget.event?.calendar.owned ?? false;

  bool get isRequest => widget.event != null && (widget.event?.isRequest ?? false);

  bool get isFocused => titleFocusNode.hasFocus || descriptionFocusNode.hasFocus || locationSearchFieldFocusNode.hasFocus || attendeeFocusNode.hasFocus;

  bool get isModifiable => widget.event == null || (widget.event?.isModifiable ?? false);

  bool get isOrganizer => widget.event == null || (widget.event?.organizer == calendar?.email);

  bool get canSeeOtherGuests => widget.event == null || (widget.event != null && (widget.event?.canSeeOtherGuests ?? true));

  bool get canInviteOthers => widget.event == null || (widget.event != null && (widget.event?.canInviteOthers ?? true));

  RecurrenceOptionType get recurrenceOptionType =>
      RecurrenceOptionType.values.firstWhereOrNull((e) => e.getRecurrenceRule(startDate) == rrule) ?? RecurrenceOptionType.doesNotRepeat;

  late String eventId;

  late TextEditingController descriptionController;

  double timeFieldPopupHeight = 240;

  bool attendeeExpanded = false;

  bool get isDarkMode => context.isDarkMode;

  bool get isIncludeConferenceLink {
    final user = ref.read(authControllerProvider).requireValue;
    return widget.tabType == TabType.calendar ? (user.userIncludeConferenceLinkOnCalendarTab) : (user.userIncludeConferenceLinkOnHomeTab);
  }

  VisirButtonTooltipLocation bottomButtonTooltipLocation = VisirButtonTooltipLocation.bottom;

  @override
  void initState() {
    super.initState();

    rruleL10n = ref.read(rruleL10nEnProvider).asData?.value;
    final user = ref.read(authControllerProvider).requireValue;

    if (widget.titleHintText != null) {
      titleHintText = widget.titleHintText;
    }

    isAllDay = widget.event?.isAllDay ?? widget.isAllDay ?? false;
    isAllDayInitial = isAllDay;
    eventId = widget.event?.eventId ?? Utils.generateBase32HexStringFromTimestamp();

    final now = DateTime.now();
    startDate = widget.event?.startDate ?? widget.startDate ?? DateTime(now.year, now.month, now.day, now.hour, (now.minute ~/ 15 + 1) * 15);
    endDate =
        widget.event?.endDate ??
        widget.endDate ??
        startDate.add(isAllDay ? Duration(days: 1) : Duration(minutes: (widget.tabType == TabType.home ? user.userDefaultDurationInMinutes : user.defaultDurationInMinutes) ?? 60));

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
      ..removeWhere((c) => c.modifiable != true || calendarHide.contains(c.uniqueId) == true && c.uniqueId != (user.userDefaultCalendarId ?? lastUsedCalendarIds.firstOrNull))
      ..unique((element) => element.uniqueId);

    calendar =
        widget.event?.calendar ??
        (calendars
                .where((e) => e.uniqueId == ((widget.tabType == TabType.home ? user.userDefaultCalendarId : user.userDefaultCalendarId) ?? lastUsedCalendarIds.firstOrNull))
                .toList()
                .firstOrNull ??
            calendars.firstOrNull);

    if (calendar != null) {
      final sortedOrder = (calendars.where((e) => e.uniqueId != calendar!.uniqueId).toList()
        ..sort((a, b) => (a.email ?? '').compareTo(b.email ?? ''))
        ..sort((b, a) => (lastUsedCalendarIds.indexOf(a.uniqueId)).compareTo(lastUsedCalendarIds.indexOf(b.uniqueId))));
      calendars = [calendar!, ...sortedOrder];
    }

    reminders = widget.event?.reminders ?? (isAllDay ? [] : [...(calendar?.defaultReminders ?? [])]);

    rrule = widget.event?.rrule == null ? null : RecurrenceRule.fromString(widget.event!.rrule!);
    title = widget.event?.title;
    description = widget.description == null ? widget.event?.description : widget.description;
    location = widget.event?.location;

    attendee = widget.event?.attendees ?? [];
    attendee = [...(attendee.where((e) => e.organizer == true)), ...(attendee.where((e) => e.organizer != true))];
    attachments = widget.event?.attachments ?? [];

    conferenceLink = widget.event?.conferenceLink;

    if (isIncludeConferenceLink && title == null) {
      conferenceLink = tempConferenceLink;
    }

    initialStartDate = startDate;
    initialEndDate = endDate;
    savedStartDate = widget.savedStartDate ?? (isAllDay ? DateTime(now.year, now.month, now.day, now.hour, (now.minute ~/ 15 + 1) * 15) : startDate);
    savedEndDate =
        widget.savedEndDate ??
        (isAllDay ? DateTime(now.year, now.month, now.day, now.hour, (now.minute ~/ 15 + 1) * 15).add(Duration(minutes: user.userTaskDefaultDurationInMinutes)) : endDate);

    isEdited = widget.isEdited ?? false;

    titleFocusNode.onKeyEvent = onKeyEventTextField;
    descriptionFocusNode.onKeyEvent = onKeyEventTextField;
    locationSearchFieldFocusNode.onKeyEvent = onKeyEventTextField;
    attendeeFocusNode.onKeyEvent = onKeyEventTextField;

    descriptionController = TextEditingController(text: description);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onColorChanged?.call(ColorX.fromHex(calendar!.backgroundColor));
      widget.onTitleChanged?.call(title ?? 'New Event');
      UserActionSwtichAction.onCalendarAction();
    });

    Future.delayed(Duration(milliseconds: 500), () {
      if (!mounted) return;
      final RenderBox renderBox = context.findRenderObject() as RenderBox;
      final Size size = renderBox.size;
      final Offset offset = renderBox.localToGlobal(Offset.zero);

      if ((size.height + offset.dy - Utils.mainContext.height).abs() < 100) {
        bottomButtonTooltipLocation = VisirButtonTooltipLocation.top;
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    widget.onRemoveCreateShadow?.call();
    locationSearchFieldFocusNode.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  KeyEventResult onKeyEventTextField(FocusNode node, KeyEvent event) {
    final key = event.logicalKey;

    if (event is KeyDownEvent) {
      final logicalKeyPressed = ServicesBinding.instance.keyboard.logicalKeysPressed.toList();
      if (descriptionFocusNode.hasFocus && logicalKeyPressed.length == 2 && logicalKeyPressed.isShiftPressed && logicalKeyPressed.contains(LogicalKeyboardKey.enter)) {
        // Shift + Enter 입력 시 줄바꿈을 처리
        final text = descriptionController.text;
        final selection = descriptionController.selection;
        // 현재 커서 위치에 줄바꿈 삽입
        final newText = text.replaceRange(selection.start, selection.end, '\n');
        // 줄바꿈 이후 새로운 위치로 커서 이동
        descriptionController.value = TextEditingValue(
          text: newText,
          selection: TextSelection.collapsed(offset: selection.start + 1),
        );
        return KeyEventResult.handled;
      }
      if (ServicesBinding.instance.keyboard.logicalKeysPressed.length == 1 && key == LogicalKeyboardKey.escape) {
        onEscapePressed();
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  void onEventChanged() {
    if (calendar == null) return;

    final event = EventEntity(
      calendarType: calendar?.type ?? CalendarEntityType.google,
      eventId: eventId,
      title: title,
      description: description,
      rrule: rrule,
      location: location,
      isAllDay: isAllDay,
      startDate: startDate,
      timezone: widget.event?.timezone ?? ref.read(timezoneProvider).value,
      endDate: endDate,
      attendees: attendee,
      reminders: reminders,
      attachments: attachments,
      conferenceLink: conferenceLink,
      modifiedEvent: widget.event,
      calendar: calendar!,
      sequence: widget.event == null ? 1 : widget.event!.sequence + 1,
    );

    widget.onEventChanged?.call(event);
  }

  void updateCalendar(CalendarEntity calendar) {
    isEdited = true;
    this.calendar = calendar;
    reminders = [...(calendar.defaultReminders ?? [])];
    setState(() {});
    onEventChanged();
  }

  void onEscapePressed() {
    if (attendeeFieldKey.currentState?.isOpen ?? false) {
      attendeeFieldKey.currentState?.closeSuggestionBox(isClearData: true);
      return;
    }

    if (locationFieldKey.currentState?.isSuggestionExists() == true) {
      locationFieldKey.currentState?.closeSuggestion();
      return;
    }

    titleFocusNode.unfocus();
    descriptionFocusNode.unfocus();
    locationSearchFieldFocusNode.unfocus();
    attendeeFocusNode.unfocus();
    doNotSave = true;
    Navigator.of(Utils.mainContext).maybePop();
  }

  void startChat() {
    // Get current event - only tag if event exists
    EventEntity? currentEvent = widget.event;
    if (currentEvent == null) {
      return;
    }

    // Navigate to home tab
    Navigator.maybeOf(Utils.mainContext)?.popUntil((route) => route.isFirst);
    tabNotifier.value = TabType.home;
    UserActionSwtichAction.onSwtichTab(targetTab: TabType.home);

    // Add tag to AgentInputField after navigation - retry multiple times
    void tryAddTag({int retryCount = 0}) {
      // Find AgentInputFieldState from widget tree
      AgentInputFieldState? agentInputFieldState;
      try {
        agentInputFieldState = AgentInputField.of(Utils.mainContext);
      } catch (e) {
        // Ignore
      }

      // Check if state is valid and mounted
      if (agentInputFieldState != null && agentInputFieldState.mounted) {
        // Check if messageController is still valid (not disposed)
        try {
          // Try to access messageController to check if it's disposed
          final controller = agentInputFieldState.messageController;
          final _ = controller.text; // This will throw if disposed

          agentInputFieldState.addEventTag(currentEvent);
          agentInputFieldState.requestFocus();
        } catch (e) {
          if (retryCount < 5) {
            Future.delayed(Duration(milliseconds: (retryCount + 1) * 200), () {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                tryAddTag(retryCount: retryCount + 1);
              });
            });
          }
        }
      } else if (retryCount < 5) {
        Future.delayed(Duration(milliseconds: (retryCount + 1) * 200), () {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            tryAddTag(retryCount: retryCount + 1);
          });
        });
      }
    }

    Future.delayed(Duration(milliseconds: 300), () {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        tryAddTag();
      });
    });
  }

  void setStartDateTime(DateTime dateTime) {
    isEdited = true;
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
    setState(() {});

    widget.onTimeChanged?.call(startDate, endDate, isAllDay);
    onEventChanged();
  }

  void setEndDateTime(DateTime dateTime) {
    isEdited = true;
    if (isAllDay) {
      endDate = dateTime;
      if (startDate.compareTo(dateTime) > 0) {
        startDate = dateTime;
      }
    } else {
      final user = ref.read(authControllerProvider).requireValue;

      endDate = dateTime;
      if (startDate.compareTo(dateTime) > 0) {
        startDate = dateTime.subtract(Duration(minutes: (widget.tabType == TabType.home ? user.userDefaultDurationInMinutes : user.defaultDurationInMinutes) ?? 60));
      }

      savedStartDate = startDate;
      savedEndDate = endDate;
    }
    setState(() {});

    widget.onTimeChanged?.call(startDate, endDate, isAllDay);
    onEventChanged();
  }

  Future<void> delete() async {
    if (widget.event == null) return;
    if (isRequest) {
      Navigator.of(Utils.mainContext).popUntil((route) => route.isFirst);
      await CalendarAction.responseCalendarInvitation(status: EventAttendeeResponseStatus.declined, event: widget.event!, context: context, tabType: widget.tabType);
    } else {
      Navigator.of(Utils.mainContext).maybePop();
      await CalendarAction.editCalendarEvent(
        tabType: widget.tabType,
        originalEvent: widget.event,
        newEvent: null,
        selectedEndDate: initialEndDate.add(Duration(days: isAllDayInitial ? 1 : 0)),
        selectedStartDate: initialStartDate,
        isCreate: false,
      );
    }
  }

  Future<void> copy() async {
    if (widget.event == null) return;
    eventId = Utils.generateBase32HexStringFromTimestamp();
    isEdited = true;
    isCopy = true;
    Navigator.of(Utils.mainContext).maybePop();
  }

  Future<void> save() async {
    if (doNotSave) return;
    if (widget.titleHintText != null && (title ?? '').isEmpty) {
      title = widget.titleHintText;
      isEdited = true;
    }

    if (!isEdited) return;
    if (title?.isNotEmpty != true) return;
    final user = ref.read(authControllerProvider).requireValue;
    if (calendar == null) return;

    final newAttendee = [
      if (attendee.isNotEmpty && calendar!.email == calendar!.id && (calendar!.type == CalendarEntityType.google || calendar!.type == null))
        EventAttendeeEntity(email: calendar!.email, organizer: true, responseStatus: EventAttendeeResponseStatus.accepted),
      ...(attendee.where((e) => e.email != calendar!.email)),
    ];

    final newEvent = EventEntity(
      calendarType: calendar?.type ?? CalendarEntityType.google,
      eventId: eventId,
      title: title,
      description: description,
      rrule: isCopy ? null : rrule,
      location: location,
      isAllDay: isAllDay,
      startDate: startDate,
      endDate: endDate.add(Duration(days: isAllDay ? 1 : 0)),
      timezone: widget.event?.timezone ?? ref.read(timezoneProvider).value,
      attendees: newAttendee,
      reminders: reminders,
      attachments: attachments,
      conferenceLink: conferenceLink,
      modifiedEvent: widget.event,
      calendar: calendar!,
      sequence: widget.event == null ? 1 : widget.event!.sequence + 1,
    );

    widget.onRemoveCreateShadow?.call();

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
      tabType: widget.tabType,
      originalEvent: isCopy ? null : widget.event,
      newEvent: newEvent,
      selectedEndDate: initialEndDate.add(Duration(days: isAllDayInitial ? 1 : 0)),
      selectedStartDate: initialStartDate,
      isCreate: widget.forceCreate ?? (isCopy ? true : widget.event == null),
      calendarTaskEditSourceType: widget.calendarTaskEditSourceType,
      isLinkedWithMessages: widget.originalTaskMessage != null,
      isLinkedWithMails: widget.originalTaskMail != null,
      isChannel: (widget.originalTaskMessage?.isChannel ?? false),
      isRepeat: rrule != null,
      startDate: startDate,
      showToast: true,
    );

    widget.onSaved?.call();
  }

  Widget allDayButton() {
    return VisirButton(
      type: VisirButtonAnimationType.scaleAndOpacity,
      style: VisirButtonStyle(
        cursor: SystemMouseCursors.click,
        margin: EdgeInsets.only(right: 4),
        padding: EdgeInsets.symmetric(horizontal: 6 + (isAllDay ? 1 : 0), vertical: 4 + (isAllDay ? 1 : 0)),
        backgroundColor: isAllDay ? context.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(4),
        border: isAllDay ? null : Border.all(color: context.surfaceVariant, width: 1),
      ),
      onTap: isModifiable && !isRequest
          ? () {
              isEdited = true;
              isAllDay = !isAllDay;
              reminders = [];

              if (isAllDay) {
                final startDateTime = DateUtils.dateOnly(startDate);
                final endDateTime = DateUtils.dateOnly(endDate.compareTo(startDateTime) < 0 ? startDateTime : endDate);

                startDate = DateUtils.dateOnly(startDateTime);
                endDate = DateUtils.dateOnly(endDateTime);
              } else {
                DateTime startDateTime = DateTime(startDate.year, startDate.month, startDate.day, savedStartDate.hour, savedStartDate.minute);
                DateTime endDateTime = DateTime(endDate.year, endDate.month, endDate.day, savedEndDate.hour, savedEndDate.minute);

                if (endDateTime.isBefore(startDateTime)) endDateTime = endDateTime.add(Duration(days: 1));

                startDate = startDateTime;
                endDate = endDateTime;
                savedStartDate = startDate;
                savedEndDate = endDate;
              }
              setState(() {});

              widget.onTimeChanged?.call(startDate, endDate, isAllDay);
              onEventChanged();
            }
          : null,
      child: Text(context.tr.all_day, style: context.bodyLarge?.textColor(isAllDay ? context.onPrimary : context.outlineVariant)),
    );
  }

  Widget repeatButton() {
    return Flexible(
      child: PopupMenu(
        enabled: isModifiable && !isRequest,
        forcePopup: true,
        location: PopupMenuLocation.bottom,
        width: 280,
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
              isEdited = true;
              this.rrule = rrule;
              setState(() {});
              onEventChanged();

              WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                if (Navigator.of(Utils.mainContext).canPop()) Navigator.of(Utils.mainContext).pop();
              });
            },
          ),
          onSelect: (rruleOptionType) {
            switch (rruleOptionType) {
              case RecurrenceOptionType.doesNotRepeat:
                isEdited = true;
                this.rrule = null;
                setState(() {});
                onEventChanged();
                break;
              case RecurrenceOptionType.daily:
              case RecurrenceOptionType.weeklyByWeekDay:
              case RecurrenceOptionType.monthlyByWeekDay:
              case RecurrenceOptionType.monthlyByMonthDay:
              case RecurrenceOptionType.annualy:
              case RecurrenceOptionType.weekdays:
                isEdited = true;
                this.rrule = rruleOptionType.getRecurrenceRule(startDate);
                setState(() {});
                onEventChanged();
                break;
              case RecurrenceOptionType.custom:
                break;
            }
          },
        ),
        style: VisirButtonStyle(
          borderRadius: BorderRadius.circular(4),
          border: rruleL10n == null || rrule == null ? Border.all(color: context.surfaceVariant, width: 1) : null,
          backgroundColor: rruleL10n == null || rrule == null ? Colors.transparent : context.primary,
          padding: EdgeInsets.symmetric(horizontal: 6 + (rruleL10n == null || rrule == null ? 0 : 1), vertical: 4 + (rruleL10n == null || rrule == null ? 0 : 1)),
        ),
        child: Text(
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          rruleL10n == null || rrule == null
              ? context.tr.calendar_event_edit_repeat
              : recurrenceOptionType == RecurrenceOptionType.annualy || recurrenceOptionType == RecurrenceOptionType.weekdays
              ? recurrenceOptionType.getSelectionOptionTitle(rruleL10n, startDate, context)
              : rrule!.toText(l10n: rruleL10n!),
          style: context.bodyLarge?.textColor(rruleL10n == null || rrule == null ? context.outlineVariant : context.onPrimary),
        ),
      ),
    );
  }

  Widget timeSection({required bool isOverMultipleDays}) {
    List<Widget> optionButtons = [];

    if (isModifiable && !isRequest) optionButtons.add(allDayButton());
    if ((isModifiable && !isRequest) || recurrenceOptionType != RecurrenceOptionType.doesNotRepeat) optionButtons.add(repeatButton());

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(left: 16, right: 16, top: 11),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 10, top: 5),
                child: VisirIcon(type: VisirIconType.clock, size: 14, isSelected: true),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: [
                        PopupMenu(
                          enabled: isModifiable && !isRequest,
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
                            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 5),
                            backgroundColor: context.surfaceVariant,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(EventEntity.getDateForEditSimple(startDate), style: context.bodyLarge?.textColor(context.outlineVariant)),
                        ),
                        if (!isAllDay)
                          PopupMenu(
                            enabled: isModifiable && !isRequest,
                            width: 160,
                            height: timeFieldPopupHeight,
                            forcePopup: true,
                            location: PopupMenuLocation.bottom,
                            type: ContextMenuActionType.tap,
                            borderRadius: 6,
                            popup: CalendarDesktopTimeFieldSimpleCreate(
                              isAllDay: isAllDay,
                              selectedDateTime: startDate,
                              onDateChanged: setStartDateTime,
                              isEndDateTime: false,
                              startDateTime: startDate,
                              endDateTime: endDate,
                              height: timeFieldPopupHeight,
                            ),
                            style: VisirButtonStyle(
                              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 5),
                              backgroundColor: context.surfaceVariant,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(EventEntity.getTimeForEdit(startDate), style: context.bodyLarge?.textColor(context.outlineVariant)),
                          ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 5),
                          child: Text(context.tr.to, style: context.bodyLarge?.textColor(context.outlineVariant)),
                        ),
                        if (isOverMultipleDays || isAllDay) ...[
                          if (!isAllDay) SizedBox(width: double.infinity),
                          PopupMenu(
                            enabled: isModifiable && !isRequest,
                            width: 296,
                            height: 300,
                            forcePopup: true,
                            location: PopupMenuLocation.bottom,
                            type: ContextMenuActionType.tap,
                            popup: OmniDateTimePicker(
                              type: OmniDateTimePickerType.date,
                              initialDate: endDate,
                              backgroundColor: context.surfaceVariant,
                              onDateChanged: setEndDateTime,
                            ),
                            style: VisirButtonStyle(
                              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 5),
                              backgroundColor: context.surfaceVariant,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(EventEntity.getDateForEditSimple(endDate), style: context.bodyLarge?.textColor(context.outlineVariant)),
                          ),
                        ],
                        if (!isAllDay)
                          PopupMenu(
                            enabled: isModifiable && !isRequest,
                            width: 180,
                            height: timeFieldPopupHeight,
                            forcePopup: true,
                            location: PopupMenuLocation.bottom,
                            type: ContextMenuActionType.tap,
                            borderRadius: 6,
                            popup: CalendarDesktopTimeFieldSimpleCreate(
                              isAllDay: isAllDay,
                              selectedDateTime: endDate,
                              onDateChanged: setEndDateTime,
                              isEndDateTime: true,
                              startDateTime: startDate,
                              endDateTime: endDate,
                              height: timeFieldPopupHeight,
                            ),
                            style: VisirButtonStyle(
                              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 5),
                              backgroundColor: context.surfaceVariant,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(EventEntity.getTimeForEdit(endDate), style: context.bodyLarge?.textColor(context.outlineVariant)),
                          ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: optionButtons.isEmpty ? 0 : 8),
                      child: Row(children: optionButtons),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void onTextFieldSubmitted(String text) {
    Navigator.of(Utils.mainContext).maybePop();
  }

  GlobalKey<LocationSearchFieldState> locationFieldKey = GlobalKey();
  GlobalKey<TagsEditorState> attendeeFieldKey = GlobalKey();

  Widget bodyDivider({bool? forceShow}) {
    if (forceShow != true) return SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, top: 12),
      height: 1,
      decoration: BoxDecoration(color: context.context.surfaceVariant),
    );
  }

  @override
  Widget build(BuildContext context) {
    final borderRaidus = 6.0;

    bool isOverMultipleDays = startDate.date != endDate.date;

    final linkedMails = widget.linkedMails ?? [];
    final linkedMessages = widget.linkedMessages ?? [];

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        save();
      },
      child: Theme(
        data: context.theme.popupTheme,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (isModifiable && !isRequest)
              Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Container(
                  height: 28,
                  padding: EdgeInsets.symmetric(horizontal: 3, vertical: 2),
                  decoration: BoxDecoration(
                    color: context.surface,
                    borderRadius: BorderRadius.circular(DesktopScaffold.cardRadius),
                    boxShadow: PopupMenu.popupShadow,
                    border: Border.all(color: context.outline, width: 0.5),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.event != null && PlatformX.isDesktopView && isModifiable && widget.forceCreate != true && !isRequest)
                        VisirButton(
                          type: VisirButtonAnimationType.scaleAndOpacity,
                          style: VisirButtonStyle(borderRadius: BorderRadius.circular(4), margin: EdgeInsets.only(right: 4), width: 24, height: 24),
                          options: VisirButtonOptions(
                            tabType: widget.tabType,
                            shortcuts: [
                              VisirButtonKeyboardShortcut(
                                message: context.tr.task_action_duplicate,
                                keys: [LogicalKeyboardKey.keyD, if (PlatformX.isApple) LogicalKeyboardKey.meta, if (!PlatformX.isApple) LogicalKeyboardKey.control],
                              ),
                            ],
                          ),
                          onTap: copy,
                          child: VisirIcon(type: VisirIconType.copy, size: 14, isSelected: true),
                        ),
                      if (widget.event != null && PlatformX.isDesktopView && isModifiable && widget.forceCreate != true)
                        VisirButton(
                          type: VisirButtonAnimationType.scaleAndOpacity,
                          style: VisirButtonStyle(borderRadius: BorderRadius.circular(4), margin: EdgeInsets.only(right: 4), width: 24, height: 24),
                          options: VisirButtonOptions(
                            tabType: widget.tabType,
                            shortcuts: [
                              VisirButtonKeyboardShortcut(
                                message: context.tr.task_action_delete,
                                keys: [LogicalKeyboardKey.backspace, if (PlatformX.isApple) LogicalKeyboardKey.meta, if (!PlatformX.isApple) LogicalKeyboardKey.control],
                                subkeys: [
                                  [LogicalKeyboardKey.delete, if (PlatformX.isApple) LogicalKeyboardKey.meta, if (!PlatformX.isApple) LogicalKeyboardKey.control],
                                ],
                                onTrigger: () {
                                  if (isFocused) return false;
                                  delete();
                                  return true;
                                },
                              ),
                            ],
                          ),
                          onTap: delete,
                          child: VisirIcon(type: VisirIconType.trash, size: 14, isSelected: true),
                        ),
                      if (isModifiable && !isRequest)
                        VisirButton(
                          type: VisirButtonAnimationType.scaleAndOpacity,
                          style: VisirButtonStyle(width: 24, height: 24, borderRadius: BorderRadius.circular(4), margin: EdgeInsets.only(right: 4)),
                          options: VisirButtonOptions(
                            tabType: widget.tabType,
                            bypassTextField: true,
                            shortcuts: [
                              VisirButtonKeyboardShortcut(
                                message: context.tr.confirm,
                                keys: [LogicalKeyboardKey.enter],
                                onTrigger: () {
                                  if (suggestion.isNotEmpty) return false;
                                  Navigator.of(Utils.mainContext).maybePop();
                                  return true;
                                },
                              ),
                            ],
                          ),
                          onTap: Navigator.of(Utils.mainContext).maybePop,
                          child: VisirIcon(type: VisirIconType.check, size: 14, isSelected: true),
                        ),
                      VisirButton(
                        type: VisirButtonAnimationType.scaleAndOpacity,
                        style: VisirButtonStyle(width: 24, height: 24, borderRadius: BorderRadius.circular(4), margin: EdgeInsets.only(right: 4)),
                        options: VisirButtonOptions(
                          tabType: widget.tabType,
                          bypassTextField: true,
                          shortcuts: [
                            VisirButtonKeyboardShortcut(
                              message: 'Start chat',
                              keys: [LogicalKeyboardKey.keyL, if (PlatformX.isApple) LogicalKeyboardKey.meta, if (!PlatformX.isApple) LogicalKeyboardKey.control],
                            ),
                          ],
                        ),
                        onTap: startChat,
                        child: VisirIcon(type: VisirIconType.at, color: context.onInverseSurface, size: 14, isSelected: true),
                      ),
                      if (isModifiable && !isRequest)
                        VisirButton(
                          type: VisirButtonAnimationType.scaleAndOpacity,
                          style: VisirButtonStyle(width: 24, height: 24, borderRadius: BorderRadius.circular(4)),
                          options: VisirButtonOptions(
                            tabType: widget.tabType,
                            shortcuts: [
                              VisirButtonKeyboardShortcut(message: context.tr.cancel, keys: [LogicalKeyboardKey.escape], onTrigger: () => false),
                            ],
                          ),
                          onTap: onEscapePressed,
                          child: VisirIcon(type: VisirIconType.close, size: 14, isSelected: true),
                        ),
                    ],
                  ),
                ),
              ),
            ShowcaseWrapper(
              // closePopupOnNext: true,
              showcaseKey: taskLinkedChatShowcaseKeyString,
              child: Container(
                decoration: BoxDecoration(
                  color: context.surface,
                  borderRadius: BorderRadius.circular(DesktopScaffold.cardRadius),
                  boxShadow: PopupMenu.popupShadow,
                  border: Border.all(color: context.outline, width: 0.5),
                ),
                child: PopupMenuContainer(
                  horizontalPadding: 0,
                  backgroundColor: null,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SingleChildScrollView(
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
                              child: CollapsingTextFormField(
                                enabled: isModifiable && !isRequest,
                                focusNode: titleFocusNode,
                                onFieldSubmitted: onTextFieldSubmitted,
                                initialValue: title ?? '',
                                textInputAction: TextInputAction.none,
                                autofocus: widget.event == null || widget.forceCreate == true,
                                collapsedLines: 2,
                                style: context.titleMedium?.textColor(context.outlineVariant).textBold.copyWith(overflow: TextOverflow.ellipsis),
                                decoration: InputDecoration(
                                  constraints: BoxConstraints(minHeight: 20),
                                  hintText: titleHintText ?? context.tr.event_title,
                                  hintStyle: context.titleMedium?.textColor(context.surfaceTint).textBold,
                                  filled: false,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 4),
                                  hoverColor: Colors.transparent,
                                  border: InputBorder.none,
                                  isDense: true,
                                ),
                                onChanged: (text) {
                                  if (text.isEmpty) {
                                    titleHintText = widget.titleHintText ?? context.tr.event_title;
                                  } else {
                                    titleHintText = '';
                                  }

                                  isEdited = true;
                                  title = text;
                                  setState(() {});

                                  widget.onTitleChanged?.call(text.isEmpty ? null : text);
                                  onEventChanged();
                                },
                              ),
                            ),
                            bodyDivider(),
                            if ((isModifiable && !isRequest) || location != null)
                              Column(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(left: 16, right: 16, top: 14),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(right: 10),
                                          child: VisirIcon(type: VisirIconType.location, size: 14, isSelected: (location ?? '').isNotEmpty),
                                        ),
                                        Expanded(
                                          child: LocationSearchField(
                                            key: locationFieldKey,
                                            enabled: isModifiable && !isRequest,
                                            decoration: InputDecorationTheme(
                                              contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 3),
                                              border: InputBorder.none,
                                              disabledBorder: InputBorder.none,
                                              filled: false,
                                              isDense: true,
                                              hintStyle: context.bodyLarge?.copyWith(color: context.surfaceTint),
                                              hoverColor: Colors.transparent,
                                            ),
                                            hint: context.tr.location,
                                            initialValue: location,
                                            offset: Offset(0, 22),
                                            onSearchTextChanged: (text) {
                                              isEdited = true;
                                              location = text;
                                              setState(() {});
                                              onEventChanged();
                                            },
                                            focusNode: locationSearchFieldFocusNode,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(padding: const EdgeInsets.only(left: 24), child: bodyDivider()),
                                ],
                              ),
                            if ((isModifiable && !isRequest) || description != null)
                              Column(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(left: 16, right: 16, top: 14),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(right: 10),
                                          child: VisirIcon(type: VisirIconType.description, size: 14, isSelected: (description ?? '').isNotEmpty),
                                        ),
                                        Expanded(
                                          child: CollapsingTextFormField(
                                            controller: descriptionController,
                                            enabled: isModifiable && !isRequest,
                                            focusNode: descriptionFocusNode,
                                            onFieldSubmitted: onTextFieldSubmitted,
                                            textInputAction: TextInputAction.none,
                                            style: context.bodyMedium?.copyWith(color: context.outlineVariant),
                                            collapsedLines: 5,
                                            decoration: InputDecoration(
                                              hintText: context.tr.description,
                                              contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 3),
                                              border: InputBorder.none,
                                              fillColor: description?.isNotEmpty == true ? context.surface : Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              filled: false,
                                              isDense: true,
                                              hintStyle: context.bodyLarge?.copyWith(color: context.surfaceTint),
                                            ),
                                            onChanged: (text) {
                                              isEdited = true;
                                              description = text;
                                              setState(() {});
                                              onEventChanged();
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(padding: const EdgeInsets.only(left: 24), child: bodyDivider()),
                                ],
                              ),
                            SimpleLinkedMessageMailSection(
                              originalTaskMessage: widget.originalTaskMessage,
                              originalTaskMail: widget.originalTaskMail,
                              linkedMessages: linkedMessages,
                              linkedMails: linkedMails,
                              tabType: widget.tabType,
                              isEvent: true,
                            ),
                            timeSection(isOverMultipleDays: isOverMultipleDays),
                            if (isModifiable || (canSeeOtherGuests && attendee.isNotEmpty))
                              Column(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(
                                      left: 16,
                                      right: 16,
                                      top: 8,
                                      bottom: isRequest
                                          ? 16
                                          : (isModifiable && !isRequest)
                                          ? 0
                                          : 8,
                                    ),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(right: 10, top: 5),
                                          child: VisirIcon(type: VisirIconType.attendee, size: 14, isSelected: attendee.isNotEmpty),
                                        ),
                                        Expanded(
                                          child: Column(
                                            children: [
                                              if (attendee.length > 5)
                                                VisirButton(
                                                  type: VisirButtonAnimationType.scaleAndOpacity,
                                                  style: VisirButtonStyle(hoverColor: Colors.transparent, margin: EdgeInsets.only(bottom: 6)),
                                                  onTap: () {
                                                    attendeeExpanded = !attendeeExpanded;
                                                    setState(() {});
                                                  },
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    children: [
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Text(
                                                              '${attendee.length} ${context.tr.guests}',
                                                              style: context.bodyLarge?.textColor(context.outlineVariant),
                                                              maxLines: 1,
                                                              overflow: TextOverflow.ellipsis,
                                                            ),
                                                            Text.rich(
                                                              TextSpan(
                                                                children: [
                                                                  TextSpan(
                                                                    text:
                                                                        '${attendee.where((e) => e.responseStatus == EventAttendeeResponseStatus.accepted).length} ${context.tr.yes}, ',
                                                                    style: context.bodySmall?.textColor(context.inverseSurface),
                                                                  ),
                                                                  TextSpan(
                                                                    text:
                                                                        '${attendee.where((e) => e.responseStatus == EventAttendeeResponseStatus.declined).length} ${context.tr.no}, ',
                                                                    style: context.bodySmall?.textColor(context.inverseSurface),
                                                                  ),
                                                                  TextSpan(
                                                                    text:
                                                                        '${attendee.where((e) => e.responseStatus == EventAttendeeResponseStatus.needsAction).length} ${context.tr.awaiting}',
                                                                    style: context.bodySmall?.textColor(context.inverseSurface),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      AnimatedRotation(
                                                        duration: Duration(milliseconds: 150),
                                                        turns: attendeeExpanded ? 1 / 2 : 0,
                                                        child: VisirIcon(type: VisirIconType.arrowDown, size: 12),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              if (attendeeExpanded || attendee.length <= 5)
                                                TagEditor<EventAttendeeEntity>(
                                                  key: attendeeFieldKey,
                                                  enabled: isModifiable,
                                                  focusNode: attendeeFocusNode,
                                                  padding: EdgeInsets.zero,
                                                  offset: 0,
                                                  length: attendee.length,
                                                  delimiters: [',', ' '],
                                                  hasAddButton: false,
                                                  borderRadius: 6,
                                                  suggestionsBoxRadius: 6,
                                                  onSubmitted: onTextFieldSubmitted,
                                                  keyboardType: TextInputType.emailAddress,
                                                  backgroundColor: Colors.transparent,
                                                  onTagChanged: (newValue) {
                                                    isEdited = true;
                                                    attendee.add(EventAttendeeEntity(email: newValue));
                                                    setState(() {});
                                                    onEventChanged();
                                                  },
                                                  inputDecoration: InputDecoration(
                                                    constraints: BoxConstraints(maxHeight: attendee.isEmpty ? 24 : 28, minHeight: 24),
                                                    hintText: context.tr.add_guest,
                                                    contentPadding: EdgeInsets.zero,
                                                    border: OutlineInputBorder(
                                                      borderRadius: BorderRadius.circular(borderRaidus),
                                                      borderSide: BorderSide(color: Colors.transparent, width: 0),
                                                    ),
                                                    errorBorder: OutlineInputBorder(
                                                      borderRadius: BorderRadius.circular(borderRaidus),
                                                      borderSide: BorderSide(color: Colors.transparent, width: 0),
                                                    ),
                                                    enabledBorder: OutlineInputBorder(
                                                      borderRadius: BorderRadius.circular(borderRaidus),
                                                      borderSide: BorderSide(color: Colors.transparent, width: 0),
                                                    ),
                                                    focusedBorder: OutlineInputBorder(
                                                      borderRadius: BorderRadius.circular(borderRaidus),
                                                      borderSide: BorderSide(color: Colors.transparent, width: 0),
                                                    ),
                                                    disabledBorder: InputBorder.none,
                                                    fillColor: attendee.isNotEmpty == true ? context.surface : Colors.transparent,
                                                    hoverColor: Colors.transparent,
                                                    filled: false,
                                                    isDense: false,
                                                    hintStyle: context.bodyLarge?.copyWith(color: context.surfaceTint),
                                                  ),
                                                  textStyle: context.bodyLarge?.textColor(context.outlineVariant),
                                                  tagBuilder: (context, index) {
                                                    return Container(
                                                      height: 24,
                                                      decoration: BoxDecoration(color: context.surfaceVariant, borderRadius: BorderRadius.circular(4)),
                                                      margin: EdgeInsets.only(right: 10, bottom: 8),
                                                      padding: EdgeInsets.only(left: 6, right: 0),
                                                      child: IntrinsicWidth(
                                                        child: Row(
                                                          children: [
                                                            if (attendee[index].responseStatus == EventAttendeeResponseStatus.accepted)
                                                              VisirIcon(type: VisirIconType.checkWithCircle, size: 12, color: context.errorContainer, isSelected: true),
                                                            if (attendee[index].responseStatus == EventAttendeeResponseStatus.tentative)
                                                              VisirIcon(type: VisirIconType.helpWithCircle, size: 12, color: context.secondaryContainer, isSelected: true),
                                                            if (attendee[index].responseStatus == EventAttendeeResponseStatus.declined)
                                                              VisirIcon(type: VisirIconType.closeWithCircle, size: 12, color: context.error, isSelected: true),
                                                            if (attendee[index].responseStatus == EventAttendeeResponseStatus.needsAction)
                                                              VisirIcon(type: VisirIconType.unknownWithCircle, size: 12, color: context.onBackground, isSelected: true),
                                                            if (attendee[index].responseStatus != null) SizedBox(width: 4),
                                                            Expanded(
                                                              child: Padding(
                                                                padding: const EdgeInsets.only(bottom: 2),
                                                                child: Text(
                                                                  maxLines: 1,
                                                                  overflow: TextOverflow.ellipsis,
                                                                  '${attendee[index].email ?? attendee[index].displayName ?? ''}${attendee[index].organizer == true ? ' (${context.tr.mail_organizer})' : ''}',
                                                                  style: context.bodyLarge?.textColor(context.outlineVariant),
                                                                ),
                                                              ),
                                                            ),
                                                            isModifiable && !isRequest && isOrganizer
                                                                ? VisirButton(
                                                                    type: VisirButtonAnimationType.scaleAndOpacity,
                                                                    style: VisirButtonStyle(padding: EdgeInsets.all(6), hoverColor: Colors.transparent),
                                                                    onTap: () {
                                                                      attendee.removeAt(index);
                                                                      setState(() {});
                                                                    },
                                                                    child: VisirIcon(type: VisirIconType.closeWithCircle, size: 12, isSelected: true),
                                                                  )
                                                                : SizedBox(width: 6, height: 24),
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                  onDeleteTagAction: () {
                                                    if (attendee.isEmpty) return;
                                                    attendee.removeLast();
                                                    isEdited = true;
                                                    setState(() {});
                                                    onEventChanged();
                                                  },
                                                  suggestionsBoxBackgroundColor: (context.context.surfaceVariant),
                                                  suggestionItemHeight: 46,
                                                  suggestionPadding: EdgeInsets.symmetric(vertical: 6),
                                                  suggestionMargin: EdgeInsets.symmetric(vertical: 8),
                                                  suggestionBuilder: (context, state, data, index, length, highlight, suggestionValid) => Container(
                                                    width: double.maxFinite,
                                                    height: 46,
                                                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Text(data.email!, style: context.bodyMedium!.textColor(context.shadow), maxLines: 1, overflow: TextOverflow.ellipsis),
                                                        if (data.displayName != null && data.displayName!.isNotEmpty)
                                                          Padding(
                                                            padding: const EdgeInsets.only(top: 4.0),
                                                            child: Text(
                                                              data.displayName!,
                                                              style: context.bodySmall?.textColor(context.onInverseSurface),
                                                              maxLines: 1,
                                                              overflow: TextOverflow.ellipsis,
                                                            ),
                                                          ),
                                                      ],
                                                    ),
                                                  ),
                                                  onSelectOptionAction: (value) {
                                                    isEdited = true;
                                                    attendee.add(value);
                                                    suggestion.clear();
                                                    setState(() {});
                                                    onEventChanged();
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

                                                    emailConnections.removeWhere((p) => attendee.map((e) => e.email ?? '').toSet().intersection(([p.email]).toSet()).isNotEmpty);
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
                                                    return suggestion;
                                                  },
                                                ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            if (reminders.isNotEmpty && isModifiable && !isRequest)
                              Column(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(left: 16, right: 16, top: reminders.isEmpty ? 8 : 3),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(right: 10, top: 5),
                                          child: VisirIcon(type: VisirIconType.notification, size: 14, isSelected: true),
                                        ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: reminders.mapIndexed((index, e) {
                                              bool isFirst = index == 0;

                                              return Container(
                                                height: 24,
                                                decoration: BoxDecoration(color: context.surfaceVariant, borderRadius: BorderRadius.circular(4)),
                                                margin: EdgeInsets.only(right: 10, top: isFirst ? 0 : 8),
                                                padding: EdgeInsets.only(left: 6),
                                                child: IntrinsicWidth(
                                                  child: Row(
                                                    children: [
                                                      Text(
                                                        getReminderString(context: context, isAllDay: isAllDay, minute: e.minutes ?? 0),
                                                        style: context.bodyLarge?.textColor(context.outlineVariant),
                                                      ),
                                                      VisirButton(
                                                        type: VisirButtonAnimationType.scaleAndOpacity,
                                                        style: VisirButtonStyle(hoverColor: Colors.transparent, padding: EdgeInsets.all(6)),
                                                        onTap: () {
                                                          isEdited = true;
                                                          reminders.remove(e);
                                                          setState(() {});
                                                          onEventChanged();
                                                        },
                                                        child: VisirIcon(type: VisirIconType.closeWithCircle, size: 12, isSelected: true),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            if (conferenceLink != null && conferenceLink != tempConferenceLink)
                              Column(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(left: 16, right: 16, top: 8),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(right: 10),
                                          child: VisirIcon(type: VisirIconType.videoCall, size: 14, isSelected: conferenceLink != null),
                                        ),
                                        Flexible(
                                          child: Padding(
                                            padding: const EdgeInsets.only(right: 8),
                                            child: VisirButton(
                                              style: VisirButtonStyle(hoverColor: Colors.transparent, alignment: Alignment.topLeft),
                                              type: VisirButtonAnimationType.scaleAndOpacity,
                                              onTap: () => Utils.launchUrlExternal(url: conferenceLink),
                                              builder: (isHover) => Text(
                                                (conferenceLink ?? '').replaceFirst('https://', '').replaceFirst('http://', ''),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: isHover ? context.bodyLarge?.textColor(context.primary).textUnderline : context.bodyLarge?.textColor(context.primary),
                                              ),
                                            ),
                                          ),
                                        ),
                                        VisirButton(
                                          type: VisirButtonAnimationType.scaleAndOpacity,
                                          style: VisirButtonStyle(
                                            cursor: SystemMouseCursors.click,
                                            margin: EdgeInsets.only(right: 6),
                                            padding: EdgeInsets.all(5),
                                            borderRadius: BorderRadius.circular(4),
                                            border: Border.all(color: context.surfaceVariant, width: 1),
                                          ),
                                          onTap: () async {
                                            final clipboard = SystemClipboard.instance;
                                            if (clipboard == null) return;
                                            if (conferenceLink == null) return;
                                            final item = DataWriterItem();
                                            item.add(Formats.plainText(conferenceLink!));
                                            await clipboard.write([item]);
                                            Utils.showToast(
                                              ToastModel(
                                                message: TextSpan(text: Utils.mainContext.tr.link_copied_to_clipboard),
                                                buttons: [],
                                              ),
                                            );
                                          },
                                          options: VisirButtonOptions(tabType: widget.tabType, message: context.tr.task_action_copy_link),
                                          child: VisirIcon(
                                            type: VisirIconType.copy,
                                            size: 12,
                                            color: conferenceLink == null
                                                ? context.onInverseSurface
                                                : isDarkMode
                                                ? context.onPrimary
                                                : context.surfaceTint,
                                            isSelected: true,
                                          ),
                                        ),
                                        if (isModifiable && !isRequest)
                                          VisirButton(
                                            type: VisirButtonAnimationType.scaleAndOpacity,
                                            style: VisirButtonStyle(
                                              cursor: SystemMouseCursors.click,
                                              borderRadius: BorderRadius.circular(4),
                                              padding: EdgeInsets.all(5),
                                              border: Border.all(color: context.surfaceVariant, width: 1),
                                            ),
                                            onTap: () {
                                              isEdited = true;
                                              conferenceLink = null;
                                              setState(() {});
                                              onEventChanged();
                                            },
                                            options: VisirButtonOptions(tabType: widget.tabType, message: context.tr.task_action_delete_link),
                                            child: VisirIcon(
                                              type: VisirIconType.trash,
                                              size: 12,
                                              isSelected: true,
                                              color: conferenceLink == null
                                                  ? context.onInverseSurface
                                                  : isDarkMode
                                                  ? context.onPrimary
                                                  : context.surfaceTint,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            bodyDivider(forceShow: true),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              child: Row(
                                children: [
                                  Flexible(
                                    child: PopupMenu(
                                      enabled: isModifiable && !isRequest,
                                      forcePopup: true,
                                      location: PopupMenuLocation.bottom,
                                      width: 256,
                                      borderRadius: 6,
                                      type: ContextMenuActionType.tap,
                                      popup: SelectionWidget<CalendarEntity>(
                                        cellHeight: 28,
                                        current: calendar!,
                                        items: [calendar!, ...calendars.where((e) => e.uniqueId != calendar!.uniqueId)],
                                        getChild: (calendar) {
                                          return Row(
                                            children: [
                                              SizedBox(width: 6),
                                              Container(
                                                width: 16,
                                                height: 16,
                                                decoration: BoxDecoration(color: ColorX.fromHex(calendar.backgroundColor), borderRadius: BorderRadius.circular(4)),
                                              ),
                                              SizedBox(width: 12),
                                              Expanded(
                                                child: Text(calendar.name, style: context.bodyMedium!.textColor(context.shadow), maxLines: 1, overflow: TextOverflow.ellipsis),
                                              ),
                                              SizedBox(width: 12),
                                            ],
                                          );
                                        },
                                        onSelect: (calendar) {
                                          updateCalendar(calendar);
                                          widget.onColorChanged?.call(ColorX.fromHex(calendar.backgroundColor));
                                        },
                                      ),
                                      style: VisirButtonStyle(
                                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                        borderRadius: BorderRadius.circular(borderRaidus),
                                        backgroundColor: context.surfaceVariant,
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            width: 16,
                                            height: 16,
                                            decoration: BoxDecoration(color: ColorX.fromHex(calendar!.backgroundColor), borderRadius: BorderRadius.circular(4)),
                                          ),
                                          SizedBox(width: 6),
                                          Flexible(
                                            child: Container(
                                              constraints: BoxConstraints(maxWidth: 120),
                                              child: Text(calendar!.name, style: context.bodyMedium?.textColor(context.shadow), maxLines: 1, overflow: TextOverflow.ellipsis),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  if (isModifiable && !isRequest)
                                    PopupMenu(
                                      forcePopup: true,
                                      location: PopupMenuLocation.bottom,
                                      width: 284,
                                      borderRadius: 6,
                                      type: ContextMenuActionType.tap,
                                      popup: SelectionWidget<ReminderOptionType>(
                                        current: ReminderOptionType.none,
                                        items: List<ReminderOptionType>.from(ReminderOptionType.values)
                                          ..removeWhere((e) => e == (isAllDay ? ReminderOptionType.hourBefore : ReminderOptionType.thirteenHourBefore))
                                          ..remove(ReminderOptionType.none),
                                        getTitle: (type) => type.getSelectionOptionTitle(context, isAllDay),
                                        getChildIsPopup: (type) => type == ReminderOptionType.custom,
                                        getChildPopup: (type) => CalendarReminderEditWidget(
                                          initialReminder: null,
                                          isAllDay: isAllDay,
                                          onReminderChanged: (reminder) {
                                            if (!reminders.contains(reminder)) {
                                              isEdited = true;
                                              reminders.add(reminder);
                                              setState(() {});
                                              onEventChanged();
                                            }

                                            WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                                              if (Navigator.of(Utils.mainContext).canPop()) Navigator.of(Utils.mainContext).pop();
                                            });
                                          },
                                        ),
                                        onSelect: (type) {
                                          if (type == ReminderOptionType.none) {
                                          } else if (type == ReminderOptionType.custom) {
                                          } else {
                                            if (!reminders.contains(EventReminderEntity(minutes: type.minutes(), method: 'popup'))) {
                                              isEdited = true;
                                              reminders.add(EventReminderEntity(minutes: type.minutes(), method: 'popup'));
                                              setState(() {});
                                              onEventChanged();
                                            }
                                          }
                                        },
                                      ),
                                      style: VisirButtonStyle(
                                        margin: EdgeInsets.only(left: 6),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: context.surfaceVariant, width: 1),
                                        padding: EdgeInsets.all(5),
                                      ),
                                      options: VisirButtonOptions(tabType: widget.tabType, message: context.tr.add_reminder, tooltipLocation: bottomButtonTooltipLocation),
                                      child: VisirIcon(type: VisirIconType.notification, size: 16, isSelected: true),
                                    ),
                                  if (isOwned
                                      ? (widget.event == null || (widget.forceCreate ?? false))
                                            ? ((isModifiable && !isRequest) || conferenceLink != null)
                                            : !isRequest && (conferenceLink == null || conferenceLink == tempConferenceLink)
                                      : isModifiable && !isRequest)
                                    VisirButton(
                                      type: VisirButtonAnimationType.scaleAndOpacity,
                                      style: VisirButtonStyle(
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: conferenceLink == null ? context.surfaceVariant : context.primary, width: 1),
                                        backgroundColor: conferenceLink == null ? Colors.transparent : context.primary,
                                        margin: EdgeInsets.only(left: 6),
                                        padding: EdgeInsets.all(5),
                                      ),
                                      options: VisirButtonOptions(tabType: widget.tabType, message: context.tr.add_conference, tooltipLocation: bottomButtonTooltipLocation),
                                      onTap: () {
                                        isEdited = true;
                                        if (conferenceLink == null) {
                                          conferenceLink = widget.event?.conferenceLink ?? tempConferenceLink;
                                        } else {
                                          conferenceLink = null;
                                        }
                                        setState(() {});
                                        onEventChanged();
                                      },
                                      child: VisirIcon(
                                        type: VisirIconType.videoCall,
                                        size: 16,
                                        color: conferenceLink == null ? null : context.onPrimary,
                                        isSelected: conferenceLink != null,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (attendee.any((e) => e.email == calendar?.email))
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                          decoration: BoxDecoration(
                            color: context.surfaceVariant,
                            borderRadius: BorderRadius.circular(DesktopScaffold.cardRadius),
                            boxShadow: PopupMenu.popupShadow,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(child: Text(context.tr.going_question, style: context.bodyLarge?.textColor(context.outlineVariant))),
                              SizedBox(width: 24),
                              ...[EventAttendeeResponseStatus.accepted, EventAttendeeResponseStatus.declined, EventAttendeeResponseStatus.tentative].map<Widget>((e) {
                                  final myStatus = attendee.firstWhere((e) => e.email == calendar?.email).responseStatus;
                                  return Expanded(
                                    child: VisirButton(
                                      type: VisirButtonAnimationType.scaleAndOpacity,
                                      style: VisirButtonStyle(
                                        cursor: SystemMouseCursors.click,
                                        backgroundColor: e == myStatus ? context.tertiary : Colors.transparent,
                                        // backgroundColor: e.getBackgroundColor(context),
                                        borderRadius: BorderRadius.circular(14),
                                        border: e == myStatus ? null : Border.all(color: context.onBackground.withValues(alpha: 0.5), width: 1),
                                        width: double.maxFinite,
                                        height: 28,
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
                                          ? CustomCircularLoadingIndicator(size: 14, color: context.onBackground.withValues(alpha: 0.5))
                                          : Text(
                                              e.getTitle(context),
                                              style: context.bodyLarge
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
            ),
          ],
        ),
      ),
    );
  }
}
