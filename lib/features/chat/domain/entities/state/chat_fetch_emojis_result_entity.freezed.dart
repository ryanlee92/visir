// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_fetch_emojis_result_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ChatFetchEmojisResultEntity {

 List<MessageEmojiEntity> get emojis; int get sequence;
/// Create a copy of ChatFetchEmojisResultEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatFetchEmojisResultEntityCopyWith<ChatFetchEmojisResultEntity> get copyWith => _$ChatFetchEmojisResultEntityCopyWithImpl<ChatFetchEmojisResultEntity>(this as ChatFetchEmojisResultEntity, _$identity);

  /// Serializes this ChatFetchEmojisResultEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatFetchEmojisResultEntity&&const DeepCollectionEquality().equals(other.emojis, emojis)&&(identical(other.sequence, sequence) || other.sequence == sequence));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(emojis),sequence);

@override
String toString() {
  return 'ChatFetchEmojisResultEntity(emojis: $emojis, sequence: $sequence)';
}


}

/// @nodoc
abstract mixin class $ChatFetchEmojisResultEntityCopyWith<$Res>  {
  factory $ChatFetchEmojisResultEntityCopyWith(ChatFetchEmojisResultEntity value, $Res Function(ChatFetchEmojisResultEntity) _then) = _$ChatFetchEmojisResultEntityCopyWithImpl;
@useResult
$Res call({
 List<MessageEmojiEntity> emojis, int sequence
});




}
/// @nodoc
class _$ChatFetchEmojisResultEntityCopyWithImpl<$Res>
    implements $ChatFetchEmojisResultEntityCopyWith<$Res> {
  _$ChatFetchEmojisResultEntityCopyWithImpl(this._self, this._then);

  final ChatFetchEmojisResultEntity _self;
  final $Res Function(ChatFetchEmojisResultEntity) _then;

/// Create a copy of ChatFetchEmojisResultEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? emojis = null,Object? sequence = null,}) {
  return _then(_self.copyWith(
emojis: null == emojis ? _self.emojis : emojis // ignore: cast_nullable_to_non_nullable
as List<MessageEmojiEntity>,sequence: null == sequence ? _self.sequence : sequence // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ChatFetchEmojisResultEntity].
extension ChatFetchEmojisResultEntityPatterns on ChatFetchEmojisResultEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatFetchEmojisResultEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatFetchEmojisResultEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatFetchEmojisResultEntity value)  $default,){
final _that = this;
switch (_that) {
case _ChatFetchEmojisResultEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatFetchEmojisResultEntity value)?  $default,){
final _that = this;
switch (_that) {
case _ChatFetchEmojisResultEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<MessageEmojiEntity> emojis,  int sequence)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatFetchEmojisResultEntity() when $default != null:
return $default(_that.emojis,_that.sequence);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<MessageEmojiEntity> emojis,  int sequence)  $default,) {final _that = this;
switch (_that) {
case _ChatFetchEmojisResultEntity():
return $default(_that.emojis,_that.sequence);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<MessageEmojiEntity> emojis,  int sequence)?  $default,) {final _that = this;
switch (_that) {
case _ChatFetchEmojisResultEntity() when $default != null:
return $default(_that.emojis,_that.sequence);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _ChatFetchEmojisResultEntity implements ChatFetchEmojisResultEntity {
  const _ChatFetchEmojisResultEntity({required final  List<MessageEmojiEntity> emojis, required this.sequence}): _emojis = emojis;
  factory _ChatFetchEmojisResultEntity.fromJson(Map<String, dynamic> json) => _$ChatFetchEmojisResultEntityFromJson(json);

 final  List<MessageEmojiEntity> _emojis;
@override List<MessageEmojiEntity> get emojis {
  if (_emojis is EqualUnmodifiableListView) return _emojis;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_emojis);
}

@override final  int sequence;

/// Create a copy of ChatFetchEmojisResultEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatFetchEmojisResultEntityCopyWith<_ChatFetchEmojisResultEntity> get copyWith => __$ChatFetchEmojisResultEntityCopyWithImpl<_ChatFetchEmojisResultEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChatFetchEmojisResultEntityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatFetchEmojisResultEntity&&const DeepCollectionEquality().equals(other._emojis, _emojis)&&(identical(other.sequence, sequence) || other.sequence == sequence));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_emojis),sequence);

@override
String toString() {
  return 'ChatFetchEmojisResultEntity(emojis: $emojis, sequence: $sequence)';
}


}

/// @nodoc
abstract mixin class _$ChatFetchEmojisResultEntityCopyWith<$Res> implements $ChatFetchEmojisResultEntityCopyWith<$Res> {
  factory _$ChatFetchEmojisResultEntityCopyWith(_ChatFetchEmojisResultEntity value, $Res Function(_ChatFetchEmojisResultEntity) _then) = __$ChatFetchEmojisResultEntityCopyWithImpl;
@override @useResult
$Res call({
 List<MessageEmojiEntity> emojis, int sequence
});




}
/// @nodoc
class __$ChatFetchEmojisResultEntityCopyWithImpl<$Res>
    implements _$ChatFetchEmojisResultEntityCopyWith<$Res> {
  __$ChatFetchEmojisResultEntityCopyWithImpl(this._self, this._then);

  final _ChatFetchEmojisResultEntity _self;
  final $Res Function(_ChatFetchEmojisResultEntity) _then;

/// Create a copy of ChatFetchEmojisResultEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? emojis = null,Object? sequence = null,}) {
  return _then(_ChatFetchEmojisResultEntity(
emojis: null == emojis ? _self._emojis : emojis // ignore: cast_nullable_to_non_nullable
as List<MessageEmojiEntity>,sequence: null == sequence ? _self.sequence : sequence // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
