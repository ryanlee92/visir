// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'connection_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ConnectionEntity {

@JsonKey(includeIfNull: false) String? get email;@JsonKey(includeIfNull: false) String? get name;
/// Create a copy of ConnectionEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConnectionEntityCopyWith<ConnectionEntity> get copyWith => _$ConnectionEntityCopyWithImpl<ConnectionEntity>(this as ConnectionEntity, _$identity);

  /// Serializes this ConnectionEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConnectionEntity&&(identical(other.email, email) || other.email == email)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,email,name);

@override
String toString() {
  return 'ConnectionEntity(email: $email, name: $name)';
}


}

/// @nodoc
abstract mixin class $ConnectionEntityCopyWith<$Res>  {
  factory $ConnectionEntityCopyWith(ConnectionEntity value, $Res Function(ConnectionEntity) _then) = _$ConnectionEntityCopyWithImpl;
@useResult
$Res call({
@JsonKey(includeIfNull: false) String? email,@JsonKey(includeIfNull: false) String? name
});




}
/// @nodoc
class _$ConnectionEntityCopyWithImpl<$Res>
    implements $ConnectionEntityCopyWith<$Res> {
  _$ConnectionEntityCopyWithImpl(this._self, this._then);

  final ConnectionEntity _self;
  final $Res Function(ConnectionEntity) _then;

/// Create a copy of ConnectionEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? email = freezed,Object? name = freezed,}) {
  return _then(_self.copyWith(
email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ConnectionEntity].
extension ConnectionEntityPatterns on ConnectionEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ConnectionEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ConnectionEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ConnectionEntity value)  $default,){
final _that = this;
switch (_that) {
case _ConnectionEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ConnectionEntity value)?  $default,){
final _that = this;
switch (_that) {
case _ConnectionEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(includeIfNull: false)  String? email, @JsonKey(includeIfNull: false)  String? name)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ConnectionEntity() when $default != null:
return $default(_that.email,_that.name);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(includeIfNull: false)  String? email, @JsonKey(includeIfNull: false)  String? name)  $default,) {final _that = this;
switch (_that) {
case _ConnectionEntity():
return $default(_that.email,_that.name);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(includeIfNull: false)  String? email, @JsonKey(includeIfNull: false)  String? name)?  $default,) {final _that = this;
switch (_that) {
case _ConnectionEntity() when $default != null:
return $default(_that.email,_that.name);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _ConnectionEntity implements ConnectionEntity {
  const _ConnectionEntity({@JsonKey(includeIfNull: false) this.email, @JsonKey(includeIfNull: false) this.name});
  factory _ConnectionEntity.fromJson(Map<String, dynamic> json) => _$ConnectionEntityFromJson(json);

@override@JsonKey(includeIfNull: false) final  String? email;
@override@JsonKey(includeIfNull: false) final  String? name;

/// Create a copy of ConnectionEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ConnectionEntityCopyWith<_ConnectionEntity> get copyWith => __$ConnectionEntityCopyWithImpl<_ConnectionEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ConnectionEntityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ConnectionEntity&&(identical(other.email, email) || other.email == email)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,email,name);

@override
String toString() {
  return 'ConnectionEntity(email: $email, name: $name)';
}


}

/// @nodoc
abstract mixin class _$ConnectionEntityCopyWith<$Res> implements $ConnectionEntityCopyWith<$Res> {
  factory _$ConnectionEntityCopyWith(_ConnectionEntity value, $Res Function(_ConnectionEntity) _then) = __$ConnectionEntityCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(includeIfNull: false) String? email,@JsonKey(includeIfNull: false) String? name
});




}
/// @nodoc
class __$ConnectionEntityCopyWithImpl<$Res>
    implements _$ConnectionEntityCopyWith<$Res> {
  __$ConnectionEntityCopyWithImpl(this._self, this._then);

  final _ConnectionEntity _self;
  final $Res Function(_ConnectionEntity) _then;

/// Create a copy of ConnectionEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? email = freezed,Object? name = freezed,}) {
  return _then(_ConnectionEntity(
email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
