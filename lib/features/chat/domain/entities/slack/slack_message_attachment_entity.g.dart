// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'slack_message_attachment_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SlackMessageAttachmentEntity _$SlackMessageAttachmentEntityFromJson(
  Map<String, dynamic> json,
) => _SlackMessageAttachmentEntity(
  serviceName: json['service_name'] as String?,
  serviceIcon: json['service_icon'] as String?,
  text: json['text'] as String?,
  fallback: json['fallback'] as String?,
  color: json['color'] as String?,
  pretext: json['pretext'] as String?,
  authorName: json['author_name'] as String?,
  authorLink: json['author_link'] as String?,
  authorIcon: json['author_icon'] as String?,
  authorSubname: json['author_subname'] as String?,
  title: json['title'] as String?,
  titleLink: json['title_link'] as String?,
  fromUrl: json['from_url'] as String?,
  imageUrl: json['image_url'] as String?,
  thumbUrl: json['thumb_url'] as String?,
  originalUrl: json['original_url'] as String?,
  footer: json['footer'] as String?,
  footerIcon: json['footer_icon'] as String?,
  ts: json['ts'],
  fields: json['fields'] as List<dynamic>?,
  blocks: json['blocks'] as List<dynamic>?,
  actions: json['actions'] as List<dynamic>?,
  thumbWidth: (json['thumb_width'] as num?)?.toInt(),
  thumbHeight: (json['thumb_height'] as num?)?.toInt(),
  id: (json['id'] as num?)?.toInt(),
  isMsgUnfurl: json['is_msg_unfurl'] as bool?,
  isShare: json['is_share'] as bool?,
);

Map<String, dynamic> _$SlackMessageAttachmentEntityToJson(
  _SlackMessageAttachmentEntity instance,
) => <String, dynamic>{
  'service_name': ?instance.serviceName,
  'service_icon': ?instance.serviceIcon,
  'text': ?instance.text,
  'fallback': ?instance.fallback,
  'color': ?instance.color,
  'pretext': ?instance.pretext,
  'author_name': ?instance.authorName,
  'author_link': ?instance.authorLink,
  'author_icon': ?instance.authorIcon,
  'author_subname': ?instance.authorSubname,
  'title': ?instance.title,
  'title_link': ?instance.titleLink,
  'from_url': ?instance.fromUrl,
  'image_url': ?instance.imageUrl,
  'thumb_url': ?instance.thumbUrl,
  'original_url': ?instance.originalUrl,
  'footer': ?instance.footer,
  'footer_icon': ?instance.footerIcon,
  'ts': ?instance.ts,
  'fields': ?instance.fields,
  'blocks': ?instance.blocks,
  'actions': ?instance.actions,
  'thumb_width': ?instance.thumbWidth,
  'thumb_height': ?instance.thumbHeight,
  'id': ?instance.id,
  'is_msg_unfurl': ?instance.isMsgUnfurl,
  'is_share': ?instance.isShare,
};
