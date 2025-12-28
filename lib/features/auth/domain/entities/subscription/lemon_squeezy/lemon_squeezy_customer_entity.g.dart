// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lemon_squeezy_customer_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LemonSqueezyCustomerEntity _$LemonSqueezyCustomerEntityFromJson(
  Map<String, dynamic> json,
) => _LemonSqueezyCustomerEntity(
  id: json['id'] as String,
  storeId: (json['store_id'] as num).toInt(),
  email: json['email'] as String,
  status: json['status'] as String,
  city: json['city'] as String?,
  region: json['region'] as String?,
  country: json['country'] as String?,
  total_revenue_currency: (json['total_revenue_currency'] as num?)?.toInt(),
  mrr: (json['mrr'] as num?)?.toInt(),
  status_formatted: json['status_formatted'] as String?,
  country_formatted: json['country_formatted'] as String?,
  total_revenue_currency_formatted:
      json['total_revenue_currency_formatted'] as String?,
  mrr_formatted: json['mrr_formatted'] as String?,
  vatNumber: json['vat_number'] as String?,
  vatNumberFormatted: json['vat_number_formatted'] as String?,
  urls: json['urls'] as Map<String, dynamic>?,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
  testMode: json['test_mode'] as bool?,
);

Map<String, dynamic> _$LemonSqueezyCustomerEntityToJson(
  _LemonSqueezyCustomerEntity instance,
) => <String, dynamic>{
  'id': instance.id,
  'store_id': instance.storeId,
  'email': instance.email,
  'status': instance.status,
  'city': ?instance.city,
  'region': ?instance.region,
  'country': ?instance.country,
  'total_revenue_currency': ?instance.total_revenue_currency,
  'mrr': ?instance.mrr,
  'status_formatted': ?instance.status_formatted,
  'country_formatted': ?instance.country_formatted,
  'total_revenue_currency_formatted':
      ?instance.total_revenue_currency_formatted,
  'mrr_formatted': ?instance.mrr_formatted,
  'vat_number': ?instance.vatNumber,
  'vat_number_formatted': ?instance.vatNumberFormatted,
  'urls': ?instance.urls,
  'created_at': ?instance.createdAt?.toIso8601String(),
  'updated_at': ?instance.updatedAt?.toIso8601String(),
  'test_mode': ?instance.testMode,
};
