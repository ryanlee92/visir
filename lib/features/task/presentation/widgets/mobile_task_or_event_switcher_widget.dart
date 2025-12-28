import 'package:Visir/config/providers.dart';
import 'package:Visir/features/auth/application/auth_controller.dart';
import 'package:Visir/features/calendar/application/calendar_list_controller.dart';
import 'package:Visir/features/calendar/domain/entities/calendar_entity.dart';
import 'package:Visir/features/calendar/presentation/widgets/calendar_simple_create_widget.dart';
import 'package:Visir/features/calendar/presentation/widgets/mobile_calendar_edit_widget.dart';
import 'package:Visir/features/calendar/providers.dart';
import 'package:Visir/features/common/domain/entities/linked_item_entity.dart';
import 'package:Visir/features/common/presentation/utils/extensions/list_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/common/presentation/widgets/visir_button.dart';
import 'package:Visir/features/common/presentation/widgets/visir_icon.dart';
import 'package:Visir/features/preference/application/local_pref_controller.dart';
import 'package:Visir/features/task/application/project_list_controller.dart';
import 'package:Visir/features/task/domain/entities/project_entity.dart';
import 'package:Visir/features/task/domain/entities/task_entity.dart';
import 'package:Visir/features/task/presentation/widgets/mobile_task_edit_widget.dart';
import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MobileTaskOrEventSwitcherWidget extends ConsumerStatefulWidget {
  final bool isEvent;
  final bool isAllDay;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime selectedDate;
  final TabType tabType;
  final CalendarTaskEditSourceType calendarTaskEditSourceType;

  final String? title;
  final String? description;
  final String? titleHintText;
  final LinkedMessageEntity? originalTaskMessage;
  final LinkedMailEntity? originalTaskMail;
  final List<LinkedMessageEntity>? linkedMessages;
  final List<LinkedMailEntity>? linkedMails;
  final List<TaskProvider>? providers;
  final bool? hideEventTaskSwitcher;
  final bool? isFromInboxDrag;
  final String? suggestedProjectId;

  const MobileTaskOrEventSwitcherWidget({
    super.key,
    required this.isEvent,
    required this.isAllDay,
    required this.startDate,
    required this.endDate,
    required this.selectedDate,
    required this.tabType,
    required this.calendarTaskEditSourceType,
    this.title,
    this.description,
    this.titleHintText,
    this.originalTaskMessage,
    this.originalTaskMail,
    this.linkedMessages,
    this.linkedMails,
    this.providers,
    this.hideEventTaskSwitcher,
    this.isFromInboxDrag,
    this.suggestedProjectId,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MobileTaskOrEventSwitcherWidgetState();
}

class _MobileTaskOrEventSwitcherWidgetState extends ConsumerState<MobileTaskOrEventSwitcherWidget> {
  bool isEvent = true;

  late String _title;
  late String _description;
  late DateTime _startDate;
  late DateTime _endDate;
  late bool _isAllDay;
  CalendarEntity? _calendar;
  ProjectEntity? _project;

  bool get hideEventTaskSwitcher => widget.hideEventTaskSwitcher ?? false;

  @override
  void initState() {
    super.initState();

    isEvent = widget.isEvent;

    _title = widget.title ?? '';
    _description = Utils.textTrimmer(widget.description);
    _startDate = widget.startDate;
    _endDate = widget.endDate;
    _isAllDay = widget.isAllDay;

    final user = ref.read(authControllerProvider).requireValue;

    final calendarMap = ref.read(calendarListControllerProvider);
    final calendarHide = ref.read(calendarHideProvider(widget.tabType));
    List<CalendarEntity> calendars = calendarMap.values.expand((e) => e).toList()
      ..removeWhere((c) => c.modifiable != true || calendarHide.contains(c.uniqueId) == true)
      ..unique((element) => element.uniqueId);

    final lastUsedCalendarIds = ref.read(lastUsedCalendarIdProvider);
    _calendar =
        (calendars.where((e) => e.uniqueId == (user.userDefaultCalendarId ?? lastUsedCalendarIds.firstOrNull)).toList().firstOrNull ?? calendars.firstOrNull);

    final lastUsedProjectId = ref.read(lastUsedProjectIdProvider).firstOrNull;
    final lastUsedProject = lastUsedProjectId == null
        ? null
        : ref.read(projectListControllerProvider).firstWhereOrNull((e) => e.isPointedProjectId(lastUsedProjectId));
    final defaultProject = ref.read(projectListControllerProvider).firstWhereOrNull((e) => e.isDefault);
    final suggestedProject = widget.suggestedProjectId == null
        ? null
        : ref.read(projectListControllerProvider).firstWhereOrNull((e) => e.isPointedProjectId(widget.suggestedProjectId));

    _project = suggestedProject ?? lastUsedProject ?? defaultProject;
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget eventTaskSwitcher() {
    return Container(
      height: 32,
      width: 64,
      child: AnimatedToggleSwitch<bool>.rolling(
        current: isEvent,
        values: [true, false],
        height: 32,
        indicatorSize: Size(32, 32),
        indicatorIconScale: 1,
        iconOpacity: 0.5,
        borderWidth: 0,
        onChanged: (isEvent) => setState(() => this.isEvent = isEvent),
        iconBuilder: (isEvent, selected) =>
            VisirIcon(type: isEvent ? VisirIconType.calendar : VisirIconType.task, size: 16, isSelected: selected, color: context.onBackground),
        style: ToggleStyle(backgroundColor: context.surface, borderRadius: BorderRadius.circular(6), indicatorColor: context.surfaceVariant),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isCalendarEmpty = ref.watch(localPrefControllerProvider.select((value) => value.value?.calendarOAuths?.isEmpty)) ?? true;

    return VisirButton(
      type: VisirButtonAnimationType.none,
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      style: VisirButtonStyle(),
      child: Material(
        color: context.background,
        child: FocusTraversalGroup(
          child: Stack(
            children: [
              Positioned.fill(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: isEvent
                          ? MobileCalendarEditWidget(
                              tabType: widget.tabType,
                              event: null,
                              startDate: _startDate,
                              endDate: _endDate,
                              isAllDay: _isAllDay,
                              initialCalendar: _calendar,
                              selectedDate: DateUtils.dateOnly(_startDate),
                              initialTitle: _title,
                              initialDescription: _description,
                              titleHintText: widget.titleHintText,
                              originalTaskMessage: widget.originalTaskMessage,
                              originalTaskMail: widget.originalTaskMail,
                              onTitleChanged: (title) {
                                _title = title;
                              },
                              onDescriptionChanged: (description) {
                                _description = description;
                              },
                              onStartDateChanged: (startDate) {
                                _startDate = startDate;
                              },
                              onEndDateChanged: (endDate) {
                                _endDate = endDate;
                              },
                              onIsAllDayChanged: (isAllDay) {
                                _isAllDay = isAllDay;
                              },
                              onCalendarChanged: (calendar) {
                                _calendar = calendar;
                              },
                              calendarTaskEditSourceType: widget.calendarTaskEditSourceType,
                            )
                          : MobileTaskEditWidget(
                              task: null,
                              startDate: _startDate,
                              endDate: _endDate,
                              isAllDay: _isAllDay,
                              selectedDate: DateUtils.dateOnly(_startDate),
                              tabType: widget.tabType,
                              initialProject: _project,
                              initialTitle: _title,
                              initialDescription: _description,
                              titleHintText: widget.titleHintText,
                              originalTaskMessage: widget.originalTaskMessage,
                              originalTaskMail: widget.originalTaskMail,
                              isFromInboxDrag: widget.isFromInboxDrag,
                              onTitleChanged: (title) {
                                _title = title;
                              },
                              onDescriptionChanged: (description) {
                                _description = description;
                              },
                              onStartDateChanged: (startDate) {
                                _startDate = startDate;
                              },
                              onEndDateChanged: (endDate) {
                                _endDate = endDate;
                              },
                              onIsAllDayChanged: (isAllDay) {
                                _isAllDay = isAllDay;
                              },
                              onProjectChanged: (project) {
                                _project = project;
                              },
                              calendarTaskEditSourceType: widget.calendarTaskEditSourceType,
                            ),
                    ),
                  ],
                ),
              ),
              Positioned(top: 8, height: 32, width: 64, right: 52, child: (hideEventTaskSwitcher || isCalendarEmpty) ? SizedBox.shrink() : eventTaskSwitcher()),
            ],
          ),
        ),
      ),
    );
  }
}
