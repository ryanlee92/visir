// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'lemon_squeezy_customer_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LemonSqueezyCustomerEntity {

 String get id; int get storeId; String get email; String get status;@JsonKey(includeIfNull: false) String? get city;@JsonKey(includeIfNull: false) String? get region;@JsonKey(includeIfNull: false) String? get country;@JsonKey(includeIfNull: false) int? get total_revenue_currency;@JsonKey(includeIfNull: false) int? get mrr;@JsonKey(includeIfNull: false) String? get status_formatted;@JsonKey(includeIfNull: false) String? get country_formatted;@JsonKey(includeIfNull: false) String? get total_revenue_currency_formatted;@JsonKey(includeIfNull: false) String? get mrr_formatted;@JsonKey(includeIfNull: false) String? get vatNumber;@JsonKey(includeIfNull: false) String? get vatNumberFormatted;@JsonKey(includeIfNull: false) Map<String, dynamic>? get urls;@JsonKey(includeIfNull: false) DateTime? get createdAt;@JsonKey(includeIfNull: false) DateTime? get updatedAt;@JsonKey(includeIfNull: false) bool? get testMode;
/// Create a copy of LemonSqueezyCustomerEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LemonSqueezyCustomerEntityCopyWith<LemonSqueezyCustomerEntity> get copyWith => _$LemonSqueezyCustomerEntityCopyWithImpl<LemonSqueezyCustomerEntity>(this as LemonSqueezyCustomerEntity, _$identity);

  /// Serializes this LemonSqueezyCustomerEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LemonSqueezyCustomerEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.storeId, storeId) || other.storeId == storeId)&&(identical(other.email, email) || other.email == email)&&(identical(other.status, status) || other.status == status)&&(identical(other.city, city) || other.city == city)&&(identical(other.region, region) || other.region == region)&&(identical(other.country, country) || other.country == country)&&(identical(other.total_revenue_currency, total_revenue_currency) || other.total_revenue_currency == total_revenue_currency)&&(identical(other.mrr, mrr) || other.mrr == mrr)&&(identical(other.status_formatted, status_formatted) || other.status_formatted == status_formatted)&&(identical(other.country_formatted, country_formatted) || other.country_formatted == country_formatted)&&(identical(other.total_revenue_currency_formatted, total_revenue_currency_formatted) || other.total_revenue_currency_formatted == total_revenue_currency_formatted)&&(identical(other.mrr_formatted, mrr_formatted) || other.mrr_formatted == mrr_formatted)&&(identical(other.vatNumber, vatNumber) || other.vatNumber == vatNumber)&&(identical(other.vatNumberFormatted, vatNumberFormatted) || other.vatNumberFormatted == vatNumberFormatted)&&const DeepCollectionEquality().equals(other.urls, urls)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.testMode, testMode) || other.testMode == testMode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,storeId,email,status,city,region,country,total_revenue_currency,mrr,status_formatted,country_formatted,total_revenue_currency_formatted,mrr_formatted,vatNumber,vatNumberFormatted,const DeepCollectionEquality().hash(urls),createdAt,updatedAt,testMode]);

@override
String toString() {
  return 'LemonSqueezyCustomerEntity(id: $id, storeId: $storeId, email: $email, status: $status, city: $city, region: $region, country: $country, total_revenue_currency: $total_revenue_currency, mrr: $mrr, status_formatted: $status_formatted, country_formatted: $country_formatted, total_revenue_currency_formatted: $total_revenue_currency_formatted, mrr_formatted: $mrr_formatted, vatNumber: $vatNumber, vatNumberFormatted: $vatNumberFormatted, urls: $urls, createdAt: $createdAt, updatedAt: $updatedAt, testMode: $testMode)';
}


}

