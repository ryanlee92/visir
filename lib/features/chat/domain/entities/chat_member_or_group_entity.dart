import 'package:Visir/features/chat/domain/entities/message_group_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_member_entity.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_member_or_group_entity.freezed.dart';
part 'chat_member_or_group_entity.g.dart';

@freezed
abstract class ChatMemberOrGroupEntity with _$ChatMemberOrGroupEntity {
  const factory ChatMemberOrGroupEntity({MessageMemberEntity? member, MessageGroupEntity? group}) = _ChatMemberOrGroupEntity;

  factory ChatMemberOrGroupEntity.fromJson(Map<String, dynamic> json) => _$ChatMemberOrGroupEntityFromJson(json);
}
