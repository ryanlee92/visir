// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_subscription_attribute_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserSubscriptionAttributeEntity _$UserSubscriptionAttributeEntityFromJson(
  Map<String, dynamic> json,
) => _UserSubscriptionAttributeEntity(
  storeId: (json['store_id'] as num).toInt(),
  customerId: (json['customer_id'] as num).toInt(),
  status: $enumDecode(_$SubscriptionStatusEnumMap, json['status']),
  orderId: (json['order_id'] as num?)?.toInt(),
  orderItemId: (json['order_item_id'] as num?)?.toInt(),
  productId: (json['product_id'] as num?)?.toInt(),
  variantId: (json['variant_id'] as num?)?.toInt(),
  productName: json['product_name'] as String?,
  variantName: json['variant_name'] as String?,
  userName: json['user_name'] as String?,
  userEmail: json['user_email'] as String?,
  statusFormatted: json['status_formatted'] as String?,
  cardBrand: json['card_brand'] as String?,
  cardLastFour: json['card_last_four'] as String?,
  pause: json['pause'] as Map<String, dynamic>?,
  cancelled: json['cancelled'] as bool?,
  trialEndsAt: json['trial_ends_at'] == null
      ? null
      : DateTime.parse(json['trial_ends_at'] as String),
  billingAnchor: (json['billing_anchor'] as num?)?.toInt(),
  firstSubscriptionItem:
      json['first_subscription_item'] as Map<String, dynamic>?,
  urls: json['urls'] as Map<String, dynamic>?,
  renewsAt: json['renews_at'] == null
      ? null
      : DateTime.parse(json['renews_at'] as String),
  endsAt: json['ends_at'] == null
      ? null
      : DateTime.parse(json['ends_at'] as String),
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
  testMode: json['test_mode'] as bool?,
);

Map<String, dynamic> _$UserSubscriptionAttributeEntityToJson(
  _UserSubscriptionAttributeEntity instance,
) => <String, dynamic>{
  'store_id': instance.storeId,
  'customer_id': instance.customerId,
  'status': _$SubscriptionStatusEnumMap[instance.status]!,
  'order_id': ?instance.orderId,
  'order_item_id': ?instance.orderItemId,
  'product_id': ?instance.productId,
  'variant_id': ?instance.variantId,
  'product_name': ?instance.productName,
  'variant_name': ?instance.variantName,
  'user_name': ?instance.userName,
  'user_email': ?instance.userEmail,
  'status_formatted': ?instance.statusFormatted,
  'card_brand': ?instance.cardBrand,
  'card_last_four': ?instance.cardLastFour,
  'pause': ?instance.pause,
  'cancelled': ?instance.cancelled,
  'trial_ends_at': ?instance.trialEndsAt?.toIso8601String(),
  'billing_anchor': ?instance.billingAnchor,
  'first_subscription_item': ?instance.firstSubscriptionItem,
  'urls': ?instance.urls,
  'renews_at': ?instance.renewsAt?.toIso8601String(),
  'ends_at': ?instance.endsAt?.toIso8601String(),
  'created_at': ?instance.createdAt?.toIso8601String(),
  'updated_at': ?instance.updatedAt?.toIso8601String(),
  'test_mode': ?instance.testMode,
};

const _$SubscriptionStatusEnumMap = {
  SubscriptionStatus.onTrial: 'on_trial',
  SubscriptionStatus.active: 'active',
  SubscriptionStatus.paused: 'paused',
  SubscriptionStatus.expired: 'expired',
  SubscriptionStatus.cancelled: 'cancelled',
  SubscriptionStatus.pastDue: 'past_due',
  SubscriptionStatus.unPaid: 'unpaid',
  SubscriptionStatus.paid: 'paid',
};
