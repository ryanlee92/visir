// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'slack_message_group_entity.freezed.dart';
part 'slack_message_group_entity.g.dart';

@freezed
abstract class SlackMessageGroupEntity with _$SlackMessageGroupEntity {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory SlackMessageGroupEntity({
    @JsonKey(includeIfNull: false) String? id,
    @JsonKey(includeIfNull: false) String? teamId,
    @JsonKey(includeIfNull: false) bool? isUsergroup,
    @JsonKey(includeIfNull: false) String? name,
    @JsonKey(includeIfNull: false) String? description,
    @JsonKey(includeIfNull: false) String? handle,
    @JsonKey(includeIfNull: false) bool? isExternal,
    @JsonKey(includeIfNull: false) int? dateCreate,
    @JsonKey(includeIfNull: false) int? dateUpdate,
    @JsonKey(includeIfNull: false) int? dateDelete,
    @JsonKey(includeIfNull: false) String? autoType,
    @JsonKey(includeIfNull: false) String? createdBy,
    @JsonKey(includeIfNull: false) String? updatedBy,
    @JsonKey(includeIfNull: false) String? deletedBy,
    @JsonKey(includeIfNull: false) Map<String, dynamic>? prefs,
    @JsonKey(includeIfNull: false) List<String>? users,
    @JsonKey(includeIfNull: false) int? userCount,
  }) = _SlackMessageGroupEntity;

  factory SlackMessageGroupEntity.fromJson(Map<String, dynamic> json) => _$SlackMessageGroupEntityFromJson(json);
}
