import 'dart:convert';

import 'package:Visir/config/providers.dart';
import 'package:Visir/features/auth/application/auth_controller.dart';
import 'package:Visir/features/mail/application/mail_list_controller.dart';
import 'package:Visir/features/mail/application/mail_label_list_controller.dart';
import 'package:Visir/features/chat/application/chat_channel_list_controller.dart';
import 'package:Visir/features/chat/application/chat_member_list_controller.dart';
import 'package:Visir/features/chat/application/chat_group_list_controller.dart';
import 'package:Visir/features/chat/application/chat_emoji_list_controller.dart';
import 'package:Visir/features/chat/application/chat_list_controller.dart';
import 'package:Visir/features/calendar/actions.dart';
import 'package:Visir/features/calendar/application/calendar_event_list_controller.dart';
import 'package:Visir/features/calendar/application/calendar_list_controller.dart';
import 'package:Visir/features/calendar/domain/entities/calendar_entity.dart';
import 'package:Visir/features/calendar/domain/entities/event_attendee_entity.dart';
import 'package:Visir/features/calendar/domain/entities/event_entity.dart';
import 'package:Visir/features/calendar/domain/entities/event_reminder_entity.dart';
import 'package:Visir/features/calendar/presentation/widgets/calendar_simple_create_widget.dart';
import 'package:Visir/dependency/rrule/src/recurrence_rule.dart';
import 'package:Visir/features/calendar/providers.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/mail/actions.dart';
import 'package:Visir/features/mail/domain/entities/mail_entity.dart';
import 'package:Visir/features/mail/domain/entities/mail_label_entity.dart';
import 'package:Visir/features/mail/domain/entities/mail_user_entity.dart';
import 'package:Visir/features/mail/providers.dart';
import 'package:Visir/features/chat/actions.dart';
import 'package:Visir/features/chat/domain/entities/message_channel_entity.dart';
import 'package:Visir/features/chat/providers.dart';
import 'package:Visir/features/preference/application/local_pref_controller.dart';
import 'package:Visir/features/preference/domain/entities/oauth_entity.dart';
import 'package:Visir/features/task/actions.dart';
import 'package:Visir/features/task/application/project_list_controller.dart';
import 'package:Visir/features/task/application/task_list_controller.dart';
import 'package:Visir/features/task/domain/entities/project_entity.dart';
import 'package:Visir/features/task/domain/entities/task_entity.dart';
import 'package:Visir/features/task/domain/entities/task_reminder_option_type.dart';
import 'package:Visir/features/common/domain/entities/connection_entity.dart';
import 'package:Visir/features/common/domain/entities/linked_item_entity.dart';
import 'package:Visir/features/inbox/domain/entities/inbox_entity.dart';
import 'package:Visir/features/inbox/application/inbox_agent_list_controller.dart';
import 'package:Visir/features/inbox/application/inbox_linked_task_controller.dart';
import 'package:Visir/features/inbox/application/inbox_list_controller.dart';
import 'package:Visir/features/task/providers.dart';
import 'package:Visir/features/common/presentation/utils/extensions/date_time_extension.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:enough_mail/enough_mail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

/// MCP 함수 호출을 파싱하고 실행하는 클래스
class McpFunctionExecutor {
  WidgetRef get ref => Utils.ref;

  /// AI 응답에서 함수 호출을 파싱합니다.
  /// OpenAI의 function calling 형식 또는 커스텀 JSON 형식을 지원합니다.
  Map<String, dynamic>? parseFunctionCall(String aiResponse) {
    final calls = parseFunctionCalls(aiResponse);
    return calls.isNotEmpty ? calls.first : null;
  }

  /// AI 응답에서 여러 개의 함수 호출을 파싱합니다.
  /// 여러 형식을 지원합니다:
  /// - 배열 형식: [{"function": "...", "arguments": {...}}, ...]
  /// - 여러 개의 function_call 태그
  /// - 여러 개의 JSON 블록
  List<Map<String, dynamic>> parseFunctionCalls(String aiResponse) {
    final results = <Map<String, dynamic>>[];

    try {
      // 1. 배열 형식: [{"function": "...", "arguments": {...}}, ...]
      // 먼저 배열이 있는지 확인
      final arrayStart = aiResponse.indexOf('[');
      final arrayEnd = aiResponse.lastIndexOf(']');
      if (arrayStart != -1 && arrayEnd != -1 && arrayEnd > arrayStart) {
        try {
          // 배열 부분을 추출하여 파싱 시도
          final arrayStr = aiResponse.substring(arrayStart, arrayEnd + 1);
          final parsed = jsonDecode(arrayStr) as List<dynamic>?;
          if (parsed != null && parsed.isNotEmpty) {
            // 먼저 함수 호출 형식인지 확인
            for (final item in parsed) {
              if (item is Map<String, dynamic> && item.containsKey('function') && item.containsKey('arguments')) {
                // can_parallelize 필드가 있으면 포함, 없으면 기본값 true (독립적인 함수는 기본적으로 병렬 처리 가능)
                final functionCall = Map<String, dynamic>.from(item);
                if (!functionCall.containsKey('can_parallelize')) {
                  // 기본값: 검색 함수들은 병렬 처리 가능, 나머지는 false
                  final functionName = functionCall['function'] as String? ?? '';
                  final searchFunctions = {'searchInbox', 'searchTask', 'searchCalendarEvent'};
                  functionCall['can_parallelize'] = searchFunctions.contains(functionName);
                }
                results.add(functionCall);
              }
            }
            if (results.isNotEmpty) return results;

            // 함수 호출 형식이 아니면 task/event 형식인지 확인
            for (final item in parsed) {
              if (item is Map<String, dynamic>) {
                // Task 형식 확인: title, startAt, endAt 등이 있으면 task로 간주
                if (item.containsKey('title') && (item.containsKey('startAt') || item.containsKey('start_at'))) {
                  final taskArgs = <String, dynamic>{
                    'title': item['title'] as String? ?? '',
                    'description': item['description'] as String?,
                    'startAt': item['startAt'] as String? ?? item['start_at'] as String?,
                    'endAt': item['endAt'] as String? ?? item['end_at'] as String?,
                    'isAllDay': item['isAllDay'] as bool? ?? item['is_all_day'] as bool? ?? false,
                    'projectId': item['projectId'] as String? ?? item['project_id'] as String?,
                    'status': item['status'] as String? ?? 'none',
                  };
                  results.add({'function': 'createTask', 'arguments': taskArgs});
                }
                // Event 형식 확인: title, startAt, endAt, calendarId 등이 있으면 event로 간주
                else if (item.containsKey('title') &&
                    (item.containsKey('startAt') || item.containsKey('start_at')) &&
                    (item.containsKey('calendarId') || item.containsKey('calendar_id'))) {
                  final eventArgs = <String, dynamic>{
                    'title': item['title'] as String? ?? '',
                    'description': item['description'] as String?,
                    'startAt': item['startAt'] as String? ?? item['start_at'] as String?,
                    'endAt': item['endAt'] as String? ?? item['end_at'] as String?,
                    'isAllDay': item['isAllDay'] as bool? ?? item['is_all_day'] as bool? ?? false,
                    'calendarId': item['calendarId'] as String? ?? item['calendar_id'] as String?,
                    'location': item['location'] as String?,
                    'attendees': item['attendees'] as List<dynamic>?,
                    'conferenceLink': item['conferenceLink'] as String? ?? item['conference_link'] as String?,
                  };
                  results.add({'function': 'createEvent', 'arguments': eventArgs});
                }
              }
            }
            if (results.isNotEmpty) return results;
          }
        } catch (e) {
          // 배열 파싱 실패, 다른 형식 시도
        }
      }

      // 2. 여러 개의 커스텀 형식: <function_call name="...">{...}</function_call>
      final customRegex = RegExp(r'<function_call\s+name="([^"]+)">\s*(\{.*?\})\s*</function_call>', dotAll: true);
      final customMatches = customRegex.allMatches(aiResponse);
      for (final match in customMatches) {
        final functionName = match.group(1);
        final argumentsJson = match.group(2);
        if (functionName != null && argumentsJson != null) {
          try {
            final arguments = jsonDecode(argumentsJson) as Map<String, dynamic>;
            final functionCall = <String, dynamic>{'function': functionName, 'arguments': arguments};
            // can_parallelize 필드는 커스텀 태그 형식에서는 기본값 사용
            final searchFunctions = {'searchInbox', 'searchTask', 'searchCalendarEvent'};
            functionCall['can_parallelize'] = searchFunctions.contains(functionName);
            results.add(functionCall);
          } catch (e) {
            // 개별 파싱 실패는 무시하고 계속 진행
          }
        }
      }
      if (results.isNotEmpty) return results;

      // 3. 여러 개의 JSON 블록 형식: ```json\n{"function": "...", "arguments": {...}}\n```
      final jsonBlockRegex = RegExp(r'```json\s*(\{.*?\})\s*```', dotAll: true);
      final jsonBlockMatches = jsonBlockRegex.allMatches(aiResponse);
      for (final match in jsonBlockMatches) {
        final jsonStr = match.group(1);
        if (jsonStr != null) {
          try {
            final parsed = jsonDecode(jsonStr) as Map<String, dynamic>;
            if (parsed.containsKey('function') && parsed.containsKey('arguments')) {
              final functionCall = Map<String, dynamic>.from(parsed);
              // can_parallelize 필드가 없으면 기본값 설정
              if (!functionCall.containsKey('can_parallelize')) {
                final functionName = functionCall['function'] as String? ?? '';
                final searchFunctions = {'searchInbox', 'searchTask', 'searchCalendarEvent'};
                functionCall['can_parallelize'] = searchFunctions.contains(functionName);
              }
              results.add(functionCall);
            }
          } catch (e) {
            // 개별 파싱 실패는 무시하고 계속 진행
          }
        }
      }
      if (results.isNotEmpty) return results;

      // 4. 단일 OpenAI function calling 형식: {"function": "createTask", "arguments": {...}}
      // 여러 개 찾기 위해 allMatches 사용
      final functionCallRegex = RegExp(r'\{[^}]*"function"\s*:\s*"([^"]+)"[^}]*"arguments"\s*:\s*(\{[^}]*\})[^}]*\}', dotAll: true);
      final matches = functionCallRegex.allMatches(aiResponse);
      for (final match in matches) {
        final functionName = match.group(1);
        final argumentsJson = match.group(2);
        if (functionName != null && argumentsJson != null) {
          try {
            final arguments = jsonDecode(argumentsJson) as Map<String, dynamic>;
            final functionCall = <String, dynamic>{'function': functionName, 'arguments': arguments};
            // can_parallelize 필드가 없으면 기본값 설정
            // 정규식으로 파싱한 경우 전체 JSON을 다시 파싱해서 can_parallelize 확인 시도
            try {
              // 전체 JSON 블록을 다시 파싱해서 can_parallelize 확인
              final fullJsonStr = aiResponse.substring(match.start, match.end);
              final fullJson = jsonDecode(fullJsonStr) as Map<String, dynamic>?;
              if (fullJson != null && fullJson.containsKey('can_parallelize')) {
                functionCall['can_parallelize'] = fullJson['can_parallelize'] as bool? ?? false;
              } else {
                final searchFunctions = {'searchInbox', 'searchTask', 'searchCalendarEvent'};
                functionCall['can_parallelize'] = searchFunctions.contains(functionName);
              }
            } catch (e) {
              // 전체 JSON 파싱 실패 시 기본값 사용
              final searchFunctions = {'searchInbox', 'searchTask', 'searchCalendarEvent'};
              functionCall['can_parallelize'] = searchFunctions.contains(functionName);
            }
            results.add(functionCall);
          } catch (e) {
            // 개별 파싱 실패는 무시하고 계속 진행
          }
        }
      }
    } catch (e) {
      // 파싱 실패
    }

    return results;
  }

