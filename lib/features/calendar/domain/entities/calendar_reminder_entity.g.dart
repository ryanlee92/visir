// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_reminder_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CalendarReminderEntity _$CalendarReminderEntityFromJson(
  Map<String, dynamic> json,
) => _CalendarReminderEntity(
  id: json['id'] as String,
  title: json['title'] as String,
  minutes: (json['minutes'] as num).toInt(),
  userId: json['user_id'] as String,
  email: json['email'] as String?,
  eventId: json['event_id'] as String,
  deviceId: json['device_id'] as String,
  calendarId: json['calendar_id'] as String,
  calendarName: json['calendar_name'] as String,
  provider: json['provider'] as String,
  targetDateTime: DateTime.parse(json['target_date_time'] as String),
  startDate: DateTime.parse(json['start_date'] as String),
  endDate: DateTime.parse(json['end_date'] as String),
  locale: json['locale'] as String,
  isAllDay: json['is_all_day'] as bool,
  isEncrypted: json['is_encrypted'] as bool,
  iv: json['iv'] as String,
);

Map<String, dynamic> _$CalendarReminderEntityToJson(
  _CalendarReminderEntity instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'minutes': instance.minutes,
  'user_id': instance.userId,
  'email': ?instance.email,
  'event_id': instance.eventId,
  'device_id': instance.deviceId,
  'calendar_id': instance.calendarId,
  'calendar_name': instance.calendarName,
  'provider': instance.provider,
  'target_date_time': instance.targetDateTime.toIso8601String(),
  'start_date': instance.startDate.toIso8601String(),
  'end_date': instance.endDate.toIso8601String(),
  'locale': instance.locale,
  'is_all_day': instance.isAllDay,
  'is_encrypted': instance.isEncrypted,
  'iv': instance.iv,
};
