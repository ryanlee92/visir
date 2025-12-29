/// MCP (Model Context Protocol) 스타일의 함수 호출 스키마 정의
/// AI가 actions.dart에 있는 함수들을 동적으로 호출할 수 있도록 합니다.

class McpFunctionSchema {
  final String name;
  final String description;
  final List<McpFunctionParameter> parameters;
  final String? returnType;

  const McpFunctionSchema({required this.name, required this.description, required this.parameters, this.returnType});

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'parameters': {
        'type': 'object',
        'properties': {
          for (final param in parameters)
            param.name: {
              'type': param.type,
              'description': param.description,
              if (param.enumValues != null) 'enum': param.enumValues,
              if (param.required != null) 'required': param.required,
            },
        },
        'required': parameters.where((p) => p.required ?? false).map((p) => p.name).toList(),
      },
      if (returnType != null) 'returns': returnType,
    };
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

/// 사용 가능한 모든 함수 스키마를 정의합니다.
class McpFunctionRegistry {
  static List<McpFunctionSchema> getAllFunctions() {
    return [
      // Task Actions
      McpFunctionSchema(
        name: 'createTask',
        description: '새로운 작업을 생성합니다. 작업 제목, 설명, 프로젝트, 날짜 등을 설정할 수 있습니다.',
        parameters: [
          McpFunctionParameter(name: 'title', type: 'string', description: '작업 제목', required: true),
          McpFunctionParameter(name: 'description', type: 'string', description: '작업 설명 (선택사항)'),
          McpFunctionParameter(name: 'projectId', type: 'string', description: '프로젝트 ID (선택사항)'),
          McpFunctionParameter(
            name: 'startAt',
            type: 'string',
            description: '시작 날짜/시간 (ISO 8601 형식: YYYY-MM-DDTHH:mm:ss, 예: "2024-01-01T09:00:00", 선택사항). 필드명은 startAt을 사용하세요 (start_at 아님).',
            required: false,
          ),
          McpFunctionParameter(
            name: 'endAt',
            type: 'string',
            description: '종료 날짜/시간 (ISO 8601 형식: YYYY-MM-DDTHH:mm:ss, 예: "2024-01-01T10:00:00", 선택사항). 필드명은 endAt을 사용하세요 (end_at 아님).',
            required: false,
          ),
          McpFunctionParameter(name: 'isAllDay', type: 'boolean', description: '하루 종일 작업 여부 (기본값: false)', required: false),
          McpFunctionParameter(name: 'status', type: 'string', description: '작업 상태 (기본값: "none")', enumValues: ['none', 'done', 'cancelled'], required: false),
          McpFunctionParameter(
            name: 'rrule',
            type: 'string',
            description: '반복 규칙 (RFC 5545 RRULE 형식, 예: "FREQ=DAILY", "FREQ=WEEKLY;BYDAY=MO", "FREQ=MONTHLY", 선택사항)',
            required: false,
          ),
          McpFunctionParameter(name: 'reminders', type: 'array', description: '알림 목록 (선택사항). 각 항목은 {"method": "push"|"email", "minutes": number} 형식', required: false),
          McpFunctionParameter(name: 'recurrenceEndAt', type: 'string', description: '반복 종료 날짜/시간 (ISO 8601 형식: YYYY-MM-DDTHH:mm:ss, 선택사항)', required: false),
          McpFunctionParameter(name: 'excludedRecurrenceDate', type: 'array', description: '제외된 반복 날짜 목록 (ISO 8601 형식 문자열 배열, 선택사항)', required: false),
          McpFunctionParameter(name: 'from', type: 'string', description: '작업이 생성된 소스 (예: GitHub, Email 등, 선택사항)', required: false),
          McpFunctionParameter(name: 'subject', type: 'string', description: '원본 제목 또는 주제 (선택사항)', required: false),
          McpFunctionParameter(name: 'actionNeeded', type: 'string', description: '필요한 액션 설명 (선택사항)', required: false),
        ],
      ),
      McpFunctionSchema(
        name: 'updateTask',
        description: '기존 작업을 업데이트합니다.',
        parameters: [
          McpFunctionParameter(name: 'taskId', type: 'string', description: '작업 ID', required: true),
          McpFunctionParameter(name: 'title', type: 'string', description: '작업 제목'),
          McpFunctionParameter(name: 'description', type: 'string', description: '작업 설명'),
          McpFunctionParameter(name: 'projectId', type: 'string', description: '프로젝트 ID'),
          McpFunctionParameter(name: 'startAt', type: 'string', description: '시작 날짜/시간 (ISO 8601 형식)'),
          McpFunctionParameter(name: 'endAt', type: 'string', description: '종료 날짜/시간 (ISO 8601 형식)'),
          McpFunctionParameter(name: 'isAllDay', type: 'boolean', description: '하루 종일 작업 여부'),
          McpFunctionParameter(name: 'status', type: 'string', description: '작업 상태', enumValues: ['none', 'done', 'cancelled']),
          McpFunctionParameter(name: 'rrule', type: 'string', description: '반복 규칙 (RFC 5545 RRULE 형식, 예: "FREQ=DAILY", "FREQ=WEEKLY;BYDAY=MO", 선택사항)'),
          McpFunctionParameter(name: 'reminders', type: 'array', description: '알림 목록 (선택사항). 각 항목은 {"method": "push"|"email", "minutes": number} 형식'),
          McpFunctionParameter(name: 'recurrenceEndAt', type: 'string', description: '반복 종료 날짜/시간 (ISO 8601 형식, 선택사항)'),
          McpFunctionParameter(name: 'excludedRecurrenceDate', type: 'array', description: '제외된 반복 날짜 목록 (ISO 8601 형식 문자열 배열, 선택사항)'),
        ],
      ),
      McpFunctionSchema(
        name: 'deleteTask',
        description: '작업을 삭제합니다.',
        parameters: [McpFunctionParameter(name: 'taskId', type: 'string', description: '작업 ID', required: true)],
      ),
      McpFunctionSchema(
        name: 'toggleTaskStatus',
        description: '작업의 완료 상태를 토글합니다 (완료 ↔ 미완료).',
        parameters: [McpFunctionParameter(name: 'taskId', type: 'string', description: '작업 ID', required: true)],
      ),

      // Calendar Actions
      McpFunctionSchema(
        name: 'createEvent',
        description: '새로운 일정을 생성합니다. 제목, 설명, 날짜/시간, 위치, 참석자 등을 설정할 수 있습니다.',
        parameters: [
          McpFunctionParameter(name: 'title', type: 'string', description: '일정 제목', required: true),
          McpFunctionParameter(name: 'description', type: 'string', description: '일정 설명 (선택사항)', required: false),
          McpFunctionParameter(name: 'calendarId', type: 'string', description: '캘린더 ID (선택사항)', required: false),
          McpFunctionParameter(
            name: 'startAt',
            type: 'string',
            description: '시작 날짜/시간 (ISO 8601 형식: YYYY-MM-DDTHH:mm:ss, 예: "2024-01-01T09:00:00", 선택사항). 필드명은 startAt을 사용하세요 (start_at 아님).',
            required: false,
          ),
          McpFunctionParameter(
            name: 'endAt',
            type: 'string',
            description: '종료 날짜/시간 (ISO 8601 형식: YYYY-MM-DDTHH:mm:ss, 예: "2024-01-01T10:00:00", 선택사항). 필드명은 endAt을 사용하세요 (end_at 아님).',
            required: false,
          ),
          McpFunctionParameter(name: 'isAllDay', type: 'boolean', description: '하루 종일 일정 여부 (기본값: false)', required: false),
          McpFunctionParameter(name: 'location', type: 'string', description: '장소 (선택사항)', required: false),
          McpFunctionParameter(name: 'attendees', type: 'array', description: '참석자 이메일 목록 (선택사항, 예: ["email1@example.com", "email2@example.com"])', required: false),
          McpFunctionParameter(name: 'conferenceLink', type: 'string', description: '화상회의 링크 (선택사항, "added"로 설정하면 자동 생성)', required: false),
          McpFunctionParameter(
            name: 'rrule',
            type: 'string',
            description: '반복 규칙 (RFC 5545 RRULE 형식, 예: "FREQ=DAILY", "FREQ=WEEKLY;BYDAY=MO", "FREQ=MONTHLY", 선택사항)',
            required: false,
          ),
          McpFunctionParameter(name: 'reminders', type: 'array', description: '알림 목록 (선택사항). 각 항목은 {"method": "push"|"email", "minutes": number} 형식', required: false),
          McpFunctionParameter(name: 'timezone', type: 'string', description: '타임존 (선택사항, 예: "America/New_York", "Asia/Seoul". 기본값: 사용자 설정 타임존)', required: false),
          McpFunctionParameter(name: 'from', type: 'string', description: '일정이 생성된 소스 (예: GitHub, Email 등, 선택사항)', required: false),
          McpFunctionParameter(name: 'subject', type: 'string', description: '원본 제목 또는 주제 (선택사항)', required: false),
          McpFunctionParameter(name: 'actionNeeded', type: 'string', description: '필요한 액션 설명 (선택사항)', required: false),
        ],
      ),
      McpFunctionSchema(
        name: 'updateEvent',
        description: '기존 일정을 업데이트합니다.',
        parameters: [
          McpFunctionParameter(name: 'eventId', type: 'string', description: '일정 ID', required: true),
          McpFunctionParameter(name: 'title', type: 'string', description: '일정 제목'),
          McpFunctionParameter(name: 'description', type: 'string', description: '일정 설명'),
          McpFunctionParameter(name: 'startAt', type: 'string', description: '시작 날짜/시간 (ISO 8601 형식)'),
          McpFunctionParameter(name: 'endAt', type: 'string', description: '종료 날짜/시간 (ISO 8601 형식)'),
          McpFunctionParameter(name: 'isAllDay', type: 'boolean', description: '하루 종일 일정 여부'),
          McpFunctionParameter(name: 'location', type: 'string', description: '장소'),
          McpFunctionParameter(name: 'attendees', type: 'array', description: '참석자 이메일 목록'),
          McpFunctionParameter(name: 'rrule', type: 'string', description: '반복 규칙 (RFC 5545 RRULE 형식, 예: "FREQ=DAILY", "FREQ=WEEKLY;BYDAY=MO", 선택사항)'),
          McpFunctionParameter(name: 'reminders', type: 'array', description: '알림 목록 (선택사항). 각 항목은 {"method": "push"|"email", "minutes": number} 형식'),
          McpFunctionParameter(name: 'timezone', type: 'string', description: '타임존 (선택사항, 예: "America/New_York", "Asia/Seoul")'),
          McpFunctionParameter(name: 'conferenceLink', type: 'string', description: '화상회의 링크 (선택사항, "added"로 설정하면 자동 생성)'),
        ],
      ),
      McpFunctionSchema(
        name: 'deleteEvent',
        description: '일정을 삭제합니다.',
        parameters: [McpFunctionParameter(name: 'eventId', type: 'string', description: '일정 ID', required: true)],
      ),
      McpFunctionSchema(
        name: 'responseCalendarInvitation',
        description: '캘린더 초대에 응답합니다.',
        parameters: [
          McpFunctionParameter(name: 'eventId', type: 'string', description: '일정 ID', required: true),
          McpFunctionParameter(name: 'response', type: 'string', description: '응답 상태', enumValues: ['accepted', 'declined', 'tentative'], required: true),
        ],
      ),

      // Mail Actions
      McpFunctionSchema(
        name: 'sendMail',
        description: '이메일을 전송합니다.',
        parameters: [
          McpFunctionParameter(name: 'to', type: 'array', description: '받는 사람 이메일 목록', required: true),
          McpFunctionParameter(name: 'cc', type: 'array', description: '참조 이메일 목록 (선택사항)'),
          McpFunctionParameter(name: 'bcc', type: 'array', description: '숨은 참조 이메일 목록 (선택사항)'),
          McpFunctionParameter(name: 'subject', type: 'string', description: '이메일 제목', required: true),
          McpFunctionParameter(name: 'body', type: 'string', description: '이메일 본문 (HTML 형식)', required: true),
        ],
      ),
      McpFunctionSchema(
        name: 'replyMail',
        description: '이메일에 답장합니다.',
        parameters: [
          McpFunctionParameter(name: 'threadId', type: 'string', description: '스레드 ID', required: true),
          McpFunctionParameter(name: 'to', type: 'array', description: '받는 사람 이메일 목록 (선택사항, 없으면 원본 발신자에게)'),
          McpFunctionParameter(name: 'cc', type: 'array', description: '참조 이메일 목록 (선택사항)'),
          McpFunctionParameter(name: 'subject', type: 'string', description: '이메일 제목 (선택사항, 없으면 "Re: " 자동 추가)'),
          McpFunctionParameter(name: 'body', type: 'string', description: '이메일 본문 (HTML 형식)', required: true),
        ],
      ),
      McpFunctionSchema(
        name: 'forwardMail',
        description: '이메일을 전달합니다.',
        parameters: [
          McpFunctionParameter(name: 'threadId', type: 'string', description: '스레드 ID', required: true),
          McpFunctionParameter(name: 'to', type: 'array', description: '받는 사람 이메일 목록', required: true),
          McpFunctionParameter(name: 'cc', type: 'array', description: '참조 이메일 목록 (선택사항)'),
          McpFunctionParameter(name: 'subject', type: 'string', description: '이메일 제목 (선택사항, 없으면 "Fwd: " 자동 추가)'),
          McpFunctionParameter(name: 'body', type: 'string', description: '이메일 본문 (HTML 형식, 선택사항)'),
        ],
      ),
      McpFunctionSchema(
        name: 'markMailAsRead',
        description: '이메일을 읽음으로 표시합니다.',
        parameters: [McpFunctionParameter(name: 'threadId', type: 'string', description: '스레드 ID', required: true)],
      ),
      McpFunctionSchema(
        name: 'markMailAsUnread',
        description: '이메일을 읽지 않음으로 표시합니다.',
        parameters: [McpFunctionParameter(name: 'threadId', type: 'string', description: '스레드 ID', required: true)],
      ),
      McpFunctionSchema(
        name: 'archiveMail',
        description: '이메일을 보관합니다.',
        parameters: [McpFunctionParameter(name: 'threadId', type: 'string', description: '스레드 ID', required: true)],
      ),
      McpFunctionSchema(
        name: 'deleteMail',
        description: '이메일을 삭제합니다.',
        parameters: [McpFunctionParameter(name: 'threadId', type: 'string', description: '스레드 ID', required: true)],
      ),

      // Project Actions (continued)
      McpFunctionSchema(
        name: 'updateProject',
        description: '기존 프로젝트를 업데이트합니다.',
        parameters: [
          McpFunctionParameter(name: 'projectId', type: 'string', description: '프로젝트 ID', required: true),
          McpFunctionParameter(name: 'name', type: 'string', description: '프로젝트 이름'),
          McpFunctionParameter(name: 'description', type: 'string', description: '프로젝트 설명'),
        ],
      ),
      McpFunctionSchema(
        name: 'deleteProject',
        description: '프로젝트를 삭제합니다.',
        parameters: [McpFunctionParameter(name: 'projectId', type: 'string', description: '프로젝트 ID', required: true)],
      ),
      McpFunctionSchema(
        name: 'searchProject',
        description: '프로젝트를 검색합니다. 검색어로 이름이나 설명을 검색할 수 있습니다.',
        parameters: [McpFunctionParameter(name: 'query', type: 'string', description: '검색어 (이름, 설명 등)', required: true)],
      ),
      McpFunctionSchema(
        name: 'moveProject',
        description: '프로젝트를 다른 프로젝트의 하위 프로젝트로 이동하거나 루트로 이동합니다.',
        parameters: [
          McpFunctionParameter(name: 'projectId', type: 'string', description: '이동할 프로젝트 ID', required: true),
          McpFunctionParameter(name: 'newParentId', type: 'string', description: '새 부모 프로젝트 ID (null이면 루트로 이동)'),
        ],
      ),
      McpFunctionSchema(
        name: 'inviteUserToProject',
        description: '프로젝트에 사용자를 초대합니다.',
        parameters: [
          McpFunctionParameter(name: 'projectId', type: 'string', description: '프로젝트 ID', required: true),
          McpFunctionParameter(name: 'email', type: 'string', description: '초대할 사용자의 이메일 주소', required: true),
        ],
      ),
      McpFunctionSchema(
        name: 'removeUserFromProject',
        description: '프로젝트에서 사용자를 제거합니다.',
        parameters: [
          McpFunctionParameter(name: 'projectId', type: 'string', description: '프로젝트 ID', required: true),
          McpFunctionParameter(name: 'userId', type: 'string', description: '제거할 사용자 ID', required: true),
        ],
      ),

      // List/Get Actions
      McpFunctionSchema(
        name: 'listTasks',
        description: '작업 목록을 가져옵니다. 프로젝트, 상태, 날짜 범위로 필터링할 수 있습니다.',
        parameters: [
          McpFunctionParameter(name: 'projectId', type: 'string', description: '프로젝트 ID로 필터링 (선택사항)'),
          McpFunctionParameter(name: 'status', type: 'string', description: '상태로 필터링', enumValues: ['none', 'done', 'cancelled']),
          McpFunctionParameter(name: 'startDate', type: 'string', description: '시작 날짜 (ISO 8601 형식, 선택사항)'),
          McpFunctionParameter(name: 'endDate', type: 'string', description: '종료 날짜 (ISO 8601 형식, 선택사항)'),
          McpFunctionParameter(name: 'limit', type: 'number', description: '결과 개수 제한 (선택사항)'),
        ],
      ),
      McpFunctionSchema(
        name: 'listEvents',
        description: '일정 목록을 가져옵니다. 캘린더, 날짜 범위로 필터링할 수 있습니다.',
        parameters: [
          McpFunctionParameter(name: 'calendarId', type: 'string', description: '캘린더 ID로 필터링 (선택사항)'),
          McpFunctionParameter(name: 'startDate', type: 'string', description: '시작 날짜 (ISO 8601 형식, 선택사항)'),
          McpFunctionParameter(name: 'endDate', type: 'string', description: '종료 날짜 (ISO 8601 형식, 선택사항)'),
          McpFunctionParameter(name: 'limit', type: 'number', description: '결과 개수 제한 (선택사항)'),
        ],
      ),
      McpFunctionSchema(name: 'listProjects', description: '프로젝트 목록을 가져옵니다.', parameters: []),
      McpFunctionSchema(
        name: 'getTaskDetails',
        description: '특정 작업의 상세 정보를 가져옵니다.',
        parameters: [McpFunctionParameter(name: 'taskId', type: 'string', description: '작업 ID', required: true)],
      ),
      McpFunctionSchema(
        name: 'getEventDetails',
        description: '특정 일정의 상세 정보를 가져옵니다.',
        parameters: [
          McpFunctionParameter(name: 'eventId', type: 'string', description: '일정 ID (eventId 또는 uniqueId 중 하나 필요)'),
          McpFunctionParameter(name: 'uniqueId', type: 'string', description: '고유 ID (eventId 또는 uniqueId 중 하나 필요)'),
        ],
      ),
      McpFunctionSchema(name: 'getCalendarList', description: '사용 가능한 캘린더 목록을 가져옵니다.', parameters: []),
      McpFunctionSchema(name: 'getUnscheduledTasks', description: '스케줄되지 않은 작업 목록을 가져옵니다.', parameters: []),
      McpFunctionSchema(
        name: 'getCompletedTasks',
        description: '완료된 작업 목록을 가져옵니다.',
        parameters: [McpFunctionParameter(name: 'limit', type: 'number', description: '결과 개수 제한 (선택사항)')],
      ),
      McpFunctionSchema(
        name: 'removeReminder',
        description: '작업이나 일정에서 알림을 제거합니다.',
        parameters: [
          McpFunctionParameter(name: 'taskId', type: 'string', description: '작업 ID (taskId 또는 eventId 중 하나 필요)'),
          McpFunctionParameter(name: 'eventId', type: 'string', description: '일정 ID (taskId 또는 eventId 중 하나 필요)'),
        ],
      ),
      McpFunctionSchema(
        name: 'removeRecurrence',
        description: '작업이나 일정에서 반복 규칙을 제거합니다.',
        parameters: [
          McpFunctionParameter(name: 'taskId', type: 'string', description: '작업 ID (taskId 또는 eventId 중 하나 필요)'),
          McpFunctionParameter(name: 'eventId', type: 'string', description: '일정 ID (taskId 또는 eventId 중 하나 필요)'),
        ],
      ),
      McpFunctionSchema(
        name: 'getInboxDetails',
        description: '인박스의 상세 정보를 가져옵니다.',
        parameters: [McpFunctionParameter(name: 'inboxId', type: 'string', description: '인박스 ID', required: true)],
      ),
      McpFunctionSchema(
        name: 'listInboxes',
        description: '인박스 목록을 가져옵니다. 고정 여부, 연결된 작업 여부로 필터링할 수 있습니다.',
        parameters: [
          McpFunctionParameter(name: 'isPinned', type: 'boolean', description: '고정된 인박스만 가져오기 (선택사항)'),
          McpFunctionParameter(name: 'hasLinkedTask', type: 'boolean', description: '연결된 작업이 있는 인박스만 가져오기 (선택사항)'),
          McpFunctionParameter(name: 'limit', type: 'number', description: '결과 개수 제한 (선택사항)'),
        ],
      ),
      McpFunctionSchema(
        name: 'pinInbox',
        description: '인박스 항목을 고정합니다.',
        parameters: [McpFunctionParameter(name: 'inboxId', type: 'string', description: '인박스 ID', required: true)],
      ),
      McpFunctionSchema(
        name: 'unpinInbox',
        description: '고정된 인박스 항목의 고정을 해제합니다.',
        parameters: [McpFunctionParameter(name: 'inboxId', type: 'string', description: '인박스 ID', required: true)],
      ),
      McpFunctionSchema(
        name: 'createTaskFromInbox',
        description: '인박스 항목에서 작업을 생성합니다.',
        parameters: [
          McpFunctionParameter(name: 'inboxId', type: 'string', description: '인박스 ID', required: true),
          McpFunctionParameter(name: 'title', type: 'string', description: '작업 제목 (선택사항, 없으면 인박스 제목 사용)'),
          McpFunctionParameter(name: 'projectId', type: 'string', description: '프로젝트 ID (선택사항)'),
          McpFunctionParameter(name: 'startAt', type: 'string', description: '시작 날짜/시간 (ISO 8601 형식, 선택사항)'),
          McpFunctionParameter(name: 'endAt', type: 'string', description: '종료 날짜/시간 (ISO 8601 형식, 선택사항)'),
        ],
      ),
      McpFunctionSchema(
        name: 'moveTask',
        description: '작업을 다른 프로젝트로 이동합니다.',
        parameters: [
          McpFunctionParameter(name: 'taskId', type: 'string', description: '작업 ID', required: true),
          McpFunctionParameter(name: 'projectId', type: 'string', description: '이동할 프로젝트 ID (null이면 프로젝트에서 제거)'),
        ],
      ),
      McpFunctionSchema(
        name: 'moveEvent',
        description: '일정을 다른 캘린더로 이동합니다.',
        parameters: [
          McpFunctionParameter(name: 'eventId', type: 'string', description: '일정 ID', required: true),
          McpFunctionParameter(name: 'calendarId', type: 'string', description: '이동할 캘린더 ID', required: true),
        ],
      ),

      // Search Actions
      McpFunctionSchema(
        name: 'searchInbox',
        description: '인박스에서 이메일이나 메시지를 검색합니다. 검색어로 제목, 발신자, 내용 등을 검색할 수 있습니다.',
        parameters: [McpFunctionParameter(name: 'query', type: 'string', description: '검색어 (제목, 발신자, 내용 등)', required: true)],
      ),
      McpFunctionSchema(
        name: 'searchTask',
        description: '작업을 검색합니다. 검색어로 제목이나 설명을 검색할 수 있습니다.',
        parameters: [
          McpFunctionParameter(name: 'query', type: 'string', description: '검색어 (제목, 설명 등)', required: true),
          McpFunctionParameter(name: 'isDone', type: 'boolean', description: '완료된 작업만 검색할지 여부 (선택사항)'),
        ],
      ),
      McpFunctionSchema(
        name: 'searchCalendarEvent',
        description: '캘린더 일정을 검색합니다. 검색어로 제목이나 설명을 검색할 수 있습니다.',
        parameters: [McpFunctionParameter(name: 'query', type: 'string', description: '검색어 (제목, 설명 등)', required: true)],
      ),
      McpFunctionSchema(
        name: 'replyAllMail',
        description: '메일에 전체 답장을 보냅니다.',
        parameters: [McpFunctionParameter(name: 'threadId', type: 'string', description: '메일 스레드 ID', required: true)],
      ),
      McpFunctionSchema(
        name: 'unarchiveMail',
        description: '보관된 메일을 보관 해제합니다.',
        parameters: [McpFunctionParameter(name: 'threadId', type: 'string', description: '메일 스레드 ID', required: true)],
      ),
      McpFunctionSchema(
        name: 'pinMail',
        description: '메일을 고정합니다.',
        parameters: [McpFunctionParameter(name: 'threadId', type: 'string', description: '메일 스레드 ID', required: true)],
      ),
      McpFunctionSchema(
        name: 'unpinMail',
        description: '고정된 메일을 고정 해제합니다.',
        parameters: [McpFunctionParameter(name: 'threadId', type: 'string', description: '메일 스레드 ID', required: true)],
      ),
      McpFunctionSchema(
        name: 'markMailAsImportant',
        description: '메일을 중요 표시합니다.',
        parameters: [McpFunctionParameter(name: 'threadId', type: 'string', description: '메일 스레드 ID', required: true)],
      ),
      McpFunctionSchema(
        name: 'markMailAsNotImportant',
        description: '메일의 중요 표시를 제거합니다.',
        parameters: [McpFunctionParameter(name: 'threadId', type: 'string', description: '메일 스레드 ID', required: true)],
      ),
      McpFunctionSchema(
        name: 'spamMail',
        description: '메일을 스팸으로 표시합니다.',
        parameters: [McpFunctionParameter(name: 'threadId', type: 'string', description: '메일 스레드 ID', required: true)],
      ),
      McpFunctionSchema(
        name: 'unspamMail',
        description: '스팸 표시를 제거합니다.',
        parameters: [McpFunctionParameter(name: 'threadId', type: 'string', description: '메일 스레드 ID', required: true)],
      ),
      McpFunctionSchema(
        name: 'getMailDetails',
        description: '메일의 상세 정보를 가져옵니다.',
        parameters: [McpFunctionParameter(name: 'threadId', type: 'string', description: '메일 스레드 ID', required: true)],
      ),
      McpFunctionSchema(
        name: 'listMails',
        description: '메일 목록을 가져옵니다. 라벨, 읽음 상태, 고정 상태로 필터링할 수 있습니다.',
        parameters: [
          McpFunctionParameter(name: 'labelId', type: 'string', description: '라벨 ID (예: "INBOX", "SENT", "DRAFT")'),
          McpFunctionParameter(name: 'email', type: 'string', description: '이메일 주소'),
          McpFunctionParameter(name: 'isUnread', type: 'boolean', description: '읽지 않은 메일만 가져오기'),
          McpFunctionParameter(name: 'isPinned', type: 'boolean', description: '고정된 메일만 가져오기'),
          McpFunctionParameter(name: 'limit', type: 'number', description: '결과 개수 제한'),
        ],
      ),
      McpFunctionSchema(
        name: 'moveMailToLabel',
        description: '메일을 특정 라벨로 이동합니다.',
        parameters: [
          McpFunctionParameter(name: 'threadId', type: 'string', description: '메일 스레드 ID', required: true),
          McpFunctionParameter(name: 'labelId', type: 'string', description: '이동할 라벨 ID (예: "INBOX", "SENT", "DRAFT")', required: true),
        ],
      ),
      McpFunctionSchema(
        name: 'getMailLabels',
        description: '사용 가능한 메일 라벨 목록을 가져옵니다.',
        parameters: [McpFunctionParameter(name: 'email', type: 'string', description: '이메일 주소 (선택사항, 없으면 모든 계정의 라벨)')],
      ),
      McpFunctionSchema(
        name: 'sendMessage',
        description: '채널에 메시지를 전송합니다.',
        parameters: [
          McpFunctionParameter(name: 'channelId', type: 'string', description: '채널 ID', required: true),
          McpFunctionParameter(name: 'text', type: 'string', description: '메시지 내용 (HTML 형식)', required: true),
        ],
      ),
      McpFunctionSchema(
        name: 'replyMessage',
        description: '스레드에 답장을 보냅니다.',
        parameters: [
          McpFunctionParameter(name: 'threadId', type: 'string', description: '스레드 ID', required: true),
          McpFunctionParameter(name: 'text', type: 'string', description: '메시지 내용 (HTML 형식)', required: true),
        ],
      ),
      McpFunctionSchema(
        name: 'editMessage',
        description: '메시지를 수정합니다.',
        parameters: [
          McpFunctionParameter(name: 'messageId', type: 'string', description: '메시지 ID', required: true),
          McpFunctionParameter(name: 'text', type: 'string', description: '수정할 메시지 내용 (HTML 형식)', required: true),
        ],
      ),
      McpFunctionSchema(
        name: 'deleteMessage',
        description: '메시지를 삭제합니다.',
        parameters: [McpFunctionParameter(name: 'messageId', type: 'string', description: '메시지 ID', required: true)],
      ),
      McpFunctionSchema(
        name: 'addReaction',
        description: '메시지에 이모지 반응을 추가합니다.',
        parameters: [
          McpFunctionParameter(name: 'messageId', type: 'string', description: '메시지 ID', required: true),
          McpFunctionParameter(name: 'emoji', type: 'string', description: '이모지 (예: ":thumbsup:", ":smile:")', required: true),
        ],
      ),
      McpFunctionSchema(
        name: 'removeReaction',
        description: '메시지에서 이모지 반응을 제거합니다.',
        parameters: [
          McpFunctionParameter(name: 'messageId', type: 'string', description: '메시지 ID', required: true),
          McpFunctionParameter(name: 'emoji', type: 'string', description: '이모지 (예: ":thumbsup:", ":smile:")', required: true),
        ],
      ),
      McpFunctionSchema(
        name: 'getMessageDetails',
        description: '메시지의 상세 정보를 가져옵니다.',
        parameters: [McpFunctionParameter(name: 'messageId', type: 'string', description: '메시지 ID', required: true)],
      ),
      McpFunctionSchema(
        name: 'listMessages',
        description: '채널의 메시지 목록을 가져옵니다.',
        parameters: [
          McpFunctionParameter(name: 'channelId', type: 'string', description: '채널 ID'),
          McpFunctionParameter(name: 'limit', type: 'number', description: '결과 개수 제한'),
        ],
      ),
      McpFunctionSchema(
        name: 'searchMessages',
        description: '메시지를 검색합니다.',
        parameters: [
          McpFunctionParameter(name: 'query', type: 'string', description: '검색어', required: true),
          McpFunctionParameter(name: 'channelId', type: 'string', description: '채널 ID (선택사항, 특정 채널에서만 검색)'),
        ],
      ),
    ];
  }

  /// 함수 스키마 목록을 JSON 형식으로 반환합니다 (AI 프롬프트에 사용).
  static String getFunctionsJson() {
    final functions = getAllFunctions();
    final functionsJson = functions.map((f) => f.toJson()).toList();
    return functionsJson.toString();
  }

  /// 함수 스키마 목록을 OpenAI 함수 호출 형식으로 반환합니다.
  static List<Map<String, dynamic>> getOpenAiFunctions() {
    return getAllFunctions().map((f) => f.toJson()).toList();
  }
}
