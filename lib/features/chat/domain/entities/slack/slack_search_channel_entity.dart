// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'slack_search_channel_entity.freezed.dart';
part 'slack_search_channel_entity.g.dart';

@freezed
abstract class SlackSearchChannelEntity with _$SlackSearchChannelEntity {
  @JsonSerializable(fieldRename: FieldRename.snake)
  //https://api.slack.com/events/message
  const factory SlackSearchChannelEntity({
    @JsonKey(includeIfNull: false) String? id,
    @JsonKey(includeIfNull: false) bool? isExtShared,
    @JsonKey(includeIfNull: false) bool? isMpim,
    @JsonKey(includeIfNull: false) bool? isOrgShared,
    @JsonKey(includeIfNull: false) bool? isPendingExtShared,
    @JsonKey(includeIfNull: false) bool? isPrivate,
    @JsonKey(includeIfNull: false) bool? isShared,
    @JsonKey(includeIfNull: false) String? name,
  }) = _SlackSearchChannelEntity;

  /// Serialization
  factory SlackSearchChannelEntity.fromJson(Map<String, dynamic> json) => _$SlackSearchChannelEntityFromJson(json);
}
