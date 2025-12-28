// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'feedback_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FeedbackEntity {

 String get id; String? get authorId; String get description; DateTime get createdAt; List<String> get fileUrls; String get version; bool get isAutoReport; String get platform; String get osVersion; String? get errorMessage;
/// Create a copy of FeedbackEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FeedbackEntityCopyWith<FeedbackEntity> get copyWith => _$FeedbackEntityCopyWithImpl<FeedbackEntity>(this as FeedbackEntity, _$identity);

  /// Serializes this FeedbackEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FeedbackEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.authorId, authorId) || other.authorId == authorId)&&(identical(other.description, description) || other.description == description)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&const DeepCollectionEquality().equals(other.fileUrls, fileUrls)&&(identical(other.version, version) || other.version == version)&&(identical(other.isAutoReport, isAutoReport) || other.isAutoReport == isAutoReport)&&(identical(other.platform, platform) || other.platform == platform)&&(identical(other.osVersion, osVersion) || other.osVersion == osVersion)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,authorId,description,createdAt,const DeepCollectionEquality().hash(fileUrls),version,isAutoReport,platform,osVersion,errorMessage);

@override
String toString() {
  return 'FeedbackEntity(id: $id, authorId: $authorId, description: $description, createdAt: $createdAt, fileUrls: $fileUrls, version: $version, isAutoReport: $isAutoReport, platform: $platform, osVersion: $osVersion, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class $FeedbackEntityCopyWith<$Res>  {
  factory $FeedbackEntityCopyWith(FeedbackEntity value, $Res Function(FeedbackEntity) _then) = _$FeedbackEntityCopyWithImpl;
@useResult
$Res call({
 String id, String? authorId, String description, DateTime createdAt, List<String> fileUrls, String version, bool isAutoReport, String platform, String osVersion, String? errorMessage
});




}
/// @nodoc
class _$FeedbackEntityCopyWithImpl<$Res>
    implements $FeedbackEntityCopyWith<$Res> {
  _$FeedbackEntityCopyWithImpl(this._self, this._then);

  final FeedbackEntity _self;
  final $Res Function(FeedbackEntity) _then;

/// Create a copy of FeedbackEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? authorId = freezed,Object? description = null,Object? createdAt = null,Object? fileUrls = null,Object? version = null,Object? isAutoReport = null,Object? platform = null,Object? osVersion = null,Object? errorMessage = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,authorId: freezed == authorId ? _self.authorId : authorId // ignore: cast_nullable_to_non_nullable
as String?,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,fileUrls: null == fileUrls ? _self.fileUrls : fileUrls // ignore: cast_nullable_to_non_nullable
as List<String>,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,isAutoReport: null == isAutoReport ? _self.isAutoReport : isAutoReport // ignore: cast_nullable_to_non_nullable
as bool,platform: null == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as String,osVersion: null == osVersion ? _self.osVersion : osVersion // ignore: cast_nullable_to_non_nullable
as String,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [FeedbackEntity].
extension FeedbackEntityPatterns on FeedbackEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FeedbackEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FeedbackEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FeedbackEntity value)  $default,){
final _that = this;
switch (_that) {
case _FeedbackEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FeedbackEntity value)?  $default,){
final _that = this;
switch (_that) {
case _FeedbackEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? authorId,  String description,  DateTime createdAt,  List<String> fileUrls,  String version,  bool isAutoReport,  String platform,  String osVersion,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FeedbackEntity() when $default != null:
return $default(_that.id,_that.authorId,_that.description,_that.createdAt,_that.fileUrls,_that.version,_that.isAutoReport,_that.platform,_that.osVersion,_that.errorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? authorId,  String description,  DateTime createdAt,  List<String> fileUrls,  String version,  bool isAutoReport,  String platform,  String osVersion,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case _FeedbackEntity():
return $default(_that.id,_that.authorId,_that.description,_that.createdAt,_that.fileUrls,_that.version,_that.isAutoReport,_that.platform,_that.osVersion,_that.errorMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? authorId,  String description,  DateTime createdAt,  List<String> fileUrls,  String version,  bool isAutoReport,  String platform,  String osVersion,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _FeedbackEntity() when $default != null:
return $default(_that.id,_that.authorId,_that.description,_that.createdAt,_that.fileUrls,_that.version,_that.isAutoReport,_that.platform,_that.osVersion,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _FeedbackEntity implements FeedbackEntity {
  const _FeedbackEntity({required this.id, required this.authorId, required this.description, required this.createdAt, required final  List<String> fileUrls, required this.version, required this.isAutoReport, required this.platform, required this.osVersion, this.errorMessage}): _fileUrls = fileUrls;
  factory _FeedbackEntity.fromJson(Map<String, dynamic> json) => _$FeedbackEntityFromJson(json);

@override final  String id;
@override final  String? authorId;
@override final  String description;
@override final  DateTime createdAt;
 final  List<String> _fileUrls;
@override List<String> get fileUrls {
  if (_fileUrls is EqualUnmodifiableListView) return _fileUrls;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_fileUrls);
}

@override final  String version;
@override final  bool isAutoReport;
@override final  String platform;
@override final  String osVersion;
@override final  String? errorMessage;

/// Create a copy of FeedbackEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FeedbackEntityCopyWith<_FeedbackEntity> get copyWith => __$FeedbackEntityCopyWithImpl<_FeedbackEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FeedbackEntityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FeedbackEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.authorId, authorId) || other.authorId == authorId)&&(identical(other.description, description) || other.description == description)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&const DeepCollectionEquality().equals(other._fileUrls, _fileUrls)&&(identical(other.version, version) || other.version == version)&&(identical(other.isAutoReport, isAutoReport) || other.isAutoReport == isAutoReport)&&(identical(other.platform, platform) || other.platform == platform)&&(identical(other.osVersion, osVersion) || other.osVersion == osVersion)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,authorId,description,createdAt,const DeepCollectionEquality().hash(_fileUrls),version,isAutoReport,platform,osVersion,errorMessage);

@override
String toString() {
  return 'FeedbackEntity(id: $id, authorId: $authorId, description: $description, createdAt: $createdAt, fileUrls: $fileUrls, version: $version, isAutoReport: $isAutoReport, platform: $platform, osVersion: $osVersion, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$FeedbackEntityCopyWith<$Res> implements $FeedbackEntityCopyWith<$Res> {
  factory _$FeedbackEntityCopyWith(_FeedbackEntity value, $Res Function(_FeedbackEntity) _then) = __$FeedbackEntityCopyWithImpl;
@override @useResult
$Res call({
 String id, String? authorId, String description, DateTime createdAt, List<String> fileUrls, String version, bool isAutoReport, String platform, String osVersion, String? errorMessage
});




}
/// @nodoc
class __$FeedbackEntityCopyWithImpl<$Res>
    implements _$FeedbackEntityCopyWith<$Res> {
  __$FeedbackEntityCopyWithImpl(this._self, this._then);

  final _FeedbackEntity _self;
  final $Res Function(_FeedbackEntity) _then;

/// Create a copy of FeedbackEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? authorId = freezed,Object? description = null,Object? createdAt = null,Object? fileUrls = null,Object? version = null,Object? isAutoReport = null,Object? platform = null,Object? osVersion = null,Object? errorMessage = freezed,}) {
  return _then(_FeedbackEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,authorId: freezed == authorId ? _self.authorId : authorId // ignore: cast_nullable_to_non_nullable
as String?,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,fileUrls: null == fileUrls ? _self._fileUrls : fileUrls // ignore: cast_nullable_to_non_nullable
as List<String>,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,isAutoReport: null == isAutoReport ? _self.isAutoReport : isAutoReport // ignore: cast_nullable_to_non_nullable
as bool,platform: null == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as String,osVersion: null == osVersion ? _self.osVersion : osVersion // ignore: cast_nullable_to_non_nullable
as String,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
