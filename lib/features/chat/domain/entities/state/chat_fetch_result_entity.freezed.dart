// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_fetch_result_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ChatFetchResultEntity {

 List<MessageEntity> get messages; bool get hasMore; MessageChannelEntity? get channel; String? get nextCursor; bool? get hasRecent; bool? get isRateLimited; Map<String, String?>? get nextPageTokens; int? get sequence;
/// Create a copy of ChatFetchResultEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatFetchResultEntityCopyWith<ChatFetchResultEntity> get copyWith => _$ChatFetchResultEntityCopyWithImpl<ChatFetchResultEntity>(this as ChatFetchResultEntity, _$identity);

  /// Serializes this ChatFetchResultEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatFetchResultEntity&&const DeepCollectionEquality().equals(other.messages, messages)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore)&&(identical(other.channel, channel) || other.channel == channel)&&(identical(other.nextCursor, nextCursor) || other.nextCursor == nextCursor)&&(identical(other.hasRecent, hasRecent) || other.hasRecent == hasRecent)&&(identical(other.isRateLimited, isRateLimited) || other.isRateLimited == isRateLimited)&&const DeepCollectionEquality().equals(other.nextPageTokens, nextPageTokens)&&(identical(other.sequence, sequence) || other.sequence == sequence));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(messages),hasMore,channel,nextCursor,hasRecent,isRateLimited,const DeepCollectionEquality().hash(nextPageTokens),sequence);

@override
String toString() {
  return 'ChatFetchResultEntity(messages: $messages, hasMore: $hasMore, channel: $channel, nextCursor: $nextCursor, hasRecent: $hasRecent, isRateLimited: $isRateLimited, nextPageTokens: $nextPageTokens, sequence: $sequence)';
}


}

