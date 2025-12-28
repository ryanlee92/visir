import 'package:Visir/features/chat/domain/entities/message_channel_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_emoji_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_group_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_member_entity.dart';
import 'package:Visir/features/inbox/domain/entities/inbox_entity.dart';

class InboxFetchListEntity {
  List<InboxEntity> inboxes;
  List<DateTime> separator;
  List<MessageChannelEntity>? channels;
  List<MessageMemberEntity>? members;
  List<MessageGroupEntity>? groups;
  List<MessageEmojiEntity>? emojis;
  int? sequence;

  InboxFetchListEntity({required this.inboxes, required this.separator, this.channels, this.members, this.groups, this.emojis, this.sequence});

  addChannels(List<MessageChannelEntity> channels) {
    this.channels = channels;
  }

  addMembers(List<MessageMemberEntity> members) {
    this.members = members;
  }

  addGroups(List<MessageGroupEntity> groups) {
    this.groups = groups;
  }

  addEmojis(List<MessageEmojiEntity> emojis) {
    this.emojis = emojis;
  }

  updateSequence() {
    this.sequence = (sequence ?? 0) + 1;
  }

  toJson(bool isLocal) {
    return {
      "inboxes": inboxes.map((e) => e.toJson(local: true)).toList(),
      "separator": separator.map((e) => e.toIso8601String()).toList(),
      "sequence": sequence,
    };
  }

  factory InboxFetchListEntity.fromJson(Map<String, dynamic> json, bool isLocal) {
    return InboxFetchListEntity(
      inboxes: List<InboxEntity?>.from(
        json['inboxes'].map((e) {
          try {
            return InboxEntity.fromJson(e, local: isLocal);
          } catch (e) {
            return null;
          }
        }),
      ).whereType<InboxEntity>().toList(),
      separator: List<DateTime?>.from(
        json['separator'].map((e) {
          try {
            return DateTime.parse(e);
          } catch (e) {
            return null;
          }
        }),
      ).whereType<DateTime>().toList(),
      sequence: json['sequence'],
    );
  }
}
