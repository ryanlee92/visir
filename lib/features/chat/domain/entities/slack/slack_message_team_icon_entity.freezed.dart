// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'slack_message_team_icon_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SlackMessageTeamIconEntity {

@JsonKey(includeIfNull: false) bool? get imageDefault;@JsonKey(includeIfNull: false) String? get image_34;@JsonKey(includeIfNull: false) String? get image_44;@JsonKey(includeIfNull: false) String? get image_68;@JsonKey(includeIfNull: false) String? get image_88;@JsonKey(includeIfNull: false) String? get image_102;@JsonKey(includeIfNull: false) String? get image_132;@JsonKey(includeIfNull: false) String? get image_230;
/// Create a copy of SlackMessageTeamIconEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SlackMessageTeamIconEntityCopyWith<SlackMessageTeamIconEntity> get copyWith => _$SlackMessageTeamIconEntityCopyWithImpl<SlackMessageTeamIconEntity>(this as SlackMessageTeamIconEntity, _$identity);

  /// Serializes this SlackMessageTeamIconEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SlackMessageTeamIconEntity&&(identical(other.imageDefault, imageDefault) || other.imageDefault == imageDefault)&&(identical(other.image_34, image_34) || other.image_34 == image_34)&&(identical(other.image_44, image_44) || other.image_44 == image_44)&&(identical(other.image_68, image_68) || other.image_68 == image_68)&&(identical(other.image_88, image_88) || other.image_88 == image_88)&&(identical(other.image_102, image_102) || other.image_102 == image_102)&&(identical(other.image_132, image_132) || other.image_132 == image_132)&&(identical(other.image_230, image_230) || other.image_230 == image_230));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,imageDefault,image_34,image_44,image_68,image_88,image_102,image_132,image_230);

@override
String toString() {
  return 'SlackMessageTeamIconEntity(imageDefault: $imageDefault, image_34: $image_34, image_44: $image_44, image_68: $image_68, image_88: $image_88, image_102: $image_102, image_132: $image_132, image_230: $image_230)';
}


}

