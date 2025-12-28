// ignore_for_file: invalid_annotation_target

import 'package:Visir/features/chat/domain/entities/message_channel_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_emoji_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_group_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_member_entity.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'message_thread_fetch_result_entity.freezed.dart';
part 'message_thread_fetch_result_entity.g.dart';

@freezed
abstract class MessageThreadFetchResultEntity with _$MessageThreadFetchResultEntity {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory MessageThreadFetchResultEntity({
    required List<MessageEntity> messages,
    List<MessageMemberEntity>? members,
    List<MessageGroupEntity>? groups,
    List<MessageEmojiEntity>? emojis,
    required bool hasMore,
    MessageChannelEntity? channel,
    String? nextCursor,
    bool? hasRecent,
    bool? isRateLimited,
    Map<String, String?>? nextPageTokens,
    int? sequence,
  }) = _MessageThreadFetchResultEntity;

  /// Serialization
  factory MessageThreadFetchResultEntity.fromJson(Map<String, dynamic> json) => _$MessageThreadFetchResultEntityFromJson(json);
}
