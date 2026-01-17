import 'package:Visir/features/inbox/domain/entities/inbox_entity.dart';
import 'package:Visir/features/task/domain/entities/task_entity.dart';
import 'package:Visir/features/calendar/domain/entities/calendar_entity.dart';
import 'package:Visir/features/calendar/domain/entities/event_entity.dart';
import 'package:Visir/features/common/domain/entities/connection_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_channel_entity.dart';
import 'package:Visir/features/task/domain/entities/project_entity.dart';

/// Service for building AI context from various data sources
/// Optimized to reduce token usage while maintaining necessary information
class AgentContextService {
  /// Maximum length for content snippets to avoid token bloat
  static const int maxContentLength = 2000;
  static const int maxFullContentLength = 8000;

  /// Build context from inbox items
  /// [summaryOnly] - if true, only include title and snippet
  /// [requestedInboxNumbers] - specific inbox numbers to include full content for
  String buildInboxContext(
    List<InboxEntity> inboxes, {
    bool summaryOnly = false,
    Set<int> requestedInboxNumbers = const {},
  }) {
    if (inboxes.isEmpty) return '';

    final buffer = StringBuffer();
    buffer.writeln('## Inbox Items');

    for (int i = 0; i < inboxes.length; i++) {
      final inbox = inboxes[i];
      final inboxNumber = i + 1;
      final isFullContentRequested = requestedInboxNumbers.contains(inboxNumber);

      buffer.writeln('\n### Inbox #$inboxNumber');
      buffer.writeln('ID: ${inbox.id}');
      buffer.writeln('Title: ${inbox.title}');

      // Handle mail or message
      if (inbox.linkedMail != null) {
        final mail = inbox.linkedMail!;
        buffer.writeln('Type: Email');
        buffer.writeln('From: ${mail.fromName}');
      } else if (inbox.linkedMessage != null) {
        final message = inbox.linkedMessage!;
        buffer.writeln('Type: Message');
        buffer.writeln('From: ${message.userName}');
        buffer.writeln('Channel: ${message.channelName}');
      }

      buffer.writeln('Date: ${inbox.inboxDatetime.toIso8601String()}');

      // Include full content if requested, otherwise just snippet
      if (!summaryOnly && isFullContentRequested && inbox.description != null) {
        final content = inbox.description!;
        final truncated = content.length > maxFullContentLength
            ? '${content.substring(0, maxFullContentLength)}...[truncated]'
            : content;
        buffer.writeln('Content: $truncated');
      } else if (inbox.description != null && inbox.description!.isNotEmpty) {
        final snippet = inbox.description!;
        final truncated = snippet.length > maxContentLength
            ? '${snippet.substring(0, maxContentLength)}...'
            : snippet;
        buffer.writeln('Snippet: $truncated');
      }
    }

    return buffer.toString();
  }

  /// Build context from search results for inboxes
  String buildInboxContextFromSearchResults(List<dynamic> searchResults) {
    if (searchResults.isEmpty) {
      return '## Search Results\nNo inbox items found matching your search criteria.';
    }

    final buffer = StringBuffer();
    buffer.writeln('## Search Results (${searchResults.length} items found)');

    for (int i = 0; i < searchResults.length; i++) {
      final result = searchResults[i] as Map<String, dynamic>;
      buffer.writeln('\n### Result #${i + 1}');
      buffer.writeln('ID: ${result['id']}');
      buffer.writeln('Title: ${result['title'] ?? 'N/A'}');

      // Note: search results use 'sender' and 'description', not 'from' and 'snippet'
      if (result['sender'] != null) {
        buffer.writeln('From: ${result['sender']}');
      }

      if (result['description'] != null) {
        final description = result['description'] as String;
        final truncated = description.length > maxContentLength
            ? '${description.substring(0, maxContentLength)}...'
            : description;
        buffer.writeln('Snippet: $truncated');
      }

      if (result['inboxDatetime'] != null) {
        buffer.writeln('Date: ${result['inboxDatetime']}');
      }
    }

    return buffer.toString();
  }