/// @nodoc
abstract mixin class $SlackMessageTeamIconEntityCopyWith<$Res>  {
  factory $SlackMessageTeamIconEntityCopyWith(SlackMessageTeamIconEntity value, $Res Function(SlackMessageTeamIconEntity) _then) = _$SlackMessageTeamIconEntityCopyWithImpl;
@useResult
$Res call({
@JsonKey(includeIfNull: false) bool? imageDefault,@JsonKey(includeIfNull: false) String? image_34,@JsonKey(includeIfNull: false) String? image_44,@JsonKey(includeIfNull: false) String? image_68,@JsonKey(includeIfNull: false) String? image_88,@JsonKey(includeIfNull: false) String? image_102,@JsonKey(includeIfNull: false) String? image_132,@JsonKey(includeIfNull: false) String? image_230
});




}
/// @nodoc
class _$SlackMessageTeamIconEntityCopyWithImpl<$Res>
    implements $SlackMessageTeamIconEntityCopyWith<$Res> {
  _$SlackMessageTeamIconEntityCopyWithImpl(this._self, this._then);

  final SlackMessageTeamIconEntity _self;
  final $Res Function(SlackMessageTeamIconEntity) _then;

/// Create a copy of SlackMessageTeamIconEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? imageDefault = freezed,Object? image_34 = freezed,Object? image_44 = freezed,Object? image_68 = freezed,Object? image_88 = freezed,Object? image_102 = freezed,Object? image_132 = freezed,Object? image_230 = freezed,}) {
  return _then(_self.copyWith(
imageDefault: freezed == imageDefault ? _self.imageDefault : imageDefault // ignore: cast_nullable_to_non_nullable
as bool?,image_34: freezed == image_34 ? _self.image_34 : image_34 // ignore: cast_nullable_to_non_nullable
as String?,image_44: freezed == image_44 ? _self.image_44 : image_44 // ignore: cast_nullable_to_non_nullable
as String?,image_68: freezed == image_68 ? _self.image_68 : image_68 // ignore: cast_nullable_to_non_nullable
as String?,image_88: freezed == image_88 ? _self.image_88 : image_88 // ignore: cast_nullable_to_non_nullable
as String?,image_102: freezed == image_102 ? _self.image_102 : image_102 // ignore: cast_nullable_to_non_nullable
as String?,image_132: freezed == image_132 ? _self.image_132 : image_132 // ignore: cast_nullable_to_non_nullable
as String?,image_230: freezed == image_230 ? _self.image_230 : image_230 // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [SlackMessageTeamIconEntity].
extension SlackMessageTeamIconEntityPatterns on SlackMessageTeamIconEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SlackMessageTeamIconEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SlackMessageTeamIconEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SlackMessageTeamIconEntity value)  $default,){
final _that = this;
switch (_that) {
case _SlackMessageTeamIconEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SlackMessageTeamIconEntity value)?  $default,){
final _that = this;
switch (_that) {
case _SlackMessageTeamIconEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(includeIfNull: false)  bool? imageDefault, @JsonKey(includeIfNull: false)  String? image_34, @JsonKey(includeIfNull: false)  String? image_44, @JsonKey(includeIfNull: false)  String? image_68, @JsonKey(includeIfNull: false)  String? image_88, @JsonKey(includeIfNull: false)  String? image_102, @JsonKey(includeIfNull: false)  String? image_132, @JsonKey(includeIfNull: false)  String? image_230)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SlackMessageTeamIconEntity() when $default != null:
return $default(_that.imageDefault,_that.image_34,_that.image_44,_that.image_68,_that.image_88,_that.image_102,_that.image_132,_that.image_230);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(includeIfNull: false)  bool? imageDefault, @JsonKey(includeIfNull: false)  String? image_34, @JsonKey(includeIfNull: false)  String? image_44, @JsonKey(includeIfNull: false)  String? image_68, @JsonKey(includeIfNull: false)  String? image_88, @JsonKey(includeIfNull: false)  String? image_102, @JsonKey(includeIfNull: false)  String? image_132, @JsonKey(includeIfNull: false)  String? image_230)  $default,) {final _that = this;
switch (_that) {
case _SlackMessageTeamIconEntity():
return $default(_that.imageDefault,_that.image_34,_that.image_44,_that.image_68,_that.image_88,_that.image_102,_that.image_132,_that.image_230);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(includeIfNull: false)  bool? imageDefault, @JsonKey(includeIfNull: false)  String? image_34, @JsonKey(includeIfNull: false)  String? image_44, @JsonKey(includeIfNull: false)  String? image_68, @JsonKey(includeIfNull: false)  String? image_88, @JsonKey(includeIfNull: false)  String? image_102, @JsonKey(includeIfNull: false)  String? image_132, @JsonKey(includeIfNull: false)  String? image_230)?  $default,) {final _that = this;
switch (_that) {
case _SlackMessageTeamIconEntity() when $default != null:
return $default(_that.imageDefault,_that.image_34,_that.image_44,_that.image_68,_that.image_88,_that.image_102,_that.image_132,_that.image_230);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _SlackMessageTeamIconEntity implements SlackMessageTeamIconEntity {
  const _SlackMessageTeamIconEntity({@JsonKey(includeIfNull: false) this.imageDefault, @JsonKey(includeIfNull: false) this.image_34, @JsonKey(includeIfNull: false) this.image_44, @JsonKey(includeIfNull: false) this.image_68, @JsonKey(includeIfNull: false) this.image_88, @JsonKey(includeIfNull: false) this.image_102, @JsonKey(includeIfNull: false) this.image_132, @JsonKey(includeIfNull: false) this.image_230});
  factory _SlackMessageTeamIconEntity.fromJson(Map<String, dynamic> json) => _$SlackMessageTeamIconEntityFromJson(json);

@override@JsonKey(includeIfNull: false) final  bool? imageDefault;
@override@JsonKey(includeIfNull: false) final  String? image_34;
@override@JsonKey(includeIfNull: false) final  String? image_44;
@override@JsonKey(includeIfNull: false) final  String? image_68;
@override@JsonKey(includeIfNull: false) final  String? image_88;
@override@JsonKey(includeIfNull: false) final  String? image_102;
@override@JsonKey(includeIfNull: false) final  String? image_132;
@override@JsonKey(includeIfNull: false) final  String? image_230;

/// Create a copy of SlackMessageTeamIconEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SlackMessageTeamIconEntityCopyWith<_SlackMessageTeamIconEntity> get copyWith => __$SlackMessageTeamIconEntityCopyWithImpl<_SlackMessageTeamIconEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SlackMessageTeamIconEntityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SlackMessageTeamIconEntity&&(identical(other.imageDefault, imageDefault) || other.imageDefault == imageDefault)&&(identical(other.image_34, image_34) || other.image_34 == image_34)&&(identical(other.image_44, image_44) || other.image_44 == image_44)&&(identical(other.image_68, image_68) || other.image_68 == image_68)&&(identical(other.image_88, image_88) || other.image_88 == image_88)&&(identical(other.image_102, image_102) || other.image_102 == image_102)&&(identical(other.image_132, image_132) || other.image_132 == image_132)&&(identical(other.image_230, image_230) || other.image_230 == image_230));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,imageDefault,image_34,image_44,image_68,image_88,image_102,image_132,image_230);

@override
String toString() {
  return 'SlackMessageTeamIconEntity(imageDefault: $imageDefault, image_34: $image_34, image_44: $image_44, image_68: $image_68, image_88: $image_88, image_102: $image_102, image_132: $image_132, image_230: $image_230)';
}


}

/// @nodoc
abstract mixin class _$SlackMessageTeamIconEntityCopyWith<$Res> implements $SlackMessageTeamIconEntityCopyWith<$Res> {
  factory _$SlackMessageTeamIconEntityCopyWith(_SlackMessageTeamIconEntity value, $Res Function(_SlackMessageTeamIconEntity) _then) = __$SlackMessageTeamIconEntityCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(includeIfNull: false) bool? imageDefault,@JsonKey(includeIfNull: false) String? image_34,@JsonKey(includeIfNull: false) String? image_44,@JsonKey(includeIfNull: false) String? image_68,@JsonKey(includeIfNull: false) String? image_88,@JsonKey(includeIfNull: false) String? image_102,@JsonKey(includeIfNull: false) String? image_132,@JsonKey(includeIfNull: false) String? image_230
});




}
/// @nodoc
class __$SlackMessageTeamIconEntityCopyWithImpl<$Res>
    implements _$SlackMessageTeamIconEntityCopyWith<$Res> {
  __$SlackMessageTeamIconEntityCopyWithImpl(this._self, this._then);

  final _SlackMessageTeamIconEntity _self;
  final $Res Function(_SlackMessageTeamIconEntity) _then;

/// Create a copy of SlackMessageTeamIconEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? imageDefault = freezed,Object? image_34 = freezed,Object? image_44 = freezed,Object? image_68 = freezed,Object? image_88 = freezed,Object? image_102 = freezed,Object? image_132 = freezed,Object? image_230 = freezed,}) {
  return _then(_SlackMessageTeamIconEntity(
imageDefault: freezed == imageDefault ? _self.imageDefault : imageDefault // ignore: cast_nullable_to_non_nullable
as bool?,image_34: freezed == image_34 ? _self.image_34 : image_34 // ignore: cast_nullable_to_non_nullable
as String?,image_44: freezed == image_44 ? _self.image_44 : image_44 // ignore: cast_nullable_to_non_nullable
as String?,image_68: freezed == image_68 ? _self.image_68 : image_68 // ignore: cast_nullable_to_non_nullable
as String?,image_88: freezed == image_88 ? _self.image_88 : image_88 // ignore: cast_nullable_to_non_nullable
as String?,image_102: freezed == image_102 ? _self.image_102 : image_102 // ignore: cast_nullable_to_non_nullable
as String?,image_132: freezed == image_132 ? _self.image_132 : image_132 // ignore: cast_nullable_to_non_nullable
as String?,image_230: freezed == image_230 ? _self.image_230 : image_230 // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
