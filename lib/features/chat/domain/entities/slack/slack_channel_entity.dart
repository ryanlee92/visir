// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'slack_channel_entity.freezed.dart';
part 'slack_channel_entity.g.dart';

@freezed
abstract class SlackMessageChannelEntity with _$SlackMessageChannelEntity {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory SlackMessageChannelEntity({
    @JsonKey(includeIfNull: false) String? teamId,
    //https://api.slack.com/types/channel
    @JsonKey(includeIfNull: false) String? id,
    @JsonKey(includeIfNull: false) String? name,
    @JsonKey(includeIfNull: false) bool? isChannel,
    @JsonKey(includeIfNull: false) int? created,
    @JsonKey(includeIfNull: false) String? creator,
    @JsonKey(includeIfNull: false) bool? isArchived,
    @JsonKey(includeIfNull: false) bool? isGeneral,
    @JsonKey(includeIfNull: false) String? nameNormalized,
    @JsonKey(includeIfNull: false) bool? isShared,
    @JsonKey(includeIfNull: false) bool? isOrgShared,
    @JsonKey(includeIfNull: false) bool? isMember,
    @JsonKey(includeIfNull: false) bool? isPrivate,
    @JsonKey(includeIfNull: false) bool? isMpim,
    @JsonKey(includeIfNull: false) String? lastRead,
    @JsonKey(includeIfNull: false) DateTime? lastUpdated,
    @JsonKey(includeIfNull: false) int? unreadCount,
    @JsonKey(includeIfNull: false) int? unreadCountDisplay,
    @JsonKey(includeIfNull: false) List<String>? members,
    @JsonKey(includeIfNull: false) Map<String, dynamic>? topic,
    @JsonKey(includeIfNull: false) Map<String, dynamic>? purpose,
    @JsonKey(includeIfNull: false) List<String>? previousNames,
    //https://api.slack.com/types/group
    @JsonKey(includeIfNull: false) bool? isGroup,
    //https://api.slack.com/types/im
    @JsonKey(includeIfNull: false) bool? isIm,
    @JsonKey(includeIfNull: false) String? user,
    @JsonKey(includeIfNull: false) bool? isUserDeleted,
    //https://api.slack.com/types/mpim
    //위 네가지에는 없지만 repsonse에는 있는 parameter들
    @JsonKey(includeIfNull: false) int? updated,
    @JsonKey(includeIfNull: false) int? unlinked,
    @JsonKey(includeIfNull: false) bool? isPendingExtShared,
    @JsonKey(includeIfNull: false) String? contextTeamId,
    @JsonKey(includeIfNull: false) double? priority,
    @JsonKey(includeIfNull: false) bool? isOpen,
  }) = _SlackMessageChannelEntity;

  /// Serialization
  factory SlackMessageChannelEntity.fromJson(Map<String, dynamic> json) => _$SlackMessageChannelEntityFromJson(json);
}
