// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_attachment_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_EventAttachmentEntity _$EventAttachmentEntityFromJson(
  Map<String, dynamic> json,
) => _EventAttachmentEntity(
  fileId: json['file_id'] as String?,
  fileUrl: json['file_url'] as String?,
  iconLink: json['icon_link'] as String?,
  mimeType: json['mime_type'] as String?,
  title: json['title'] as String?,
  size: (json['size'] as num?)?.toInt(),
  isInline: json['is_inline'] as bool?,
);

Map<String, dynamic> _$EventAttachmentEntityToJson(
  _EventAttachmentEntity instance,
) => <String, dynamic>{
  'file_id': ?instance.fileId,
  'file_url': ?instance.fileUrl,
  'icon_link': ?instance.iconLink,
  'mime_type': ?instance.mimeType,
  'title': ?instance.title,
  'size': ?instance.size,
  'is_inline': ?instance.isInline,
};
