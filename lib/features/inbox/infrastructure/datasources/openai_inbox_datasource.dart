import 'dart:convert';

import 'package:Visir/config/providers.dart';
import 'package:Visir/features/calendar/domain/entities/calendar_entity.dart';
import 'package:Visir/features/calendar/domain/entities/event_entity.dart';
import 'package:Visir/features/common/domain/entities/linked_item_entity.dart';
import 'package:Visir/features/common/infrastructure/entities/environment.dart';
import 'package:Visir/features/inbox/domain/datasources/inbox_datasource.dart';
import 'package:Visir/features/inbox/domain/entities/inbox_config_entity.dart';
import 'package:Visir/features/inbox/domain/entities/inbox_entity.dart';
import 'package:Visir/features/inbox/domain/entities/inbox_fetch_list_entity.dart';
import 'package:Visir/features/inbox/domain/entities/inbox_suggestion_entity.dart';
import 'package:Visir/features/mail/domain/entities/mail_entity.dart';
import 'package:Visir/features/task/domain/entities/project_entity.dart';
import 'package:Visir/features/task/domain/entities/task_entity.dart';
import 'package:Visir/flavors.dart';
import 'package:collection/collection.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

class OpenAiInboxDatasource extends InboxDatasource {
  @override
  Future<List<InboxSuggestionEntity>> fetchInboxSuggestions({required List<InboxEntity> inboxes, required List<ProjectEntity> projects, String? model, String? apiKey}) async {
    // API 키가 제공되지 않으면 전역 변수에서 가져오기
    String? finalApiKey = apiKey;
    if (finalApiKey == null || finalApiKey.isEmpty) {
      finalApiKey = openAiApiKey.isNotEmpty ? openAiApiKey : null;
      // 전역 변수에도 없으면 config.json에서 가져오기 (fallback)
      if (finalApiKey == null || finalApiKey.isEmpty) {
        final configFile = await rootBundle.loadString('assets/config/${F.envFileName}');
        final env = Environment.fromJson(json.decode(configFile) as Map<String, dynamic>);
        finalApiKey = env.openAiApiKey;
      }
    }
    if (finalApiKey == null || finalApiKey.isEmpty) {
      return [];
    }

    final modelName = model ?? 'gpt-4.1-mini';
    if (inboxes.isEmpty) return [];

    final allSuggestions = <InboxSuggestionEntity>[];
    // Optimal batch size for balance between speed and API response time
    const batchSize = 10;

    // Get device timezone
    final deviceTimezone = tz.local.name;

    // Helper function to get timezone for each inbox item
    String getItemTimezone(InboxEntity item) {
      // For mail, use the mail's timezone if available
      if (item.linkedMail?.timezone != null) {
        return item.linkedMail!.timezone!;
      }
      // For messages or when mail timezone is not available, use device timezone
      return deviceTimezone;
    }

    // Helper function to build conversation snippet from related inboxes
    // All thread messages should already be in allInboxes (fetched by controller)
    String _buildConversationSnippet(InboxEntity inbox, List<InboxEntity> allInboxes) {
      if (inbox.linkedMail != null) {
        // For mail: get all messages in the same thread
        final threadId = inbox.linkedMail!.threadId;
        final hostMail = inbox.linkedMail!.hostMail;
        final threadInboxes = allInboxes.where((i) => i.linkedMail?.threadId == threadId && i.linkedMail?.hostMail == hostMail).toList()
          ..sort((a, b) => a.inboxDatetime.compareTo(b.inboxDatetime));

        if (threadInboxes.length > 1) {
          return threadInboxes.map((i) => '${i.title}: ${i.description ?? ''}').join('\n---\n');
        }
        return inbox.description ?? '';
      } else if (inbox.linkedMessage != null) {
        final linkedMsg = inbox.linkedMessage!;

        if (linkedMsg.threadId.isNotEmpty && linkedMsg.threadId != linkedMsg.messageId) {
          // For chat thread: get all messages in the same thread
          final threadInboxes =
              allInboxes
                  .where((i) => i.linkedMessage?.threadId == linkedMsg.threadId && i.linkedMessage?.teamId == linkedMsg.teamId && i.linkedMessage?.channelId == linkedMsg.channelId)
                  .toList()
                ..sort((a, b) => a.inboxDatetime.compareTo(b.inboxDatetime));

          if (threadInboxes.length > 1) {
            return threadInboxes.map((i) => '${i.title}: ${i.description ?? ''}').join('\n---\n');
          }
        } else {
          // For regular chat messages (not thread): include context messages from the same channel
          // These are messages fetched around the target message for context
          final contextInboxes =
              allInboxes
                  .where(
                    (i) =>
                        i.linkedMessage != null &&
                        i.linkedMessage?.teamId == linkedMsg.teamId &&
                        i.linkedMessage?.channelId == linkedMsg.channelId &&
                        // Exclude thread replies (they are handled separately)
                        (i.linkedMessage?.threadId == null || i.linkedMessage?.threadId == i.linkedMessage?.messageId) &&
                        // Include messages within a reasonable time window (e.g., 2 hours)
                        (i.inboxDatetime.difference(inbox.inboxDatetime).abs() <= const Duration(hours: 2)),
                  )
                  .toList()
                ..sort((a, b) => a.inboxDatetime.compareTo(b.inboxDatetime));

          if (contextInboxes.length > 1) {
            return contextInboxes.map((i) => '${i.title}: ${i.description ?? ''}').join('\n---\n');
          }
        }

        return inbox.description ?? '';
      }

      return inbox.description ?? '';
    }

    Future<void> fetchSuggestions(List<InboxEntity> batch) async {
      final prompt =
          '''
You are an expert productivity assistant who triages a user's email-like inbox.

## Task
For **EVERY** item provided, you MUST return exactly one suggestion object. Do not skip or omit any items.
Decide whether each item deserves the user's attention and, if so, extract a deadline.
Return your results **only** as a JSON array, with exactly one object per input item, in the same order as the input items.

## Input
Each item has:
- `id` (string)
- `title` (string)
- `snippet` (string)    - full conversation content including thread messages or related messages in time window
- `datetime` (string, RFC 3339) - when the item arrived
- `timezone` (string) - timezone offset for the item (e.g., "+09:00", "-05:00")

## Output schema
```jsonc
[
  {
    "id":               "<same as input>",
    "summary":          "<short summary of the item>",
    "urgency":          "urgent | important | action_required | need_review | none",
    "reason":           "meeting_invitation | meeting_followup | meeting_notes | task_assignment | task_status_update | scheduling_request | scheduling_confirmation | document_review | code_review | approval_request | question | information_sharing | announcement | system_notification | cold_contact | customer_contact | other",
    "date_type":        "task | event",
    "project_id":       "<project id>",
    "target_date":      "<RFC 3339 timestamp with timezone or null>",   // For tasks: response/action deadline. For events: event start time
    "duration":         <number>,
    "is_asap":          <boolean>,
    "is_date_only":     <boolean>,
    "estimated_effort": <number>,  // Estimated minutes to read/respond/complete
    "sender_name":      "<sender name or null>",
    "priority_score":   <number>,  // 0-100, AI's overall priority assessment
    "reasoned_body":    "<≤ 20 characters from the snippet that justify the urgency>"
  },
  …
]

No additional keys, comments, or text are allowed.

Rules
	1.	When to set urgency = none:
	•	The snippet is advertisement-like or
	•	The message does not require reading, replying, acting, or has no deadline the user must meet.
	2.	Urgency classification (pick exactly one based on time sensitivity):
	•	urgent: must be read/replied immediately on sight
	•	important: not instant, but must be handled today
	•	action_required: user must reply or act, but the timing is flexible
	•	need_review: only needs reading/awareness (no reply)
	•	none: unimportant, ads, newsletters, etc.
	3.	Reason classification (pick exactly one based on content type):
	•	meeting_invitation     : Calendar invites, meeting requests.
	•	meeting_followup      : Post-meeting action items, decisions.
	•	meeting_notes        : Meeting recaps, notes, recordings.
	•	task_assignment       : Explicit task assignments, work requests, or action items directed to the user. This includes:
		- Direct requests to complete a task ("please do X", "can you handle Y", "I need you to Z")
		- Work assignments ("assign this to you", "your task is to...", "please take care of...")
		- Action items from meetings or discussions ("action item: you will...", "your responsibility is...")
		- Requests to review, prepare, or deliver something specific ("please review...", "can you prepare...", "please send me...")
		- Any message where someone is explicitly asking the user to do something specific
	•	task_status_update     : Updates on existing tasks/projects.
	•	scheduling_request     : Asking for availability, time proposals.
	•	scheduling_confirmation  : Confirming times, finalizing meetings.
	•	document_review       : Documents/reports needing review.
	•	code_review         : Pull requests, code reviews.
	•	approval_request      : Needing user approval/sign-off.
	•	question          : Direct questions to user. **DO NOT** use this reason for emails from noreply@ addresses, no-reply@ addresses, or any automated/system sender addresses. Use "system_notification" or "announcement" instead.
	•	information_sharing    : FYI emails, sharing information.
	•	announcement        : Team/company announcements.
	•	system_notification     : Automated system messages.
	•	cold_contact        : Initial outreach from unknown contacts (people you don't know or haven't interacted with before).
	•	customer_contact      : Messages from YOUR customers or clients (people/companies who are YOUR customers, meaning you provide services/products to them). **DO NOT** use this for emails where YOU are the customer (e.g., emails from companies you buy from, subscription services, vendors you purchase from). Use "other" or "system_notification" instead.
	•	other            : Doesn't fit other categories.
	4.	Target-date logic:
	•	For actionable tasks (date_type = "task"):
		- Set date_type = "task"
		- target_date should be the RESPONSE/ACTION DEADLINE (when user must reply or act), NOT the task completion date
		- Extract from phrases like "please respond by...", "reply before...", "let me know by..."
		- Use RFC 3339 format with timezone offset (e.g., "2024-03-15T14:30:00+09:00")
		- Use the item's timezone to interpret any dates/times mentioned in the snippet
		- If no specific deadline is mentioned → target_date = null, is_asap = false
		- If "ASAP" or "urgent response needed" is mentioned → is_asap = true and omit target_date
	•	For calendar events (date_type = "event"):
		- Set date_type = "event"
		- Set target_date to the event's START TIME in RFC 3339 format with timezone offset
		- Use the item's timezone to interpret the event time
		- Include duration in minutes (as integer) if mentioned
		- If only a date (no time) is given → set is_date_only = true and use YYYY-MM-DD format
	•	target_date must be on or after the item's datetime; otherwise use null
	5.	Estimated effort:
	•	Estimate how many minutes it will take the user to read, understand, and respond/complete this item
	•	Consider: email length, complexity, number of questions, attachments mentioned
	•	Typical ranges: Quick read (1-5 min), Simple reply (5-15 min), Detailed response (15-30 min), Complex task (30+ min)
	•	Set to null if cannot estimate
	6.	Sender information:
	•	Extract the sender's name from the snippet if available
	•	Use the most human-readable form (e.g., "John Smith" not "john.smith@company.com")
	•	Set to null if sender is unclear or system-generated
	7.	Priority score:
	•	Calculate a 0-100 priority score combining:
		- Urgency level (urgent=high, need_review=low)
		- Sender importance (if recognizable as manager/client/VIP)
		- Deadline proximity
		- Content complexity
	•	Higher score = higher priority
	8.	Reasoned body:
	•	Copy ≤ 20 consecutive characters (no line breaks) from the original snippet that best explain why the item has this urgency level.
	9.	**CRITICAL REQUIREMENT**: You MUST return exactly one suggestion object for EVERY input item. Never skip, omit, or filter out any items. The output array must have the same length as the input array.
	11.	De-duplication & Noise Control:
	•	If multiple items are about the same topic (e.g., a series of commit messages, repeated system alerts, or duplicate notifications), mark the redundant items with urgency="none" but still return a suggestion for each item.
	•	For commit messages, unless they explicitly mention a failure or urgent action, mark them as urgency="none" if they are just logs, but still return a suggestion for each item.
	•	**STRICTLY** mark as urgency="none" if the item is:
		- A newsletter, marketing email, or promotional offer.
		- A notification about a sale, discount, or new product launch.
		- A generic "Welcome" or "Thank you for subscribing" message.
		- Contains keywords like "unsubscribe", "view in browser", "limited time offer", "sale ends soon".
	•	**MANDATORY**: The number of suggestions in your output must exactly match the number of items in the input. If you receive N items, you must return N suggestions.
	10.	Summary:
	•	Generate a concise, action-oriented title (e.g., "Review Q3 Report", "Meeting with John").
	•	Avoid generic titles like "Forwarded message" or "Re: Hello".
	11.	Project id:
	•	Select the most relevant project ID from the list below based on the item content and project name/description.
	•	Consider the project hierarchy (parent_id) to understand the context.
	•	If the item does not clearly belong to any project, set project_id to null.
	•	Available Projects: ${jsonEncode(projects.map((e) => {'id': e.uniqueId, 'name': e.name, 'description': e.description, 'parent_id': e.parentId}).toList())}
	•	If the item does not clearly belong to any project, set project_id to null.

Style requirements
	•	Return valid JSON only.
	•	Do not output explanations, comments, or markdown.
	•	Think through the rules internally before writing the final JSON, but do not reveal your reasoning.

Begin

Items:

${jsonEncode(batch.map((e) => {'id': e.id, 'datetime': e.inboxDatetime.toLocal().toIso8601String(), 'timezone': getItemTimezone(e), 'snippet': _buildConversationSnippet(e, inboxes), 'title': e.title}).toList())}
''';

      const endpoint = 'https://api.openai.com/v1/responses';

      final body = {
        'model': modelName,
        'store': false,
        'input': [
          {'role': 'user', 'content': prompt},
        ],
        "text": {
          "format": {
            "type": "json_schema",
            "name": "inbox_suggestion",
            "schema": {
              "type": "object",
              "properties": {
                "suggestions": {
                  "type": "array",
                  "items": {
                    "type": "object",
                    "properties": {
                      "id": {"type": "string"},
                      "summary": {"type": "string"},
                      "urgency": {
                        "type": "string",
                        "enum": ["urgent", "important", "action_required", "need_review", "none"],
                      },
                      "reason": {
                        "type": "string",
                        "enum": [
                          "meeting_invitation",
                          "meeting_followup",
                          "meeting_notes",
                          "task_assignment",
                          "task_status_update",
                          "scheduling_request",
                          "scheduling_confirmation",
                          "document_review",
                          "code_review",
                          "approval_request",
                          "question",
                          "information_sharing",
                          "announcement",
                          "system_notification",
                          "cold_contact",
                          "customer_contact",
                          "other",
                        ],
                      },
                      "reasoned_body": {
                        "type": ["string", "null"],
                      },
                      "date_type": {
                        "type": "string",
                        "enum": ["task", "event"],
                      },
                      "target_date": {
                        "type": ["string", "null"],
                        "format": "date-time",
                      },
                      "duration": {
                        "type": ["integer", "null"],
                        "description": "Duration in minutes for calendar events",
                      },
                      "is_asap": {
                        "type": ["boolean", "null"],
                      },
                      "is_date_only": {
                        "type": ["boolean", "null"],
                      },
                      "project_id": {
                        "type": ["string", "null"],
                      },
                      "estimated_effort": {
                        "type": ["integer", "null"],
                        "description": "Estimated effort in minutes",
                      },
                      "sender_name": {
                        "type": ["string", "null"],
                      },
                      "priority_score": {
                        "type": ["integer", "null"],
                        "description": "Priority score from 0 to 100",
                      },
                    },
                    "required": [
                      "id",
                      "summary",
                      "urgency",
                      "reason",
                      "reasoned_body",
                      "date_type",
                      "target_date",
                      "duration",
                      "is_asap",
                      "is_date_only",
                      "project_id",
                      "estimated_effort",
                      "sender_name",
                      "priority_score",
                    ],
                    "additionalProperties": false,
                  },
                },
              },
              "required": ["suggestions"],
              "additionalProperties": false,
            },
            "strict": true,
          },
        },
      };

      final res = await http.post(Uri.parse(endpoint), headers: {'Authorization': 'Bearer $finalApiKey', 'Content-Type': 'application/json'}, body: jsonEncode(body));

      if (res.statusCode == 200) {
        final decoded = jsonDecode(utf8.decode(res.bodyBytes));
        final text = ((decoded?['output'] as List<dynamic>?)?.firstOrNull?['content'] as List<dynamic>?)?.firstOrNull?['text'];
        final json = text is String ? jsonDecode(text) : text;
        final suggestions = (json ?? {})['suggestions'] as List<dynamic>?;

        if (suggestions != null && suggestions.isNotEmpty) {
          final receivedIds = suggestions.map((e) => e['id'] as String).toSet();
          final batchIds = batch.map((e) => e.id).toSet();

          // Check for missing suggestions and create default ones
          final missingIds = batchIds.difference(receivedIds);
          if (missingIds.isNotEmpty) {
            // Create default suggestions for missing items
            for (final missingId in missingIds) {
              final inbox = batch.firstWhere((e) => e.id == missingId);
              suggestions.add({
                'id': missingId,
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
              });
            }
          }

          allSuggestions.addAll(suggestions.map((e) => InboxSuggestionEntity.fromJson(e, local: true))); // AI는 평문
        } else {
          // If no suggestions returned, create default ones for all batch items
          for (final inbox in batch) {
            allSuggestions.add(
              InboxSuggestionEntity.fromJson({
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
                'is_encrypted': false,
              }, local: true), // AI는 평문
            );
          }
        }
      }
    }

    List<List<InboxEntity>> batches = [];
    for (var i = 0; i < inboxes.length; i += batchSize) {
      final end = (i + batchSize < inboxes.length) ? i + batchSize : inboxes.length;
      final batch = inboxes.sublist(i, end);
      batches.add(batch);
    }

    await Future.wait(batches.map((e) => fetchSuggestions(e)).toList());
    return allSuggestions;
  }

