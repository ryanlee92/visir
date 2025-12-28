// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'slack_message_block_text_object_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SlackMessageBlockTextObjectEntity {

@JsonKey(includeIfNull: false) SlackMessageBlockTextObjectEntityType? get type;@JsonKey(includeIfNull: false) String? get text;@JsonKey(includeIfNull: false) bool? get emoji;@JsonKey(includeIfNull: false) bool? get verbatim;
/// Create a copy of SlackMessageBlockTextObjectEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SlackMessageBlockTextObjectEntityCopyWith<SlackMessageBlockTextObjectEntity> get copyWith => _$SlackMessageBlockTextObjectEntityCopyWithImpl<SlackMessageBlockTextObjectEntity>(this as SlackMessageBlockTextObjectEntity, _$identity);

  /// Serializes this SlackMessageBlockTextObjectEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SlackMessageBlockTextObjectEntity&&(identical(other.type, type) || other.type == type)&&(identical(other.text, text) || other.text == text)&&(identical(other.emoji, emoji) || other.emoji == emoji)&&(identical(other.verbatim, verbatim) || other.verbatim == verbatim));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,text,emoji,verbatim);

@override
String toString() {
  return 'SlackMessageBlockTextObjectEntity(type: $type, text: $text, emoji: $emoji, verbatim: $verbatim)';
}


}

