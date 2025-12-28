// ignore_for_file: invalid_annotation_target

import 'package:Visir/features/chat/domain/entities/slack/slack_message_team_icon_entity.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'slack_message_team_entity.freezed.dart';
part 'slack_message_team_entity.g.dart';

@freezed
abstract class SlackMessageTeamEntity with _$SlackMessageTeamEntity {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory SlackMessageTeamEntity({
    required String id,
    required String name,
    required String domain,
    required String email_domain,
    @JsonKey(includeIfNull: false) String? avatar_base_url,
    @JsonKey(includeIfNull: false) bool? isVerified,
    @JsonKey(includeIfNull: false) String? publicUrl,
    @JsonKey(includeIfNull: false) String? enterprise_id,
    @JsonKey(includeIfNull: false) String? enterprise_name,
    @JsonKey(includeIfNull: false) SlackMessageTeamIconEntity? icon,
  }) = _SlackTeamEntity;

  /// Serialization
  factory SlackMessageTeamEntity.fromJson(Map<String, dynamic> json) => _$SlackMessageTeamEntityFromJson(json);
}
