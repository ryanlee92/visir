import 'package:Visir/features/calendar/domain/entities/event_entity.dart';

class CalendarEventResultEntity {
  final Map<String, List<EventEntity>> events;
  final Map<String, String?> pageTokens;

  CalendarEventResultEntity({required this.events, required this.pageTokens});
}
