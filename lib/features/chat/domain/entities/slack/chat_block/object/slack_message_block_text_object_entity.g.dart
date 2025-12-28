// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'slack_message_block_text_object_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SlackMessageBlockTextObjectEntity _$SlackMessageBlockTextObjectEntityFromJson(
  Map<String, dynamic> json,
) => _SlackMessageBlockTextObjectEntity(
  type: $enumDecodeNullable(
    _$SlackMessageBlockTextObjectEntityTypeEnumMap,
    json['type'],
  ),
  text: json['text'] as String?,
  emoji: json['emoji'] as bool?,
  verbatim: json['verbatim'] as bool?,
);

Map<String, dynamic> _$SlackMessageBlockTextObjectEntityToJson(
  _SlackMessageBlockTextObjectEntity instance,
) => <String, dynamic>{
  'type': ?_$SlackMessageBlockTextObjectEntityTypeEnumMap[instance.type],
  'text': ?instance.text,
  'emoji': ?instance.emoji,
  'verbatim': ?instance.verbatim,
};

const _$SlackMessageBlockTextObjectEntityTypeEnumMap = {
  SlackMessageBlockTextObjectEntityType.plainText: 'plain_text',
  SlackMessageBlockTextObjectEntityType.mrkdwn: 'mrkdwn',
};
