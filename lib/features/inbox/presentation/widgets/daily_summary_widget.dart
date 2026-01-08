import 'package:Visir/config/providers.dart';
import 'package:Visir/dependency/contextmenu/src/ContextMenuArea.dart';
import 'package:Visir/features/auth/application/auth_controller.dart';
import 'package:Visir/features/calendar/domain/entities/calendar_entity.dart';
import 'package:Visir/features/calendar/domain/entities/event_entity.dart';
import 'package:Visir/features/calendar/presentation/widgets/calendar_simple_create_widget.dart';
import 'package:Visir/features/chat/application/chat_channel_list_controller.dart';
import 'package:Visir/features/chat/presentation/screens/chat_list_screen.dart';
import 'package:Visir/features/chat/providers.dart';
import 'package:Visir/features/common/presentation/utils/extensions/platform_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/inbox/application/inbox_agent_list_controller.dart';
import 'package:Visir/features/inbox/domain/entities/inbox_config_entity.dart';
import 'package:Visir/l10n/app_localizations.dart';
import 'package:Visir/features/common/presentation/widgets/popup_menu.dart';
import 'package:Visir/features/common/presentation/widgets/visir_app_bar.dart';
import 'package:Visir/features/common/presentation/widgets/visir_button.dart';
import 'package:Visir/features/common/presentation/widgets/visir_icon.dart';
import 'package:Visir/features/common/provider.dart';
import 'package:Visir/features/inbox/application/inbox_conversation_summary_controller.dart';
import 'package:Visir/features/inbox/presentation/widgets/inbox_draggable.dart';
import 'package:Visir/features/inbox/presentation/widgets/inbox_item.dart';
import 'package:Visir/features/mail/domain/entities/mail_label_entity.dart';
import 'package:Visir/features/mail/presentation/screens/mail_detail_screen.dart';
import 'package:Visir/features/mail/providers.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:hugeicons/hugeicons_full.dart';
import 'package:Visir/features/inbox/domain/entities/inbox_entity.dart';
import 'package:Visir/features/inbox/domain/entities/inbox_suggestion_entity.dart';
import 'package:Visir/features/inbox/application/mcp_function_executor.dart';
import 'package:Visir/features/inbox/providers/daily_summary_providers.dart';
import 'package:Visir/dependency/toasty_box/model/toast_model.dart';
import 'package:Visir/features/task/actions.dart';
import 'package:Visir/features/task/application/project_list_controller.dart';
import 'package:Visir/features/task/domain/entities/project_entity.dart';
import 'package:Visir/features/task/domain/entities/task_entity.dart';
import 'package:Visir/features/task/presentation/widgets/mobile_task_edit_widget.dart';
import 'package:Visir/features/task/presentation/widgets/task_simple_create_widget.dart';
import 'package:collection/collection.dart';
import 'package:easy_debounce/easy_throttle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class DailySummaryWidget extends ConsumerWidget {
  final List<EventEntity> events;
  final List<TaskEntity> tasks;
  final List<InboxEntity> inboxes;
  final ProjectEntity? selectedProject;
  final List<ProjectEntityWithDepth> projects;
  final String? userName;

  final void Function(InboxEntity? inbox, TaskEntity? task)? onDragStart;
  final void Function(InboxEntity? inbox, TaskEntity? task, Offset offset)? onDragUpdate;
  final void Function(InboxEntity? inbox, TaskEntity? task, Offset offset)? onDragEnd;

  DailySummaryWidget({
    super.key,
    required this.events,
    required this.tasks,
    required this.inboxes,
    required this.selectedProject,
    required this.projects,
    this.userName,
    this.onDragStart,
    this.onDragUpdate,
    this.onDragEnd,
  });

  // _relevantProjectIds는 이제 Provider로 이동됨 (daily_summary_providers.dart)

  String _getReasonTitle(BuildContext context, InboxSuggestionReason reason) {
    final localizations = AppLocalizations.of(context);
    if (localizations == null) return '';

    switch (reason) {
      case InboxSuggestionReason.meeting_invitation:
        return localizations.ai_suggestion_reason_meeting_invitation;
      case InboxSuggestionReason.meeting_followup:
        return localizations.ai_suggestion_reason_meeting_followup;
      case InboxSuggestionReason.meeting_notes:
        return localizations.ai_suggestion_reason_meeting_notes;
      case InboxSuggestionReason.task_assignment:
        return localizations.ai_suggestion_reason_task_assignment;
      case InboxSuggestionReason.task_status_update:
        return localizations.ai_suggestion_reason_task_status_update;
      case InboxSuggestionReason.scheduling_request:
        return localizations.ai_suggestion_reason_scheduling_request;
      case InboxSuggestionReason.scheduling_confirmation:
        return localizations.ai_suggestion_reason_scheduling_confirmation;
      case InboxSuggestionReason.document_review:
        return localizations.ai_suggestion_reason_document_review;
      case InboxSuggestionReason.code_review:
        return localizations.ai_suggestion_reason_code_review;
      case InboxSuggestionReason.approval_request:
        return localizations.ai_suggestion_reason_approval_request;
      case InboxSuggestionReason.question:
        return localizations.ai_suggestion_reason_question;
      case InboxSuggestionReason.information_sharing:
        return localizations.ai_suggestion_reason_information_sharing;
      case InboxSuggestionReason.announcement:
        return localizations.ai_suggestion_reason_announcement;
      case InboxSuggestionReason.system_notification:
        return localizations.ai_suggestion_reason_system_notification;
      case InboxSuggestionReason.cold_contact:
        return localizations.ai_suggestion_reason_cold_contact;
      case InboxSuggestionReason.customer_contact:
        return localizations.ai_suggestion_reason_customer_contact;
      case InboxSuggestionReason.other:
        return localizations.ai_suggestion_reason_other;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Provider를 사용하여 계산 결과 캐싱 (성능 최적화)
    final relevantIds = ref.watch(relevantProjectIdsProvider(selectedProject, projects));

    // 필터링된 데이터 (Provider로 캐싱)
    final filteredTasks = ref.watch(filteredTasksProvider(tasks, selectedProject, relevantIds));
    final filteredInboxes = ref.watch(filteredInboxesProvider(inboxes, selectedProject, relevantIds));

    // 오늘의 태스크/이벤트 (Provider로 캐싱)
    final todayTasks = ref.watch(todayTasksProvider(filteredTasks));
    final todayEvents = ref.watch(todayEventsProvider(events));
    final overdueTasks = ref.watch(overdueTasksProvider(filteredTasks));

    // 이벤트-태스크 매핑 (Provider로 캐싱)
    final eventToTaskMap = ref.watch(eventToTaskMapProvider(tasks));

    // 다음 일정 계산 (Provider로 캐싱)
    final todayUpcomingItems = ref.watch(todayUpcomingItemsProvider(todayEvents, todayTasks, eventToTaskMap, projects));
    final futureUpcomingItems = ref.watch(futureUpcomingItemsProvider(events, tasks, eventToTaskMap, projects));
    final nextUpcomingItem = ref.watch(nextItemProvider(todayUpcomingItems, futureUpcomingItems));

    // Color를 위젯에서 설정 (Provider에서는 기본값만 제공)
    final nextItem = nextUpcomingItem != null
        ? _UpcomingItem(
            time: nextUpcomingItem.time,
            title: nextUpcomingItem.title,
            isEvent: nextUpcomingItem.isEvent,
            event: nextUpcomingItem.event,
            task: nextUpcomingItem.task,
            color: nextUpcomingItem.color == Colors.transparent && nextUpcomingItem.project != null
                ? (nextUpcomingItem.project!.color ?? context.surface)
                : (nextUpcomingItem.color == Colors.transparent ? context.surface : nextUpcomingItem.color),
            project: nextUpcomingItem.project,
            calendar: nextUpcomingItem.calendar,
            description: nextUpcomingItem.description,
          )
        : null;

    // Checked 아이템 필터링 (linkedTask가 있거나 isRead == true인 inbox들)
    final checkedInboxes = filteredInboxes.where((i) => (i.linkedTask?.tasks.isNotEmpty == true || i.isRead == true)).toList();
    final checkedItems = checkedInboxes.map((i) {
      // Get project from inbox: first try linkedTask, then suggestion.project_id
      String? projectId;
      if (i.linkedTask?.tasks.isNotEmpty == true) {
        projectId = i.linkedTask!.tasks.first.projectId;
      } else if (i.suggestion?.project_id != null) {
        projectId = i.suggestion!.project_id;
      }
      final project = projectId != null ? projects.firstWhereOrNull((p) => p.project.uniqueId == projectId) : null;
      final defaultProject = projects.firstWhereOrNull((p) => p.project.isDefault);
      final finalProject = project?.project ?? defaultProject?.project;

      return _DashboardItem(
        title: i.suggestion?.decryptedSummary ?? i.decryptedTitle,
        subtitle: i.linkedMail?.fromName ?? i.linkedMessage?.userName ?? i.suggestion?.sender_name,
        urgency: i.suggestion?.urgency ?? InboxSuggestionUrgency.none,
        icon: finalProject?.icon ?? VisirIconType.inbox,
        projectId: projectId,
        inbox: i,
      );
    }).toList();

    // Checked 아이템을 제외한 inbox 리스트 (다른 컬럼에서 제외하기 위해)
    final inboxesExcludingChecked = filteredInboxes.where((i) => !checkedInboxes.contains(i)).toList();

    // 인박스 그룹화 및 정렬 (Provider로 캐싱) - checked 아이템 제외
    final inboxesByReason = ref.watch(inboxesByReasonProvider(inboxesExcludingChecked));
    final sortedReasons = ref.watch(sortedReasonsProvider(inboxesByReason));

    // 지연된 태스크를 대시보드 아이템으로 변환 (Provider로 캐싱)
    // checked inbox와 연결된 task도 제외
    final checkedTaskIds = checkedInboxes.where((i) => i.linkedTask?.tasks.isNotEmpty == true).expand((i) => i.linkedTask!.tasks.map((t) => t.id)).toSet();
    final overdueTasksExcludingChecked = overdueTasks.where((t) => !checkedTaskIds.contains(t.id)).toList();
    final overdueDashboardItems = ref.watch(overdueDashboardItemsProvider(overdueTasksExcludingChecked, projects, context.tr.daily_summary_overdue_task));
    final allOverdueItems = overdueDashboardItems
        .map(
          (item) =>
              _DashboardItem(title: item.title, subtitle: item.subtitle, urgency: item.urgency, icon: item.icon, projectId: item.projectId, task: item.task, inbox: item.inbox),
        )
        .toList();

    final horizontalMargin = 16.0;
    final isMobileView = PlatformX.isMobileView;

    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: Container(
        padding: const EdgeInsets.only(top: 6),
        child: isMobileView
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Inbox Highlights Section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Up Next Section
                      if (nextItem != null) ...[
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: horizontalMargin),
                          child: _buildUpNextSection(context, nextItem, tasks, isNextSchedule: todayUpcomingItems.isEmpty),
                        ),
                      ],

                      Container(
                        height: VisirAppBar.height,
                        padding: EdgeInsets.only(left: horizontalMargin, top: 0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [Text(context.tr.daily_summary_inbox_highlights, style: context.titleLarge?.textBold.textColor(context.onBackground))],
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(height: 8),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final columnWidth = isMobileView ? 210.0 : 240.0;
                              const columnSpacing = 16.0;

                              final rowChildren = [
                                // Show overdue tasks if any
                                if (allOverdueItems.isNotEmpty) ...[
                                  SizedBox(
                                    width: columnWidth,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(right: 0, left: 8),
                                          child: Row(
                                            children: [
                                              HugeIcon(icon: HugeIcons.solidRoundedAlert02, size: 14, color: context.error),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  context.tr.daily_summary_overdue,
                                                  style: context.titleMedium?.textBold.textColor(context.onBackground).appFont(context),
                                                ),
                                              ),
                                              Builder(
                                                builder: (context) {
                                                  final overdueTaskList = allOverdueItems.map((item) => item.task).whereType<TaskEntity>().toList();
                                                  if (overdueTaskList.isEmpty) return const SizedBox.shrink();

                                                  final now = DateTime.now();
                                                  final today = DateUtils.dateOnly(now);

                                                  return VisirButton(
                                                    style: VisirButtonStyle(
                                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                                      backgroundColor: context.surface,
                                                      borderRadius: BorderRadius.circular(6),
                                                    ),
                                                    onTap: () async {
                                                      // Filter out recurring tasks and tasks already scheduled for today
                                                      final tasksToReschedule = overdueTaskList.where((task) {
                                                        // Exclude recurring task instances
                                                        if (task.recurringTaskId != null) return false;

                                                        // Exclude tasks already scheduled for today
                                                        final taskStartDate = task.startAt ?? task.startDate;
                                                        if (DateUtils.dateOnly(taskStartDate) == today) return false;

                                                        return true;
                                                      }).toList();

                                                      if (tasksToReschedule.isEmpty) return;

                                                      // Use MCP reschedule function to intelligently schedule tasks
                                                      final executor = McpFunctionExecutor();
                                                      final taskIds = tasksToReschedule.map((task) => task.id).toList();

                                                      final result = await executor.executeFunction(
                                                        'reschedule',
                                                        {'taskIds': taskIds},
                                                        tabType: TabType.home,
                                                        availableTasks: tasksToReschedule,
                                                      );

                                                      if (result['success'] == true) {
                                                        // Show success message if needed
                                                        final message = result['message'] as String?;
                                                        if (message != null) {
                                                          Utils.showToast(
                                                            ToastModel(
                                                              message: TextSpan(text: message),
                                                              buttons: [],
                                                            ),
                                                          );
                                                        }
                                                      } else {
                                                        // Fallback to simple reschedule if reschedule fails
                                                        final error = result['error'] as String? ?? '재스케줄 중 오류가 발생했습니다.';
                                                        Utils.showToast(
                                                          ToastModel(
                                                            message: TextSpan(text: error),
                                                            buttons: [],
                                                          ),
                                                        );
                                                      }
                                                    },
                                                    child: Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        VisirIcon(type: VisirIconType.calendarAfter, size: 14, color: context.onSurface, isSelected: false),
                                                        const SizedBox(width: 3),
                                                        Text(context.tr.daily_summary_move_to_today, style: context.bodySmall?.textColor(context.onSurface)),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Container(color: context.outline.withValues(alpha: 0.15), height: 1, margin: EdgeInsets.symmetric(horizontal: 4)),
                                        _buildColumnList(context: context, ref: ref, items: allOverdueItems, emptyMessage: context.tr.daily_summary_no_urgent_items),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: columnSpacing),
                                ],
                                // Show reason-based columns
                                ...() {
                                  final reasonWidgets = sortedReasons
                                      .map((reason) {
                                        final reasonInboxes = inboxesByReason[reason]!;
                                        // Filter out items with urgency none and sort by urgency first, then by weight
                                        final sortedItems = reasonInboxes.where((i) => i.suggestion?.urgency != InboxSuggestionUrgency.none).toList()
                                          ..sort((a, b) {
                                            final aUrgency = a.suggestion?.urgency.priority ?? 999;
                                            final bUrgency = b.suggestion?.urgency.priority ?? 999;
                                            if (aUrgency != bUrgency) {
                                              return aUrgency.compareTo(bUrgency);
                                            }
                                            // If same urgency, sort by weight (lower weight = higher priority)
                                            final aWeight = a.suggestion?.reason.weight ?? 999;
                                            final bWeight = b.suggestion?.reason.weight ?? 999;
                                            return aWeight.compareTo(bWeight);
                                          });

                                        // Don't show section if no items after filtering
                                        if (sortedItems.isEmpty) {
                                          return null;
                                        }

                                        return Container(
                                          width: columnWidth,
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.only(right: 8, left: 8),
                                                child: SizedBox(
                                                  height: 26, // Overdue 섹션의 버튼 높이와 맞추기 (padding 6*2 + icon/text ~14 = ~26)
                                                  child: Row(
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    children: [
                                                      if (reason.icon != null) ...[HugeIcon(icon: reason.icon, size: 14, color: reason.iconColor), const SizedBox(width: 8)],
                                                      Expanded(
                                                        child: Builder(
                                                          builder: (context) {
                                                            final title = reason.title.isNotEmpty ? reason.title : _getReasonTitle(context, reason);
                                                            return Text(title, style: context.titleMedium?.textBold.textColor(context.onBackground).appFont(context));
                                                          },
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Container(color: context.outline.withValues(alpha: 0.15), height: 1, margin: EdgeInsets.symmetric(horizontal: 4)),
                                              _buildColumnList(
                                                context: context,
                                                ref: ref,
                                                items: sortedItems.map((i) {
                                                  // Get project from inbox: first try linkedTask, then suggestion.project_id
                                                  String? projectId;
                                                  if (i.linkedTask?.tasks.isNotEmpty == true) {
                                                    projectId = i.linkedTask!.tasks.first.projectId;
                                                  } else if (i.suggestion?.project_id != null) {
                                                    projectId = i.suggestion!.project_id;
                                                  }
                                                  final project = projectId != null ? projects.firstWhereOrNull((p) => p.project.uniqueId == projectId) : null;
                                                  final defaultProject = projects.firstWhereOrNull((p) => p.project.isDefault);
                                                  final finalProject = project?.project ?? defaultProject?.project;

                                                  return _DashboardItem(
                                                    title: i.suggestion?.decryptedSummary ?? i.decryptedTitle,
                                                    subtitle: i.linkedMail?.fromName ?? i.linkedMessage?.userName ?? i.suggestion?.sender_name,
                                                    urgency: i.suggestion?.urgency ?? InboxSuggestionUrgency.none,
                                                    icon: finalProject?.icon ?? VisirIconType.inbox,
                                                    projectId: projectId,
                                                    inbox: i,
                                                  );
                                                }).toList(),
                                                emptyMessage: 'No ${reason.title.toLowerCase()}',
                                              ),
                                            ],
                                          ),
                                        );
                                      })
                                      .whereType<Widget>()
                                      .expand((widget) => [widget, SizedBox(width: columnSpacing)])
                                      .toList();
                                  if (reasonWidgets.isNotEmpty) {
                                    reasonWidgets.removeLast();
                                  }
                                  return reasonWidgets;
                                }(),
                                // Show checked column if any
                                if (checkedItems.isNotEmpty) ...[
                                  SizedBox(width: columnSpacing),
                                  Container(
                                    width: columnWidth,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(right: 8, left: 8),
                                          child: SizedBox(
                                            height: 26,
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                VisirIcon(type: VisirIconType.taskCheck, size: 14, color: context.onSurfaceVariant, isSelected: true),
                                                const SizedBox(width: 8),
                                                Expanded(child: Text('Checked', style: context.titleMedium?.textBold.textColor(context.onBackground).appFont(context))),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Container(color: context.outline.withValues(alpha: 0.15), height: 1, margin: EdgeInsets.symmetric(horizontal: 4)),
                                        _buildColumnList(context: context, ref: ref, items: checkedItems, emptyMessage: 'No checked items'),
                                      ],
                                    ),
                                  ),
                                ],
                              ];

                              // Show empty state if no columns to display
                              if (rowChildren.isEmpty) {
                                return Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Opacity(
                                        opacity: 0.5,
                                        child: Container(
                                          margin: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                                          constraints: BoxConstraints(maxWidth: 240, maxHeight: 240),
                                          child: Image.asset('assets/illust/noselection.png', fit: BoxFit.contain),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(top: 0, bottom: 24, left: horizontalMargin, right: horizontalMargin),
                                        child: Text(
                                          context.tr.daily_summary_no_inbox_highlights_friendly,
                                          style: context.titleMedium?.textColor(context.surfaceTint),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }

                              return SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                child: Container(
                                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(width: horizontalMargin),
                                      ...rowChildren,
                                      SizedBox(width: horizontalMargin),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: VisirAppBar.height,
                          padding: EdgeInsets.only(left: horizontalMargin, top: 0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [Text(context.tr.daily_summary_inbox_highlights, style: context.titleLarge?.textBold.textColor(context.onBackground))],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              SizedBox(height: 8),
                              Expanded(
                                child: LayoutBuilder(
                                  builder: (context, constraints) {
                                    const columnWidth = 240.0;
                                    const columnSpacing = 16.0;
                                    final totalColumnCount = (allOverdueItems.isNotEmpty ? 1 : 0) + sortedReasons.length + (checkedItems.isNotEmpty ? 1 : 0);
                                    final totalWidth = (totalColumnCount * columnWidth) + ((totalColumnCount - 1) * columnSpacing) + (horizontalMargin * 2);
                                    final needsScroll = totalWidth > constraints.maxWidth;

                                    final rowChildren = [
                                      // Show overdue tasks if any
                                      if (allOverdueItems.isNotEmpty) ...[
                                        SizedBox(
                                          width: columnWidth,
                                          child: Column(
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.only(right: 0, left: 8),
                                                child: Row(
                                                  children: [
                                                    HugeIcon(icon: HugeIcons.solidRoundedAlert02, size: 14, color: context.error),
                                                    const SizedBox(width: 8),
                                                    Expanded(
                                                      child: Text(
                                                        context.tr.daily_summary_overdue,
                                                        style: context.titleMedium?.textBold.textColor(context.onBackground).appFont(context),
                                                      ),
                                                    ),
                                                    Builder(
                                                      builder: (context) {
                                                        final overdueTaskList = allOverdueItems.map((item) => item.task).whereType<TaskEntity>().toList();
                                                        if (overdueTaskList.isEmpty) return const SizedBox.shrink();

                                                        final now = DateTime.now();
                                                        final today = DateUtils.dateOnly(now);

                                                        return VisirButton(
                                                          style: VisirButtonStyle(
                                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                                            backgroundColor: context.surface,
                                                            borderRadius: BorderRadius.circular(6),
                                                          ),
                                                          onTap: () async {
                                                            // Filter out recurring tasks and tasks already scheduled for today
                                                            final tasksToReschedule = overdueTaskList.where((task) {
                                                              // Exclude recurring task instances
                                                              if (task.recurringTaskId != null) return false;

                                                              // Exclude tasks already scheduled for today
                                                              final taskStartDate = task.startAt ?? task.startDate;
                                                              if (DateUtils.dateOnly(taskStartDate) == today) return false;

                                                              return true;
                                                            }).toList();

                                                            if (tasksToReschedule.isEmpty) return;

                                                            // Use MCP reschedule function to intelligently schedule tasks
                                                            final executor = McpFunctionExecutor();
                                                            final taskIds = tasksToReschedule.map((task) => task.id).toList();

                                                            final result = await executor.executeFunction(
                                                              'reschedule',
                                                              {'taskIds': taskIds},
                                                              tabType: TabType.home,
                                                              availableTasks: tasksToReschedule,
                                                            );

                                                            if (result['success'] == true) {
                                                              // Show success message if needed
                                                              final message = result['message'] as String?;
                                                              if (message != null) {
                                                                Utils.showToast(
                                                                  ToastModel(
                                                                    message: TextSpan(text: message),
                                                                    buttons: [],
                                                                  ),
                                                                );
                                                              }
                                                            } else {
                                                              // Fallback to simple reschedule if reschedule fails
                                                              final error = result['error'] as String? ?? '재스케줄 중 오류가 발생했습니다.';
                                                              Utils.showToast(
                                                                ToastModel(
                                                                  message: TextSpan(text: error),
                                                                  buttons: [],
                                                                ),
                                                              );
                                                            }
                                                          },
                                                          child: Row(
                                                            mainAxisSize: MainAxisSize.min,
                                                            children: [
                                                              VisirIcon(type: VisirIconType.calendarAfter, size: 14, color: context.onSurface, isSelected: false),
                                                              const SizedBox(width: 3),
                                                              Text(context.tr.daily_summary_move_to_today, style: context.bodySmall?.textColor(context.onSurface)),
                                                            ],
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Container(color: context.outline.withValues(alpha: 0.15), height: 1, margin: EdgeInsets.symmetric(horizontal: 4)),
                                              Expanded(
                                                child: _buildColumnList(context: context, ref: ref, items: allOverdueItems, emptyMessage: context.tr.daily_summary_no_urgent_items),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(width: columnSpacing),
                                      ],
                                      // Show reason-based columns
                                      ...() {
                                        final reasonWidgets = sortedReasons
                                            .map((reason) {
                                              final reasonInboxes = inboxesByReason[reason]!;
                                              // Filter out items with urgency none and sort by urgency first, then by weight
                                              final sortedItems = reasonInboxes.where((i) => i.suggestion?.urgency != InboxSuggestionUrgency.none).toList()
                                                ..sort((a, b) {
                                                  final aUrgency = a.suggestion?.urgency.priority ?? 999;
                                                  final bUrgency = b.suggestion?.urgency.priority ?? 999;
                                                  if (aUrgency != bUrgency) {
                                                    return aUrgency.compareTo(bUrgency);
                                                  }
                                                  // If same urgency, sort by weight (lower weight = higher priority)
                                                  final aWeight = a.suggestion?.reason.weight ?? 999;
                                                  final bWeight = b.suggestion?.reason.weight ?? 999;
                                                  return aWeight.compareTo(bWeight);
                                                });

                                              // Don't show section if no items after filtering
                                              if (sortedItems.isEmpty) {
                                                return null;
                                              }

                                              return Container(
                                                width: columnWidth,
                                                child: Column(
                                                  children: [
                                                    Padding(
                                                      padding: EdgeInsets.only(right: 8, left: 8),
                                                      child: SizedBox(
                                                        height: 26, // Overdue 섹션의 버튼 높이와 맞추기 (padding 6*2 + icon/text ~14 = ~26)
                                                        child: Row(
                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                          children: [
                                                            if (reason.icon != null) ...[HugeIcon(icon: reason.icon, size: 14, color: reason.iconColor), const SizedBox(width: 8)],
                                                            Expanded(
                                                              child: Builder(
                                                                builder: (context) {
                                                                  final title = reason.title.isNotEmpty ? reason.title : _getReasonTitle(context, reason);
                                                                  return Text(title, style: context.titleMedium?.textBold.textColor(context.onBackground).appFont(context));
                                                                },
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Container(color: context.outline.withValues(alpha: 0.15), height: 1, margin: EdgeInsets.symmetric(horizontal: 4)),
                                                    Expanded(
                                                      child: _buildColumnList(
                                                        context: context,
                                                        ref: ref,
                                                        items: sortedItems.map((i) {
                                                          // Get project from inbox: first try linkedTask, then suggestion.project_id
                                                          String? projectId;
                                                          if (i.linkedTask?.tasks.isNotEmpty == true) {
                                                            projectId = i.linkedTask!.tasks.first.projectId;
                                                          } else if (i.suggestion?.project_id != null) {
                                                            projectId = i.suggestion!.project_id;
                                                          }
                                                          final project = projectId != null ? projects.firstWhereOrNull((p) => p.project.uniqueId == projectId) : null;
                                                          final defaultProject = projects.firstWhereOrNull((p) => p.project.isDefault);
                                                          final finalProject = project?.project ?? defaultProject?.project;

                                                          return _DashboardItem(
                                                            title: i.suggestion?.decryptedSummary ?? i.decryptedTitle,
                                                            subtitle: i.linkedMail?.fromName ?? i.linkedMessage?.userName ?? i.suggestion?.sender_name,
                                                            urgency: i.suggestion?.urgency ?? InboxSuggestionUrgency.none,
                                                            icon: finalProject?.icon ?? VisirIconType.inbox,
                                                            projectId: projectId,
                                                            inbox: i,
                                                          );
                                                        }).toList(),
                                                        emptyMessage: 'No ${reason.title.toLowerCase()}',
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            })
                                            .whereType<Widget>()
                                            .expand((widget) => [widget, SizedBox(width: columnSpacing)])
                                            .toList();
                                        if (reasonWidgets.isNotEmpty) {
                                          reasonWidgets.removeLast();
                                        }
                                        return reasonWidgets;
                                      }(),
                                      // Show checked column if any
                                      if (checkedItems.isNotEmpty) ...[
                                        SizedBox(width: columnSpacing),
                                        Container(
                                          width: columnWidth,
                                          child: Column(
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.only(right: 8, left: 8),
                                                child: SizedBox(
                                                  height: 26,
                                                  child: Row(
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    children: [
                                                      VisirIcon(type: VisirIconType.taskCheck, size: 14, color: context.onSurfaceVariant, isSelected: true),
                                                      const SizedBox(width: 8),
                                                      Expanded(child: Text('Checked', style: context.titleMedium?.textBold.textColor(context.onBackground).appFont(context))),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Container(color: context.outline.withValues(alpha: 0.15), height: 1, margin: EdgeInsets.symmetric(horizontal: 4)),
                                              Expanded(
                                                child: _buildColumnList(context: context, ref: ref, items: checkedItems, emptyMessage: 'No checked items'),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ];

                                    // Show empty state if no columns to display
                                    if (rowChildren.isEmpty) {
                                      return Center(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Opacity(
                                              opacity: 0.5,
                                              child: Container(
                                                margin: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                                                constraints: BoxConstraints(maxWidth: 240, maxHeight: 240),
                                                child: Image.asset('assets/illust/noselection.png', fit: BoxFit.contain),
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(top: 0, bottom: 24),
                                              child: Text(
                                                context.tr.daily_summary_no_inbox_highlights_friendly,
                                                style: context.titleMedium?.textColor(context.surfaceTint),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }

                                    return SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      physics: needsScroll ? const BouncingScrollPhysics() : const NeverScrollableScrollPhysics(),
                                      child: Container(
                                        constraints: BoxConstraints(minWidth: constraints.maxWidth),
                                        child: Row(
                                          mainAxisSize: needsScroll ? MainAxisSize.min : MainAxisSize.max,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(width: horizontalMargin),
                                            ...rowChildren,
                                            SizedBox(width: horizontalMargin),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (nextItem != null) ...[
                    Container(color: context.outline.withValues(alpha: 0.15), width: 1, height: double.infinity, margin: EdgeInsets.only(top: 0, bottom: 12)),
                    SizedBox(
                      width: 320,
                      child: Padding(
                        padding: EdgeInsets.only(left: horizontalMargin, right: horizontalMargin),
                        child: _buildUpNextSection(context, nextItem, tasks, isNextSchedule: todayUpcomingItems.isEmpty),
                      ),
                    ),
                  ],
                ],
              ),
      ),
    );
  }

  Widget _buildColumnList({required BuildContext context, required WidgetRef ref, required List<_DashboardItem> items, required String emptyMessage}) {
    final isMobileView = PlatformX.isMobileView;

    final columnChild = items.map((item) {
      final project = item.projectId != null ? ref.read(projectListControllerProvider).firstWhereOrNull((p) => p.uniqueId == item.projectId) : null;
      final itemIconColor = project?.color ?? context.onSurfaceVariant;
      final isUnread = item.inbox == null ? false : item.inbox?.isRead != true;

      return _buildDraggable(
        ref: ref,
        context: context,
        inbox: item.inbox,
        task: item.task,
        child: PopupMenu(
          style: VisirButtonStyle(
            width: double.maxFinite,
            padding: const EdgeInsets.all(8),
            backgroundColor: context.surface.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(8),
          ),
          backgroundColor: item.inbox?.linkedMail != null || item.inbox?.linkedMessage != null ? null : Colors.transparent,
          hideShadow: item.inbox?.linkedMail != null || item.inbox?.linkedMessage != null ? false : true,
          forceShiftOffset: Offset(0, -36),
          beforePopup: () {
            if (item.inbox != null && item.inbox?.isRead != true) {
              final userId = Utils.ref.read(authControllerProvider).value?.id;
              if (userId == null) return;
              ref
                  .read(inboxAgentListControllerProvider.notifier)
                  .updateInboxConfig(
                    item.inbox?.config?.copyWith(isRead: true) ??
                        InboxConfigEntity(inboxUniqueId: item.inbox!.uniqueId, userId: userId, dateTime: DateTime.now(), updatedAt: DateTime.now(), isRead: true),
                  );
            }

            if (item.inbox != null && item.inbox!.linkedMessage != null) {
              final channels = ref.read(chatChannelListControllerProvider.select((v) => v.values.expand((e) => e.channels).toList()));
              final channel = channels.firstWhereOrNull((e) => e.id == item.inbox!.linkedMessage!.channelId);
              if (channel == null) return;
              ref
                  .read(chatConditionProvider(TabType.home).notifier)
                  .setThreadAndChannel(item.inbox!.linkedMessage!.threadId, channel, targetMessageId: item.inbox!.linkedMessage!.messageId);
            }

            if (item.inbox != null && item.inbox!.linkedMail != null) {
              final inboxMail = item.inbox!.linkedMail!;
              ref
                  .read(mailConditionProvider(TabType.home).notifier)
                  .openThread(label: CommonMailLabels.inbox.id, email: null, threadId: inboxMail.threadId, threadEmail: inboxMail.hostMail, type: inboxMail.type);
            }

            mailViewportSyncVisibleNotifier[TabType.home]!.value = false;
          },
          // doNotResizePopup: item.inbox?.linkedMail != null || item.inbox?.linkedMessage != null,
          width: item.inbox != null ? 480 : 320,
          // height: item.inbox?.linkedMail != null || item.inbox?.linkedMessage != null ? context.height * 2 / 3 : null,
          popup: item.inbox != null
              ? item.inbox!.linkedMail != null
                    ? Container(
                        // width: 720,
                        height: context.height * 4 / 5,
                        child: MailDetailScreen(
                          tabType: TabType.home,
                          taskMail: item.inbox!.linkedMail!,
                          anchorMailId: item.inbox!.linkedMail!.messageId,
                          // onKeyDown: (event) => _onKeyDown(event, justReturnResult: true),
                          // onKeyRepeat: (event) => _onKeyRepeat(event, justReturnResult: true),
                          // deleteTask: () => toggleDeleteInbox(),
                          inboxConfig: item.inbox!.config,
                          close: () => Navigator.of(Utils.mainContext).maybePop(),
                        ),
                      )
                    : item.inbox!.linkedMessage != null
                    ? Container(
                        height: context.height * 2 / 3,
                        child: ChatListScreen(
                          tabType: TabType.home,
                          taskMessage: item.inbox!.linkedMessage!,
                          // taskMessageGroupIds: item.inbox!.linkedMessage!.groupIds,
                          // onKeyDown: (event) => _onKeyDown(event, justReturnResult: true),
                          // onKeyRepeat: (event) => _onKeyRepeat(event, justReturnResult: true),
                          // deleteTask: () => toggleDeleteInbox(),
                          inboxConfig: item.inbox!.config,
                          close: () => Navigator.of(Utils.mainContext).maybePop(),
                        ),
                      )
                    : null
              : item.task != null
              ? PlatformX.isMobileView
                    ? MobileTaskEditWidget(
                        task: item.task!,
                        selectedDate: item.task!.startDate,
                        tabType: TabType.home,
                        calendarTaskEditSourceType: CalendarTaskEditSourceType.editOriginal,
                      )
                    : TaskSimpleCreateWidget(
                        tabType: TabType.home,
                        task: item.task!,
                        selectedDate: item.task!.startDate,
                        calendarTaskEditSourceType: CalendarTaskEditSourceType.editOriginal,
                      )
              : null,
          type: ContextMenuActionType.tap,
          location: PopupMenuLocation.right,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      VisirIcon(type: project?.icon ?? VisirIconType.project, size: 14, color: itemIconColor, isSelected: true),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '${project?.name ?? context.tr.no_project_suggested}${item.inbox != null ? ' · ${item.inbox?.linkedMail?.fromName ?? item.inbox?.linkedMessage?.userName ?? item.inbox?.suggestion?.sender_name}' : ''}',
                          style: context.bodyMedium?.textColor(context.onSurfaceVariant),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (item.urgency != InboxSuggestionUrgency.none) ...[
                        Builder(
                          builder: (context) {
                            // urgency 문자열을 미리 저장 (context를 사용하여 로컬라이제이션 가져오기)
                            final urgencyTitle = item.urgency.title.isNotEmpty
                                ? item.urgency.title
                                : (item.urgency == InboxSuggestionUrgency.urgent
                                      ? context.tr.ai_suggestion_urgency_urgent
                                      : item.urgency == InboxSuggestionUrgency.important
                                      ? context.tr.ai_suggestion_urgency_important
                                      : item.urgency == InboxSuggestionUrgency.action_required
                                      ? context.tr.ai_suggestion_urgency_action_required
                                      : item.urgency == InboxSuggestionUrgency.need_review
                                      ? context.tr.ai_suggestion_urgency_need_review
                                      : '');

                            // urgencyTitle이 비어있으면 태그를 표시하지 않음
                            if (urgencyTitle.isEmpty) return const SizedBox.shrink();

                            return Container(
                              margin: EdgeInsets.only(left: 6),
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: item.urgency.color.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(4)),
                              child: Text(urgencyTitle, style: context.bodySmall?.textColor(item.urgency.color), maxLines: 1),
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          if (isUnread)
                            WidgetSpan(
                              alignment: PlaceholderAlignment.middle,
                              child: Container(
                                margin: EdgeInsets.only(right: 6),
                                decoration: BoxDecoration(color: context.primary, borderRadius: BorderRadius.circular(3)),
                                width: 6,
                                height: 6,
                              ),
                            ),
                          TextSpan(text: item.title, style: context.bodyLarge?.textColor(context.onBackground)),
                        ],
                      ),
                      maxLines: 5,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (item.inbox?.linkedTask?.tasks.isNotEmpty == true)
                    IntrinsicWidth(
                      child: PopupMenu(
                        type: ContextMenuActionType.tap,
                        location: PopupMenuLocation.right,
                        backgroundColor: item.inbox?.linkedTask?.tasks.length == 1 ? Colors.transparent : null,
                        hideShadow: item.inbox?.linkedTask?.tasks.length == 1 ? true : null,
                        width: 300,
                        forceShiftOffset: item.inbox?.linkedTask?.tasks.length == 1 ? Offset(0, -28) : null,
                        borderRadius: 12,
                        mobileUseBottomSheet: true,
                        mobiileBottomSheetTitle: context.tr.linked_task_evnet,
                        popup: LinkedTasksPopup(tasks: item.inbox?.linkedTask?.tasks ?? [], tabType: TabType.home),
                        popupBuilderOnMobileView: (scr) => LinkedTasksPopup(tasks: item.inbox?.linkedTask?.tasks ?? [], tabType: TabType.home, scrollController: scr),
                        style: VisirButtonStyle(
                          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          backgroundColor: context.surfaceVariant.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(6),
                          margin: EdgeInsets.only(left: 6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            VisirIcon(type: VisirIconType.linkedTask, size: 12, color: context.onSurface, isSelected: true),
                            SizedBox(width: 4),
                            Text(item.inbox?.linkedTask?.tasks.length.toString() ?? '0', style: context.bodySmall?.textColor(context.onSurface)),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      );
    }).toList();

    if (isMobileView) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: items.isEmpty
            ? Center(child: Text(emptyMessage, style: context.bodyMedium?.textColor(context.onSurfaceVariant)))
            : ListView.separated(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (context, index) => columnChild[index],
                separatorBuilder: (context, index) => SizedBox(height: 8),
                itemCount: columnChild.length,
                padding: EdgeInsets.symmetric(vertical: 12),
                // hitTestBehavior: HitTestBehavior.deferToChild,
              ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return items.isEmpty
            ? Center(child: Text(emptyMessage, style: context.bodyMedium?.textColor(context.onSurfaceVariant)))
            : ListView.separated(
                itemBuilder: (context, index) => columnChild[index],
                separatorBuilder: (context, index) => SizedBox(height: 8),
                itemCount: columnChild.length,
                padding: EdgeInsets.symmetric(vertical: 12),
                // hitTestBehavior: HitTestBehavior.deferToChild,
              );
      },
    );
  }

  Widget _buildDraggable({required Widget child, required WidgetRef ref, required BuildContext context, required InboxEntity? inbox, TaskEntity? task}) {
    if (inbox == null && task == null) return child;
    final ratio = ref.watch(zoomRatioProvider);
    Offset lastPosition = Offset.zero; // 메서드 내부 변수로 이동 (immutable 위젯 호환)
    final displayText = inbox != null ? (inbox.suggestion?.decryptedSummary ?? inbox.decryptedTitle) : (task?.title ?? 'Untitled');
    final feedbackWidget = Material(
      color: Colors.transparent,
      child: Opacity(
        opacity: 0.5,
        child: Container(
          constraints: BoxConstraints(maxWidth: 180),
          decoration: BoxDecoration(color: context.surface, borderRadius: BorderRadius.circular(6)),
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Text(displayText, style: context.bodyLarge?.textColor(context.onBackground)),
        ),
      ),
    );

    if (PlatformX.isMobileView) {
      return InboxLongPressDraggable(
        scaleFactor: ratio,
        dragAnchorStrategy: (InboxDraggable<Object> d, BuildContext context, Offset point) {
          return Offset(d.feedbackOffset.dx, d.feedbackOffset.dy);
        },
        onDragStarted: () {
          onDragStart?.call(inbox, task);
        },
        onDragUpdate: (details) {
          onDragUpdate?.call(inbox, task, details.globalPosition / ratio);
          lastPosition = details.globalPosition;
        },
        onDragEnd: (details) {
          onDragEnd?.call(inbox, task, lastPosition / ratio);
        },
        hitTestBehavior: HitTestBehavior.opaque,
        feedback: feedbackWidget,
        child: child,
      );
    }
    return InboxDraggable(
      scaleFactor: ratio,
      dragAnchorStrategy: (InboxDraggable<Object> d, BuildContext context, Offset point) {
        return Offset(d.feedbackOffset.dx, d.feedbackOffset.dy);
      },
      onDragUpdate: (details) {
        onDragUpdate?.call(inbox, task, details.globalPosition / ratio);
        lastPosition = details.globalPosition;
      },
      onDragEnd: (details) {
        onDragEnd?.call(inbox, task, lastPosition / ratio);
      },
      hitTestBehavior: HitTestBehavior.opaque,
      feedback: feedbackWidget,
      child: child,
    );
  }

  Widget _buildUpNextSection(BuildContext context, _UpcomingItem item, List<TaskEntity> tasks, {bool isNextSchedule = false}) {
    final now = DateTime.now();
    final isToday = DateUtils.isSameDay(now, item.time);
    final timeString = isToday ? DateFormat.jm().format(item.time) : DateFormat.yMMMEd().add_jm().format(item.time);
    final durationString = item.event != null
        ? (item.event!.editedEndTime ?? item.event!.endDate).difference(item.event!.editedStartTime ?? item.event!.startDate).inMinutes.toString()
        : item.task != null
        ? item.task!.duration.inMinutes.toString()
        : '';

    final checkboxSize = context.titleMedium!.height! * context.titleMedium!.fontSize! - 2;
    final showConferenceButton = (item.task?.conferenceLink != null || item.event?.conferenceLink != null);
    final isMobileView = PlatformX.isMobileView;

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(
                    TextSpan(
                      children: [
                        WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: Container(
                            height: context.titleMedium!.height! * context.titleMedium!.fontSize!,
                            padding: EdgeInsets.only(bottom: 2),
                            child: !item.isEvent
                                ? VisirButton(
                                    type: VisirButtonAnimationType.scaleAndOpacity,
                                    style: VisirButtonStyle(
                                      cursor: WidgetStateMouseCursor.clickable,
                                      margin: EdgeInsets.only(right: 6),
                                      width: checkboxSize,
                                      height: checkboxSize,
                                      clickMargin: EdgeInsets.all(4),
                                      hoverColor: item.task?.status == TaskStatus.done ? null : item.color.withValues(alpha: 0.5),
                                      backgroundColor: item.task?.status == TaskStatus.done ? item.color : null,
                                      borderRadius: BorderRadius.circular(6),
                                      border: item.task?.status == TaskStatus.done ? null : Border.all(color: item.color, width: 2),
                                    ),
                                    child: item.task?.status == TaskStatus.done ? VisirIcon(type: VisirIconType.taskCheck, size: checkboxSize * 2 / 3, color: Colors.white) : null,
                                    onTap: () {
                                      EasyThrottle.throttle('toggleTaskStatus${item.task?.id}', Duration(milliseconds: 50), () {
                                        TaskAction.toggleStatus(
                                          task: item.task!,
                                          startAt: item.task!.editedStartTime ?? item.task!.startAt,
                                          endAt: item.task!.editedEndTime ?? item.task!.endAt,
                                          tabType: TabType.home,
                                        );
                                      });
                                    },
                                  )
                                : Container(
                                    width: 4,
                                    margin: EdgeInsets.only(right: 6),
                                    height: checkboxSize,
                                    decoration: BoxDecoration(color: item.color, borderRadius: BorderRadius.circular(2)),
                                  ),
                          ),
                        ),
                        TextSpan(text: item.title, style: context.titleMedium?.textColor(context.onBackground)),
                      ],
                    ),
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${timeString} ${durationString.isNotEmpty ? '• ${durationString} ${context.tr.daily_summary_min}' : ''} ${item.project != null ? '• ${item.project!.name}' : ''} ${item.calendar != null ? '• ${item.calendar!.name}' : ''}',
                    style: context.labelLarge?.textColor(context.inverseSurface),
                  ),
                ],
              ),
            ),
          ],
        ),

        // Show inbox summaries if linkedMail or linkedMessage exists
        _ConversationSummaryWidget(task: item.task, event: item.event),

        if (item.task != null) ...[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Builder(
                builder: (context) {
                  // Find completed tasks from the same project

                  final sameProjectCompletedTasks =
                      item.isEvent
                            ? []
                            : tasks.where((t) {
                                final currentTask = item.task!;
                                return t.projectId == currentTask.projectId &&
                                    t.projectId != null &&
                                    t.id != currentTask.id &&
                                    t.status == TaskStatus.done &&
                                    (t.updatedAt != null && currentTask.updatedAt != null ? t.updatedAt!.isBefore(currentTask.updatedAt!) : true);
                              }).toList()
                        ..sort((a, b) {
                          // Sort by updatedAt descending (most recent first)
                          final aUpdated = a.updatedAt ?? DateTime(1970);
                          final bUpdated = b.updatedAt ?? DateTime(1970);
                          return bUpdated.compareTo(aUpdated);
                        });

                  if (item.isEvent || sameProjectCompletedTasks.isEmpty) {
                    // Show description if no completed tasks
                    if (item.description != null && item.description!.isNotEmpty) {
                      return Container(
                        margin: EdgeInsets.only(top: 12),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: context.surface.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(8)),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                VisirIcon(type: VisirIconType.description, size: 16, color: context.onBackground, isSelected: true),
                                const SizedBox(width: 6),
                                Text(context.tr.description, style: context.titleMedium?.textColor(context.onBackground).textBold.appFont(context)),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(item.description!, style: context.bodyLarge?.textColor(context.onSurfaceVariant), maxLines: 5, overflow: TextOverflow.ellipsis),
                            SizedBox(height: 2),
                          ],
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }

                  // Show completed tasks from same project
                  return Container(
                    margin: EdgeInsets.only(top: 12),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: context.surface.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(8)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            VisirIcon(type: VisirIconType.task, size: 16, color: context.onBackground, isSelected: true),
                            const SizedBox(width: 6),
                            Text(context.tr.daily_summary_previously_completed_tasks, style: context.titleMedium?.textColor(context.onBackground).textBold.appFont(context)),
                          ],
                        ),
                        const SizedBox(height: 2),
                        ...sameProjectCompletedTasks.take(10).map((completedTask) {
                          return PopupMenu(
                            type: ContextMenuActionType.tap,
                            location: PopupMenuLocation.right,
                            backgroundColor: Colors.transparent,
                            hideShadow: true,
                            forceShiftOffset: Offset(0, -36),
                            popup: PlatformX.isMobileView
                                ? MobileTaskEditWidget(
                                    task: completedTask,
                                    selectedDate: completedTask.startDate,
                                    tabType: TabType.home,
                                    calendarTaskEditSourceType: CalendarTaskEditSourceType.editOriginal,
                                  )
                                : TaskSimpleCreateWidget(
                                    tabType: TabType.home,
                                    task: completedTask,
                                    selectedDate: completedTask.startDate,
                                    calendarTaskEditSourceType: CalendarTaskEditSourceType.editOriginal,
                                  ),
                            style: VisirButtonStyle(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                              backgroundColor: context.onBackground.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(8),
                              margin: EdgeInsets.only(top: 6),
                            ),
                            child: Text.rich(
                              TextSpan(text: completedTask.title ?? 'Untitled'),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: context.bodyLarge?.textColor(context.onSurfaceVariant),
                            ),
                          );
                        }),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ],
        const SizedBox(height: 8),

        if (item.isEvent && item.event != null) ...[
          if (item.event!.location != null && item.event!.location!.isNotEmpty) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                VisirIcon(type: VisirIconType.location, size: context.bodyLarge!.height! * context.bodyLarge!.fontSize!, color: context.inverseSurface, isSelected: true),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    item.event?.location ?? context.tr.daily_summary_unknown,
                    style: context.bodyLarge?.textColor(context.inverseSurface),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          if (item.event!.attendees.isNotEmpty) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                VisirIcon(type: VisirIconType.attendee, size: context.bodyLarge!.height! * context.bodyLarge!.fontSize!, color: context.inverseSurface, isSelected: true),
                const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.event!.attendees.map((a) => a.displayName ?? a.email ?? context.tr.daily_summary_unknown).join(' • '),
                        style: context.bodyLarge?.textColor(context.inverseSurface),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ],
      ],
    );

    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: VisirAppBar.height,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        isNextSchedule ? context.tr.daily_summary_next_schedule : context.tr.daily_summary_up_next,
                        style: context.titleLarge?.textBold.textColor(context.onBackground),
                      ),
                    ),
                    if (showConferenceButton)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          VisirButton(
                            style: VisirButtonStyle(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                              backgroundColor: context.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                VisirIcon(type: VisirIconType.videoCall, size: 16, color: context.onPrimary, isSelected: true),
                                const SizedBox(width: 6),
                                Text(context.tr.join_conference, style: context.bodyLarge?.textColor(context.onPrimary)),
                              ],
                            ),
                            onTap: () => Utils.launchUrlExternal(url: item.task?.conferenceLink ?? item.event?.conferenceLink ?? ''),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
          if (isMobileView) content else Expanded(child: SingleChildScrollView(child: content)),
        ],
      ),
    );
  }
}

class _UpcomingItem {
  final DateTime time;
  final String title;
  final bool isEvent;
  final EventEntity? event;
  final TaskEntity? task;
  final Color color;
  final ProjectEntity? project;
  final CalendarEntity? calendar;
  final String? description;

  _UpcomingItem({required this.time, required this.title, required this.isEvent, this.event, this.task, required this.color, this.project, this.calendar, this.description});
}

class _DashboardItem {
  final String title;
  final String? subtitle;
  final InboxSuggestionUrgency urgency;
  final VisirIconType icon;
  final String? projectId;
  final TaskEntity? task;
  final InboxEntity? inbox;

  _DashboardItem({required this.title, this.subtitle, required this.urgency, required this.icon, this.projectId, this.task, this.inbox});
}

class _ConversationSummaryWidget extends ConsumerWidget {
  final TaskEntity? task;
  final EventEntity? event;

  const _ConversationSummaryWidget({required this.task, required this.event});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Always watch the conversation summary provider - it will handle searching when no linked mail/chat exists
    final conversationSummaryAsync = ref.watch(inboxConversationSummaryProvider(task?.id, event?.uniqueId));

    // return Padding(
    //   padding: const EdgeInsets.only(bottom: 2),
    //   child: ShimmerText(
    //     text: context.tr.daily_summary_reading_previous_conversations,
    //     textSize: context.bodyLarge!.fontSize!,
    //     // textFamily: context.bodyLarge?.appFont(context).fontFamily ?? '',
    //     textColor: context.onSurfaceVariant,
    //     shiningColor: context.onSurface,
    //     letterspacing: 0,
    //   ),
    // );

    final wrapper = (Widget child) => Container(
      margin: EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: context.surface.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              VisirIcon(type: VisirIconType.brain, size: 16, color: context.onBackground, isSelected: true),
              const SizedBox(width: 6),
              Text(context.tr.daily_summary_previous_context, style: context.titleMedium?.textColor(context.onBackground).textBold.appFont(context)),
            ],
          ),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );

    return conversationSummaryAsync.when(
      data: (summary) {
        if (summary == null || summary.isEmpty) return const SizedBox.shrink();
        return wrapper(
          SelectionArea(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(summary, style: context.bodyLarge?.textColor(context.onSurfaceVariant), maxLines: 100, overflow: TextOverflow.ellipsis),
            ),
          ),
        );
      },
      loading: () => wrapper(
        Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: AnimatedTextKit(
            animatedTexts: [
              TypewriterAnimatedText(
                context.tr.daily_summary_reading_previous_conversations,
                textStyle: context.bodyLarge?.copyWith(color: context.onSurfaceVariant),
                speed: const Duration(milliseconds: 50),
              ),
            ],
            repeatForever: true,
            pause: const Duration(milliseconds: 1000),
            displayFullTextOnTap: true,
          ),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
