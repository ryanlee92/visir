// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'slack_message_reaction_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SlackMessageReactionEntity {

@JsonKey(includeIfNull: false) String? get name;@JsonKey(includeIfNull: false) int? get count;@JsonKey(includeIfNull: false) List<String>? get users;
/// Create a copy of SlackMessageReactionEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SlackMessageReactionEntityCopyWith<SlackMessageReactionEntity> get copyWith => _$SlackMessageReactionEntityCopyWithImpl<SlackMessageReactionEntity>(this as SlackMessageReactionEntity, _$identity);

  /// Serializes this SlackMessageReactionEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SlackMessageReactionEntity&&(identical(other.name, name) || other.name == name)&&(identical(other.count, count) || other.count == count)&&const DeepCollectionEquality().equals(other.users, users));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,count,const DeepCollectionEquality().hash(users));

@override
String toString() {
  return 'SlackMessageReactionEntity(name: $name, count: $count, users: $users)';
}


}

/// @nodoc
abstract mixin class $SlackMessageReactionEntityCopyWith<$Res>  {
  factory $SlackMessageReactionEntityCopyWith(SlackMessageReactionEntity value, $Res Function(SlackMessageReactionEntity) _then) = _$SlackMessageReactionEntityCopyWithImpl;
@useResult
$Res call({
@JsonKey(includeIfNull: false) String? name,@JsonKey(includeIfNull: false) int? count,@JsonKey(includeIfNull: false) List<String>? users
});




}
/// @nodoc
class _$SlackMessageReactionEntityCopyWithImpl<$Res>
    implements $SlackMessageReactionEntityCopyWith<$Res> {
  _$SlackMessageReactionEntityCopyWithImpl(this._self, this._then);

  final SlackMessageReactionEntity _self;
  final $Res Function(SlackMessageReactionEntity) _then;

/// Create a copy of SlackMessageReactionEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = freezed,Object? count = freezed,Object? users = freezed,}) {
  return _then(_self.copyWith(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,count: freezed == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int?,users: freezed == users ? _self.users : users // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}

}


/// Adds pattern-matching-related methods to [SlackMessageReactionEntity].
extension SlackMessageReactionEntityPatterns on SlackMessageReactionEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SlackMessageReactionEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SlackMessageReactionEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SlackMessageReactionEntity value)  $default,){
final _that = this;
switch (_that) {
case _SlackMessageReactionEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SlackMessageReactionEntity value)?  $default,){
final _that = this;
switch (_that) {
case _SlackMessageReactionEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(includeIfNull: false)  String? name, @JsonKey(includeIfNull: false)  int? count, @JsonKey(includeIfNull: false)  List<String>? users)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SlackMessageReactionEntity() when $default != null:
return $default(_that.name,_that.count,_that.users);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(includeIfNull: false)  String? name, @JsonKey(includeIfNull: false)  int? count, @JsonKey(includeIfNull: false)  List<String>? users)  $default,) {final _that = this;
switch (_that) {
case _SlackMessageReactionEntity():
return $default(_that.name,_that.count,_that.users);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(includeIfNull: false)  String? name, @JsonKey(includeIfNull: false)  int? count, @JsonKey(includeIfNull: false)  List<String>? users)?  $default,) {final _that = this;
switch (_that) {
case _SlackMessageReactionEntity() when $default != null:
return $default(_that.name,_that.count,_that.users);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _SlackMessageReactionEntity implements SlackMessageReactionEntity {
  const _SlackMessageReactionEntity({@JsonKey(includeIfNull: false) this.name, @JsonKey(includeIfNull: false) this.count, @JsonKey(includeIfNull: false) final  List<String>? users}): _users = users;
  factory _SlackMessageReactionEntity.fromJson(Map<String, dynamic> json) => _$SlackMessageReactionEntityFromJson(json);

@override@JsonKey(includeIfNull: false) final  String? name;
@override@JsonKey(includeIfNull: false) final  int? count;
 final  List<String>? _users;
@override@JsonKey(includeIfNull: false) List<String>? get users {
  final value = _users;
  if (value == null) return null;
  if (_users is EqualUnmodifiableListView) return _users;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of SlackMessageReactionEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SlackMessageReactionEntityCopyWith<_SlackMessageReactionEntity> get copyWith => __$SlackMessageReactionEntityCopyWithImpl<_SlackMessageReactionEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SlackMessageReactionEntityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SlackMessageReactionEntity&&(identical(other.name, name) || other.name == name)&&(identical(other.count, count) || other.count == count)&&const DeepCollectionEquality().equals(other._users, _users));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,count,const DeepCollectionEquality().hash(_users));

@override
String toString() {
  return 'SlackMessageReactionEntity(name: $name, count: $count, users: $users)';
}


}

/// @nodoc
abstract mixin class _$SlackMessageReactionEntityCopyWith<$Res> implements $SlackMessageReactionEntityCopyWith<$Res> {
  factory _$SlackMessageReactionEntityCopyWith(_SlackMessageReactionEntity value, $Res Function(_SlackMessageReactionEntity) _then) = __$SlackMessageReactionEntityCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(includeIfNull: false) String? name,@JsonKey(includeIfNull: false) int? count,@JsonKey(includeIfNull: false) List<String>? users
});




}
/// @nodoc
class __$SlackMessageReactionEntityCopyWithImpl<$Res>
    implements _$SlackMessageReactionEntityCopyWith<$Res> {
  __$SlackMessageReactionEntityCopyWithImpl(this._self, this._then);

  final _SlackMessageReactionEntity _self;
  final $Res Function(_SlackMessageReactionEntity) _then;

/// Create a copy of SlackMessageReactionEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = freezed,Object? count = freezed,Object? users = freezed,}) {
  return _then(_SlackMessageReactionEntity(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,count: freezed == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int?,users: freezed == users ? _self._users : users // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}


}

// dart format on
