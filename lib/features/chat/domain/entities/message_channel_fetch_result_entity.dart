import 'package:Visir/features/chat/domain/entities/message_channel_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_emoji_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_group_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_member_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_team_entity.dart';

class MessageChannelFetchResultEntity {
  final List<MessageChannelEntity> channels;
  final MessageMemberEntity me;
  final MessageTeamEntity team;
  final List<MessageEmojiEntity> emojis;
  final List<MessageGroupEntity> groups;
  final List<MessageMemberEntity> members;

  MessageChannelFetchResultEntity({
    required this.channels,
    required this.me,
    required this.team,
    required this.emojis,
    required this.groups,
    required this.members,
  });

  Map<String, dynamic> toJson() => {
    'channels': channels.map((e) => e.toJson()).toList(),
    'me': me.toJson(),
    'team': team.toJson(),
    'emojis': emojis.map((e) => e.toJson()).toList(),
    'groups': groups.map((e) => e.toJson()).toList(),
    'members': members.map((e) => e.toJson()).toList(),
  };

  factory MessageChannelFetchResultEntity.fromJson(Map<String, dynamic> json) => MessageChannelFetchResultEntity(
    channels: json['channels'].map((e) => MessageChannelEntity.fromJson(e)).whereType<MessageChannelEntity>().toList(),
    me: MessageMemberEntity.fromJson(json['me']),
    team: MessageTeamEntity.fromJson(json['team']),
    emojis: json['emojis'].map((e) => MessageEmojiEntity.fromJson(e)).whereType<MessageEmojiEntity>().toList(),
    groups: json['groups'].map((e) => MessageGroupEntity.fromJson(e)).whereType<MessageGroupEntity>().toList(),
    members: json['members'].map((e) => MessageMemberEntity.fromJson(e)).whereType<MessageMemberEntity>().toList(),
  );

  MessageChannelFetchResultEntity copyWithChannelUpdated({required String channelId, required DateTime lastUpdatedAt}) {
    return MessageChannelFetchResultEntity(
      channels: channels.map((c) {
        if (c.id == channelId) {
          return c.copyWith(lastUpdated: lastUpdatedAt, unreadCount: lastUpdatedAt.isAfter(c.lastReadAt ?? DateTime(1970)) ? 1 : 0);
        }
        return c;
      }).toList(),
      me: me,
      team: team,
      emojis: emojis,
      groups: groups,
      members: members,
    );
  }

  MessageChannelFetchResultEntity copyWithChannelRead({required String channelId, required DateTime lastReadAt}) {
    return MessageChannelFetchResultEntity(
      channels: channels.map((c) {
        if (c.id == channelId) {
          return c.copyWith(lastReadAt: lastReadAt, unreadCount: c.lastUpdated.isAfter(lastReadAt) != false ? 1 : 0);
        }
        return c;
      }).toList(),
      me: me,
      team: team,
      emojis: emojis,
      groups: groups,
      members: members,
    );
  }

  MessageChannelFetchResultEntity copyWithReadCursor({required String channelId, required DateTime lastReadAt}) {
    return MessageChannelFetchResultEntity(
      channels: channels.map((c) {
        if (c.id == channelId) {
          return c.copyWith(lastUpdated: lastReadAt, lastReadAt: lastReadAt, unreadCount: 0);
        }
        return c;
      }).toList(),
      me: me,
      team: team,
      emojis: emojis,
      groups: groups,
      members: members,
    );
  }

  MessageChannelFetchResultEntity copyWithChannel({required MessageChannelEntity channel}) {
    return MessageChannelFetchResultEntity(
      channels: channels.map((c) {
        if (c.id == channel.id) {
          return channel.copyWith(lastUpdated: c.lastUpdated, lastReadAt: c.lastReadAt ?? channel.lastReadAt, unreadCount: c.unreadCount);
        }
        return c;
      }).toList(),
      me: me,
      team: team,
      emojis: emojis,
      groups: groups,
      members: members,
    );
  }

  MessageChannelFetchResultEntity copyWithIsChannels(bool isChannel) {
    return MessageChannelFetchResultEntity(
      channels: channels.where((c) {
        return c.isChannel == isChannel;
      }).toList(),
      me: me,
      team: team,
      emojis: emojis,
      groups: groups,
      members: members,
    );
  }

  MessageChannelFetchResultEntity copyWithIncrementUnread({required MessageChannelEntity channel, required MessageEntity lastMessage}) {
    return MessageChannelFetchResultEntity(
      channels: channels.map((c) {
        if (c.id == channel.id) {
          return c.copyWith(
            unreadCount: c.unreadCount + (lastMessage.isMyMessage(channel: channel) ? 0 : 1),
            lastUpdated: lastMessage.createdAt ?? c.lastUpdated,
          );
        }
        return c;
      }).toList(),
      me: me,
      team: team,
      emojis: emojis,
      groups: groups,
      members: members,
    );
  }

  MessageChannelFetchResultEntity copyWithMembers({required List<MessageMemberEntity> members}) {
    return MessageChannelFetchResultEntity(channels: channels, me: me, team: team, emojis: emojis, groups: groups, members: members);
  }

  MessageChannelFetchResultEntity copyWithGroups({required List<MessageGroupEntity> groups}) {
    return MessageChannelFetchResultEntity(channels: channels, me: me, team: team, emojis: emojis, groups: groups, members: members);
  }

  MessageChannelFetchResultEntity copyWithEmojis({required List<MessageEmojiEntity> emojis}) {
    return MessageChannelFetchResultEntity(channels: channels, me: me, team: team, emojis: emojis, groups: groups, members: members);
  }

  MessageChannelFetchResultEntity mergeWithData({List<MessageMemberEntity>? members, List<MessageGroupEntity>? groups, List<MessageEmojiEntity>? emojis}) {
    return MessageChannelFetchResultEntity(
      channels: channels,
      me: me,
      team: team,
      emojis: emojis == null ? this.emojis : [...(this.emojis.where((e) => !emojis.any((e) => e.id == e.id)).toList()), ...emojis],
      groups: groups == null ? this.groups : [...(this.groups.where((e) => !groups.any((e) => e.id == e.id)).toList()), ...groups],
      members: members == null ? this.members : [...(this.members.where((e) => !members.any((e) => e.id == e.id)).toList()), ...members],
    );
  }

  List<MessageChannelEntity> get availableChannelsAndDms {
    return channels.where((e) => e.isMember && !e.isDmWithDeletedUser && !e.isArchived).toList();
  }

  List<MessageChannelEntity> get availableChannels {
    return channels.where((e) => !e.isDm && !e.isGroupDm && e.isMember && !e.isDmWithDeletedUser && !e.isArchived).toList();
  }

  List<MessageChannelEntity> get availableDms {
    return channels.where((e) => (e.isDm || e.isGroupDm) && e.isMember && !e.isDmWithDeletedUser && !e.isArchived).toList();
  }
}
