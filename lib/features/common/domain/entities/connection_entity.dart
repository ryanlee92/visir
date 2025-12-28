// {
// "ios_link": "",
// "macos_link": "",
// "android_link": "",
// "windows_link": "",
// "ios_minimum_build": 440,
// "macos_minimum_build": 440,
// "android_minimum_build": 440,
// "windows_minimum_build": 440
// }

// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'connection_entity.freezed.dart';
part 'connection_entity.g.dart';

@freezed
abstract class ConnectionEntity with _$ConnectionEntity {
  @JsonSerializable(fieldRename: FieldRename.snake)

  /// Factory Constructor
  const factory ConnectionEntity({
    @JsonKey(includeIfNull: false) String? email,
    @JsonKey(includeIfNull: false) String? name,
  }) = _ConnectionEntity;

  factory ConnectionEntity.fromJson(Map<String, dynamic> json) => _$ConnectionEntityFromJson(json);
}
