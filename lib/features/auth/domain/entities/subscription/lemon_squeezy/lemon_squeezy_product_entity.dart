// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'lemon_squeezy_product_entity.freezed.dart';
part 'lemon_squeezy_product_entity.g.dart';

@freezed
abstract class LemonSqueezyProductEntity with _$LemonSqueezyProductEntity {
  const LemonSqueezyProductEntity._();

  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory LemonSqueezyProductEntity({
    required String id,
    required int storeId,
    required String name,
    required String status,
    required int price,
    @JsonKey(includeIfNull: false) String? slug,
    @JsonKey(includeIfNull: false) String? description,
    @JsonKey(includeIfNull: false) String? statusFormatted,
    @JsonKey(includeIfNull: false) String? thumbUrl,
    @JsonKey(includeIfNull: false) String? largeThumbUrl,
    @JsonKey(includeIfNull: false) String? priceFormatted,
    @JsonKey(includeIfNull: false) int? fromPrice,
    @JsonKey(includeIfNull: false) String? fromPriceFormatted,
    @JsonKey(includeIfNull: false) int? toPrice,
    @JsonKey(includeIfNull: false) String? toPriceFormatted,
    @JsonKey(includeIfNull: false) bool? payWhatYouWant,
    @JsonKey(includeIfNull: false) String? buyNowUrl,
    @JsonKey(includeIfNull: false) DateTime? createdAt,
    @JsonKey(includeIfNull: false) DateTime? updatedAt,
    @JsonKey(includeIfNull: false) bool? testMode,
  }) = _LemonSqueezyProductEntity;

  factory LemonSqueezyProductEntity.fromJson(Map<String, dynamic> json) => _$LemonSqueezyProductEntityFromJson(json);
}
