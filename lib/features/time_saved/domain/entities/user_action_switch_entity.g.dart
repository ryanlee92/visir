// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_action_switch_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserActionSwitchEntity _$UserActionSwitchEntityFromJson(
  Map<String, dynamic> json,
) => _UserActionSwitchEntity(
  id: json['id'] as String,
  userId: json['user_id'] as String,
  createdAt: DateTime.parse(json['created_at'] as String),
  prevAction: UserActionEntity.fromJson(
    json['prev_action'] as Map<String, dynamic>,
  ),
  nextAction: UserActionEntity.fromJson(
    json['next_action'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$UserActionSwitchEntityToJson(
  _UserActionSwitchEntity instance,
) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  'created_at': instance.createdAt.toIso8601String(),
  'prev_action': instance.prevAction.toJson(),
  'next_action': instance.nextAction.toJson(),
};
