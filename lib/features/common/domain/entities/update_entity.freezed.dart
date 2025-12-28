// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'update_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UpdateEntity {

@JsonKey(includeIfNull: false) String? get iosLink;@JsonKey(includeIfNull: false) String? get macosLink;@JsonKey(includeIfNull: false) String? get androidLink;@JsonKey(includeIfNull: false) String? get windowsLink;@JsonKey(includeIfNull: false) int? get iosMinimumBuild;@JsonKey(includeIfNull: false) int? get macosMinimumBuild;@JsonKey(includeIfNull: false) int? get androidMinimumBuild;@JsonKey(includeIfNull: false) int? get windowsMinimumBuild;
/// Create a copy of UpdateEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdateEntityCopyWith<UpdateEntity> get copyWith => _$UpdateEntityCopyWithImpl<UpdateEntity>(this as UpdateEntity, _$identity);

  /// Serializes this UpdateEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateEntity&&(identical(other.iosLink, iosLink) || other.iosLink == iosLink)&&(identical(other.macosLink, macosLink) || other.macosLink == macosLink)&&(identical(other.androidLink, androidLink) || other.androidLink == androidLink)&&(identical(other.windowsLink, windowsLink) || other.windowsLink == windowsLink)&&(identical(other.iosMinimumBuild, iosMinimumBuild) || other.iosMinimumBuild == iosMinimumBuild)&&(identical(other.macosMinimumBuild, macosMinimumBuild) || other.macosMinimumBuild == macosMinimumBuild)&&(identical(other.androidMinimumBuild, androidMinimumBuild) || other.androidMinimumBuild == androidMinimumBuild)&&(identical(other.windowsMinimumBuild, windowsMinimumBuild) || other.windowsMinimumBuild == windowsMinimumBuild));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,iosLink,macosLink,androidLink,windowsLink,iosMinimumBuild,macosMinimumBuild,androidMinimumBuild,windowsMinimumBuild);

@override
String toString() {
  return 'UpdateEntity(iosLink: $iosLink, macosLink: $macosLink, androidLink: $androidLink, windowsLink: $windowsLink, iosMinimumBuild: $iosMinimumBuild, macosMinimumBuild: $macosMinimumBuild, androidMinimumBuild: $androidMinimumBuild, windowsMinimumBuild: $windowsMinimumBuild)';
}


}

