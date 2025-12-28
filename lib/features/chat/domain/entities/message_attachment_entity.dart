import 'dart:ui';

import 'package:Visir/features/common/presentation/utils/extensions/color_extension.dart';
import 'package:Visir/features/chat/domain/entities/slack/slack_message_attachment_entity.dart';
import 'package:emoji_extension/emoji_extension.dart' as emojiExtension;

enum MessageAttachmentEntityType {
  slack,
}

class MessageAttachmentEntity {
  //for slack
  final SlackMessageAttachmentEntity? _slackMessageAttachment;

  //common
  final MessageAttachmentEntityType type;

  MessageAttachmentEntity.fromSlack({SlackMessageAttachmentEntity? attachment})
      : _slackMessageAttachment = attachment,
        type = MessageAttachmentEntityType.slack;

  factory MessageAttachmentEntity.fromJson(Map<String, dynamic> json) {
    MessageAttachmentEntityType messageAttachmentType = MessageAttachmentEntityType.values.firstWhere(
      (e) => e.name == json['messageAttachmentType'],
      orElse: () => MessageAttachmentEntityType.slack,
    );

    if (messageAttachmentType == MessageAttachmentEntityType.slack) {
      return MessageAttachmentEntity.fromSlack(
        attachment: SlackMessageAttachmentEntity.fromJson(json['_slackMessageAttachment']),
      );
    }

    return MessageAttachmentEntity.fromSlack(
      attachment: SlackMessageAttachmentEntity.fromJson(json['_slackMessageAttachment']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "messageAttachmentType": type.name,
      "_slackMessageAttachment": _slackMessageAttachment?.toJson(),
    };
  }

  SlackMessageAttachmentEntity? get slackMessageAttachment {
    switch (type) {
      case MessageAttachmentEntityType.slack:
        return _slackMessageAttachment;
    }
  }

  Color? get color {
    switch (type) {
      case MessageAttachmentEntityType.slack:
        return _slackMessageAttachment?.color == null ? null : ColorX.fromHex('${_slackMessageAttachment?.color}');
    }
  }

  String? get title {
    switch (type) {
      case MessageAttachmentEntityType.slack:
        return _slackMessageAttachment?.title;
    }
  }

  String? get pretext {
    switch (type) {
      case MessageAttachmentEntityType.slack:
        return _slackMessageAttachment?.pretext?.emojis.fromShortcodes();
    }
  }

  String? get text {
    switch (type) {
      case MessageAttachmentEntityType.slack:
        return _slackMessageAttachment?.text;
    }
  }

  String? get fallback {
    switch (type) {
      case MessageAttachmentEntityType.slack:
        return _slackMessageAttachment?.fallback;
    }
  }

  String? get fromUrl {
    switch (type) {
      case MessageAttachmentEntityType.slack:
        return _slackMessageAttachment?.fromUrl;
    }
  }

  String? get serviceIcon {
    switch (type) {
      case MessageAttachmentEntityType.slack:
        return _slackMessageAttachment?.serviceIcon;
    }
  }

  String? get serviceName {
    switch (type) {
      case MessageAttachmentEntityType.slack:
        return _slackMessageAttachment?.serviceName;
    }
  }

  String? get titleLink {
    switch (type) {
      case MessageAttachmentEntityType.slack:
        return _slackMessageAttachment?.titleLink;
    }
  }

  String? get footerIcon {
    switch (type) {
      case MessageAttachmentEntityType.slack:
        return _slackMessageAttachment?.footerIcon;
    }
  }

  String? get footer {
    switch (type) {
      case MessageAttachmentEntityType.slack:
        return _slackMessageAttachment?.footer;
    }
  }

  bool? get isMsgUnfurl {
    switch (type) {
      case MessageAttachmentEntityType.slack:
        return _slackMessageAttachment?.isMsgUnfurl;
    }
  }

  bool? get isShare {
    switch (type) {
      case MessageAttachmentEntityType.slack:
        return _slackMessageAttachment?.isShare;
    }
  }

  bool get isForwardedMessage => isMsgUnfurl == true || isShare == true;

  bool get isForwardedFromThread => isForwardedMessage && footer?.contains('Thread') == true;

  String? get authorIcon {
    switch (type) {
      case MessageAttachmentEntityType.slack:
        return _slackMessageAttachment?.authorIcon;
    }
  }

  String? get authorName {
    switch (type) {
      case MessageAttachmentEntityType.slack:
        return _slackMessageAttachment?.authorName;
    }
  }

  String? get authorSubname {
    switch (type) {
      case MessageAttachmentEntityType.slack:
        return _slackMessageAttachment?.authorSubname;
    }
  }

  String? get authorLink {
    switch (type) {
      case MessageAttachmentEntityType.slack:
        return _slackMessageAttachment?.authorLink;
    }
  }

  String? get ts {
    switch (type) {
      case MessageAttachmentEntityType.slack:
        return _slackMessageAttachment?.ts;
    }
  }

  DateTime? get fromMessageCreatedAt {
    switch (type) {
      case MessageAttachmentEntityType.slack:
        return _slackMessageAttachment?.ts == null
            ? null
            : DateTime.fromMicrosecondsSinceEpoch((double.tryParse(_slackMessageAttachment!.ts!)! * 1000000).toInt());
    }
  }

  String? get authorId => authorLink?.split('/').last;
}
