import 'package:Visir/features/chat/domain/entities/message_channel_entity.dart';

class MessageSelectedEntity {
  MessageChannelEntity channel;
  String? threadId;
  String? targetMessageId;

  MessageSelectedEntity({
    required this.channel,
    required this.threadId,
    required this.targetMessageId,
  });

  operator ==(Object other) {
    return other is MessageSelectedEntity && other.channel == channel && other.threadId == threadId && other.targetMessageId == targetMessageId;
  }
}
