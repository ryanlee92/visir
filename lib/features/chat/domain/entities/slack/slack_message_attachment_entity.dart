// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'slack_message_attachment_entity.freezed.dart';
part 'slack_message_attachment_entity.g.dart';

@freezed
abstract class SlackMessageAttachmentEntity with _$SlackMessageAttachmentEntity {
  // https://api.slack.com/reference/surfaces/formatting#attachments
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory SlackMessageAttachmentEntity({
    @JsonKey(includeIfNull: false) String? serviceName,
    @JsonKey(includeIfNull: false) String? serviceIcon,
    @JsonKey(includeIfNull: false) String? text,
    @JsonKey(includeIfNull: false) String? fallback,
    @JsonKey(includeIfNull: false) String? color,
    @JsonKey(includeIfNull: false) String? pretext,
    @JsonKey(includeIfNull: false) String? authorName,
    @JsonKey(includeIfNull: false) String? authorLink,
    @JsonKey(includeIfNull: false) String? authorIcon,
    @JsonKey(includeIfNull: false) String? authorSubname,
    @JsonKey(includeIfNull: false) String? title,
    @JsonKey(includeIfNull: false) String? titleLink,
    @JsonKey(includeIfNull: false) String? fromUrl,
    @JsonKey(includeIfNull: false) String? imageUrl,
    @JsonKey(includeIfNull: false) String? thumbUrl,
    @JsonKey(includeIfNull: false) String? originalUrl,
    @JsonKey(includeIfNull: false) String? footer,
    @JsonKey(includeIfNull: false) String? footerIcon,
    @JsonKey(includeIfNull: false) dynamic ts,
    @JsonKey(includeIfNull: false) List<dynamic>? fields,
    @JsonKey(includeIfNull: false) List<dynamic>? blocks,
    @JsonKey(includeIfNull: false) List<dynamic>? actions,
    @JsonKey(includeIfNull: false) int? thumbWidth,
    @JsonKey(includeIfNull: false) int? thumbHeight,
    @JsonKey(includeIfNull: false) int? id,
    @JsonKey(includeIfNull: false) bool? isMsgUnfurl,
    @JsonKey(includeIfNull: false) bool? isShare,
  }) = _SlackMessageAttachmentEntity;

  /// Serialization
  factory SlackMessageAttachmentEntity.fromJson(Map<String, dynamic> json) => _$SlackMessageAttachmentEntityFromJson(json);
}
