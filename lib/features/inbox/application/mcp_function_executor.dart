import 'dart:convert';

import 'package:Visir/config/providers.dart';
import 'package:Visir/features/auth/application/auth_controller.dart';
import 'package:Visir/features/calendar/actions.dart';
import 'package:Visir/features/calendar/application/calendar_event_list_controller.dart';
import 'package:Visir/features/calendar/application/calendar_list_controller.dart';
import 'package:Visir/features/calendar/domain/entities/calendar_entity.dart';
import 'package:Visir/features/calendar/domain/entities/event_attendee_entity.dart';
import 'package:Visir/features/calendar/domain/entities/event_entity.dart';
import 'package:Visir/features/calendar/presentation/widgets/calendar_simple_create_widget.dart';
import 'package:Visir/features/calendar/providers.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/mail/actions.dart';
import 'package:Visir/features/mail/domain/entities/mail_entity.dart';
import 'package:Visir/features/mail/domain/entities/mail_label_entity.dart';
import 'package:Visir/features/mail/domain/entities/mail_user_entity.dart';
import 'package:Visir/features/mail/providers.dart';
import 'package:Visir/features/preference/application/local_pref_controller.dart';
import 'package:Visir/features/task/actions.dart';
import 'package:Visir/features/task/application/project_list_controller.dart';
import 'package:Visir/features/task/application/task_list_controller.dart';
import 'package:Visir/features/task/domain/entities/project_entity.dart';
import 'package:Visir/features/task/domain/entities/task_entity.dart';
import 'package:Visir/features/common/domain/entities/connection_entity.dart';
import 'package:Visir/features/common/domain/entities/linked_item_entity.dart';
import 'package:Visir/features/inbox/domain/entities/inbox_entity.dart';
import 'package:Visir/features/inbox/application/inbox_agent_list_controller.dart';
import 'package:Visir/features/inbox/application/inbox_linked_task_controller.dart';
import 'package:Visir/features/inbox/application/inbox_list_controller.dart';
import 'package:Visir/features/task/providers.dart';
import 'package:Visir/features/calendar/providers.dart';
import 'package:Visir/features/common/presentation/utils/extensions/date_time_extension.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:enough_mail/enough_mail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

/// MCP 함수 호출을 파싱하고 실행하는 클래스
class McpFunctionExecutor {
  // WidgetRef도 받을 수 있도록 dynamic으로 선언
  final dynamic ref;

  McpFunctionExecutor(this.ref);

