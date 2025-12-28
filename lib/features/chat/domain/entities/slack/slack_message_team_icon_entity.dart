// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'slack_message_team_icon_entity.freezed.dart';
part 'slack_message_team_icon_entity.g.dart';

@freezed
abstract class SlackMessageTeamIconEntity with _$SlackMessageTeamIconEntity {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory SlackMessageTeamIconEntity({
    @JsonKey(includeIfNull: false) bool? imageDefault,
    @JsonKey(includeIfNull: false) String? image_34,
    @JsonKey(includeIfNull: false) String? image_44,
    @JsonKey(includeIfNull: false) String? image_68,
    @JsonKey(includeIfNull: false) String? image_88,
    @JsonKey(includeIfNull: false) String? image_102,
    @JsonKey(includeIfNull: false) String? image_132,
    @JsonKey(includeIfNull: false) String? image_230,
  }) = _SlackMessageTeamIconEntity;

  /// Serialization
  factory SlackMessageTeamIconEntity.fromJson(Map<String, dynamic> json) => _$SlackMessageTeamIconEntityFromJson(json);
}
