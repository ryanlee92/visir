// ignore_for_file: invalid_annotation_target
import 'package:Visir/features/chat/domain/entities/slack/chat_block/slack_message_block_rich_text_element_entity.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'slack_message_block_rich_text_entity.freezed.dart';
part 'slack_message_block_rich_text_entity.g.dart';

enum SlackMessageBlockElementEntityType {
  @JsonValue('rich_text_section')
  richTextSection,
  @JsonValue('rich_text_list')
  richTextList,
  @JsonValue('rich_text_preformatted')
  richTextPreformatted,
  @JsonValue('rich_text_quote')
  richTextQuote,
  @JsonValue('image')
  image,
  @JsonValue('mrkdwn')
  mrkdwn,
}

@freezed
abstract class SlackMessageBlockElementEntity with _$SlackMessageBlockElementEntity {
  @JsonSerializable(fieldRename: FieldRename.snake)
  //https://api.slack.com/reference/block-kit/blocks#divider
  const factory SlackMessageBlockElementEntity({
    @JsonKey(includeIfNull: false) SlackMessageBlockElementEntityType? type,
    @JsonKey(includeIfNull: false) List<SlackMessageBlockRichTextElementEntity>? elements,
    @JsonKey(includeIfNull: false) String? style,
    @JsonKey(includeIfNull: false) String? imageUrl,
    @JsonKey(includeIfNull: false) String? text,
    @JsonKey(includeIfNull: false) int? indent,
    @JsonKey(includeIfNull: false) int? offset,
    @JsonKey(includeIfNull: false) int? border,
  }) = _SlackMessageBlockElementEntity;

  /// Serialization
  factory SlackMessageBlockElementEntity.fromJson(Map<String, dynamic> json) => _$SlackMessageBlockElementEntityFromJson(json);
}
