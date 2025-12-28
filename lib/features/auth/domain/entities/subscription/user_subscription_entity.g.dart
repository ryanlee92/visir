// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_subscription_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserSubscriptionEntity _$UserSubscriptionEntityFromJson(
  Map<String, dynamic> json,
) => _UserSubscriptionEntity(
  id: json['id'] as String,
  type: json['type'] as String,
  attributes: json['attributes'] == null
      ? null
      : UserSubscriptionAttributeEntity.fromJson(
          json['attributes'] as Map<String, dynamic>,
        ),
  relationships: json['relationships'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$UserSubscriptionEntityToJson(
  _UserSubscriptionEntity instance,
) => <String, dynamic>{
  'id': instance.id,
  'type': instance.type,
  'attributes': ?instance.attributes?.toJson(),
  'relationships': ?instance.relationships,
};
