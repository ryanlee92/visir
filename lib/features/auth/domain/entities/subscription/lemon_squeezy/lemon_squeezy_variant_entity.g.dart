// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lemon_squeezy_variant_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LemonSqueezyVariantEntity _$LemonSqueezyVariantEntityFromJson(
  Map<String, dynamic> json,
) => _LemonSqueezyVariantEntity(
  id: json['id'] as String,
  productId: (json['product_id'] as num).toInt(),
  name: json['name'] as String,
  price: (json['price'] as num).toInt(),
  description: json['description'] as String?,
  slug: json['slug'] as String?,
  hasLicenseKeys: json['has_license_keys'] as bool?,
  licenseActivationLimit: (json['license_activation_limit'] as num?)?.toInt(),
  isLicenseLimitUnlimited: json['is_license_limit_unlimited'] as bool?,
  licenseLengthValue: (json['license_length_value'] as num?)?.toInt(),
  licenseLengthUnit: json['license_length_unit'] as String?,
  isLicenseLengthUnlimited: json['is_license_length_unlimited'] as bool?,
  links: (json['links'] as List<dynamic>?)?.map((e) => e as String).toList(),
  sort: (json['sort'] as num?)?.toInt(),
  status: json['status'] as String?,
  statusFormatted: json['status_formatted'] as String?,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
  testMode: json['test_mode'] as bool?,
);

Map<String, dynamic> _$LemonSqueezyVariantEntityToJson(
  _LemonSqueezyVariantEntity instance,
) => <String, dynamic>{
  'id': instance.id,
  'product_id': instance.productId,
  'name': instance.name,
  'price': instance.price,
  'description': ?instance.description,
  'slug': ?instance.slug,
  'has_license_keys': ?instance.hasLicenseKeys,
  'license_activation_limit': ?instance.licenseActivationLimit,
  'is_license_limit_unlimited': ?instance.isLicenseLimitUnlimited,
  'license_length_value': ?instance.licenseLengthValue,
  'license_length_unit': ?instance.licenseLengthUnit,
  'is_license_length_unlimited': ?instance.isLicenseLengthUnlimited,
  'links': ?instance.links,
  'sort': ?instance.sort,
  'status': ?instance.status,
  'status_formatted': ?instance.statusFormatted,
  'created_at': ?instance.createdAt?.toIso8601String(),
  'updated_at': ?instance.updatedAt?.toIso8601String(),
  'test_mode': ?instance.testMode,
};