  /// Build context from tasks
  String buildTaskContext(List<TaskEntity> tasks) {
    if (tasks.isEmpty) return '';

    final buffer = StringBuffer();
    buffer.writeln('## Tagged Tasks');

    for (final task in tasks) {
      buffer.writeln('\n### Task: ${task.title}');
      buffer.writeln('ID: ${task.id}');
      if (task.description != null && task.description!.isNotEmpty) {
        final desc = task.description!;
        final truncated = desc.length > maxContentLength
            ? '${desc.substring(0, maxContentLength)}...'
            : desc;
        buffer.writeln('Description: $truncated');
      }
      if (task.startAt != null) {
        buffer.writeln('Start: ${task.startAt!.toIso8601String()}');
      }
      if (task.endAt != null) {
        buffer.writeln('End: ${task.endAt!.toIso8601String()}');
      }
      buffer.writeln('Status: ${task.status}');
      buffer.writeln('Is All Day: ${task.isAllDay}');
      if (task.projectId != null) {
        buffer.writeln('Project ID: ${task.projectId}');
      }
      if (task.rrule != null) {
        buffer.writeln('Recurrence: ${task.rrule}');
      }

      // linkedMail 또는 linkedMessages가 있으면 inboxId 정보 제공
      if (task.linkedMails.isNotEmpty) {
        buffer.writeln('Linked Mails:');
        for (final mail in task.linkedMails) {
          final inboxId = InboxEntity.getInboxIdFromLinkedMail(mail);
          if (inboxId.isNotEmpty) {
            buffer.writeln('  - Inbox ID: $inboxId');
          }
        }
      }
      if (task.linkedMessages.isNotEmpty) {
        buffer.writeln('Linked Messages:');
        for (final message in task.linkedMessages) {
          final inboxId = InboxEntity.getInboxIdFromLinkedChat(message);
          if (inboxId.isNotEmpty) {
            buffer.writeln('  - Inbox ID: $inboxId');
          }
        }
      }
    }

    return buffer.toString();
  }

  /// Build context from task search results
  String buildTaskContextFromSearchResults(List<dynamic> searchResults) {
    if (searchResults.isEmpty) {
      return '## Search Results\nNo tasks found matching your search criteria.';
    }

    final buffer = StringBuffer();
    buffer.writeln('## Search Results (${searchResults.length} tasks found)');

    for (int i = 0; i < searchResults.length; i++) {
      final result = searchResults[i] as Map<String, dynamic>;
      buffer.writeln('\n### Task #${i + 1}');
      buffer.writeln('ID: ${result['id']}');
      buffer.writeln('Title: ${result['title'] ?? 'N/A'}');

      if (result['description'] != null) {
        final desc = result['description'] as String;
        final truncated = desc.length > maxContentLength
            ? '${desc.substring(0, maxContentLength)}...'
            : desc;
        buffer.writeln('Description: $truncated');
      }

      // Note: search results use camelCase (projectId, startAt, endAt), not snake_case
      if (result['startAt'] != null) {
        buffer.writeln('Start: ${result['startAt']}');
      }

      if (result['endAt'] != null) {
        buffer.writeln('End: ${result['endAt']}');
      }

      if (result['status'] != null) {
        buffer.writeln('Status: ${result['status']}');
      }

      if (result['isAllDay'] != null) {
        buffer.writeln('Is All Day: ${result['isAllDay']}');
      }

      if (result['projectId'] != null) {
        buffer.writeln('Project ID: ${result['projectId']}');
      }

      if (result['rrule'] != null) {
        buffer.writeln('Recurrence: ${result['rrule']}');
      }
    }

    return buffer.toString();
  }

