// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'slack_message_block_rich_text_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SlackMessageBlockElementEntity _$SlackMessageBlockElementEntityFromJson(
  Map<String, dynamic> json,
) => _SlackMessageBlockElementEntity(
  type: $enumDecodeNullable(
    _$SlackMessageBlockElementEntityTypeEnumMap,
    json['type'],
  ),
  elements: (json['elements'] as List<dynamic>?)
      ?.map(
        (e) => SlackMessageBlockRichTextElementEntity.fromJson(
          e as Map<String, dynamic>,
        ),
      )
      .toList(),
  style: json['style'] as String?,
  imageUrl: json['image_url'] as String?,
  text: json['text'] as String?,
  indent: (json['indent'] as num?)?.toInt(),
  offset: (json['offset'] as num?)?.toInt(),
  border: (json['border'] as num?)?.toInt(),
);

Map<String, dynamic> _$SlackMessageBlockElementEntityToJson(
  _SlackMessageBlockElementEntity instance,
) => <String, dynamic>{
  'type': ?_$SlackMessageBlockElementEntityTypeEnumMap[instance.type],
  'elements': ?instance.elements?.map((e) => e.toJson()).toList(),
  'style': ?instance.style,
  'image_url': ?instance.imageUrl,
  'text': ?instance.text,
  'indent': ?instance.indent,
  'offset': ?instance.offset,
  'border': ?instance.border,
};

const _$SlackMessageBlockElementEntityTypeEnumMap = {
  SlackMessageBlockElementEntityType.richTextSection: 'rich_text_section',
  SlackMessageBlockElementEntityType.richTextList: 'rich_text_list',
  SlackMessageBlockElementEntityType.richTextPreformatted:
      'rich_text_preformatted',
  SlackMessageBlockElementEntityType.richTextQuote: 'rich_text_quote',
  SlackMessageBlockElementEntityType.image: 'image',
  SlackMessageBlockElementEntityType.mrkdwn: 'mrkdwn',
};
