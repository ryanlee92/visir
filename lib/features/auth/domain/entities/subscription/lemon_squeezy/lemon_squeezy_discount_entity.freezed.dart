// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'lemon_squeezy_discount_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LemonSqueezyDiscountEntity {

 String get id; int get storeId; String get name; String get code; int get amount; String get amountType;@JsonKey(includeIfNull: false) bool? get isLimitedToProducts;@JsonKey(includeIfNull: false) bool? get isLimitedRedemptions;@JsonKey(includeIfNull: false) int? get maxRedemptions;@JsonKey(includeIfNull: false) DateTime? get startsAt;@JsonKey(includeIfNull: false) DateTime? get expiresAt;@JsonKey(includeIfNull: false) String? get duration;@JsonKey(includeIfNull: false) int? get durationInMonths;@JsonKey(includeIfNull: false) String? get status;@JsonKey(includeIfNull: false) String? get status_formatted;@JsonKey(includeIfNull: false) DateTime? get createdAt;@JsonKey(includeIfNull: false) DateTime? get updatedAt;@JsonKey(includeIfNull: false) bool? get testMode;@JsonKey(includeIfNull: false) List<String>? get variants;
/// Create a copy of LemonSqueezyDiscountEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LemonSqueezyDiscountEntityCopyWith<LemonSqueezyDiscountEntity> get copyWith => _$LemonSqueezyDiscountEntityCopyWithImpl<LemonSqueezyDiscountEntity>(this as LemonSqueezyDiscountEntity, _$identity);

  /// Serializes this LemonSqueezyDiscountEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LemonSqueezyDiscountEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.storeId, storeId) || other.storeId == storeId)&&(identical(other.name, name) || other.name == name)&&(identical(other.code, code) || other.code == code)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.amountType, amountType) || other.amountType == amountType)&&(identical(other.isLimitedToProducts, isLimitedToProducts) || other.isLimitedToProducts == isLimitedToProducts)&&(identical(other.isLimitedRedemptions, isLimitedRedemptions) || other.isLimitedRedemptions == isLimitedRedemptions)&&(identical(other.maxRedemptions, maxRedemptions) || other.maxRedemptions == maxRedemptions)&&(identical(other.startsAt, startsAt) || other.startsAt == startsAt)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.durationInMonths, durationInMonths) || other.durationInMonths == durationInMonths)&&(identical(other.status, status) || other.status == status)&&(identical(other.status_formatted, status_formatted) || other.status_formatted == status_formatted)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.testMode, testMode) || other.testMode == testMode)&&const DeepCollectionEquality().equals(other.variants, variants));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,storeId,name,code,amount,amountType,isLimitedToProducts,isLimitedRedemptions,maxRedemptions,startsAt,expiresAt,duration,durationInMonths,status,status_formatted,createdAt,updatedAt,testMode,const DeepCollectionEquality().hash(variants)]);

@override
String toString() {
  return 'LemonSqueezyDiscountEntity(id: $id, storeId: $storeId, name: $name, code: $code, amount: $amount, amountType: $amountType, isLimitedToProducts: $isLimitedToProducts, isLimitedRedemptions: $isLimitedRedemptions, maxRedemptions: $maxRedemptions, startsAt: $startsAt, expiresAt: $expiresAt, duration: $duration, durationInMonths: $durationInMonths, status: $status, status_formatted: $status_formatted, createdAt: $createdAt, updatedAt: $updatedAt, testMode: $testMode, variants: $variants)';
}


}

