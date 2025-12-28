// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'total_user_action_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TotalUserActionEntity {

 List<UserActionSwitchCountEntity> get userActions;
/// Create a copy of TotalUserActionEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TotalUserActionEntityCopyWith<TotalUserActionEntity> get copyWith => _$TotalUserActionEntityCopyWithImpl<TotalUserActionEntity>(this as TotalUserActionEntity, _$identity);

  /// Serializes this TotalUserActionEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TotalUserActionEntity&&const DeepCollectionEquality().equals(other.userActions, userActions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(userActions));

@override
String toString() {
  return 'TotalUserActionEntity(userActions: $userActions)';
}


}

/// @nodoc
abstract mixin class $TotalUserActionEntityCopyWith<$Res>  {
  factory $TotalUserActionEntityCopyWith(TotalUserActionEntity value, $Res Function(TotalUserActionEntity) _then) = _$TotalUserActionEntityCopyWithImpl;
@useResult
$Res call({
 List<UserActionSwitchCountEntity> userActions
});




}
/// @nodoc
class _$TotalUserActionEntityCopyWithImpl<$Res>
    implements $TotalUserActionEntityCopyWith<$Res> {
  _$TotalUserActionEntityCopyWithImpl(this._self, this._then);

  final TotalUserActionEntity _self;
  final $Res Function(TotalUserActionEntity) _then;

/// Create a copy of TotalUserActionEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userActions = null,}) {
  return _then(_self.copyWith(
userActions: null == userActions ? _self.userActions : userActions // ignore: cast_nullable_to_non_nullable
as List<UserActionSwitchCountEntity>,
  ));
}

}


/// Adds pattern-matching-related methods to [TotalUserActionEntity].
extension TotalUserActionEntityPatterns on TotalUserActionEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TotalUserActionEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TotalUserActionEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TotalUserActionEntity value)  $default,){
final _that = this;
switch (_that) {
case _TotalUserActionEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TotalUserActionEntity value)?  $default,){
final _that = this;
switch (_that) {
case _TotalUserActionEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<UserActionSwitchCountEntity> userActions)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TotalUserActionEntity() when $default != null:
return $default(_that.userActions);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<UserActionSwitchCountEntity> userActions)  $default,) {final _that = this;
switch (_that) {
case _TotalUserActionEntity():
return $default(_that.userActions);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<UserActionSwitchCountEntity> userActions)?  $default,) {final _that = this;
switch (_that) {
case _TotalUserActionEntity() when $default != null:
return $default(_that.userActions);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _TotalUserActionEntity implements TotalUserActionEntity {
  const _TotalUserActionEntity({required final  List<UserActionSwitchCountEntity> userActions}): _userActions = userActions;
  factory _TotalUserActionEntity.fromJson(Map<String, dynamic> json) => _$TotalUserActionEntityFromJson(json);

 final  List<UserActionSwitchCountEntity> _userActions;
@override List<UserActionSwitchCountEntity> get userActions {
  if (_userActions is EqualUnmodifiableListView) return _userActions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_userActions);
}


/// Create a copy of TotalUserActionEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TotalUserActionEntityCopyWith<_TotalUserActionEntity> get copyWith => __$TotalUserActionEntityCopyWithImpl<_TotalUserActionEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TotalUserActionEntityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TotalUserActionEntity&&const DeepCollectionEquality().equals(other._userActions, _userActions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_userActions));

@override
String toString() {
  return 'TotalUserActionEntity(userActions: $userActions)';
}


}

/// @nodoc
abstract mixin class _$TotalUserActionEntityCopyWith<$Res> implements $TotalUserActionEntityCopyWith<$Res> {
  factory _$TotalUserActionEntityCopyWith(_TotalUserActionEntity value, $Res Function(_TotalUserActionEntity) _then) = __$TotalUserActionEntityCopyWithImpl;
@override @useResult
$Res call({
 List<UserActionSwitchCountEntity> userActions
});




}
/// @nodoc
class __$TotalUserActionEntityCopyWithImpl<$Res>
    implements _$TotalUserActionEntityCopyWith<$Res> {
  __$TotalUserActionEntityCopyWithImpl(this._self, this._then);

  final _TotalUserActionEntity _self;
  final $Res Function(_TotalUserActionEntity) _then;

/// Create a copy of TotalUserActionEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userActions = null,}) {
  return _then(_TotalUserActionEntity(
userActions: null == userActions ? _self._userActions : userActions // ignore: cast_nullable_to_non_nullable
as List<UserActionSwitchCountEntity>,
  ));
}


}

// dart format on
