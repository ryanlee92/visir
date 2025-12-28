// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notification_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$NotificationEntity {

 String get id; String get deviceId; String get userId;@JsonKey(includeIfNull: false) String? get platform;@JsonKey(includeIfNull: false) String? get fcmToken;@JsonKey(includeIfNull: false) String? get apnsToken;@JsonKey(includeIfNull: false) bool? get showTaskNotification;@JsonKey(includeIfNull: false) Map<dynamic, dynamic>? get showCalendarNotification;@JsonKey(includeIfNull: false) Map<dynamic, dynamic>? get showGmailNotification;@JsonKey(includeIfNull: false) Map<dynamic, dynamic>? get showSlackNotification;@JsonKey(includeIfNull: false) Map<dynamic, dynamic>? get showOutlookMailNotification;@JsonKey(includeIfNull: false) List<String>? get linkedGmails;@JsonKey(includeIfNull: false) List<String>? get linkedGoogleCalendars;@JsonKey(includeIfNull: false) List<String>? get linkedSlackTeams;@JsonKey(includeIfNull: false) List<String>? get tokenSlackTeams;@JsonKey(includeIfNull: false) List<String>? get linkedOutlookMails;@JsonKey(includeIfNull: false) Map<dynamic, dynamic>? get gmailServerCode;@JsonKey(includeIfNull: false) Map<dynamic, dynamic>? get gcalServerCode;@JsonKey(includeIfNull: false) Map<dynamic, dynamic>? get slackServerCode;@JsonKey(includeIfNull: false) Map<dynamic, dynamic>? get gmailNotificationImage;@JsonKey(includeIfNull: false) Map<dynamic, dynamic>? get gcalNotificationImage;@JsonKey(includeIfNull: false) Map<dynamic, dynamic>? get slackNotificationImage;@JsonKey(includeIfNull: false) Map<dynamic, dynamic>? get outlookMailServerCode;@JsonKey(includeIfNull: false) Map<dynamic, dynamic>? get outlookMailNotificationImage;
/// Create a copy of NotificationEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotificationEntityCopyWith<NotificationEntity> get copyWith => _$NotificationEntityCopyWithImpl<NotificationEntity>(this as NotificationEntity, _$identity);

  /// Serializes this NotificationEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotificationEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.deviceId, deviceId) || other.deviceId == deviceId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.platform, platform) || other.platform == platform)&&(identical(other.fcmToken, fcmToken) || other.fcmToken == fcmToken)&&(identical(other.apnsToken, apnsToken) || other.apnsToken == apnsToken)&&(identical(other.showTaskNotification, showTaskNotification) || other.showTaskNotification == showTaskNotification)&&const DeepCollectionEquality().equals(other.showCalendarNotification, showCalendarNotification)&&const DeepCollectionEquality().equals(other.showGmailNotification, showGmailNotification)&&const DeepCollectionEquality().equals(other.showSlackNotification, showSlackNotification)&&const DeepCollectionEquality().equals(other.showOutlookMailNotification, showOutlookMailNotification)&&const DeepCollectionEquality().equals(other.linkedGmails, linkedGmails)&&const DeepCollectionEquality().equals(other.linkedGoogleCalendars, linkedGoogleCalendars)&&const DeepCollectionEquality().equals(other.linkedSlackTeams, linkedSlackTeams)&&const DeepCollectionEquality().equals(other.tokenSlackTeams, tokenSlackTeams)&&const DeepCollectionEquality().equals(other.linkedOutlookMails, linkedOutlookMails)&&const DeepCollectionEquality().equals(other.gmailServerCode, gmailServerCode)&&const DeepCollectionEquality().equals(other.gcalServerCode, gcalServerCode)&&const DeepCollectionEquality().equals(other.slackServerCode, slackServerCode)&&const DeepCollectionEquality().equals(other.gmailNotificationImage, gmailNotificationImage)&&const DeepCollectionEquality().equals(other.gcalNotificationImage, gcalNotificationImage)&&const DeepCollectionEquality().equals(other.slackNotificationImage, slackNotificationImage)&&const DeepCollectionEquality().equals(other.outlookMailServerCode, outlookMailServerCode)&&const DeepCollectionEquality().equals(other.outlookMailNotificationImage, outlookMailNotificationImage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,deviceId,userId,platform,fcmToken,apnsToken,showTaskNotification,const DeepCollectionEquality().hash(showCalendarNotification),const DeepCollectionEquality().hash(showGmailNotification),const DeepCollectionEquality().hash(showSlackNotification),const DeepCollectionEquality().hash(showOutlookMailNotification),const DeepCollectionEquality().hash(linkedGmails),const DeepCollectionEquality().hash(linkedGoogleCalendars),const DeepCollectionEquality().hash(linkedSlackTeams),const DeepCollectionEquality().hash(tokenSlackTeams),const DeepCollectionEquality().hash(linkedOutlookMails),const DeepCollectionEquality().hash(gmailServerCode),const DeepCollectionEquality().hash(gcalServerCode),const DeepCollectionEquality().hash(slackServerCode),const DeepCollectionEquality().hash(gmailNotificationImage),const DeepCollectionEquality().hash(gcalNotificationImage),const DeepCollectionEquality().hash(slackNotificationImage),const DeepCollectionEquality().hash(outlookMailServerCode),const DeepCollectionEquality().hash(outlookMailNotificationImage)]);

