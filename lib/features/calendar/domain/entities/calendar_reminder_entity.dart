// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'calendar_reminder_entity.freezed.dart';
part 'calendar_reminder_entity.g.dart';

@freezed
abstract class CalendarReminderEntity with _$CalendarReminderEntity {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory CalendarReminderEntity({
    required String id,
    required String title,
    required int minutes,
    required String userId,
    String? email,
    required String eventId,
    required String deviceId,
    required String calendarId,
    required String calendarName,
    required String provider,
    required DateTime targetDateTime,
    required DateTime startDate,
    required DateTime endDate,
    required String locale,
    required bool isAllDay,
    required bool isEncrypted,
    required String iv,
  }) = _CalendarReminderEntity;

  /// Serialization
  factory CalendarReminderEntity.fromJson(Map<String, dynamic> json) => _$CalendarReminderEntityFromJson(json);
}
