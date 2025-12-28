// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'lemon_squeezy_variant_entity.freezed.dart';
part 'lemon_squeezy_variant_entity.g.dart';

@freezed
abstract class LemonSqueezyVariantEntity with _$LemonSqueezyVariantEntity {
  const LemonSqueezyVariantEntity._();

  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory LemonSqueezyVariantEntity({
    required String id,
    required int productId,
    required String name,
    required int price,
    @JsonKey(includeIfNull: false) String? description,
    @JsonKey(includeIfNull: false) String? slug,
    @JsonKey(includeIfNull: false) bool? hasLicenseKeys,
    @JsonKey(includeIfNull: false) int? licenseActivationLimit,
    @JsonKey(includeIfNull: false) bool? isLicenseLimitUnlimited,
    @JsonKey(includeIfNull: false) int? licenseLengthValue,
    @JsonKey(includeIfNull: false) String? licenseLengthUnit,
    @JsonKey(includeIfNull: false) bool? isLicenseLengthUnlimited,
    @JsonKey(includeIfNull: false) List<String>? links,
    @JsonKey(includeIfNull: false) int? sort,
    @JsonKey(includeIfNull: false) String? status,
    @JsonKey(includeIfNull: false) String? statusFormatted,
    @JsonKey(includeIfNull: false) DateTime? createdAt,
    @JsonKey(includeIfNull: false) DateTime? updatedAt,
    @JsonKey(includeIfNull: false) bool? testMode,
  }) = _LemonSqueezyVariantEntity;

  factory LemonSqueezyVariantEntity.fromJson(Map<String, dynamic> json) => _$LemonSqueezyVariantEntityFromJson(json);

  bool get isPublished => status == 'published';

  double get priceInDollar => price / 100;
}
