// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'event_attachment_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$EventAttachmentEntity {

 String? get fileId; String? get fileUrl; String? get iconLink; String? get mimeType; String? get title; int? get size; bool? get isInline;
/// Create a copy of EventAttachmentEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EventAttachmentEntityCopyWith<EventAttachmentEntity> get copyWith => _$EventAttachmentEntityCopyWithImpl<EventAttachmentEntity>(this as EventAttachmentEntity, _$identity);

  /// Serializes this EventAttachmentEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EventAttachmentEntity&&(identical(other.fileId, fileId) || other.fileId == fileId)&&(identical(other.fileUrl, fileUrl) || other.fileUrl == fileUrl)&&(identical(other.iconLink, iconLink) || other.iconLink == iconLink)&&(identical(other.mimeType, mimeType) || other.mimeType == mimeType)&&(identical(other.title, title) || other.title == title)&&(identical(other.size, size) || other.size == size)&&(identical(other.isInline, isInline) || other.isInline == isInline));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,fileId,fileUrl,iconLink,mimeType,title,size,isInline);

@override
String toString() {
  return 'EventAttachmentEntity(fileId: $fileId, fileUrl: $fileUrl, iconLink: $iconLink, mimeType: $mimeType, title: $title, size: $size, isInline: $isInline)';
}


}

/// @nodoc
abstract mixin class $EventAttachmentEntityCopyWith<$Res>  {
  factory $EventAttachmentEntityCopyWith(EventAttachmentEntity value, $Res Function(EventAttachmentEntity) _then) = _$EventAttachmentEntityCopyWithImpl;
@useResult
$Res call({
 String? fileId, String? fileUrl, String? iconLink, String? mimeType, String? title, int? size, bool? isInline
});




}
/// @nodoc
class _$EventAttachmentEntityCopyWithImpl<$Res>
    implements $EventAttachmentEntityCopyWith<$Res> {
  _$EventAttachmentEntityCopyWithImpl(this._self, this._then);

  final EventAttachmentEntity _self;
  final $Res Function(EventAttachmentEntity) _then;

/// Create a copy of EventAttachmentEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? fileId = freezed,Object? fileUrl = freezed,Object? iconLink = freezed,Object? mimeType = freezed,Object? title = freezed,Object? size = freezed,Object? isInline = freezed,}) {
  return _then(_self.copyWith(
fileId: freezed == fileId ? _self.fileId : fileId // ignore: cast_nullable_to_non_nullable
as String?,fileUrl: freezed == fileUrl ? _self.fileUrl : fileUrl // ignore: cast_nullable_to_non_nullable
as String?,iconLink: freezed == iconLink ? _self.iconLink : iconLink // ignore: cast_nullable_to_non_nullable
as String?,mimeType: freezed == mimeType ? _self.mimeType : mimeType // ignore: cast_nullable_to_non_nullable
as String?,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,size: freezed == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int?,isInline: freezed == isInline ? _self.isInline : isInline // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}

}


/// Adds pattern-matching-related methods to [EventAttachmentEntity].
extension EventAttachmentEntityPatterns on EventAttachmentEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EventAttachmentEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EventAttachmentEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EventAttachmentEntity value)  $default,){
final _that = this;
switch (_that) {
case _EventAttachmentEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EventAttachmentEntity value)?  $default,){
final _that = this;
switch (_that) {
case _EventAttachmentEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? fileId,  String? fileUrl,  String? iconLink,  String? mimeType,  String? title,  int? size,  bool? isInline)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EventAttachmentEntity() when $default != null:
return $default(_that.fileId,_that.fileUrl,_that.iconLink,_that.mimeType,_that.title,_that.size,_that.isInline);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? fileId,  String? fileUrl,  String? iconLink,  String? mimeType,  String? title,  int? size,  bool? isInline)  $default,) {final _that = this;
switch (_that) {
case _EventAttachmentEntity():
return $default(_that.fileId,_that.fileUrl,_that.iconLink,_that.mimeType,_that.title,_that.size,_that.isInline);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? fileId,  String? fileUrl,  String? iconLink,  String? mimeType,  String? title,  int? size,  bool? isInline)?  $default,) {final _that = this;
switch (_that) {
case _EventAttachmentEntity() when $default != null:
return $default(_that.fileId,_that.fileUrl,_that.iconLink,_that.mimeType,_that.title,_that.size,_that.isInline);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _EventAttachmentEntity implements EventAttachmentEntity {
  const _EventAttachmentEntity({this.fileId, this.fileUrl, this.iconLink, this.mimeType, this.title, this.size, this.isInline});
  factory _EventAttachmentEntity.fromJson(Map<String, dynamic> json) => _$EventAttachmentEntityFromJson(json);

@override final  String? fileId;
@override final  String? fileUrl;
@override final  String? iconLink;
@override final  String? mimeType;
@override final  String? title;
@override final  int? size;
@override final  bool? isInline;

/// Create a copy of EventAttachmentEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EventAttachmentEntityCopyWith<_EventAttachmentEntity> get copyWith => __$EventAttachmentEntityCopyWithImpl<_EventAttachmentEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EventAttachmentEntityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EventAttachmentEntity&&(identical(other.fileId, fileId) || other.fileId == fileId)&&(identical(other.fileUrl, fileUrl) || other.fileUrl == fileUrl)&&(identical(other.iconLink, iconLink) || other.iconLink == iconLink)&&(identical(other.mimeType, mimeType) || other.mimeType == mimeType)&&(identical(other.title, title) || other.title == title)&&(identical(other.size, size) || other.size == size)&&(identical(other.isInline, isInline) || other.isInline == isInline));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,fileId,fileUrl,iconLink,mimeType,title,size,isInline);

@override
String toString() {
  return 'EventAttachmentEntity(fileId: $fileId, fileUrl: $fileUrl, iconLink: $iconLink, mimeType: $mimeType, title: $title, size: $size, isInline: $isInline)';
}


}

/// @nodoc
abstract mixin class _$EventAttachmentEntityCopyWith<$Res> implements $EventAttachmentEntityCopyWith<$Res> {
  factory _$EventAttachmentEntityCopyWith(_EventAttachmentEntity value, $Res Function(_EventAttachmentEntity) _then) = __$EventAttachmentEntityCopyWithImpl;
@override @useResult
$Res call({
 String? fileId, String? fileUrl, String? iconLink, String? mimeType, String? title, int? size, bool? isInline
});




}
/// @nodoc
class __$EventAttachmentEntityCopyWithImpl<$Res>
    implements _$EventAttachmentEntityCopyWith<$Res> {
  __$EventAttachmentEntityCopyWithImpl(this._self, this._then);

  final _EventAttachmentEntity _self;
  final $Res Function(_EventAttachmentEntity) _then;

/// Create a copy of EventAttachmentEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? fileId = freezed,Object? fileUrl = freezed,Object? iconLink = freezed,Object? mimeType = freezed,Object? title = freezed,Object? size = freezed,Object? isInline = freezed,}) {
  return _then(_EventAttachmentEntity(
fileId: freezed == fileId ? _self.fileId : fileId // ignore: cast_nullable_to_non_nullable
as String?,fileUrl: freezed == fileUrl ? _self.fileUrl : fileUrl // ignore: cast_nullable_to_non_nullable
as String?,iconLink: freezed == iconLink ? _self.iconLink : iconLink // ignore: cast_nullable_to_non_nullable
as String?,mimeType: freezed == mimeType ? _self.mimeType : mimeType // ignore: cast_nullable_to_non_nullable
as String?,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,size: freezed == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int?,isInline: freezed == isInline ? _self.isInline : isInline // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}


}

// dart format on
