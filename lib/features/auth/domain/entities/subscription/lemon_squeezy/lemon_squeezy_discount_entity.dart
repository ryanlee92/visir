// ignore_for_file: invalid_annotation_target, unused_element

import 'package:freezed_annotation/freezed_annotation.dart';

part 'lemon_squeezy_discount_entity.freezed.dart';
part 'lemon_squeezy_discount_entity.g.dart';

@freezed
abstract class LemonSqueezyDiscountEntity with _$LemonSqueezyDiscountEntity {
  const LemonSqueezyDiscountEntity._();

  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory LemonSqueezyDiscountEntity({
    required String id,
    required int storeId,
    required String name,
    required String code,
    required int amount,
    required String amountType,
    @JsonKey(includeIfNull: false) bool? isLimitedToProducts,
    @JsonKey(includeIfNull: false) bool? isLimitedRedemptions,
    @JsonKey(includeIfNull: false) int? maxRedemptions,
    @JsonKey(includeIfNull: false) DateTime? startsAt,
    @JsonKey(includeIfNull: false) DateTime? expiresAt,
    @JsonKey(includeIfNull: false) String? duration,
    @JsonKey(includeIfNull: false) int? durationInMonths,
    @JsonKey(includeIfNull: false) String? status,
    @JsonKey(includeIfNull: false) String? status_formatted,
    @JsonKey(includeIfNull: false) DateTime? createdAt,
    @JsonKey(includeIfNull: false) DateTime? updatedAt,
    @JsonKey(includeIfNull: false) bool? testMode,
    @JsonKey(includeIfNull: false) List<String>? variants,
  }) = _LemonSqueezyDiscountEntity;

  factory LemonSqueezyDiscountEntity.fromJson(Map<String, dynamic> json) => _$LemonSqueezyDiscountEntityFromJson(json);

  bool get isFixed => amountType == 'fixed';
}
