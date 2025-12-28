// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feedback_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FeedbackEntity _$FeedbackEntityFromJson(Map<String, dynamic> json) =>
    _FeedbackEntity(
      id: json['id'] as String,
      authorId: json['author_id'] as String?,
      description: json['description'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      fileUrls: (json['file_urls'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      version: json['version'] as String,
      isAutoReport: json['is_auto_report'] as bool,
      platform: json['platform'] as String,
      osVersion: json['os_version'] as String,
      errorMessage: json['error_message'] as String?,
    );

Map<String, dynamic> _$FeedbackEntityToJson(_FeedbackEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'author_id': ?instance.authorId,
      'description': instance.description,
      'created_at': instance.createdAt.toIso8601String(),
      'file_urls': instance.fileUrls,
      'version': instance.version,
      'is_auto_report': instance.isAutoReport,
      'platform': instance.platform,
      'os_version': instance.osVersion,
      'error_message': ?instance.errorMessage,
    };
