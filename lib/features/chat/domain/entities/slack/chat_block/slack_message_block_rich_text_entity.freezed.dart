// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'slack_message_block_rich_text_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SlackMessageBlockElementEntity {

@JsonKey(includeIfNull: false) SlackMessageBlockElementEntityType? get type;@JsonKey(includeIfNull: false) List<SlackMessageBlockRichTextElementEntity>? get elements;@JsonKey(includeIfNull: false) String? get style;@JsonKey(includeIfNull: false) String? get imageUrl;@JsonKey(includeIfNull: false) String? get text;@JsonKey(includeIfNull: false) int? get indent;@JsonKey(includeIfNull: false) int? get offset;@JsonKey(includeIfNull: false) int? get border;
/// Create a copy of SlackMessageBlockElementEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SlackMessageBlockElementEntityCopyWith<SlackMessageBlockElementEntity> get copyWith => _$SlackMessageBlockElementEntityCopyWithImpl<SlackMessageBlockElementEntity>(this as SlackMessageBlockElementEntity, _$identity);

  /// Serializes this SlackMessageBlockElementEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SlackMessageBlockElementEntity&&(identical(other.type, type) || other.type == type)&&const DeepCollectionEquality().equals(other.elements, elements)&&(identical(other.style, style) || other.style == style)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.text, text) || other.text == text)&&(identical(other.indent, indent) || other.indent == indent)&&(identical(other.offset, offset) || other.offset == offset)&&(identical(other.border, border) || other.border == border));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,const DeepCollectionEquality().hash(elements),style,imageUrl,text,indent,offset,border);

@override
String toString() {
  return 'SlackMessageBlockElementEntity(type: $type, elements: $elements, style: $style, imageUrl: $imageUrl, text: $text, indent: $indent, offset: $offset, border: $border)';
}


}

