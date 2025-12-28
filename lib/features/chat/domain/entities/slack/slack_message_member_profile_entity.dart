// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'slack_message_member_profile_entity.freezed.dart';
part 'slack_message_member_profile_entity.g.dart';

@freezed
abstract class SlackMessageMemberProfileEntity with _$SlackMessageMemberProfileEntity {
  //https://api.slack.com/types/user#example
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory SlackMessageMemberProfileEntity({
    @JsonKey(includeIfNull: false) String? avatarHash,
    @JsonKey(includeIfNull: false) String? displayName,
    @JsonKey(includeIfNull: false) String? displayNameNormalized,
    @JsonKey(includeIfNull: false) String? email,
    @JsonKey(includeIfNull: false) Map<String, dynamic>? fields,
    @JsonKey(includeIfNull: false) String? firstName,
    @JsonKey(includeIfNull: false) String? image_24,
    @JsonKey(includeIfNull: false) String? image_32,
    @JsonKey(includeIfNull: false) String? image_48,
    @JsonKey(includeIfNull: false) String? image_72,
    @JsonKey(includeIfNull: false) String? image_192,
    @JsonKey(includeIfNull: false) String? image_512,
    @JsonKey(includeIfNull: false) String? lastName,
    @JsonKey(includeIfNull: false) String? phone,
    @JsonKey(includeIfNull: false) String? pronouns,
    @JsonKey(includeIfNull: false) String? realName,
    @JsonKey(includeIfNull: false) String? realNameNormalized,
    @JsonKey(includeIfNull: false) String? skype,
    @JsonKey(includeIfNull: false) String? startDate,
    @JsonKey(includeIfNull: false) String? statusEmoji,
    @JsonKey(includeIfNull: false) int? statusExpiration,
    @JsonKey(includeIfNull: false) String? statsText,
    @JsonKey(includeIfNull: false) String? team,
    @JsonKey(includeIfNull: false) String? title,
  }) = _SlackMessageMemberProfileEntity;

  /// Serialization
  factory SlackMessageMemberProfileEntity.fromJson(Map<String, dynamic> json) => _$SlackMessageMemberProfileEntityFromJson(json);
}
