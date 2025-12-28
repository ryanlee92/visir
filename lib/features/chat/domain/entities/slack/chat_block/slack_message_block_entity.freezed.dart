// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'slack_message_block_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SlackMessageBlockEntity {

@JsonKey(includeIfNull: false) SlackMessageBlockEntityType? get type;@JsonKey(includeIfNull: false) String? get blockId;@JsonKey(includeIfNull: false) String? get externalId;@JsonKey(includeIfNull: false) String? get altText;@JsonKey(includeIfNull: false) String? get imageUrl;@JsonKey(includeIfNull: false) String? get authorName;@JsonKey(includeIfNull: false) String? get providerIconUrl;@JsonKey(includeIfNull: false) String? get providerName;@JsonKey(includeIfNull: false) String? get titleUrl;@JsonKey(includeIfNull: false) String? get thumbnailUrl;@JsonKey(includeIfNull: false) String? get videoUrl;@JsonKey(includeIfNull: false) bool? get dispatchAction;@JsonKey(includeIfNull: false) bool? get optional;@JsonKey(includeIfNull: false) SlackMessageBlockTextObjectEntity? get text;@JsonKey(includeIfNull: false) Map<String, dynamic>? get title;@JsonKey(includeIfNull: false) Map<String, dynamic>? get slackFile;@JsonKey(includeIfNull: false) Map<String, dynamic>? get label;@JsonKey(includeIfNull: false) Map<String, dynamic>? get element;@JsonKey(includeIfNull: false) Map<String, dynamic>? get hint;@JsonKey(includeIfNull: false) Map<String, dynamic>? get accessory;@JsonKey(includeIfNull: false) Map<String, dynamic>? get description;@JsonKey(includeIfNull: false) List<Map<String, dynamic>>? get elements;@JsonKey(includeIfNull: false) List<Map<String, dynamic>>? get fields;
/// Create a copy of SlackMessageBlockEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SlackMessageBlockEntityCopyWith<SlackMessageBlockEntity> get copyWith => _$SlackMessageBlockEntityCopyWithImpl<SlackMessageBlockEntity>(this as SlackMessageBlockEntity, _$identity);

  /// Serializes this SlackMessageBlockEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SlackMessageBlockEntity&&(identical(other.type, type) || other.type == type)&&(identical(other.blockId, blockId) || other.blockId == blockId)&&(identical(other.externalId, externalId) || other.externalId == externalId)&&(identical(other.altText, altText) || other.altText == altText)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.authorName, authorName) || other.authorName == authorName)&&(identical(other.providerIconUrl, providerIconUrl) || other.providerIconUrl == providerIconUrl)&&(identical(other.providerName, providerName) || other.providerName == providerName)&&(identical(other.titleUrl, titleUrl) || other.titleUrl == titleUrl)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&(identical(other.videoUrl, videoUrl) || other.videoUrl == videoUrl)&&(identical(other.dispatchAction, dispatchAction) || other.dispatchAction == dispatchAction)&&(identical(other.optional, optional) || other.optional == optional)&&(identical(other.text, text) || other.text == text)&&const DeepCollectionEquality().equals(other.title, title)&&const DeepCollectionEquality().equals(other.slackFile, slackFile)&&const DeepCollectionEquality().equals(other.label, label)&&const DeepCollectionEquality().equals(other.element, element)&&const DeepCollectionEquality().equals(other.hint, hint)&&const DeepCollectionEquality().equals(other.accessory, accessory)&&const DeepCollectionEquality().equals(other.description, description)&&const DeepCollectionEquality().equals(other.elements, elements)&&const DeepCollectionEquality().equals(other.fields, fields));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,type,blockId,externalId,altText,imageUrl,authorName,providerIconUrl,providerName,titleUrl,thumbnailUrl,videoUrl,dispatchAction,optional,text,const DeepCollectionEquality().hash(title),const DeepCollectionEquality().hash(slackFile),const DeepCollectionEquality().hash(label),const DeepCollectionEquality().hash(element),const DeepCollectionEquality().hash(hint),const DeepCollectionEquality().hash(accessory),const DeepCollectionEquality().hash(description),const DeepCollectionEquality().hash(elements),const DeepCollectionEquality().hash(fields)]);

