// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lemon_squeezy_discount_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LemonSqueezyDiscountEntity _$LemonSqueezyDiscountEntityFromJson(
  Map<String, dynamic> json,
) => _LemonSqueezyDiscountEntity(
  id: json['id'] as String,
  storeId: (json['store_id'] as num).toInt(),
  name: json['name'] as String,
  code: json['code'] as String,
  amount: (json['amount'] as num).toInt(),
  amountType: json['amount_type'] as String,
  isLimitedToProducts: json['is_limited_to_products'] as bool?,
  isLimitedRedemptions: json['is_limited_redemptions'] as bool?,
  maxRedemptions: (json['max_redemptions'] as num?)?.toInt(),
  startsAt: json['starts_at'] == null
      ? null
      : DateTime.parse(json['starts_at'] as String),
  expiresAt: json['expires_at'] == null
      ? null
      : DateTime.parse(json['expires_at'] as String),
  duration: json['duration'] as String?,
  durationInMonths: (json['duration_in_months'] as num?)?.toInt(),
  status: json['status'] as String?,
  status_formatted: json['status_formatted'] as String?,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
  testMode: json['test_mode'] as bool?,
  variants: (json['variants'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$LemonSqueezyDiscountEntityToJson(
  _LemonSqueezyDiscountEntity instance,
) => <String, dynamic>{
  'id': instance.id,
  'store_id': instance.storeId,
  'name': instance.name,
  'code': instance.code,
  'amount': instance.amount,
  'amount_type': instance.amountType,
  'is_limited_to_products': ?instance.isLimitedToProducts,
  'is_limited_redemptions': ?instance.isLimitedRedemptions,
  'max_redemptions': ?instance.maxRedemptions,
  'starts_at': ?instance.startsAt?.toIso8601String(),
  'expires_at': ?instance.expiresAt?.toIso8601String(),
  'duration': ?instance.duration,
  'duration_in_months': ?instance.durationInMonths,
  'status': ?instance.status,
  'status_formatted': ?instance.status_formatted,
  'created_at': ?instance.createdAt?.toIso8601String(),
  'updated_at': ?instance.updatedAt?.toIso8601String(),
  'test_mode': ?instance.testMode,
  'variants': ?instance.variants,
};
