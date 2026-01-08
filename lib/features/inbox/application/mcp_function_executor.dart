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
import 'package:Visir/features/chat/domain/entities/message_entity.dart';
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
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/provider.dart';
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
import 'package:Visir/features/task/application/calendar_task_list_controller.dart';
import 'package:Visir/features/task/domain/entities/project_entity.dart';
import 'package:Visir/features/task/domain/entities/task_entity.dart';
import 'package:Visir/features/task/domain/entities/task_reminder_option_type.dart';
import 'package:Visir/features/common/domain/entities/connection_entity.dart';
import 'package:Visir/features/common/domain/entities/linked_item_entity.dart';
import 'package:Visir/features/inbox/domain/entities/inbox_entity.dart';
import 'package:Visir/features/inbox/domain/entities/agent_model_entity.dart';
import 'package:Visir/features/common/domain/entities/ai_provider_entity.dart';
import 'package:Visir/features/inbox/application/inbox_agent_list_controller.dart';
import 'package:Visir/features/inbox/application/inbox_config_controller.dart';
import 'package:Visir/features/inbox/application/inbox_controller.dart';
import 'package:Visir/features/inbox/application/inbox_linked_task_controller.dart';
import 'package:Visir/features/inbox/providers.dart';
import 'package:Visir/features/mail/domain/entities/mail_label_entity.dart';
import 'package:Visir/features/task/providers.dart';
import 'package:Visir/features/common/presentation/utils/extensions/date_time_extension.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:enough_mail/enough_mail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:pdfx/pdfx.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';

/// MCP 함수 호출을 파싱하고 실행하는 클래스
class McpFunctionExecutor {
  WidgetRef get ref => Utils.ref;

