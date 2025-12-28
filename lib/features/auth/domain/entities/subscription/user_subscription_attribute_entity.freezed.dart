// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_subscription_attribute_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserSubscriptionAttributeEntity {

 int get storeId; int get customerId; SubscriptionStatus get status;@JsonKey(includeIfNull: false) int? get orderId;@JsonKey(includeIfNull: false) int? get orderItemId;@JsonKey(includeIfNull: false) int? get productId;@JsonKey(includeIfNull: false) int? get variantId;@JsonKey(includeIfNull: false) String? get productName;@JsonKey(includeIfNull: false) String? get variantName;@JsonKey(includeIfNull: false) String? get userName;@JsonKey(includeIfNull: false) String? get userEmail;@JsonKey(includeIfNull: false) String? get statusFormatted;@JsonKey(includeIfNull: false) String? get cardBrand;@JsonKey(includeIfNull: false) String? get cardLastFour;@JsonKey(includeIfNull: false) Map<String, dynamic>? get pause;@JsonKey(includeIfNull: false) bool? get cancelled;@JsonKey(includeIfNull: false) DateTime? get trialEndsAt;@JsonKey(includeIfNull: false) int? get billingAnchor;@JsonKey(includeIfNull: false) Map<String, dynamic>? get firstSubscriptionItem;@JsonKey(includeIfNull: false) Map<String, dynamic>? get urls;@JsonKey(includeIfNull: false) DateTime? get renewsAt;@JsonKey(includeIfNull: false) DateTime? get endsAt;@JsonKey(includeIfNull: false) DateTime? get createdAt;@JsonKey(includeIfNull: false) DateTime? get updatedAt;@JsonKey(includeIfNull: false) bool? get testMode;
/// Create a copy of UserSubscriptionAttributeEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserSubscriptionAttributeEntityCopyWith<UserSubscriptionAttributeEntity> get copyWith => _$UserSubscriptionAttributeEntityCopyWithImpl<UserSubscriptionAttributeEntity>(this as UserSubscriptionAttributeEntity, _$identity);

  /// Serializes this UserSubscriptionAttributeEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserSubscriptionAttributeEntity&&(identical(other.storeId, storeId) || other.storeId == storeId)&&(identical(other.customerId, customerId) || other.customerId == customerId)&&(identical(other.status, status) || other.status == status)&&(identical(other.orderId, orderId) || other.orderId == orderId)&&(identical(other.orderItemId, orderItemId) || other.orderItemId == orderItemId)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.variantId, variantId) || other.variantId == variantId)&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.variantName, variantName) || other.variantName == variantName)&&(identical(other.userName, userName) || other.userName == userName)&&(identical(other.userEmail, userEmail) || other.userEmail == userEmail)&&(identical(other.statusFormatted, statusFormatted) || other.statusFormatted == statusFormatted)&&(identical(other.cardBrand, cardBrand) || other.cardBrand == cardBrand)&&(identical(other.cardLastFour, cardLastFour) || other.cardLastFour == cardLastFour)&&const DeepCollectionEquality().equals(other.pause, pause)&&(identical(other.cancelled, cancelled) || other.cancelled == cancelled)&&(identical(other.trialEndsAt, trialEndsAt) || other.trialEndsAt == trialEndsAt)&&(identical(other.billingAnchor, billingAnchor) || other.billingAnchor == billingAnchor)&&const DeepCollectionEquality().equals(other.firstSubscriptionItem, firstSubscriptionItem)&&const DeepCollectionEquality().equals(other.urls, urls)&&(identical(other.renewsAt, renewsAt) || other.renewsAt == renewsAt)&&(identical(other.endsAt, endsAt) || other.endsAt == endsAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.testMode, testMode) || other.testMode == testMode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,storeId,customerId,status,orderId,orderItemId,productId,variantId,productName,variantName,userName,userEmail,statusFormatted,cardBrand,cardLastFour,const DeepCollectionEquality().hash(pause),cancelled,trialEndsAt,billingAnchor,const DeepCollectionEquality().hash(firstSubscriptionItem),const DeepCollectionEquality().hash(urls),renewsAt,endsAt,createdAt,updatedAt,testMode]);