@override
String toString() {
  return 'SlackMessageBlockEntity(type: $type, blockId: $blockId, externalId: $externalId, altText: $altText, imageUrl: $imageUrl, authorName: $authorName, providerIconUrl: $providerIconUrl, providerName: $providerName, titleUrl: $titleUrl, thumbnailUrl: $thumbnailUrl, videoUrl: $videoUrl, dispatchAction: $dispatchAction, optional: $optional, text: $text, title: $title, slackFile: $slackFile, label: $label, element: $element, hint: $hint, accessory: $accessory, description: $description, elements: $elements, fields: $fields)';
}


}

/// @nodoc
abstract mixin class $SlackMessageBlockEntityCopyWith<$Res>  {
  factory $SlackMessageBlockEntityCopyWith(SlackMessageBlockEntity value, $Res Function(SlackMessageBlockEntity) _then) = _$SlackMessageBlockEntityCopyWithImpl;
@useResult
$Res call({
@JsonKey(includeIfNull: false) SlackMessageBlockEntityType? type,@JsonKey(includeIfNull: false) String? blockId,@JsonKey(includeIfNull: false) String? externalId,@JsonKey(includeIfNull: false) String? altText,@JsonKey(includeIfNull: false) String? imageUrl,@JsonKey(includeIfNull: false) String? authorName,@JsonKey(includeIfNull: false) String? providerIconUrl,@JsonKey(includeIfNull: false) String? providerName,@JsonKey(includeIfNull: false) String? titleUrl,@JsonKey(includeIfNull: false) String? thumbnailUrl,@JsonKey(includeIfNull: false) String? videoUrl,@JsonKey(includeIfNull: false) bool? dispatchAction,@JsonKey(includeIfNull: false) bool? optional,@JsonKey(includeIfNull: false) SlackMessageBlockTextObjectEntity? text,@JsonKey(includeIfNull: false) Map<String, dynamic>? title,@JsonKey(includeIfNull: false) Map<String, dynamic>? slackFile,@JsonKey(includeIfNull: false) Map<String, dynamic>? label,@JsonKey(includeIfNull: false) Map<String, dynamic>? element,@JsonKey(includeIfNull: false) Map<String, dynamic>? hint,@JsonKey(includeIfNull: false) Map<String, dynamic>? accessory,@JsonKey(includeIfNull: false) Map<String, dynamic>? description,@JsonKey(includeIfNull: false) List<Map<String, dynamic>>? elements,@JsonKey(includeIfNull: false) List<Map<String, dynamic>>? fields
});


$SlackMessageBlockTextObjectEntityCopyWith<$Res>? get text;

}
/// @nodoc
class _$SlackMessageBlockEntityCopyWithImpl<$Res>
    implements $SlackMessageBlockEntityCopyWith<$Res> {
  _$SlackMessageBlockEntityCopyWithImpl(this._self, this._then);

  final SlackMessageBlockEntity _self;
  final $Res Function(SlackMessageBlockEntity) _then;

/// Create a copy of SlackMessageBlockEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = freezed,Object? blockId = freezed,Object? externalId = freezed,Object? altText = freezed,Object? imageUrl = freezed,Object? authorName = freezed,Object? providerIconUrl = freezed,Object? providerName = freezed,Object? titleUrl = freezed,Object? thumbnailUrl = freezed,Object? videoUrl = freezed,Object? dispatchAction = freezed,Object? optional = freezed,Object? text = freezed,Object? title = freezed,Object? slackFile = freezed,Object? label = freezed,Object? element = freezed,Object? hint = freezed,Object? accessory = freezed,Object? description = freezed,Object? elements = freezed,Object? fields = freezed,}) {
  return _then(_self.copyWith(
type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as SlackMessageBlockEntityType?,blockId: freezed == blockId ? _self.blockId : blockId // ignore: cast_nullable_to_non_nullable
as String?,externalId: freezed == externalId ? _self.externalId : externalId // ignore: cast_nullable_to_non_nullable
as String?,altText: freezed == altText ? _self.altText : altText // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,authorName: freezed == authorName ? _self.authorName : authorName // ignore: cast_nullable_to_non_nullable
as String?,providerIconUrl: freezed == providerIconUrl ? _self.providerIconUrl : providerIconUrl // ignore: cast_nullable_to_non_nullable
as String?,providerName: freezed == providerName ? _self.providerName : providerName // ignore: cast_nullable_to_non_nullable
as String?,titleUrl: freezed == titleUrl ? _self.titleUrl : titleUrl // ignore: cast_nullable_to_non_nullable
as String?,thumbnailUrl: freezed == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String?,videoUrl: freezed == videoUrl ? _self.videoUrl : videoUrl // ignore: cast_nullable_to_non_nullable
as String?,dispatchAction: freezed == dispatchAction ? _self.dispatchAction : dispatchAction // ignore: cast_nullable_to_non_nullable
as bool?,optional: freezed == optional ? _self.optional : optional // ignore: cast_nullable_to_non_nullable
as bool?,text: freezed == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as SlackMessageBlockTextObjectEntity?,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,slackFile: freezed == slackFile ? _self.slackFile : slackFile // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,label: freezed == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,element: freezed == element ? _self.element : element // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,hint: freezed == hint ? _self.hint : hint // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,accessory: freezed == accessory ? _self.accessory : accessory // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,elements: freezed == elements ? _self.elements : elements // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>?,fields: freezed == fields ? _self.fields : fields // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>?,
  ));
}
/// Create a copy of SlackMessageBlockEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SlackMessageBlockTextObjectEntityCopyWith<$Res>? get text {
    if (_self.text == null) {
    return null;
  }

  return $SlackMessageBlockTextObjectEntityCopyWith<$Res>(_self.text!, (value) {
    return _then(_self.copyWith(text: value));
  });
}
}


