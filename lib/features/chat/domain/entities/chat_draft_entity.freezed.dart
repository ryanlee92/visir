// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_draft_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ChatDraftEntity {

 String get id; String get teamId; String get channelId; String? get threadId; String get content; String? get editingMessageId;
/// Create a copy of ChatDraftEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatDraftEntityCopyWith<ChatDraftEntity> get copyWith => _$ChatDraftEntityCopyWithImpl<ChatDraftEntity>(this as ChatDraftEntity, _$identity);

  /// Serializes this ChatDraftEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatDraftEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.teamId, teamId) || other.teamId == teamId)&&(identical(other.channelId, channelId) || other.channelId == channelId)&&(identical(other.threadId, threadId) || other.threadId == threadId)&&(identical(other.content, content) || other.content == content)&&(identical(other.editingMessageId, editingMessageId) || other.editingMessageId == editingMessageId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,teamId,channelId,threadId,content,editingMessageId);

@override
String toString() {
  return 'ChatDraftEntity(id: $id, teamId: $teamId, channelId: $channelId, threadId: $threadId, content: $content, editingMessageId: $editingMessageId)';
}


}

/// @nodoc
abstract mixin class $ChatDraftEntityCopyWith<$Res>  {
  factory $ChatDraftEntityCopyWith(ChatDraftEntity value, $Res Function(ChatDraftEntity) _then) = _$ChatDraftEntityCopyWithImpl;
@useResult
$Res call({
 String id, String teamId, String channelId, String? threadId, String content, String? editingMessageId
});




}
/// @nodoc
class _$ChatDraftEntityCopyWithImpl<$Res>
    implements $ChatDraftEntityCopyWith<$Res> {
  _$ChatDraftEntityCopyWithImpl(this._self, this._then);

  final ChatDraftEntity _self;
  final $Res Function(ChatDraftEntity) _then;

/// Create a copy of ChatDraftEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? teamId = null,Object? channelId = null,Object? threadId = freezed,Object? content = null,Object? editingMessageId = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,teamId: null == teamId ? _self.teamId : teamId // ignore: cast_nullable_to_non_nullable
as String,channelId: null == channelId ? _self.channelId : channelId // ignore: cast_nullable_to_non_nullable
as String,threadId: freezed == threadId ? _self.threadId : threadId // ignore: cast_nullable_to_non_nullable
as String?,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,editingMessageId: freezed == editingMessageId ? _self.editingMessageId : editingMessageId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ChatDraftEntity].
extension ChatDraftEntityPatterns on ChatDraftEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatDraftEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatDraftEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatDraftEntity value)  $default,){
final _that = this;
switch (_that) {
case _ChatDraftEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatDraftEntity value)?  $default,){
final _that = this;
switch (_that) {
case _ChatDraftEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String teamId,  String channelId,  String? threadId,  String content,  String? editingMessageId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatDraftEntity() when $default != null:
return $default(_that.id,_that.teamId,_that.channelId,_that.threadId,_that.content,_that.editingMessageId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String teamId,  String channelId,  String? threadId,  String content,  String? editingMessageId)  $default,) {final _that = this;
switch (_that) {
case _ChatDraftEntity():
return $default(_that.id,_that.teamId,_that.channelId,_that.threadId,_that.content,_that.editingMessageId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String teamId,  String channelId,  String? threadId,  String content,  String? editingMessageId)?  $default,) {final _that = this;
switch (_that) {
case _ChatDraftEntity() when $default != null:
return $default(_that.id,_that.teamId,_that.channelId,_that.threadId,_that.content,_that.editingMessageId);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _ChatDraftEntity implements ChatDraftEntity {
  const _ChatDraftEntity({required this.id, required this.teamId, required this.channelId, required this.threadId, required this.content, required this.editingMessageId});
  factory _ChatDraftEntity.fromJson(Map<String, dynamic> json) => _$ChatDraftEntityFromJson(json);

@override final  String id;
@override final  String teamId;
@override final  String channelId;
@override final  String? threadId;
@override final  String content;
@override final  String? editingMessageId;

/// Create a copy of ChatDraftEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatDraftEntityCopyWith<_ChatDraftEntity> get copyWith => __$ChatDraftEntityCopyWithImpl<_ChatDraftEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChatDraftEntityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatDraftEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.teamId, teamId) || other.teamId == teamId)&&(identical(other.channelId, channelId) || other.channelId == channelId)&&(identical(other.threadId, threadId) || other.threadId == threadId)&&(identical(other.content, content) || other.content == content)&&(identical(other.editingMessageId, editingMessageId) || other.editingMessageId == editingMessageId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,teamId,channelId,threadId,content,editingMessageId);

@override
String toString() {
  return 'ChatDraftEntity(id: $id, teamId: $teamId, channelId: $channelId, threadId: $threadId, content: $content, editingMessageId: $editingMessageId)';
}


}

/// @nodoc
abstract mixin class _$ChatDraftEntityCopyWith<$Res> implements $ChatDraftEntityCopyWith<$Res> {
  factory _$ChatDraftEntityCopyWith(_ChatDraftEntity value, $Res Function(_ChatDraftEntity) _then) = __$ChatDraftEntityCopyWithImpl;
@override @useResult
$Res call({
 String id, String teamId, String channelId, String? threadId, String content, String? editingMessageId
});




}
/// @nodoc
class __$ChatDraftEntityCopyWithImpl<$Res>
    implements _$ChatDraftEntityCopyWith<$Res> {
  __$ChatDraftEntityCopyWithImpl(this._self, this._then);

  final _ChatDraftEntity _self;
  final $Res Function(_ChatDraftEntity) _then;

/// Create a copy of ChatDraftEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? teamId = null,Object? channelId = null,Object? threadId = freezed,Object? content = null,Object? editingMessageId = freezed,}) {
  return _then(_ChatDraftEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,teamId: null == teamId ? _self.teamId : teamId // ignore: cast_nullable_to_non_nullable
as String,channelId: null == channelId ? _self.channelId : channelId // ignore: cast_nullable_to_non_nullable
as String,threadId: freezed == threadId ? _self.threadId : threadId // ignore: cast_nullable_to_non_nullable
as String?,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,editingMessageId: freezed == editingMessageId ? _self.editingMessageId : editingMessageId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
