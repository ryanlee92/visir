import 'package:Visir/config/providers.dart';
import 'package:Visir/features/calendar/presentation/screens/main_calendar_widget.dart';
import 'package:Visir/features/common/presentation/utils/extensions/platform_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/widgets/desktop_scaffold.dart';
import 'package:Visir/features/common/provider.dart';
import 'package:Visir/features/inbox/domain/entities/inbox_entity.dart';
import 'package:Visir/features/task/domain/entities/task_entity.dart';
import 'package:Visir/features/task/presentation/widgets/unscheduled_task_drop_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_resizable_container/flutter_resizable_container.dart';

class TimeblockDropWidget extends StatefulWidget {
  final TabType tabType;
  final bool? transparent;

  const TimeblockDropWidget({super.key, required this.tabType, this.transparent});

  @override
  State<TimeblockDropWidget> createState() => TimeblockDropWidgetState();
}

class TimeblockDropWidgetState extends State<TimeblockDropWidget> {
  final GlobalKey<MainCalendarWidgetState> calendarKey = GlobalKey();
  final GlobalKey<UnscheduledTaskDropWidgetState> unscheduledTaskDropWidgetKey = GlobalKey();

  onInboxDragUpdate(InboxEntity inbox, Offset offset) {
    calendarKey.currentState?.onInboxDragUpdate(inbox, offset);
    unscheduledTaskDropWidgetKey.currentState?.onInboxDragUpdate(inbox, offset);
  }

  Future<void> onInboxDragEnd(InboxEntity inbox, Offset offset) async {
    await calendarKey.currentState?.onInboxDragEnd(inbox, offset);
    await unscheduledTaskDropWidgetKey.currentState?.onInboxDragEnd(inbox, offset);
  }

  onShowCreateShadow(DateTime startTime, DateTime endTime, bool isAllDay) {
    calendarKey.currentState?.onShowCreateShadow(startTime, endTime, isAllDay);
  }

  onRemoveCreateShadow() {
    calendarKey.currentState?.onRemoveCreateShadow();
  }

  onSaved() {
    calendarKey.currentState?.onSaved();
    unscheduledTaskDropWidgetKey.currentState?.onSaved();
  }

  onTitleChanged(String? title) {
    calendarKey.currentState?.onTitleChanged(title);
    unscheduledTaskDropWidgetKey.currentState?.onTitleChanged(title);
  }

  onColorChanged(Color? color) {
    calendarKey.currentState?.onColorChanged(color);
    unscheduledTaskDropWidgetKey.currentState?.onColorChanged(color);
  }

  onTimeChanged(DateTime startDate, DateTime endDate, bool isAllDay) {
    calendarKey.currentState?.onTimeChanged(startDate, endDate, isAllDay);
  }

  updateIsTask(bool isTask) {
    calendarKey.currentState?.updateIsTask(isTask);
  }

  updateTaskDragFromCalendar({required Offset globalPosition, required TaskEntity task}) {
    unscheduledTaskDropWidgetKey.currentState?.onTaskDragUpdate(task, globalPosition);
  }

  endTaskDragFromCalendar() {
    unscheduledTaskDropWidgetKey.currentState?.onTaskDragEnd();
  }

  onTaskDragStart(TaskEntity task) {}

  onTaskDragUpdate(TaskEntity task, Offset offset) {
    calendarKey.currentState?.onTaskDragUpdate(task, offset);
  }

  onTaskDragEnd(TaskEntity task) {
    calendarKey.currentState?.onTaskDragEnd(task);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (PlatformX.isMobileView) Positioned.fill(child: meshLoadingBackground),
        if (PlatformX.isMobileView) Positioned.fill(child: Container(color: context.background.withValues(alpha: 0.5))),
        Positioned.fill(
          child: ResizableContainer(
            direction: Axis.vertical,
            children: [
              ResizableChild(
                size: ResizableSize.expand(min: 160, flex: 1),
                child: DesktopCard(
                  child: UnscheduledTaskDropWidget(
                    key: unscheduledTaskDropWidgetKey,
                    tabType: widget.tabType,
                    onTaskDragStart: onTaskDragStart,
                    onTaskDragUpdate: onTaskDragUpdate,
                    onTaskDragEnd: onTaskDragEnd,
                    backgroundColor: widget.transparent == true ? Colors.transparent : null,
                  ),
                ),
                divider: ResizableDivider(thickness: DesktopScaffold.cardPadding, color: Colors.transparent),
              ),
              ResizableChild(
                size: ResizableSize.expand(min: 400, flex: 5),
                child: DesktopCard(
                  child: MainCalendarWidget(
                    tabType: widget.tabType,
                    key: calendarKey,
                    backgroundColor: widget.transparent == true ? Colors.transparent : null,
                    isPopup: false,
                    onDragUpdate: updateTaskDragFromCalendar,
                    onDragEnd: endTaskDragFromCalendar,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
