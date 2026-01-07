import 'package:flutter_test/flutter_test.dart';
import 'dart:convert';

void main() {
  group('Entity Tag Parsing Tests', () {
    test('inapp_task 태그 파싱', () {
      final content = '''
<inapp_task>{"id": "task-1", "title": "테스트 작업", "description": "작업 설명", "project_id": "project-1", "start_at": "2024-01-01T10:00:00", "status": "none"}</inapp_task>
''';

      final regex = RegExp(r'<inapp_task>([\s\S]*?)</inapp_task>', multiLine: true);
      final match = regex.firstMatch(content);
      
      expect(match, isNotNull);
      final jsonText = match!.group(1)?.trim() ?? '';
      final jsonData = jsonDecode(jsonText) as Map<String, dynamic>;
      
      expect(jsonData['id'], 'task-1');
      expect(jsonData['title'], '테스트 작업');
      expect(jsonData['description'], '작업 설명');
    });

    test('inapp_event 태그 파싱', () {
      final content = '''
<inapp_event>{"id": "event-1", "title": "테스트 이벤트", "description": "이벤트 설명", "calendar_id": "calendar-1", "start_at": "2024-01-01T10:00:00", "end_at": "2024-01-01T11:00:00", "isAllDay": false}</inapp_event>
''';

      final regex = RegExp(r'<inapp_event>([\s\S]*?)</inapp_event>', multiLine: true);
      final match = regex.firstMatch(content);
      
      expect(match, isNotNull);
      final jsonText = match!.group(1)?.trim() ?? '';
      final jsonData = jsonDecode(jsonText) as Map<String, dynamic>;
      
      expect(jsonData['id'], 'event-1');
      expect(jsonData['title'], '테스트 이벤트');
      expect(jsonData['isAllDay'], false);
    });

    test('inapp_mail_entity 태그 파싱', () {
      final content = '''
<inapp_mail_entity>{"id": "mail-1", "threadId": "thread-1", "subject": "테스트 메일", "snippet": "메일 스니펫", "from": {"name": "보낸 사람", "email": "sender@example.com"}, "date": "2024-01-01T10:00:00Z"}</inapp_mail_entity>
''';

      final regex = RegExp(r'<inapp_mail_entity>([\s\S]*?)</inapp_mail_entity>', multiLine: true);
      final match = regex.firstMatch(content);
      
      expect(match, isNotNull);
      final jsonText = match!.group(1)?.trim() ?? '';
      final jsonData = jsonDecode(jsonText) as Map<String, dynamic>;
      
      expect(jsonData['id'], 'mail-1');
      expect(jsonData['subject'], '테스트 메일');
      expect(jsonData['from']['name'], '보낸 사람');
    });

    test('inapp_message 태그 파싱', () {
      final content = '''
<inapp_message>{"id": "msg-1", "channelId": "channel-1", "userId": "user-1", "text": "메시지 텍스트", "createdAt": "2024-01-01T10:00:00Z"}</inapp_message>
''';

      final regex = RegExp(r'<inapp_message>([\s\S]*?)</inapp_message>', multiLine: true);
      final match = regex.firstMatch(content);
      
      expect(match, isNotNull);
      final jsonText = match!.group(1)?.trim() ?? '';
      final jsonData = jsonDecode(jsonText) as Map<String, dynamic>;
      
      expect(jsonData['id'], 'msg-1');
      expect(jsonData['text'], '메시지 텍스트');
    });

    test('여러 entity 태그 파싱', () {
      final content = '''
<inapp_task>{"id": "task-1", "title": "작업 1"}</inapp_task>
<inapp_event>{"id": "event-1", "title": "이벤트 1"}</inapp_event>
<inapp_mail_entity>{"id": "mail-1", "subject": "메일 1"}</inapp_mail_entity>
''';

      final taskRegex = RegExp(r'<inapp_task>([\s\S]*?)</inapp_task>', multiLine: true);
      final eventRegex = RegExp(r'<inapp_event>([\s\S]*?)</inapp_event>', multiLine: true);
      final mailRegex = RegExp(r'<inapp_mail_entity>([\s\S]*?)</inapp_mail_entity>', multiLine: true);

      final taskMatch = taskRegex.firstMatch(content);
      final eventMatch = eventRegex.firstMatch(content);
      final mailMatch = mailRegex.firstMatch(content);

      expect(taskMatch, isNotNull);
      expect(eventMatch, isNotNull);
      expect(mailMatch, isNotNull);

      final taskData = jsonDecode(taskMatch!.group(1)!.trim()) as Map<String, dynamic>;
      final eventData = jsonDecode(eventMatch!.group(1)!.trim()) as Map<String, dynamic>;
      final mailData = jsonDecode(mailMatch!.group(1)!.trim()) as Map<String, dynamic>;

      expect(taskData['title'], '작업 1');
      expect(eventData['title'], '이벤트 1');
      expect(mailData['subject'], '메일 1');
    });

    test('Markdown 내 entity 태그 파싱', () {
      final content = '''
# 작업 목록

<inapp_task>{"id": "task-1", "title": "마크다운 작업"}</inapp_task>

이 작업을 완료해야 합니다.
''';

      final regex = RegExp(r'<inapp_task>([\s\S]*?)</inapp_task>', multiLine: true);
      final match = regex.firstMatch(content);
      
      expect(match, isNotNull);
      final jsonText = match!.group(1)?.trim() ?? '';
      final jsonData = jsonDecode(jsonText) as Map<String, dynamic>;
      
      expect(jsonData['title'], '마크다운 작업');
    });

    test('HTML 내 entity 태그 파싱', () {
      final content = '''
<p>작업 정보:</p>
<inapp_task>{"id": "task-1", "title": "HTML 작업"}</inapp_task>
<p>추가 설명</p>
''';

      final regex = RegExp(r'<inapp_task>([\s\S]*?)</inapp_task>', multiLine: true);
      final match = regex.firstMatch(content);
      
      expect(match, isNotNull);
      final jsonText = match!.group(1)?.trim() ?? '';
      final jsonData = jsonDecode(jsonText) as Map<String, dynamic>;
      
      expect(jsonData['title'], 'HTML 작업');
    });

    test('잘못된 JSON 형식 처리', () {
      final content = '''
<inapp_task>{"id": "task-1", "title": 잘못된 JSON}</inapp_task>
''';

      final regex = RegExp(r'<inapp_task>([\s\S]*?)</inapp_task>', multiLine: true);
      final match = regex.firstMatch(content);
      
      expect(match, isNotNull);
      final jsonText = match!.group(1)?.trim() ?? '';
      
      expect(() => jsonDecode(jsonText), throwsA(isA<FormatException>()));
    });

    test('빈 태그 처리', () {
      final content = '<inapp_task></inapp_task>';
      final regex = RegExp(r'<inapp_task>([\s\S]*?)</inapp_task>', multiLine: true);
      final match = regex.firstMatch(content);
      
      expect(match, isNotNull);
      final jsonText = match!.group(1)?.trim() ?? '';
      expect(jsonText.isEmpty, true);
    });
  });
}





