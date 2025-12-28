// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'slack_message_member_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
SlackMessageMemberEntity _$SlackMessageMemberEntityFromJson(
  Map<String, dynamic> json
) {
    return _SlackMessageTeamMemberEntity.fromJson(
      json
    );
}

/// @nodoc
mixin _$SlackMessageMemberEntity {

@JsonKey(includeIfNull: false) bool? get alwaysActive;@JsonKey(includeIfNull: false) String? get color;@JsonKey(includeIfNull: false) bool? get deleted;@JsonKey(includeIfNull: false) bool? get has2fa;@JsonKey(includeIfNull: false) String? get id;@JsonKey(includeIfNull: false) bool? get isAdmin;@JsonKey(includeIfNull: false) bool? get isAppUser;@JsonKey(includeIfNull: false) bool? get isBot;@JsonKey(includeIfNull: false) bool? get isInvitedUser;@JsonKey(includeIfNull: false) bool? get isOwner;@JsonKey(includeIfNull: false) bool? get isPrimaryOwner;@JsonKey(includeIfNull: false) bool? get isRestricted;@JsonKey(includeIfNull: false) bool? get isStranger;@JsonKey(includeIfNull: false) bool? get isUltraRestricted;@JsonKey(includeIfNull: false) String? get locale;@JsonKey(includeIfNull: false) String? get name;@JsonKey(includeIfNull: false) SlackMessageMemberProfileEntity? get profile;@JsonKey(includeIfNull: false) String? get twoFactorType;@JsonKey(includeIfNull: false) String? get tz;@JsonKey(includeIfNull: false) String? get tzLabel;@JsonKey(includeIfNull: false) int? get tzOffset;@JsonKey(includeIfNull: false) int? get updated;
/// Create a copy of SlackMessageMemberEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SlackMessageMemberEntityCopyWith<SlackMessageMemberEntity> get copyWith => _$SlackMessageMemberEntityCopyWithImpl<SlackMessageMemberEntity>(this as SlackMessageMemberEntity, _$identity);

  /// Serializes this SlackMessageMemberEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SlackMessageMemberEntity&&(identical(other.alwaysActive, alwaysActive) || other.alwaysActive == alwaysActive)&&(identical(other.color, color) || other.color == color)&&(identical(other.deleted, deleted) || other.deleted == deleted)&&(identical(other.has2fa, has2fa) || other.has2fa == has2fa)&&(identical(other.id, id) || other.id == id)&&(identical(other.isAdmin, isAdmin) || other.isAdmin == isAdmin)&&(identical(other.isAppUser, isAppUser) || other.isAppUser == isAppUser)&&(identical(other.isBot, isBot) || other.isBot == isBot)&&(identical(other.isInvitedUser, isInvitedUser) || other.isInvitedUser == isInvitedUser)&&(identical(other.isOwner, isOwner) || other.isOwner == isOwner)&&(identical(other.isPrimaryOwner, isPrimaryOwner) || other.isPrimaryOwner == isPrimaryOwner)&&(identical(other.isRestricted, isRestricted) || other.isRestricted == isRestricted)&&(identical(other.isStranger, isStranger) || other.isStranger == isStranger)&&(identical(other.isUltraRestricted, isUltraRestricted) || other.isUltraRestricted == isUltraRestricted)&&(identical(other.locale, locale) || other.locale == locale)&&(identical(other.name, name) || other.name == name)&&(identical(other.profile, profile) || other.profile == profile)&&(identical(other.twoFactorType, twoFactorType) || other.twoFactorType == twoFactorType)&&(identical(other.tz, tz) || other.tz == tz)&&(identical(other.tzLabel, tzLabel) || other.tzLabel == tzLabel)&&(identical(other.tzOffset, tzOffset) || other.tzOffset == tzOffset)&&(identical(other.updated, updated) || other.updated == updated));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,alwaysActive,color,deleted,has2fa,id,isAdmin,isAppUser,isBot,isInvitedUser,isOwner,isPrimaryOwner,isRestricted,isStranger,isUltraRestricted,locale,name,profile,twoFactorType,tz,tzLabel,tzOffset,updated]);

@override
String toString() {
  return 'SlackMessageMemberEntity(alwaysActive: $alwaysActive, color: $color, deleted: $deleted, has2fa: $has2fa, id: $id, isAdmin: $isAdmin, isAppUser: $isAppUser, isBot: $isBot, isInvitedUser: $isInvitedUser, isOwner: $isOwner, isPrimaryOwner: $isPrimaryOwner, isRestricted: $isRestricted, isStranger: $isStranger, isUltraRestricted: $isUltraRestricted, locale: $locale, name: $name, profile: $profile, twoFactorType: $twoFactorType, tz: $tz, tzLabel: $tzLabel, tzOffset: $tzOffset, updated: $updated)';
}


}

