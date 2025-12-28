// ignore_for_file: invalid_annotation_target

import 'package:Visir/features/chat/domain/entities/slack/chat_block/slack_message_block_entity.dart';
import 'package:Visir/features/chat/domain/entities/slack/slack_message_attachment_entity.dart';
import 'package:Visir/features/chat/domain/entities/slack/slack_message_entity.dart';
import 'package:Visir/features/chat/domain/entities/slack/slack_message_file_entity.dart';
import 'package:Visir/features/chat/domain/entities/slack/slack_message_reaction_entity.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'slack_message_event_entity.freezed.dart';
part 'slack_message_event_entity.g.dart';

enum SlackMessageEventEntityType {
  @JsonValue('message')
  message,
  @JsonValue('reaction_added')
  reactionAdded,
  @JsonValue('reaction_removed')
  reactionRemoved,
}

@freezed
abstract class SlackMessageEventEntity with _$SlackMessageEventEntity {
  @JsonSerializable(fieldRename: FieldRename.snake)
  // https://api.slack.com/events
  const factory SlackMessageEventEntity({
    @JsonKey(includeIfNull: false) String? token,
    @JsonKey(includeIfNull: false) SlackMessageEventEntityType? type,
    @JsonKey(includeIfNull: false) SlackMessageEntitySubtype? subtype,
    @JsonKey(includeIfNull: false) String? channel,
    @JsonKey(includeIfNull: false) String? user,
    @JsonKey(includeIfNull: false) String? team,
    @JsonKey(includeIfNull: false) String? text,
    @JsonKey(includeIfNull: false) String? ts,
    @JsonKey(includeIfNull: false) String? threadTs,
    @JsonKey(includeIfNull: false) String? eventTs,
    @JsonKey(includeIfNull: false) String? clientMsgId,
    @JsonKey(includeIfNull: false) String? parentUserId,
    @JsonKey(includeIfNull: false) String? channelType,
    @JsonKey(includeIfNull: false) String? reaction,
    @JsonKey(includeIfNull: false) String? itemUser,
    @JsonKey(includeIfNull: false) bool? hidden,
    @JsonKey(includeIfNull: false) List<SlackMessageAttachmentEntity>? attachments,
    @JsonKey(includeIfNull: false) List<SlackMessageFileEntity>? files,
    @JsonKey(includeIfNull: false) Map<String, dynamic>? message,
    @JsonKey(includeIfNull: false) Map<String, dynamic>? previousMessage,
    @JsonKey(includeIfNull: false) Map<String, dynamic>? item,
    @JsonKey(includeIfNull: false) String? deletedTs,
    @JsonKey(includeIfNull: false) String? latestReply,
    @JsonKey(includeIfNull: false) int? replyCount,
    @JsonKey(includeIfNull: false) int? replyUsersCount,
    @JsonKey(includeIfNull: false) List<String>? replyUsers,
    @JsonKey(includeIfNull: false) bool? isStarred,
    @JsonKey(includeIfNull: false) bool? isLocked,
    @JsonKey(includeIfNull: false) bool? subscribed,
    @JsonKey(includeIfNull: false) List<String>? pinnedTo,
    @JsonKey(includeIfNull: false) Map<String, dynamic>? edited,
    @JsonKey(includeIfNull: false) List<SlackMessageReactionEntity>? reactions,
    @JsonKey(includeIfNull: false) List<SlackMessageBlockEntity>? blocks,
    @JsonKey(includeIfNull: false) String? botId,
  }) = _SlackMessageEventEntity;

  /// Serialization
  factory SlackMessageEventEntity.fromJson(Map<String, dynamic> json) => _$SlackMessageEventEntityFromJson(json);
}
