// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'lemon_squeezy_customer_entity.freezed.dart';
part 'lemon_squeezy_customer_entity.g.dart';

@freezed
abstract class LemonSqueezyCustomerEntity with _$LemonSqueezyCustomerEntity {
  const LemonSqueezyCustomerEntity._();

  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory LemonSqueezyCustomerEntity({
    required String id,
    required int storeId,
    required String email,
    required String status,
    @JsonKey(includeIfNull: false) String? city,
    @JsonKey(includeIfNull: false) String? region,
    @JsonKey(includeIfNull: false) String? country,
    @JsonKey(includeIfNull: false) int? total_revenue_currency,
    @JsonKey(includeIfNull: false) int? mrr,
    @JsonKey(includeIfNull: false) String? status_formatted,
    @JsonKey(includeIfNull: false) String? country_formatted,
    @JsonKey(includeIfNull: false) String? total_revenue_currency_formatted,
    @JsonKey(includeIfNull: false) String? mrr_formatted,
    @JsonKey(includeIfNull: false) String? vatNumber,
    @JsonKey(includeIfNull: false) String? vatNumberFormatted,
    @JsonKey(includeIfNull: false) Map<String, dynamic>? urls,
    @JsonKey(includeIfNull: false) DateTime? createdAt,
    @JsonKey(includeIfNull: false) DateTime? updatedAt,
    @JsonKey(includeIfNull: false) bool? testMode,
  }) = _LemonSqueezyCustomerEntity;

  factory LemonSqueezyCustomerEntity.fromJson(Map<String, dynamic> json) => _$LemonSqueezyCustomerEntityFromJson(json);

  String? get customerPortalUrl => urls?['customer_portal'];
}
