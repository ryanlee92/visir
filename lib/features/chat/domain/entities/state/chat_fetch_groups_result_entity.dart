// ignore_for_file: invalid_annotation_target

import 'package:Visir/features/chat/domain/entities/message_group_entity.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_fetch_groups_result_entity.freezed.dart';
part 'chat_fetch_groups_result_entity.g.dart';

@freezed
abstract class ChatFetchGroupsResultEntity with _$ChatFetchGroupsResultEntity {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory ChatFetchGroupsResultEntity({required List<MessageGroupEntity> groups, required int sequence}) = _ChatFetchGroupsResultEntity;

  /// Serialization
  factory ChatFetchGroupsResultEntity.fromJson(Map<String, dynamic> json) => _$ChatFetchGroupsResultEntityFromJson(json);
}
