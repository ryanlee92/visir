import 'dart:convert';

import 'package:Visir/config/providers.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/mail/domain/entities/mail_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_entity.dart';
import 'package:collection/collection.dart';

class LinkedMailEntity {
  String hostMail;
  String fromName;
  String messageId;
  String title;
  String threadId;
  MailEntityType type;
  DateTime date;
  String? link;
  String? pageToken;
  List<String>? labelIds;
  bool? encrypted;
  String? timezone;

  LinkedMailEntity({
    required this.title,
    required this.hostMail,
    required this.fromName,
    required this.messageId,
    required this.threadId,
    required this.type,
    required this.date,
    required this.link,
    required this.pageToken,
    required this.labelIds,
    required this.encrypted,
    this.timezone,
  });

  Map<String, dynamic> toJson({bool? local}) {
    return {
      'title': title.isNotEmpty == true
          ? local == true
                ? title
                : Utils.encryptAESCryptoJS(title, aesKey)
          : null,
      'host_mail': hostMail,
      'from_name': fromName.isNotEmpty == true
          ? local == true
                ? fromName
                : Utils.encryptAESCryptoJS(fromName, aesKey)
          : null,
      'message_id': messageId,
      'thread_id': threadId,
      'type': type.name,
      'date': date.toUtc().toIso8601String(),
      'link': link,
      'page_token': pageToken,
      'label_ids': labelIds,
      'encrypted': true,
      'timezone': timezone,
    };
  }

  factory LinkedMailEntity.fromJson(Map<String, dynamic> json, {bool? local}) {
    // 암호화된 데이터 자동 감지: base64로 디코딩하면 "Salted__"로 시작함
    bool isEncryptedData(String? value) {
      if (value == null || value.isEmpty) return false;
      try {
        final decoded = base64Decode(value);
        return decoded.length >= 8 && String.fromCharCodes(decoded.take(8)) == 'Salted__';
      } catch (e) {
        return false;
      }
    }

    String? decryptField(String? value) {
      if (value == null || value.isEmpty) return value;
      if (local == true) return value; // 로컬 저장소는 평문
      // encrypted 플래그가 true이거나 실제 데이터가 암호화되어 있으면 복호화
      if (json['encrypted'] == true || isEncryptedData(value)) {
        try {
          return Utils.decryptAESCryptoJS(value, aesKey);
        } catch (e) {
          return value; // 복호화 실패 시 원본 반환
        }
      }
      return value;
    }

    return LinkedMailEntity(
      title: decryptField(json['title'] as String?) ?? '',
      hostMail: json['host_mail'],
      fromName: decryptField(json['from_name'] as String?) ?? '',
      messageId: json['message_id'],
      threadId: json['thread_id'],
      type: MailEntityType.values.firstWhere((e) => e.name == json['type'], orElse: () => MailEntityType.google),
      date: DateTime.parse(json['date']).toLocal(),
      link: json['link'],
      pageToken: json['page_token'],
      labelIds: (json['label_ids'] as List?)?.map((e) => e.toString()).toList(),
      encrypted: json['encrypted'],
      timezone: json['timezone'],
    );
  }

  LinkedMailEntity copyWith({
    String? title,
    String? hostMail,
    String? fromName,
    String? messageId,
    String? threadId,
    MailEntityType? type,
    DateTime? date,
    String? link,
    String? pageToken,
    List<String>? labelIds,
    bool? encrypted,
    String? timezone,
  }) => LinkedMailEntity(
    title: title ?? this.title,
    hostMail: hostMail ?? this.hostMail,
    fromName: fromName ?? this.fromName,
    messageId: messageId ?? this.messageId,
    threadId: threadId ?? this.threadId,
    type: type ?? this.type,
    date: date ?? this.date,
    link: link ?? this.link,
    pageToken: pageToken ?? this.pageToken,
    labelIds: labelIds ?? this.labelIds,
    encrypted: encrypted ?? this.encrypted,
    timezone: timezone ?? this.timezone,
  );

