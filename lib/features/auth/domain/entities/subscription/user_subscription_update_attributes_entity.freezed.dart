// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_subscription_update_attributes_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserSubscriptionUpdateAttributesEntity {

 bool get cancelled;@JsonKey(includeIfNull: false) String? get variantId;@JsonKey(includeIfNull: false) DateTime? get trialEndsAt;@JsonKey(includeIfNull: false) int? get billingAnchor;@JsonKey(includeIfNull: false) bool? get invoiceImmediately;@JsonKey(includeIfNull: false) bool? get disableProration;@JsonKey(includeIfNull: false) Map<String, dynamic>? get pause;
/// Create a copy of UserSubscriptionUpdateAttributesEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserSubscriptionUpdateAttributesEntityCopyWith<UserSubscriptionUpdateAttributesEntity> get copyWith => _$UserSubscriptionUpdateAttributesEntityCopyWithImpl<UserSubscriptionUpdateAttributesEntity>(this as UserSubscriptionUpdateAttributesEntity, _$identity);

  /// Serializes this UserSubscriptionUpdateAttributesEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserSubscriptionUpdateAttributesEntity&&(identical(other.cancelled, cancelled) || other.cancelled == cancelled)&&(identical(other.variantId, variantId) || other.variantId == variantId)&&(identical(other.trialEndsAt, trialEndsAt) || other.trialEndsAt == trialEndsAt)&&(identical(other.billingAnchor, billingAnchor) || other.billingAnchor == billingAnchor)&&(identical(other.invoiceImmediately, invoiceImmediately) || other.invoiceImmediately == invoiceImmediately)&&(identical(other.disableProration, disableProration) || other.disableProration == disableProration)&&const DeepCollectionEquality().equals(other.pause, pause));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,cancelled,variantId,trialEndsAt,billingAnchor,invoiceImmediately,disableProration,const DeepCollectionEquality().hash(pause));

@override
String toString() {
  return 'UserSubscriptionUpdateAttributesEntity(cancelled: $cancelled, variantId: $variantId, trialEndsAt: $trialEndsAt, billingAnchor: $billingAnchor, invoiceImmediately: $invoiceImmediately, disableProration: $disableProration, pause: $pause)';
}


}

