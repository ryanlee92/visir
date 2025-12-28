// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'slack_message_team_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
SlackMessageTeamEntity _$SlackMessageTeamEntityFromJson(
  Map<String, dynamic> json
) {
    return _SlackTeamEntity.fromJson(
      json
    );
}

/// @nodoc
mixin _$SlackMessageTeamEntity {

 String get id; String get name; String get domain; String get email_domain;@JsonKey(includeIfNull: false) String? get avatar_base_url;@JsonKey(includeIfNull: false) bool? get isVerified;@JsonKey(includeIfNull: false) String? get publicUrl;@JsonKey(includeIfNull: false) String? get enterprise_id;@JsonKey(includeIfNull: false) String? get enterprise_name;@JsonKey(includeIfNull: false) SlackMessageTeamIconEntity? get icon;
/// Create a copy of SlackMessageTeamEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SlackMessageTeamEntityCopyWith<SlackMessageTeamEntity> get copyWith => _$SlackMessageTeamEntityCopyWithImpl<SlackMessageTeamEntity>(this as SlackMessageTeamEntity, _$identity);

  /// Serializes this SlackMessageTeamEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SlackMessageTeamEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.domain, domain) || other.domain == domain)&&(identical(other.email_domain, email_domain) || other.email_domain == email_domain)&&(identical(other.avatar_base_url, avatar_base_url) || other.avatar_base_url == avatar_base_url)&&(identical(other.isVerified, isVerified) || other.isVerified == isVerified)&&(identical(other.publicUrl, publicUrl) || other.publicUrl == publicUrl)&&(identical(other.enterprise_id, enterprise_id) || other.enterprise_id == enterprise_id)&&(identical(other.enterprise_name, enterprise_name) || other.enterprise_name == enterprise_name)&&(identical(other.icon, icon) || other.icon == icon));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,domain,email_domain,avatar_base_url,isVerified,publicUrl,enterprise_id,enterprise_name,icon);

@override
String toString() {
  return 'SlackMessageTeamEntity(id: $id, name: $name, domain: $domain, email_domain: $email_domain, avatar_base_url: $avatar_base_url, isVerified: $isVerified, publicUrl: $publicUrl, enterprise_id: $enterprise_id, enterprise_name: $enterprise_name, icon: $icon)';
}


}

/// @nodoc
abstract mixin class $SlackMessageTeamEntityCopyWith<$Res>  {
  factory $SlackMessageTeamEntityCopyWith(SlackMessageTeamEntity value, $Res Function(SlackMessageTeamEntity) _then) = _$SlackMessageTeamEntityCopyWithImpl;
@useResult
$Res call({
 String id, String name, String domain, String email_domain,@JsonKey(includeIfNull: false) String? avatar_base_url,@JsonKey(includeIfNull: false) bool? isVerified,@JsonKey(includeIfNull: false) String? publicUrl,@JsonKey(includeIfNull: false) String? enterprise_id,@JsonKey(includeIfNull: false) String? enterprise_name,@JsonKey(includeIfNull: false) SlackMessageTeamIconEntity? icon
});


$SlackMessageTeamIconEntityCopyWith<$Res>? get icon;

}
/// @nodoc
class _$SlackMessageTeamEntityCopyWithImpl<$Res>
    implements $SlackMessageTeamEntityCopyWith<$Res> {
  _$SlackMessageTeamEntityCopyWithImpl(this._self, this._then);

  final SlackMessageTeamEntity _self;
  final $Res Function(SlackMessageTeamEntity) _then;

/// Create a copy of SlackMessageTeamEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? domain = null,Object? email_domain = null,Object? avatar_base_url = freezed,Object? isVerified = freezed,Object? publicUrl = freezed,Object? enterprise_id = freezed,Object? enterprise_name = freezed,Object? icon = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,domain: null == domain ? _self.domain : domain // ignore: cast_nullable_to_non_nullable
as String,email_domain: null == email_domain ? _self.email_domain : email_domain // ignore: cast_nullable_to_non_nullable
as String,avatar_base_url: freezed == avatar_base_url ? _self.avatar_base_url : avatar_base_url // ignore: cast_nullable_to_non_nullable
as String?,isVerified: freezed == isVerified ? _self.isVerified : isVerified // ignore: cast_nullable_to_non_nullable
as bool?,publicUrl: freezed == publicUrl ? _self.publicUrl : publicUrl // ignore: cast_nullable_to_non_nullable
as String?,enterprise_id: freezed == enterprise_id ? _self.enterprise_id : enterprise_id // ignore: cast_nullable_to_non_nullable
as String?,enterprise_name: freezed == enterprise_name ? _self.enterprise_name : enterprise_name // ignore: cast_nullable_to_non_nullable
as String?,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as SlackMessageTeamIconEntity?,
  ));
}
/// Create a copy of SlackMessageTeamEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SlackMessageTeamIconEntityCopyWith<$Res>? get icon {
    if (_self.icon == null) {
    return null;
  }

  return $SlackMessageTeamIconEntityCopyWith<$Res>(_self.icon!, (value) {
    return _then(_self.copyWith(icon: value));
  });
}
}