/// @nodoc
abstract mixin class $UpdateEntityCopyWith<$Res>  {
  factory $UpdateEntityCopyWith(UpdateEntity value, $Res Function(UpdateEntity) _then) = _$UpdateEntityCopyWithImpl;
@useResult
$Res call({
@JsonKey(includeIfNull: false) String? iosLink,@JsonKey(includeIfNull: false) String? macosLink,@JsonKey(includeIfNull: false) String? androidLink,@JsonKey(includeIfNull: false) String? windowsLink,@JsonKey(includeIfNull: false) int? iosMinimumBuild,@JsonKey(includeIfNull: false) int? macosMinimumBuild,@JsonKey(includeIfNull: false) int? androidMinimumBuild,@JsonKey(includeIfNull: false) int? windowsMinimumBuild
});




}
/// @nodoc
class _$UpdateEntityCopyWithImpl<$Res>
    implements $UpdateEntityCopyWith<$Res> {
  _$UpdateEntityCopyWithImpl(this._self, this._then);

  final UpdateEntity _self;
  final $Res Function(UpdateEntity) _then;

/// Create a copy of UpdateEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? iosLink = freezed,Object? macosLink = freezed,Object? androidLink = freezed,Object? windowsLink = freezed,Object? iosMinimumBuild = freezed,Object? macosMinimumBuild = freezed,Object? androidMinimumBuild = freezed,Object? windowsMinimumBuild = freezed,}) {
  return _then(_self.copyWith(
iosLink: freezed == iosLink ? _self.iosLink : iosLink // ignore: cast_nullable_to_non_nullable
as String?,macosLink: freezed == macosLink ? _self.macosLink : macosLink // ignore: cast_nullable_to_non_nullable
as String?,androidLink: freezed == androidLink ? _self.androidLink : androidLink // ignore: cast_nullable_to_non_nullable
as String?,windowsLink: freezed == windowsLink ? _self.windowsLink : windowsLink // ignore: cast_nullable_to_non_nullable
as String?,iosMinimumBuild: freezed == iosMinimumBuild ? _self.iosMinimumBuild : iosMinimumBuild // ignore: cast_nullable_to_non_nullable
as int?,macosMinimumBuild: freezed == macosMinimumBuild ? _self.macosMinimumBuild : macosMinimumBuild // ignore: cast_nullable_to_non_nullable
as int?,androidMinimumBuild: freezed == androidMinimumBuild ? _self.androidMinimumBuild : androidMinimumBuild // ignore: cast_nullable_to_non_nullable
as int?,windowsMinimumBuild: freezed == windowsMinimumBuild ? _self.windowsMinimumBuild : windowsMinimumBuild // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [UpdateEntity].
extension UpdateEntityPatterns on UpdateEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UpdateEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpdateEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UpdateEntity value)  $default,){
final _that = this;
switch (_that) {
case _UpdateEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UpdateEntity value)?  $default,){
final _that = this;
switch (_that) {
case _UpdateEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(includeIfNull: false)  String? iosLink, @JsonKey(includeIfNull: false)  String? macosLink, @JsonKey(includeIfNull: false)  String? androidLink, @JsonKey(includeIfNull: false)  String? windowsLink, @JsonKey(includeIfNull: false)  int? iosMinimumBuild, @JsonKey(includeIfNull: false)  int? macosMinimumBuild, @JsonKey(includeIfNull: false)  int? androidMinimumBuild, @JsonKey(includeIfNull: false)  int? windowsMinimumBuild)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpdateEntity() when $default != null:
return $default(_that.iosLink,_that.macosLink,_that.androidLink,_that.windowsLink,_that.iosMinimumBuild,_that.macosMinimumBuild,_that.androidMinimumBuild,_that.windowsMinimumBuild);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(includeIfNull: false)  String? iosLink, @JsonKey(includeIfNull: false)  String? macosLink, @JsonKey(includeIfNull: false)  String? androidLink, @JsonKey(includeIfNull: false)  String? windowsLink, @JsonKey(includeIfNull: false)  int? iosMinimumBuild, @JsonKey(includeIfNull: false)  int? macosMinimumBuild, @JsonKey(includeIfNull: false)  int? androidMinimumBuild, @JsonKey(includeIfNull: false)  int? windowsMinimumBuild)  $default,) {final _that = this;
switch (_that) {
case _UpdateEntity():
return $default(_that.iosLink,_that.macosLink,_that.androidLink,_that.windowsLink,_that.iosMinimumBuild,_that.macosMinimumBuild,_that.androidMinimumBuild,_that.windowsMinimumBuild);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(includeIfNull: false)  String? iosLink, @JsonKey(includeIfNull: false)  String? macosLink, @JsonKey(includeIfNull: false)  String? androidLink, @JsonKey(includeIfNull: false)  String? windowsLink, @JsonKey(includeIfNull: false)  int? iosMinimumBuild, @JsonKey(includeIfNull: false)  int? macosMinimumBuild, @JsonKey(includeIfNull: false)  int? androidMinimumBuild, @JsonKey(includeIfNull: false)  int? windowsMinimumBuild)?  $default,) {final _that = this;
switch (_that) {
case _UpdateEntity() when $default != null:
return $default(_that.iosLink,_that.macosLink,_that.androidLink,_that.windowsLink,_that.iosMinimumBuild,_that.macosMinimumBuild,_that.androidMinimumBuild,_that.windowsMinimumBuild);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _UpdateEntity implements UpdateEntity {
  const _UpdateEntity({@JsonKey(includeIfNull: false) this.iosLink, @JsonKey(includeIfNull: false) this.macosLink, @JsonKey(includeIfNull: false) this.androidLink, @JsonKey(includeIfNull: false) this.windowsLink, @JsonKey(includeIfNull: false) this.iosMinimumBuild, @JsonKey(includeIfNull: false) this.macosMinimumBuild, @JsonKey(includeIfNull: false) this.androidMinimumBuild, @JsonKey(includeIfNull: false) this.windowsMinimumBuild});
  factory _UpdateEntity.fromJson(Map<String, dynamic> json) => _$UpdateEntityFromJson(json);

@override@JsonKey(includeIfNull: false) final  String? iosLink;
@override@JsonKey(includeIfNull: false) final  String? macosLink;
@override@JsonKey(includeIfNull: false) final  String? androidLink;
@override@JsonKey(includeIfNull: false) final  String? windowsLink;
@override@JsonKey(includeIfNull: false) final  int? iosMinimumBuild;
@override@JsonKey(includeIfNull: false) final  int? macosMinimumBuild;
@override@JsonKey(includeIfNull: false) final  int? androidMinimumBuild;
@override@JsonKey(includeIfNull: false) final  int? windowsMinimumBuild;

/// Create a copy of UpdateEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateEntityCopyWith<_UpdateEntity> get copyWith => __$UpdateEntityCopyWithImpl<_UpdateEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UpdateEntityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateEntity&&(identical(other.iosLink, iosLink) || other.iosLink == iosLink)&&(identical(other.macosLink, macosLink) || other.macosLink == macosLink)&&(identical(other.androidLink, androidLink) || other.androidLink == androidLink)&&(identical(other.windowsLink, windowsLink) || other.windowsLink == windowsLink)&&(identical(other.iosMinimumBuild, iosMinimumBuild) || other.iosMinimumBuild == iosMinimumBuild)&&(identical(other.macosMinimumBuild, macosMinimumBuild) || other.macosMinimumBuild == macosMinimumBuild)&&(identical(other.androidMinimumBuild, androidMinimumBuild) || other.androidMinimumBuild == androidMinimumBuild)&&(identical(other.windowsMinimumBuild, windowsMinimumBuild) || other.windowsMinimumBuild == windowsMinimumBuild));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,iosLink,macosLink,androidLink,windowsLink,iosMinimumBuild,macosMinimumBuild,androidMinimumBuild,windowsMinimumBuild);

@override
String toString() {
  return 'UpdateEntity(iosLink: $iosLink, macosLink: $macosLink, androidLink: $androidLink, windowsLink: $windowsLink, iosMinimumBuild: $iosMinimumBuild, macosMinimumBuild: $macosMinimumBuild, androidMinimumBuild: $androidMinimumBuild, windowsMinimumBuild: $windowsMinimumBuild)';
}


}

/// @nodoc
abstract mixin class _$UpdateEntityCopyWith<$Res> implements $UpdateEntityCopyWith<$Res> {
  factory _$UpdateEntityCopyWith(_UpdateEntity value, $Res Function(_UpdateEntity) _then) = __$UpdateEntityCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(includeIfNull: false) String? iosLink,@JsonKey(includeIfNull: false) String? macosLink,@JsonKey(includeIfNull: false) String? androidLink,@JsonKey(includeIfNull: false) String? windowsLink,@JsonKey(includeIfNull: false) int? iosMinimumBuild,@JsonKey(includeIfNull: false) int? macosMinimumBuild,@JsonKey(includeIfNull: false) int? androidMinimumBuild,@JsonKey(includeIfNull: false) int? windowsMinimumBuild
});




}
/// @nodoc
class __$UpdateEntityCopyWithImpl<$Res>
    implements _$UpdateEntityCopyWith<$Res> {
  __$UpdateEntityCopyWithImpl(this._self, this._then);

  final _UpdateEntity _self;
  final $Res Function(_UpdateEntity) _then;

/// Create a copy of UpdateEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? iosLink = freezed,Object? macosLink = freezed,Object? androidLink = freezed,Object? windowsLink = freezed,Object? iosMinimumBuild = freezed,Object? macosMinimumBuild = freezed,Object? androidMinimumBuild = freezed,Object? windowsMinimumBuild = freezed,}) {
  return _then(_UpdateEntity(
iosLink: freezed == iosLink ? _self.iosLink : iosLink // ignore: cast_nullable_to_non_nullable
as String?,macosLink: freezed == macosLink ? _self.macosLink : macosLink // ignore: cast_nullable_to_non_nullable
as String?,androidLink: freezed == androidLink ? _self.androidLink : androidLink // ignore: cast_nullable_to_non_nullable
as String?,windowsLink: freezed == windowsLink ? _self.windowsLink : windowsLink // ignore: cast_nullable_to_non_nullable
as String?,iosMinimumBuild: freezed == iosMinimumBuild ? _self.iosMinimumBuild : iosMinimumBuild // ignore: cast_nullable_to_non_nullable
as int?,macosMinimumBuild: freezed == macosMinimumBuild ? _self.macosMinimumBuild : macosMinimumBuild // ignore: cast_nullable_to_non_nullable
as int?,androidMinimumBuild: freezed == androidMinimumBuild ? _self.androidMinimumBuild : androidMinimumBuild // ignore: cast_nullable_to_non_nullable
as int?,windowsMinimumBuild: freezed == windowsMinimumBuild ? _self.windowsMinimumBuild : windowsMinimumBuild // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
