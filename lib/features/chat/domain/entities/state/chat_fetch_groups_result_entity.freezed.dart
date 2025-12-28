// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_fetch_groups_result_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ChatFetchGroupsResultEntity {

 List<MessageGroupEntity> get groups; int get sequence;
/// Create a copy of ChatFetchGroupsResultEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatFetchGroupsResultEntityCopyWith<ChatFetchGroupsResultEntity> get copyWith => _$ChatFetchGroupsResultEntityCopyWithImpl<ChatFetchGroupsResultEntity>(this as ChatFetchGroupsResultEntity, _$identity);

  /// Serializes this ChatFetchGroupsResultEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatFetchGroupsResultEntity&&const DeepCollectionEquality().equals(other.groups, groups)&&(identical(other.sequence, sequence) || other.sequence == sequence));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(groups),sequence);

@override
String toString() {
  return 'ChatFetchGroupsResultEntity(groups: $groups, sequence: $sequence)';
}


}

/// @nodoc
abstract mixin class $ChatFetchGroupsResultEntityCopyWith<$Res>  {
  factory $ChatFetchGroupsResultEntityCopyWith(ChatFetchGroupsResultEntity value, $Res Function(ChatFetchGroupsResultEntity) _then) = _$ChatFetchGroupsResultEntityCopyWithImpl;
@useResult
$Res call({
 List<MessageGroupEntity> groups, int sequence
});




}
/// @nodoc
class _$ChatFetchGroupsResultEntityCopyWithImpl<$Res>
    implements $ChatFetchGroupsResultEntityCopyWith<$Res> {
  _$ChatFetchGroupsResultEntityCopyWithImpl(this._self, this._then);

  final ChatFetchGroupsResultEntity _self;
  final $Res Function(ChatFetchGroupsResultEntity) _then;

/// Create a copy of ChatFetchGroupsResultEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? groups = null,Object? sequence = null,}) {
  return _then(_self.copyWith(
groups: null == groups ? _self.groups : groups // ignore: cast_nullable_to_non_nullable
as List<MessageGroupEntity>,sequence: null == sequence ? _self.sequence : sequence // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ChatFetchGroupsResultEntity].
extension ChatFetchGroupsResultEntityPatterns on ChatFetchGroupsResultEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatFetchGroupsResultEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatFetchGroupsResultEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatFetchGroupsResultEntity value)  $default,){
final _that = this;
switch (_that) {
case _ChatFetchGroupsResultEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatFetchGroupsResultEntity value)?  $default,){
final _that = this;
switch (_that) {
case _ChatFetchGroupsResultEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<MessageGroupEntity> groups,  int sequence)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatFetchGroupsResultEntity() when $default != null:
return $default(_that.groups,_that.sequence);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<MessageGroupEntity> groups,  int sequence)  $default,) {final _that = this;
switch (_that) {
case _ChatFetchGroupsResultEntity():
return $default(_that.groups,_that.sequence);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<MessageGroupEntity> groups,  int sequence)?  $default,) {final _that = this;
switch (_that) {
case _ChatFetchGroupsResultEntity() when $default != null:
return $default(_that.groups,_that.sequence);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _ChatFetchGroupsResultEntity implements ChatFetchGroupsResultEntity {
  const _ChatFetchGroupsResultEntity({required final  List<MessageGroupEntity> groups, required this.sequence}): _groups = groups;
  factory _ChatFetchGroupsResultEntity.fromJson(Map<String, dynamic> json) => _$ChatFetchGroupsResultEntityFromJson(json);

 final  List<MessageGroupEntity> _groups;
@override List<MessageGroupEntity> get groups {
  if (_groups is EqualUnmodifiableListView) return _groups;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_groups);
}

@override final  int sequence;

/// Create a copy of ChatFetchGroupsResultEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatFetchGroupsResultEntityCopyWith<_ChatFetchGroupsResultEntity> get copyWith => __$ChatFetchGroupsResultEntityCopyWithImpl<_ChatFetchGroupsResultEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChatFetchGroupsResultEntityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatFetchGroupsResultEntity&&const DeepCollectionEquality().equals(other._groups, _groups)&&(identical(other.sequence, sequence) || other.sequence == sequence));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_groups),sequence);

@override
String toString() {
  return 'ChatFetchGroupsResultEntity(groups: $groups, sequence: $sequence)';
}


}

/// @nodoc
abstract mixin class _$ChatFetchGroupsResultEntityCopyWith<$Res> implements $ChatFetchGroupsResultEntityCopyWith<$Res> {
  factory _$ChatFetchGroupsResultEntityCopyWith(_ChatFetchGroupsResultEntity value, $Res Function(_ChatFetchGroupsResultEntity) _then) = __$ChatFetchGroupsResultEntityCopyWithImpl;
@override @useResult
$Res call({
 List<MessageGroupEntity> groups, int sequence
});




}
/// @nodoc
class __$ChatFetchGroupsResultEntityCopyWithImpl<$Res>
    implements _$ChatFetchGroupsResultEntityCopyWith<$Res> {
  __$ChatFetchGroupsResultEntityCopyWithImpl(this._self, this._then);

  final _ChatFetchGroupsResultEntity _self;
  final $Res Function(_ChatFetchGroupsResultEntity) _then;

/// Create a copy of ChatFetchGroupsResultEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? groups = null,Object? sequence = null,}) {
  return _then(_ChatFetchGroupsResultEntity(
groups: null == groups ? _self._groups : groups // ignore: cast_nullable_to_non_nullable
as List<MessageGroupEntity>,sequence: null == sequence ? _self.sequence : sequence // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
