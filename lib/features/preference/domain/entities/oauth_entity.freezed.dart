// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'oauth_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$OAuthEntity {

 String get email; String? get name; String? get imageUrl; String? get notificationUrl; String? get serverCode; Map<String, dynamic> get accessToken; String get refreshToken; OAuthType get type; MessageTeamEntity? get team; bool? get needReAuth;
/// Create a copy of OAuthEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OAuthEntityCopyWith<OAuthEntity> get copyWith => _$OAuthEntityCopyWithImpl<OAuthEntity>(this as OAuthEntity, _$identity);

  /// Serializes this OAuthEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OAuthEntity&&(identical(other.email, email) || other.email == email)&&(identical(other.name, name) || other.name == name)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.notificationUrl, notificationUrl) || other.notificationUrl == notificationUrl)&&(identical(other.serverCode, serverCode) || other.serverCode == serverCode)&&const DeepCollectionEquality().equals(other.accessToken, accessToken)&&(identical(other.refreshToken, refreshToken) || other.refreshToken == refreshToken)&&(identical(other.type, type) || other.type == type)&&(identical(other.team, team) || other.team == team)&&(identical(other.needReAuth, needReAuth) || other.needReAuth == needReAuth));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,email,name,imageUrl,notificationUrl,serverCode,const DeepCollectionEquality().hash(accessToken),refreshToken,type,team,needReAuth);

@override
String toString() {
  return 'OAuthEntity(email: $email, name: $name, imageUrl: $imageUrl, notificationUrl: $notificationUrl, serverCode: $serverCode, accessToken: $accessToken, refreshToken: $refreshToken, type: $type, team: $team, needReAuth: $needReAuth)';
}


}

