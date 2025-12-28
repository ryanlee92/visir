// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'slack_message_block_rich_text_element_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SlackMessageBlockRichTextElementEntity
_$SlackMessageBlockRichTextElementEntityFromJson(Map<String, dynamic> json) =>
    _SlackMessageBlockRichTextElementEntity(
      type: $enumDecodeNullable(
        _$SlackMessageBlockRichTextElementEntityTypeEnumMap,
        json['type'],
      ),
      style: (json['style'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as bool),
      ),
      name: json['name'] as String?,
      unicode: json['unicode'] as String?,
      url: json['url'] as String?,
      text: json['text'] as String?,
      unsafe: json['unsafe'] as bool?,
      userId: json['user_id'] as String?,
      usergroupId: json['usergroup_id'] as String?,
      channelId: json['channel_id'] as String?,
      range: json['range'] as String?,
      fallback: json['fallback'] as String?,
      value: json['value'] as String?,
      elements: (json['elements'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList(),
      indent: (json['indent'] as num?)?.toInt(),
      offset: (json['offset'] as num?)?.toInt(),
    );

Map<String, dynamic> _$SlackMessageBlockRichTextElementEntityToJson(
  _SlackMessageBlockRichTextElementEntity instance,
) => <String, dynamic>{
  'type': ?_$SlackMessageBlockRichTextElementEntityTypeEnumMap[instance.type],
  'style': ?instance.style,
  'name': ?instance.name,
  'unicode': ?instance.unicode,
  'url': ?instance.url,
  'text': ?instance.text,
  'unsafe': ?instance.unsafe,
  'user_id': ?instance.userId,
  'usergroup_id': ?instance.usergroupId,
  'channel_id': ?instance.channelId,
  'range': ?instance.range,
  'fallback': ?instance.fallback,
  'value': ?instance.value,
  'elements': ?instance.elements,
  'indent': ?instance.indent,
  'offset': ?instance.offset,
};

const _$SlackMessageBlockRichTextElementEntityTypeEnumMap = {
  SlackMessageBlockRichTextElementEntityType.channel: 'channel',
  SlackMessageBlockRichTextElementEntityType.emoji: 'emoji',
  SlackMessageBlockRichTextElementEntityType.link: 'link',
  SlackMessageBlockRichTextElementEntityType.text: 'text',
  SlackMessageBlockRichTextElementEntityType.user: 'user',
  SlackMessageBlockRichTextElementEntityType.usergroup: 'usergroup',
  SlackMessageBlockRichTextElementEntityType.broadcast: 'broadcast',
  SlackMessageBlockRichTextElementEntityType.richTextSection:
      'rich_text_section',
  SlackMessageBlockRichTextElementEntityType.richTextPreformatted:
      'rich_text_preformatted',
  SlackMessageBlockRichTextElementEntityType.date: 'date',
  SlackMessageBlockRichTextElementEntityType.color: 'color',
  SlackMessageBlockRichTextElementEntityType.richTextList: 'rich_text_list',
  SlackMessageBlockRichTextElementEntityType.richTextQuote: 'rich_text_quote',
};
