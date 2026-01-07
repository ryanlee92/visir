import 'package:flutter_test/flutter_test.dart';
import 'package:Visir/features/inbox/application/mcp_function_executor.dart';

void main() {
  group('McpFunctionExecutor - parseFunctionCalls', () {
    late McpFunctionExecutor executor;

    setUp(() {
      // Mock ref는 실제로 사용되지 않으므로 null로 설정
      executor = McpFunctionExecutor(null);
    });

    test('단일 함수 호출 파싱', () {
      final response = '''
[
  {
    "function": "createTask",
    "arguments": {
      "title": "테스트 작업",
      "description": "테스트 설명"
    }
  }
]
''';

      final calls = executor.parseFunctionCalls(response);
      expect(calls.length, 1);
      expect(calls[0]['function'], 'createTask');
      expect(calls[0]['arguments']['title'], '테스트 작업');
      expect(calls[0]['arguments']['description'], '테스트 설명');
    });

    test('여러 함수 호출 파싱', () {
      final response = '''
[
  {
    "function": "searchInbox",
    "arguments": {"query": "우리카드"},
    "can_parallelize": true
  },
  {
    "function": "searchTask",
    "arguments": {"query": "프로젝트"},
    "can_parallelize": true
  },
  {
    "function": "createTask",
    "arguments": {"title": "작업 생성"},
    "can_parallelize": false,
    "depends_on": ["searchTask"]
  }
]
''';

      final calls = executor.parseFunctionCalls(response);
      expect(calls.length, 3);
      expect(calls[0]['function'], 'searchInbox');
      expect(calls[0]['can_parallelize'], true);
      expect(calls[1]['function'], 'searchTask');
      expect(calls[1]['can_parallelize'], true);
      expect(calls[2]['function'], 'createTask');
      expect(calls[2]['can_parallelize'], false);
      expect(calls[2]['depends_on'], ['searchTask']);
    });

    test('function_call 태그 형식 파싱', () {
      final response = '''
<function_call name="createTask">
{
  "title": "태그 형식 작업",
  "description": "태그 형식 설명"
}
</function_call>
''';

      final calls = executor.parseFunctionCalls(response);
      expect(calls.length, 1);
      expect(calls[0]['function'], 'createTask');
      expect(calls[0]['arguments']['title'], '태그 형식 작업');
    });

    test('여러 function_call 태그 파싱', () {
      final response = '''
<function_call name="searchInbox">
{"query": "메일"}
</function_call>
<function_call name="createTask">
{"title": "작업"}
</function_call>
''';

      final calls = executor.parseFunctionCalls(response);
      expect(calls.length, 2);
      expect(calls[0]['function'], 'searchInbox');
      expect(calls[1]['function'], 'createTask');
    });

    test('can_parallelize 기본값 테스트 (search 함수)', () {
      final response = '''
[
  {
    "function": "searchInbox",
    "arguments": {"query": "테스트"}
  }
]
''';

      final calls = executor.parseFunctionCalls(response);
      expect(calls.length, 1);
      // search 함수는 기본적으로 can_parallelize가 true
      expect(calls[0]['can_parallelize'], true);
    });

    test('can_parallelize 기본값 테스트 (일반 함수)', () {
      final response = '''
[
  {
    "function": "createTask",
    "arguments": {"title": "테스트"}
  }
]
''';

      final calls = executor.parseFunctionCalls(response);
      expect(calls.length, 1);
      // 일반 함수는 기본적으로 can_parallelize가 false
      expect(calls[0]['can_parallelize'], false);
    });

    test('빈 응답 처리', () {
      final calls = executor.parseFunctionCalls('');
      expect(calls.isEmpty, true);
    });

    test('잘못된 JSON 형식 처리', () {
      final response = '잘못된 형식의 응답';
      final calls = executor.parseFunctionCalls(response);
      expect(calls.isEmpty, true);
    });

    test('혼합 형식 파싱 (배열 + 태그)', () {
      final response = '''
[
  {
    "function": "searchInbox",
    "arguments": {"query": "테스트"}
  }
]
<function_call name="createTask">
{"title": "추가 작업"}
</function_call>
''';

      final calls = executor.parseFunctionCalls(response);
      // 배열 형식이 우선이므로 배열만 파싱됨
      expect(calls.length, greaterThanOrEqualTo(1));
    });
  });
}





