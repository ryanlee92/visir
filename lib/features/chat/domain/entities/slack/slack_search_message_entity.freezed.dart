// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'slack_search_message_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SlackSearchMessageEntity {

@JsonKey(includeIfNull: false) SlackSearchChannelEntity? get channel;@JsonKey(includeIfNull: false) String? get iid;@JsonKey(includeIfNull: false) String? get permalink;@JsonKey(includeIfNull: false) String? get team;@JsonKey(includeIfNull: false) String? get text;@JsonKey(includeIfNull: false) String? get ts;@JsonKey(includeIfNull: false) String? get type;@JsonKey(includeIfNull: false) String? get user;@JsonKey(includeIfNull: false) String? get username;
/// Create a copy of SlackSearchMessageEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SlackSearchMessageEntityCopyWith<SlackSearchMessageEntity> get copyWith => _$SlackSearchMessageEntityCopyWithImpl<SlackSearchMessageEntity>(this as SlackSearchMessageEntity, _$identity);

  /// Serializes this SlackSearchMessageEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SlackSearchMessageEntity&&(identical(other.channel, channel) || other.channel == channel)&&(identical(other.iid, iid) || other.iid == iid)&&(identical(other.permalink, permalink) || other.permalink == permalink)&&(identical(other.team, team) || other.team == team)&&(identical(other.text, text) || other.text == text)&&(identical(other.ts, ts) || other.ts == ts)&&(identical(other.type, type) || other.type == type)&&(identical(other.user, user) || other.user == user)&&(identical(other.username, username) || other.username == username));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,channel,iid,permalink,team,text,ts,type,user,username);

@override
String toString() {
  return 'SlackSearchMessageEntity(channel: $channel, iid: $iid, permalink: $permalink, team: $team, text: $text, ts: $ts, type: $type, user: $user, username: $username)';
}


}

