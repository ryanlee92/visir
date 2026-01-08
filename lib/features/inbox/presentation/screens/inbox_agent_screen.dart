import 'dart:convert';
import 'dart:math';
import 'dart:ui';

import 'package:Visir/config/providers.dart';
import 'package:Visir/features/auth/application/auth_controller.dart';
import 'package:Visir/features/calendar/application/calendar_event_list_controller.dart';
import 'package:Visir/features/calendar/providers.dart';
import 'package:Visir/features/common/presentation/utils/extensions/platform_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';

import 'package:Visir/features/common/presentation/widgets/bottom_sheet_scroll_physics.dart';
import 'package:Visir/features/common/presentation/widgets/desktop_scaffold.dart';
import 'package:Visir/features/common/presentation/widgets/mesh_loading_background.dart';
import 'package:Visir/features/common/presentation/widgets/mobile_scaffold.dart';
import 'package:Visir/features/common/presentation/widgets/popup_menu.dart';
import 'package:Visir/features/common/presentation/widgets/wave_refresh_footer.dart';
import 'package:Visir/features/common/presentation/widgets/wave_refresh_header.dart';
import 'package:Visir/features/common/provider.dart' hide TextScaler;
import 'package:desktop_drop/desktop_drop.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:Visir/features/inbox/application/agent_action_controller.dart';
import 'package:Visir/features/inbox/application/inbox_agent_list_controller.dart';
import 'package:Visir/features/inbox/application/inbox_agent_weather_controller.dart';
import 'package:Visir/features/inbox/application/inbox_controller.dart';
import 'package:Visir/features/inbox/application/mcp_function_executor.dart';
import 'package:Visir/features/inbox/domain/entities/inbox_entity.dart';
import 'package:Visir/features/inbox/domain/entities/inbox_suggestion_entity.dart';
import 'package:Visir/features/inbox/presentation/widgets/agent_action_messages_widget.dart';
import 'package:Visir/features/inbox/presentation/widgets/agent_input_field.dart';
import 'package:Visir/features/inbox/presentation/widgets/inbox_action_suggestions_widget.dart';
import 'package:Visir/features/inbox/utils/agent_tag_controller.dart';
import 'package:Visir/features/inbox/presentation/widgets/daily_summary_widget.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:Visir/features/inbox/presentation/widgets/project_summary_cards_widget.dart';
import 'package:Visir/features/calendar/domain/entities/calendar_entity.dart';
import 'package:Visir/features/calendar/domain/entities/event_entity.dart';
import 'package:Visir/features/preference/application/local_pref_controller.dart';
import 'package:Visir/features/preference/domain/entities/oauth_entity.dart';
import 'package:Visir/features/task/application/calendar_task_list_controller.dart';
import 'package:Visir/features/task/application/project_list_controller.dart';

import 'package:Visir/features/task/domain/entities/project_entity.dart';
import 'package:Visir/features/task/domain/entities/task_entity.dart';
import 'package:Visir/features/task/presentation/widgets/timeblock_drop_widget.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_resizable_container/flutter_resizable_container.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons_full.dart';
import 'package:intl/intl.dart';
import 'package:shimmer_text/shimmer_text.dart';
import 'package:super_clipboard/super_clipboard.dart';
import 'package:super_drag_and_drop/super_drag_and_drop.dart';

class InboxAgentScreen extends ConsumerStatefulWidget {
  final void Function(InboxEntity inbox)? onDragStart;
  final void Function(InboxEntity inbox, Offset offset)? onDragUpdate;
  final void Function(InboxEntity inbox, Offset offset)? onDragEnd;

  const InboxAgentScreen({super.key, this.onDragStart, this.onDragUpdate, this.onDragEnd});

  @override
  ConsumerState<InboxAgentScreen> createState() => _InboxAgentScreenState();
}

class _InboxAgentScreenState extends ConsumerState<InboxAgentScreen> {
  TabType get tabType => TabType.home;

  GlobalKey<TimeblockDropWidgetState> timeblockDropWidgetKey = GlobalKey<TimeblockDropWidgetState>();
  GlobalKey projectSummaryCardsWidgetKey = GlobalKey();

  ResizableController resizableController = ResizableController();
  ProjectEntity? _selectedProject;

  AgentTagController? _messageController;
  FocusNode? _focusNode;

  double _agentInputFieldHeight = 0;
  final GlobalKey _agentInputFieldKey = GlobalKey();
  final GlobalKey<AgentInputFieldState> _agentInputFieldStateKey = GlobalKey<AgentInputFieldState>();
  RefreshController _refreshController = RefreshController();

  bool onFileEntered = false;

  String getDateString({required DateTime date, bool? forceDate}) {
    if (DateUtils.isSameDay(DateTime.now(), date) && forceDate != true) return DateFormat.jm().format(date);
    if (DateUtils.isSameDay(DateTime.now(), date) && forceDate == true) return context.tr.today;
    if (DateUtils.isSameDay(DateTime.now().subtract(Duration(days: 1)), date)) return context.tr.yesterday;
    if (DateUtils.isSameDay(DateTime.now().add(Duration(days: 1)), date)) return context.tr.tomorrow;
    if (date.isBefore(DateUtils.dateOnly(DateTime.now().add(Duration(days: 7)))) && date.isAfter(DateUtils.dateOnly(DateTime.now()))) return DateFormat.E().format(date);
    if (date.year == DateTime.now().year) return DateFormat.MMMd().format(date);
    return DateFormat.yMMMd().format(date);
  }