/// @nodoc
abstract mixin class $SlackMessageMemberEntityCopyWith<$Res>  {
  factory $SlackMessageMemberEntityCopyWith(SlackMessageMemberEntity value, $Res Function(SlackMessageMemberEntity) _then) = _$SlackMessageMemberEntityCopyWithImpl;
@useResult
$Res call({
@JsonKey(includeIfNull: false) bool? alwaysActive,@JsonKey(includeIfNull: false) String? color,@JsonKey(includeIfNull: false) bool? deleted,@JsonKey(includeIfNull: false) bool? has2fa,@JsonKey(includeIfNull: false) String? id,@JsonKey(includeIfNull: false) bool? isAdmin,@JsonKey(includeIfNull: false) bool? isAppUser,@JsonKey(includeIfNull: false) bool? isBot,@JsonKey(includeIfNull: false) bool? isInvitedUser,@JsonKey(includeIfNull: false) bool? isOwner,@JsonKey(includeIfNull: false) bool? isPrimaryOwner,@JsonKey(includeIfNull: false) bool? isRestricted,@JsonKey(includeIfNull: false) bool? isStranger,@JsonKey(includeIfNull: false) bool? isUltraRestricted,@JsonKey(includeIfNull: false) String? locale,@JsonKey(includeIfNull: false) String? name,@JsonKey(includeIfNull: false) SlackMessageMemberProfileEntity? profile,@JsonKey(includeIfNull: false) String? twoFactorType,@JsonKey(includeIfNull: false) String? tz,@JsonKey(includeIfNull: false) String? tzLabel,@JsonKey(includeIfNull: false) int? tzOffset,@JsonKey(includeIfNull: false) int? updated
});


$SlackMessageMemberProfileEntityCopyWith<$Res>? get profile;

}
/// @nodoc
class _$SlackMessageMemberEntityCopyWithImpl<$Res>
    implements $SlackMessageMemberEntityCopyWith<$Res> {
  _$SlackMessageMemberEntityCopyWithImpl(this._self, this._then);

  final SlackMessageMemberEntity _self;
  final $Res Function(SlackMessageMemberEntity) _then;

/// Create a copy of SlackMessageMemberEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? alwaysActive = freezed,Object? color = freezed,Object? deleted = freezed,Object? has2fa = freezed,Object? id = freezed,Object? isAdmin = freezed,Object? isAppUser = freezed,Object? isBot = freezed,Object? isInvitedUser = freezed,Object? isOwner = freezed,Object? isPrimaryOwner = freezed,Object? isRestricted = freezed,Object? isStranger = freezed,Object? isUltraRestricted = freezed,Object? locale = freezed,Object? name = freezed,Object? profile = freezed,Object? twoFactorType = freezed,Object? tz = freezed,Object? tzLabel = freezed,Object? tzOffset = freezed,Object? updated = freezed,}) {
  return _then(_self.copyWith(
alwaysActive: freezed == alwaysActive ? _self.alwaysActive : alwaysActive // ignore: cast_nullable_to_non_nullable
as bool?,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String?,deleted: freezed == deleted ? _self.deleted : deleted // ignore: cast_nullable_to_non_nullable
as bool?,has2fa: freezed == has2fa ? _self.has2fa : has2fa // ignore: cast_nullable_to_non_nullable
as bool?,id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,isAdmin: freezed == isAdmin ? _self.isAdmin : isAdmin // ignore: cast_nullable_to_non_nullable
as bool?,isAppUser: freezed == isAppUser ? _self.isAppUser : isAppUser // ignore: cast_nullable_to_non_nullable
as bool?,isBot: freezed == isBot ? _self.isBot : isBot // ignore: cast_nullable_to_non_nullable
as bool?,isInvitedUser: freezed == isInvitedUser ? _self.isInvitedUser : isInvitedUser // ignore: cast_nullable_to_non_nullable
as bool?,isOwner: freezed == isOwner ? _self.isOwner : isOwner // ignore: cast_nullable_to_non_nullable
as bool?,isPrimaryOwner: freezed == isPrimaryOwner ? _self.isPrimaryOwner : isPrimaryOwner // ignore: cast_nullable_to_non_nullable
as bool?,isRestricted: freezed == isRestricted ? _self.isRestricted : isRestricted // ignore: cast_nullable_to_non_nullable
as bool?,isStranger: freezed == isStranger ? _self.isStranger : isStranger // ignore: cast_nullable_to_non_nullable
as bool?,isUltraRestricted: freezed == isUltraRestricted ? _self.isUltraRestricted : isUltraRestricted // ignore: cast_nullable_to_non_nullable
as bool?,locale: freezed == locale ? _self.locale : locale // ignore: cast_nullable_to_non_nullable
as String?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,profile: freezed == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as SlackMessageMemberProfileEntity?,twoFactorType: freezed == twoFactorType ? _self.twoFactorType : twoFactorType // ignore: cast_nullable_to_non_nullable
as String?,tz: freezed == tz ? _self.tz : tz // ignore: cast_nullable_to_non_nullable
as String?,tzLabel: freezed == tzLabel ? _self.tzLabel : tzLabel // ignore: cast_nullable_to_non_nullable
as String?,tzOffset: freezed == tzOffset ? _self.tzOffset : tzOffset // ignore: cast_nullable_to_non_nullable
as int?,updated: freezed == updated ? _self.updated : updated // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}
/// Create a copy of SlackMessageMemberEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SlackMessageMemberProfileEntityCopyWith<$Res>? get profile {
    if (_self.profile == null) {
    return null;
  }

  return $SlackMessageMemberProfileEntityCopyWith<$Res>(_self.profile!, (value) {
    return _then(_self.copyWith(profile: value));
  });
}
}


/// Adds pattern-matching-related methods to [SlackMessageMemberEntity].
extension SlackMessageMemberEntityPatterns on SlackMessageMemberEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SlackMessageTeamMemberEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SlackMessageTeamMemberEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SlackMessageTeamMemberEntity value)  $default,){
final _that = this;
switch (_that) {
case _SlackMessageTeamMemberEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SlackMessageTeamMemberEntity value)?  $default,){
final _that = this;
switch (_that) {
case _SlackMessageTeamMemberEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(includeIfNull: false)  bool? alwaysActive, @JsonKey(includeIfNull: false)  String? color, @JsonKey(includeIfNull: false)  bool? deleted, @JsonKey(includeIfNull: false)  bool? has2fa, @JsonKey(includeIfNull: false)  String? id, @JsonKey(includeIfNull: false)  bool? isAdmin, @JsonKey(includeIfNull: false)  bool? isAppUser, @JsonKey(includeIfNull: false)  bool? isBot, @JsonKey(includeIfNull: false)  bool? isInvitedUser, @JsonKey(includeIfNull: false)  bool? isOwner, @JsonKey(includeIfNull: false)  bool? isPrimaryOwner, @JsonKey(includeIfNull: false)  bool? isRestricted, @JsonKey(includeIfNull: false)  bool? isStranger, @JsonKey(includeIfNull: false)  bool? isUltraRestricted, @JsonKey(includeIfNull: false)  String? locale, @JsonKey(includeIfNull: false)  String? name, @JsonKey(includeIfNull: false)  SlackMessageMemberProfileEntity? profile, @JsonKey(includeIfNull: false)  String? twoFactorType, @JsonKey(includeIfNull: false)  String? tz, @JsonKey(includeIfNull: false)  String? tzLabel, @JsonKey(includeIfNull: false)  int? tzOffset, @JsonKey(includeIfNull: false)  int? updated)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SlackMessageTeamMemberEntity() when $default != null:
return $default(_that.alwaysActive,_that.color,_that.deleted,_that.has2fa,_that.id,_that.isAdmin,_that.isAppUser,_that.isBot,_that.isInvitedUser,_that.isOwner,_that.isPrimaryOwner,_that.isRestricted,_that.isStranger,_that.isUltraRestricted,_that.locale,_that.name,_that.profile,_that.twoFactorType,_that.tz,_that.tzLabel,_that.tzOffset,_that.updated);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(includeIfNull: false)  bool? alwaysActive, @JsonKey(includeIfNull: false)  String? color, @JsonKey(includeIfNull: false)  bool? deleted, @JsonKey(includeIfNull: false)  bool? has2fa, @JsonKey(includeIfNull: false)  String? id, @JsonKey(includeIfNull: false)  bool? isAdmin, @JsonKey(includeIfNull: false)  bool? isAppUser, @JsonKey(includeIfNull: false)  bool? isBot, @JsonKey(includeIfNull: false)  bool? isInvitedUser, @JsonKey(includeIfNull: false)  bool? isOwner, @JsonKey(includeIfNull: false)  bool? isPrimaryOwner, @JsonKey(includeIfNull: false)  bool? isRestricted, @JsonKey(includeIfNull: false)  bool? isStranger, @JsonKey(includeIfNull: false)  bool? isUltraRestricted, @JsonKey(includeIfNull: false)  String? locale, @JsonKey(includeIfNull: false)  String? name, @JsonKey(includeIfNull: false)  SlackMessageMemberProfileEntity? profile, @JsonKey(includeIfNull: false)  String? twoFactorType, @JsonKey(includeIfNull: false)  String? tz, @JsonKey(includeIfNull: false)  String? tzLabel, @JsonKey(includeIfNull: false)  int? tzOffset, @JsonKey(includeIfNull: false)  int? updated)  $default,) {final _that = this;
switch (_that) {
case _SlackMessageTeamMemberEntity():
return $default(_that.alwaysActive,_that.color,_that.deleted,_that.has2fa,_that.id,_that.isAdmin,_that.isAppUser,_that.isBot,_that.isInvitedUser,_that.isOwner,_that.isPrimaryOwner,_that.isRestricted,_that.isStranger,_that.isUltraRestricted,_that.locale,_that.name,_that.profile,_that.twoFactorType,_that.tz,_that.tzLabel,_that.tzOffset,_that.updated);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(includeIfNull: false)  bool? alwaysActive, @JsonKey(includeIfNull: false)  String? color, @JsonKey(includeIfNull: false)  bool? deleted, @JsonKey(includeIfNull: false)  bool? has2fa, @JsonKey(includeIfNull: false)  String? id, @JsonKey(includeIfNull: false)  bool? isAdmin, @JsonKey(includeIfNull: false)  bool? isAppUser, @JsonKey(includeIfNull: false)  bool? isBot, @JsonKey(includeIfNull: false)  bool? isInvitedUser, @JsonKey(includeIfNull: false)  bool? isOwner, @JsonKey(includeIfNull: false)  bool? isPrimaryOwner, @JsonKey(includeIfNull: false)  bool? isRestricted, @JsonKey(includeIfNull: false)  bool? isStranger, @JsonKey(includeIfNull: false)  bool? isUltraRestricted, @JsonKey(includeIfNull: false)  String? locale, @JsonKey(includeIfNull: false)  String? name, @JsonKey(includeIfNull: false)  SlackMessageMemberProfileEntity? profile, @JsonKey(includeIfNull: false)  String? twoFactorType, @JsonKey(includeIfNull: false)  String? tz, @JsonKey(includeIfNull: false)  String? tzLabel, @JsonKey(includeIfNull: false)  int? tzOffset, @JsonKey(includeIfNull: false)  int? updated)?  $default,) {final _that = this;
switch (_that) {
case _SlackMessageTeamMemberEntity() when $default != null:
return $default(_that.alwaysActive,_that.color,_that.deleted,_that.has2fa,_that.id,_that.isAdmin,_that.isAppUser,_that.isBot,_that.isInvitedUser,_that.isOwner,_that.isPrimaryOwner,_that.isRestricted,_that.isStranger,_that.isUltraRestricted,_that.locale,_that.name,_that.profile,_that.twoFactorType,_that.tz,_that.tzLabel,_that.tzOffset,_that.updated);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _SlackMessageTeamMemberEntity implements SlackMessageMemberEntity {
  const _SlackMessageTeamMemberEntity({@JsonKey(includeIfNull: false) this.alwaysActive, @JsonKey(includeIfNull: false) this.color, @JsonKey(includeIfNull: false) this.deleted, @JsonKey(includeIfNull: false) this.has2fa, @JsonKey(includeIfNull: false) this.id, @JsonKey(includeIfNull: false) this.isAdmin, @JsonKey(includeIfNull: false) this.isAppUser, @JsonKey(includeIfNull: false) this.isBot, @JsonKey(includeIfNull: false) this.isInvitedUser, @JsonKey(includeIfNull: false) this.isOwner, @JsonKey(includeIfNull: false) this.isPrimaryOwner, @JsonKey(includeIfNull: false) this.isRestricted, @JsonKey(includeIfNull: false) this.isStranger, @JsonKey(includeIfNull: false) this.isUltraRestricted, @JsonKey(includeIfNull: false) this.locale, @JsonKey(includeIfNull: false) this.name, @JsonKey(includeIfNull: false) this.profile, @JsonKey(includeIfNull: false) this.twoFactorType, @JsonKey(includeIfNull: false) this.tz, @JsonKey(includeIfNull: false) this.tzLabel, @JsonKey(includeIfNull: false) this.tzOffset, @JsonKey(includeIfNull: false) this.updated});
  factory _SlackMessageTeamMemberEntity.fromJson(Map<String, dynamic> json) => _$SlackMessageTeamMemberEntityFromJson(json);

@override@JsonKey(includeIfNull: false) final  bool? alwaysActive;
@override@JsonKey(includeIfNull: false) final  String? color;
@override@JsonKey(includeIfNull: false) final  bool? deleted;
@override@JsonKey(includeIfNull: false) final  bool? has2fa;
@override@JsonKey(includeIfNull: false) final  String? id;
@override@JsonKey(includeIfNull: false) final  bool? isAdmin;
@override@JsonKey(includeIfNull: false) final  bool? isAppUser;
@override@JsonKey(includeIfNull: false) final  bool? isBot;
@override@JsonKey(includeIfNull: false) final  bool? isInvitedUser;
@override@JsonKey(includeIfNull: false) final  bool? isOwner;
@override@JsonKey(includeIfNull: false) final  bool? isPrimaryOwner;
@override@JsonKey(includeIfNull: false) final  bool? isRestricted;
@override@JsonKey(includeIfNull: false) final  bool? isStranger;
@override@JsonKey(includeIfNull: false) final  bool? isUltraRestricted;
@override@JsonKey(includeIfNull: false) final  String? locale;
@override@JsonKey(includeIfNull: false) final  String? name;
@override@JsonKey(includeIfNull: false) final  SlackMessageMemberProfileEntity? profile;
@override@JsonKey(includeIfNull: false) final  String? twoFactorType;
@override@JsonKey(includeIfNull: false) final  String? tz;
@override@JsonKey(includeIfNull: false) final  String? tzLabel;
@override@JsonKey(includeIfNull: false) final  int? tzOffset;
@override@JsonKey(includeIfNull: false) final  int? updated;

/// Create a copy of SlackMessageMemberEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SlackMessageTeamMemberEntityCopyWith<_SlackMessageTeamMemberEntity> get copyWith => __$SlackMessageTeamMemberEntityCopyWithImpl<_SlackMessageTeamMemberEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SlackMessageTeamMemberEntityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SlackMessageTeamMemberEntity&&(identical(other.alwaysActive, alwaysActive) || other.alwaysActive == alwaysActive)&&(identical(other.color, color) || other.color == color)&&(identical(other.deleted, deleted) || other.deleted == deleted)&&(identical(other.has2fa, has2fa) || other.has2fa == has2fa)&&(identical(other.id, id) || other.id == id)&&(identical(other.isAdmin, isAdmin) || other.isAdmin == isAdmin)&&(identical(other.isAppUser, isAppUser) || other.isAppUser == isAppUser)&&(identical(other.isBot, isBot) || other.isBot == isBot)&&(identical(other.isInvitedUser, isInvitedUser) || other.isInvitedUser == isInvitedUser)&&(identical(other.isOwner, isOwner) || other.isOwner == isOwner)&&(identical(other.isPrimaryOwner, isPrimaryOwner) || other.isPrimaryOwner == isPrimaryOwner)&&(identical(other.isRestricted, isRestricted) || other.isRestricted == isRestricted)&&(identical(other.isStranger, isStranger) || other.isStranger == isStranger)&&(identical(other.isUltraRestricted, isUltraRestricted) || other.isUltraRestricted == isUltraRestricted)&&(identical(other.locale, locale) || other.locale == locale)&&(identical(other.name, name) || other.name == name)&&(identical(other.profile, profile) || other.profile == profile)&&(identical(other.twoFactorType, twoFactorType) || other.twoFactorType == twoFactorType)&&(identical(other.tz, tz) || other.tz == tz)&&(identical(other.tzLabel, tzLabel) || other.tzLabel == tzLabel)&&(identical(other.tzOffset, tzOffset) || other.tzOffset == tzOffset)&&(identical(other.updated, updated) || other.updated == updated));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,alwaysActive,color,deleted,has2fa,id,isAdmin,isAppUser,isBot,isInvitedUser,isOwner,isPrimaryOwner,isRestricted,isStranger,isUltraRestricted,locale,name,profile,twoFactorType,tz,tzLabel,tzOffset,updated]);

@override
String toString() {
  return 'SlackMessageMemberEntity(alwaysActive: $alwaysActive, color: $color, deleted: $deleted, has2fa: $has2fa, id: $id, isAdmin: $isAdmin, isAppUser: $isAppUser, isBot: $isBot, isInvitedUser: $isInvitedUser, isOwner: $isOwner, isPrimaryOwner: $isPrimaryOwner, isRestricted: $isRestricted, isStranger: $isStranger, isUltraRestricted: $isUltraRestricted, locale: $locale, name: $name, profile: $profile, twoFactorType: $twoFactorType, tz: $tz, tzLabel: $tzLabel, tzOffset: $tzOffset, updated: $updated)';
}


}

/// @nodoc
abstract mixin class _$SlackMessageTeamMemberEntityCopyWith<$Res> implements $SlackMessageMemberEntityCopyWith<$Res> {
  factory _$SlackMessageTeamMemberEntityCopyWith(_SlackMessageTeamMemberEntity value, $Res Function(_SlackMessageTeamMemberEntity) _then) = __$SlackMessageTeamMemberEntityCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(includeIfNull: false) bool? alwaysActive,@JsonKey(includeIfNull: false) String? color,@JsonKey(includeIfNull: false) bool? deleted,@JsonKey(includeIfNull: false) bool? has2fa,@JsonKey(includeIfNull: false) String? id,@JsonKey(includeIfNull: false) bool? isAdmin,@JsonKey(includeIfNull: false) bool? isAppUser,@JsonKey(includeIfNull: false) bool? isBot,@JsonKey(includeIfNull: false) bool? isInvitedUser,@JsonKey(includeIfNull: false) bool? isOwner,@JsonKey(includeIfNull: false) bool? isPrimaryOwner,@JsonKey(includeIfNull: false) bool? isRestricted,@JsonKey(includeIfNull: false) bool? isStranger,@JsonKey(includeIfNull: false) bool? isUltraRestricted,@JsonKey(includeIfNull: false) String? locale,@JsonKey(includeIfNull: false) String? name,@JsonKey(includeIfNull: false) SlackMessageMemberProfileEntity? profile,@JsonKey(includeIfNull: false) String? twoFactorType,@JsonKey(includeIfNull: false) String? tz,@JsonKey(includeIfNull: false) String? tzLabel,@JsonKey(includeIfNull: false) int? tzOffset,@JsonKey(includeIfNull: false) int? updated
});


@override $SlackMessageMemberProfileEntityCopyWith<$Res>? get profile;

}
/// @nodoc
class __$SlackMessageTeamMemberEntityCopyWithImpl<$Res>
    implements _$SlackMessageTeamMemberEntityCopyWith<$Res> {
  __$SlackMessageTeamMemberEntityCopyWithImpl(this._self, this._then);

  final _SlackMessageTeamMemberEntity _self;
  final $Res Function(_SlackMessageTeamMemberEntity) _then;

/// Create a copy of SlackMessageMemberEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? alwaysActive = freezed,Object? color = freezed,Object? deleted = freezed,Object? has2fa = freezed,Object? id = freezed,Object? isAdmin = freezed,Object? isAppUser = freezed,Object? isBot = freezed,Object? isInvitedUser = freezed,Object? isOwner = freezed,Object? isPrimaryOwner = freezed,Object? isRestricted = freezed,Object? isStranger = freezed,Object? isUltraRestricted = freezed,Object? locale = freezed,Object? name = freezed,Object? profile = freezed,Object? twoFactorType = freezed,Object? tz = freezed,Object? tzLabel = freezed,Object? tzOffset = freezed,Object? updated = freezed,}) {
  return _then(_SlackMessageTeamMemberEntity(
alwaysActive: freezed == alwaysActive ? _self.alwaysActive : alwaysActive // ignore: cast_nullable_to_non_nullable
as bool?,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String?,deleted: freezed == deleted ? _self.deleted : deleted // ignore: cast_nullable_to_non_nullable
as bool?,has2fa: freezed == has2fa ? _self.has2fa : has2fa // ignore: cast_nullable_to_non_nullable
as bool?,id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,isAdmin: freezed == isAdmin ? _self.isAdmin : isAdmin // ignore: cast_nullable_to_non_nullable
as bool?,isAppUser: freezed == isAppUser ? _self.isAppUser : isAppUser // ignore: cast_nullable_to_non_nullable
as bool?,isBot: freezed == isBot ? _self.isBot : isBot // ignore: cast_nullable_to_non_nullable
as bool?,isInvitedUser: freezed == isInvitedUser ? _self.isInvitedUser : isInvitedUser // ignore: cast_nullable_to_non_nullable
as bool?,isOwner: freezed == isOwner ? _self.isOwner : isOwner // ignore: cast_nullable_to_non_nullable
as bool?,isPrimaryOwner: freezed == isPrimaryOwner ? _self.isPrimaryOwner : isPrimaryOwner // ignore: cast_nullable_to_non_nullable
as bool?,isRestricted: freezed == isRestricted ? _self.isRestricted : isRestricted // ignore: cast_nullable_to_non_nullable
as bool?,isStranger: freezed == isStranger ? _self.isStranger : isStranger // ignore: cast_nullable_to_non_nullable
as bool?,isUltraRestricted: freezed == isUltraRestricted ? _self.isUltraRestricted : isUltraRestricted // ignore: cast_nullable_to_non_nullable
as bool?,locale: freezed == locale ? _self.locale : locale // ignore: cast_nullable_to_non_nullable
as String?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,profile: freezed == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as SlackMessageMemberProfileEntity?,twoFactorType: freezed == twoFactorType ? _self.twoFactorType : twoFactorType // ignore: cast_nullable_to_non_nullable
as String?,tz: freezed == tz ? _self.tz : tz // ignore: cast_nullable_to_non_nullable
as String?,tzLabel: freezed == tzLabel ? _self.tzLabel : tzLabel // ignore: cast_nullable_to_non_nullable
as String?,tzOffset: freezed == tzOffset ? _self.tzOffset : tzOffset // ignore: cast_nullable_to_non_nullable
as int?,updated: freezed == updated ? _self.updated : updated // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

/// Create a copy of SlackMessageMemberEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SlackMessageMemberProfileEntityCopyWith<$Res>? get profile {
    if (_self.profile == null) {
    return null;
  }

  return $SlackMessageMemberProfileEntityCopyWith<$Res>(_self.profile!, (value) {
    return _then(_self.copyWith(profile: value));
  });
}
}

// dart format on
