// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'slack_message_reaction_entity.freezed.dart';
part 'slack_message_reaction_entity.g.dart';

@freezed
abstract class SlackMessageReactionEntity with _$SlackMessageReactionEntity {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory SlackMessageReactionEntity({
    @JsonKey(includeIfNull: false) String? name,
    @JsonKey(includeIfNull: false) int? count,
    @JsonKey(includeIfNull: false) List<String>? users,
  }) = _SlackMessageReactionEntity;

  /// Serialization
  factory SlackMessageReactionEntity.fromJson(Map<String, dynamic> json) => _$SlackMessageReactionEntityFromJson(json);
}
