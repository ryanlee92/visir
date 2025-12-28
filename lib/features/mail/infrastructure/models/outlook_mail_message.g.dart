// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'outlook_mail_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OutlookMailMessage _$OutlookMailMessageFromJson(Map<String, dynamic> json) =>
    OutlookMailMessage(
      id: json['id'] as String?,
      subject: json['subject'] as String?,
      bodyPreview: json['bodyPreview'] as String?,
      hasAttachments: json['hasAttachments'] as bool?,
      conversationId: json['conversationId'] as String?,
      importance: json['importance'] as String?,
      receivedDateTime: json['receivedDateTime'] == null
          ? null
          : DateTime.parse(json['receivedDateTime'] as String),
      sentDateTime: json['sentDateTime'] == null
          ? null
          : DateTime.parse(json['sentDateTime'] as String),
      createdDateTime: json['createdDateTime'] == null
          ? null
          : DateTime.parse(json['createdDateTime'] as String),
      sender: json['sender'] == null
          ? null
          : Recipient.fromJson(json['sender'] as Map<String, dynamic>),
      from: json['from'] == null
          ? null
          : Recipient.fromJson(json['from'] as Map<String, dynamic>),
      toRecipients: (json['toRecipients'] as List<dynamic>?)
          ?.map((e) => Recipient.fromJson(e as Map<String, dynamic>))
          .toList(),
      ccRecipients: (json['ccRecipients'] as List<dynamic>?)
          ?.map((e) => Recipient.fromJson(e as Map<String, dynamic>))
          .toList(),
      bccRecipients: (json['bccRecipients'] as List<dynamic>?)
          ?.map((e) => Recipient.fromJson(e as Map<String, dynamic>))
          .toList(),
      body: json['body'] == null
          ? null
          : ItemBody.fromJson(json['body'] as Map<String, dynamic>),
      isRead: json['isRead'] as bool?,
      followupFlag: json['flag'] == null
          ? null
          : FollowupFlag.fromJson(json['flag'] as Map<String, dynamic>),
      parentFolderId: json['parentFolderId'] as String?,
      labelIds: (json['labelIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      attachments: (json['attachments'] as List<dynamic>?)
          ?.map((e) => Attachment.fromJson(e as Map<String, dynamic>))
          .toList(),
      lastModifiedDateTime: json['lastModifiedDateTime'] == null
          ? null
          : DateTime.parse(json['lastModifiedDateTime'] as String),
    );

Map<String, dynamic> _$OutlookMailMessageToJson(OutlookMailMessage instance) =>
    <String, dynamic>{
      'id': ?instance.id,
      'subject': ?instance.subject,
      'bodyPreview': ?instance.bodyPreview,
      'hasAttachments': ?instance.hasAttachments,
      'conversationId': ?instance.conversationId,
      'importance': ?instance.importance,
      'receivedDateTime': ?instance.receivedDateTime?.toIso8601String(),
      'sentDateTime': ?instance.sentDateTime?.toIso8601String(),
      'createdDateTime': ?instance.createdDateTime?.toIso8601String(),
      'lastModifiedDateTime': ?instance.lastModifiedDateTime?.toIso8601String(),
      'sender': ?instance.sender?.toJson(),
      'from': ?instance.from?.toJson(),
      'toRecipients': ?instance.toRecipients?.map((e) => e.toJson()).toList(),
      'ccRecipients': ?instance.ccRecipients?.map((e) => e.toJson()).toList(),
      'bccRecipients': ?instance.bccRecipients?.map((e) => e.toJson()).toList(),
      'body': ?instance.body?.toJson(),
      'isRead': ?instance.isRead,
      'parentFolderId': ?instance.parentFolderId,
      'flag': ?instance.followupFlag?.toJson(),
      'labelIds': ?instance.labelIds,
      'attachments': ?instance.attachments?.map((e) => e.toJson()).toList(),
    };