  @override
  Future<List<InboxSuggestionEntity>> fetchInboxSuggestionsFromCache({required String userId, required List<String> inboxIds}) async {
    // OpenAI datasource doesn't handle caching - Supabase datasource handles it
    return [];
  }

  @override
  Future<void> saveInboxSuggestions({required String userId, required List<InboxSuggestionEntity> suggestions}) async {
    // OpenAI datasource doesn't handle caching - Supabase datasource handles it
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
    // OpenAI datasource doesn't handle caching - Supabase datasource handles it
    return null;
  }

  @override
  Future<void> saveConversationSummary({required String userId, String? taskId, String? eventId, required String summary}) async {
    // OpenAI datasource doesn't handle caching - Supabase datasource handles it
    return;
  }

  /// Fetches conversation summary for a specific inbox item
  /// This is called on-demand when needed (e.g., in summary widget)
  Future<String?> fetchConversationSummary({
    required InboxEntity inbox,
    required List<InboxEntity> allInboxes,
    List<EventEntity>? eventEntities,
    String? model,
    String? apiKey,
  }) async {
    final modelName = model ?? 'gpt-5-mini';
    // API 키가 제공되지 않으면 환경 변수에서 가져오기
    String? finalApiKey = apiKey;
    if (finalApiKey == null || finalApiKey.isEmpty) {
      final configFile = await rootBundle.loadString('assets/config/${F.envFileName}');
      final env = Environment.fromJson(json.decode(configFile) as Map<String, dynamic>);
      finalApiKey = openAiApiKey.isNotEmpty ? openAiApiKey : (env.openAiApiKey.isNotEmpty ? env.openAiApiKey : null);
    }

    // Build conversation snippet
    String conversationSnippet;

    // Virtual inbox (no linkedMail/linkedMessage): use allInboxes to build conversation snippet
    // Group by threadId for mails and by channel/thread for messages
    if (allInboxes.isNotEmpty) {
      // Separate mails and messages
      final mailInboxes = allInboxes.where((i) => i.linkedMail != null).toList();
      final messageInboxes = allInboxes.where((i) => i.linkedMessage != null).toList();

      List<String> snippets = [];

      // Process mails: group by threadId
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

      // Process messages: group by channel/thread
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

    // Process calendar events if provided
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

    // Check if virtual inbox (no linkedMail/linkedMessage and no conversation content)
    final hasVirtualInbox = inbox.linkedMail == null && inbox.linkedMessage == null && allInboxes.isEmpty;
    final hasOnlyEvents = hasVirtualInbox && (eventSnippet != null && eventSnippet.isNotEmpty);

    // Extract current task/event description if available - always include if present
    final currentTaskEventDescription = inbox.description != null && inbox.description!.isNotEmpty ? inbox.description : null;

    // If no conversation content and no events, return null
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

    const endpoint = 'https://api.openai.com/v1/responses';

    final body = {
      'model': modelName,
      'store': false,
      'input': [
        {'role': 'user', 'content': prompt},
      ],
    };

    try {
      final res = await http.post(Uri.parse(endpoint), headers: {'Authorization': 'Bearer $finalApiKey', 'Content-Type': 'application/json'}, body: jsonEncode(body));

      if (res.statusCode == 200) {
        final decoded = jsonDecode(utf8.decode(res.bodyBytes));

        // Check for errors
        if (decoded['error'] != null) {
          return null;
        }

        // Find the message output item and extract text
        String? text;
        final outputList = decoded?['output'] as List<dynamic>?;
        if (outputList != null) {
          for (final outputItem in outputList) {
            if (outputItem is Map<String, dynamic> && outputItem['type'] == 'message') {
              final contentList = outputItem['content'] as List<dynamic>?;
              if (contentList != null) {
                for (final contentItem in contentList) {
                  if (contentItem is Map<String, dynamic> && contentItem['type'] == 'output_text') {
                    text = contentItem['text'] as String?;
                    break;
                  }
                }
              }
              if (text != null) break;
            }
          }
        }

        return text?.trim();
      }
    } catch (e) {
      // Return null on error
      return null;
    }

    return null;
  }

  /// Extracts search keywords from task information using OpenAI
  /// Returns a list of keywords that can be used to search in integrated datasources
  Future<List<String>?> extractSearchKeywords({required String taskTitle, String? taskDescription, String? taskProjectName, String? calendarName, String? apiKey}) async {
    // API 키가 제공되지 않으면 환경 변수에서 가져오기
    String? finalApiKey = apiKey;
    if (finalApiKey == null || finalApiKey.isEmpty) {
      final configFile = await rootBundle.loadString('assets/config/${F.envFileName}');
      final env = Environment.fromJson(json.decode(configFile) as Map<String, dynamic>);
      finalApiKey = openAiApiKey.isNotEmpty ? openAiApiKey : (env.openAiApiKey.isNotEmpty ? env.openAiApiKey : null);
    }

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

    const endpoint = 'https://api.openai.com/v1/responses';

    final body = {
      'model': 'gpt-4o-mini',
      'store': false,
      'input': [
        {'role': 'user', 'content': prompt},
      ],
      "text": {
        "format": {
          "type": "json_schema",
          "name": "search_keywords",
          "schema": {
            "type": "object",
            "properties": {
              "keywords": {
                "type": "array",
                "items": {"type": "string"},
                "minItems": 1,
                "maxItems": 5,
              },
            },
            "required": ["keywords"],
            "additionalProperties": false,
          },
          "strict": true,
        },
      },
    };

    try {
      final res = await http.post(Uri.parse(endpoint), headers: {'Authorization': 'Bearer $finalApiKey', 'Content-Type': 'application/json'}, body: jsonEncode(body));

      if (res.statusCode == 200) {
        final decoded = jsonDecode(utf8.decode(res.bodyBytes));

        // Check for errors
        if (decoded['error'] != null) {
          return null;
        }

        // Find the message output item and extract text
        String? text;
        final outputList = decoded?['output'] as List<dynamic>?;
        if (outputList != null) {
          for (final outputItem in outputList) {
            if (outputItem is Map<String, dynamic> && outputItem['type'] == 'message') {
              final contentList = outputItem['content'] as List<dynamic>?;
              if (contentList != null) {
                for (final contentItem in contentList) {
                  if (contentItem is Map<String, dynamic> && contentItem['type'] == 'output_text') {
                    text = contentItem['text'] as String?;
                    break;
                  }
                }
              }
              if (text != null) break;
            }
          }
        }

        if (text != null) {
          final jsonData = jsonDecode(text);
          final keywords = (jsonData['keywords'] as List<dynamic>?)?.map((e) => e.toString()).toList();
          return keywords?.where((k) => k.isNotEmpty).toList();
        }
      }
    } catch (e) {
      // Return null on error
      return null;
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
    // API 키가 제공되지 않으면 환경 변수에서 가져오기
    String? finalApiKey = apiKey;
    if (finalApiKey == null || finalApiKey.isEmpty) {
      final configFile = await rootBundle.loadString('assets/config/${F.envFileName}');
      final env = Environment.fromJson(json.decode(configFile) as Map<String, dynamic>);
      finalApiKey = openAiApiKey.isNotEmpty ? openAiApiKey : (env.openAiApiKey.isNotEmpty ? env.openAiApiKey : null);
    }

    final originalSnippet = originalMail.snippetWithLineBreaks ?? originalMail.snippet ?? '';
    final originalSubject = originalMail.subject ?? '';
    final fromName = originalMail.from?.name ?? '';
    final fromEmail = originalMail.from?.email ?? '';

    // 대화 히스토리를 문자열로 변환
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

    const endpoint = 'https://api.openai.com/v1/responses';

    final body = {
      'model': 'gpt-4o-mini',
      'store': false,
      'input': [
        {'role': 'user', 'content': prompt},
      ],
    };

    try {
      final res = await http.post(Uri.parse(endpoint), headers: {'Authorization': 'Bearer $finalApiKey', 'Content-Type': 'application/json'}, body: jsonEncode(body));

      if (res.statusCode == 200) {
        final decoded = jsonDecode(utf8.decode(res.bodyBytes));

        // Check for errors
        if (decoded['error'] != null) {
          return null;
        }

        // Find the message output item and extract text
        String? text;
        final outputList = decoded?['output'] as List<dynamic>?;
        if (outputList != null) {
          for (final outputItem in outputList) {
            if (outputItem is Map<String, dynamic> && outputItem['type'] == 'message') {
              final contentList = outputItem['content'] as List<dynamic>?;
              if (contentList != null) {
                for (final contentItem in contentList) {
                  if (contentItem is Map<String, dynamic> && contentItem['type'] == 'output_text') {
                    text = contentItem['text'] as String?;
                    break;
                  }
                }
              }
              if (text != null) break;
            }
          }
        }

        return text?.trim();
      }
    } catch (e) {
      // Return null on error
      return null;
    }

    return null;
  }

  /// AI를 사용하여 메일 내용을 생성합니다. (LinkedMailEntity 사용)
  Future<String?> generateMailContentFromLinked({
    String? apiKey,
    required LinkedMailEntity linkedMail,
    required String snippet,
    required String userRequest,
    required List<Map<String, dynamic>> conversationHistory,
    required String model,
  }) async {
    // API 키가 제공되지 않으면 환경 변수에서 가져오기
    String? finalApiKey = apiKey;
    if (finalApiKey == null || finalApiKey.isEmpty) {
      final configFile = await rootBundle.loadString('assets/config/${F.envFileName}');
      final env = Environment.fromJson(json.decode(configFile) as Map<String, dynamic>);
      finalApiKey = openAiApiKey.isNotEmpty ? openAiApiKey : (env.openAiApiKey.isNotEmpty ? env.openAiApiKey : null);
    }

    final originalSubject = linkedMail.title;
    final fromName = linkedMail.fromName;

    // Convert conversation history to string
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

    const endpoint = 'https://api.openai.com/v1/responses';

    final body = {
      'model': model,
      'store': false,
      'input': [
        {'role': 'user', 'content': prompt},
      ],
    };

    try {
      final res = await http.post(Uri.parse(endpoint), headers: {'Authorization': 'Bearer $finalApiKey', 'Content-Type': 'application/json'}, body: jsonEncode(body));

      if (res.statusCode == 200) {
        final decoded = jsonDecode(utf8.decode(res.bodyBytes));

        // Check for errors
        if (decoded['error'] != null) {
          return null;
        }

        // Find the message output item and extract text
        String? text;
        final outputList = decoded?['output'] as List<dynamic>?;
        if (outputList != null) {
          for (final outputItem in outputList) {
            if (outputItem is Map<String, dynamic> && outputItem['type'] == 'message') {
              final contentList = outputItem['content'] as List<dynamic>?;
              if (contentList != null) {
                for (final contentItem in contentList) {
                  if (contentItem is Map<String, dynamic> && contentItem['type'] == 'output_text') {
                    text = contentItem['text'] as String?;
                    break;
                  }
                }
              }
              if (text != null) break;
            }
          }
        }

        return text?.trim();
      }
    } catch (e) {
      // Return null on error
      return null;
    }

    return null;
  }

  /// AI를 사용하여 메일 답장 제안을 생성합니다. (LinkedMailEntity 사용)
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
    String? actionType, // 'reply', 'send', etc. - used to adjust prompt
    String? apiKey,
  }) async {
    // API 키가 제공되지 않으면 환경 변수에서 가져오기
    String? finalApiKey = apiKey;
    if (finalApiKey == null || finalApiKey.isEmpty) {
      final configFile = await rootBundle.loadString('assets/config/${F.envFileName}');
      final env = Environment.fromJson(json.decode(configFile) as Map<String, dynamic>);
      finalApiKey = openAiApiKey.isNotEmpty ? openAiApiKey : (env.openAiApiKey.isNotEmpty ? env.openAiApiKey : null);
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
    final actionVerb = isSendAction ? 'send' : 'reply';

    if (previousReply != null && userModificationRequest != null) {
      // User wants to modify the existing reply/email
      prompt =
          '''
You are helping to modify a suggested email ${actionLabel} based on user feedback.
${isSendAction ? '''
## Email to Send
Subject: $originalSubject
Body:
$previousReply
''' : '''
## Email Thread${threadMessages != null && threadMessages.isNotEmpty ? ' (Full Thread)' : ' (Single Email)'}
${threadMessages != null && threadMessages.isNotEmpty ? threadContext : '''
Subject: $originalSubject
From: $fromName
Body:
$snippet
'''}

## Previous Suggested Reply
$previousReply
'''}
## User's Modification Request
$userModificationRequest

## Your Task
**Modify the ${actionLabel}**: Update the suggested ${actionLabel} based on the user's request. The modified ${actionLabel} should:
   - Address the user's specific modification request
   - Maintain the professional tone and context
   - Keep appropriate greetings and closing remarks
   - Be concise and to the point
   - Sound professional but friendly
   - Be written in plain text format (not HTML)
   - Preserve line breaks (use \\n for new lines)
   - Use [Your Name] as a placeholder for the sender's name if the name is not available in the context
   ${originalMailBody != null && originalMailBody.isNotEmpty ? '- **CRITICAL**: Write the modified ${actionLabel} in the SAME LANGUAGE as the original email. Maintain the language consistency with the original email.\n' : ''}

- **Determine if the user is confirming/approving the ${actionVerb} sending (isConfirmed: true) or just requesting modification (isConfirmed: false)**:
  - **STEP 1 - CHECK USER REQUEST FIRST**: Look at the user's request ("$userModificationRequest") and check if it contains ONLY confirmation phrases or modification words.
  - **CRITICAL RULE FOR CONFIRMATION PHRASES**: If the user's request contains ONLY confirmation phrases WITHOUT any modification requests, isConfirmed MUST be true. Confirmation phrases include:
    * "send it", "send as is", "now send it", "ok, now send it", "ok now send it"
    * "이대로 보내줘", "그대로 보내줘", "보내줘", "보내", "그대로", "이대로"
    * "yes, send it", "go ahead", "proceed", "ok", "네", "좋아", "응"
  - **CRITICAL**: If userModificationRequest contains ONLY confirmation phrases (listed above) and NO modification words (like "change", "modify", "edit", "make", "add", "remove", "수정", "바꿔", "변경"), then isConfirmed MUST be true.
  - CRITICAL: Set isConfirmed to true if ALL of the following conditions are met:
    1. The user explicitly confirms sending the ${actionLabel} using confirmation phrases (e.g., "send it", "now send it", "ok, now send it", "send as is", "이대로 보내줘", "그대로 보내줘", "yes, send it", "go ahead", "proceed", "보내줘", "보내", "그대로", "이대로", "ok", "네", "좋아")
    2. The user is NOT requesting ANY changes to the ${actionLabel} (no words like "change", "modify", "edit", "make", "add", "remove", "shorter", "longer", "수정", "바꿔", "변경")
    3. The user is NOT asking questions about the ${actionLabel}
    4. The user's request is a clear confirmation command, NOT a modification request
  - Examples of isConfirmed = true (when user says ONLY confirmation phrases):
    - "send it" → isConfirmed = true
    - "send as is" → isConfirmed = true
    - "now send it" → isConfirmed = true
    - "ok, now send it" → isConfirmed = true
    - "이대로 보내줘" → isConfirmed = true
    - "그대로 보내줘" → isConfirmed = true
    - "보내줘" → isConfirmed = true
    - "yes, send it" → isConfirmed = true
    - "go ahead and send" → isConfirmed = true
    - "proceed" → isConfirmed = true
    - "ok" → isConfirmed = true
  - Examples of isConfirmed = false (when user requests changes):
    - "make it shorter" → isConfirmed = false
    - "add more details" → isConfirmed = false
    - "change the tone" → isConfirmed = false
    - "수정해줘" → isConfirmed = false
    - "바꿔줘" → isConfirmed = false
  - **EXAMPLES FOR DECISION**:
    - User says: "send it" → Contains ONLY confirmation phrase → isConfirmed = true
    - User says: "send as is" → Contains ONLY confirmation phrase → isConfirmed = true
    - User says: "now send it" → Contains ONLY confirmation phrase → isConfirmed = true
    - User says: "ok, now send it" → Contains ONLY confirmation phrase → isConfirmed = true
    - User says: "make it shorter" → Contains modification word "make" → isConfirmed = false
    - User says: "send it but make it shorter" → Contains modification word "make" → isConfirmed = false
    - User says: "이대로 보내줘" → Contains ONLY confirmation phrase → isConfirmed = true
    - User says: "그대로 보내줘" → Contains ONLY confirmation phrase → isConfirmed = true
    - User says: "수정해줘" → Contains modification word "수정" → isConfirmed = false
  - **CRITICAL**: When user says ONLY "send it", "send as is", "now send it", "ok, now send it", "이대로 보내줘", "그대로 보내줘" WITHOUT any modification words, isConfirmed MUST be true. Do NOT set isConfirmed to false just because you are in modification mode - check the actual user request first.

## Output Format
Return a JSON object with the following structure:
{
  "suggested_reply": "The modified suggested reply text",
  "isConfirmed": true or false
}

Return only the JSON object, no additional text or explanations.
''';
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

      prompt =
          '''
You are helping to draft a reply email. First, analyze the email thread and summarize it, then suggest an appropriate reply.

## Email Thread${threadMessages != null && threadMessages.isNotEmpty ? ' (Full Thread)' : ' (Single Email)'}
${threadMessages != null && threadMessages.isNotEmpty ? threadContext : '''
Subject: $originalSubject
From: $fromName${senderEmail != null ? ' <$senderEmail>' : ''}
Body:
$snippet
'''}$recipientsInfo

## Important Context
- You are replying to an email from: ${senderName ?? fromName}${senderEmail != null ? ' ($senderEmail)' : ''}
- Your email address (the person replying) is: ${currentUserEmail?.isNotEmpty == true ? currentUserEmail : '[not provided]'}
- For a simple Reply, the "to" field must contain ONLY the original sender's email address${senderEmail != null ? ' ($senderEmail)' : ''}, NOT your own email address${currentUserEmail?.isNotEmpty == true ? ' ($currentUserEmail)' : ''}.
- **CRITICAL**: Do NOT include ${currentUserEmail?.isNotEmpty == true ? currentUserEmail : 'your own email address'} in the "to" list. The "to" list should only contain ${senderEmail != null ? senderEmail : 'the original sender\'s email'}.
- Use [Your Name] as a placeholder for YOUR name (the person replying), NOT the recipient's name (${senderName ?? fromName}).
- Do NOT use "${senderName ?? fromName}" in the reply signature or greeting - that is the person you're replying TO, not your name.
${originalMailBody != null && originalMailBody.isNotEmpty ? '- **Language**: Write the suggested reply in the same language as the original email. Analyze the language used in the original email and respond in that same language.\n' : ''}

## Your Task
1. **Summarize the thread**: Provide a concise summary of the entire email thread, highlighting:
   - The main topic/subject
   - Key points discussed
   - Any questions or requests
   - Important context or background
   - The current state of the conversation

2. **Determine reply recipients**: Based on the email thread and original recipients, decide whether this should be a "Reply" (only to the sender) or "Reply All" (including CC recipients):
   - If the conversation involves multiple people (CC recipients), use "Reply All"
   - If the conversation is a direct exchange with the sender only, use "Reply"
   - Consider the context: if CC recipients are part of the discussion, include them
   - Set "suggest_reply_all" to true if Reply All is more appropriate

3. **Suggest a reply**: Generate a natural, professional reply that:
   - Addresses any questions or requests from the thread
   - Is appropriate for the conversation context
   - Includes appropriate greetings and closing remarks
   - Is concise and to the point
   - Sounds professional but friendly
   - Is written in plain text format (not HTML)
   - Preserves line breaks (use \\n for new lines)
   - **IMPORTANT**: Use [Your Name] as a placeholder for the sender's name (the person replying), NOT the recipient's name. Do NOT use the recipient's name in the reply signature.
   ${originalMailBody != null && originalMailBody.isNotEmpty ? '- **CRITICAL**: Write the reply in the SAME LANGUAGE as the original email. Analyze the language used in the original email body and respond in that exact same language (e.g., if the original email is in Korean, write the reply in Korean; if it is in English, write in English).\n' : ''}

4. **Determine if the user is confirming/approving the reply sending (isConfirmed: true) or just requesting information/modification (isConfirmed: false)**:
   - CRITICAL RULE: This is the initial reply generation. isConfirmed MUST be false for initial generation. Only set isConfirmed to true if the user explicitly confirms sending in a subsequent interaction.
   - CRITICAL: Set isConfirmed to true ONLY if ALL of the following conditions are met:
     1. The user explicitly confirms sending the reply (e.g., "send it", "now send it", "ok, now send it", "이대로 보내줘", "그대로 보내줘", "yes, send it", "go ahead", "proceed", "send as is", "보내줘", "보내")
     2. The user is NOT requesting ANY changes to the reply
     3. The user is NOT asking questions about the reply
     4. The user's request contains confirmation phrases like: "그대로", "이대로", "send", "now send", "go ahead", "proceed", "yes", "ok", "네", "좋아"
   - Examples of isConfirmed = true (ONLY when no changes are requested):
     - "send it", "now send it", "ok, now send it", "ok now send it", "이대로 보내줘", "그대로 보내줘", "보내줘", "yes, send it", "go ahead and send", "proceed", "send as is", "ok", "네", "좋아"
   - CRITICAL: Set isConfirmed to false if ANY of the following is true:
     - The user is requesting ANY changes to the reply (e.g., "make it shorter", "add more details", "change the tone", "수정해줘", "바꿔줘")
     - The user is asking questions about the reply
     - The user wants to see the reply first before sending
     - This is the first time generating the reply (initial generation) - ALWAYS false
     - The user's request does NOT contain clear confirmation phrases
     * For initial generation, ALWAYS set isConfirmed to false
     * Only set isConfirmed to true when the user explicitly confirms sending (e.g., "이대로 보내줘", "그대로 보내줘", "send it as shown", "yes, send it", "now send it", "ok, now send it", "send as is")
     * **IMPORTANT**: "send as is" is a CLEAR confirmation phrase - set isConfirmed to true

## Output Format
Return a JSON object with the following structure:
{
  "thread_summary": "Brief summary of the email thread",
  "suggested_reply": "The suggested reply text",
  "to": [{"email": "email@example.com", "name": "Name"}],
  "cc": [{"email": "email@example.com", "name": "Name"}],
  "bcc": [],
  "suggest_reply_all": true or false,
  "isConfirmed": true or false
}

For recipients:
- "to": List of email addresses that should receive this reply. For a simple Reply, this should be ONLY the original sender (the person who sent the email you're replying to). For Reply All, include all participants.
- "cc": List of CC recipients (empty for Reply, include original CC recipients for Reply All)
- "bcc": Always empty array (BCC recipients should not be included)
- "suggest_reply_all": Boolean indicating if Reply All is recommended

**IMPORTANT**: 
- For a simple Reply, "to" must contain ONLY the original sender's email address${senderEmail != null ? ' ($senderEmail)' : ''}, NOT your own email address${currentUserEmail?.isNotEmpty == true ? ' ($currentUserEmail)' : ''}.
- **CRITICAL**: Do NOT include ${currentUserEmail?.isNotEmpty == true ? currentUserEmail : 'your own email address'} in the "to" list. The "to" list should only contain ${senderEmail != null ? senderEmail : 'the original sender\'s email'}.
- The reply text should use [Your Name] as a placeholder for YOUR name (the person replying), NOT the recipient's name (${senderName ?? fromName}).
- Do NOT use "${senderName ?? fromName}" in the reply signature or greeting - that is the person you're replying TO, not your name.

Return only the JSON object, no additional text or explanations.
''';
    }

    const endpoint = 'https://api.openai.com/v1/responses';

    // Different JSON schema based on whether it's a modification or initial generation
    final Map<String, dynamic> schema;
    if (previousReply != null && userModificationRequest != null) {
      // Modification mode: suggested_reply and isConfirmed are required
      schema = {
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
      schema = {
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

    final body = {
      'model': model,
      'store': false,
      'input': [
        {'role': 'user', 'content': prompt},
      ],
      "text": {
        "format": {"type": "json_schema", "name": "reply_suggestion", "schema": schema, "strict": true},
      },
    };

    try {
      final res = await http.post(Uri.parse(endpoint), headers: {'Authorization': 'Bearer $finalApiKey', 'Content-Type': 'application/json'}, body: jsonEncode(body));

      if (res.statusCode == 200) {
        final decoded = jsonDecode(utf8.decode(res.bodyBytes));

        // Check for errors
        if (decoded['error'] != null) {
          return null;
        }

        // Find the message output item and extract JSON
        String? jsonText;
        final outputList = decoded?['output'] as List<dynamic>?;
        if (outputList != null) {
          for (final outputItem in outputList) {
            if (outputItem is Map<String, dynamic> && outputItem['type'] == 'message') {
              final contentList = outputItem['content'] as List<dynamic>?;
              if (contentList != null) {
                for (final contentItem in contentList) {
                  if (contentItem is Map<String, dynamic> && contentItem['type'] == 'output_text') {
                    jsonText = contentItem['text'] as String?;
                    break;
                  }
                }
              }
              if (jsonText != null) break;
            }
          }
        }

        if (jsonText != null) {
          try {
            final jsonData = jsonDecode(jsonText) as Map<String, dynamic>;
            final result = <String, dynamic>{};

            // Check if this is modification mode or initial generation
            final isModification = previousReply != null && userModificationRequest != null;

            if (isModification) {
              // Modification mode: include suggested_reply and isConfirmed
              result['suggested_reply'] = jsonData['suggested_reply'] as String? ?? '';
              result['isConfirmed'] = jsonData['isConfirmed'] as bool? ?? false;
            } else {
              // Initial generation: include thread_summary, suggested_reply, recipients, and isConfirmed
              result['thread_summary'] = jsonData['thread_summary'] as String? ?? '';
              result['suggested_reply'] = jsonData['suggested_reply'] as String? ?? '';
              result['to'] = jsonData['to'] as List? ?? [];
              result['cc'] = jsonData['cc'] as List? ?? [];
              result['bcc'] = jsonData['bcc'] as List? ?? [];
              result['suggest_reply_all'] = jsonData['suggest_reply_all'] as bool? ?? false;
              result['isConfirmed'] = jsonData['isConfirmed'] as bool? ?? false;
            }

            return result;
          } catch (e) {
            // Failed to parse JSON, return null
            return null;
          }
        }
      }
    } catch (e) {
      // Return null on error
      return null;
    }
    return null;
  }

  /// Helper function to get project name by ID
  String _getProjectName(String projectId, List<Map<String, dynamic>> projects) {
    final project = projects.firstWhereOrNull((p) => p['id'] == projectId);
    return project?['name'] as String? ?? 'Unknown';
  }

  /// AI를 사용하여 task 정보를 생성합니다.
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
    // API 키가 제공되지 않으면 환경 변수에서 가져오기
    String? finalApiKey = apiKey;
    if (finalApiKey == null || finalApiKey.isEmpty) {
      final configFile = await rootBundle.loadString('assets/config/${F.envFileName}');
      final env = Environment.fromJson(json.decode(configFile) as Map<String, dynamic>);
      finalApiKey = openAiApiKey.isNotEmpty ? openAiApiKey : (env.openAiApiKey.isNotEmpty ? env.openAiApiKey : null);
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

      previousTaskInfo =
          '''
## Previous Task Entity (Base for Modifications)
The user wants to MODIFY this existing task. This task may have been shown in a previous message OR the user has tagged/mentioned this task in their current message (e.g., using @taskname or mentioning the task title). Use this task as the base and ONLY apply the changes requested by the user.

IMPORTANT: All dates and times are in LOCAL timezone (not UTC). Return dates in the same format (YYYY-MM-DDTHH:mm:ss without Z suffix).

Current Task Details:
- Title: ${previousTaskEntity.title}
- Description: ${previousTaskEntity.description ?? 'Not set'}
- Start Date/Time: ${formatLocalDateTime(previousTaskEntity.startAt)}
- End Date/Time: ${formatLocalDateTime(previousTaskEntity.endAt)}
- Is All Day: ${previousTaskEntity.isAllDay ?? false}
- Project ID: ${previousTaskEntity.projectId ?? 'Not set'}
- Current Project Name: $currentProjectName

CRITICAL: 
1. The user is requesting to MODIFY this task, not create a new one.
2. You MUST use the previous task entity as the base. Only modify the fields that the user explicitly requests to change.
3. If the user doesn't mention a field, keep it exactly as it is in the previous task entity.
4. When the user mentions the task title or tags the task (e.g., "@agentic home" or "agentic home"), they are referring to THIS task and want to modify it.
5. Parse the user's request carefully to understand what changes they want to make to THIS task.
''';
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
      suggestedTaskInfo =
          '''
## Suggested Task Information
The user has a suggested task with the following details:
- Title: ${suggestion.summary}
- Start Date/Time: ${suggestedStartAt ?? 'Not set'}
- End Date/Time: ${suggestedEndAt ?? 'Not set'}
- Is All Day: ${suggestion.is_date_only ?? false}
- Project ID: ${suggestion.project_id ?? 'Not set'}
- Duration: ${suggestion.duration ?? 'Not set'} minutes

IMPORTANT: If the user requests to create the task "as is", "as suggested", or similar phrases, you MUST use the suggested task's date/time information (start_at and isAllDay) instead of extracting new dates from the user request.
''';
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

    // Log the snippet being sent to AI
    print('=== AI Task Creation - Inbox Snippet ===');
    print('Title: $inboxTitle');
    print('Description/Snippet:');
    print(snippet);
    print('========================================');

    final prompt =
        '''
Please create a task based on the following inbox item and user request.

## Inbox Item Information
Title: $inboxTitle
Description:
$snippet

${previousTaskInfo ?? ''}
${suggestedTaskInfo ?? ''}
## Available Projects
You MUST select a project_id from this list. Match the user's request to one of these projects by name (case-insensitive, partial matching is OK).

${projects.map((p) => 'Project Name: "${p['name']}" | Project ID: "${p['id']}"${p['description'] != null ? ' | Description: "${p['description']}"' : ''}${p['parent_id'] != null ? ' | Parent ID: "${p['parent_id']}"' : ''}').join('\n')}

CRITICAL PROJECT SELECTION RULES:
1. When the user mentions a project name (e.g., "networking project", "marketing", "change project to X"), you MUST:
   - Search through the Available Projects list above
   - Find the project whose name best matches the user's request (case-insensitive, partial match is OK)
   - Return the EXACT project_id from the matching project
   - If no match is found, return null for project_id

2. Examples of matching:
   - User says "networking project" → Find project with name containing "networking" → Return its project_id
   - User says "marketing" → Find project with name containing "marketing" → Return its project_id
   - User says "change project to [project name]" → Find matching project → Return its project_id

3. The project_id MUST be one of the IDs listed in the Available Projects section above, or null if no match is found.

## Conversation History
$conversationText

## Current Date Information
- TODAY's date: $todayStr
- TOMORROW's date: $tomorrowStr
- Current time: ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}

## User Request
$userRequest

## Requirements
${previousTaskEntity != null ? '''- IMPORTANT: A previous task entity is provided above. Use it as the base and ONLY modify the fields that the user explicitly requests to change.
- If the user doesn't mention a field (title, description, date/time, project, etc.), keep it exactly as it is in the previous task entity.
- Only extract and apply the specific changes requested by the user.
- CRITICAL DATE EXTRACTION PRIORITY: When extracting dates/times, follow this priority order:
  1. FIRST: Check the Inbox Item Information (Description section above) for **actionable dates/times** that should be used for the task/event:
     - **Deadlines** (e.g., "Due date: 2024-01-20", "Deadline: tomorrow", "Submit by January 15th", "마감일: 2024-01-20")
     - **Meeting/Event times** (e.g., "Meeting on January 15th at 3pm", "회의 시간: 1월 15일 오후 3시")
     - **Schedule dates** (e.g., "Schedule for next Monday", "일정: 내일")
     - **Task completion dates** (e.g., "Complete by Friday", "완료 기한: 금요일")
     - **DO NOT** use reference dates that are just mentioned for context (e.g., "as of 2025-12-31", "2025-12-31 기준", "based on December 31st data" - these are just reference points, not deadlines)
  2. SECOND: Check the user's explicit request for dates/times
  3. THIRD: Use suggested task information if available
  4. LAST: Use default dates (today/tomorrow) only if no actionable dates are found in the inbox item or user request
- CRITICAL: Extract only **actionable dates** (deadlines, meeting times, schedules) from the inbox item's content. Ignore reference dates that are just mentioned for context (e.g., "as of", "기준", "based on"). If the inbox item contains an actionable date/time (e.g., "Due date: 2024-01-20", "Meeting on January 15th at 3pm", "Deadline: tomorrow"), you MUST extract and use that date/time from the inbox item's content. Do NOT ignore actionable dates mentioned in the inbox item.
- CRITICAL: If the user requests a date/time change (e.g., "tomorrow", "내일", "change date to X", "make it tomorrow", "I want to create task at tomorrow"), you MUST extract the new date and include it in start_at (LOCAL timezone format: YYYY-MM-DDTHH:mm:ss without Z suffix). Do NOT leave start_at as null or empty. Do NOT use the previous task's date.
- CRITICAL PROJECT SELECTION: If the user mentions a project name or requests a project change (e.g., "change project to X", "I want to change project to networking project", "set project to Y", "networking project"), you MUST:
  1. Look at the Available Projects section above
  2. Find the project whose name best matches the user's request (case-insensitive, partial matching is OK)
  3. Return the EXACT project_id from that project in your response
  4. If the user doesn't mention a project and you're modifying an existing task, keep the previous task's project_id unchanged
  5. If no matching project is found, return null for project_id
- CRITICAL DATE CALCULATION: 
  * TODAY's date is ${todayStr} (see Current Date Information above)
  * TOMORROW's date is ${tomorrowStr} (see Current Date Information above)
  * When the user says "tomorrow" or "내일", you MUST use TOMORROW's date (${tomorrowStr}), NOT today's date (${todayStr}), and NOT the previous task's date.
  * Example: If user says "tomorrow" or "I want to create task at tomorrow", set start_at to "${tomorrowStr}T00:00:00" (or the appropriate time based on previous task)
- For example:
  - If user says "change title to X", only change the title, keep everything else the same.
  - If user says "change project to networking project" or "I want to change project to X" or "set project to Y" or mentions any project name:
    * Look at the Available Projects section above
    * Find the project whose name matches the user's request (case-insensitive, partial match is OK)
    * Extract the EXACT project_id from that project (it's shown as "Project ID: [id]" in the list)
    * Set project_id in your response to that exact ID
    * Keep all other fields the same as the previous task
    * Example: If user says "networking project" and Available Projects shows "Project Name: 'Networking Project' | Project ID: 'abc-123'", then set project_id to "abc-123"
  - If user says "change date to tomorrow" or "I want to create task at tomorrow" or "make it tomorrow" or "내일로 바꿔줘":
    * Use TOMORROW's date: ${tomorrowStr} (NOT today: ${todayStr}, NOT previous task date)
    * Set start_at to "${tomorrowStr}T00:00:00" (or the appropriate time if previous task had a specific time)
    * Keep the same time as the previous task, or use 00:00:00 if the previous task was all-day
    * Calculate end_at based on the previous task's duration
  - If user says "as is" or "create as is", use the previous task entity exactly as is (all fields unchanged) - in this case, you can omit start_at from the response or set it to the previous task's start_at.''' : '''- Generate a task title and description based on the inbox item and user request.
- CRITICAL PROJECT SELECTION: Look at the Available Projects section above. If the user mentions a project name, find the matching project from the list and return its EXACT project_id. Match project names case-insensitively with partial matching. If no project is mentioned or no match is found, use null for project_id.
- CRITICAL DATE EXTRACTION PRIORITY: When extracting dates/times, follow this priority order:
  1. FIRST: Check the Inbox Item Information (Description section above) for **actionable dates/times** that should be used for the task/event:
     - **Deadlines** (e.g., "Due date: 2024-01-20", "Deadline: tomorrow", "Submit by January 15th", "마감일: 2024-01-20")
     - **Meeting/Event times** (e.g., "Meeting on January 15th at 3pm", "Event starts at 2:00 PM on Friday", "회의 시간: 1월 15일 오후 3시")
     - **Schedule dates** (e.g., "Schedule for next Monday", "일정: 내일")
     - **Task completion dates** (e.g., "Complete by Friday", "완료 기한: 금요일")
     - **DO NOT** use reference dates that are just mentioned for context (e.g., "as of 2025-12-31", "2025-12-31 기준", "based on December 31st data" - these are just reference points, not deadlines)
  2. SECOND: Check the user's explicit request for dates/times (e.g., "create task for tomorrow", "make it next Monday")
  3. THIRD: Use suggested task information if available
  4. LAST: Use default dates (today/tomorrow) only if no actionable dates are found in the inbox item or user request
- CRITICAL: Extract only **actionable dates** (deadlines, meeting times, schedules) from the inbox item's content. Ignore reference dates that are just mentioned for context (e.g., "as of", "기준", "based on"). Parse dates in various formats (e.g., "January 15th", "2024-01-15", "tomorrow", "next Monday", "3pm on Friday", etc.) and convert them to ISO 8601 format.
- If the user mentions a specific date or time, extract it and include it in start_at (ISO 8601 format).
- CRITICAL: If the user mentions a specific time (e.g., "9시", "9 o'clock", "9am", "오후 3시", "3pm"), you MUST include the time in start_at (format: YYYY-MM-DDTHH:mm:ss) and set isAllDay to false. If only a date is mentioned without time, you can set isAllDay to true or include 00:00:00 in start_at.
- ${suggestion != null ? 'If the user requests to create the task "as is", "as suggested", "create as suggested", or similar phrases, use the suggested task\'s start_at, end_at, and isAllDay values from the Suggested Task Information section above.' : ''}
- Keep the task title concise and action-oriented.
- The description should include relevant details from the inbox item.
- RECURRENCE (RRULE): If the user mentions recurring/repeating patterns (e.g., "every day", "weekly", "every Monday", "monthly", "repeat", "반복"), extract the recurrence rule and include it in rrule field as an RFC 5545 RRULE string.
  - Examples:
    * "every day" or "daily" → "FREQ=DAILY"
    * "every week" or "weekly" or "every Monday" → "FREQ=WEEKLY;BYDAY=MO"
    * "every month" or "monthly" → "FREQ=MONTHLY"
    * "every year" or "yearly" → "FREQ=YEARLY"
    * "every 2 weeks" → "FREQ=WEEKLY;INTERVAL=2"
    * "every Monday and Wednesday" → "FREQ=WEEKLY;BYDAY=MO,WE"
  - If the user mentions "until [date]" or "for [number] times", include UNTIL or COUNT in the rrule.
  - If no recurrence is mentioned, set rrule to null.'''}
- Determine if the user is confirming/approving the task creation (isConfirmed: true) or just requesting information/modification (isConfirmed: false).
  - CRITICAL RULE: If a previous task entity exists (you are modifying an existing task), isConfirmed MUST be false UNLESS the user explicitly confirms the final version WITHOUT requesting any further changes.
  - CRITICAL: Set isConfirmed to true ONLY if ALL of the following conditions are met:
    1. The user explicitly confirms, approves, or asks to create the task WITHOUT requesting any changes
    2. There is NO previous task entity, OR if there is a previous task entity, the user has seen the modified version and explicitly confirms it
    3. The user's message contains confirmation words/phrases AND does NOT contain any change requests
  - Examples of isConfirmed = true (ONLY when no changes are requested):
    * "yes", "ok", "create it", "go ahead", "confirm", "sounds good", "that's fine"
    * "create task as is", "create as is", "make it", "do it", "proceed", "let's do it"
    * "이대로 만들어줘", "이대로 생성해줘", "이대로 해줘", "확인", "좋아"
    * "create it as shown", "create this task", "go ahead and create"
  - CRITICAL: Set isConfirmed to false if ANY of the following is true:
    - A previous task entity exists AND the user is requesting ANY changes (e.g., "change date to tomorrow", "make it tomorrow", "change title to X", "modify the date", etc.)
    - The user is requesting ANY changes, even if they also say "create" or "make" (e.g., "create it tomorrow" → isConfirmed = false, "make it weekly" → isConfirmed = false)
    - The user is asking questions (e.g., "what's the date?", "can I change it?")
    - The user is providing feedback without explicit confirmation (e.g., "I prefer tomorrow", "that date doesn't work")
    - The user is making suggestions or corrections
  - MODIFICATION PROCESS RULE: If you are modifying a previous task entity:
    * ALWAYS set isConfirmed to false when applying changes
    * The user must see the modified task and explicitly confirm it separately
    * Even if the user says "create" or "make" while requesting changes, isConfirmed MUST be false
    * Only set isConfirmed to true when the user explicitly confirms the final modified version (e.g., "이대로 만들어줘", "create it as shown", "yes, create it")
- Generate a user-friendly message in HTML format that displays the task information in a structured way.
  - Always format the message using HTML with proper structure.
  - If isConfirmed is false and you need to display inbox item information, use the custom element format: <inapp_inbox>{JSON stringified inbox entity}</inapp_inbox>
  - If isConfirmed is false and you need to display task information, use the custom element format: <inapp_task>{JSON stringified task entity}</inapp_task>
  - The task entity JSON should include: id, title, description, project_id, start_at, end_at, rrule, and other relevant fields from the taskInfo object.
  - Example HTML structure for task proposal:
    <inapp_task>{"id": "task-id", "title": "Task title here", "description": "Task description here", "project_id": "project-id", "start_at": "2024-01-01T10:00:00", "rrule": "FREQ=WEEKLY;BYDAY=MO"}</inapp_task>
    <p>Please confirm if you'd like me to create this task, or let me know if you'd like to make any changes.</p>
  - If isConfirmed is true, use a simpler format indicating the task was created:
    <p>Task has been created successfully.</p>
    <inapp_task>{JSON stringified created task entity}</inapp_task>
  - Always wrap the entire message in HTML format, even for simple messages.
  - Use <br> tags for line breaks in descriptions to preserve formatting.

## Output Format
Return a JSON object with the following structure:
{
  "title": "Task title",
  "description": "Task description (can be null)",
  "project_id": "project-id-or-null",
  "start_at": "2024-01-01T10:00:00 or null",
  "rrule": "FREQ=WEEKLY;BYDAY=MO or null",
  "isConfirmed": true or false,
  "message": "<HTML formatted message>"
}

IMPORTANT: The start_at field must be in LOCAL timezone format (YYYY-MM-DDTHH:mm:ss) WITHOUT the Z suffix. Do NOT convert to UTC. Use the same timezone as the previous task entity or the user's local timezone.
For example: "2024-01-01T10:00:00" (local time) NOT "2024-01-01T10:00:00Z" (UTC).

Return only the JSON object, no additional text or explanations.
''';

    const endpoint = 'https://api.openai.com/v1/responses';

    final body = {
      'model': model,
      'store': false,
      'input': [
        {'role': 'user', 'content': prompt},
      ],
      "text": {
        "format": {
          "type": "json_schema",
          "name": "task_info",
          "schema": {
            "type": "object",
            "properties": {
              "title": {"type": "string"},
              "description": {
                "type": ["string", "null"],
              },
              "project_id": {
                "type": ["string", "null"],
              },
              "start_at": {
                "type": ["string", "null"],
              },
              "rrule": {
                "type": ["string", "null"],
              },
              "isConfirmed": {"type": "boolean"},
              "action_type_change": {
                "type": ["string", "null"],
                "enum": [null, "event"],
                "description": "Set to 'event' if user wants to switch from task to event, null otherwise",
              },
              "message": {"type": "string"},
            },
            "required": ["title", "description", "project_id", "start_at", "rrule", "isConfirmed", "action_type_change", "message"],
            "additionalProperties": false,
          },
          "strict": true,
        },
      },
    };

    try {
      final res = await http.post(Uri.parse(endpoint), headers: {'Authorization': 'Bearer $finalApiKey', 'Content-Type': 'application/json'}, body: jsonEncode(body));

      if (res.statusCode == 200) {
        final decoded = jsonDecode(utf8.decode(res.bodyBytes));

        // Check for errors
        if (decoded['error'] != null) {
          return null;
        }

        // Find the message output item and extract JSON
        Map<String, dynamic>? taskInfo;
        final outputList = decoded?['output'] as List<dynamic>?;

        if (outputList != null) {
          for (final outputItem in outputList) {
            if (outputItem is Map<String, dynamic> && outputItem['type'] == 'message') {
              final contentList = outputItem['content'] as List<dynamic>?;

              if (contentList != null) {
                for (final contentItem in contentList) {
                  if (contentItem is Map<String, dynamic> && contentItem['type'] == 'output_text') {
                    final text = contentItem['text'] as String?;

                    if (text != null) {
                      try {
                        taskInfo = jsonDecode(text.trim()) as Map<String, dynamic>;
                      } catch (e) {
                        // Try to extract JSON from text if it's wrapped
                        final jsonMatch = RegExp(r'\{[^{}]*(?:\{[^{}]*\}[^{}]*)*\}').firstMatch(text);
                        if (jsonMatch != null) {
                          try {
                            taskInfo = jsonDecode(jsonMatch.group(0)!) as Map<String, dynamic>;
                          } catch (e2) {
                            // Error parsing extracted JSON
                          }
                        }
                      }
                    }
                    break;
                  }
                }
              }
              if (taskInfo != null) break;
            }
          }
        }

        return taskInfo;
      }
    } catch (e) {
      // Return null on error
      return null;
    }

    return null;
  }

  /// AI를 사용하여 task 제안을 생성합니다.
  Future<Map<String, dynamic>?> generateSuggestedTask({required InboxEntity inbox, required List<Map<String, dynamic>> projects, required String model, String? apiKey}) async {
    // API 키가 제공되지 않으면 환경 변수에서 가져오기
    String? finalApiKey = apiKey;
    if (finalApiKey == null || finalApiKey.isEmpty) {
      final configFile = await rootBundle.loadString('assets/config/${F.envFileName}');
      final env = Environment.fromJson(json.decode(configFile) as Map<String, dynamic>);
      finalApiKey = openAiApiKey.isNotEmpty ? openAiApiKey : (env.openAiApiKey.isNotEmpty ? env.openAiApiKey : null);
    }

    final inboxTitle = inbox.title ?? '';
    final inboxDescription = inbox.description ?? '';
    final snippet = inboxDescription;

    final prompt =
        '''
Please suggest a task based on the following inbox item.

## Inbox Item Information
Title: $inboxTitle
Description:
$snippet

## Available Projects
${projects.map((p) => '- ${p['name']} (id: ${p['id']})${p['description'] != null ? ': ${p['description']}' : ''}${p['parent_id'] != null ? ' | parent_id: ${p['parent_id']}' : ''}').join('\n')}

## Requirements
- Generate a task title and description based on the inbox item.
- Select the most appropriate project ID from the available projects list, or use null if no project matches.
- Keep the task title concise and action-oriented.
- The description should include relevant details from the inbox item.

## Output Format
Return a JSON object with the following structure:
{
  "title": "Task title",
  "description": "Task description (can be null)",
  "project_id": "project-id-or-null"
}

Return only the JSON object, no additional text or explanations.
''';

    const endpoint = 'https://api.openai.com/v1/responses';

    final body = {
      'model': model,
      'store': false,
      'input': [
        {'role': 'user', 'content': prompt},
      ],
      "text": {
        "format": {
          "type": "json_schema",
          "name": "task_info",
          "schema": {
            "type": "object",
            "properties": {
              "title": {"type": "string"},
              "description": {
                "type": ["string", "null"],
              },
              "project_id": {
                "type": ["string", "null"],
              },
            },
            "required": ["title"],
            "additionalProperties": false,
          },
          "strict": true,
        },
      },
    };

    try {
      final res = await http.post(Uri.parse(endpoint), headers: {'Authorization': 'Bearer $finalApiKey', 'Content-Type': 'application/json'}, body: jsonEncode(body));

      if (res.statusCode == 200) {
        final decoded = jsonDecode(utf8.decode(res.bodyBytes));

        // Check for errors
        if (decoded['error'] != null) {
          return null;
        }

        // Find the message output item and extract JSON
        Map<String, dynamic>? taskInfo;
        final outputList = decoded?['output'] as List<dynamic>?;
        if (outputList != null) {
          for (final outputItem in outputList) {
            if (outputItem is Map<String, dynamic> && outputItem['type'] == 'message') {
              final contentList = outputItem['content'] as List<dynamic>?;
              if (contentList != null) {
                for (final contentItem in contentList) {
                  if (contentItem is Map<String, dynamic> && contentItem['type'] == 'output_text') {
                    final text = contentItem['text'] as String?;
                    if (text != null) {
                      try {
                        taskInfo = jsonDecode(text.trim()) as Map<String, dynamic>;
                      } catch (e) {
                        // Try to extract JSON from text if it's wrapped
                        final jsonMatch = RegExp(r'\{[^{}]*(?:\{[^{}]*\}[^{}]*)*\}').firstMatch(text);
                        if (jsonMatch != null) {
                          try {
                            taskInfo = jsonDecode(jsonMatch.group(0)!) as Map<String, dynamic>;
                          } catch (_) {}
                        }
                      }
                    }
                    break;
                  }
                }
              }
              if (taskInfo != null) break;
            }
          }
        }

        return taskInfo;
      }
    } catch (e) {
      // Return null on error
      return null;
    }

    return null;
  }

  /// AI를 사용하여 suggested event를 생성합니다.
  Future<Map<String, dynamic>?> generateSuggestedEvent({required InboxEntity inbox, required List<Map<String, dynamic>> calendars, required String model, String? apiKey}) async {
    // API 키가 제공되지 않으면 환경 변수에서 가져오기
    String? finalApiKey = apiKey;
    if (finalApiKey == null || finalApiKey.isEmpty) {
      final configFile = await rootBundle.loadString('assets/config/${F.envFileName}');
      final env = Environment.fromJson(json.decode(configFile) as Map<String, dynamic>);
      finalApiKey = openAiApiKey.isNotEmpty ? openAiApiKey : (env.openAiApiKey.isNotEmpty ? env.openAiApiKey : null);
    }

    final inboxTitle = inbox.title ?? '';
    final inboxDescription = inbox.description ?? '';
    final snippet = inboxDescription;

    // Get source host email from inbox
    final sourceHostEmail = inbox.linkedMail?.hostMail ?? inbox.linkedMessage?.teamId;
    final sourceFromName = inbox.linkedMail?.fromName ?? inbox.linkedMessage?.userName;

    final prompt =
        '''
Please suggest a calendar event based on the following inbox item.

## Inbox Item Information
Title: $inboxTitle
Description:
$snippet
${sourceHostEmail != null ? '\nSource Host Email: $sourceHostEmail' : ''}
${sourceFromName != null ? 'Source From Name: $sourceFromName' : ''}

## Available Calendars
You MUST select a calendar_id from this list. Use the following information to make an intelligent choice:
- Consider the source host email and context to infer the most appropriate calendar
- Prefer calendars that match the domain or context of the inbox item

${calendars.map((c) => 'Calendar Name: "${c['name']}" | Calendar ID: "${c['id']}"${c['email'] != null ? ' | Email: "${c['email']}"' : ''} | Modifiable: ${c['modifiable'] == true ? 'YES (can create events)' : 'NO (read-only, DO NOT SELECT)'}').join('\n')}

CRITICAL CALENDAR SELECTION RULES:
1. ABSOLUTE PRIORITY: You MUST ONLY select calendars where "Modifiable: YES". NEVER select a calendar marked "Modifiable: NO" as it will cause an error.

2. Intelligently select the most appropriate calendar based on:
   - FIRST: Filter to only calendars marked "Modifiable: YES"
   - Source host email matching calendar emails or domains
   - Context: work-related emails → work calendar, personal emails → personal calendar
   - Calendar names and their relevance to the source
3. The calendar_id MUST be one of the IDs listed in the Available Calendars section above AND must be modifiable.

## Conference Call Decision
You MUST decide whether to add a conference call link to this event. Consider the following:
- Add conference_link automatically if:
  * The event involves multiple attendees (2+ people mentioned in the inbox item)
  * The inbox item mentions "meeting", "call", "video", "zoom", "teams", "google meet", "conference", "화상", "회의", "통화"
  * The event title or description suggests a remote meeting or online interaction
- Set conference_link to "added" (a special value that indicates a conference link should be generated) if a conference call is appropriate
- Set conference_link to null if:
  * The event is clearly in-person (mentions physical location without remote option)
  * It's a personal reminder or task without attendees
  * There's no indication of a meeting or call

## Location Extraction
- Extract location information from the inbox item if mentioned (e.g., "at office", "in conference room", "서울시 강남구", "123 Main St", "Google Office")
- Look for location keywords: "at", "in", "location", "venue", "address", "장소", "위치", "주소"
- If a physical location is mentioned, extract it and include in the location field
- If no location is mentioned, set location to null

## Attendees Extraction
- Extract email addresses of people mentioned in the inbox item
- Look for email patterns (e.g., "john@example.com", "jane@company.com")
- Extract names and try to infer email addresses if the inbox item mentions people but not emails (use common patterns like "firstname.lastname@domain.com" or "firstname@domain.com" based on the source host email domain)
- If the inbox item mentions people to invite or attendees, include them in the attendees array
- Return attendees as an array of email address strings: ["john@example.com", "jane@example.com"]
- If no attendees are mentioned, return an empty array []

## Description Summarization
- Summarize the inbox item description into a concise event description
- Include only the most relevant and important information
- Remove unnecessary details, links, or promotional content
- Keep it clear and actionable
- If the inbox item description is very long, summarize it to 2-3 sentences maximum
- If the inbox item description is already concise, you can use it as-is or slightly refine it

## Requirements
- Generate an event title and description based on the inbox item (summarize description if needed).
- Select the most appropriate calendar ID from the available calendars list.
- Extract location from the inbox item if mentioned.
- Extract attendees (email addresses) from the inbox item if mentioned.
- Decide whether to add a conference call link based on the context above.
- Keep the event title concise and action-oriented.

## Output Format
Return a JSON object with the following structure:
{
  "title": "Event title",
  "description": "Summarized event description (can be null)",
  "calendar_id": "calendar-id",
  "location": "Location string or null",
  "attendees": ["email1@example.com", "email2@example.com"] or [],
  "conference_link": "added" or null
}

Return only the JSON object, no additional text or explanations.
''';

    const endpoint = 'https://api.openai.com/v1/responses';

    final body = {
      'model': model,
      'store': false,
      'input': [
        {'role': 'user', 'content': prompt},
      ],
      "text": {
        "format": {
          "type": "json_schema",
          "name": "event_info",
          "schema": {
            "type": "object",
            "properties": {
              "title": {"type": "string"},
              "description": {
                "type": ["string", "null"],
              },
              "calendar_id": {"type": "string"},
              "location": {
                "type": ["string", "null"],
              },
              "attendees": {
                "type": "array",
                "items": {"type": "string"},
              },
              "conference_link": {
                "type": ["string", "null"],
              },
            },
            "required": ["title", "calendar_id", "location", "attendees", "conference_link"],
            "additionalProperties": false,
          },
          "strict": true,
        },
      },
    };

    try {
      final res = await http.post(Uri.parse(endpoint), headers: {'Authorization': 'Bearer $finalApiKey', 'Content-Type': 'application/json'}, body: jsonEncode(body));

      if (res.statusCode == 200) {
        final decoded = jsonDecode(utf8.decode(res.bodyBytes));

        // Check for errors
        if (decoded['error'] != null) {
          return null;
        }

        // Find the message output item and extract JSON
        Map<String, dynamic>? eventInfo;
        final outputList = decoded?['output'] as List<dynamic>?;
        if (outputList != null) {
          for (final outputItem in outputList) {
            if (outputItem is Map<String, dynamic> && outputItem['type'] == 'message') {
              final contentList = outputItem['content'] as List<dynamic>?;
              if (contentList != null) {
                for (final contentItem in contentList) {
                  if (contentItem is Map<String, dynamic> && contentItem['type'] == 'output_text') {
                    final text = contentItem['text'] as String?;
                    if (text != null) {
                      try {
                        eventInfo = jsonDecode(text.trim()) as Map<String, dynamic>;
                      } catch (e) {
                        // Try to extract JSON from text if it's wrapped
                        final jsonMatch = RegExp(r'\{[^{}]*(?:\{[^{}]*\}[^{}]*)*\}').firstMatch(text);
                        if (jsonMatch != null) {
                          try {
                            eventInfo = jsonDecode(jsonMatch.group(0)!) as Map<String, dynamic>;
                          } catch (e2) {
                            // Failed to parse JSON
                          }
                        }
                      }
                      break;
                    }
                  }
                }
              }
              if (eventInfo != null) break;
            }
          }

          return eventInfo;
        }
      }
    } catch (e) {
      // Return null on error
      return null;
    }

    return null;
  }

  /// AI를 사용하여 event 정보를 생성합니다.
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
    // API 키가 제공되지 않으면 환경 변수에서 가져오기
    String? finalApiKey = apiKey;
    if (finalApiKey == null || finalApiKey.isEmpty) {
      final configFile = await rootBundle.loadString('assets/config/${F.envFileName}');
      final env = Environment.fromJson(json.decode(configFile) as Map<String, dynamic>);
      finalApiKey = openAiApiKey.isNotEmpty ? openAiApiKey : (env.openAiApiKey.isNotEmpty ? env.openAiApiKey : null);
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

      previousEventInfo =
          '''
## Previous Event Entity (Base for Modifications)
The user is modifying an event that was shown in the previous message. Use this as the base and ONLY apply the changes requested by the user.

IMPORTANT: All dates and times are in LOCAL timezone (not UTC). Return dates in the same format (YYYY-MM-DDTHH:mm:ss without Z suffix).

Current Event Details:
- Title: ${previousEventEntity.title}
- Description: ${previousEventEntity.description ?? 'Not set'}
- Start Date/Time: ${formatLocalDateTime(previousEventEntity.startDate)}
- End Date/Time: ${formatLocalDateTime(previousEventEntity.endDate)}
- Is All Day: ${previousEventEntity.isAllDay}
- Location: ${previousEventEntity.location ?? 'Not set'}
- Calendar Name: $currentCalendarName
- Calendar ID: ${previousEventEntity.calendar.uniqueId}
- Conference Link: ${previousEventEntity.conferenceLink ?? 'Not set'}

CRITICAL: You MUST use the previous event entity as the base. Only modify the fields that the user explicitly requests to change. If the user doesn't mention a field, keep it exactly as it is in the previous event entity.

ABSOLUTE RULE FOR CALENDAR_ID WHEN PREVIOUS EVENT EXISTS:
- If a previous event entity exists, you MUST use the previous event's calendar_id UNLESS the user explicitly requests to change the calendar.
- Examples of explicit calendar change requests: "change calendar to X", "use work calendar", "switch to personal calendar", "캘린더를 X로 바꿔줘"
- Examples of NO calendar change: "add video call", "add conference", "컨퍼런스콜 추가", "change title", "change date" → These do NOT mention calendar, so keep the previous calendar_id unchanged.
- DO NOT intelligently select a calendar when modifying an existing event unless the user explicitly requests it.

ABSOLUTE RULE FOR CONFERENCE_LINK WHEN PREVIOUS EVENT EXISTS:
- If a previous event entity exists, you MUST use the previous event's conference_link UNLESS the user explicitly requests to add or remove it.
- Examples of explicit conference_link change requests: "add video call", "add conference", "remove video call", "no conference", "화상 회의 추가", "비디오 콜 제거"
- Examples of NO conference_link change: "change title", "change date", "change calendar", "이대로 만들어줘" → These do NOT mention conference call, so keep the previous conference_link unchanged.
- DO NOT intelligently change conference_link when modifying an existing event unless the user explicitly requests it.
''';
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

      previousEventInfo =
          '''
## IMPORTANT: Converting Task to Event
The user is converting a previous task to an event. Use the task information below as the base for creating the event.

IMPORTANT: All dates and times are in LOCAL timezone (not UTC). Return dates in the same format (YYYY-MM-DDTHH:mm:ss without Z suffix).

Previous Task Details (to be converted to event):
- Title: ${previousTaskEntity.title}
- Description: ${previousTaskEntity.description ?? 'Not set'}
- Start Date/Time: ${formatLocalDateTime(previousTaskEntity.startAt)}
- End Date/Time: ${formatLocalDateTime(previousTaskEntity.endAt)}
- Is All Day: ${previousTaskEntity.isAllDay ?? false}
- Project ID: ${previousTaskEntity.projectId ?? 'Not set'}

CRITICAL: Convert the task information to event format. Use the title, description, dates, and other relevant information from the task. The user may request changes during conversion (e.g., calendar selection, location, attendees, conference link).
''';
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

    final prompt =
        '''
Please create a calendar event based on the following inbox item and user request.

## Inbox Item Information
Title: $inboxTitle
Description:
$snippet
${sourceHostEmail != null ? '\nSource Host Email: $sourceHostEmail' : ''}
${sourceFromName != null ? 'Source From Name: $sourceFromName' : ''}

${previousEventInfo ?? ''}
## Available Calendars
You MUST select a calendar_id from this list. Use the following information to make an intelligent choice:
- Match the user's explicit request if they mention a calendar name
- Consider the source host email and context to infer the most appropriate calendar
- Prefer calendars that match the domain or context of the inbox item

${calendars.map((c) => 'Calendar Name: "${c['name']}" | Calendar ID: "${c['id']}"${c['email'] != null ? ' | Email: "${c['email']}"' : ''} | Modifiable: ${c['modifiable'] == true ? 'YES (can create events)' : 'NO (read-only, DO NOT SELECT)'}').join('\n')}

CRITICAL CALENDAR SELECTION RULES:
1. ABSOLUTE PRIORITY: You MUST ONLY select calendars where "Modifiable: YES". NEVER select a calendar marked "Modifiable: NO" as it will cause an error.

2. If a previous event entity exists, you MUST use the previous event's calendar_id UNLESS the user explicitly requests to change the calendar.
   - If the user does NOT mention calendar at all, keep the previous calendar_id unchanged.
   - DO NOT intelligently select a calendar when modifying an existing event unless explicitly requested.
   - However, if the previous calendar is marked "Modifiable: NO", you MUST select a different modifiable calendar.

3. When the user explicitly mentions a calendar name (e.g., "work calendar", "personal", "change calendar to X"), you MUST:
   - Search through the Available Calendars list above
   - Find the calendar whose name best matches the user's request (case-insensitive, partial match is OK)
   - CRITICAL: Verify that the matching calendar has "Modifiable: YES" before selecting it
   - If the matching calendar is "Modifiable: NO", find the next best match that is modifiable
   - Return the EXACT calendar_id from a modifiable calendar

4. When the user does NOT mention a calendar name AND there is NO previous event entity, you MUST intelligently select the most appropriate calendar:
   - FIRST: Filter to only calendars marked "Modifiable: YES"
   - If source host email is available, try to match it with calendar emails or infer from the email domain
   - Consider the context: work-related emails → work calendar, personal emails → personal calendar
   - Look at calendar names and emails to find the best match among modifiable calendars
   - As a last resort, select the first modifiable calendar from the list

4. Examples of intelligent matching (ONLY when creating a NEW event, not modifying):
   - Work email (e.g., company.com domain) → Look for work-related calendar names or matching email domains
   - Personal email → Look for personal calendar names
   - Source host email matches a calendar email → Use that calendar
   - User says "work calendar" → Find calendar with name containing "work" → Return its calendar_id

5. The calendar_id MUST be one of the IDs listed in the Available Calendars section above.

## Conversation History
$conversationText

## Current Date Information
- TODAY's date: $todayStr
- TOMORROW's date: $tomorrowStr
- Current time: ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}

## User Request
$userRequest

## Requirements
${previousEventEntity != null ? '''- IMPORTANT: A previous event entity is provided above. Use it as the base and ONLY modify the fields that the user explicitly requests to change.
- If the user doesn't mention a field (title, description, date/time, calendar, location, etc.), keep it exactly as it is in the previous event entity.
- Only extract and apply the specific changes requested by the user.
- CRITICAL: If the user requests a date/time change (e.g., "tomorrow", "내일", "change date to X", "make it tomorrow"), you MUST extract the new date and include it in start_at (LOCAL timezone format: YYYY-MM-DDTHH:mm:ss without Z suffix). Do NOT leave start_at as null or empty. Do NOT use the previous event's date.
- CRITICAL CALENDAR SELECTION: 
  * ABSOLUTE RULE: If a previous event entity exists, you MUST use the previous event's calendar_id UNLESS the user explicitly requests to change the calendar.
  * If the user mentions a calendar name or requests a calendar change (e.g., "change calendar to X", "use work calendar", "캘린더를 X로 바꿔줘"), you MUST:
    1. Look at the Available Calendars section above
    2. Find the calendar whose name best matches the user's request (case-insensitive, partial matching is OK)
    3. Return the EXACT calendar_id from that calendar in your response
  * If the user does NOT mention calendar at all and you're modifying an existing event, you MUST keep the previous event's calendar_id unchanged.
  * Examples of requests that do NOT change calendar: "add video call", "add conference", "컨퍼런스콜 추가", "change title", "change date" → Keep previous calendar_id.
  * If no matching calendar is found when user explicitly requests a change, use the first calendar from the list as default
- CRITICAL DATE CALCULATION: 
  * TODAY's date is ${todayStr} (see Current Date Information above)
  * TOMORROW's date is ${tomorrowStr} (see Current Date Information above)
  * When the user says "tomorrow" or "내일", you MUST use TOMORROW's date (${tomorrowStr}), NOT today's date (${todayStr}), and NOT the previous event's date.
  * Example: If user says "tomorrow" or "I want to create event at tomorrow", set start_at to "${tomorrowStr}T00:00:00" (or the appropriate time based on previous event)
- For example:
  - If user says "change title to X", only change the title, keep everything else the same.
  - If user says "change calendar to work calendar" or mentions any calendar name:
    * Look at the Available Calendars section above
    * Find the calendar whose name matches the user's request (case-insensitive, partial match is OK)
    * Extract the EXACT calendar_id from that calendar (it's shown as "Calendar ID: [id]" in the list)
    * Set calendar_id in your response to that exact ID
    * Keep all other fields the same as the previous event
  - If user says "change date to tomorrow" or "I want to create event at tomorrow" or "make it tomorrow" or "내일로 바꿔줘":
    * Use TOMORROW's date: ${tomorrowStr} (NOT today: ${todayStr}, NOT previous event date)
    * Set start_at to "${tomorrowStr}T00:00:00" (or the appropriate time if previous event had a specific time)
    * Keep the same time as the previous event, or use 00:00:00 if the previous event was all-day
    * Calculate end_at based on the previous event's duration''' : '''- Generate an event title and description based on the inbox item and user request.
- CRITICAL CALENDAR SELECTION: Look at the Available Calendars section above. If the user mentions a calendar name, find the matching calendar from the list and return its EXACT calendar_id. Match calendar names case-insensitively with partial matching. If no calendar is mentioned or no match is found, use the first calendar from the list as default.
- If the user mentions a specific date or time, extract it and include it in start_at (ISO 8601 format).
- CRITICAL: If the user mentions a specific time (e.g., "9시", "9 o'clock", "9am", "오후 3시", "3pm", "내일 9시"), you MUST include the time in start_at (format: YYYY-MM-DDTHH:mm:ss) and set isAllDay to false. If only a date is mentioned without time, you can set isAllDay to true or include 00:00:00 in start_at.
- Keep the event title concise and action-oriented.
- The description should include relevant details from the inbox item.
- LOCATION: If the user mentions a location (e.g., "at office", "in conference room", "서울시 강남구"), extract it and include it in the location field. If no location is mentioned, set location to null.
- RECURRENCE (RRULE): If the user mentions recurring/repeating patterns (e.g., "every day", "weekly", "every Monday", "monthly", "repeat", "반복"), extract the recurrence rule and include it in rrule field as an RFC 5545 RRULE string.
  - Examples:
    * "every day" or "daily" → "FREQ=DAILY"
    * "every week" or "weekly" or "every Monday" → "FREQ=WEEKLY;BYDAY=MO"
    * "every month" or "monthly" → "FREQ=MONTHLY"
    * "every year" or "yearly" → "FREQ=YEARLY"
    * "every 2 weeks" → "FREQ=WEEKLY;INTERVAL=2"
    * "every Monday and Wednesday" → "FREQ=WEEKLY;BYDAY=MO,WE"
  - If the user mentions "until [date]" or "for [number] times", include UNTIL or COUNT in the rrule.
  - If no recurrence is mentioned, set rrule to null.
- ATTENDEES: If the user mentions people to invite (e.g., "invite john@example.com", "add attendees", "참석자 추가"), extract email addresses and include them in the attendees array.
  - Extract email addresses from the user's request (e.g., "john@example.com", "jane@example.com").
  - Return attendees as an array of email address strings: ["john@example.com", "jane@example.com"]
  - If no attendees are mentioned, return an empty array [].
- CONFERENCE CALL: Intelligently determine if a conference call/video meeting should be added to this event.
  - CRITICAL RULE: If a previous event entity exists (you are modifying an existing event), you MUST use the previous event's conference_link UNLESS the user explicitly requests to add or remove it.
    * If the user does NOT mention conference call at all, keep the previous conference_link unchanged.
    * DO NOT intelligently change conference_link when modifying an existing event unless explicitly requested.
  - CRITICAL: If the user explicitly requests to add a conference call/video meeting (e.g., "add video call", "add meeting link", "add zoom link", "add conference", "화상 회의 추가", "비디오 콜 추가"), you MUST set conference_link to "added".
  - When creating a NEW event (no previous event entity), add conference_link automatically if:
    * The event involves multiple attendees (2+ people)
    * The inbox item mentions "meeting", "call", "video", "zoom", "teams", "google meet", "conference", "화상", "회의", "통화"
    * The event title or description suggests a remote meeting
    * The user explicitly requests a video call or meeting link
  - Set conference_link to "added" (a special value that indicates a conference link should be generated) if a conference call is appropriate
  - Set conference_link to null if:
    * The event is clearly in-person (mentions physical location without remote option)
    * The user explicitly requests to remove conference call (e.g., "remove video call", "no conference", "remove meeting link", "화상 회의 제거", "비디오 콜 제거")
    * It's a personal event without attendees and user doesn't request it
  - Examples of user requests to ADD conference call:
    * "add video call" → set conference_link to "added"
    * "add meeting link" → set conference_link to "added"
    * "add zoom link" → set conference_link to "added"
    * "add conference" → set conference_link to "added"
    * "화상 회의 추가" → set conference_link to "added"
    * "비디오 콜 추가" → set conference_link to "added"
  - Examples of user requests to REMOVE conference call:
    * "remove video call" → set conference_link to null
    * "remove meeting link" → set conference_link to null
    * "no conference" → set conference_link to null
    * "화상 회의 제거" → set conference_link to null
    * "비디오 콜 제거" → set conference_link to null'''}
- ACTION TYPE CHANGE: Determine if the user wants to switch from creating an event to creating a task.
  - If the user explicitly or implicitly requests to convert the event to a task (e.g., "make it a task", "change to task", "할일로 바꿔줘", "task로 바꿔줘", "I want to make it a task instead of an event"), set action_type_change to "task".
  - Otherwise, set action_type_change to null.
  - Examples of switching to task:
    * "make it a task", "change to task", "switch to task", "convert to task"
    * "할일로 바꿔줘", "task로 바꿔줘", "태스크로 바꿔줘", "할일로 변경"
    * "I want to make it a task instead of an event"
  - Examples of NOT switching (action_type_change = null):
    * "change date to tomorrow", "modify title", "create event", "이대로 만들어줘"
    * Any request that modifies event properties without mentioning task conversion
- Determine if the user is confirming/approving the event creation (isConfirmed: true) or just requesting information/modification (isConfirmed: false).
  - CRITICAL RULE: If a previous event entity exists (you are modifying an existing event), isConfirmed MUST be false UNLESS the user explicitly confirms the final version WITHOUT requesting any further changes.
  - CRITICAL: Set isConfirmed to true ONLY if ALL of the following conditions are met:
    1. The user explicitly confirms, approves, or asks to create the event WITHOUT requesting any changes
    2. There is NO previous event entity, OR if there is a previous event entity, the user has seen the modified version and explicitly confirms it
    3. The user's message contains confirmation words/phrases AND does NOT contain any change requests
  - Examples of isConfirmed = true (ONLY when no changes are requested):
    * "yes", "ok", "create it", "go ahead", "confirm", "sounds good", "that's fine"
    * "create event as is", "create as is", "make it", "do it", "proceed", "let's do it"
    * "이대로 만들어줘", "이대로 생성해줘", "이대로 해줘", "확인", "좋아"
    * "create it as shown", "create this event", "go ahead and create"
  - CRITICAL: Set isConfirmed to false if ANY of the following is true:
    - A previous event entity exists AND the user is requesting ANY changes (e.g., "change date to tomorrow", "make it tomorrow", "change title to X", "modify the date", "add video call", "remove conference", etc.)
    - The user is requesting ANY changes, even if they also say "create" or "make" (e.g., "create it tomorrow" → isConfirmed = false, "make it with video call" → isConfirmed = false)
    - The user is asking questions (e.g., "what's the date?", "can I change it?")
    - The user is providing feedback without explicit confirmation (e.g., "I prefer tomorrow", "that date doesn't work")
    - The user is making suggestions or corrections
  - MODIFICATION PROCESS RULE: If you are modifying a previous event entity:
    * ALWAYS set isConfirmed to false when applying changes
    * The user must see the modified event and explicitly confirm it separately
    * Even if the user says "create" or "make" while requesting changes, isConfirmed MUST be false
    * Only set isConfirmed to true when the user explicitly confirms the final modified version (e.g., "이대로 만들어줘", "create it as shown", "yes, create it")
- Generate a user-friendly message in HTML format that displays the event information in a structured way.
  - Always format the message using HTML with proper structure.
  - If isConfirmed is false and you need to display inbox item information, use the custom element format: <inapp_inbox>{JSON stringified inbox entity}</inapp_inbox>
  - If isConfirmed is false and you need to display event information, use the custom element format: <inapp_event>{JSON stringified event entity}</inapp_event>
  - The event entity JSON should include: id, title, description, calendar_id, start_at, end_at, location, rrule, attendees, isAllDay, and other relevant fields from the eventInfo object.
  - Example HTML structure for event proposal:
    <inapp_event>{"id": "event-id", "title": "Event title here", "description": "Event description here", "calendar_id": "calendar-id", "start_at": "2024-01-01T10:00:00", "end_at": "2024-01-01T11:00:00", "location": "Location here", "rrule": "FREQ=WEEKLY;BYDAY=MO", "attendees": ["john@example.com"], "isAllDay": false}</inapp_event>
    <p>Please confirm if you'd like me to create this event, or let me know if you'd like to make any changes.</p>
  - If isConfirmed is true, use a simpler format indicating the event was created:
    <p>Event has been created successfully.</p>
    <inapp_event>{JSON stringified created event entity}</inapp_event>
  - Always wrap the entire message in HTML format, even for simple messages.
  - Use <br> tags for line breaks in descriptions to preserve formatting.

## Output Format
Return a JSON object with the following structure:
{
  "title": "Event title",
  "description": "Event description (can be null)",
  "calendar_id": "calendar-id",
  "start_at": "2024-01-01T10:00:00 or null",
  "end_at": "2024-01-01T11:00:00 or null",
  "location": "Location (can be null)",
  "rrule": "FREQ=WEEKLY;BYDAY=MO or null",
  "attendees": ["email1@example.com", "email2@example.com"] or [],
  "conference_link": "added" or null,
  "isAllDay": true or false,
  "isConfirmed": true or false,
  "message": "<HTML formatted message>"
}

IMPORTANT: The start_at and end_at fields must be in LOCAL timezone format (YYYY-MM-DDTHH:mm:ss) WITHOUT the Z suffix. Do NOT convert to UTC. Use the same timezone as the previous event entity or the user's local timezone.
For example: "2024-01-01T10:00:00" (local time) NOT "2024-01-01T10:00:00Z" (UTC).

Return only the JSON object, no additional text or explanations.
''';

    const endpoint = 'https://api.openai.com/v1/responses';

    final body = {
      'model': model,
      'store': false,
      'input': [
        {'role': 'user', 'content': prompt},
      ],
      "text": {
        "format": {
          "type": "json_schema",
          "name": "event_info",
          "schema": {
            "type": "object",
            "properties": {
              "title": {"type": "string"},
              "description": {
                "type": ["string", "null"],
              },
              "calendar_id": {"type": "string"},
              "start_at": {
                "type": ["string", "null"],
              },
              "end_at": {
                "type": ["string", "null"],
              },
              "location": {
                "type": ["string", "null"],
              },
              "rrule": {
                "type": ["string", "null"],
              },
              "attendees": {
                "type": "array",
                "items": {"type": "string"},
              },
              "conference_link": {
                "type": ["string", "null"],
              },
              "isAllDay": {"type": "boolean"},
              "isConfirmed": {"type": "boolean"},
              "action_type_change": {
                "type": ["string", "null"],
                "enum": [null, "task"],
                "description": "Set to 'task' if user wants to switch from event to task, null otherwise",
              },
              "message": {"type": "string"},
            },
            "required": [
              "title",
              "description",
              "calendar_id",
              "start_at",
              "end_at",
              "location",
              "rrule",
              "attendees",
              "conference_link",
              "isAllDay",
              "isConfirmed",
              "action_type_change",
              "message",
            ],
            "additionalProperties": false,
          },
          "strict": true,
        },
      },
    };

    try {
      final res = await http.post(Uri.parse(endpoint), headers: {'Authorization': 'Bearer $finalApiKey', 'Content-Type': 'application/json'}, body: jsonEncode(body));

      if (res.statusCode == 200) {
        final decoded = jsonDecode(utf8.decode(res.bodyBytes));

        // Check for errors
        if (decoded['error'] != null) {
          return null;
        }

        // Find the message output item and extract JSON
        Map<String, dynamic>? eventInfo;
        final outputList = decoded?['output'] as List<dynamic>?;

        if (outputList != null) {
          for (final outputItem in outputList) {
            if (outputItem is Map<String, dynamic> && outputItem['type'] == 'message') {
              final contentList = outputItem['content'] as List<dynamic>?;

              if (contentList != null) {
                for (final contentItem in contentList) {
                  if (contentItem is Map<String, dynamic> && contentItem['type'] == 'output_text') {
                    final text = contentItem['text'] as String?;

                    if (text != null) {
                      try {
                        eventInfo = jsonDecode(text.trim()) as Map<String, dynamic>;
                      } catch (e) {
                        // Try to extract JSON from text if it's wrapped
                        final jsonMatch = RegExp(r'\{[^{}]*(?:\{[^{}]*\}[^{}]*)*\}').firstMatch(text);
                        if (jsonMatch != null) {
                          try {
                            eventInfo = jsonDecode(jsonMatch.group(0)!) as Map<String, dynamic>;
                          } catch (e2) {
                            // Error parsing extracted JSON
                          }
                        }
                      }
                    }
                    break;
                  }
                }
              }
              if (eventInfo != null) break;
            }
          }
        }

        return eventInfo;
      }
    } catch (e) {
      // Return null on error
      return null;
    }

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
    try {
      // API 키가 제공되지 않으면 환경 변수에서 가져오기
      String? finalApiKey = apiKey;
      if (finalApiKey == null || finalApiKey.isEmpty) {
        final configFile = await rootBundle.loadString('assets/config/${F.envFileName}');
        final env = Environment.fromJson(json.decode(configFile) as Map<String, dynamic>);
        finalApiKey = openAiApiKey.isNotEmpty ? openAiApiKey : (env.openAiApiKey.isNotEmpty ? env.openAiApiKey : null);
      }

      // Build system message with project context and tagged context if available
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

      // Log inbox context if available
      if (inboxContext != null && inboxContext.isNotEmpty) {
        print('=== AI General Chat - Inbox Context ===');
        print(inboxContext);
        print('========================================');
      }

      systemMessage +=
          '''You are a helpful AI assistant integrated with Visir, a productivity app.

## Current Date Information
- TODAY's date: $todayStr
- TOMORROW's date: $tomorrowStr
- Current time: ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}

When calculating dates for repetitive tasks, use TODAY's date ($todayStr) as the starting point.

You can help users manage tasks, events, and emails by calling functions. When the user mentions actions like "toggle task status", "create task", "delete event", etc., you should call the appropriate function.

## Available Functions

You can call functions using this format:
<function_call name="functionName">
{
  "param1": "value1",
  "param2": "value2"
}
</function_call>

### Task Functions
- createTask: Create a new task
- updateTask: Update an existing task
- deleteTask: Delete a task
- toggleTaskStatus: Toggle task completion status

### Calendar Functions
- createEvent: Create a new calendar event
- updateEvent: Update an existing event
- deleteEvent: Delete an event
- responseCalendarInvitation: Respond to a calendar invitation

### Mail Functions
- sendMail: Send an email
- replyMail: Reply to an email
- forwardMail: Forward an email
- markMailAsRead: Mark email as read
- markMailAsUnread: Mark email as unread
- archiveMail: Archive an email
- deleteMail: Delete an email

### Search Functions
- searchInbox: Search for inbox items (emails and messages) by query. Use this when the user asks about specific emails or messages that are not in the current Inbox Context, or when you need to find inbox items that match certain criteria.
- searchTask: Search for tasks by query. Use this when the user asks about specific tasks that are not in the current context (tagged items or project context), or when you need to find tasks matching certain criteria.
- searchCalendarEvent: Search for calendar events by query. Use this when the user asks about specific events that are not in the current context, or when you need to find events matching certain criteria.

**IMPORTANT**: Before calling search functions, first check if the requested items are already available in the provided context (Inbox Context, Tagged Items, Project Context). Only use search functions when:
1. The user explicitly asks to search for something
2. The requested item is not found in the current context
3. You need to find items that match specific criteria that aren't in the current context

After calling a search function, the search results will be automatically added to the context for subsequent function calls and responses. If you need to read the full content of searched inbox items or need more information to complete the user's request, use the <need_more_action> tag to request additional content. Do NOT automatically re-request - only request more content if you actually need it to answer the user's question.

## Multiple Function Calls and Function Chaining

When a user requests multiple actions or complex workflows, you MUST call multiple functions in sequence (function chaining). Functions are executed sequentially, and the results of earlier functions are automatically available to later functions.

### Function Chaining Rules

1. **Automatic Result Propagation**: When you call multiple functions, the results from earlier functions are automatically added to the context for later functions:
   - `searchInbox` results → automatically available for `replyMail`, `forwardMail`, `markMailAsRead`, etc.
   - `searchTask` results → automatically available for `updateTask`, `deleteTask`, `toggleTaskStatus`, etc.
   - `searchCalendarEvent` results → automatically available for `updateEvent`, `deleteEvent`, `responseCalendarInvitation`, etc.

2. **Chain Multiple Functions**: When a user request requires multiple steps, call all necessary functions in a single response:
   - Example: "우리카드에서 온 메일 찾아서 답장해줘" → Call `searchInbox` first, then `replyMail` using the search results
   - Example: "내일 회의 일정 찾아서 삭제해줘" → Call `searchCalendarEvent` first, then `deleteEvent` using the search results
   - Example: "프로젝트 관련 작업 찾아서 완료 처리해줘" → Call `searchTask` first, then `toggleTaskStatus` using the search results

3. **Use Array Format**: For multiple function calls, use an array format:

```json
[
  {"function": "searchInbox", "arguments": {"query": "우리카드"}},
  {"function": "replyMail", "arguments": {"threadId": "{{result from searchInbox}}", "body": "답장 내용"}}
]
```

**IMPORTANT**: When chaining functions:
- Call search functions first if you need to find items
- Use the results from search functions in subsequent function calls
- The system automatically matches search results to function parameters (e.g., inbox search results → threadId for replyMail)
- If a search function returns multiple results, use the first matching result unless the user specifies otherwise

### Simple Multiple Function Calls

For repetitive tasks or independent actions, call multiple functions:

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

## User Confirmation for Critical Actions

Certain functions require user confirmation before execution because they modify data or send information. These functions include:
- **Mail actions**: `sendMail`, `replyMail`, `forwardMail`
- **Delete actions**: `deleteTask`, `deleteEvent`, `deleteMail`
- **Update actions**: `updateTask`, `updateEvent`
- **Status changes**: `markMailAsRead`, `markMailAsUnread`, `archiveMail`, `responseCalendarInvitation`
- **Create actions**: `createTask`, `createEvent`

**IMPORTANT**: When you call these functions, the system will automatically:
1. Display a confirmation UI in the chat with the action details
2. Wait for user confirmation before executing the function
3. Show the confirmation UI using the `<inapp_action_confirm>` tag format

**You do NOT need to manually add the `<inapp_action_confirm>` tag** - the system automatically handles this. Just call the function normally using the function_call format, and the system will display the confirmation UI.

**Example**: If you call `replyMail`, the system will automatically show a confirmation UI with:
- The email subject
- Recipients (To, CC, BCC)
- Reply content preview
- A confirm button

The user can then click the confirm button or press Command+Enter (Mac) / Ctrl+Enter (Windows/Linux) to execute the action.

## Important Rules
1. When a user mentions a task/event without specifying an ID, use the tagged items from the context below.
2. If multiple tasks/events are tagged, use the first one unless the user specifies which one.
3. Always use the exact function names and parameter names as specified.
4. **CRITICAL**: If you need to call a function, ALWAYS use the function_call format with "function" and "arguments" keys. DO NOT return raw task/event JSON objects.
5. **CRITICAL**: When a user request requires multiple steps (e.g., "찾아서", "검색해서", "~한 다음"), you MUST call multiple functions in sequence. Do NOT ask the user to do it manually - call all necessary functions automatically.
6. If you need to call multiple functions, use the array format shown above with function calls.
7. For repetitive tasks, calculate dates correctly and create separate function calls for each occurrence.
8. **Function Chaining**: When chaining functions (e.g., search → action), call all functions in a single response. The system will execute them sequentially and automatically pass results between functions.
9. **User Confirmation**: Functions that require confirmation will automatically show a confirmation UI. You don't need to ask the user separately - just call the function and the system will handle the confirmation flow.
10. **Parallel Execution and Dependency Analysis**: When calling multiple functions, analyze dependencies and mark functions that can run in parallel:
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
11. If you're just having a conversation without needing to call a function, respond normally without function_call blocks.

## Task Entity Schema

When calling `createTask` or `updateTask`, you MUST use the following field names and formats:

**CRITICAL FIELD NAMING**: Use camelCase field names (NOT snake_case):
- ✅ `startAt` (NOT `start_at`)
- ✅ `endAt` (NOT `end_at`)
- ✅ `projectId` (NOT `project_id`)
- ✅ `isAllDay` (NOT `is_all_day`)
- ✅ `actionNeeded` (NOT `action_needed`)

**CRITICAL DATE EXTRACTION**: When creating tasks from inbox items:
- **ALWAYS check the inbox item's description/content FIRST** for **actionable dates/times** (deadlines, meeting times, schedules) before using default dates
- **MULTIPLE DEADLINES**: If the inbox item contains MULTIPLE deadlines (e.g., "2026년 1월 6일까지 제출", "2026년 1월 15일까지 제출", "2026년 1월 29일까지 제출"), you MUST create SEPARATE tasks for EACH deadline:
  - Each deadline should have its own task with a distinct title describing what needs to be submitted by that deadline
  - Extract the specific materials/documents mentioned for each deadline
  - Use the exact deadline date for each task's `startAt` and `endAt`
  - Example: If the inbox says "주주명부는 1월 6일까지, 재무제표는 1월 29일까지", create TWO separate tasks:
    1. Task 1: Title about 주주명부, deadline: 2026-01-06
    2. Task 2: Title about 재무제표, deadline: 2026-01-29
- Extract **actionable dates** from the inbox item content:
  - **Deadlines**: "Due date: 2024-01-20", "Deadline: tomorrow", "Submit by January 15th", "마감일: 2024-01-20", "제출 기한: 내일", "2026년 1월 6일(화)까지", "2026년 1월 15일(목)까지", "2026년 1월 29일(목)까지"
  - **Meeting/Event times**: "Meeting on January 15th at 3pm", "회의 시간: 1월 15일 오후 3시"
  - **Schedule dates**: "Schedule for next Monday", "일정: 내일"
  - **Task completion dates**: "Complete by Friday", "완료 기한: 금요일"
- **DO NOT** use reference dates that are just mentioned for context:
  - "as of 2025-12-31", "2025-12-31 기준", "based on December 31st data" - these are reference points, not deadlines
  - "2025-12-31 기준 주주명부" - this is a reference date for the document, not a task deadline
  - Look for keywords like "기준", "as of", "based on" to identify reference dates vs actionable dates
- If the inbox item mentions an **actionable date/time**, use that date/time instead of defaulting to today or tomorrow
- Only use default dates (today/tomorrow) if NO actionable dates are found in the inbox item's content

**Task Entity Fields**:
- `title` (string, required): Task title
- `description` (string, optional): Task description
- `projectId` (string, optional): Project ID
- `startAt` (string, optional): Start date/time in ISO 8601 format: "YYYY-MM-DDTHH:mm:ss" (e.g., "2024-01-01T09:00:00"). **CRITICAL**: Extract this from **actionable dates** (deadlines, meeting times, schedules) in the inbox item's content if available, otherwise use user request or default dates. Do NOT use reference dates.
- `endAt` (string, optional): End date/time in ISO 8601 format: "YYYY-MM-DDTHH:mm:ss" (e.g., "2024-01-01T10:00:00"). **CRITICAL**: Extract this from **actionable dates** in the inbox item's content if available, otherwise calculate based on startAt.
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

**CRITICAL DATE EXTRACTION**: When creating events from inbox items:
- **ALWAYS check the inbox item's description/content FIRST** for **actionable dates/times** (deadlines, meeting times, schedules) before using default dates
- **MULTIPLE DEADLINES**: If the inbox item contains MULTIPLE deadlines or event times, you MUST create SEPARATE events for EACH deadline/time:
  - Each deadline should have its own event with a distinct title describing what needs to be done by that deadline
  - Extract the specific materials/documents mentioned for each deadline
  - Use the exact deadline date for each event's `startAt` and `endAt`
- Extract **actionable dates** from the inbox item content:
  - **Deadlines**: "Due date: 2024-01-20", "Deadline: tomorrow", "Submit by January 15th", "마감일: 2024-01-20", "제출 기한: 내일", "2026년 1월 6일(화)까지", "2026년 1월 15일(목)까지", "2026년 1월 29일(목)까지"
  - **Meeting/Event times**: "Meeting on January 15th at 3pm", "Event starts at 2:00 PM on Friday", "회의 시간: 1월 15일 오후 3시"
  - **Schedule dates**: "Schedule for next Monday", "일정: 내일"
  - **Task completion dates**: "Complete by Friday", "완료 기한: 금요일"
- **DO NOT** use reference dates that are just mentioned for context:
  - "as of 2025-12-31", "2025-12-31 기준", "based on December 31st data" - these are reference points, not deadlines
  - "2025-12-31 기준 주주명부" - this is a reference date for the document, not an event time
  - Look for keywords like "기준", "as of", "based on" to identify reference dates vs actionable dates
- If the inbox item mentions an **actionable date/time**, use that date/time instead of defaulting to today or tomorrow
- Only use default dates (today/tomorrow) if NO actionable dates are found in the inbox item's content

**Event Entity Fields**:
- `title` (string, required): Event title
- `description` (string, optional): Event description
- `calendarId` (string, optional): Calendar ID
- `startAt` (string, optional): Start date/time in ISO 8601 format: "YYYY-MM-DDTHH:mm:ss" (e.g., "2024-01-01T09:00:00"). **CRITICAL**: Extract this from **actionable dates** (deadlines, meeting times, schedules) in the inbox item's content if available, otherwise use user request or default dates. Do NOT use reference dates.
- `endAt` (string, optional): End date/time in ISO 8601 format: "YYYY-MM-DDTHH:mm:ss" (e.g., "2024-01-01T10:00:00"). **CRITICAL**: Extract this from **actionable dates** in the inbox item's content if available, otherwise calculate based on startAt.
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
<inapp_task>{"id": "task-id", "title": "Task title", "description": "Task description", "project_id": "project-id", "start_at": "2024-01-01T10:00:00", "end_at": "2024-01-01T11:00:00", "rrule": "FREQ=WEEKLY;BYDAY=MO", "status": "none"}</inapp_task>
```

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

### Examples

**Example 1: Displaying search results**
User: "우리카드에서 온 메일 찾아줘"
Response:
```html
<p>우리카드에서 온 메일을 찾았습니다:</p>
<inapp_mail_entity>{"id": "mail-1", "threadId": "thread-1", "subject": "우리카드 알림", "snippet": "결제 내역을 확인하세요", "from": {"name": "우리카드", "email": "noreply@wooricard.com"}, "date": "2024-01-01T10:00:00Z"}</inapp_mail_entity>
```

**Example 2: Displaying task information**
User: "오늘 할 일 보여줘"
Response:
```html
<p>오늘 할 일 목록입니다:</p>
<inapp_task>{"id": "task-1", "title": "회의 준비", "description": "프로젝트 회의 자료 준비", "start_at": "2024-01-01T09:00:00", "end_at": "2024-01-01T10:00:00", "status": "none"}</inapp_task>
<inapp_task>{"id": "task-2", "title": "문서 작성", "description": "월간 보고서 작성", "start_at": "2024-01-01T14:00:00", "end_at": "2024-01-01T16:00:00", "status": "none"}</inapp_task>
```

**Example 3: Displaying event information**
User: "이번 주 일정 알려줘"
Response:
```html
<p>이번 주 일정입니다:</p>
<inapp_event_entity>{"id": "event-1", "title": "팀 미팅", "description": "주간 팀 미팅", "start_at": "2024-01-01T10:00:00", "end_at": "2024-01-01T11:00:00", "location": "회의실 A", "isAllDay": false}</inapp_event_entity>
```

**IMPORTANT**: 
- Always include the JSON data inside the tags as a single-line string (no line breaks in JSON)
- Use the appropriate tag for each entity type
- You can combine these tags with regular HTML/text in your response
- These tags work in both HTML and Markdown responses''';

      if (projectContext != null && projectContext.isNotEmpty) {
        systemMessage +=
            '\n\n## CRITICAL: Project Context Available\nYou have access to detailed project information including raw task data in JSON format in the Project Context section below.';
        systemMessage += '\n\n## Project Context\n$projectContext';
        systemMessage +=
            '\n\n## MANDATORY: Project-Related Questions & AI Analysis\nWhen the user asks ANY question about the project (e.g., "어떤 작업을 하고 있어?", "what work is being done?", "어떤 일이 진행되고 있어?", "프로젝트 요약", "project summary", "이 프로젝트에서 요즘 어떤 작업을 하고 있어?", "이 프로젝트 요약해줘"), you MUST:\n\n1. **ALWAYS use the Project Context above** - The Project Context contains raw task data in JSON format. Parse the JSON array and analyze the tasks. Do NOT say "I cannot access" or "I don\'t have information". You have all the information in the Project Context.\n\n2. **AI-Powered Analysis (No Rule-Based Filtering)**:\n   - Parse the JSON task data provided in the Project Context\n   - Filter out irrelevant tasks yourself (e.g., isEventDummyTask: true, isOriginalRecurrenceTask: true)\n   - Calculate statistics yourself (total tasks, completed tasks, in-progress tasks)\n   - Analyze task patterns, trends, and insights\n   - Identify important deadlines and upcoming items\n   - Group tasks by status, project, or other meaningful categories\n\n3. **MANDATORY: Use actual task data** - Reference specific tasks from the parsed JSON data. Quote actual task titles, mention their statuses (done/none/cancelled), and reference their dates. Do NOT provide generic descriptions. IMPORTANT: Only use tasks that belong to the Current Project or its subprojects as specified in the Project Context. Check the projectName field in each task JSON object - if it does not match the Current Project or listed subprojects, exclude it from your response.\n\n4. **DO NOT mention project name or ID** - Skip any mention of "Current Project: X", project name, project ID, or project description.\n\n5. **DO NOT make up generic information** - Do NOT say things like "팀원들이 작업을 업데이트하고 있습니다" or "일정 조정을 진행하고 있습니다" unless these are explicitly mentioned in the actual task titles or descriptions. Only use information from the actual tasks in the JSON data.\n\n6. **Required Response Structure**:\n   - Parse and analyze the JSON task data\n   - Calculate and present Task Statistics (total, completed, in-progress)\n   - List specific tasks that are done (with their actual titles from JSON)\n   - List specific tasks that are in progress/pending (with their actual titles from JSON)\n   - Mention specific upcoming deadlines from task dates in JSON\n   - Reference actual task descriptions if they provide insights\n   - Provide AI-generated insights and patterns\n\n7. **Example of good response**:\n   "현재 총 15개의 작업이 있으며, 그 중 5개가 완료되었고 10개가 진행 중입니다. 완료된 작업으로는 [실제 태스크 제목 1], [실제 태스크 제목 2] 등이 있습니다. 진행 중인 주요 작업으로는 [실제 태스크 제목 3] (마감일: [실제 날짜]), [실제 태스크 제목 4] 등이 있습니다."\n\n8. **Example of bad response (DO NOT DO THIS)**:\n   "프로젝트 정보를 직접 확인할 수 없어요" or "프로젝트는 효과적인 일정 관리를 목표로 합니다. 팀원들이 작업을 업데이트하고 있습니다." - These are wrong. Parse and use the JSON data.\n\nABSOLUTE RULE: If Project Context is provided, you MUST parse the JSON task data, perform AI analysis (filtering, statistics, insights), and use it to answer project-related questions. Never say you cannot access the information.';
      }

      if (taggedContext != null && taggedContext.isNotEmpty) {
        systemMessage += '\n\n## Tagged Items (Available for Function Calls)\n$taggedContext';
        systemMessage += '\n\nWhen calling functions that require taskId or eventId, use the IDs from the tagged items above if the user doesn\'t specify one.';
      }

      if (channelContext != null && channelContext.isNotEmpty) {
        systemMessage += '\n\n## Channel Messages Context\n$channelContext';
        systemMessage +=
            '\n\nWhen the user asks about a channel or requests a channel summary, use the channel messages above. The messages are from the last 3 days. Analyze and summarize the conversation based on the actual messages provided.';
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
      final messages = <Map<String, dynamic>>[
        {'role': 'system', 'content': systemMessage},
        ...conversationHistory.map((m) => {'role': m['role'], 'content': m['content']}),
      ];

      // Call OpenAI API
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $finalApiKey'},
        body: jsonEncode({'model': model, 'messages': messages, 'temperature': 0.7}),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(utf8.decode(response.bodyBytes));
        final content = decoded['choices']?[0]?['message']?['content'] as String?;

        if (content != null) {
          final result = <String, dynamic>{'message': content};

          // Extract token usage information
          final usage = decoded['usage'] as Map<String, dynamic>?;
          if (usage != null) {
            result['_token_usage'] = {
              'prompt_tokens': usage['prompt_tokens'] ?? 0,
              'completion_tokens': usage['completion_tokens'] ?? 0,
              'total_tokens': usage['total_tokens'] ?? 0,
            };
          }

          return result;
        }
      }
    } catch (e) {
      // Ignore exceptions
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
    try {
      // API 키가 제공되지 않으면 환경 변수에서 가져오기
      String? finalApiKey = apiKey;
      if (finalApiKey == null || finalApiKey.isEmpty) {
        final configFile = await rootBundle.loadString('assets/config/${F.envFileName}');
        final env = Environment.fromJson(json.decode(configFile) as Map<String, dynamic>);
        finalApiKey = openAiApiKey.isNotEmpty ? openAiApiKey : (env.openAiApiKey.isNotEmpty ? env.openAiApiKey : null);
      }

      // Build recipients info
      final toInfo = toRecipients.map((r) => '${r['name'] ?? ''} ${r['email'] ?? ''}'.trim()).join(', ');
      final ccInfo = ccRecipients.isNotEmpty ? ccRecipients.map((r) => '${r['name'] ?? ''} ${r['email'] ?? ''}'.trim()).join(', ') : null;
      final bccInfo = bccRecipients.isNotEmpty ? bccRecipients.map((r) => '${r['name'] ?? ''} ${r['email'] ?? ''}'.trim()).join(', ') : null;

      String prompt;
      if (previousSubject != null && previousSubject.isNotEmpty && previousBody != null && previousBody.isNotEmpty) {
        // User wants to modify existing email
        prompt =
            '''
You are helping to modify a suggested email based on user feedback.

## Previous Email
Subject: $previousSubject
Body:
$previousBody

## Recipients
To: $toInfo
${ccInfo != null ? 'CC: $ccInfo' : ''}
${bccInfo != null ? 'BCC: $bccInfo' : ''}

## User's Request
$userRequest

## Your Task
Modify the email subject, body, and recipients based on the user's request. Return a JSON object with:
- "subject": The modified email subject (string)
- "body": The modified email body (string)
- "to": List of recipient objects with updated names if requested [{"email": "email@example.com", "name": "Updated Name"}]
- "cc": List of CC recipient objects with updated names if requested [{"email": "email@example.com", "name": "Updated Name"}]
- "bcc": List of BCC recipient objects with updated names if requested [{"email": "email@example.com", "name": "Updated Name"}]

If the user requests changes to recipient names (e.g., "put Sungho in recipient's name"), update the "name" field for the appropriate recipients while keeping the email addresses unchanged.

Return only valid JSON, no additional text.
''';
      } else {
        // Generate new email from user request
        prompt =
            '''
You are helping to compose an email based on the user's request.

## User's Request
$userRequest

## Recipients
To: $toInfo
${ccInfo != null ? 'CC: $ccInfo' : ''}
${bccInfo != null ? 'BCC: $bccInfo' : ''}

## Conversation History
${conversationHistory.map((m) => '${m['role']}: ${m['content']}').join('\n')}

## Your Task
Generate an appropriate email subject, body, and recipients based on the user's request and conversation context. Return a JSON object with:
- "subject": A clear, concise email subject (string)
- "body": A professional email body that addresses the user's request (string)
- "to": List of recipient objects with updated names if requested [{"email": "email@example.com", "name": "Updated Name"}]
- "cc": List of CC recipient objects with updated names if requested [{"email": "email@example.com", "name": "Updated Name"}]
- "bcc": List of BCC recipient objects with updated names if requested [{"email": "email@example.com", "name": "Updated Name"}]

Guidelines:
- Make the subject clear and specific
- Write a professional, friendly email body
- Address the user's intent from their request
- Keep it concise but complete
- If the user requests changes to recipient names (e.g., "put Sungho in recipient's name"), update the "name" field for the appropriate recipients while keeping the email addresses unchanged

Return only valid JSON, no additional text.
''';
      }

      // Call OpenAI API
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $finalApiKey'},
        body: jsonEncode({
          'model': model,
          'messages': [
            {'role': 'user', 'content': prompt},
          ],
          'temperature': 0.7,
          'response_format': {'type': 'json_object'},
        }),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(utf8.decode(response.bodyBytes));
        final content = decoded['choices']?[0]?['message']?['content'] as String?;

        if (content != null) {
          try {
            final result = jsonDecode(content) as Map<String, dynamic>;
            return {
              'subject': result['subject'] as String? ?? '',
              'body': result['body'] as String? ?? '',
              'to': result['to'] as List?,
              'cc': result['cc'] as List?,
              'bcc': result['bcc'] as List?,
            };
          } catch (e) {
            // Failed to parse JSON, return null
          }
        }
      }
    } catch (e) {
      // Return null on error
    }

    return null;
  }
}
