// ignore_for_file: invalid_annotation_target

import 'package:Visir/features/chat/domain/entities/slack/chat_block/object/slack_message_block_text_object_entity.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'slack_message_block_entity.freezed.dart';
part 'slack_message_block_entity.g.dart';

enum SlackMessageBlockEntityType {
  @JsonValue('actions')
  actions,
  @JsonValue('context')
  context,
  @JsonValue('divider')
  divider,
  @JsonValue('file')
  file,
  @JsonValue('header')
  header,
  @JsonValue('image')
  image,
  @JsonValue('input')
  input,
  @JsonValue('rich_text')
  richText,
  @JsonValue('section')
  section,
  @JsonValue('video')
  video,
}

@freezed
abstract class SlackMessageBlockEntity with _$SlackMessageBlockEntity {
  /// Serialization

  @JsonSerializable(fieldRename: FieldRename.snake)
  //https://api.slack.com/reference/block-kit/blocks#divider
  const factory SlackMessageBlockEntity({
    @JsonKey(includeIfNull: false) SlackMessageBlockEntityType? type,
    @JsonKey(includeIfNull: false) String? blockId,
    @JsonKey(includeIfNull: false) String? externalId,
    @JsonKey(includeIfNull: false) String? altText,
    @JsonKey(includeIfNull: false) String? imageUrl,
    @JsonKey(includeIfNull: false) String? authorName,
    @JsonKey(includeIfNull: false) String? providerIconUrl,
    @JsonKey(includeIfNull: false) String? providerName,
    @JsonKey(includeIfNull: false) String? titleUrl,
    @JsonKey(includeIfNull: false) String? thumbnailUrl,
    @JsonKey(includeIfNull: false) String? videoUrl,
    @JsonKey(includeIfNull: false) bool? dispatchAction,
    @JsonKey(includeIfNull: false) bool? optional,
    @JsonKey(includeIfNull: false) SlackMessageBlockTextObjectEntity? text,
    @JsonKey(includeIfNull: false) Map<String, dynamic>? title,
    @JsonKey(includeIfNull: false) Map<String, dynamic>? slackFile,
    @JsonKey(includeIfNull: false) Map<String, dynamic>? label,
    @JsonKey(includeIfNull: false) Map<String, dynamic>? element,
    @JsonKey(includeIfNull: false) Map<String, dynamic>? hint,
    @JsonKey(includeIfNull: false) Map<String, dynamic>? accessory,
    @JsonKey(includeIfNull: false) Map<String, dynamic>? description,
    @JsonKey(includeIfNull: false) List<Map<String, dynamic>>? elements,
    @JsonKey(includeIfNull: false) List<Map<String, dynamic>>? fields,
  }) = _SlackMessageBlockEntity;

  factory SlackMessageBlockEntity.fromJson(Map<String, dynamic> json) => _$SlackMessageBlockEntityFromJson(json);
}
