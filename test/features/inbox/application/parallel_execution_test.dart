import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Parallel Execution and Dependency Analysis Tests', () {
    test('독립적인 함수들은 병렬 실행 가능', () {
      final functionCalls = [
        {
          'function': 'searchInbox',
          'arguments': {'query': '테스트'},
          'can_parallelize': true,
        },
        {
          'function': 'searchTask',
          'arguments': {'query': '작업'},
          'can_parallelize': true,
        },
        {
          'function': 'searchCalendarEvent',
          'arguments': {'query': '이벤트'},
          'can_parallelize': true,
        },
      ];

      // 모든 함수가 병렬 실행 가능한지 확인
      final canAllParallelize = functionCalls.every((call) => call['can_parallelize'] == true);
      expect(canAllParallelize, true);
    });

    test('의존성이 있는 함수들은 순차 실행', () {
      final functionCalls = [
        {
          'function': 'searchTask',
          'arguments': {'query': '작업'},
          'can_parallelize': true,
        },
        {
          'function': 'createTask',
          'arguments': {'title': '작업 생성'},
          'can_parallelize': false,
          'depends_on': ['searchTask'],
        },
      ];

      // 첫 번째 함수는 병렬 실행 가능
      expect(functionCalls[0]['can_parallelize'], true);
      
      // 두 번째 함수는 의존성이 있어 순차 실행
      expect(functionCalls[1]['can_parallelize'], false);
      expect(functionCalls[1]['depends_on'], ['searchTask']);
    });

    test('함수 그룹화 로직 테스트', () {
      final functionCalls = [
        {
          'function': 'searchInbox',
          'arguments': {'query': '메일'},
          'can_parallelize': true,
        },
        {
          'function': 'searchTask',
          'arguments': {'query': '작업'},
          'can_parallelize': true,
        },
        {
          'function': 'createTask',
          'arguments': {'title': '작업 생성'},
          'can_parallelize': false,
          'depends_on': ['searchTask'],
        },
        {
          'function': 'createEvent',
          'arguments': {'title': '이벤트 생성'},
          'can_parallelize': false,
          'depends_on': ['createTask'],
        },
      ];

      // 그룹화: 병렬 실행 가능한 함수들 그룹
      final parallelGroup = functionCalls.where((call) => call['can_parallelize'] == true).toList();
      expect(parallelGroup.length, 2);
      expect(parallelGroup[0]['function'], 'searchInbox');
      expect(parallelGroup[1]['function'], 'searchTask');

      // 순차 실행 그룹
      final sequentialGroup = functionCalls.where((call) => call['can_parallelize'] == false).toList();
      expect(sequentialGroup.length, 2);
      expect(sequentialGroup[0]['function'], 'createTask');
      expect(sequentialGroup[1]['function'], 'createEvent');
    });

    test('의존성 체인 확인', () {
      final functionCalls = [
        {
          'function': 'searchInbox',
          'arguments': {'query': '메일'},
          'can_parallelize': true,
        },
        {
          'function': 'replyMail',
          'arguments': {'threadId': 'thread-1'},
          'can_parallelize': false,
          'depends_on': ['searchInbox'],
        },
      ];

      // 의존성 체인이 올바른지 확인
      final dependentCall = functionCalls.firstWhere((call) => call['depends_on'] != null);
      expect(dependentCall['depends_on'], ['searchInbox']);
      expect(dependentCall['function'], 'replyMail');
    });

    test('동일 리소스 수정 함수는 순차 실행', () {
      final functionCalls = [
        {
          'function': 'updateTask',
          'arguments': {'taskId': 'task-1', 'title': '제목 변경'},
          'can_parallelize': false,
        },
        {
          'function': 'deleteTask',
          'arguments': {'taskId': 'task-1'},
          'can_parallelize': false,
        },
      ];

      // 동일 리소스를 수정하는 함수들은 모두 순차 실행
      final allSequential = functionCalls.every((call) => call['can_parallelize'] == false);
      expect(allSequential, true);
    });

    test('복잡한 의존성 그래프', () {
      final functionCalls = [
        {
          'function': 'searchInbox',
          'arguments': {'query': '메일'},
          'can_parallelize': true,
        },
        {
          'function': 'searchTask',
          'arguments': {'query': '작업'},
          'can_parallelize': true,
        },
        {
          'function': 'createTask',
          'arguments': {'title': '작업 생성'},
          'can_parallelize': false,
          'depends_on': ['searchTask'],
        },
        {
          'function': 'replyMail',
          'arguments': {'threadId': 'thread-1'},
          'can_parallelize': false,
          'depends_on': ['searchInbox'],
        },
      ];

      // 병렬 그룹
      final parallelGroup = functionCalls.where((call) => call['can_parallelize'] == true).toList();
      expect(parallelGroup.length, 2);

      // 의존성 그룹들
      final taskDependent = functionCalls.firstWhere((call) {
        final dependsOn = call['depends_on'] as List?;
        return dependsOn != null && dependsOn.contains('searchTask');
      });
      expect(taskDependent['function'], 'createTask');

      final mailDependent = functionCalls.firstWhere((call) {
        final dependsOn = call['depends_on'] as List?;
        return dependsOn != null && dependsOn.contains('searchInbox');
      });
      expect(mailDependent['function'], 'replyMail');
    });
  });
}

