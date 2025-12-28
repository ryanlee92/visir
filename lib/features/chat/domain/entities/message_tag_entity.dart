import 'package:Visir/features/chat/domain/entities/message_channel_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_group_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_member_entity.dart';
import 'package:Visir/features/common/presentation/widgets/visir_icon.dart';
import 'package:Visir/features/task/domain/entities/task_entity.dart';
import 'package:Visir/features/calendar/domain/entities/event_entity.dart';
import 'package:Visir/features/common/domain/entities/connection_entity.dart';
import 'package:Visir/features/task/domain/entities/project_entity.dart';
import 'package:flutter/material.dart';

enum MessageTagEntityType { member, memberGroup, channel, broadcastChannel, broadcastHere, task, event, connection, project }

class MessageTagEntity {
  final MessageTagEntityType type;
  final MessageMemberEntity? member;
  final MessageGroupEntity? memberGroup;
  final MessageChannelEntity? channel;
  final TaskEntity? task;
  final EventEntity? event;
  final ConnectionEntity? connection;
  final ProjectEntity? project;

  MessageTagEntity({
    required this.type,
    this.member,
    this.memberGroup,
    this.channel,
    this.task,
    this.event,
    this.connection,
    this.project,
  });

  String? get formattedName {
    switch (type) {
      case MessageTagEntityType.member:
        return member?.displayName;
      case MessageTagEntityType.memberGroup:
        return '${memberGroup?.displayName} (${memberGroup?.users?.length.toString()} member${((memberGroup?.users?.length ?? 0) > 1) ? 's' : ''})';
      case MessageTagEntityType.channel:
        return channel?.name;
      case MessageTagEntityType.broadcastChannel:
        return '@channel';
      case MessageTagEntityType.broadcastHere:
        return '@here';
      case MessageTagEntityType.task:
        return task?.title;
      case MessageTagEntityType.event:
        return event?.title;
      case MessageTagEntityType.connection:
        return connection?.name ?? connection?.email;
      case MessageTagEntityType.project:
        return project?.name;
    }
  }

  String? get displayName {
    switch (type) {
      case MessageTagEntityType.member:
        return member?.displayName;
      case MessageTagEntityType.memberGroup:
        return memberGroup?.displayName;
      case MessageTagEntityType.channel:
        return channel?.name;
      case MessageTagEntityType.broadcastChannel:
        return 'channel';
      case MessageTagEntityType.broadcastHere:
        return 'here';
      case MessageTagEntityType.task:
        return task?.title;
      case MessageTagEntityType.event:
        return event?.title;
      case MessageTagEntityType.connection:
        return connection?.name ?? connection?.email;
      case MessageTagEntityType.project:
        return project?.name;
    }
  }

  String? get profileImageSmall {
    switch (type) {
      case MessageTagEntityType.member:
        return member?.profileImage;
      case MessageTagEntityType.memberGroup:
      case MessageTagEntityType.channel:
      case MessageTagEntityType.broadcastChannel:
      case MessageTagEntityType.broadcastHere:
      case MessageTagEntityType.task:
      case MessageTagEntityType.event:
      case MessageTagEntityType.connection:
      case MessageTagEntityType.project:
        return null;
    }
  }

  String? get id {
    switch (type) {
      case MessageTagEntityType.member:
        return member?.id;
      case MessageTagEntityType.memberGroup:
        return memberGroup?.id;
      case MessageTagEntityType.channel:
        return channel?.id;
      case MessageTagEntityType.broadcastChannel:
        return 'channel';
      case MessageTagEntityType.broadcastHere:
        return 'here';
      case MessageTagEntityType.task:
        return task?.id;
      case MessageTagEntityType.event:
        return event?.uniqueId;
      case MessageTagEntityType.connection:
        return connection?.email;
      case MessageTagEntityType.project:
        return project?.uniqueId;
    }
  }

  VisirIconType? get iconData {
    switch (type) {
      case MessageTagEntityType.member:
        return null;
      case MessageTagEntityType.memberGroup:
        return VisirIconType.chatGroupDm;
      case MessageTagEntityType.channel:
        return VisirIconType.chatChannel;
      case MessageTagEntityType.broadcastChannel:
      case MessageTagEntityType.broadcastHere:
        return VisirIconType.chatDm;
      case MessageTagEntityType.task:
        return VisirIconType.task;
      case MessageTagEntityType.event:
        return VisirIconType.calendar;
      case MessageTagEntityType.connection:
        return VisirIconType.profile;
      case MessageTagEntityType.project:
        return VisirIconType.project;
    }
  }

  GlobalObjectKey get globalObjectKey {
    return GlobalObjectKey(displayName ?? '');
  }
}
