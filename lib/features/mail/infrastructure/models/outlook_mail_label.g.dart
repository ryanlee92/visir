// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'outlook_mail_label.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OutlookMailLabel _$OutlookMailLabelFromJson(Map<String, dynamic> json) =>
    OutlookMailLabel(
      id: json['id'] as String?,
      displayName: json['displayName'] as String?,
      childFolderCount: (json['childFolderCount'] as num?)?.toInt(),
      totalItemCount: (json['totalItemCount'] as num?)?.toInt(),
      unreadItemCount: (json['unreadItemCount'] as num?)?.toInt(),
      parentFolderId: json['parentFolderId'] as String?,
      wellKnownName: json['wellKnownName'] as String?,
    );

Map<String, dynamic> _$OutlookMailLabelToJson(OutlookMailLabel instance) =>
    <String, dynamic>{
      'id': ?instance.id,
      'displayName': ?instance.displayName,
      'childFolderCount': ?instance.childFolderCount,
      'totalItemCount': ?instance.totalItemCount,
      'unreadItemCount': ?instance.unreadItemCount,
      'parentFolderId': ?instance.parentFolderId,
      'wellKnownName': ?instance.wellKnownName,
    };
