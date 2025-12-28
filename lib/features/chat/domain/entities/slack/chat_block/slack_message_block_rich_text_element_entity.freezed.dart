// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'slack_message_block_rich_text_element_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SlackMessageBlockRichTextElementEntity {

@JsonKey(includeIfNull: false, unknownEnumValue: null) SlackMessageBlockRichTextElementEntityType? get type;@JsonKey(includeIfNull: false) Map<String, bool>? get style;@JsonKey(includeIfNull: false) String? get name;@JsonKey(includeIfNull: false) String? get unicode;@JsonKey(includeIfNull: false) String? get url;@JsonKey(includeIfNull: false) String? get text;@JsonKey(includeIfNull: false) bool? get unsafe;@JsonKey(includeIfNull: false) String? get userId;@JsonKey(includeIfNull: false) String? get usergroupId;@JsonKey(includeIfNull: false) String? get channelId;@JsonKey(includeIfNull: false) String? get range;@JsonKey(includeIfNull: false) String? get fallback;@JsonKey(includeIfNull: false) String? get value;@JsonKey(includeIfNull: false) List<Map<String, dynamic>>? get elements;@JsonKey(includeIfNull: false) int? get indent;@JsonKey(includeIfNull: false) int? get offset;
/// Create a copy of SlackMessageBlockRichTextElementEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SlackMessageBlockRichTextElementEntityCopyWith<SlackMessageBlockRichTextElementEntity> get copyWith => _$SlackMessageBlockRichTextElementEntityCopyWithImpl<SlackMessageBlockRichTextElementEntity>(this as SlackMessageBlockRichTextElementEntity, _$identity);

  /// Serializes this SlackMessageBlockRichTextElementEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SlackMessageBlockRichTextElementEntity&&(identical(other.type, type) || other.type == type)&&const DeepCollectionEquality().equals(other.style, style)&&(identical(other.name, name) || other.name == name)&&(identical(other.unicode, unicode) || other.unicode == unicode)&&(identical(other.url, url) || other.url == url)&&(identical(other.text, text) || other.text == text)&&(identical(other.unsafe, unsafe) || other.unsafe == unsafe)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.usergroupId, usergroupId) || other.usergroupId == usergroupId)&&(identical(other.channelId, channelId) || other.channelId == channelId)&&(identical(other.range, range) || other.range == range)&&(identical(other.fallback, fallback) || other.fallback == fallback)&&(identical(other.value, value) || other.value == value)&&const DeepCollectionEquality().equals(other.elements, elements)&&(identical(other.indent, indent) || other.indent == indent)&&(identical(other.offset, offset) || other.offset == offset));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,const DeepCollectionEquality().hash(style),name,unicode,url,text,unsafe,userId,usergroupId,channelId,range,fallback,value,const DeepCollectionEquality().hash(elements),indent,offset);

@override
String toString() {
  return 'SlackMessageBlockRichTextElementEntity(type: $type, style: $style, name: $name, unicode: $unicode, url: $url, text: $text, unsafe: $unsafe, userId: $userId, usergroupId: $usergroupId, channelId: $channelId, range: $range, fallback: $fallback, value: $value, elements: $elements, indent: $indent, offset: $offset)';
}


}