@override
String toString() {
  return 'NotificationEntity(id: $id, deviceId: $deviceId, userId: $userId, platform: $platform, fcmToken: $fcmToken, apnsToken: $apnsToken, showTaskNotification: $showTaskNotification, showCalendarNotification: $showCalendarNotification, showGmailNotification: $showGmailNotification, showSlackNotification: $showSlackNotification, showOutlookMailNotification: $showOutlookMailNotification, linkedGmails: $linkedGmails, linkedGoogleCalendars: $linkedGoogleCalendars, linkedSlackTeams: $linkedSlackTeams, tokenSlackTeams: $tokenSlackTeams, linkedOutlookMails: $linkedOutlookMails, gmailServerCode: $gmailServerCode, gcalServerCode: $gcalServerCode, slackServerCode: $slackServerCode, gmailNotificationImage: $gmailNotificationImage, gcalNotificationImage: $gcalNotificationImage, slackNotificationImage: $slackNotificationImage, outlookMailServerCode: $outlookMailServerCode, outlookMailNotificationImage: $outlookMailNotificationImage)';
}


}

/// @nodoc
abstract mixin class $NotificationEntityCopyWith<$Res>  {
  factory $NotificationEntityCopyWith(NotificationEntity value, $Res Function(NotificationEntity) _then) = _$NotificationEntityCopyWithImpl;
@useResult
$Res call({
 String id, String deviceId, String userId,@JsonKey(includeIfNull: false) String? platform,@JsonKey(includeIfNull: false) String? fcmToken,@JsonKey(includeIfNull: false) String? apnsToken,@JsonKey(includeIfNull: false) bool? showTaskNotification,@JsonKey(includeIfNull: false) Map<dynamic, dynamic>? showCalendarNotification,@JsonKey(includeIfNull: false) Map<dynamic, dynamic>? showGmailNotification,@JsonKey(includeIfNull: false) Map<dynamic, dynamic>? showSlackNotification,@JsonKey(includeIfNull: false) Map<dynamic, dynamic>? showOutlookMailNotification,@JsonKey(includeIfNull: false) List<String>? linkedGmails,@JsonKey(includeIfNull: false) List<String>? linkedGoogleCalendars,@JsonKey(includeIfNull: false) List<String>? linkedSlackTeams,@JsonKey(includeIfNull: false) List<String>? tokenSlackTeams,@JsonKey(includeIfNull: false) List<String>? linkedOutlookMails,@JsonKey(includeIfNull: false) Map<dynamic, dynamic>? gmailServerCode,@JsonKey(includeIfNull: false) Map<dynamic, dynamic>? gcalServerCode,@JsonKey(includeIfNull: false) Map<dynamic, dynamic>? slackServerCode,@JsonKey(includeIfNull: false) Map<dynamic, dynamic>? gmailNotificationImage,@JsonKey(includeIfNull: false) Map<dynamic, dynamic>? gcalNotificationImage,@JsonKey(includeIfNull: false) Map<dynamic, dynamic>? slackNotificationImage,@JsonKey(includeIfNull: false) Map<dynamic, dynamic>? outlookMailServerCode,@JsonKey(includeIfNull: false) Map<dynamic, dynamic>? outlookMailNotificationImage
});




}
/// @nodoc
class _$NotificationEntityCopyWithImpl<$Res>
    implements $NotificationEntityCopyWith<$Res> {
  _$NotificationEntityCopyWithImpl(this._self, this._then);

  final NotificationEntity _self;
  final $Res Function(NotificationEntity) _then;

/// Create a copy of NotificationEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? deviceId = null,Object? userId = null,Object? platform = freezed,Object? fcmToken = freezed,Object? apnsToken = freezed,Object? showTaskNotification = freezed,Object? showCalendarNotification = freezed,Object? showGmailNotification = freezed,Object? showSlackNotification = freezed,Object? showOutlookMailNotification = freezed,Object? linkedGmails = freezed,Object? linkedGoogleCalendars = freezed,Object? linkedSlackTeams = freezed,Object? tokenSlackTeams = freezed,Object? linkedOutlookMails = freezed,Object? gmailServerCode = freezed,Object? gcalServerCode = freezed,Object? slackServerCode = freezed,Object? gmailNotificationImage = freezed,Object? gcalNotificationImage = freezed,Object? slackNotificationImage = freezed,Object? outlookMailServerCode = freezed,Object? outlookMailNotificationImage = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,deviceId: null == deviceId ? _self.deviceId : deviceId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,platform: freezed == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as String?,fcmToken: freezed == fcmToken ? _self.fcmToken : fcmToken // ignore: cast_nullable_to_non_nullable
as String?,apnsToken: freezed == apnsToken ? _self.apnsToken : apnsToken // ignore: cast_nullable_to_non_nullable
as String?,showTaskNotification: freezed == showTaskNotification ? _self.showTaskNotification : showTaskNotification // ignore: cast_nullable_to_non_nullable
as bool?,showCalendarNotification: freezed == showCalendarNotification ? _self.showCalendarNotification : showCalendarNotification // ignore: cast_nullable_to_non_nullable
as Map<dynamic, dynamic>?,showGmailNotification: freezed == showGmailNotification ? _self.showGmailNotification : showGmailNotification // ignore: cast_nullable_to_non_nullable
as Map<dynamic, dynamic>?,showSlackNotification: freezed == showSlackNotification ? _self.showSlackNotification : showSlackNotification // ignore: cast_nullable_to_non_nullable
as Map<dynamic, dynamic>?,showOutlookMailNotification: freezed == showOutlookMailNotification ? _self.showOutlookMailNotification : showOutlookMailNotification // ignore: cast_nullable_to_non_nullable
as Map<dynamic, dynamic>?,linkedGmails: freezed == linkedGmails ? _self.linkedGmails : linkedGmails // ignore: cast_nullable_to_non_nullable
as List<String>?,linkedGoogleCalendars: freezed == linkedGoogleCalendars ? _self.linkedGoogleCalendars : linkedGoogleCalendars // ignore: cast_nullable_to_non_nullable
as List<String>?,linkedSlackTeams: freezed == linkedSlackTeams ? _self.linkedSlackTeams : linkedSlackTeams // ignore: cast_nullable_to_non_nullable
as List<String>?,tokenSlackTeams: freezed == tokenSlackTeams ? _self.tokenSlackTeams : tokenSlackTeams // ignore: cast_nullable_to_non_nullable
as List<String>?,linkedOutlookMails: freezed == linkedOutlookMails ? _self.linkedOutlookMails : linkedOutlookMails // ignore: cast_nullable_to_non_nullable
as List<String>?,gmailServerCode: freezed == gmailServerCode ? _self.gmailServerCode : gmailServerCode // ignore: cast_nullable_to_non_nullable
as Map<dynamic, dynamic>?,gcalServerCode: freezed == gcalServerCode ? _self.gcalServerCode : gcalServerCode // ignore: cast_nullable_to_non_nullable
as Map<dynamic, dynamic>?,slackServerCode: freezed == slackServerCode ? _self.slackServerCode : slackServerCode // ignore: cast_nullable_to_non_nullable
as Map<dynamic, dynamic>?,gmailNotificationImage: freezed == gmailNotificationImage ? _self.gmailNotificationImage : gmailNotificationImage // ignore: cast_nullable_to_non_nullable
as Map<dynamic, dynamic>?,gcalNotificationImage: freezed == gcalNotificationImage ? _self.gcalNotificationImage : gcalNotificationImage // ignore: cast_nullable_to_non_nullable
as Map<dynamic, dynamic>?,slackNotificationImage: freezed == slackNotificationImage ? _self.slackNotificationImage : slackNotificationImage // ignore: cast_nullable_to_non_nullable
as Map<dynamic, dynamic>?,outlookMailServerCode: freezed == outlookMailServerCode ? _self.outlookMailServerCode : outlookMailServerCode // ignore: cast_nullable_to_non_nullable
as Map<dynamic, dynamic>?,outlookMailNotificationImage: freezed == outlookMailNotificationImage ? _self.outlookMailNotificationImage : outlookMailNotificationImage // ignore: cast_nullable_to_non_nullable
as Map<dynamic, dynamic>?,
  ));
}

}


