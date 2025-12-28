// ignore_for_file: invalid_annotation_target

import 'package:Visir/features/chat/domain/entities/slack/slack_message_member_profile_entity.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'slack_message_member_entity.freezed.dart';
part 'slack_message_member_entity.g.dart';

@freezed
abstract class SlackMessageMemberEntity with _$SlackMessageMemberEntity {
  //https://api.slack.com/types/user#example
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory SlackMessageMemberEntity({
    @JsonKey(includeIfNull: false) bool? alwaysActive,
    @JsonKey(includeIfNull: false) String? color,
    @JsonKey(includeIfNull: false) bool? deleted,
    @JsonKey(includeIfNull: false) bool? has2fa,
    @JsonKey(includeIfNull: false) String? id,
    @JsonKey(includeIfNull: false) bool? isAdmin,
    @JsonKey(includeIfNull: false) bool? isAppUser,
    @JsonKey(includeIfNull: false) bool? isBot,
    @JsonKey(includeIfNull: false) bool? isInvitedUser,
    @JsonKey(includeIfNull: false) bool? isOwner,
    @JsonKey(includeIfNull: false) bool? isPrimaryOwner,
    @JsonKey(includeIfNull: false) bool? isRestricted,
    @JsonKey(includeIfNull: false) bool? isStranger,
    @JsonKey(includeIfNull: false) bool? isUltraRestricted,
    @JsonKey(includeIfNull: false) String? locale,
    @JsonKey(includeIfNull: false) String? name,
    @JsonKey(includeIfNull: false) SlackMessageMemberProfileEntity? profile,
    @JsonKey(includeIfNull: false) String? twoFactorType,
    @JsonKey(includeIfNull: false) String? tz,
    @JsonKey(includeIfNull: false) String? tzLabel,
    @JsonKey(includeIfNull: false) int? tzOffset,
    @JsonKey(includeIfNull: false) int? updated,
  }) = _SlackMessageTeamMemberEntity;

  /// Serialization
  factory SlackMessageMemberEntity.fromJson(Map<String, dynamic> json) => _$SlackMessageMemberEntityFromJson(json);
}