  @override
  void initState() {
    resizableController.addListener(() {
      setState(() {});
    });
    _messageController = AgentTagController();
    _focusNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    resizableController.dispose();
    _messageController?.dispose();
    _focusNode?.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  /// MCP 함수를 직접 실행하는 헬퍼 함수
  Future<void> _executeMcpFunctionDirectly({
    required WidgetRef ref,
    required AgentActionController controller,
    required String mcpFunctionName,
    TaskEntity? task,
    EventEntity? event,
    InboxEntity? inbox,
    required List<TaskEntity> taggedTasks,
    required List<EventEntity> taggedEvents,
    required List<InboxEntity> taggedInboxes,
    required List<InboxEntity> filteredInboxes,
  }) async {
    try {
      print('[executeMcpFunctionDirectly] Executing function: $mcpFunctionName');

      final executor = McpFunctionExecutor();
      Map<String, dynamic> functionArgs = {};

      // 함수 인자 준비
      if (task != null) {
        functionArgs['taskId'] = task.id;
      }
      if (event != null) {
        functionArgs['eventId'] = event.eventId;
      }
      if (inbox != null) {
        functionArgs['inboxId'] = inbox.id;
      }

      // 조합 액션 처리
      if (mcpFunctionName == 'markDoneAndReply' && task != null) {
        // markDoneAndReply는 두 개의 함수를 순차 호출
        print('[executeMcpFunctionDirectly] Executing markDoneAndReply: toggleTaskStatus + reply');

        // 첫 번째: toggleTaskStatus
        final toggleResult = await executor.executeFunction(
          'toggleTaskStatus',
          {'taskId': task.id, 'status': 'done'},
          tabType: tabType,
          availableTasks: taggedTasks,
          availableEvents: taggedEvents,
          availableInboxes: filteredInboxes,
        );
        print('[executeMcpFunctionDirectly] toggleTaskStatus result: $toggleResult');

        // 두 번째: replyMail 또는 replyMessage
        String replyFunction = task.linkedMails.isNotEmpty ? 'replyMail' : (task.linkedMessages.isNotEmpty ? 'replyMessage' : '');
        if (replyFunction.isNotEmpty) {
          String replyId = task.linkedMails.isNotEmpty ? task.linkedMails.first.threadId : task.linkedMessages.first.channelId;
          Map<String, dynamic> replyArgs = task.linkedMails.isNotEmpty ? {'threadId': replyId} : {'channelId': replyId};

          final replyResult = await executor.executeFunction(
            replyFunction,
            replyArgs,
            tabType: tabType,
            availableTasks: taggedTasks,
            availableEvents: taggedEvents,
            availableInboxes: filteredInboxes,
          );
          print('[executeMcpFunctionDirectly] $replyFunction result: $replyResult');

          // 결과 메시지 추가
          final resultMessage = toggleResult['success'] == true && replyResult['success'] == true ? (replyResult['message'] as String? ?? '완료되었습니다.') : '오류가 발생했습니다.';

          final currentState = ref.read(agentActionControllerProvider);
          final updatedMessages = [...currentState.messages, AgentActionMessage(role: 'assistant', content: resultMessage)];
          ref.read(agentActionControllerProvider.notifier).state = currentState.copyWith(messages: updatedMessages, isLoading: false);
        } else {
          // reply 함수가 없으면 toggleTaskStatus 결과만 표시
          final resultMessage = toggleResult['success'] == true ? (toggleResult['message'] as String? ?? '완료되었습니다.') : (toggleResult['error'] as String? ?? '오류가 발생했습니다.');

          final currentState = ref.read(agentActionControllerProvider);
          final updatedMessages = [...currentState.messages, AgentActionMessage(role: 'assistant', content: resultMessage)];
          ref.read(agentActionControllerProvider.notifier).state = currentState.copyWith(messages: updatedMessages, isLoading: false);
        }
        return;
      } else if (mcpFunctionName == 'convertBraindumpToTask' && task != null) {
        // convertBraindumpToTask는 updateTask로 status를 none으로 변경
        print('[executeMcpFunctionDirectly] Executing convertBraindumpToTask: updateTask');
        functionArgs = {'taskId': task.id, 'status': 'none'};
        mcpFunctionName = 'updateTask';
      }

      print('[executeMcpFunctionDirectly] Executing function: $mcpFunctionName with args: $functionArgs');

      // MCP 함수 실행
      final result = await executor.executeFunction(
        mcpFunctionName,
        functionArgs,
        tabType: tabType,
        availableTasks: taggedTasks,
        availableEvents: taggedEvents,
        availableInboxes: filteredInboxes,
      );

      print('[executeMcpFunctionDirectly] Function result: $result');

      // 결과 메시지 추가
      String resultMessage;
      if (result['success'] == true) {
        // result['result']가 Map인 경우 (예: getPreviousContext의 경우)
        if (result['result'] is Map<String, dynamic>) {
          final resultMap = result['result'] as Map<String, dynamic>;
          // summary 필드가 있으면 사용, 없으면 전체를 JSON으로 변환
          resultMessage = resultMap['summary'] as String? ?? result['message'] as String? ?? jsonEncode(resultMap);
        } else {
          // result['result']가 String이거나 다른 타입인 경우
          resultMessage = result['message'] as String? ?? result['result']?.toString() ?? '완료되었습니다.';
        }
      } else {
        resultMessage = result['error'] as String? ?? '오류가 발생했습니다.';
      }

      print('[executeMcpFunctionDirectly] Result message: $resultMessage');
      print('[executeMcpFunctionDirectly] Result message length: ${resultMessage.length}');

      // State 업데이트를 위해 notifier를 통해 업데이트
      final notifier = ref.read(agentActionControllerProvider.notifier);
      final currentState = ref.read(agentActionControllerProvider);
      print('[executeMcpFunctionDirectly] Current messages count: ${currentState.messages.length}');

      final updatedMessages = [...currentState.messages, AgentActionMessage(role: 'assistant', content: resultMessage)];
      print('[executeMcpFunctionDirectly] Updated messages count: ${updatedMessages.length}');

      // State를 직접 업데이트 (동기적으로)
      notifier.state = currentState.copyWith(messages: updatedMessages, isLoading: false);

      // 업데이트 확인
      final updatedState = ref.read(agentActionControllerProvider);
      print('[executeMcpFunctionDirectly] After update messages count: ${updatedState.messages.length}');
      if (updatedState.messages.isNotEmpty) {
        final lastMessage = updatedState.messages.last.content;
        print('[executeMcpFunctionDirectly] Last message content: ${lastMessage.length > 100 ? lastMessage.substring(0, 100) : lastMessage}...');
      }
    } catch (e, stackTrace) {
      print('[executeMcpFunctionDirectly] Error: $e');
      print('[executeMcpFunctionDirectly] StackTrace: $stackTrace');

      final currentState = ref.read(agentActionControllerProvider);
      final updatedMessages = [...currentState.messages, AgentActionMessage(role: 'assistant', content: '오류가 발생했습니다: ${e.toString()}')];
      ref.read(agentActionControllerProvider.notifier).state = currentState.copyWith(messages: updatedMessages, isLoading: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final weatherData = ref.watch(inboxAgentWeatherControllerProvider);
    final inboxes = ref.watch(inboxControllerProvider.select((v) => v?.inboxes ?? []));

    final calendarHide = ref.watch(calendarHideProvider(TabType.home));
    final projectHide = ref.watch(projectHideProvider(TabType.home));
    final calendarOAuths = ref.watch(localPrefControllerProvider.select((v) => v.value?.calendarOAuths ?? []));

    final events = ref.watch(calendarEventListControllerProvider(tabType: tabType)).eventsOnView.where((e) {
      return !calendarHide.contains(e.calendarUniqueId) && calendarOAuths.any((o) => o.email == e.calendar.email && o.type.calendarType == e.calendar.type) == true;
    }).toList();

    final tasks = ref.watch(
      calendarTaskListControllerProvider(
        tabType: tabType,
      ).select((v) => v.tasksOnView.where((e) => !projectHide.contains(e.projectId) && !e.isEventDummyTask && !e.isCancelled && !e.isOriginalRecurrenceTask).toList()),
    );

    final userName = ref.watch(authControllerProvider.select((v) => v.value?.name));

    final projects = ref.watch(projectListControllerProvider).sortedProjectWithDepth;

    final projectMap = [
      ...projects.map((p) {
        final projectInboxes = inboxes.where((e) => e.suggestion?.project_id != null && p.project.isPointedProjectId(e.suggestion?.project_id)).toList();
        return MapEntry(p.project.uniqueId, {'project': p.project, 'inboxes': projectInboxes});
      }).toList(),
      MapEntry(null, {'project': null, 'inboxes': inboxes.where((e) => e.suggestion != null && e.suggestion?.project_id == null).toList()}),
    ];

    projectMap.sort((b, a) {
      final aInboxes = a.value['inboxes'] as List<InboxEntity>;
      final bInboxes = b.value['inboxes'] as List<InboxEntity>;

      final aUrgentInboxes = aInboxes.where((i) => i.suggestion?.urgency == InboxSuggestionUrgency.urgent).toList();
      final bUrgentInboxes = bInboxes.where((i) => i.suggestion?.urgency == InboxSuggestionUrgency.urgent).toList();
      final urgentCompare = aUrgentInboxes.length.compareTo(bUrgentInboxes.length);
      if (urgentCompare != 0) return urgentCompare;

      final aImportantInboxes = aInboxes.where((i) => i.suggestion?.urgency == InboxSuggestionUrgency.important).toList();
      final bImportantInboxes = bInboxes.where((i) => i.suggestion?.urgency == InboxSuggestionUrgency.important).toList();
      final importantCompare = aImportantInboxes.length.compareTo(bImportantInboxes.length);
      if (importantCompare != 0) return importantCompare;

      final aNormalInboxes = aInboxes.where((i) => i.suggestion?.urgency == InboxSuggestionUrgency.action_required).toList();
      final bNormalInboxes = bInboxes.where((i) => i.suggestion?.urgency == InboxSuggestionUrgency.action_required).toList();
      final normalCompare = aNormalInboxes.length.compareTo(bNormalInboxes.length);
      if (normalCompare != 0) return normalCompare;

      final aLowInboxes = aInboxes.where((i) => i.suggestion?.urgency == InboxSuggestionUrgency.need_review).toList();
      final bLowInboxes = bInboxes.where((i) => i.suggestion?.urgency == InboxSuggestionUrgency.need_review).toList();
      final lowCompare = aLowInboxes.length.compareTo(bLowInboxes.length);
      if (lowCompare != 0) return lowCompare;

      return aInboxes.length.compareTo(bInboxes.length);
    });

    final actionRequiredCount = inboxes
        .where(
          (e) =>
              e.suggestion?.urgency == InboxSuggestionUrgency.action_required ||
              e.suggestion?.urgency == InboxSuggestionUrgency.important ||
              e.suggestion?.urgency == InboxSuggestionUrgency.urgent,
        )
        .length;

    // Filter events and tasks for last 24 hours
    final now = DateTime.now();
    final last24HoursStart = now.subtract(const Duration(hours: 24));

    // Count events: EventEntity list (filtered by calendarHide) + TaskEntity with isEvent == true (filtered by projectHide)
    final last24HoursEventEntitiesCount = events
        .where((e) => !calendarHide.contains(e.calendarUniqueId) && e.startDate.isAfter(last24HoursStart) && !e.startDate.isAfter(now))
        .length;

    final last24HoursEventTasksCount = tasks
        .where(
          (t) =>
              !t.isCancelled &&
              !t.isOriginalRecurrenceTask &&
              !t.isEventDummyTask &&
              t.isEvent &&
              t.isDone != true &&
              (t.startAt ?? t.startDate).isAfter(last24HoursStart) &&
              !(t.startAt ?? t.startDate).isAfter(now),
        )
        .length;

    final last24HoursEventsCount = last24HoursEventEntitiesCount + last24HoursEventTasksCount;

    // Count tasks: TaskEntity with isEvent == false (filtered by projectHide)
    final last24HoursTasksCount = tasks
        .where(
          (t) =>
              !t.isCancelled &&
              !t.isOriginalRecurrenceTask &&
              !t.isEventDummyTask &&
              !t.isEvent &&
              t.isDone != true &&
              (t.startAt ?? t.startDate).isAfter(last24HoursStart) &&
              !(t.startAt ?? t.startDate).isAfter(now),
        )
        .length;

    // Get actual fetch duration from inboxAgentListController
    final inboxAgentController = ref.read(inboxAgentListControllerProvider.notifier);
    final fetchDuration = inboxAgentController.fetchDurationForDisplay;
    final hours = fetchDuration.inHours;
    final days = fetchDuration.inDays;

    // 이틀(48시간)까지는 시간으로, 나머지는 일로 표시
    String fetchDurationString;
    if (hours < 48) {
      if (hours == 0) {
        final minutes = fetchDuration.inMinutes;
        fetchDurationString = minutes == 1 ? context.tr.reminder_minute : context.tr.reminder_minutes(minutes);
      } else if (hours == 1) {
        fetchDurationString = context.tr.reminder_hour;
      } else {
        fetchDurationString = context.tr.reminder_hours(hours);
      }
    } else {
      // 일 단위로 표시
      if (days == 1) {
        fetchDurationString = context.tr.duration_day(1);
      } else {
        fetchDurationString = context.tr.duration_days(days);
      }
    }

    String summaryText;
    if (ref.watch(shouldUseMockDataProvider)) {
      summaryText = 'You have 12 items pending review across your projects.';
    } else if (actionRequiredCount > 0) {
      summaryText = context.tr.agentic_home_summary_action_required_dynamic(actionRequiredCount, fetchDurationString);
    } else if (last24HoursEventsCount > 0 || last24HoursTasksCount > 0) {
      if (last24HoursEventsCount > 0 && last24HoursTasksCount > 0) {
        summaryText = context.tr.agentic_home_summary_events_dynamic(last24HoursEventsCount, last24HoursTasksCount, fetchDurationString);
      } else if (last24HoursEventsCount > 0) {
        summaryText = context.tr.agentic_home_summary_only_events_dynamic(last24HoursEventsCount, fetchDurationString);
      } else {
        summaryText = context.tr.agentic_home_summary_only_tasks_dynamic(last24HoursTasksCount, fetchDurationString);
      }
    } else {
      summaryText = context.tr.agentic_home_summary_all_clear;
    }

    ref.watch(loadingStatusProvider);
    final _isSuggestionLoading = ref.read(loadingStatusProvider.notifier).isLoading(TabType.home);

    // Calculate up next item (same logic as daily_summary_widget)
    final nowForUpNext = DateTime.now();
    final today = DateTime(nowForUpNext.year, nowForUpNext.month, nowForUpNext.day);
    final tomorrow = today.add(const Duration(days: 1));

    final baseFilteredTasks = tasks.where((t) => !t.isCancelled && !t.isOriginalRecurrenceTask && !t.isEventDummyTask).toList();
    final relevantIds = _selectedProject == null
        ? <String>[]
        : () {
            final project = projects.firstWhereOrNull((p) => p.project.uniqueId == _selectedProject!.uniqueId);
            if (project == null) return [_selectedProject!.uniqueId];

            final allIds = {_selectedProject!.uniqueId};

            Set<String> findDescendants(String targetParentId) {
              final parentNode = projects.firstWhereOrNull((p) => p.project.uniqueId == targetParentId);
              Iterable<String> childrenIds;

              if (parentNode != null) {
                childrenIds = projects.where((p) => parentNode.project.isParent(p.project.parentId)).map((p) => p.project.uniqueId);
              } else {
                childrenIds = projects.where((p) => p.project.parentId == targetParentId).map((p) => p.project.uniqueId);
              }

              if (childrenIds.isEmpty) return {};

              final descendants = <String>{...childrenIds};
              for (final childId in childrenIds) {
                descendants.addAll(findDescendants(childId));
              }
              return descendants;
            }

            allIds.addAll(findDescendants(_selectedProject!.uniqueId));
            return allIds.toList();
          }();

    final filteredTasks = _selectedProject == null
        ? baseFilteredTasks
        : baseFilteredTasks.where((t) => relevantIds.contains(t.projectId) || (t.projectId == null && _selectedProject == null)).toList();

    final todayTasks = filteredTasks.where((t) => t.startDate.isAfter(today) && t.startDate.isBefore(tomorrow) && t.isDone != true && t.isAllDay != true).toList();
    final todayEvents = events.where((e) => e.startDate.isAfter(today) && e.startDate.isBefore(tomorrow) && e.isAllDay != true).toList();

    // Convert EventEntity to TaskEntity to get linkedMails and linkedMessages
    final eventToTaskMap = <String, TaskEntity>{};
    for (final task in tasks) {
      if (task.linkedEvent != null) {
        eventToTaskMap[task.linkedEvent!.eventId] = task;
      }
    }

    // Get next upcoming item
    final allUpcomingItems = <_UpcomingItem>[
      ...todayEvents.map((e) {
        final linkedTask = eventToTaskMap[e.eventId];
        return _UpcomingItem(
          time: e.startDate,
          title: e.title ?? 'Untitled',
          isEvent: true,
          event: e,
          task: linkedTask,
          color: e.backgroundColor,
          calendar: e.calendar,
          description: e.description,
        );
      }),
      ...todayTasks
          .where((t) => !t.isEventDummyTask && !t.isDone && !t.isCancelled)
          .map(
            (t) => _UpcomingItem(
              time: t.startAt ?? t.startDate,
              title: t.title ?? 'Untitled',
              isEvent: false,
              task: t,
              color: projects.where((p) => p.project.isPointedProject(t)).firstOrNull?.project.color ?? context.surface,
              project: projects.where((p) => p.project.isPointedProject(t)).firstOrNull?.project,
              calendar: t.linkedEvent?.calendar,
              description: t.description,
            ),
          ),
    ].where((item) => item.time.isAfter(nowForUpNext)).toList()..sort((a, b) => a.time.compareTo(b.time));

    // If no items today, find next schedule
    final nextItem = allUpcomingItems.isNotEmpty
        ? allUpcomingItems.first
        : () {
            final futureEvents = events.where((e) => e.startDate.isAfter(nowForUpNext) && e.isAllDay != true).toList();
            final futureTasks = tasks
                .where((t) => t.isEventDummyTask && !t.isDone && !t.isCancelled && t.isAllDay != true && (t.startAt?.isAfter(nowForUpNext) ?? t.startDate.isAfter(nowForUpNext)))
                .toList();
            final futureItems = <_UpcomingItem>[
              ...futureEvents.map((e) {
                final linkedTask = eventToTaskMap[e.eventId];
                return _UpcomingItem(
                  time: e.startDate,
                  title: e.title ?? 'Untitled',
                  isEvent: true,
                  event: e,
                  task: linkedTask,
                  color: e.backgroundColor,
                  calendar: e.calendar,
                  description: e.description,
                );
              }),
              ...futureTasks.map(
                (t) => _UpcomingItem(
                  time: t.startAt ?? t.startDate,
                  title: t.title ?? 'Untitled',
                  isEvent: false,
                  task: t,
                  color: projects.where((p) => p.project.isPointedProject(t)).firstOrNull?.project.color ?? context.surface,
                  project: projects.where((p) => p.project.isPointedProject(t)).firstOrNull?.project,
                  calendar: t.linkedEvent?.calendar,
                  description: t.description,
                ),
              ),
            ]..sort((a, b) => a.time.compareTo(b.time));
            return futureItems.isNotEmpty ? futureItems.first : null;
          }();

    // Filter inboxes for action suggestions
    final filteredInboxes = _selectedProject == null
        ? inboxes
              .where(
                (i) =>
                    i.suggestion != null &&
                    (i.suggestion!.urgency == InboxSuggestionUrgency.urgent ||
                        i.suggestion!.urgency == InboxSuggestionUrgency.important ||
                        i.suggestion!.urgency == InboxSuggestionUrgency.action_required),
              )
              .toList()
        : inboxes
              .where(
                (i) =>
                    i.suggestion != null &&
                    relevantIds.contains(i.suggestion!.project_id) &&
                    (i.suggestion!.urgency == InboxSuggestionUrgency.urgent ||
                        i.suggestion!.urgency == InboxSuggestionUrgency.important ||
                        i.suggestion!.urgency == InboxSuggestionUrgency.action_required),
              )
              .toList();

    final isMobileView = PlatformX.isMobileView;
    final headerSectionHeight = isMobileView ? 288.0 : 372.0;
    final headerPadding = isMobileView ? EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 16) : EdgeInsets.only(top: 24, left: 36, right: 28, bottom: 28);
    final projectCardsTop = isMobileView ? 100.0 : 140.0;
    final cardMargin = isMobileView ? EdgeInsets.all(8) : EdgeInsets.only(top: 8, bottom: 8, left: 8, right: 2);
    final cardRadius = isMobileView ? 12.0 : DesktopScaffold.cardRadius;

    if (isMobileView) {
      return Utils.buildDropTarget(
        onDropEnter: () {
          onFileEntered = true;
          setState(() {});
        },
        onDropLeave: () {
          onFileEntered = false;
          setState(() {});
        },
        onDrop: (files) {
          _agentInputFieldStateKey.currentState?.uploadFiles(files: files);
          onFileEntered = false;
          setState(() {});
        },
        child: Material(
          color: Colors.transparent,
          child: Stack(
            children: [
              Container(
                height: headerSectionHeight,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      child: weatherData != null ? Image.asset(weatherData.condition.assets, fit: BoxFit.cover) : Image.asset(WeatherCondition.clear.assets, fit: BoxFit.cover),
                    ),
                    if (weatherData == null)
                      BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                        child: Container(color: context.background.withValues(alpha: 0.9)),
                      ),
                    if (weatherData != null) Container(color: context.background.withValues(alpha: 0.65)),
                    MediaQuery(
                      data: context.mediaQuery.copyWith(textScaler: TextScaler.linear(1)),
                      child: Column(
                        children: [
                          Container(
                            padding: headerPadding,
                            child: Material(
                              clipBehavior: Clip.none,
                              color: Colors.transparent,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          '${context.tr.agentic_home_hi}${userName == null ? '' : userName.split(' ').first}',
                                          style: context.headlineLarge?.textColor(context.onBackground).textBold,
                                        ),
                                      ),
                                      if (weatherData != null)
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Row(
                                              children: [
                                                Text(weatherData.temperature.round().toString(), style: context.titleLarge?.textColor(context.onBackground).appFont(context)),
                                                HugeIcon(
                                                  icon: weatherData.useFahrenheit ? HugeIcons.solidRoundedFahrenheit : HugeIcons.solidRoundedCelsius,
                                                  size: context.textScaler.scale(context.titleLarge!.fontSize!),
                                                  color: context.onBackground,
                                                ),
                                              ],
                                            ),
                                            Text(weatherData.name, style: context.bodySmall?.textColor(context.inverseSurface)),
                                          ],
                                        ),
                                    ],
                                  ),
                                  SizedBox(height: 6),
                                  if (!_isSuggestionLoading)
                                    Text(summaryText, style: context.titleMedium?.textColor(context.surfaceTint), maxLines: 2, overflow: TextOverflow.ellipsis),
                                  if (_isSuggestionLoading)
                                    ShimmerText(
                                      text: context.tr.inbox_agent_loading_dynamic(fetchDurationString),
                                      textSize: context.titleMedium!.fontSize!,
                                      textFamily: context.titleMedium?.appFont(context).fontFamily ?? '',
                                      textColor: context.surfaceTint,
                                      shiningColor: context.inverseSurface,
                                      letterspacing: 0,
                                    ),
                                ],
                              ),
                            ),
                          ),
                          ProjectSummaryCardsWidget(
                            key: projectSummaryCardsWidgetKey,
                            projectMap: projectMap,
                            projectHide: projectHide,
                            resizableController: resizableController,
                            onProjectSelected: (project) {
                              setState(() {
                                _selectedProject = project;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Positioned.fill(
                top: headerSectionHeight - 20,
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: context.background,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                  ),
                ),
              ),
              Positioned.fill(
                child: ValueListenableBuilder(
                  valueListenable: MobileScaffold.largeTabBar,
                  builder: (context, largeTabBar, child) {
                    final tabMargin = (largeTabBar ? MobileScaffold.bottomPaddingForLargeTabBar : MobileScaffold.bottomPaddingForSmallTabBar);
                    return LayoutBuilder(
                      builder: (context, constraints) {
                        return SmartRefresher(
                          controller: _refreshController,
                          enablePullDown: !_isSuggestionLoading,
                          enablePullUp: false,
                          hitTestBehavior: HitTestBehavior.translucent,
                          header: WaveRefreshHeader(),
                          footer: WaveRefreshFooter(),
                          onRefresh: () async {
                            try {
                              await ref.read(inboxControllerProvider.notifier).refresh();
                              _refreshController.refreshCompleted();
                            } catch (e) {
                              _refreshController.refreshFailed();
                            }
                          },
                          physics: BottomSheetScrollPhysics(),
                          child: SingleChildScrollView(
                            hitTestBehavior: HitTestBehavior.translucent,
                            physics: NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.only(top: headerSectionHeight - 20, bottom: (_agentInputFieldHeight > 0 ? _agentInputFieldHeight + 8 : 0) + tabMargin + 8),
                            child: Container(
                              decoration: BoxDecoration(
                                color: context.background,
                                borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                              ),
                              constraints: BoxConstraints(minHeight: constraints.maxHeight - headerSectionHeight - 20 + context.padding.bottom),
                              child: DailySummaryWidget(
                                events: events,
                                tasks: tasks,
                                inboxes: inboxes,
                                selectedProject: _selectedProject,
                                projects: projects,
                                userName: userName,
                                onDragStart: (inbox, task) {
                                  _agentInputFieldStateKey.currentState?.handleDragStart(inbox, task, Offset.zero);
                                  if (inbox == null) return;
                                  widget.onDragStart?.call(inbox);
                                },
                                onDragUpdate: (inbox, task, offset) {
                                  _agentInputFieldStateKey.currentState?.handleDragUpdate(inbox, task, offset);
                                  if (inbox == null) return;
                                  widget.onDragUpdate?.call(inbox, offset);
                                },
                                onDragEnd: (inbox, task, offset) {
                                  _agentInputFieldStateKey.currentState?.handleDragEnd(inbox, task, offset);
                                  if (inbox == null) return;
                                  widget.onDragEnd?.call(inbox, offset);
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              ValueListenableBuilder(
                valueListenable: MobileScaffold.largeTabBar,
                builder: (context, largeTabBar, child) {
                  final tabMargin = (largeTabBar ? MobileScaffold.bottomPaddingForLargeTabBar : MobileScaffold.bottomPaddingForSmallTabBar);
                  return Stack(
                    children: [
                      // Positioned(
                      //   bottom: 0,
                      //   left: 0,
                      //   right: 0,
                      //   height: tabMargin + 8,
                      //   child: Container(color: context.background),
                      // ),
                      AnimatedPositioned(
                        duration: Duration(milliseconds: 250),
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          color: context.background,
                          padding: EdgeInsets.only(bottom: _agentInputFieldHeight),
                          child: AgentActionMessagesWidget(maxHeight: (context.height / ref.read(zoomRatioProvider) - max(context.padding.top - 8, 20)) - _agentInputFieldHeight),
                        ),
                      ),
                      AnimatedPositioned(
                        duration: Duration(milliseconds: 250),
                        bottom: 0,
                        left: 8,
                        right: 8,
                        child: NotificationListener<SizeChangedLayoutNotification>(
                          onNotification: (notification) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              final RenderBox? renderBox = _agentInputFieldKey.currentContext?.findRenderObject() as RenderBox?;
                              if (renderBox != null) {
                                final height = renderBox.size.height;
                                if (height != _agentInputFieldHeight) {
                                  setState(() {
                                    _agentInputFieldHeight = height;
                                  });
                                }
                              }
                            });
                            return true;
                          },
                          child: SizeChangedLayoutNotifier(
                            child: Container(
                              key: _agentInputFieldKey,
                              padding: EdgeInsets.only(bottom: max(MediaQuery.of(context).viewInsets.bottom / ref.read(zoomRatioProvider) + 8, tabMargin + 8)),
                              child: AgentInputField(
                                key: _agentInputFieldStateKey,
                                fieldKey: _agentInputFieldStateKey,
                                messageController: _messageController,
                                focusNode: _focusNode,
                                onPressEscape: () => true,
                                tabType: tabType,
                                initialProject: _selectedProject,
                                inboxes: filteredInboxes,
                                upNextTask: nextItem?.task,
                                upNextEvent: nextItem?.event,
                                onProjectChanged: (p) {
                                  setState(() {
                                    _selectedProject = p;
                                  });
                                },
                                onActionTap: (mcpFunctionName, {inbox, task, event}) {
                                  final actionType = mcpFunctionToAgentActionType(mcpFunctionName);
                                  if (actionType != null) {
                                    ref.read(agentActionControllerProvider.notifier).startAction(actionType: actionType, inbox: inbox, task: task, event: event);
                                  } else {
                                    // actionType이 null인 경우 (새로운 함수들: getPreviousContext, convertBraindumpToTask, markDoneAndReply 등)
                                    // 메시지는 로컬에만 추가하고, 실제 액션은 바로 MCP 함수 실행
                                    final controller = ref.read(agentActionControllerProvider.notifier);
                                    final taggedTasks = List<TaskEntity>.from(_messageController?.taggedTasks ?? []);
                                    final taggedEvents = List<EventEntity>.from(_messageController?.taggedEvents ?? []);
                                    final taggedInboxes = List<InboxEntity>.from(_messageController?.taggedInboxes ?? []);

                                    // 드롭된 아이템을 태그된 아이템에 추가
                                    if (task != null && !taggedTasks.any((t) => t.id == task.id)) {
                                      taggedTasks.add(task);
                                    }
                                    if (event != null && !taggedEvents.any((e) => e.eventId == event.eventId)) {
                                      taggedEvents.add(event);
                                    }
                                    if (inbox != null && !taggedInboxes.any((i) => i.id == inbox.id)) {
                                      taggedInboxes.add(inbox);
                                    }

                                    // 액션 타이틀 가져오기
                                    String actionTitle = mcpFunctionName;
                                    switch (mcpFunctionName) {
                                      case 'getPreviousContext':
                                        actionTitle = 'View Previous Context';
                                        break;
                                      case 'convertBraindumpToTask':
                                        actionTitle = 'Convert to Task';
                                        break;
                                      case 'markDoneAndReply':
                                        actionTitle = 'Mark Done & Reply';
                                        break;
                                      case 'reschedule':
                                        actionTitle = 'Reschedule';
                                        break;
                                      case 'setDueDate':
                                        actionTitle = 'Set Due Date';
                                        break;
                                      case 'setRecurrence':
                                        actionTitle = 'Edit Recurrence';
                                        break;
                                      case 'removeRecurrence':
                                        actionTitle = 'Remove Recurrence';
                                        break;
                                      case 'responseCalendarInvitation':
                                        actionTitle = 'Respond to Invitation';
                                        break;
                                    }

                                    // 메시지를 로컬에만 추가 (태그된 아이템 포함)
                                    final buffer = StringBuffer();
                                    buffer.write(actionTitle);

                                    // 태그된 항목들을 HTML 태그로 추가
                                    for (final task in taggedTasks) {
                                      final taskJson = jsonEncode(task.toJson(local: true));
                                      buffer.write('<tagged_task>$taskJson</tagged_task>');
                                    }
                                    for (final event in taggedEvents) {
                                      final eventJson = jsonEncode({
                                        'id': event.eventId,
                                        'title': event.title,
                                        'description': event.description,
                                        'calendar_id': event.calendar.uniqueId,
                                        'start_at': event.startDate.toIso8601String(),
                                        'end_at': event.endDate.toIso8601String(),
                                        'location': event.location,
                                        'rrule': event.rrule?.toString(),
                                        'attendees': event.attendees.map((a) => a.email).whereType<String>().toList(),
                                        'conference_link': event.conferenceLink,
                                        'isAllDay': event.isAllDay,
                                      });
                                      buffer.write('<tagged_event>$eventJson</tagged_event>');
                                    }
                                    for (final inbox in taggedInboxes) {
                                      final inboxJson = jsonEncode(inbox.toJson(local: true));
                                      buffer.write('<tagged_inbox>$inboxJson</tagged_inbox>');
                                    }
                                    if (_messageController?.taggedConnections != null) {
                                      for (final connection in _messageController!.taggedConnections) {
                                        final connectionJson = jsonEncode({'name': connection.name, 'email': connection.email});
                                        buffer.write('<tagged_connection>$connectionJson</tagged_connection>');
                                      }
                                    }
                                    if (_messageController?.taggedChannels != null) {
                                      for (final channel in _messageController!.taggedChannels) {
                                        final channelJson = jsonEncode({'id': channel.id, 'name': channel.name, 'teamId': channel.teamId});
                                        buffer.write('<tagged_channel>$channelJson</tagged_channel>');
                                      }
                                    }
                                    if (_messageController?.taggedProjects != null) {
                                      for (final project in _messageController!.taggedProjects) {
                                        final projectJson = jsonEncode({'id': project.uniqueId, 'name': project.name});
                                        buffer.write('<tagged_project>$projectJson</tagged_project>');
                                      }
                                    }

                                    final messageWithTags = buffer.toString();

                                    final currentState = ref.read(agentActionControllerProvider);
                                    final updatedMessages = [...currentState.messages, AgentActionMessage(role: 'user', content: messageWithTags)];
                                    ref.read(agentActionControllerProvider.notifier).state = ref
                                        .read(agentActionControllerProvider.notifier)
                                        .state
                                        .copyWith(messages: updatedMessages, isLoading: true);

                                    // input 비우기
                                    _agentInputFieldStateKey.currentState?.clearMessage();

                                    // MCP 함수 직접 실행
                                    _executeMcpFunctionDirectly(
                                      ref: ref,
                                      controller: controller,
                                      mcpFunctionName: mcpFunctionName,
                                      task: task,
                                      event: event,
                                      inbox: inbox,
                                      taggedTasks: taggedTasks,
                                      taggedEvents: taggedEvents,
                                      taggedInboxes: taggedInboxes,
                                      filteredInboxes: filteredInboxes,
                                    );
                                  }
                                },
                                onCustomPrompt: (title, prompt) {
                                  final controller = ref.read(agentActionControllerProvider.notifier);
                                  final message = prompt.isNotEmpty ? prompt : title;
                                  if (message.isNotEmpty) {
                                    controller.handleMessageWithoutAction(message, inboxes: filteredInboxes);
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              ValueListenableBuilder(
                valueListenable: MobileScaffold.largeTabBar,
                builder: (context, largeTabBar, child) {
                  final tabMargin = (largeTabBar ? MobileScaffold.bottomPaddingForLargeTabBar : MobileScaffold.bottomPaddingForSmallTabBar);
                  return Positioned.fill(
                    child: IgnorePointer(
                      child: AnimatedOpacity(
                        opacity: onFileEntered ? 1 : 0,
                        duration: Duration(milliseconds: 250),
                        child: Container(
                          decoration: BoxDecoration(color: context.background.withValues(alpha: 0.75)),
                          padding: EdgeInsets.all(16),
                          child: Padding(
                            padding: EdgeInsets.only(top: headerSectionHeight - 20, bottom: (_agentInputFieldHeight > 0 ? _agentInputFieldHeight + 8 : 0) + tabMargin + 8),
                            child: DottedBorder(
                              options: RoundedRectDottedBorderOptions(radius: Radius.circular(8), dashPattern: [12, 12], color: context.outline, strokeWidth: 6),
                              child: Container(
                                child: Center(child: Text(context.tr.mail_drop_to_attach, style: context.displayMedium?.textColor(context.inverseSurface))),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      );
    }

    return Material(
      color: Colors.transparent,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: headerSectionHeight,
            child: Container(
              child: weatherData != null ? Image.asset(weatherData.condition.assets, fit: BoxFit.cover) : Image.asset(WeatherCondition.clear.assets, fit: BoxFit.cover),
            ),
          ),
          if (weatherData == null)
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(color: context.background.withValues(alpha: 0.9)),
              ),
            ),
          if (weatherData != null) Positioned.fill(child: Container(color: context.background.withValues(alpha: 0.65))),
          Positioned(
            top: projectCardsTop,
            left: 0,
            right: 0,
            child: ProjectSummaryCardsWidget(
              key: projectSummaryCardsWidgetKey,
              projectMap: projectMap,
              projectHide: projectHide,
              resizableController: resizableController,
              onProjectSelected: (project) {
                setState(() {
                  _selectedProject = project;
                });
              },
            ),
          ),
          Positioned.fill(
            child: ResizableContainer(
              direction: Axis.horizontal,
              controller: resizableController,
              children: [
                ResizableChild(
                  size: ResizableSize.expand(min: 380, flex: 3),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Stack(
                        children: [
                          Utils.buildDropTarget(
                            onDropEnter: () {
                              onFileEntered = true;
                              setState(() {});
                            },
                            onDropLeave: () {
                              onFileEntered = false;
                              setState(() {});
                            },
                            onDrop: (files) {
                              _agentInputFieldStateKey.currentState?.uploadFiles(files: files);
                              onFileEntered = false;
                              setState(() {});
                            },
                            child: Positioned.fill(
                              child: Column(
                                children: [
                                  MediaQuery(
                                    data: context.mediaQuery.copyWith(textScaler: TextScaler.linear(1)),
                                    child: IgnorePointer(
                                      child: Container(
                                        height: headerSectionHeight,
                                        padding: headerPadding,
                                        child: Material(
                                          clipBehavior: Clip.none,
                                          color: Colors.transparent,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      '${context.tr.agentic_home_hi}${userName == null ? '' : userName.split(' ').first}',
                                                      style: context.displayLarge?.textColor(context.onBackground).textBold,
                                                    ),
                                                  ),
                                                  if (weatherData != null)
                                                    Column(
                                                      crossAxisAlignment: CrossAxisAlignment.end,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Text(
                                                              weatherData.temperature.round().toString(),
                                                              style: context.headlineLarge?.textColor(context.onBackground).appFont(context),
                                                            ),
                                                            HugeIcon(
                                                              icon: weatherData.useFahrenheit ? HugeIcons.solidRoundedFahrenheit : HugeIcons.solidRoundedCelsius,
                                                              size: context.textScaler.scale(context.headlineLarge!.fontSize!),
                                                              color: context.onBackground,
                                                            ),
                                                          ],
                                                        ),
                                                        Text(weatherData.name, style: context.titleSmall?.textColor(context.inverseSurface)),
                                                      ],
                                                    ),
                                                ],
                                              ),
                                              SizedBox(height: 6),
                                              if (!_isSuggestionLoading)
                                                Text(summaryText, style: context.headlineMedium?.textColor(context.surfaceTint), maxLines: 1, overflow: TextOverflow.ellipsis),
                                              if (_isSuggestionLoading)
                                                Row(
                                                  children: [
                                                    ShimmerText(
                                                      text: context.tr.inbox_agent_loading_dynamic(fetchDurationString),
                                                      textSize: context.headlineMedium!.fontSize!,
                                                      textFamily: context.headlineMedium?.appFont(context).fontFamily ?? '',
                                                      textColor: context.surfaceTint,
                                                      shiningColor: context.inverseSurface,
                                                      letterspacing: 0,
                                                    ),
                                                  ],
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      margin: cardMargin,
                                      child: Stack(
                                        clipBehavior: Clip.none,
                                        children: [
                                          Positioned.fill(
                                            child: ClipRRect(borderRadius: BorderRadius.circular(cardRadius), child: MeshLoadingBackground(doNotAnimate: true)),
                                          ),
                                          IgnorePointer(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: context.background.withValues(alpha: 0.7),
                                                border: Border.all(color: context.onBackground.withValues(alpha: 0.1), width: 1),
                                                borderRadius: BorderRadius.circular(cardRadius),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            bottom: _agentInputFieldHeight,
                                            left: 0,
                                            right: 0,
                                            top: 0,
                                            child: Material(
                                              clipBehavior: Clip.none,
                                              color: Colors.transparent,
                                              child: DailySummaryWidget(
                                                events: events,
                                                tasks: tasks,
                                                inboxes: inboxes,
                                                selectedProject: _selectedProject,
                                                projects: projects,
                                                userName: userName,
                                                onDragStart: (inbox, task) {
                                                  if (PlatformX.isDesktopView) {
                                                    _agentInputFieldStateKey.currentState?.handleDragStart(inbox, task, Offset.zero);
                                                  } else {
                                                    _agentInputFieldStateKey.currentState?.handleDragStart(inbox, task, Offset.zero);
                                                    if (inbox == null) return;
                                                    widget.onDragStart?.call(inbox);
                                                  }
                                                },
                                                onDragUpdate: (inbox, task, offset) {
                                                  if (PlatformX.isDesktopView) {
                                                    if (inbox == null) return;
                                                    _agentInputFieldStateKey.currentState?.handleDragUpdate(inbox, task, offset);
                                                    timeblockDropWidgetKey.currentState?.onInboxDragUpdate(inbox, offset);
                                                  } else {
                                                    _agentInputFieldStateKey.currentState?.handleDragUpdate(inbox, task, offset);
                                                    if (inbox == null) return;
                                                    widget.onDragUpdate?.call(inbox, offset);
                                                  }
                                                },
                                                onDragEnd: (inbox, task, offset) {
                                                  if (PlatformX.isDesktopView) {
                                                    _agentInputFieldStateKey.currentState?.handleDragEnd(inbox, task, offset);
                                                    if (inbox == null) return;
                                                    timeblockDropWidgetKey.currentState?.onInboxDragEnd(inbox, offset);
                                                  } else {
                                                    _agentInputFieldStateKey.currentState?.handleDragEnd(inbox, task, offset);
                                                    if (inbox == null) return;
                                                    widget.onDragEnd?.call(inbox, offset);
                                                  }
                                                },
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          Positioned(
                            left: 8,
                            bottom: _agentInputFieldHeight,
                            right: 1,
                            child: AgentActionMessagesWidget(maxHeight: constraints.maxHeight - _agentInputFieldHeight - 8),
                          ),

                          Positioned(
                            bottom: 8,
                            left: 8,
                            right: 2,
                            child: NotificationListener<SizeChangedLayoutNotification>(
                              onNotification: (notification) {
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  final RenderBox? renderBox = _agentInputFieldKey.currentContext?.findRenderObject() as RenderBox?;
                                  if (renderBox != null) {
                                    final height = renderBox.size.height;
                                    if (height != _agentInputFieldHeight) {
                                      setState(() {
                                        _agentInputFieldHeight = height;
                                      });
                                    }
                                  }
                                });
                                return true;
                              },
                              child: SizeChangedLayoutNotifier(
                                child: Container(
                                  key: _agentInputFieldKey,
                                  child: AgentInputField(
                                    key: _agentInputFieldStateKey,
                                    fieldKey: _agentInputFieldStateKey,
                                    messageController: _messageController,
                                    focusNode: _focusNode,
                                    onPressEscape: () => true,
                                    tabType: tabType,
                                    initialProject: _selectedProject,
                                    inboxes: filteredInboxes,
                                    upNextTask: nextItem?.task,
                                    upNextEvent: nextItem?.event,
                                    onProjectChanged: (p) {
                                      setState(() {
                                        _selectedProject = p;
                                      });
                                    },
                                    onActionTap: (mcpFunctionName, {inbox, task, event}) {
                                      final actionType = mcpFunctionToAgentActionType(mcpFunctionName);
                                      if (actionType != null) {
                                        ref.read(agentActionControllerProvider.notifier).startAction(actionType: actionType, inbox: inbox, task: task, event: event);
                                      } else {
                                        // actionType이 null인 경우 (새로운 함수들: getPreviousContext, convertBraindumpToTask, markDoneAndReply 등)
                                        // 드롭된 아이템을 messageController에 추가하고 액션 타이틀만 텍스트로 추가
                                        if (_messageController != null) {
                                          // 드롭된 아이템을 태그된 아이템에 추가
                                          if (task != null && !_messageController!.taggedTasks.any((t) => t.id == task.id)) {
                                            _messageController!.addTaggedData(task: task);
                                          }
                                          if (event != null && !_messageController!.taggedEvents.any((e) => e.eventId == event.eventId)) {
                                            _messageController!.addTaggedData(event: event);
                                          }
                                          if (inbox != null && !_messageController!.taggedInboxes.any((i) => i.id == inbox.id)) {
                                            _messageController!.addTaggedData(inbox: inbox);
                                          }

                                          // 액션 타이틀 가져오기
                                          String actionTitle = mcpFunctionName;
                                          switch (mcpFunctionName) {
                                            case 'getPreviousContext':
                                              actionTitle = 'View Previous Context';
                                              break;
                                            case 'convertBraindumpToTask':
                                              actionTitle = 'Convert to Task';
                                              break;
                                            case 'markDoneAndReply':
                                              actionTitle = 'Mark Done & Reply';
                                              break;
                                            case 'reschedule':
                                              actionTitle = 'Reschedule';
                                              break;
                                            case 'setDueDate':
                                              actionTitle = 'Set Due Date';
                                              break;
                                            case 'setRecurrence':
                                              actionTitle = 'Edit Recurrence';
                                              break;
                                            case 'removeRecurrence':
                                              actionTitle = 'Remove Recurrence';
                                              break;
                                            case 'responseCalendarInvitation':
                                              actionTitle = 'Respond to Invitation';
                                              break;
                                          }

                                          // 메시지는 로컬에만 추가하고, 실제 액션은 바로 MCP 함수 실행
                                          final controller = ref.read(agentActionControllerProvider.notifier);
                                          final taggedTasks = List<TaskEntity>.from(_messageController!.taggedTasks);
                                          final taggedEvents = List<EventEntity>.from(_messageController!.taggedEvents);
                                          final taggedInboxes = List<InboxEntity>.from(_messageController!.taggedInboxes);

                                          // 드롭된 아이템을 태그된 아이템에 추가
                                          if (task != null && !taggedTasks.any((t) => t.id == task.id)) {
                                            taggedTasks.add(task);
                                          }
                                          if (event != null && !taggedEvents.any((e) => e.eventId == event.eventId)) {
                                            taggedEvents.add(event);
                                          }
                                          if (inbox != null && !taggedInboxes.any((i) => i.id == inbox.id)) {
                                            taggedInboxes.add(inbox);
                                          }

                                          // 메시지를 로컬에만 추가 (태그된 아이템 포함)
                                          final buffer = StringBuffer();
                                          buffer.write(actionTitle);

                                          // 태그된 항목들을 HTML 태그로 추가
                                          for (final task in taggedTasks) {
                                            final taskJson = jsonEncode(task.toJson(local: true));
                                            buffer.write('<tagged_task>$taskJson</tagged_task>');
                                          }
                                          for (final event in taggedEvents) {
                                            final eventJson = jsonEncode({
                                              'id': event.eventId,
                                              'title': event.title,
                                              'description': event.description,
                                              'calendar_id': event.calendar.uniqueId,
                                              'start_at': event.startDate.toIso8601String(),
                                              'end_at': event.endDate.toIso8601String(),
                                              'location': event.location,
                                              'rrule': event.rrule?.toString(),
                                              'attendees': event.attendees.map((a) => a.email).whereType<String>().toList(),
                                              'conference_link': event.conferenceLink,
                                              'isAllDay': event.isAllDay,
                                            });
                                            buffer.write('<tagged_event>$eventJson</tagged_event>');
                                          }
                                          for (final inbox in taggedInboxes) {
                                            final inboxJson = jsonEncode(inbox.toJson(local: true));
                                            buffer.write('<tagged_inbox>$inboxJson</tagged_inbox>');
                                          }
                                          if (_messageController!.taggedConnections.isNotEmpty) {
                                            for (final connection in _messageController!.taggedConnections) {
                                              final connectionJson = jsonEncode({'name': connection.name, 'email': connection.email});
                                              buffer.write('<tagged_connection>$connectionJson</tagged_connection>');
                                            }
                                          }
                                          if (_messageController!.taggedChannels.isNotEmpty) {
                                            for (final channel in _messageController!.taggedChannels) {
                                              final channelJson = jsonEncode({'id': channel.id, 'name': channel.name, 'teamId': channel.teamId});
                                              buffer.write('<tagged_channel>$channelJson</tagged_channel>');
                                            }
                                          }
                                          if (_messageController!.taggedProjects.isNotEmpty) {
                                            for (final project in _messageController!.taggedProjects) {
                                              final projectJson = jsonEncode({'id': project.uniqueId, 'name': project.name});
                                              buffer.write('<tagged_project>$projectJson</tagged_project>');
                                            }
                                          }

                                          final messageWithTags = buffer.toString();

                                          // 메시지를 로컬에만 추가
                                          final currentState = ref.read(agentActionControllerProvider);
                                          final updatedMessages = [...currentState.messages, AgentActionMessage(role: 'user', content: messageWithTags)];
                                          ref.read(agentActionControllerProvider.notifier).state = currentState.copyWith(messages: updatedMessages, isLoading: true);

                                          // input 비우기
                                          _agentInputFieldStateKey.currentState?.clearMessage();

                                          // MCP 함수 직접 실행
                                          _executeMcpFunctionDirectly(
                                            ref: ref,
                                            controller: controller,
                                            mcpFunctionName: mcpFunctionName,
                                            task: task,
                                            event: event,
                                            inbox: inbox,
                                            taggedTasks: taggedTasks,
                                            taggedEvents: taggedEvents,
                                            taggedInboxes: taggedInboxes,
                                            filteredInboxes: filteredInboxes,
                                          );
                                        }
                                      }
                                    },
                                    onCustomPrompt: (title, prompt) {
                                      final controller = ref.read(agentActionControllerProvider.notifier);
                                      final message = prompt.isNotEmpty ? prompt : title;
                                      if (message.isNotEmpty) {
                                        controller.handleMessageWithoutAction(message, inboxes: filteredInboxes);
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),

                          Positioned(
                            bottom: 8,
                            left: 8,
                            right: 2,
                            height: constraints.maxHeight - _agentInputFieldHeight - 16,
                            child: IgnorePointer(
                              child: Material(
                                color: Colors.transparent,
                                child: AnimatedOpacity(
                                  opacity: onFileEntered ? 1 : 0,
                                  duration: Duration(milliseconds: 250),
                                  child: Container(
                                    decoration: BoxDecoration(color: context.background.withValues(alpha: 0.75)),
                                    height: constraints.maxHeight,
                                    width: constraints.maxWidth,
                                    padding: EdgeInsets.all(16),
                                    child: DottedBorder(
                                      options: RoundedRectDottedBorderOptions(radius: Radius.circular(8), dashPattern: [12, 12], color: context.outline, strokeWidth: 6),
                                      child: Container(
                                        child: Center(child: Text(context.tr.mail_drop_to_attach, style: context.displayMedium?.textColor(context.inverseSurface))),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  divider: ResizableDivider(thickness: DesktopScaffold.cardPadding, color: Colors.transparent),
                ),

                ResizableChild(
                  size: ResizableSize.expand(min: 320, flex: 1),
                  child: Builder(
                    builder: (context) {
                      final borderRadius = 10.0;
                      return Container(
                        margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(borderRadius), boxShadow: PopupMenu.popupShadow),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(borderRadius),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                            child: Stack(
                              children: [
                                Positioned.fill(child: MeshLoadingBackground(doNotAnimate: true)),
                                IgnorePointer(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: context.background.withValues(alpha: 0.5),
                                      border: Border.all(color: context.onBackground.withValues(alpha: 0.1), width: 1),
                                      borderRadius: BorderRadius.circular(borderRadius),
                                    ),
                                  ),
                                ),
                                Positioned.fill(
                                  child: TimeblockDropWidget(key: timeblockDropWidgetKey, tabType: tabType, transparent: true),
                                ),
                              ],
                            ),
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
