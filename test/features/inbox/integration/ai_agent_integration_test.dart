import 'package:flutter_test/flutter_test.dart';
import 'dart:convert';

void main() {
  group('AI Agent Integration Tests', () {
    test('전체 플로우: 함수 호출 파싱 → 실행 → 결과 표시', () {
      // 1. AI 응답 시뮬레이션
      final aiResponse = '''
[
  {
    "function": "searchInbox",
    "arguments": {"query": "우리카드"},
    "can_parallelize": true
  },
  {
    "function": "createTask",
    "arguments": {"title": "우리카드 메일 확인"},
    "can_parallelize": false,
    "depends_on": ["searchInbox"]
  }
]
''';

      // 2. 함수 호출 파싱
      final arrayStart = aiResponse.indexOf('[');
      final arrayEnd = aiResponse.lastIndexOf(']');
      final arrayStr = aiResponse.substring(arrayStart, arrayEnd + 1);
      final parsed = jsonDecode(arrayStr) as List<dynamic>;

      expect(parsed.length, 2);
      expect(parsed[0]['function'], 'searchInbox');
      expect(parsed[1]['function'], 'createTask');

      // 3. 병렬 실행 가능 여부 확인
      final canParallelize = parsed[0]['can_parallelize'] == true;
      expect(canParallelize, true);

      // 4. 의존성 확인
      final hasDependency = parsed[1]['depends_on'] != null;
      expect(hasDependency, true);
      expect(parsed[1]['depends_on'], ['searchInbox']);
    });

    test('Entity 태그가 포함된 AI 응답 처리', () {
      final aiResponse = '''
<p>검색 결과입니다:</p>
<inapp_mail_entity>{"id": "mail-1", "threadId": "thread-1", "subject": "우리카드 알림", "snippet": "결제 내역", "from": {"name": "우리카드", "email": "noreply@wooricard.com"}, "date": "2024-01-01T10:00:00Z"}</inapp_mail_entity>
<p>이 메일을 기반으로 작업을 생성하시겠습니까?</p>
''';

      // Entity 태그 추출
      final mailRegex = RegExp(r'<inapp_mail_entity>([\s\S]*?)</inapp_mail_entity>', multiLine: true);
      final match = mailRegex.firstMatch(aiResponse);

      expect(match, isNotNull);
      final jsonText = match!.group(1)?.trim() ?? '';
      final mailData = jsonDecode(jsonText) as Map<String, dynamic>;

      expect(mailData['subject'], '우리카드 알림');
      expect(mailData['from']['name'], '우리카드');
    });

    test('Markdown 응답 내 Entity 태그 처리', () {
      final markdownResponse = '''
# 작업 목록

<inapp_task>{"id": "task-1", "title": "오늘 할 일", "description": "중요한 작업"}</inapp_task>

이 작업을 완료해야 합니다.

<inapp_event>{"id": "event-1", "title": "회의", "start_at": "2024-01-01T10:00:00"}</inapp_event>
''';

      // Entity 태그 추출
      final entityTagRegex = RegExp(
        r'<(inapp_task|inapp_event|inapp_mail|inapp_mail_entity|inapp_message|inapp_calendar|inapp_event_entity|inapp_inbox|inapp_mail_summary|inapp_action_confirm)>([\s\S]*?)</\1>',
        multiLine: true,
      );

      final matches = entityTagRegex.allMatches(markdownResponse);
      expect(matches.length, 2);

      final taskMatch = matches.firstWhere((m) => m.group(1) == 'inapp_task');
      final eventMatch = matches.firstWhere((m) => m.group(1) == 'inapp_event');

      final taskData = jsonDecode(taskMatch.group(2)!.trim()) as Map<String, dynamic>;
      final eventData = jsonDecode(eventMatch.group(2)!.trim()) as Map<String, dynamic>;

      expect(taskData['title'], '오늘 할 일');
      expect(eventData['title'], '회의');
    });

    test('함수 호출과 Entity 표시 혼합', () {
      final aiResponse = '''
[
  {
    "function": "searchTask",
    "arguments": {"query": "프로젝트"},
    "can_parallelize": true
  }
]

<p>검색 결과:</p>
<inapp_task>{"id": "task-1", "title": "프로젝트 작업"}</inapp_task>
''';

      // 함수 호출 파싱
      final functionCallRegex = RegExp(r'\[([\s\S]*?)\]', multiLine: true);
      final functionMatch = functionCallRegex.firstMatch(aiResponse);
      
      if (functionMatch != null) {
        final functionArray = jsonDecode('[${functionMatch.group(1)}]') as List<dynamic>;
        expect(functionArray.length, 1);
        expect(functionArray[0]['function'], 'searchTask');
      }

      // Entity 태그 파싱
      final taskRegex = RegExp(r'<inapp_task>([\s\S]*?)</inapp_task>', multiLine: true);
      final taskMatch = taskRegex.firstMatch(aiResponse);
      
      expect(taskMatch, isNotNull);
      final taskData = jsonDecode(taskMatch!.group(1)!.trim()) as Map<String, dynamic>;
      expect(taskData['title'], '프로젝트 작업');
    });

    test('일괄 확인 플로우', () {
      // 1. 여러 함수 호출
      final functionCalls = [
        {
          'action_id': 'action-1',
          'function': 'createTask',
          'arguments': {'title': '작업 1'},
        },
        {
          'action_id': 'action-2',
          'function': 'createTask',
          'arguments': {'title': '작업 2'},
        },
        {
          'action_id': 'action-3',
          'function': 'createEvent',
          'arguments': {'title': '이벤트 1'},
        },
      ];

      // 2. 사용자가 일부 선택
      final selectedIds = {'action-1', 'action-3'};

      // 3. 선택된 액션만 필터링
      final selectedActions = functionCalls.where((call) => 
        selectedIds.contains(call['action_id'])
      ).toList();

      expect(selectedActions.length, 2);
      expect(selectedActions[0]['action_id'], 'action-1');
      expect(selectedActions[1]['action_id'], 'action-3');
    });
  });
}