/// @nodoc
abstract mixin class $LemonSqueezyCustomerEntityCopyWith<$Res>  {
  factory $LemonSqueezyCustomerEntityCopyWith(LemonSqueezyCustomerEntity value, $Res Function(LemonSqueezyCustomerEntity) _then) = _$LemonSqueezyCustomerEntityCopyWithImpl;
@useResult
$Res call({
 String id, int storeId, String email, String status,@JsonKey(includeIfNull: false) String? city,@JsonKey(includeIfNull: false) String? region,@JsonKey(includeIfNull: false) String? country,@JsonKey(includeIfNull: false) int? total_revenue_currency,@JsonKey(includeIfNull: false) int? mrr,@JsonKey(includeIfNull: false) String? status_formatted,@JsonKey(includeIfNull: false) String? country_formatted,@JsonKey(includeIfNull: false) String? total_revenue_currency_formatted,@JsonKey(includeIfNull: false) String? mrr_formatted,@JsonKey(includeIfNull: false) String? vatNumber,@JsonKey(includeIfNull: false) String? vatNumberFormatted,@JsonKey(includeIfNull: false) Map<String, dynamic>? urls,@JsonKey(includeIfNull: false) DateTime? createdAt,@JsonKey(includeIfNull: false) DateTime? updatedAt,@JsonKey(includeIfNull: false) bool? testMode
});




}
/// @nodoc
class _$LemonSqueezyCustomerEntityCopyWithImpl<$Res>
    implements $LemonSqueezyCustomerEntityCopyWith<$Res> {
  _$LemonSqueezyCustomerEntityCopyWithImpl(this._self, this._then);

  final LemonSqueezyCustomerEntity _self;
  final $Res Function(LemonSqueezyCustomerEntity) _then;

/// Create a copy of LemonSqueezyCustomerEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? storeId = null,Object? email = null,Object? status = null,Object? city = freezed,Object? region = freezed,Object? country = freezed,Object? total_revenue_currency = freezed,Object? mrr = freezed,Object? status_formatted = freezed,Object? country_formatted = freezed,Object? total_revenue_currency_formatted = freezed,Object? mrr_formatted = freezed,Object? vatNumber = freezed,Object? vatNumberFormatted = freezed,Object? urls = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? testMode = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,storeId: null == storeId ? _self.storeId : storeId // ignore: cast_nullable_to_non_nullable
as int,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,region: freezed == region ? _self.region : region // ignore: cast_nullable_to_non_nullable
as String?,country: freezed == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String?,total_revenue_currency: freezed == total_revenue_currency ? _self.total_revenue_currency : total_revenue_currency // ignore: cast_nullable_to_non_nullable
as int?,mrr: freezed == mrr ? _self.mrr : mrr // ignore: cast_nullable_to_non_nullable
as int?,status_formatted: freezed == status_formatted ? _self.status_formatted : status_formatted // ignore: cast_nullable_to_non_nullable
as String?,country_formatted: freezed == country_formatted ? _self.country_formatted : country_formatted // ignore: cast_nullable_to_non_nullable
as String?,total_revenue_currency_formatted: freezed == total_revenue_currency_formatted ? _self.total_revenue_currency_formatted : total_revenue_currency_formatted // ignore: cast_nullable_to_non_nullable
as String?,mrr_formatted: freezed == mrr_formatted ? _self.mrr_formatted : mrr_formatted // ignore: cast_nullable_to_non_nullable
as String?,vatNumber: freezed == vatNumber ? _self.vatNumber : vatNumber // ignore: cast_nullable_to_non_nullable
as String?,vatNumberFormatted: freezed == vatNumberFormatted ? _self.vatNumberFormatted : vatNumberFormatted // ignore: cast_nullable_to_non_nullable
as String?,urls: freezed == urls ? _self.urls : urls // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,testMode: freezed == testMode ? _self.testMode : testMode // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}

}