/// @nodoc
abstract mixin class $SlackMessageBlockElementEntityCopyWith<$Res>  {
  factory $SlackMessageBlockElementEntityCopyWith(SlackMessageBlockElementEntity value, $Res Function(SlackMessageBlockElementEntity) _then) = _$SlackMessageBlockElementEntityCopyWithImpl;
@useResult
$Res call({
@JsonKey(includeIfNull: false) SlackMessageBlockElementEntityType? type,@JsonKey(includeIfNull: false) List<SlackMessageBlockRichTextElementEntity>? elements,@JsonKey(includeIfNull: false) String? style,@JsonKey(includeIfNull: false) String? imageUrl,@JsonKey(includeIfNull: false) String? text,@JsonKey(includeIfNull: false) int? indent,@JsonKey(includeIfNull: false) int? offset,@JsonKey(includeIfNull: false) int? border
});




}
/// @nodoc
class _$SlackMessageBlockElementEntityCopyWithImpl<$Res>
    implements $SlackMessageBlockElementEntityCopyWith<$Res> {
  _$SlackMessageBlockElementEntityCopyWithImpl(this._self, this._then);

  final SlackMessageBlockElementEntity _self;
  final $Res Function(SlackMessageBlockElementEntity) _then;

/// Create a copy of SlackMessageBlockElementEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = freezed,Object? elements = freezed,Object? style = freezed,Object? imageUrl = freezed,Object? text = freezed,Object? indent = freezed,Object? offset = freezed,Object? border = freezed,}) {
  return _then(_self.copyWith(
type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as SlackMessageBlockElementEntityType?,elements: freezed == elements ? _self.elements : elements // ignore: cast_nullable_to_non_nullable
as List<SlackMessageBlockRichTextElementEntity>?,style: freezed == style ? _self.style : style // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,text: freezed == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String?,indent: freezed == indent ? _self.indent : indent // ignore: cast_nullable_to_non_nullable
as int?,offset: freezed == offset ? _self.offset : offset // ignore: cast_nullable_to_non_nullable
as int?,border: freezed == border ? _self.border : border // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [SlackMessageBlockElementEntity].
extension SlackMessageBlockElementEntityPatterns on SlackMessageBlockElementEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SlackMessageBlockElementEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SlackMessageBlockElementEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SlackMessageBlockElementEntity value)  $default,){
final _that = this;
switch (_that) {
case _SlackMessageBlockElementEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SlackMessageBlockElementEntity value)?  $default,){
final _that = this;
switch (_that) {
case _SlackMessageBlockElementEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(includeIfNull: false)  SlackMessageBlockElementEntityType? type, @JsonKey(includeIfNull: false)  List<SlackMessageBlockRichTextElementEntity>? elements, @JsonKey(includeIfNull: false)  String? style, @JsonKey(includeIfNull: false)  String? imageUrl, @JsonKey(includeIfNull: false)  String? text, @JsonKey(includeIfNull: false)  int? indent, @JsonKey(includeIfNull: false)  int? offset, @JsonKey(includeIfNull: false)  int? border)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SlackMessageBlockElementEntity() when $default != null:
return $default(_that.type,_that.elements,_that.style,_that.imageUrl,_that.text,_that.indent,_that.offset,_that.border);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(includeIfNull: false)  SlackMessageBlockElementEntityType? type, @JsonKey(includeIfNull: false)  List<SlackMessageBlockRichTextElementEntity>? elements, @JsonKey(includeIfNull: false)  String? style, @JsonKey(includeIfNull: false)  String? imageUrl, @JsonKey(includeIfNull: false)  String? text, @JsonKey(includeIfNull: false)  int? indent, @JsonKey(includeIfNull: false)  int? offset, @JsonKey(includeIfNull: false)  int? border)  $default,) {final _that = this;
switch (_that) {
case _SlackMessageBlockElementEntity():
return $default(_that.type,_that.elements,_that.style,_that.imageUrl,_that.text,_that.indent,_that.offset,_that.border);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(includeIfNull: false)  SlackMessageBlockElementEntityType? type, @JsonKey(includeIfNull: false)  List<SlackMessageBlockRichTextElementEntity>? elements, @JsonKey(includeIfNull: false)  String? style, @JsonKey(includeIfNull: false)  String? imageUrl, @JsonKey(includeIfNull: false)  String? text, @JsonKey(includeIfNull: false)  int? indent, @JsonKey(includeIfNull: false)  int? offset, @JsonKey(includeIfNull: false)  int? border)?  $default,) {final _that = this;
switch (_that) {
case _SlackMessageBlockElementEntity() when $default != null:
return $default(_that.type,_that.elements,_that.style,_that.imageUrl,_that.text,_that.indent,_that.offset,_that.border);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _SlackMessageBlockElementEntity implements SlackMessageBlockElementEntity {
  const _SlackMessageBlockElementEntity({@JsonKey(includeIfNull: false) this.type, @JsonKey(includeIfNull: false) final  List<SlackMessageBlockRichTextElementEntity>? elements, @JsonKey(includeIfNull: false) this.style, @JsonKey(includeIfNull: false) this.imageUrl, @JsonKey(includeIfNull: false) this.text, @JsonKey(includeIfNull: false) this.indent, @JsonKey(includeIfNull: false) this.offset, @JsonKey(includeIfNull: false) this.border}): _elements = elements;
  factory _SlackMessageBlockElementEntity.fromJson(Map<String, dynamic> json) => _$SlackMessageBlockElementEntityFromJson(json);

@override@JsonKey(includeIfNull: false) final  SlackMessageBlockElementEntityType? type;
 final  List<SlackMessageBlockRichTextElementEntity>? _elements;
@override@JsonKey(includeIfNull: false) List<SlackMessageBlockRichTextElementEntity>? get elements {
  final value = _elements;
  if (value == null) return null;
  if (_elements is EqualUnmodifiableListView) return _elements;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override@JsonKey(includeIfNull: false) final  String? style;
@override@JsonKey(includeIfNull: false) final  String? imageUrl;
@override@JsonKey(includeIfNull: false) final  String? text;
@override@JsonKey(includeIfNull: false) final  int? indent;
@override@JsonKey(includeIfNull: false) final  int? offset;
@override@JsonKey(includeIfNull: false) final  int? border;

/// Create a copy of SlackMessageBlockElementEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SlackMessageBlockElementEntityCopyWith<_SlackMessageBlockElementEntity> get copyWith => __$SlackMessageBlockElementEntityCopyWithImpl<_SlackMessageBlockElementEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SlackMessageBlockElementEntityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SlackMessageBlockElementEntity&&(identical(other.type, type) || other.type == type)&&const DeepCollectionEquality().equals(other._elements, _elements)&&(identical(other.style, style) || other.style == style)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.text, text) || other.text == text)&&(identical(other.indent, indent) || other.indent == indent)&&(identical(other.offset, offset) || other.offset == offset)&&(identical(other.border, border) || other.border == border));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,const DeepCollectionEquality().hash(_elements),style,imageUrl,text,indent,offset,border);

@override
String toString() {
  return 'SlackMessageBlockElementEntity(type: $type, elements: $elements, style: $style, imageUrl: $imageUrl, text: $text, indent: $indent, offset: $offset, border: $border)';
}


}

/// @nodoc
abstract mixin class _$SlackMessageBlockElementEntityCopyWith<$Res> implements $SlackMessageBlockElementEntityCopyWith<$Res> {
  factory _$SlackMessageBlockElementEntityCopyWith(_SlackMessageBlockElementEntity value, $Res Function(_SlackMessageBlockElementEntity) _then) = __$SlackMessageBlockElementEntityCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(includeIfNull: false) SlackMessageBlockElementEntityType? type,@JsonKey(includeIfNull: false) List<SlackMessageBlockRichTextElementEntity>? elements,@JsonKey(includeIfNull: false) String? style,@JsonKey(includeIfNull: false) String? imageUrl,@JsonKey(includeIfNull: false) String? text,@JsonKey(includeIfNull: false) int? indent,@JsonKey(includeIfNull: false) int? offset,@JsonKey(includeIfNull: false) int? border
});




}
/// @nodoc
class __$SlackMessageBlockElementEntityCopyWithImpl<$Res>
    implements _$SlackMessageBlockElementEntityCopyWith<$Res> {
  __$SlackMessageBlockElementEntityCopyWithImpl(this._self, this._then);

  final _SlackMessageBlockElementEntity _self;
  final $Res Function(_SlackMessageBlockElementEntity) _then;

/// Create a copy of SlackMessageBlockElementEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = freezed,Object? elements = freezed,Object? style = freezed,Object? imageUrl = freezed,Object? text = freezed,Object? indent = freezed,Object? offset = freezed,Object? border = freezed,}) {
  return _then(_SlackMessageBlockElementEntity(
type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as SlackMessageBlockElementEntityType?,elements: freezed == elements ? _self._elements : elements // ignore: cast_nullable_to_non_nullable
as List<SlackMessageBlockRichTextElementEntity>?,style: freezed == style ? _self.style : style // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,text: freezed == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String?,indent: freezed == indent ? _self.indent : indent // ignore: cast_nullable_to_non_nullable
as int?,offset: freezed == offset ? _self.offset : offset // ignore: cast_nullable_to_non_nullable
as int?,border: freezed == border ? _self.border : border // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
