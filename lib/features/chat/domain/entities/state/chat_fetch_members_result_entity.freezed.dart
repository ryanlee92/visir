// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_fetch_members_result_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ChatFetchMembersResultEntity {

 List<MessageMemberEntity> get members; int get sequence; List<String> get loadedMembers;
/// Create a copy of ChatFetchMembersResultEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatFetchMembersResultEntityCopyWith<ChatFetchMembersResultEntity> get copyWith => _$ChatFetchMembersResultEntityCopyWithImpl<ChatFetchMembersResultEntity>(this as ChatFetchMembersResultEntity, _$identity);

  /// Serializes this ChatFetchMembersResultEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatFetchMembersResultEntity&&const DeepCollectionEquality().equals(other.members, members)&&(identical(other.sequence, sequence) || other.sequence == sequence)&&const DeepCollectionEquality().equals(other.loadedMembers, loadedMembers));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(members),sequence,const DeepCollectionEquality().hash(loadedMembers));

@override
String toString() {
  return 'ChatFetchMembersResultEntity(members: $members, sequence: $sequence, loadedMembers: $loadedMembers)';
}


}

/// @nodoc
abstract mixin class $ChatFetchMembersResultEntityCopyWith<$Res>  {
  factory $ChatFetchMembersResultEntityCopyWith(ChatFetchMembersResultEntity value, $Res Function(ChatFetchMembersResultEntity) _then) = _$ChatFetchMembersResultEntityCopyWithImpl;
@useResult
$Res call({
 List<MessageMemberEntity> members, int sequence, List<String> loadedMembers
});




}
/// @nodoc
class _$ChatFetchMembersResultEntityCopyWithImpl<$Res>
    implements $ChatFetchMembersResultEntityCopyWith<$Res> {
  _$ChatFetchMembersResultEntityCopyWithImpl(this._self, this._then);

  final ChatFetchMembersResultEntity _self;
  final $Res Function(ChatFetchMembersResultEntity) _then;

/// Create a copy of ChatFetchMembersResultEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? members = null,Object? sequence = null,Object? loadedMembers = null,}) {
  return _then(_self.copyWith(
members: null == members ? _self.members : members // ignore: cast_nullable_to_non_nullable
as List<MessageMemberEntity>,sequence: null == sequence ? _self.sequence : sequence // ignore: cast_nullable_to_non_nullable
as int,loadedMembers: null == loadedMembers ? _self.loadedMembers : loadedMembers // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [ChatFetchMembersResultEntity].
extension ChatFetchMembersResultEntityPatterns on ChatFetchMembersResultEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatFetchMembersResultEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatFetchMembersResultEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatFetchMembersResultEntity value)  $default,){
final _that = this;
switch (_that) {
case _ChatFetchMembersResultEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatFetchMembersResultEntity value)?  $default,){
final _that = this;
switch (_that) {
case _ChatFetchMembersResultEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<MessageMemberEntity> members,  int sequence,  List<String> loadedMembers)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatFetchMembersResultEntity() when $default != null:
return $default(_that.members,_that.sequence,_that.loadedMembers);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<MessageMemberEntity> members,  int sequence,  List<String> loadedMembers)  $default,) {final _that = this;
switch (_that) {
case _ChatFetchMembersResultEntity():
return $default(_that.members,_that.sequence,_that.loadedMembers);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<MessageMemberEntity> members,  int sequence,  List<String> loadedMembers)?  $default,) {final _that = this;
switch (_that) {
case _ChatFetchMembersResultEntity() when $default != null:
return $default(_that.members,_that.sequence,_that.loadedMembers);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _ChatFetchMembersResultEntity implements ChatFetchMembersResultEntity {
  const _ChatFetchMembersResultEntity({required final  List<MessageMemberEntity> members, required this.sequence, required final  List<String> loadedMembers}): _members = members,_loadedMembers = loadedMembers;
  factory _ChatFetchMembersResultEntity.fromJson(Map<String, dynamic> json) => _$ChatFetchMembersResultEntityFromJson(json);

 final  List<MessageMemberEntity> _members;
@override List<MessageMemberEntity> get members {
  if (_members is EqualUnmodifiableListView) return _members;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_members);
}

@override final  int sequence;
 final  List<String> _loadedMembers;
@override List<String> get loadedMembers {
  if (_loadedMembers is EqualUnmodifiableListView) return _loadedMembers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_loadedMembers);
}


/// Create a copy of ChatFetchMembersResultEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatFetchMembersResultEntityCopyWith<_ChatFetchMembersResultEntity> get copyWith => __$ChatFetchMembersResultEntityCopyWithImpl<_ChatFetchMembersResultEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChatFetchMembersResultEntityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatFetchMembersResultEntity&&const DeepCollectionEquality().equals(other._members, _members)&&(identical(other.sequence, sequence) || other.sequence == sequence)&&const DeepCollectionEquality().equals(other._loadedMembers, _loadedMembers));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_members),sequence,const DeepCollectionEquality().hash(_loadedMembers));

@override
String toString() {
  return 'ChatFetchMembersResultEntity(members: $members, sequence: $sequence, loadedMembers: $loadedMembers)';
}


}

/// @nodoc
abstract mixin class _$ChatFetchMembersResultEntityCopyWith<$Res> implements $ChatFetchMembersResultEntityCopyWith<$Res> {
  factory _$ChatFetchMembersResultEntityCopyWith(_ChatFetchMembersResultEntity value, $Res Function(_ChatFetchMembersResultEntity) _then) = __$ChatFetchMembersResultEntityCopyWithImpl;
@override @useResult
$Res call({
 List<MessageMemberEntity> members, int sequence, List<String> loadedMembers
});




}
/// @nodoc
class __$ChatFetchMembersResultEntityCopyWithImpl<$Res>
    implements _$ChatFetchMembersResultEntityCopyWith<$Res> {
  __$ChatFetchMembersResultEntityCopyWithImpl(this._self, this._then);

  final _ChatFetchMembersResultEntity _self;
  final $Res Function(_ChatFetchMembersResultEntity) _then;

/// Create a copy of ChatFetchMembersResultEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? members = null,Object? sequence = null,Object? loadedMembers = null,}) {
  return _then(_ChatFetchMembersResultEntity(
members: null == members ? _self._members : members // ignore: cast_nullable_to_non_nullable
as List<MessageMemberEntity>,sequence: null == sequence ? _self.sequence : sequence // ignore: cast_nullable_to_non_nullable
as int,loadedMembers: null == loadedMembers ? _self._loadedMembers : loadedMembers // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
