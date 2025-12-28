// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'slack_message_block_text_object_entity.freezed.dart';
part 'slack_message_block_text_object_entity.g.dart';

enum SlackMessageBlockTextObjectEntityType {
  @JsonValue('plain_text')
  plainText,
  @JsonValue('mrkdwn')
  mrkdwn,
}

@freezed
abstract class SlackMessageBlockTextObjectEntity with _$SlackMessageBlockTextObjectEntity {
  @JsonSerializable(fieldRename: FieldRename.snake)
  //https://api.slack.com/reference/block-kit/composition-objects#text
  const factory SlackMessageBlockTextObjectEntity({
    @JsonKey(includeIfNull: false) SlackMessageBlockTextObjectEntityType? type,
    @JsonKey(includeIfNull: false) String? text,
    @JsonKey(includeIfNull: false) bool? emoji,
    @JsonKey(includeIfNull: false) bool? verbatim,
  }) = _SlackMessageBlockTextObjectEntity;

  factory SlackMessageBlockTextObjectEntity.fromJson(Map<String, dynamic> json) => _$SlackMessageBlockTextObjectEntityFromJson(json);
}
