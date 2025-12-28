// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UpdateEntity _$UpdateEntityFromJson(Map<String, dynamic> json) =>
    _UpdateEntity(
      iosLink: json['ios_link'] as String?,
      macosLink: json['macos_link'] as String?,
      androidLink: json['android_link'] as String?,
      windowsLink: json['windows_link'] as String?,
      iosMinimumBuild: (json['ios_minimum_build'] as num?)?.toInt(),
      macosMinimumBuild: (json['macos_minimum_build'] as num?)?.toInt(),
      androidMinimumBuild: (json['android_minimum_build'] as num?)?.toInt(),
      windowsMinimumBuild: (json['windows_minimum_build'] as num?)?.toInt(),
    );

Map<String, dynamic> _$UpdateEntityToJson(_UpdateEntity instance) =>
    <String, dynamic>{
      'ios_link': ?instance.iosLink,
      'macos_link': ?instance.macosLink,
      'android_link': ?instance.androidLink,
      'windows_link': ?instance.windowsLink,
      'ios_minimum_build': ?instance.iosMinimumBuild,
      'macos_minimum_build': ?instance.macosMinimumBuild,
      'android_minimum_build': ?instance.androidMinimumBuild,
      'windows_minimum_build': ?instance.windowsMinimumBuild,
    };
