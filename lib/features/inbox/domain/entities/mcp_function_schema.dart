/// MCP (Model Context Protocol) style function call schema definitions
/// Allows AI to dynamically call functions in actions.dart

class McpFunctionSchema {
  final String name;
  final String description;
  final List<McpFunctionParameter> parameters;
  final String? returnType;

  const McpFunctionSchema({required this.name, required this.description, required this.parameters, this.returnType});

  Map<String, dynamic> toJson() {
    // Get required parameter names (only those with required == true)
    final requiredParams = parameters.where((p) => p.required == true).map((p) => p.name).toList();

    return {
      'name': name,
      'description': description,
      'parameters': {
        'type': 'object',
        'properties': {for (final param in parameters) param.name: _buildParameterSchema(param)},
        // OpenAI API requires 'required' to be an array of parameter names
        if (requiredParams.isNotEmpty) 'required': requiredParams,
      },
      if (returnType != null) 'returns': returnType,
    };
  }

  /// Builds the schema for a single parameter, handling array types with items
  Map<String, dynamic> _buildParameterSchema(McpFunctionParameter param) {
    final schema = <String, dynamic>{'type': param.type, 'description': param.description};

    // For array types, OpenAI API requires 'items' property
    if (param.type == 'array') {
      // Determine item type from parameter name and description
      if (param.name == 'reminders') {
        // Reminders is an array of objects
        schema['items'] = {
          'type': 'object',
          'properties': {
            'method': {
              'type': 'string',
              'enum': ['push', 'email'],
            },
            'minutes': {'type': 'number'},
          },
          'required': ['method', 'minutes'],
        };
      } else if (param.name == 'to' || param.name == 'cc' || param.name == 'bcc') {
        // Email recipients are arrays of objects
        schema['items'] = {
          'type': 'object',
          'properties': {
            'email': {'type': 'string'},
            'name': {'type': 'string'},
          },
          'required': ['email'],
        };
      } else {
        // Default: array of strings (for excludedRecurrenceDate, attendees, tags, etc.)
        schema['items'] = {'type': 'string'};
      }
    }

    // Add enum values if present
    if (param.enumValues != null) {
      schema['enum'] = param.enumValues;
    }

    return schema;
  }
}

class McpFunctionParameter {
  final String name;
  final String type; // 'string', 'number', 'boolean', 'object', 'array'
  final String description;
  final List<String>? enumValues;
  final bool? required;

  const McpFunctionParameter({required this.name, required this.type, required this.description, this.enumValues, this.required});
}

