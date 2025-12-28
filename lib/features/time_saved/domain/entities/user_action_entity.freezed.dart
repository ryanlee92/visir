// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_action_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserActionEntity implements DiagnosticableTreeMixin {

 String? get id; DateTime? get createdAt; UserActionType get type; OAuthType? get oAuthType;//task는 oAuthType == null
 String? get identifier;
/// Create a copy of UserActionEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserActionEntityCopyWith<UserActionEntity> get copyWith => _$UserActionEntityCopyWithImpl<UserActionEntity>(this as UserActionEntity, _$identity);

  /// Serializes this UserActionEntity to a JSON map.
  Map<String, dynamic> toJson();

@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'UserActionEntity'))
    ..add(DiagnosticsProperty('id', id))..add(DiagnosticsProperty('createdAt', createdAt))..add(DiagnosticsProperty('type', type))..add(DiagnosticsProperty('oAuthType', oAuthType))..add(DiagnosticsProperty('identifier', identifier));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserActionEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.type, type) || other.type == type)&&(identical(other.oAuthType, oAuthType) || other.oAuthType == oAuthType)&&(identical(other.identifier, identifier) || other.identifier == identifier));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,createdAt,type,oAuthType,identifier);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'UserActionEntity(id: $id, createdAt: $createdAt, type: $type, oAuthType: $oAuthType, identifier: $identifier)';
}


}

/// @nodoc
abstract mixin class $UserActionEntityCopyWith<$Res>  {
  factory $UserActionEntityCopyWith(UserActionEntity value, $Res Function(UserActionEntity) _then) = _$UserActionEntityCopyWithImpl;
@useResult
$Res call({
 String? id, DateTime? createdAt, UserActionType type, OAuthType? oAuthType, String? identifier
});




}
/// @nodoc
class _$UserActionEntityCopyWithImpl<$Res>
    implements $UserActionEntityCopyWith<$Res> {
  _$UserActionEntityCopyWithImpl(this._self, this._then);

  final UserActionEntity _self;
  final $Res Function(UserActionEntity) _then;

/// Create a copy of UserActionEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? createdAt = freezed,Object? type = null,Object? oAuthType = freezed,Object? identifier = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as UserActionType,oAuthType: freezed == oAuthType ? _self.oAuthType : oAuthType // ignore: cast_nullable_to_non_nullable
as OAuthType?,identifier: freezed == identifier ? _self.identifier : identifier // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [UserActionEntity].
extension UserActionEntityPatterns on UserActionEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserActionEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserActionEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserActionEntity value)  $default,){
final _that = this;
switch (_that) {
case _UserActionEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserActionEntity value)?  $default,){
final _that = this;
switch (_that) {
case _UserActionEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id,  DateTime? createdAt,  UserActionType type,  OAuthType? oAuthType,  String? identifier)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserActionEntity() when $default != null:
return $default(_that.id,_that.createdAt,_that.type,_that.oAuthType,_that.identifier);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id,  DateTime? createdAt,  UserActionType type,  OAuthType? oAuthType,  String? identifier)  $default,) {final _that = this;
switch (_that) {
case _UserActionEntity():
return $default(_that.id,_that.createdAt,_that.type,_that.oAuthType,_that.identifier);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id,  DateTime? createdAt,  UserActionType type,  OAuthType? oAuthType,  String? identifier)?  $default,) {final _that = this;
switch (_that) {
case _UserActionEntity() when $default != null:
return $default(_that.id,_that.createdAt,_that.type,_that.oAuthType,_that.identifier);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _UserActionEntity with DiagnosticableTreeMixin implements UserActionEntity {
  const _UserActionEntity({this.id, this.createdAt, required this.type, this.oAuthType, this.identifier});
  factory _UserActionEntity.fromJson(Map<String, dynamic> json) => _$UserActionEntityFromJson(json);

@override final  String? id;
@override final  DateTime? createdAt;
@override final  UserActionType type;
@override final  OAuthType? oAuthType;
//task는 oAuthType == null
@override final  String? identifier;

/// Create a copy of UserActionEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserActionEntityCopyWith<_UserActionEntity> get copyWith => __$UserActionEntityCopyWithImpl<_UserActionEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserActionEntityToJson(this, );
}
@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'UserActionEntity'))
    ..add(DiagnosticsProperty('id', id))..add(DiagnosticsProperty('createdAt', createdAt))..add(DiagnosticsProperty('type', type))..add(DiagnosticsProperty('oAuthType', oAuthType))..add(DiagnosticsProperty('identifier', identifier));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserActionEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.type, type) || other.type == type)&&(identical(other.oAuthType, oAuthType) || other.oAuthType == oAuthType)&&(identical(other.identifier, identifier) || other.identifier == identifier));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,createdAt,type,oAuthType,identifier);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'UserActionEntity(id: $id, createdAt: $createdAt, type: $type, oAuthType: $oAuthType, identifier: $identifier)';
}


}

/// @nodoc
abstract mixin class _$UserActionEntityCopyWith<$Res> implements $UserActionEntityCopyWith<$Res> {
  factory _$UserActionEntityCopyWith(_UserActionEntity value, $Res Function(_UserActionEntity) _then) = __$UserActionEntityCopyWithImpl;
@override @useResult
$Res call({
 String? id, DateTime? createdAt, UserActionType type, OAuthType? oAuthType, String? identifier
});




}
/// @nodoc
class __$UserActionEntityCopyWithImpl<$Res>
    implements _$UserActionEntityCopyWith<$Res> {
  __$UserActionEntityCopyWithImpl(this._self, this._then);

  final _UserActionEntity _self;
  final $Res Function(_UserActionEntity) _then;

/// Create a copy of UserActionEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? createdAt = freezed,Object? type = null,Object? oAuthType = freezed,Object? identifier = freezed,}) {
  return _then(_UserActionEntity(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as UserActionType,oAuthType: freezed == oAuthType ? _self.oAuthType : oAuthType // ignore: cast_nullable_to_non_nullable
as OAuthType?,identifier: freezed == identifier ? _self.identifier : identifier // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
