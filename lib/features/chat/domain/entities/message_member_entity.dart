import 'package:Visir/features/chat/domain/entities/slack/slack_message_member_entity.dart';

enum MessageMemberEntityType { slack }

class MessageMemberEntity {
  //for slack
  final SlackMessageMemberEntity? _slackMember;

  //common
  final MessageMemberEntityType type;

  MessageMemberEntity.fromSlack({required SlackMessageMemberEntity member}) : _slackMember = member, type = MessageMemberEntityType.slack;

  factory MessageMemberEntity.fromJson(Map<String, dynamic> json) {
    MessageMemberEntityType teamMemberType = MessageMemberEntityType.values.firstWhere(
      (e) => e.name == json['memberType'],
      orElse: () => MessageMemberEntityType.slack,
    );

    if (teamMemberType == MessageMemberEntityType.slack) {
      return MessageMemberEntity.fromSlack(member: SlackMessageMemberEntity.fromJson(json['_slackMember']));
    }

    return MessageMemberEntity.fromSlack(member: SlackMessageMemberEntity.fromJson(json['_slackMember']));
  }

  Map<String, dynamic> toJson() {
    return {"memberType": type.name, "_slackMember": _slackMember?.toJson()};
  }

  String get id {
    switch (type) {
      case MessageMemberEntityType.slack:
        return _slackMember!.id!;
    }
  }

  String? get displayName {
    switch (type) {
      case MessageMemberEntityType.slack:
        if ((_slackMember?.profile?.displayName ?? '').isNotEmpty) {
          return _slackMember?.profile?.displayName;
        } else if ((_slackMember?.profile?.realName ?? '').isNotEmpty) {
          return _slackMember?.profile?.realName;
        } else {
          return _slackMember?.name;
        }
    }
  }

  String? get username {
    switch (type) {
      case MessageMemberEntityType.slack:
        return _slackMember?.name;
    }
  }

  String? get profileImage {
    switch (type) {
      case MessageMemberEntityType.slack:
        return _slackMember?.profile?.image_72;
    }
  }

  String? get email {
    switch (type) {
      case MessageMemberEntityType.slack:
        return _slackMember?.profile?.email;
    }
  }

  bool get isDeleted {
    switch (type) {
      case MessageMemberEntityType.slack:
        return _slackMember?.deleted ?? false;
    }
  }

  bool get isBot {
    switch (type) {
      case MessageMemberEntityType.slack:
        return _slackMember?.isBot ?? _slackMember?.id?.startsWith('B') ?? false;
    }
  }

  bool get isActive {
    switch (type) {
      case MessageMemberEntityType.slack:
        return _slackMember?.deleted != true;
    }
  }
}

extension MessageMemberEntityListX on List<MessageMemberEntity> {
  List<MessageMemberEntity> get activeMembers {
    return this.where((e) => e.isActive).toList();
  }

  MessageMemberEntity? getMemberFromUserId({required String? userId}) {
    return this.where((e) => e.id == userId).firstOrNull;
  }

  MessageMemberEntity? getMemberFromName({required String? name}) {
    return this.where((e) => e.displayName == name).firstOrNull;
  }

  List<String> get notFetchMembers {
    return this.where((e) => e.isDeleted).map((e) => e.id).toList();
  }
}
