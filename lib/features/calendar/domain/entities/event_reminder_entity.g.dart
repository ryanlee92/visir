// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_reminder_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_EventReminderEntity _$EventReminderEntityFromJson(Map<String, dynamic> json) =>
    _EventReminderEntity(
      method: json['method'] as String?,
      minutes: (json['minutes'] as num?)?.toInt(),
    );

Map<String, dynamic> _$EventReminderEntityToJson(
  _EventReminderEntity instance,
) => <String, dynamic>{
  'method': ?instance.method,
  'minutes': ?instance.minutes,
};
