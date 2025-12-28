// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'slack_message_block_rich_text_element_entity.freezed.dart';
part 'slack_message_block_rich_text_element_entity.g.dart';

enum SlackMessageBlockRichTextElementEntityType {
  @JsonValue('channel')
  channel,
  @JsonValue('emoji')
  emoji,
  @JsonValue('link')
  link,
  @JsonValue('text')
  text,
  @JsonValue('user')
  user,
  @JsonValue('usergroup')
  usergroup,
  @JsonValue('broadcast')
  broadcast,
  @JsonValue('rich_text_section')
  richTextSection,
  @JsonValue('rich_text_preformatted')
  richTextPreformatted,
  @JsonValue('date')
  date,
  @JsonValue('color')
  color,
  @JsonValue('rich_text_list')
  richTextList,
  @JsonValue('rich_text_quote')
  richTextQuote,
}

@freezed
abstract class SlackMessageBlockRichTextElementEntity with _$SlackMessageBlockRichTextElementEntity {
  @JsonSerializable(fieldRename: FieldRename.snake)
  //https://api.slack.com/reference/block-kit/blocks#user-group-element-type
  const factory SlackMessageBlockRichTextElementEntity({
    @JsonKey(includeIfNull: false, unknownEnumValue: null) SlackMessageBlockRichTextElementEntityType? type,
    @JsonKey(includeIfNull: false) Map<String, bool>? style,
    @JsonKey(includeIfNull: false) String? name,
    @JsonKey(includeIfNull: false) String? unicode,
    @JsonKey(includeIfNull: false) String? url,
    @JsonKey(includeIfNull: false) String? text,
    @JsonKey(includeIfNull: false) bool? unsafe,
    @JsonKey(includeIfNull: false) String? userId,
    @JsonKey(includeIfNull: false) String? usergroupId,
    @JsonKey(includeIfNull: false) String? channelId,
    @JsonKey(includeIfNull: false) String? range,
    @JsonKey(includeIfNull: false) String? fallback,
    @JsonKey(includeIfNull: false) String? value,
    @JsonKey(includeIfNull: false) List<Map<String, dynamic>>? elements,
    @JsonKey(includeIfNull: false) int? indent,
    @JsonKey(includeIfNull: false) int? offset,
  }) = _SlackMessageBlockRichTextElementEntity;

  /// Serialization
  factory SlackMessageBlockRichTextElementEntity.fromJson(Map<String, dynamic> json) => _$SlackMessageBlockRichTextElementEntityFromJson(json);
}
