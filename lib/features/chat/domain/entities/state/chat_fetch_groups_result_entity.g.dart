// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_fetch_groups_result_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ChatFetchGroupsResultEntity _$ChatFetchGroupsResultEntityFromJson(
  Map<String, dynamic> json,
) => _ChatFetchGroupsResultEntity(
  groups: (json['groups'] as List<dynamic>)
      .map((e) => MessageGroupEntity.fromJson(e as Map<String, dynamic>))
      .toList(),
  sequence: (json['sequence'] as num).toInt(),
);

Map<String, dynamic> _$ChatFetchGroupsResultEntityToJson(
  _ChatFetchGroupsResultEntity instance,
) => <String, dynamic>{
  'groups': instance.groups.map((e) => e.toJson()).toList(),
  'sequence': instance.sequence,
};