  operator ==(Object other) {
    return other is LinkedMailEntity &&
        hostMail == other.hostMail &&
        fromName == other.fromName &&
        messageId == other.messageId &&
        threadId == other.threadId &&
        type == other.type &&
        date == other.date &&
        link == other.link &&
        pageToken == other.pageToken &&
        encrypted == other.encrypted &&
        timezone == other.timezone &&
        const ListEquality().equals(labelIds, other.labelIds);
  }
}

class LinkedMessageEntity {
  String teamId;
  String channelId;
  String userId;
  String messageId;
  String threadId;
  String userName;
  String channelName;
  MessageEntityType type;
  DateTime date;
  String? link;
  String? pageToken;
  bool? isDm;
  bool? isGroupDm;
  bool? isChannel;
  bool? isUserTagged;
  bool? isMe;

  LinkedMessageEntity({
    required this.teamId,
    required this.channelId,
    required this.userId,
    required this.messageId,
    required this.threadId,
    required this.userName,
    required this.channelName,
    required this.type,
    required this.date,
    required this.link,
    required this.pageToken,
    required this.isDm,
    required this.isGroupDm,
    required this.isChannel,
    required this.isUserTagged,
    required this.isMe,
  });

  Map<String, dynamic> toJson({bool? local}) {
    return {
      'team_id': teamId,
      'channel_id': channelId,
      'user_id': userId,
      'message_id': messageId,
      'thread_id': threadId,
      'user_name': userName.isNotEmpty == true
          ? local == true
                ? userName
                : Utils.encryptAESCryptoJS(userName, aesKey)
          : null,
      'channel_name': channelName.isNotEmpty == true
          ? local == true
                ? channelName
                : Utils.encryptAESCryptoJS(channelName, aesKey)
          : null,
      'type': type.name,
      'date': date.toUtc().toIso8601String(),
      'link': link,
      'page_token': pageToken,
      'is_dm': isDm,
      'is_group_dm': isGroupDm,
      'is_channel': isChannel,
      'is_user_tagged': isUserTagged,
      'is_me': isMe,
    };
  }

  factory LinkedMessageEntity.fromJson(Map<String, dynamic> json, {bool? local}) {
    // 암호화된 데이터 자동 감지: base64로 디코딩하면 "Salted__"로 시작함
    bool isEncryptedData(String? value) {
      if (value == null || value.isEmpty) return false;
      try {
        final decoded = base64Decode(value);
        return decoded.length >= 8 && String.fromCharCodes(decoded.take(8)) == 'Salted__';
      } catch (e) {
        return false;
      }
    }

    String? decryptField(String? value) {
      if (value == null || value.isEmpty) return value;
      if (local == true) return value; // 로컬 저장소는 평문
      // 실제 데이터가 암호화되어 있으면 복호화
      if (isEncryptedData(value)) {
        try {
          return Utils.decryptAESCryptoJS(value, aesKey);
        } catch (e) {
          return value; // 복호화 실패 시 원본 반환
        }
      }
      return value;
    }

    return LinkedMessageEntity(
      teamId: json['team_id'],
      channelId: json['channel_id'],
      userId: json['user_id'],
      messageId: json['message_id'],
      threadId: json['thread_id'],
      userName: decryptField(json['user_name'] as String?) ?? '',
      channelName: decryptField(json['channel_name'] as String?) ?? '',
      type: MessageEntityType.values.firstWhere((e) => e.name == json['type'], orElse: () => MessageEntityType.slack),
      date: DateTime.parse(json['date']),
      link: json['link'],
      pageToken: json['page_token'],
      isDm: json['is_dm'],
      isGroupDm: json['is_group_dm'],
      isChannel: json['is_channel'],
      isUserTagged: json['is_user_tagged'],
      isMe: json['is_me'],
    );
  }

  operator ==(Object other) {
    return other is LinkedMessageEntity &&
        other.messageId == messageId &&
        other.threadId == threadId &&
        other.userId == userId &&
        other.teamId == teamId &&
        other.channelId == channelId &&
        other.date == date &&
        other.type == type &&
        other.userName == userName &&
        other.channelName == channelName &&
        other.link == link &&
        other.pageToken == pageToken &&
        other.isDm == isDm &&
        other.isGroupDm == isGroupDm &&
        other.isChannel == isChannel &&
        other.isUserTagged == isUserTagged &&
        other.isMe == isMe;
  }
}
