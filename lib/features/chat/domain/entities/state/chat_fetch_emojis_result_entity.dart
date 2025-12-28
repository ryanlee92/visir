// ignore_for_file: invalid_annotation_target

import 'package:Visir/features/chat/domain/entities/message_emoji_entity.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_fetch_emojis_result_entity.freezed.dart';
part 'chat_fetch_emojis_result_entity.g.dart';

@freezed
abstract class ChatFetchEmojisResultEntity with _$ChatFetchEmojisResultEntity {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory ChatFetchEmojisResultEntity({required List<MessageEmojiEntity> emojis, required int sequence}) = _ChatFetchEmojisResultEntity;

  /// Serialization
  factory ChatFetchEmojisResultEntity.fromJson(Map<String, dynamic> json) => _$ChatFetchEmojisResultEntityFromJson(json);
}