/// @nodoc
abstract mixin class $SlackMessageBlockRichTextElementEntityCopyWith<$Res>  {
  factory $SlackMessageBlockRichTextElementEntityCopyWith(SlackMessageBlockRichTextElementEntity value, $Res Function(SlackMessageBlockRichTextElementEntity) _then) = _$SlackMessageBlockRichTextElementEntityCopyWithImpl;
@useResult
$Res call({
@JsonKey(includeIfNull: false, unknownEnumValue: null) SlackMessageBlockRichTextElementEntityType? type,@JsonKey(includeIfNull: false) Map<String, bool>? style,@JsonKey(includeIfNull: false) String? name,@JsonKey(includeIfNull: false) String? unicode,@JsonKey(includeIfNull: false) String? url,@JsonKey(includeIfNull: false) String? text,@JsonKey(includeIfNull: false) bool? unsafe,@JsonKey(includeIfNull: false) String? userId,@JsonKey(includeIfNull: false) String? usergroupId,@JsonKey(includeIfNull: false) String? channelId,@JsonKey(includeIfNull: false) String? range,@JsonKey(includeIfNull: false) String? fallback,@JsonKey(includeIfNull: false) String? value,@JsonKey(includeIfNull: false) List<Map<String, dynamic>>? elements,@JsonKey(includeIfNull: false) int? indent,@JsonKey(includeIfNull: false) int? offset
});




}
/// @nodoc
class _$SlackMessageBlockRichTextElementEntityCopyWithImpl<$Res>
    implements $SlackMessageBlockRichTextElementEntityCopyWith<$Res> {
  _$SlackMessageBlockRichTextElementEntityCopyWithImpl(this._self, this._then);

  final SlackMessageBlockRichTextElementEntity _self;
  final $Res Function(SlackMessageBlockRichTextElementEntity) _then;

/// Create a copy of SlackMessageBlockRichTextElementEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = freezed,Object? style = freezed,Object? name = freezed,Object? unicode = freezed,Object? url = freezed,Object? text = freezed,Object? unsafe = freezed,Object? userId = freezed,Object? usergroupId = freezed,Object? channelId = freezed,Object? range = freezed,Object? fallback = freezed,Object? value = freezed,Object? elements = freezed,Object? indent = freezed,Object? offset = freezed,}) {
  return _then(_self.copyWith(
type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as SlackMessageBlockRichTextElementEntityType?,style: freezed == style ? _self.style : style // ignore: cast_nullable_to_non_nullable
as Map<String, bool>?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,unicode: freezed == unicode ? _self.unicode : unicode // ignore: cast_nullable_to_non_nullable
as String?,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,text: freezed == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String?,unsafe: freezed == unsafe ? _self.unsafe : unsafe // ignore: cast_nullable_to_non_nullable
as bool?,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,usergroupId: freezed == usergroupId ? _self.usergroupId : usergroupId // ignore: cast_nullable_to_non_nullable
as String?,channelId: freezed == channelId ? _self.channelId : channelId // ignore: cast_nullable_to_non_nullable
as String?,range: freezed == range ? _self.range : range // ignore: cast_nullable_to_non_nullable
as String?,fallback: freezed == fallback ? _self.fallback : fallback // ignore: cast_nullable_to_non_nullable
as String?,value: freezed == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String?,elements: freezed == elements ? _self.elements : elements // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>?,indent: freezed == indent ? _self.indent : indent // ignore: cast_nullable_to_non_nullable
as int?,offset: freezed == offset ? _self.offset : offset // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [SlackMessageBlockRichTextElementEntity].
extension SlackMessageBlockRichTextElementEntityPatterns on SlackMessageBlockRichTextElementEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SlackMessageBlockRichTextElementEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SlackMessageBlockRichTextElementEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SlackMessageBlockRichTextElementEntity value)  $default,){
final _that = this;
switch (_that) {
case _SlackMessageBlockRichTextElementEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SlackMessageBlockRichTextElementEntity value)?  $default,){
final _that = this;
switch (_that) {
case _SlackMessageBlockRichTextElementEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(includeIfNull: false, unknownEnumValue: null)  SlackMessageBlockRichTextElementEntityType? type, @JsonKey(includeIfNull: false)  Map<String, bool>? style, @JsonKey(includeIfNull: false)  String? name, @JsonKey(includeIfNull: false)  String? unicode, @JsonKey(includeIfNull: false)  String? url, @JsonKey(includeIfNull: false)  String? text, @JsonKey(includeIfNull: false)  bool? unsafe, @JsonKey(includeIfNull: false)  String? userId, @JsonKey(includeIfNull: false)  String? usergroupId, @JsonKey(includeIfNull: false)  String? channelId, @JsonKey(includeIfNull: false)  String? range, @JsonKey(includeIfNull: false)  String? fallback, @JsonKey(includeIfNull: false)  String? value, @JsonKey(includeIfNull: false)  List<Map<String, dynamic>>? elements, @JsonKey(includeIfNull: false)  int? indent, @JsonKey(includeIfNull: false)  int? offset)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SlackMessageBlockRichTextElementEntity() when $default != null:
return $default(_that.type,_that.style,_that.name,_that.unicode,_that.url,_that.text,_that.unsafe,_that.userId,_that.usergroupId,_that.channelId,_that.range,_that.fallback,_that.value,_that.elements,_that.indent,_that.offset);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(includeIfNull: false, unknownEnumValue: null)  SlackMessageBlockRichTextElementEntityType? type, @JsonKey(includeIfNull: false)  Map<String, bool>? style, @JsonKey(includeIfNull: false)  String? name, @JsonKey(includeIfNull: false)  String? unicode, @JsonKey(includeIfNull: false)  String? url, @JsonKey(includeIfNull: false)  String? text, @JsonKey(includeIfNull: false)  bool? unsafe, @JsonKey(includeIfNull: false)  String? userId, @JsonKey(includeIfNull: false)  String? usergroupId, @JsonKey(includeIfNull: false)  String? channelId, @JsonKey(includeIfNull: false)  String? range, @JsonKey(includeIfNull: false)  String? fallback, @JsonKey(includeIfNull: false)  String? value, @JsonKey(includeIfNull: false)  List<Map<String, dynamic>>? elements, @JsonKey(includeIfNull: false)  int? indent, @JsonKey(includeIfNull: false)  int? offset)  $default,) {final _that = this;
switch (_that) {
case _SlackMessageBlockRichTextElementEntity():
return $default(_that.type,_that.style,_that.name,_that.unicode,_that.url,_that.text,_that.unsafe,_that.userId,_that.usergroupId,_that.channelId,_that.range,_that.fallback,_that.value,_that.elements,_that.indent,_that.offset);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(includeIfNull: false, unknownEnumValue: null)  SlackMessageBlockRichTextElementEntityType? type, @JsonKey(includeIfNull: false)  Map<String, bool>? style, @JsonKey(includeIfNull: false)  String? name, @JsonKey(includeIfNull: false)  String? unicode, @JsonKey(includeIfNull: false)  String? url, @JsonKey(includeIfNull: false)  String? text, @JsonKey(includeIfNull: false)  bool? unsafe, @JsonKey(includeIfNull: false)  String? userId, @JsonKey(includeIfNull: false)  String? usergroupId, @JsonKey(includeIfNull: false)  String? channelId, @JsonKey(includeIfNull: false)  String? range, @JsonKey(includeIfNull: false)  String? fallback, @JsonKey(includeIfNull: false)  String? value, @JsonKey(includeIfNull: false)  List<Map<String, dynamic>>? elements, @JsonKey(includeIfNull: false)  int? indent, @JsonKey(includeIfNull: false)  int? offset)?  $default,) {final _that = this;
switch (_that) {
case _SlackMessageBlockRichTextElementEntity() when $default != null:
return $default(_that.type,_that.style,_that.name,_that.unicode,_that.url,_that.text,_that.unsafe,_that.userId,_that.usergroupId,_that.channelId,_that.range,_that.fallback,_that.value,_that.elements,_that.indent,_that.offset);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _SlackMessageBlockRichTextElementEntity implements SlackMessageBlockRichTextElementEntity {
  const _SlackMessageBlockRichTextElementEntity({@JsonKey(includeIfNull: false, unknownEnumValue: null) this.type, @JsonKey(includeIfNull: false) final  Map<String, bool>? style, @JsonKey(includeIfNull: false) this.name, @JsonKey(includeIfNull: false) this.unicode, @JsonKey(includeIfNull: false) this.url, @JsonKey(includeIfNull: false) this.text, @JsonKey(includeIfNull: false) this.unsafe, @JsonKey(includeIfNull: false) this.userId, @JsonKey(includeIfNull: false) this.usergroupId, @JsonKey(includeIfNull: false) this.channelId, @JsonKey(includeIfNull: false) this.range, @JsonKey(includeIfNull: false) this.fallback, @JsonKey(includeIfNull: false) this.value, @JsonKey(includeIfNull: false) final  List<Map<String, dynamic>>? elements, @JsonKey(includeIfNull: false) this.indent, @JsonKey(includeIfNull: false) this.offset}): _style = style,_elements = elements;
  factory _SlackMessageBlockRichTextElementEntity.fromJson(Map<String, dynamic> json) => _$SlackMessageBlockRichTextElementEntityFromJson(json);

@override@JsonKey(includeIfNull: false, unknownEnumValue: null) final  SlackMessageBlockRichTextElementEntityType? type;
 final  Map<String, bool>? _style;
@override@JsonKey(includeIfNull: false) Map<String, bool>? get style {
  final value = _style;
  if (value == null) return null;
  if (_style is EqualUnmodifiableMapView) return _style;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override@JsonKey(includeIfNull: false) final  String? name;
@override@JsonKey(includeIfNull: false) final  String? unicode;
@override@JsonKey(includeIfNull: false) final  String? url;
@override@JsonKey(includeIfNull: false) final  String? text;
@override@JsonKey(includeIfNull: false) final  bool? unsafe;
@override@JsonKey(includeIfNull: false) final  String? userId;
@override@JsonKey(includeIfNull: false) final  String? usergroupId;
@override@JsonKey(includeIfNull: false) final  String? channelId;
@override@JsonKey(includeIfNull: false) final  String? range;
@override@JsonKey(includeIfNull: false) final  String? fallback;
@override@JsonKey(includeIfNull: false) final  String? value;
 final  List<Map<String, dynamic>>? _elements;
@override@JsonKey(includeIfNull: false) List<Map<String, dynamic>>? get elements {
  final value = _elements;
  if (value == null) return null;
  if (_elements is EqualUnmodifiableListView) return _elements;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override@JsonKey(includeIfNull: false) final  int? indent;
@override@JsonKey(includeIfNull: false) final  int? offset;

/// Create a copy of SlackMessageBlockRichTextElementEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SlackMessageBlockRichTextElementEntityCopyWith<_SlackMessageBlockRichTextElementEntity> get copyWith => __$SlackMessageBlockRichTextElementEntityCopyWithImpl<_SlackMessageBlockRichTextElementEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SlackMessageBlockRichTextElementEntityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SlackMessageBlockRichTextElementEntity&&(identical(other.type, type) || other.type == type)&&const DeepCollectionEquality().equals(other._style, _style)&&(identical(other.name, name) || other.name == name)&&(identical(other.unicode, unicode) || other.unicode == unicode)&&(identical(other.url, url) || other.url == url)&&(identical(other.text, text) || other.text == text)&&(identical(other.unsafe, unsafe) || other.unsafe == unsafe)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.usergroupId, usergroupId) || other.usergroupId == usergroupId)&&(identical(other.channelId, channelId) || other.channelId == channelId)&&(identical(other.range, range) || other.range == range)&&(identical(other.fallback, fallback) || other.fallback == fallback)&&(identical(other.value, value) || other.value == value)&&const DeepCollectionEquality().equals(other._elements, _elements)&&(identical(other.indent, indent) || other.indent == indent)&&(identical(other.offset, offset) || other.offset == offset));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,const DeepCollectionEquality().hash(_style),name,unicode,url,text,unsafe,userId,usergroupId,channelId,range,fallback,value,const DeepCollectionEquality().hash(_elements),indent,offset);

@override
String toString() {
  return 'SlackMessageBlockRichTextElementEntity(type: $type, style: $style, name: $name, unicode: $unicode, url: $url, text: $text, unsafe: $unsafe, userId: $userId, usergroupId: $usergroupId, channelId: $channelId, range: $range, fallback: $fallback, value: $value, elements: $elements, indent: $indent, offset: $offset)';
}


}

/// @nodoc
abstract mixin class _$SlackMessageBlockRichTextElementEntityCopyWith<$Res> implements $SlackMessageBlockRichTextElementEntityCopyWith<$Res> {
  factory _$SlackMessageBlockRichTextElementEntityCopyWith(_SlackMessageBlockRichTextElementEntity value, $Res Function(_SlackMessageBlockRichTextElementEntity) _then) = __$SlackMessageBlockRichTextElementEntityCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(includeIfNull: false, unknownEnumValue: null) SlackMessageBlockRichTextElementEntityType? type,@JsonKey(includeIfNull: false) Map<String, bool>? style,@JsonKey(includeIfNull: false) String? name,@JsonKey(includeIfNull: false) String? unicode,@JsonKey(includeIfNull: false) String? url,@JsonKey(includeIfNull: false) String? text,@JsonKey(includeIfNull: false) bool? unsafe,@JsonKey(includeIfNull: false) String? userId,@JsonKey(includeIfNull: false) String? usergroupId,@JsonKey(includeIfNull: false) String? channelId,@JsonKey(includeIfNull: false) String? range,@JsonKey(includeIfNull: false) String? fallback,@JsonKey(includeIfNull: false) String? value,@JsonKey(includeIfNull: false) List<Map<String, dynamic>>? elements,@JsonKey(includeIfNull: false) int? indent,@JsonKey(includeIfNull: false) int? offset
});




}
/// @nodoc
class __$SlackMessageBlockRichTextElementEntityCopyWithImpl<$Res>
    implements _$SlackMessageBlockRichTextElementEntityCopyWith<$Res> {
  __$SlackMessageBlockRichTextElementEntityCopyWithImpl(this._self, this._then);

  final _SlackMessageBlockRichTextElementEntity _self;
  final $Res Function(_SlackMessageBlockRichTextElementEntity) _then;

/// Create a copy of SlackMessageBlockRichTextElementEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = freezed,Object? style = freezed,Object? name = freezed,Object? unicode = freezed,Object? url = freezed,Object? text = freezed,Object? unsafe = freezed,Object? userId = freezed,Object? usergroupId = freezed,Object? channelId = freezed,Object? range = freezed,Object? fallback = freezed,Object? value = freezed,Object? elements = freezed,Object? indent = freezed,Object? offset = freezed,}) {
  return _then(_SlackMessageBlockRichTextElementEntity(
type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as SlackMessageBlockRichTextElementEntityType?,style: freezed == style ? _self._style : style // ignore: cast_nullable_to_non_nullable
as Map<String, bool>?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,unicode: freezed == unicode ? _self.unicode : unicode // ignore: cast_nullable_to_non_nullable
as String?,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,text: freezed == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String?,unsafe: freezed == unsafe ? _self.unsafe : unsafe // ignore: cast_nullable_to_non_nullable
as bool?,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,usergroupId: freezed == usergroupId ? _self.usergroupId : usergroupId // ignore: cast_nullable_to_non_nullable
as String?,channelId: freezed == channelId ? _self.channelId : channelId // ignore: cast_nullable_to_non_nullable
as String?,range: freezed == range ? _self.range : range // ignore: cast_nullable_to_non_nullable
as String?,fallback: freezed == fallback ? _self.fallback : fallback // ignore: cast_nullable_to_non_nullable
as String?,value: freezed == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String?,elements: freezed == elements ? _self._elements : elements // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>?,indent: freezed == indent ? _self.indent : indent // ignore: cast_nullable_to_non_nullable
as int?,offset: freezed == offset ? _self.offset : offset // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
