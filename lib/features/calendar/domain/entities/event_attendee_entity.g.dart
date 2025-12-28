// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_attendee_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_EventAttendeeEntity _$EventAttendeeEntityFromJson(Map<String, dynamic> json) =>
    _EventAttendeeEntity(
      comment: json['comment'] as String?,
      displayName: json['display_name'] as String?,
      email: json['email'] as String?,
      id: json['id'] as String?,
      organizer: json['organizer'] as bool?,
      responseStatus: $enumDecodeNullable(
        _$EventAttendeeResponseStatusEnumMap,
        json['response_status'],
      ),
    );

Map<String, dynamic> _$EventAttendeeEntityToJson(
  _EventAttendeeEntity instance,
) => <String, dynamic>{
  'comment': ?instance.comment,
  'display_name': ?instance.displayName,
  'email': ?instance.email,
  'id': ?instance.id,
  'organizer': ?instance.organizer,
  'response_status':
      ?_$EventAttendeeResponseStatusEnumMap[instance.responseStatus],
};

const _$EventAttendeeResponseStatusEnumMap = {
  EventAttendeeResponseStatus.needsAction: 'needsAction',
  EventAttendeeResponseStatus.declined: 'declined',
  EventAttendeeResponseStatus.tentative: 'tentative',
  EventAttendeeResponseStatus.accepted: 'accepted',
};
