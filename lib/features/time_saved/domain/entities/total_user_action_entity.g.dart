// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'total_user_action_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TotalUserActionEntity _$TotalUserActionEntityFromJson(
  Map<String, dynamic> json,
) => _TotalUserActionEntity(
  userActions: (json['user_actions'] as List<dynamic>)
      .map(
        (e) => UserActionSwitchCountEntity.fromJson(e as Map<String, dynamic>),
      )
      .toList(),
);

Map<String, dynamic> _$TotalUserActionEntityToJson(
  _TotalUserActionEntity instance,
) => <String, dynamic>{
  'user_actions': instance.userActions.map((e) => e.toJson()).toList(),
};