  /// Build context from events
  String buildEventContext(List<EventEntity> events) {
    if (events.isEmpty) return '';

    final buffer = StringBuffer();
    buffer.writeln('## Tagged Events');

    for (final event in events) {
      buffer.writeln('\n### Event: ${event.title}');
      buffer.writeln('ID: ${event.eventId}');
      if (event.description != null && event.description!.isNotEmpty) {
        final desc = event.description!;
        final truncated = desc.length > maxContentLength
            ? '${desc.substring(0, maxContentLength)}...'
            : desc;
        buffer.writeln('Description: $truncated');
      }
      buffer.writeln('Start: ${event.startDate.toIso8601String()}');
      buffer.writeln('End: ${event.endDate.toIso8601String()}');
      buffer.writeln('Is All Day: ${event.isAllDay}');
      buffer.writeln('Calendar ID: ${event.calendar.uniqueId}');
      if (event.location != null && event.location!.isNotEmpty) {
        buffer.writeln('Location: ${event.location}');
      }
      if (event.rrule != null) {
        buffer.writeln('Recurrence: ${event.rrule}');
      }
      if (event.attendees.isNotEmpty) {
        final attendeeEmails = event.attendees.map((a) => a.email).whereType<String>().toList();
        if (attendeeEmails.isNotEmpty) {
          buffer.writeln('Attendees: ${attendeeEmails.join(', ')}');
        }
      }
      if (event.conferenceLink != null && event.conferenceLink!.isNotEmpty) {
        buffer.writeln('Conference Link: ${event.conferenceLink}');
      }
    }

    return buffer.toString();
  }

  /// Build context from event search results
  String buildEventContextFromSearchResults(List<dynamic> searchResults) {
    if (searchResults.isEmpty) {
      return '## Search Results\nNo events found matching your search criteria.';
    }

    final buffer = StringBuffer();
    buffer.writeln('## Search Results (${searchResults.length} events found)');

    for (int i = 0; i < searchResults.length; i++) {
      final result = searchResults[i] as Map<String, dynamic>;
      buffer.writeln('\n### Event #${i + 1}');
      buffer.writeln('ID: ${result['id']}');
      buffer.writeln('Title: ${result['title'] ?? 'N/A'}');

      if (result['description'] != null) {
        final desc = result['description'] as String;
        final truncated = desc.length > maxContentLength
            ? '${desc.substring(0, maxContentLength)}...'
            : desc;
        buffer.writeln('Description: $truncated');
      }

      // Note: search results use camelCase (startAt, endAt, calendarId), not snake_case
      if (result['startAt'] != null || result['startDate'] != null) {
        buffer.writeln('Start: ${result['startAt'] ?? result['startDate']}');
      }

      if (result['endAt'] != null || result['endDate'] != null) {
        buffer.writeln('End: ${result['endAt'] ?? result['endDate']}');
      }

      if (result['location'] != null) {
        buffer.writeln('Location: ${result['location']}');
      }

      if (result['isAllDay'] != null) {
        buffer.writeln('Is All Day: ${result['isAllDay']}');
      }

      if (result['calendarId'] != null) {
        buffer.writeln('Calendar ID: ${result['calendarId']}');
      }

      if (result['rrule'] != null) {
        buffer.writeln('Recurrence: ${result['rrule']}');
      }

      if (result['attendees'] != null) {
        buffer.writeln('Attendees: ${result['attendees']}');
      }

      if (result['conferenceLink'] != null) {
        buffer.writeln('Conference Link: ${result['conferenceLink']}');
      }
    }

    return buffer.toString();
  }

  /// Build context from connections
  String buildConnectionContext(List<ConnectionEntity> connections) {
    if (connections.isEmpty) return '';

    final buffer = StringBuffer();
    buffer.writeln('## Tagged Connections');

    for (final connection in connections) {
      buffer.writeln('\n### Connection: ${connection.name}');
      if (connection.email != null && connection.email!.isNotEmpty) {
        buffer.writeln('Email: ${connection.email}');
      }
    }

    return buffer.toString();
  }

