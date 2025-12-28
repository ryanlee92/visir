// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'slack_message_file_entity.freezed.dart';
part 'slack_message_file_entity.g.dart';

@freezed
abstract class SlackMessageFileEntity with _$SlackMessageFileEntity {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory SlackMessageFileEntity({
    @JsonKey(includeIfNull: false) String? id,
    @JsonKey(includeIfNull: false) int? created,
    @JsonKey(includeIfNull: false) int? timestamp,
    @JsonKey(includeIfNull: false) String? name,
    @JsonKey(includeIfNull: false) String? title,
    @JsonKey(includeIfNull: false) String? mimetype,
    @JsonKey(includeIfNull: false) String? filetype,
    @JsonKey(includeIfNull: false) String? prettyType,
    @JsonKey(includeIfNull: false) String? user,
    @JsonKey(includeIfNull: false) String? userTeam,
    @JsonKey(includeIfNull: false) bool? editable,
    @JsonKey(includeIfNull: false) int? size,
    @JsonKey(includeIfNull: false) String? mode,
    @JsonKey(includeIfNull: false) bool? isExternal,
    @JsonKey(includeIfNull: false) bool? isPublic,
    @JsonKey(includeIfNull: false) bool? publicUrlShared,
    @JsonKey(includeIfNull: false) bool? displayAsBot,
    @JsonKey(includeIfNull: false) String? username,
    @JsonKey(includeIfNull: false) String? urlPrivate,
    @JsonKey(includeIfNull: false) String? urlPrivateDownload,
    @JsonKey(includeIfNull: false) String? mediaDisplayType,
    @JsonKey(includeIfNull: false) String? thumb_64,
    @JsonKey(includeIfNull: false) String? thumb_80,
    @JsonKey(includeIfNull: false) String? thumb_160,
    @JsonKey(includeIfNull: false) String? thumb_360,
    @JsonKey(includeIfNull: false) int? thumb_360_w,
    @JsonKey(includeIfNull: false) int? thumb_360_h,
    @JsonKey(includeIfNull: false) String? thumb_480,
    @JsonKey(includeIfNull: false) int? thumb_480_w,
    @JsonKey(includeIfNull: false) int? thumb_480_h,
    @JsonKey(includeIfNull: false) String? thumb_720,
    @JsonKey(includeIfNull: false) int? thumb_720_w,
    @JsonKey(includeIfNull: false) int? thumb_720_h,
    @JsonKey(includeIfNull: false) String? thumb_800,
    @JsonKey(includeIfNull: false) int? thumb_800_w,
    @JsonKey(includeIfNull: false) int? thumb_800_h,
    @JsonKey(includeIfNull: false) String? thumb_960,
    @JsonKey(includeIfNull: false) int? thumb_960_w,
    @JsonKey(includeIfNull: false) int? thumb_960_h,
    @JsonKey(includeIfNull: false) String? thumb_1024,
    @JsonKey(includeIfNull: false) int? thumb_1024_w,
    @JsonKey(includeIfNull: false) int? thumb_1024_h,
    @JsonKey(includeIfNull: false) String? thumb_video,
    @JsonKey(includeIfNull: false) int? thumb_video_w,
    @JsonKey(includeIfNull: false) int? thumb_video_h,
    @JsonKey(includeIfNull: false) int? original_w,
    @JsonKey(includeIfNull: false) int? original_h,
    @JsonKey(includeIfNull: false) String? thumbTiny,
    @JsonKey(includeIfNull: false) String? permalink,
    @JsonKey(includeIfNull: false) String? permalinkPublic,
    @JsonKey(includeIfNull: false) bool? isStarred,
    @JsonKey(includeIfNull: false) bool? hasRichPreview,
    @JsonKey(includeIfNull: false) String? fileAccess,
  }) = _SlackMessageFileEntity;

  /// Serialization
  factory SlackMessageFileEntity.fromJson(Map<String, dynamic> json) => _$SlackMessageFileEntityFromJson(json);
}