/// Adds pattern-matching-related methods to [SlackMessageTeamEntity].
extension SlackMessageTeamEntityPatterns on SlackMessageTeamEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SlackTeamEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SlackTeamEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SlackTeamEntity value)  $default,){
final _that = this;
switch (_that) {
case _SlackTeamEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SlackTeamEntity value)?  $default,){
final _that = this;
switch (_that) {
case _SlackTeamEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String domain,  String email_domain, @JsonKey(includeIfNull: false)  String? avatar_base_url, @JsonKey(includeIfNull: false)  bool? isVerified, @JsonKey(includeIfNull: false)  String? publicUrl, @JsonKey(includeIfNull: false)  String? enterprise_id, @JsonKey(includeIfNull: false)  String? enterprise_name, @JsonKey(includeIfNull: false)  SlackMessageTeamIconEntity? icon)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SlackTeamEntity() when $default != null:
return $default(_that.id,_that.name,_that.domain,_that.email_domain,_that.avatar_base_url,_that.isVerified,_that.publicUrl,_that.enterprise_id,_that.enterprise_name,_that.icon);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String domain,  String email_domain, @JsonKey(includeIfNull: false)  String? avatar_base_url, @JsonKey(includeIfNull: false)  bool? isVerified, @JsonKey(includeIfNull: false)  String? publicUrl, @JsonKey(includeIfNull: false)  String? enterprise_id, @JsonKey(includeIfNull: false)  String? enterprise_name, @JsonKey(includeIfNull: false)  SlackMessageTeamIconEntity? icon)  $default,) {final _that = this;
switch (_that) {
case _SlackTeamEntity():
return $default(_that.id,_that.name,_that.domain,_that.email_domain,_that.avatar_base_url,_that.isVerified,_that.publicUrl,_that.enterprise_id,_that.enterprise_name,_that.icon);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String domain,  String email_domain, @JsonKey(includeIfNull: false)  String? avatar_base_url, @JsonKey(includeIfNull: false)  bool? isVerified, @JsonKey(includeIfNull: false)  String? publicUrl, @JsonKey(includeIfNull: false)  String? enterprise_id, @JsonKey(includeIfNull: false)  String? enterprise_name, @JsonKey(includeIfNull: false)  SlackMessageTeamIconEntity? icon)?  $default,) {final _that = this;
switch (_that) {
case _SlackTeamEntity() when $default != null:
return $default(_that.id,_that.name,_that.domain,_that.email_domain,_that.avatar_base_url,_that.isVerified,_that.publicUrl,_that.enterprise_id,_that.enterprise_name,_that.icon);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _SlackTeamEntity implements SlackMessageTeamEntity {
  const _SlackTeamEntity({required this.id, required this.name, required this.domain, required this.email_domain, @JsonKey(includeIfNull: false) this.avatar_base_url, @JsonKey(includeIfNull: false) this.isVerified, @JsonKey(includeIfNull: false) this.publicUrl, @JsonKey(includeIfNull: false) this.enterprise_id, @JsonKey(includeIfNull: false) this.enterprise_name, @JsonKey(includeIfNull: false) this.icon});
  factory _SlackTeamEntity.fromJson(Map<String, dynamic> json) => _$SlackTeamEntityFromJson(json);

@override final  String id;
@override final  String name;
@override final  String domain;
@override final  String email_domain;
@override@JsonKey(includeIfNull: false) final  String? avatar_base_url;
@override@JsonKey(includeIfNull: false) final  bool? isVerified;
@override@JsonKey(includeIfNull: false) final  String? publicUrl;
@override@JsonKey(includeIfNull: false) final  String? enterprise_id;
@override@JsonKey(includeIfNull: false) final  String? enterprise_name;
@override@JsonKey(includeIfNull: false) final  SlackMessageTeamIconEntity? icon;

/// Create a copy of SlackMessageTeamEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SlackTeamEntityCopyWith<_SlackTeamEntity> get copyWith => __$SlackTeamEntityCopyWithImpl<_SlackTeamEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SlackTeamEntityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SlackTeamEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.domain, domain) || other.domain == domain)&&(identical(other.email_domain, email_domain) || other.email_domain == email_domain)&&(identical(other.avatar_base_url, avatar_base_url) || other.avatar_base_url == avatar_base_url)&&(identical(other.isVerified, isVerified) || other.isVerified == isVerified)&&(identical(other.publicUrl, publicUrl) || other.publicUrl == publicUrl)&&(identical(other.enterprise_id, enterprise_id) || other.enterprise_id == enterprise_id)&&(identical(other.enterprise_name, enterprise_name) || other.enterprise_name == enterprise_name)&&(identical(other.icon, icon) || other.icon == icon));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,domain,email_domain,avatar_base_url,isVerified,publicUrl,enterprise_id,enterprise_name,icon);

@override
String toString() {
  return 'SlackMessageTeamEntity(id: $id, name: $name, domain: $domain, email_domain: $email_domain, avatar_base_url: $avatar_base_url, isVerified: $isVerified, publicUrl: $publicUrl, enterprise_id: $enterprise_id, enterprise_name: $enterprise_name, icon: $icon)';
}


}

/// @nodoc
abstract mixin class _$SlackTeamEntityCopyWith<$Res> implements $SlackMessageTeamEntityCopyWith<$Res> {
  factory _$SlackTeamEntityCopyWith(_SlackTeamEntity value, $Res Function(_SlackTeamEntity) _then) = __$SlackTeamEntityCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String domain, String email_domain,@JsonKey(includeIfNull: false) String? avatar_base_url,@JsonKey(includeIfNull: false) bool? isVerified,@JsonKey(includeIfNull: false) String? publicUrl,@JsonKey(includeIfNull: false) String? enterprise_id,@JsonKey(includeIfNull: false) String? enterprise_name,@JsonKey(includeIfNull: false) SlackMessageTeamIconEntity? icon
});


@override $SlackMessageTeamIconEntityCopyWith<$Res>? get icon;

}
/// @nodoc
class __$SlackTeamEntityCopyWithImpl<$Res>
    implements _$SlackTeamEntityCopyWith<$Res> {
  __$SlackTeamEntityCopyWithImpl(this._self, this._then);

  final _SlackTeamEntity _self;
  final $Res Function(_SlackTeamEntity) _then;

/// Create a copy of SlackMessageTeamEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? domain = null,Object? email_domain = null,Object? avatar_base_url = freezed,Object? isVerified = freezed,Object? publicUrl = freezed,Object? enterprise_id = freezed,Object? enterprise_name = freezed,Object? icon = freezed,}) {
  return _then(_SlackTeamEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,domain: null == domain ? _self.domain : domain // ignore: cast_nullable_to_non_nullable
as String,email_domain: null == email_domain ? _self.email_domain : email_domain // ignore: cast_nullable_to_non_nullable
as String,avatar_base_url: freezed == avatar_base_url ? _self.avatar_base_url : avatar_base_url // ignore: cast_nullable_to_non_nullable
as String?,isVerified: freezed == isVerified ? _self.isVerified : isVerified // ignore: cast_nullable_to_non_nullable
as bool?,publicUrl: freezed == publicUrl ? _self.publicUrl : publicUrl // ignore: cast_nullable_to_non_nullable
as String?,enterprise_id: freezed == enterprise_id ? _self.enterprise_id : enterprise_id // ignore: cast_nullable_to_non_nullable
as String?,enterprise_name: freezed == enterprise_name ? _self.enterprise_name : enterprise_name // ignore: cast_nullable_to_non_nullable
as String?,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as SlackMessageTeamIconEntity?,
  ));
}

/// Create a copy of SlackMessageTeamEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SlackMessageTeamIconEntityCopyWith<$Res>? get icon {
    if (_self.icon == null) {
    return null;
  }

  return $SlackMessageTeamIconEntityCopyWith<$Res>(_self.icon!, (value) {
    return _then(_self.copyWith(icon: value));
  });
}
}

// dart format on
