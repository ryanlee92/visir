// ignore_for_file: invalid_annotation_target

import 'package:Visir/features/chat/domain/entities/message_member_entity.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_fetch_members_result_entity.freezed.dart';
part 'chat_fetch_members_result_entity.g.dart';

@freezed
abstract class ChatFetchMembersResultEntity with _$ChatFetchMembersResultEntity {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory ChatFetchMembersResultEntity({required List<MessageMemberEntity> members, required int sequence, required List<String> loadedMembers}) =
      _ChatFetchMembersResultEntity;

  /// Serialization
  factory ChatFetchMembersResultEntity.fromJson(Map<String, dynamic> json) => _$ChatFetchMembersResultEntityFromJson(json);
}
