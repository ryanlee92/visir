import 'dart:convert';
import 'dart:math';

import 'package:Visir/config/providers.dart';
import 'package:Visir/features/chat/domain/entities/message_channel_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_group_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_member_entity.dart';
import 'package:Visir/features/common/domain/entities/linked_item_entity.dart';
import 'package:Visir/features/common/presentation/utils/constants.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/inbox/domain/entities/inbox_config_entity.dart';
import 'package:Visir/features/inbox/domain/entities/inbox_linked_task_entity.dart';
import 'package:Visir/features/inbox/domain/entities/inbox_suggestion_entity.dart';
import 'package:Visir/features/mail/domain/entities/mail_entity.dart';
import 'package:Visir/features/mail/domain/entities/mail_label_entity.dart';
import 'package:Visir/features/preference/application/local_pref_controller.dart';
import 'package:Visir/features/preference/domain/entities/oauth_entity.dart';
import 'package:Visir/features/task/domain/entities/task_entity.dart';
import 'package:collection/collection.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class InboxMessageEntity {
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

  InboxMessageEntity({
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

  factory InboxMessageEntity.fromJson(Map<String, dynamic> json, {bool? local}) {
    return InboxMessageEntity(
      teamId: json['team_id'],
      channelId: json['channel_id'],
      userId: json['user_id'],
      messageId: json['message_id'],
      threadId: json['thread_id'],
      userName: local == true ? json['user_name'] : Utils.decryptAESCryptoJS(json['user_name'], aesKey),
      channelName: local == true ? json['channel_name'] : Utils.decryptAESCryptoJS(json['channel_name'], aesKey),
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
    return other is InboxMessageEntity &&
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

class InboxEntity {
  String id;
  String title;
  String? description;
  LinkedMailEntity? linkedMail;
  LinkedMessageEntity? linkedMessage;

  InboxConfigEntity? config;
  InboxSuggestionEntity? suggestion;
  InboxLinkedTaskEntity? linkedTask;
  bool? isSuggestion;
  bool? isPinned;
  List<String>? mergedInboxIds; // IDs of merged inbox items (same message)

  InboxEntity({
    required this.id,
    required this.title,
    this.description,
    this.linkedMail,
    this.linkedMessage,
    this.config,
    this.suggestion,
    this.isSuggestion,
    this.linkedTask,
    this.isPinned,
    this.mergedInboxIds,
  });

  InboxEntity copyWith({
    String? id,
    String? title,
    String? description,
    LinkedMailEntity? linkedMail,
    LinkedMessageEntity? linkedMessage,
    InboxConfigEntity? config,
    InboxSuggestionEntity? suggestion,
    InboxLinkedTaskEntity? linkedTask,
    bool? isPinned,
    bool? isSuggestion,
    List<String>? mergedInboxIds,
  }) {
    return InboxEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      linkedMail: linkedMail ?? this.linkedMail,
      linkedMessage: linkedMessage ?? this.linkedMessage,
      config: config ?? this.config,
      suggestion: suggestion ?? this.suggestion,
      isPinned: isPinned ?? this.isPinned,
      linkedTask: linkedTask ?? this.linkedTask,
      isSuggestion: isSuggestion ?? this.isSuggestion,
      mergedInboxIds: mergedInboxIds ?? this.mergedInboxIds,
    );
  }

  Map<String, dynamic> toJson({bool? local}) {
    String? encryptField(String? value) {
      if (value == null || value.isEmpty) return value;
      if (local == true) return value; // 로컬 저장소는 평문
      return Utils.encryptAESCryptoJS(value, aesKey);
    }

    return {
      'id': id,
      'title': encryptField(title),
      'description': encryptField(description),
      'linked_mail': linkedMail?.toJson(local: local),
      'linked_message': linkedMessage?.toJson(local: local),
      'config': config?.toJson(),
      'suggestion': suggestion?.toJson(local: local),
      'is_pinned': isPinned,
      'linked_task': linkedTask?.toJson(),
      'is_suggestion': isSuggestion,
      'merged_inbox_ids': mergedInboxIds,
    };
  }

  factory InboxEntity.fromMail(MailEntity e, InboxConfigEntity? config) {
    final userId = Supabase.instance.client.auth.currentUser?.id ?? fakeUser.id;
    return InboxEntity(
      id: InboxEntity.getInboxIdFromMail(e),
      title: e.subject?.isNotEmpty == true ? e.subject! : Utils.mainContext.tr.mail_empty_subject,
      description: e.snippetWithLineBreaks ?? e.snippet, // Use snippetWithLineBreaks for AI actions (longer, preserves line breaks)
      isPinned: e.isPinned,
      config: config ?? InboxConfigEntity(id: InboxEntity.getInboxIdFromMail(e), userId: userId, dateTime: e.date ?? DateTime.now()),
      linkedMail: LinkedMailEntity(
        title: e.subject ?? '',
        hostMail: e.hostEmail,
        fromName: e.from?.name ?? e.from?.email ?? '',
        messageId: e.id!,
        threadId: e.threadId!,
        type: e.type,
        date: e.date ?? DateTime.now(),
        link: e.link,
        pageToken: e.pageToken,
        labelIds: e.labelIds ?? [],
        encrypted: true,
        timezone: e.timezone,
      ),
    );
  }

  factory InboxEntity.fromChat(
    MessageEntity m,
    InboxConfigEntity? config,
    MessageChannelEntity channel,
    MessageMemberEntity sender,
    List<MessageChannelEntity> channels,
    List<MessageMemberEntity> members,
    List<MessageGroupEntity> groups,
  ) {
    final userId = Supabase.instance.client.auth.currentUser?.id ?? fakeUser.id;
    return InboxEntity(
      id: InboxEntity.getInboxIdFromChat(m),
      title: m.toSnippet(channel: channel, channels: channels, members: members, groups: groups),
      isPinned: m.isPinned,
      config: config ?? InboxConfigEntity(id: InboxEntity.getInboxIdFromChat(m), userId: userId, dateTime: m.createdAt ?? DateTime.now()),
      linkedMessage: LinkedMessageEntity(
        teamId: m.teamId!,
        channelId: channel.id,
        userId: m.userId!,
        messageId: m.id!,
        threadId: m.threadId ?? '',
        type: m.type,
        date: m.createdAt ?? DateTime.now(),
        userName: sender.displayName!,
        channelName: channel.displayName,
        link: m.link,
        pageToken: m.pageToken,
        isDm: channel.isDm,
        isChannel: channel.isChannel,
        isGroupDm: channel.isGroupDm,
        isUserTagged: m.isUserTagged(userId: channel.meId, groups: groups),
        isMe: channel.meId == m.userId,
      ),
    );
  }

  factory InboxEntity.fromJson(Map<String, dynamic> json, {bool? local}) {
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
      // local이 true여도 이미 암호화된 데이터가 저장되어 있을 수 있으므로 항상 확인
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

    return InboxEntity(
      id: json['id'],
      title: decryptField(json['title'] as String?) ?? '',
      description: decryptField(json['description'] as String?),
      linkedMail: json['linked_mail'] != null ? LinkedMailEntity.fromJson(json['linked_mail'], local: local) : null,
      linkedMessage: json['linked_message'] != null ? LinkedMessageEntity.fromJson(json['linked_message'], local: local) : null,
      config: json['config'] != null ? InboxConfigEntity.fromJson(json['config']) : null,
      suggestion: json['suggestion'] != null ? InboxSuggestionEntity.fromJson(json['suggestion'], local: local) : null,
      isPinned: json['is_pinned'],
      linkedTask: json['linked_task'] != null ? InboxLinkedTaskEntity.fromJson(json['linked_task']) : null,
      isSuggestion: json['is_suggestion'],
      mergedInboxIds: json['merged_inbox_ids'] != null ? List<String>.from(json['merged_inbox_ids']) : null,
    );
  }

  List<InboxProvider> get providers {
    List<InboxProvider> providers = [];
    final localPref = Utils.ref.read(localPrefControllerProvider).value;
    if (localPref == null) return providers; // localPref가 null이면 빈 리스트 반환

    if (linkedMail != null) {
      final oauth = localPref.mailOAuths?.firstWhereOrNull((e) => e.email == linkedMail!.hostMail);
      providers.add(InboxProvider(icon: linkedMail!.type.icon, name: linkedMail!.fromName, datetime: linkedMail!.date, avatarUrl: oauth?.notificationUrl));
    }
    if (linkedMessage != null) {
      final oauth = localPref.messengerOAuths?.firstWhereOrNull((e) => e.teamId == linkedMessage!.teamId);
      providers.add(
        InboxProvider(
          icon: linkedMessage!.type.icon,
          name: '${!(linkedMessage!.isDm ?? false) ? '#' : ''}${linkedMessage!.channelName}',
          datetime: linkedMessage!.date,
          avatarUrl: oauth?.notificationUrl,
        ),
      );
    }
    return providers;
  }

  operator ==(Object other) {
    return other is InboxEntity &&
        other.id == id &&
        other.linkedMail == linkedMail &&
        other.linkedMessage == linkedMessage &&
        other.config == config &&
        other.suggestion == suggestion &&
        other.isPinned == isPinned &&
        other.isSuggestion == isSuggestion;
  }

  String get uniqueId => id;

  bool get isThread => linkedMessage?.threadId.isNotEmpty == true && linkedMessage?.threadId != linkedMessage?.messageId;

  String? get inboxPageToken => linkedMail?.pageToken ?? linkedMessage?.pageToken;

  DateTime get inboxDatetime => linkedMail?.date ?? linkedMessage?.date ?? DateTime(1970);

  String? get inboxId => linkedMail?.messageId ?? linkedMessage?.messageId;

  String? get inboxGroupId => linkedMail?.threadId ?? linkedMessage?.channelId;

  String? get inboxSearchId => linkedMail?.hostMail ?? linkedMessage?.teamId;

  String? get inboxIdWithCheckSuggestion => '${isSuggestion == true ? 'suggestion_' : ''}$inboxId';

  String? get inboxGroupIdWithCheckSuggestion => '${isSuggestion == true ? 'suggestion_' : ''}$inboxGroupId';

  // title이 암호화되어 있을 수 있으므로 복호화하여 반환
  String get decryptedTitle {
    if (title.isEmpty) return title;
    // 암호화된 데이터 자동 감지
    // CryptoJS로 암호화된 데이터는 base64로 인코딩되어 있고, 디코딩하면 "Salted__"로 시작함
    bool isEncryptedData(String value) {
      if (value.isEmpty) return false;
      // base64 문자열 형식 확인 (길이가 충분하고 base64 문자만 포함)
      if (value.length < 16) return false; // 암호화된 데이터는 최소 길이가 있음
      // base64 디코딩 시도
      try {
        final decoded = base64Decode(value);
        if (decoded.length >= 8) {
          final header = String.fromCharCodes(decoded.take(8));
          return header == 'Salted__';
        }
      } catch (e) {
        // base64 디코딩 실패 시 평문으로 간주
        return false;
      }
      return false;
    }

    if (isEncryptedData(title)) {
      try {
        String decrypted = Utils.decryptAESCryptoJS(title, aesKey);

        // 복호화된 결과가 여전히 암호화된 형식인지 확인 (중첩 암호화 처리)
        // base64 디코딩을 시도하지 않고, 길이와 시작 문자열만 확인
        bool isStillEncrypted = decrypted.length >= 16 && decrypted.startsWith('U2FsdGVkX1') && (decrypted.length % 4 == 0 || decrypted.length % 4 == 1); // base64 길이 패턴

        if (isStillEncrypted) {
          try {
            // 실제로 base64 디코딩이 가능한지 확인
            final testDecoded = base64Decode(decrypted);
            if (testDecoded.length >= 8 && String.fromCharCodes(testDecoded.take(8)) == 'Salted__') {
              decrypted = Utils.decryptAESCryptoJS(decrypted, aesKey);
            }
          } catch (e) {
            // base64 디코딩 실패 = 평문이므로 첫 번째 복호화 결과 반환
          }
        }

        return decrypted;
      } catch (e) {
        return title; // 복호화 실패 시 원본 반환
      }
    }
    return title;
  }

  String get shortTitle {
    final decrypted = decryptedTitle;
    return '${decrypted.substring(0, min(decrypted.length, 120))}${decrypted.length > 120 ? '...' : ''}';
  }

  String get messageTeamId => linkedMessage?.teamId ?? '';

  String get messageChannelId => linkedMessage?.channelId ?? '';

  bool get isRead => config?.isRead ?? false;

  bool getIsUnread(List<MessageChannelEntity> channels) {
    if (config?.isRead != null) return !config!.isRead!;
    if (linkedMail != null) {
      return linkedMail!.labelIds?.contains(CommonMailLabels.unread.id) == true;
    }

    if (linkedMessage != null) {
      final channel = channels.firstWhereOrNull((e) => e.id == linkedMessage!.channelId);
      return channel?.hasUnreadMessage == true;
    }

    return false;
  }

  static String Function(MailEntity mail) getInboxIdFromMail = (MailEntity mail) => 'mail_${mail.type.name}_${mail.hostEmail}_${mail.id}';
  static String Function(LinkedMailEntity mail) getInboxIdFromLinkedMail = (LinkedMailEntity mail) => 'mail_${mail.type.name}_${mail.hostMail}_${mail.messageId}';
  static String Function(MessageEntity chat) getInboxIdFromChat = (MessageEntity chat) => 'message_${chat.type.name}_${chat.teamId}_${chat.id}';
  static String Function(LinkedMessageEntity chat) getInboxIdFromLinkedChat = (LinkedMessageEntity chat) => 'message_${chat.type.name}_${chat.teamId}_${chat.messageId}';
}

class InboxProvider {
  String icon;
  String name;
  DateTime datetime;
  String? avatarUrl;

  InboxProvider({required this.icon, required this.name, required this.datetime, this.avatarUrl});

  operator ==(Object other) {
    return other is InboxProvider && other.icon == icon && other.name == name && other.datetime == datetime && other.avatarUrl == avatarUrl;
  }
}

extension InboxEntityX on InboxEntity {
  TaskEntity toTaskEntity() {
    return TaskEntity(
      id: id,
      title: title,
      description: description,
      linkedMails: linkedMail != null ? [linkedMail!] : [],
      linkedMessages: linkedMessage != null ? [linkedMessage!] : [],
    );
  }
}