/// Defines all available function schemas.
class McpFunctionRegistry {
  static List<McpFunctionSchema> getAllFunctions() {
    return [
      // Task Actions
      McpFunctionSchema(
        name: 'createTask',
        description: 'Creates a new task. You can set task title, description, project, dates, etc.',
        parameters: [
          McpFunctionParameter(name: 'title', type: 'string', description: 'Task title', required: true),
          McpFunctionParameter(name: 'description', type: 'string', description: 'Task description (optional)', required: false),
          McpFunctionParameter(name: 'projectId', type: 'string', description: 'Project ID (optional)', required: false),
          McpFunctionParameter(
            name: 'startAt',
            type: 'string',
            description: 'Start date/time in ISO 8601 format: YYYY-MM-DDTHH:mm:ss, e.g., "2024-01-01T09:00:00" (optional). Use field name startAt (not start_at).',
            required: false,
          ),
          McpFunctionParameter(
            name: 'endAt',
            type: 'string',
            description: 'End date/time in ISO 8601 format: YYYY-MM-DDTHH:mm:ss, e.g., "2024-01-01T10:00:00" (optional). Use field name endAt (not end_at).',
            required: false,
          ),
          McpFunctionParameter(name: 'isAllDay', type: 'boolean', description: 'Whether the task is all-day (default: false)', required: false),
          McpFunctionParameter(name: 'status', type: 'string', description: 'Task status (default: "none")', enumValues: ['none', 'done', 'cancelled'], required: false),
          McpFunctionParameter(
            name: 'rrule',
            type: 'string',
            description: 'Recurrence rule in RFC 5545 RRULE format, e.g., "FREQ=DAILY", "FREQ=WEEKLY;BYDAY=MO", "FREQ=MONTHLY" (optional)',
            required: false,
          ),
          McpFunctionParameter(
            name: 'reminders',
            type: 'array',
            description: 'List of reminders (optional). Each item should be {"method": "push"|"email", "minutes": number}',
            required: false,
          ),
          McpFunctionParameter(
            name: 'recurrenceEndAt',
            type: 'string',
            description: 'Recurrence end date/time in ISO 8601 format: YYYY-MM-DDTHH:mm:ss (optional)',
            required: false,
          ),
          McpFunctionParameter(
            name: 'excludedRecurrenceDate',
            type: 'array',
            description: 'List of excluded recurrence dates as ISO 8601 format strings (optional)',
            required: false,
          ),
          McpFunctionParameter(name: 'from', type: 'string', description: 'Source where the task was created (e.g., GitHub, Email, optional)', required: false),
          McpFunctionParameter(name: 'subject', type: 'string', description: 'Original title or subject (optional)', required: false),
          McpFunctionParameter(name: 'actionNeeded', type: 'string', description: 'Description of action needed (optional)', required: false),
          McpFunctionParameter(
            name: 'inboxId',
            type: 'string',
            description:
                '**MANDATORY when creating tasks from inbox items**: Inbox ID to link the task to a specific inbox item (email or message). You MUST use the exact inboxId shown in the Inbox Context (format: "Inbox ID (USE THIS EXACT ID): `mail_...`" or "Inbox ID: `mail_...`"). Copy the inboxId EXACTLY as shown - do NOT use item numbers or titles. Example: If Inbox Context shows "Inbox ID (USE THIS EXACT ID): `mail_google_example@gmail.com_12345`", use "mail_google_example@gmail.com_12345". (required when creating from inbox items)',
            required: false,
          ),
        ],
      ),
      McpFunctionSchema(
        name: 'updateTask',
        description: 'Updates an existing task.',
        parameters: [
          McpFunctionParameter(name: 'taskId', type: 'string', description: 'Task ID', required: true),
          McpFunctionParameter(name: 'title', type: 'string', description: 'Task title'),
          McpFunctionParameter(name: 'description', type: 'string', description: 'Task description'),
          McpFunctionParameter(name: 'projectId', type: 'string', description: 'Project ID'),
          McpFunctionParameter(name: 'startAt', type: 'string', description: 'Start date/time in ISO 8601 format'),
          McpFunctionParameter(name: 'endAt', type: 'string', description: 'End date/time in ISO 8601 format'),
          McpFunctionParameter(name: 'isAllDay', type: 'boolean', description: 'Whether the task is all-day'),
          McpFunctionParameter(name: 'status', type: 'string', description: 'Task status', enumValues: ['none', 'done', 'cancelled']),
          McpFunctionParameter(name: 'rrule', type: 'string', description: 'Recurrence rule in RFC 5545 RRULE format, e.g., "FREQ=DAILY", "FREQ=WEEKLY;BYDAY=MO" (optional)'),
          McpFunctionParameter(name: 'reminders', type: 'array', description: 'List of reminders (optional). Each item should be {"method": "push"|"email", "minutes": number}'),
          McpFunctionParameter(name: 'recurrenceEndAt', type: 'string', description: 'Recurrence end date/time in ISO 8601 format (optional)'),
          McpFunctionParameter(name: 'excludedRecurrenceDate', type: 'array', description: 'List of excluded recurrence dates as ISO 8601 format strings (optional)'),
        ],
      ),
      McpFunctionSchema(
        name: 'deleteTask',
        description: 'Deletes a task.',
        parameters: [McpFunctionParameter(name: 'taskId', type: 'string', description: 'Task ID', required: true)],
      ),
      McpFunctionSchema(
        name: 'toggleTaskStatus',
        description: 'Toggles the completion status of a task (done ↔ not done).',
        parameters: [McpFunctionParameter(name: 'taskId', type: 'string', description: 'Task ID', required: true)],
      ),
      McpFunctionSchema(
        name: 'assignProject',
        description: 'Assigns a task to a project.',
        parameters: [
          McpFunctionParameter(name: 'taskId', type: 'string', description: 'Task ID', required: true),
          McpFunctionParameter(name: 'projectId', type: 'string', description: 'Project ID', required: true),
        ],
      ),
      McpFunctionSchema(
        name: 'setPriority',
        description: 'Sets the priority of a task. (Not yet implemented)',
        parameters: [
          McpFunctionParameter(name: 'taskId', type: 'string', description: 'Task ID', required: true),
          McpFunctionParameter(name: 'priority', type: 'string', description: 'Priority level', enumValues: ['low', 'medium', 'high'], required: true),
        ],
      ),
      McpFunctionSchema(
        name: 'addTags',
        description: 'Adds tags to a task. (Not yet implemented)',
        parameters: [
          McpFunctionParameter(name: 'taskId', type: 'string', description: 'Task ID', required: true),
          McpFunctionParameter(name: 'tags', type: 'array', description: 'List of tag names', required: true),
        ],
      ),
      McpFunctionSchema(
        name: 'removeTags',
        description: 'Removes tags from a task. (Not yet implemented)',
        parameters: [
          McpFunctionParameter(name: 'taskId', type: 'string', description: 'Task ID', required: true),
          McpFunctionParameter(name: 'tags', type: 'array', description: 'List of tag names to remove', required: true),
        ],
      ),
      McpFunctionSchema(
        name: 'setDueDate',
        description: 'Sets the due date for a task.',
        parameters: [
          McpFunctionParameter(name: 'taskId', type: 'string', description: 'Task ID', required: true),
          McpFunctionParameter(name: 'dueDate', type: 'string', description: 'Due date/time in ISO 8601 format', required: true),
        ],
      ),
      McpFunctionSchema(
        name: 'setReminder',
        description: 'Sets a reminder for a task or event.',
        parameters: [
          McpFunctionParameter(name: 'taskId', type: 'string', description: 'Task ID (either taskId or eventId is required)'),
          McpFunctionParameter(name: 'eventId', type: 'string', description: 'Event ID (either taskId or eventId is required)'),
          McpFunctionParameter(name: 'minutes', type: 'number', description: 'Minutes before the task/event to remind', required: true),
          McpFunctionParameter(name: 'method', type: 'string', description: 'Reminder method', enumValues: ['push', 'email'], required: false),
        ],
      ),
      McpFunctionSchema(
        name: 'setRecurrence',
        description: 'Sets a recurrence rule for a task or event.',
        parameters: [
          McpFunctionParameter(name: 'taskId', type: 'string', description: 'Task ID (either taskId or eventId is required)'),
          McpFunctionParameter(name: 'eventId', type: 'string', description: 'Event ID (either taskId or eventId is required)'),
          McpFunctionParameter(name: 'rrule', type: 'string', description: 'Recurrence rule in RFC 5545 RRULE format, e.g., "FREQ=DAILY;INTERVAL=1"', required: true),
        ],
      ),
      McpFunctionSchema(
        name: 'duplicateTask',
        description: 'Duplicates a task.',
        parameters: [McpFunctionParameter(name: 'taskId', type: 'string', description: 'Task ID', required: true)],
      ),
      McpFunctionSchema(
        name: 'duplicateEvent',
        description: 'Duplicates an event.',
        parameters: [McpFunctionParameter(name: 'eventId', type: 'string', description: 'Event ID', required: true)],
      ),
      McpFunctionSchema(
        name: 'removeReminder',
        description: 'Removes reminders from a task or event.',
        parameters: [
          McpFunctionParameter(name: 'taskId', type: 'string', description: 'Task ID (either taskId or eventId is required)'),
          McpFunctionParameter(name: 'eventId', type: 'string', description: 'Event ID (either taskId or eventId is required)'),
        ],
      ),
      McpFunctionSchema(
        name: 'removeRecurrence',
        description: 'Removes recurrence rule from a task or event.',
        parameters: [
          McpFunctionParameter(name: 'taskId', type: 'string', description: 'Task ID (either taskId or eventId is required)'),
          McpFunctionParameter(name: 'eventId', type: 'string', description: 'Event ID (either taskId or eventId is required)'),
        ],
      ),

      // Calendar Actions
      McpFunctionSchema(
        name: 'createEvent',
        description: 'Creates a new calendar event. You can set title, description, date/time, location, attendees, etc.',
        parameters: [
          McpFunctionParameter(name: 'title', type: 'string', description: 'Event title', required: true),
          McpFunctionParameter(name: 'description', type: 'string', description: 'Event description (optional)', required: false),
          McpFunctionParameter(name: 'calendarId', type: 'string', description: 'Calendar ID (optional)', required: false),
          McpFunctionParameter(
            name: 'startAt',
            type: 'string',
            description: 'Start date/time in ISO 8601 format: YYYY-MM-DDTHH:mm:ss, e.g., "2024-01-01T09:00:00" (optional). Use field name startAt (not start_at).',
            required: false,
          ),
          McpFunctionParameter(
            name: 'endAt',
            type: 'string',
            description: 'End date/time in ISO 8601 format: YYYY-MM-DDTHH:mm:ss, e.g., "2024-01-01T10:00:00" (optional). Use field name endAt (not end_at).',
            required: false,
          ),
          McpFunctionParameter(name: 'isAllDay', type: 'boolean', description: 'Whether the event is all-day (default: false)', required: false),
          McpFunctionParameter(name: 'location', type: 'string', description: 'Location (optional)', required: false),
          McpFunctionParameter(
            name: 'attendees',
            type: 'array',
            description: 'List of attendee email addresses (optional, e.g., ["email1@example.com", "email2@example.com"])',
            required: false,
          ),
          McpFunctionParameter(name: 'conferenceLink', type: 'string', description: 'Conference link (optional, set to "added" to auto-generate)', required: false),
          McpFunctionParameter(
            name: 'rrule',
            type: 'string',
            description: 'Recurrence rule in RFC 5545 RRULE format, e.g., "FREQ=DAILY", "FREQ=WEEKLY;BYDAY=MO", "FREQ=MONTHLY" (optional)',
            required: false,
          ),
          McpFunctionParameter(
            name: 'reminders',
            type: 'array',
            description: 'List of reminders (optional). Each item should be {"method": "push"|"email", "minutes": number}',
            required: false,
          ),
          McpFunctionParameter(
            name: 'timezone',
            type: 'string',
            description: 'Timezone (optional, e.g., "America/New_York", "Asia/Seoul". Default: user\'s configured timezone)',
            required: false,
          ),
          McpFunctionParameter(name: 'from', type: 'string', description: 'Source where the event was created (e.g., GitHub, Email, optional)', required: false),
          McpFunctionParameter(name: 'subject', type: 'string', description: 'Original title or subject (optional)', required: false),
          McpFunctionParameter(name: 'actionNeeded', type: 'string', description: 'Description of action needed (optional)', required: false),
        ],
      ),
      McpFunctionSchema(
        name: 'updateEvent',
        description: 'Updates an existing calendar event.',
        parameters: [
          McpFunctionParameter(name: 'eventId', type: 'string', description: 'Event ID', required: true),
          McpFunctionParameter(name: 'title', type: 'string', description: 'Event title'),
          McpFunctionParameter(name: 'description', type: 'string', description: 'Event description'),
          McpFunctionParameter(name: 'startAt', type: 'string', description: 'Start date/time in ISO 8601 format'),
          McpFunctionParameter(name: 'endAt', type: 'string', description: 'End date/time in ISO 8601 format'),
          McpFunctionParameter(name: 'isAllDay', type: 'boolean', description: 'Whether the event is all-day'),
          McpFunctionParameter(name: 'location', type: 'string', description: 'Location'),
          McpFunctionParameter(name: 'attendees', type: 'array', description: 'List of attendee email addresses'),
          McpFunctionParameter(name: 'rrule', type: 'string', description: 'Recurrence rule in RFC 5545 RRULE format, e.g., "FREQ=DAILY", "FREQ=WEEKLY;BYDAY=MO" (optional)'),
          McpFunctionParameter(name: 'reminders', type: 'array', description: 'List of reminders (optional). Each item should be {"method": "push"|"email", "minutes": number}'),
          McpFunctionParameter(name: 'timezone', type: 'string', description: 'Timezone (optional, e.g., "America/New_York", "Asia/Seoul")'),
          McpFunctionParameter(name: 'conferenceLink', type: 'string', description: 'Conference link (optional, set to "added" to auto-generate)'),
        ],
      ),
      McpFunctionSchema(
        name: 'deleteEvent',
        description: 'Deletes a calendar event.',
        parameters: [McpFunctionParameter(name: 'eventId', type: 'string', description: 'Event ID', required: true)],
      ),
      McpFunctionSchema(
        name: 'responseCalendarInvitation',
        description: 'Responds to a calendar invitation.',
        parameters: [
          McpFunctionParameter(name: 'eventId', type: 'string', description: 'Event ID', required: true),
          McpFunctionParameter(name: 'response', type: 'string', description: 'Response status', enumValues: ['accepted', 'declined', 'tentative'], required: true),
        ],
      ),
      McpFunctionSchema(
        name: 'optimizeSchedule',
        description:
            'Optimizes the schedule for a task or event by finding the best available time slot. **IMPORTANT**: Before calling this function, you MUST first call searchTask or searchCalendarEvent to get the task/event list with their current time information in the context. This function needs to know the current schedule to find optimal time slots.',
        parameters: [
          McpFunctionParameter(
            name: 'taskId',
            type: 'string',
            description: 'Task ID (either taskId or eventId is required). Must be found in the context from a previous searchTask call.',
            required: false,
          ),
          McpFunctionParameter(
            name: 'eventId',
            type: 'string',
            description: 'Event ID (either taskId or eventId is required). Must be found in the context from a previous searchCalendarEvent call.',
            required: false,
          ),
        ],
      ),
      McpFunctionSchema(
        name: 'reschedule',
        description:
            'Reschedules multiple tasks to optimal time slots on today. Works for tasks on any day (moves them to today) or tasks already on today (optimizes their time slots). **IMPORTANT**: Use task IDs from tagged tasks when available. If user has tagged tasks, extract the IDs from the Tagged Items context. If no tagged items, call searchTask first to get task IDs. This function needs current schedule information to find optimal time slots.',
        parameters: [
          McpFunctionParameter(
            name: 'taskIds',
            type: 'array',
            description: 'Array of task IDs to reschedule. Extract from Tagged Items context if tasks are tagged, otherwise from searchTask results. Example: ["task-id-1", "task-id-2"]',
            required: true,
          ),
        ],
      ),

      // Project Actions
      McpFunctionSchema(
        name: 'createProject',
        description: 'Creates a new project.',
        parameters: [
          McpFunctionParameter(name: 'name', type: 'string', description: 'Project name', required: true),
          McpFunctionParameter(name: 'description', type: 'string', description: 'Project description (optional)', required: false),
        ],
      ),
      McpFunctionSchema(
        name: 'updateProject',
        description: 'Updates an existing project.',
        parameters: [
          McpFunctionParameter(name: 'projectId', type: 'string', description: 'Project ID', required: true),
          McpFunctionParameter(name: 'name', type: 'string', description: 'Project name'),
          McpFunctionParameter(name: 'description', type: 'string', description: 'Project description'),
        ],
      ),
      McpFunctionSchema(
        name: 'deleteProject',
        description: 'Deletes a project.',
        parameters: [McpFunctionParameter(name: 'projectId', type: 'string', description: 'Project ID', required: true)],
      ),
      McpFunctionSchema(
        name: 'searchProject',
        description: 'Searches for projects. You can search by name or description.',
        parameters: [McpFunctionParameter(name: 'query', type: 'string', description: 'Search query (name, description, etc.)', required: true)],
      ),
      McpFunctionSchema(
        name: 'moveProject',
        description: 'Moves a project to be a sub-project of another project or to the root.',
        parameters: [
          McpFunctionParameter(name: 'projectId', type: 'string', description: 'Project ID to move', required: true),
          McpFunctionParameter(name: 'newParentId', type: 'string', description: 'New parent project ID (null to move to root)'),
        ],
      ),
      McpFunctionSchema(
        name: 'inviteUserToProject',
        description: 'Invites a user to a project.',
        parameters: [
          McpFunctionParameter(name: 'projectId', type: 'string', description: 'Project ID', required: true),
          McpFunctionParameter(name: 'email', type: 'string', description: 'Email address of the user to invite', required: true),
        ],
      ),
      McpFunctionSchema(
        name: 'removeUserFromProject',
        description: 'Removes a user from a project.',
        parameters: [
          McpFunctionParameter(name: 'projectId', type: 'string', description: 'Project ID', required: true),
          McpFunctionParameter(name: 'userId', type: 'string', description: 'User ID to remove', required: true),
        ],
      ),
      McpFunctionSchema(
        name: 'linkToProject',
        description:
            'Links an inbox item or task to a project by creating or updating a linked task. Use taskId if you want to move an existing task to a different project, or use inboxId if you want to link an inbox item to a project.',
        parameters: [
          McpFunctionParameter(name: 'inboxId', type: 'string', description: 'Inbox ID (required if taskId is not provided)', required: false),
          McpFunctionParameter(
            name: 'taskId',
            type: 'string',
            description: 'Task ID (required if inboxId is not provided). Use this to move an existing task to a different project.',
            required: false,
          ),
          McpFunctionParameter(name: 'projectId', type: 'string', description: 'Project ID', required: true),
        ],
      ),

      // Mail Actions
      McpFunctionSchema(
        name: 'sendMail',
        description: 'Sends an email.',
        parameters: [
          McpFunctionParameter(name: 'to', type: 'array', description: 'List of recipient email addresses', required: true),
          McpFunctionParameter(name: 'cc', type: 'array', description: 'List of CC email addresses (optional)', required: false),
          McpFunctionParameter(name: 'bcc', type: 'array', description: 'List of BCC email addresses (optional)', required: false),
          McpFunctionParameter(name: 'subject', type: 'string', description: 'Email subject', required: true),
          McpFunctionParameter(name: 'body', type: 'string', description: 'Email body (HTML format)', required: true),
        ],
      ),
      McpFunctionSchema(
        name: 'replyMail',
        description: 'Replies to an email.',
        parameters: [
          McpFunctionParameter(name: 'threadId', type: 'string', description: 'Thread ID', required: true),
          McpFunctionParameter(name: 'to', type: 'array', description: 'List of recipient email addresses (optional, defaults to original sender)'),
          McpFunctionParameter(name: 'cc', type: 'array', description: 'List of CC email addresses (optional)'),
          McpFunctionParameter(name: 'subject', type: 'string', description: 'Email subject (optional, "Re: " will be auto-added if not present)'),
          McpFunctionParameter(name: 'body', type: 'string', description: 'Email body (HTML format)', required: true),
        ],
      ),
      McpFunctionSchema(
        name: 'forwardMail',
        description: 'Forwards an email.',
        parameters: [
          McpFunctionParameter(name: 'threadId', type: 'string', description: 'Thread ID', required: true),
          McpFunctionParameter(name: 'to', type: 'array', description: 'List of recipient email addresses', required: true),
          McpFunctionParameter(name: 'cc', type: 'array', description: 'List of CC email addresses (optional)'),
          McpFunctionParameter(name: 'subject', type: 'string', description: 'Email subject (optional, "Fwd: " will be auto-added if not present)'),
          McpFunctionParameter(name: 'body', type: 'string', description: 'Email body (HTML format, optional)'),
        ],
      ),
      McpFunctionSchema(
        name: 'markMailAsRead',
        description: 'Marks an email as read.',
        parameters: [McpFunctionParameter(name: 'threadId', type: 'string', description: 'Thread ID', required: true)],
      ),
      McpFunctionSchema(
        name: 'markMailAsUnread',
        description: 'Marks an email as unread.',
        parameters: [McpFunctionParameter(name: 'threadId', type: 'string', description: 'Thread ID', required: true)],
      ),
      McpFunctionSchema(
        name: 'archiveMail',
        description: 'Archives an email.',
        parameters: [McpFunctionParameter(name: 'threadId', type: 'string', description: 'Thread ID', required: true)],
      ),
      McpFunctionSchema(
        name: 'unarchiveMail',
        description: 'Unarchives an archived email.',
        parameters: [McpFunctionParameter(name: 'threadId', type: 'string', description: 'Thread ID', required: true)],
      ),
      McpFunctionSchema(
        name: 'pinMail',
        description: 'Pins an email.',
        parameters: [McpFunctionParameter(name: 'threadId', type: 'string', description: 'Thread ID', required: true)],
      ),
      McpFunctionSchema(
        name: 'unpinMail',
        description: 'Unpins a pinned email.',
        parameters: [McpFunctionParameter(name: 'threadId', type: 'string', description: 'Thread ID', required: true)],
      ),
      McpFunctionSchema(
        name: 'markMailAsImportant',
        description: 'Marks an email as important.',
        parameters: [McpFunctionParameter(name: 'threadId', type: 'string', description: 'Thread ID', required: true)],
      ),
      McpFunctionSchema(
        name: 'markMailAsNotImportant',
        description: 'Removes the important mark from an email.',
        parameters: [McpFunctionParameter(name: 'threadId', type: 'string', description: 'Thread ID', required: true)],
      ),
      McpFunctionSchema(
        name: 'spamMail',
        description: 'Marks an email as spam.',
        parameters: [McpFunctionParameter(name: 'threadId', type: 'string', description: 'Thread ID', required: true)],
      ),
      McpFunctionSchema(
        name: 'unspamMail',
        description: 'Removes the spam mark from an email.',
        parameters: [McpFunctionParameter(name: 'threadId', type: 'string', description: 'Thread ID', required: true)],
      ),
      McpFunctionSchema(
        name: 'deleteMail',
        description: 'Deletes an email.',
        parameters: [McpFunctionParameter(name: 'threadId', type: 'string', description: 'Thread ID', required: true)],
      ),
      McpFunctionSchema(
        name: 'replyAllMail',
        description: 'Replies to all recipients of an email.',
        parameters: [McpFunctionParameter(name: 'threadId', type: 'string', description: 'Thread ID', required: true)],
      ),
      McpFunctionSchema(
        name: 'getMailDetails',
        description: 'Gets detailed information about an email.',
        parameters: [McpFunctionParameter(name: 'threadId', type: 'string', description: 'Thread ID', required: true)],
      ),
      McpFunctionSchema(
        name: 'listMails',
        description: 'Gets a list of emails. Can be filtered by label, read status, pinned status.',
        parameters: [
          McpFunctionParameter(name: 'labelId', type: 'string', description: 'Label ID (e.g., "INBOX", "SENT", "DRAFT")'),
          McpFunctionParameter(name: 'email', type: 'string', description: 'Email address'),
          McpFunctionParameter(name: 'isUnread', type: 'boolean', description: 'Get only unread emails'),
          McpFunctionParameter(name: 'isPinned', type: 'boolean', description: 'Get only pinned emails'),
          McpFunctionParameter(name: 'limit', type: 'number', description: 'Maximum number of results'),
        ],
      ),
      McpFunctionSchema(
        name: 'moveMailToLabel',
        description: 'Moves an email to a specific label.',
        parameters: [
          McpFunctionParameter(name: 'threadId', type: 'string', description: 'Thread ID', required: true),
          McpFunctionParameter(name: 'labelId', type: 'string', description: 'Label ID to move to (e.g., "INBOX", "SENT", "DRAFT")', required: true),
        ],
      ),
      McpFunctionSchema(
        name: 'getMailLabels',
        description: 'Gets a list of available email labels.',
        parameters: [McpFunctionParameter(name: 'email', type: 'string', description: 'Email address (optional, if not provided returns labels for all accounts)')],
      ),
      McpFunctionSchema(
        name: 'getMailAttachments',
        description: 'Gets attachments for an email.',
        parameters: [McpFunctionParameter(name: 'threadId', type: 'string', description: 'Thread ID', required: true)],
      ),

      // Message/Chat Actions
      McpFunctionSchema(
        name: 'sendMessage',
        description: 'Sends a message to a channel.',
        parameters: [
          McpFunctionParameter(name: 'channelId', type: 'string', description: 'Channel ID', required: true),
          McpFunctionParameter(name: 'text', type: 'string', description: 'Message content (HTML format)', required: true),
        ],
      ),
      McpFunctionSchema(
        name: 'replyMessage',
        description: 'Replies to a thread.',
        parameters: [
          McpFunctionParameter(name: 'threadId', type: 'string', description: 'Thread ID', required: true),
          McpFunctionParameter(name: 'text', type: 'string', description: 'Message content (HTML format)', required: true),
        ],
      ),
      McpFunctionSchema(
        name: 'editMessage',
        description: 'Edits a message.',
        parameters: [
          McpFunctionParameter(name: 'messageId', type: 'string', description: 'Message ID', required: true),
          McpFunctionParameter(name: 'text', type: 'string', description: 'Updated message content (HTML format)', required: true),
        ],
      ),
      McpFunctionSchema(
        name: 'deleteMessage',
        description: 'Deletes a message.',
        parameters: [McpFunctionParameter(name: 'messageId', type: 'string', description: 'Message ID', required: true)],
      ),
      McpFunctionSchema(
        name: 'addReaction',
        description: 'Adds an emoji reaction to a message.',
        parameters: [
          McpFunctionParameter(name: 'messageId', type: 'string', description: 'Message ID', required: true),
          McpFunctionParameter(name: 'emoji', type: 'string', description: 'Emoji (e.g., ":thumbsup:", ":smile:")', required: true),
        ],
      ),
      McpFunctionSchema(
        name: 'removeReaction',
        description: 'Removes an emoji reaction from a message.',
        parameters: [
          McpFunctionParameter(name: 'messageId', type: 'string', description: 'Message ID', required: true),
          McpFunctionParameter(name: 'emoji', type: 'string', description: 'Emoji (e.g., ":thumbsup:", ":smile:")', required: true),
        ],
      ),
      McpFunctionSchema(
        name: 'getMessageDetails',
        description: 'Gets detailed information about a message.',
        parameters: [McpFunctionParameter(name: 'messageId', type: 'string', description: 'Message ID', required: true)],
      ),
      McpFunctionSchema(
        name: 'listMessages',
        description: 'Gets a list of messages in a channel.',
        parameters: [
          McpFunctionParameter(name: 'channelId', type: 'string', description: 'Channel ID'),
          McpFunctionParameter(name: 'limit', type: 'number', description: 'Maximum number of results'),
        ],
      ),
      McpFunctionSchema(
        name: 'searchMessages',
        description: 'Searches for messages.',
        parameters: [
          McpFunctionParameter(name: 'query', type: 'string', description: 'Search query', required: true),
          McpFunctionParameter(name: 'channelId', type: 'string', description: 'Channel ID (optional, search only in specific channel)'),
        ],
      ),
      McpFunctionSchema(
        name: 'getMessageAttachments',
        description: 'Gets attachments for a message. (Not yet implemented)',
        parameters: [McpFunctionParameter(name: 'messageId', type: 'string', description: 'Message ID', required: true)],
      ),

      // Task/Event Movement and Attachments
      McpFunctionSchema(
        name: 'moveTask',
        description: 'Moves a task to another project.',
        parameters: [
          McpFunctionParameter(name: 'taskId', type: 'string', description: 'Task ID', required: true),
          McpFunctionParameter(name: 'projectId', type: 'string', description: 'Project ID to move to (null to remove from project)'),
        ],
      ),
      McpFunctionSchema(
        name: 'moveEvent',
        description: 'Moves an event to another calendar.',
        parameters: [
          McpFunctionParameter(name: 'eventId', type: 'string', description: 'Event ID', required: true),
          McpFunctionParameter(name: 'calendarId', type: 'string', description: 'Calendar ID to move to', required: true),
        ],
      ),
      McpFunctionSchema(
        name: 'getTaskAttachments',
        description: 'Gets attachments for a task. (Not yet implemented)',
        parameters: [McpFunctionParameter(name: 'taskId', type: 'string', description: 'Task ID', required: true)],
      ),
      McpFunctionSchema(
        name: 'getEventAttachments',
        description: 'Gets attachments for an event. (Not yet implemented)',
        parameters: [McpFunctionParameter(name: 'eventId', type: 'string', description: 'Event ID', required: true)],
      ),

      // Inbox Actions
      McpFunctionSchema(
        name: 'pinInbox',
        description: 'Pins an inbox item.',
        parameters: [McpFunctionParameter(name: 'inboxId', type: 'string', description: 'Inbox ID', required: true)],
      ),
      McpFunctionSchema(
        name: 'unpinInbox',
        description: 'Unpins a pinned inbox item.',
        parameters: [McpFunctionParameter(name: 'inboxId', type: 'string', description: 'Inbox ID', required: true)],
      ),
      McpFunctionSchema(
        name: 'createTaskFromInbox',
        description: 'Creates a task from an inbox item.',
        parameters: [
          McpFunctionParameter(name: 'inboxId', type: 'string', description: 'Inbox ID', required: true),
          McpFunctionParameter(name: 'title', type: 'string', description: 'Task title (optional, uses inbox title if not provided)'),
          McpFunctionParameter(name: 'projectId', type: 'string', description: 'Project ID (optional)'),
          McpFunctionParameter(name: 'startAt', type: 'string', description: 'Start date/time in ISO 8601 format (optional)'),
          McpFunctionParameter(name: 'endAt', type: 'string', description: 'End date/time in ISO 8601 format (optional)'),
        ],
      ),

      // List/Get Actions
      McpFunctionSchema(
        name: 'listTasks',
        description: 'Gets a list of tasks. Can be filtered by project, status, date range.',
        parameters: [
          McpFunctionParameter(name: 'projectId', type: 'string', description: 'Filter by project ID (optional)'),
          McpFunctionParameter(name: 'status', type: 'string', description: 'Filter by status', enumValues: ['none', 'done', 'cancelled']),
          McpFunctionParameter(name: 'startDate', type: 'string', description: 'Start date in ISO 8601 format (optional)'),
          McpFunctionParameter(name: 'endDate', type: 'string', description: 'End date in ISO 8601 format (optional)'),
          McpFunctionParameter(name: 'limit', type: 'number', description: 'Maximum number of results (optional)'),
        ],
      ),
      McpFunctionSchema(
        name: 'listEvents',
        description: 'Gets a list of calendar events. Can be filtered by calendar, date range.',
        parameters: [
          McpFunctionParameter(name: 'calendarId', type: 'string', description: 'Filter by calendar ID (optional)'),
          McpFunctionParameter(name: 'startDate', type: 'string', description: 'Start date in ISO 8601 format (optional)'),
          McpFunctionParameter(name: 'endDate', type: 'string', description: 'End date in ISO 8601 format (optional)'),
          McpFunctionParameter(name: 'limit', type: 'number', description: 'Maximum number of results (optional)'),
        ],
      ),
      McpFunctionSchema(name: 'listProjects', description: 'Gets a list of projects.', parameters: []),
      McpFunctionSchema(
        name: 'getTaskDetails',
        description: 'Gets detailed information about a specific task.',
        parameters: [McpFunctionParameter(name: 'taskId', type: 'string', description: 'Task ID', required: true)],
      ),
      McpFunctionSchema(
        name: 'getEventDetails',
        description: 'Gets detailed information about a specific event.',
        parameters: [
          McpFunctionParameter(name: 'eventId', type: 'string', description: 'Event ID (either eventId or uniqueId is required)'),
          McpFunctionParameter(name: 'uniqueId', type: 'string', description: 'Unique ID (either eventId or uniqueId is required)'),
        ],
      ),
      McpFunctionSchema(name: 'getCalendarList', description: 'Gets a list of available calendars.', parameters: []),
      McpFunctionSchema(
        name: 'getInboxDetails',
        description: 'Gets detailed information about an inbox item.',
        parameters: [McpFunctionParameter(name: 'inboxId', type: 'string', description: 'Inbox ID', required: true)],
      ),
      McpFunctionSchema(
        name: 'listInboxes',
        description: 'Gets a list of inbox items. Can be filtered by pinned status, linked task status.',
        parameters: [
          McpFunctionParameter(name: 'isPinned', type: 'boolean', description: 'Get only pinned inboxes (optional)'),
          McpFunctionParameter(name: 'hasLinkedTask', type: 'boolean', description: 'Get only inboxes with linked tasks (optional)'),
          McpFunctionParameter(name: 'limit', type: 'number', description: 'Maximum number of results (optional)'),
        ],
      ),

      // Search Actions
      McpFunctionSchema(
        name: 'searchInbox',
        description:
            'Searches inbox for emails or messages. Can search by title, sender, content, etc. When the user mentions a date range (e.g., "today", "this week", "tomorrow"), urgency (e.g., "urgent", "important", "action required"), or specific ID, include those in the scope parameters.',
        parameters: [
          McpFunctionParameter(name: 'query', type: 'string', description: 'Search query (title, sender, content, etc.)', required: true),
          McpFunctionParameter(
            name: 'startDate',
            type: 'string',
            description: 'Start date in ISO 8601 format (YYYY-MM-DDTHH:mm:ss) for filtering results. Use when user mentions "today", "this week", "tomorrow", etc. (optional)',
            required: false,
          ),
          McpFunctionParameter(
            name: 'endDate',
            type: 'string',
            description: 'End date in ISO 8601 format (YYYY-MM-DDTHH:mm:ss) for filtering results. Use when user mentions a date range. (optional)',
            required: false,
          ),
          McpFunctionParameter(name: 'inboxId', type: 'string', description: 'Filter by specific inbox ID (optional)', required: false),
          McpFunctionParameter(
            name: 'urgency',
            type: 'string',
            description:
                'Filter by urgency level. Use when user mentions "urgent", "important", "action required", "꼭 봐야", "중요", "조치 필요". Values: "urgent", "important", "action_required", "need_review" (optional)',
            enumValues: ['urgent', 'important', 'action_required', 'need_review'],
            required: false,
          ),
        ],
      ),
      McpFunctionSchema(
        name: 'searchTask',
        description:
            'Searches for tasks. Can search by title or description. When the user mentions a date range (e.g., "today", "this week"), include those in the scope parameters. At least one of query, startDate, endDate, or taskId must be provided.',
        parameters: [
          McpFunctionParameter(name: 'query', type: 'string', description: 'Search query (title, description, etc.)', required: false),
          McpFunctionParameter(name: 'isDone', type: 'boolean', description: 'Search only completed tasks (optional)', required: false),
          McpFunctionParameter(
            name: 'startDate',
            type: 'string',
            description: 'Start date in ISO 8601 format (YYYY-MM-DDTHH:mm:ss) for filtering results. Use when user mentions "today", "this week", "tomorrow", etc. (optional)',
            required: false,
          ),
          McpFunctionParameter(
            name: 'endDate',
            type: 'string',
            description: 'End date in ISO 8601 format (YYYY-MM-DDTHH:mm:ss) for filtering results. Use when user mentions a date range. (optional)',
            required: false,
          ),
          McpFunctionParameter(name: 'taskId', type: 'string', description: 'Filter by specific task ID (optional)', required: false),
        ],
      ),
      McpFunctionSchema(
        name: 'searchCalendarEvent',
        description:
            'Searches for calendar events. Can search by title or description. When the user mentions a date range (e.g., "today", "this week"), include those in the scope parameters. At least one of query, startDate, endDate, or eventId must be provided.',
        parameters: [
          McpFunctionParameter(name: 'query', type: 'string', description: 'Search query (title, description, etc.)', required: false),
          McpFunctionParameter(
            name: 'startDate',
            type: 'string',
            description: 'Start date in ISO 8601 format (YYYY-MM-DDTHH:mm:ss) for filtering results. Use when user mentions "today", "this week", "tomorrow", etc. (optional)',
            required: false,
          ),
          McpFunctionParameter(
            name: 'endDate',
            type: 'string',
            description: 'End date in ISO 8601 format (YYYY-MM-DDTHH:mm:ss) for filtering results. Use when user mentions a date range. (optional)',
            required: false,
          ),
          McpFunctionParameter(name: 'eventId', type: 'string', description: 'Filter by specific event ID (optional)', required: false),
        ],
      ),
      McpFunctionSchema(
        name: 'getPreviousContext',
        description:
            'Gets the conversation summary (previous context) for a task, event, or inbox item. Uses AI to generate a summary of related conversations, emails, and messages.',
        parameters: [
          McpFunctionParameter(name: 'taskId', type: 'string', description: 'Task ID (optional, provide if getting context for a task)', required: false),
          McpFunctionParameter(name: 'eventId', type: 'string', description: 'Event ID (optional, provide if getting context for an event)', required: false),
          McpFunctionParameter(name: 'inboxId', type: 'string', description: 'Inbox ID (optional, provide if getting context for an inbox item)', required: false),
        ],
      ),
      McpFunctionSchema(
        name: 'summarizeAttachment',
        description:
            '**MANDATORY FUNCTION FOR ATTACHMENT REQUESTS**: When the user asks to read, summarize, analyze, or open attachments/files (e.g., "첨부파일 요약해줘", "첨부파일 열어서", "PDF 읽어서", "attachment summary", "open attachment"), you MUST call this function. It downloads attachments, converts PDFs to images, and extracts text content. The inboxId can be found in the current conversation context (look for "Inbox ID" or inbox items mentioned above).',
        parameters: [
          McpFunctionParameter(
            name: 'inboxId',
            type: 'string',
            description:
                'Inbox ID that contains the attachment. Find this in the current context - look for inbox items shown above or use the inboxId from "View Previous Context" section. Format: mail_<type>_<email>_<messageId> or message_<type>_<teamId>_<messageId>',
            required: true,
          ),
          McpFunctionParameter(name: 'attachmentId', type: 'string', description: 'Attachment ID (optional, if not provided, all attachments will be processed)', required: false),
        ],
      ),
    ];
  }

  /// Returns function schemas as JSON format (for use in AI prompts).
  static String getFunctionsJson() {
    final functions = getAllFunctions();
    final functionsJson = functions.map((f) => f.toJson()).toList();
    return functionsJson.toString();
  }

  /// Returns function schemas in OpenAI function call format.
  static List<Map<String, dynamic>> getOpenAiFunctions() {
    return getAllFunctions().map((f) => f.toJson()).toList();
  }

  /// Returns function schemas in Google AI (Gemini) function calling format.
  static List<Map<String, dynamic>> getGoogleAiFunctions() {
    return getAllFunctions().map((f) {
      final json = f.toJson();
      return {'name': json['name'], 'description': json['description'], 'parameters': json['parameters']};
    }).toList();
  }

  /// Returns function schemas in Anthropic Claude function calling format.
  static List<Map<String, dynamic>> getAnthropicFunctions() {
    return getAllFunctions().map((f) {
      final json = f.toJson();
      return {'name': json['name'], 'description': json['description'], 'input_schema': json['parameters']};
    }).toList();
  }
}