/// @nodoc
abstract mixin class $LemonSqueezyDiscountEntityCopyWith<$Res>  {
  factory $LemonSqueezyDiscountEntityCopyWith(LemonSqueezyDiscountEntity value, $Res Function(LemonSqueezyDiscountEntity) _then) = _$LemonSqueezyDiscountEntityCopyWithImpl;
@useResult
$Res call({
 String id, int storeId, String name, String code, int amount, String amountType,@JsonKey(includeIfNull: false) bool? isLimitedToProducts,@JsonKey(includeIfNull: false) bool? isLimitedRedemptions,@JsonKey(includeIfNull: false) int? maxRedemptions,@JsonKey(includeIfNull: false) DateTime? startsAt,@JsonKey(includeIfNull: false) DateTime? expiresAt,@JsonKey(includeIfNull: false) String? duration,@JsonKey(includeIfNull: false) int? durationInMonths,@JsonKey(includeIfNull: false) String? status,@JsonKey(includeIfNull: false) String? status_formatted,@JsonKey(includeIfNull: false) DateTime? createdAt,@JsonKey(includeIfNull: false) DateTime? updatedAt,@JsonKey(includeIfNull: false) bool? testMode,@JsonKey(includeIfNull: false) List<String>? variants
});




}
/// @nodoc
class _$LemonSqueezyDiscountEntityCopyWithImpl<$Res>
    implements $LemonSqueezyDiscountEntityCopyWith<$Res> {
  _$LemonSqueezyDiscountEntityCopyWithImpl(this._self, this._then);

  final LemonSqueezyDiscountEntity _self;
  final $Res Function(LemonSqueezyDiscountEntity) _then;

/// Create a copy of LemonSqueezyDiscountEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? storeId = null,Object? name = null,Object? code = null,Object? amount = null,Object? amountType = null,Object? isLimitedToProducts = freezed,Object? isLimitedRedemptions = freezed,Object? maxRedemptions = freezed,Object? startsAt = freezed,Object? expiresAt = freezed,Object? duration = freezed,Object? durationInMonths = freezed,Object? status = freezed,Object? status_formatted = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? testMode = freezed,Object? variants = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,storeId: null == storeId ? _self.storeId : storeId // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,amountType: null == amountType ? _self.amountType : amountType // ignore: cast_nullable_to_non_nullable
as String,isLimitedToProducts: freezed == isLimitedToProducts ? _self.isLimitedToProducts : isLimitedToProducts // ignore: cast_nullable_to_non_nullable
as bool?,isLimitedRedemptions: freezed == isLimitedRedemptions ? _self.isLimitedRedemptions : isLimitedRedemptions // ignore: cast_nullable_to_non_nullable
as bool?,maxRedemptions: freezed == maxRedemptions ? _self.maxRedemptions : maxRedemptions // ignore: cast_nullable_to_non_nullable
as int?,startsAt: freezed == startsAt ? _self.startsAt : startsAt // ignore: cast_nullable_to_non_nullable
as DateTime?,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,duration: freezed == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as String?,durationInMonths: freezed == durationInMonths ? _self.durationInMonths : durationInMonths // ignore: cast_nullable_to_non_nullable
as int?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,status_formatted: freezed == status_formatted ? _self.status_formatted : status_formatted // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,testMode: freezed == testMode ? _self.testMode : testMode // ignore: cast_nullable_to_non_nullable
as bool?,variants: freezed == variants ? _self.variants : variants // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}

}


