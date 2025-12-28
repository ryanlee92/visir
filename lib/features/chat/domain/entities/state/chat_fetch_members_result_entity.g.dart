// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_fetch_members_result_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ChatFetchMembersResultEntity _$ChatFetchMembersResultEntityFromJson(
  Map<String, dynamic> json,
) => _ChatFetchMembersResultEntity(
  members: (json['members'] as List<dynamic>)
      .map((e) => MessageMemberEntity.fromJson(e as Map<String, dynamic>))
      .toList(),
  sequence: (json['sequence'] as num).toInt(),
  loadedMembers: (json['loaded_members'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$ChatFetchMembersResultEntityToJson(
  _ChatFetchMembersResultEntity instance,
) => <String, dynamic>{
  'members': instance.members.map((e) => e.toJson()).toList(),
  'sequence': instance.sequence,
  'loaded_members': instance.loadedMembers,
};
