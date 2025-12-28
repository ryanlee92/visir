import 'package:Visir/features/chat/domain/entities/message_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_reaction_entity.dart';
import 'package:Visir/features/chat/domain/entities/slack/slack_channel_entity.dart';
import 'package:Visir/features/common/presentation/widgets/visir_icon.dart';
import 'package:Visir/features/preference/domain/entities/oauth_entity.dart';

enum MessageChannelEntityType { slack }

extension MessageChannelEntityTypeX on MessageChannelEntityType {
  DatasourceType get datasourceType {
    switch (this) {
      case MessageChannelEntityType.slack:
        return DatasourceType.slack;
    }
  }

  OAuthType get oAuthType {
    switch (this) {
      case MessageChannelEntityType.slack:
        return OAuthType.slack;
    }
  }
}

class MessageChannelEntity {
  SlackMessageChannelEntity? _slackChannel;
  final MessageChannelEntityType type;
  String teamId;
  String meId;
  String? customName;

  String get uniqueId => '${type.name}_${teamId}_${id}';

  MessageChannelEntity({required this.type, required this.teamId, required this.meId, this.customName, SlackMessageChannelEntity? slackChannel}) {
    if (type == MessageChannelEntityType.slack) {
      _slackChannel = slackChannel;
    }
  }

  MessageChannelEntity.fromSlack({required SlackMessageChannelEntity channel, required this.teamId, required this.meId, this.customName})
    : _slackChannel = channel,
      type = MessageChannelEntityType.slack;

  factory MessageChannelEntity.fromJson(Map<String, dynamic> json) {
    MessageChannelEntityType type = MessageChannelEntityType.values.firstWhere((e) => e.name == json['type'], orElse: () => MessageChannelEntityType.slack);

    if (type == MessageChannelEntityType.slack) {
      return MessageChannelEntity.fromSlack(
        channel: SlackMessageChannelEntity.fromJson(json['_slackChannel']),
        teamId: json['teamId'],
        meId: json['meId'],
        customName: json['customName'],
      );
    }

    return MessageChannelEntity.fromSlack(
      channel: SlackMessageChannelEntity.fromJson(json['_slackChannel']),
      teamId: json['teamId'],
      meId: json['meId'],
      customName: json['customName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {"type": type.name, "_slackChannel": _slackChannel?.toJson(), "teamId": teamId, "meId": meId, "customName": customName};
  }

  MessageChannelEntity copyWith({DateTime? lastUpdated, DateTime? lastReadAt, int? unreadCount, String? customName}) {
    if (type == MessageChannelEntityType.slack) {
      return MessageChannelEntity.fromSlack(
        channel: _slackChannel!.copyWith(
          lastUpdated: lastUpdated ?? this.lastUpdated,
          lastRead: (lastReadAt ?? this.lastReadAt) == null ? null : ((lastReadAt ?? this.lastReadAt)!.millisecondsSinceEpoch / 1000000).toString(),
          unreadCount: unreadCount ?? this.unreadCount,
          unreadCountDisplay: unreadCount ?? this.unreadCount,
        ),
        teamId: teamId,
        meId: meId,
        customName: customName ?? this.customName,
      );
    }

    return this;
  }

  MessageChannelEntity simplify() {
    if (type == MessageChannelEntityType.slack) {
      return MessageChannelEntity(type: type, slackChannel: _slackChannel!, teamId: teamId, meId: meId, customName: customName);
    }

    return this;
  }

  String get displayName {
    return customName ?? '';
  }

  String get membersNameString {
    if (isGroupDm) {
      List<String> names = displayName.split(',');
      if (names.length < 2) {
        return displayName;
      } else {
        String last = names.last;
        names.removeLast();
        return '${names.join(', ')} and ${last}';
      }
    } else {
      return '';
    }
  }

  String? get name {
    switch (type) {
      case MessageChannelEntityType.slack:
        return _slackChannel?.name;
    }
  }

  String get id {
    switch (type) {
      case MessageChannelEntityType.slack:
        return _slackChannel!.id!;
    }
  }

  VisirIconType get icon {
    switch (type) {
      case MessageChannelEntityType.slack:
        if ((_slackChannel?.isIm ?? false) || (_slackChannel?.isMpim ?? false)) {
          return VisirIconType.chatDm;
        } else {
          return VisirIconType.chatChannel;
        }
    }
  }

  bool get isDm {
    switch (type) {
      case MessageChannelEntityType.slack:
        return _slackChannel?.isIm ?? false;
    }
  }

  bool get isGroupDm {
    switch (type) {
      case MessageChannelEntityType.slack:
        return _slackChannel?.isMpim ?? false;
    }
  }

  bool get isChannel {
    switch (type) {
      case MessageChannelEntityType.slack:
        return !isDm && !isGroupDm;
    }
  }

  bool get isMember {
    switch (type) {
      case MessageChannelEntityType.slack:
        return isDm ? true : _slackChannel?.isMember ?? false;
    }
  }

  DateTime? get lastReadAt {
    switch (type) {
      case MessageChannelEntityType.slack:
        if (_slackChannel?.lastRead == null) return null;
        final date = DateTime.fromMicrosecondsSinceEpoch((double.parse(_slackChannel!.lastRead!) * 1000000).toInt());
        if (date.year == 1970) return DateTime.fromMillisecondsSinceEpoch((double.parse(_slackChannel!.lastRead!) * 1000000).toInt());
        return date;
    }
  }

  DateTime? get createdAt {
    switch (type) {
      case MessageChannelEntityType.slack:
        return _slackChannel?.created == null ? null : DateTime.fromMillisecondsSinceEpoch(_slackChannel!.created! * 1000);
    }
  }

  DateTime? get updatedAt {
    switch (type) {
      case MessageChannelEntityType.slack:
        return _slackChannel?.updated == null ? null : DateTime.fromMillisecondsSinceEpoch(_slackChannel!.updated!);
    }
  }

  String get universalLink {
    switch (type) {
      case MessageChannelEntityType.slack:
        return 'slack://channel?team=${teamId}&id=${id}';
    }
  }

  bool get isArchived {
    switch (type) {
      case MessageChannelEntityType.slack:
        return _slackChannel?.isArchived ?? false;
    }
  }

  bool get isDmWithDeletedUser {
    if (isDm) {
      switch (type) {
        case MessageChannelEntityType.slack:
          return _slackChannel?.isUserDeleted ?? false;
      }
    } else {
      return false;
    }
  }

  int get unreadCount {
    switch (type) {
      case MessageChannelEntityType.slack:
        return _slackChannel?.unreadCountDisplay ?? 0;
    }
  }

  bool get hasUnreadMessage {
    return unreadCount > 0;
  }

  String get unreadCountString {
    if (unreadCount < 1)
      return '';
    else if (unreadCount < 10)
      return unreadCount.toString();
    else
      return '9+';
  }

  DateTime get lastUpdated {
    switch (type) {
      case MessageChannelEntityType.slack:
        return _slackChannel?.lastUpdated ?? updatedAt ?? DateTime(1970);
    }
  }

  MessageEntityType get messageType {
    switch (type) {
      case MessageChannelEntityType.slack:
        return MessageEntityType.slack;
    }
  }

  MessageReactionEntityType get reactionType {
    switch (type) {
      case MessageChannelEntityType.slack:
        return MessageReactionEntityType.slack;
    }
  }
}
