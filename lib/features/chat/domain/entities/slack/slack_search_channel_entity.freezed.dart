// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'slack_search_channel_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SlackSearchChannelEntity {

@JsonKey(includeIfNull: false) String? get id;@JsonKey(includeIfNull: false) bool? get isExtShared;@JsonKey(includeIfNull: false) bool? get isMpim;@JsonKey(includeIfNull: false) bool? get isOrgShared;@JsonKey(includeIfNull: false) bool? get isPendingExtShared;@JsonKey(includeIfNull: false) bool? get isPrivate;@JsonKey(includeIfNull: false) bool? get isShared;@JsonKey(includeIfNull: false) String? get name;
/// Create a copy of SlackSearchChannelEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SlackSearchChannelEntityCopyWith<SlackSearchChannelEntity> get copyWith => _$SlackSearchChannelEntityCopyWithImpl<SlackSearchChannelEntity>(this as SlackSearchChannelEntity, _$identity);

  /// Serializes this SlackSearchChannelEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SlackSearchChannelEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.isExtShared, isExtShared) || other.isExtShared == isExtShared)&&(identical(other.isMpim, isMpim) || other.isMpim == isMpim)&&(identical(other.isOrgShared, isOrgShared) || other.isOrgShared == isOrgShared)&&(identical(other.isPendingExtShared, isPendingExtShared) || other.isPendingExtShared == isPendingExtShared)&&(identical(other.isPrivate, isPrivate) || other.isPrivate == isPrivate)&&(identical(other.isShared, isShared) || other.isShared == isShared)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,isExtShared,isMpim,isOrgShared,isPendingExtShared,isPrivate,isShared,name);

@override
String toString() {
  return 'SlackSearchChannelEntity(id: $id, isExtShared: $isExtShared, isMpim: $isMpim, isOrgShared: $isOrgShared, isPendingExtShared: $isPendingExtShared, isPrivate: $isPrivate, isShared: $isShared, name: $name)';
}


}