  /// Build combined context from tagged items
  String buildTaggedContext({
    List<TaskEntity>? taggedTasks,
    List<EventEntity>? taggedEvents,
    List<ConnectionEntity>? taggedConnections,
  }) {
    final parts = <String>[];

    if (taggedTasks != null && taggedTasks.isNotEmpty) {
      parts.add(buildTaskContext(taggedTasks));
    }

    if (taggedEvents != null && taggedEvents.isNotEmpty) {
      parts.add(buildEventContext(taggedEvents));
    }

    if (taggedConnections != null && taggedConnections.isNotEmpty) {
      parts.add(buildConnectionContext(taggedConnections));
    }

    return parts.isEmpty ? '' : parts.join('\n\n');
  }

  /// Build message with tagged items embedded as HTML
  String buildMessageWithTaggedItems({
    required String userMessage,
    List<TaskEntity>? taggedTasks,
    List<EventEntity>? taggedEvents,
    List<InboxEntity>? taggedInboxes,
    List<ConnectionEntity>? taggedConnections,
    List<MessageChannelEntity>? taggedChannels,
    List<ProjectEntity>? taggedProjects,
  }) {
    final buffer = StringBuffer(userMessage);

    if (taggedTasks != null && taggedTasks.isNotEmpty) {
      buffer.writeln('\n\n## Tagged Tasks:');
      for (final task in taggedTasks) {
        buffer.writeln('- ${task.title} (ID: ${task.id})');
      }
    }

    if (taggedEvents != null && taggedEvents.isNotEmpty) {
      buffer.writeln('\n\n## Tagged Events:');
      for (final event in taggedEvents) {
        buffer.writeln('- ${event.title} (ID: ${event.eventId})');
      }
    }

    if (taggedInboxes != null && taggedInboxes.isNotEmpty) {
      buffer.writeln('\n\n## Tagged Inbox Items:');
      for (final inbox in taggedInboxes) {
        buffer.writeln('- ${inbox.title} (ID: ${inbox.id})');
      }
    }

    if (taggedConnections != null && taggedConnections.isNotEmpty) {
      buffer.writeln('\n\n## Tagged Connections:');
      for (final conn in taggedConnections) {
        final emailStr = conn.email != null ? ' (${conn.email})' : '';
        buffer.writeln('- ${conn.name}$emailStr');
      }
    }

    if (taggedChannels != null && taggedChannels.isNotEmpty) {
      buffer.writeln('\n\n## Tagged Channels:');
      for (final channel in taggedChannels) {
        buffer.writeln('- ${channel.name} (ID: ${channel.id})');
      }
    }

    if (taggedProjects != null && taggedProjects.isNotEmpty) {
      buffer.writeln('\n\n## Tagged Projects:');
      for (final project in taggedProjects) {
        buffer.writeln('- ${project.name} (ID: ${project.uniqueId})');
      }
    }

    return buffer.toString();
  }

  /// Build minimal recent task/event context for system prompt
  /// Only includes IDs and minimal instructions to reduce tokens
  String buildRecentItemsContext({
    List<String>? recentTaskIds,
    List<String>? recentEventIds,
  }) {
    if ((recentTaskIds == null || recentTaskIds.isEmpty) &&
        (recentEventIds == null || recentEventIds.isEmpty)) {
      return '';
    }

    final buffer = StringBuffer();
    buffer.writeln('\n## Recent Items');

    if (recentTaskIds != null && recentTaskIds.isNotEmpty) {
      final mostRecent = recentTaskIds.last;
      buffer.writeln('Recent Task ID: $mostRecent');
      buffer.writeln('Use updateTask() to modify this task, NOT createTask().');
    }

    if (recentEventIds != null && recentEventIds.isNotEmpty) {
      final mostRecent = recentEventIds.last;
      buffer.writeln('Recent Event ID: $mostRecent');
      buffer.writeln('Use updateEvent() to modify this event, NOT createEvent().');
    }

    return buffer.toString();
  }
}
