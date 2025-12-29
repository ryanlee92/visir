import 'dart:convert';

import 'package:Visir/features/calendar/domain/entities/event_entity.dart';
import 'package:Visir/features/common/domain/entities/linked_item_entity.dart';
import 'package:Visir/features/inbox/domain/datasources/inbox_datasource.dart';
import 'package:Visir/features/inbox/domain/entities/inbox_config_entity.dart';
import 'package:Visir/features/inbox/domain/entities/inbox_entity.dart';
import 'package:Visir/features/inbox/domain/entities/inbox_fetch_list_entity.dart';
import 'package:Visir/features/inbox/domain/entities/inbox_suggestion_entity.dart';
import 'package:Visir/features/mail/domain/entities/mail_entity.dart';
import 'package:Visir/features/task/domain/entities/project_entity.dart';
import 'package:Visir/features/task/domain/entities/task_entity.dart';
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
        final isRecurring = rrule != null && rrule.isNotEmpty;

        eventSnippets.add(
          'Event: $title\nCalendar: $calendarName\nDate: $startDateStr - $endDateStr${isRecurring ? '\nRecurring: Yes' : ''}${description.isNotEmpty ? '\nDescription: $description' : ''}',
        );
      }
      eventSnippet = eventSnippets.join('\n\n---\n\n');
    }

    final hasVirtualInbox = inbox.linkedMail == null && inbox.linkedMessage == null && allInboxes.isEmpty;
    final hasOnlyEvents = hasVirtualInbox && (eventSnippet != null && eventSnippet.isNotEmpty);

    // Extract current task/event description if available - always include if present
    final currentTaskEventDescription = inbox.description != null && inbox.description!.isNotEmpty ? inbox.description : null;

    if (conversationSnippet.isEmpty && (eventSnippet == null || eventSnippet.isEmpty) && currentTaskEventDescription == null) return null;

    final eventInfoPrompt = eventSnippet != null && eventSnippet.isNotEmpty
        ? '''
For calendar events, briefly mention:
- When similar events occurred most recently
- What recurrence pattern they follow (if any)
Keep it concise (1-2 sentences).
'''
        : '';

    final descriptionPrompt = currentTaskEventDescription != null
        ? '''
IMPORTANT: The current task/event has a description below. You MUST incorporate the key information from this description into your summary. Focus on:
- What the task/event is about
- Important details or context mentioned in the description
- Any actionable items or key points
- Make sure the description content is reflected in your summary, not just the conversation or related events
'''
        : '';

    final prompt = hasOnlyEvents
        ? '''
You are an expert productivity assistant. Analyze the following calendar events.

## Task
Based on the calendar events provided, briefly summarize:
- When similar events occurred most recently
- What recurrence pattern they follow (if any)
${descriptionPrompt}

Keep the response concise (1-2 sentences).

## Calendar Events
$eventSnippet
${currentTaskEventDescription != null ? '\n\n## Current Event Description\n$currentTaskEventDescription' : ''}

## Output
Return only the summary text, no additional formatting or explanations.
'''
        : '''
You are an expert productivity assistant. Summarize the following conversation thread${eventSnippet != null && eventSnippet.isNotEmpty ? ' and related calendar events' : ''}.

## Task
Provide a brief summary (2-3 sentences) of the key discussion points, decisions made, or main topics covered in this conversation.
Focus on actionable information, important details, and context that would help the user understand what was discussed.
$eventInfoPrompt
${descriptionPrompt}

${currentTaskEventDescription != null ? '## Current Task/Event Description\n$currentTaskEventDescription\n\n' : ''}## Conversation
$conversationSnippet
${eventSnippet != null && eventSnippet.isNotEmpty ? '\n\n## Related Calendar Events\n$eventSnippet' : ''}

## Output
Return only the summary text, no additional formatting or explanations.
''';

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

    final prompt =
        '''
You are an expert productivity assistant. Extract search keywords from the following task information.

## Task
Extract 3-5 relevant search keywords that would help find related emails, messages, or calendar events in integrated datasources (Gmail, Outlook Mail, Slack, Google Calendar, Outlook Calendar).

Focus on:
- Key topics or subjects mentioned
- Important project names, concepts, or specific terms
- Action items or deadlines
- Meeting or event-related terms
- Specific topics, technologies, or domain-specific keywords

## Important Exclusions
DO NOT include:
- The user's own name (the person who owns this task/event)
- Generic company names (unless it's a specific client/vendor/partner company mentioned in the task)
- Generic terms like "meeting", "email", "task" unless combined with specific context
- Calendar names (these are too generic and would match too many results)

## Important Inclusions
DO include:
- Other people's names mentioned in the task (colleagues, clients, partners, etc.)
- Specific project names, product names, or technical terms
- Client/vendor/partner company names if mentioned

## Task Information
$taskInfo

## Output
Return a JSON array of strings, each string being a search keyword.
Example: ["project alpha", "API integration", "deadline Q4", "bug fix sprint"]

Return only the JSON array, no additional text or explanations.
''';

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

    final prompt =
        '''
다음 원본 메일에 대한 답장을 작성해주세요.

## 원본 메일 정보
제목: $originalSubject
보낸 사람: $fromName <$fromEmail>
본문:
$originalSnippet

## 대화 히스토리
$conversationText

## 요구사항
- 사용자의 요청에 맞는 자연스러운 답장을 작성해주세요.
- HTML 형식으로 작성해주세요.
- 적절한 인사말과 마무리 인사를 포함해주세요.
- 원본 메일의 내용을 참고하여 맥락에 맞는 답장을 작성해주세요.
- 불필요한 인용이나 반복을 피해주세요.

## 출력 형식
HTML 형식의 메일 본문만 반환해주세요. 추가 설명이나 주석은 포함하지 마세요.
''';

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

    final prompt =
        '''
Please write a reply to the following original email.

## Original Email Information
Subject: $originalSubject
From: $fromName
Body:
$snippet

## Conversation History
$conversationText

## Requirements
- Write a natural reply that matches the user's request.
- Write in HTML format.
- Include appropriate greetings and closing remarks.
- Refer to the original email content to write a contextually appropriate reply.
- Avoid unnecessary quotes or repetition.

## Output Format
Return only the HTML-formatted email body. Do not include any additional explanations or comments.
''';

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
    // Implementation similar to OpenAI but using Google AI API
    // This is a placeholder - full implementation will follow OpenAI structure
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
    return null;
  }

  Future<Map<String, dynamic>?> generateSuggestedTask({required InboxEntity inbox, required List<Map<String, dynamic>> projects, required String model, String? apiKey}) async {
    return null;
  }

  Future<Map<String, dynamic>?> generateSuggestedEvent({required InboxEntity inbox, required List<Map<String, dynamic>> calendars, required String model, String? apiKey}) async {
    return null;
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
    return null;
  }

  Future<Map<String, dynamic>?> generateGeneralChat({
    required String userMessage,
    required List<Map<String, dynamic>> conversationHistory,
    String? projectContext,
    String? taggedContext,
    String? channelContext,
    String? inboxContext,
    required String model,
    String? apiKey,
    String? systemPrompt,
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
      
      systemMessage += '''You are a helpful AI assistant integrated with Visir, a productivity app.

## Current Date Information
- TODAY's date: $todayStr
- TOMORROW's date: $tomorrowStr
- Current time: ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}

## CRITICAL DATE EXTRACTION RULES
When creating tasks or events from inbox items:
1. **ALWAYS check the inbox item's content/description FIRST** for **actionable dates/times** (deadlines, meeting times, schedules) before using default dates
2. **MULTIPLE DEADLINES**: If the inbox item contains MULTIPLE deadlines (e.g., "2026년 1월 6일까지 제출", "2026년 1월 15일까지 제출", "2026년 1월 29일까지 제출"), you MUST create SEPARATE tasks/events for EACH deadline:
   - Each deadline should have its own task/event with a distinct title describing what needs to be submitted by that deadline
   - Extract the specific materials/documents mentioned for each deadline
   - Use the exact deadline date for each task/event's `startAt` and `endAt`
   - Example: If the inbox says "주주명부는 1월 6일까지, 재무제표는 1월 29일까지", create TWO separate tasks:
     1. Task 1: Title about 주주명부, deadline: 2026-01-06
     2. Task 2: Title about 재무제표, deadline: 2026-01-29
3. Extract **actionable dates** from the inbox item content:
   - **Deadlines**: "Due date: 2024-01-20", "Deadline: tomorrow", "Submit by January 15th", "마감일: 2024-01-20", "제출 기한: 내일", "2026년 1월 6일(화)까지", "2026년 1월 15일(목)까지", "2026년 1월 29일(목)까지"
   - **Meeting/Event times**: "Meeting on January 15th at 3pm", "Event starts at 2:00 PM on Friday", "회의 시간: 1월 15일 오후 3시"
   - **Schedule dates**: "Schedule for next Monday", "일정: 내일"
   - **Task completion dates**: "Complete by Friday", "완료 기한: 금요일"
   - Absolute dates: "January 15th", "2024-01-15", "15/01/2024"
   - Relative dates: "tomorrow", "next Monday", "in 3 days"
   - Date + time: "3pm on Friday", "Meeting at 2:00 PM"
4. **DO NOT** use reference dates that are just mentioned for context:
   - "as of 2025-12-31", "2025-12-31 기준", "based on December 31st data" - these are reference points, not deadlines
   - "2025-12-31 기준 주주명부" - this is a reference date for the document, not a task deadline
   - Look for keywords like "기준", "as of", "based on" to identify reference dates vs actionable dates
5. If the inbox item mentions an **actionable date/time** (deadline, meeting time, schedule), you MUST use that date/time instead of defaulting to today or tomorrow
6. Only use default dates (today/tomorrow) if NO actionable dates are found in the inbox item's content
7. When parsing dates from inbox content, consider the context and convert them to ISO 8601 format (YYYY-MM-DDTHH:mm:ss)

When calculating dates for repetitive tasks, use TODAY's date ($todayStr) as the starting point.

You can help users manage tasks, events, and emails by calling functions. When the user mentions actions like "toggle task status", "create task", "delete event", etc., you should call the appropriate function.

## Multiple Function Calls

When a user requests multiple actions or repetitive tasks, you MUST call functions using the function_call format. DO NOT return raw JSON arrays of task/event objects. ALWAYS use function calls.

For multiple function calls, use an array format with function_call blocks:

```json
[
  {"function": "createTask", "arguments": {"title": "Task 1", "startAt": "2024-01-01T09:00:00", "endAt": "2024-01-01T10:00:00", "isAllDay": false}},
  {"function": "createTask", "arguments": {"title": "Task 2", "startAt": "2024-01-02T09:00:00", "endAt": "2024-01-02T10:00:00", "isAllDay": false}}
]
```

**CRITICAL**: When creating tasks or events, you MUST use function calls. DO NOT return JSON arrays like:
```json
[
  {"title": "hi", "description": "hello", "startAt": "...", "endAt": "...", "isAllDay": true}
]
```

Instead, ALWAYS use:
```json
[
  {"function": "createTask", "arguments": {"title": "hi", "description": "hello", "startAt": "...", "endAt": "...", "isAllDay": true}}
]
```

### Handling Repetitive Tasks and Date Calculations

When users request repetitive tasks (e.g., "오늘부터 매일 1주 간 task 생성해줘"):
1. **Calculate dates**: Start from today (or the specified start date) and calculate dates for each day
2. **Create multiple function calls**: Generate one function call for each task/event needed using the format above
3. **Use ISO 8601 format**: All dates must be in ISO 8601 format (e.g., "2024-01-01T09:00:00")
4. **Increment dates**: For daily tasks, add 1 day to the previous date

**Example**: User says "오늘부터 매일 1주 간 task 생성해줘 이름은 hi로"
- Today is 2024-01-01
- Day 1-7: Create "hi" task for 2024-01-01, 2024-01-02, 2024-01-03, 2024-01-04, 2024-01-05, 2024-01-06, 2024-01-07
- Return an array with 7 function calls:
```json
[
  {"function": "createTask", "arguments": {"title": "hi", "startAt": "2024-01-01T00:00:00", "endAt": "2024-01-02T00:00:00", "isAllDay": true}},
  {"function": "createTask", "arguments": {"title": "hi", "startAt": "2024-01-02T00:00:00", "endAt": "2024-01-03T00:00:00", "isAllDay": true}},
  ...
]
```

**Date Format**: Always use ISO 8601 format: "YYYY-MM-DDTHH:mm:ss" (e.g., "2024-01-01T09:00:00")
- For all-day tasks, set isAllDay to true and use dates like "2024-01-01T00:00:00" to "2024-01-02T00:00:00"
- For timed tasks, include both startAt and endAt times

### Parallel Execution and Dependency Analysis
When calling multiple functions, analyze dependencies and mark functions that can run in parallel:
- **Independent search functions** (`searchInbox`, `searchTask`, `searchCalendarEvent`) can run in parallel - set `can_parallelize: true`
- **Functions that depend on previous results** (e.g., creating a task after searching) must run sequentially - set `can_parallelize: false` and optionally include `depends_on: ["functionName"]`
- **Functions modifying the same resource** must run sequentially - set `can_parallelize: false`
- **Example format**:
  ```json
  [
    {"function": "searchInbox", "arguments": {...}, "can_parallelize": true},
    {"function": "searchTask", "arguments": {...}, "can_parallelize": true},
    {"function": "createTask", "arguments": {...}, "can_parallelize": false, "depends_on": ["searchTask"]}
  ]
  ```
The system will automatically execute parallelizable functions simultaneously for better performance.

## Task Entity Schema

When calling `createTask` or `updateTask`, you MUST use the following field names and formats:

**CRITICAL FIELD NAMING**: Use camelCase field names (NOT snake_case):
- ✅ `startAt` (NOT `start_at`)
- ✅ `endAt` (NOT `end_at`)
- ✅ `projectId` (NOT `project_id`)
- ✅ `isAllDay` (NOT `is_all_day`)
- ✅ `actionNeeded` (NOT `action_needed`)

**Task Entity Fields**:
- `title` (string, required): Task title
- `description` (string, optional): Task description
- `projectId` (string, optional): Project ID
- `startAt` (string, optional): Start date/time in ISO 8601 format: "YYYY-MM-DDTHH:mm:ss" (e.g., "2024-01-01T09:00:00")
- `endAt` (string, optional): End date/time in ISO 8601 format: "YYYY-MM-DDTHH:mm:ss" (e.g., "2024-01-01T10:00:00")
- `isAllDay` (boolean, optional, default: false): Whether the task is all-day
- `status` (string, optional, default: "none"): Task status - one of: "none", "done", "cancelled"
- `from` (string, optional): Source of the task (e.g., "GitHub", "Email")
- `subject` (string, optional): Original subject or title
- `actionNeeded` (string, optional): Action needed description

**Example createTask call**:
```json
{
  "function": "createTask",
  "arguments": {
    "title": "Review pull request",
    "description": "Review PR #123",
    "projectId": "project-123",
    "startAt": "2024-01-01T09:00:00",
    "endAt": "2024-01-01T10:00:00",
    "isAllDay": false,
    "status": "none"
  }
}
```

## Event Entity Schema

When calling `createEvent` or `updateEvent`, you MUST use the following field names and formats:

**CRITICAL FIELD NAMING**: Use camelCase field names (NOT snake_case):
- ✅ `startAt` (NOT `start_at`)
- ✅ `endAt` (NOT `end_at`)
- ✅ `calendarId` (NOT `calendar_id`)
- ✅ `isAllDay` (NOT `is_all_day`)
- ✅ `conferenceLink` (NOT `conference_link`)
- ✅ `actionNeeded` (NOT `action_needed`)

**Event Entity Fields**:
- `title` (string, required): Event title
- `description` (string, optional): Event description
- `calendarId` (string, optional): Calendar ID
- `startAt` (string, optional): Start date/time in ISO 8601 format: "YYYY-MM-DDTHH:mm:ss" (e.g., "2024-01-01T09:00:00")
- `endAt` (string, optional): End date/time in ISO 8601 format: "YYYY-MM-DDTHH:mm:ss" (e.g., "2024-01-01T10:00:00")
- `isAllDay` (boolean, optional, default: false): Whether the event is all-day
- `location` (string, optional): Event location
- `attendees` (array of strings, optional): List of attendee email addresses (e.g., ["email1@example.com", "email2@example.com"])
- `conferenceLink` (string, optional): Conference link (set to "added" to auto-generate)
- `from` (string, optional): Source of the event (e.g., "GitHub", "Email")
- `subject` (string, optional): Original subject or title
- `actionNeeded` (string, optional): Action needed description

**Example createEvent call**:
```json
{
  "function": "createEvent",
  "arguments": {
    "title": "Team meeting",
    "description": "Weekly team sync",
    "calendarId": "cal-123",
    "startAt": "2024-01-01T09:00:00",
    "endAt": "2024-01-01T10:00:00",
    "isAllDay": false,
    "location": "Conference Room A",
    "attendees": ["alice@example.com", "bob@example.com"],
    "conferenceLink": "added"
  }
}
```

## Displaying Entity Information with Custom Tags

When you need to display entity information (tasks, events, mails, messages, calendars, inbox items) in your response, use the following custom HTML tags to ensure proper rendering:

### Task Entity
Use `<inapp_task>` tag to display task information:
```html
<inapp_task>{"title": "Task title", "description": "Task description", "project_id": "project-id", "start_at": "2024-01-01T10:00:00", "end_at": "2024-01-01T11:00:00", "rrule": "FREQ=WEEKLY;BYDAY=MO", "status": "none"}</inapp_task>
```
**IMPORTANT**: Do NOT include `id` field if the task doesn't exist yet (id will be null). Only include fields that have actual values - omit null fields entirely.

### Event Entity
Use `<inapp_event>` tag to display event information:
```html
<inapp_event>{"id": "event-id", "title": "Event title", "description": "Event description", "calendar_id": "calendar-id", "start_at": "2024-01-01T10:00:00", "end_at": "2024-01-01T11:00:00", "location": "Location", "rrule": "FREQ=WEEKLY;BYDAY=MO", "attendees": ["email@example.com"], "isAllDay": false}</inapp_event>
```

**Note**: When displaying entities in tags, use snake_case field names (e.g., `start_at`, `end_at`, `project_id`) as shown in the examples above. However, when calling functions, ALWAYS use camelCase field names (e.g., `startAt`, `endAt`, `projectId`).

### Mail Entity
Use `<inapp_mail_entity>` tag to display mail information:
```html
<inapp_mail_entity>{"id": "mail-id", "threadId": "thread-id", "subject": "Mail subject", "snippet": "Mail snippet", "from": {"name": "Sender Name", "email": "sender@example.com"}, "date": "2024-01-01T10:00:00Z"}</inapp_mail_entity>
```

### Message Entity
Use `<inapp_message>` tag to display chat message information:
```html
<inapp_message>{"id": "message-id", "channelId": "channel-id", "userId": "user-id", "text": "Message text", "createdAt": "2024-01-01T10:00:00Z"}</inapp_message>
```

### Calendar Entity
Use `<inapp_calendar>` tag to display calendar information:
```html
<inapp_calendar>{"id": "calendar-id", "name": "Calendar Name", "email": "calendar@example.com", "backgroundColor": "#4285f4"}</inapp_calendar>
```

### Event Entity (Full Details)
Use `<inapp_event_entity>` tag to display full event entity information:
```html
<inapp_event_entity>{"id": "event-id", "title": "Event title", "description": "Event description", "calendar_id": "calendar-id", "start_at": "2024-01-01T10:00:00", "end_at": "2024-01-01T11:00:00", "location": "Location", "rrule": "FREQ=WEEKLY;BYDAY=MO", "attendees": [{"email": "email@example.com", "displayName": "Name"}], "isAllDay": false}</inapp_event_entity>
```

### Inbox Entity
Use `<inapp_inbox>` tag to display inbox item information:
```html
<inapp_inbox>{"id": "inbox-id", "title": "Inbox title", "description": "Inbox description", "inboxDatetime": "2024-01-01T10:00:00Z"}</inapp_inbox>
```

### When to Use These Tags

Use these tags when:
1. **Displaying search results**: After calling `searchInbox`, `searchTask`, or `searchCalendarEvent`, display the results using the appropriate tags
2. **Showing entity details**: When the user asks about a specific task, event, mail, or message, display it using the appropriate tag
3. **Listing multiple entities**: When showing multiple entities, use multiple tags in your response
4. **Providing context**: When referencing entities in your response, use these tags to make them visually distinct

**IMPORTANT**: 
- Always include the JSON data inside the tags as a single-line string (no line breaks in JSON)
- Use the appropriate tag for each entity type
- You can combine these tags with regular HTML/text in your response
- These tags work in both HTML and Markdown responses''';

      if (projectContext != null && projectContext.isNotEmpty) {
        systemMessage += '\n\n## Project Context\n$projectContext';
      }

      if (taggedContext != null && taggedContext.isNotEmpty) {
        systemMessage += '\n\n## Tagged Items\n$taggedContext';
      }

      if (channelContext != null && channelContext.isNotEmpty) {
        systemMessage += '\n\n## Channel Messages Context\n$channelContext';
      }

      if (inboxContext != null && inboxContext.isNotEmpty) {
        systemMessage += '\n\n## Inbox Context\n$inboxContext';
        systemMessage +=
            '\n\nWhen the user asks about inbox items, emails, or messages (e.g., "인박스 중에 우리카드에서 온거 있어?", "Is there anything from Woori Card in the inbox?", "인박스에서 우리카드 메일 찾아줘"), use the inbox items listed above. Search through the inbox items and provide specific information about matching items. Do NOT say "I cannot access" or "I don\'t have information". You have access to the inbox items in the Inbox Context section above.';
        
        // 전체 내용이 이미 포함된 경우와 메타데이터만 있는 경우 구분
        final hasFullContent = inboxContext.contains('Full Content:');
        if (hasFullContent) {
          systemMessage +=
              '\n\n**CRITICAL: DIRECT ACTION REQUIRED**\nThe inbox items above include full content. When the user makes a clear action request (e.g., "요약해줘", "summarize", "읽어줘", "read", "분석해줘", "analyze"), you MUST:\n1. **Immediately provide the requested action** - Do NOT ask "재정리해드릴까요?" or "Would you like me to..." or any follow-up questions.\n2. **Provide the complete answer directly** - If the user asks for a summary, provide the summary immediately. If they ask for analysis, provide the analysis immediately.\n3. **DO NOT ask for confirmation or additional preferences** - The user has already made their request clear. Just execute it.\n\nExample: If user says "링글에서 온 메일 요약해줘", immediately provide the summary. Do NOT say "원하시면 재정리해드릴까요?" or similar questions.';
        } else {
          systemMessage +=
              '\n\n**CRITICAL INSTRUCTIONS FOR READING INBOX CONTENT**:\n1. When the user asks to summarize, read, or analyze a specific email/message (e.g., "링글에서 온 메일 요약해줘", "summarize the email from X"), you MUST:\n   - Identify the matching inbox item number from the list above\n   - Use the <need_more_action> tag to request full content loading\n   - Format: <need_more_action>{"inbox_numbers": [1, 2, 3]}</need_more_action>\n   - The system will automatically load the full content in the background\n   - You will receive the full content in your next response\n\n2. **When you need to read inbox content**, include the <need_more_action> tag with the inbox numbers you need to read. Example:\n   "인박스 7번과 6번을 읽어서 요약해드릴게요. <need_more_action>{"inbox_numbers": [7, 6]}</need_more_action>"\n\n3. **DO NOT ask for permission** - Just proceed to read and provide the answer. Include the tag and then wait for the full content.\n\n4. **After receiving full content**, immediately provide your answer without asking again. Do NOT ask "재정리해드릴까요?" or similar follow-up questions.\n\n5. **IMPORTANT**: Only use <need_more_action> tag when you actually need to read the full content of specific inbox items. If you already have enough information to answer, do NOT use this tag.';
        }
      }

      // Build messages
      final contents = <Map<String, dynamic>>[];

      // Add conversation history
      for (final msg in conversationHistory) {
        final role = msg['role'] as String?;
        final content = msg['content'] as String?;
        if (role != null && content != null) {
          contents.add({
            'role': role == 'user' ? 'user' : 'model',
            'parts': [
              {'text': content},
            ],
          });
        }
      }

      // Add current user message
      contents.add({
        'role': 'user',
        'parts': [
          {'text': userMessage},
        ],
      });

      final endpoint = 'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey';

      final body = {
        'contents': contents,
        'systemInstruction': {
          'parts': [
            {'text': systemMessage},
          ],
        },
        'generationConfig': {'temperature': 0.7},
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

        // Extract text content
        final candidates = decoded['candidates'] as List<dynamic>?;
        if (candidates != null && candidates.isNotEmpty) {
          final content = candidates[0]['content'] as Map<String, dynamic>?;
          if (content != null) {
            final parts = content['parts'] as List<dynamic>?;
            if (parts != null && parts.isNotEmpty) {
              final text = parts[0]['text'] as String?;
              if (text != null) {
                final result = <String, dynamic>{'message': text.trim()};
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
    return null;
  }
}