/// @nodoc
abstract mixin class $ChatFetchResultEntityCopyWith<$Res>  {
  factory $ChatFetchResultEntityCopyWith(ChatFetchResultEntity value, $Res Function(ChatFetchResultEntity) _then) = _$ChatFetchResultEntityCopyWithImpl;
@useResult
$Res call({
 List<MessageEntity> messages, bool hasMore, MessageChannelEntity? channel, String? nextCursor, bool? hasRecent, bool? isRateLimited, Map<String, String?>? nextPageTokens, int? sequence
});




}
/// @nodoc
class _$ChatFetchResultEntityCopyWithImpl<$Res>
    implements $ChatFetchResultEntityCopyWith<$Res> {
  _$ChatFetchResultEntityCopyWithImpl(this._self, this._then);

  final ChatFetchResultEntity _self;
  final $Res Function(ChatFetchResultEntity) _then;

/// Create a copy of ChatFetchResultEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? messages = null,Object? hasMore = null,Object? channel = freezed,Object? nextCursor = freezed,Object? hasRecent = freezed,Object? isRateLimited = freezed,Object? nextPageTokens = freezed,Object? sequence = freezed,}) {
  return _then(_self.copyWith(
messages: null == messages ? _self.messages : messages // ignore: cast_nullable_to_non_nullable
as List<MessageEntity>,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,channel: freezed == channel ? _self.channel : channel // ignore: cast_nullable_to_non_nullable
as MessageChannelEntity?,nextCursor: freezed == nextCursor ? _self.nextCursor : nextCursor // ignore: cast_nullable_to_non_nullable
as String?,hasRecent: freezed == hasRecent ? _self.hasRecent : hasRecent // ignore: cast_nullable_to_non_nullable
as bool?,isRateLimited: freezed == isRateLimited ? _self.isRateLimited : isRateLimited // ignore: cast_nullable_to_non_nullable
as bool?,nextPageTokens: freezed == nextPageTokens ? _self.nextPageTokens : nextPageTokens // ignore: cast_nullable_to_non_nullable
as Map<String, String?>?,sequence: freezed == sequence ? _self.sequence : sequence // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [ChatFetchResultEntity].
extension ChatFetchResultEntityPatterns on ChatFetchResultEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatFetchResultEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatFetchResultEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatFetchResultEntity value)  $default,){
final _that = this;
switch (_that) {
case _ChatFetchResultEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatFetchResultEntity value)?  $default,){
final _that = this;
switch (_that) {
case _ChatFetchResultEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<MessageEntity> messages,  bool hasMore,  MessageChannelEntity? channel,  String? nextCursor,  bool? hasRecent,  bool? isRateLimited,  Map<String, String?>? nextPageTokens,  int? sequence)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatFetchResultEntity() when $default != null:
return $default(_that.messages,_that.hasMore,_that.channel,_that.nextCursor,_that.hasRecent,_that.isRateLimited,_that.nextPageTokens,_that.sequence);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<MessageEntity> messages,  bool hasMore,  MessageChannelEntity? channel,  String? nextCursor,  bool? hasRecent,  bool? isRateLimited,  Map<String, String?>? nextPageTokens,  int? sequence)  $default,) {final _that = this;
switch (_that) {
case _ChatFetchResultEntity():
return $default(_that.messages,_that.hasMore,_that.channel,_that.nextCursor,_that.hasRecent,_that.isRateLimited,_that.nextPageTokens,_that.sequence);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<MessageEntity> messages,  bool hasMore,  MessageChannelEntity? channel,  String? nextCursor,  bool? hasRecent,  bool? isRateLimited,  Map<String, String?>? nextPageTokens,  int? sequence)?  $default,) {final _that = this;
switch (_that) {
case _ChatFetchResultEntity() when $default != null:
return $default(_that.messages,_that.hasMore,_that.channel,_that.nextCursor,_that.hasRecent,_that.isRateLimited,_that.nextPageTokens,_that.sequence);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _ChatFetchResultEntity implements ChatFetchResultEntity {
  const _ChatFetchResultEntity({required final  List<MessageEntity> messages, required this.hasMore, this.channel, this.nextCursor, this.hasRecent, this.isRateLimited, final  Map<String, String?>? nextPageTokens, this.sequence}): _messages = messages,_nextPageTokens = nextPageTokens;
  factory _ChatFetchResultEntity.fromJson(Map<String, dynamic> json) => _$ChatFetchResultEntityFromJson(json);

 final  List<MessageEntity> _messages;
@override List<MessageEntity> get messages {
  if (_messages is EqualUnmodifiableListView) return _messages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_messages);
}

@override final  bool hasMore;
@override final  MessageChannelEntity? channel;
@override final  String? nextCursor;
@override final  bool? hasRecent;
@override final  bool? isRateLimited;
 final  Map<String, String?>? _nextPageTokens;
@override Map<String, String?>? get nextPageTokens {
  final value = _nextPageTokens;
  if (value == null) return null;
  if (_nextPageTokens is EqualUnmodifiableMapView) return _nextPageTokens;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override final  int? sequence;

/// Create a copy of ChatFetchResultEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatFetchResultEntityCopyWith<_ChatFetchResultEntity> get copyWith => __$ChatFetchResultEntityCopyWithImpl<_ChatFetchResultEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChatFetchResultEntityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatFetchResultEntity&&const DeepCollectionEquality().equals(other._messages, _messages)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore)&&(identical(other.channel, channel) || other.channel == channel)&&(identical(other.nextCursor, nextCursor) || other.nextCursor == nextCursor)&&(identical(other.hasRecent, hasRecent) || other.hasRecent == hasRecent)&&(identical(other.isRateLimited, isRateLimited) || other.isRateLimited == isRateLimited)&&const DeepCollectionEquality().equals(other._nextPageTokens, _nextPageTokens)&&(identical(other.sequence, sequence) || other.sequence == sequence));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_messages),hasMore,channel,nextCursor,hasRecent,isRateLimited,const DeepCollectionEquality().hash(_nextPageTokens),sequence);

@override
String toString() {
  return 'ChatFetchResultEntity(messages: $messages, hasMore: $hasMore, channel: $channel, nextCursor: $nextCursor, hasRecent: $hasRecent, isRateLimited: $isRateLimited, nextPageTokens: $nextPageTokens, sequence: $sequence)';
}


}

/// @nodoc
abstract mixin class _$ChatFetchResultEntityCopyWith<$Res> implements $ChatFetchResultEntityCopyWith<$Res> {
  factory _$ChatFetchResultEntityCopyWith(_ChatFetchResultEntity value, $Res Function(_ChatFetchResultEntity) _then) = __$ChatFetchResultEntityCopyWithImpl;
@override @useResult
$Res call({
 List<MessageEntity> messages, bool hasMore, MessageChannelEntity? channel, String? nextCursor, bool? hasRecent, bool? isRateLimited, Map<String, String?>? nextPageTokens, int? sequence
});




}
/// @nodoc
class __$ChatFetchResultEntityCopyWithImpl<$Res>
    implements _$ChatFetchResultEntityCopyWith<$Res> {
  __$ChatFetchResultEntityCopyWithImpl(this._self, this._then);

  final _ChatFetchResultEntity _self;
  final $Res Function(_ChatFetchResultEntity) _then;

/// Create a copy of ChatFetchResultEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? messages = null,Object? hasMore = null,Object? channel = freezed,Object? nextCursor = freezed,Object? hasRecent = freezed,Object? isRateLimited = freezed,Object? nextPageTokens = freezed,Object? sequence = freezed,}) {
  return _then(_ChatFetchResultEntity(
messages: null == messages ? _self._messages : messages // ignore: cast_nullable_to_non_nullable
as List<MessageEntity>,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,channel: freezed == channel ? _self.channel : channel // ignore: cast_nullable_to_non_nullable
as MessageChannelEntity?,nextCursor: freezed == nextCursor ? _self.nextCursor : nextCursor // ignore: cast_nullable_to_non_nullable
as String?,hasRecent: freezed == hasRecent ? _self.hasRecent : hasRecent // ignore: cast_nullable_to_non_nullable
as bool?,isRateLimited: freezed == isRateLimited ? _self.isRateLimited : isRateLimited // ignore: cast_nullable_to_non_nullable
as bool?,nextPageTokens: freezed == nextPageTokens ? _self._nextPageTokens : nextPageTokens // ignore: cast_nullable_to_non_nullable
as Map<String, String?>?,sequence: freezed == sequence ? _self.sequence : sequence // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
