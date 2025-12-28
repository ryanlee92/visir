import 'dart:async';

import 'package:Visir/config/providers.dart';
import 'package:Visir/dependency/board_view/board_item.dart';
import 'package:Visir/dependency/board_view/board_list.dart';
import 'package:Visir/dependency/board_view/boardview.dart';
import 'package:Visir/dependency/board_view/boardview_controller.dart';
import 'package:Visir/dependency/contextmenu/src/ContextMenuArea.dart';
import 'package:Visir/features/auth/application/auth_controller.dart';
import 'package:Visir/features/calendar/presentation/widgets/calendar_simple_create_widget.dart';
import 'package:Visir/features/calendar/providers.dart';
import 'package:Visir/features/common/presentation/utils/constants.dart';
import 'package:Visir/features/common/presentation/utils/extensions/date_time_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/platform_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/common/presentation/widgets/popup_menu.dart';
import 'package:Visir/features/common/presentation/widgets/visir_app_bar.dart';
import 'package:Visir/features/common/presentation/widgets/visir_button.dart';
import 'package:Visir/features/common/presentation/widgets/visir_icon.dart';
import 'package:Visir/features/common/provider.dart';
import 'package:Visir/features/inbox/domain/entities/inbox_entity.dart';
import 'package:Visir/features/inbox/presentation/widgets/inbox_draggable.dart';
import 'package:Visir/features/task/actions.dart';
import 'package:Visir/features/task/application/project_list_controller.dart';
import 'package:Visir/features/task/application/task_list_controller.dart';
import 'package:Visir/features/task/domain/entities/task_entity.dart';
import 'package:Visir/features/task/presentation/widgets/mobile_task_edit_widget.dart';
import 'package:Visir/features/task/presentation/widgets/simple_task_or_event_switcher_widget.dart';
import 'package:Visir/features/task/presentation/widgets/task_simple_create_widget.dart';
import 'package:Visir/features/time_saved/actions.dart';
import 'package:collection/collection.dart';
import 'package:easy_debounce/easy_throttle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

class UnscheduledTaskDropWidget extends ConsumerStatefulWidget {
  final TabType tabType;
  final void Function(TaskEntity task, Offset offset)? onTaskDragUpdate;
  final void Function(TaskEntity task)? onTaskDragStart;
  final void Function(TaskEntity task)? onTaskDragEnd;
  final Color? backgroundColor;

  const UnscheduledTaskDropWidget({super.key, required this.tabType, this.onTaskDragEnd, this.onTaskDragStart, this.onTaskDragUpdate, this.backgroundColor});

  @override
  ConsumerState<UnscheduledTaskDropWidget> createState() => UnscheduledTaskDropWidgetState();
}

class UnscheduledTaskDropWidgetState extends ConsumerState<UnscheduledTaskDropWidget> {
  BoardViewController boardViewController = BoardViewController();

  GlobalKey unscheduledTaskDropWidgetKey = GlobalKey();
  GlobalKey braindumpTaskDropWidgetKey = GlobalKey();
  GlobalKey createTaskShadowKey = GlobalKey();

  InboxEntity? draggedInbox;
  TaskEntity? draggedTask;
  bool? draggedItemIsBraindump;
  bool? draggedInboxIsReadyToCreate;
  String? draggedInboxTitle;
  Color? draggedInboxColor;
  TaskEntity? originalTask;

  double get ratio => ref.watch(zoomRatioProvider);

