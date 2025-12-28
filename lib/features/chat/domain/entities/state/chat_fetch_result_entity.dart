// ignore_for_file: invalid_annotation_target

import 'package:Visir/features/chat/domain/entities/message_channel_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_entity.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_fetch_result_entity.freezed.dart';
part 'chat_fetch_result_entity.g.dart';

@freezed
abstract class ChatFetchResultEntity with _$ChatFetchResultEntity {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory ChatFetchResultEntity({
    required List<MessageEntity> messages,
    required bool hasMore,
    MessageChannelEntity? channel,
    String? nextCursor,
    bool? hasRecent,
    bool? isRateLimited,
    Map<String, String?>? nextPageTokens,
    int? sequence,
  }) = _ChatFetchResultEntity;

  /// Serialization
  factory ChatFetchResultEntity.fromJson(Map<String, dynamic> json) => _$ChatFetchResultEntityFromJson(json);
}