/// @nodoc
abstract mixin class $SlackSearchMessageEntityCopyWith<$Res>  {
  factory $SlackSearchMessageEntityCopyWith(SlackSearchMessageEntity value, $Res Function(SlackSearchMessageEntity) _then) = _$SlackSearchMessageEntityCopyWithImpl;
@useResult
$Res call({
@JsonKey(includeIfNull: false) SlackSearchChannelEntity? channel,@JsonKey(includeIfNull: false) String? iid,@JsonKey(includeIfNull: false) String? permalink,@JsonKey(includeIfNull: false) String? team,@JsonKey(includeIfNull: false) String? text,@JsonKey(includeIfNull: false) String? ts,@JsonKey(includeIfNull: false) String? type,@JsonKey(includeIfNull: false) String? user,@JsonKey(includeIfNull: false) String? username
});


$SlackSearchChannelEntityCopyWith<$Res>? get channel;

}
/// @nodoc
class _$SlackSearchMessageEntityCopyWithImpl<$Res>
    implements $SlackSearchMessageEntityCopyWith<$Res> {
  _$SlackSearchMessageEntityCopyWithImpl(this._self, this._then);

  final SlackSearchMessageEntity _self;
  final $Res Function(SlackSearchMessageEntity) _then;

/// Create a copy of SlackSearchMessageEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? channel = freezed,Object? iid = freezed,Object? permalink = freezed,Object? team = freezed,Object? text = freezed,Object? ts = freezed,Object? type = freezed,Object? user = freezed,Object? username = freezed,}) {
  return _then(_self.copyWith(
channel: freezed == channel ? _self.channel : channel // ignore: cast_nullable_to_non_nullable
as SlackSearchChannelEntity?,iid: freezed == iid ? _self.iid : iid // ignore: cast_nullable_to_non_nullable
as String?,permalink: freezed == permalink ? _self.permalink : permalink // ignore: cast_nullable_to_non_nullable
as String?,team: freezed == team ? _self.team : team // ignore: cast_nullable_to_non_nullable
as String?,text: freezed == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String?,ts: freezed == ts ? _self.ts : ts // ignore: cast_nullable_to_non_nullable
as String?,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String?,user: freezed == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as String?,username: freezed == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of SlackSearchMessageEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SlackSearchChannelEntityCopyWith<$Res>? get channel {
    if (_self.channel == null) {
    return null;
  }

  return $SlackSearchChannelEntityCopyWith<$Res>(_self.channel!, (value) {
    return _then(_self.copyWith(channel: value));
  });
}
}


/// Adds pattern-matching-related methods to [SlackSearchMessageEntity].
extension SlackSearchMessageEntityPatterns on SlackSearchMessageEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SlackSearchMessageEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SlackSearchMessageEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SlackSearchMessageEntity value)  $default,){
final _that = this;
switch (_that) {
case _SlackSearchMessageEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SlackSearchMessageEntity value)?  $default,){
final _that = this;
switch (_that) {
case _SlackSearchMessageEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(includeIfNull: false)  SlackSearchChannelEntity? channel, @JsonKey(includeIfNull: false)  String? iid, @JsonKey(includeIfNull: false)  String? permalink, @JsonKey(includeIfNull: false)  String? team, @JsonKey(includeIfNull: false)  String? text, @JsonKey(includeIfNull: false)  String? ts, @JsonKey(includeIfNull: false)  String? type, @JsonKey(includeIfNull: false)  String? user, @JsonKey(includeIfNull: false)  String? username)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SlackSearchMessageEntity() when $default != null:
return $default(_that.channel,_that.iid,_that.permalink,_that.team,_that.text,_that.ts,_that.type,_that.user,_that.username);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(includeIfNull: false)  SlackSearchChannelEntity? channel, @JsonKey(includeIfNull: false)  String? iid, @JsonKey(includeIfNull: false)  String? permalink, @JsonKey(includeIfNull: false)  String? team, @JsonKey(includeIfNull: false)  String? text, @JsonKey(includeIfNull: false)  String? ts, @JsonKey(includeIfNull: false)  String? type, @JsonKey(includeIfNull: false)  String? user, @JsonKey(includeIfNull: false)  String? username)  $default,) {final _that = this;
switch (_that) {
case _SlackSearchMessageEntity():
return $default(_that.channel,_that.iid,_that.permalink,_that.team,_that.text,_that.ts,_that.type,_that.user,_that.username);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(includeIfNull: false)  SlackSearchChannelEntity? channel, @JsonKey(includeIfNull: false)  String? iid, @JsonKey(includeIfNull: false)  String? permalink, @JsonKey(includeIfNull: false)  String? team, @JsonKey(includeIfNull: false)  String? text, @JsonKey(includeIfNull: false)  String? ts, @JsonKey(includeIfNull: false)  String? type, @JsonKey(includeIfNull: false)  String? user, @JsonKey(includeIfNull: false)  String? username)?  $default,) {final _that = this;
switch (_that) {
case _SlackSearchMessageEntity() when $default != null:
return $default(_that.channel,_that.iid,_that.permalink,_that.team,_that.text,_that.ts,_that.type,_that.user,_that.username);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _SlackSearchMessageEntity implements SlackSearchMessageEntity {
  const _SlackSearchMessageEntity({@JsonKey(includeIfNull: false) this.channel, @JsonKey(includeIfNull: false) this.iid, @JsonKey(includeIfNull: false) this.permalink, @JsonKey(includeIfNull: false) this.team, @JsonKey(includeIfNull: false) this.text, @JsonKey(includeIfNull: false) this.ts, @JsonKey(includeIfNull: false) this.type, @JsonKey(includeIfNull: false) this.user, @JsonKey(includeIfNull: false) this.username});
  factory _SlackSearchMessageEntity.fromJson(Map<String, dynamic> json) => _$SlackSearchMessageEntityFromJson(json);

@override@JsonKey(includeIfNull: false) final  SlackSearchChannelEntity? channel;
@override@JsonKey(includeIfNull: false) final  String? iid;
@override@JsonKey(includeIfNull: false) final  String? permalink;
@override@JsonKey(includeIfNull: false) final  String? team;
@override@JsonKey(includeIfNull: false) final  String? text;
@override@JsonKey(includeIfNull: false) final  String? ts;
@override@JsonKey(includeIfNull: false) final  String? type;
@override@JsonKey(includeIfNull: false) final  String? user;
@override@JsonKey(includeIfNull: false) final  String? username;

/// Create a copy of SlackSearchMessageEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SlackSearchMessageEntityCopyWith<_SlackSearchMessageEntity> get copyWith => __$SlackSearchMessageEntityCopyWithImpl<_SlackSearchMessageEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SlackSearchMessageEntityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SlackSearchMessageEntity&&(identical(other.channel, channel) || other.channel == channel)&&(identical(other.iid, iid) || other.iid == iid)&&(identical(other.permalink, permalink) || other.permalink == permalink)&&(identical(other.team, team) || other.team == team)&&(identical(other.text, text) || other.text == text)&&(identical(other.ts, ts) || other.ts == ts)&&(identical(other.type, type) || other.type == type)&&(identical(other.user, user) || other.user == user)&&(identical(other.username, username) || other.username == username));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,channel,iid,permalink,team,text,ts,type,user,username);

@override
String toString() {
  return 'SlackSearchMessageEntity(channel: $channel, iid: $iid, permalink: $permalink, team: $team, text: $text, ts: $ts, type: $type, user: $user, username: $username)';
}


}

/// @nodoc
abstract mixin class _$SlackSearchMessageEntityCopyWith<$Res> implements $SlackSearchMessageEntityCopyWith<$Res> {
  factory _$SlackSearchMessageEntityCopyWith(_SlackSearchMessageEntity value, $Res Function(_SlackSearchMessageEntity) _then) = __$SlackSearchMessageEntityCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(includeIfNull: false) SlackSearchChannelEntity? channel,@JsonKey(includeIfNull: false) String? iid,@JsonKey(includeIfNull: false) String? permalink,@JsonKey(includeIfNull: false) String? team,@JsonKey(includeIfNull: false) String? text,@JsonKey(includeIfNull: false) String? ts,@JsonKey(includeIfNull: false) String? type,@JsonKey(includeIfNull: false) String? user,@JsonKey(includeIfNull: false) String? username
});


@override $SlackSearchChannelEntityCopyWith<$Res>? get channel;

}
/// @nodoc
class __$SlackSearchMessageEntityCopyWithImpl<$Res>
    implements _$SlackSearchMessageEntityCopyWith<$Res> {
  __$SlackSearchMessageEntityCopyWithImpl(this._self, this._then);

  final _SlackSearchMessageEntity _self;
  final $Res Function(_SlackSearchMessageEntity) _then;

/// Create a copy of SlackSearchMessageEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? channel = freezed,Object? iid = freezed,Object? permalink = freezed,Object? team = freezed,Object? text = freezed,Object? ts = freezed,Object? type = freezed,Object? user = freezed,Object? username = freezed,}) {
  return _then(_SlackSearchMessageEntity(
channel: freezed == channel ? _self.channel : channel // ignore: cast_nullable_to_non_nullable
as SlackSearchChannelEntity?,iid: freezed == iid ? _self.iid : iid // ignore: cast_nullable_to_non_nullable
as String?,permalink: freezed == permalink ? _self.permalink : permalink // ignore: cast_nullable_to_non_nullable
as String?,team: freezed == team ? _self.team : team // ignore: cast_nullable_to_non_nullable
as String?,text: freezed == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String?,ts: freezed == ts ? _self.ts : ts // ignore: cast_nullable_to_non_nullable
as String?,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String?,user: freezed == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as String?,username: freezed == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of SlackSearchMessageEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SlackSearchChannelEntityCopyWith<$Res>? get channel {
    if (_self.channel == null) {
    return null;
  }

  return $SlackSearchChannelEntityCopyWith<$Res>(_self.channel!, (value) {
    return _then(_self.copyWith(channel: value));
  });
}
}

// dart format on
