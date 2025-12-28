// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'mail_fetch_result_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MailFetchResultEntity {

 List<MailEntity> get messages; bool get hasMore; String? get nextPageToken; bool? get hasRecent; bool? get isRateLimited;
/// Create a copy of MailFetchResultEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MailFetchResultEntityCopyWith<MailFetchResultEntity> get copyWith => _$MailFetchResultEntityCopyWithImpl<MailFetchResultEntity>(this as MailFetchResultEntity, _$identity);

  /// Serializes this MailFetchResultEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MailFetchResultEntity&&const DeepCollectionEquality().equals(other.messages, messages)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore)&&(identical(other.nextPageToken, nextPageToken) || other.nextPageToken == nextPageToken)&&(identical(other.hasRecent, hasRecent) || other.hasRecent == hasRecent)&&(identical(other.isRateLimited, isRateLimited) || other.isRateLimited == isRateLimited));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(messages),hasMore,nextPageToken,hasRecent,isRateLimited);

@override
String toString() {
  return 'MailFetchResultEntity(messages: $messages, hasMore: $hasMore, nextPageToken: $nextPageToken, hasRecent: $hasRecent, isRateLimited: $isRateLimited)';
}


}

/// @nodoc
abstract mixin class $MailFetchResultEntityCopyWith<$Res>  {
  factory $MailFetchResultEntityCopyWith(MailFetchResultEntity value, $Res Function(MailFetchResultEntity) _then) = _$MailFetchResultEntityCopyWithImpl;
@useResult
$Res call({
 List<MailEntity> messages, bool hasMore, String? nextPageToken, bool? hasRecent, bool? isRateLimited
});




}
/// @nodoc
class _$MailFetchResultEntityCopyWithImpl<$Res>
    implements $MailFetchResultEntityCopyWith<$Res> {
  _$MailFetchResultEntityCopyWithImpl(this._self, this._then);

  final MailFetchResultEntity _self;
  final $Res Function(MailFetchResultEntity) _then;

/// Create a copy of MailFetchResultEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? messages = null,Object? hasMore = null,Object? nextPageToken = freezed,Object? hasRecent = freezed,Object? isRateLimited = freezed,}) {
  return _then(_self.copyWith(
messages: null == messages ? _self.messages : messages // ignore: cast_nullable_to_non_nullable
as List<MailEntity>,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,nextPageToken: freezed == nextPageToken ? _self.nextPageToken : nextPageToken // ignore: cast_nullable_to_non_nullable
as String?,hasRecent: freezed == hasRecent ? _self.hasRecent : hasRecent // ignore: cast_nullable_to_non_nullable
as bool?,isRateLimited: freezed == isRateLimited ? _self.isRateLimited : isRateLimited // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}

}


/// Adds pattern-matching-related methods to [MailFetchResultEntity].
extension MailFetchResultEntityPatterns on MailFetchResultEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MailFetchResultEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MailFetchResultEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MailFetchResultEntity value)  $default,){
final _that = this;
switch (_that) {
case _MailFetchResultEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MailFetchResultEntity value)?  $default,){
final _that = this;
switch (_that) {
case _MailFetchResultEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<MailEntity> messages,  bool hasMore,  String? nextPageToken,  bool? hasRecent,  bool? isRateLimited)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MailFetchResultEntity() when $default != null:
return $default(_that.messages,_that.hasMore,_that.nextPageToken,_that.hasRecent,_that.isRateLimited);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<MailEntity> messages,  bool hasMore,  String? nextPageToken,  bool? hasRecent,  bool? isRateLimited)  $default,) {final _that = this;
switch (_that) {
case _MailFetchResultEntity():
return $default(_that.messages,_that.hasMore,_that.nextPageToken,_that.hasRecent,_that.isRateLimited);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<MailEntity> messages,  bool hasMore,  String? nextPageToken,  bool? hasRecent,  bool? isRateLimited)?  $default,) {final _that = this;
switch (_that) {
case _MailFetchResultEntity() when $default != null:
return $default(_that.messages,_that.hasMore,_that.nextPageToken,_that.hasRecent,_that.isRateLimited);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _MailFetchResultEntity implements MailFetchResultEntity {
  const _MailFetchResultEntity({required final  List<MailEntity> messages, required this.hasMore, this.nextPageToken, this.hasRecent, this.isRateLimited}): _messages = messages;
  factory _MailFetchResultEntity.fromJson(Map<String, dynamic> json) => _$MailFetchResultEntityFromJson(json);

 final  List<MailEntity> _messages;
@override List<MailEntity> get messages {
  if (_messages is EqualUnmodifiableListView) return _messages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_messages);
}

@override final  bool hasMore;
@override final  String? nextPageToken;
@override final  bool? hasRecent;
@override final  bool? isRateLimited;

/// Create a copy of MailFetchResultEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MailFetchResultEntityCopyWith<_MailFetchResultEntity> get copyWith => __$MailFetchResultEntityCopyWithImpl<_MailFetchResultEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MailFetchResultEntityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MailFetchResultEntity&&const DeepCollectionEquality().equals(other._messages, _messages)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore)&&(identical(other.nextPageToken, nextPageToken) || other.nextPageToken == nextPageToken)&&(identical(other.hasRecent, hasRecent) || other.hasRecent == hasRecent)&&(identical(other.isRateLimited, isRateLimited) || other.isRateLimited == isRateLimited));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_messages),hasMore,nextPageToken,hasRecent,isRateLimited);

@override
String toString() {
  return 'MailFetchResultEntity(messages: $messages, hasMore: $hasMore, nextPageToken: $nextPageToken, hasRecent: $hasRecent, isRateLimited: $isRateLimited)';
}


}

/// @nodoc
abstract mixin class _$MailFetchResultEntityCopyWith<$Res> implements $MailFetchResultEntityCopyWith<$Res> {
  factory _$MailFetchResultEntityCopyWith(_MailFetchResultEntity value, $Res Function(_MailFetchResultEntity) _then) = __$MailFetchResultEntityCopyWithImpl;
@override @useResult
$Res call({
 List<MailEntity> messages, bool hasMore, String? nextPageToken, bool? hasRecent, bool? isRateLimited
});




}
/// @nodoc
class __$MailFetchResultEntityCopyWithImpl<$Res>
    implements _$MailFetchResultEntityCopyWith<$Res> {
  __$MailFetchResultEntityCopyWithImpl(this._self, this._then);

  final _MailFetchResultEntity _self;
  final $Res Function(_MailFetchResultEntity) _then;

/// Create a copy of MailFetchResultEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? messages = null,Object? hasMore = null,Object? nextPageToken = freezed,Object? hasRecent = freezed,Object? isRateLimited = freezed,}) {
  return _then(_MailFetchResultEntity(
messages: null == messages ? _self._messages : messages // ignore: cast_nullable_to_non_nullable
as List<MailEntity>,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,nextPageToken: freezed == nextPageToken ? _self.nextPageToken : nextPageToken // ignore: cast_nullable_to_non_nullable
as String?,hasRecent: freezed == hasRecent ? _self.hasRecent : hasRecent // ignore: cast_nullable_to_non_nullable
as bool?,isRateLimited: freezed == isRateLimited ? _self.isRateLimited : isRateLimited // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}


}

// dart format on