  onTaskDragUpdate(TaskEntity task, Offset offset, {TaskStatus? targetStatus}) {
    originalTask = task;
    final braindumpRenderBox = braindumpTaskDropWidgetKey.currentContext?.findRenderObject() as RenderBox;
    final unscheduledRenderBox = unscheduledTaskDropWidgetKey.currentContext?.findRenderObject() as RenderBox;

    final braindumpOffset = braindumpRenderBox.localToGlobal(Offset.zero) / ratio;
    final unscheduledOffset = unscheduledRenderBox.localToGlobal(Offset.zero) / ratio;
    final braindumpSize = braindumpRenderBox.size * ratio;
    final unscheduledSize = unscheduledRenderBox.size * ratio;

    final braindumpRect = Rect.fromLTWH(braindumpOffset.dx, braindumpOffset.dy, braindumpSize.width, braindumpSize.height);
    final unscheduledRect = Rect.fromLTWH(unscheduledOffset.dx, unscheduledOffset.dy, unscheduledSize.width, unscheduledSize.height);

    if (braindumpRect.contains(offset)) {
      draggedTask = task.copyWith(status: TaskStatus.braindump, removeTime: true);
      draggedItemIsBraindump = true;
    } else if (unscheduledRect.contains(offset)) {
      draggedTask = task.copyWith(status: targetStatus ?? null, removeTime: true);
      draggedItemIsBraindump = false;
    } else {
      draggedTask = null;
      draggedItemIsBraindump = null;
    }
    setState(() {});
  }

  onTaskDragEnd() {
    if (draggedTask == null || originalTask == null) return;
    TaskAction.upsertTask(
      task: draggedTask!,
      originalTask: originalTask!,
      calendarTaskEditSourceType: CalendarTaskEditSourceType.drag,
      tabType: widget.tabType,
      isLinkedWithMails: originalTask!.linkedMails.isNotEmpty,
      isLinkedWithMessages: originalTask!.linkedMessages.isNotEmpty,
    );
    originalTask = null;
    draggedTask = null;
    draggedItemIsBraindump = null;
    setState(() {});
  }

  onInboxDragUpdate(InboxEntity inbox, Offset offset) {
    final braindumpRenderBox = braindumpTaskDropWidgetKey.currentContext?.findRenderObject() as RenderBox;
    final unscheduledRenderBox = unscheduledTaskDropWidgetKey.currentContext?.findRenderObject() as RenderBox;

    final braindumpOffset = braindumpRenderBox.localToGlobal(Offset.zero) / ratio;
    final unscheduledOffset = unscheduledRenderBox.localToGlobal(Offset.zero) / ratio;
    final braindumpSize = braindumpRenderBox.size * ratio;
    final unscheduledSize = unscheduledRenderBox.size * ratio;

    final braindumpRect = Rect.fromLTWH(braindumpOffset.dx, braindumpOffset.dy, braindumpSize.width, braindumpSize.height);
    final unscheduledRect = Rect.fromLTWH(unscheduledOffset.dx, unscheduledOffset.dy, unscheduledSize.width, unscheduledSize.height);

    if (braindumpRect.contains(offset)) {
      draggedInbox = inbox;
      draggedItemIsBraindump = true;
      draggedInboxIsReadyToCreate = null;
      draggedInboxTitle = null;
      draggedInboxColor = null;
    } else if (unscheduledRect.contains(offset)) {
      draggedInbox = inbox;
      draggedItemIsBraindump = false;
      draggedInboxIsReadyToCreate = null;
      draggedInboxTitle = null;
      draggedInboxColor = null;
    } else {
      draggedInbox = null;
      draggedItemIsBraindump = null;
      draggedInboxIsReadyToCreate = null;
      draggedInboxTitle = null;
      draggedInboxColor = null;
    }
    setState(() {});
  }

