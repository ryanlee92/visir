// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_action_switch_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserActionSwitchEntity {

 String get id; String get userId; DateTime get createdAt; UserActionEntity get prevAction; UserActionEntity get nextAction;
/// Create a copy of UserActionSwitchEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserActionSwitchEntityCopyWith<UserActionSwitchEntity> get copyWith => _$UserActionSwitchEntityCopyWithImpl<UserActionSwitchEntity>(this as UserActionSwitchEntity, _$identity);

  /// Serializes this UserActionSwitchEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserActionSwitchEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.prevAction, prevAction) || other.prevAction == prevAction)&&(identical(other.nextAction, nextAction) || other.nextAction == nextAction));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,createdAt,prevAction,nextAction);

@override
String toString() {
  return 'UserActionSwitchEntity(id: $id, userId: $userId, createdAt: $createdAt, prevAction: $prevAction, nextAction: $nextAction)';
}


}

/// @nodoc
abstract mixin class $UserActionSwitchEntityCopyWith<$Res>  {
  factory $UserActionSwitchEntityCopyWith(UserActionSwitchEntity value, $Res Function(UserActionSwitchEntity) _then) = _$UserActionSwitchEntityCopyWithImpl;
@useResult
$Res call({
 String id, String userId, DateTime createdAt, UserActionEntity prevAction, UserActionEntity nextAction
});


$UserActionEntityCopyWith<$Res> get prevAction;$UserActionEntityCopyWith<$Res> get nextAction;

}
/// @nodoc
class _$UserActionSwitchEntityCopyWithImpl<$Res>
    implements $UserActionSwitchEntityCopyWith<$Res> {
  _$UserActionSwitchEntityCopyWithImpl(this._self, this._then);

  final UserActionSwitchEntity _self;
  final $Res Function(UserActionSwitchEntity) _then;

/// Create a copy of UserActionSwitchEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? createdAt = null,Object? prevAction = null,Object? nextAction = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,prevAction: null == prevAction ? _self.prevAction : prevAction // ignore: cast_nullable_to_non_nullable
as UserActionEntity,nextAction: null == nextAction ? _self.nextAction : nextAction // ignore: cast_nullable_to_non_nullable
as UserActionEntity,
  ));
}
/// Create a copy of UserActionSwitchEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserActionEntityCopyWith<$Res> get prevAction {
  
  return $UserActionEntityCopyWith<$Res>(_self.prevAction, (value) {
    return _then(_self.copyWith(prevAction: value));
  });
}/// Create a copy of UserActionSwitchEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserActionEntityCopyWith<$Res> get nextAction {
  
  return $UserActionEntityCopyWith<$Res>(_self.nextAction, (value) {
    return _then(_self.copyWith(nextAction: value));
  });
}
}


/// Adds pattern-matching-related methods to [UserActionSwitchEntity].
extension UserActionSwitchEntityPatterns on UserActionSwitchEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserActionSwitchEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserActionSwitchEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserActionSwitchEntity value)  $default,){
final _that = this;
switch (_that) {
case _UserActionSwitchEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserActionSwitchEntity value)?  $default,){
final _that = this;
switch (_that) {
case _UserActionSwitchEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  DateTime createdAt,  UserActionEntity prevAction,  UserActionEntity nextAction)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserActionSwitchEntity() when $default != null:
return $default(_that.id,_that.userId,_that.createdAt,_that.prevAction,_that.nextAction);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  DateTime createdAt,  UserActionEntity prevAction,  UserActionEntity nextAction)  $default,) {final _that = this;
switch (_that) {
case _UserActionSwitchEntity():
return $default(_that.id,_that.userId,_that.createdAt,_that.prevAction,_that.nextAction);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  DateTime createdAt,  UserActionEntity prevAction,  UserActionEntity nextAction)?  $default,) {final _that = this;
switch (_that) {
case _UserActionSwitchEntity() when $default != null:
return $default(_that.id,_that.userId,_that.createdAt,_that.prevAction,_that.nextAction);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _UserActionSwitchEntity implements UserActionSwitchEntity {
  const _UserActionSwitchEntity({required this.id, required this.userId, required this.createdAt, required this.prevAction, required this.nextAction});
  factory _UserActionSwitchEntity.fromJson(Map<String, dynamic> json) => _$UserActionSwitchEntityFromJson(json);

@override final  String id;
@override final  String userId;
@override final  DateTime createdAt;
@override final  UserActionEntity prevAction;
@override final  UserActionEntity nextAction;

/// Create a copy of UserActionSwitchEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserActionSwitchEntityCopyWith<_UserActionSwitchEntity> get copyWith => __$UserActionSwitchEntityCopyWithImpl<_UserActionSwitchEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserActionSwitchEntityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserActionSwitchEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.prevAction, prevAction) || other.prevAction == prevAction)&&(identical(other.nextAction, nextAction) || other.nextAction == nextAction));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,createdAt,prevAction,nextAction);

@override
String toString() {
  return 'UserActionSwitchEntity(id: $id, userId: $userId, createdAt: $createdAt, prevAction: $prevAction, nextAction: $nextAction)';
}


}

/// @nodoc
abstract mixin class _$UserActionSwitchEntityCopyWith<$Res> implements $UserActionSwitchEntityCopyWith<$Res> {
  factory _$UserActionSwitchEntityCopyWith(_UserActionSwitchEntity value, $Res Function(_UserActionSwitchEntity) _then) = __$UserActionSwitchEntityCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, DateTime createdAt, UserActionEntity prevAction, UserActionEntity nextAction
});


@override $UserActionEntityCopyWith<$Res> get prevAction;@override $UserActionEntityCopyWith<$Res> get nextAction;

}
/// @nodoc
class __$UserActionSwitchEntityCopyWithImpl<$Res>
    implements _$UserActionSwitchEntityCopyWith<$Res> {
  __$UserActionSwitchEntityCopyWithImpl(this._self, this._then);

  final _UserActionSwitchEntity _self;
  final $Res Function(_UserActionSwitchEntity) _then;

/// Create a copy of UserActionSwitchEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? createdAt = null,Object? prevAction = null,Object? nextAction = null,}) {
  return _then(_UserActionSwitchEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,prevAction: null == prevAction ? _self.prevAction : prevAction // ignore: cast_nullable_to_non_nullable
as UserActionEntity,nextAction: null == nextAction ? _self.nextAction : nextAction // ignore: cast_nullable_to_non_nullable
as UserActionEntity,
  ));
}

/// Create a copy of UserActionSwitchEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserActionEntityCopyWith<$Res> get prevAction {
  
  return $UserActionEntityCopyWith<$Res>(_self.prevAction, (value) {
    return _then(_self.copyWith(prevAction: value));
  });
}/// Create a copy of UserActionSwitchEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserActionEntityCopyWith<$Res> get nextAction {
  
  return $UserActionEntityCopyWith<$Res>(_self.nextAction, (value) {
    return _then(_self.copyWith(nextAction: value));
  });
}
}

// dart format on
