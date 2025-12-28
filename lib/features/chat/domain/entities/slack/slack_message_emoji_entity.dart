// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'slack_message_emoji_entity.freezed.dart';
part 'slack_message_emoji_entity.g.dart';

@freezed
abstract class SlackMessagEmojiEntity with _$SlackMessagEmojiEntity {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory SlackMessagEmojiEntity({
    required String name,
    required String url,
  }) = _SlackMessagEmojiEntity;

  /// Serialization
  factory SlackMessagEmojiEntity.fromJson(Map<String, dynamic> json) => _$SlackMessagEmojiEntityFromJson(json);
}
