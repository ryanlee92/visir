import 'dart:convert';

import 'package:Visir/features/calendar/domain/entities/calendar_entity.dart';
import 'package:pdfx/pdfx.dart';
import 'package:Visir/features/calendar/domain/entities/event_entity.dart';
import 'package:Visir/features/common/domain/entities/linked_item_entity.dart';
import 'package:Visir/features/inbox/domain/datasources/inbox_datasource.dart';
import 'package:Visir/features/inbox/domain/entities/inbox_config_entity.dart';
import 'package:Visir/features/inbox/domain/entities/inbox_entity.dart';
import 'package:Visir/features/inbox/domain/entities/inbox_fetch_list_entity.dart';
import 'package:Visir/features/inbox/domain/entities/inbox_suggestion_entity.dart';
import 'package:Visir/features/inbox/infrastructure/datasources/openai_inbox_prompts.dart';
import 'package:Visir/features/inbox/domain/entities/mcp_function_schema.dart';
import 'package:Visir/features/mail/domain/entities/mail_entity.dart';
import 'package:Visir/features/task/domain/entities/project_entity.dart';
import 'package:Visir/features/task/domain/entities/task_entity.dart';
import 'package:collection/collection.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class GoogleAiInboxDatasource extends InboxDatasource {
  /// Helper method to call Google Gemini API
  Future<String?> _callGoogleAiApi({required String prompt, required String model, String? apiKey, Map<String, dynamic>? generationConfig}) async {
    if (apiKey == null || apiKey.isEmpty) {
      return null;
    }

    try {
      // Google Gemini API endpoint
      final endpoint = 'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey';

      final body = {
        'contents': [
          {
            'parts': [
              {'text': prompt},
            ],
          },
        ],
        if (generationConfig != null) 'generationConfig': generationConfig,
      };

      final response = await http.post(Uri.parse(endpoint), headers: {'Content-Type': 'application/json'}, body: jsonEncode(body));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(utf8.decode(response.bodyBytes));

        // Check for errors
        if (decoded['error'] != null) {
          return null;
        }

        // Extract text from response
        final candidates = decoded['candidates'] as List<dynamic>?;
        if (candidates != null && candidates.isNotEmpty) {
          final content = candidates[0]['content'] as Map<String, dynamic>?;
          if (content != null) {
            final parts = content['parts'] as List<dynamic>?;
            if (parts != null && parts.isNotEmpty) {
              final text = parts[0]['text'] as String?;
              return text?.trim();
            }
          }
        }
      }
    } catch (e) {
      return null;
    }

    return null;
  }

  /// Helper method to call Google Gemini API with JSON response format
  /// Returns a map with 'data' (the actual response) and '_token_usage' (token information)
  Future<Map<String, dynamic>?> _callGoogleAiApiJson({required String prompt, required String model, String? apiKey, Map<String, dynamic>? jsonSchema}) async {
    if (apiKey == null || apiKey.isEmpty) {
      return null;
    }

    try {
      final endpoint = 'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey';

      final generationConfig = <String, dynamic>{
        'temperature': 0.7,
        if (jsonSchema != null) 'responseMimeType': 'application/json',
        if (jsonSchema != null) 'responseSchema': jsonSchema,
      };

      final body = {
        'contents': [
          {
            'parts': [
              {'text': prompt},
            ],
          },
        ],
        'generationConfig': generationConfig,
      };

      final response = await http.post(Uri.parse(endpoint), headers: {'Content-Type': 'application/json'}, body: jsonEncode(body));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(utf8.decode(response.bodyBytes));

        if (decoded['error'] != null) {
          return null;
        }

        // Extract token usage information
        final usageMetadata = decoded['usageMetadata'] as Map<String, dynamic>?;
        Map<String, dynamic>? tokenUsage;
        if (usageMetadata != null) {
          tokenUsage = {
            'prompt_tokens': usageMetadata['promptTokenCount'] ?? 0,
            'completion_tokens': usageMetadata['candidatesTokenCount'] ?? 0,
            'total_tokens': usageMetadata['totalTokenCount'] ?? 0,
          };
        }

        final candidates = decoded['candidates'] as List<dynamic>?;
        if (candidates != null && candidates.isNotEmpty) {
          final content = candidates[0]['content'] as Map<String, dynamic>?;
          if (content != null) {
            final parts = content['parts'] as List<dynamic>?;
            if (parts != null && parts.isNotEmpty) {
              final text = parts[0]['text'] as String?;
              if (text != null) {
                try {
                  final jsonData = jsonDecode(text.trim()) as Map<String, dynamic>;
                  // Add token usage to result
                  if (tokenUsage != null) {
                    jsonData['_token_usage'] = tokenUsage;
                  }
                  return jsonData;
                } catch (e) {
                  // Try to extract JSON from text if it's wrapped
                  final jsonMatch = RegExp(r'\{[^{}]*(?:\{[^{}]*\}[^{}]*)*\}').firstMatch(text);
                  if (jsonMatch != null) {
                    try {
                      final jsonData = jsonDecode(jsonMatch.group(0)!) as Map<String, dynamic>;
                      // Add token usage to result
                      if (tokenUsage != null) {
                        jsonData['_token_usage'] = tokenUsage;
                      }
                      return jsonData;
                    } catch (_) {}
                  }
                }
              }
            }
          }
        }
      }
    } catch (e) {
      return null;
    }

    return null;
  }

  @override
  Future<List<InboxSuggestionEntity>> fetchInboxSuggestions({required List<InboxEntity> inboxes, required List<ProjectEntity> projects, String? model, String? apiKey}) async {
    if (apiKey == null || apiKey.isEmpty) {
      return [];
    }
    if (inboxes.isEmpty) return [];

    final allSuggestions = <InboxSuggestionEntity>[];

    // This method needs API key, so it will be implemented when API key is available
    // For now, return default suggestions
    for (final inbox in inboxes) {
      allSuggestions.add(
        InboxSuggestionEntity.fromJson({
          'is_encrypted': false,
          'id': inbox.id,
          'summary': inbox.title,
          'urgency': 'none',
          'reason': 'other',
          'reasoned_body': null,
          'date_type': 'task',
          'target_date': null,
          'duration': null,
          'is_asap': false,
          'is_date_only': false,
          'project_id': null,
          'estimated_effort': null,
          'sender_name': null,
          'priority_score': 0,
        }, local: true), // AI는 평문
      );
    }

    return allSuggestions;
  }

  @override
  Future<List<InboxSuggestionEntity>> fetchInboxSuggestionsFromCache({required String userId, required List<String> inboxIds}) async {
    // Google AI datasource doesn't handle caching - Supabase datasource handles it
    return [];
  }

  @override
  Future<void> saveInboxSuggestions({required String userId, required List<InboxSuggestionEntity> suggestions}) async {
    // Google AI datasource doesn't handle caching - Supabase datasource handles it
    return;
  }

  @override
  Future<void> deleteInboxConfig({required List<String> configIds}) async {
    return;
  }

  @override
  Future<InboxFetchListEntity> fetchInbox({required DateTime dateTime}) async {
    return InboxFetchListEntity(inboxes: [], separator: []);
  }

  @override
  Future<List<InboxConfigEntity>> fetchInboxConfig({required String userId, List<String>? configIds}) async {
    return [];
  }

  @override
  Future<void> saveInboxConfig({required List<InboxConfigEntity> inboxConfigs}) async {
    return;
  }

  @override
  Future<String?> fetchConversationSummaryFromCache({required String userId, String? taskId, String? eventId}) async {
    // Google AI datasource doesn't handle caching - Supabase datasource handles it
    return null;
  }

  @override
  Future<void> saveConversationSummary({required String userId, String? taskId, String? eventId, required String summary}) async {
    // Google AI datasource doesn't handle caching - Supabase datasource handles it
    return;
  }

  /// Fetches conversation summary for a specific inbox item
  Future<String?> fetchConversationSummary({
    required InboxEntity inbox,
    required List<InboxEntity> allInboxes,
    List<EventEntity>? eventEntities,
    List<TaskEntity>? taskEntities,
    String? model,
    String? apiKey,
  }) async {
    final modelName = model ?? 'gemini-1.5-flash';

    // Build conversation snippet (same as OpenAI implementation)
    String conversationSnippet;

    if (allInboxes.isNotEmpty) {
      final mailInboxes = allInboxes.where((i) => i.linkedMail != null).toList();
      final messageInboxes = allInboxes.where((i) => i.linkedMessage != null).toList();

      List<String> snippets = [];

      if (mailInboxes.isNotEmpty) {
        final Map<String, List<InboxEntity>> mailThreads = {};
        for (final mailInbox in mailInboxes) {
          final threadKey = '${mailInbox.linkedMail!.threadId}_${mailInbox.linkedMail!.hostMail}';
          if (!mailThreads.containsKey(threadKey)) {
            mailThreads[threadKey] = [];
          }
          mailThreads[threadKey]!.add(mailInbox);
        }

        for (final threadInboxes in mailThreads.values) {
          threadInboxes.sort((a, b) => a.inboxDatetime.compareTo(b.inboxDatetime));
          if (threadInboxes.length > 1) {
            snippets.add(threadInboxes.map((i) => '${i.title}: ${i.description ?? i.title}').join('\n---\n'));
          } else {
            snippets.add(threadInboxes.first.description ?? threadInboxes.first.title);
          }
        }
      }

      if (messageInboxes.isNotEmpty) {
        final Map<String, List<InboxEntity>> messageGroups = {};
        for (final msgInbox in messageInboxes) {
          final linkedMsg = msgInbox.linkedMessage!;
          final groupKey = linkedMsg.threadId.isNotEmpty && linkedMsg.threadId != linkedMsg.messageId
              ? 'thread_${linkedMsg.threadId}_${linkedMsg.teamId}_${linkedMsg.channelId}'
              : 'channel_${linkedMsg.teamId}_${linkedMsg.channelId}';
          if (!messageGroups.containsKey(groupKey)) {
            messageGroups[groupKey] = [];
          }
          messageGroups[groupKey]!.add(msgInbox);
        }

        for (final groupInboxes in messageGroups.values) {
          groupInboxes.sort((a, b) => a.inboxDatetime.compareTo(b.inboxDatetime));
          if (groupInboxes.length > 1) {
            snippets.add(groupInboxes.map((i) => '${i.title}: ${i.description ?? i.title}').join('\n---\n'));
          } else {
            snippets.add(groupInboxes.first.description ?? groupInboxes.first.title);
          }
        }
      }

      conversationSnippet = snippets.isNotEmpty ? snippets.join('\n\n===\n\n') : (inbox.description ?? inbox.title);
    } else {
      conversationSnippet = inbox.description ?? inbox.title;
    }

    String? eventSnippet;
    if (eventEntities != null && eventEntities.isNotEmpty) {
      final eventSnippets = <String>[];
      for (final event in eventEntities) {
        final dateFormat = DateFormat('yyyy-MM-dd HH:mm');
        final startDateStr = dateFormat.format(event.startDate);
        final endDateStr = dateFormat.format(event.endDate);
        final calendarName = event.calendarName;
        final title = event.title ?? 'Untitled Event';
        final description = event.description ?? '';
        final rrule = event.rrule;
        final isRecurring = rrule != null;

        eventSnippets.add(
          'Event: $title\nCalendar: $calendarName\nDate: $startDateStr - $endDateStr${isRecurring ? '\nRecurring: Yes' : ''}${description.isNotEmpty ? '\nDescription: $description' : ''}',
        );
      }
      eventSnippet = eventSnippets.join('\n\n---\n\n');
    }

    // Process tasks if provided
    String? taskSnippet;
    if (taskEntities != null && taskEntities.isNotEmpty) {
      final taskSnippets = <String>[];
      for (final task in taskEntities) {
        final dateFormat = DateFormat('yyyy-MM-dd HH:mm');
        final startDateStr = task.startAt != null ? dateFormat.format(task.startAt!) : (task.startDate != null ? dateFormat.format(task.startDate!) : 'Not scheduled');
        final endDateStr = task.endAt != null ? dateFormat.format(task.endAt!) : (task.endDate != null ? dateFormat.format(task.endDate!) : 'Not scheduled');
        final title = task.title ?? 'Untitled Task';
        final description = task.description ?? '';
        final status = task.status?.name ?? 'none';
        final rrule = task.rrule;
        final isRecurring = rrule != null;

        taskSnippets.add(
          'Task: $title\nStatus: $status\nDate: $startDateStr - $endDateStr${isRecurring ? '\nRecurring: Yes' : ''}${description.isNotEmpty ? '\nDescription: $description' : ''}',
        );
      }
      taskSnippet = taskSnippets.join('\n\n---\n\n');
    }

    final hasVirtualInbox = inbox.linkedMail == null && inbox.linkedMessage == null && allInboxes.isEmpty;
    final hasOnlyEvents = hasVirtualInbox && (eventSnippet != null && eventSnippet.isNotEmpty);

    // Extract current task/event description if available - always include if present
    final currentTaskEventDescription = inbox.description != null && inbox.description!.isNotEmpty ? inbox.description : null;

    if (conversationSnippet.isEmpty && (eventSnippet == null || eventSnippet.isEmpty) && (taskSnippet == null || taskSnippet.isEmpty) && currentTaskEventDescription == null) return null;

    final descriptionPrompt = OpenAiInboxPrompts.buildDescriptionPrompt(currentTaskEventDescription: currentTaskEventDescription);

    final prompt = OpenAiInboxPrompts.buildConversationSnippetPrompt(
      hasOnlyEvents: hasOnlyEvents,
      eventSnippet: eventSnippet,
      taskSnippet: taskSnippet,
      descriptionPrompt: descriptionPrompt,
      conversationSnippet: conversationSnippet,
      currentTaskEventDescription: currentTaskEventDescription,
    );

    return await _callGoogleAiApi(prompt: prompt, model: modelName, apiKey: apiKey);
  }

  /// Extracts search keywords from task information using Google AI
  Future<List<String>?> extractSearchKeywords({required String taskTitle, String? taskDescription, String? taskProjectName, String? calendarName, String? apiKey}) async {
    final taskInfo = [
      if (taskTitle.isNotEmpty) 'Title: $taskTitle',
      if (taskDescription != null && taskDescription.isNotEmpty) 'Description: $taskDescription',
      if (taskProjectName != null && taskProjectName.isNotEmpty) 'Project: $taskProjectName',
      if (calendarName != null && calendarName.isNotEmpty) 'Calendar: $calendarName',
    ].join('\n');

    if (taskInfo.isEmpty) return null;

    final prompt = OpenAiInboxPrompts.buildExtractSearchKeywordsPrompt(taskInfo: taskInfo);

    final jsonSchema = {
      'type': 'object',
      'properties': {
        'keywords': {
          'type': 'array',
          'items': {'type': 'string'},
          'minItems': 1,
          'maxItems': 5,
        },
      },
      'required': ['keywords'],
      'additionalProperties': false,
    };

    final result = await _callGoogleAiApiJson(prompt: prompt, model: 'gemini-1.5-flash', apiKey: apiKey, jsonSchema: jsonSchema);

    if (result != null) {
      final keywords = (result['keywords'] as List<dynamic>?)?.map((e) => e.toString()).toList();
      return keywords?.where((k) => k.isNotEmpty).toList();
    }

    return null;
  }

  /// AI를 사용하여 메일 내용을 생성합니다.
  Future<String?> generateMailContent({
    required MailEntity originalMail,
    required String userRequest,
    required List<Map<String, dynamic>> conversationHistory,
    String? apiKey,
  }) async {
    final originalSnippet = originalMail.snippetWithLineBreaks ?? originalMail.snippet ?? '';
    final originalSubject = originalMail.subject ?? '';
    final fromName = originalMail.from?.name ?? '';
    final fromEmail = originalMail.from?.email ?? '';

    final conversationText = conversationHistory
        .map((m) {
          final role = m['role'] == 'user' ? '사용자' : 'AI';
          return '$role: ${m['content']}';
        })
        .join('\n\n');

    final prompt = OpenAiInboxPrompts.buildGenerateMailContentPrompt(
      originalSubject: originalSubject,
      fromName: fromName,
      fromEmail: fromEmail,
      originalSnippet: originalSnippet,
      conversationText: conversationText,
      threadId: originalMail.threadId,
    );

    return await _callGoogleAiApi(prompt: prompt, model: 'gemini-1.5-flash', apiKey: apiKey);
  }

  /// AI를 사용하여 메일 내용을 생성합니다. (LinkedMailEntity 사용)
  Future<String?> generateMailContentFromLinked({
    required LinkedMailEntity linkedMail,
    required String snippet,
    required String userRequest,
    required List<Map<String, dynamic>> conversationHistory,
    required String model,
    String? apiKey,
  }) async {
    final originalSubject = linkedMail.title;
    final fromName = linkedMail.fromName;

    final conversationText = conversationHistory
        .map((m) {
          final role = m['role'] == 'user' ? 'User' : 'AI';
          return '$role: ${m['content']}';
        })
        .join('\n\n');

    final prompt = OpenAiInboxPrompts.buildGenerateMailContentPromptEn(
      originalSubject: originalSubject,
      fromName: fromName,
      originalSnippet: snippet,
      conversationText: conversationText,
      threadId: linkedMail.threadId,
    );

    return await _callGoogleAiApi(prompt: prompt, model: model, apiKey: apiKey);
  }

  // Note: The remaining methods (generateSuggestedReply, generateTaskFromInbox, etc.)
  // follow the same pattern - they need API key as parameter and use _callGoogleAiApi or _callGoogleAiApiJson
  // Due to length constraints, I'll create a separate file for Anthropic and then we can add the remaining methods

  /// Placeholder methods - will be implemented with full OpenAI datasource structure
  Future<Map<String, dynamic>?> generateSuggestedReply({
    required LinkedMailEntity linkedMail,
    required String snippet,
    required String model,
    List<Map<String, dynamic>>? threadMessages,
    String? previousReply,
    String? userModificationRequest,
    List<Map<String, String>>? originalTo,
    List<Map<String, String>>? originalCc,
    List<Map<String, String>>? originalBcc,
    String? senderEmail,
    String? senderName,
    String? currentUserEmail,
    String? originalMailBody,
    String? actionType,
    String? apiKey,
  }) async {
    if (apiKey == null || apiKey.isEmpty) {
      return null;
    }

    final originalSubject = linkedMail.title;
    final fromName = linkedMail.fromName;

    // Build thread context if available
    String threadContext = '';
    if (threadMessages != null && threadMessages.isNotEmpty) {
      threadContext = threadMessages
          .map((msg) {
            final from = msg['from'] as String? ?? 'Unknown';
            final subject = msg['subject'] as String? ?? '';
            final body = msg['body'] as String? ?? '';
            final date = msg['date'] as String? ?? '';
            return 'From: $from\nSubject: $subject\nDate: $date\nBody: $body';
          })
          .join('\n\n---\n\n');
    }

    String prompt;
    final isSendAction = actionType == 'send';
    final actionLabel = isSendAction ? 'email' : 'reply';

    if (previousReply != null && userModificationRequest != null) {
      // User wants to modify the existing reply/email
      prompt = OpenAiInboxPrompts.buildSuggestReplyModificationPrompt(
        actionLabel: actionLabel,
        isSendAction: isSendAction,
        originalSubject: originalSubject,
        previousReply: previousReply,
        threadMessages: threadMessages != null && threadMessages.isNotEmpty ? threadContext : null,
        threadContext: threadContext,
        fromName: fromName,
        snippet: snippet,
        userModificationRequest: userModificationRequest,
        originalMailBody: originalMailBody,
        threadId: linkedMail.threadId,
      );
    } else {
      // Initial reply generation
      // Build recipients info for AI
      String recipientsInfo = '';
      if (originalTo != null && originalTo.isNotEmpty) {
        recipientsInfo += '\n## Original Email Recipients\n';
        recipientsInfo += 'To: ${originalTo.map((r) => r['name']?.isNotEmpty == true && r['name'] != r['email'] ? '${r['name']} <${r['email']}>' : r['email']).join(', ')}\n';
        if (originalCc != null && originalCc.isNotEmpty) {
          recipientsInfo += 'CC: ${originalCc.map((r) => r['name']?.isNotEmpty == true && r['name'] != r['email'] ? '${r['name']} <${r['email']}>' : r['email']).join(', ')}\n';
        }
        if (originalBcc != null && originalBcc.isNotEmpty) {
          recipientsInfo += 'BCC: ${originalBcc.map((r) => r['name']?.isNotEmpty == true && r['name'] != r['email'] ? '${r['name']} <${r['email']}>' : r['email']).join(', ')}\n';
        }
      }

      prompt = OpenAiInboxPrompts.buildSuggestReplyInitialPrompt(
        threadMessages: threadMessages?.isNotEmpty == true ? 'full' : null,
        threadContext: threadContext,
        originalSubject: originalSubject,
        fromName: fromName,
        senderEmail: senderEmail,
        snippet: snippet,
        recipientsInfo: recipientsInfo,
        senderName: senderName,
        currentUserEmail: currentUserEmail,
        originalMailBody: originalMailBody,
        threadId: linkedMail.threadId,
      );
    }

    // Different JSON schema based on whether it's a modification or initial generation
    final Map<String, dynamic> jsonSchema;
    if (previousReply != null && userModificationRequest != null) {
      // Modification mode: suggested_reply and isConfirmed are required
      jsonSchema = {
        "type": "object",
        "properties": {
          "suggested_reply": {"type": "string"},
          "isConfirmed": {"type": "boolean"},
        },
        "required": ["suggested_reply", "isConfirmed"],
        "additionalProperties": false,
      };
    } else {
      // Initial generation: thread_summary, suggested_reply, and recipients are required
      jsonSchema = {
        "type": "object",
        "properties": {
          "thread_summary": {"type": "string"},
          "suggested_reply": {"type": "string"},
          "to": {
            "type": "array",
            "items": {
              "type": "object",
              "properties": {
                "email": {"type": "string"},
                "name": {"type": "string"},
              },
              "required": ["email", "name"],
              "additionalProperties": false,
            },
          },
          "cc": {
            "type": "array",
            "items": {
              "type": "object",
              "properties": {
                "email": {"type": "string"},
                "name": {"type": "string"},
              },
              "required": ["email", "name"],
              "additionalProperties": false,
            },
          },
          "bcc": {
            "type": "array",
            "items": {
              "type": "object",
              "properties": {
                "email": {"type": "string"},
                "name": {"type": "string"},
              },
              "required": ["email", "name"],
              "additionalProperties": false,
            },
          },
          "suggest_reply_all": {"type": "boolean"},
          "isConfirmed": {"type": "boolean"},
        },
        "required": ["thread_summary", "suggested_reply", "to", "cc", "bcc", "suggest_reply_all", "isConfirmed"],
        "additionalProperties": false,
      };
    }

    try {
      final result = await _callGoogleAiApiJson(prompt: prompt, model: model, apiKey: apiKey, jsonSchema: jsonSchema);
      if (result != null) {
        final isModification = previousReply != null && userModificationRequest != null;
        final response = <String, dynamic>{};

        if (isModification) {
          // Modification mode: include suggested_reply and isConfirmed
          response['suggested_reply'] = result['suggested_reply'] as String? ?? '';
          response['isConfirmed'] = result['isConfirmed'] as bool? ?? false;
        } else {
          // Initial generation: include thread_summary, suggested_reply, recipients, and isConfirmed
          response['thread_summary'] = result['thread_summary'] as String? ?? '';
          response['suggested_reply'] = result['suggested_reply'] as String? ?? '';
          response['to'] = result['to'] as List? ?? [];
          response['cc'] = result['cc'] as List? ?? [];
          response['bcc'] = result['bcc'] as List? ?? [];
          response['suggest_reply_all'] = result['suggest_reply_all'] as bool? ?? false;
          response['isConfirmed'] = result['isConfirmed'] as bool? ?? false;
        }

        return response;
      }
    } catch (e) {
      return null;
    }

    return null;
  }

  Future<Map<String, dynamic>?> generateTaskFromInbox({
    required InboxEntity inbox,
    required String userRequest,
    required List<Map<String, dynamic>> conversationHistory,
    required List<Map<String, dynamic>> projects,
    required String model,
    TaskEntity? previousTaskEntity,
    EventEntity? previousEventEntity,
    String? apiKey,
  }) async {
    if (apiKey == null || apiKey.isEmpty) {
      return null;
    }

    final inboxTitle = inbox.title ?? '';
    final inboxDescription = inbox.description ?? '';
    final snippet = inboxDescription;

    // Get previous task entity information if available
    String? previousTaskInfo;
    if (previousTaskEntity != null) {
      // Convert to local timezone ISO8601 string (without Z suffix)
      String formatLocalDateTime(DateTime? dt) {
        if (dt == null) return 'Not set';
        // Format as local timezone: YYYY-MM-DDTHH:mm:ss (no Z, no UTC conversion)
        final year = dt.year.toString().padLeft(4, '0');
        final month = dt.month.toString().padLeft(2, '0');
        final day = dt.day.toString().padLeft(2, '0');
        final hour = dt.hour.toString().padLeft(2, '0');
        final minute = dt.minute.toString().padLeft(2, '0');
        final second = dt.second.toString().padLeft(2, '0');
        return '$year-$month-${day}T$hour:$minute:$second';
      }

      final currentProjectName = previousTaskEntity.projectId != null ? _getProjectName(previousTaskEntity.projectId!, projects) : 'Not set';

      previousTaskInfo = OpenAiInboxPrompts.buildPreviousTaskInfoPrompt(
        taskTitle: previousTaskEntity.title ?? '',
        taskDescription: previousTaskEntity.description,
        startDateTime: formatLocalDateTime(previousTaskEntity.startAt),
        endDateTime: formatLocalDateTime(previousTaskEntity.endAt),
        isAllDay: previousTaskEntity.isAllDay,
        projectId: previousTaskEntity.projectId,
        currentProjectName: currentProjectName,
        taskId: previousTaskEntity.id,
      );
    }

    // Get suggested task information if available (only if no previous task entity)
    final suggestion = inbox.suggestion;
    String? suggestedTaskInfo;
    if (previousTaskEntity == null && suggestion != null && suggestion.summary != null && suggestion.summary!.isNotEmpty) {
      final suggestedStartAt = suggestion.target_date?.toIso8601String();
      final suggestedEndAt = suggestion.target_date != null
          ? (suggestion.duration != null && suggestion.duration! > 0
                ? suggestion.target_date!.add(Duration(minutes: suggestion.duration!)).toIso8601String()
                : suggestion.target_date!.add(const Duration(hours: 1)).toIso8601String())
          : null;
      suggestedTaskInfo = OpenAiInboxPrompts.buildSuggestedTaskInfoPrompt(
        summary: suggestion.summary!,
        suggestedStartAt: suggestedStartAt,
        suggestedEndAt: suggestedEndAt,
        isDateOnly: suggestion.is_date_only ?? false,
        projectId: suggestion.project_id,
        duration: suggestion.duration,
        inboxId: inbox.id,
      );
    }

    // Convert conversation history to string
    final conversationText = conversationHistory
        .map((m) {
          final role = m['role'] == 'user' ? 'User' : 'AI';
          return '$role: ${m['content']}';
        })
        .join('\n\n');

    // Calculate today and tomorrow dates for the prompt
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));
    final todayStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final tomorrowStr = '${tomorrow.year}-${tomorrow.month.toString().padLeft(2, '0')}-${tomorrow.day.toString().padLeft(2, '0')}';
    final currentTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';

    final prompt = OpenAiInboxPrompts.buildGenerateTaskPrompt(
      inboxTitle: inboxTitle,
      snippet: snippet,
      previousTaskInfo: previousTaskInfo,
      suggestedTaskInfo: suggestedTaskInfo,
      projects: projects,
      conversationText: conversationText,
      todayStr: todayStr,
      tomorrowStr: tomorrowStr,
      currentTime: currentTime,
      userRequest: userRequest,
      hasPreviousTask: previousTaskEntity != null,
      suggestionSummary: suggestion?.summary,
      taskId: previousTaskEntity?.id,
      inboxId: inbox.id,
    );

    final jsonSchema = {
      'type': 'object',
      'properties': {
        'title': {'type': 'string'},
        'description': {
          'type': ['string', 'null'],
        },
        'project_id': {'type': 'string', 'description': 'REQUIRED - must always be included, cannot be null'},
        'start_at': {
          'type': ['string', 'null'],
        },
        'rrule': {
          'type': ['string', 'null'],
        },
        'isConfirmed': {'type': 'boolean'},
        'action_type_change': {
          'type': ['string', 'null'],
          'enum': [null, 'event'],
          'description': "Set to 'event' if user wants to switch from task to event, null otherwise",
        },
        'message': {'type': 'string'},
      },
      'required': ['title', 'project_id', 'isConfirmed', 'message'],
      'additionalProperties': false,
    };

    try {
      final result = await _callGoogleAiApiJson(prompt: prompt, model: model, apiKey: apiKey, jsonSchema: jsonSchema);
      return result;
    } catch (e) {
      return null;
    }
  }

  /// Helper function to get project name by ID
  String _getProjectName(String projectId, List<Map<String, dynamic>> projects) {
    final project = projects.firstWhereOrNull((p) => p['id'] == projectId);
    return project?['name'] as String? ?? 'Unknown';
  }

  Future<Map<String, dynamic>?> generateSuggestedTask({required InboxEntity inbox, required List<Map<String, dynamic>> projects, required String model, String? apiKey}) async {
    if (apiKey == null || apiKey.isEmpty) {
      return null;
    }

    final inboxTitle = inbox.title ?? '';
    final inboxDescription = inbox.description ?? '';
    final snippet = inboxDescription;

    final prompt = OpenAiInboxPrompts.buildGenerateTaskPrompt(
      inboxTitle: inboxTitle,
      snippet: snippet,
      projects: projects,
      inboxId: inbox.id,
      isSuggestionMode: true,
    );

    final jsonSchema = {
      'type': 'object',
      'properties': {
        'title': {'type': 'string'},
        'description': {
          'type': ['string', 'null'],
        },
        'project_id': {'type': 'string', 'description': 'REQUIRED - must always be included, cannot be null'},
      },
      'required': ['title', 'project_id'],
      'additionalProperties': false,
    };

    try {
      final result = await _callGoogleAiApiJson(prompt: prompt, model: model, apiKey: apiKey, jsonSchema: jsonSchema);
      return result;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> generateSuggestedEvent({required InboxEntity inbox, required List<Map<String, dynamic>> calendars, required String model, String? apiKey}) async {
    if (apiKey == null || apiKey.isEmpty) {
      return null;
    }

    final inboxTitle = inbox.title ?? '';
    final inboxDescription = inbox.description ?? '';
    final snippet = inboxDescription;

    // Get source host email from inbox
    final sourceHostEmail = inbox.linkedMail?.hostMail ?? inbox.linkedMessage?.teamId;
    final sourceFromName = inbox.linkedMail?.fromName ?? inbox.linkedMessage?.userName;

    final prompt = OpenAiInboxPrompts.buildGenerateEventFromInboxPrompt(
      inboxTitle: inboxTitle,
      snippet: snippet,
      sourceHostEmail: sourceHostEmail,
      sourceFromName: sourceFromName,
      calendars: calendars,
      inboxId: inbox.id,
      isSuggestionMode: true,
    );

    final jsonSchema = {
      'type': 'object',
      'properties': {
        'title': {'type': 'string'},
        'description': {
          'type': ['string', 'null'],
        },
        'calendar_id': {'type': 'string'},
        'location': {
          'type': ['string', 'null'],
        },
        'attendees': {
          'type': 'array',
          'items': {'type': 'string'},
        },
        'conference_link': {
          'type': ['string', 'null'],
        },
      },
      'required': ['title', 'calendar_id', 'location', 'attendees', 'conference_link'],
      'additionalProperties': false,
    };

    try {
      final result = await _callGoogleAiApiJson(prompt: prompt, model: model, apiKey: apiKey, jsonSchema: jsonSchema);
      return result;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> generateEventFromInbox({
    required InboxEntity inbox,
    required String userRequest,
    required List<Map<String, dynamic>> conversationHistory,
    required List<Map<String, dynamic>> calendars,
    required String model,
    EventEntity? previousEventEntity,
    TaskEntity? previousTaskEntity,
    String? apiKey,
  }) async {
    if (apiKey == null || apiKey.isEmpty) {
      return null;
    }

    final inboxTitle = inbox.title ?? '';
    final inboxDescription = inbox.description ?? '';
    final snippet = inboxDescription;

    // Get source host email from inbox
    final sourceHostEmail = inbox.linkedMail?.hostMail ?? inbox.linkedMessage?.teamId;
    final sourceFromName = inbox.linkedMail?.fromName ?? inbox.linkedMessage?.userName;

    // Get previous event entity information if available
    String? previousEventInfo;
    if (previousEventEntity != null) {
      // Convert to local timezone ISO8601 string (without Z suffix)
      String formatLocalDateTime(DateTime? dt) {
        if (dt == null) return 'Not set';
        // Format as local timezone: YYYY-MM-DDTHH:mm:ss (no Z, no UTC conversion)
        final year = dt.year.toString().padLeft(4, '0');
        final month = dt.month.toString().padLeft(2, '0');
        final day = dt.day.toString().padLeft(2, '0');
        final hour = dt.hour.toString().padLeft(2, '0');
        final minute = dt.minute.toString().padLeft(2, '0');
        final second = dt.second.toString().padLeft(2, '0');
        return '$year-$month-${day}T$hour:$minute:$second';
      }

      final currentCalendarName = previousEventEntity.calendar.name;

      previousEventInfo = OpenAiInboxPrompts.buildPreviousEventInfoPrompt(
        eventTitle: previousEventEntity.title ?? '',
        eventDescription: previousEventEntity.description,
        startDateTime: formatLocalDateTime(previousEventEntity.startDate),
        endDateTime: formatLocalDateTime(previousEventEntity.endDate),
        isAllDay: previousEventEntity.isAllDay,
        location: previousEventEntity.location,
        currentCalendarName: currentCalendarName,
        calendarId: previousEventEntity.calendar.uniqueId,
        conferenceLink: previousEventEntity.conferenceLink,
        eventId: previousEventEntity.eventId,
      );
    } else if (previousTaskEntity != null) {
      // User switched from task to event - convert task info to event context
      String formatLocalDateTime(DateTime? dt) {
        if (dt == null) return 'Not set';
        final year = dt.year.toString().padLeft(4, '0');
        final month = dt.month.toString().padLeft(2, '0');
        final day = dt.day.toString().padLeft(2, '0');
        final hour = dt.hour.toString().padLeft(2, '0');
        final minute = dt.minute.toString().padLeft(2, '0');
        final second = dt.second.toString().padLeft(2, '0');
        return '$year-$month-${day}T$hour:$minute:$second';
      }

      previousEventInfo = OpenAiInboxPrompts.buildPreviousTaskToEventInfoPrompt(
        taskTitle: previousTaskEntity.title ?? '',
        taskDescription: previousTaskEntity.description,
        startDateTime: formatLocalDateTime(previousTaskEntity.startAt),
        endDateTime: formatLocalDateTime(previousTaskEntity.endAt),
        isAllDay: previousTaskEntity.isAllDay,
        projectId: previousTaskEntity.projectId,
        taskId: previousTaskEntity.id,
      );
    }

    // Convert conversation history to string
    final conversationText = conversationHistory
        .map((m) {
          final role = m['role'] == 'user' ? 'User' : 'AI';
          return '$role: ${m['content']}';
        })
        .join('\n\n');

    // Calculate today and tomorrow dates for the prompt
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));
    final todayStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final tomorrowStr = '${tomorrow.year}-${tomorrow.month.toString().padLeft(2, '0')}-${tomorrow.day.toString().padLeft(2, '0')}';
    final currentTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';

    final prompt = OpenAiInboxPrompts.buildGenerateEventFromInboxPrompt(
      inboxTitle: inboxTitle,
      snippet: snippet,
      sourceHostEmail: sourceHostEmail,
      sourceFromName: sourceFromName,
      previousEventInfo: previousEventInfo,
      calendars: calendars,
      conversationText: conversationText,
      todayStr: todayStr,
      tomorrowStr: tomorrowStr,
      currentTime: currentTime,
      userRequest: userRequest,
      hasPreviousEventEntity: previousEventEntity != null,
      inboxId: inbox.id,
    );

    // JSON schema for Google Gemini API
    final jsonSchema = {
      'type': 'object',
      'properties': {
        'title': {'type': 'string'},
        'description': {
          'type': ['string', 'null'],
        },
        'calendar_id': {'type': 'string'},
        'start_at': {
          'type': ['string', 'null'],
        },
        'end_at': {
          'type': ['string', 'null'],
        },
        'location': {
          'type': ['string', 'null'],
        },
        'rrule': {
          'type': ['string', 'null'],
        },
        'attendees': {
          'type': 'array',
          'items': {'type': 'string'},
        },
        'conference_link': {
          'type': ['string', 'null'],
        },
        'isAllDay': {'type': 'boolean'},
        'isConfirmed': {'type': 'boolean'},
        'action_type_change': {
          'type': ['string', 'null'],
          'enum': [null, 'task'],
        },
        'message': {'type': 'string'},
      },
      'required': [
        'title',
        'description',
        'calendar_id',
        'start_at',
        'end_at',
        'location',
        'rrule',
        'attendees',
        'conference_link',
        'isAllDay',
        'isConfirmed',
        'action_type_change',
        'message',
      ],
      'additionalProperties': false,
    };

    try {
      final result = await _callGoogleAiApiJson(prompt: prompt, model: model, apiKey: apiKey, jsonSchema: jsonSchema);
      return result;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> generateGeneralChat({
    required String userMessage,
    required List<Map<String, dynamic>> conversationHistory,
    String? projectContext,
    List<Map<String, dynamic>>? projects,
    String? taggedContext,
    String? channelContext,
    String? inboxContext,
    required String model,
    String? apiKey,
    String? systemPrompt,
    bool includeTools = true, // Google AI에서 function calling 포함 여부 (기본값: true)
  }) async {
    if (apiKey == null || apiKey.isEmpty) {
      return null;
    }

    try {
      // Build system message (similar to OpenAI implementation)
      // If custom system prompt is provided, prepend it to the default system message
      String systemMessage = '';
      if (systemPrompt != null && systemPrompt.isNotEmpty) {
        systemMessage = '$systemPrompt\n\n';
      }

      // Add current date information for date calculations
      final now = DateTime.now();
      final todayStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      final tomorrow = now.add(const Duration(days: 1));
      final tomorrowStr = '${tomorrow.year}-${tomorrow.month.toString().padLeft(2, '0')}-${tomorrow.day.toString().padLeft(2, '0')}';
      final currentTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';

      systemMessage += OpenAiInboxPrompts.buildBaseSystemMessage(todayStr: todayStr, tomorrowStr: tomorrowStr, currentTime: currentTime);

      // Add Available Projects section if projects are provided
      if (projects != null && projects.isNotEmpty) {
        systemMessage = OpenAiInboxPrompts.addAvailableProjectsSection(systemMessage: systemMessage, projects: projects);
      }

      if (projectContext != null && projectContext.isNotEmpty) {
        systemMessage = OpenAiInboxPrompts.addProjectContextSection(systemMessage: systemMessage, projectContext: projectContext);
      }

      if (taggedContext != null && taggedContext.isNotEmpty) {
        systemMessage = OpenAiInboxPrompts.addTaggedContextSection(systemMessage: systemMessage, taggedContext: taggedContext);
      }

      if (channelContext != null && channelContext.isNotEmpty) {
        systemMessage = OpenAiInboxPrompts.addChannelContextSection(systemMessage: systemMessage, channelContext: channelContext);
      }

      if (inboxContext != null && inboxContext.isNotEmpty) {
        systemMessage = OpenAiInboxPrompts.addInboxContextSection(systemMessage: systemMessage, inboxContext: inboxContext);
      }

      // Build messages
      final contents = <Map<String, dynamic>>[];

      // Add conversation history with file support
      final processedHistory = await Future.wait(
        conversationHistory.map((m) async {
          final role = m['role'] as String;
          final content = m['content'] as String? ?? '';
          final files = m['files'] as List<dynamic>?;

          // 파일이 첨부된 경우 parts를 배열로 변환
          if (files != null && files.isNotEmpty && role == 'user') {
            final parts = <Map<String, dynamic>>[
              {'text': content},
            ];

            // 각 파일을 처리
            for (final file in files) {
              final fileMap = file as Map<String, dynamic>;
              final fileName = fileMap['name'] as String? ?? '';
              final fileBytes = fileMap['bytes'] as String?; // base64 encoded

              if (fileBytes != null && fileName.isNotEmpty) {
                final lowerName = fileName.toLowerCase();

                // 이미지 파일인 경우
                if (lowerName.endsWith('.png') || lowerName.endsWith('.jpg') || lowerName.endsWith('.jpeg') || lowerName.endsWith('.gif') || lowerName.endsWith('.webp')) {
                  parts.add({
                    'inline_data': {
                      'mime_type': lowerName.endsWith('.png')
                          ? 'image/png'
                          : lowerName.endsWith('.jpg') || lowerName.endsWith('.jpeg')
                          ? 'image/jpeg'
                          : lowerName.endsWith('.gif')
                          ? 'image/gif'
                          : 'image/webp',
                      'data': fileBytes,
                    },
                  });
                }
                // PDF 파일인 경우 - 각 페이지를 이미지로 변환하여 전달
                else if (lowerName.endsWith('.pdf')) {
                  try {
                    // Base64 디코딩
                    final pdfBytes = base64Decode(fileBytes);

                    // PDF 문서 로드
                    final pdfDocument = await PdfDocument.openData(pdfBytes);
                    final pageCount = pdfDocument.pagesCount;

                    // 각 페이지를 이미지로 변환 (최대 10페이지까지만 처리)
                    final maxPages = pageCount > 10 ? 10 : pageCount;
                    for (int i = 1; i <= maxPages; i++) {
                      // PDF 페이지 가져오기 (페이지 번호는 1부터 시작)
                      final page = await pdfDocument.getPage(i);

                      // PDF 페이지를 이미지로 렌더링
                      final pageImage = await page.render(
                        width: page.width * 2, // 2배 해상도
                        height: page.height * 2,
                        format: PdfPageImageFormat.png, // PNG 형식
                      );

                      // 렌더링된 이미지의 bytes를 Base64로 인코딩
                      final bytes = pageImage?.bytes;
                      if (bytes != null && bytes.isNotEmpty) {
                        final imageBase64 = base64Encode(bytes);

                        parts.add({
                          'inline_data': {'mime_type': 'image/png', 'data': imageBase64},
                        });
                      }

                      // 페이지 닫기 (메모리 관리)
                      page.close();
                    }

                    // 페이지가 10개를 넘으면 알림 추가
                    if (pageCount > 10) {
                      parts.add({'text': '\n[참고: PDF 파일이 $pageCount 페이지입니다. 처음 10페이지만 표시했습니다.]'});
                    }

                    // PDF 문서 닫기
                    pdfDocument.close();
                  } catch (e) {
                    // PDF 변환 실패 시 파일 정보만 전달
                    final fileSizeKB = ((fileMap['size'] as int? ?? 0) / 1024).toStringAsFixed(1);
                    parts.add({'text': '\n[PDF 파일 첨부됨: $fileName (${fileSizeKB} KB) - 파일을 이미지로 변환하는 중 오류가 발생했습니다: $e]'});
                  }
                }
                // 기타 파일인 경우
                else {
                  parts.add({'text': '\n[파일 첨부됨: $fileName]'});
                }
              }
            }

            return {'role': role == 'user' ? 'user' : 'model', 'parts': parts};
          } else {
            return {
              'role': role == 'user' ? 'user' : 'model',
              'parts': [
                {'text': content},
              ],
            };
          }
        }),
      );

      for (final msg in processedHistory) {
        contents.add(msg);
      }

      // Add current user message
      contents.add({
        'role': 'user',
        'parts': [
          {'text': userMessage},
        ],
      });

      final endpoint = 'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey';

      final body = <String, dynamic>{
        'contents': contents,
        'systemInstruction': {
          'parts': [
            {'text': systemMessage},
          ],
        },
        'generationConfig': {'temperature': 0.7},
      };

      // Add function declarations if includeTools is true
      if (includeTools) {
        final functions = McpFunctionRegistry.getGoogleAiFunctions();
        print('[GoogleAI] Adding ${functions.length} functions to API call');
        body['tools'] = [
          {
            'function_declarations': functions,
          },
        ];
      } else {
        print('[GoogleAI] Skipping tools for generateGeneralChat (includeTools=false)');
      }

      final response = await http.post(Uri.parse(endpoint), headers: {'Content-Type': 'application/json'}, body: jsonEncode(body));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(utf8.decode(response.bodyBytes));

        if (decoded['error'] != null) {
          return null;
        }

        // Extract token usage information
        final usageMetadata = decoded['usageMetadata'] as Map<String, dynamic>?;
        Map<String, dynamic>? tokenUsage;
        if (usageMetadata != null) {
          tokenUsage = {
            'prompt_tokens': usageMetadata['promptTokenCount'] ?? 0,
            'completion_tokens': usageMetadata['candidatesTokenCount'] ?? 0,
            'total_tokens': usageMetadata['totalTokenCount'] ?? 0,
          };
        }

        // Extract text content and function calls
        final candidates = decoded['candidates'] as List<dynamic>?;
        if (candidates != null && candidates.isNotEmpty) {
          final candidate = candidates[0] as Map<String, dynamic>?;
          final content = candidate?['content'] as Map<String, dynamic>?;
          if (content != null) {
            final parts = content['parts'] as List<dynamic>?;
            if (parts != null && parts.isNotEmpty) {
              String? text;
              final functionCalls = <Map<String, dynamic>>[];

              for (final part in parts) {
                final partMap = part as Map<String, dynamic>?;
                if (partMap != null) {
                  if (partMap['text'] != null) {
                    text = partMap['text'] as String?;
                  } else if (partMap['functionCall'] != null) {
                    final functionCall = partMap['functionCall'] as Map<String, dynamic>?;
                    if (functionCall != null) {
                      final functionName = functionCall['name'] as String?;
                      final args = functionCall['args'] as Map<String, dynamic>?;
                      if (functionName != null && args != null) {
                        functionCalls.add({
                          'function': functionName,
                          'arguments': args,
                        });
                      }
                    }
                  }
                }
              }

              String finalContent = text?.trim() ?? '';
              
              // Convert Google AI function calls to our format
              if (functionCalls.isNotEmpty) {
                final functionCallsJson = jsonEncode(functionCalls);
                finalContent = '$finalContent\n\n$functionCallsJson';
                print('[GoogleAI] Added ${functionCalls.length} function calls to content');
              }

              if (finalContent.isNotEmpty) {
                final result = <String, dynamic>{'message': finalContent};
                if (tokenUsage != null) {
                  result['_token_usage'] = tokenUsage;
                }
                return result;
              }
            }
          }
        }
      }
    } catch (e) {
      return null;
    }

    return null;
  }

  Future<Map<String, dynamic>?> generateSuggestedSendContent({
    required String userRequest,
    required List<Map<String, dynamic>> conversationHistory,
    required List<Map<String, String>> toRecipients,
    required List<Map<String, String>> ccRecipients,
    required List<Map<String, String>> bccRecipients,
    String? previousSubject,
    String? previousBody,
    required String model,
    String? apiKey,
  }) async {
    if (apiKey == null || apiKey.isEmpty) {
      return null;
    }

    // Build recipients info
    final toInfo = toRecipients.map((r) => '${r['name'] ?? ''} ${r['email'] ?? ''}'.trim()).join(', ');
    final ccInfo = ccRecipients.isNotEmpty ? ccRecipients.map((r) => '${r['name'] ?? ''} ${r['email'] ?? ''}'.trim()).join(', ') : null;
    final bccInfo = bccRecipients.isNotEmpty ? bccRecipients.map((r) => '${r['name'] ?? ''} ${r['email'] ?? ''}'.trim()).join(', ') : null;

    String prompt;
    if (previousSubject != null && previousSubject.isNotEmpty && previousBody != null && previousBody.isNotEmpty) {
      // User wants to modify existing email
      prompt = OpenAiInboxPrompts.buildSuggestSendContentModificationPrompt(
        previousSubject: previousSubject,
        previousBody: previousBody,
        toInfo: toInfo,
        ccInfo: ccInfo,
        bccInfo: bccInfo,
        userRequest: userRequest,
      );
    } else {
      // Generate new email from user request
      prompt = OpenAiInboxPrompts.buildSuggestSendContentInitialPrompt(
        userRequest: userRequest,
        toInfo: toInfo,
        ccInfo: ccInfo,
        bccInfo: bccInfo,
        conversationHistory: conversationHistory,
      );
    }

    final jsonSchema = {
      'type': 'object',
      'properties': {
        'subject': {'type': 'string'},
        'body': {'type': 'string'},
        'to': {
          'type': 'array',
          'items': {
            'type': 'object',
            'properties': {
              'email': {'type': 'string'},
              'name': {'type': 'string'},
            },
            'required': ['email', 'name'],
            'additionalProperties': false,
          },
        },
        'cc': {
          'type': 'array',
          'items': {
            'type': 'object',
            'properties': {
              'email': {'type': 'string'},
              'name': {'type': 'string'},
            },
            'required': ['email', 'name'],
            'additionalProperties': false,
          },
        },
        'bcc': {
          'type': 'array',
          'items': {
            'type': 'object',
            'properties': {
              'email': {'type': 'string'},
              'name': {'type': 'string'},
            },
            'required': ['email', 'name'],
            'additionalProperties': false,
          },
        },
      },
      'required': ['subject', 'body', 'to', 'cc', 'bcc'],
      'additionalProperties': false,
    };

    try {
      final result = await _callGoogleAiApiJson(prompt: prompt, model: model, apiKey: apiKey, jsonSchema: jsonSchema);
      if (result != null) {
        return {
          'subject': result['subject'] as String? ?? '',
          'body': result['body'] as String? ?? '',
          'to': result['to'] as List?,
          'cc': result['cc'] as List?,
          'bcc': result['bcc'] as List?,
        };
      }
    } catch (e) {
      return null;
    }

    return null;
  }
}