/// Adds pattern-matching-related methods to [SlackMessageBlockEntity].
extension SlackMessageBlockEntityPatterns on SlackMessageBlockEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SlackMessageBlockEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SlackMessageBlockEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SlackMessageBlockEntity value)  $default,){
final _that = this;
switch (_that) {
case _SlackMessageBlockEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SlackMessageBlockEntity value)?  $default,){
final _that = this;
switch (_that) {
case _SlackMessageBlockEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(includeIfNull: false)  SlackMessageBlockEntityType? type, @JsonKey(includeIfNull: false)  String? blockId, @JsonKey(includeIfNull: false)  String? externalId, @JsonKey(includeIfNull: false)  String? altText, @JsonKey(includeIfNull: false)  String? imageUrl, @JsonKey(includeIfNull: false)  String? authorName, @JsonKey(includeIfNull: false)  String? providerIconUrl, @JsonKey(includeIfNull: false)  String? providerName, @JsonKey(includeIfNull: false)  String? titleUrl, @JsonKey(includeIfNull: false)  String? thumbnailUrl, @JsonKey(includeIfNull: false)  String? videoUrl, @JsonKey(includeIfNull: false)  bool? dispatchAction, @JsonKey(includeIfNull: false)  bool? optional, @JsonKey(includeIfNull: false)  SlackMessageBlockTextObjectEntity? text, @JsonKey(includeIfNull: false)  Map<String, dynamic>? title, @JsonKey(includeIfNull: false)  Map<String, dynamic>? slackFile, @JsonKey(includeIfNull: false)  Map<String, dynamic>? label, @JsonKey(includeIfNull: false)  Map<String, dynamic>? element, @JsonKey(includeIfNull: false)  Map<String, dynamic>? hint, @JsonKey(includeIfNull: false)  Map<String, dynamic>? accessory, @JsonKey(includeIfNull: false)  Map<String, dynamic>? description, @JsonKey(includeIfNull: false)  List<Map<String, dynamic>>? elements, @JsonKey(includeIfNull: false)  List<Map<String, dynamic>>? fields)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SlackMessageBlockEntity() when $default != null:
return $default(_that.type,_that.blockId,_that.externalId,_that.altText,_that.imageUrl,_that.authorName,_that.providerIconUrl,_that.providerName,_that.titleUrl,_that.thumbnailUrl,_that.videoUrl,_that.dispatchAction,_that.optional,_that.text,_that.title,_that.slackFile,_that.label,_that.element,_that.hint,_that.accessory,_that.description,_that.elements,_that.fields);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(includeIfNull: false)  SlackMessageBlockEntityType? type, @JsonKey(includeIfNull: false)  String? blockId, @JsonKey(includeIfNull: false)  String? externalId, @JsonKey(includeIfNull: false)  String? altText, @JsonKey(includeIfNull: false)  String? imageUrl, @JsonKey(includeIfNull: false)  String? authorName, @JsonKey(includeIfNull: false)  String? providerIconUrl, @JsonKey(includeIfNull: false)  String? providerName, @JsonKey(includeIfNull: false)  String? titleUrl, @JsonKey(includeIfNull: false)  String? thumbnailUrl, @JsonKey(includeIfNull: false)  String? videoUrl, @JsonKey(includeIfNull: false)  bool? dispatchAction, @JsonKey(includeIfNull: false)  bool? optional, @JsonKey(includeIfNull: false)  SlackMessageBlockTextObjectEntity? text, @JsonKey(includeIfNull: false)  Map<String, dynamic>? title, @JsonKey(includeIfNull: false)  Map<String, dynamic>? slackFile, @JsonKey(includeIfNull: false)  Map<String, dynamic>? label, @JsonKey(includeIfNull: false)  Map<String, dynamic>? element, @JsonKey(includeIfNull: false)  Map<String, dynamic>? hint, @JsonKey(includeIfNull: false)  Map<String, dynamic>? accessory, @JsonKey(includeIfNull: false)  Map<String, dynamic>? description, @JsonKey(includeIfNull: false)  List<Map<String, dynamic>>? elements, @JsonKey(includeIfNull: false)  List<Map<String, dynamic>>? fields)  $default,) {final _that = this;
switch (_that) {
case _SlackMessageBlockEntity():
return $default(_that.type,_that.blockId,_that.externalId,_that.altText,_that.imageUrl,_that.authorName,_that.providerIconUrl,_that.providerName,_that.titleUrl,_that.thumbnailUrl,_that.videoUrl,_that.dispatchAction,_that.optional,_that.text,_that.title,_that.slackFile,_that.label,_that.element,_that.hint,_that.accessory,_that.description,_that.elements,_that.fields);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(includeIfNull: false)  SlackMessageBlockEntityType? type, @JsonKey(includeIfNull: false)  String? blockId, @JsonKey(includeIfNull: false)  String? externalId, @JsonKey(includeIfNull: false)  String? altText, @JsonKey(includeIfNull: false)  String? imageUrl, @JsonKey(includeIfNull: false)  String? authorName, @JsonKey(includeIfNull: false)  String? providerIconUrl, @JsonKey(includeIfNull: false)  String? providerName, @JsonKey(includeIfNull: false)  String? titleUrl, @JsonKey(includeIfNull: false)  String? thumbnailUrl, @JsonKey(includeIfNull: false)  String? videoUrl, @JsonKey(includeIfNull: false)  bool? dispatchAction, @JsonKey(includeIfNull: false)  bool? optional, @JsonKey(includeIfNull: false)  SlackMessageBlockTextObjectEntity? text, @JsonKey(includeIfNull: false)  Map<String, dynamic>? title, @JsonKey(includeIfNull: false)  Map<String, dynamic>? slackFile, @JsonKey(includeIfNull: false)  Map<String, dynamic>? label, @JsonKey(includeIfNull: false)  Map<String, dynamic>? element, @JsonKey(includeIfNull: false)  Map<String, dynamic>? hint, @JsonKey(includeIfNull: false)  Map<String, dynamic>? accessory, @JsonKey(includeIfNull: false)  Map<String, dynamic>? description, @JsonKey(includeIfNull: false)  List<Map<String, dynamic>>? elements, @JsonKey(includeIfNull: false)  List<Map<String, dynamic>>? fields)?  $default,) {final _that = this;
switch (_that) {
case _SlackMessageBlockEntity() when $default != null:
return $default(_that.type,_that.blockId,_that.externalId,_that.altText,_that.imageUrl,_that.authorName,_that.providerIconUrl,_that.providerName,_that.titleUrl,_that.thumbnailUrl,_that.videoUrl,_that.dispatchAction,_that.optional,_that.text,_that.title,_that.slackFile,_that.label,_that.element,_that.hint,_that.accessory,_that.description,_that.elements,_that.fields);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _SlackMessageBlockEntity implements SlackMessageBlockEntity {
  const _SlackMessageBlockEntity({@JsonKey(includeIfNull: false) this.type, @JsonKey(includeIfNull: false) this.blockId, @JsonKey(includeIfNull: false) this.externalId, @JsonKey(includeIfNull: false) this.altText, @JsonKey(includeIfNull: false) this.imageUrl, @JsonKey(includeIfNull: false) this.authorName, @JsonKey(includeIfNull: false) this.providerIconUrl, @JsonKey(includeIfNull: false) this.providerName, @JsonKey(includeIfNull: false) this.titleUrl, @JsonKey(includeIfNull: false) this.thumbnailUrl, @JsonKey(includeIfNull: false) this.videoUrl, @JsonKey(includeIfNull: false) this.dispatchAction, @JsonKey(includeIfNull: false) this.optional, @JsonKey(includeIfNull: false) this.text, @JsonKey(includeIfNull: false) final  Map<String, dynamic>? title, @JsonKey(includeIfNull: false) final  Map<String, dynamic>? slackFile, @JsonKey(includeIfNull: false) final  Map<String, dynamic>? label, @JsonKey(includeIfNull: false) final  Map<String, dynamic>? element, @JsonKey(includeIfNull: false) final  Map<String, dynamic>? hint, @JsonKey(includeIfNull: false) final  Map<String, dynamic>? accessory, @JsonKey(includeIfNull: false) final  Map<String, dynamic>? description, @JsonKey(includeIfNull: false) final  List<Map<String, dynamic>>? elements, @JsonKey(includeIfNull: false) final  List<Map<String, dynamic>>? fields}): _title = title,_slackFile = slackFile,_label = label,_element = element,_hint = hint,_accessory = accessory,_description = description,_elements = elements,_fields = fields;
  factory _SlackMessageBlockEntity.fromJson(Map<String, dynamic> json) => _$SlackMessageBlockEntityFromJson(json);

@override@JsonKey(includeIfNull: false) final  SlackMessageBlockEntityType? type;
@override@JsonKey(includeIfNull: false) final  String? blockId;
@override@JsonKey(includeIfNull: false) final  String? externalId;
@override@JsonKey(includeIfNull: false) final  String? altText;
@override@JsonKey(includeIfNull: false) final  String? imageUrl;
@override@JsonKey(includeIfNull: false) final  String? authorName;
@override@JsonKey(includeIfNull: false) final  String? providerIconUrl;
@override@JsonKey(includeIfNull: false) final  String? providerName;
@override@JsonKey(includeIfNull: false) final  String? titleUrl;
@override@JsonKey(includeIfNull: false) final  String? thumbnailUrl;
@override@JsonKey(includeIfNull: false) final  String? videoUrl;
@override@JsonKey(includeIfNull: false) final  bool? dispatchAction;
@override@JsonKey(includeIfNull: false) final  bool? optional;
@override@JsonKey(includeIfNull: false) final  SlackMessageBlockTextObjectEntity? text;
 final  Map<String, dynamic>? _title;
@override@JsonKey(includeIfNull: false) Map<String, dynamic>? get title {
  final value = _title;
  if (value == null) return null;
  if (_title is EqualUnmodifiableMapView) return _title;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  Map<String, dynamic>? _slackFile;
@override@JsonKey(includeIfNull: false) Map<String, dynamic>? get slackFile {
  final value = _slackFile;
  if (value == null) return null;
  if (_slackFile is EqualUnmodifiableMapView) return _slackFile;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  Map<String, dynamic>? _label;
@override@JsonKey(includeIfNull: false) Map<String, dynamic>? get label {
  final value = _label;
  if (value == null) return null;
  if (_label is EqualUnmodifiableMapView) return _label;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  Map<String, dynamic>? _element;
@override@JsonKey(includeIfNull: false) Map<String, dynamic>? get element {
  final value = _element;
  if (value == null) return null;
  if (_element is EqualUnmodifiableMapView) return _element;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  Map<String, dynamic>? _hint;
@override@JsonKey(includeIfNull: false) Map<String, dynamic>? get hint {
  final value = _hint;
  if (value == null) return null;
  if (_hint is EqualUnmodifiableMapView) return _hint;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  Map<String, dynamic>? _accessory;
@override@JsonKey(includeIfNull: false) Map<String, dynamic>? get accessory {
  final value = _accessory;
  if (value == null) return null;
  if (_accessory is EqualUnmodifiableMapView) return _accessory;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  Map<String, dynamic>? _description;
@override@JsonKey(includeIfNull: false) Map<String, dynamic>? get description {
  final value = _description;
  if (value == null) return null;
  if (_description is EqualUnmodifiableMapView) return _description;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  List<Map<String, dynamic>>? _elements;
@override@JsonKey(includeIfNull: false) List<Map<String, dynamic>>? get elements {
  final value = _elements;
  if (value == null) return null;
  if (_elements is EqualUnmodifiableListView) return _elements;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<Map<String, dynamic>>? _fields;
@override@JsonKey(includeIfNull: false) List<Map<String, dynamic>>? get fields {
  final value = _fields;
  if (value == null) return null;
  if (_fields is EqualUnmodifiableListView) return _fields;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of SlackMessageBlockEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SlackMessageBlockEntityCopyWith<_SlackMessageBlockEntity> get copyWith => __$SlackMessageBlockEntityCopyWithImpl<_SlackMessageBlockEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SlackMessageBlockEntityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SlackMessageBlockEntity&&(identical(other.type, type) || other.type == type)&&(identical(other.blockId, blockId) || other.blockId == blockId)&&(identical(other.externalId, externalId) || other.externalId == externalId)&&(identical(other.altText, altText) || other.altText == altText)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.authorName, authorName) || other.authorName == authorName)&&(identical(other.providerIconUrl, providerIconUrl) || other.providerIconUrl == providerIconUrl)&&(identical(other.providerName, providerName) || other.providerName == providerName)&&(identical(other.titleUrl, titleUrl) || other.titleUrl == titleUrl)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&(identical(other.videoUrl, videoUrl) || other.videoUrl == videoUrl)&&(identical(other.dispatchAction, dispatchAction) || other.dispatchAction == dispatchAction)&&(identical(other.optional, optional) || other.optional == optional)&&(identical(other.text, text) || other.text == text)&&const DeepCollectionEquality().equals(other._title, _title)&&const DeepCollectionEquality().equals(other._slackFile, _slackFile)&&const DeepCollectionEquality().equals(other._label, _label)&&const DeepCollectionEquality().equals(other._element, _element)&&const DeepCollectionEquality().equals(other._hint, _hint)&&const DeepCollectionEquality().equals(other._accessory, _accessory)&&const DeepCollectionEquality().equals(other._description, _description)&&const DeepCollectionEquality().equals(other._elements, _elements)&&const DeepCollectionEquality().equals(other._fields, _fields));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,type,blockId,externalId,altText,imageUrl,authorName,providerIconUrl,providerName,titleUrl,thumbnailUrl,videoUrl,dispatchAction,optional,text,const DeepCollectionEquality().hash(_title),const DeepCollectionEquality().hash(_slackFile),const DeepCollectionEquality().hash(_label),const DeepCollectionEquality().hash(_element),const DeepCollectionEquality().hash(_hint),const DeepCollectionEquality().hash(_accessory),const DeepCollectionEquality().hash(_description),const DeepCollectionEquality().hash(_elements),const DeepCollectionEquality().hash(_fields)]);

@override
String toString() {
  return 'SlackMessageBlockEntity(type: $type, blockId: $blockId, externalId: $externalId, altText: $altText, imageUrl: $imageUrl, authorName: $authorName, providerIconUrl: $providerIconUrl, providerName: $providerName, titleUrl: $titleUrl, thumbnailUrl: $thumbnailUrl, videoUrl: $videoUrl, dispatchAction: $dispatchAction, optional: $optional, text: $text, title: $title, slackFile: $slackFile, label: $label, element: $element, hint: $hint, accessory: $accessory, description: $description, elements: $elements, fields: $fields)';
}


}

/// @nodoc
abstract mixin class _$SlackMessageBlockEntityCopyWith<$Res> implements $SlackMessageBlockEntityCopyWith<$Res> {
  factory _$SlackMessageBlockEntityCopyWith(_SlackMessageBlockEntity value, $Res Function(_SlackMessageBlockEntity) _then) = __$SlackMessageBlockEntityCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(includeIfNull: false) SlackMessageBlockEntityType? type,@JsonKey(includeIfNull: false) String? blockId,@JsonKey(includeIfNull: false) String? externalId,@JsonKey(includeIfNull: false) String? altText,@JsonKey(includeIfNull: false) String? imageUrl,@JsonKey(includeIfNull: false) String? authorName,@JsonKey(includeIfNull: false) String? providerIconUrl,@JsonKey(includeIfNull: false) String? providerName,@JsonKey(includeIfNull: false) String? titleUrl,@JsonKey(includeIfNull: false) String? thumbnailUrl,@JsonKey(includeIfNull: false) String? videoUrl,@JsonKey(includeIfNull: false) bool? dispatchAction,@JsonKey(includeIfNull: false) bool? optional,@JsonKey(includeIfNull: false) SlackMessageBlockTextObjectEntity? text,@JsonKey(includeIfNull: false) Map<String, dynamic>? title,@JsonKey(includeIfNull: false) Map<String, dynamic>? slackFile,@JsonKey(includeIfNull: false) Map<String, dynamic>? label,@JsonKey(includeIfNull: false) Map<String, dynamic>? element,@JsonKey(includeIfNull: false) Map<String, dynamic>? hint,@JsonKey(includeIfNull: false) Map<String, dynamic>? accessory,@JsonKey(includeIfNull: false) Map<String, dynamic>? description,@JsonKey(includeIfNull: false) List<Map<String, dynamic>>? elements,@JsonKey(includeIfNull: false) List<Map<String, dynamic>>? fields
});


@override $SlackMessageBlockTextObjectEntityCopyWith<$Res>? get text;

}
/// @nodoc
class __$SlackMessageBlockEntityCopyWithImpl<$Res>
    implements _$SlackMessageBlockEntityCopyWith<$Res> {
  __$SlackMessageBlockEntityCopyWithImpl(this._self, this._then);

  final _SlackMessageBlockEntity _self;
  final $Res Function(_SlackMessageBlockEntity) _then;

/// Create a copy of SlackMessageBlockEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = freezed,Object? blockId = freezed,Object? externalId = freezed,Object? altText = freezed,Object? imageUrl = freezed,Object? authorName = freezed,Object? providerIconUrl = freezed,Object? providerName = freezed,Object? titleUrl = freezed,Object? thumbnailUrl = freezed,Object? videoUrl = freezed,Object? dispatchAction = freezed,Object? optional = freezed,Object? text = freezed,Object? title = freezed,Object? slackFile = freezed,Object? label = freezed,Object? element = freezed,Object? hint = freezed,Object? accessory = freezed,Object? description = freezed,Object? elements = freezed,Object? fields = freezed,}) {
  return _then(_SlackMessageBlockEntity(
type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as SlackMessageBlockEntityType?,blockId: freezed == blockId ? _self.blockId : blockId // ignore: cast_nullable_to_non_nullable
as String?,externalId: freezed == externalId ? _self.externalId : externalId // ignore: cast_nullable_to_non_nullable
as String?,altText: freezed == altText ? _self.altText : altText // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,authorName: freezed == authorName ? _self.authorName : authorName // ignore: cast_nullable_to_non_nullable
as String?,providerIconUrl: freezed == providerIconUrl ? _self.providerIconUrl : providerIconUrl // ignore: cast_nullable_to_non_nullable
as String?,providerName: freezed == providerName ? _self.providerName : providerName // ignore: cast_nullable_to_non_nullable
as String?,titleUrl: freezed == titleUrl ? _self.titleUrl : titleUrl // ignore: cast_nullable_to_non_nullable
as String?,thumbnailUrl: freezed == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String?,videoUrl: freezed == videoUrl ? _self.videoUrl : videoUrl // ignore: cast_nullable_to_non_nullable
as String?,dispatchAction: freezed == dispatchAction ? _self.dispatchAction : dispatchAction // ignore: cast_nullable_to_non_nullable
as bool?,optional: freezed == optional ? _self.optional : optional // ignore: cast_nullable_to_non_nullable
as bool?,text: freezed == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as SlackMessageBlockTextObjectEntity?,title: freezed == title ? _self._title : title // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,slackFile: freezed == slackFile ? _self._slackFile : slackFile // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,label: freezed == label ? _self._label : label // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,element: freezed == element ? _self._element : element // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,hint: freezed == hint ? _self._hint : hint // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,accessory: freezed == accessory ? _self._accessory : accessory // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,description: freezed == description ? _self._description : description // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,elements: freezed == elements ? _self._elements : elements // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>?,fields: freezed == fields ? _self._fields : fields // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>?,
  ));
}

/// Create a copy of SlackMessageBlockEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SlackMessageBlockTextObjectEntityCopyWith<$Res>? get text {
    if (_self.text == null) {
    return null;
  }

  return $SlackMessageBlockTextObjectEntityCopyWith<$Res>(_self.text!, (value) {
    return _then(_self.copyWith(text: value));
  });
}
}

// dart format on