/// @nodoc
abstract mixin class $OAuthEntityCopyWith<$Res>  {
  factory $OAuthEntityCopyWith(OAuthEntity value, $Res Function(OAuthEntity) _then) = _$OAuthEntityCopyWithImpl;
@useResult
$Res call({
 String email, String? name, String? imageUrl, String? notificationUrl, String? serverCode, Map<String, dynamic> accessToken, String refreshToken, OAuthType type, MessageTeamEntity? team, bool? needReAuth
});




}
/// @nodoc
class _$OAuthEntityCopyWithImpl<$Res>
    implements $OAuthEntityCopyWith<$Res> {
  _$OAuthEntityCopyWithImpl(this._self, this._then);

  final OAuthEntity _self;
  final $Res Function(OAuthEntity) _then;

/// Create a copy of OAuthEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? email = null,Object? name = freezed,Object? imageUrl = freezed,Object? notificationUrl = freezed,Object? serverCode = freezed,Object? accessToken = null,Object? refreshToken = null,Object? type = null,Object? team = freezed,Object? needReAuth = freezed,}) {
  return _then(_self.copyWith(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,notificationUrl: freezed == notificationUrl ? _self.notificationUrl : notificationUrl // ignore: cast_nullable_to_non_nullable
as String?,serverCode: freezed == serverCode ? _self.serverCode : serverCode // ignore: cast_nullable_to_non_nullable
as String?,accessToken: null == accessToken ? _self.accessToken : accessToken // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,refreshToken: null == refreshToken ? _self.refreshToken : refreshToken // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as OAuthType,team: freezed == team ? _self.team : team // ignore: cast_nullable_to_non_nullable
as MessageTeamEntity?,needReAuth: freezed == needReAuth ? _self.needReAuth : needReAuth // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}

}


/// Adds pattern-matching-related methods to [OAuthEntity].
extension OAuthEntityPatterns on OAuthEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OAuthEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OAuthEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OAuthEntity value)  $default,){
final _that = this;
switch (_that) {
case _OAuthEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OAuthEntity value)?  $default,){
final _that = this;
switch (_that) {
case _OAuthEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String email,  String? name,  String? imageUrl,  String? notificationUrl,  String? serverCode,  Map<String, dynamic> accessToken,  String refreshToken,  OAuthType type,  MessageTeamEntity? team,  bool? needReAuth)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OAuthEntity() when $default != null:
return $default(_that.email,_that.name,_that.imageUrl,_that.notificationUrl,_that.serverCode,_that.accessToken,_that.refreshToken,_that.type,_that.team,_that.needReAuth);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String email,  String? name,  String? imageUrl,  String? notificationUrl,  String? serverCode,  Map<String, dynamic> accessToken,  String refreshToken,  OAuthType type,  MessageTeamEntity? team,  bool? needReAuth)  $default,) {final _that = this;
switch (_that) {
case _OAuthEntity():
return $default(_that.email,_that.name,_that.imageUrl,_that.notificationUrl,_that.serverCode,_that.accessToken,_that.refreshToken,_that.type,_that.team,_that.needReAuth);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String email,  String? name,  String? imageUrl,  String? notificationUrl,  String? serverCode,  Map<String, dynamic> accessToken,  String refreshToken,  OAuthType type,  MessageTeamEntity? team,  bool? needReAuth)?  $default,) {final _that = this;
switch (_that) {
case _OAuthEntity() when $default != null:
return $default(_that.email,_that.name,_that.imageUrl,_that.notificationUrl,_that.serverCode,_that.accessToken,_that.refreshToken,_that.type,_that.team,_that.needReAuth);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _OAuthEntity implements OAuthEntity {
  const _OAuthEntity({required this.email, this.name, this.imageUrl, this.notificationUrl, this.serverCode, required final  Map<String, dynamic> accessToken, required this.refreshToken, required this.type, this.team, this.needReAuth}): _accessToken = accessToken;
  factory _OAuthEntity.fromJson(Map<String, dynamic> json) => _$OAuthEntityFromJson(json);

@override final  String email;
@override final  String? name;
@override final  String? imageUrl;
@override final  String? notificationUrl;
@override final  String? serverCode;
 final  Map<String, dynamic> _accessToken;
@override Map<String, dynamic> get accessToken {
  if (_accessToken is EqualUnmodifiableMapView) return _accessToken;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_accessToken);
}

@override final  String refreshToken;
@override final  OAuthType type;
@override final  MessageTeamEntity? team;
@override final  bool? needReAuth;

/// Create a copy of OAuthEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OAuthEntityCopyWith<_OAuthEntity> get copyWith => __$OAuthEntityCopyWithImpl<_OAuthEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OAuthEntityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OAuthEntity&&(identical(other.email, email) || other.email == email)&&(identical(other.name, name) || other.name == name)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.notificationUrl, notificationUrl) || other.notificationUrl == notificationUrl)&&(identical(other.serverCode, serverCode) || other.serverCode == serverCode)&&const DeepCollectionEquality().equals(other._accessToken, _accessToken)&&(identical(other.refreshToken, refreshToken) || other.refreshToken == refreshToken)&&(identical(other.type, type) || other.type == type)&&(identical(other.team, team) || other.team == team)&&(identical(other.needReAuth, needReAuth) || other.needReAuth == needReAuth));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,email,name,imageUrl,notificationUrl,serverCode,const DeepCollectionEquality().hash(_accessToken),refreshToken,type,team,needReAuth);

@override
String toString() {
  return 'OAuthEntity(email: $email, name: $name, imageUrl: $imageUrl, notificationUrl: $notificationUrl, serverCode: $serverCode, accessToken: $accessToken, refreshToken: $refreshToken, type: $type, team: $team, needReAuth: $needReAuth)';
}


}

/// @nodoc
abstract mixin class _$OAuthEntityCopyWith<$Res> implements $OAuthEntityCopyWith<$Res> {
  factory _$OAuthEntityCopyWith(_OAuthEntity value, $Res Function(_OAuthEntity) _then) = __$OAuthEntityCopyWithImpl;
@override @useResult
$Res call({
 String email, String? name, String? imageUrl, String? notificationUrl, String? serverCode, Map<String, dynamic> accessToken, String refreshToken, OAuthType type, MessageTeamEntity? team, bool? needReAuth
});




}
/// @nodoc
class __$OAuthEntityCopyWithImpl<$Res>
    implements _$OAuthEntityCopyWith<$Res> {
  __$OAuthEntityCopyWithImpl(this._self, this._then);

  final _OAuthEntity _self;
  final $Res Function(_OAuthEntity) _then;

/// Create a copy of OAuthEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? email = null,Object? name = freezed,Object? imageUrl = freezed,Object? notificationUrl = freezed,Object? serverCode = freezed,Object? accessToken = null,Object? refreshToken = null,Object? type = null,Object? team = freezed,Object? needReAuth = freezed,}) {
  return _then(_OAuthEntity(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,notificationUrl: freezed == notificationUrl ? _self.notificationUrl : notificationUrl // ignore: cast_nullable_to_non_nullable
as String?,serverCode: freezed == serverCode ? _self.serverCode : serverCode // ignore: cast_nullable_to_non_nullable
as String?,accessToken: null == accessToken ? _self._accessToken : accessToken // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,refreshToken: null == refreshToken ? _self.refreshToken : refreshToken // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as OAuthType,team: freezed == team ? _self.team : team // ignore: cast_nullable_to_non_nullable
as MessageTeamEntity?,needReAuth: freezed == needReAuth ? _self.needReAuth : needReAuth // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}


}

// dart format on
