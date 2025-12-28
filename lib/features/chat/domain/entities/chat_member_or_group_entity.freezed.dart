// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_member_or_group_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ChatMemberOrGroupEntity {

 MessageMemberEntity? get member; MessageGroupEntity? get group;
/// Create a copy of ChatMemberOrGroupEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatMemberOrGroupEntityCopyWith<ChatMemberOrGroupEntity> get copyWith => _$ChatMemberOrGroupEntityCopyWithImpl<ChatMemberOrGroupEntity>(this as ChatMemberOrGroupEntity, _$identity);

  /// Serializes this ChatMemberOrGroupEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatMemberOrGroupEntity&&(identical(other.member, member) || other.member == member)&&(identical(other.group, group) || other.group == group));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,member,group);

@override
String toString() {
  return 'ChatMemberOrGroupEntity(member: $member, group: $group)';
}


}

/// @nodoc
abstract mixin class $ChatMemberOrGroupEntityCopyWith<$Res>  {
  factory $ChatMemberOrGroupEntityCopyWith(ChatMemberOrGroupEntity value, $Res Function(ChatMemberOrGroupEntity) _then) = _$ChatMemberOrGroupEntityCopyWithImpl;
@useResult
$Res call({
 MessageMemberEntity? member, MessageGroupEntity? group
});




}
/// @nodoc
class _$ChatMemberOrGroupEntityCopyWithImpl<$Res>
    implements $ChatMemberOrGroupEntityCopyWith<$Res> {
  _$ChatMemberOrGroupEntityCopyWithImpl(this._self, this._then);

  final ChatMemberOrGroupEntity _self;
  final $Res Function(ChatMemberOrGroupEntity) _then;

/// Create a copy of ChatMemberOrGroupEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? member = freezed,Object? group = freezed,}) {
  return _then(_self.copyWith(
member: freezed == member ? _self.member : member // ignore: cast_nullable_to_non_nullable
as MessageMemberEntity?,group: freezed == group ? _self.group : group // ignore: cast_nullable_to_non_nullable
as MessageGroupEntity?,
  ));
}

}


/// Adds pattern-matching-related methods to [ChatMemberOrGroupEntity].
extension ChatMemberOrGroupEntityPatterns on ChatMemberOrGroupEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatMemberOrGroupEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatMemberOrGroupEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatMemberOrGroupEntity value)  $default,){
final _that = this;
switch (_that) {
case _ChatMemberOrGroupEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatMemberOrGroupEntity value)?  $default,){
final _that = this;
switch (_that) {
case _ChatMemberOrGroupEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( MessageMemberEntity? member,  MessageGroupEntity? group)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatMemberOrGroupEntity() when $default != null:
return $default(_that.member,_that.group);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( MessageMemberEntity? member,  MessageGroupEntity? group)  $default,) {final _that = this;
switch (_that) {
case _ChatMemberOrGroupEntity():
return $default(_that.member,_that.group);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( MessageMemberEntity? member,  MessageGroupEntity? group)?  $default,) {final _that = this;
switch (_that) {
case _ChatMemberOrGroupEntity() when $default != null:
return $default(_that.member,_that.group);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ChatMemberOrGroupEntity implements ChatMemberOrGroupEntity {
  const _ChatMemberOrGroupEntity({this.member, this.group});
  factory _ChatMemberOrGroupEntity.fromJson(Map<String, dynamic> json) => _$ChatMemberOrGroupEntityFromJson(json);

@override final  MessageMemberEntity? member;
@override final  MessageGroupEntity? group;

/// Create a copy of ChatMemberOrGroupEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatMemberOrGroupEntityCopyWith<_ChatMemberOrGroupEntity> get copyWith => __$ChatMemberOrGroupEntityCopyWithImpl<_ChatMemberOrGroupEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChatMemberOrGroupEntityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatMemberOrGroupEntity&&(identical(other.member, member) || other.member == member)&&(identical(other.group, group) || other.group == group));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,member,group);

@override
String toString() {
  return 'ChatMemberOrGroupEntity(member: $member, group: $group)';
}


}

/// @nodoc
abstract mixin class _$ChatMemberOrGroupEntityCopyWith<$Res> implements $ChatMemberOrGroupEntityCopyWith<$Res> {
  factory _$ChatMemberOrGroupEntityCopyWith(_ChatMemberOrGroupEntity value, $Res Function(_ChatMemberOrGroupEntity) _then) = __$ChatMemberOrGroupEntityCopyWithImpl;
@override @useResult
$Res call({
 MessageMemberEntity? member, MessageGroupEntity? group
});




}
/// @nodoc
class __$ChatMemberOrGroupEntityCopyWithImpl<$Res>
    implements _$ChatMemberOrGroupEntityCopyWith<$Res> {
  __$ChatMemberOrGroupEntityCopyWithImpl(this._self, this._then);

  final _ChatMemberOrGroupEntity _self;
  final $Res Function(_ChatMemberOrGroupEntity) _then;

/// Create a copy of ChatMemberOrGroupEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? member = freezed,Object? group = freezed,}) {
  return _then(_ChatMemberOrGroupEntity(
member: freezed == member ? _self.member : member // ignore: cast_nullable_to_non_nullable
as MessageMemberEntity?,group: freezed == group ? _self.group : group // ignore: cast_nullable_to_non_nullable
as MessageGroupEntity?,
  ));
}


}

// dart format on
