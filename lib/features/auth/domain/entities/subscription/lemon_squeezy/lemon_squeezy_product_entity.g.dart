// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lemon_squeezy_product_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LemonSqueezyProductEntity _$LemonSqueezyProductEntityFromJson(
  Map<String, dynamic> json,
) => _LemonSqueezyProductEntity(
  id: json['id'] as String,
  storeId: (json['store_id'] as num).toInt(),
  name: json['name'] as String,
  status: json['status'] as String,
  price: (json['price'] as num).toInt(),
  slug: json['slug'] as String?,
  description: json['description'] as String?,
  statusFormatted: json['status_formatted'] as String?,
  thumbUrl: json['thumb_url'] as String?,
  largeThumbUrl: json['large_thumb_url'] as String?,
  priceFormatted: json['price_formatted'] as String?,
  fromPrice: (json['from_price'] as num?)?.toInt(),
  fromPriceFormatted: json['from_price_formatted'] as String?,
  toPrice: (json['to_price'] as num?)?.toInt(),
  toPriceFormatted: json['to_price_formatted'] as String?,
  payWhatYouWant: json['pay_what_you_want'] as bool?,
  buyNowUrl: json['buy_now_url'] as String?,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
  testMode: json['test_mode'] as bool?,
);

Map<String, dynamic> _$LemonSqueezyProductEntityToJson(
  _LemonSqueezyProductEntity instance,
) => <String, dynamic>{
  'id': instance.id,
  'store_id': instance.storeId,
  'name': instance.name,
  'status': instance.status,
  'price': instance.price,
  'slug': ?instance.slug,
  'description': ?instance.description,
  'status_formatted': ?instance.statusFormatted,
  'thumb_url': ?instance.thumbUrl,
  'large_thumb_url': ?instance.largeThumbUrl,
  'price_formatted': ?instance.priceFormatted,
  'from_price': ?instance.fromPrice,
  'from_price_formatted': ?instance.fromPriceFormatted,
  'to_price': ?instance.toPrice,
  'to_price_formatted': ?instance.toPriceFormatted,
  'pay_what_you_want': ?instance.payWhatYouWant,
  'buy_now_url': ?instance.buyNowUrl,
  'created_at': ?instance.createdAt?.toIso8601String(),
  'updated_at': ?instance.updatedAt?.toIso8601String(),
  'test_mode': ?instance.testMode,
};
