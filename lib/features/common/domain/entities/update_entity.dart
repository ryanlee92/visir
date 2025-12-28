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

import 'package:Visir/features/common/presentation/utils/extensions/platform_extension.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'update_entity.freezed.dart';
part 'update_entity.g.dart';

@freezed
abstract class UpdateEntity with _$UpdateEntity {
  @JsonSerializable(fieldRename: FieldRename.snake)

  /// Factory Constructor
  const factory UpdateEntity({
    @JsonKey(includeIfNull: false) String? iosLink,
    @JsonKey(includeIfNull: false) String? macosLink,
    @JsonKey(includeIfNull: false) String? androidLink,
    @JsonKey(includeIfNull: false) String? windowsLink,
    @JsonKey(includeIfNull: false) int? iosMinimumBuild,
    @JsonKey(includeIfNull: false) int? macosMinimumBuild,
    @JsonKey(includeIfNull: false) int? androidMinimumBuild,
    @JsonKey(includeIfNull: false) int? windowsMinimumBuild,
  }) = _UpdateEntity;

  factory UpdateEntity.fromJson(Map<String, dynamic> json) => _$UpdateEntityFromJson(json);
}

extension UpdateEntityX on UpdateEntity {
  String? get link {
    if (PlatformX.isIOS) return iosLink;
    if (PlatformX.isAndroid) return androidLink;
    if (PlatformX.isMacOS) return macosLink;
    if (PlatformX.isWindows) return windowsLink;
    return '';
  }

  int? get minimumBuild {
    if (PlatformX.isIOS) return iosMinimumBuild;
    if (PlatformX.isAndroid) return androidMinimumBuild;
    if (PlatformX.isMacOS) return macosMinimumBuild;
    if (PlatformX.isWindows) return windowsMinimumBuild;
    return 0;
  }
}