/// @nodoc
abstract mixin class $SlackMessageBlockTextObjectEntityCopyWith<$Res>  {
  factory $SlackMessageBlockTextObjectEntityCopyWith(SlackMessageBlockTextObjectEntity value, $Res Function(SlackMessageBlockTextObjectEntity) _then) = _$SlackMessageBlockTextObjectEntityCopyWithImpl;
@useResult
$Res call({
@JsonKey(includeIfNull: false) SlackMessageBlockTextObjectEntityType? type,@JsonKey(includeIfNull: false) String? text,@JsonKey(includeIfNull: false) bool? emoji,@JsonKey(includeIfNull: false) bool? verbatim
});




}
/// @nodoc
class _$SlackMessageBlockTextObjectEntityCopyWithImpl<$Res>
    implements $SlackMessageBlockTextObjectEntityCopyWith<$Res> {
  _$SlackMessageBlockTextObjectEntityCopyWithImpl(this._self, this._then);

  final SlackMessageBlockTextObjectEntity _self;
  final $Res Function(SlackMessageBlockTextObjectEntity) _then;

/// Create a copy of SlackMessageBlockTextObjectEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = freezed,Object? text = freezed,Object? emoji = freezed,Object? verbatim = freezed,}) {
  return _then(_self.copyWith(
type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as SlackMessageBlockTextObjectEntityType?,text: freezed == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String?,emoji: freezed == emoji ? _self.emoji : emoji // ignore: cast_nullable_to_non_nullable
as bool?,verbatim: freezed == verbatim ? _self.verbatim : verbatim // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}

}


/// Adds pattern-matching-related methods to [SlackMessageBlockTextObjectEntity].
extension SlackMessageBlockTextObjectEntityPatterns on SlackMessageBlockTextObjectEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SlackMessageBlockTextObjectEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SlackMessageBlockTextObjectEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SlackMessageBlockTextObjectEntity value)  $default,){
final _that = this;
switch (_that) {
case _SlackMessageBlockTextObjectEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SlackMessageBlockTextObjectEntity value)?  $default,){
final _that = this;
switch (_that) {
case _SlackMessageBlockTextObjectEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(includeIfNull: false)  SlackMessageBlockTextObjectEntityType? type, @JsonKey(includeIfNull: false)  String? text, @JsonKey(includeIfNull: false)  bool? emoji, @JsonKey(includeIfNull: false)  bool? verbatim)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SlackMessageBlockTextObjectEntity() when $default != null:
return $default(_that.type,_that.text,_that.emoji,_that.verbatim);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(includeIfNull: false)  SlackMessageBlockTextObjectEntityType? type, @JsonKey(includeIfNull: false)  String? text, @JsonKey(includeIfNull: false)  bool? emoji, @JsonKey(includeIfNull: false)  bool? verbatim)  $default,) {final _that = this;
switch (_that) {
case _SlackMessageBlockTextObjectEntity():
return $default(_that.type,_that.text,_that.emoji,_that.verbatim);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(includeIfNull: false)  SlackMessageBlockTextObjectEntityType? type, @JsonKey(includeIfNull: false)  String? text, @JsonKey(includeIfNull: false)  bool? emoji, @JsonKey(includeIfNull: false)  bool? verbatim)?  $default,) {final _that = this;
switch (_that) {
case _SlackMessageBlockTextObjectEntity() when $default != null:
return $default(_that.type,_that.text,_that.emoji,_that.verbatim);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _SlackMessageBlockTextObjectEntity implements SlackMessageBlockTextObjectEntity {
  const _SlackMessageBlockTextObjectEntity({@JsonKey(includeIfNull: false) this.type, @JsonKey(includeIfNull: false) this.text, @JsonKey(includeIfNull: false) this.emoji, @JsonKey(includeIfNull: false) this.verbatim});
  factory _SlackMessageBlockTextObjectEntity.fromJson(Map<String, dynamic> json) => _$SlackMessageBlockTextObjectEntityFromJson(json);

@override@JsonKey(includeIfNull: false) final  SlackMessageBlockTextObjectEntityType? type;
@override@JsonKey(includeIfNull: false) final  String? text;
@override@JsonKey(includeIfNull: false) final  bool? emoji;
@override@JsonKey(includeIfNull: false) final  bool? verbatim;

/// Create a copy of SlackMessageBlockTextObjectEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SlackMessageBlockTextObjectEntityCopyWith<_SlackMessageBlockTextObjectEntity> get copyWith => __$SlackMessageBlockTextObjectEntityCopyWithImpl<_SlackMessageBlockTextObjectEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SlackMessageBlockTextObjectEntityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SlackMessageBlockTextObjectEntity&&(identical(other.type, type) || other.type == type)&&(identical(other.text, text) || other.text == text)&&(identical(other.emoji, emoji) || other.emoji == emoji)&&(identical(other.verbatim, verbatim) || other.verbatim == verbatim));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,text,emoji,verbatim);

@override
String toString() {
  return 'SlackMessageBlockTextObjectEntity(type: $type, text: $text, emoji: $emoji, verbatim: $verbatim)';
}


}

/// @nodoc
abstract mixin class _$SlackMessageBlockTextObjectEntityCopyWith<$Res> implements $SlackMessageBlockTextObjectEntityCopyWith<$Res> {
  factory _$SlackMessageBlockTextObjectEntityCopyWith(_SlackMessageBlockTextObjectEntity value, $Res Function(_SlackMessageBlockTextObjectEntity) _then) = __$SlackMessageBlockTextObjectEntityCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(includeIfNull: false) SlackMessageBlockTextObjectEntityType? type,@JsonKey(includeIfNull: false) String? text,@JsonKey(includeIfNull: false) bool? emoji,@JsonKey(includeIfNull: false) bool? verbatim
});




}
/// @nodoc
class __$SlackMessageBlockTextObjectEntityCopyWithImpl<$Res>
    implements _$SlackMessageBlockTextObjectEntityCopyWith<$Res> {
  __$SlackMessageBlockTextObjectEntityCopyWithImpl(this._self, this._then);

  final _SlackMessageBlockTextObjectEntity _self;
  final $Res Function(_SlackMessageBlockTextObjectEntity) _then;

/// Create a copy of SlackMessageBlockTextObjectEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = freezed,Object? text = freezed,Object? emoji = freezed,Object? verbatim = freezed,}) {
  return _then(_SlackMessageBlockTextObjectEntity(
type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as SlackMessageBlockTextObjectEntityType?,text: freezed == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String?,emoji: freezed == emoji ? _self.emoji : emoji // ignore: cast_nullable_to_non_nullable
as bool?,verbatim: freezed == verbatim ? _self.verbatim : verbatim // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}


}

// dart format on