/// Adds pattern-matching-related methods to [LemonSqueezyCustomerEntity].
extension LemonSqueezyCustomerEntityPatterns on LemonSqueezyCustomerEntity {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LemonSqueezyCustomerEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LemonSqueezyCustomerEntity() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LemonSqueezyCustomerEntity value)  $default,){
final _that = this;
switch (_that) {
case _LemonSqueezyCustomerEntity():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LemonSqueezyCustomerEntity value)?  $default,){
final _that = this;
switch (_that) {
case _LemonSqueezyCustomerEntity() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  int storeId,  String email,  String status, @JsonKey(includeIfNull: false)  String? city, @JsonKey(includeIfNull: false)  String? region, @JsonKey(includeIfNull: false)  String? country, @JsonKey(includeIfNull: false)  int? total_revenue_currency, @JsonKey(includeIfNull: false)  int? mrr, @JsonKey(includeIfNull: false)  String? status_formatted, @JsonKey(includeIfNull: false)  String? country_formatted, @JsonKey(includeIfNull: false)  String? total_revenue_currency_formatted, @JsonKey(includeIfNull: false)  String? mrr_formatted, @JsonKey(includeIfNull: false)  String? vatNumber, @JsonKey(includeIfNull: false)  String? vatNumberFormatted, @JsonKey(includeIfNull: false)  Map<String, dynamic>? urls, @JsonKey(includeIfNull: false)  DateTime? createdAt, @JsonKey(includeIfNull: false)  DateTime? updatedAt, @JsonKey(includeIfNull: false)  bool? testMode)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LemonSqueezyCustomerEntity() when $default != null:
return $default(_that.id,_that.storeId,_that.email,_that.status,_that.city,_that.region,_that.country,_that.total_revenue_currency,_that.mrr,_that.status_formatted,_that.country_formatted,_that.total_revenue_currency_formatted,_that.mrr_formatted,_that.vatNumber,_that.vatNumberFormatted,_that.urls,_that.createdAt,_that.updatedAt,_that.testMode);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  int storeId,  String email,  String status, @JsonKey(includeIfNull: false)  String? city, @JsonKey(includeIfNull: false)  String? region, @JsonKey(includeIfNull: false)  String? country, @JsonKey(includeIfNull: false)  int? total_revenue_currency, @JsonKey(includeIfNull: false)  int? mrr, @JsonKey(includeIfNull: false)  String? status_formatted, @JsonKey(includeIfNull: false)  String? country_formatted, @JsonKey(includeIfNull: false)  String? total_revenue_currency_formatted, @JsonKey(includeIfNull: false)  String? mrr_formatted, @JsonKey(includeIfNull: false)  String? vatNumber, @JsonKey(includeIfNull: false)  String? vatNumberFormatted, @JsonKey(includeIfNull: false)  Map<String, dynamic>? urls, @JsonKey(includeIfNull: false)  DateTime? createdAt, @JsonKey(includeIfNull: false)  DateTime? updatedAt, @JsonKey(includeIfNull: false)  bool? testMode)  $default,) {final _that = this;
switch (_that) {
case _LemonSqueezyCustomerEntity():
return $default(_that.id,_that.storeId,_that.email,_that.status,_that.city,_that.region,_that.country,_that.total_revenue_currency,_that.mrr,_that.status_formatted,_that.country_formatted,_that.total_revenue_currency_formatted,_that.mrr_formatted,_that.vatNumber,_that.vatNumberFormatted,_that.urls,_that.createdAt,_that.updatedAt,_that.testMode);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  int storeId,  String email,  String status, @JsonKey(includeIfNull: false)  String? city, @JsonKey(includeIfNull: false)  String? region, @JsonKey(includeIfNull: false)  String? country, @JsonKey(includeIfNull: false)  int? total_revenue_currency, @JsonKey(includeIfNull: false)  int? mrr, @JsonKey(includeIfNull: false)  String? status_formatted, @JsonKey(includeIfNull: false)  String? country_formatted, @JsonKey(includeIfNull: false)  String? total_revenue_currency_formatted, @JsonKey(includeIfNull: false)  String? mrr_formatted, @JsonKey(includeIfNull: false)  String? vatNumber, @JsonKey(includeIfNull: false)  String? vatNumberFormatted, @JsonKey(includeIfNull: false)  Map<String, dynamic>? urls, @JsonKey(includeIfNull: false)  DateTime? createdAt, @JsonKey(includeIfNull: false)  DateTime? updatedAt, @JsonKey(includeIfNull: false)  bool? testMode)?  $default,) {final _that = this;
switch (_that) {
case _LemonSqueezyCustomerEntity() when $default != null:
return $default(_that.id,_that.storeId,_that.email,_that.status,_that.city,_that.region,_that.country,_that.total_revenue_currency,_that.mrr,_that.status_formatted,_that.country_formatted,_that.total_revenue_currency_formatted,_that.mrr_formatted,_that.vatNumber,_that.vatNumberFormatted,_that.urls,_that.createdAt,_that.updatedAt,_that.testMode);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _LemonSqueezyCustomerEntity extends LemonSqueezyCustomerEntity {
  const _LemonSqueezyCustomerEntity({required this.id, required this.storeId, required this.email, required this.status, @JsonKey(includeIfNull: false) this.city, @JsonKey(includeIfNull: false) this.region, @JsonKey(includeIfNull: false) this.country, @JsonKey(includeIfNull: false) this.total_revenue_currency, @JsonKey(includeIfNull: false) this.mrr, @JsonKey(includeIfNull: false) this.status_formatted, @JsonKey(includeIfNull: false) this.country_formatted, @JsonKey(includeIfNull: false) this.total_revenue_currency_formatted, @JsonKey(includeIfNull: false) this.mrr_formatted, @JsonKey(includeIfNull: false) this.vatNumber, @JsonKey(includeIfNull: false) this.vatNumberFormatted, @JsonKey(includeIfNull: false) final  Map<String, dynamic>? urls, @JsonKey(includeIfNull: false) this.createdAt, @JsonKey(includeIfNull: false) this.updatedAt, @JsonKey(includeIfNull: false) this.testMode}): _urls = urls,super._();
  factory _LemonSqueezyCustomerEntity.fromJson(Map<String, dynamic> json) => _$LemonSqueezyCustomerEntityFromJson(json);

@override final  String id;
@override final  int storeId;
@override final  String email;
@override final  String status;
@override@JsonKey(includeIfNull: false) final  String? city;
@override@JsonKey(includeIfNull: false) final  String? region;
@override@JsonKey(includeIfNull: false) final  String? country;
@override@JsonKey(includeIfNull: false) final  int? total_revenue_currency;
@override@JsonKey(includeIfNull: false) final  int? mrr;
@override@JsonKey(includeIfNull: false) final  String? status_formatted;
@override@JsonKey(includeIfNull: false) final  String? country_formatted;
@override@JsonKey(includeIfNull: false) final  String? total_revenue_currency_formatted;
@override@JsonKey(includeIfNull: false) final  String? mrr_formatted;
@override@JsonKey(includeIfNull: false) final  String? vatNumber;
@override@JsonKey(includeIfNull: false) final  String? vatNumberFormatted;
 final  Map<String, dynamic>? _urls;
@override@JsonKey(includeIfNull: false) Map<String, dynamic>? get urls {
  final value = _urls;
  if (value == null) return null;
  if (_urls is EqualUnmodifiableMapView) return _urls;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override@JsonKey(includeIfNull: false) final  DateTime? createdAt;
@override@JsonKey(includeIfNull: false) final  DateTime? updatedAt;
@override@JsonKey(includeIfNull: false) final  bool? testMode;

/// Create a copy of LemonSqueezyCustomerEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LemonSqueezyCustomerEntityCopyWith<_LemonSqueezyCustomerEntity> get copyWith => __$LemonSqueezyCustomerEntityCopyWithImpl<_LemonSqueezyCustomerEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LemonSqueezyCustomerEntityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LemonSqueezyCustomerEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.storeId, storeId) || other.storeId == storeId)&&(identical(other.email, email) || other.email == email)&&(identical(other.status, status) || other.status == status)&&(identical(other.city, city) || other.city == city)&&(identical(other.region, region) || other.region == region)&&(identical(other.country, country) || other.country == country)&&(identical(other.total_revenue_currency, total_revenue_currency) || other.total_revenue_currency == total_revenue_currency)&&(identical(other.mrr, mrr) || other.mrr == mrr)&&(identical(other.status_formatted, status_formatted) || other.status_formatted == status_formatted)&&(identical(other.country_formatted, country_formatted) || other.country_formatted == country_formatted)&&(identical(other.total_revenue_currency_formatted, total_revenue_currency_formatted) || other.total_revenue_currency_formatted == total_revenue_currency_formatted)&&(identical(other.mrr_formatted, mrr_formatted) || other.mrr_formatted == mrr_formatted)&&(identical(other.vatNumber, vatNumber) || other.vatNumber == vatNumber)&&(identical(other.vatNumberFormatted, vatNumberFormatted) || other.vatNumberFormatted == vatNumberFormatted)&&const DeepCollectionEquality().equals(other._urls, _urls)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.testMode, testMode) || other.testMode == testMode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,storeId,email,status,city,region,country,total_revenue_currency,mrr,status_formatted,country_formatted,total_revenue_currency_formatted,mrr_formatted,vatNumber,vatNumberFormatted,const DeepCollectionEquality().hash(_urls),createdAt,updatedAt,testMode]);

@override
String toString() {
  return 'LemonSqueezyCustomerEntity(id: $id, storeId: $storeId, email: $email, status: $status, city: $city, region: $region, country: $country, total_revenue_currency: $total_revenue_currency, mrr: $mrr, status_formatted: $status_formatted, country_formatted: $country_formatted, total_revenue_currency_formatted: $total_revenue_currency_formatted, mrr_formatted: $mrr_formatted, vatNumber: $vatNumber, vatNumberFormatted: $vatNumberFormatted, urls: $urls, createdAt: $createdAt, updatedAt: $updatedAt, testMode: $testMode)';
}


}

/// @nodoc
abstract mixin class _$LemonSqueezyCustomerEntityCopyWith<$Res> implements $LemonSqueezyCustomerEntityCopyWith<$Res> {
  factory _$LemonSqueezyCustomerEntityCopyWith(_LemonSqueezyCustomerEntity value, $Res Function(_LemonSqueezyCustomerEntity) _then) = __$LemonSqueezyCustomerEntityCopyWithImpl;
@override @useResult
$Res call({
 String id, int storeId, String email, String status,@JsonKey(includeIfNull: false) String? city,@JsonKey(includeIfNull: false) String? region,@JsonKey(includeIfNull: false) String? country,@JsonKey(includeIfNull: false) int? total_revenue_currency,@JsonKey(includeIfNull: false) int? mrr,@JsonKey(includeIfNull: false) String? status_formatted,@JsonKey(includeIfNull: false) String? country_formatted,@JsonKey(includeIfNull: false) String? total_revenue_currency_formatted,@JsonKey(includeIfNull: false) String? mrr_formatted,@JsonKey(includeIfNull: false) String? vatNumber,@JsonKey(includeIfNull: false) String? vatNumberFormatted,@JsonKey(includeIfNull: false) Map<String, dynamic>? urls,@JsonKey(includeIfNull: false) DateTime? createdAt,@JsonKey(includeIfNull: false) DateTime? updatedAt,@JsonKey(includeIfNull: false) bool? testMode
});




}
/// @nodoc
class __$LemonSqueezyCustomerEntityCopyWithImpl<$Res>
    implements _$LemonSqueezyCustomerEntityCopyWith<$Res> {
  __$LemonSqueezyCustomerEntityCopyWithImpl(this._self, this._then);

  final _LemonSqueezyCustomerEntity _self;
  final $Res Function(_LemonSqueezyCustomerEntity) _then;

/// Create a copy of LemonSqueezyCustomerEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? storeId = null,Object? email = null,Object? status = null,Object? city = freezed,Object? region = freezed,Object? country = freezed,Object? total_revenue_currency = freezed,Object? mrr = freezed,Object? status_formatted = freezed,Object? country_formatted = freezed,Object? total_revenue_currency_formatted = freezed,Object? mrr_formatted = freezed,Object? vatNumber = freezed,Object? vatNumberFormatted = freezed,Object? urls = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? testMode = freezed,}) {
  return _then(_LemonSqueezyCustomerEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,storeId: null == storeId ? _self.storeId : storeId // ignore: cast_nullable_to_non_nullable
as int,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,region: freezed == region ? _self.region : region // ignore: cast_nullable_to_non_nullable
as String?,country: freezed == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String?,total_revenue_currency: freezed == total_revenue_currency ? _self.total_revenue_currency : total_revenue_currency // ignore: cast_nullable_to_non_nullable
as int?,mrr: freezed == mrr ? _self.mrr : mrr // ignore: cast_nullable_to_non_nullable
as int?,status_formatted: freezed == status_formatted ? _self.status_formatted : status_formatted // ignore: cast_nullable_to_non_nullable
as String?,country_formatted: freezed == country_formatted ? _self.country_formatted : country_formatted // ignore: cast_nullable_to_non_nullable
as String?,total_revenue_currency_formatted: freezed == total_revenue_currency_formatted ? _self.total_revenue_currency_formatted : total_revenue_currency_formatted // ignore: cast_nullable_to_non_nullable
as String?,mrr_formatted: freezed == mrr_formatted ? _self.mrr_formatted : mrr_formatted // ignore: cast_nullable_to_non_nullable
as String?,vatNumber: freezed == vatNumber ? _self.vatNumber : vatNumber // ignore: cast_nullable_to_non_nullable
as String?,vatNumberFormatted: freezed == vatNumberFormatted ? _self.vatNumberFormatted : vatNumberFormatted // ignore: cast_nullable_to_non_nullable
as String?,urls: freezed == urls ? _self._urls : urls // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,testMode: freezed == testMode ? _self.testMode : testMode // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}


}

// dart format on
