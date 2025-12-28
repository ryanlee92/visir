// ignore_for_file: invalid_annotation_target

import 'package:Visir/features/chat/domain/entities/slack/slack_search_channel_entity.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'slack_search_message_entity.freezed.dart';
part 'slack_search_message_entity.g.dart';

@freezed
abstract class SlackSearchMessageEntity with _$SlackSearchMessageEntity {
  @JsonSerializable(fieldRename: FieldRename.snake)
  //https://api.slack.com/events/message
  const factory SlackSearchMessageEntity({
    @JsonKey(includeIfNull: false) SlackSearchChannelEntity? channel,
    @JsonKey(includeIfNull: false) String? iid,
    @JsonKey(includeIfNull: false) String? permalink,
    @JsonKey(includeIfNull: false) String? team,
    @JsonKey(includeIfNull: false) String? text,
    @JsonKey(includeIfNull: false) String? ts,
    @JsonKey(includeIfNull: false) String? type,
    @JsonKey(includeIfNull: false) String? user,
    @JsonKey(includeIfNull: false) String? username,
  }) = _SlackSearchMessageEntity;

  /// Serialization
  factory SlackSearchMessageEntity.fromJson(Map<String, dynamic> json) => _$SlackSearchMessageEntityFromJson(json);
}