/// Adds pattern-matching-related methods to [LemonSqueezyDiscountEntity].
extension LemonSqueezyDiscountEntityPatterns on LemonSqueezyDiscountEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LemonSqueezyDiscountEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LemonSqueezyDiscountEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LemonSqueezyDiscountEntity value)  $default,){
final _that = this;
switch (_that) {
case _LemonSqueezyDiscountEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LemonSqueezyDiscountEntity value)?  $default,){
final _that = this;
switch (_that) {
case _LemonSqueezyDiscountEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  int storeId,  String name,  String code,  int amount,  String amountType, @JsonKey(includeIfNull: false)  bool? isLimitedToProducts, @JsonKey(includeIfNull: false)  bool? isLimitedRedemptions, @JsonKey(includeIfNull: false)  int? maxRedemptions, @JsonKey(includeIfNull: false)  DateTime? startsAt, @JsonKey(includeIfNull: false)  DateTime? expiresAt, @JsonKey(includeIfNull: false)  String? duration, @JsonKey(includeIfNull: false)  int? durationInMonths, @JsonKey(includeIfNull: false)  String? status, @JsonKey(includeIfNull: false)  String? status_formatted, @JsonKey(includeIfNull: false)  DateTime? createdAt, @JsonKey(includeIfNull: false)  DateTime? updatedAt, @JsonKey(includeIfNull: false)  bool? testMode, @JsonKey(includeIfNull: false)  List<String>? variants)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LemonSqueezyDiscountEntity() when $default != null:
return $default(_that.id,_that.storeId,_that.name,_that.code,_that.amount,_that.amountType,_that.isLimitedToProducts,_that.isLimitedRedemptions,_that.maxRedemptions,_that.startsAt,_that.expiresAt,_that.duration,_that.durationInMonths,_that.status,_that.status_formatted,_that.createdAt,_that.updatedAt,_that.testMode,_that.variants);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  int storeId,  String name,  String code,  int amount,  String amountType, @JsonKey(includeIfNull: false)  bool? isLimitedToProducts, @JsonKey(includeIfNull: false)  bool? isLimitedRedemptions, @JsonKey(includeIfNull: false)  int? maxRedemptions, @JsonKey(includeIfNull: false)  DateTime? startsAt, @JsonKey(includeIfNull: false)  DateTime? expiresAt, @JsonKey(includeIfNull: false)  String? duration, @JsonKey(includeIfNull: false)  int? durationInMonths, @JsonKey(includeIfNull: false)  String? status, @JsonKey(includeIfNull: false)  String? status_formatted, @JsonKey(includeIfNull: false)  DateTime? createdAt, @JsonKey(includeIfNull: false)  DateTime? updatedAt, @JsonKey(includeIfNull: false)  bool? testMode, @JsonKey(includeIfNull: false)  List<String>? variants)  $default,) {final _that = this;
switch (_that) {
case _LemonSqueezyDiscountEntity():
return $default(_that.id,_that.storeId,_that.name,_that.code,_that.amount,_that.amountType,_that.isLimitedToProducts,_that.isLimitedRedemptions,_that.maxRedemptions,_that.startsAt,_that.expiresAt,_that.duration,_that.durationInMonths,_that.status,_that.status_formatted,_that.createdAt,_that.updatedAt,_that.testMode,_that.variants);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  int storeId,  String name,  String code,  int amount,  String amountType, @JsonKey(includeIfNull: false)  bool? isLimitedToProducts, @JsonKey(includeIfNull: false)  bool? isLimitedRedemptions, @JsonKey(includeIfNull: false)  int? maxRedemptions, @JsonKey(includeIfNull: false)  DateTime? startsAt, @JsonKey(includeIfNull: false)  DateTime? expiresAt, @JsonKey(includeIfNull: false)  String? duration, @JsonKey(includeIfNull: false)  int? durationInMonths, @JsonKey(includeIfNull: false)  String? status, @JsonKey(includeIfNull: false)  String? status_formatted, @JsonKey(includeIfNull: false)  DateTime? createdAt, @JsonKey(includeIfNull: false)  DateTime? updatedAt, @JsonKey(includeIfNull: false)  bool? testMode, @JsonKey(includeIfNull: false)  List<String>? variants)?  $default,) {final _that = this;
switch (_that) {
case _LemonSqueezyDiscountEntity() when $default != null:
return $default(_that.id,_that.storeId,_that.name,_that.code,_that.amount,_that.amountType,_that.isLimitedToProducts,_that.isLimitedRedemptions,_that.maxRedemptions,_that.startsAt,_that.expiresAt,_that.duration,_that.durationInMonths,_that.status,_that.status_formatted,_that.createdAt,_that.updatedAt,_that.testMode,_that.variants);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _LemonSqueezyDiscountEntity extends LemonSqueezyDiscountEntity {
  const _LemonSqueezyDiscountEntity({required this.id, required this.storeId, required this.name, required this.code, required this.amount, required this.amountType, @JsonKey(includeIfNull: false) this.isLimitedToProducts, @JsonKey(includeIfNull: false) this.isLimitedRedemptions, @JsonKey(includeIfNull: false) this.maxRedemptions, @JsonKey(includeIfNull: false) this.startsAt, @JsonKey(includeIfNull: false) this.expiresAt, @JsonKey(includeIfNull: false) this.duration, @JsonKey(includeIfNull: false) this.durationInMonths, @JsonKey(includeIfNull: false) this.status, @JsonKey(includeIfNull: false) this.status_formatted, @JsonKey(includeIfNull: false) this.createdAt, @JsonKey(includeIfNull: false) this.updatedAt, @JsonKey(includeIfNull: false) this.testMode, @JsonKey(includeIfNull: false) final  List<String>? variants}): _variants = variants,super._();
  factory _LemonSqueezyDiscountEntity.fromJson(Map<String, dynamic> json) => _$LemonSqueezyDiscountEntityFromJson(json);

@override final  String id;
@override final  int storeId;
@override final  String name;
@override final  String code;
@override final  int amount;
@override final  String amountType;
@override@JsonKey(includeIfNull: false) final  bool? isLimitedToProducts;
@override@JsonKey(includeIfNull: false) final  bool? isLimitedRedemptions;
@override@JsonKey(includeIfNull: false) final  int? maxRedemptions;
@override@JsonKey(includeIfNull: false) final  DateTime? startsAt;
@override@JsonKey(includeIfNull: false) final  DateTime? expiresAt;
@override@JsonKey(includeIfNull: false) final  String? duration;
@override@JsonKey(includeIfNull: false) final  int? durationInMonths;
@override@JsonKey(includeIfNull: false) final  String? status;
@override@JsonKey(includeIfNull: false) final  String? status_formatted;
@override@JsonKey(includeIfNull: false) final  DateTime? createdAt;
@override@JsonKey(includeIfNull: false) final  DateTime? updatedAt;
@override@JsonKey(includeIfNull: false) final  bool? testMode;
 final  List<String>? _variants;
@override@JsonKey(includeIfNull: false) List<String>? get variants {
  final value = _variants;
  if (value == null) return null;
  if (_variants is EqualUnmodifiableListView) return _variants;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of LemonSqueezyDiscountEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LemonSqueezyDiscountEntityCopyWith<_LemonSqueezyDiscountEntity> get copyWith => __$LemonSqueezyDiscountEntityCopyWithImpl<_LemonSqueezyDiscountEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LemonSqueezyDiscountEntityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LemonSqueezyDiscountEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.storeId, storeId) || other.storeId == storeId)&&(identical(other.name, name) || other.name == name)&&(identical(other.code, code) || other.code == code)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.amountType, amountType) || other.amountType == amountType)&&(identical(other.isLimitedToProducts, isLimitedToProducts) || other.isLimitedToProducts == isLimitedToProducts)&&(identical(other.isLimitedRedemptions, isLimitedRedemptions) || other.isLimitedRedemptions == isLimitedRedemptions)&&(identical(other.maxRedemptions, maxRedemptions) || other.maxRedemptions == maxRedemptions)&&(identical(other.startsAt, startsAt) || other.startsAt == startsAt)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.durationInMonths, durationInMonths) || other.durationInMonths == durationInMonths)&&(identical(other.status, status) || other.status == status)&&(identical(other.status_formatted, status_formatted) || other.status_formatted == status_formatted)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.testMode, testMode) || other.testMode == testMode)&&const DeepCollectionEquality().equals(other._variants, _variants));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,storeId,name,code,amount,amountType,isLimitedToProducts,isLimitedRedemptions,maxRedemptions,startsAt,expiresAt,duration,durationInMonths,status,status_formatted,createdAt,updatedAt,testMode,const DeepCollectionEquality().hash(_variants)]);

