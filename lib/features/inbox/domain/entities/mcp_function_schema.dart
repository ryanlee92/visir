/// MCP (Model Context Protocol) 스타일의 함수 호출 스키마 정의
/// AI가 actions.dart에 있는 함수들을 동적으로 호출할 수 있도록 합니다.

class McpFunctionSchema {
  final String name;
  final String description;
  final List<McpFunctionParameter> parameters;
  final String? returnType;

  const McpFunctionSchema({
    required this.name,
    required this.description,
    required this.parameters,
    this.returnType,
  });

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

  const McpFunctionParameter({
    required this.name,
    required this.type,
    required this.description,
    this.enumValues,
    this.required,
  });
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
          McpFunctionParameter(name: 'startAt', type: 'string', description: '시작 날짜/시간 (ISO 8601 형식, 선택사항)'),
          McpFunctionParameter(name: 'endAt', type: 'string', description: '종료 날짜/시간 (ISO 8601 형식, 선택사항)'),
          McpFunctionParameter(name: 'isAllDay', type: 'boolean', description: '하루 종일 작업 여부 (기본값: false)'),
          McpFunctionParameter(name: 'status', type: 'string', description: '작업 상태', enumValues: ['none', 'done', 'cancelled']),
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
        ],
      ),
      McpFunctionSchema(
        name: 'deleteTask',
        description: '작업을 삭제합니다.',
        parameters: [
          McpFunctionParameter(name: 'taskId', type: 'string', description: '작업 ID', required: true),
        ],
      ),
      McpFunctionSchema(
        name: 'toggleTaskStatus',
        description: '작업의 완료 상태를 토글합니다 (완료 ↔ 미완료).',
        parameters: [
          McpFunctionParameter(name: 'taskId', type: 'string', description: '작업 ID', required: true),
        ],
      ),

      // Calendar Actions
      McpFunctionSchema(
        name: 'createEvent',
        description: '새로운 일정을 생성합니다. 제목, 설명, 날짜/시간, 위치, 참석자 등을 설정할 수 있습니다.',
        parameters: [
          McpFunctionParameter(name: 'title', type: 'string', description: '일정 제목', required: true),
          McpFunctionParameter(name: 'description', type: 'string', description: '일정 설명 (선택사항)'),
          McpFunctionParameter(name: 'calendarId', type: 'string', description: '캘린더 ID (선택사항)'),
          McpFunctionParameter(name: 'startAt', type: 'string', description: '시작 날짜/시간 (ISO 8601 형식, 선택사항)'),
          McpFunctionParameter(name: 'endAt', type: 'string', description: '종료 날짜/시간 (ISO 8601 형식, 선택사항)'),
          McpFunctionParameter(name: 'isAllDay', type: 'boolean', description: '하루 종일 일정 여부 (기본값: false)'),
          McpFunctionParameter(name: 'location', type: 'string', description: '장소 (선택사항)'),
          McpFunctionParameter(name: 'attendees', type: 'array', description: '참석자 이메일 목록 (선택사항)'),
          McpFunctionParameter(name: 'conferenceLink', type: 'string', description: '화상회의 링크 (선택사항, "added"로 설정하면 자동 생성)'),
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
        ],
      ),
      McpFunctionSchema(
        name: 'deleteEvent',
        description: '일정을 삭제합니다.',
        parameters: [
          McpFunctionParameter(name: 'eventId', type: 'string', description: '일정 ID', required: true),
        ],
      ),
      McpFunctionSchema(
        name: 'responseCalendarInvitation',
        description: '캘린더 초대에 응답합니다.',
        parameters: [
          McpFunctionParameter(name: 'eventId', type: 'string', description: '일정 ID', required: true),
          McpFunctionParameter(
            name: 'response',
            type: 'string',
            description: '응답 상태',
            enumValues: ['accepted', 'declined', 'tentative'],
            required: true,
          ),
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
        parameters: [
          McpFunctionParameter(name: 'threadId', type: 'string', description: '스레드 ID', required: true),
        ],
      ),
      McpFunctionSchema(
        name: 'markMailAsUnread',
        description: '이메일을 읽지 않음으로 표시합니다.',
        parameters: [
          McpFunctionParameter(name: 'threadId', type: 'string', description: '스레드 ID', required: true),
        ],
      ),
      McpFunctionSchema(
        name: 'archiveMail',
        description: '이메일을 보관합니다.',
        parameters: [
          McpFunctionParameter(name: 'threadId', type: 'string', description: '스레드 ID', required: true),
        ],
      ),
      McpFunctionSchema(
        name: 'deleteMail',
        description: '이메일을 삭제합니다.',
        parameters: [
          McpFunctionParameter(name: 'threadId', type: 'string', description: '스레드 ID', required: true),
        ],
      ),

      // Search Actions
      McpFunctionSchema(
        name: 'searchInbox',
        description: '인박스에서 이메일이나 메시지를 검색합니다. 검색어로 제목, 발신자, 내용 등을 검색할 수 있습니다.',
        parameters: [
          McpFunctionParameter(name: 'query', type: 'string', description: '검색어 (제목, 발신자, 내용 등)', required: true),
        ],
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
        parameters: [
          McpFunctionParameter(name: 'query', type: 'string', description: '검색어 (제목, 설명 등)', required: true),
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

