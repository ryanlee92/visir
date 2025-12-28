// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'slack_message_block_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SlackMessageBlockEntity _$SlackMessageBlockEntityFromJson(
  Map<String, dynamic> json,
) => _SlackMessageBlockEntity(
  type: $enumDecodeNullable(_$SlackMessageBlockEntityTypeEnumMap, json['type']),
  blockId: json['block_id'] as String?,
  externalId: json['external_id'] as String?,
  altText: json['alt_text'] as String?,
  imageUrl: json['image_url'] as String?,
  authorName: json['author_name'] as String?,
  providerIconUrl: json['provider_icon_url'] as String?,
  providerName: json['provider_name'] as String?,
  titleUrl: json['title_url'] as String?,
  thumbnailUrl: json['thumbnail_url'] as String?,
  videoUrl: json['video_url'] as String?,
  dispatchAction: json['dispatch_action'] as bool?,
  optional: json['optional'] as bool?,
  text: json['text'] == null
      ? null
      : SlackMessageBlockTextObjectEntity.fromJson(
          json['text'] as Map<String, dynamic>,
        ),
  title: json['title'] as Map<String, dynamic>?,
  slackFile: json['slack_file'] as Map<String, dynamic>?,
  label: json['label'] as Map<String, dynamic>?,
  element: json['element'] as Map<String, dynamic>?,
  hint: json['hint'] as Map<String, dynamic>?,
  accessory: json['accessory'] as Map<String, dynamic>?,
  description: json['description'] as Map<String, dynamic>?,
  elements: (json['elements'] as List<dynamic>?)
      ?.map((e) => e as Map<String, dynamic>)
      .toList(),
  fields: (json['fields'] as List<dynamic>?)
      ?.map((e) => e as Map<String, dynamic>)
      .toList(),
);

Map<String, dynamic> _$SlackMessageBlockEntityToJson(
  _SlackMessageBlockEntity instance,
) => <String, dynamic>{
  'type': ?_$SlackMessageBlockEntityTypeEnumMap[instance.type],
  'block_id': ?instance.blockId,
  'external_id': ?instance.externalId,
  'alt_text': ?instance.altText,
  'image_url': ?instance.imageUrl,
  'author_name': ?instance.authorName,
  'provider_icon_url': ?instance.providerIconUrl,
  'provider_name': ?instance.providerName,
  'title_url': ?instance.titleUrl,
  'thumbnail_url': ?instance.thumbnailUrl,
  'video_url': ?instance.videoUrl,
  'dispatch_action': ?instance.dispatchAction,
  'optional': ?instance.optional,
  'text': ?instance.text?.toJson(),
  'title': ?instance.title,
  'slack_file': ?instance.slackFile,
  'label': ?instance.label,
  'element': ?instance.element,
  'hint': ?instance.hint,
  'accessory': ?instance.accessory,
  'description': ?instance.description,
  'elements': ?instance.elements,
  'fields': ?instance.fields,
};

const _$SlackMessageBlockEntityTypeEnumMap = {
  SlackMessageBlockEntityType.actions: 'actions',
  SlackMessageBlockEntityType.context: 'context',
  SlackMessageBlockEntityType.divider: 'divider',
  SlackMessageBlockEntityType.file: 'file',
  SlackMessageBlockEntityType.header: 'header',
  SlackMessageBlockEntityType.image: 'image',
  SlackMessageBlockEntityType.input: 'input',
  SlackMessageBlockEntityType.richText: 'rich_text',
  SlackMessageBlockEntityType.section: 'section',
  SlackMessageBlockEntityType.video: 'video',
};
