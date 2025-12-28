// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_subscription_attribute_entity.freezed.dart';
part 'user_subscription_attribute_entity.g.dart';

enum SubscriptionStatus {
  @JsonValue('on_trial')
  onTrial,
  @JsonValue('active')
  active,
  @JsonValue('paused')
  paused,
  @JsonValue('expired')
  expired,
  @JsonValue('cancelled')
  cancelled,
  @JsonValue('past_due')
  pastDue,
  @JsonValue('unpaid')
  unPaid,
} //https://docs.lemonsqueezy.com/api/subscriptions/the-subscription-object

extension SubscriptionStatusX on SubscriptionStatus {
  bool get onSubscription => this == SubscriptionStatus.active || this == SubscriptionStatus.onTrial;

  bool get isCancelled => this == SubscriptionStatus.cancelled;
}

@freezed
abstract class UserSubscriptionAttributeEntity with _$UserSubscriptionAttributeEntity {
  const UserSubscriptionAttributeEntity._();

  @JsonSerializable(fieldRename: FieldRename.snake)

  /// Factory Constructor
  const factory UserSubscriptionAttributeEntity({
    required int storeId,
    required int customerId,
    required SubscriptionStatus status,
    @JsonKey(includeIfNull: false) int? orderId,
    @JsonKey(includeIfNull: false) int? orderItemId,
    @JsonKey(includeIfNull: false) int? productId,
    @JsonKey(includeIfNull: false) int? variantId,
    @JsonKey(includeIfNull: false) String? productName,
    @JsonKey(includeIfNull: false) String? variantName,
    @JsonKey(includeIfNull: false) String? userName,
    @JsonKey(includeIfNull: false) String? userEmail,
    @JsonKey(includeIfNull: false) String? statusFormatted,
    @JsonKey(includeIfNull: false) String? cardBrand,
    @JsonKey(includeIfNull: false) String? cardLastFour,
    @JsonKey(includeIfNull: false) Map<String, dynamic>? pause,
    @JsonKey(includeIfNull: false) bool? cancelled,
    @JsonKey(includeIfNull: false) DateTime? trialEndsAt,
    @JsonKey(includeIfNull: false) int? billingAnchor,
    @JsonKey(includeIfNull: false) Map<String, dynamic>? firstSubscriptionItem,
    @JsonKey(includeIfNull: false) Map<String, dynamic>? urls,
    @JsonKey(includeIfNull: false) DateTime? renewsAt,
    @JsonKey(includeIfNull: false) DateTime? endsAt,
    @JsonKey(includeIfNull: false) DateTime? createdAt,
    @JsonKey(includeIfNull: false) DateTime? updatedAt,
    @JsonKey(includeIfNull: false) bool? testMode,
  }) = _UserSubscriptionAttributeEntity;

  factory UserSubscriptionAttributeEntity.fromJson(Map<String, dynamic> json) => _$UserSubscriptionAttributeEntityFromJson(json);
}
