# MCP 및 AI 콜 구현 문서

## 목차
1. [개요](#개요)
2. [아키텍처](#아키텍처)
3. [MCP 함수 스키마](#mcp-함수-스키마)
4. [MCP 함수 실행기](#mcp-함수-실행기)
5. [AI 액션 컨트롤러](#ai-액션-컨트롤러)
6. [AI 데이터소스](#ai-데이터소스)
7. [함수 호출 흐름](#함수-호출-흐름)
8. [지원되는 함수 목록](#지원되는-함수-목록)

---

## 개요

이 프로젝트는 **MCP (Model Context Protocol)** 스타일의 함수 호출 시스템을 구현하여 AI가 애플리케이션의 기능들을 동적으로 호출할 수 있도록 합니다. AI는 사용자의 자연어 요청을 받아 적절한 함수를 호출하여 작업, 일정, 이메일 등을 관리할 수 있습니다.

### 주요 특징
- **동적 함수 호출**: AI가 자연어 요청을 분석하여 적절한 함수를 자동으로 호출
- **함수 체이닝**: 여러 함수를 순차적으로 호출하여 복잡한 워크플로우 처리
- **사용자 확인**: 중요한 작업(전송, 삭제 등)은 사용자 확인 후 실행
- **다중 AI 모델 지원**: OpenAI, Google AI (Gemini), Anthropic AI (Claude) 지원
- **컨텍스트 인식**: 프로젝트, 태그된 항목, 인박스 등의 컨텍스트를 활용

---

## 아키텍처

```
┌─────────────────────────────────────────────────────────────┐
│                    사용자 입력 (자연어)                        │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│          AgentActionController                                │
│  - 메시지 관리                                                │
│  - 컨텍스트 구축 (프로젝트, 태그된 항목, 인박스 등)            │
│  - 크레딧 체크                                                │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│          AI Datasource (OpenAI/Google/Anthropic)             │
│  - AI API 호출                                               │
│  - 함수 스키마 제공                                           │
│  - 시스템 프롬프트 구성                                        │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│          AI 응답 (함수 호출 포함)                             │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│          McpFunctionExecutor                                 │
│  - 함수 호출 파싱                                            │
│  - 함수 실행                                                 │
│  - 결과 처리                                                 │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│          Actions (TaskAction, CalendarAction, MailAction)    │
│  - 실제 작업 수행                                            │
└─────────────────────────────────────────────────────────────┘
```

---

## MCP 함수 스키마

### 위치
`lib/features/inbox/domain/entities/mcp_function_schema.dart`

### 구조

#### McpFunctionSchema
함수 스키마를 정의하는 클래스입니다.

```dart
class McpFunctionSchema {
  final String name;                    // 함수 이름
  final String description;             // 함수 설명
  final List<McpFunctionParameter> parameters;  // 파라미터 목록
  final String? returnType;             // 반환 타입 (선택사항)
}
```

#### McpFunctionParameter
함수 파라미터를 정의하는 클래스입니다.

```dart
class McpFunctionParameter {
  final String name;                    // 파라미터 이름
  final String type;                    // 타입: 'string', 'number', 'boolean', 'object', 'array'
  final String description;             // 파라미터 설명
  final List<String>? enumValues;       // 열거형 값 (선택사항)
  final bool? required;                // 필수 여부
}
```

#### McpFunctionRegistry
모든 사용 가능한 함수 스키마를 등록하고 관리하는 클래스입니다.

**주요 메서드:**
- `getAllFunctions()`: 모든 함수 스키마 목록 반환
- `getFunctionsJson()`: JSON 형식으로 함수 목록 반환
- `getOpenAiFunctions()`: OpenAI 함수 호출 형식으로 반환

---

## MCP 함수 실행기

### 위치
`lib/features/inbox/application/mcp_function_executor.dart`

### 주요 기능

#### 1. 함수 호출 파싱

AI 응답에서 함수 호출을 파싱합니다. 여러 형식을 지원합니다:

**지원되는 형식:**

1. **배열 형식**:
```json
[
  {"function": "createTask", "arguments": {"title": "작업 제목"}},
  {"function": "createEvent", "arguments": {"title": "일정 제목"}}
]
```

2. **커스텀 태그 형식**:
```xml
<function_call name="createTask">
{
  "title": "작업 제목",
  "description": "작업 설명"
}
</function_call>
```

3. **JSON 블록 형식**:
```json
```json
{"function": "createTask", "arguments": {"title": "작업 제목"}}
```
```

4. **단일 객체 형식**:
```json
{"function": "createTask", "arguments": {"title": "작업 제목"}}
```

**메서드:**
- `parseFunctionCall(String aiResponse)`: 단일 함수 호출 파싱
- `parseFunctionCalls(String aiResponse)`: 여러 함수 호출 파싱

#### 2. 함수 실행

파싱된 함수 호출을 실행합니다.

**메서드:**
```dart
Future<Map<String, dynamic>> executeFunction(
  String functionName,
  Map<String, dynamic> arguments, {
  TabType tabType = TabType.home,
  List<TaskEntity>? availableTasks,
  List<EventEntity>? availableEvents,
  List<ConnectionEntity>? availableConnections,
  List<InboxEntity>? availableInboxes,
  double? remainingCredits,
})
```

**반환 형식:**
```dart
{
  'success': true/false,
  'message': '성공/실패 메시지',
  'taskId': '...',  // 작업 관련 함수의 경우
  'eventId': '...', // 일정 관련 함수의 경우
  'results': [...], // 검색 함수의 경우
}
```

---

## AI 액션 컨트롤러

### 위치
`lib/features/inbox/application/agent_action_controller.dart`

### 주요 기능

#### 1. 메시지 관리
- 사용자 메시지와 AI 응답을 관리
- 대화 히스토리 저장 및 로드
- 첫 메시지에서 대화 제목 자동 생성

#### 2. 컨텍스트 구축

다양한 컨텍스트를 수집하여 AI에 제공합니다:

- **프로젝트 컨텍스트**: 선택된 프로젝트의 작업 데이터 (JSON 형식)
- **태그된 항목**: 사용자가 태그한 작업, 일정, 연결 등
- **채널 컨텍스트**: 태그된 채널의 최근 메시지 (최근 3일)
- **인박스 컨텍스트**: 인박스 항목의 요약 또는 전체 내용

#### 3. 크레딧 관리

- AI 호출 전 크레딧 사전 체크
- 예상 토큰 수 계산
- 크레딧 부족 시 구매 화면 표시

#### 4. 함수 호출 처리

```dart
Future<void> _generateGeneralChat(...) async {
  // 1. 컨텍스트 구축
  final projectContext = await _buildProjectContext(selectedProject);
  final taggedContext = _buildTaggedContext(...);
  
  // 2. AI API 호출
  final response = await _repository.generateGeneralChat(...);
  
  // 3. 함수 호출 파싱
  final executor = McpFunctionExecutor(ref);
  final functionCalls = executor.parseFunctionCalls(aiMessage);
  
  // 4. 함수 실행
  for (final functionCall in functionCalls) {
    // 확인이 필요한 함수는 pendingFunctionCalls에 저장
    if (requiresConfirmation) {
      // 사용자 확인 대기
    } else {
      // 즉시 실행
      await executor.executeFunction(...);
    }
  }
}
```

#### 5. 사용자 확인 처리

중요한 작업은 사용자 확인 후 실행됩니다:

**확인이 필요한 함수:**
- 전송: `sendMail`, `replyMail`, `forwardMail`
- 삭제: `deleteTask`, `deleteEvent`, `deleteMail`
- 수정: `updateTask`, `updateEvent`
- 상태 변경: `markMailAsRead`, `markMailAsUnread`, `archiveMail`, `responseCalendarInvitation`
- 생성: `createTask`, `createEvent`

확인이 필요한 함수는 `pendingFunctionCalls`에 저장되고, 사용자가 확인하면 실행됩니다.

---

## AI 데이터소스

### 지원되는 AI 모델

1. **OpenAI** (`lib/features/inbox/infrastructure/datasources/openai_inbox_datasource.dart`)
   - GPT-4, GPT-3.5 등
   - Function calling 지원

2. **Google AI** (`lib/features/inbox/infrastructure/datasources/google_ai_inbox_datasource.dart`)
   - Gemini 모델
   - JSON 스키마 기반 응답

3. **Anthropic AI** (`lib/features/inbox/infrastructure/datasources/anthropic_ai_inbox_datasource.dart`)
   - Claude 모델
   - 커스텀 프롬프트 형식

### 시스템 프롬프트 구성

각 데이터소스는 AI에게 함수 호출 방법을 안내하는 시스템 프롬프트를 구성합니다.

**주요 내용:**
- 사용 가능한 함수 목록 및 설명
- 함수 호출 형식 예시
- 함수 체이닝 규칙
- 날짜 계산 규칙
- 사용자 확인 필요 함수 안내
- 컨텍스트 사용 방법

**예시 (OpenAI):**
```
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
...
```

---

## 함수 호출 흐름

### 1. 사용자 입력
```
사용자: "내일 회의 일정 만들어줘"
```

### 2. 컨텍스트 구축
- 프로젝트 컨텍스트 수집
- 태그된 항목 수집
- 인박스 컨텍스트 수집

### 3. AI API 호출
```dart
final response = await datasource.generateGeneralChat(
  userMessage: "내일 회의 일정 만들어줘",
  conversationHistory: [...],
  projectContext: "...",
  model: "gpt-4",
  apiKey: "...",
);
```

### 4. AI 응답 파싱
```dart
final executor = McpFunctionExecutor(ref);
final functionCalls = executor.parseFunctionCalls(aiResponse);
// 결과: [
//   {
//     "function": "createEvent",
//     "arguments": {
//       "title": "회의",
//       "startAt": "2024-01-02T09:00:00",
//       "endAt": "2024-01-02T10:00:00"
//     }
//   }
// ]
```

### 5. 함수 실행
```dart
for (final functionCall in functionCalls) {
  if (requiresConfirmation) {
    // 사용자 확인 대기
    state.pendingFunctionCalls.add(functionCall);
  } else {
    // 즉시 실행
    await executor.executeFunction(
      functionCall['function'],
      functionCall['arguments'],
    );
  }
}
```

### 6. 결과 처리
- 성공/실패 메시지 표시
- 검색 결과는 컨텍스트에 추가
- 생성된 항목은 태그된 항목에 추가

---

## 지원되는 함수 목록

### 작업 (Task) 함수

#### createTask
새로운 작업을 생성합니다.

**파라미터:**
- `title` (string, 필수): 작업 제목
- `description` (string, 선택): 작업 설명
- `projectId` (string, 선택): 프로젝트 ID
- `startAt` (string, 선택): 시작 날짜/시간 (ISO 8601)
- `endAt` (string, 선택): 종료 날짜/시간 (ISO 8601)
- `isAllDay` (boolean, 선택): 하루 종일 작업 여부
- `status` (string, 선택): 작업 상태 ('none', 'done', 'cancelled')

**예시:**
```json
{
  "function": "createTask",
  "arguments": {
    "title": "프로젝트 문서 작성",
    "description": "API 문서 작성 및 리뷰",
    "startAt": "2024-01-02T09:00:00",
    "endAt": "2024-01-02T17:00:00",
    "isAllDay": false,
    "status": "none"
  }
}
```

#### updateTask
기존 작업을 업데이트합니다.

**파라미터:**
- `taskId` (string, 필수): 작업 ID
- `title` (string, 선택): 작업 제목
- `description` (string, 선택): 작업 설명
- `projectId` (string, 선택): 프로젝트 ID
- `startAt` (string, 선택): 시작 날짜/시간
- `endAt` (string, 선택): 종료 날짜/시간
- `isAllDay` (boolean, 선택): 하루 종일 작업 여부
- `status` (string, 선택): 작업 상태

#### deleteTask
작업을 삭제합니다.

**파라미터:**
- `taskId` (string, 필수): 작업 ID

#### toggleTaskStatus
작업의 완료 상태를 토글합니다.

**파라미터:**
- `taskId` (string, 필수): 작업 ID

### 일정 (Calendar) 함수

#### createEvent
새로운 일정을 생성합니다.

**파라미터:**
- `title` (string, 필수): 일정 제목
- `description` (string, 선택): 일정 설명
- `calendarId` (string, 선택): 캘린더 ID
- `startAt` (string, 선택): 시작 날짜/시간 (ISO 8601)
- `endAt` (string, 선택): 종료 날짜/시간 (ISO 8601)
- `isAllDay` (boolean, 선택): 하루 종일 일정 여부
- `location` (string, 선택): 장소
- `attendees` (array, 선택): 참석자 이메일 목록
- `conferenceLink` (string, 선택): 화상회의 링크 ("added"로 설정하면 자동 생성)

#### updateEvent
기존 일정을 업데이트합니다.

**파라미터:**
- `eventId` (string, 필수): 일정 ID
- `title` (string, 선택): 일정 제목
- `description` (string, 선택): 일정 설명
- `startAt` (string, 선택): 시작 날짜/시간
- `endAt` (string, 선택): 종료 날짜/시간
- `isAllDay` (boolean, 선택): 하루 종일 일정 여부
- `location` (string, 선택): 장소
- `attendees` (array, 선택): 참석자 이메일 목록

#### deleteEvent
일정을 삭제합니다.

**파라미터:**
- `eventId` (string, 필수): 일정 ID

#### responseCalendarInvitation
캘린더 초대에 응답합니다.

**파라미터:**
- `eventId` (string, 필수): 일정 ID
- `response` (string, 필수): 응답 상태 ('accepted', 'declined', 'tentative')

### 이메일 (Mail) 함수

#### sendMail
이메일을 전송합니다.

**파라미터:**
- `to` (array, 필수): 받는 사람 이메일 목록
- `cc` (array, 선택): 참조 이메일 목록
- `bcc` (array, 선택): 숨은 참조 이메일 목록
- `subject` (string, 필수): 이메일 제목
- `body` (string, 필수): 이메일 본문 (HTML 형식)

#### replyMail
이메일에 답장합니다.

**파라미터:**
- `threadId` (string, 필수): 스레드 ID
- `to` (array, 선택): 받는 사람 이메일 목록 (없으면 원본 발신자에게)
- `cc` (array, 선택): 참조 이메일 목록
- `subject` (string, 선택): 이메일 제목 (없으면 "Re: " 자동 추가)
- `body` (string, 필수): 이메일 본문 (HTML 형식)

#### forwardMail
이메일을 전달합니다.

**파라미터:**
- `threadId` (string, 필수): 스레드 ID
- `to` (array, 필수): 받는 사람 이메일 목록
- `cc` (array, 선택): 참조 이메일 목록
- `subject` (string, 선택): 이메일 제목 (없으면 "Fwd: " 자동 추가)
- `body` (string, 선택): 이메일 본문 (HTML 형식)

#### markMailAsRead
이메일을 읽음으로 표시합니다.

**파라미터:**
- `threadId` (string, 필수): 스레드 ID

#### markMailAsUnread
이메일을 읽지 않음으로 표시합니다.

**파라미터:**
- `threadId` (string, 필수): 스레드 ID

#### archiveMail
이메일을 보관합니다.

**파라미터:**
- `threadId` (string, 필수): 스레드 ID

#### deleteMail
이메일을 삭제합니다.

**파라미터:**
- `threadId` (string, 필수): 스레드 ID

### 검색 (Search) 함수

#### searchInbox
인박스에서 이메일이나 메시지를 검색합니다.

**파라미터:**
- `query` (string, 필수): 검색어 (제목, 발신자, 내용 등)

**반환:**
- `results`: 검색 결과 목록 (최대 20개)
- 각 결과는 `id`, `number`, `title`, `description`, `sender`, `inboxDatetime` 포함

#### searchTask
작업을 검색합니다.

**파라미터:**
- `query` (string, 필수): 검색어 (제목, 설명 등)
- `isDone` (boolean, 선택): 완료된 작업만 검색할지 여부

**반환:**
- `results`: 검색 결과 목록 (최대 20개)
- 각 결과는 `id`, `title`, `description`, `status`, `projectId`, `startAt`, `endAt`, `isAllDay` 포함

#### searchCalendarEvent
캘린더 일정을 검색합니다.

**파라미터:**
- `query` (string, 필수): 검색어 (제목, 설명 등)

**반환:**
- `results`: 검색 결과 목록 (최대 20개)
- 각 결과는 `id`, `uniqueId`, `title`, `description`, `startDate`, `endDate`, `isAllDay`, `location`, `calendarId`, `calendarName` 포함

### 기타 함수

#### reschedule
여러 작업을 오늘 적절한 시간에 재스케줄합니다.

**파라미터:**
- `taskIds` (array, 필수): 작업 ID 목록

**동작:**
- 작업들을 오늘 날짜로 이동
- 충돌을 피하기 위해 최적의 시간 슬롯 찾기
- 하루 종일 작업은 날짜만 변경
- 시간 작업은 15분 단위로 스케줄링

---

## 함수 체이닝

여러 함수를 순차적으로 호출하여 복잡한 워크플로우를 처리할 수 있습니다.

### 예시 1: 검색 후 답장
```
사용자: "우리카드에서 온 메일 찾아서 답장해줘"
```

**함수 호출:**
```json
[
  {
    "function": "searchInbox",
    "arguments": {"query": "우리카드"}
  },
  {
    "function": "replyMail",
    "arguments": {
      "threadId": "{{searchInbox 결과의 threadId}}",
      "body": "답장 내용"
    }
  }
]
```

### 예시 2: 여러 작업 생성
```
사용자: "오늘부터 매일 1주 간 '운동' 작업 생성해줘"
```

**함수 호출:**
```json
[
  {"function": "createTask", "arguments": {"title": "운동", "startAt": "2024-01-01T00:00:00", "endAt": "2024-01-02T00:00:00", "isAllDay": true}},
  {"function": "createTask", "arguments": {"title": "운동", "startAt": "2024-01-02T00:00:00", "endAt": "2024-01-03T00:00:00", "isAllDay": true}},
  ...
]
```

---

## 날짜 형식

모든 날짜는 **ISO 8601 형식**을 사용합니다.

**형식:** `YYYY-MM-DDTHH:mm:ss`

**예시:**
- `2024-01-01T09:00:00` - 2024년 1월 1일 오전 9시
- `2024-01-01T00:00:00` - 2024년 1월 1일 자정 (하루 종일 작업의 시작)
- `2024-01-02T00:00:00` - 2024년 1월 2일 자정 (하루 종일 작업의 종료)

---

## 에러 처리

### 함수 실행 실패
```dart
{
  'success': false,
  'error': '에러 메시지'
}
```

### 일반적인 에러
- `taskId is required`: 작업 ID가 필요합니다
- `Task not found`: 작업을 찾을 수 없습니다
- `Event not found`: 일정을 찾을 수 없습니다
- `Mail thread not found`: 이메일 스레드를 찾을 수 없습니다
- `No email account configured`: 이메일 계정이 설정되지 않았습니다

---

## 보안 및 확인

### 사용자 확인이 필요한 작업

다음 작업은 사용자 확인 후 실행됩니다:
- 이메일 전송/답장/전달
- 작업/일정/이메일 삭제
- 작업/일정 수정
- 이메일 상태 변경
- 작업/일정 생성

확인이 필요한 함수는 `pendingFunctionCalls`에 저장되고, 사용자가 확인하면 실행됩니다.

### 크레딧 관리

- 사용자 API 키를 사용하지 않는 경우 크레딧 사전 체크
- 예상 토큰 수 계산
- 크레딧 부족 시 구매 화면 표시

---

## 확장 방법

### 새로운 함수 추가

1. **함수 스키마 정의** (`mcp_function_schema.dart`)
```dart
McpFunctionSchema(
  name: 'newFunction',
  description: '새로운 함수 설명',
  parameters: [
    McpFunctionParameter(name: 'param1', type: 'string', description: '파라미터 설명', required: true),
  ],
),
```

2. **함수 실행 로직 구현** (`mcp_function_executor.dart`)
```dart
case 'newFunction':
  return await _executeNewFunction(arguments, ...);

Future<Map<String, dynamic>> _executeNewFunction(Map<String, dynamic> args, ...) async {
  // 함수 실행 로직
  return {'success': true, 'message': '성공 메시지'};
}
```

3. **시스템 프롬프트 업데이트** (각 데이터소스 파일)
- 함수 설명 추가
- 사용 예시 추가

---

## 참고 파일

- `lib/features/inbox/domain/entities/mcp_function_schema.dart` - 함수 스키마 정의
- `lib/features/inbox/application/mcp_function_executor.dart` - 함수 실행기
- `lib/features/inbox/application/agent_action_controller.dart` - AI 액션 컨트롤러
- `lib/features/inbox/infrastructure/datasources/openai_inbox_datasource.dart` - OpenAI 데이터소스
- `lib/features/inbox/infrastructure/datasources/google_ai_inbox_datasource.dart` - Google AI 데이터소스
- `lib/features/inbox/infrastructure/datasources/anthropic_ai_inbox_datasource.dart` - Anthropic AI 데이터소스

---

## 업데이트 이력

- 2024-01-XX: 초기 문서 작성

