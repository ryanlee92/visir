// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_member_or_group_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ChatMemberOrGroupEntity _$ChatMemberOrGroupEntityFromJson(
  Map<String, dynamic> json,
) => _ChatMemberOrGroupEntity(
  member: json['member'] == null
      ? null
      : MessageMemberEntity.fromJson(json['member'] as Map<String, dynamic>),
  group: json['group'] == null
      ? null
      : MessageGroupEntity.fromJson(json['group'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ChatMemberOrGroupEntityToJson(
  _ChatMemberOrGroupEntity instance,
) => <String, dynamic>{
  'member': ?instance.member?.toJson(),
  'group': ?instance.group?.toJson(),
};
