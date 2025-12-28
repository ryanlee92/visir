// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_subscription_update_attributes_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserSubscriptionUpdateAttributesEntity
_$UserSubscriptionUpdateAttributesEntityFromJson(Map<String, dynamic> json) =>
    _UserSubscriptionUpdateAttributesEntity(
      cancelled: json['cancelled'] as bool,
      variantId: json['variant_id'] as String?,
      trialEndsAt: json['trial_ends_at'] == null
          ? null
          : DateTime.parse(json['trial_ends_at'] as String),
      billingAnchor: (json['billing_anchor'] as num?)?.toInt(),
      invoiceImmediately: json['invoice_immediately'] as bool?,
      disableProration: json['disable_proration'] as bool?,
      pause: json['pause'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$UserSubscriptionUpdateAttributesEntityToJson(
  _UserSubscriptionUpdateAttributesEntity instance,
) => <String, dynamic>{
  'cancelled': instance.cancelled,
  'variant_id': ?instance.variantId,
  'trial_ends_at': ?instance.trialEndsAt?.toIso8601String(),
  'billing_anchor': ?instance.billingAnchor,
  'invoice_immediately': ?instance.invoiceImmediately,
  'disable_proration': ?instance.disableProration,
  'pause': ?instance.pause,
};
