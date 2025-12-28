// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_draft_entity.freezed.dart';
part 'chat_draft_entity.g.dart';

@freezed
abstract class ChatDraftEntity with _$ChatDraftEntity {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory ChatDraftEntity({
    required String id,
    required String teamId,
    required String channelId,
    required String? threadId,
    required String content,
    required String? editingMessageId,
  }) = _ChatDraftEntity;

  /// Serialization
  factory ChatDraftEntity.fromJson(Map<String, dynamic> json) => _$ChatDraftEntityFromJson(json);
}
