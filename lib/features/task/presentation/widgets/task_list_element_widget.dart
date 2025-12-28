import 'package:Visir/config/providers.dart';
import 'package:Visir/features/auth/application/auth_controller.dart';
import 'package:Visir/features/calendar/presentation/widgets/calendar_simple_create_widget.dart';
import 'package:Visir/features/chat/domain/entities/message_entity.dart';
import 'package:Visir/features/common/domain/entities/linked_item_entity.dart';
import 'package:Visir/features/common/presentation/utils/extensions/platform_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/utils/log_event.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/common/presentation/widgets/auth_image_view.dart';
import 'package:Visir/features/common/presentation/widgets/visir_button.dart';
import 'package:Visir/features/common/presentation/widgets/visir_icon.dart';
import 'package:Visir/features/common/presentation/widgets/visir_list_item.dart';
import 'package:Visir/features/common/presentation/widgets/visir_list_section.dart';
import 'package:Visir/features/mail/domain/entities/mail_entity.dart';
import 'package:Visir/features/preference/application/local_pref_controller.dart';
import 'package:Visir/features/preference/domain/entities/oauth_entity.dart';
import 'package:Visir/features/task/actions.dart';
import 'package:Visir/features/task/application/project_list_controller.dart';
import 'package:Visir/features/task/domain/entities/task_entity.dart';
import 'package:Visir/features/task/domain/entities/task_label_entity.dart';
import 'package:Visir/features/task/presentation/widgets/mobile_task_edit_widget.dart';
import 'package:Visir/features/time_saved/actions.dart';
import 'package:collection/collection.dart';
import 'package:easy_debounce/easy_throttle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class TaskListElementWidget extends ConsumerStatefulWidget {
  final TabType tabType;
  final TaskEntity? task;
  final List<TaskEntity> tasksOnSameDate;
  final DateTime? date;
  final bool onAddTask;
  final bool isSelected;
  final void Function() openDetails;
  final void Function(DateTime? date, CalendarTaskEditSourceType calendarTaskEditSourceType) showAddTaskBottomSheet;
  final void Function(DateTime? date) setDateOnAddTask;
  final Widget addTaskWidget;
  final bool isUnscheduled;
  final bool isOverdue;
  final bool hideFooter;
  final bool isCompletedTab;
  final bool isFirst;
  final bool? hasNextItem;
  final bool? isInDragTarget;
  final TaskLabelType currentTaskLabelType;
  final TaskEntity? prevItem;

  const TaskListElementWidget({
    super.key,
    required this.tabType,
    required this.task,
    required this.tasksOnSameDate,
    required this.date,
    required this.onAddTask,
    required this.isSelected,
    required this.openDetails,
    required this.showAddTaskBottomSheet,
    required this.setDateOnAddTask,
    required this.addTaskWidget,
    required this.isUnscheduled,
    required this.isOverdue,
    required this.hideFooter,
    required this.isCompletedTab,
    required this.isFirst,
    required this.currentTaskLabelType,
    this.prevItem,
    this.hasNextItem,
    this.isInDragTarget,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _TaskListTaskWidgetState();
}

class _TaskListTaskWidgetState extends ConsumerState<TaskListElementWidget> {
  final double widthBreakPoint = 400;

  final maxWidth = 1080.0;

  TaskEntity? get task => widget.task;

  List<TaskEntity> get tasksOnSameDate => widget.tasksOnSameDate;

  String get title => task?.title ?? '';

  String get prevItemProjectId => widget.prevItem?.projectId ?? '';

  String get description => task?.description ?? '';

  List<LinkedMailEntity> get linkedMails => task?.linkedMails ?? [];

  List<LinkedMessageEntity> get linkedMessages => task?.linkedMessages ?? [];

  bool get isCompletedTaskLabel => widget.currentTaskLabelType == TaskLabelType.completed;

  bool get isMobileView => PlatformX.isMobileView;

  bool get isFirstTaskInGroup => tasksOnSameDate.isEmpty || tasksOnSameDate.firstOrNull?.uniqueId == task?.uniqueId;

  bool get isLastTaskInGroup => tasksOnSameDate.isEmpty || tasksOnSameDate.lastOrNull?.uniqueId == task?.uniqueId;

  bool get isUnscheduled => widget.isUnscheduled;

  bool get isOverdue => widget.isOverdue;

  bool get isCompletedTab => widget.isCompletedTab;

  bool get showTimeString => isCompletedTaskLabel ? true : ((task?.isAllDay ?? false) ? (task?.isOverdue ?? false) : true) && !isUnscheduled;

  bool get showUnscheduledHeader =>
      (widget.currentTaskLabelType == TaskLabelType.all || widget.currentTaskLabelType == TaskLabelType.upcoming) &&
      isUnscheduled &&
      widget.prevItem?.isBraindump != false &&
      task != null &&
      task!.isBraindump != true;

  bool get showBraindumpHeader =>
      (widget.currentTaskLabelType == TaskLabelType.all || widget.currentTaskLabelType == TaskLabelType.upcoming) &&
      widget.prevItem == null &&
      task != null &&
      task!.isBraindump == true;

  bool get showOverdueHeader =>
      (widget.currentTaskLabelType == TaskLabelType.all || widget.currentTaskLabelType == TaskLabelType.upcoming) && isOverdue && isFirstTaskInGroup && task != null;

  bool get showCompletedHeader => false;

  bool get showDateHeader => !isUnscheduled && !isOverdue && isFirstTaskInGroup && !isCompletedTab;

  bool get showFooter => !isUnscheduled && !isOverdue && isLastTaskInGroup && !widget.hideFooter;

  bool get isDarkMode => context.isDarkMode;

  Color get dragOverlayColor => context.outlineVariant.withValues(alpha: 0.1);

  TextSpan? getTimeStringWidget(bool isCompletedTab, TextStyle style) {
    if (task == null) return null;
    final user = ref.read(authControllerProvider).requireValue;
    int defaultDurationInMinutes = user.userTaskDefaultDurationInMinutes;

    bool isDurationOver24Hrs = task!.duration.inHours >= 24 && !task!.isAllDay;

    String _formatDuration(Duration duration) {
      int hours = duration.inHours;
      int minutes = duration.inMinutes % 60;

      String hoursPart = hours > 0 ? '${hours}h' : '';
      String minutesPart = minutes > 0 ? '${minutes}m' : '';

      return [hoursPart, minutesPart].where((part) => part.isNotEmpty).join(' ');
    }

    String _formatHourAndMinute(DateTime time) {
      bool isDefaultDuration = defaultDurationInMinutes == task!.duration.inMinutes;

      return '${time.minute == 0 ? DateFormat('h a').format(time) : DateFormat('h:mm a').format(time)}${(isDefaultDuration || isDurationOver24Hrs) ? '' : ' (${_formatDuration(task!.duration)})'}';
    }

    String formatDate(DateTime date, bool isOnlyDate) {
      if (task == null) return '';

      bool isToday = DateUtils.isSameDay(date, DateTime.now());
      bool isYesterday = DateUtils.isSameDay(date, DateTime.now().subtract(Duration(days: 1)));
      bool isBeforeYesterday = date.isBefore(DateTime.now()) && !isToday && !isYesterday;
      bool isFuture = date.isAfter(DateTime.now());
      bool isThisYear = date.year == DateTime.now().year;

      if (isToday) return '${context.tr.today}${isOnlyDate ? '' : ', '}';
      if (isYesterday) return '${context.tr.yesterday}${isOnlyDate ? '' : ', '}';
      if (isBeforeYesterday || isFuture)
        return isThisYear ? '${DateFormat('MMM d').format(date)}${isOnlyDate ? '' : ', '}' : '${DateFormat('MMM d, yyyy').format(date)}${isOnlyDate ? '' : ', '}';
      return '';
    }

    String dateTimeFormatter(DateTime date) {
      return task!.isAllDay ? formatDate(date, true) : '${formatDate(date, false)}${_formatHourAndMinute(date)}';
    }

    if (task?.isUnscheduled ?? true) return null;

    return TextSpan(
      text: isDurationOver24Hrs
          ? '${dateTimeFormatter(task!.editedStartTime ?? task!.startDate)} ${context.tr.task_to} ${dateTimeFormatter(task!.editedEndTime ?? task!.endDate)}'
          : dateTimeFormatter(task!.editedStartTime ?? task!.startDate),
      style: style.textColor(((task?.isOverdue ?? false) && task!.status != TaskStatus.done) ? context.error : null),
    );
  }

  Widget maxWidthContainer(Widget child, {Color? backgroundColor, bool? showDragOverlay, EdgeInsets? margin}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: Padding(
            padding: margin ?? EdgeInsets.zero,
            child: Container(
              decoration: BoxDecoration(
                color: showDragOverlay == true
                    ? widget.isInDragTarget == true
                          ? dragOverlayColor
                          : widget.isInDragTarget == false
                          ? Colors.transparent
                          : backgroundColor ?? Colors.transparent
                    : backgroundColor ?? Colors.transparent,
                borderRadius: PlatformX.isMobileView
                    ? null
                    : task == null || isUnscheduled
                    ? BorderRadius.circular(6)
                    : BorderRadius.vertical(top: Radius.circular(6)),
              ),
              child: child,
            ),
          ),
        ),
      ],
    );
  }

  Widget divider() {
    return Container(
      width: double.maxFinite,
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 0.5, strokeAlign: BorderSide.strokeAlignCenter, color: context.outline),
        ),
      ),
    );
  }

  Widget textHeader() {
    return VisirListSection(
      isSelected: widget.isInDragTarget == true,
      removeTopMargin: widget.isFirst,
      titleBuilder: (height, baseStyle, subStyle, horizontalSpacing) {
        return TextSpan(
          text: showCompletedHeader
              ? context.tr.task_label_completed
              : showBraindumpHeader
              ? context.tr.task_section_braindump
              : showUnscheduledHeader
              ? context.tr.task_unscheduled
              : context.tr.task_overdue,
        );
      },
    );
  }

  Widget dateHeader() {
    DateTime date = widget.date ?? DateTime.now();
    return VisirListSection(
      isSelected: widget.isInDragTarget == true,
      removeTopMargin: widget.isFirst,
      titleBuilder: (height, baseStyle, subStyle, horizontalSpacing) {
        return TextSpan(
          text: '${DateFormat.E().format(date)}, ${DateFormat.MMMd().format(date)} ',
          children: [
            TextSpan(
              text: DateUtils.isSameDay(date, DateTime.now())
                  ? context.tr.today
                  : DateUtils.isSameDay(date, DateTime.now().add(Duration(days: 1)))
                  ? context.tr.tomorrow
                  : '',
              style: subStyle?.textColor(DateUtils.isSameDay(date, DateTime.now()) ? context.tertiary : null).textBold.appFont(context),
            ),
          ],
        );
      },
    );
  }

  Widget addFooter() {
    return widget.onAddTask
        ? Padding(padding: const EdgeInsets.symmetric(horizontal: 8.0), child: widget.addTaskWidget)
        : Row(
            children: [
              VisirButton(
                type: VisirButtonAnimationType.scaleAndOpacity,
                style: VisirButtonStyle(
                  cursor: SystemMouseCursors.click,
                  borderRadius: BorderRadius.circular(6),
                  padding: EdgeInsets.only(left: 9, right: 14, top: 8, bottom: 8),
                  margin: EdgeInsets.symmetric(vertical: 3, horizontal: 8),
                  clickMargin: EdgeInsets.symmetric(vertical: 3, horizontal: 8),
                  hoverColor: widget.isInDragTarget == null ? null : Colors.transparent,
                ),
                onTap: () {
                  if (isMobileView) {
                    widget.showAddTaskBottomSheet(widget.date, CalendarTaskEditSourceType.addTaskOnDate);
                  } else {
                    widget.setDateOnAddTask(widget.date);
                  }
                },
                builder: (isHover) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      VisirIcon(type: VisirIconType.add, size: 16, color: widget.isInDragTarget == null && isHover ? context.outlineVariant : context.outline),
                      SizedBox(width: 8),
                      Text(context.tr.task_add_task, style: context.titleSmall?.textColor(widget.isInDragTarget == null && isHover ? context.outlineVariant : context.outline)),
                    ],
                  );
                },
              ),
            ],
          );
  }

  @override
  Widget build(BuildContext context) {
    final timeStringWidget = getTimeStringWidget(isCompletedTab, context.bodyMedium!);
    final project = ref.watch(
      projectListControllerProvider.select((p) => p.firstWhereOrNull((p) => task != null ? p.isPointedProject(task!) : false) ?? p.firstWhereOrNull((p) => p.isDefault)),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showUnscheduledHeader || showOverdueHeader || showCompletedHeader || showBraindumpHeader) textHeader(),
        if (showDateHeader) dateHeader(),
        if (widget.task != null &&
            (!(project?.isPointedProjectId(prevItemProjectId) == true || (prevItemProjectId.isEmpty && project?.isDefault == true)) ||
                showUnscheduledHeader ||
                showOverdueHeader ||
                showCompletedHeader ||
                showBraindumpHeader ||
                showDateHeader))
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 12, bottom: 6),
            child: Text.rich(
              TextSpan(
                children: [
                  WidgetSpan(
                    child: Container(
                      padding: EdgeInsets.only(right: 8),
                      child: project == null
                          ? null
                          : VisirIcon(
                              type: project.icon ?? VisirIconType.project,
                              size: context.bodyLarge!.fontSize! * context.bodyLarge!.height!,
                              color: project.color!,
                              isSelected: true,
                            ),
                    ),
                  ),
                  TextSpan(text: project?.name),
                ],
              ),
              style: context.bodyLarge?.textColor(context.inverseSurface),
            ),
          ),
        if (task != null)
          Column(
            children: [
              ValueListenableBuilder<bool>(
                valueListenable: ValueNotifier<bool>(widget.isSelected),
                builder: (context, isSelected, child) {
                  return VisirListItem(
                    hoverDisabled: widget.isInDragTarget != null,
                    isSelected: isSelected,
                    titleLeadingBuilder: task?.status == TaskStatus.braindump
                        ? null
                        : (height, baseStyle, verticalPadding, horizontalPadding) {
                            return TextSpan(
                              children: [
                                WidgetSpan(
                                  alignment: PlaceholderAlignment.middle,
                                  child: VisirButton(
                                    key: ValueKey('task_list_element_widget.checkbox_button.${task?.uniqueId}.${task?.status == TaskStatus.done}'),
                                    type: VisirButtonAnimationType.scaleAndOpacity,
                                    style: VisirButtonStyle(
                                      cursor: SystemMouseCursors.click,
                                      clickMargin: EdgeInsets.all(12),
                                      backgroundColor: task?.status == TaskStatus.done ? project!.color : Colors.transparent,
                                      borderRadius: BorderRadius.circular(6),
                                      border: task?.status == TaskStatus.done ? null : Border.all(color: project!.color!, width: 1.5),
                                      hoverColor: task?.status == TaskStatus.done ? null : project!.color!.withValues(alpha: 0.5),
                                      width: height,
                                      height: height,
                                    ),
                                    onTap: () {
                                      EasyThrottle.throttle('toggleTaskStatus${task?.id}', Duration(milliseconds: 200), () async {
                                        if (task == null) return;
                                        if (task!.status == TaskStatus.none) logAnalyticsEvent(eventName: 'task_check_done');
                                        TaskAction.toggleStatus(task: task!, startAt: task!.editedStartTime, endAt: task!.editedEndTime, tabType: widget.tabType);
                                        UserActionSwtichAction.onTaskAction();
                                      });
                                    },
                                    child: task?.status == TaskStatus.done ? VisirIcon(type: VisirIconType.taskCheck, size: height * 2 / 3, color: Colors.white) : null,
                                  ),
                                ),
                              ],
                            );
                          },
                    titleBuilder: (height, baseStyle, verticalPadding, horizontalPadding) {
                      return TextSpan(text: title);
                    },
                    titleTrailingOnNextLine: PlatformX.isMobileView,
                    titleTrailingBuilder: showTimeString && timeStringWidget != null
                        ? (height, style, verticalPadding, horizontalPadding) => getTimeStringWidget(isCompletedTab, style!)!
                        : null,
                    detailsBuilder: [...linkedMessages, ...linkedMails].isEmpty && description.isEmpty
                        ? null
                        : (height, style, verticalPadding, horizontalPadding) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (description.isNotEmpty)
                                  Container(
                                    width: double.maxFinite,
                                    child: Text(description, style: style, maxLines: 2, overflow: TextOverflow.ellipsis),
                                  ),
                                if ([...linkedMessages, ...linkedMails].isNotEmpty) SizedBox(height: verticalPadding),
                                ...[...linkedMessages, ...linkedMails].map((m) {
                                  final text = m is LinkedMessageEntity
                                      ? '${m.userName} - ${m.channelName}'
                                      : m is LinkedMailEntity
                                      ? m.fromName
                                      : null;

                                  final icon = m is LinkedMessageEntity
                                      ? m.type.icon
                                      : m is LinkedMailEntity
                                      ? m.type.icon
                                      : null;

                                  OAuthEntity? oauth;
                                  if (m is LinkedMailEntity) {
                                    oauth = Utils.ref.read(localPrefControllerProvider).value?.mailOAuths?.firstWhereOrNull((e) => e.email == m.hostMail);
                                  } else if (m is LinkedMessageEntity) {
                                    oauth = Utils.ref.read(localPrefControllerProvider).value?.messengerOAuths?.firstWhereOrNull((e) => e.teamId == m.teamId);
                                  }

                                  return Row(
                                    children: [
                                      if (oauth != null) AuthImageView(oauth: oauth, size: height),
                                      if (oauth == null) Image.asset(icon!, width: height, height: height),
                                      SizedBox(width: horizontalPadding),
                                      Text(text!, style: style, maxLines: 1, overflow: TextOverflow.ellipsis),
                                    ],
                                  );
                                }),
                              ],
                            );
                          },
                    onTap: () {
                      if (isMobileView && task != null) {
                        Utils.showPopupDialog(
                          child: MobileTaskEditWidget(
                            task: task,
                            selectedDate: task!.editedStartDateOnly,
                            tabType: widget.tabType,
                            calendarTaskEditSourceType: CalendarTaskEditSourceType.editOriginal,
                          ),
                        );
                      } else {
                        widget.openDetails();
                      }
                    },
                  );
                },
              ),
            ],
          ),
        if (showFooter) maxWidthContainer(addFooter()),
      ],
    );
  }
}
