import 'dart:convert';

import 'package:Visir/config/providers.dart';
import 'package:pdfx/pdfx.dart';
import 'package:Visir/features/calendar/domain/entities/calendar_entity.dart';
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
import 'package:timezone/timezone.dart' as tz;

class OpenAiInboxDatasource extends InboxDatasource {
  @override
  Future<List<InboxSuggestionEntity>> fetchInboxSuggestions({required List<InboxEntity> inboxes, required List<ProjectEntity> projects, String? model, String? apiKey}) async {
    // API 키가 제공되지 않으면 전역 변수에서 가져오기
    String? finalApiKey = apiKey;
    if (finalApiKey == null || finalApiKey.isEmpty) {
      // 전역 변수에서 가져오기 (Edge Function에서 업데이트됨), 없으면 null
      finalApiKey = openAiApiKey.isNotEmpty ? openAiApiKey : null;
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
	•	**MANDATORY: project_id MUST ALWAYS be included** - You MUST always provide a project_id in your response. project_id cannot be null.
	•	Select the most relevant project ID from the list below based on the item content and project name/description.
	•	Consider the project hierarchy (parent_id) to understand the context.
	•	If the item does not clearly belong to any project, select the first project from the Available Projects list.
	•	Available Projects: ${jsonEncode(projects.map((e) => {'id': e.uniqueId, 'name': e.name, 'description': e.description, 'parent_id': e.parentId}).toList())}
	•	**CRITICAL: project_id is REQUIRED and MUST always be included. It cannot be null. If you cannot determine which project to use, select the first project from the Available Projects list.**

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
    List<TaskEntity>? taskEntities,
    String? model,
    String? apiKey,
  }) async {
    final modelName = model ?? 'gpt-5-mini';
    // API 키가 제공되지 않으면 전역 변수에서 가져오기 (Edge Function에서 업데이트됨)
    String? finalApiKey = apiKey;
    if (finalApiKey == null || finalApiKey.isEmpty) {
      finalApiKey = openAiApiKey.isNotEmpty ? openAiApiKey : null;
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

    // Check if virtual inbox (no linkedMail/linkedMessage and no conversation content)
    final hasVirtualInbox = inbox.linkedMail == null && inbox.linkedMessage == null && allInboxes.isEmpty;
    final hasOnlyEvents = hasVirtualInbox && (eventSnippet != null && eventSnippet.isNotEmpty);

    // Extract current task/event description if available - always include if present
    final currentTaskEventDescription = inbox.description != null && inbox.description!.isNotEmpty ? inbox.description : null;

    // If no conversation content and no events and no tasks, return null
    if (conversationSnippet.isEmpty && (eventSnippet == null || eventSnippet.isEmpty) && (taskSnippet == null || taskSnippet.isEmpty) && currentTaskEventDescription == null)
      return null;

    final descriptionPrompt = OpenAiInboxPrompts.buildDescriptionPrompt(currentTaskEventDescription: currentTaskEventDescription);

    final prompt = OpenAiInboxPrompts.buildConversationSnippetPrompt(
      hasOnlyEvents: hasOnlyEvents,
      eventSnippet: eventSnippet,
      taskSnippet: taskSnippet,
      descriptionPrompt: descriptionPrompt,
      conversationSnippet: conversationSnippet,
      currentTaskEventDescription: currentTaskEventDescription,
    );

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
    // API 키가 제공되지 않으면 전역 변수에서 가져오기 (Edge Function에서 업데이트됨)
    String? finalApiKey = apiKey;
    if (finalApiKey == null || finalApiKey.isEmpty) {
      finalApiKey = openAiApiKey.isNotEmpty ? openAiApiKey : null;
    }

    final taskInfo = [
      if (taskTitle.isNotEmpty) 'Title: $taskTitle',
      if (taskDescription != null && taskDescription.isNotEmpty) 'Description: $taskDescription',
      if (taskProjectName != null && taskProjectName.isNotEmpty) 'Project: $taskProjectName',
      if (calendarName != null && calendarName.isNotEmpty) 'Calendar: $calendarName',
    ].join('\n');

    if (taskInfo.isEmpty) return null;

    final prompt = OpenAiInboxPrompts.buildExtractSearchKeywordsPrompt(taskInfo: taskInfo);

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
    // API 키가 제공되지 않으면 전역 변수에서 가져오기 (Edge Function에서 업데이트됨)
    String? finalApiKey = apiKey;
    if (finalApiKey == null || finalApiKey.isEmpty) {
      finalApiKey = openAiApiKey.isNotEmpty ? openAiApiKey : null;
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

    final prompt = OpenAiInboxPrompts.buildGenerateMailContentPrompt(
      originalSubject: originalSubject,
      fromName: fromName,
      fromEmail: fromEmail,
      originalSnippet: originalSnippet,
      conversationText: conversationText,
      threadId: originalMail.threadId,
    );

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
    // API 키가 제공되지 않으면 전역 변수에서 가져오기 (Edge Function에서 업데이트됨)
    String? finalApiKey = apiKey;
    if (finalApiKey == null || finalApiKey.isEmpty) {
      finalApiKey = openAiApiKey.isNotEmpty ? openAiApiKey : null;
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

    final prompt = OpenAiInboxPrompts.buildGenerateMailContentPromptEn(
      originalSubject: originalSubject,
      fromName: fromName,
      originalSnippet: snippet,
      conversationText: conversationText,
      threadId: linkedMail.threadId,
    );

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
    // API 키가 제공되지 않으면 전역 변수에서 가져오기 (Edge Function에서 업데이트됨)
    String? finalApiKey = apiKey;
    if (finalApiKey == null || finalApiKey.isEmpty) {
      finalApiKey = openAiApiKey.isNotEmpty ? openAiApiKey : null;
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
    // API 키가 제공되지 않으면 전역 변수에서 가져오기 (Edge Function에서 업데이트됨)
    String? finalApiKey = apiKey;
    if (finalApiKey == null || finalApiKey.isEmpty) {
      finalApiKey = openAiApiKey.isNotEmpty ? openAiApiKey : null;
    }

    final inboxTitle = inbox.title;
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
              "project_id": {"type": "string", "description": "REQUIRED - must always be included, cannot be null"},
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
            "required": ["title", "project_id", "isConfirmed", "message"],
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
    // API 키가 제공되지 않으면 전역 변수에서 가져오기 (Edge Function에서 업데이트됨)
    String? finalApiKey = apiKey;
    if (finalApiKey == null || finalApiKey.isEmpty) {
      finalApiKey = openAiApiKey.isNotEmpty ? openAiApiKey : null;
    }

    final inboxTitle = inbox.title;
    final inboxDescription = inbox.description ?? '';
    final snippet = inboxDescription;

    final prompt = OpenAiInboxPrompts.buildGenerateTaskPrompt(inboxTitle: inboxTitle, snippet: snippet, projects: projects, inboxId: inbox.id, isSuggestionMode: true);

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
              "project_id": {"type": "string", "description": "REQUIRED - must always be included, cannot be null"},
            },
            "required": ["title", "project_id"],
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
    // API 키가 제공되지 않으면 전역 변수에서 가져오기 (Edge Function에서 업데이트됨)
    String? finalApiKey = apiKey;
    if (finalApiKey == null || finalApiKey.isEmpty) {
      finalApiKey = openAiApiKey.isNotEmpty ? openAiApiKey : null;
    }

    final inboxTitle = inbox.title;
    final inboxDescription = inbox.description ?? '';
    final snippet = inboxDescription;

    // Get source host email from inbox
    final sourceHostEmail = inbox.linkedMail?.hostMail ?? inbox.linkedMessage?.teamId;
    final sourceFromName = inbox.linkedMail != null ? inbox.linkedMail!.fromName : inbox.linkedMessage?.userName;

    final prompt = OpenAiInboxPrompts.buildGenerateEventFromInboxPrompt(
      inboxTitle: inboxTitle,
      snippet: snippet,
      sourceHostEmail: sourceHostEmail,
      sourceFromName: sourceFromName,
      calendars: calendars,
      inboxId: inbox.id,
      isSuggestionMode: true,
    );

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
    // API 키가 제공되지 않으면 전역 변수에서 가져오기 (Edge Function에서 업데이트됨)
    String? finalApiKey = apiKey;
    if (finalApiKey == null || finalApiKey.isEmpty) {
      finalApiKey = openAiApiKey.isNotEmpty ? openAiApiKey : null;
    }

    final inboxTitle = inbox.title;
    final inboxDescription = inbox.description ?? '';
    final snippet = inboxDescription;

    // Get source host email from inbox
    final sourceHostEmail = inbox.linkedMail?.hostMail ?? inbox.linkedMessage?.teamId;
    final sourceFromName = inbox.linkedMail != null ? inbox.linkedMail!.fromName : inbox.linkedMessage?.userName;

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
    List<Map<String, dynamic>>? projects,
    String? taggedContext,
    String? channelContext,
    String? inboxContext,
    required String model,
    String? apiKey,
    String? systemPrompt,
    bool includeTools = true, // tools 포함 여부 (기본값: true)
  }) async {
    try {
      // API 키가 제공되지 않으면 전역 변수에서 가져오기 (Edge Function에서 업데이트됨)
      String? finalApiKey = apiKey;
      if (finalApiKey == null || finalApiKey.isEmpty) {
        finalApiKey = openAiApiKey.isNotEmpty ? openAiApiKey : null;
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
      // 파일이 첨부된 경우 OpenAI API 형식에 맞게 content를 배열로 변환
      final messages = <Map<String, dynamic>>[
        {'role': 'system', 'content': systemMessage},
        ...await Future.wait(
          conversationHistory.map((m) async {
            final role = m['role'] as String;
            final content = m['content'] as String? ?? '';
            final files = m['files'] as List<dynamic>?;

            // 파일이 첨부된 경우 content를 배열로 변환
            if (files != null && files.isNotEmpty && role == 'user') {
              final contentArray = <Map<String, dynamic>>[
                {'type': 'text', 'text': content},
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
                    final mimeType = lowerName.endsWith('.png')
                        ? 'image/png'
                        : lowerName.endsWith('.jpg') || lowerName.endsWith('.jpeg')
                        ? 'image/jpeg'
                        : lowerName.endsWith('.gif')
                        ? 'image/gif'
                        : 'image/webp';
                    contentArray.add({
                      'type': 'image_url',
                      'image_url': {'url': 'data:$mimeType;base64,$fileBytes'},
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
                        // 높은 해상도로 렌더링 (OpenAI Vision API 권장 해상도)
                        final pageImage = await page.render(
                          width: page.width * 2, // 2배 해상도
                          height: page.height * 2,
                          format: PdfPageImageFormat.png, // PNG 형식
                        );

                        // 렌더링된 이미지의 bytes를 Base64로 인코딩
                        final bytes = pageImage?.bytes;
                        if (bytes != null && bytes.isNotEmpty) {
                          final imageBase64 = base64Encode(bytes);

                          contentArray.add({
                            'type': 'image_url',
                            'image_url': {'url': 'data:image/png;base64,$imageBase64'},
                          });
                        }

                        // 페이지 닫기 (메모리 관리)
                        page.close();
                      }

                      // 페이지가 10개를 넘으면 알림 추가
                      if (pageCount > 10) {
                        contentArray.add({'type': 'text', 'text': '\n[참고: PDF 파일이 $pageCount 페이지입니다. 처음 10페이지만 표시했습니다.]'});
                      }

                      // PDF 문서 닫기
                      pdfDocument.close();
                    } catch (e) {
                      // PDF 변환 실패 시 파일 정보만 전달
                      final fileSizeKB = ((fileMap['size'] as int? ?? 0) / 1024).toStringAsFixed(1);
                      contentArray.add({'type': 'text', 'text': '\n[PDF 파일 첨부됨: $fileName (${fileSizeKB} KB) - 파일을 이미지로 변환하는 중 오류가 발생했습니다: $e]'});
                    }
                  }
                  // 기타 파일인 경우
                  else {
                    contentArray.add({'type': 'text', 'text': '\n[파일 첨부됨: $fileName]'});
                  }
                }
              }

              return {'role': role, 'content': contentArray};
            } else {
              return {'role': role, 'content': content};
            }
          }),
        ),
      ];

      // Get function schemas for OpenAI function calling
      final functions = McpFunctionRegistry.getOpenAiFunctions();

      // Convert functions to OpenAI tools format
      final tools = functions.map((f) => {'type': 'function', 'function': f}).toList();

      // Call OpenAI API with tools (includeTools가 true일 때만)
      final requestBody = <String, dynamic>{'model': model, 'messages': messages, 'temperature': 0.7};

      if (includeTools) {
        requestBody['tools'] = tools;
        requestBody['tool_choice'] = 'auto'; // Let AI decide when to use tools
      }

      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $finalApiKey'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(utf8.decode(response.bodyBytes));
        final message = decoded['choices']?[0]?['message'] as Map<String, dynamic>?;
        final content = message?['content'] as String?;
        final toolCalls = message?['tool_calls'] as List<dynamic>?;

        // Handle tool calls - convert to function call format for parsing
        String finalContent = content ?? '';
        if (toolCalls != null && toolCalls.isNotEmpty) {
          // Convert OpenAI tool_calls format to our function call format
          final functionCalls = <Map<String, dynamic>>[];
          for (final toolCall in toolCalls) {
            final function = toolCall['function'] as Map<String, dynamic>?;
            final functionName = function?['name'] as String?;
            final argumentsJson = function?['arguments'] as String?;
            if (functionName != null && argumentsJson != null) {
              try {
                final arguments = jsonDecode(argumentsJson) as Map<String, dynamic>;
                functionCalls.add({'function': functionName, 'arguments': arguments});
              } catch (e) {
                // Failed to parse tool call arguments
              }
            }
          }

          if (functionCalls.isNotEmpty) {
            // Convert function calls to JSON array format for parsing
            final functionCallsJson = jsonEncode(functionCalls);
            finalContent = '$finalContent\n\n$functionCallsJson';
          }
        }

        if (finalContent.isNotEmpty) {
          final result = <String, dynamic>{'message': finalContent};

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
        } else if (toolCalls != null && toolCalls.isNotEmpty) {
          // Only tool calls, no content - return empty message with function calls
          final functionCalls = <Map<String, dynamic>>[];
          for (final toolCall in toolCalls) {
            final function = toolCall['function'] as Map<String, dynamic>?;
            final functionName = function?['name'] as String?;
            final argumentsJson = function?['arguments'] as String?;
            if (functionName != null && argumentsJson != null) {
              try {
                final arguments = jsonDecode(argumentsJson) as Map<String, dynamic>;
                functionCalls.add({'function': functionName, 'arguments': arguments});
              } catch (e) {
                // Failed to parse tool call arguments
              }
            }
          }

          if (functionCalls.isNotEmpty) {
            final functionCallsJson = jsonEncode(functionCalls);
            final result = <String, dynamic>{'message': functionCallsJson};

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
      }
    } catch (e, stackTrace) {
      // Ignore exceptions but log them
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
      // API 키가 제공되지 않으면 전역 변수에서 가져오기 (Edge Function에서 업데이트됨)
      String? finalApiKey = apiKey;
      if (finalApiKey == null || finalApiKey.isEmpty) {
        finalApiKey = openAiApiKey.isNotEmpty ? openAiApiKey : null;
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
