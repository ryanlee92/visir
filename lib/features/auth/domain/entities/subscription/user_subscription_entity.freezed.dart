// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_subscription_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserSubscriptionEntity {

 String get id; String get type; UserSubscriptionAttributeEntity? get attributes;@JsonKey(includeIfNull: false) Map<String, dynamic>? get relationships;
/// Create a copy of UserSubscriptionEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserSubscriptionEntityCopyWith<UserSubscriptionEntity> get copyWith => _$UserSubscriptionEntityCopyWithImpl<UserSubscriptionEntity>(this as UserSubscriptionEntity, _$identity);

  /// Serializes this UserSubscriptionEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserSubscriptionEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.attributes, attributes) || other.attributes == attributes)&&const DeepCollectionEquality().equals(other.relationships, relationships));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,attributes,const DeepCollectionEquality().hash(relationships));

@override
String toString() {
  return 'UserSubscriptionEntity(id: $id, type: $type, attributes: $attributes, relationships: $relationships)';
}


}

/// @nodoc
abstract mixin class $UserSubscriptionEntityCopyWith<$Res>  {
  factory $UserSubscriptionEntityCopyWith(UserSubscriptionEntity value, $Res Function(UserSubscriptionEntity) _then) = _$UserSubscriptionEntityCopyWithImpl;
@useResult
$Res call({
 String id, String type, UserSubscriptionAttributeEntity? attributes,@JsonKey(includeIfNull: false) Map<String, dynamic>? relationships
});


$UserSubscriptionAttributeEntityCopyWith<$Res>? get attributes;

}
/// @nodoc
class _$UserSubscriptionEntityCopyWithImpl<$Res>
    implements $UserSubscriptionEntityCopyWith<$Res> {
  _$UserSubscriptionEntityCopyWithImpl(this._self, this._then);

  final UserSubscriptionEntity _self;
  final $Res Function(UserSubscriptionEntity) _then;

/// Create a copy of UserSubscriptionEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,Object? attributes = freezed,Object? relationships = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,attributes: freezed == attributes ? _self.attributes : attributes // ignore: cast_nullable_to_non_nullable
as UserSubscriptionAttributeEntity?,relationships: freezed == relationships ? _self.relationships : relationships // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}
/// Create a copy of UserSubscriptionEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserSubscriptionAttributeEntityCopyWith<$Res>? get attributes {
    if (_self.attributes == null) {
    return null;
  }

  return $UserSubscriptionAttributeEntityCopyWith<$Res>(_self.attributes!, (value) {
    return _then(_self.copyWith(attributes: value));
  });
}
}


/// Adds pattern-matching-related methods to [UserSubscriptionEntity].
extension UserSubscriptionEntityPatterns on UserSubscriptionEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserSubscriptionEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserSubscriptionEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserSubscriptionEntity value)  $default,){
final _that = this;
switch (_that) {
case _UserSubscriptionEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserSubscriptionEntity value)?  $default,){
final _that = this;
switch (_that) {
case _UserSubscriptionEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String type,  UserSubscriptionAttributeEntity? attributes, @JsonKey(includeIfNull: false)  Map<String, dynamic>? relationships)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserSubscriptionEntity() when $default != null:
return $default(_that.id,_that.type,_that.attributes,_that.relationships);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String type,  UserSubscriptionAttributeEntity? attributes, @JsonKey(includeIfNull: false)  Map<String, dynamic>? relationships)  $default,) {final _that = this;
switch (_that) {
case _UserSubscriptionEntity():
return $default(_that.id,_that.type,_that.attributes,_that.relationships);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String type,  UserSubscriptionAttributeEntity? attributes, @JsonKey(includeIfNull: false)  Map<String, dynamic>? relationships)?  $default,) {final _that = this;
switch (_that) {
case _UserSubscriptionEntity() when $default != null:
return $default(_that.id,_that.type,_that.attributes,_that.relationships);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _UserSubscriptionEntity extends UserSubscriptionEntity {
  const _UserSubscriptionEntity({required this.id, required this.type, required this.attributes, @JsonKey(includeIfNull: false) final  Map<String, dynamic>? relationships}): _relationships = relationships,super._();
  factory _UserSubscriptionEntity.fromJson(Map<String, dynamic> json) => _$UserSubscriptionEntityFromJson(json);

@override final  String id;
@override final  String type;
@override final  UserSubscriptionAttributeEntity? attributes;
 final  Map<String, dynamic>? _relationships;
@override@JsonKey(includeIfNull: false) Map<String, dynamic>? get relationships {
  final value = _relationships;
  if (value == null) return null;
  if (_relationships is EqualUnmodifiableMapView) return _relationships;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of UserSubscriptionEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserSubscriptionEntityCopyWith<_UserSubscriptionEntity> get copyWith => __$UserSubscriptionEntityCopyWithImpl<_UserSubscriptionEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserSubscriptionEntityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserSubscriptionEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.attributes, attributes) || other.attributes == attributes)&&const DeepCollectionEquality().equals(other._relationships, _relationships));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,attributes,const DeepCollectionEquality().hash(_relationships));

@override
String toString() {
  return 'UserSubscriptionEntity(id: $id, type: $type, attributes: $attributes, relationships: $relationships)';
}


}

/// @nodoc
abstract mixin class _$UserSubscriptionEntityCopyWith<$Res> implements $UserSubscriptionEntityCopyWith<$Res> {
  factory _$UserSubscriptionEntityCopyWith(_UserSubscriptionEntity value, $Res Function(_UserSubscriptionEntity) _then) = __$UserSubscriptionEntityCopyWithImpl;
@override @useResult
$Res call({
 String id, String type, UserSubscriptionAttributeEntity? attributes,@JsonKey(includeIfNull: false) Map<String, dynamic>? relationships
});


@override $UserSubscriptionAttributeEntityCopyWith<$Res>? get attributes;

}
/// @nodoc
class __$UserSubscriptionEntityCopyWithImpl<$Res>
    implements _$UserSubscriptionEntityCopyWith<$Res> {
  __$UserSubscriptionEntityCopyWithImpl(this._self, this._then);

  final _UserSubscriptionEntity _self;
  final $Res Function(_UserSubscriptionEntity) _then;

/// Create a copy of UserSubscriptionEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? attributes = freezed,Object? relationships = freezed,}) {
  return _then(_UserSubscriptionEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,attributes: freezed == attributes ? _self.attributes : attributes // ignore: cast_nullable_to_non_nullable
as UserSubscriptionAttributeEntity?,relationships: freezed == relationships ? _self._relationships : relationships // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}

/// Create a copy of UserSubscriptionEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserSubscriptionAttributeEntityCopyWith<$Res>? get attributes {
    if (_self.attributes == null) {
    return null;
  }

  return $UserSubscriptionAttributeEntityCopyWith<$Res>(_self.attributes!, (value) {
    return _then(_self.copyWith(attributes: value));
  });
}
}

// dart format on