@override
String toString() {
  return 'LemonSqueezyDiscountEntity(id: $id, storeId: $storeId, name: $name, code: $code, amount: $amount, amountType: $amountType, isLimitedToProducts: $isLimitedToProducts, isLimitedRedemptions: $isLimitedRedemptions, maxRedemptions: $maxRedemptions, startsAt: $startsAt, expiresAt: $expiresAt, duration: $duration, durationInMonths: $durationInMonths, status: $status, status_formatted: $status_formatted, createdAt: $createdAt, updatedAt: $updatedAt, testMode: $testMode, variants: $variants)';
}


}

/// @nodoc
abstract mixin class _$LemonSqueezyDiscountEntityCopyWith<$Res> implements $LemonSqueezyDiscountEntityCopyWith<$Res> {
  factory _$LemonSqueezyDiscountEntityCopyWith(_LemonSqueezyDiscountEntity value, $Res Function(_LemonSqueezyDiscountEntity) _then) = __$LemonSqueezyDiscountEntityCopyWithImpl;
@override @useResult
$Res call({
 String id, int storeId, String name, String code, int amount, String amountType,@JsonKey(includeIfNull: false) bool? isLimitedToProducts,@JsonKey(includeIfNull: false) bool? isLimitedRedemptions,@JsonKey(includeIfNull: false) int? maxRedemptions,@JsonKey(includeIfNull: false) DateTime? startsAt,@JsonKey(includeIfNull: false) DateTime? expiresAt,@JsonKey(includeIfNull: false) String? duration,@JsonKey(includeIfNull: false) int? durationInMonths,@JsonKey(includeIfNull: false) String? status,@JsonKey(includeIfNull: false) String? status_formatted,@JsonKey(includeIfNull: false) DateTime? createdAt,@JsonKey(includeIfNull: false) DateTime? updatedAt,@JsonKey(includeIfNull: false) bool? testMode,@JsonKey(includeIfNull: false) List<String>? variants
});




}
/// @nodoc
class __$LemonSqueezyDiscountEntityCopyWithImpl<$Res>
    implements _$LemonSqueezyDiscountEntityCopyWith<$Res> {
  __$LemonSqueezyDiscountEntityCopyWithImpl(this._self, this._then);

  final _LemonSqueezyDiscountEntity _self;
  final $Res Function(_LemonSqueezyDiscountEntity) _then;

/// Create a copy of LemonSqueezyDiscountEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? storeId = null,Object? name = null,Object? code = null,Object? amount = null,Object? amountType = null,Object? isLimitedToProducts = freezed,Object? isLimitedRedemptions = freezed,Object? maxRedemptions = freezed,Object? startsAt = freezed,Object? expiresAt = freezed,Object? duration = freezed,Object? durationInMonths = freezed,Object? status = freezed,Object? status_formatted = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? testMode = freezed,Object? variants = freezed,}) {
  return _then(_LemonSqueezyDiscountEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,storeId: null == storeId ? _self.storeId : storeId // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,amountType: null == amountType ? _self.amountType : amountType // ignore: cast_nullable_to_non_nullable
as String,isLimitedToProducts: freezed == isLimitedToProducts ? _self.isLimitedToProducts : isLimitedToProducts // ignore: cast_nullable_to_non_nullable
as bool?,isLimitedRedemptions: freezed == isLimitedRedemptions ? _self.isLimitedRedemptions : isLimitedRedemptions // ignore: cast_nullable_to_non_nullable
as bool?,maxRedemptions: freezed == maxRedemptions ? _self.maxRedemptions : maxRedemptions // ignore: cast_nullable_to_non_nullable
as int?,startsAt: freezed == startsAt ? _self.startsAt : startsAt // ignore: cast_nullable_to_non_nullable
as DateTime?,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,duration: freezed == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as String?,durationInMonths: freezed == durationInMonths ? _self.durationInMonths : durationInMonths // ignore: cast_nullable_to_non_nullable
as int?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,status_formatted: freezed == status_formatted ? _self.status_formatted : status_formatted // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,testMode: freezed == testMode ? _self.testMode : testMode // ignore: cast_nullable_to_non_nullable
as bool?,variants: freezed == variants ? _self._variants : variants // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}


}

// dart format on