  Future<void> onInboxDragEnd(InboxEntity? inbox, Offset offset, {bool isBraindump = false}) async {
    if (draggedInbox == null) return;
    Completer<void> completer = Completer<void>();
    draggedInboxIsReadyToCreate = true;
    setState(() {});

    bool isLinkedWithMail = inbox?.linkedMail != null;
    bool isLinkedWithMessage = inbox?.linkedMessage != null;

    final lastUsedProjectId = ref.read(lastUsedProjectIdProvider).firstOrNull;
    final lastUsedProject = lastUsedProjectId == null
        ? null
        : ref.read(projectListControllerProvider).firstWhereOrNull((e) => e.isPointedProjectId(lastUsedProjectId));
    final defaultProject = ref.read(projectListControllerProvider).firstWhereOrNull((e) => e.isDefault);
    final suggestedProject = draggedInbox?.suggestion?.project_id == null
        ? null
        : ref.read(projectListControllerProvider).firstWhereOrNull((e) => e.isPointedProjectId(draggedInbox?.suggestion?.project_id));
    final project = suggestedProject ?? lastUsedProject ?? defaultProject;

    // controller.showCreateShadow?.call(date, endAt, isAllDay, offset, (anchorDiff) {});
    if (PlatformX.isMobileView) {
      // controller.hideCreateShadow?.call();
      Utils.showPopupDialog(
            child: MobileTaskEditWidget(
              isFromInboxDrag: true,
              selectedDate: DateUtils.dateOnly(DateTime.now()),
              tabType: widget.tabType,
              titleHintText: inbox?.suggestion?.summary ?? inbox?.title,
              initialDescription: inbox?.description,
              initialProject: project,
              originalTaskMail: inbox?.linkedMail,
              originalTaskMessage: inbox?.linkedMessage,
              calendarTaskEditSourceType: CalendarTaskEditSourceType.inboxDrag,
            ),
          )
          .then((_) {
            completer.complete();
          })
          .catchError((e) {
            completer.completeError(e);
          });
    } else {
      RenderBox renderBox = (isBraindump ? braindumpTaskDropWidgetKey : unscheduledTaskDropWidgetKey).currentContext?.findRenderObject() as RenderBox;
      Offset offset = renderBox.localToGlobal(Offset.zero);
      Size size = renderBox.size;

      if (inbox != null) {
        renderBox = createTaskShadowKey.currentContext?.findRenderObject() as RenderBox;
        offset = renderBox.localToGlobal(Offset.zero);
        size = renderBox.size;
        isBraindump = draggedItemIsBraindump == true;
      }

      showContextMenu(
        topLeft: offset - Offset(0, inbox == null ? 0 : 36),
        bottomRight: Offset(offset.dx + size.width, offset.dy + size.height) - Offset(0, inbox == null ? 0 : 36),
        context: context,
        popupMenuLocation: PopupMenuLocation.right,
        child: SimpleTaskOrEventSwithcerWidget(
          tabType: widget.tabType,
          isUnscheduledTask: true,
          targetStatus: isBraindump ? TaskStatus.braindump : TaskStatus.none,
          isEvent: false,
          suggestedProjectId: inbox?.suggestion?.project_id,
          selectedDate: DateUtils.dateOnly(DateTime.now()),
          onTitleChanged: onTitleChanged,
          onColorChanged: onColorChanged,
          onSaved: onSaved,
          titleHintText: inbox?.suggestion?.summary ?? inbox?.title,
          description: inbox?.description,
          originalTaskMail: inbox?.linkedMail,
          originalTaskMessage: inbox?.linkedMessage,
          calendarTaskEditSourceType: CalendarTaskEditSourceType.inboxDrag,
          isAllDay: false,
          startDate: DateTime.now(),
          endDate: DateTime.now(),
        ),
        verticalPadding: 16.0,
        borderRadius: 6.0,
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        clipBehavior: Clip.none,
        isPopupMenu: false,
        hideShadow: true,
        width: Constants.desktopCreateTaskPopupWidth,
        afterPopup: () {
          draggedInbox = null;
          draggedItemIsBraindump = null;
          draggedInboxIsReadyToCreate = null;
          draggedInboxTitle = null;
          draggedInboxColor = null;
          setState(() {});
          completer.complete();
        },
      );
    }

    if (isLinkedWithMail) {
      UserActionSwtichAction.onOpenMail(mailHost: inbox?.linkedMail?.hostMail ?? '');
    }
    if (isLinkedWithMessage) {
      UserActionSwtichAction.onOpenExternalMessageLink(teamId: inbox?.linkedMessage?.teamId ?? '');
    }

    return completer.future;
  }

  onSaved() {}

  onTitleChanged(String? title) {
    if (title?.isNotEmpty != true) {
      final suggestedTitle = draggedInbox?.suggestion?.summary ?? draggedInbox?.title;
      draggedInboxTitle = suggestedTitle?.isNotEmpty == true ? suggestedTitle : context.tr.new_task;
    } else {
      draggedInboxTitle = title;
    }
    setState(() {});
  }