/// @nodoc
abstract mixin class $SlackSearchChannelEntityCopyWith<$Res>  {
  factory $SlackSearchChannelEntityCopyWith(SlackSearchChannelEntity value, $Res Function(SlackSearchChannelEntity) _then) = _$SlackSearchChannelEntityCopyWithImpl;
@useResult
$Res call({
@JsonKey(includeIfNull: false) String? id,@JsonKey(includeIfNull: false) bool? isExtShared,@JsonKey(includeIfNull: false) bool? isMpim,@JsonKey(includeIfNull: false) bool? isOrgShared,@JsonKey(includeIfNull: false) bool? isPendingExtShared,@JsonKey(includeIfNull: false) bool? isPrivate,@JsonKey(includeIfNull: false) bool? isShared,@JsonKey(includeIfNull: false) String? name
});




}
/// @nodoc
class _$SlackSearchChannelEntityCopyWithImpl<$Res>
    implements $SlackSearchChannelEntityCopyWith<$Res> {
  _$SlackSearchChannelEntityCopyWithImpl(this._self, this._then);

  final SlackSearchChannelEntity _self;
  final $Res Function(SlackSearchChannelEntity) _then;

/// Create a copy of SlackSearchChannelEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? isExtShared = freezed,Object? isMpim = freezed,Object? isOrgShared = freezed,Object? isPendingExtShared = freezed,Object? isPrivate = freezed,Object? isShared = freezed,Object? name = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,isExtShared: freezed == isExtShared ? _self.isExtShared : isExtShared // ignore: cast_nullable_to_non_nullable
as bool?,isMpim: freezed == isMpim ? _self.isMpim : isMpim // ignore: cast_nullable_to_non_nullable
as bool?,isOrgShared: freezed == isOrgShared ? _self.isOrgShared : isOrgShared // ignore: cast_nullable_to_non_nullable
as bool?,isPendingExtShared: freezed == isPendingExtShared ? _self.isPendingExtShared : isPendingExtShared // ignore: cast_nullable_to_non_nullable
as bool?,isPrivate: freezed == isPrivate ? _self.isPrivate : isPrivate // ignore: cast_nullable_to_non_nullable
as bool?,isShared: freezed == isShared ? _self.isShared : isShared // ignore: cast_nullable_to_non_nullable
as bool?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [SlackSearchChannelEntity].
extension SlackSearchChannelEntityPatterns on SlackSearchChannelEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SlackSearchChannelEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SlackSearchChannelEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SlackSearchChannelEntity value)  $default,){
final _that = this;
switch (_that) {
case _SlackSearchChannelEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SlackSearchChannelEntity value)?  $default,){
final _that = this;
switch (_that) {
case _SlackSearchChannelEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(includeIfNull: false)  String? id, @JsonKey(includeIfNull: false)  bool? isExtShared, @JsonKey(includeIfNull: false)  bool? isMpim, @JsonKey(includeIfNull: false)  bool? isOrgShared, @JsonKey(includeIfNull: false)  bool? isPendingExtShared, @JsonKey(includeIfNull: false)  bool? isPrivate, @JsonKey(includeIfNull: false)  bool? isShared, @JsonKey(includeIfNull: false)  String? name)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SlackSearchChannelEntity() when $default != null:
return $default(_that.id,_that.isExtShared,_that.isMpim,_that.isOrgShared,_that.isPendingExtShared,_that.isPrivate,_that.isShared,_that.name);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(includeIfNull: false)  String? id, @JsonKey(includeIfNull: false)  bool? isExtShared, @JsonKey(includeIfNull: false)  bool? isMpim, @JsonKey(includeIfNull: false)  bool? isOrgShared, @JsonKey(includeIfNull: false)  bool? isPendingExtShared, @JsonKey(includeIfNull: false)  bool? isPrivate, @JsonKey(includeIfNull: false)  bool? isShared, @JsonKey(includeIfNull: false)  String? name)  $default,) {final _that = this;
switch (_that) {
case _SlackSearchChannelEntity():
return $default(_that.id,_that.isExtShared,_that.isMpim,_that.isOrgShared,_that.isPendingExtShared,_that.isPrivate,_that.isShared,_that.name);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(includeIfNull: false)  String? id, @JsonKey(includeIfNull: false)  bool? isExtShared, @JsonKey(includeIfNull: false)  bool? isMpim, @JsonKey(includeIfNull: false)  bool? isOrgShared, @JsonKey(includeIfNull: false)  bool? isPendingExtShared, @JsonKey(includeIfNull: false)  bool? isPrivate, @JsonKey(includeIfNull: false)  bool? isShared, @JsonKey(includeIfNull: false)  String? name)?  $default,) {final _that = this;
switch (_that) {
case _SlackSearchChannelEntity() when $default != null:
return $default(_that.id,_that.isExtShared,_that.isMpim,_that.isOrgShared,_that.isPendingExtShared,_that.isPrivate,_that.isShared,_that.name);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _SlackSearchChannelEntity implements SlackSearchChannelEntity {
  const _SlackSearchChannelEntity({@JsonKey(includeIfNull: false) this.id, @JsonKey(includeIfNull: false) this.isExtShared, @JsonKey(includeIfNull: false) this.isMpim, @JsonKey(includeIfNull: false) this.isOrgShared, @JsonKey(includeIfNull: false) this.isPendingExtShared, @JsonKey(includeIfNull: false) this.isPrivate, @JsonKey(includeIfNull: false) this.isShared, @JsonKey(includeIfNull: false) this.name});
  factory _SlackSearchChannelEntity.fromJson(Map<String, dynamic> json) => _$SlackSearchChannelEntityFromJson(json);

@override@JsonKey(includeIfNull: false) final  String? id;
@override@JsonKey(includeIfNull: false) final  bool? isExtShared;
@override@JsonKey(includeIfNull: false) final  bool? isMpim;
@override@JsonKey(includeIfNull: false) final  bool? isOrgShared;
@override@JsonKey(includeIfNull: false) final  bool? isPendingExtShared;
@override@JsonKey(includeIfNull: false) final  bool? isPrivate;
@override@JsonKey(includeIfNull: false) final  bool? isShared;
@override@JsonKey(includeIfNull: false) final  String? name;

/// Create a copy of SlackSearchChannelEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SlackSearchChannelEntityCopyWith<_SlackSearchChannelEntity> get copyWith => __$SlackSearchChannelEntityCopyWithImpl<_SlackSearchChannelEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SlackSearchChannelEntityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SlackSearchChannelEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.isExtShared, isExtShared) || other.isExtShared == isExtShared)&&(identical(other.isMpim, isMpim) || other.isMpim == isMpim)&&(identical(other.isOrgShared, isOrgShared) || other.isOrgShared == isOrgShared)&&(identical(other.isPendingExtShared, isPendingExtShared) || other.isPendingExtShared == isPendingExtShared)&&(identical(other.isPrivate, isPrivate) || other.isPrivate == isPrivate)&&(identical(other.isShared, isShared) || other.isShared == isShared)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,isExtShared,isMpim,isOrgShared,isPendingExtShared,isPrivate,isShared,name);

@override
String toString() {
  return 'SlackSearchChannelEntity(id: $id, isExtShared: $isExtShared, isMpim: $isMpim, isOrgShared: $isOrgShared, isPendingExtShared: $isPendingExtShared, isPrivate: $isPrivate, isShared: $isShared, name: $name)';
}


}

/// @nodoc
abstract mixin class _$SlackSearchChannelEntityCopyWith<$Res> implements $SlackSearchChannelEntityCopyWith<$Res> {
  factory _$SlackSearchChannelEntityCopyWith(_SlackSearchChannelEntity value, $Res Function(_SlackSearchChannelEntity) _then) = __$SlackSearchChannelEntityCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(includeIfNull: false) String? id,@JsonKey(includeIfNull: false) bool? isExtShared,@JsonKey(includeIfNull: false) bool? isMpim,@JsonKey(includeIfNull: false) bool? isOrgShared,@JsonKey(includeIfNull: false) bool? isPendingExtShared,@JsonKey(includeIfNull: false) bool? isPrivate,@JsonKey(includeIfNull: false) bool? isShared,@JsonKey(includeIfNull: false) String? name
});




}
/// @nodoc
class __$SlackSearchChannelEntityCopyWithImpl<$Res>
    implements _$SlackSearchChannelEntityCopyWith<$Res> {
  __$SlackSearchChannelEntityCopyWithImpl(this._self, this._then);

  final _SlackSearchChannelEntity _self;
  final $Res Function(_SlackSearchChannelEntity) _then;

/// Create a copy of SlackSearchChannelEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? isExtShared = freezed,Object? isMpim = freezed,Object? isOrgShared = freezed,Object? isPendingExtShared = freezed,Object? isPrivate = freezed,Object? isShared = freezed,Object? name = freezed,}) {
  return _then(_SlackSearchChannelEntity(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,isExtShared: freezed == isExtShared ? _self.isExtShared : isExtShared // ignore: cast_nullable_to_non_nullable
as bool?,isMpim: freezed == isMpim ? _self.isMpim : isMpim // ignore: cast_nullable_to_non_nullable
as bool?,isOrgShared: freezed == isOrgShared ? _self.isOrgShared : isOrgShared // ignore: cast_nullable_to_non_nullable
as bool?,isPendingExtShared: freezed == isPendingExtShared ? _self.isPendingExtShared : isPendingExtShared // ignore: cast_nullable_to_non_nullable
as bool?,isPrivate: freezed == isPrivate ? _self.isPrivate : isPrivate // ignore: cast_nullable_to_non_nullable
as bool?,isShared: freezed == isShared ? _self.isShared : isShared // ignore: cast_nullable_to_non_nullable
as bool?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
