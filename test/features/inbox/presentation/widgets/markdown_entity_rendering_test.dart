import 'package:flutter_test/flutter_test.dart';
import 'dart:convert';

void main() {
  group('Markdown Entity Rendering Tests', () {
    test('Markdown 내 단일 entity 태그 추출', () {
      final markdown = '''
# 작업 목록

<inapp_task>{"id": "task-1", "title": "마크다운 작업"}</inapp_task>

이 작업을 완료해야 합니다.
''';

      final entityTagRegex = RegExp(
        r'<(inapp_task|inapp_event|inapp_mail|inapp_mail_entity|inapp_message|inapp_calendar|inapp_event_entity|inapp_inbox|inapp_mail_summary|inapp_action_confirm)>([\s\S]*?)</\1>',
        multiLine: true,
      );

      final matches = entityTagRegex.allMatches(markdown);
      expect(matches.length, 1);

      final match = matches.first;
      expect(match.group(1), 'inapp_task');
      
      final jsonText = match.group(2)?.trim() ?? '';
      final jsonData = jsonDecode(jsonText) as Map<String, dynamic>;
      expect(jsonData['title'], '마크다운 작업');
    });

    test('Markdown 내 여러 entity 태그 추출', () {
      final markdown = '''
# 오늘 할 일

<inapp_task>{"id": "task-1", "title": "작업 1"}</inapp_task>

<inapp_event>{"id": "event-1", "title": "이벤트 1"}</inapp_event>

<inapp_mail_entity>{"id": "mail-1", "subject": "메일 1"}</inapp_mail_entity>
''';

      final entityTagRegex = RegExp(
        r'<(inapp_task|inapp_event|inapp_mail|inapp_mail_entity|inapp_message|inapp_calendar|inapp_event_entity|inapp_inbox|inapp_mail_summary|inapp_action_confirm)>([\s\S]*?)</\1>',
        multiLine: true,
      );

      final matches = entityTagRegex.allMatches(markdown);
      expect(matches.length, 3);

      final taskMatch = matches.firstWhere((m) => m.group(1) == 'inapp_task');
      final eventMatch = matches.firstWhere((m) => m.group(1) == 'inapp_event');
      final mailMatch = matches.firstWhere((m) => m.group(1) == 'inapp_mail_entity');

      expect(taskMatch, isNotNull);
      expect(eventMatch, isNotNull);
      expect(mailMatch, isNotNull);

      final taskData = jsonDecode(taskMatch.group(2)!.trim()) as Map<String, dynamic>;
      final eventData = jsonDecode(eventMatch.group(2)!.trim()) as Map<String, dynamic>;
      final mailData = jsonDecode(mailMatch.group(2)!.trim()) as Map<String, dynamic>;

      expect(taskData['title'], '작업 1');
      expect(eventData['title'], '이벤트 1');
      expect(mailData['subject'], '메일 1');
    });

    test('Placeholder 교체 로직 테스트', () {
      final markdown = '''
# 작업

<inapp_task>{"id": "task-1", "title": "작업"}</inapp_task>

설명입니다.
''';

      final entityTagRegex = RegExp(
        r'<(inapp_task|inapp_event|inapp_mail|inapp_mail_entity|inapp_message|inapp_calendar|inapp_event_entity|inapp_inbox|inapp_mail_summary|inapp_action_confirm)>([\s\S]*?)</\1>',
        multiLine: true,
      );

      String processedMarkdown = markdown;
      int placeholderIndex = 0;
      final placeholders = <String, String>{};

      for (final match in entityTagRegex.allMatches(markdown)) {
        final placeholder = '___ENTITY_PLACEHOLDER_${placeholderIndex++}___';
        placeholders[placeholder] = match.group(0)!;
        processedMarkdown = processedMarkdown.replaceFirst(match.group(0)!, placeholder);
      }

      expect(processedMarkdown.contains('___ENTITY_PLACEHOLDER_0___'), true);
      expect(processedMarkdown.contains('<inapp_task>'), false);
      expect(placeholders.length, 1);
    });

    test('Markdown과 entity 태그 혼합 처리', () {
      final markdown = '''
## 제목

일반 텍스트입니다.

<inapp_task>{"id": "task-1", "title": "작업"}</inapp_task>

- 리스트 항목 1
- 리스트 항목 2

<inapp_event>{"id": "event-1", "title": "이벤트"}</inapp_event>

**굵은 텍스트**
''';

      final entityTagRegex = RegExp(
        r'<(inapp_task|inapp_event|inapp_mail|inapp_mail_entity|inapp_message|inapp_calendar|inapp_event_entity|inapp_inbox|inapp_mail_summary|inapp_action_confirm)>([\s\S]*?)</\1>',
        multiLine: true,
      );

      final matches = entityTagRegex.allMatches(markdown);
      expect(matches.length, 2);

      // Markdown 구조가 유지되는지 확인
      expect(markdown.contains('## 제목'), true);
      expect(markdown.contains('- 리스트 항목 1'), true);
      expect(markdown.contains('**굵은 텍스트**'), true);
    });

    test('중첩된 태그 처리 (정상 동작 확인)', () {
      final markdown = '''
<inapp_task>{"id": "task-1", "title": "작업", "description": "<p>HTML 설명</p>"}</inapp_task>
''';

      final entityTagRegex = RegExp(
        r'<(inapp_task|inapp_event|inapp_mail|inapp_mail_entity|inapp_message|inapp_calendar|inapp_event_entity|inapp_inbox|inapp_mail_summary|inapp_action_confirm)>([\s\S]*?)</\1>',
        multiLine: true,
      );

      final match = entityTagRegex.firstMatch(markdown);
      expect(match, isNotNull);

      final jsonText = match!.group(2)?.trim() ?? '';
      final jsonData = jsonDecode(jsonText) as Map<String, dynamic>;
      
      // JSON 내부의 HTML은 정상적으로 파싱되어야 함
      expect(jsonData['description'], '<p>HTML 설명</p>');
    });
  });
}