  /// 함수 호출을 실행합니다.
  Future<Map<String, dynamic>> executeFunction(
    String functionName,
    Map<String, dynamic> arguments, {
    TabType tabType = TabType.home,
    List<TaskEntity>? availableTasks,
    List<EventEntity>? availableEvents,
    List<ConnectionEntity>? availableConnections,
    List<InboxEntity>? availableInboxes,
    double? remainingCredits,
  }) async {
    try {
      switch (functionName) {
        // Task Actions
        case 'createTask':
          return await _executeCreateTask(arguments, tabType: tabType, availableInboxes: availableInboxes);
        case 'updateTask':
          return await _executeUpdateTask(arguments, tabType: tabType, availableTasks: availableTasks);
        case 'deleteTask':
          return await _executeDeleteTask(arguments, tabType: tabType, availableTasks: availableTasks);
        case 'toggleTaskStatus':
          return await _executeToggleTaskStatus(arguments, tabType: tabType, availableTasks: availableTasks);
        case 'assignProject':
          return await _executeAssignProject(arguments, tabType: tabType, availableTasks: availableTasks);
        case 'setPriority':
          return await _executeSetPriority(arguments, tabType: tabType, availableTasks: availableTasks);
        case 'addTags':
          return await _executeAddTags(arguments, tabType: tabType, availableTasks: availableTasks);
        case 'removeTags':
          return await _executeRemoveTags(arguments, tabType: tabType, availableTasks: availableTasks);
        case 'setDueDate':
          return await _executeSetDueDate(arguments, tabType: tabType, availableTasks: availableTasks);
        case 'setReminder':
          return await _executeSetReminder(arguments, tabType: tabType, availableTasks: availableTasks, availableEvents: availableEvents);
        case 'setRecurrence':
          return await _executeSetRecurrence(arguments, tabType: tabType, availableTasks: availableTasks, availableEvents: availableEvents);
        case 'duplicateTask':
          return await _executeDuplicateTask(arguments, tabType: tabType, availableTasks: availableTasks);
        case 'duplicateEvent':
          return await _executeDuplicateEvent(arguments, tabType: tabType, availableEvents: availableEvents);
        case 'getTodayTasks':
          return await _executeGetTodayTasks(arguments, tabType: tabType);
        case 'getTodayEvents':
          return await _executeGetTodayEvents(arguments, tabType: tabType);
        case 'getUpcomingTasks':
          return await _executeGetUpcomingTasks(arguments, tabType: tabType);
        case 'getUpcomingEvents':
          return await _executeGetUpcomingEvents(arguments, tabType: tabType);
        case 'getOverdueTasks':
          return await _executeGetOverdueTasks(arguments, tabType: tabType);
        case 'getUnscheduledTasks':
          return await _executeGetUnscheduledTasks(arguments, tabType: tabType);
        case 'getCompletedTasks':
          return await _executeGetCompletedTasks(arguments, tabType: tabType);
        case 'removeReminder':
          return await _executeRemoveReminder(arguments, tabType: tabType, availableTasks: availableTasks, availableEvents: availableEvents);
        case 'removeRecurrence':
          return await _executeRemoveRecurrence(arguments, tabType: tabType, availableTasks: availableTasks, availableEvents: availableEvents);
        case 'getProjectDetails':
          return await _executeGetProjectDetails(arguments);
        case 'getInboxDetails':
          return await _executeGetInboxDetails(arguments, tabType: tabType);
        case 'listInboxes':
          return await _executeListInboxes(arguments, tabType: tabType);

        // Calendar Actions
        case 'createEvent':
          return await _executeCreateEvent(arguments, tabType: tabType, availableInboxes: availableInboxes);
        case 'updateEvent':
          return await _executeUpdateEvent(arguments, tabType: tabType, availableEvents: availableEvents);
        case 'deleteEvent':
          return await _executeDeleteEvent(arguments, tabType: tabType, availableEvents: availableEvents);
        case 'responseCalendarInvitation':
          return await _executeResponseCalendarInvitation(arguments, tabType: tabType, availableEvents: availableEvents);
        case 'optimizeSchedule':
          return await _executeOptimizeSchedule(arguments, tabType: tabType, availableTasks: availableTasks, availableEvents: availableEvents);
        case 'reschedule':
          return await _executeReschedule(arguments, tabType: tabType, availableTasks: availableTasks, availableEvents: availableEvents);

        // Project Actions
        case 'createProject':
          return await _executeCreateProject(arguments);
        case 'updateProject':
          return await _executeUpdateProject(arguments);
        case 'deleteProject':
          return await _executeDeleteProject(arguments);
        case 'searchProject':
          return await _executeSearchProject(arguments);
        case 'linkToProject':
          return await _executeLinkToProject(arguments, tabType: tabType, availableInboxes: availableInboxes);
        case 'moveProject':
          return await _executeMoveProject(arguments);
        case 'inviteUserToProject':
          return await _executeInviteUserToProject(arguments);
        case 'removeUserFromProject':
          return await _executeRemoveUserFromProject(arguments);

        // Mail Actions
        case 'sendMail':
          return await _executeSendMail(arguments);
        case 'replyMail':
          return await _executeReplyMail(arguments);
        case 'replyAllMail':
          return await _executeReplyAllMail(arguments);
        case 'forwardMail':
          return await _executeForwardMail(arguments);
        case 'markMailAsRead':
          return await _executeMarkMailAsRead(arguments);
        case 'markMailAsUnread':
          return await _executeMarkMailAsUnread(arguments);
        case 'archiveMail':
          return await _executeArchiveMail(arguments);
        case 'unarchiveMail':
          return await _executeUnarchiveMail(arguments);
        case 'pinMail':
          return await _executePinMail(arguments, tabType: tabType);
        case 'unpinMail':
          return await _executeUnpinMail(arguments, tabType: tabType);
        case 'markMailAsImportant':
          return await _executeMarkMailAsImportant(arguments, tabType: tabType);
        case 'markMailAsNotImportant':
          return await _executeMarkMailAsNotImportant(arguments, tabType: tabType);
        case 'spamMail':
          return await _executeSpamMail(arguments, tabType: tabType);
        case 'unspamMail':
          return await _executeUnspamMail(arguments, tabType: tabType);
        case 'deleteMail':
          return await _executeDeleteMail(arguments);
        case 'getMailDetails':
          return await _executeGetMailDetails(arguments, tabType: tabType);
        case 'listMails':
          return await _executeListMails(arguments, tabType: tabType);
        case 'moveMailToLabel':
          return await _executeMoveMailToLabel(arguments, tabType: tabType);
        case 'getMailLabels':
          return await _executeGetMailLabels(arguments);

        // Message/Chat Actions
        case 'sendMessage':
          return await _executeSendMessage(arguments, tabType: tabType);
        case 'replyMessage':
          return await _executeReplyMessage(arguments, tabType: tabType);
        case 'editMessage':
          return await _executeEditMessage(arguments, tabType: tabType);
        case 'deleteMessage':
          return await _executeDeleteMessage(arguments, tabType: tabType);
        case 'addReaction':
          return await _executeAddReaction(arguments, tabType: tabType);
        case 'removeReaction':
          return await _executeRemoveReaction(arguments, tabType: tabType);
        case 'getMessageDetails':
          return await _executeGetMessageDetails(arguments, tabType: tabType);
        case 'listMessages':
          return await _executeListMessages(arguments, tabType: tabType);
        case 'searchMessages':
          return await _executeSearchMessages(arguments, tabType: tabType);

        // Task/Event Movement and Attachments
        case 'moveTask':
          return await _executeMoveTask(arguments, tabType: tabType, availableTasks: availableTasks);
        case 'moveEvent':
          return await _executeMoveEvent(arguments, tabType: tabType, availableEvents: availableEvents);
        case 'getTaskAttachments':
          return await _executeGetTaskAttachments(arguments, availableTasks: availableTasks);
        case 'getEventAttachments':
          return await _executeGetEventAttachments(arguments, availableEvents: availableEvents);
        case 'getMailAttachments':
          return await _executeGetMailAttachments(arguments);
        case 'getMessageAttachments':
          return await _executeGetMessageAttachments(arguments, tabType: tabType);

        // Inbox Actions
        case 'pinInbox':
          return await _executePinInbox(arguments, tabType: tabType);
        case 'unpinInbox':
          return await _executeUnpinInbox(arguments, tabType: tabType);
        case 'createTaskFromInbox':
          return await _executeCreateTaskFromInbox(arguments, tabType: tabType, availableInboxes: availableInboxes);

        // List/Get Actions
        case 'listTasks':
          return await _executeListTasks(arguments, tabType: tabType);
        case 'listEvents':
          return await _executeListEvents(arguments, tabType: tabType);
        case 'listProjects':
          return await _executeListProjects(arguments);
        case 'getTaskDetails':
          return await _executeGetTaskDetails(arguments, tabType: tabType);
        case 'getEventDetails':
          return await _executeGetEventDetails(arguments, tabType: tabType);
        case 'getCalendarList':
          return await _executeGetCalendarList(arguments);

        // Search Actions
        case 'searchInbox':
          return await _executeSearchInbox(arguments, tabType: tabType);
        case 'searchTask':
          return await _executeSearchTask(arguments);
        case 'searchCalendarEvent':
          return await _executeSearchCalendarEvent(arguments, tabType: tabType);

        default:
          return {'success': false, 'error': 'Unknown function: $functionName'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Execution error: ${e.toString()}'};
    }
  }

  // Task execution methods
  Future<Map<String, dynamic>> _executeCreateTask(Map<String, dynamic> args, {required TabType tabType, List<InboxEntity>? availableInboxes}) async {
    final user = ref.read(authControllerProvider).requireValue;
    final title = args['title'] as String?;
    if (title == null || title.isEmpty) {
      return {'success': false, 'error': 'Title is required'};
    }

    final description = args['description'] as String?;
    var projectId = args['projectId'] as String?;
    final startAtStr = args['startAt'] as String? ?? args['start_at'] as String?;
    final endAtStr = args['endAt'] as String? ?? args['end_at'] as String?;
    var isAllDay = args['isAllDay'] as bool? ?? false;
    final statusStr = args['status'] as String? ?? 'none';
    final inboxId = args['inboxId'] as String?;

    // Find matching inbox by id first, then by linkedMail/linkedMessage
    InboxEntity? matchingInbox;
    if (availableInboxes != null && availableInboxes.isNotEmpty) {
      // First, try to find inbox by id if provided
      if (inboxId != null && inboxId.isNotEmpty) {
        matchingInbox = availableInboxes.firstWhereOrNull((inbox) => inbox.id == inboxId);
      }

      // If not found by id, try to find inbox that has linkedMail or linkedMessage
      if (matchingInbox == null) {
        matchingInbox = availableInboxes.firstWhereOrNull((inbox) => inbox.linkedMail != null || inbox.linkedMessage != null);
      }
    }

    // If projectId is not provided, try to get it from inbox suggestion, then lastUsedProject, then defaultProject
    if (projectId == null || projectId.isEmpty) {
      // First, try to get projectId from any inbox suggestion in availableInboxes
      if (availableInboxes != null && availableInboxes.isNotEmpty) {
        for (final inbox in availableInboxes) {
          final suggestion = inbox.suggestion;
          if (suggestion != null && suggestion.project_id != null && suggestion.project_id!.isNotEmpty) {
            projectId = suggestion.project_id;
            break; // Use the first found projectId from suggestion
          }
        }
      }

      // If still no projectId, use lastUsedProject or defaultProject (same logic as _executeCreateEvent)
      if (projectId == null || projectId.isEmpty) {
        final lastUsedProjectId = ref.read(lastUsedProjectIdProvider).firstOrNull;
        final lastUsedProject = lastUsedProjectId == null ? null : ref.read(projectListControllerProvider).firstWhereOrNull((e) => e.isPointedProjectId(lastUsedProjectId));
        final defaultProject = ref.read(projectListControllerProvider).firstWhereOrNull((e) => e.isDefault);
        projectId = lastUsedProject?.uniqueId ?? defaultProject?.uniqueId;
      }
    }

    DateTime? startAt;
    DateTime? endAt;

    if (startAtStr != null) {
      try {
        startAt = DateTime.parse(startAtStr);
        if (startAt.isUtc) startAt = startAt.toLocal();
        // If isAllDay is true, use date only (midnight)
        if (isAllDay) {
          startAt = DateTime(startAt.year, startAt.month, startAt.day);
        }
      } catch (e) {
        // Fallback to today
        final now = DateTime.now();
        startAt = isAllDay ? DateTime(now.year, now.month, now.day) : now;
      }
    } else {
      // Default to today
      final now = DateTime.now();
      startAt = isAllDay ? DateTime(now.year, now.month, now.day) : now;

      // If inbox suggestion has target_date, use it
      if (matchingInbox != null) {
        final suggestion = matchingInbox.suggestion;
        if (suggestion != null && suggestion.target_date != null) {
          startAt = suggestion.target_date!;
          // If isAllDay is not explicitly set, use suggestion's is_date_only
          if (args['isAllDay'] == null) {
            isAllDay = suggestion.is_date_only ?? true;
          }
          if (isAllDay) {
            startAt = DateTime(startAt.year, startAt.month, startAt.day);
          }
        }
      }
    }

    if (endAtStr != null) {
      try {
        endAt = DateTime.parse(endAtStr);
        if (endAt.isUtc) endAt = endAt.toLocal();
        // If isAllDay is true, use date only (midnight)
        if (isAllDay) {
          endAt = DateTime(endAt.year, endAt.month, endAt.day);
        }
      } catch (e) {
        endAt = startAt.add(isAllDay ? const Duration(days: 1) : const Duration(hours: 1));
      }
    } else {
      // Calculate endAt based on startAt and isAllDay
      if (matchingInbox != null) {
        final suggestion = matchingInbox.suggestion;
        if (suggestion != null && suggestion.duration != null && suggestion.duration! > 0) {
          endAt = startAt.add(Duration(minutes: suggestion.duration!));
        } else {
          endAt = startAt.add(isAllDay ? const Duration(days: 1) : const Duration(hours: 1));
        }
      } else {
        endAt = startAt.add(isAllDay ? const Duration(days: 1) : const Duration(hours: 1));
      }
    }

    TaskStatus status;
    switch (statusStr) {
      case 'done':
        status = TaskStatus.done;
        break;
      case 'cancelled':
        status = TaskStatus.cancelled;
        break;
      default:
        status = TaskStatus.none;
    }

    List<LinkedMailEntity> linkedMails = [];
    List<LinkedMessageEntity> linkedMessages = [];
    if (matchingInbox != null) {
      if (matchingInbox.linkedMail != null) {
        linkedMails = [matchingInbox.linkedMail!];
      }
      if (matchingInbox.linkedMessage != null) {
        linkedMessages = [matchingInbox.linkedMessage!];
      }
    }

    // Set reminders based on user preferences (same logic as task_simple_create_widget.dart)
    final defaultTaskReminderType = user.userDefaultTaskReminderType;
    final defaultAllDayTaskReminderType = user.userDefaultAllDayTaskReminderType;
    final List<EventReminderEntity> reminders = isAllDay
        ? defaultAllDayTaskReminderType == TaskReminderOptionType.none
              ? []
              : [EventReminderEntity(method: 'push', minutes: defaultAllDayTaskReminderType.minutes())]
        : defaultTaskReminderType == TaskReminderOptionType.none
        ? []
        : [EventReminderEntity(method: 'push', minutes: defaultTaskReminderType.minutes())];

    final now = DateTime.now();
    final task = TaskEntity(
      id: const Uuid().v4(),
      ownerId: user.id,
      title: title,
      description: description,
      projectId: projectId,
      startAt: startAt,
      endAt: endAt,
      isAllDay: isAllDay,
      linkedMails: linkedMails,
      linkedMessages: linkedMessages,
      reminders: reminders,
      createdAt: now,
      updatedAt: now,
      status: status,
      recurrenceEndAt: endAt, // recurrence_end_at을 end_at과 같게 설정하여 null이 되지 않도록
    );

    await TaskAction.upsertTask(task: task, calendarTaskEditSourceType: CalendarTaskEditSourceType.inboxDrag, tabType: tabType, showToast: false);

    return {'success': true, 'taskId': task.id, 'message': 'Task created successfully'};
  }

  Future<Map<String, dynamic>> _executeUpdateTask(Map<String, dynamic> args, {required TabType tabType, List<TaskEntity>? availableTasks}) async {
    final taskId = args['taskId'] as String?;
    if (taskId == null) {
      return {'success': false, 'error': 'taskId is required'};
    }

    final allTasks = availableTasks ?? ref.read(taskListControllerProvider).tasks.where((e) => !e.isEventDummyTask).toList();
    final task = allTasks.firstWhere((t) => t.id == taskId, orElse: () => throw Exception('Task not found'));

    final title = args['title'] as String? ?? task.title;
    final description = args['description'] as String? ?? task.description;
    final projectId = args['projectId'] as String? ?? task.projectId;
    final startAtStr = args['startAt'] as String?;
    final endAtStr = args['endAt'] as String?;
    final isAllDay = args['isAllDay'] as bool? ?? task.isAllDay;
    final statusStr = args['status'] as String?;

    DateTime? startAt = task.startAt;
    DateTime? endAt = task.endAt;

    if (startAtStr != null) {
      try {
        startAt = DateTime.parse(startAtStr);
        if (startAt.isUtc) startAt = startAt.toLocal();
      } catch (e) {
        // Keep existing startAt
      }
    }

    if (endAtStr != null) {
      try {
        endAt = DateTime.parse(endAtStr);
        if (endAt.isUtc) endAt = endAt.toLocal();
      } catch (e) {
        // Keep existing endAt
      }
    }

    TaskStatus? status;
    if (statusStr != null) {
      switch (statusStr) {
        case 'done':
          status = TaskStatus.done;
          break;
        case 'cancelled':
          status = TaskStatus.cancelled;
          break;
        case 'none':
          status = TaskStatus.none;
          break;
      }
    }

    final updatedTask = task.copyWith(
      title: title,
      description: description,
      projectId: projectId,
      startAt: startAt,
      endAt: endAt,
      isAllDay: isAllDay,
      status: status ?? task.status,
      updatedAt: DateTime.now(),
    );

    await TaskAction.upsertTask(task: updatedTask, originalTask: task, calendarTaskEditSourceType: CalendarTaskEditSourceType.inboxDrag, tabType: tabType, showToast: false);

    return {'success': true, 'taskId': updatedTask.id, 'message': 'Task updated successfully'};
  }

  Future<Map<String, dynamic>> _executeDeleteTask(Map<String, dynamic> args, {required TabType tabType, List<TaskEntity>? availableTasks}) async {
    print('[McpFunctionExecutor] _executeDeleteTask 시작: args=$args, tabType=$tabType');
    final taskId = args['taskId'] as String?;
    if (taskId == null) {
      print('[McpFunctionExecutor] _executeDeleteTask: taskId가 없음');
      return {'success': false, 'error': 'taskId is required'};
    }
    print('[McpFunctionExecutor] _executeDeleteTask: taskId=$taskId');

    final allTasks = availableTasks ?? ref.read(taskListControllerProvider).tasks.where((e) => !e.isEventDummyTask).toList();
    print('[McpFunctionExecutor] _executeDeleteTask: allTasks 개수=${allTasks.length}');
    final task = allTasks.firstWhere((t) => t.id == taskId, orElse: () => throw Exception('Task not found'));
    print('[McpFunctionExecutor] _executeDeleteTask: task 찾음, task.id=${task.id}, task.title=${task.title}');

    print('[McpFunctionExecutor] _executeDeleteTask: TaskAction.deleteTask 호출 전');
    await TaskAction.deleteTask(
      task: task,
      calendarTaskEditSourceType: CalendarTaskEditSourceType.inboxDrag,
      tabType: tabType,
      selectedStartDate: task.startAt,
      selectedEndDate: task.endAt,
      showToast: false,
    );
    print('[McpFunctionExecutor] _executeDeleteTask: TaskAction.deleteTask 호출 완료');

    return {'success': true, 'message': 'Task deleted successfully'};
  }

  Future<Map<String, dynamic>> _executeToggleTaskStatus(Map<String, dynamic> args, {required TabType tabType, List<TaskEntity>? availableTasks}) async {
    final taskId = args['taskId'] as String?;
    if (taskId == null) {
      return {'success': false, 'error': 'taskId is required'};
    }

    final allTasks = availableTasks ?? ref.read(taskListControllerProvider).tasks.where((e) => !e.isEventDummyTask).toList();
    final task = allTasks.firstWhere((t) => t.id == taskId, orElse: () => throw Exception('Task not found'));

    await TaskAction.toggleStatus(task: task, startAt: task.startAt ?? DateTime.now(), endAt: task.endAt ?? DateTime.now(), tabType: tabType, showToast: false);

    return {'success': true, 'message': 'Task status toggled successfully'};
  }

  // Calendar execution methods
  Future<Map<String, dynamic>> _executeCreateEvent(Map<String, dynamic> args, {required TabType tabType, List<InboxEntity>? availableInboxes}) async {
    final title = args['title'] as String?;
    if (title == null || title.isEmpty) {
      return {'success': false, 'error': 'Title is required'};
    }

    final description = args['description'] as String?;
    final calendarId = args['calendarId'] as String?;
    final startAtStr = args['startAt'] as String?;
    final endAtStr = args['endAt'] as String?;
    final isAllDay = args['isAllDay'] as bool? ?? false;
    final location = args['location'] as String?;
    final attendeesList = args['attendees'] as List<dynamic>?;
    final conferenceLink = args['conferenceLink'] as String?;
    final inboxId = args['inboxId'] as String?;

    final calendarMap = ref.read(calendarListControllerProvider);
    final calendarList = calendarMap.values.expand((e) => e).toList();
    CalendarEntity? calendar;

    if (calendarId != null) {
      calendar = calendarList.firstWhereOrNull((c) => c.uniqueId == calendarId);
    }
    if (calendar == null || calendar.modifiable != true) {
      final modifiableCalendars = calendarList.where((c) => c.modifiable == true).toList();
      calendar = modifiableCalendars.firstOrNull ?? calendarList.firstOrNull;
    }
    if (calendar == null) {
      return {'success': false, 'error': 'No modifiable calendar available'};
    }

    DateTime? startAt;
    DateTime? endAt;

    if (startAtStr != null) {
      try {
        startAt = DateTime.parse(startAtStr);
        if (startAt.isUtc) startAt = startAt.toLocal();
      } catch (e) {
        startAt = DateTime.now();
      }
    } else {
      startAt = DateTime.now();
    }

    if (endAtStr != null) {
      try {
        endAt = DateTime.parse(endAtStr);
        if (endAt.isUtc) endAt = endAt.toLocal();
      } catch (e) {
        endAt = startAt.add(isAllDay ? const Duration(days: 1) : const Duration(hours: 1));
      }
    } else {
      endAt = startAt.add(isAllDay ? const Duration(days: 1) : const Duration(hours: 1));
    }

    final attendees =
        attendeesList?.whereType<String>().map((email) => EventAttendeeEntity(email: email.trim(), responseStatus: EventAttendeeResponseStatus.needsAction)).toList() ?? [];

    final timezone = ref.read(timezoneProvider).value;
    final event = EventEntity(
      calendarType: calendar.type ?? CalendarEntityType.google,
      eventId: Utils.generateBase32HexStringFromTimestamp(),
      title: title,
      description: description,
      rrule: null,
      location: location,
      isAllDay: isAllDay,
      startDate: startAt,
      endDate: isAllDay ? startAt.dateOnly : endAt,
      timezone: timezone,
      attendees: attendees,
      reminders: isAllDay ? [] : (calendar.defaultReminders ?? []),
      attachments: [],
      conferenceLink: conferenceLink,
      modifiedEvent: null,
      calendar: calendar,
      sequence: 1,
    );

    // Find matching inbox by id first, then by linkedMail/linkedMessage
    List<LinkedMailEntity> linkedMails = [];
    List<LinkedMessageEntity> linkedMessages = [];
    if (availableInboxes != null && availableInboxes.isNotEmpty) {
      InboxEntity? matchingInbox;

      // First, try to find inbox by id if provided
      if (inboxId != null && inboxId.isNotEmpty) {
        matchingInbox = availableInboxes.firstWhereOrNull((inbox) => inbox.id == inboxId);
      }

      // If not found by id, try to find inbox that has linkedMail or linkedMessage
      if (matchingInbox == null) {
        matchingInbox = availableInboxes.firstWhereOrNull((inbox) => inbox.linkedMail != null || inbox.linkedMessage != null);
      }

      if (matchingInbox != null) {
        if (matchingInbox.linkedMail != null) {
          linkedMails = [matchingInbox.linkedMail!];
        }
        if (matchingInbox.linkedMessage != null) {
          linkedMessages = [matchingInbox.linkedMessage!];
        }
      }
    }

    // If linkedMail or linkedMessage exists, create a task with the event
    if (linkedMails.isNotEmpty || linkedMessages.isNotEmpty) {
      final user = ref.read(authControllerProvider).requireValue;
      final lastUsedProjectId = ref.read(lastUsedProjectIdProvider).firstOrNull;
      final lastUsedProject = lastUsedProjectId == null ? null : ref.read(projectListControllerProvider).firstWhereOrNull((e) => e.isPointedProjectId(lastUsedProjectId));
      final defaultProject = ref.read(projectListControllerProvider).firstWhereOrNull((e) => e.isDefault);
      final now = DateTime.now();
      final taskEndAt = isAllDay ? startAt.dateOnly : endAt;
      final task = TaskEntity(
        id: const Uuid().v4(),
        ownerId: user.id,
        title: title,
        description: description,
        startAt: startAt,
        endAt: taskEndAt,
        isAllDay: isAllDay,
        linkedMails: linkedMails,
        linkedMessages: linkedMessages,
        reminders: isAllDay ? [] : (calendar.defaultReminders ?? []),
        createdAt: now,
        updatedAt: now,
        status: TaskStatus.none,
        linkedEvent: event,
        projectId: lastUsedProject?.uniqueId ?? defaultProject?.uniqueId,
        recurrenceEndAt: taskEndAt, // recurrence_end_at을 end_at과 같게 설정하여 null이 되지 않도록
      );

      await TaskAction.upsertTask(
        task: task,
        originalTask: task,
        calendarTaskEditSourceType: CalendarTaskEditSourceType.inboxDrag,
        tabType: tabType,
        selectedStartDate: startAt,
        selectedEndDate: isAllDay ? startAt.dateOnly : endAt,
        showToast: false,
      );
    }

    await CalendarAction.editCalendarEvent(
      tabType: tabType,
      originalEvent: null,
      newEvent: event,
      selectedEndDate: event.endDate,
      selectedStartDate: event.startDate,
      calendarTaskEditSourceType: CalendarTaskEditSourceType.inboxDrag,
      isCreate: true,
      isLinkedWithMessages: linkedMessages.isNotEmpty,
      isLinkedWithMails: linkedMails.isNotEmpty,
      showToast: false,
    );

    return {'success': true, 'eventId': event.eventId, 'message': 'Event created successfully'};
  }

  Future<Map<String, dynamic>> _executeUpdateEvent(Map<String, dynamic> args, {required TabType tabType, List<EventEntity>? availableEvents}) async {
    final eventId = args['eventId'] as String?;
    if (eventId == null) {
      return {'success': false, 'error': 'eventId is required'};
    }

    // Find event from availableEvents or controller
    EventEntity? event;
    if (availableEvents != null && availableEvents.isNotEmpty) {
      event = availableEvents.firstWhereOrNull((e) => e.eventId == eventId || e.uniqueId == eventId);
    }
    if (event == null) {
      // Try to find from controller
      final allEvents = ref.read(calendarEventListControllerProvider(tabType: tabType)).eventsOnView;
      event = allEvents.firstWhereOrNull((e) => e.eventId == eventId || e.uniqueId == eventId);
    }
    if (event == null) {
      return {'success': false, 'error': 'Event not found'};
    }

    final title = args['title'] as String? ?? event.title;
    final description = args['description'] as String? ?? event.description;
    final startAtStr = args['startAt'] as String?;
    final endAtStr = args['endAt'] as String?;
    final isAllDay = args['isAllDay'] as bool? ?? event.isAllDay;
    final location = args['location'] as String? ?? event.location;
    final attendeesList = args['attendees'] as List<dynamic>?;

    DateTime? startAt = event.startDate;
    DateTime? endAt = event.endDate;

    if (startAtStr != null) {
      try {
        startAt = DateTime.parse(startAtStr);
        if (startAt.isUtc) startAt = startAt.toLocal();
      } catch (e) {
        // Keep existing startAt
      }
    }

    if (endAtStr != null) {
      try {
        endAt = DateTime.parse(endAtStr);
        if (endAt.isUtc) endAt = endAt.toLocal();
      } catch (e) {
        // Keep existing endAt
      }
    }

    List<EventAttendeeEntity> attendees = event.attendees;
    if (attendeesList != null && attendeesList.isNotEmpty) {
      attendees = attendeesList.whereType<String>().map((email) => EventAttendeeEntity(email: email.trim(), responseStatus: EventAttendeeResponseStatus.needsAction)).toList();
    }

    final updatedEvent = event.copyWith(
      title: title,
      description: description,
      location: location,
      isAllDay: isAllDay,
      startDate: startAt,
      endDate: isAllDay ? (startAt?.dateOnly ?? DateTime.now()) : endAt,
      attendees: attendees,
    );

    await CalendarAction.editCalendarEvent(
      tabType: tabType,
      originalEvent: event,
      newEvent: updatedEvent,
      selectedEndDate: updatedEvent.endDate,
      selectedStartDate: updatedEvent.startDate,
      calendarTaskEditSourceType: CalendarTaskEditSourceType.inboxDrag,
      isCreate: false,
      showToast: false,
    );

    return {'success': true, 'eventId': updatedEvent.eventId, 'message': 'Event updated successfully'};
  }

  Future<Map<String, dynamic>> _executeDeleteEvent(Map<String, dynamic> args, {required TabType tabType, List<EventEntity>? availableEvents}) async {
    final eventId = args['eventId'] as String?;
    if (eventId == null) {
      return {'success': false, 'error': 'eventId is required'};
    }

    // Find event from availableEvents or controller
    EventEntity? event;
    if (availableEvents != null && availableEvents.isNotEmpty) {
      event = availableEvents.firstWhereOrNull((e) => e.eventId == eventId || e.uniqueId == eventId);
    }
    if (event == null) {
      // Try to find from controller
      final allEvents = ref.read(calendarEventListControllerProvider(tabType: tabType)).eventsOnView;
      event = allEvents.firstWhereOrNull((e) => e.eventId == eventId || e.uniqueId == eventId);
    }
    if (event == null) {
      return {'success': false, 'error': 'Event not found'};
    }

    await CalendarAction.editCalendarEvent(
      tabType: tabType,
      originalEvent: event,
      newEvent: null,
      selectedEndDate: event.endDate,
      selectedStartDate: event.startDate,
      calendarTaskEditSourceType: CalendarTaskEditSourceType.inboxDrag,
      isCreate: false,
      showToast: false,
    );

    return {'success': true, 'message': 'Event deleted successfully'};
  }

  Future<Map<String, dynamic>> _executeResponseCalendarInvitation(Map<String, dynamic> args, {required TabType tabType, List<EventEntity>? availableEvents}) async {
    final eventId = args['eventId'] as String?;
    final responseStr = args['response'] as String?;
    if (eventId == null || responseStr == null) {
      return {'success': false, 'error': 'eventId and response are required'};
    }

    // Find event from availableEvents or controller
    EventEntity? event;
    if (availableEvents != null && availableEvents.isNotEmpty) {
      event = availableEvents.firstWhereOrNull((e) => e.eventId == eventId || e.uniqueId == eventId);
    }
    if (event == null) {
      // Try to find from controller
      final allEvents = ref.read(calendarEventListControllerProvider(tabType: tabType)).eventsOnView;
      event = allEvents.firstWhereOrNull((e) => e.eventId == eventId || e.uniqueId == eventId);
    }
    if (event == null) {
      return {'success': false, 'error': 'Event not found'};
    }

    // Parse response status
    EventAttendeeResponseStatus status;
    switch (responseStr.toLowerCase()) {
      case 'accepted':
        status = EventAttendeeResponseStatus.accepted;
        break;
      case 'declined':
        status = EventAttendeeResponseStatus.declined;
        break;
      case 'tentative':
        status = EventAttendeeResponseStatus.tentative;
        break;
      default:
        return {'success': false, 'error': 'Invalid response status. Must be: accepted, declined, or tentative'};
    }

    await CalendarAction.responseCalendarInvitation(event: event, status: status, context: Utils.mainContext, tabType: tabType);

    return {'success': true, 'message': 'Calendar invitation response sent successfully'};
  }

  // Mail execution methods
  Future<Map<String, dynamic>> _executeSendMail(Map<String, dynamic> args) async {
    final toList = args['to'] as List<dynamic>?;
    final ccList = args['cc'] as List<dynamic>?;
    final bccList = args['bcc'] as List<dynamic>?;
    final subject = args['subject'] as String?;
    final body = args['body'] as String?;

    if (toList == null || toList.isEmpty) {
      return {'success': false, 'error': 'To recipients are required'};
    }
    if (subject == null || subject.isEmpty) {
      return {'success': false, 'error': 'Subject is required'};
    }
    if (body == null || body.isEmpty) {
      return {'success': false, 'error': 'Body is required'};
    }

    final user = ref.read(authControllerProvider).requireValue;
    if (user.email == null || user.email!.isEmpty) {
      return {'success': false, 'error': 'User email not found'};
    }

    final oauths = ref.read(localPrefControllerProvider.select((v) => v.value?.mailOAuths)) ?? [];
    if (oauths.isEmpty) {
      return {'success': false, 'error': 'No email account configured'};
    }
    final oauth = oauths.first;
    final fromEmail = oauth.email;
    final mailType = MailEntityTypeX.fromOAuthType(oauth.type);

    // Encode subject to RFC 2047 Base64
    String encodeSubjectRfc2047(String text) {
      final utf8Bytes = utf8.encode(text);
      final base64Text = base64.encode(utf8Bytes);
      const chunkSize = 60;
      if (base64Text.length <= chunkSize) {
        return '=?UTF-8?B?$base64Text?=';
      }
      final chunks = <String>[];
      for (var i = 0; i < base64Text.length; i += chunkSize) {
        final end = (i + chunkSize < base64Text.length) ? i + chunkSize : base64Text.length;
        chunks.add('=?UTF-8?B?${base64Text.substring(i, end)}?=');
      }
      return chunks.join('\r\n ');
    }

    final encodedSubject = encodeSubjectRfc2047(subject);
    final bodyHtml = body.replaceAll('\n', '<br>');

    final builder = MessageBuilder(characterSet: CharacterSet.utf8, transferEncoding: TransferEncoding.base64)
      ..from = [MailAddress(user.name ?? user.email!, fromEmail)]
      ..to = toList.whereType<String>().map((e) => MailAddress('', e)).where((e) => e.email.isNotEmpty).toList()
      ..cc = (ccList?.whereType<String>() ?? []).map((e) => MailAddress('', e)).where((e) => e.email.isNotEmpty).toList()
      ..bcc = (bccList?.whereType<String>() ?? []).map((e) => MailAddress('', e)).where((e) => e.email.isNotEmpty).toList();

    builder.setHeader('Subject', encodedSubject);
    builder.addTextHtml(bodyHtml);

    final mimeMessage = builder.buildMimeMessage();
    final fromUser = MailUserEntity(email: fromEmail, name: user.name, type: mailType);
    final mail = MailEntity(mailType: mailType, from: fromUser, draftId: null, messageId: null, threadId: null, mimeMessage: mimeMessage, subject: subject);

    MailAction.sendMail(mimeMessage: mimeMessage, mail: mail);

    return {'success': true, 'message': 'Mail sent successfully'};
  }

  Future<Map<String, dynamic>> _executeReplyMail(Map<String, dynamic> args) async {
    final threadId = args['threadId'] as String?;
    final toList = args['to'] as List<dynamic>?;
    final ccList = args['cc'] as List<dynamic>?;
    final subject = args['subject'] as String?;
    final body = args['body'] as String?;

    if (threadId == null || threadId.isEmpty) {
      return {'success': false, 'error': 'threadId is required'};
    }
    if (body == null || body.isEmpty) {
      return {'success': false, 'error': 'Body is required'};
    }

    final user = ref.read(authControllerProvider).requireValue;
    if (user.email == null || user.email!.isEmpty) {
      return {'success': false, 'error': 'User email not found'};
    }

    // Note: Finding mail by threadId requires access to mail list controller with specific label/email
    // For now, we'll use the first available OAuth account
    // In a real implementation, you would need to pass availableMails or search through all mail providers
    final oauths = ref.read(localPrefControllerProvider.select((v) => v.value?.mailOAuths)) ?? [];
    if (oauths.isEmpty) {
      return {'success': false, 'error': 'No email account configured'};
    }
    final oauth = oauths.first;
    final fromEmail = oauth.email;
    final mailType = MailEntityTypeX.fromOAuthType(oauth.type);

    // For reply, we need the original mail to get proper recipients and subject
    // This is a limitation - in a full implementation, you'd need to pass the original mail or search for it
    // For now, we'll use basic reply logic without the original mail context

    // Determine recipients
    List<MailAddress> toAddresses;
    if (toList != null && toList.isNotEmpty) {
      toAddresses = toList.whereType<String>().map((e) => MailAddress('', e)).where((e) => e.email.isNotEmpty).toList();
    } else {
      // Without original mail, we can't determine recipients - require toList
      return {'success': false, 'error': 'To recipients are required when original mail is not available'};
    }

    final ccAddresses = (ccList?.whereType<String>() ?? []).map((e) => MailAddress('', e)).where((e) => e.email.isNotEmpty).toList();

    // Determine subject
    String replySubject = subject ?? '';
    if (replySubject.isEmpty) {
      replySubject = 'Re: ';
    } else if (!replySubject.toLowerCase().startsWith('re:')) {
      replySubject = 'Re: $replySubject';
    }

    // Encode subject to RFC 2047 Base64
    String encodeSubjectRfc2047(String text) {
      final utf8Bytes = utf8.encode(text);
      final base64Text = base64.encode(utf8Bytes);
      const chunkSize = 60;
      if (base64Text.length <= chunkSize) {
        return '=?UTF-8?B?$base64Text?=';
      }
      final chunks = <String>[];
      for (var i = 0; i < base64Text.length; i += chunkSize) {
        final end = (i + chunkSize < base64Text.length) ? i + chunkSize : base64Text.length;
        chunks.add('=?UTF-8?B?${base64Text.substring(i, end)}?=');
      }
      return chunks.join('\r\n ');
    }

    final encodedSubject = encodeSubjectRfc2047(replySubject);
    final replyHtml = body.replaceAll('\n', '<br>');

    final builder = MessageBuilder(characterSet: CharacterSet.utf8, transferEncoding: TransferEncoding.base64)
      ..from = [MailAddress(user.name ?? user.email!, fromEmail)]
      ..to = toAddresses
      ..cc = ccAddresses;

    builder.setHeader('Subject', encodedSubject);
    // Note: In-Reply-To and References headers would require original mail ID
    // For now, we'll skip them since we don't have access to the original mail

    builder.addTextHtml(replyHtml);

    final mimeMessage = builder.buildMimeMessage();
    final fromUser = MailUserEntity(email: fromEmail, name: user.name, type: mailType);
    final replyMail = MailEntity(mailType: mailType, from: fromUser, draftId: null, messageId: null, threadId: threadId, mimeMessage: mimeMessage, subject: replySubject);

    MailAction.sendMail(mimeMessage: mimeMessage, mail: replyMail);

    return {'success': true, 'message': 'Reply sent successfully'};
  }

  Future<Map<String, dynamic>> _executeForwardMail(Map<String, dynamic> args) async {
    final threadId = args['threadId'] as String?;
    final toList = args['to'] as List<dynamic>?;
    final ccList = args['cc'] as List<dynamic>?;
    final subject = args['subject'] as String?;
    final body = args['body'] as String?;

    if (threadId == null || threadId.isEmpty) {
      return {'success': false, 'error': 'threadId is required'};
    }
    if (toList == null || toList.isEmpty) {
      return {'success': false, 'error': 'To recipients are required'};
    }

    final user = ref.read(authControllerProvider).requireValue;
    if (user.email == null || user.email!.isEmpty) {
      return {'success': false, 'error': 'User email not found'};
    }

    // Note: Finding mail by threadId requires access to mail list controller with specific label/email
    // For now, we'll use the first available OAuth account
    // In a real implementation, you would need to pass availableMails or search through all mail providers
    final oauths = ref.read(localPrefControllerProvider.select((v) => v.value?.mailOAuths)) ?? [];
    if (oauths.isEmpty) {
      return {'success': false, 'error': 'No email account configured'};
    }
    final oauth = oauths.first;
    final fromEmail = oauth.email;
    final mailType = MailEntityTypeX.fromOAuthType(oauth.type);

    // Determine subject
    String forwardSubject = subject ?? '';
    if (forwardSubject.isNotEmpty && !forwardSubject.toLowerCase().startsWith('fwd:') && !forwardSubject.toLowerCase().startsWith('fw:')) {
      forwardSubject = 'Fwd: $forwardSubject';
    } else if (forwardSubject.isEmpty) {
      forwardSubject = 'Fwd: ';
    }

    // Build forward body - without original mail, we can only use the provided body
    // In a full implementation, you'd fetch the original mail and include it

    final forwardBodyHtml = body != null && body.isNotEmpty ? body.replaceAll('\n', '<br>') : '';

    // Encode subject to RFC 2047 Base64
    String encodeSubjectRfc2047(String text) {
      final utf8Bytes = utf8.encode(text);
      final base64Text = base64.encode(utf8Bytes);
      const chunkSize = 60;
      if (base64Text.length <= chunkSize) {
        return '=?UTF-8?B?$base64Text?=';
      }
      final chunks = <String>[];
      for (var i = 0; i < base64Text.length; i += chunkSize) {
        final end = (i + chunkSize < base64Text.length) ? i + chunkSize : base64Text.length;
        chunks.add('=?UTF-8?B?${base64Text.substring(i, end)}?=');
      }
      return chunks.join('\r\n ');
    }

    final encodedSubject = encodeSubjectRfc2047(forwardSubject);

    final builder = MessageBuilder(characterSet: CharacterSet.utf8, transferEncoding: TransferEncoding.base64)
      ..from = [MailAddress(user.name ?? user.email!, fromEmail)]
      ..to = toList.whereType<String>().map((e) => MailAddress('', e)).where((e) => e.email.isNotEmpty).toList()
      ..cc = (ccList?.whereType<String>() ?? []).map((e) => MailAddress('', e)).where((e) => e.email.isNotEmpty).toList();

    builder.setHeader('Subject', encodedSubject);
    builder.addTextHtml(forwardBodyHtml);

    final mimeMessage = builder.buildMimeMessage();
    final fromUser = MailUserEntity(email: fromEmail, name: user.name, type: mailType);
    final forwardMail = MailEntity(mailType: mailType, from: fromUser, draftId: null, messageId: null, threadId: null, mimeMessage: mimeMessage, subject: forwardSubject);

    MailAction.sendMail(mimeMessage: mimeMessage, mail: forwardMail);

    return {'success': true, 'message': 'Mail forwarded successfully'};
  }

  /// Find mail by threadId across all mail providers
  Future<List<MailEntity>?> _findMailByThreadId(String threadId) async {
    final oauths = ref.read(localPrefControllerProvider.select((v) => v.value?.mailOAuths)) ?? [];
    if (oauths.isEmpty) {
      return null;
    }

    final mailRepository = ref.read(mailRepositoryProvider);
    final labelsToTry = [CommonMailLabels.inbox, CommonMailLabels.sent, CommonMailLabels.archive, CommonMailLabels.draft];

    // Try to find mail in each OAuth account and label
    for (final oauth in oauths) {
      final mailType = MailEntityTypeX.fromOAuthType(oauth.type);

      for (final label in labelsToTry) {
        final labelId = mailType == MailEntityType.google ? label.id : label.msId;

        final threadResult = await mailRepository.fetchThreads(oauth: oauth, type: mailType, threadId: threadId, email: oauth.email, labelId: labelId);

        final mails = threadResult.fold((failure) => null, (threadMails) => threadMails.isNotEmpty ? threadMails : null);

        if (mails != null && mails.isNotEmpty) {
          return mails;
        }
      }
    }

    return null;
  }

  Future<Map<String, dynamic>> _executeMarkMailAsRead(Map<String, dynamic> args) async {
    final threadId = args['threadId'] as String?;
    if (threadId == null || threadId.isEmpty) {
      return {'success': false, 'error': 'threadId is required'};
    }

    final mails = await _findMailByThreadId(threadId);
    if (mails == null || mails.isEmpty) {
      return {'success': false, 'error': 'Mail thread not found'};
    }

    final unreadMails = mails.where((m) => m.isUnread).toList();
    if (unreadMails.isEmpty) {
      return {'success': false, 'error': 'Mail thread is already read'};
    }

    MailAction.read(mails: unreadMails, tabType: TabType.home);

    return {'success': true, 'message': 'Mail marked as read successfully'};
  }

  Future<Map<String, dynamic>> _executeMarkMailAsUnread(Map<String, dynamic> args) async {
    final threadId = args['threadId'] as String?;
    if (threadId == null || threadId.isEmpty) {
      return {'success': false, 'error': 'threadId is required'};
    }

    final mails = await _findMailByThreadId(threadId);
    if (mails == null || mails.isEmpty) {
      return {'success': false, 'error': 'Mail thread not found'};
    }

    final readMails = mails.where((m) => !m.isUnread).toList();
    if (readMails.isEmpty) {
      return {'success': false, 'error': 'Mail thread is already unread'};
    }

    MailAction.unread(mails: readMails, tabType: TabType.home);

    return {'success': true, 'message': 'Mail marked as unread successfully'};
  }

  Future<Map<String, dynamic>> _executeArchiveMail(Map<String, dynamic> args) async {
    final threadId = args['threadId'] as String?;
    if (threadId == null || threadId.isEmpty) {
      return {'success': false, 'error': 'threadId is required'};
    }

    final mails = await _findMailByThreadId(threadId);
    if (mails == null || mails.isEmpty) {
      return {'success': false, 'error': 'Mail thread not found'};
    }

    final unarchivedMails = mails.where((m) => !m.isArchive).toList();
    if (unarchivedMails.isEmpty) {
      return {'success': false, 'error': 'Mail thread is already archived'};
    }

    MailAction.archive(mails: unarchivedMails, tabType: TabType.home);

    return {'success': true, 'message': 'Mail archived successfully'};
  }

  Future<Map<String, dynamic>> _executeDeleteMail(Map<String, dynamic> args) async {
    final threadId = args['threadId'] as String?;
    if (threadId == null || threadId.isEmpty) {
      return {'success': false, 'error': 'threadId is required'};
    }

    final mails = await _findMailByThreadId(threadId);
    if (mails == null || mails.isEmpty) {
      return {'success': false, 'error': 'Mail thread not found'};
    }

    MailAction.delete(mails: mails, tabType: TabType.home);

    return {'success': true, 'message': 'Mail deleted successfully'};
  }

  Future<Map<String, dynamic>> _executeReplyAllMail(Map<String, dynamic> args) async {
    final threadId = args['threadId'] as String?;

    if (threadId == null || threadId.isEmpty) {
      return {'success': false, 'error': 'threadId is required'};
    }

    final mails = await _findMailByThreadId(threadId);
    if (mails == null || mails.isEmpty) {
      return {'success': false, 'error': 'Mail thread not found'};
    }

    final mail = mails.first;
    final oauths = ref.read(localPrefControllerProvider.select((v) => v.value?.mailOAuths)) ?? [];
    if (oauths.isEmpty) {
      return {'success': false, 'error': 'No email account configured'};
    }
    final oauth = oauths.firstWhereOrNull((e) => e.email == mail.hostEmail) ?? oauths.first;
    final me = MailUserEntity(email: oauth.email, name: oauth.name, type: MailEntityTypeX.fromOAuthType(oauth.type));

    Utils.replyAllMail(mail: mail, me: me);

    return {'success': true, 'message': 'Reply all mail opened successfully'};
  }

  Future<Map<String, dynamic>> _executeUnarchiveMail(Map<String, dynamic> args) async {
    final threadId = args['threadId'] as String?;
    if (threadId == null || threadId.isEmpty) {
      return {'success': false, 'error': 'threadId is required'};
    }

    final mails = await _findMailByThreadId(threadId);
    if (mails == null || mails.isEmpty) {
      return {'success': false, 'error': 'Mail thread not found'};
    }

    MailAction.unarchive(mails: mails, tabType: TabType.home);

    return {'success': true, 'message': 'Mail unarchived successfully'};
  }

  Future<Map<String, dynamic>> _executePinMail(Map<String, dynamic> args, {required TabType tabType}) async {
    final threadId = args['threadId'] as String?;
    if (threadId == null || threadId.isEmpty) {
      return {'success': false, 'error': 'threadId is required'};
    }

    final mails = await _findMailByThreadId(threadId);
    if (mails == null || mails.isEmpty) {
      return {'success': false, 'error': 'Mail thread not found'};
    }

    final unpinnedMails = mails.where((m) => !m.isPinned).toList();
    if (unpinnedMails.isEmpty) {
      return {'success': false, 'error': 'Mail is already pinned'};
    }

    MailAction.pin(mails: unpinnedMails, tabType: tabType);

    return {'success': true, 'message': 'Mail pinned successfully'};
  }

  Future<Map<String, dynamic>> _executeUnpinMail(Map<String, dynamic> args, {required TabType tabType}) async {
    final threadId = args['threadId'] as String?;
    if (threadId == null || threadId.isEmpty) {
      return {'success': false, 'error': 'threadId is required'};
    }

    final mails = await _findMailByThreadId(threadId);
    if (mails == null || mails.isEmpty) {
      return {'success': false, 'error': 'Mail thread not found'};
    }

    final pinnedMails = mails.where((m) => m.isPinned).toList();
    if (pinnedMails.isEmpty) {
      return {'success': false, 'error': 'Mail is not pinned'};
    }

    MailAction.unpin(mails: pinnedMails, tabType: tabType);

    return {'success': true, 'message': 'Mail unpinned successfully'};
  }

  Future<Map<String, dynamic>> _executeMarkMailAsImportant(Map<String, dynamic> args, {required TabType tabType}) async {
    final threadId = args['threadId'] as String?;
    if (threadId == null || threadId.isEmpty) {
      return {'success': false, 'error': 'threadId is required'};
    }

    final mails = await _findMailByThreadId(threadId);
    if (mails == null || mails.isEmpty) {
      return {'success': false, 'error': 'Mail thread not found'};
    }

    final oauths = ref.read(localPrefControllerProvider.select((v) => v.value?.mailOAuths)) ?? [];
    if (oauths.isEmpty) {
      return {'success': false, 'error': 'No email account configured'};
    }

    final mailRepository = ref.read(mailRepositoryProvider);
    for (final mail in mails) {
      final oauth = oauths.firstWhereOrNull((e) => e.email == mail.hostEmail);
      if (oauth != null) {
        await mailRepository.important(oauth: oauth, mails: [mail]);
      }
    }

    return {'success': true, 'message': 'Mail marked as important successfully'};
  }

  Future<Map<String, dynamic>> _executeMarkMailAsNotImportant(Map<String, dynamic> args, {required TabType tabType}) async {
    final threadId = args['threadId'] as String?;
    if (threadId == null || threadId.isEmpty) {
      return {'success': false, 'error': 'threadId is required'};
    }

    final mails = await _findMailByThreadId(threadId);
    if (mails == null || mails.isEmpty) {
      return {'success': false, 'error': 'Mail thread not found'};
    }

    final oauths = ref.read(localPrefControllerProvider.select((v) => v.value?.mailOAuths)) ?? [];
    if (oauths.isEmpty) {
      return {'success': false, 'error': 'No email account configured'};
    }

    final mailRepository = ref.read(mailRepositoryProvider);
    for (final mail in mails) {
      final oauth = oauths.firstWhereOrNull((e) => e.email == mail.hostEmail);
      if (oauth != null) {
        await mailRepository.unimportant(oauth: oauth, mails: [mail]);
      }
    }

    return {'success': true, 'message': 'Mail marked as not important successfully'};
  }

  Future<Map<String, dynamic>> _executeSpamMail(Map<String, dynamic> args, {required TabType tabType}) async {
    final threadId = args['threadId'] as String?;
    if (threadId == null || threadId.isEmpty) {
      return {'success': false, 'error': 'threadId is required'};
    }

    final mails = await _findMailByThreadId(threadId);
    if (mails == null || mails.isEmpty) {
      return {'success': false, 'error': 'Mail thread not found'};
    }

    MailAction.spam(mails: mails, tabType: tabType);

    return {'success': true, 'message': 'Mail marked as spam successfully'};
  }

  Future<Map<String, dynamic>> _executeUnspamMail(Map<String, dynamic> args, {required TabType tabType}) async {
    final threadId = args['threadId'] as String?;
    if (threadId == null || threadId.isEmpty) {
      return {'success': false, 'error': 'threadId is required'};
    }

    final mails = await _findMailByThreadId(threadId);
    if (mails == null || mails.isEmpty) {
      return {'success': false, 'error': 'Mail thread not found'};
    }

    MailAction.unspam(mails: mails, tabType: tabType);

    return {'success': true, 'message': 'Mail unmarked as spam successfully'};
  }

  Future<Map<String, dynamic>> _executeGetMailDetails(Map<String, dynamic> args, {required TabType tabType}) async {
    final threadId = args['threadId'] as String?;
    if (threadId == null || threadId.isEmpty) {
      return {'success': false, 'error': 'threadId is required'};
    }

    final mails = await _findMailByThreadId(threadId);
    if (mails == null || mails.isEmpty) {
      return {'success': false, 'error': 'Mail thread not found'};
    }

    final mail = mails.first;
    final threads = mails;

    return {
      'success': true,
      'result': {
        'threadId': threadId,
        'subject': mail.subject ?? '',
        'from': mail.from?.email ?? '',
        'fromName': mail.from?.name ?? '',
        'to': mail.to?.map((e) => e.email).toList() ?? [],
        'cc': mail.cc?.map((e) => e.email).toList() ?? [],
        'date': mail.date?.toIso8601String(),
        'isUnread': mail.isUnread,
        'isPinned': mail.isPinned,
        'isArchive': mail.isArchive,
        'isSpam': mail.isSpam,
        'isTrash': mail.isTrash,
        'threadCount': threads.length,
        'hasAttachments': mail.getAttachments().isNotEmpty,
      },
      'message': '메일 정보를 가져왔습니다.',
    };
  }

  Future<Map<String, dynamic>> _executeListMails(Map<String, dynamic> args, {required TabType tabType}) async {
    final labelId = args['labelId'] as String?; // 'INBOX', 'SENT', 'DRAFT', etc.
    final email = args['email'] as String?;
    final isUnread = args['isUnread'] as bool?;
    final isPinned = args['isPinned'] as bool?;
    final limit = args['limit'] as int?;

    try {
      final mailList = ref.read(mailListControllerProvider);

      var allMails = <MailEntity>[];
      mailList.mails.forEach((key, value) {
        if (email == null || key == email) {
          allMails.addAll(value.messages);
        }
      });

      // Filter by label
      if (labelId != null && labelId.isNotEmpty) {
        allMails = allMails.where((m) => m.labelIds?.contains(labelId) == true).toList();
      }

      // Filter by unread status
      if (isUnread != null) {
        allMails = allMails.where((m) => m.isUnread == isUnread).toList();
      }

      // Filter by pinned status
      if (isPinned != null) {
        allMails = allMails.where((m) => m.isPinned == isPinned).toList();
      }

      // Sort by date (newest first)
      allMails.sort((a, b) => (b.date ?? DateTime(1970)).compareTo(a.date ?? DateTime(1970)));

      // Apply limit
      if (limit != null && limit > 0) {
        allMails = allMails.take(limit).toList();
      }

      final results = allMails.map((mail) {
        return {
          'threadId': mail.threadId,
          'id': mail.id,
          'subject': mail.subject ?? '',
          'from': mail.from?.email ?? '',
          'fromName': mail.from?.name ?? '',
          'date': mail.date?.toIso8601String(),
          'isUnread': mail.isUnread,
          'isPinned': mail.isPinned,
          'isArchive': mail.isArchive,
          'isSpam': mail.isSpam,
        };
      }).toList();

      return {'success': true, 'results': results, 'message': '${results.length}개의 메일을 찾았습니다.'};
    } catch (e) {
      return {'success': false, 'error': 'Failed to list mails: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> _executeSendMessage(Map<String, dynamic> args, {required TabType tabType}) async {
    final channelId = args['channelId'] as String?;
    final text = args['text'] as String?;

    if (channelId == null || channelId.isEmpty) {
      return {'success': false, 'error': 'channelId is required'};
    }
    if (text == null || text.isEmpty) {
      return {'success': false, 'error': 'text is required'};
    }

    try {
      final channelList = ref.read(chatChannelListControllerProvider);
      final allChannels = channelList.values.expand((e) => e.channels).toList();
      final channel = allChannels.firstWhereOrNull((c) => c.id == channelId);

      if (channel == null) {
        return {'success': false, 'error': 'Channel not found'};
      }

      final members = ref.read(chatMemberListControllerProvider(tabType: tabType)).members;
      final groups = ref.read(chatGroupListControllerProvider(tabType: tabType)).groups;
      final emojis = ref.read(chatEmojiListControllerProvider(tabType: tabType)).emojis;

      final result = await MessageAction.postMessage(html: text, channel: channel, channels: allChannels, members: members, groups: groups, emojis: emojis, tabType: tabType);

      return result ? {'success': true, 'message': 'Message sent successfully'} : {'success': false, 'error': 'Failed to send message'};
    } catch (e) {
      return {'success': false, 'error': 'Failed to send message: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> _executeReplyMessage(Map<String, dynamic> args, {required TabType tabType}) async {
    final threadId = args['threadId'] as String?;
    final text = args['text'] as String?;

    if (threadId == null || threadId.isEmpty) {
      return {'success': false, 'error': 'threadId is required'};
    }
    if (text == null || text.isEmpty) {
      return {'success': false, 'error': 'text is required'};
    }

    try {
      final channelCondition = ref.read(chatConditionProvider(tabType));
      final channel = channelCondition.channel;

      if (channel == null) {
        return {'success': false, 'error': 'Channel not found'};
      }

      final members = ref.read(chatMemberListControllerProvider(tabType: tabType)).members;
      final groups = ref.read(chatGroupListControllerProvider(tabType: tabType)).groups;
      final emojis = ref.read(chatEmojiListControllerProvider(tabType: tabType)).emojis;
      final allChannels = ref.read(chatChannelListControllerProvider).values.expand((e) => e.channels).toList();

      final result = await MessageAction.postReply(
        id: null,
        html: text,
        channel: channel,
        channels: allChannels,
        members: members,
        groups: groups,
        emojis: emojis,
        threadId: threadId,
        tabType: tabType,
      );

      return result ? {'success': true, 'message': 'Reply sent successfully'} : {'success': false, 'error': 'Failed to send reply'};
    } catch (e) {
      return {'success': false, 'error': 'Failed to send reply: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> _executeEditMessage(Map<String, dynamic> args, {required TabType tabType}) async {
    final messageId = args['messageId'] as String?;
    final text = args['text'] as String?;

    if (messageId == null || messageId.isEmpty) {
      return {'success': false, 'error': 'messageId is required'};
    }
    if (text == null || text.isEmpty) {
      return {'success': false, 'error': 'text is required'};
    }

    try {
      final channelCondition = ref.read(chatConditionProvider(tabType));
      final channel = channelCondition.channel;

      if (channel == null) {
        return {'success': false, 'error': 'Channel not found'};
      }

      final members = ref.read(chatMemberListControllerProvider(tabType: tabType)).members;
      final groups = ref.read(chatGroupListControllerProvider(tabType: tabType)).groups;
      final emojis = ref.read(chatEmojiListControllerProvider(tabType: tabType)).emojis;
      final allChannels = ref.read(chatChannelListControllerProvider).values.expand((e) => e.channels).toList();

      final result = await MessageAction.postMessage(
        id: messageId,
        html: text,
        channel: channel,
        channels: allChannels,
        members: members,
        groups: groups,
        emojis: emojis,
        tabType: tabType,
      );

      return result ? {'success': true, 'message': 'Message edited successfully'} : {'success': false, 'error': 'Failed to edit message'};
    } catch (e) {
      return {'success': false, 'error': 'Failed to edit message: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> _executeDeleteMessage(Map<String, dynamic> args, {required TabType tabType}) async {
    final messageId = args['messageId'] as String?;

    if (messageId == null || messageId.isEmpty) {
      return {'success': false, 'error': 'messageId is required'};
    }

    try {
      final chatList = ref.read(chatListControllerProvider(tabType: tabType));
      final message = chatList?.messages.firstWhereOrNull((m) => m.id == messageId);

      if (message == null) {
        return {'success': false, 'error': 'Message not found'};
      }

      final channelCondition = ref.read(chatConditionProvider(tabType));
      final channel = channelCondition.channel;

      if (channel == null) {
        return {'success': false, 'error': 'Channel not found'};
      }

      final chatListController = ref.read(chatListControllerProvider(tabType: tabType).notifier);
      chatListController.deleteMessageLocally(id: messageId);

      final oauths = ref.read(localPrefControllerProvider.select((v) => v.value?.messengerOAuths)) ?? [];
      if (oauths.isEmpty) {
        return {'success': false, 'error': 'No messenger account configured'};
      }
      final oauth = oauths.first;

      final repository = ref.read(chatRepositoryProvider);
      final result = await repository.deleteMessage(type: channel.type, oauth: oauth, channelId: channel.id, messageId: messageId);

      return result.fold(
        (l) => {'success': false, 'error': 'Failed to delete message'},
        (r) => r ? {'success': true, 'message': 'Message deleted successfully'} : {'success': false, 'error': 'Failed to delete message'},
      );
    } catch (e) {
      return {'success': false, 'error': 'Failed to delete message: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> _executeAddReaction(Map<String, dynamic> args, {required TabType tabType}) async {
    final messageId = args['messageId'] as String?;
    final emoji = args['emoji'] as String?;

    if (messageId == null || messageId.isEmpty) {
      return {'success': false, 'error': 'messageId is required'};
    }
    if (emoji == null || emoji.isEmpty) {
      return {'success': false, 'error': 'emoji is required'};
    }

    try {
      final chatList = ref.read(chatListControllerProvider(tabType: tabType));
      final message = chatList?.messages.firstWhereOrNull((m) => m.id == messageId);

      if (message == null) {
        return {'success': false, 'error': 'Message not found'};
      }

      final channelCondition = ref.read(chatConditionProvider(tabType));
      final channel = channelCondition.channel;

      if (channel == null) {
        return {'success': false, 'error': 'Channel not found'};
      }

      final oauths = ref.read(localPrefControllerProvider.select((v) => v.value?.messengerOAuths)) ?? [];
      if (oauths.isEmpty) {
        return {'success': false, 'error': 'No messenger account configured'};
      }
      final oauth = oauths.first;

      final repository = ref.read(chatRepositoryProvider);
      final result = await repository.addReaction(type: channel.type, oauth: oauth, channelId: channel.id, messageId: messageId, emoji: emoji);

      if (result.fold((l) => false, (r) => r)) {
        // Update local state
        final channelCondition = ref.read(chatConditionProvider(tabType));
        final channel = channelCondition.channel;
        if (channel != null) {
          final chatListController = ref.read(chatListControllerProvider(tabType: tabType).notifier);
          await chatListController.getReactions(messageId: messageId, channel: channel);
        }

        return {'success': true, 'message': 'Reaction added successfully'};
      }

      return {'success': false, 'error': 'Failed to add reaction'};
    } catch (e) {
      return {'success': false, 'error': 'Failed to add reaction: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> _executeRemoveReaction(Map<String, dynamic> args, {required TabType tabType}) async {
    final messageId = args['messageId'] as String?;
    final emoji = args['emoji'] as String?;

    if (messageId == null || messageId.isEmpty) {
      return {'success': false, 'error': 'messageId is required'};
    }
    if (emoji == null || emoji.isEmpty) {
      return {'success': false, 'error': 'emoji is required'};
    }

    try {
      final chatList = ref.read(chatListControllerProvider(tabType: tabType));
      final message = chatList?.messages.firstWhereOrNull((m) => m.id == messageId);

      if (message == null) {
        return {'success': false, 'error': 'Message not found'};
      }

      final channelCondition = ref.read(chatConditionProvider(tabType));
      final channel = channelCondition.channel;

      if (channel == null) {
        return {'success': false, 'error': 'Channel not found'};
      }

      final oauths = ref.read(localPrefControllerProvider.select((v) => v.value?.messengerOAuths)) ?? [];
      if (oauths.isEmpty) {
        return {'success': false, 'error': 'No messenger account configured'};
      }
      final oauth = oauths.first;

      final repository = ref.read(chatRepositoryProvider);
      final result = await repository.removeReaction(type: channel.type, oauth: oauth, channelId: channel.id, messageId: messageId, emoji: emoji);

      if (result.fold((l) => false, (r) => r)) {
        // Update local state
        final channelCondition = ref.read(chatConditionProvider(tabType));
        final channel = channelCondition.channel;
        if (channel != null) {
          final chatListController = ref.read(chatListControllerProvider(tabType: tabType).notifier);
          await chatListController.getReactions(messageId: messageId, channel: channel);
        }

        return {'success': true, 'message': 'Reaction removed successfully'};
      }

      return {'success': false, 'error': 'Failed to remove reaction'};
    } catch (e) {
      return {'success': false, 'error': 'Failed to remove reaction: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> _executeGetMessageDetails(Map<String, dynamic> args, {required TabType tabType}) async {
    final messageId = args['messageId'] as String?;

    if (messageId == null || messageId.isEmpty) {
      return {'success': false, 'error': 'messageId is required'};
    }

    try {
      final chatList = ref.read(chatListControllerProvider(tabType: tabType));
      final message = chatList?.messages.firstWhereOrNull((m) => m.id == messageId);

      if (message == null) {
        return {'success': false, 'error': 'Message not found'};
      }

      final members = ref.read(chatMemberListControllerProvider(tabType: tabType)).members;
      final channels = ref.read(chatChannelListControllerProvider).values.expand((e) => e.channels).toList();

      final userId = message.userId;
      final member = userId != null ? members.firstWhereOrNull((m) => m.id == userId) : null;
      final userName = member?.displayName ?? userId ?? 'Unknown user';

      final channelId = message.channelId;
      final channel = channelId != null ? channels.firstWhereOrNull((c) => c.id == channelId) : null;

      return {
        'success': true,
        'result': {
          'id': message.id,
          'text': message.text,
          'userId': message.userId,
          'userName': userName,
          'createdAt': message.createdAt?.toIso8601String(),
          'threadId': message.threadId,
          'replyCount': message.replyCount,
          'hasFiles': message.files?.isNotEmpty ?? false,
          'reactions': message.reactions?.map((r) => {'emoji': r.name ?? '', 'users': r.users}).toList() ?? [],
        },
        'message': '메시지 정보를 가져왔습니다.',
      };
    } catch (e) {
      return {'success': false, 'error': 'Failed to get message details: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> _executeListMessages(Map<String, dynamic> args, {required TabType tabType}) async {
    final channelId = args['channelId'] as String?;
    final limit = args['limit'] as int?;

    try {
      final channelCondition = ref.read(chatConditionProvider(tabType));
      final targetChannelId = channelId ?? channelCondition.channel?.id;

      if (targetChannelId == null) {
        return {'success': false, 'error': 'channelId is required'};
      }

      final chatList = ref.read(chatListControllerProvider(tabType: tabType));
      var messages = chatList?.messages ?? [];

      // Filter by channel if specified
      if (channelId != null && channelId != channelCondition.channel?.id) {
        // Need to load messages for the specified channel
        // For now, return empty if channel doesn't match current channel
        messages = [];
      }

      // Sort by date (newest first)
      messages.sort((a, b) => (b.createdAt ?? DateTime(1970)).compareTo(a.createdAt ?? DateTime(1970)));

      // Apply limit
      if (limit != null && limit > 0) {
        messages = messages.take(limit).toList();
      }

      final members = ref.read(chatMemberListControllerProvider(tabType: tabType)).members;

      final results = messages.map((message) {
        final userId = message.userId;
        final member = userId != null ? members.firstWhereOrNull((m) => m.id == userId) : null;
        final userName = member?.displayName ?? userId ?? '알 수 없는 사용자';

        return {
          'id': message.id,
          'text': message.text,
          'userId': message.userId,
          'userName': userName,
          'createdAt': message.createdAt?.toIso8601String(),
          'threadId': message.threadId,
          'replyCount': message.replyCount,
          'hasFiles': message.files?.isNotEmpty ?? false,
        };
      }).toList();

      return {'success': true, 'results': results, 'message': '${results.length}개의 메시지를 찾았습니다.'};
    } catch (e) {
      return {'success': false, 'error': 'Failed to list messages: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> _executeSearchMessages(Map<String, dynamic> args, {required TabType tabType}) async {
    final query = args['query'] as String?;
    final channelId = args['channelId'] as String?;

    if (query == null || query.isEmpty) {
      return {'success': false, 'error': 'query is required'};
    }

    try {
      final oauths = ref.read(localPrefControllerProvider.select((v) => v.value?.messengerOAuths)) ?? [];
      if (oauths.isEmpty) {
        return {'success': false, 'error': 'No messenger account configured'};
      }
      final oauth = oauths.first;

      final user = ref.read(authControllerProvider).requireValue;
      final repository = ref.read(chatRepositoryProvider);

      List<MessageChannelEntity>? channels;
      if (channelId != null) {
        final channelList = ref.read(chatChannelListControllerProvider);
        final allChannels = channelList.values.expand((e) => e.channels).toList();
        final channel = allChannels.firstWhereOrNull((c) => c.id == channelId);
        channels = channel != null ? [channel] : null;
      }

      final result = await repository.searchMessage(oauth: oauth, user: user, q: query, channels: channels);

      return result.fold((l) => {'success': false, 'error': 'Failed to search messages'}, (r) {
        final allChannels = ref.read(chatChannelListControllerProvider).values.expand((e) => e.channels).toList();
        final members = ref.read(chatMemberListControllerProvider(tabType: tabType)).members;

        final results = r.messages.map((message) {
          final userId = message.userId;
          final member = userId != null ? members.firstWhereOrNull((m) => m.id == userId) : null;
          final userName = member?.displayName ?? userId ?? '알 수 없는 사용자';

          final channelId = message.channelId;
          final channel = channelId != null ? allChannels.firstWhereOrNull((c) => c.id == channelId) : null;
          final channelName = channel?.displayName ?? channel?.name ?? '알 수 없는 채널';

          return {
            'id': message.id,
            'text': message.text,
            'userId': message.userId,
            'userName': userName,
            'createdAt': message.createdAt?.toIso8601String(),
            'channelId': message.channelId,
            'channelName': channelName,
          };
        }).toList();

        return {'success': true, 'results': results, 'message': '${results.length}개의 메시지를 찾았습니다.'};
      });
    } catch (e) {
      return {'success': false, 'error': 'Failed to search messages: ${e.toString()}'};
    }
  }

  // Task improvement actions
  Future<Map<String, dynamic>> _executeAssignProject(Map<String, dynamic> args, {required TabType tabType, List<TaskEntity>? availableTasks}) async {
    final taskId = args['taskId'] as String?;
    final projectId = args['projectId'] as String?;

    if (taskId == null) {
      return {'success': false, 'error': 'taskId is required'};
    }
    if (projectId == null) {
      return {'success': false, 'error': 'projectId is required'};
    }

    final allTasks = availableTasks ?? ref.read(taskListControllerProvider).tasks.where((e) => !e.isEventDummyTask).toList();
    final task = allTasks.firstWhere((t) => t.id == taskId, orElse: () => throw Exception('Task not found'));

    final updatedTask = task.copyWith(projectId: projectId, updatedAt: DateTime.now());
    await TaskAction.upsertTask(task: updatedTask, originalTask: task, calendarTaskEditSourceType: CalendarTaskEditSourceType.inboxDrag, tabType: tabType, showToast: false);

    return {'success': true, 'taskId': updatedTask.id, 'message': 'Project assigned successfully'};
  }

  Future<Map<String, dynamic>> _executeSetPriority(Map<String, dynamic> args, {required TabType tabType, List<TaskEntity>? availableTasks}) async {
    // Priority는 현재 TaskEntity에 필드가 없을 수 있으므로, description이나 tags를 통해 구현할 수 있습니다.
    // 또는 향후 priority 필드가 추가되면 그 필드를 사용할 수 있습니다.
    return {'success': false, 'error': 'Priority feature not yet implemented'};
  }

  Future<Map<String, dynamic>> _executeAddTags(Map<String, dynamic> args, {required TabType tabType, List<TaskEntity>? availableTasks}) async {
    // Tags는 현재 TaskEntity에 필드가 없을 수 있으므로, 향후 구현 필요
    return {'success': false, 'error': 'Tags feature not yet implemented'};
  }

  Future<Map<String, dynamic>> _executeRemoveTags(Map<String, dynamic> args, {required TabType tabType, List<TaskEntity>? availableTasks}) async {
    // Tags는 현재 TaskEntity에 필드가 없을 수 있으므로, 향후 구현 필요
    return {'success': false, 'error': 'Tags feature not yet implemented'};
  }

  Future<Map<String, dynamic>> _executeSetDueDate(Map<String, dynamic> args, {required TabType tabType, List<TaskEntity>? availableTasks}) async {
    final taskId = args['taskId'] as String?;
    final dueDateStr = args['dueDate'] as String?;

    if (taskId == null) {
      return {'success': false, 'error': 'taskId is required'};
    }
    if (dueDateStr == null) {
      return {'success': false, 'error': 'dueDate is required'};
    }

    final allTasks = availableTasks ?? ref.read(taskListControllerProvider).tasks.where((e) => !e.isEventDummyTask).toList();
    final task = allTasks.firstWhere((t) => t.id == taskId, orElse: () => throw Exception('Task not found'));

    DateTime? dueDate;
    try {
      dueDate = DateTime.parse(dueDateStr);
      if (dueDate.isUtc) dueDate = dueDate.toLocal();
    } catch (e) {
      return {'success': false, 'error': 'Invalid dueDate format'};
    }

    // Due date는 endAt으로 설정하거나, 별도 필드가 있으면 그것을 사용
    final updatedTask = task.copyWith(endAt: dueDate, updatedAt: DateTime.now());
    await TaskAction.upsertTask(task: updatedTask, originalTask: task, calendarTaskEditSourceType: CalendarTaskEditSourceType.inboxDrag, tabType: tabType, showToast: false);

    return {'success': true, 'taskId': updatedTask.id, 'message': 'Due date set successfully'};
  }

  Future<Map<String, dynamic>> _executeSetReminder(
    Map<String, dynamic> args, {
    required TabType tabType,
    List<TaskEntity>? availableTasks,
    List<EventEntity>? availableEvents,
  }) async {
    final taskId = args['taskId'] as String?;
    final eventId = args['eventId'] as String?;
    final minutes = args['minutes'] as int?;
    final method = args['method'] as String? ?? 'push';

    if ((taskId == null && eventId == null) || minutes == null) {
      return {'success': false, 'error': 'taskId or eventId and minutes are required'};
    }

    try {
      if (taskId != null) {
        final allTasks = availableTasks ?? ref.read(taskListControllerProvider).tasks.where((e) => !e.isEventDummyTask).toList();
        final task = allTasks.firstWhereOrNull((t) => t.id == taskId);

        if (task == null) {
          return {'success': false, 'error': 'Task not found'};
        }

        final reminders = [EventReminderEntity(method: method, minutes: minutes)];
        final updatedTask = task.copyWith(reminders: reminders, updatedAt: DateTime.now());
        await TaskAction.upsertTask(task: updatedTask, originalTask: task, calendarTaskEditSourceType: CalendarTaskEditSourceType.inboxDrag, tabType: tabType, showToast: false);

        return {'success': true, 'message': 'Reminder set successfully'};
      } else {
        final allEvents = availableEvents ?? ref.read(calendarEventListControllerProvider(tabType: tabType)).eventsOnView;
        final event = allEvents.firstWhereOrNull((e) => e.eventId == eventId);

        if (event == null) {
          return {'success': false, 'error': 'Event not found'};
        }

        final reminders = [EventReminderEntity(method: method, minutes: minutes)];
        final updatedEvent = event.copyWith(reminders: reminders);
        await CalendarAction.editCalendarEvent(
          tabType: tabType,
          originalEvent: event,
          newEvent: updatedEvent,
          selectedStartDate: event.startDate,
          selectedEndDate: event.endDate,
          isCreate: false,
          showToast: false,
        );

        return {'success': true, 'message': 'Reminder set successfully'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Failed to set reminder: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> _executeSetRecurrence(
    Map<String, dynamic> args, {
    required TabType tabType,
    List<TaskEntity>? availableTasks,
    List<EventEntity>? availableEvents,
  }) async {
    final taskId = args['taskId'] as String?;
    final eventId = args['eventId'] as String?;
    final rruleStr = args['rrule'] as String?; // RRULE 형식 문자열 (예: "FREQ=DAILY;INTERVAL=1")

    if ((taskId == null && eventId == null) || rruleStr == null || rruleStr.isEmpty) {
      return {'success': false, 'error': 'taskId or eventId and rrule are required'};
    }

    try {
      RecurrenceRule? rrule;
      try {
        rrule = RecurrenceRule.fromString(rruleStr);
      } catch (e) {
        return {'success': false, 'error': 'Invalid rrule format: ${e.toString()}'};
      }

      if (taskId != null) {
        final allTasks = availableTasks ?? ref.read(taskListControllerProvider).tasks.where((e) => !e.isEventDummyTask).toList();
        final task = allTasks.firstWhereOrNull((t) => t.id == taskId);

        if (task == null) {
          return {'success': false, 'error': 'Task not found'};
        }

        final recurrenceEndAt = rrule.until ?? (rrule.count != null ? (task.startAt?.add(Duration(days: 365)) ?? DateTime(3000)) : DateTime(3000));
        final updatedTask = task.copyWith(rrule: rrule, recurrenceEndAt: recurrenceEndAt, updatedAt: DateTime.now());
        await TaskAction.upsertTask(task: updatedTask, originalTask: task, calendarTaskEditSourceType: CalendarTaskEditSourceType.inboxDrag, tabType: tabType, showToast: false);

        return {'success': true, 'message': 'Recurrence set successfully'};
      } else {
        final allEvents = availableEvents ?? ref.read(calendarEventListControllerProvider(tabType: tabType)).eventsOnView;
        final event = allEvents.firstWhereOrNull((e) => e.eventId == eventId);

        if (event == null) {
          return {'success': false, 'error': 'Event not found'};
        }

        final updatedEvent = event.copyWith(rrule: rrule, modifiedEvent: event);
        await CalendarAction.editCalendarEvent(
          tabType: tabType,
          originalEvent: event,
          newEvent: updatedEvent,
          selectedStartDate: event.startDate,
          selectedEndDate: event.endDate,
          isCreate: false,
          showToast: false,
        );

        return {'success': true, 'message': 'Recurrence set successfully'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Failed to set recurrence: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> _executeDuplicateTask(Map<String, dynamic> args, {required TabType tabType, List<TaskEntity>? availableTasks}) async {
    final taskId = args['taskId'] as String?;

    if (taskId == null || taskId.isEmpty) {
      return {'success': false, 'error': 'taskId is required'};
    }

    try {
      final allTasks = availableTasks ?? ref.read(taskListControllerProvider).tasks.where((e) => !e.isEventDummyTask).toList();
      final task = allTasks.firstWhereOrNull((t) => t.id == taskId);

      if (task == null) {
        return {'success': false, 'error': 'Task not found'};
      }

      final user = ref.read(authControllerProvider).requireValue;
      final duplicatedTask = task.copyWith(
        id: const Uuid().v4(),
        removeRrule: true,
        removeRecurringTaskId: true,
        createdAt: DateTime.now(),
        ownerId: user.id,
        status: TaskStatus.none,
      );

      await TaskAction.upsertTask(task: duplicatedTask, originalTask: null, calendarTaskEditSourceType: CalendarTaskEditSourceType.inboxDrag, tabType: tabType, showToast: false);

      return {'success': true, 'taskId': duplicatedTask.id, 'message': 'Task duplicated successfully'};
    } catch (e) {
      return {'success': false, 'error': 'Failed to duplicate task: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> _executeDuplicateEvent(Map<String, dynamic> args, {required TabType tabType, List<EventEntity>? availableEvents}) async {
    final eventId = args['eventId'] as String?;

    if (eventId == null || eventId.isEmpty) {
      return {'success': false, 'error': 'eventId is required'};
    }

    try {
      final allEvents = availableEvents ?? ref.read(calendarEventListControllerProvider(tabType: tabType)).eventsOnView;
      final event = allEvents.firstWhereOrNull((e) => e.eventId == eventId);

      if (event == null) {
        return {'success': false, 'error': 'Event not found'};
      }

      final duplicatedEvent = event.copyWith(
        id: Utils.generateBase32HexStringFromTimestamp(),
        rrule: null, // 복제 시 반복 규칙 제거
        removeRecurrence: true,
        removeICalUID: true,
        removeRecurringId: true,
      );

      await CalendarAction.editCalendarEvent(
        tabType: tabType,
        originalEvent: null,
        newEvent: duplicatedEvent,
        selectedStartDate: event.startDate,
        selectedEndDate: event.endDate,
        isCreate: true,
        showToast: false,
      );

      return {'success': true, 'eventId': duplicatedEvent.eventId, 'message': 'Event duplicated successfully'};
    } catch (e) {
      return {'success': false, 'error': 'Failed to duplicate event: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> _executeGetTodayTasks(Map<String, dynamic> args, {required TabType tabType}) async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final tomorrow = today.add(const Duration(days: 1));

      final allTasks = ref.read(taskListControllerProvider).tasks;
      final todayTasks = allTasks.where((t) {
        if (t.isCancelled || t.isOriginalRecurrenceTask || t.isEventDummyTask) return false;
        if (t.status == TaskStatus.done) return false;
        final taskStart = t.startDate;
        return !taskStart.isBefore(today) && taskStart.isBefore(tomorrow);
      }).toList();

      final results = todayTasks.map((task) {
        return {
          'id': task.id,
          'title': task.title,
          'description': task.description,
          'status': task.status.name,
          'projectId': task.projectId,
          'startAt': task.startAt?.toIso8601String(),
          'endAt': task.endAt?.toIso8601String(),
          'isAllDay': task.isAllDay,
        };
      }).toList();

      return {'success': true, 'results': results, 'message': '오늘 ${results.length}개의 작업이 있습니다.'};
    } catch (e) {
      return {'success': false, 'error': 'Failed to get today tasks: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> _executeGetTodayEvents(Map<String, dynamic> args, {required TabType tabType}) async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final tomorrow = today.add(const Duration(days: 1));

      final allEvents = ref.read(calendarEventListControllerProvider(tabType: tabType)).eventsOnView;
      final todayEvents = allEvents.where((e) {
        final eventStart = e.startDate;
        return eventStart.isAfter(today) && eventStart.isBefore(tomorrow);
      }).toList();

      final results = todayEvents.map((event) {
        return {
          'id': event.eventId,
          'uniqueId': event.uniqueId,
          'title': event.title,
          'description': event.description,
          'calendarId': event.calendarId,
          'startAt': event.startDate.toIso8601String(),
          'endAt': event.endDate.toIso8601String(),
          'isAllDay': event.isAllDay,
          'location': event.location,
        };
      }).toList();

      return {'success': true, 'results': results, 'message': '오늘 ${results.length}개의 일정이 있습니다.'};
    } catch (e) {
      return {'success': false, 'error': 'Failed to get today events: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> _executeGetUpcomingTasks(Map<String, dynamic> args, {required TabType tabType}) async {
    final limit = args['limit'] as int? ?? 10;

    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final allTasks = ref.read(taskListControllerProvider).tasks;
      final upcomingTasks = allTasks.where((t) {
        if (t.isCancelled || t.isOriginalRecurrenceTask || t.isEventDummyTask) return false;
        if (t.status != TaskStatus.none) return false;
        if (t.isOverdue || t.isUnscheduled) return false;
        final taskStart = t.startDate;
        return taskStart.isAfter(today);
      }).toList()..sort((a, b) => a.startDate.compareTo(b.startDate));

      final limitedTasks = upcomingTasks.take(limit).toList();

      final results = limitedTasks.map((task) {
        return {
          'id': task.id,
          'title': task.title,
          'description': task.description,
          'status': task.status.name,
          'projectId': task.projectId,
          'startAt': task.startAt?.toIso8601String(),
          'endAt': task.endAt?.toIso8601String(),
          'isAllDay': task.isAllDay,
        };
      }).toList();

      return {'success': true, 'results': results, 'message': '다가오는 작업 ${results.length}개를 찾았습니다.'};
    } catch (e) {
      return {'success': false, 'error': 'Failed to get upcoming tasks: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> _executeGetUpcomingEvents(Map<String, dynamic> args, {required TabType tabType}) async {
    final limit = args['limit'] as int? ?? 10;

    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final allEvents = ref.read(calendarEventListControllerProvider(tabType: tabType)).eventsOnView;
      final upcomingEvents = allEvents.where((e) {
        final eventStart = e.startDate;
        return eventStart.isAfter(today);
      }).toList()..sort((a, b) => a.startDate.compareTo(b.startDate));

      final limitedEvents = upcomingEvents.take(limit).toList();

      final results = limitedEvents.map((event) {
        return {
          'id': event.eventId,
          'uniqueId': event.uniqueId,
          'title': event.title,
          'description': event.description,
          'calendarId': event.calendarId,
          'startAt': event.startDate.toIso8601String(),
          'endAt': event.endDate.toIso8601String(),
          'isAllDay': event.isAllDay,
          'location': event.location,
        };
      }).toList();

      return {'success': true, 'results': results, 'message': '다가오는 일정 ${results.length}개를 찾았습니다.'};
    } catch (e) {
      return {'success': false, 'error': 'Failed to get upcoming events: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> _executeGetOverdueTasks(Map<String, dynamic> args, {required TabType tabType}) async {
    try {
      final allTasks = ref.read(taskListControllerProvider).tasks;
      final overdueTasks = allTasks.where((t) {
        if (t.isCancelled || t.isOriginalRecurrenceTask || t.isEventDummyTask) return false;
        return t.status == TaskStatus.none && t.isOverdue && !t.isUnscheduled;
      }).toList()..sort((a, b) => a.startDate.compareTo(b.startDate));

      final results = overdueTasks.map((task) {
        return {
          'id': task.id,
          'title': task.title,
          'description': task.description,
          'status': task.status.name,
          'projectId': task.projectId,
          'startAt': task.startAt?.toIso8601String(),
          'endAt': task.endAt?.toIso8601String(),
          'isAllDay': task.isAllDay,
        };
      }).toList();

      return {'success': true, 'results': results, 'message': '지연된 작업 ${results.length}개를 찾았습니다.'};
    } catch (e) {
      return {'success': false, 'error': 'Failed to get overdue tasks: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> _executeGetUnscheduledTasks(Map<String, dynamic> args, {required TabType tabType}) async {
    try {
      final allTasks = ref.read(taskListControllerProvider).tasks;
      final unscheduledTasks = allTasks.where((t) {
        if (t.isCancelled || t.isOriginalRecurrenceTask || t.isEventDummyTask) return false;
        return t.status == TaskStatus.none && t.isUnscheduled;
      }).toList()..sort((a, b) => (a.updatedAt ?? a.createdAt ?? DateTime(1000)).compareTo(b.updatedAt ?? b.createdAt ?? DateTime(1000)));

      final results = unscheduledTasks.map((task) {
        return {
          'id': task.id,
          'title': task.title,
          'description': task.description,
          'status': task.status.name,
          'projectId': task.projectId,
          'createdAt': task.createdAt?.toIso8601String(),
          'updatedAt': task.updatedAt?.toIso8601String(),
        };
      }).toList();

      return {'success': true, 'results': results, 'message': '스케줄되지 않은 작업 ${results.length}개를 찾았습니다.'};
    } catch (e) {
      return {'success': false, 'error': 'Failed to get unscheduled tasks: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> _executeGetCompletedTasks(Map<String, dynamic> args, {required TabType tabType}) async {
    final limit = args['limit'] as int?;

    try {
      final allTasks = ref.read(taskListControllerProvider).tasks;
      final completedTasks = allTasks.where((t) {
        if (t.isCancelled || t.isOriginalRecurrenceTask || t.isEventDummyTask) return false;
        return t.status == TaskStatus.done;
      }).toList()..sort((a, b) => (b.updatedAt ?? b.createdAt ?? DateTime(1000)).compareTo(a.updatedAt ?? a.createdAt ?? DateTime(1000)));

      final limitedTasks = limit != null && limit > 0 ? completedTasks.take(limit).toList() : completedTasks;

      final results = limitedTasks.map((task) {
        return {
          'id': task.id,
          'title': task.title,
          'description': task.description,
          'status': task.status.name,
          'projectId': task.projectId,
          'startAt': task.startAt?.toIso8601String(),
          'endAt': task.endAt?.toIso8601String(),
          'completedAt': task.updatedAt?.toIso8601String(),
        };
      }).toList();

      return {'success': true, 'results': results, 'message': '완료된 작업 ${results.length}개를 찾았습니다.'};
    } catch (e) {
      return {'success': false, 'error': 'Failed to get completed tasks: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> _executeRemoveReminder(
    Map<String, dynamic> args, {
    required TabType tabType,
    List<TaskEntity>? availableTasks,
    List<EventEntity>? availableEvents,
  }) async {
    final taskId = args['taskId'] as String?;
    final eventId = args['eventId'] as String?;

    if (taskId == null && eventId == null) {
      return {'success': false, 'error': 'taskId or eventId is required'};
    }

    try {
      if (taskId != null) {
        final allTasks = availableTasks ?? ref.read(taskListControllerProvider).tasks.where((e) => !e.isEventDummyTask).toList();
        final task = allTasks.firstWhereOrNull((t) => t.id == taskId);

        if (task == null) {
          return {'success': false, 'error': 'Task not found'};
        }

        final updatedTask = task.copyWith(reminders: [], updatedAt: DateTime.now());
        await TaskAction.upsertTask(task: updatedTask, originalTask: task, calendarTaskEditSourceType: CalendarTaskEditSourceType.inboxDrag, tabType: tabType, showToast: false);

        return {'success': true, 'message': 'Reminder removed successfully'};
      } else {
        final allEvents = availableEvents ?? ref.read(calendarEventListControllerProvider(tabType: tabType)).eventsOnView;
        final event = allEvents.firstWhereOrNull((e) => e.eventId == eventId);

        if (event == null) {
          return {'success': false, 'error': 'Event not found'};
        }

        final updatedEvent = event.copyWith(reminders: [], modifiedEvent: event);
        await CalendarAction.editCalendarEvent(
          tabType: tabType,
          originalEvent: event,
          newEvent: updatedEvent,
          selectedStartDate: event.startDate,
          selectedEndDate: event.endDate,
          isCreate: false,
          showToast: false,
        );

        return {'success': true, 'message': 'Reminder removed successfully'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Failed to remove reminder: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> _executeRemoveRecurrence(
    Map<String, dynamic> args, {
    required TabType tabType,
    List<TaskEntity>? availableTasks,
    List<EventEntity>? availableEvents,
  }) async {
    final taskId = args['taskId'] as String?;
    final eventId = args['eventId'] as String?;

    if (taskId == null && eventId == null) {
      return {'success': false, 'error': 'taskId or eventId is required'};
    }

    try {
      if (taskId != null) {
        final allTasks = availableTasks ?? ref.read(taskListControllerProvider).tasks.where((e) => !e.isEventDummyTask).toList();
        final task = allTasks.firstWhereOrNull((t) => t.id == taskId);

        if (task == null) {
          return {'success': false, 'error': 'Task not found'};
        }

        final updatedTask = task.copyWith(removeRrule: true, recurrenceEndAt: null, updatedAt: DateTime.now());
        await TaskAction.upsertTask(task: updatedTask, originalTask: task, calendarTaskEditSourceType: CalendarTaskEditSourceType.inboxDrag, tabType: tabType, showToast: false);

        return {'success': true, 'message': 'Recurrence removed successfully'};
      } else {
        final allEvents = availableEvents ?? ref.read(calendarEventListControllerProvider(tabType: tabType)).eventsOnView;
        final event = allEvents.firstWhereOrNull((e) => e.eventId == eventId);

        if (event == null) {
          return {'success': false, 'error': 'Event not found'};
        }

        final updatedEvent = event.copyWith(removeRecurrence: true, modifiedEvent: event);
        await CalendarAction.editCalendarEvent(
          tabType: tabType,
          originalEvent: event,
          newEvent: updatedEvent,
          selectedStartDate: event.startDate,
          selectedEndDate: event.endDate,
          isCreate: false,
          showToast: false,
        );

        return {'success': true, 'message': 'Recurrence removed successfully'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Failed to remove recurrence: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> _executeGetInboxDetails(Map<String, dynamic> args, {required TabType tabType}) async {
    final inboxId = args['inboxId'] as String?;

    if (inboxId == null || inboxId.isEmpty) {
      return {'success': false, 'error': 'inboxId is required'};
    }

    try {
      final inboxList = ref.read(inboxListControllerProvider);
      final inboxes = inboxList?.inboxes ?? [];
      final inbox = inboxes.firstWhereOrNull((i) => i.id == inboxId);

      if (inbox == null) {
        return {'success': false, 'error': 'Inbox not found'};
      }

      return {
        'success': true,
        'result': {
          'id': inbox.id,
          'title': inbox.title,
          'description': inbox.description,
          'isPinned': inbox.isPinned ?? false,
          'isSuggestion': inbox.isSuggestion ?? false,
          'hasLinkedMail': inbox.linkedMail != null,
          'hasLinkedMessage': inbox.linkedMessage != null,
          'hasLinkedTask': inbox.linkedTask != null,
          'datetime': inbox.inboxDatetime.toIso8601String(),
        },
        'message': '인박스 정보를 가져왔습니다.',
      };
    } catch (e) {
      return {'success': false, 'error': 'Failed to get inbox details: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> _executeListInboxes(Map<String, dynamic> args, {required TabType tabType}) async {
    final isPinned = args['isPinned'] as bool?;
    final hasLinkedTask = args['hasLinkedTask'] as bool?;
    final limit = args['limit'] as int?;

    try {
      final inboxList = ref.read(inboxListControllerProvider);
      var inboxes = inboxList?.inboxes ?? [];

      // Filter by pinned status
      if (isPinned != null) {
        inboxes = inboxes.where((i) => (i.isPinned ?? false) == isPinned).toList();
      }

      // Filter by linked task
      if (hasLinkedTask != null) {
        inboxes = inboxes.where((i) => (i.linkedTask != null) == hasLinkedTask).toList();
      }

      // Apply limit
      if (limit != null && limit > 0) {
        inboxes = inboxes.take(limit).toList();
      }

      final results = inboxes.map((inbox) {
        return {
          'id': inbox.id,
          'title': inbox.title,
          'description': inbox.description,
          'isPinned': inbox.isPinned ?? false,
          'isSuggestion': inbox.isSuggestion ?? false,
          'hasLinkedTask': inbox.linkedTask != null,
          'datetime': inbox.inboxDatetime.toIso8601String(),
        };
      }).toList();

      return {'success': true, 'results': results, 'message': '${results.length}개의 인박스를 찾았습니다.'};
    } catch (e) {
      return {'success': false, 'error': 'Failed to list inboxes: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> _executeGetProjectDetails(Map<String, dynamic> args) async {
    final projectId = args['projectId'] as String?;

    if (projectId == null || projectId.isEmpty) {
      return {'success': false, 'error': 'projectId is required'};
    }

    try {
      final projects = ref.read(projectListControllerProvider);
      final project = projects.firstWhereOrNull((p) => p.uniqueId == projectId);

      if (project == null) {
        return {'success': false, 'error': 'Project not found'};
      }

      // 프로젝트에 속한 작업 개수 계산
      final allTasks = ref.read(taskListControllerProvider).tasks;
      final projectTasks = allTasks.where((t) => t.projectId == projectId && !t.isCancelled && !t.isOriginalRecurrenceTask && !t.isEventDummyTask).toList();
      final taskCount = projectTasks.length;
      final doneTaskCount = projectTasks.where((t) => t.status == TaskStatus.done).length;

      return {
        'success': true,
        'result': {
          'id': project.uniqueId,
          'name': project.name,
          'description': project.description,
          'parentId': project.parentId,
          'taskCount': taskCount,
          'doneTaskCount': doneTaskCount,
          'pendingTaskCount': taskCount - doneTaskCount,
        },
        'message': '프로젝트 정보를 가져왔습니다.',
      };
    } catch (e) {
      return {'success': false, 'error': 'Failed to get project details: ${e.toString()}'};
    }
  }

  // Schedule optimization
  Future<Map<String, dynamic>> _executeOptimizeSchedule(
    Map<String, dynamic> args, {
    required TabType tabType,
    List<TaskEntity>? availableTasks,
    List<EventEntity>? availableEvents,
  }) async {
    final taskId = args['taskId'] as String?;
    final eventId = args['eventId'] as String?;

    if (taskId == null && eventId == null) {
      return {'success': false, 'error': 'Either taskId or eventId is required'};
    }

    // Get all tasks and events to find available time slots
    final allTasks = availableTasks ?? ref.read(taskListControllerProvider).tasks.where((e) => !e.isEventDummyTask && e.startAt != null).toList();
    final allEvents = availableEvents ?? ref.read(calendarEventListControllerProvider(tabType: tabType)).eventsOnView.where((e) => e.startDate != null).toList();

    // Find the item to optimize
    TaskEntity? task;
    EventEntity? event;
    Duration? duration;

    if (taskId != null) {
      task = allTasks.firstWhereOrNull((t) => t.id == taskId);
      if (task == null) {
        return {'success': false, 'error': 'Task not found'};
      }
      final taskStartAt = task.startAt;
      final taskEndAt = task.endAt;
      duration = taskEndAt != null && taskStartAt != null ? taskEndAt.difference(taskStartAt) : const Duration(hours: 1);
    } else if (eventId != null) {
      event = allEvents.firstWhereOrNull((e) => e.eventId == eventId);
      if (event == null) {
        return {'success': false, 'error': 'Event not found'};
      }
      duration = event.endDate.difference(event.startDate);
    }

    if (duration == null) {
      return {'success': false, 'error': 'Could not determine duration'};
    }

    // Find the best available time slot
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final nextWeek = today.add(const Duration(days: 7));

    // Get all scheduled items
    final scheduledItems = <DateTime, DateTime>{};
    for (final t in allTasks) {
      if (t.startAt != null && t.endAt != null && !t.isCancelled && t.status != TaskStatus.done) {
        scheduledItems[t.startAt!] = t.endAt!;
      }
    }
    for (final e in allEvents) {
      final startDate = e.startDate;
      final endDate = e.endDate;
      if (startDate != null && endDate != null) {
        scheduledItems[startDate] = endDate;
      }
    }

    // Find first available slot
    DateTime? bestStartTime;
    DateTime currentTime = now;

    while (currentTime.isBefore(nextWeek)) {
      final endTime = currentTime.add(duration);
      bool isAvailable = true;

      // Check if this slot conflicts with any scheduled item
      for (final entry in scheduledItems.entries) {
        final scheduledStart = entry.key;
        final scheduledEnd = entry.value;

        if ((currentTime.isBefore(scheduledEnd) && endTime.isAfter(scheduledStart))) {
          isAvailable = false;
          // Move to after this conflicting item
          currentTime = scheduledEnd;
          break;
        }
      }

      if (isAvailable) {
        bestStartTime = currentTime;
        break;
      }

      // Move to next hour if no conflict found but slot is not available
      if (currentTime == now) {
        currentTime = currentTime.add(const Duration(hours: 1));
      }
    }

    if (bestStartTime == null) {
      return {'success': false, 'error': 'No available time slot found in the next week'};
    }

    final bestEndTime = bestStartTime.add(duration);

    if (task != null) {
      final updatedTask = task.copyWith(startAt: bestStartTime, endAt: bestEndTime, updatedAt: DateTime.now());
      await TaskAction.upsertTask(task: updatedTask, originalTask: task, calendarTaskEditSourceType: CalendarTaskEditSourceType.inboxDrag, tabType: tabType, showToast: false);
      return {
        'success': true,
        'taskId': updatedTask.id,
        'startAt': bestStartTime.toIso8601String(),
        'endAt': bestEndTime.toIso8601String(),
        'message': 'Task schedule optimized successfully',
      };
    } else if (event != null) {
      final updatedEvent = event.copyWith(startDate: bestStartTime, endDate: bestEndTime);
      await CalendarAction.editCalendarEvent(
        originalEvent: event,
        newEvent: updatedEvent,
        calendarTaskEditSourceType: CalendarTaskEditSourceType.inboxDrag,
        tabType: tabType,
        selectedStartDate: bestStartTime,
        selectedEndDate: bestEndTime,
        showToast: false,
        isCreate: false,
      );
      return {
        'success': true,
        'eventId': updatedEvent.eventId,
        'startDate': bestStartTime.toIso8601String(),
        'endDate': bestEndTime.toIso8601String(),
        'message': 'Event schedule optimized successfully',
      };
    }

    return {'success': false, 'error': 'Unknown error'};
  }

  // Reschedule multiple tasks to today with optimal time slots
  Future<Map<String, dynamic>> _executeReschedule(
    Map<String, dynamic> args, {
    required TabType tabType,
    List<TaskEntity>? availableTasks,
    List<EventEntity>? availableEvents,
  }) async {
    final taskIds = args['taskIds'] as List<dynamic>?;

    if (taskIds == null || taskIds.isEmpty) {
      return {'success': false, 'error': 'taskIds is required and must not be empty'};
    }

    // Get all tasks and events for conflict checking
    // Use full task/event lists to check for conflicts, not just the ones being rescheduled
    final Iterable<TaskEntity> allTasksForConflictCheck = ref.read(taskListControllerProvider).tasks.where((e) => !e.isEventDummyTask && e.startAt != null && e.endAt != null);
    final Iterable<EventEntity> allEventsForConflictCheck = ref
        .read(calendarEventListControllerProvider(tabType: tabType))
        .eventsOnView
        .where((e) => e.startDate != null && e.endDate != null);

    // Find tasks to reschedule from availableTasks or all tasks
    final tasksToReschedule = <TaskEntity>[];
    final allTasksMap = <String, TaskEntity>{};

    // Build a map of all tasks for quick lookup
    if (availableTasks != null) {
      for (final task in availableTasks) {
        if (task.id != null) {
          allTasksMap[task.id!] = task;
        }
      }
    } else {
      for (final task in ref.read(taskListControllerProvider).tasks) {
        if (!task.isEventDummyTask && task.id != null) {
          allTasksMap[task.id!] = task;
        }
      }
    }

    // Get tasks to reschedule
    for (final taskId in taskIds) {
      final taskIdStr = taskId?.toString() ?? '';
      if (taskIdStr.isEmpty) continue;
      final task = allTasksMap[taskIdStr];
      if (task != null && task.recurringTaskId == null) {
        // Exclude recurring task instances
        final taskStartDate = task.startAt ?? task.startDate;
        final today = DateUtils.dateOnly(DateTime.now());
        // Exclude tasks already scheduled for today
        if (DateUtils.dateOnly(taskStartDate) != today) {
          tasksToReschedule.add(task);
        }
      }
    }

    if (tasksToReschedule.isEmpty) {
      return {'success': false, 'error': 'No valid tasks to reschedule'};
    }

    // Find the best available time slots
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    // Get all scheduled items (excluding tasks being rescheduled)
    final scheduledItems = <DateTime, DateTime>{};
    final allTasksList = allTasksForConflictCheck.toList();
    final allEventsList = allEventsForConflictCheck.toList();
    final reschedulingTaskIds = tasksToReschedule.map((t) => t.id).toSet();

    for (final t in allTasksList) {
      if (!t.isCancelled && t.status != TaskStatus.done) {
        // Exclude tasks being rescheduled
        if (!reschedulingTaskIds.contains(t.id)) {
          // Exclude all-day tasks from conflict checking (they don't occupy time slots)
          if (t.isAllDay != true) {
            scheduledItems[t.startAt!] = t.endAt!;
          }
        }
      }
    }
    for (final e in allEventsList) {
      // Exclude all-day events from conflict checking (they don't occupy time slots)
      if (e.isAllDay != true) {
        scheduledItems[e.startDate!] = e.endDate!;
      }
    }

    // Sort tasks by priority/duration (shorter tasks first for better scheduling)
    tasksToReschedule.sort((a, b) {
      final aDuration = (a.endAt ?? a.startAt?.add(const Duration(hours: 1)) ?? today.add(const Duration(hours: 1))).difference(a.startAt ?? today);
      final bDuration = (b.endAt ?? b.startAt?.add(const Duration(hours: 1)) ?? today.add(const Duration(hours: 1))).difference(b.startAt ?? today);
      return aDuration.compareTo(bDuration);
    });

    // Schedule each task to the best available slot today
    final results = <Map<String, dynamic>>[];
    DateTime currentTime = now.roundUp(delta: const Duration(minutes: 15));

    for (final task in tasksToReschedule) {
      final taskStartAt = task.startAt;
      final taskEndAt = task.endAt;
      final taskIsAllDay = task.isAllDay ?? false;

      // Calculate duration from original task
      Duration duration;
      if (taskEndAt != null && taskStartAt != null) {
        if (taskIsAllDay) {
          // For all-day tasks, when rescheduling to time slots, use a reasonable default duration (1-2 hours)
          // instead of the full day duration
          final adjustedEndAt = taskEndAt.subtract(const Duration(days: 1));
          final daysDiff = DateUtils.dateOnly(adjustedEndAt).difference(DateUtils.dateOnly(taskStartAt)).inDays;

          // If it's a single day all-day task, use 1 hour
          // If it spans multiple days, use 1 hour per day (max 2 hours for reasonable scheduling)
          if (daysDiff <= 0) {
            duration = const Duration(hours: 1);
          } else {
            duration = Duration(hours: daysDiff + 1);
            // Cap at 2 hours for reasonable time slot scheduling
            if (duration.inHours > 2) {
              duration = const Duration(hours: 2);
            }
          }
        } else {
          duration = taskEndAt.difference(taskStartAt);
        }
      } else {
        duration = const Duration(hours: 1);
      }

      // Use minimum 15 minutes duration, cap at 2 hours for reasonable scheduling
      final finalDuration = duration.inMinutes < 15 ? const Duration(minutes: 15) : (duration.inHours > 2 ? const Duration(hours: 2) : duration);

      DateTime? bestStartTime;
      DateTime? bestEndTime;
      bool finalIsAllDay;

      if (taskIsAllDay) {
        // For all-day tasks, set to today with same start and end date (date only, no time)
        bestStartTime = DateUtils.dateOnly(today);
        bestEndTime = DateUtils.dateOnly(today);
        finalIsAllDay = true;
      } else {
        // For timed tasks, find time slot
        // Ensure searchTime is within today's range
        DateTime searchTime = currentTime;
        final endOfDay = DateTime(today.year, today.month, today.day, 23, 59);

        // If currentTime is already past today or tomorrow, reset to current time rounded up
        if (DateUtils.dateOnly(searchTime).isAfter(today)) {
          searchTime = now.roundUp(delta: const Duration(minutes: 15));
        }

        // Ensure searchTime is not before now
        if (searchTime.isBefore(now)) {
          searchTime = now.roundUp(delta: const Duration(minutes: 15));
        }

        while (searchTime.isBefore(endOfDay)) {
          final endTime = searchTime.add(finalDuration);
          bool isAvailable = true;

          // Check if this slot conflicts with any scheduled item
          for (final entry in scheduledItems.entries) {
            final scheduledStart = entry.key;
            final scheduledEnd = entry.value;

            if ((searchTime.isBefore(scheduledEnd) && endTime.isAfter(scheduledStart))) {
              isAvailable = false;
              // Move to after this conflicting item
              searchTime = scheduledEnd;
              break;
            }
          }

          if (isAvailable) {
            bestStartTime = searchTime;
            bestEndTime = endTime;
            break;
          }

          // Move to next 15-minute slot
          searchTime = searchTime.add(const Duration(minutes: 15));
        }

        // If no slot found today, try tomorrow morning
        if (bestStartTime == null) {
          final tomorrowMorning = DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 9, 0);
          bestStartTime = tomorrowMorning;
          bestEndTime = tomorrowMorning.add(finalDuration);
        }

        finalIsAllDay = false;
      }

      final updatedTask = task.copyWith(startAt: bestStartTime, endAt: bestEndTime, updatedAt: DateTime.now(), isAllDay: finalIsAllDay);

      await TaskAction.upsertTask(task: updatedTask, originalTask: task, calendarTaskEditSourceType: CalendarTaskEditSourceType.inboxDrag, tabType: tabType, showToast: false);

      // Add to scheduled items to avoid conflicts with next tasks (only for timed tasks)
      if (!finalIsAllDay && bestStartTime != null && bestEndTime != null) {
        scheduledItems[bestStartTime] = bestEndTime;
        // Update currentTime to after this task, but only if it's still today
        // If task was scheduled for tomorrow, keep currentTime for today's search
        if (DateUtils.dateOnly(bestEndTime) == today) {
          currentTime = bestEndTime;
        } else {
          // If scheduled for tomorrow, reset currentTime to continue searching today
          currentTime = now.roundUp(delta: const Duration(minutes: 15));
        }
      }

      results.add({'taskId': updatedTask.id, 'startAt': bestStartTime?.toIso8601String() ?? '', 'endAt': bestEndTime?.toIso8601String() ?? ''});
    }

    return {'success': true, 'results': results, 'message': '${results.length}개의 작업이 오늘 적절한 시간에 재스케줄되었습니다.'};
  }

  // Project actions
  Future<Map<String, dynamic>> _executeCreateProject(Map<String, dynamic> args) async {
    final name = args['name'] as String?;
    final description = args['description'] as String?;

    if (name == null || name.isEmpty) {
      return {'success': false, 'error': 'name is required'};
    }

    final user = ref.read(authControllerProvider).requireValue;
    final projectId = const Uuid().v4();

    final project = ProjectEntity(id: projectId, ownerId: user.id, name: name, description: description, createdAt: DateTime.now(), updatedAt: DateTime.now());

    await ref.read(projectListControllerProvider.notifier).addProject(project);

    return {'success': true, 'projectId': projectId, 'message': 'Project created successfully'};
  }

  Future<Map<String, dynamic>> _executeUpdateProject(Map<String, dynamic> args) async {
    final projectId = args['projectId'] as String?;
    final name = args['name'] as String?;
    final description = args['description'] as String?;

    if (projectId == null || projectId.isEmpty) {
      return {'success': false, 'error': 'projectId is required'};
    }

    final projects = ref.read(projectListControllerProvider);
    final project = projects.firstWhereOrNull((p) => p.uniqueId == projectId);

    if (project == null) {
      return {'success': false, 'error': 'Project not found'};
    }

    final updatedProject = project.copyWith(
      parentId: project.parentId,
      icon: project.icon,
      name: name ?? project.name,
      description: description ?? project.description,
      updatedAt: DateTime.now(),
    );

    await ref.read(projectListControllerProvider.notifier).addProject(updatedProject);

    return {'success': true, 'message': 'Project updated successfully'};
  }

  Future<Map<String, dynamic>> _executeDeleteProject(Map<String, dynamic> args) async {
    final projectId = args['projectId'] as String?;

    if (projectId == null || projectId.isEmpty) {
      return {'success': false, 'error': 'projectId is required'};
    }

    final projects = ref.read(projectListControllerProvider);
    final project = projects.firstWhereOrNull((p) => p.uniqueId == projectId);

    if (project == null) {
      return {'success': false, 'error': 'Project not found'};
    }

    await ref.read(projectListControllerProvider.notifier).deleteProject(projectId);

    return {'success': true, 'message': 'Project deleted successfully'};
  }

  Future<Map<String, dynamic>> _executeSearchProject(Map<String, dynamic> args) async {
    final query = args['query'] as String?;

    if (query == null || query.isEmpty) {
      return {'success': false, 'error': 'query is required'};
    }

    final projects = ref.read(projectListControllerProvider);
    final queryLower = query.toLowerCase();

    final results = projects
        .where((project) {
          final nameMatch = project.name.toLowerCase().contains(queryLower);
          final descriptionMatch = project.description?.toLowerCase().contains(queryLower) ?? false;
          return nameMatch || descriptionMatch;
        })
        .map((project) {
          return {'id': project.uniqueId, 'name': project.name, 'description': project.description};
        })
        .toList();

    return {'success': true, 'results': results, 'message': '${results.length}개의 프로젝트를 찾았습니다.'};
  }

  Future<Map<String, dynamic>> _executeListTasks(Map<String, dynamic> args, {required TabType tabType}) async {
    final projectId = args['projectId'] as String?;
    final status = args['status'] as String?; // 'none', 'done', 'cancelled'
    final startDate = args['startDate'] as String?; // ISO 8601 format
    final endDate = args['endDate'] as String?; // ISO 8601 format
    final limit = args['limit'] as int?;

    try {
      final allTasks = ref.read(taskListControllerProvider).tasks;
      var filteredTasks = allTasks.where((t) => !t.isCancelled && !t.isOriginalRecurrenceTask && !t.isEventDummyTask).toList();

      // Filter by project
      if (projectId != null && projectId.isNotEmpty) {
        filteredTasks = filteredTasks.where((t) => t.projectId == projectId).toList();
      }

      // Filter by status
      if (status != null) {
        TaskStatus? taskStatus;
        switch (status.toLowerCase()) {
          case 'none':
            taskStatus = TaskStatus.none;
            break;
          case 'done':
            taskStatus = TaskStatus.done;
            break;
          case 'cancelled':
            taskStatus = TaskStatus.cancelled;
            break;
        }
        if (taskStatus != null) {
          filteredTasks = filteredTasks.where((t) => t.status == taskStatus).toList();
        }
      }

      // Filter by date range
      if (startDate != null || endDate != null) {
        DateTime? startDateTime;
        DateTime? endDateTime;

        if (startDate != null) {
          try {
            startDateTime = DateTime.parse(startDate).toLocal();
          } catch (e) {
            // Invalid date format
          }
        }

        if (endDate != null) {
          try {
            endDateTime = DateTime.parse(endDate).toLocal();
          } catch (e) {
            // Invalid date format
          }
        }

        if (startDateTime != null || endDateTime != null) {
          filteredTasks = filteredTasks.where((t) {
            final taskStart = t.startDate;
            if (startDateTime != null && taskStart.isBefore(startDateTime)) return false;
            if (endDateTime != null && taskStart.isAfter(endDateTime)) return false;
            return true;
          }).toList();
        }
      }

      // Apply limit
      if (limit != null && limit > 0) {
        filteredTasks = filteredTasks.take(limit).toList();
      }

      final results = filteredTasks.map((task) {
        return {
          'id': task.id,
          'title': task.title,
          'description': task.description,
          'status': task.status.name,
          'projectId': task.projectId,
          'startAt': task.startAt?.toIso8601String(),
          'endAt': task.endAt?.toIso8601String(),
          'isAllDay': task.isAllDay,
        };
      }).toList();

      return {'success': true, 'results': results, 'message': '${results.length}개의 작업을 찾았습니다.'};
    } catch (e) {
      return {'success': false, 'error': 'Failed to list tasks: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> _executeListEvents(Map<String, dynamic> args, {required TabType tabType}) async {
    final startDate = args['startDate'] as String?; // ISO 8601 format
    final endDate = args['endDate'] as String?; // ISO 8601 format
    final calendarId = args['calendarId'] as String?;
    final limit = args['limit'] as int?;

    try {
      final allEvents = ref.read(calendarEventListControllerProvider(tabType: tabType)).eventsOnView;
      var filteredEvents = allEvents.toList();

      // Filter by calendar
      if (calendarId != null && calendarId.isNotEmpty) {
        filteredEvents = filteredEvents.where((e) => e.calendarId == calendarId).toList();
      }

      // Filter by date range
      if (startDate != null || endDate != null) {
        DateTime? startDateTime;
        DateTime? endDateTime;

        if (startDate != null) {
          try {
            startDateTime = DateTime.parse(startDate).toLocal();
          } catch (e) {
            // Invalid date format
          }
        }

        if (endDate != null) {
          try {
            endDateTime = DateTime.parse(endDate).toLocal();
          } catch (e) {
            // Invalid date format
          }
        }

        if (startDateTime != null || endDateTime != null) {
          filteredEvents = filteredEvents.where((e) {
            final eventStart = e.startDate;
            if (startDateTime != null && eventStart.isBefore(startDateTime)) return false;
            if (endDateTime != null && eventStart.isAfter(endDateTime)) return false;
            return true;
          }).toList();
        }
      }

      // Apply limit
      if (limit != null && limit > 0) {
        filteredEvents = filteredEvents.take(limit).toList();
      }

      final results = filteredEvents.map((event) {
        return {
          'id': event.eventId,
          'uniqueId': event.uniqueId,
          'title': event.title,
          'description': event.description,
          'calendarId': event.calendarId,
          'startAt': event.startDate.toIso8601String(),
          'endAt': event.endDate.toIso8601String(),
          'isAllDay': event.isAllDay,
          'location': event.location,
        };
      }).toList();

      return {'success': true, 'results': results, 'message': '${results.length}개의 일정을 찾았습니다.'};
    } catch (e) {
      return {'success': false, 'error': 'Failed to list events: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> _executeListProjects(Map<String, dynamic> args) async {
    try {
      final projects = ref.read(projectListControllerProvider);

      final results = projects.map((project) {
        return {'id': project.uniqueId, 'name': project.name, 'description': project.description, 'parentId': project.parentId};
      }).toList();

      return {'success': true, 'results': results, 'message': '${results.length}개의 프로젝트를 찾았습니다.'};
    } catch (e) {
      return {'success': false, 'error': 'Failed to list projects: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> _executeGetTaskDetails(Map<String, dynamic> args, {required TabType tabType}) async {
    final taskId = args['taskId'] as String?;

    if (taskId == null || taskId.isEmpty) {
      return {'success': false, 'error': 'taskId is required'};
    }

    try {
      final allTasks = ref.read(taskListControllerProvider).tasks;
      final task = allTasks.firstWhereOrNull((t) => t.id == taskId);

      if (task == null) {
        return {'success': false, 'error': 'Task not found'};
      }

      return {
        'success': true,
        'result': {
          'id': task.id,
          'title': task.title,
          'description': task.description,
          'status': task.status.name,
          'projectId': task.projectId,
          'startAt': task.startAt?.toIso8601String(),
          'endAt': task.endAt?.toIso8601String(),
          'isAllDay': task.isAllDay,
          'createdAt': task.createdAt?.toIso8601String(),
          'updatedAt': task.updatedAt?.toIso8601String(),
        },
        'message': '작업 정보를 가져왔습니다.',
      };
    } catch (e) {
      return {'success': false, 'error': 'Failed to get task details: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> _executeGetEventDetails(Map<String, dynamic> args, {required TabType tabType}) async {
    final eventId = args['eventId'] as String?;
    final uniqueId = args['uniqueId'] as String?;

    if ((eventId == null || eventId.isEmpty) && (uniqueId == null || uniqueId.isEmpty)) {
      return {'success': false, 'error': 'eventId or uniqueId is required'};
    }

    try {
      final allEvents = ref.read(calendarEventListControllerProvider(tabType: tabType)).eventsOnView;
      final event = allEvents.firstWhereOrNull((e) => e.eventId == eventId || e.uniqueId == uniqueId);

      if (event == null) {
        return {'success': false, 'error': 'Event not found'};
      }

      return {
        'success': true,
        'result': {
          'id': event.eventId,
          'uniqueId': event.uniqueId,
          'title': event.title,
          'description': event.description,
          'calendarId': event.calendarId,
          'startAt': event.startDate.toIso8601String(),
          'endAt': event.endDate.toIso8601String(),
          'isAllDay': event.isAllDay,
          'location': event.location,
        },
        'message': '일정 정보를 가져왔습니다.',
      };
    } catch (e) {
      return {'success': false, 'error': 'Failed to get event details: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> _executeGetCalendarList(Map<String, dynamic> args) async {
    try {
      final calendarMap = ref.read(calendarListControllerProvider);
      final allCalendars = calendarMap.values.expand((e) => e).toList();

      final results = allCalendars.map((calendar) {
        return {'id': calendar.uniqueId, 'name': calendar.name, 'email': calendar.email, 'owned': calendar.owned, 'modifiable': calendar.modifiable};
      }).toList();

      return {'success': true, 'results': results, 'message': '${results.length}개의 캘린더를 찾았습니다.'};
    } catch (e) {
      return {'success': false, 'error': 'Failed to get calendar list: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> _executeLinkToProject(Map<String, dynamic> args, {required TabType tabType, List<InboxEntity>? availableInboxes}) async {
    final inboxId = args['inboxId'] as String?;
    final projectId = args['projectId'] as String?;

    if (inboxId == null) {
      return {'success': false, 'error': 'inboxId is required'};
    }
    if (projectId == null) {
      return {'success': false, 'error': 'projectId is required'};
    }

    // Find inbox and create/update linked task with project
    List<InboxEntity> allInboxes;
    if (availableInboxes != null && availableInboxes.isNotEmpty) {
      allInboxes = availableInboxes;
    } else {
      final agentController = ref.read(inboxAgentListControllerProvider.notifier);
      allInboxes = agentController.availableInboxes;
    }
    final inbox = allInboxes.firstWhereOrNull((i) => i.id == inboxId);

    if (inbox == null) {
      return {'success': false, 'error': 'Inbox not found'};
    }

    // Check if task already exists for this inbox
    final linkedTasksData = ref.read(inboxLinkedTaskControllerProvider);
    final linkedTask = linkedTasksData?.linkedTasks.firstWhereOrNull((lt) => lt.inboxId == inboxId);

    final user = ref.read(authControllerProvider).requireValue;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (linkedTask != null && linkedTask.tasks.isNotEmpty) {
      // Update existing task's project
      final existingTask = linkedTask.tasks.first;
      final updatedTask = existingTask.copyWith(projectId: projectId, updatedAt: DateTime.now());
      await TaskAction.upsertTask(
        task: updatedTask,
        originalTask: existingTask,
        calendarTaskEditSourceType: CalendarTaskEditSourceType.inboxDrag,
        tabType: tabType,
        showToast: false,
      );
      return {'success': true, 'taskId': updatedTask.id, 'message': 'Inbox linked to project successfully'};
    } else {
      // Create new task with project
      final suggestion = inbox.suggestion;
      final task = TaskEntity(
        id: const Uuid().v4(),
        ownerId: user.id,
        title: suggestion?.summary ?? inbox.title ?? 'New Task',
        description: inbox.description,
        projectId: projectId,
        startAt: today,
        endAt: today.add(const Duration(days: 1)),
        isAllDay: true,
        linkedMails: inbox.linkedMail != null ? [inbox.linkedMail!] : [],
        linkedMessages: inbox.linkedMessage != null ? [inbox.linkedMessage!] : [],
        createdAt: DateTime.now(),
        status: TaskStatus.none,
      );

      await TaskAction.upsertTask(task: task, calendarTaskEditSourceType: CalendarTaskEditSourceType.inboxDrag, tabType: tabType, showToast: false);
      return {'success': true, 'taskId': task.id, 'message': 'Inbox linked to project successfully'};
    }
  }

  // Search execution methods
  Future<Map<String, dynamic>> _executeSearchInbox(Map<String, dynamic> args, {required TabType tabType}) async {
    final query = args['query'] as String?;
    if (query == null || query.isEmpty) {
      return {'success': false, 'error': 'query is required'};
    }

    try {
      // Search inbox using inbox_list_controller
      final inboxController = ref.read(inboxListControllerProvider.notifier);
      await inboxController.search(query: query);

      // Wait a bit for search to complete
      await Future.delayed(const Duration(milliseconds: 500));

      // Get search results
      final inboxList = ref.read(inboxListControllerProvider);
      final searchResults = inboxList?.inboxes ?? [];

      // Limit results to 20
      final limitedResults = searchResults.take(20).toList();

      // Format results
      final results = limitedResults.map((inbox) {
        final sender = inbox.linkedMail?.fromName ?? inbox.linkedMessage?.userName ?? '';
        final sourceType = inbox.linkedMail?.type ?? inbox.linkedMessage?.type;

        return {
          'id': inbox.id,
          'title': inbox.title ?? '',
          'description': inbox.description ?? '',
          'sender': sender,
          'inboxDatetime': inbox.inboxDatetime.toIso8601String(),
          'sourceType': sourceType?.name ?? '',
        };
      }).toList();

      return {'success': true, 'results': results, 'count': results.length, 'message': '${results.length}개의 인박스 항목을 찾았습니다.'};
    } catch (e) {
      return {'success': false, 'error': 'Search error: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> _executeSearchTask(Map<String, dynamic> args) async {
    final query = args['query'] as String?;
    if (query == null || query.isEmpty) {
      return {'success': false, 'error': 'query is required'};
    }

    final isDone = args['isDone'] as bool?;

    try {
      final user = ref.read(authControllerProvider).requireValue;
      final pref = ref.read(localPrefControllerProvider).value;
      if (pref == null) {
        return {'success': false, 'error': 'Preferences not found'};
      }

      final taskRepository = ref.read(taskRepositoryProvider);
      final searchResult = await taskRepository.searchTasks(query: query, pref: pref, userId: user.id, isDone: isDone);

      final tasks = searchResult.fold((failure) => <TaskEntity>[], (result) => result.tasks.values.expand((e) => e).toList());

      // Limit results to 20
      final limitedTasks = tasks.take(20).toList();

      // Format results
      final results = limitedTasks.map((task) {
        return {
          'id': task.id,
          'title': task.title ?? '',
          'description': task.description ?? '',
          'status': task.status.name,
          'projectId': task.projectId,
          'startAt': task.startAt?.toIso8601String(),
          'endAt': task.endAt?.toIso8601String(),
          'isAllDay': task.isAllDay ?? false,
        };
      }).toList();

      return {'success': true, 'results': results, 'count': results.length, 'message': '${results.length}개의 작업을 찾았습니다.'};
    } catch (e) {
      return {'success': false, 'error': 'Search error: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> _executeSearchCalendarEvent(Map<String, dynamic> args, {required TabType tabType}) async {
    final query = args['query'] as String?;
    if (query == null || query.isEmpty) {
      return {'success': false, 'error': 'query is required'};
    }

    try {
      final pref = ref.read(localPrefControllerProvider).value;
      if (pref == null) {
        return {'success': false, 'error': 'Preferences not found'};
      }

      final calendarRepository = ref.read(calendarRepositoryProvider);
      final calendarOAuths = pref.calendarOAuths ?? [];

      if (calendarOAuths.isEmpty) {
        return {'success': false, 'error': 'No calendar accounts configured'};
      }

      final allEvents = <EventEntity>[];

      // Search in each calendar OAuth account
      for (final oauth in calendarOAuths) {
        final calendarListResult = await calendarRepository.fetchCalendarLists(oauth: oauth);

        await calendarListResult.fold(
          (failure) async {
            // Calendar list fetch failed, skip this OAuth account
          },
          (calendarMap) async {
            final calendars = calendarMap.values
                .expand((e) => e)
                .where((c) => c.email == oauth.email && c.type != null && c.type!.datasourceType == oauth.type.datasourceType)
                .toList();

            if (calendars.isEmpty) return;

            final eventResult = await calendarRepository.searchEventLists(query: query, oauth: oauth, calendars: calendars, nextPageTokens: null);

            await eventResult.fold(
              (failure) async {
                // Calendar search failed, skip this OAuth account
              },
              (result) async {
                // Collect all events from the result
                for (final eventList in result.events.values) {
                  allEvents.addAll(eventList);
                }
              },
            );
          },
        );
      }

      // Limit results to 20
      final limitedEvents = allEvents.take(20).toList();

      // Format results
      final results = limitedEvents.map((event) {
        return {
          'id': event.eventId,
          'uniqueId': event.uniqueId,
          'title': event.title ?? '',
          'description': event.description ?? '',
          'startDate': event.startDate?.toIso8601String(),
          'endDate': event.endDate?.toIso8601String(),
          'isAllDay': event.isAllDay ?? false,
          'location': event.location,
          'calendarId': event.calendar?.id,
          'calendarName': event.calendarName,
        };
      }).toList();

      return {'success': true, 'results': results, 'count': results.length, 'message': '${results.length}개의 일정을 찾았습니다.'};
    } catch (e) {
      return {'success': false, 'error': 'Search error: ${e.toString()}'};
    }
  }

  // Project management functions
  Future<Map<String, dynamic>> _executeMoveProject(Map<String, dynamic> args) async {
    final projectId = args['projectId'] as String?;
    final newParentId = args['newParentId'] as String?;

    if (projectId == null || projectId.isEmpty) {
      return {'success': false, 'error': 'projectId is required'};
    }

    try {
      await ref.read(projectListControllerProvider.notifier).moveProject(projectId, newParentId);
      return {'success': true, 'message': 'Project moved successfully'};
    } catch (e) {
      return {'success': false, 'error': 'Failed to move project: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> _executeInviteUserToProject(Map<String, dynamic> args) async {
    final projectId = args['projectId'] as String?;
    final email = args['email'] as String?;

    if (projectId == null || projectId.isEmpty) {
      return {'success': false, 'error': 'projectId is required'};
    }
    if (email == null || email.isEmpty) {
      return {'success': false, 'error': 'email is required'};
    }

    try {
      final repository = ref.read(projectRepositoryProvider);
      await repository.inviteUserToProject(projectId: projectId, email: email);
      return {'success': true, 'message': 'User invited to project successfully'};
    } catch (e) {
      return {'success': false, 'error': 'Failed to invite user: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> _executeRemoveUserFromProject(Map<String, dynamic> args) async {
    final projectId = args['projectId'] as String?;
    final userId = args['userId'] as String?;

    if (projectId == null || projectId.isEmpty) {
      return {'success': false, 'error': 'projectId is required'};
    }
    if (userId == null || userId.isEmpty) {
      return {'success': false, 'error': 'userId is required'};
    }

    try {
      final repository = ref.read(projectRepositoryProvider);
      await repository.removeUserFromProject(projectId: projectId, userId: userId);
      return {'success': true, 'message': 'User removed from project successfully'};
    } catch (e) {
      return {'success': false, 'error': 'Failed to remove user: ${e.toString()}'};
    }
  }

  // Mail label functions
  Future<Map<String, dynamic>> _executeMoveMailToLabel(Map<String, dynamic> args, {required TabType tabType}) async {
    final threadId = args['threadId'] as String?;
    final labelId = args['labelId'] as String?;

    if (threadId == null || threadId.isEmpty) {
      return {'success': false, 'error': 'threadId is required'};
    }
    if (labelId == null || labelId.isEmpty) {
      return {'success': false, 'error': 'labelId is required'};
    }

    try {
      final mails = await _findMailByThreadId(threadId);
      if (mails == null || mails.isEmpty) {
        return {'success': false, 'error': 'Mail thread not found'};
      }

      // Use MailAction for common labels
      if (labelId == 'ARCHIVE') {
        await MailAction.archive(mails: mails, tabType: tabType);
        return {'success': true, 'message': 'Mail moved to archive successfully'};
      } else if (labelId == 'TRASH') {
        await MailAction.trash(mails: mails, tabType: tabType);
        return {'success': true, 'message': 'Mail moved to trash successfully'};
      } else if (labelId == 'SPAM') {
        await MailAction.spam(mails: mails, tabType: tabType);
        return {'success': true, 'message': 'Mail moved to spam successfully'};
      } else if (labelId == 'INBOX') {
        // Unarchive if archived
        await MailAction.unarchive(mails: mails, tabType: tabType);
        return {'success': true, 'message': 'Mail moved to inbox successfully'};
      } else {
        // For other labels, use mailListController's addLabelsLocal/removeLabelsLocal
        final mailListController = ref.read(mailListControllerProvider.notifier);
        final mailLabelListController = ref.read(mailLabelListControllerProvider.notifier);

        final currentLabels = mails.first.labelIds ?? [];
        final removeLabels = <String>[];
        final addLabels = <String>[labelId];

        // Remove INBOX if moving to another label
        if (currentLabels.contains('INBOX')) {
          removeLabels.add('INBOX');
        }

        mailLabelListController.addLabelsLocal(mails, addLabels);
        mailListController.addLabelsLocal(mails, addLabels);

        if (removeLabels.isNotEmpty) {
          mailLabelListController.removeLabelsLocal(mails, removeLabels);
          mailListController.removeLabelsLocal(mails, removeLabels);
        }

        return {'success': true, 'message': 'Mail moved to label successfully'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Failed to move mail to label: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> _executeGetMailLabels(Map<String, dynamic> args) async {
    final email = args['email'] as String?;

    try {
      final mailLabelListController = ref.read(mailLabelListControllerProvider);
      Map<String, List<MailLabelEntity>> labels;

      if (email != null && email.isNotEmpty) {
        labels = {email: mailLabelListController[email] ?? []};
      } else {
        labels = mailLabelListController;
      }

      final results = <Map<String, dynamic>>[];
      labels.forEach((email, labelList) {
        for (final label in labelList) {
          results.add({'id': label.id, 'name': label.name, 'email': email, 'messagesTotal': label.total, 'messagesUnread': label.unread});
        }
      });

      return {'success': true, 'results': results, 'message': '${results.length}개의 라벨을 찾았습니다.'};
    } catch (e) {
      return {'success': false, 'error': 'Failed to get mail labels: ${e.toString()}'};
    }
  }

  // Inbox functions
  Future<Map<String, dynamic>> _executePinInbox(Map<String, dynamic> args, {required TabType tabType}) async {
    final inboxId = args['inboxId'] as String?;

    if (inboxId == null || inboxId.isEmpty) {
      return {'success': false, 'error': 'inboxId is required'};
    }

    try {
      final inboxList = ref.read(inboxListControllerProvider);
      final inboxes = inboxList?.inboxes ?? [];
      final inbox = inboxes.firstWhereOrNull((i) => i.id == inboxId);

      if (inbox == null) {
        return {'success': false, 'error': 'Inbox not found'};
      }

      // If it's a mail inbox, use MailAction.pin
      if (inbox.linkedMail != null) {
        final mails = await _findMailByThreadId(inbox.linkedMail!.threadId ?? '');
        if (mails != null && mails.isNotEmpty) {
          await MailAction.pin(mails: mails, tabType: tabType);
          return {'success': true, 'message': 'Inbox pinned successfully'};
        }
      }

      // For other inbox types, update locally
      // Note: This might need to be implemented in inbox controller
      return {'success': false, 'error': 'Pinning not supported for this inbox type'};
    } catch (e) {
      return {'success': false, 'error': 'Failed to pin inbox: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> _executeUnpinInbox(Map<String, dynamic> args, {required TabType tabType}) async {
    final inboxId = args['inboxId'] as String?;

    if (inboxId == null || inboxId.isEmpty) {
      return {'success': false, 'error': 'inboxId is required'};
    }

    try {
      final inboxList = ref.read(inboxListControllerProvider);
      final inboxes = inboxList?.inboxes ?? [];
      final inbox = inboxes.firstWhereOrNull((i) => i.id == inboxId);

      if (inbox == null) {
        return {'success': false, 'error': 'Inbox not found'};
      }

      // If it's a mail inbox, use MailAction.unpin
      if (inbox.linkedMail != null) {
        final mails = await _findMailByThreadId(inbox.linkedMail!.threadId ?? '');
        if (mails != null && mails.isNotEmpty) {
          await MailAction.unpin(mails: mails, tabType: tabType);
          return {'success': true, 'message': 'Inbox unpinned successfully'};
        }
      }

      // For other inbox types, update locally
      return {'success': false, 'error': 'Unpinning not supported for this inbox type'};
    } catch (e) {
      return {'success': false, 'error': 'Failed to unpin inbox: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> _executeCreateTaskFromInbox(Map<String, dynamic> args, {required TabType tabType, List<InboxEntity>? availableInboxes}) async {
    final inboxId = args['inboxId'] as String?;
    final title = args['title'] as String?;
    final projectId = args['projectId'] as String?;
    final startAtStr = args['startAt'] as String?;
    final endAtStr = args['endAt'] as String?;

    if (inboxId == null || inboxId.isEmpty) {
      return {'success': false, 'error': 'inboxId is required'};
    }

    try {
      List<InboxEntity> allInboxes;
      if (availableInboxes != null && availableInboxes.isNotEmpty) {
        allInboxes = availableInboxes;
      } else {
        final agentController = ref.read(inboxAgentListControllerProvider.notifier);
        allInboxes = agentController.availableInboxes;
      }
      final inbox = allInboxes.firstWhereOrNull((i) => i.id == inboxId);

      if (inbox == null) {
        return {'success': false, 'error': 'Inbox not found'};
      }

      final user = ref.read(authControllerProvider).requireValue;
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      DateTime? startAt;
      DateTime? endAt;

      if (startAtStr != null) {
        try {
          startAt = DateTime.parse(startAtStr).toLocal();
        } catch (e) {
          return {'success': false, 'error': 'Invalid startAt format'};
        }
      } else {
        startAt = today;
      }

      if (endAtStr != null) {
        try {
          endAt = DateTime.parse(endAtStr).toLocal();
        } catch (e) {
          return {'success': false, 'error': 'Invalid endAt format'};
        }
      } else {
        endAt = startAt.add(const Duration(days: 1));
      }

      final taskTitle = title ?? inbox.title ?? 'New Task';
      final task = TaskEntity(
        id: const Uuid().v4(),
        ownerId: user.id,
        title: taskTitle,
        description: inbox.description,
        projectId: projectId,
        startAt: startAt,
        endAt: endAt,
        isAllDay: true,
        linkedMails: inbox.linkedMail != null ? [inbox.linkedMail!] : [],
        linkedMessages: inbox.linkedMessage != null ? [inbox.linkedMessage!] : [],
        createdAt: DateTime.now(),
        status: TaskStatus.none,
      );

      await TaskAction.upsertTask(task: task, calendarTaskEditSourceType: CalendarTaskEditSourceType.inboxDrag, tabType: tabType, showToast: false);
      return {'success': true, 'taskId': task.id, 'message': 'Task created from inbox successfully'};
    } catch (e) {
      return {'success': false, 'error': 'Failed to create task from inbox: ${e.toString()}'};
    }
  }

  // Task/Event movement functions
  Future<Map<String, dynamic>> _executeMoveTask(Map<String, dynamic> args, {required TabType tabType, List<TaskEntity>? availableTasks}) async {
    final taskId = args['taskId'] as String?;
    final projectId = args['projectId'] as String?;

    if (taskId == null || taskId.isEmpty) {
      return {'success': false, 'error': 'taskId is required'};
    }

    try {
      final allTasks = availableTasks ?? ref.read(taskListControllerProvider).tasks.where((e) => !e.isEventDummyTask).toList();
      final task = allTasks.firstWhereOrNull((t) => t.id == taskId);

      if (task == null) {
        return {'success': false, 'error': 'Task not found'};
      }

      final updatedTask = task.copyWith(projectId: projectId, updatedAt: DateTime.now());
      await TaskAction.upsertTask(task: updatedTask, originalTask: task, calendarTaskEditSourceType: CalendarTaskEditSourceType.inboxDrag, tabType: tabType, showToast: false);

      return {'success': true, 'taskId': updatedTask.id, 'message': 'Task moved successfully'};
    } catch (e) {
      return {'success': false, 'error': 'Failed to move task: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> _executeMoveEvent(Map<String, dynamic> args, {required TabType tabType, List<EventEntity>? availableEvents}) async {
    final eventId = args['eventId'] as String?;
    final calendarId = args['calendarId'] as String?;

    if (eventId == null || eventId.isEmpty) {
      return {'success': false, 'error': 'eventId is required'};
    }
    if (calendarId == null || calendarId.isEmpty) {
      return {'success': false, 'error': 'calendarId is required'};
    }

    try {
      final allEvents = availableEvents ?? ref.read(calendarEventListControllerProvider(tabType: tabType)).eventsOnView;
      final event = allEvents.firstWhereOrNull((e) => e.eventId == eventId);

      if (event == null) {
        return {'success': false, 'error': 'Event not found'};
      }

      // Find calendar by calendarId
      final calendarList = ref.read(calendarListControllerProvider);
      final allCalendars = calendarList.values.expand((e) => e).toList();
      final targetCalendar = allCalendars.firstWhereOrNull((c) => c.id == calendarId || c.uniqueId == calendarId);

      if (targetCalendar == null) {
        return {'success': false, 'error': 'Calendar not found'};
      }

      final updatedEvent = event.copyWith(calendar: targetCalendar);
      await CalendarAction.editCalendarEvent(
        tabType: tabType,
        originalEvent: event,
        newEvent: updatedEvent,
        selectedStartDate: event.startDate,
        selectedEndDate: event.endDate,
        isCreate: false,
        showToast: false,
      );

      return {'success': true, 'eventId': updatedEvent.eventId, 'message': 'Event moved successfully'};
    } catch (e) {
      return {'success': false, 'error': 'Failed to move event: ${e.toString()}'};
    }
  }

  // Attachment functions
  Future<Map<String, dynamic>> _executeGetTaskAttachments(Map<String, dynamic> args, {List<TaskEntity>? availableTasks}) async {
    final taskId = args['taskId'] as String?;

    if (taskId == null || taskId.isEmpty) {
      return {'success': false, 'error': 'taskId is required'};
    }

    try {
      final allTasks = availableTasks ?? ref.read(taskListControllerProvider).tasks.where((e) => !e.isEventDummyTask).toList();
      final task = allTasks.firstWhereOrNull((t) => t.id == taskId);

      if (task == null) {
        return {'success': false, 'error': 'Task not found'};
      }

      // Tasks don't currently have attachments in the entity
      return {'success': true, 'results': [], 'message': 'Task attachments feature not yet implemented'};
    } catch (e) {
      return {'success': false, 'error': 'Failed to get task attachments: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> _executeGetEventAttachments(Map<String, dynamic> args, {List<EventEntity>? availableEvents}) async {
    final eventId = args['eventId'] as String?;

    if (eventId == null || eventId.isEmpty) {
      return {'success': false, 'error': 'eventId is required'};
    }

    try {
      final allEvents = availableEvents ?? ref.read(calendarEventListControllerProvider(tabType: TabType.home)).eventsOnView;
      final event = allEvents.firstWhereOrNull((e) => e.eventId == eventId);

      if (event == null) {
        return {'success': false, 'error': 'Event not found'};
      }

      // Events don't currently have attachments in the entity
      return {'success': true, 'results': [], 'message': 'Event attachments feature not yet implemented'};
    } catch (e) {
      return {'success': false, 'error': 'Failed to get event attachments: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> _executeGetMailAttachments(Map<String, dynamic> args) async {
    final threadId = args['threadId'] as String?;

    if (threadId == null || threadId.isEmpty) {
      return {'success': false, 'error': 'threadId is required'};
    }

    try {
      final mails = await _findMailByThreadId(threadId);
      if (mails == null || mails.isEmpty) {
        return {'success': false, 'error': 'Mail thread not found'};
      }

      final mail = mails.first;
      final attachments = mail.getAttachments();

      final results = attachments.map((attachment) {
        return {
          'name': attachment.name,
          'size': 0, // Size not available in MailFileEntity
          'contentType': attachment.mimeType,
        };
      }).toList();

      return {'success': true, 'results': results, 'message': '${results.length}개의 첨부파일을 찾았습니다.'};
    } catch (e) {
      return {'success': false, 'error': 'Failed to get mail attachments: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> _executeGetMessageAttachments(Map<String, dynamic> args, {required TabType tabType}) async {
    final messageId = args['messageId'] as String?;

    if (messageId == null || messageId.isEmpty) {
      return {'success': false, 'error': 'messageId is required'};
    }

    try {
      // Messages don't currently have attachments in the entity
      // This is a placeholder implementation
      return {'success': true, 'results': [], 'message': 'Message attachments feature not yet implemented'};
    } catch (e) {
      return {'success': false, 'error': 'Failed to get message attachments: ${e.toString()}'};
    }
  }
}