  onColorChanged(Color? color) {
    if (color == null) return;
    draggedInboxColor = color;
    setState(() {});
  }

  Widget buildTaskView(TaskEntity e, {required double height, required double width, required TaskStatus targetStatus}) {
    final userId = ref.read(authControllerProvider.select((v) => v.requireValue.id));
    final project = ref.read(
      projectListControllerProvider.select((p) => p.firstWhereOrNull((p) => p.isPointedProject(e)) ?? p.firstWhereOrNull((p) => p.uniqueId == userId)),
    );
    if (project == null) return SizedBox.shrink();
    Color? backgroundColor = e.isEvent ? e.linkedEvent?.backgroundColor : project.color;
    if (backgroundColor == null) return SizedBox.shrink();

    HSVColor hsvColor = HSVColor.fromColor(backgroundColor);
    if (context.brightness == Brightness.light) {
      if (hsvColor.value > 0.7 && hsvColor.saturation >= 0.2 && hsvColor.saturation < 0.5) {
        hsvColor = hsvColor.withValue(0.7);
        backgroundColor = hsvColor.toColor();
      } else if (hsvColor.value > 0.5 && hsvColor.saturation < 0.2) {
        hsvColor = hsvColor.withValue(0.5);
        backgroundColor = hsvColor.toColor();
      } else if (hsvColor.value > 0.9 && hsvColor.saturation >= 0.5) {
        hsvColor = hsvColor.withValue(0.9);
      }
    }

    Color nonAgendaBackgroundColor = backgroundColor.withValues(alpha: hsvColor.value <= 0.6 && context.brightness == Brightness.dark ? 0.3 : 0.15);
    Color nonAgendaForegroundColor = backgroundColor;
    Color nonAgendaTextColor = backgroundColor;

    if (context.brightness == Brightness.dark) {
      if (hsvColor.value <= 0.6) {
        hsvColor = hsvColor.withValue(0.9);
        nonAgendaForegroundColor = hsvColor.toColor();
        nonAgendaTextColor = hsvColor.toColor();
      }

      nonAgendaTextColor = hsvColor.withSaturation(0.2).withValue(1).toColor();
    } else {
      if (hsvColor.hue > 0.4 && hsvColor.hue < 0.95 && hsvColor.value > 0.7 && hsvColor.saturation >= 0.5) {
        hsvColor = hsvColor.withValue(0.7);
        nonAgendaTextColor = hsvColor.toColor();
      }

      nonAgendaTextColor = hsvColor.withSaturation(0.95).withValue(0.3).toColor();
    }

    double checkboxSize = context.bodyLarge!.height! * context.bodyLarge!.fontSize! - 2;

    double leftPadding = 4;
    double topPadding = 0;

    final isRequest = false;
    final isDeclined = false;

    Color base = nonAgendaBackgroundColor;

    Widget child = RepaintBoundary(
      child: Container(
        height: height,
        constraints: BoxConstraints(minHeight: 18),
        alignment: Alignment.centerLeft,
        child: Stack(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      double maxHeight = constraints.maxHeight - (isRequest || isDeclined || e.isAllDay ? 0 : topPadding);
                      // double maxWidth = constraints.maxWidth - (leftPadding + rightPadding);

                      bool isHideCell = maxHeight < (context.bodyLarge!.height! * context.textScaler.scale(context.bodyLarge!.fontSize!));

                      return Stack(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: leftPadding, right: 2, top: isRequest || isDeclined || e.isAllDay ? 0 : topPadding),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                if (isHideCell) return SizedBox.shrink();

                                return Align(
                                  alignment: Alignment.centerLeft,
                                  child: Row(
                                    children: [
                                      if (!e.isEvent && !e.isBraindump)
                                        VisirButton(
                                          type: VisirButtonAnimationType.scaleAndOpacity,
                                          style: VisirButtonStyle(
                                            cursor: WidgetStateMouseCursor.clickable,
                                            margin: EdgeInsets.only(right: 4),
                                            width: checkboxSize,
                                            height: checkboxSize,
                                            clickMargin: EdgeInsets.all(4),
                                            hoverColor: e.status == TaskStatus.done ? null : nonAgendaForegroundColor.withValues(alpha: 0.5),
                                            backgroundColor: e.status == TaskStatus.done ? nonAgendaForegroundColor : null,
                                            borderRadius: BorderRadius.circular(4),
                                            border: e.status == TaskStatus.done ? null : Border.all(color: nonAgendaForegroundColor, width: 1),
                                          ),
                                          child: e.status == TaskStatus.done
                                              ? VisirIcon(type: VisirIconType.taskCheck, size: checkboxSize * 2 / 3, color: Colors.white)
                                              : null,
                                          onTap: () {
                                            EasyThrottle.throttle('toggleTaskStatus${e.id}', Duration(milliseconds: 50), () {
                                              TaskAction.toggleStatus(
                                                task: e,
                                                startAt: e.editedStartTime ?? e.startAt,
                                                endAt: e.editedEndTime ?? e.endAt,
                                                tabType: widget.tabType,
                                              );
                                            });
                                          },
                                        ),
                                      Expanded(
                                        child: Text(
                                          '${e.title ?? 'New Event'}',
                                          softWrap: false,
                                          overflow: TextOverflow.ellipsis,
                                          style: context.bodyLarge?.textColor(
                                            e.isBraindump ? context.onBackground.withValues(alpha: 0.8) : nonAgendaTextColor.withValues(alpha: 0.8),
                                          ),
                                          maxLines: 1,
                                          strutStyle: StrutStyle(
                                            forceStrutHeight: true,
                                            height: context.bodyLarge?.height,
                                            fontSize: context.bodyLarge?.fontSize,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    final style = VisirButtonStyle(
      hoverBorder: Border.all(color: e.isBraindump ? context.surfaceVariant : backgroundColor, width: 1, strokeAlign: BorderSide.strokeAlignInside),
      clickMargin: EdgeInsets.zero,
      borderRadius: BorderRadius.circular(6),
      margin: EdgeInsets.only(right: 6, left: 6, bottom: 1),
      backgroundColor: e.isBraindump ? context.surfaceVariant.withValues(alpha: 0.2) : base,
      border: Border.all(color: Colors.transparent, width: 1, strokeAlign: BorderSide.strokeAlignInside),
    );

    // if (!(PlatformX.isDesktopView && widget.tabType == TabType.home)) return child;

    final result = buildDraggable(
      task: e,
      child: PopupMenu(
        enabled: PlatformX.isDesktopView,
        backgroundColor: Colors.transparent,
        hideShadow: true,
        forceShiftOffset: forceShiftOffsetForMenu,
        popup: TaskSimpleCreateWidget(
          tabType: widget.tabType,
          targetStatus: targetStatus,
          forceUnscheduled: true,
          task: e,
          selectedDate: DateTime.now().dateOnly,
          calendarTaskEditSourceType: CalendarTaskEditSourceType.editOriginal,
        ),
        type: ContextMenuActionType.tap,
        location: PopupMenuLocation.right,
        style: style,
        child: child,
      ),
    );

    return result;
  }

  Offset lastPosition = Offset.zero;
  Widget buildDraggable({required Widget child, required TaskEntity task}) {
    final ratio = ref.watch(zoomRatioProvider);
    if (PlatformX.isMobileView) {
      return InboxLongPressDraggable(
        scaleFactor: ratio,
        dragAnchorStrategy: (InboxDraggable<Object> d, BuildContext context, Offset point) {
          return Offset(d.feedbackOffset.dx, d.feedbackOffset.dy);
        },
        onDragStarted: () {
          draggedTask = task;
          originalTask = task;
          draggedItemIsBraindump = task.status == TaskStatus.braindump;
          setState(() {});
          widget.onTaskDragStart?.call(draggedTask!);
        },
        onDragUpdate: (details) {
          if (draggedTask == null) {
            draggedTask = task;
            originalTask = task;
            draggedItemIsBraindump = task.status == TaskStatus.braindump;
            setState(() {});
            widget.onTaskDragStart?.call(draggedTask!);
            return;
          }

          widget.onTaskDragUpdate?.call(draggedTask!, details.globalPosition / ratio);
          lastPosition = details.globalPosition;
          onTaskDragUpdate(task, details.globalPosition, targetStatus: task.status == TaskStatus.braindump ? TaskStatus.none : TaskStatus.braindump);
        },
        onDragEnd: (details) {
          widget.onTaskDragEnd?.call(draggedTask!);
          onTaskDragEnd();
        },
        hitTestBehavior: HitTestBehavior.opaque,
        feedback: SizedBox.shrink(),
        child: child,
      );
    }

    return InboxDraggable(
      scaleFactor: ratio,
      dragAnchorStrategy: (InboxDraggable<Object> d, BuildContext context, Offset point) {
        return Offset(d.feedbackOffset.dx, d.feedbackOffset.dy);
      },
      onDragStarted: () {
        draggedTask = task;
        originalTask = task;
        draggedItemIsBraindump = task.status == TaskStatus.braindump;
        setState(() {});
        widget.onTaskDragStart?.call(task);
      },
      onDragUpdate: (details) {
        widget.onTaskDragUpdate?.call(task, details.globalPosition / ratio);
        lastPosition = details.globalPosition;
        onTaskDragUpdate(task, details.globalPosition, targetStatus: task.status == TaskStatus.braindump ? TaskStatus.none : TaskStatus.braindump);
      },
      onDragEnd: (details) {
        widget.onTaskDragEnd?.call(task);
        onTaskDragEnd();
      },
      hitTestBehavior: HitTestBehavior.opaque,
      feedback: SizedBox.shrink(),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cateogry = [context.tr.task_section_braindump, context.tr.task_section_unscheduled];
    final unscheduledTask = ref.watch(taskListControllerProvider.select((v) => v.tasks.where((e) => e.isUnscheduled && !e.isDone && !e.isCancelled)));
    return LayoutBuilder(
      builder: (context, constraints) {
        return Material(
          color: widget.backgroundColor ?? context.background,
          child: BoardView(
            boardViewController: boardViewController,
            width: constraints.maxWidth / 2 - 3,
            lists: cateogry.map((p) {
              bool isBraindump = p == context.tr.task_section_braindump;
              return BoardList(
                key: isBraindump ? braindumpTaskDropWidgetKey : unscheduledTaskDropWidgetKey,
                onStartDragList: (int? listIndex) {},
                onTapList: (int? listIndex) async {},
                onDropList: (int? listIndex, int? oldListIndex) {},
                headerBackgroundColor: Colors.transparent,
                backgroundColor: context.surface.withValues(alpha: draggedItemIsBraindump == isBraindump ? 0.8 : 0.4),
                onDoubleTapList: (details) {
                  draggedInbox = InboxEntity(id: Uuid().v4(), title: '');
                  draggedItemIsBraindump = isBraindump;
                  draggedInboxTitle = context.tr.new_task;
                  onInboxDragEnd(null, details.globalPosition, isBraindump: isBraindump);
                },
                header: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                      child: Text(p, style: context.titleLarge?.textColor(context.onBackground), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                  ),
                  if (PlatformX.isDesktopView && widget.tabType == TabType.home)
                    VisirAppBarButton(
                      icon: VisirIconType.add,
                      popupBackgroundColor: Colors.transparent,
                      popupWidth: 320,
                      hideShadow: true,
                      popupLocation: PopupMenuLocation.right,
                      popupForceShiftOffset: Offset(0, -36),
                      options: VisirButtonOptions(
                        shortcuts: [
                          if (isBraindump)
                            VisirButtonKeyboardShortcut(
                              keys: [
                                if (PlatformX.isApple) LogicalKeyboardKey.meta,
                                if (!PlatformX.isApple) LogicalKeyboardKey.control,
                                LogicalKeyboardKey.keyB,
                              ],
                              message: context.tr.dump_ideas_from_brain,
                            ),
                          if (!isBraindump)
                            VisirButtonKeyboardShortcut(
                              keys: [
                                if (PlatformX.isApple) LogicalKeyboardKey.meta,
                                if (!PlatformX.isApple) LogicalKeyboardKey.control,
                                LogicalKeyboardKey.keyU,
                              ],
                              message: context.tr.add_unscheduled_task,
                            ),
                        ],
                      ),
                      popup: TaskSimpleCreateWidget(
                        tabType: widget.tabType,
                        calendarTaskEditSourceType: CalendarTaskEditSourceType.doubleClick,
                        selectedDate: DateTime.now().dateOnly,
                        forceUnscheduled: true,
                        targetStatus: isBraindump ? TaskStatus.braindump : TaskStatus.none,
                      ),
                    ).getButton(context: context),
                  SizedBox(width: 1),
                ],
                items: [
                  ...unscheduledTask.where((e) => isBraindump ? e.status == TaskStatus.braindump : e.status == TaskStatus.none).map((t) {
                    return BoardItem(
                      onStartDragItem: (int? listIndex, int? itemIndex, BoardItemState state) {},
                      // onDropItem: (int? listIndex, int? itemIndex, int oldListIndex, int oldItemIndex, BoardItemState state) {},
                      onTapItem: (int? listIndex, int? itemIndex, BoardItemState state) async {},
                      item: buildTaskView(t, height: 20, width: 172, targetStatus: isBraindump ? TaskStatus.braindump : TaskStatus.none),
                    );
                  }).toList(),
                  if (isBraindump == draggedItemIsBraindump && (draggedInbox != null || draggedTask != null))
                    BoardItem(
                      item: Builder(
                        builder: (context) {
                          final lastUsedProjectId = ref.read(lastUsedProjectIdProvider).firstOrNull;
                          final lastUsedProject = lastUsedProjectId == null
                              ? null
                              : ref.read(projectListControllerProvider).firstWhereOrNull((e) => e.isPointedProjectId(lastUsedProjectId));
                          final defaultProject = ref.read(projectListControllerProvider).firstWhereOrNull((e) => e.isDefault);
                          final taskProject = draggedTask?.projectId == null
                              ? null
                              : ref.read(projectListControllerProvider).firstWhereOrNull((e) => e.isPointedProjectId(draggedTask!.projectId));
                          final suggestedProject = draggedInbox?.suggestion?.project_id == null
                              ? null
                              : ref.read(projectListControllerProvider).firstWhereOrNull((e) => e.isPointedProjectId(draggedInbox?.suggestion?.project_id));
                          final color = taskProject?.color ?? draggedInboxColor ?? suggestedProject?.color ?? lastUsedProject?.color ?? defaultProject?.color;
                          return Container(
                            key: createTaskShadowKey,
                            decoration: BoxDecoration(
                              color: isBraindump
                                  ? context.surfaceVariant.withValues(alpha: 0.2)
                                  : draggedTask != null
                                  ? color?.withValues(alpha: 0.15)
                                  : draggedInboxIsReadyToCreate == true
                                  ? color
                                  : null,
                              border: Border.all(
                                color: isBraindump ? context.surfaceVariant.withValues(alpha: 0.8) : color?.withValues(alpha: 0.5) ?? context.primary,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            margin: EdgeInsets.symmetric(horizontal: 6),
                            height: 20,
                            width: 172,
                            alignment: Alignment.centerLeft,
                            child: draggedInboxIsReadyToCreate == true || draggedTask != null
                                ? Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 5),
                                    child: Text.rich(
                                      TextSpan(
                                        children: [
                                          TextSpan(
                                            text: draggedTask?.title ?? draggedInboxTitle ?? draggedInbox?.suggestion?.summary ?? draggedInbox?.title ?? "",
                                            style: context.bodyMedium?.textColor(
                                              isBraindump
                                                  ? context.onBackground.withValues(alpha: 0.9)
                                                  : draggedTask != null
                                                  ? color?.withValues(alpha: 0.9)
                                                  : Colors.white.withValues(alpha: 0.9),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : null,
                          );
                        },
                      ),
                    ),
                ],
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