/// @nodoc
abstract mixin class $UserSubscriptionUpdateAttributesEntityCopyWith<$Res>  {
  factory $UserSubscriptionUpdateAttributesEntityCopyWith(UserSubscriptionUpdateAttributesEntity value, $Res Function(UserSubscriptionUpdateAttributesEntity) _then) = _$UserSubscriptionUpdateAttributesEntityCopyWithImpl;
@useResult
$Res call({
 bool cancelled,@JsonKey(includeIfNull: false) String? variantId,@JsonKey(includeIfNull: false) DateTime? trialEndsAt,@JsonKey(includeIfNull: false) int? billingAnchor,@JsonKey(includeIfNull: false) bool? invoiceImmediately,@JsonKey(includeIfNull: false) bool? disableProration,@JsonKey(includeIfNull: false) Map<String, dynamic>? pause
});




}
/// @nodoc
class _$UserSubscriptionUpdateAttributesEntityCopyWithImpl<$Res>
    implements $UserSubscriptionUpdateAttributesEntityCopyWith<$Res> {
  _$UserSubscriptionUpdateAttributesEntityCopyWithImpl(this._self, this._then);

  final UserSubscriptionUpdateAttributesEntity _self;
  final $Res Function(UserSubscriptionUpdateAttributesEntity) _then;

/// Create a copy of UserSubscriptionUpdateAttributesEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? cancelled = null,Object? variantId = freezed,Object? trialEndsAt = freezed,Object? billingAnchor = freezed,Object? invoiceImmediately = freezed,Object? disableProration = freezed,Object? pause = freezed,}) {
  return _then(_self.copyWith(
cancelled: null == cancelled ? _self.cancelled : cancelled // ignore: cast_nullable_to_non_nullable
as bool,variantId: freezed == variantId ? _self.variantId : variantId // ignore: cast_nullable_to_non_nullable
as String?,trialEndsAt: freezed == trialEndsAt ? _self.trialEndsAt : trialEndsAt // ignore: cast_nullable_to_non_nullable
as DateTime?,billingAnchor: freezed == billingAnchor ? _self.billingAnchor : billingAnchor // ignore: cast_nullable_to_non_nullable
as int?,invoiceImmediately: freezed == invoiceImmediately ? _self.invoiceImmediately : invoiceImmediately // ignore: cast_nullable_to_non_nullable
as bool?,disableProration: freezed == disableProration ? _self.disableProration : disableProration // ignore: cast_nullable_to_non_nullable
as bool?,pause: freezed == pause ? _self.pause : pause // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}

}


/// Adds pattern-matching-related methods to [UserSubscriptionUpdateAttributesEntity].
extension UserSubscriptionUpdateAttributesEntityPatterns on UserSubscriptionUpdateAttributesEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserSubscriptionUpdateAttributesEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserSubscriptionUpdateAttributesEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserSubscriptionUpdateAttributesEntity value)  $default,){
final _that = this;
switch (_that) {
case _UserSubscriptionUpdateAttributesEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserSubscriptionUpdateAttributesEntity value)?  $default,){
final _that = this;
switch (_that) {
case _UserSubscriptionUpdateAttributesEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool cancelled, @JsonKey(includeIfNull: false)  String? variantId, @JsonKey(includeIfNull: false)  DateTime? trialEndsAt, @JsonKey(includeIfNull: false)  int? billingAnchor, @JsonKey(includeIfNull: false)  bool? invoiceImmediately, @JsonKey(includeIfNull: false)  bool? disableProration, @JsonKey(includeIfNull: false)  Map<String, dynamic>? pause)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserSubscriptionUpdateAttributesEntity() when $default != null:
return $default(_that.cancelled,_that.variantId,_that.trialEndsAt,_that.billingAnchor,_that.invoiceImmediately,_that.disableProration,_that.pause);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool cancelled, @JsonKey(includeIfNull: false)  String? variantId, @JsonKey(includeIfNull: false)  DateTime? trialEndsAt, @JsonKey(includeIfNull: false)  int? billingAnchor, @JsonKey(includeIfNull: false)  bool? invoiceImmediately, @JsonKey(includeIfNull: false)  bool? disableProration, @JsonKey(includeIfNull: false)  Map<String, dynamic>? pause)  $default,) {final _that = this;
switch (_that) {
case _UserSubscriptionUpdateAttributesEntity():
return $default(_that.cancelled,_that.variantId,_that.trialEndsAt,_that.billingAnchor,_that.invoiceImmediately,_that.disableProration,_that.pause);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool cancelled, @JsonKey(includeIfNull: false)  String? variantId, @JsonKey(includeIfNull: false)  DateTime? trialEndsAt, @JsonKey(includeIfNull: false)  int? billingAnchor, @JsonKey(includeIfNull: false)  bool? invoiceImmediately, @JsonKey(includeIfNull: false)  bool? disableProration, @JsonKey(includeIfNull: false)  Map<String, dynamic>? pause)?  $default,) {final _that = this;
switch (_that) {
case _UserSubscriptionUpdateAttributesEntity() when $default != null:
return $default(_that.cancelled,_that.variantId,_that.trialEndsAt,_that.billingAnchor,_that.invoiceImmediately,_that.disableProration,_that.pause);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _UserSubscriptionUpdateAttributesEntity extends UserSubscriptionUpdateAttributesEntity {
  const _UserSubscriptionUpdateAttributesEntity({required this.cancelled, @JsonKey(includeIfNull: false) this.variantId, @JsonKey(includeIfNull: false) this.trialEndsAt, @JsonKey(includeIfNull: false) this.billingAnchor, @JsonKey(includeIfNull: false) this.invoiceImmediately, @JsonKey(includeIfNull: false) this.disableProration, @JsonKey(includeIfNull: false) final  Map<String, dynamic>? pause}): _pause = pause,super._();
  factory _UserSubscriptionUpdateAttributesEntity.fromJson(Map<String, dynamic> json) => _$UserSubscriptionUpdateAttributesEntityFromJson(json);

@override final  bool cancelled;
@override@JsonKey(includeIfNull: false) final  String? variantId;
@override@JsonKey(includeIfNull: false) final  DateTime? trialEndsAt;
@override@JsonKey(includeIfNull: false) final  int? billingAnchor;
@override@JsonKey(includeIfNull: false) final  bool? invoiceImmediately;
@override@JsonKey(includeIfNull: false) final  bool? disableProration;
 final  Map<String, dynamic>? _pause;
@override@JsonKey(includeIfNull: false) Map<String, dynamic>? get pause {
  final value = _pause;
  if (value == null) return null;
  if (_pause is EqualUnmodifiableMapView) return _pause;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of UserSubscriptionUpdateAttributesEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserSubscriptionUpdateAttributesEntityCopyWith<_UserSubscriptionUpdateAttributesEntity> get copyWith => __$UserSubscriptionUpdateAttributesEntityCopyWithImpl<_UserSubscriptionUpdateAttributesEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserSubscriptionUpdateAttributesEntityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserSubscriptionUpdateAttributesEntity&&(identical(other.cancelled, cancelled) || other.cancelled == cancelled)&&(identical(other.variantId, variantId) || other.variantId == variantId)&&(identical(other.trialEndsAt, trialEndsAt) || other.trialEndsAt == trialEndsAt)&&(identical(other.billingAnchor, billingAnchor) || other.billingAnchor == billingAnchor)&&(identical(other.invoiceImmediately, invoiceImmediately) || other.invoiceImmediately == invoiceImmediately)&&(identical(other.disableProration, disableProration) || other.disableProration == disableProration)&&const DeepCollectionEquality().equals(other._pause, _pause));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,cancelled,variantId,trialEndsAt,billingAnchor,invoiceImmediately,disableProration,const DeepCollectionEquality().hash(_pause));

@override
String toString() {
  return 'UserSubscriptionUpdateAttributesEntity(cancelled: $cancelled, variantId: $variantId, trialEndsAt: $trialEndsAt, billingAnchor: $billingAnchor, invoiceImmediately: $invoiceImmediately, disableProration: $disableProration, pause: $pause)';
}


}

/// @nodoc
abstract mixin class _$UserSubscriptionUpdateAttributesEntityCopyWith<$Res> implements $UserSubscriptionUpdateAttributesEntityCopyWith<$Res> {
  factory _$UserSubscriptionUpdateAttributesEntityCopyWith(_UserSubscriptionUpdateAttributesEntity value, $Res Function(_UserSubscriptionUpdateAttributesEntity) _then) = __$UserSubscriptionUpdateAttributesEntityCopyWithImpl;
@override @useResult
$Res call({
 bool cancelled,@JsonKey(includeIfNull: false) String? variantId,@JsonKey(includeIfNull: false) DateTime? trialEndsAt,@JsonKey(includeIfNull: false) int? billingAnchor,@JsonKey(includeIfNull: false) bool? invoiceImmediately,@JsonKey(includeIfNull: false) bool? disableProration,@JsonKey(includeIfNull: false) Map<String, dynamic>? pause
});




}
/// @nodoc
class __$UserSubscriptionUpdateAttributesEntityCopyWithImpl<$Res>
    implements _$UserSubscriptionUpdateAttributesEntityCopyWith<$Res> {
  __$UserSubscriptionUpdateAttributesEntityCopyWithImpl(this._self, this._then);

  final _UserSubscriptionUpdateAttributesEntity _self;
  final $Res Function(_UserSubscriptionUpdateAttributesEntity) _then;

/// Create a copy of UserSubscriptionUpdateAttributesEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? cancelled = null,Object? variantId = freezed,Object? trialEndsAt = freezed,Object? billingAnchor = freezed,Object? invoiceImmediately = freezed,Object? disableProration = freezed,Object? pause = freezed,}) {
  return _then(_UserSubscriptionUpdateAttributesEntity(
cancelled: null == cancelled ? _self.cancelled : cancelled // ignore: cast_nullable_to_non_nullable
as bool,variantId: freezed == variantId ? _self.variantId : variantId // ignore: cast_nullable_to_non_nullable
as String?,trialEndsAt: freezed == trialEndsAt ? _self.trialEndsAt : trialEndsAt // ignore: cast_nullable_to_non_nullable
as DateTime?,billingAnchor: freezed == billingAnchor ? _self.billingAnchor : billingAnchor // ignore: cast_nullable_to_non_nullable
as int?,invoiceImmediately: freezed == invoiceImmediately ? _self.invoiceImmediately : invoiceImmediately // ignore: cast_nullable_to_non_nullable
as bool?,disableProration: freezed == disableProration ? _self.disableProration : disableProration // ignore: cast_nullable_to_non_nullable
as bool?,pause: freezed == pause ? _self._pause : pause // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}


}

// dart format on
