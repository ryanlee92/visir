// ignore_for_file: invalid_annotation_target

import 'package:Visir/features/auth/domain/entities/subscription/user_subscription_attribute_entity.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_subscription_entity.freezed.dart';
part 'user_subscription_entity.g.dart';

@freezed
abstract class UserSubscriptionEntity with _$UserSubscriptionEntity {
  const UserSubscriptionEntity._();

  @JsonSerializable(fieldRename: FieldRename.snake)
  /// Factory Constructor
  const factory UserSubscriptionEntity({
    required String id,
    required String type,
    required UserSubscriptionAttributeEntity? attributes,
    @JsonKey(includeIfNull: false) Map<String, dynamic>? relationships,
  }) = _UserSubscriptionEntity;

  factory UserSubscriptionEntity.fromJson(Map<String, dynamic> json) => _$UserSubscriptionEntityFromJson(json);

  String get id => id;

  String get type => type;

  String get subscriptionProductName => attributes?.productName ?? '';

  DateTime? get subscriptionEndsAt => attributes?.endsAt?.toLocal();

  DateTime? get subscriptionRenewsAt => attributes?.renewsAt?.toLocal();

  DateTime? get subscriptionCreatedAt => attributes?.createdAt?.toLocal();

  DateTime? get subscriptionUpdatedAt => attributes?.updatedAt?.toLocal();

  DateTime? get subscriptionTrialEndsAt => attributes?.trialEndsAt?.toLocal();

  bool get isTestMode => attributes?.testMode ?? false;

  String get userName => attributes?.userName ?? '';

  String get userEmail => attributes?.userEmail ?? '';

  SubscriptionStatus? get subscriptionStatus => attributes?.status;

  bool get isCancelled => subscriptionStatus == SubscriptionStatus.cancelled;

  bool get isExpired => subscriptionStatus == SubscriptionStatus.expired;

  bool get isActive => subscriptionStatus == SubscriptionStatus.active;

  bool get isPaused => subscriptionStatus == SubscriptionStatus.paused;

  String get variantId => attributes?.variantId?.toString() ?? '';
}
