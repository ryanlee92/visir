import 'package:json_annotation/json_annotation.dart';
import 'package:microsoft_graph_api/models/mail/attachment_model.dart';
import 'package:microsoft_graph_api/models/mail/followup_flag_model.dart';
import 'package:microsoft_graph_api/models/mail/item_body_model.dart';
import 'package:microsoft_graph_api/models/mail/recipient_model.dart';

part 'outlook_mail_message.g.dart';

/// Represents an email message in a user's mailbox.
@JsonSerializable()
class OutlookMailMessage {
  /// The message ID.
  final String? id;

  /// The subject line of the message.
  final String? subject;

  /// The HTML body content of the message.
  final String? bodyPreview;

  /// Indicates whether the message has attachments.
  final bool? hasAttachments;

  /// Indicates whether the message has attachments.
  final String? conversationId;

  /// The importance of the message: low, normal, or high.
  final String? importance;

  /// The date and time the message was received.
  final DateTime? receivedDateTime;

  /// The date and time the message was sent.
  final DateTime? sentDateTime;

  final DateTime? createdDateTime;

  final DateTime? lastModifiedDateTime;

  /// The sender of the message.
  final Recipient? sender;

  /// The display name of the sender.
  @JsonKey(name: 'from')
  final Recipient? from;

  /// The recipient list for the message.
  final List<Recipient>? toRecipients;

  /// The CC recipient list for the message.
  final List<Recipient>? ccRecipients;

  /// The BCC recipient list for the message.
  final List<Recipient>? bccRecipients;

  /// The message body.
  final ItemBody? body;

  /// Flag indicating whether the message has been read.
  final bool? isRead;

  final String? parentFolderId;

  /// Flag indicating whether the message has been favorited/flagged.
  @JsonKey(name: 'flag')
  final FollowupFlag? followupFlag;

  final List<String>? labelIds;

  final List<Attachment>? attachments;

  OutlookMailMessage({
    this.id,
    this.subject,
    this.bodyPreview,
    this.hasAttachments,
    this.conversationId,
    this.importance,
    this.receivedDateTime,
    this.sentDateTime,
    this.createdDateTime,
    this.sender,
    this.from,
    this.toRecipients,
    this.ccRecipients,
    this.bccRecipients,
    this.body,
    this.isRead,
    this.followupFlag,
    this.parentFolderId,
    this.labelIds,
    this.attachments,
    this.lastModifiedDateTime,
  });

  const OutlookMailMessage.empty()
      : id = null,
        createdDateTime = null,
        subject = null,
        bodyPreview = null,
        conversationId = null,
        hasAttachments = null,
        importance = null,
        receivedDateTime = null,
        sentDateTime = null,
        sender = null,
        from = null,
        toRecipients = null,
        ccRecipients = null,
        bccRecipients = null,
        body = null,
        isRead = null,
        lastModifiedDateTime = null,
        parentFolderId = null,
        labelIds = null,
        attachments = null,
        followupFlag = null;

  factory OutlookMailMessage.fromJson(Map<String, dynamic> json) => _$OutlookMailMessageFromJson(json);
  Map<String, dynamic> toJson() => _$OutlookMailMessageToJson(this);

  OutlookMailMessage copyWith({
    List<String>? labelIds,
    String? id,
    String? subject,
    String? bodyPreview,
    bool? hasAttachments,
    String? conversationId,
    String? importance,
    DateTime? receivedDateTime,
    DateTime? lastModifiedDateTime,
    DateTime? sentDateTime,
    DateTime? createdDateTime,
    Recipient? sender,
    Recipient? from,
    List<Recipient>? toRecipients,
    List<Recipient>? ccRecipients,
    List<Recipient>? bccRecipients,
    ItemBody? body,
    bool? isRead,
    String? parentFolderId,
    List<Attachment>? attachments,
    FollowupFlag? followupFlag,
  }) {
    return OutlookMailMessage(
      id: id ?? this.id,
      subject: subject ?? this.subject,
      bodyPreview: bodyPreview ?? this.bodyPreview,
      hasAttachments: hasAttachments ?? this.hasAttachments,
      conversationId: conversationId ?? this.conversationId,
      importance: importance ?? this.importance,
      receivedDateTime: receivedDateTime ?? this.receivedDateTime,
      lastModifiedDateTime: lastModifiedDateTime ?? this.lastModifiedDateTime,
      sentDateTime: sentDateTime ?? this.sentDateTime,
      createdDateTime: createdDateTime ?? this.createdDateTime,
      sender: sender ?? this.sender,
      from: from ?? this.from,
      toRecipients: toRecipients ?? this.toRecipients,
      ccRecipients: ccRecipients ?? this.ccRecipients,
      bccRecipients: bccRecipients ?? this.bccRecipients,
      body: body ?? this.body,
      isRead: isRead ?? this.isRead,
      parentFolderId: parentFolderId ?? this.parentFolderId,
      followupFlag: followupFlag ?? this.followupFlag,
      labelIds: labelIds ?? this.labelIds,
      attachments: attachments ?? this.attachments,
    );
  }

  bool isLikelyNewMessage(DateTime created, DateTime modified, {Duration tolerance = const Duration(seconds: 5)}) {
    return (created.difference(modified).abs() <= tolerance);
  }

  bool get isCreated => (createdDateTime != null && lastModifiedDateTime != null && isLikelyNewMessage(createdDateTime!, lastModifiedDateTime!));
}
