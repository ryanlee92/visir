// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CalendarEntity _$CalendarEntityFromJson(Map<String, dynamic> json) =>
    _CalendarEntity(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String?,
      backgroundColor: json['background_color'] as String,
      foregroundColor: json['foreground_color'] as String,
      defaultReminders: (json['default_reminders'] as List<dynamic>?)
          ?.map((e) => EventReminderEntity.fromJson(e as Map<String, dynamic>))
          .toList(),
      owned: json['owned'] as bool?,
      modifiable: json['modifiable'] as bool?,
      shareable: json['shareable'] as bool?,
      removable: json['removable'] as bool?,
      type: $enumDecodeNullable(_$CalendarEntityTypeEnumMap, json['type']),
    );

Map<String, dynamic> _$CalendarEntityToJson(_CalendarEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': ?instance.email,
      'background_color': instance.backgroundColor,
      'foreground_color': instance.foregroundColor,
      'default_reminders': ?instance.defaultReminders
          ?.map((e) => e.toJson())
          .toList(),
      'owned': ?instance.owned,
      'modifiable': ?instance.modifiable,
      'shareable': ?instance.shareable,
      'removable': ?instance.removable,
      'type': ?_$CalendarEntityTypeEnumMap[instance.type],
    };

const _$CalendarEntityTypeEnumMap = {
  CalendarEntityType.google: 'google',
  CalendarEntityType.microsoft: 'outlook',
};