  /// 함수 이름을 기반으로 confirm이 필요한지 판단합니다.
  /// write/send 관련 함수만 confirm이 필요합니다.
  bool requiresConfirmation(String functionName) {
    // Confirm 필요한 함수 목록 (DB 쓰기, 전송, 삭제, 수정 등)
    const functionsRequiringConfirmation = {
      // 전송 관련
      'sendMail',
      'replyMail',
      'replyAllMail',
      'forwardMail',
      // 삭제 관련
      'deleteTask',
      'deleteEvent',
      'deleteMail',
      'deleteMessage',
      'deleteProject',
      // 수정 관련
      'updateTask',
      'updateEvent',
      'updateProject',
      // 상태 변경
      'markMailAsRead',
      'markMailAsUnread',
      'archiveMail',
      'unarchiveMail',
      'responseCalendarInvitation',
      // 생성 (DB에 쓰는 작업)
      'createTask',
      'createEvent',
      'createProject',
      // 기타 데이터 변경 함수
      'sendMessage',
      'replyMessage',
      'editMessage',
      'moveTask',
      'moveEvent',
      'moveProject',
      'pinInbox',
      'unpinInbox',
      'pinMail',
      'unpinMail',
      'markMailAsImportant',
      'markMailAsNotImportant',
      'spamMail',
      'unspamMail',
      'moveMailToLabel',
    };

    return functionsRequiringConfirmation.contains(functionName);
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
    print('[FunctionCall] parseFunctionCalls called, response length: ${aiResponse.length}');
    print('[FunctionCall] Checking for summarizeAttachment in response: ${aiResponse.contains('summarizeAttachment')}');
    print('[FunctionCall] Checking for 첨부파일 in response: ${aiResponse.contains('첨부파일')}');
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
                print('[FunctionCall] Found function call: ${functionCall['function']}');
                if (functionCall['function'] == 'summarizeAttachment') {
                  print('[FunctionCall] ✓ summarizeAttachment found in array format!');
                  print('[FunctionCall] Arguments: ${functionCall['arguments']}');
                }
              }
            }
            if (results.isNotEmpty) {
              print('[FunctionCall] Returning ${results.length} function calls from array format');
              return results;
            }

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
            print('[FunctionCall] Found function call in custom tag: $functionName');
            if (functionName == 'summarizeAttachment') {
              print('[FunctionCall] ✓ summarizeAttachment found in custom tag format!');
              print('[FunctionCall] Arguments: ${functionCall['arguments']}');
            }
          } catch (e) {
            print('[FunctionCall] Failed to parse custom tag: $e');
            // 개별 파싱 실패는 무시하고 계속 진행
          }
        }
      }
      if (results.isNotEmpty) {
        print('[FunctionCall] Returning ${results.length} function calls from custom tag format');
        return results;
      }

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
              print('[FunctionCall] Found function call in JSON block: ${functionCall['function']}');
              if (functionCall['function'] == 'summarizeAttachment') {
                print('[FunctionCall] ✓ summarizeAttachment found in JSON block format!');
                print('[FunctionCall] Arguments: ${functionCall['arguments']}');
              }
            }
          } catch (e) {
            print('[FunctionCall] Failed to parse JSON block: $e');
            // 개별 파싱 실패는 무시하고 계속 진행
          }
        }
      }
      if (results.isNotEmpty) {
        print('[FunctionCall] Returning ${results.length} function calls from JSON block format');
        return results;
      }

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
            print('[FunctionCall] Found function call in single format: $functionName');
            if (functionName == 'summarizeAttachment') {
              print('[FunctionCall] ✓ summarizeAttachment found in single format!');
              print('[FunctionCall] Arguments: ${functionCall['arguments']}');
            }
          } catch (e) {
            print('[FunctionCall] Failed to parse single format: $e');
            // 개별 파싱 실패는 무시하고 계속 진행
          }
        }
      }
    } catch (e) {
      print('[FunctionCall] Error parsing function calls: $e');
      // 파싱 실패
    }

    print('[FunctionCall] Total function calls parsed: ${results.length}');
    if (results.isEmpty) {
      print('[FunctionCall] ⚠ No function calls found in AI response');
    } else {
      final functionNames = results.map((r) => r['function']).toList();
      print('[FunctionCall] Parsed functions: $functionNames');
      if (!functionNames.contains('summarizeAttachment')) {
        print('[FunctionCall] ⚠ summarizeAttachment NOT found in parsed functions');
      }
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
    print('[FunctionCall] executeFunction called: $functionName');
    print('[FunctionCall] Arguments: $arguments');
    if (functionName == 'summarizeAttachment') {
      print('[FunctionCall] ✓ Executing summarizeAttachment function');
    }
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
          return await _executeGetInboxDetails(arguments, tabType: tabType, availableInboxes: availableInboxes);
        case 'getPreviousContext':
          return await _executeGetPreviousContext(arguments, tabType: tabType);
        case 'summarizeAttachment':
          print('[FunctionCall] Switching to summarizeAttachment case');
          final summarizeResult = await _executeSummarizeAttachment(arguments, tabType: tabType);
          print('[FunctionCall] summarizeAttachment returned: success=${summarizeResult['success']}, has result=${summarizeResult.containsKey('result')}');
          if (summarizeResult.containsKey('result') && summarizeResult['result'] is Map) {
            final resultData = summarizeResult['result'] as Map<String, dynamic>;
            print('[FunctionCall] summarizeAttachment result data keys: ${resultData.keys.toList()}');
            if (resultData.containsKey('files')) {
              final files = resultData['files'];
              print('[FunctionCall] summarizeAttachment files: ${files is List ? files.length : 'not a list'}');
            }
          }
          return summarizeResult;
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
          return await _executeLinkToProject(arguments, tabType: tabType, availableInboxes: availableInboxes, availableTasks: availableTasks);
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
    final threadId = args['threadId'] as String?;
    final messageId = args['messageId'] as String?;

    // Find matching inbox
    InboxEntity? matchingInbox;
    if (availableInboxes != null && availableInboxes.isNotEmpty) {
      // 1. inboxId가 명시적으로 제공되면 그것으로 찾기
      if (inboxId != null && inboxId.isNotEmpty) {
        matchingInbox = availableInboxes.firstWhereOrNull((inbox) => inbox.id == inboxId);
      }

      // 2. inboxId가 없으면 threadId나 messageId로 inboxId 생성해서 찾기
      if (matchingInbox == null) {
        String? generatedInboxId;

        // threadId가 있으면 mail로 간주하고 inboxId 생성
        if (threadId != null && threadId.isNotEmpty) {
          final mailInbox = availableInboxes.firstWhereOrNull((inbox) => inbox.linkedMail != null && inbox.linkedMail!.threadId == threadId);
          if (mailInbox != null && mailInbox.linkedMail != null) {
            generatedInboxId = InboxEntity.getInboxIdFromLinkedMail(mailInbox.linkedMail!);
            matchingInbox = availableInboxes.firstWhereOrNull((inbox) => inbox.id == generatedInboxId);
          }
        }

        // messageId가 있으면 chat으로 간주하고 inboxId 생성
        if (matchingInbox == null && messageId != null && messageId.isNotEmpty) {
          final chatInbox = availableInboxes.firstWhereOrNull((inbox) => inbox.linkedMessage != null && inbox.linkedMessage!.messageId == messageId);
          if (chatInbox != null && chatInbox.linkedMessage != null) {
            generatedInboxId = InboxEntity.getInboxIdFromLinkedChat(chatInbox.linkedMessage!);
            matchingInbox = availableInboxes.firstWhereOrNull((inbox) => inbox.id == generatedInboxId);
          }
        }
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

    // availableTasks에서 먼저 찾기
    TaskEntity? task;
    if (availableTasks != null && availableTasks.isNotEmpty) {
      task = availableTasks.firstWhereOrNull((t) => t.id == taskId);
    }

    // availableTasks에서 찾지 못하면 두 provider에서 최신 목록 가져오기
    if (task == null) {
      final allTasks = _getAllTasksFromBothProviders();
      task = allTasks.firstWhereOrNull((t) => t.id == taskId);
    }

    if (task == null) {
      return {'success': false, 'error': 'Task not found'};
    }

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

    // availableTasks에서 먼저 찾기
    TaskEntity? task;
    if (availableTasks != null && availableTasks.isNotEmpty) {
      task = availableTasks.firstWhereOrNull((t) => t.id == taskId);
    }

    // availableTasks에서 찾지 못하면 두 provider에서 최신 목록 가져오기
    if (task == null) {
      final allTasks = _getAllTasksFromBothProviders();
      task = allTasks.firstWhereOrNull((t) => t.id == taskId);
    }

    if (task == null) {
      return {'success': false, 'error': 'Task not found'};
    }

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

    // availableTasks에서 먼저 찾기
    TaskEntity? task;
    if (availableTasks != null && availableTasks.isNotEmpty) {
      task = availableTasks.firstWhereOrNull((t) => t.id == taskId);
    }

    // availableTasks에서 찾지 못하면 두 provider에서 최신 목록 가져오기
    if (task == null) {
      final allTasks = _getAllTasksFromBothProviders();
      task = allTasks.firstWhereOrNull((t) => t.id == taskId);
    }

    if (task == null) {
      return {'success': false, 'error': 'Task not found'};
    }

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
      'message': Utils.mainContext.tr.mcp_mail_info_retrieved,
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

      return {'success': true, 'results': results, 'message': Utils.mainContext.tr.mcp_found_mails(results.length)};
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
        'message': Utils.mainContext.tr.mcp_message_info_retrieved,
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
        final userName = member?.displayName ?? userId ?? Utils.mainContext.tr.mcp_unknown_user;

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

      return {'success': true, 'results': results, 'message': Utils.mainContext.tr.mcp_found_messages(results.length)};
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
          final userName = member?.displayName ?? userId ?? Utils.mainContext.tr.mcp_unknown_user;

          final channelId = message.channelId;
          final channel = channelId != null ? allChannels.firstWhereOrNull((c) => c.id == channelId) : null;
          final channelName = channel?.displayName ?? channel?.name ?? Utils.mainContext.tr.mcp_unknown_channel;

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

        return {'success': true, 'results': results, 'message': Utils.mainContext.tr.mcp_found_messages(results.length)};
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

    // availableTasks에서 먼저 찾기
    TaskEntity? task;
    if (availableTasks != null && availableTasks.isNotEmpty) {
      task = availableTasks.firstWhereOrNull((t) => t.id == taskId);
    }

    // availableTasks에서 찾지 못하면 두 provider에서 최신 목록 가져오기
    if (task == null) {
      final allTasks = _getAllTasksFromBothProviders();
      task = allTasks.firstWhereOrNull((t) => t.id == taskId);
    }

    if (task == null) {
      return {'success': false, 'error': 'Task not found'};
    }

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

    final allTasks = availableTasks ?? _getAllTasksFromBothProviders();
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
        final allTasks = availableTasks ?? _getAllTasksFromBothProviders();
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
        final allTasks = availableTasks ?? _getAllTasksFromBothProviders();
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
      final allTasks = availableTasks ?? _getAllTasksFromBothProviders();
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

      final allTasks = _getAllTasksFromBothProviders();
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

      return {'success': true, 'results': results, 'message': Utils.mainContext.tr.mcp_tasks_today(results.length)};
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

      return {'success': true, 'results': results, 'message': Utils.mainContext.tr.mcp_events_today(results.length)};
    } catch (e) {
      return {'success': false, 'error': 'Failed to get today events: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> _executeGetUpcomingTasks(Map<String, dynamic> args, {required TabType tabType}) async {
    final limit = args['limit'] as int? ?? 10;

    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final allTasks = _getAllTasksFromBothProviders();
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

      return {'success': true, 'results': results, 'message': Utils.mainContext.tr.mcp_found_upcoming_tasks(results.length)};
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

      return {'success': true, 'results': results, 'message': Utils.mainContext.tr.mcp_found_upcoming_events(results.length)};
    } catch (e) {
      return {'success': false, 'error': 'Failed to get upcoming events: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> _executeGetOverdueTasks(Map<String, dynamic> args, {required TabType tabType}) async {
    try {
      final allTasks = _getAllTasksFromBothProviders();
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

      return {'success': true, 'results': results, 'message': Utils.mainContext.tr.mcp_found_overdue_tasks(results.length)};
    } catch (e) {
      return {'success': false, 'error': 'Failed to get overdue tasks: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> _executeGetUnscheduledTasks(Map<String, dynamic> args, {required TabType tabType}) async {
    try {
      final allTasks = _getAllTasksFromBothProviders();
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

      return {'success': true, 'results': results, 'message': Utils.mainContext.tr.mcp_found_unscheduled_tasks(results.length)};
    } catch (e) {
      return {'success': false, 'error': 'Failed to get unscheduled tasks: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> _executeGetCompletedTasks(Map<String, dynamic> args, {required TabType tabType}) async {
    final limit = args['limit'] as int?;

    try {
      final allTasks = _getAllTasksFromBothProviders();
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

      return {'success': true, 'results': results, 'message': Utils.mainContext.tr.mcp_found_completed_tasks(results.length)};
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
        final allTasks = availableTasks ?? _getAllTasksFromBothProviders();
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
        final allTasks = availableTasks ?? _getAllTasksFromBothProviders();
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

  Future<Map<String, dynamic>> _executeGetInboxDetails(Map<String, dynamic> args, {required TabType tabType, List<InboxEntity>? availableInboxes}) async {
    final inboxId = args['inboxId'] as String?;

    if (inboxId == null || inboxId.isEmpty) {
      return {'success': false, 'error': 'inboxId is required'};
    }

    try {
      // 먼저 availableInboxes에서 찾기 (검색 결과에서 온 경우)
      InboxEntity? inbox;
      if (availableInboxes != null && availableInboxes.isNotEmpty) {
        inbox = availableInboxes.firstWhereOrNull((i) => i.id == inboxId);
      }

      // availableInboxes에서 찾지 못한 경우에만 inboxControllerProvider에서 찾기
      if (inbox == null) {
        final inboxList = ref.read(inboxControllerProvider);
        final inboxes = inboxList?.inboxes ?? [];
        inbox = inboxes.firstWhereOrNull((i) => i.id == inboxId);
      }

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
        'message': Utils.mainContext.tr.mcp_inbox_info_retrieved,
      };
    } catch (e) {
      // Provider가 dispose된 경우를 포함한 모든 에러 처리
      if (e.toString().contains('disposed') || e.toString().contains('UnmountedRefException')) {
        return {'success': false, 'error': 'Provider has been disposed'};
      }
      return {'success': false, 'error': 'Failed to get inbox details: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> _executeGetPreviousContext(Map<String, dynamic> args, {required TabType tabType}) async {
    final taskId = args['taskId'] as String?;
    final eventId = args['eventId'] as String?;
    final inboxId = args['inboxId'] as String?;

    // At least one ID must be provided
    if ((taskId == null || taskId.isEmpty) && (eventId == null || eventId.isEmpty) && (inboxId == null || inboxId.isEmpty)) {
      return {'success': false, 'error': 'At least one of taskId, eventId, or inboxId is required'};
    }

    try {
      String? effectiveTaskId = taskId;
      String? effectiveEventId = eventId;
      InboxEntity? inbox;

      // If inboxId is provided, try to find linked task or event
      if (inboxId != null && inboxId.isNotEmpty) {
        final inboxList = ref.read(inboxControllerProvider);
        inbox = inboxList?.inboxes.firstWhereOrNull((i) => i.id == inboxId);

        if (inbox != null) {
          // First, try to find linked task
          if (inbox.linkedTask != null && inbox.linkedTask!.tasks.isNotEmpty) {
            effectiveTaskId = inbox.linkedTask!.tasks.first.id;
            // Check if the linked task has a linkedEvent
            final linkedTask = inbox.linkedTask!.tasks.first;
            if (linkedTask.linkedEvent != null) {
              effectiveEventId = linkedTask.linkedEvent!.eventId;
            }
          }
        }
      }

      // If we have taskId or eventId, use the same logic as _searchAndGenerateContext
      if (effectiveTaskId != null || effectiveEventId != null) {
        // Get task/event entities
        TaskEntity? task;
        if (effectiveTaskId != null) {
          final allTasks = _getAllTasksFromBothProviders(includeRecentMonths: true);
          task = allTasks.firstWhereOrNull((t) => (t.isEvent ? t.eventId == effectiveEventId : t.id == effectiveTaskId));
        }
        final event = effectiveEventId != null
            ? ref.read(calendarEventListControllerProvider(tabType: TabType.home).select((v) => v.eventsOnView.firstWhereOrNull((e) => e.uniqueId == effectiveEventId)))
            : null;

        if (task == null && event == null) {
          return {
            'success': true,
            'result': {'summary': 'No previous context available'},
            'message': Utils.mainContext.tr.mcp_previous_context_not_available,
          };
        }

        // Use the same logic as _searchAndGenerateContext
        final repository = ref.read(inboxRepositoryProvider);
        final userId = ref.read(authControllerProvider).requireValue.id;

        final linkedMail = task?.linkedMails.firstOrNull;
        final linkedMessage = task?.linkedMessages.firstOrNull;

        // Extract search keywords
        String? taskProjectName;
        String? calendarName;

        if (task != null && task.projectId != null) {
          taskProjectName = ref.read(projectListControllerProvider).firstWhereOrNull((p) => p.uniqueId == task!.projectId)?.name;
        } else if (event != null) {
          calendarName = event.calendarName;
        }

        final keywordsResult = await repository.extractSearchKeywords(
          taskTitle: event?.title ?? task?.title ?? '',
          taskDescription: event?.description ?? task?.description ?? '',
          taskProjectName: taskProjectName,
          calendarName: calendarName,
          model: 'gpt-4o-mini',
        );

        final keywords = keywordsResult.fold((failure) => null, (keywords) => keywords);
        if (keywords == null || keywords.isEmpty) {
          return {
            'success': true,
            'result': {'summary': 'No previous context available'},
            'message': Utils.mainContext.tr.mcp_previous_context_not_available,
          };
        }

        // Get all integrated OAuth accounts
        final mailOAuths = ref.read(localPrefControllerProvider.select((v) => v.value?.mailOAuths)) ?? [];
        final messengerOAuths = ref.read(localPrefControllerProvider.select((v) => v.value?.messengerOAuths)) ?? [];
        final calendarOAuths = ref.read(localPrefControllerProvider.select((v) => v.value?.calendarOAuths)) ?? [];

        // Search in each datasource (same logic as _searchAndGenerateContext)
        List<InboxEntity> searchResults = [];
        List<TaskEntity> taskEntities = [];
        final Set<String> processedThreadIds = {};

        // Process linkedMail/linkedMessage first if provided
        if (linkedMail != null && linkedMail.threadId.isNotEmpty) {
          final threadKey = '${linkedMail.threadId}_${linkedMail.hostMail}';
          if (!processedThreadIds.contains(threadKey)) {
            processedThreadIds.add(threadKey);

            final mailRepository = ref.watch(mailRepositoryProvider);
            final oauths = ref.read(localPrefControllerProvider.select((v) => v.value?.mailOAuths)) ?? [];
            final oauth = oauths.firstWhereOrNull((o) => o.email == linkedMail.hostMail);

            if (oauth != null) {
              final threadResult = await mailRepository.fetchThreads(
                oauth: oauth,
                type: linkedMail.type,
                threadId: linkedMail.threadId,
                labelId: CommonMailLabels.inbox.id,
                email: linkedMail.hostMail,
              );

              await threadResult.fold(
                (failure) async {
                  // Failed to fetch thread
                },
                (threadMails) async {
                  final date = ref.read(inboxListDateProvider);
                  final isSignedIn = ref.read(authControllerProvider.select((v) => v.requireValue.isSignedIn));
                  final configs = ref.read(inboxConfigListControllerProvider(isSearch: false, year: date.year, month: date.month, day: date.day, isSignedIn: isSignedIn));
                  for (final mail in threadMails) {
                    final config = configs?.configs.firstWhereOrNull((c) => c.id == InboxEntity.getInboxIdFromMail(mail));
                    searchResults.add(InboxEntity.fromMail(mail, config));
                  }
                },
              );
            }
          }
        } else if (linkedMessage != null) {
          final threadId = linkedMessage.threadId.isNotEmpty && linkedMessage.threadId != linkedMessage.messageId ? linkedMessage.threadId : linkedMessage.messageId;
          final threadKey = '${threadId}_${linkedMessage.teamId}_${linkedMessage.channelId}';

          if (!processedThreadIds.contains(threadKey)) {
            processedThreadIds.add(threadKey);

            final chatRepository = ref.watch(chatRepositoryProvider);
            final channels = ref.read(chatChannelListControllerProvider).values.expand((e) => e.channels).toList();
            final channel = channels.firstWhereOrNull((c) => c.id == linkedMessage.channelId && c.teamId == linkedMessage.teamId);

            if (channel != null) {
              final oauths = ref.read(localPrefControllerProvider.select((v) => v.value?.messengerOAuths)) ?? [];
              final oauth = oauths.firstWhereOrNull((o) => o.team?.id == linkedMessage.teamId);

              if (oauth != null) {
                final threadResult = await chatRepository.fetchReplies(oauth: oauth, channel: channel, parentMessageId: threadId);

                await threadResult.fold(
                  (failure) async {
                    // Failed to fetch thread replies
                  },
                  (threadData) async {
                    final _channels = ref.read(chatChannelListControllerProvider).values.expand((e) => e.channels).toList();
                    final _members = ref.read(chatChannelListControllerProvider).values.expand((e) => e.members).toList();
                    final _groups = ref.read(chatChannelListControllerProvider).values.expand((e) => e.groups).toList();
                    final date = ref.read(inboxListDateProvider);
                    final isSignedIn = ref.read(authControllerProvider.select((v) => v.requireValue.isSignedIn));
                    final configs = ref.read(inboxConfigListControllerProvider(isSearch: false, year: date.year, month: date.month, day: date.day, isSignedIn: isSignedIn));

                    for (final message in threadData.messages) {
                      final msgChannel = _channels.firstWhereOrNull((c) => c.id == message.channelId && c.teamId == message.teamId);
                      final member = _members.firstWhereOrNull((m) => m.id == message.userId);
                      if (msgChannel != null && member != null && message.teamId != null && message.channelId != null && message.userId != null) {
                        final config = configs?.configs.firstWhereOrNull((c) => c.id == InboxEntity.getInboxIdFromChat(message));
                        searchResults.add(InboxEntity.fromChat(message, config, msgChannel, member, _channels, _members, _groups));
                      }
                    }
                  },
                );
              }
            }
          }
        }

        // Search in tasks (local) - from both taskListControllerInternalProvider and calendarTaskListControllerInternalProvider
        final taskQuery = keywords.join(' ');
        if (taskQuery.isNotEmpty) {
          final now = DateTime.now();
          final threeMonthsAgo = DateTime(now.year, now.month - 2, 1);
          final startDate = threeMonthsAgo;
          final endDate = now;

          // Get tasks from both providers (include recent 3 months)
          final allTasks = _getAllTasksFromBothProviders(includeRecentMonths: true);

          // Filter by date range (last 3 months) and keywords
          final filteredTasks = _filterLocalTasks(allTasks, startDate, endDate, taskQuery, null, null);
          // Sort by date (closest to today first) and take 20
          filteredTasks.sort((a, b) {
            final aDate = a.startAt ?? a.startDate ?? DateTime(1970);
            final bDate = b.startAt ?? b.startDate ?? DateTime(1970);
            return bDate.compareTo(aDate);
          });
          taskEntities.addAll(filteredTasks.take(20));
        }

        // Search in mail (same logic as _searchAndGenerateContext)
        final mailQuery = keywords.join(' ');
        if (mailQuery.isNotEmpty && !ref.read(shouldUseMockDataProvider)) {
          for (final oauth in mailOAuths) {
            final mailRepository = ref.watch(mailRepositoryProvider);
            final user = ref.read(authControllerProvider).requireValue;

            final mailResult = await mailRepository.fetchMailsForLabel(
              oauth: oauth,
              user: user,
              isInbox: false,
              labelId: null,
              email: null,
              pageToken: null,
              q: mailQuery,
              startDate:
                  event?.startDate.subtract(const Duration(days: 30)) ?? task?.startDate.subtract(const Duration(days: 30)) ?? DateTime.now().subtract(const Duration(days: 30)),
              endDate: event?.endDate ?? task?.endDate ?? DateTime.now(),
            );

            await mailResult.fold(
              (failure) async {
                // Mail search failed, skip this OAuth account
              },
              (mails) async {
                final Map<String, MailEntity> threadMap = {};

                for (final mailList in mails.values) {
                  for (final mail in mailList.messages) {
                    if (mail.threadId == null || mail.threadId!.isEmpty) continue;

                    final threadKey = '${mail.threadId}_${oauth.email}';

                    if (processedThreadIds.contains(threadKey)) continue;

                    if (!threadMap.containsKey(threadKey) || (mail.date != null && threadMap[threadKey]!.date != null && mail.date!.isAfter(threadMap[threadKey]!.date!))) {
                      threadMap[threadKey] = mail;
                    }
                  }
                }

                for (final entry in threadMap.entries) {
                  final threadKey = entry.key;
                  final representativeMail = entry.value;

                  if (processedThreadIds.contains(threadKey)) continue;
                  processedThreadIds.add(threadKey);

                  final threadResult = await mailRepository.fetchThreads(
                    oauth: oauth,
                    type: representativeMail.type,
                    threadId: representativeMail.threadId!,
                    labelId: CommonMailLabels.inbox.id,
                    email: oauth.email,
                  );

                  await threadResult.fold(
                    (failure) async {
                      // Failed to fetch thread, skip this thread
                    },
                    (threadMails) async {
                      final date = ref.read(inboxListDateProvider);
                      final isSignedIn = ref.read(authControllerProvider.select((v) => v.requireValue.isSignedIn));
                      final configs = ref.read(inboxConfigListControllerProvider(isSearch: false, year: date.year, month: date.month, day: date.day, isSignedIn: isSignedIn));
                      for (final mail in threadMails) {
                        final config = configs?.configs.firstWhereOrNull((c) => c.id == InboxEntity.getInboxIdFromMail(mail));
                        searchResults.add(InboxEntity.fromMail(mail, config));
                      }
                    },
                  );
                }
              },
            );
          }
        }

        // Search in chat (same logic as _searchAndGenerateContext)
        final chatQuery = keywords.join(' ');
        if (chatQuery.isNotEmpty && !ref.read(shouldUseMockDataProvider)) {
          for (final oauth in messengerOAuths) {
            final chatRepository = ref.watch(chatRepositoryProvider);
            final channels = ref.read(chatChannelListControllerProvider).values.expand((e) => e.channels).toList();
            final user = ref.read(authControllerProvider).requireValue;

            final chatResult = await chatRepository.searchMessage(oauth: oauth, user: user, q: chatQuery, pageToken: null, channels: channels, sortType: SearchSortType.relevant);

            await chatResult.fold(
              (failure) async {
                // Chat search failed, skip this OAuth account
              },
              (result) async {
                final Map<String, MessageEntity> threadMap = {};

                for (final message in result.messages) {
                  final threadId = message.threadId?.isNotEmpty == true && message.threadId != message.id ? message.threadId! : message.id;
                  final threadKey = '${threadId}_${message.teamId}_${message.channelId}';

                  if (processedThreadIds.contains(threadKey)) continue;

                  if (!threadMap.containsKey(threadKey) ||
                      (message.createdAt != null && threadMap[threadKey]!.createdAt != null && message.createdAt!.isAfter(threadMap[threadKey]!.createdAt!))) {
                    threadMap[threadKey] = message;
                  }
                }

                for (final entry in threadMap.entries) {
                  final threadKey = entry.key;
                  final representativeMessage = entry.value;

                  if (processedThreadIds.contains(threadKey)) continue;
                  processedThreadIds.add(threadKey);

                  final _channels = ref.read(chatChannelListControllerProvider).values.expand((e) => e.channels).toList();
                  final channel = _channels.firstWhereOrNull((c) => c.id == representativeMessage.channelId && c.teamId == representativeMessage.teamId);

                  if (channel == null) continue;

                  final parentMessageId = representativeMessage.threadId?.isNotEmpty == true && representativeMessage.threadId != representativeMessage.id
                      ? representativeMessage.threadId!
                      : representativeMessage.id;

                  if (parentMessageId == null) continue;

                  final threadResult = await chatRepository.fetchReplies(oauth: oauth, channel: channel, parentMessageId: parentMessageId);

                  await threadResult.fold(
                    (failure) async {
                      // Failed to fetch thread replies, skip this thread
                    },
                    (threadData) async {
                      final _members = ref.read(chatChannelListControllerProvider).values.expand((e) => e.members).toList();
                      final _groups = ref.read(chatChannelListControllerProvider).values.expand((e) => e.groups).toList();
                      final date = ref.read(inboxListDateProvider);
                      final isSignedIn = ref.read(authControllerProvider.select((v) => v.requireValue.isSignedIn));
                      final configs = ref.read(inboxConfigListControllerProvider(isSearch: false, year: date.year, month: date.month, day: date.day, isSignedIn: isSignedIn));

                      for (final message in threadData.messages) {
                        final member = _members.firstWhereOrNull((m) => m.id == message.userId);
                        if (member != null && message.teamId != null && message.channelId != null && message.userId != null) {
                          final config = configs?.configs.firstWhereOrNull((c) => c.id == InboxEntity.getInboxIdFromChat(message));
                          searchResults.add(InboxEntity.fromChat(message, config, channel, member, _channels, _members, _groups));
                        }
                      }
                    },
                  );
                }
              },
            );
          }
        }

        // Search in calendar (same logic as _searchAndGenerateContext)
        List<EventEntity> eventEntities = [];
        final calendarQuery = keywords.join(' ');
        if (calendarQuery.isNotEmpty && !ref.read(shouldUseMockDataProvider)) {
          for (final oauth in calendarOAuths) {
            final calendarRepository = ref.watch(calendarRepositoryProvider);
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

                final eventResult = await calendarRepository.searchEventLists(query: calendarQuery, oauth: oauth, calendars: calendars, nextPageTokens: null);

                await eventResult.fold(
                  (failure) async {
                    // Calendar search failed, skip this OAuth account
                  },
                  (result) async {
                    final now = DateTime.now();
                    for (final eventList in result.events.values) {
                      for (final foundEvent in eventList) {
                        // Exclude events that start after now
                        if (foundEvent.startDate != null && foundEvent.startDate!.isAfter(now)) {
                          continue;
                        }
                        if (event == null || foundEvent.uniqueId != event.uniqueId) {
                          eventEntities.add(foundEvent);
                        }
                      }
                    }
                  },
                );
              },
            );
          }
        }

        // Sort by date (closest to today first) and limit total results
        searchResults.sort((a, b) => b.inboxDatetime.compareTo(a.inboxDatetime));
        taskEntities.sort((a, b) {
          final aDate = a.startAt ?? a.startDate ?? DateTime(1970);
          final bDate = b.startAt ?? b.startDate ?? DateTime(1970);
          return bDate.compareTo(aDate);
        });
        eventEntities.sort((a, b) {
          final aDate = a.startDate ?? DateTime(1970);
          final bDate = b.startDate ?? DateTime(1970);
          return bDate.compareTo(aDate);
        });
        searchResults = searchResults.take(20).toList();
        taskEntities = taskEntities.take(20).toList();
        eventEntities = eventEntities.take(20).toList();

        if (searchResults.isEmpty && taskEntities.isEmpty && eventEntities.isEmpty) {
          return {
            'success': true,
            'result': {'summary': 'No previous context available'},
            'message': Utils.mainContext.tr.mcp_previous_context_not_available,
          };
        }

        // Create virtual inbox from search results
        final firstLinkedInbox = searchResults.firstWhereOrNull((i) => i.linkedMail != null || i.linkedMessage != null);

        InboxEntity? baseInbox;
        if (linkedMail != null) {
          baseInbox = InboxEntity(id: InboxEntity.getInboxIdFromLinkedMail(linkedMail), title: linkedMail.title, description: null, linkedMail: linkedMail);
        } else if (linkedMessage != null) {
          baseInbox = InboxEntity(id: InboxEntity.getInboxIdFromLinkedChat(linkedMessage), title: linkedMessage.userName, description: null, linkedMessage: linkedMessage);
        }

        var virtualInbox =
            baseInbox ??
            InboxEntity(
              id: 'search_${event?.uniqueId ?? task?.id}',
              title: event?.title ?? task?.title ?? 'Untitled',
              description: event?.description ?? task?.description,
              linkedMail: firstLinkedInbox?.linkedMail,
              linkedMessage: firstLinkedInbox?.linkedMessage,
            );

        // Note: Attachment extraction is now handled separately via summarizeAttachment MCP function
        // when user explicitly requests it

        // Generate summary from search results
        // Include virtualInbox in allInboxes if it has linkedMail/linkedMessage to ensure its description (with attachments) is included
        final allInboxesForSummary = <InboxEntity>[];
        if (virtualInbox.linkedMail != null || virtualInbox.linkedMessage != null) {
          // Check if virtualInbox is already in searchResults
          final isInSearchResults = searchResults.any((i) => i.id == virtualInbox.id);
          if (!isInSearchResults) {
            allInboxesForSummary.add(virtualInbox);
          }
        }
        allInboxesForSummary.addAll(searchResults);

        print(
          '[Attachment] Calling fetchConversationSummary with ${allInboxesForSummary.length} inboxes (virtualInbox included: ${virtualInbox.linkedMail != null || virtualInbox.linkedMessage != null})',
        );
        final summaryResult = await repository.fetchConversationSummary(
          inbox: virtualInbox,
          allInboxes: allInboxesForSummary,
          eventEntities: eventEntities,
          taskEntities: taskEntities,
          userId: userId,
          taskId: effectiveTaskId,
          eventId: effectiveEventId,
        );

        final summary = summaryResult.fold((failure) => null, (summary) => summary);

        if (summary == null || summary.isEmpty) {
          return {
            'success': true,
            'result': {'summary': 'No previous context available'},
            'message': Utils.mainContext.tr.mcp_previous_context_not_available,
          };
        }

        return {
          'success': true,
          'result': {'summary': summary},
          'message': Utils.mainContext.tr.mcp_previous_context_retrieved,
        };
      } else if (inbox != null) {
        // If only inboxId is provided and no linked task/event, use inbox directly
        // This follows the same logic as inboxConversationSummaryController

        // Import the private function logic by calling it through a provider
        // Since we can't call private functions, we'll use the repository directly
        final repository = ref.read(inboxRepositoryProvider);
        final userId = ref.read(authControllerProvider).requireValue.id;

        // Extract linkedMail/linkedMessage from inbox
        final linkedMail = inbox.linkedMail;
        final linkedMessage = inbox.linkedMessage;

        // Extract search keywords from inbox title/description
        final keywordsResult = await repository.extractSearchKeywords(
          taskTitle: inbox.decryptedTitle,
          taskDescription: inbox.description,
          taskProjectName: null,
          calendarName: null,
          model: 'gpt-4o-mini',
        );

        final keywords = keywordsResult.fold((failure) => null, (keywords) => keywords);
        if (keywords == null || keywords.isEmpty) {
          return {
            'success': true,
            'result': {'summary': 'No previous context available'},
            'message': Utils.mainContext.tr.mcp_previous_context_not_available,
          };
        }

        // Get all integrated OAuth accounts
        final mailOAuths = ref.read(localPrefControllerProvider.select((v) => v.value?.mailOAuths)) ?? [];
        final messengerOAuths = ref.read(localPrefControllerProvider.select((v) => v.value?.messengerOAuths)) ?? [];
        final calendarOAuths = ref.read(localPrefControllerProvider.select((v) => v.value?.calendarOAuths)) ?? [];

        // Search in each datasource (same logic as _searchAndGenerateContext)
        List<InboxEntity> searchResults = [];
        List<TaskEntity> taskEntities = [];
        List<EventEntity> eventEntities = [];
        final Set<String> processedThreadIds = {};

        // Process linkedMail/linkedMessage first if provided
        if (linkedMail != null && linkedMail.threadId.isNotEmpty) {
          final threadKey = '${linkedMail.threadId}_${linkedMail.hostMail}';
          if (!processedThreadIds.contains(threadKey)) {
            processedThreadIds.add(threadKey);

            final mailRepository = ref.watch(mailRepositoryProvider);
            final oauths = ref.read(localPrefControllerProvider.select((v) => v.value?.mailOAuths)) ?? [];
            final oauth = oauths.firstWhereOrNull((o) => o.email == linkedMail.hostMail);

            if (oauth != null) {
              final threadResult = await mailRepository.fetchThreads(
                oauth: oauth,
                type: linkedMail.type,
                threadId: linkedMail.threadId,
                labelId: CommonMailLabels.inbox.id,
                email: linkedMail.hostMail,
              );

              await threadResult.fold(
                (failure) async {
                  // Failed to fetch thread
                },
                (threadMails) async {
                  final date = ref.read(inboxListDateProvider);
                  final isSignedIn = ref.read(authControllerProvider.select((v) => v.requireValue.isSignedIn));
                  final configs = ref.read(inboxConfigListControllerProvider(isSearch: false, year: date.year, month: date.month, day: date.day, isSignedIn: isSignedIn));
                  for (final mail in threadMails) {
                    final config = configs?.configs.firstWhereOrNull((c) => c.id == InboxEntity.getInboxIdFromMail(mail));
                    searchResults.add(InboxEntity.fromMail(mail, config));
                  }
                },
              );
            }
          }
        } else if (linkedMessage != null) {
          final threadId = linkedMessage.threadId.isNotEmpty && linkedMessage.threadId != linkedMessage.messageId ? linkedMessage.threadId : linkedMessage.messageId;
          final threadKey = '${threadId}_${linkedMessage.teamId}_${linkedMessage.channelId}';

          if (!processedThreadIds.contains(threadKey)) {
            processedThreadIds.add(threadKey);

            final chatRepository = ref.watch(chatRepositoryProvider);
            final channels = ref.read(chatChannelListControllerProvider).values.expand((e) => e.channels).toList();
            final channel = channels.firstWhereOrNull((c) => c.id == linkedMessage.channelId && c.teamId == linkedMessage.teamId);

            if (channel != null) {
              final oauths = ref.read(localPrefControllerProvider.select((v) => v.value?.messengerOAuths)) ?? [];
              final oauth = oauths.firstWhereOrNull((o) => o.team?.id == linkedMessage.teamId);

              if (oauth != null) {
                final threadResult = await chatRepository.fetchReplies(oauth: oauth, channel: channel, parentMessageId: threadId);

                await threadResult.fold(
                  (failure) async {
                    // Failed to fetch thread replies
                  },
                  (threadData) async {
                    final _channels = ref.read(chatChannelListControllerProvider).values.expand((e) => e.channels).toList();
                    final _members = ref.read(chatChannelListControllerProvider).values.expand((e) => e.members).toList();
                    final _groups = ref.read(chatChannelListControllerProvider).values.expand((e) => e.groups).toList();
                    final date = ref.read(inboxListDateProvider);
                    final isSignedIn = ref.read(authControllerProvider.select((v) => v.requireValue.isSignedIn));
                    final configs = ref.read(inboxConfigListControllerProvider(isSearch: false, year: date.year, month: date.month, day: date.day, isSignedIn: isSignedIn));

                    for (final message in threadData.messages) {
                      final msgChannel = _channels.firstWhereOrNull((c) => c.id == message.channelId && c.teamId == message.teamId);
                      final member = _members.firstWhereOrNull((m) => m.id == message.userId);
                      if (msgChannel != null && member != null && message.teamId != null && message.channelId != null && message.userId != null) {
                        final config = configs?.configs.firstWhereOrNull((c) => c.id == InboxEntity.getInboxIdFromChat(message));
                        searchResults.add(InboxEntity.fromChat(message, config, msgChannel, member, _channels, _members, _groups));
                      }
                    }
                  },
                );
              }
            }
          }
        }

        // Search in mail, chat, calendar, tasks using keywords (same as _searchAndGenerateContext)
        if (searchResults.isEmpty && keywords.isNotEmpty) {
          // Search in tasks (local) - from both taskListControllerInternalProvider and calendarTaskListControllerInternalProvider
          final taskQuery = keywords.join(' ');
          if (taskQuery.isNotEmpty) {
            final now = DateTime.now();
            final threeMonthsAgo = DateTime(now.year, now.month - 2, 1);
            final startDate = threeMonthsAgo;
            final endDate = now;

            // Get tasks from both providers (include recent 3 months)
            final allTasks = _getAllTasksFromBothProviders(includeRecentMonths: true);

            // Filter by date range (last 3 months) and keywords
            final filteredTasks = _filterLocalTasks(allTasks, startDate, endDate, taskQuery, null, null);
            // Sort by date (closest to today first) and take 20
            filteredTasks.sort((a, b) {
              final aDate = a.startAt ?? a.startDate ?? DateTime(1970);
              final bDate = b.startAt ?? b.startDate ?? DateTime(1970);
              return bDate.compareTo(aDate);
            });
            taskEntities.addAll(filteredTasks.take(20));
          }

          // Search in mail
          final mailQuery = keywords.join(' ');
          if (mailQuery.isNotEmpty && !ref.read(shouldUseMockDataProvider)) {
            for (final oauth in mailOAuths) {
              final mailRepository = ref.watch(mailRepositoryProvider);
              final user = ref.read(authControllerProvider).requireValue;

              final mailResult = await mailRepository.fetchMailsForLabel(
                oauth: oauth,
                user: user,
                isInbox: false,
                labelId: null,
                email: null,
                pageToken: null,
                q: mailQuery,
                startDate: DateTime.now().subtract(const Duration(days: 30)),
                endDate: DateTime.now(),
              );

              await mailResult.fold(
                (failure) async {
                  // Mail search failed, skip this OAuth account
                },
                (mails) async {
                  final Map<String, MailEntity> threadMap = {};

                  for (final mailList in mails.values) {
                    for (final mail in mailList.messages) {
                      if (mail.threadId == null || mail.threadId!.isEmpty) continue;

                      final threadKey = '${mail.threadId}_${oauth.email}';

                      if (processedThreadIds.contains(threadKey)) continue;

                      if (!threadMap.containsKey(threadKey) || (mail.date != null && threadMap[threadKey]!.date != null && mail.date!.isAfter(threadMap[threadKey]!.date!))) {
                        threadMap[threadKey] = mail;
                      }
                    }
                  }

                  for (final entry in threadMap.entries) {
                    final threadKey = entry.key;
                    final representativeMail = entry.value;

                    if (processedThreadIds.contains(threadKey)) continue;
                    processedThreadIds.add(threadKey);

                    final threadResult = await mailRepository.fetchThreads(
                      oauth: oauth,
                      type: representativeMail.type,
                      threadId: representativeMail.threadId!,
                      labelId: CommonMailLabels.inbox.id,
                      email: oauth.email,
                    );

                    await threadResult.fold(
                      (failure) async {
                        // Failed to fetch thread, skip this thread
                      },
                      (threadMails) async {
                        final date = ref.read(inboxListDateProvider);
                        final isSignedIn = ref.read(authControllerProvider.select((v) => v.requireValue.isSignedIn));
                        final configs = ref.read(inboxConfigListControllerProvider(isSearch: false, year: date.year, month: date.month, day: date.day, isSignedIn: isSignedIn));
                        for (final mail in threadMails) {
                          final config = configs?.configs.firstWhereOrNull((c) => c.id == InboxEntity.getInboxIdFromMail(mail));
                          searchResults.add(InboxEntity.fromMail(mail, config));
                        }
                      },
                    );
                  }
                },
              );
            }
          }

          // Search in chat
          final chatQuery = keywords.join(' ');
          if (chatQuery.isNotEmpty && !ref.read(shouldUseMockDataProvider)) {
            for (final oauth in messengerOAuths) {
              final chatRepository = ref.watch(chatRepositoryProvider);
              final channels = ref.read(chatChannelListControllerProvider).values.expand((e) => e.channels).toList();
              final user = ref.read(authControllerProvider).requireValue;

              final chatResult = await chatRepository.searchMessage(oauth: oauth, user: user, q: chatQuery, pageToken: null, channels: channels, sortType: SearchSortType.relevant);

              await chatResult.fold(
                (failure) async {
                  // Chat search failed, skip this OAuth account
                },
                (result) async {
                  final Map<String, MessageEntity> threadMap = {};

                  for (final message in result.messages) {
                    final threadId = message.threadId?.isNotEmpty == true && message.threadId != message.id ? message.threadId! : message.id;
                    final threadKey = '${threadId}_${message.teamId}_${message.channelId}';

                    if (processedThreadIds.contains(threadKey)) continue;

                    if (!threadMap.containsKey(threadKey) ||
                        (message.createdAt != null && threadMap[threadKey]!.createdAt != null && message.createdAt!.isAfter(threadMap[threadKey]!.createdAt!))) {
                      threadMap[threadKey] = message;
                    }
                  }

                  for (final entry in threadMap.entries) {
                    final threadKey = entry.key;
                    final representativeMessage = entry.value;

                    if (processedThreadIds.contains(threadKey)) continue;
                    processedThreadIds.add(threadKey);

                    final _channels = ref.read(chatChannelListControllerProvider).values.expand((e) => e.channels).toList();
                    final channel = _channels.firstWhereOrNull((c) => c.id == representativeMessage.channelId && c.teamId == representativeMessage.teamId);

                    if (channel == null) continue;

                    final parentMessageId = representativeMessage.threadId?.isNotEmpty == true && representativeMessage.threadId != representativeMessage.id
                        ? representativeMessage.threadId!
                        : representativeMessage.id;

                    if (parentMessageId == null) continue;

                    final threadResult = await chatRepository.fetchReplies(oauth: oauth, channel: channel, parentMessageId: parentMessageId);

                    await threadResult.fold(
                      (failure) async {
                        // Failed to fetch thread replies, skip this thread
                      },
                      (threadData) async {
                        final _members = ref.read(chatChannelListControllerProvider).values.expand((e) => e.members).toList();
                        final _groups = ref.read(chatChannelListControllerProvider).values.expand((e) => e.groups).toList();
                        final date = ref.read(inboxListDateProvider);
                        final isSignedIn = ref.read(authControllerProvider.select((v) => v.requireValue.isSignedIn));
                        final configs = ref.read(inboxConfigListControllerProvider(isSearch: false, year: date.year, month: date.month, day: date.day, isSignedIn: isSignedIn));

                        for (final message in threadData.messages) {
                          final member = _members.firstWhereOrNull((m) => m.id == message.userId);
                          if (member != null && message.teamId != null && message.channelId != null && message.userId != null) {
                            final config = configs?.configs.firstWhereOrNull((c) => c.id == InboxEntity.getInboxIdFromChat(message));
                            searchResults.add(InboxEntity.fromChat(message, config, channel, member, _channels, _members, _groups));
                          }
                        }
                      },
                    );
                  }
                },
              );
            }
          }

          // Search in calendar
          final calendarQuery = keywords.join(' ');
          if (calendarQuery.isNotEmpty && !ref.read(shouldUseMockDataProvider)) {
            for (final oauth in calendarOAuths) {
              final calendarRepository = ref.watch(calendarRepositoryProvider);
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

                  final eventResult = await calendarRepository.searchEventLists(query: calendarQuery, oauth: oauth, calendars: calendars, nextPageTokens: null);

                  await eventResult.fold(
                    (failure) async {
                      // Calendar search failed, skip this OAuth account
                    },
                    (result) async {
                      final now = DateTime.now();
                      for (final eventList in result.events.values) {
                        for (final foundEvent in eventList) {
                          // Exclude events that start after now
                          if (foundEvent.startDate != null && foundEvent.startDate!.isAfter(now)) {
                            continue;
                          }
                          eventEntities.add(foundEvent);
                        }
                      }
                    },
                  );
                },
              );
            }
          }
        }

        // Sort by date (closest to today first) and limit results
        searchResults.sort((a, b) => b.inboxDatetime.compareTo(a.inboxDatetime));
        taskEntities.sort((a, b) {
          final aDate = a.startAt ?? a.startDate ?? DateTime(1970);
          final bDate = b.startAt ?? b.startDate ?? DateTime(1970);
          return bDate.compareTo(aDate);
        });
        eventEntities.sort((a, b) {
          final aDate = a.startDate ?? DateTime(1970);
          final bDate = b.startDate ?? DateTime(1970);
          return bDate.compareTo(aDate);
        });
        searchResults = searchResults.take(20).toList();
        taskEntities = taskEntities.take(20).toList();
        eventEntities = eventEntities.take(20).toList();

        if (searchResults.isEmpty && taskEntities.isEmpty && eventEntities.isEmpty) {
          return {
            'success': true,
            'result': {'summary': 'No previous context available'},
            'message': Utils.mainContext.tr.mcp_previous_context_not_available,
          };
        }

        // Create virtual inbox from inbox or search results
        InboxEntity? baseInbox;
        if (linkedMail != null) {
          baseInbox = InboxEntity(id: InboxEntity.getInboxIdFromLinkedMail(linkedMail), title: linkedMail.title, description: null, linkedMail: linkedMail);
        } else if (linkedMessage != null) {
          baseInbox = InboxEntity(id: InboxEntity.getInboxIdFromLinkedChat(linkedMessage), title: linkedMessage.userName, description: null, linkedMessage: linkedMessage);
        } else {
          baseInbox = inbox;
        }

        // Note: Attachment extraction is now handled separately via summarizeAttachment MCP function
        // when user explicitly requests it

        // Generate summary from search results
        // Include baseInbox in allInboxes if it has linkedMail/linkedMessage to ensure its description (with attachments) is included
        final allInboxesForSummary2 = <InboxEntity>[];
        if (baseInbox != null && (baseInbox.linkedMail != null || baseInbox.linkedMessage != null)) {
          // Check if baseInbox is already in searchResults
          final baseInboxId = baseInbox.id;
          final isInSearchResults = searchResults.any((i) => i.id == baseInboxId);
          if (!isInSearchResults) {
            allInboxesForSummary2.add(baseInbox);
          }
        }
        allInboxesForSummary2.addAll(searchResults);

        print(
          '[Attachment] Calling fetchConversationSummary (inbox-only path) with ${allInboxesForSummary2.length} inboxes (baseInbox included: ${baseInbox != null && (baseInbox.linkedMail != null || baseInbox.linkedMessage != null)})',
        );
        final summaryResult = await repository.fetchConversationSummary(
          inbox: baseInbox ?? inbox,
          allInboxes: allInboxesForSummary2,
          eventEntities: eventEntities,
          taskEntities: taskEntities,
          userId: userId,
          taskId: null,
          eventId: null,
        );

        final summary = summaryResult.fold((failure) => null, (summary) => summary);

        if (summary == null || summary.isEmpty) {
          return {
            'success': true,
            'result': {'summary': 'No previous context available'},
            'message': Utils.mainContext.tr.mcp_previous_context_not_available,
          };
        }

        return {
          'success': true,
          'result': {'summary': summary},
          'message': Utils.mainContext.tr.mcp_previous_context_retrieved,
        };
      } else {
        return {
          'success': true,
          'result': {'summary': 'No previous context available'},
          'message': Utils.mainContext.tr.mcp_previous_context_not_available,
        };
      }
    } catch (e, stackTrace) {
      return {'success': false, 'error': '${Utils.mainContext.tr.mcp_failed_to_get_previous_context}: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> _executeListInboxes(Map<String, dynamic> args, {required TabType tabType}) async {
    final isPinned = args['isPinned'] as bool?;
    final hasLinkedTask = args['hasLinkedTask'] as bool?;
    final limit = args['limit'] as int?;

    try {
      final inboxList = ref.read(inboxControllerProvider);
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

      return {'success': true, 'results': results, 'message': Utils.mainContext.tr.mcp_found_inboxes(results.length)};
    } catch (e) {
      // Provider가 dispose된 경우를 포함한 모든 에러 처리
      if (e.toString().contains('disposed') || e.toString().contains('UnmountedRefException')) {
        return {'success': false, 'error': 'Provider has been disposed'};
      }
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
      final allTasks = _getAllTasksFromBothProviders();
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
        'message': Utils.mainContext.tr.mcp_project_info_retrieved,
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
    final allTasks = availableTasks ?? _getAllTasksFromBothProviders().where((e) => !e.isEventDummyTask && e.startAt != null).toList();
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
    final allTasksForConflictCheck = _getAllTasksFromBothProviders().where((e) => !e.isEventDummyTask && e.startAt != null && e.endAt != null);
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
      for (final task in _getAllTasksFromBothProviders()) {
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

    return {'success': true, 'results': results, 'message': Utils.mainContext.tr.mcp_tasks_rescheduled(results.length)};
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

    return {'success': true, 'results': results, 'message': Utils.mainContext.tr.mcp_found_projects(results.length)};
  }

  Future<Map<String, dynamic>> _executeListTasks(Map<String, dynamic> args, {required TabType tabType}) async {
    final projectId = args['projectId'] as String?;
    final status = args['status'] as String?; // 'none', 'done', 'cancelled'
    final startDate = args['startDate'] as String?; // ISO 8601 format
    final endDate = args['endDate'] as String?; // ISO 8601 format
    final limit = args['limit'] as int?;

    try {
      final allTasks = _getAllTasksFromBothProviders();
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

      return {'success': true, 'results': results, 'message': Utils.mainContext.tr.mcp_found_tasks(results.length)};
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

      return {'success': true, 'results': results, 'message': Utils.mainContext.tr.mcp_found_events(results.length)};
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

      return {'success': true, 'results': results, 'message': Utils.mainContext.tr.mcp_found_projects(results.length)};
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
      final allTasks = _getAllTasksFromBothProviders();
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
        'message': Utils.mainContext.tr.mcp_task_info_retrieved,
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
        'message': Utils.mainContext.tr.mcp_event_info_retrieved,
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

      return {'success': true, 'results': results, 'message': Utils.mainContext.tr.mcp_found_calendars(results.length)};
    } catch (e) {
      return {'success': false, 'error': 'Failed to get calendar list: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> _executeLinkToProject(
    Map<String, dynamic> args, {
    required TabType tabType,
    List<InboxEntity>? availableInboxes,
    List<TaskEntity>? availableTasks,
  }) async {
    final inboxId = args['inboxId'] as String?;
    final taskId = args['taskId'] as String?;
    final projectId = args['projectId'] as String?;

    if (projectId == null) {
      return {'success': false, 'error': 'projectId is required'};
    }

    // If taskId is provided, directly update the task's project
    if (taskId != null && taskId.isNotEmpty) {
      final allTasks = availableTasks ?? _getAllTasksFromBothProviders();
      final task = allTasks.firstWhereOrNull((t) => t.id == taskId);

      if (task == null) {
        return {'success': false, 'error': 'Task not found'};
      }

      final updatedTask = task.copyWith(projectId: projectId, updatedAt: DateTime.now());
      await TaskAction.upsertTask(task: updatedTask, originalTask: task, calendarTaskEditSourceType: CalendarTaskEditSourceType.inboxDrag, tabType: tabType, showToast: false);
      return {'success': true, 'taskId': updatedTask.id, 'message': 'Task moved to project successfully'};
    }

    // If inboxId is provided, use the existing logic
    if (inboxId == null || inboxId.isEmpty) {
      return {'success': false, 'error': 'Either inboxId or taskId is required'};
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
    final date = ref.read(inboxListDateProvider);
    final isSignedIn = ref.read(authControllerProvider.select((v) => v.requireValue.isSignedIn));
    final linkedTasksData = ref.read(inboxLinkedTaskControllerProvider(isSearch: false, year: date.year, month: date.month, day: date.day, isSignedIn: isSignedIn));
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

  /// Get all tasks from both taskListControllerInternalProvider and calendarTaskListControllerInternalProvider
  List<TaskEntity> _getAllTasksFromBothProviders({bool includeRecentMonths = false}) {
    final isSignedIn = ref.read(authControllerProvider.select((v) => v.requireValue.isSignedIn));

    // Get tasks from taskListControllerInternalProvider
    final tasksFromTaskList =
        ref
            .read(taskListControllerInternalProvider(isSignedIn: isSignedIn, labelId: 'all'))
            .value
            ?.tasks
            .where((t) => !t.isCancelled && !t.isOriginalRecurrenceTask && !t.isEventDummyTask)
            .toList() ??
        [];

    // Get tasks from calendarTaskListControllerInternalProvider
    final tasksFromCalendar = <TaskEntity>[];
    if (includeRecentMonths) {
      final now = DateTime.now();
      // Get tasks for current month, 1 month ago, and 2 months ago
      for (int i = 0; i < 3; i++) {
        final targetDate = DateTime(now.year, now.month - i, 1);
        try {
          final monthTasks = ref.read(calendarTaskListControllerInternalProvider(isSignedIn: isSignedIn, targetYear: targetDate.year, targetMonth: targetDate.month)).value ?? [];
          tasksFromCalendar.addAll(monthTasks.where((t) => !t.isCancelled && !t.isOriginalRecurrenceTask && !t.isEventDummyTask));
        } catch (e) {
          // Skip if provider is not available
        }
      }
    } else {
      // Get tasks for current month only
      final now = DateTime.now();
      try {
        final monthTasks = ref.read(calendarTaskListControllerInternalProvider(isSignedIn: isSignedIn, targetYear: now.year, targetMonth: now.month)).value ?? [];
        tasksFromCalendar.addAll(monthTasks.where((t) => !t.isCancelled && !t.isOriginalRecurrenceTask && !t.isEventDummyTask));
      } catch (e) {
        // Skip if provider is not available
      }
    }

    // Combine and deduplicate tasks
    final allTasksMap = <String, TaskEntity>{};
    for (final task in tasksFromTaskList) {
      if (task.id != null) {
        allTasksMap[task.id!] = task;
      }
    }
    for (final task in tasksFromCalendar) {
      if (task.id != null) {
        allTasksMap[task.id!] = task;
      }
    }

    return allTasksMap.values.toList();
  }

  /// 로컬 데이터에서 검색 범위에 해당하는 데이터가 있는지 확인하고 필터링합니다
  List<InboxEntity> _filterLocalInboxes(List<InboxEntity> localInboxes, DateTime? startDate, DateTime? endDate, String? searchKeyword, String? inboxId) {
    var filtered = localInboxes;

    // ID 필터
    if (inboxId != null && inboxId.isNotEmpty) {
      filtered = filtered.where((inbox) => inbox.id == inboxId || inbox.id.contains(inboxId)).toList();
      if (filtered.isEmpty) {
        return [];
      }
    }

    // 날짜 범위 필터
    if (startDate != null || endDate != null) {
      filtered = filtered.where((inbox) {
        final inboxDate = inbox.inboxDatetime;
        if (startDate != null && inboxDate.isBefore(startDate)) return false;
        if (endDate != null && inboxDate.isAfter(endDate)) return false;
        return true;
      }).toList();
      if (filtered.isEmpty) {
        return [];
      }
    }

    // 검색어 필터 (제목, 설명, 발신자에서 검색)
    if (searchKeyword != null && searchKeyword.isNotEmpty) {
      final keyword = searchKeyword.toLowerCase();
      filtered = filtered.where((inbox) {
        final title = inbox.title?.toLowerCase() ?? '';
        final description = inbox.description?.toLowerCase() ?? '';
        final sender = (inbox.linkedMail?.fromName ?? inbox.linkedMessage?.userName ?? '').toLowerCase();
        return title.contains(keyword) || description.contains(keyword) || sender.contains(keyword);
      }).toList();
    }

    return filtered;
  }

  /// 로컬 데이터에 검색 범위에 해당하는 데이터가 충분히 있는지 확인합니다
  bool _hasLocalDataForScope(DateTime? startDate, DateTime? endDate) {
    if (startDate == null && endDate == null) {
      return false;
    }

    try {
      final inboxList = ref.read(inboxControllerProvider);
      final localInboxes = inboxList?.inboxes ?? [];
      if (localInboxes.isEmpty) {
        return false;
      }

      // 날짜 범위에 해당하는 데이터가 있는지 확인
      final matchingCount = localInboxes.where((inbox) {
        final inboxDate = inbox.inboxDatetime;
        if (startDate != null && inboxDate.isBefore(startDate)) return false;
        if (endDate != null && inboxDate.isAfter(endDate)) return false;
        return true;
      }).length;

      // 최소 5개 이상의 데이터가 있으면 로컬 데이터가 충분하다고 판단
      final result = matchingCount >= 5;
      return result;
    } catch (e) {
      return false;
    }
  }

  // Search execution methods
  Future<Map<String, dynamic>> _executeSearchInbox(Map<String, dynamic> args, {required TabType tabType}) async {
    final query = args['query'] as String? ?? '';

    // query나 scope 파라미터(startDate, endDate, inboxId) 중 하나만 있으면 검색 가능 (urgency는 필터링용이므로 제외)
    final hasQuery = query.isNotEmpty;
    final hasScopeParams = args['startDate'] != null || args['endDate'] != null || args['inboxId'] != null;
    if (!hasQuery && !hasScopeParams) {
      return {'success': false, 'error': 'query or scope parameters (startDate, endDate, inboxId) are required'};
    }

    try {
      // AI에서 전달된 scope 파라미터만 사용 (룰베이스 파싱 없음)
      DateTime? startDate;
      DateTime? endDate;
      String? searchKeyword = query.isNotEmpty ? query : null;
      String? inboxId;

      // AI에서 전달된 파라미터 확인 (urgency는 제외)
      if (args['startDate'] != null) {
        try {
          startDate = DateTime.parse(args['startDate'] as String).toLocal();
        } catch (e) {
          // 파싱 실패 시 무시
        }
      }
      if (args['endDate'] != null) {
        try {
          endDate = DateTime.parse(args['endDate'] as String).toLocal();
        } catch (e) {
          // 파싱 실패 시 무시
        }
      }
      if (args['inboxId'] != null) {
        inboxId = args['inboxId'] as String?;
      }

      // 로컬 데이터 확인
      final hasLocalData = _hasLocalDataForScope(startDate, endDate);
      List<InboxEntity> searchResults;

      if (hasLocalData) {
        // 로컬 데이터에서 필터링
        final inboxList = ref.read(inboxControllerProvider);
        final localInboxes = inboxList?.inboxes ?? [];
        searchResults = _filterLocalInboxes(localInboxes, startDate, endDate, searchKeyword, inboxId);
      } else {
        // Remote search 실행 (검색어가 있을 때만)
        if (searchKeyword != null && searchKeyword.isNotEmpty) {
          final inboxController = ref.read(inboxControllerProvider.notifier);
          await inboxController.search(query: searchKeyword);

          // Wait a bit for search to complete
          await Future.delayed(const Duration(milliseconds: 500));

          // Get search results
          final inboxList = ref.read(inboxControllerProvider);
          final remoteResults = inboxList?.inboxes ?? [];

          // 로컬에서 추가 필터링 (날짜 범위 등)
          searchResults = _filterLocalInboxes(remoteResults, startDate, endDate, searchKeyword, inboxId);
        } else {
          // 검색어가 없으면 로컬 데이터에서만 필터링
          final inboxList = ref.read(inboxControllerProvider);
          final localInboxes = inboxList?.inboxes ?? [];
          searchResults = _filterLocalInboxes(localInboxes, startDate, endDate, searchKeyword, inboxId);
        }
      }

      // Format results
      final results = searchResults.map((inbox) {
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

      return {'success': true, 'results': results, 'count': results.length, 'message': Utils.mainContext.tr.mcp_found_inbox_items(results.length)};
    } catch (e) {
      // Provider가 dispose된 경우를 포함한 모든 에러 처리
      if (e.toString().contains('disposed') || e.toString().contains('UnmountedRefException')) {
        return {'success': false, 'error': 'Provider has been disposed'};
      }
      return {'success': false, 'error': 'Search error: ${e.toString()}'};
    }
  }

  /// 로컬 태스크 데이터에서 검색 범위에 해당하는 데이터가 있는지 확인하고 필터링합니다
  List<TaskEntity> _filterLocalTasks(List<TaskEntity> localTasks, DateTime? startDate, DateTime? endDate, String? searchKeyword, String? taskId, bool? isDone) {
    var filtered = localTasks;
    final now = DateTime.now();

    // ID 필터
    if (taskId != null && taskId.isNotEmpty) {
      filtered = filtered.where((task) => task.id == taskId || task.id?.contains(taskId) == true).toList();
      if (filtered.isEmpty) return [];
    }

    // 날짜 범위 필터 (endDate가 null이면 now를 사용, startDate가 null이면 제한 없음)
    if (startDate != null || endDate != null) {
      filtered = filtered.where((task) {
        final taskDate = task.startAt ?? task.startDate;
        if (taskDate == null) return false;
        // Always exclude tasks that start after now
        if (taskDate.isAfter(now)) return false;
        if (startDate != null && taskDate.isBefore(startDate)) return false;
        if (endDate != null && taskDate.isAfter(endDate)) return false;
        return true;
      }).toList();
      if (filtered.isEmpty) return [];
    } else {
      // 날짜 범위 필터가 없어도 now 이후의 task는 제외
      filtered = filtered.where((task) {
        final taskDate = task.startAt ?? task.startDate;
        if (taskDate == null) return false;
        return !taskDate.isAfter(now);
      }).toList();
      if (filtered.isEmpty) return [];
    }

    // 완료 상태 필터
    if (isDone != null) {
      filtered = filtered.where((task) => (task.status == TaskStatus.done) == isDone).toList();
      if (filtered.isEmpty) return [];
    }

    // 검색어 필터 (제목, 설명에서 검색)
    if (searchKeyword != null && searchKeyword.isNotEmpty) {
      final keyword = searchKeyword.toLowerCase();
      filtered = filtered.where((task) {
        final title = task.title?.toLowerCase() ?? '';
        final description = task.description?.toLowerCase() ?? '';
        return title.contains(keyword) || description.contains(keyword);
      }).toList();
    }

    return filtered;
  }

  /// 로컬 태스크 데이터에 검색 범위에 해당하는 데이터가 충분히 있는지 확인합니다
  bool _hasLocalTaskDataForScope(DateTime? startDate, DateTime? endDate) {
    if (startDate == null && endDate == null) return false;

    try {
      final allTasks = _getAllTasksFromBothProviders();
      if (allTasks.isEmpty) return false;

      // 날짜 범위에 해당하는 데이터가 있는지 확인
      final matchingCount = allTasks.where((task) {
        final taskDate = task.startAt ?? task.startDate;
        if (taskDate == null) return false;
        if (startDate != null && taskDate.isBefore(startDate)) return false;
        if (endDate != null && taskDate.isAfter(endDate)) return false;
        return true;
      }).length;

      // 최소 5개 이상의 데이터가 있으면 로컬 데이터가 충분하다고 판단
      return matchingCount >= 5;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>> _executeSearchTask(Map<String, dynamic> args) async {
    final query = args['query'] as String? ?? '';

    // query나 scope 파라미터(startDate, endDate, taskId) 중 하나만 있으면 검색 가능
    final hasQuery = query.isNotEmpty;
    final hasScopeParams = args['startDate'] != null || args['endDate'] != null || args['taskId'] != null;
    if (!hasQuery && !hasScopeParams) {
      return {'success': false, 'error': 'query or scope parameters (startDate, endDate, taskId) are required'};
    }

    final isDone = args['isDone'] as bool?;

    try {
      // AI에서 전달된 scope 파라미터만 사용 (룰베이스 파싱 없음)
      DateTime? startDate;
      DateTime? endDate;
      String? searchKeyword = query.isNotEmpty ? query : null;
      String? taskId;

      // AI에서 전달된 파라미터 확인
      if (args['startDate'] != null) {
        try {
          startDate = DateTime.parse(args['startDate'] as String).toLocal();
        } catch (e) {
          // Invalid date format, ignore
        }
      }
      if (args['endDate'] != null) {
        try {
          endDate = DateTime.parse(args['endDate'] as String).toLocal();
        } catch (e) {
          // Invalid date format, ignore
        }
      }
      if (args['taskId'] != null) {
        taskId = args['taskId'] as String?;
      }

      // 로컬 데이터 확인
      final hasLocalData = _hasLocalTaskDataForScope(startDate, endDate);
      List<TaskEntity> searchResults;

      if (hasLocalData) {
        // 로컬 데이터에서 필터링
        final allTasks = _getAllTasksFromBothProviders();
        searchResults = _filterLocalTasks(allTasks, startDate, endDate, searchKeyword, taskId, isDone);
      } else {
        // Remote search 실행
        final user = ref.read(authControllerProvider).requireValue;
        final pref = ref.read(localPrefControllerProvider).value;
        if (pref == null) {
          return {'success': false, 'error': 'Preferences not found'};
        }

        final taskRepository = ref.read(taskRepositoryProvider);
        final searchResult = await taskRepository.searchTasks(query: query, pref: pref, userId: user.id, isDone: isDone);

        final tasks = searchResult.fold((failure) => <TaskEntity>[], (result) => result.tasks.values.expand((e) => e).toList());

        // 로컬에서 추가 필터링 (날짜 범위 등)
        searchResults = _filterLocalTasks(tasks, startDate, endDate, searchKeyword, taskId, isDone);
      }

      // Sort by date (closest to today first) and limit results to 20
      searchResults.sort((a, b) {
        final aDate = a.startAt ?? a.startDate ?? DateTime(1970);
        final bDate = b.startAt ?? b.startDate ?? DateTime(1970);
        return bDate.compareTo(aDate);
      });
      final limitedTasks = searchResults.take(20).toList();

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

      return {'success': true, 'results': results, 'count': results.length, 'message': Utils.mainContext.tr.mcp_found_tasks(results.length)};
    } catch (e) {
      return {'success': false, 'error': 'Search error: ${e.toString()}'};
    }
  }

  /// 로컬 일정 데이터에서 검색 범위에 해당하는 데이터가 있는지 확인하고 필터링합니다
  List<EventEntity> _filterLocalEvents(List<EventEntity> localEvents, DateTime? startDate, DateTime? endDate, String? searchKeyword, String? eventId) {
    var filtered = localEvents;
    final now = DateTime.now();

    // ID 필터
    if (eventId != null && eventId.isNotEmpty) {
      filtered = filtered.where((event) => event.eventId == eventId || event.uniqueId == eventId || event.eventId?.contains(eventId) == true).toList();
      if (filtered.isEmpty) return [];
    }

    // 날짜 범위 필터 (endDate가 null이면 now를 사용, startDate가 null이면 제한 없음)
    if (startDate != null || endDate != null) {
      filtered = filtered.where((event) {
        final eventStart = event.startDate;
        if (eventStart == null) return false;
        // Always exclude events that start after now
        if (eventStart.isAfter(now)) return false;
        if (startDate != null && eventStart.isBefore(startDate)) return false;
        if (endDate != null && eventStart.isAfter(endDate)) return false;
        return true;
      }).toList();
      if (filtered.isEmpty) return [];
    } else {
      // 날짜 범위 필터가 없어도 now 이후의 event는 제외
      filtered = filtered.where((event) {
        final eventStart = event.startDate;
        if (eventStart == null) return false;
        return !eventStart.isAfter(now);
      }).toList();
      if (filtered.isEmpty) return [];
    }

    // 검색어 필터 (제목, 설명, 위치에서 검색)
    if (searchKeyword != null && searchKeyword.isNotEmpty) {
      final keyword = searchKeyword.toLowerCase();
      filtered = filtered.where((event) {
        final title = event.title?.toLowerCase() ?? '';
        final description = event.description?.toLowerCase() ?? '';
        final location = event.location?.toLowerCase() ?? '';
        return title.contains(keyword) || description.contains(keyword) || location.contains(keyword);
      }).toList();
    }

    return filtered;
  }

  /// 로컬 일정 데이터에 검색 범위에 해당하는 데이터가 충분히 있는지 확인합니다
  bool _hasLocalEventDataForScope(DateTime? startDate, DateTime? endDate) {
    if (startDate == null && endDate == null) return false;

    try {
      final allEvents = ref.read(calendarEventListControllerProvider(tabType: TabType.calendar)).eventsOnView;
      if (allEvents.isEmpty) return false;

      // 날짜 범위에 해당하는 데이터가 있는지 확인
      final matchingCount = allEvents.where((event) {
        final eventStart = event.startDate;
        if (eventStart == null) return false;
        if (startDate != null && eventStart.isBefore(startDate)) return false;
        if (endDate != null && eventStart.isAfter(endDate)) return false;
        return true;
      }).length;

      // 최소 5개 이상의 데이터가 있으면 로컬 데이터가 충분하다고 판단
      return matchingCount >= 5;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>> _executeSearchCalendarEvent(Map<String, dynamic> args, {required TabType tabType}) async {
    final query = args['query'] as String? ?? '';

    // query나 scope 파라미터(startDate, endDate, eventId) 중 하나만 있으면 검색 가능
    final hasQuery = query.isNotEmpty;
    final hasScopeParams = args['startDate'] != null || args['endDate'] != null || args['eventId'] != null;
    if (!hasQuery && !hasScopeParams) {
      return {'success': false, 'error': 'query or scope parameters (startDate, endDate, eventId) are required'};
    }

    try {
      // AI에서 전달된 scope 파라미터만 사용 (룰베이스 파싱 없음)
      DateTime? startDate;
      DateTime? endDate;
      String? searchKeyword = query.isNotEmpty ? query : null;
      String? eventId;

      // AI에서 전달된 파라미터 확인
      if (args['startDate'] != null) {
        try {
          startDate = DateTime.parse(args['startDate'] as String).toLocal();
        } catch (e) {
          // Invalid date format, ignore
        }
      }
      if (args['endDate'] != null) {
        try {
          endDate = DateTime.parse(args['endDate'] as String).toLocal();
        } catch (e) {
          // Invalid date format, ignore
        }
      }
      if (args['eventId'] != null) {
        eventId = args['eventId'] as String?;
      }

      // 로컬 데이터 확인
      final hasLocalData = _hasLocalEventDataForScope(startDate, endDate);
      List<EventEntity> searchResults;

      if (hasLocalData) {
        // 로컬 데이터에서 필터링
        final allEvents = ref.read(calendarEventListControllerProvider(tabType: tabType)).eventsOnView;
        searchResults = _filterLocalEvents(allEvents, startDate, endDate, searchKeyword, eventId);
      } else {
        // Remote search 실행 (검색어가 있을 때만)
        if (searchKeyword != null && searchKeyword.isNotEmpty) {
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

                final eventResult = await calendarRepository.searchEventLists(query: searchKeyword, oauth: oauth, calendars: calendars, nextPageTokens: null);

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

          // 로컬에서 추가 필터링 (날짜 범위 등)
          searchResults = _filterLocalEvents(allEvents, startDate, endDate, searchKeyword, eventId);
        } else {
          // 검색어가 없으면 로컬 데이터에서만 필터링
          final allEvents = ref.read(calendarEventListControllerProvider(tabType: tabType)).eventsOnView;
          searchResults = _filterLocalEvents(allEvents, startDate, endDate, searchKeyword, eventId);
        }
      }

      // Format results
      final results = searchResults.map((event) {
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

      return {'success': true, 'results': results, 'count': results.length, 'message': Utils.mainContext.tr.mcp_found_events(results.length)};
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

      return {'success': true, 'results': results, 'message': Utils.mainContext.tr.mcp_found_labels(results.length)};
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
      final inboxList = ref.read(inboxControllerProvider);
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
      // Provider가 dispose된 경우를 포함한 모든 에러 처리
      if (e.toString().contains('disposed') || e.toString().contains('UnmountedRefException')) {
        return {'success': false, 'error': 'Provider has been disposed'};
      }
      return {'success': false, 'error': 'Failed to pin inbox: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> _executeUnpinInbox(Map<String, dynamic> args, {required TabType tabType}) async {
    final inboxId = args['inboxId'] as String?;

    if (inboxId == null || inboxId.isEmpty) {
      return {'success': false, 'error': 'inboxId is required'};
    }

    try {
      final inboxList = ref.read(inboxControllerProvider);
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
      // Provider가 dispose된 경우를 포함한 모든 에러 처리
      if (e.toString().contains('disposed') || e.toString().contains('UnmountedRefException')) {
        return {'success': false, 'error': 'Provider has been disposed'};
      }
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
      final allTasks = availableTasks ?? _getAllTasksFromBothProviders();
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
      final allTasks = availableTasks ?? _getAllTasksFromBothProviders();
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

      return {'success': true, 'results': results, 'message': Utils.mainContext.tr.mcp_found_attachments(results.length)};
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

  /// Summarizes attachments for a specific inbox
  Future<Map<String, dynamic>> _executeSummarizeAttachment(Map<String, dynamic> args, {required TabType tabType}) async {
    print('[Attachment] summarizeAttachment called with args: $args');
    final inboxId = args['inboxId'] as String?;
    if (inboxId == null || inboxId.isEmpty) {
      print('[Attachment] Error: inboxId is required');
      return {'success': false, 'error': 'inboxId is required'};
    }

    final attachmentId = args['attachmentId'] as String?;
    print('[Attachment] Looking for inbox: $inboxId, attachmentId: $attachmentId');

    // Get inbox from available inboxes or search for it
    final inboxList = ref.read(inboxControllerProvider);
    print('[Attachment] Total inboxes available: ${inboxList?.inboxes.length ?? 0}');
    final inbox = inboxList?.inboxes.firstWhereOrNull((i) => i.id == inboxId);

    if (inbox == null) {
      print('[Attachment] Error: Inbox not found. Available inbox IDs: ${inboxList?.inboxes.map((i) => i.id).take(5).toList()}');
      return {'success': false, 'error': 'Inbox not found'};
    }

    print('[Attachment] Found inbox: ${inbox.id}, linkedMail: ${inbox.linkedMail != null}, linkedMessage: ${inbox.linkedMessage != null}');

    // Extract attachment files (images for PDFs, etc.)
    print('[Attachment] Starting attachment extraction...');
    final attachmentFiles = await _extractAttachmentFiles([inbox], tabType: tabType, attachmentId: attachmentId);

    if (attachmentFiles.containsKey(inboxId)) {
      final files = attachmentFiles[inboxId]!;
      print('[Attachment] Extracted ${files.length} files for inbox $inboxId');

      // Convert PlatformFile list to the format expected by OpenAI API (same as agent_input_field)
      print('[Attachment] Converting ${files.length} files to fileData format...');
      final fileData = files.map((file) {
        final bytesEncoded = file.bytes != null ? base64Encode(file.bytes!) : null;
        print(
          '[Attachment]   - Converting file: ${file.name}, size: ${file.size}, bytes: ${file.bytes != null ? file.bytes!.length : 'null'}, encoded: ${bytesEncoded != null ? bytesEncoded.length : 'null'}',
        );
        return {'name': file.name, 'bytes': bytesEncoded, 'size': file.size};
      }).toList();

      print('[Attachment] Created fileData with ${fileData.length} items');
      print('[Attachment] Calling AI to generate summary from files...');

      // AI에게 파일을 보내서 요약 생성
      try {
        final repository = ref.read(inboxRepositoryProvider);
        final me = ref.read(authControllerProvider).value;
        final userId = me?.id;
        final selectedModelData = ref.read(selectedAgentModelProvider).value;
        final selectedModel = selectedModelData?.model ?? AgentModel.gpt51;
        final useUserApiKey = selectedModelData?.useUserApiKey ?? false;
        String? apiKey;
        if (useUserApiKey) {
          final apiKeys = ref.read(aiApiKeysProvider);
          apiKey = apiKeys[selectedModel.provider.name];
        } else {
          // 모델에 맞는 API 키 가져오기
          switch (selectedModel.provider) {
            case AiProvider.openai:
              apiKey = openAiApiKey.isNotEmpty ? openAiApiKey : null;
              break;
            case AiProvider.google:
              apiKey = googleAiKey.isNotEmpty ? googleAiKey : null;
              break;
            case AiProvider.anthropic:
              apiKey = anthropicApiKey.isNotEmpty ? anthropicApiKey : null;
              break;
          }
        }

        // 파일과 함께 요약 요청
        final conversationHistory = [
          {'role': 'user', 'content': '이 첨부파일의 내용을 요약해주세요. 주요 내용, 금액, 날짜, 중요한 정보를 포함해서 한국어로 간단명료하게 설명해주세요.', 'files': fileData},
        ];

        final summaryResponse = await repository.generateGeneralChat(
          userMessage: '이 첨부파일의 내용을 요약해주세요. 주요 내용, 금액, 날짜, 중요한 정보를 포함해서 한국어로 간단명료하게 설명해주세요.',
          conversationHistory: conversationHistory,
          projectContext: null,
          projects: null,
          taggedContext: null,
          channelContext: null,
          inboxContext: null,
          model: selectedModel.modelName,
          apiKey: apiKey,
          userId: userId,
          systemPrompt:
              'You are a helpful assistant. Analyze the attached file(s) and provide a clear, concise summary in Korean. Include key information such as amounts, dates, important details, and main content.\n\nCRITICAL: DO NOT call any functions. Only provide a text summary of the file content. DO NOT return function calls or JSON arrays. Only return plain text summary in Korean.',
          includeTools: false, // summarizeAttachment에서는 tools 사용하지 않음
        );

        final summaryResult = summaryResponse.fold((failure) => null, (response) => response);
        var summary = summaryResult?['message'] as String? ?? '첨부파일을 다운로드하고 이미지로 변환했습니다.';

        // 함수 호출 부분 제거 (AI가 함수 호출을 반환한 경우)
        print('[Attachment] Raw AI response: $summary');
        final functionCallRegex = RegExp(
          r'\[\s*\{[^}]*"function"\s*:\s*"[^"]+"[^}]*"arguments"\s*:\s*\{[^}]*\}[^}]*\}(?:\s*,\s*\{[^}]*"function"\s*:\s*"[^"]+"[^}]*"arguments"\s*:\s*\{[^}]*\}[^}]*\})*\s*\]',
          dotAll: true,
        );
        summary = summary.replaceAll(functionCallRegex, '').trim();

        // JSON 배열 형식 제거
        try {
          final jsonArrayRegex = RegExp(r'\[(?:\s*\{[^}]*\}(?:\s*,\s*\{[^}]*\})*)?\s*\]', dotAll: true);
          final matches = jsonArrayRegex.allMatches(summary).toList();
          for (final match in matches.reversed) {
            try {
              final arrayStr = summary.substring(match.start, match.end);
              final parsed = jsonDecode(arrayStr) as List<dynamic>?;
              if (parsed != null && parsed.isNotEmpty) {
                bool isFunctionCallArray = false;
                for (final item in parsed) {
                  if (item is Map<String, dynamic> && item.containsKey('function') && item.containsKey('arguments')) {
                    isFunctionCallArray = true;
                    break;
                  }
                }
                if (isFunctionCallArray) {
                  summary = summary.substring(0, match.start) + summary.substring(match.end);
                }
              }
            } catch (e) {
              // Skip invalid JSON
            }
          }
        } catch (e) {
          // Continue with cleaned summary
        }

        // 함수 호출 태그 제거
        summary = summary.replaceAll(RegExp(r'<function_call[^>]*>.*?</function_call>', dotAll: true), '').trim();

        // 빈 문자열이면 기본 메시지 사용
        if (summary.isEmpty) {
          summary = '첨부파일을 다운로드하고 이미지로 변환했습니다.';
        }

        print('[Attachment] AI generated summary value (cleaned): $summary');
        print('[Attachment] AI generated summary length: ${summary.length}');
        print('[Attachment] AI generated summary preview: ${summary.substring(0, summary.length > 100 ? 100 : summary.length)}...');

        return {
          'success': true,
          'result': {'summary': summary, 'files': fileData},
          'message': 'Attachment content extracted and summarized successfully',
        };
      } catch (e) {
        print('[Attachment] Error generating summary: $e');
        // AI 요약 실패 시 기본 메시지 사용
        return {
          'success': true,
          'result': {'summary': '첨부파일을 다운로드하고 이미지로 변환했습니다.', 'files': fileData},
          'message': 'Attachment content extracted successfully',
        };
      }
    } else {
      print('[Attachment] No files found for inbox $inboxId');
      return {
        'success': true,
        'result': {'summary': 'No attachments found or no content extracted'},
        'message': 'No attachments found or no content extracted',
      };
    }
  }

  /// Downloads attachments and converts them to PlatformFile format
  /// PDFs are converted to PNG images (one per page)
  Future<Map<String, List<PlatformFile>>> _extractAttachmentFiles(List<InboxEntity> inboxes, {TabType tabType = TabType.home, String? attachmentId}) async {
    print('[Attachment] _extractAttachmentFiles called for ${inboxes.length} inbox(es)');
    final Map<String, List<PlatformFile>> attachmentFiles = {};

    for (final inbox in inboxes) {
      print('[Attachment] Processing inbox: ${inbox.id}');
      final files = <PlatformFile>[];

      try {
        // Process mail attachments
        if (inbox.linkedMail != null) {
          print('[Attachment] Processing mail attachments for inbox: ${inbox.id}');
          final mailRepository = ref.read(mailRepositoryProvider);
          final oauths = ref.read(localPrefControllerProvider.select((v) => v.value?.mailOAuths)) ?? [];
          final oauth = oauths.firstWhereOrNull((o) => o.email == inbox.linkedMail!.hostMail);

          if (oauth != null) {
            final mail = inbox.linkedMail!;
            final mailType = MailEntityTypeX.fromOAuthType(oauth.type);
            final labelIdsToTry = mail.labelIds?.isNotEmpty == true ? mail.labelIds! : [CommonMailLabels.inbox.id, CommonMailLabels.sent.id, CommonMailLabels.archive.id];

            MailEntity? mailEntity;
            for (final labelId in labelIdsToTry) {
              final threadResult = await mailRepository.fetchThreads(oauth: oauth, type: mailType, threadId: mail.threadId, email: mail.hostMail, labelId: labelId);
              final result = threadResult.fold((failure) => null, (threadMails) => threadMails.firstWhereOrNull((m) => m.id == mail.messageId));
              if (result != null) {
                mailEntity = result;
                break;
              }
            }

            if (mailEntity == null) {
              final threadResult = await mailRepository.fetchThreads(
                oauth: oauth,
                type: mailType,
                threadId: mail.threadId,
                email: mail.hostMail,
                labelId: CommonMailLabels.inbox.id,
              );
              mailEntity = threadResult.fold((failure) => null, (threadMails) => threadMails.firstWhereOrNull((m) => m.id == mail.messageId));
            }

            if (mailEntity == null) {
              print('[Attachment] Mail entity not found for inbox: ${inbox.id}');
              continue;
            }

            final attachments = mailEntity.getAttachments();
            print('[Attachment] Found ${attachments.length} attachments for inbox: ${inbox.id}');
            if (attachments.isEmpty) continue;

            var filteredAttachments = attachments;
            if (attachmentId != null && attachmentId.isNotEmpty) {
              filteredAttachments = attachments.where((a) => a.id == attachmentId).toList();
              if (filteredAttachments.isEmpty) {
                print('[Attachment] Attachment $attachmentId not found');
                continue;
              }
            }

            final attachmentIds = filteredAttachments.map((a) => a.id).whereType<String>().toList();
            print('[Attachment] Downloading ${attachmentIds.length} attachments...');
            final fetchResult = await mailRepository.fetchAttachments(email: mail.hostMail, messageId: mail.messageId, oauth: oauth, attachmentIds: attachmentIds);

            await fetchResult.fold(
              (failure) async {
                print('[Attachment] Failed to fetch attachments: ${failure.toString()}');
              },
              (attachmentData) async {
                print('[Attachment] Successfully downloaded ${attachmentData.length} attachments');
                for (final entry in attachmentData.entries) {
                  final attachmentId = entry.key;
                  final bytes = entry.value;
                  if (bytes == null) {
                    print('[Attachment] Attachment $attachmentId has no bytes');
                    continue;
                  }

                  final attachment = attachments.firstWhereOrNull((a) => a.id == attachmentId);
                  if (attachment == null) continue;

                  final fileName = attachment.name ?? 'unknown';
                  print('[Attachment] Processing file: $fileName (${bytes.length} bytes)');

                  // Convert PDF to images or add as-is for other files
                  final convertedFiles = await _convertAttachmentToFiles(bytes, fileName);
                  files.addAll(convertedFiles);
                }
              },
            );
          }
        }
        // Process message attachments (similar logic)
        else if (inbox.linkedMessage != null) {
          final message = inbox.linkedMessage!;
          final oauths = ref.read(localPrefControllerProvider.select((v) => v.value?.messengerOAuths)) ?? [];
          final oauth = oauths.firstWhereOrNull((o) => o.team?.id == message.teamId);

          if (oauth != null) {
            final channels = ref.read(chatChannelListControllerProvider).values.expand((e) => e.channels).toList();
            final channel = channels.firstWhereOrNull((c) => c.id == message.channelId && c.teamId == message.teamId);

            if (channel != null) {
              final chatList = ref.read(chatListControllerProvider(tabType: tabType));
              final messageEntity = chatList?.messages.firstWhereOrNull((m) => m.id == message.messageId);

              if (messageEntity != null) {
                var messageFiles = messageEntity.files;
                if (attachmentId != null && attachmentId.isNotEmpty) {
                  messageFiles = messageFiles.where((f) => f.id == attachmentId).toList();
                  if (messageFiles.isEmpty) {
                    print('[Attachment] Attachment $attachmentId not found in message files');
                    continue;
                  }
                }

                for (final file in messageFiles) {
                  final downloadUrl = file.downloadUrl;
                  if (downloadUrl == null || downloadUrl.isEmpty) continue;

                  try {
                    final fileBytes =
                        await proxyCall(
                              url: downloadUrl,
                              method: 'GET',
                              body: null,
                              oauth: oauth,
                              headers: oauth.authorizationHeaders ?? {},
                              files: null,
                              responseType: ResponseType.bytes,
                            )
                            as Uint8List?;

                    if (fileBytes != null) {
                      final fileName = file.name ?? 'unknown';
                      final convertedFiles = await _convertAttachmentToFiles(fileBytes, fileName);
                      files.addAll(convertedFiles);
                    }
                  } catch (e) {
                    print('[Attachment] Error downloading message attachment: $e');
                    continue;
                  }
                }
              }
            }
          }
        }
      } catch (e) {
        print('[Attachment] Error processing attachments for inbox ${inbox.id}: $e');
        continue;
      }

      if (files.isNotEmpty) {
        attachmentFiles[inbox.id] = files;
        print('[Attachment] Added ${files.length} files for inbox: ${inbox.id}');
      } else {
        print('[Attachment] No files extracted for inbox: ${inbox.id}');
      }
    }

    print('[Attachment] Total inboxes with files: ${attachmentFiles.length}');
    return attachmentFiles;
  }

  /// Converts attachment bytes to PlatformFile list
  /// PDFs are converted to PNG images (one per page, max 10 pages)
  Future<List<PlatformFile>> _convertAttachmentToFiles(Uint8List bytes, String fileName) async {
    final files = <PlatformFile>[];
    final lowerName = fileName.toLowerCase();

    try {
      // PDF files - convert each page to PNG image
      if (lowerName.endsWith('.pdf')) {
        try {
          final pdfDocument = await PdfDocument.openData(bytes);
          final pageCount = pdfDocument.pagesCount;
          final maxPages = pageCount > 10 ? 10 : pageCount;

          for (int i = 1; i <= maxPages; i++) {
            try {
              final page = await pdfDocument.getPage(i);

              // PDF 페이지 크기 확인 (포인트 단위)
              final pageWidth = page.width;
              final pageHeight = page.height;
              print('[Attachment] PDF page $i size: ${pageWidth}x${pageHeight} points');

              // 고해상도로 렌더링 (OpenAI Vision API 권장: 최소 512x512, 최적 1024x1024)
              // PDF 포인트를 픽셀로 변환 (72 DPI 기준, 3배 해상도 = 216 DPI로 충분히 높은 해상도)
              // 최소 1024px 너비로 스케일링하여 텍스트가 선명하게 보이도록 함
              final scaleFactor = (1024.0 / pageWidth).clamp(2.0, 4.0); // 최소 2배, 최대 4배
              final targetWidth = (pageWidth * scaleFactor);
              final targetHeight = (pageHeight * scaleFactor);

              print('[Attachment] Rendering PDF page $i at ${targetWidth.toInt()}x${targetHeight.toInt()} pixels (scale: ${scaleFactor.toStringAsFixed(2)}x)');

              final pageImage = await page.render(
                width: targetWidth,
                height: targetHeight,
                format: PdfPageImageFormat.png,
                backgroundColor: '#FFFFFF', // 흰색 배경
              );

              final imageBytes = pageImage?.bytes;
              if (imageBytes != null && imageBytes.isNotEmpty) {
                files.add(PlatformFile(name: '${fileName}_page_$i.png', size: imageBytes.length, bytes: imageBytes));
                print('[Attachment] Converted PDF page $i to PNG (${imageBytes.length} bytes, ${targetWidth}x${targetHeight}px)');
              } else {
                print('[Attachment] Failed to render PDF page $i - no image bytes');
              }

              page.close();
            } catch (e) {
              print('[Attachment] Error converting PDF page $i: $e');
              continue;
            }
          }

          pdfDocument.close();
        } catch (e) {
          print('[Attachment] Error converting PDF to images: $e');
        }
      }
      // Image files - add as-is
      else if (lowerName.endsWith('.png') || lowerName.endsWith('.jpg') || lowerName.endsWith('.jpeg') || lowerName.endsWith('.gif') || lowerName.endsWith('.webp')) {
        files.add(PlatformFile(name: fileName, size: bytes.length, bytes: bytes));
      }
      // Text files - add as-is
      else if (lowerName.endsWith('.txt') || lowerName.endsWith('.md') || lowerName.endsWith('.csv')) {
        files.add(PlatformFile(name: fileName, size: bytes.length, bytes: bytes));
      }
    } catch (e) {
      print('[Attachment] Error converting attachment to files: $e');
    }

    return files;
  }

  /// Downloads attachments from inboxes and extracts content as images/text
  /// Returns a map of inbox ID to attachment content array (OpenAI message format)
  Future<Map<String, List<Map<String, dynamic>>>> _extractAttachmentTexts(List<InboxEntity> inboxes, {TabType tabType = TabType.home, String? attachmentId}) async {
    print('[Attachment] _extractAttachmentTexts called for ${inboxes.length} inbox(es)');
    final Map<String, List<Map<String, dynamic>>> attachmentContents = {};

    for (final inbox in inboxes) {
      print('[Attachment] Processing inbox: ${inbox.id}');
      final contentArray = <Map<String, dynamic>>[];

      try {
        // Process mail attachments
        if (inbox.linkedMail != null) {
          print('[Attachment] Processing mail attachments for inbox: ${inbox.id}');
          final mailRepository = ref.read(mailRepositoryProvider);
          final oauths = ref.read(localPrefControllerProvider.select((v) => v.value?.mailOAuths)) ?? [];
          final oauth = oauths.firstWhereOrNull((o) => o.email == inbox.linkedMail!.hostMail);

          if (oauth != null) {
            final mail = inbox.linkedMail!;
            final mailType = MailEntityTypeX.fromOAuthType(oauth.type);

            // Get full mail entity to access attachments using threadId and messageId
            // Try multiple labelIds if the first one doesn't work
            final labelIdsToTry = mail.labelIds?.isNotEmpty == true ? mail.labelIds! : [CommonMailLabels.inbox.id, CommonMailLabels.sent.id, CommonMailLabels.archive.id];

            MailEntity? mailEntity;

            for (final labelId in labelIdsToTry) {
              final threadResult = await mailRepository.fetchThreads(oauth: oauth, type: mailType, threadId: mail.threadId, email: mail.hostMail, labelId: labelId);

              final result = threadResult.fold((failure) => null, (threadMails) {
                return threadMails.firstWhereOrNull((m) => m.id == mail.messageId);
              });

              if (result != null) {
                mailEntity = result;
                break;
              }
            }

            if (mailEntity == null) {
              // If not found in any label, try inbox as fallback
              final threadResult = await mailRepository.fetchThreads(
                oauth: oauth,
                type: mailType,
                threadId: mail.threadId,
                email: mail.hostMail,
                labelId: CommonMailLabels.inbox.id,
              );

              mailEntity = threadResult.fold((failure) => null, (threadMails) => threadMails.firstWhereOrNull((m) => m.id == mail.messageId));
            }

            if (mailEntity == null) {
              print('[Attachment] Mail entity not found for inbox: ${inbox.id}, messageId: ${mail.messageId}');
              continue;
            }

            final attachments = mailEntity.getAttachments();
            print('[Attachment] Found ${attachments.length} attachments for inbox: ${inbox.id}');
            if (attachments.isEmpty) continue;

            // Filter by attachmentId if provided
            var filteredAttachments = attachments;
            if (attachmentId != null && attachmentId.isNotEmpty) {
              filteredAttachments = attachments.where((a) => a.id == attachmentId).toList();
              if (filteredAttachments.isEmpty) {
                print('[Attachment] Attachment $attachmentId not found');
                continue;
              }
            }

            final attachmentIds = filteredAttachments.map((a) => a.id).whereType<String>().toList();
            print('[Attachment] Downloading ${attachmentIds.length} attachments...');
            final fetchResult = await mailRepository.fetchAttachments(email: mail.hostMail, messageId: mail.messageId, oauth: oauth, attachmentIds: attachmentIds);

            await fetchResult.fold(
              (failure) async {
                print('[Attachment] Failed to fetch attachments: ${failure.toString()}');
              },
              (attachmentData) async {
                print('[Attachment] Successfully downloaded ${attachmentData.length} attachments');
                for (final entry in attachmentData.entries) {
                  final attachmentId = entry.key;
                  final bytes = entry.value;
                  if (bytes == null) {
                    print('[Attachment] Attachment $attachmentId has no bytes');
                    continue;
                  }

                  final attachment = attachments.firstWhereOrNull((a) => a.id == attachmentId);
                  if (attachment == null) {
                    print('[Attachment] Attachment $attachmentId not found in attachment list');
                    continue;
                  }

                  final fileName = attachment.name ?? 'unknown';
                  print('[Attachment] Extracting content from: $fileName (${bytes.length} bytes)');
                  final contentItems = await _extractContentFromBytes(bytes, fileName);
                  if (contentItems.isNotEmpty) {
                    print('[Attachment] Extracted ${contentItems.length} content items from $fileName');
                    // Add file name as text
                    contentArray.add({'type': 'text', 'text': 'Attachment "$fileName":'});
                    // Add content items (images or text)
                    contentArray.addAll(contentItems);
                  } else {
                    print('[Attachment] No content extracted from $fileName (may be unsupported format)');
                  }
                }
              },
            );
          }
        }
        // Process message attachments
        else if (inbox.linkedMessage != null) {
          final message = inbox.linkedMessage!;
          final oauths = ref.read(localPrefControllerProvider.select((v) => v.value?.messengerOAuths)) ?? [];
          final oauth = oauths.firstWhereOrNull((o) => o.team?.id == message.teamId);

          if (oauth != null) {
            // Get full message entity to access files
            final chatRepository = ref.read(chatRepositoryProvider);
            final channels = ref.read(chatChannelListControllerProvider).values.expand((e) => e.channels).toList();
            final channel = channels.firstWhereOrNull((c) => c.id == message.channelId && c.teamId == message.teamId);

            if (channel != null) {
              // Fetch message details to get files
              // Get full message entity from chat list
              final chatList = ref.read(chatListControllerProvider(tabType: tabType));
              final messageEntity = chatList?.messages.firstWhereOrNull((m) => m.id == message.messageId);

              if (messageEntity != null) {
                var files = messageEntity.files;

                // Filter by attachmentId if provided
                if (attachmentId != null && attachmentId.isNotEmpty) {
                  files = files.where((f) => f.id == attachmentId).toList();
                  if (files.isEmpty) {
                    print('[Attachment] Attachment $attachmentId not found in message files');
                    continue;
                  }
                }

                if (files.isNotEmpty) {
                  for (final file in files) {
                    final downloadUrl = file.downloadUrl;
                    if (downloadUrl == null || downloadUrl.isEmpty) continue;

                    try {
                      final fileBytes =
                          await proxyCall(
                                url: downloadUrl,
                                method: 'GET',
                                body: null,
                                oauth: oauth,
                                headers: oauth.authorizationHeaders ?? {},
                                files: null,
                                responseType: ResponseType.bytes,
                              )
                              as Uint8List?;

                      if (fileBytes != null) {
                        final fileName = file.name ?? 'unknown';
                        final contentItems = await _extractContentFromBytes(fileBytes, fileName);
                        if (contentItems.isNotEmpty) {
                          // Add file name as text
                          contentArray.add({'type': 'text', 'text': 'Attachment "$fileName":'});
                          // Add content items (images or text)
                          contentArray.addAll(contentItems);
                        }
                      }
                    } catch (e) {
                      // Skip individual attachment failures
                      continue;
                    }
                  }
                }
              }
            }
          }
        }
      } catch (e) {
        // Skip inbox if attachment processing fails
        continue;
      }

      if (contentArray.isNotEmpty) {
        attachmentContents[inbox.id] = contentArray;
        print('[Attachment] Added ${contentArray.length} content items for inbox: ${inbox.id}');
      } else {
        print('[Attachment] No content extracted for inbox: ${inbox.id}');
      }
    }

    print('[Attachment] Total inboxes with attachments: ${attachmentContents.length}');
    return attachmentContents;
  }

  /// Extracts content from bytes based on file type
  /// Returns a list of content items in OpenAI message format
  Future<List<Map<String, dynamic>>> _extractContentFromBytes(Uint8List bytes, String fileName) async {
    final lowerName = fileName.toLowerCase();

    final contentItems = <Map<String, dynamic>>[];

    try {
      // PDF files - convert to images
      if (lowerName.endsWith('.pdf')) {
        try {
          final pdfDocument = await PdfDocument.openData(bytes);
          final pageCount = pdfDocument.pagesCount;

          // Convert each page to image (max 10 pages to avoid processing too many)
          final maxPages = pageCount > 10 ? 10 : pageCount;
          for (int i = 1; i <= maxPages; i++) {
            try {
              final page = await pdfDocument.getPage(i);

              // Render PDF page as image
              final pageImage = await page.render(
                width: page.width * 2, // 2x resolution
                height: page.height * 2,
                format: PdfPageImageFormat.png, // PNG format
              );

              // Encode image bytes to Base64
              final imageBytes = pageImage?.bytes;
              if (imageBytes != null && imageBytes.isNotEmpty) {
                final imageBase64 = base64Encode(imageBytes);
                // Add as OpenAI image_url format
                contentItems.add({
                  'type': 'image_url',
                  'image_url': {'url': 'data:image/png;base64,$imageBase64'},
                });
                print('[Attachment] Converted PDF page $i to image (${imageBytes.length} bytes, base64: ${imageBase64.length} chars)');
              } else {
                print('[Attachment] PDF page $i rendered but no image bytes');
              }

              // Close page (memory management)
              page.close();
            } catch (e, stackTrace) {
              print('[Attachment] Error converting PDF page $i to image: $e');
              print('[Attachment] Stack trace: $stackTrace');
              continue;
            }
          }

          pdfDocument.close();

          // Add note if PDF has more than 10 pages
          if (pageCount > 10) {
            contentItems.add({'type': 'text', 'text': '\n[참고: PDF 파일이 $pageCount 페이지입니다. 처음 10페이지만 이미지로 변환했습니다.]'});
          }

          if (contentItems.isEmpty) {
            print('[Attachment] No images generated from PDF');
            contentItems.add({'type': 'text', 'text': '[PDF 파일 첨부됨: $fileName - 이미지로 변환할 수 없습니다]'});
          } else {
            print('[Attachment] Generated ${contentItems.length} content items from PDF');
          }
        } catch (e) {
          print('[Attachment] Error converting PDF to images: $e');
          contentItems.add({'type': 'text', 'text': '[PDF 파일 첨부됨: $fileName - 파일을 이미지로 변환하는 중 오류가 발생했습니다: $e]'});
        }
      }
      // Text files
      else if (lowerName.endsWith('.txt') || lowerName.endsWith('.md') || lowerName.endsWith('.csv')) {
        try {
          final text = utf8.decode(bytes);
          if (text.isNotEmpty) {
            contentItems.add({'type': 'text', 'text': text});
          }
        } catch (e) {
          // Ignore decode errors
        }
      }
      // Image files - add as image_url
      else if (lowerName.endsWith('.png') || lowerName.endsWith('.jpg') || lowerName.endsWith('.jpeg') || lowerName.endsWith('.gif') || lowerName.endsWith('.webp')) {
        final mimeType = lowerName.endsWith('.png')
            ? 'image/png'
            : lowerName.endsWith('.jpg') || lowerName.endsWith('.jpeg')
            ? 'image/jpeg'
            : lowerName.endsWith('.gif')
            ? 'image/gif'
            : 'image/webp';
        final imageBase64 = base64Encode(bytes);
        contentItems.add({
          'type': 'image_url',
          'image_url': {'url': 'data:$mimeType;base64,$imageBase64'},
        });
      }
      // Other file types - return empty
    } catch (e) {
      print('[Attachment] Error extracting content: $e');
    }

    return contentItems;
  }
}