  // WidgetRef도 받을 수 있도록 factory 생성자 추가
  factory McpFunctionExecutor.fromWidgetRef(WidgetRef widgetRef) {
    return McpFunctionExecutor(widgetRef);
  }

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
                results.add(item);
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
                else if (item.containsKey('title') && (item.containsKey('startAt') || item.containsKey('start_at')) && (item.containsKey('calendarId') || item.containsKey('calendar_id'))) {
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
            results.add({'function': functionName, 'arguments': arguments});
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
              results.add(parsed);
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
            results.add({'function': functionName, 'arguments': arguments});
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
        case 'linkToProject':
          return await _executeLinkToProject(arguments, tabType: tabType, availableInboxes: availableInboxes);

        // Mail Actions
        case 'sendMail':
          return await _executeSendMail(arguments);
        case 'replyMail':
          return await _executeReplyMail(arguments);
        case 'forwardMail':
          return await _executeForwardMail(arguments);
        case 'markMailAsRead':
          return await _executeMarkMailAsRead(arguments);
        case 'markMailAsUnread':
          return await _executeMarkMailAsUnread(arguments);
        case 'archiveMail':
          return await _executeArchiveMail(arguments);
        case 'deleteMail':
          return await _executeDeleteMail(arguments);

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
    final startAtStr = args['startAt'] as String?;
    final endAtStr = args['endAt'] as String?;
    var isAllDay = args['isAllDay'] as bool? ?? false;
    final statusStr = args['status'] as String? ?? 'none';

    // Find matching inbox by title or description to get linkedMail/linkedMessage and suggestion
    InboxEntity? matchingInbox;
    if (availableInboxes != null && availableInboxes.isNotEmpty) {
      // Try to find inbox that matches the task title or description
      matchingInbox = availableInboxes.firstWhereOrNull((inbox) {
        final inboxTitle = (inbox.title ?? '').toLowerCase();
        final inboxDescription = (inbox.description ?? '').toLowerCase();
        final taskTitle = title.toLowerCase();
        final taskDescription = (description ?? '').toLowerCase();
        return inboxTitle.contains(taskTitle) || taskTitle.contains(inboxTitle) || inboxDescription.contains(taskDescription) || taskDescription.contains(inboxDescription);
      });
    }

    // If projectId is not provided, try to get it from inbox suggestion
    if (projectId == null || projectId.isEmpty) {
      if (matchingInbox != null) {
        final suggestion = matchingInbox.suggestion;
        if (suggestion != null && suggestion.project_id != null && suggestion.project_id!.isNotEmpty) {
          projectId = suggestion.project_id;
        }
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
      createdAt: DateTime.now(),
      status: status,
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
    final taskId = args['taskId'] as String?;
    if (taskId == null) {
      return {'success': false, 'error': 'taskId is required'};
    }

    final allTasks = availableTasks ?? ref.read(taskListControllerProvider).tasks.where((e) => !e.isEventDummyTask).toList();
    final task = allTasks.firstWhere((t) => t.id == taskId, orElse: () => throw Exception('Task not found'));

    await TaskAction.deleteTask(
      task: task,
      calendarTaskEditSourceType: CalendarTaskEditSourceType.inboxDrag,
      tabType: tabType,
      selectedStartDate: task.startAt,
      selectedEndDate: task.endAt,
      showToast: false,
    );

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

    // Find matching inbox by title or description to get linkedMail/linkedMessage
    List<LinkedMailEntity> linkedMails = [];
    List<LinkedMessageEntity> linkedMessages = [];
    if (availableInboxes != null && availableInboxes.isNotEmpty) {
      // Try to find inbox that matches the event title or description
      final matchingInbox = availableInboxes.firstWhereOrNull((inbox) {
        final inboxTitle = (inbox.title ?? '').toLowerCase();
        final inboxDescription = (inbox.description ?? '').toLowerCase();
        final eventTitle = title.toLowerCase();
        final eventDescription = (description ?? '').toLowerCase();
        return inboxTitle.contains(eventTitle) || eventTitle.contains(inboxTitle) || inboxDescription.contains(eventDescription) || eventDescription.contains(inboxDescription);
      });

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
      final task = TaskEntity(
        id: const Uuid().v4(),
        ownerId: user.id,
        title: title,
        description: description,
        startAt: startAt,
        endAt: isAllDay ? startAt.dateOnly : endAt,
        isAllDay: isAllDay,
        linkedMails: linkedMails,
        linkedMessages: linkedMessages,
        reminders: isAllDay ? [] : (calendar.defaultReminders ?? []),
        createdAt: DateTime.now(),
        status: TaskStatus.none,
        linkedEvent: event,
        projectId: lastUsedProject?.uniqueId ?? defaultProject?.uniqueId,
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

        int searchAttempts = 0;

        while (searchTime.isBefore(endOfDay)) {
          searchAttempts++;
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

    print('[Reschedule] Completed: ${results.length} tasks rescheduled successfully');
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
        return {
          'id': inbox.id,
          'number': inbox.number,
          'title': inbox.title ?? '',
          'description': inbox.description ?? '',
          'sender': inbox.sender ?? '',
          'inboxDatetime': inbox.inboxDatetime.toIso8601String(),
          'sourceType': inbox.sourceType?.name ?? '',
        };
      }).toList();

      return {
        'success': true,
        'results': results,
        'count': results.length,
        'message': '${results.length}개의 인박스 항목을 찾았습니다.',
      };
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
      final searchResult = await taskRepository.searchTasks(
        query: query,
        pref: pref,
        userId: user.id,
        isDone: isDone,
      );

      final tasks = searchResult.fold(
        (failure) => <TaskEntity>[],
        (result) => result.tasks.values.expand((e) => e).toList(),
      );

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

      return {
        'success': true,
        'results': results,
        'count': results.length,
        'message': '${results.length}개의 작업을 찾았습니다.',
      };
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

            final eventResult = await calendarRepository.searchEventLists(
              query: query,
              oauth: oauth,
              calendars: calendars,
              nextPageTokens: null,
            );

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

      return {
        'success': true,
        'results': results,
        'count': results.length,
        'message': '${results.length}개의 일정을 찾았습니다.',
      };
    } catch (e) {
      return {'success': false, 'error': 'Search error: ${e.toString()}'};
    }
  }
}
