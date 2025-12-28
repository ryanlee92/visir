// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_subscription_update_attributes_entity.freezed.dart';
part 'user_subscription_update_attributes_entity.g.dart';

@freezed
abstract class UserSubscriptionUpdateAttributesEntity with _$UserSubscriptionUpdateAttributesEntity {
  const UserSubscriptionUpdateAttributesEntity._();

  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory UserSubscriptionUpdateAttributesEntity({
    required bool cancelled,
    @JsonKey(includeIfNull: false) String? variantId,
    @JsonKey(includeIfNull: false) DateTime? trialEndsAt,
    @JsonKey(includeIfNull: false) int? billingAnchor,
    @JsonKey(includeIfNull: false) bool? invoiceImmediately,
    @JsonKey(includeIfNull: false) bool? disableProration,
    @JsonKey(includeIfNull: false) Map<String, dynamic>? pause,
  }) = _UserSubscriptionUpdateAttributesEntity;

  factory UserSubscriptionUpdateAttributesEntity.fromJson(Map<String, dynamic> json) => _$UserSubscriptionUpdateAttributesEntityFromJson(json);
}