/// Adds pattern-matching-related methods to [NotificationEntity].
extension NotificationEntityPatterns on NotificationEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NotificationEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NotificationEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NotificationEntity value)  $default,){
final _that = this;
switch (_that) {
case _NotificationEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NotificationEntity value)?  $default,){
final _that = this;
switch (_that) {
case _NotificationEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String deviceId,  String userId, @JsonKey(includeIfNull: false)  String? platform, @JsonKey(includeIfNull: false)  String? fcmToken, @JsonKey(includeIfNull: false)  String? apnsToken, @JsonKey(includeIfNull: false)  bool? showTaskNotification, @JsonKey(includeIfNull: false)  Map<dynamic, dynamic>? showCalendarNotification, @JsonKey(includeIfNull: false)  Map<dynamic, dynamic>? showGmailNotification, @JsonKey(includeIfNull: false)  Map<dynamic, dynamic>? showSlackNotification, @JsonKey(includeIfNull: false)  Map<dynamic, dynamic>? showOutlookMailNotification, @JsonKey(includeIfNull: false)  List<String>? linkedGmails, @JsonKey(includeIfNull: false)  List<String>? linkedGoogleCalendars, @JsonKey(includeIfNull: false)  List<String>? linkedSlackTeams, @JsonKey(includeIfNull: false)  List<String>? tokenSlackTeams, @JsonKey(includeIfNull: false)  List<String>? linkedOutlookMails, @JsonKey(includeIfNull: false)  Map<dynamic, dynamic>? gmailServerCode, @JsonKey(includeIfNull: false)  Map<dynamic, dynamic>? gcalServerCode, @JsonKey(includeIfNull: false)  Map<dynamic, dynamic>? slackServerCode, @JsonKey(includeIfNull: false)  Map<dynamic, dynamic>? gmailNotificationImage, @JsonKey(includeIfNull: false)  Map<dynamic, dynamic>? gcalNotificationImage, @JsonKey(includeIfNull: false)  Map<dynamic, dynamic>? slackNotificationImage, @JsonKey(includeIfNull: false)  Map<dynamic, dynamic>? outlookMailServerCode, @JsonKey(includeIfNull: false)  Map<dynamic, dynamic>? outlookMailNotificationImage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NotificationEntity() when $default != null:
return $default(_that.id,_that.deviceId,_that.userId,_that.platform,_that.fcmToken,_that.apnsToken,_that.showTaskNotification,_that.showCalendarNotification,_that.showGmailNotification,_that.showSlackNotification,_that.showOutlookMailNotification,_that.linkedGmails,_that.linkedGoogleCalendars,_that.linkedSlackTeams,_that.tokenSlackTeams,_that.linkedOutlookMails,_that.gmailServerCode,_that.gcalServerCode,_that.slackServerCode,_that.gmailNotificationImage,_that.gcalNotificationImage,_that.slackNotificationImage,_that.outlookMailServerCode,_that.outlookMailNotificationImage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String deviceId,  String userId, @JsonKey(includeIfNull: false)  String? platform, @JsonKey(includeIfNull: false)  String? fcmToken, @JsonKey(includeIfNull: false)  String? apnsToken, @JsonKey(includeIfNull: false)  bool? showTaskNotification, @JsonKey(includeIfNull: false)  Map<dynamic, dynamic>? showCalendarNotification, @JsonKey(includeIfNull: false)  Map<dynamic, dynamic>? showGmailNotification, @JsonKey(includeIfNull: false)  Map<dynamic, dynamic>? showSlackNotification, @JsonKey(includeIfNull: false)  Map<dynamic, dynamic>? showOutlookMailNotification, @JsonKey(includeIfNull: false)  List<String>? linkedGmails, @JsonKey(includeIfNull: false)  List<String>? linkedGoogleCalendars, @JsonKey(includeIfNull: false)  List<String>? linkedSlackTeams, @JsonKey(includeIfNull: false)  List<String>? tokenSlackTeams, @JsonKey(includeIfNull: false)  List<String>? linkedOutlookMails, @JsonKey(includeIfNull: false)  Map<dynamic, dynamic>? gmailServerCode, @JsonKey(includeIfNull: false)  Map<dynamic, dynamic>? gcalServerCode, @JsonKey(includeIfNull: false)  Map<dynamic, dynamic>? slackServerCode, @JsonKey(includeIfNull: false)  Map<dynamic, dynamic>? gmailNotificationImage, @JsonKey(includeIfNull: false)  Map<dynamic, dynamic>? gcalNotificationImage, @JsonKey(includeIfNull: false)  Map<dynamic, dynamic>? slackNotificationImage, @JsonKey(includeIfNull: false)  Map<dynamic, dynamic>? outlookMailServerCode, @JsonKey(includeIfNull: false)  Map<dynamic, dynamic>? outlookMailNotificationImage)  $default,) {final _that = this;
switch (_that) {
case _NotificationEntity():
return $default(_that.id,_that.deviceId,_that.userId,_that.platform,_that.fcmToken,_that.apnsToken,_that.showTaskNotification,_that.showCalendarNotification,_that.showGmailNotification,_that.showSlackNotification,_that.showOutlookMailNotification,_that.linkedGmails,_that.linkedGoogleCalendars,_that.linkedSlackTeams,_that.tokenSlackTeams,_that.linkedOutlookMails,_that.gmailServerCode,_that.gcalServerCode,_that.slackServerCode,_that.gmailNotificationImage,_that.gcalNotificationImage,_that.slackNotificationImage,_that.outlookMailServerCode,_that.outlookMailNotificationImage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String deviceId,  String userId, @JsonKey(includeIfNull: false)  String? platform, @JsonKey(includeIfNull: false)  String? fcmToken, @JsonKey(includeIfNull: false)  String? apnsToken, @JsonKey(includeIfNull: false)  bool? showTaskNotification, @JsonKey(includeIfNull: false)  Map<dynamic, dynamic>? showCalendarNotification, @JsonKey(includeIfNull: false)  Map<dynamic, dynamic>? showGmailNotification, @JsonKey(includeIfNull: false)  Map<dynamic, dynamic>? showSlackNotification, @JsonKey(includeIfNull: false)  Map<dynamic, dynamic>? showOutlookMailNotification, @JsonKey(includeIfNull: false)  List<String>? linkedGmails, @JsonKey(includeIfNull: false)  List<String>? linkedGoogleCalendars, @JsonKey(includeIfNull: false)  List<String>? linkedSlackTeams, @JsonKey(includeIfNull: false)  List<String>? tokenSlackTeams, @JsonKey(includeIfNull: false)  List<String>? linkedOutlookMails, @JsonKey(includeIfNull: false)  Map<dynamic, dynamic>? gmailServerCode, @JsonKey(includeIfNull: false)  Map<dynamic, dynamic>? gcalServerCode, @JsonKey(includeIfNull: false)  Map<dynamic, dynamic>? slackServerCode, @JsonKey(includeIfNull: false)  Map<dynamic, dynamic>? gmailNotificationImage, @JsonKey(includeIfNull: false)  Map<dynamic, dynamic>? gcalNotificationImage, @JsonKey(includeIfNull: false)  Map<dynamic, dynamic>? slackNotificationImage, @JsonKey(includeIfNull: false)  Map<dynamic, dynamic>? outlookMailServerCode, @JsonKey(includeIfNull: false)  Map<dynamic, dynamic>? outlookMailNotificationImage)?  $default,) {final _that = this;
switch (_that) {
case _NotificationEntity() when $default != null:
return $default(_that.id,_that.deviceId,_that.userId,_that.platform,_that.fcmToken,_that.apnsToken,_that.showTaskNotification,_that.showCalendarNotification,_that.showGmailNotification,_that.showSlackNotification,_that.showOutlookMailNotification,_that.linkedGmails,_that.linkedGoogleCalendars,_that.linkedSlackTeams,_that.tokenSlackTeams,_that.linkedOutlookMails,_that.gmailServerCode,_that.gcalServerCode,_that.slackServerCode,_that.gmailNotificationImage,_that.gcalNotificationImage,_that.slackNotificationImage,_that.outlookMailServerCode,_that.outlookMailNotificationImage);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _NotificationEntity implements NotificationEntity {
  const _NotificationEntity({required this.id, required this.deviceId, required this.userId, @JsonKey(includeIfNull: false) this.platform, @JsonKey(includeIfNull: false) this.fcmToken, @JsonKey(includeIfNull: false) this.apnsToken, @JsonKey(includeIfNull: false) this.showTaskNotification, @JsonKey(includeIfNull: false) final  Map<dynamic, dynamic>? showCalendarNotification, @JsonKey(includeIfNull: false) final  Map<dynamic, dynamic>? showGmailNotification, @JsonKey(includeIfNull: false) final  Map<dynamic, dynamic>? showSlackNotification, @JsonKey(includeIfNull: false) final  Map<dynamic, dynamic>? showOutlookMailNotification, @JsonKey(includeIfNull: false) final  List<String>? linkedGmails, @JsonKey(includeIfNull: false) final  List<String>? linkedGoogleCalendars, @JsonKey(includeIfNull: false) final  List<String>? linkedSlackTeams, @JsonKey(includeIfNull: false) final  List<String>? tokenSlackTeams, @JsonKey(includeIfNull: false) final  List<String>? linkedOutlookMails, @JsonKey(includeIfNull: false) final  Map<dynamic, dynamic>? gmailServerCode, @JsonKey(includeIfNull: false) final  Map<dynamic, dynamic>? gcalServerCode, @JsonKey(includeIfNull: false) final  Map<dynamic, dynamic>? slackServerCode, @JsonKey(includeIfNull: false) final  Map<dynamic, dynamic>? gmailNotificationImage, @JsonKey(includeIfNull: false) final  Map<dynamic, dynamic>? gcalNotificationImage, @JsonKey(includeIfNull: false) final  Map<dynamic, dynamic>? slackNotificationImage, @JsonKey(includeIfNull: false) final  Map<dynamic, dynamic>? outlookMailServerCode, @JsonKey(includeIfNull: false) final  Map<dynamic, dynamic>? outlookMailNotificationImage}): _showCalendarNotification = showCalendarNotification,_showGmailNotification = showGmailNotification,_showSlackNotification = showSlackNotification,_showOutlookMailNotification = showOutlookMailNotification,_linkedGmails = linkedGmails,_linkedGoogleCalendars = linkedGoogleCalendars,_linkedSlackTeams = linkedSlackTeams,_tokenSlackTeams = tokenSlackTeams,_linkedOutlookMails = linkedOutlookMails,_gmailServerCode = gmailServerCode,_gcalServerCode = gcalServerCode,_slackServerCode = slackServerCode,_gmailNotificationImage = gmailNotificationImage,_gcalNotificationImage = gcalNotificationImage,_slackNotificationImage = slackNotificationImage,_outlookMailServerCode = outlookMailServerCode,_outlookMailNotificationImage = outlookMailNotificationImage;
  factory _NotificationEntity.fromJson(Map<String, dynamic> json) => _$NotificationEntityFromJson(json);

@override final  String id;
@override final  String deviceId;
@override final  String userId;
@override@JsonKey(includeIfNull: false) final  String? platform;
@override@JsonKey(includeIfNull: false) final  String? fcmToken;
@override@JsonKey(includeIfNull: false) final  String? apnsToken;
@override@JsonKey(includeIfNull: false) final  bool? showTaskNotification;
 final  Map<dynamic, dynamic>? _showCalendarNotification;
@override@JsonKey(includeIfNull: false) Map<dynamic, dynamic>? get showCalendarNotification {
  final value = _showCalendarNotification;
  if (value == null) return null;
  if (_showCalendarNotification is EqualUnmodifiableMapView) return _showCalendarNotification;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  Map<dynamic, dynamic>? _showGmailNotification;
@override@JsonKey(includeIfNull: false) Map<dynamic, dynamic>? get showGmailNotification {
  final value = _showGmailNotification;
  if (value == null) return null;
  if (_showGmailNotification is EqualUnmodifiableMapView) return _showGmailNotification;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  Map<dynamic, dynamic>? _showSlackNotification;
@override@JsonKey(includeIfNull: false) Map<dynamic, dynamic>? get showSlackNotification {
  final value = _showSlackNotification;
  if (value == null) return null;
  if (_showSlackNotification is EqualUnmodifiableMapView) return _showSlackNotification;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  Map<dynamic, dynamic>? _showOutlookMailNotification;
@override@JsonKey(includeIfNull: false) Map<dynamic, dynamic>? get showOutlookMailNotification {
  final value = _showOutlookMailNotification;
  if (value == null) return null;
  if (_showOutlookMailNotification is EqualUnmodifiableMapView) return _showOutlookMailNotification;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  List<String>? _linkedGmails;
@override@JsonKey(includeIfNull: false) List<String>? get linkedGmails {
  final value = _linkedGmails;
  if (value == null) return null;
  if (_linkedGmails is EqualUnmodifiableListView) return _linkedGmails;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<String>? _linkedGoogleCalendars;
@override@JsonKey(includeIfNull: false) List<String>? get linkedGoogleCalendars {
  final value = _linkedGoogleCalendars;
  if (value == null) return null;
  if (_linkedGoogleCalendars is EqualUnmodifiableListView) return _linkedGoogleCalendars;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<String>? _linkedSlackTeams;
@override@JsonKey(includeIfNull: false) List<String>? get linkedSlackTeams {
  final value = _linkedSlackTeams;
  if (value == null) return null;
  if (_linkedSlackTeams is EqualUnmodifiableListView) return _linkedSlackTeams;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<String>? _tokenSlackTeams;
@override@JsonKey(includeIfNull: false) List<String>? get tokenSlackTeams {
  final value = _tokenSlackTeams;
  if (value == null) return null;
  if (_tokenSlackTeams is EqualUnmodifiableListView) return _tokenSlackTeams;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<String>? _linkedOutlookMails;
@override@JsonKey(includeIfNull: false) List<String>? get linkedOutlookMails {
  final value = _linkedOutlookMails;
  if (value == null) return null;
  if (_linkedOutlookMails is EqualUnmodifiableListView) return _linkedOutlookMails;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  Map<dynamic, dynamic>? _gmailServerCode;
@override@JsonKey(includeIfNull: false) Map<dynamic, dynamic>? get gmailServerCode {
  final value = _gmailServerCode;
  if (value == null) return null;
  if (_gmailServerCode is EqualUnmodifiableMapView) return _gmailServerCode;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  Map<dynamic, dynamic>? _gcalServerCode;
@override@JsonKey(includeIfNull: false) Map<dynamic, dynamic>? get gcalServerCode {
  final value = _gcalServerCode;
  if (value == null) return null;
  if (_gcalServerCode is EqualUnmodifiableMapView) return _gcalServerCode;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  Map<dynamic, dynamic>? _slackServerCode;
@override@JsonKey(includeIfNull: false) Map<dynamic, dynamic>? get slackServerCode {
  final value = _slackServerCode;
  if (value == null) return null;
  if (_slackServerCode is EqualUnmodifiableMapView) return _slackServerCode;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  Map<dynamic, dynamic>? _gmailNotificationImage;
@override@JsonKey(includeIfNull: false) Map<dynamic, dynamic>? get gmailNotificationImage {
  final value = _gmailNotificationImage;
  if (value == null) return null;
  if (_gmailNotificationImage is EqualUnmodifiableMapView) return _gmailNotificationImage;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  Map<dynamic, dynamic>? _gcalNotificationImage;
@override@JsonKey(includeIfNull: false) Map<dynamic, dynamic>? get gcalNotificationImage {
  final value = _gcalNotificationImage;
  if (value == null) return null;
  if (_gcalNotificationImage is EqualUnmodifiableMapView) return _gcalNotificationImage;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  Map<dynamic, dynamic>? _slackNotificationImage;
@override@JsonKey(includeIfNull: false) Map<dynamic, dynamic>? get slackNotificationImage {
  final value = _slackNotificationImage;
  if (value == null) return null;
  if (_slackNotificationImage is EqualUnmodifiableMapView) return _slackNotificationImage;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  Map<dynamic, dynamic>? _outlookMailServerCode;
@override@JsonKey(includeIfNull: false) Map<dynamic, dynamic>? get outlookMailServerCode {
  final value = _outlookMailServerCode;
  if (value == null) return null;
  if (_outlookMailServerCode is EqualUnmodifiableMapView) return _outlookMailServerCode;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  Map<dynamic, dynamic>? _outlookMailNotificationImage;
@override@JsonKey(includeIfNull: false) Map<dynamic, dynamic>? get outlookMailNotificationImage {
  final value = _outlookMailNotificationImage;
  if (value == null) return null;
  if (_outlookMailNotificationImage is EqualUnmodifiableMapView) return _outlookMailNotificationImage;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of NotificationEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NotificationEntityCopyWith<_NotificationEntity> get copyWith => __$NotificationEntityCopyWithImpl<_NotificationEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NotificationEntityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NotificationEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.deviceId, deviceId) || other.deviceId == deviceId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.platform, platform) || other.platform == platform)&&(identical(other.fcmToken, fcmToken) || other.fcmToken == fcmToken)&&(identical(other.apnsToken, apnsToken) || other.apnsToken == apnsToken)&&(identical(other.showTaskNotification, showTaskNotification) || other.showTaskNotification == showTaskNotification)&&const DeepCollectionEquality().equals(other._showCalendarNotification, _showCalendarNotification)&&const DeepCollectionEquality().equals(other._showGmailNotification, _showGmailNotification)&&const DeepCollectionEquality().equals(other._showSlackNotification, _showSlackNotification)&&const DeepCollectionEquality().equals(other._showOutlookMailNotification, _showOutlookMailNotification)&&const DeepCollectionEquality().equals(other._linkedGmails, _linkedGmails)&&const DeepCollectionEquality().equals(other._linkedGoogleCalendars, _linkedGoogleCalendars)&&const DeepCollectionEquality().equals(other._linkedSlackTeams, _linkedSlackTeams)&&const DeepCollectionEquality().equals(other._tokenSlackTeams, _tokenSlackTeams)&&const DeepCollectionEquality().equals(other._linkedOutlookMails, _linkedOutlookMails)&&const DeepCollectionEquality().equals(other._gmailServerCode, _gmailServerCode)&&const DeepCollectionEquality().equals(other._gcalServerCode, _gcalServerCode)&&const DeepCollectionEquality().equals(other._slackServerCode, _slackServerCode)&&const DeepCollectionEquality().equals(other._gmailNotificationImage, _gmailNotificationImage)&&const DeepCollectionEquality().equals(other._gcalNotificationImage, _gcalNotificationImage)&&const DeepCollectionEquality().equals(other._slackNotificationImage, _slackNotificationImage)&&const DeepCollectionEquality().equals(other._outlookMailServerCode, _outlookMailServerCode)&&const DeepCollectionEquality().equals(other._outlookMailNotificationImage, _outlookMailNotificationImage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,deviceId,userId,platform,fcmToken,apnsToken,showTaskNotification,const DeepCollectionEquality().hash(_showCalendarNotification),const DeepCollectionEquality().hash(_showGmailNotification),const DeepCollectionEquality().hash(_showSlackNotification),const DeepCollectionEquality().hash(_showOutlookMailNotification),const DeepCollectionEquality().hash(_linkedGmails),const DeepCollectionEquality().hash(_linkedGoogleCalendars),const DeepCollectionEquality().hash(_linkedSlackTeams),const DeepCollectionEquality().hash(_tokenSlackTeams),const DeepCollectionEquality().hash(_linkedOutlookMails),const DeepCollectionEquality().hash(_gmailServerCode),const DeepCollectionEquality().hash(_gcalServerCode),const DeepCollectionEquality().hash(_slackServerCode),const DeepCollectionEquality().hash(_gmailNotificationImage),const DeepCollectionEquality().hash(_gcalNotificationImage),const DeepCollectionEquality().hash(_slackNotificationImage),const DeepCollectionEquality().hash(_outlookMailServerCode),const DeepCollectionEquality().hash(_outlookMailNotificationImage)]);

@override
String toString() {
  return 'NotificationEntity(id: $id, deviceId: $deviceId, userId: $userId, platform: $platform, fcmToken: $fcmToken, apnsToken: $apnsToken, showTaskNotification: $showTaskNotification, showCalendarNotification: $showCalendarNotification, showGmailNotification: $showGmailNotification, showSlackNotification: $showSlackNotification, showOutlookMailNotification: $showOutlookMailNotification, linkedGmails: $linkedGmails, linkedGoogleCalendars: $linkedGoogleCalendars, linkedSlackTeams: $linkedSlackTeams, tokenSlackTeams: $tokenSlackTeams, linkedOutlookMails: $linkedOutlookMails, gmailServerCode: $gmailServerCode, gcalServerCode: $gcalServerCode, slackServerCode: $slackServerCode, gmailNotificationImage: $gmailNotificationImage, gcalNotificationImage: $gcalNotificationImage, slackNotificationImage: $slackNotificationImage, outlookMailServerCode: $outlookMailServerCode, outlookMailNotificationImage: $outlookMailNotificationImage)';
}


}

/// @nodoc
abstract mixin class _$NotificationEntityCopyWith<$Res> implements $NotificationEntityCopyWith<$Res> {
  factory _$NotificationEntityCopyWith(_NotificationEntity value, $Res Function(_NotificationEntity) _then) = __$NotificationEntityCopyWithImpl;
@override @useResult
$Res call({
 String id, String deviceId, String userId,@JsonKey(includeIfNull: false) String? platform,@JsonKey(includeIfNull: false) String? fcmToken,@JsonKey(includeIfNull: false) String? apnsToken,@JsonKey(includeIfNull: false) bool? showTaskNotification,@JsonKey(includeIfNull: false) Map<dynamic, dynamic>? showCalendarNotification,@JsonKey(includeIfNull: false) Map<dynamic, dynamic>? showGmailNotification,@JsonKey(includeIfNull: false) Map<dynamic, dynamic>? showSlackNotification,@JsonKey(includeIfNull: false) Map<dynamic, dynamic>? showOutlookMailNotification,@JsonKey(includeIfNull: false) List<String>? linkedGmails,@JsonKey(includeIfNull: false) List<String>? linkedGoogleCalendars,@JsonKey(includeIfNull: false) List<String>? linkedSlackTeams,@JsonKey(includeIfNull: false) List<String>? tokenSlackTeams,@JsonKey(includeIfNull: false) List<String>? linkedOutlookMails,@JsonKey(includeIfNull: false) Map<dynamic, dynamic>? gmailServerCode,@JsonKey(includeIfNull: false) Map<dynamic, dynamic>? gcalServerCode,@JsonKey(includeIfNull: false) Map<dynamic, dynamic>? slackServerCode,@JsonKey(includeIfNull: false) Map<dynamic, dynamic>? gmailNotificationImage,@JsonKey(includeIfNull: false) Map<dynamic, dynamic>? gcalNotificationImage,@JsonKey(includeIfNull: false) Map<dynamic, dynamic>? slackNotificationImage,@JsonKey(includeIfNull: false) Map<dynamic, dynamic>? outlookMailServerCode,@JsonKey(includeIfNull: false) Map<dynamic, dynamic>? outlookMailNotificationImage
});




}
/// @nodoc
class __$NotificationEntityCopyWithImpl<$Res>
    implements _$NotificationEntityCopyWith<$Res> {
  __$NotificationEntityCopyWithImpl(this._self, this._then);

  final _NotificationEntity _self;
  final $Res Function(_NotificationEntity) _then;

/// Create a copy of NotificationEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? deviceId = null,Object? userId = null,Object? platform = freezed,Object? fcmToken = freezed,Object? apnsToken = freezed,Object? showTaskNotification = freezed,Object? showCalendarNotification = freezed,Object? showGmailNotification = freezed,Object? showSlackNotification = freezed,Object? showOutlookMailNotification = freezed,Object? linkedGmails = freezed,Object? linkedGoogleCalendars = freezed,Object? linkedSlackTeams = freezed,Object? tokenSlackTeams = freezed,Object? linkedOutlookMails = freezed,Object? gmailServerCode = freezed,Object? gcalServerCode = freezed,Object? slackServerCode = freezed,Object? gmailNotificationImage = freezed,Object? gcalNotificationImage = freezed,Object? slackNotificationImage = freezed,Object? outlookMailServerCode = freezed,Object? outlookMailNotificationImage = freezed,}) {
  return _then(_NotificationEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,deviceId: null == deviceId ? _self.deviceId : deviceId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,platform: freezed == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as String?,fcmToken: freezed == fcmToken ? _self.fcmToken : fcmToken // ignore: cast_nullable_to_non_nullable
as String?,apnsToken: freezed == apnsToken ? _self.apnsToken : apnsToken // ignore: cast_nullable_to_non_nullable
as String?,showTaskNotification: freezed == showTaskNotification ? _self.showTaskNotification : showTaskNotification // ignore: cast_nullable_to_non_nullable
as bool?,showCalendarNotification: freezed == showCalendarNotification ? _self._showCalendarNotification : showCalendarNotification // ignore: cast_nullable_to_non_nullable
as Map<dynamic, dynamic>?,showGmailNotification: freezed == showGmailNotification ? _self._showGmailNotification : showGmailNotification // ignore: cast_nullable_to_non_nullable
as Map<dynamic, dynamic>?,showSlackNotification: freezed == showSlackNotification ? _self._showSlackNotification : showSlackNotification // ignore: cast_nullable_to_non_nullable
as Map<dynamic, dynamic>?,showOutlookMailNotification: freezed == showOutlookMailNotification ? _self._showOutlookMailNotification : showOutlookMailNotification // ignore: cast_nullable_to_non_nullable
as Map<dynamic, dynamic>?,linkedGmails: freezed == linkedGmails ? _self._linkedGmails : linkedGmails // ignore: cast_nullable_to_non_nullable
as List<String>?,linkedGoogleCalendars: freezed == linkedGoogleCalendars ? _self._linkedGoogleCalendars : linkedGoogleCalendars // ignore: cast_nullable_to_non_nullable
as List<String>?,linkedSlackTeams: freezed == linkedSlackTeams ? _self._linkedSlackTeams : linkedSlackTeams // ignore: cast_nullable_to_non_nullable
as List<String>?,tokenSlackTeams: freezed == tokenSlackTeams ? _self._tokenSlackTeams : tokenSlackTeams // ignore: cast_nullable_to_non_nullable
as List<String>?,linkedOutlookMails: freezed == linkedOutlookMails ? _self._linkedOutlookMails : linkedOutlookMails // ignore: cast_nullable_to_non_nullable
as List<String>?,gmailServerCode: freezed == gmailServerCode ? _self._gmailServerCode : gmailServerCode // ignore: cast_nullable_to_non_nullable
as Map<dynamic, dynamic>?,gcalServerCode: freezed == gcalServerCode ? _self._gcalServerCode : gcalServerCode // ignore: cast_nullable_to_non_nullable
as Map<dynamic, dynamic>?,slackServerCode: freezed == slackServerCode ? _self._slackServerCode : slackServerCode // ignore: cast_nullable_to_non_nullable
as Map<dynamic, dynamic>?,gmailNotificationImage: freezed == gmailNotificationImage ? _self._gmailNotificationImage : gmailNotificationImage // ignore: cast_nullable_to_non_nullable
as Map<dynamic, dynamic>?,gcalNotificationImage: freezed == gcalNotificationImage ? _self._gcalNotificationImage : gcalNotificationImage // ignore: cast_nullable_to_non_nullable
as Map<dynamic, dynamic>?,slackNotificationImage: freezed == slackNotificationImage ? _self._slackNotificationImage : slackNotificationImage // ignore: cast_nullable_to_non_nullable
as Map<dynamic, dynamic>?,outlookMailServerCode: freezed == outlookMailServerCode ? _self._outlookMailServerCode : outlookMailServerCode // ignore: cast_nullable_to_non_nullable
as Map<dynamic, dynamic>?,outlookMailNotificationImage: freezed == outlookMailNotificationImage ? _self._outlookMailNotificationImage : outlookMailNotificationImage // ignore: cast_nullable_to_non_nullable
as Map<dynamic, dynamic>?,
  ));
}


}

// dart format on