@override
String toString() {
  return 'UserSubscriptionAttributeEntity(storeId: $storeId, customerId: $customerId, status: $status, orderId: $orderId, orderItemId: $orderItemId, productId: $productId, variantId: $variantId, productName: $productName, variantName: $variantName, userName: $userName, userEmail: $userEmail, statusFormatted: $statusFormatted, cardBrand: $cardBrand, cardLastFour: $cardLastFour, pause: $pause, cancelled: $cancelled, trialEndsAt: $trialEndsAt, billingAnchor: $billingAnchor, firstSubscriptionItem: $firstSubscriptionItem, urls: $urls, renewsAt: $renewsAt, endsAt: $endsAt, createdAt: $createdAt, updatedAt: $updatedAt, testMode: $testMode)';
}


}

/// @nodoc
abstract mixin class $UserSubscriptionAttributeEntityCopyWith<$Res>  {
  factory $UserSubscriptionAttributeEntityCopyWith(UserSubscriptionAttributeEntity value, $Res Function(UserSubscriptionAttributeEntity) _then) = _$UserSubscriptionAttributeEntityCopyWithImpl;
@useResult
$Res call({
 int storeId, int customerId, SubscriptionStatus status,@JsonKey(includeIfNull: false) int? orderId,@JsonKey(includeIfNull: false) int? orderItemId,@JsonKey(includeIfNull: false) int? productId,@JsonKey(includeIfNull: false) int? variantId,@JsonKey(includeIfNull: false) String? productName,@JsonKey(includeIfNull: false) String? variantName,@JsonKey(includeIfNull: false) String? userName,@JsonKey(includeIfNull: false) String? userEmail,@JsonKey(includeIfNull: false) String? statusFormatted,@JsonKey(includeIfNull: false) String? cardBrand,@JsonKey(includeIfNull: false) String? cardLastFour,@JsonKey(includeIfNull: false) Map<String, dynamic>? pause,@JsonKey(includeIfNull: false) bool? cancelled,@JsonKey(includeIfNull: false) DateTime? trialEndsAt,@JsonKey(includeIfNull: false) int? billingAnchor,@JsonKey(includeIfNull: false) Map<String, dynamic>? firstSubscriptionItem,@JsonKey(includeIfNull: false) Map<String, dynamic>? urls,@JsonKey(includeIfNull: false) DateTime? renewsAt,@JsonKey(includeIfNull: false) DateTime? endsAt,@JsonKey(includeIfNull: false) DateTime? createdAt,@JsonKey(includeIfNull: false) DateTime? updatedAt,@JsonKey(includeIfNull: false) bool? testMode
});




}
/// @nodoc
class _$UserSubscriptionAttributeEntityCopyWithImpl<$Res>
    implements $UserSubscriptionAttributeEntityCopyWith<$Res> {
  _$UserSubscriptionAttributeEntityCopyWithImpl(this._self, this._then);

  final UserSubscriptionAttributeEntity _self;
  final $Res Function(UserSubscriptionAttributeEntity) _then;

/// Create a copy of UserSubscriptionAttributeEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? storeId = null,Object? customerId = null,Object? status = null,Object? orderId = freezed,Object? orderItemId = freezed,Object? productId = freezed,Object? variantId = freezed,Object? productName = freezed,Object? variantName = freezed,Object? userName = freezed,Object? userEmail = freezed,Object? statusFormatted = freezed,Object? cardBrand = freezed,Object? cardLastFour = freezed,Object? pause = freezed,Object? cancelled = freezed,Object? trialEndsAt = freezed,Object? billingAnchor = freezed,Object? firstSubscriptionItem = freezed,Object? urls = freezed,Object? renewsAt = freezed,Object? endsAt = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? testMode = freezed,}) {
  return _then(_self.copyWith(
storeId: null == storeId ? _self.storeId : storeId // ignore: cast_nullable_to_non_nullable
as int,customerId: null == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as SubscriptionStatus,orderId: freezed == orderId ? _self.orderId : orderId // ignore: cast_nullable_to_non_nullable
as int?,orderItemId: freezed == orderItemId ? _self.orderItemId : orderItemId // ignore: cast_nullable_to_non_nullable
as int?,productId: freezed == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int?,variantId: freezed == variantId ? _self.variantId : variantId // ignore: cast_nullable_to_non_nullable
as int?,productName: freezed == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String?,variantName: freezed == variantName ? _self.variantName : variantName // ignore: cast_nullable_to_non_nullable
as String?,userName: freezed == userName ? _self.userName : userName // ignore: cast_nullable_to_non_nullable
as String?,userEmail: freezed == userEmail ? _self.userEmail : userEmail // ignore: cast_nullable_to_non_nullable
as String?,statusFormatted: freezed == statusFormatted ? _self.statusFormatted : statusFormatted // ignore: cast_nullable_to_non_nullable
as String?,cardBrand: freezed == cardBrand ? _self.cardBrand : cardBrand // ignore: cast_nullable_to_non_nullable
as String?,cardLastFour: freezed == cardLastFour ? _self.cardLastFour : cardLastFour // ignore: cast_nullable_to_non_nullable
as String?,pause: freezed == pause ? _self.pause : pause // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,cancelled: freezed == cancelled ? _self.cancelled : cancelled // ignore: cast_nullable_to_non_nullable
as bool?,trialEndsAt: freezed == trialEndsAt ? _self.trialEndsAt : trialEndsAt // ignore: cast_nullable_to_non_nullable
as DateTime?,billingAnchor: freezed == billingAnchor ? _self.billingAnchor : billingAnchor // ignore: cast_nullable_to_non_nullable
as int?,firstSubscriptionItem: freezed == firstSubscriptionItem ? _self.firstSubscriptionItem : firstSubscriptionItem // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,urls: freezed == urls ? _self.urls : urls // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,renewsAt: freezed == renewsAt ? _self.renewsAt : renewsAt // ignore: cast_nullable_to_non_nullable
as DateTime?,endsAt: freezed == endsAt ? _self.endsAt : endsAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,testMode: freezed == testMode ? _self.testMode : testMode // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}

}


/// Adds pattern-matching-related methods to [UserSubscriptionAttributeEntity].
extension UserSubscriptionAttributeEntityPatterns on UserSubscriptionAttributeEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserSubscriptionAttributeEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserSubscriptionAttributeEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserSubscriptionAttributeEntity value)  $default,){
final _that = this;
switch (_that) {
case _UserSubscriptionAttributeEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserSubscriptionAttributeEntity value)?  $default,){
final _that = this;
switch (_that) {
case _UserSubscriptionAttributeEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int storeId,  int customerId,  SubscriptionStatus status, @JsonKey(includeIfNull: false)  int? orderId, @JsonKey(includeIfNull: false)  int? orderItemId, @JsonKey(includeIfNull: false)  int? productId, @JsonKey(includeIfNull: false)  int? variantId, @JsonKey(includeIfNull: false)  String? productName, @JsonKey(includeIfNull: false)  String? variantName, @JsonKey(includeIfNull: false)  String? userName, @JsonKey(includeIfNull: false)  String? userEmail, @JsonKey(includeIfNull: false)  String? statusFormatted, @JsonKey(includeIfNull: false)  String? cardBrand, @JsonKey(includeIfNull: false)  String? cardLastFour, @JsonKey(includeIfNull: false)  Map<String, dynamic>? pause, @JsonKey(includeIfNull: false)  bool? cancelled, @JsonKey(includeIfNull: false)  DateTime? trialEndsAt, @JsonKey(includeIfNull: false)  int? billingAnchor, @JsonKey(includeIfNull: false)  Map<String, dynamic>? firstSubscriptionItem, @JsonKey(includeIfNull: false)  Map<String, dynamic>? urls, @JsonKey(includeIfNull: false)  DateTime? renewsAt, @JsonKey(includeIfNull: false)  DateTime? endsAt, @JsonKey(includeIfNull: false)  DateTime? createdAt, @JsonKey(includeIfNull: false)  DateTime? updatedAt, @JsonKey(includeIfNull: false)  bool? testMode)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserSubscriptionAttributeEntity() when $default != null:
return $default(_that.storeId,_that.customerId,_that.status,_that.orderId,_that.orderItemId,_that.productId,_that.variantId,_that.productName,_that.variantName,_that.userName,_that.userEmail,_that.statusFormatted,_that.cardBrand,_that.cardLastFour,_that.pause,_that.cancelled,_that.trialEndsAt,_that.billingAnchor,_that.firstSubscriptionItem,_that.urls,_that.renewsAt,_that.endsAt,_that.createdAt,_that.updatedAt,_that.testMode);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int storeId,  int customerId,  SubscriptionStatus status, @JsonKey(includeIfNull: false)  int? orderId, @JsonKey(includeIfNull: false)  int? orderItemId, @JsonKey(includeIfNull: false)  int? productId, @JsonKey(includeIfNull: false)  int? variantId, @JsonKey(includeIfNull: false)  String? productName, @JsonKey(includeIfNull: false)  String? variantName, @JsonKey(includeIfNull: false)  String? userName, @JsonKey(includeIfNull: false)  String? userEmail, @JsonKey(includeIfNull: false)  String? statusFormatted, @JsonKey(includeIfNull: false)  String? cardBrand, @JsonKey(includeIfNull: false)  String? cardLastFour, @JsonKey(includeIfNull: false)  Map<String, dynamic>? pause, @JsonKey(includeIfNull: false)  bool? cancelled, @JsonKey(includeIfNull: false)  DateTime? trialEndsAt, @JsonKey(includeIfNull: false)  int? billingAnchor, @JsonKey(includeIfNull: false)  Map<String, dynamic>? firstSubscriptionItem, @JsonKey(includeIfNull: false)  Map<String, dynamic>? urls, @JsonKey(includeIfNull: false)  DateTime? renewsAt, @JsonKey(includeIfNull: false)  DateTime? endsAt, @JsonKey(includeIfNull: false)  DateTime? createdAt, @JsonKey(includeIfNull: false)  DateTime? updatedAt, @JsonKey(includeIfNull: false)  bool? testMode)  $default,) {final _that = this;
switch (_that) {
case _UserSubscriptionAttributeEntity():
return $default(_that.storeId,_that.customerId,_that.status,_that.orderId,_that.orderItemId,_that.productId,_that.variantId,_that.productName,_that.variantName,_that.userName,_that.userEmail,_that.statusFormatted,_that.cardBrand,_that.cardLastFour,_that.pause,_that.cancelled,_that.trialEndsAt,_that.billingAnchor,_that.firstSubscriptionItem,_that.urls,_that.renewsAt,_that.endsAt,_that.createdAt,_that.updatedAt,_that.testMode);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int storeId,  int customerId,  SubscriptionStatus status, @JsonKey(includeIfNull: false)  int? orderId, @JsonKey(includeIfNull: false)  int? orderItemId, @JsonKey(includeIfNull: false)  int? productId, @JsonKey(includeIfNull: false)  int? variantId, @JsonKey(includeIfNull: false)  String? productName, @JsonKey(includeIfNull: false)  String? variantName, @JsonKey(includeIfNull: false)  String? userName, @JsonKey(includeIfNull: false)  String? userEmail, @JsonKey(includeIfNull: false)  String? statusFormatted, @JsonKey(includeIfNull: false)  String? cardBrand, @JsonKey(includeIfNull: false)  String? cardLastFour, @JsonKey(includeIfNull: false)  Map<String, dynamic>? pause, @JsonKey(includeIfNull: false)  bool? cancelled, @JsonKey(includeIfNull: false)  DateTime? trialEndsAt, @JsonKey(includeIfNull: false)  int? billingAnchor, @JsonKey(includeIfNull: false)  Map<String, dynamic>? firstSubscriptionItem, @JsonKey(includeIfNull: false)  Map<String, dynamic>? urls, @JsonKey(includeIfNull: false)  DateTime? renewsAt, @JsonKey(includeIfNull: false)  DateTime? endsAt, @JsonKey(includeIfNull: false)  DateTime? createdAt, @JsonKey(includeIfNull: false)  DateTime? updatedAt, @JsonKey(includeIfNull: false)  bool? testMode)?  $default,) {final _that = this;
switch (_that) {
case _UserSubscriptionAttributeEntity() when $default != null:
return $default(_that.storeId,_that.customerId,_that.status,_that.orderId,_that.orderItemId,_that.productId,_that.variantId,_that.productName,_that.variantName,_that.userName,_that.userEmail,_that.statusFormatted,_that.cardBrand,_that.cardLastFour,_that.pause,_that.cancelled,_that.trialEndsAt,_that.billingAnchor,_that.firstSubscriptionItem,_that.urls,_that.renewsAt,_that.endsAt,_that.createdAt,_that.updatedAt,_that.testMode);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _UserSubscriptionAttributeEntity extends UserSubscriptionAttributeEntity {
  const _UserSubscriptionAttributeEntity({required this.storeId, required this.customerId, required this.status, @JsonKey(includeIfNull: false) this.orderId, @JsonKey(includeIfNull: false) this.orderItemId, @JsonKey(includeIfNull: false) this.productId, @JsonKey(includeIfNull: false) this.variantId, @JsonKey(includeIfNull: false) this.productName, @JsonKey(includeIfNull: false) this.variantName, @JsonKey(includeIfNull: false) this.userName, @JsonKey(includeIfNull: false) this.userEmail, @JsonKey(includeIfNull: false) this.statusFormatted, @JsonKey(includeIfNull: false) this.cardBrand, @JsonKey(includeIfNull: false) this.cardLastFour, @JsonKey(includeIfNull: false) final  Map<String, dynamic>? pause, @JsonKey(includeIfNull: false) this.cancelled, @JsonKey(includeIfNull: false) this.trialEndsAt, @JsonKey(includeIfNull: false) this.billingAnchor, @JsonKey(includeIfNull: false) final  Map<String, dynamic>? firstSubscriptionItem, @JsonKey(includeIfNull: false) final  Map<String, dynamic>? urls, @JsonKey(includeIfNull: false) this.renewsAt, @JsonKey(includeIfNull: false) this.endsAt, @JsonKey(includeIfNull: false) this.createdAt, @JsonKey(includeIfNull: false) this.updatedAt, @JsonKey(includeIfNull: false) this.testMode}): _pause = pause,_firstSubscriptionItem = firstSubscriptionItem,_urls = urls,super._();
  factory _UserSubscriptionAttributeEntity.fromJson(Map<String, dynamic> json) => _$UserSubscriptionAttributeEntityFromJson(json);

@override final  int storeId;
@override final  int customerId;
@override final  SubscriptionStatus status;
@override@JsonKey(includeIfNull: false) final  int? orderId;
@override@JsonKey(includeIfNull: false) final  int? orderItemId;
@override@JsonKey(includeIfNull: false) final  int? productId;
@override@JsonKey(includeIfNull: false) final  int? variantId;
@override@JsonKey(includeIfNull: false) final  String? productName;
@override@JsonKey(includeIfNull: false) final  String? variantName;
@override@JsonKey(includeIfNull: false) final  String? userName;
@override@JsonKey(includeIfNull: false) final  String? userEmail;
@override@JsonKey(includeIfNull: false) final  String? statusFormatted;
@override@JsonKey(includeIfNull: false) final  String? cardBrand;
@override@JsonKey(includeIfNull: false) final  String? cardLastFour;
 final  Map<String, dynamic>? _pause;
@override@JsonKey(includeIfNull: false) Map<String, dynamic>? get pause {
  final value = _pause;
  if (value == null) return null;
  if (_pause is EqualUnmodifiableMapView) return _pause;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override@JsonKey(includeIfNull: false) final  bool? cancelled;
@override@JsonKey(includeIfNull: false) final  DateTime? trialEndsAt;
@override@JsonKey(includeIfNull: false) final  int? billingAnchor;
 final  Map<String, dynamic>? _firstSubscriptionItem;
@override@JsonKey(includeIfNull: false) Map<String, dynamic>? get firstSubscriptionItem {
  final value = _firstSubscriptionItem;
  if (value == null) return null;
  if (_firstSubscriptionItem is EqualUnmodifiableMapView) return _firstSubscriptionItem;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  Map<String, dynamic>? _urls;
@override@JsonKey(includeIfNull: false) Map<String, dynamic>? get urls {
  final value = _urls;
  if (value == null) return null;
  if (_urls is EqualUnmodifiableMapView) return _urls;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override@JsonKey(includeIfNull: false) final  DateTime? renewsAt;
@override@JsonKey(includeIfNull: false) final  DateTime? endsAt;
@override@JsonKey(includeIfNull: false) final  DateTime? createdAt;
@override@JsonKey(includeIfNull: false) final  DateTime? updatedAt;
@override@JsonKey(includeIfNull: false) final  bool? testMode;

/// Create a copy of UserSubscriptionAttributeEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserSubscriptionAttributeEntityCopyWith<_UserSubscriptionAttributeEntity> get copyWith => __$UserSubscriptionAttributeEntityCopyWithImpl<_UserSubscriptionAttributeEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserSubscriptionAttributeEntityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserSubscriptionAttributeEntity&&(identical(other.storeId, storeId) || other.storeId == storeId)&&(identical(other.customerId, customerId) || other.customerId == customerId)&&(identical(other.status, status) || other.status == status)&&(identical(other.orderId, orderId) || other.orderId == orderId)&&(identical(other.orderItemId, orderItemId) || other.orderItemId == orderItemId)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.variantId, variantId) || other.variantId == variantId)&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.variantName, variantName) || other.variantName == variantName)&&(identical(other.userName, userName) || other.userName == userName)&&(identical(other.userEmail, userEmail) || other.userEmail == userEmail)&&(identical(other.statusFormatted, statusFormatted) || other.statusFormatted == statusFormatted)&&(identical(other.cardBrand, cardBrand) || other.cardBrand == cardBrand)&&(identical(other.cardLastFour, cardLastFour) || other.cardLastFour == cardLastFour)&&const DeepCollectionEquality().equals(other._pause, _pause)&&(identical(other.cancelled, cancelled) || other.cancelled == cancelled)&&(identical(other.trialEndsAt, trialEndsAt) || other.trialEndsAt == trialEndsAt)&&(identical(other.billingAnchor, billingAnchor) || other.billingAnchor == billingAnchor)&&const DeepCollectionEquality().equals(other._firstSubscriptionItem, _firstSubscriptionItem)&&const DeepCollectionEquality().equals(other._urls, _urls)&&(identical(other.renewsAt, renewsAt) || other.renewsAt == renewsAt)&&(identical(other.endsAt, endsAt) || other.endsAt == endsAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.testMode, testMode) || other.testMode == testMode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,storeId,customerId,status,orderId,orderItemId,productId,variantId,productName,variantName,userName,userEmail,statusFormatted,cardBrand,cardLastFour,const DeepCollectionEquality().hash(_pause),cancelled,trialEndsAt,billingAnchor,const DeepCollectionEquality().hash(_firstSubscriptionItem),const DeepCollectionEquality().hash(_urls),renewsAt,endsAt,createdAt,updatedAt,testMode]);

@override
String toString() {
  return 'UserSubscriptionAttributeEntity(storeId: $storeId, customerId: $customerId, status: $status, orderId: $orderId, orderItemId: $orderItemId, productId: $productId, variantId: $variantId, productName: $productName, variantName: $variantName, userName: $userName, userEmail: $userEmail, statusFormatted: $statusFormatted, cardBrand: $cardBrand, cardLastFour: $cardLastFour, pause: $pause, cancelled: $cancelled, trialEndsAt: $trialEndsAt, billingAnchor: $billingAnchor, firstSubscriptionItem: $firstSubscriptionItem, urls: $urls, renewsAt: $renewsAt, endsAt: $endsAt, createdAt: $createdAt, updatedAt: $updatedAt, testMode: $testMode)';
}


}

/// @nodoc
abstract mixin class _$UserSubscriptionAttributeEntityCopyWith<$Res> implements $UserSubscriptionAttributeEntityCopyWith<$Res> {
  factory _$UserSubscriptionAttributeEntityCopyWith(_UserSubscriptionAttributeEntity value, $Res Function(_UserSubscriptionAttributeEntity) _then) = __$UserSubscriptionAttributeEntityCopyWithImpl;
@override @useResult
$Res call({
 int storeId, int customerId, SubscriptionStatus status,@JsonKey(includeIfNull: false) int? orderId,@JsonKey(includeIfNull: false) int? orderItemId,@JsonKey(includeIfNull: false) int? productId,@JsonKey(includeIfNull: false) int? variantId,@JsonKey(includeIfNull: false) String? productName,@JsonKey(includeIfNull: false) String? variantName,@JsonKey(includeIfNull: false) String? userName,@JsonKey(includeIfNull: false) String? userEmail,@JsonKey(includeIfNull: false) String? statusFormatted,@JsonKey(includeIfNull: false) String? cardBrand,@JsonKey(includeIfNull: false) String? cardLastFour,@JsonKey(includeIfNull: false) Map<String, dynamic>? pause,@JsonKey(includeIfNull: false) bool? cancelled,@JsonKey(includeIfNull: false) DateTime? trialEndsAt,@JsonKey(includeIfNull: false) int? billingAnchor,@JsonKey(includeIfNull: false) Map<String, dynamic>? firstSubscriptionItem,@JsonKey(includeIfNull: false) Map<String, dynamic>? urls,@JsonKey(includeIfNull: false) DateTime? renewsAt,@JsonKey(includeIfNull: false) DateTime? endsAt,@JsonKey(includeIfNull: false) DateTime? createdAt,@JsonKey(includeIfNull: false) DateTime? updatedAt,@JsonKey(includeIfNull: false) bool? testMode
});




}
/// @nodoc
class __$UserSubscriptionAttributeEntityCopyWithImpl<$Res>
    implements _$UserSubscriptionAttributeEntityCopyWith<$Res> {
  __$UserSubscriptionAttributeEntityCopyWithImpl(this._self, this._then);

  final _UserSubscriptionAttributeEntity _self;
  final $Res Function(_UserSubscriptionAttributeEntity) _then;

/// Create a copy of UserSubscriptionAttributeEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? storeId = null,Object? customerId = null,Object? status = null,Object? orderId = freezed,Object? orderItemId = freezed,Object? productId = freezed,Object? variantId = freezed,Object? productName = freezed,Object? variantName = freezed,Object? userName = freezed,Object? userEmail = freezed,Object? statusFormatted = freezed,Object? cardBrand = freezed,Object? cardLastFour = freezed,Object? pause = freezed,Object? cancelled = freezed,Object? trialEndsAt = freezed,Object? billingAnchor = freezed,Object? firstSubscriptionItem = freezed,Object? urls = freezed,Object? renewsAt = freezed,Object? endsAt = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? testMode = freezed,}) {
  return _then(_UserSubscriptionAttributeEntity(
storeId: null == storeId ? _self.storeId : storeId // ignore: cast_nullable_to_non_nullable
as int,customerId: null == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as SubscriptionStatus,orderId: freezed == orderId ? _self.orderId : orderId // ignore: cast_nullable_to_non_nullable
as int?,orderItemId: freezed == orderItemId ? _self.orderItemId : orderItemId // ignore: cast_nullable_to_non_nullable
as int?,productId: freezed == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int?,variantId: freezed == variantId ? _self.variantId : variantId // ignore: cast_nullable_to_non_nullable
as int?,productName: freezed == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String?,variantName: freezed == variantName ? _self.variantName : variantName // ignore: cast_nullable_to_non_nullable
as String?,userName: freezed == userName ? _self.userName : userName // ignore: cast_nullable_to_non_nullable
as String?,userEmail: freezed == userEmail ? _self.userEmail : userEmail // ignore: cast_nullable_to_non_nullable
as String?,statusFormatted: freezed == statusFormatted ? _self.statusFormatted : statusFormatted // ignore: cast_nullable_to_non_nullable
as String?,cardBrand: freezed == cardBrand ? _self.cardBrand : cardBrand // ignore: cast_nullable_to_non_nullable
as String?,cardLastFour: freezed == cardLastFour ? _self.cardLastFour : cardLastFour // ignore: cast_nullable_to_non_nullable
as String?,pause: freezed == pause ? _self._pause : pause // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,cancelled: freezed == cancelled ? _self.cancelled : cancelled // ignore: cast_nullable_to_non_nullable
as bool?,trialEndsAt: freezed == trialEndsAt ? _self.trialEndsAt : trialEndsAt // ignore: cast_nullable_to_non_nullable
as DateTime?,billingAnchor: freezed == billingAnchor ? _self.billingAnchor : billingAnchor // ignore: cast_nullable_to_non_nullable
as int?,firstSubscriptionItem: freezed == firstSubscriptionItem ? _self._firstSubscriptionItem : firstSubscriptionItem // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,urls: freezed == urls ? _self._urls : urls // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,renewsAt: freezed == renewsAt ? _self.renewsAt : renewsAt // ignore: cast_nullable_to_non_nullable
as DateTime?,endsAt: freezed == endsAt ? _self.endsAt : endsAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,testMode: freezed == testMode ? _self.testMode : testMode // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}


}

// dart format on
