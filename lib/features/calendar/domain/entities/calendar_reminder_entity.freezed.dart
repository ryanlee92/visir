// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'calendar_reminder_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CalendarReminderEntity {

 String get id; String get title; int get minutes; String get userId; String? get email; String get eventId; String get deviceId; String get calendarId; String get calendarName; String get provider; DateTime get targetDateTime; DateTime get startDate; DateTime get endDate; String get locale; bool get isAllDay; bool get isEncrypted; String get iv;
/// Create a copy of CalendarReminderEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CalendarReminderEntityCopyWith<CalendarReminderEntity> get copyWith => _$CalendarReminderEntityCopyWithImpl<CalendarReminderEntity>(this as CalendarReminderEntity, _$identity);

  /// Serializes this CalendarReminderEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CalendarReminderEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.minutes, minutes) || other.minutes == minutes)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.email, email) || other.email == email)&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.deviceId, deviceId) || other.deviceId == deviceId)&&(identical(other.calendarId, calendarId) || other.calendarId == calendarId)&&(identical(other.calendarName, calendarName) || other.calendarName == calendarName)&&(identical(other.provider, provider) || other.provider == provider)&&(identical(other.targetDateTime, targetDateTime) || other.targetDateTime == targetDateTime)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.locale, locale) || other.locale == locale)&&(identical(other.isAllDay, isAllDay) || other.isAllDay == isAllDay)&&(identical(other.isEncrypted, isEncrypted) || other.isEncrypted == isEncrypted)&&(identical(other.iv, iv) || other.iv == iv));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,minutes,userId,email,eventId,deviceId,calendarId,calendarName,provider,targetDateTime,startDate,endDate,locale,isAllDay,isEncrypted,iv);

@override
String toString() {
  return 'CalendarReminderEntity(id: $id, title: $title, minutes: $minutes, userId: $userId, email: $email, eventId: $eventId, deviceId: $deviceId, calendarId: $calendarId, calendarName: $calendarName, provider: $provider, targetDateTime: $targetDateTime, startDate: $startDate, endDate: $endDate, locale: $locale, isAllDay: $isAllDay, isEncrypted: $isEncrypted, iv: $iv)';
}


}

/// @nodoc
abstract mixin class $CalendarReminderEntityCopyWith<$Res>  {
  factory $CalendarReminderEntityCopyWith(CalendarReminderEntity value, $Res Function(CalendarReminderEntity) _then) = _$CalendarReminderEntityCopyWithImpl;
@useResult
$Res call({
 String id, String title, int minutes, String userId, String? email, String eventId, String deviceId, String calendarId, String calendarName, String provider, DateTime targetDateTime, DateTime startDate, DateTime endDate, String locale, bool isAllDay, bool isEncrypted, String iv
});




}
/// @nodoc
class _$CalendarReminderEntityCopyWithImpl<$Res>
    implements $CalendarReminderEntityCopyWith<$Res> {
  _$CalendarReminderEntityCopyWithImpl(this._self, this._then);

  final CalendarReminderEntity _self;
  final $Res Function(CalendarReminderEntity) _then;

/// Create a copy of CalendarReminderEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? minutes = null,Object? userId = null,Object? email = freezed,Object? eventId = null,Object? deviceId = null,Object? calendarId = null,Object? calendarName = null,Object? provider = null,Object? targetDateTime = null,Object? startDate = null,Object? endDate = null,Object? locale = null,Object? isAllDay = null,Object? isEncrypted = null,Object? iv = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,minutes: null == minutes ? _self.minutes : minutes // ignore: cast_nullable_to_non_nullable
as int,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,eventId: null == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String,deviceId: null == deviceId ? _self.deviceId : deviceId // ignore: cast_nullable_to_non_nullable
as String,calendarId: null == calendarId ? _self.calendarId : calendarId // ignore: cast_nullable_to_non_nullable
as String,calendarName: null == calendarName ? _self.calendarName : calendarName // ignore: cast_nullable_to_non_nullable
as String,provider: null == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as String,targetDateTime: null == targetDateTime ? _self.targetDateTime : targetDateTime // ignore: cast_nullable_to_non_nullable
as DateTime,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,endDate: null == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime,locale: null == locale ? _self.locale : locale // ignore: cast_nullable_to_non_nullable
as String,isAllDay: null == isAllDay ? _self.isAllDay : isAllDay // ignore: cast_nullable_to_non_nullable
as bool,isEncrypted: null == isEncrypted ? _self.isEncrypted : isEncrypted // ignore: cast_nullable_to_non_nullable
as bool,iv: null == iv ? _self.iv : iv // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CalendarReminderEntity].
extension CalendarReminderEntityPatterns on CalendarReminderEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CalendarReminderEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CalendarReminderEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CalendarReminderEntity value)  $default,){
final _that = this;
switch (_that) {
case _CalendarReminderEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CalendarReminderEntity value)?  $default,){
final _that = this;
switch (_that) {
case _CalendarReminderEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  int minutes,  String userId,  String? email,  String eventId,  String deviceId,  String calendarId,  String calendarName,  String provider,  DateTime targetDateTime,  DateTime startDate,  DateTime endDate,  String locale,  bool isAllDay,  bool isEncrypted,  String iv)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CalendarReminderEntity() when $default != null:
return $default(_that.id,_that.title,_that.minutes,_that.userId,_that.email,_that.eventId,_that.deviceId,_that.calendarId,_that.calendarName,_that.provider,_that.targetDateTime,_that.startDate,_that.endDate,_that.locale,_that.isAllDay,_that.isEncrypted,_that.iv);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  int minutes,  String userId,  String? email,  String eventId,  String deviceId,  String calendarId,  String calendarName,  String provider,  DateTime targetDateTime,  DateTime startDate,  DateTime endDate,  String locale,  bool isAllDay,  bool isEncrypted,  String iv)  $default,) {final _that = this;
switch (_that) {
case _CalendarReminderEntity():
return $default(_that.id,_that.title,_that.minutes,_that.userId,_that.email,_that.eventId,_that.deviceId,_that.calendarId,_that.calendarName,_that.provider,_that.targetDateTime,_that.startDate,_that.endDate,_that.locale,_that.isAllDay,_that.isEncrypted,_that.iv);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  int minutes,  String userId,  String? email,  String eventId,  String deviceId,  String calendarId,  String calendarName,  String provider,  DateTime targetDateTime,  DateTime startDate,  DateTime endDate,  String locale,  bool isAllDay,  bool isEncrypted,  String iv)?  $default,) {final _that = this;
switch (_that) {
case _CalendarReminderEntity() when $default != null:
return $default(_that.id,_that.title,_that.minutes,_that.userId,_that.email,_that.eventId,_that.deviceId,_that.calendarId,_that.calendarName,_that.provider,_that.targetDateTime,_that.startDate,_that.endDate,_that.locale,_that.isAllDay,_that.isEncrypted,_that.iv);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _CalendarReminderEntity implements CalendarReminderEntity {
  const _CalendarReminderEntity({required this.id, required this.title, required this.minutes, required this.userId, this.email, required this.eventId, required this.deviceId, required this.calendarId, required this.calendarName, required this.provider, required this.targetDateTime, required this.startDate, required this.endDate, required this.locale, required this.isAllDay, required this.isEncrypted, required this.iv});
  factory _CalendarReminderEntity.fromJson(Map<String, dynamic> json) => _$CalendarReminderEntityFromJson(json);

@override final  String id;
@override final  String title;
@override final  int minutes;
@override final  String userId;
@override final  String? email;
@override final  String eventId;
@override final  String deviceId;
@override final  String calendarId;
@override final  String calendarName;
@override final  String provider;
@override final  DateTime targetDateTime;
@override final  DateTime startDate;
@override final  DateTime endDate;
@override final  String locale;
@override final  bool isAllDay;
@override final  bool isEncrypted;
@override final  String iv;

/// Create a copy of CalendarReminderEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CalendarReminderEntityCopyWith<_CalendarReminderEntity> get copyWith => __$CalendarReminderEntityCopyWithImpl<_CalendarReminderEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CalendarReminderEntityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CalendarReminderEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.minutes, minutes) || other.minutes == minutes)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.email, email) || other.email == email)&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.deviceId, deviceId) || other.deviceId == deviceId)&&(identical(other.calendarId, calendarId) || other.calendarId == calendarId)&&(identical(other.calendarName, calendarName) || other.calendarName == calendarName)&&(identical(other.provider, provider) || other.provider == provider)&&(identical(other.targetDateTime, targetDateTime) || other.targetDateTime == targetDateTime)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.locale, locale) || other.locale == locale)&&(identical(other.isAllDay, isAllDay) || other.isAllDay == isAllDay)&&(identical(other.isEncrypted, isEncrypted) || other.isEncrypted == isEncrypted)&&(identical(other.iv, iv) || other.iv == iv));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,minutes,userId,email,eventId,deviceId,calendarId,calendarName,provider,targetDateTime,startDate,endDate,locale,isAllDay,isEncrypted,iv);

@override
String toString() {
  return 'CalendarReminderEntity(id: $id, title: $title, minutes: $minutes, userId: $userId, email: $email, eventId: $eventId, deviceId: $deviceId, calendarId: $calendarId, calendarName: $calendarName, provider: $provider, targetDateTime: $targetDateTime, startDate: $startDate, endDate: $endDate, locale: $locale, isAllDay: $isAllDay, isEncrypted: $isEncrypted, iv: $iv)';
}


}

/// @nodoc
abstract mixin class _$CalendarReminderEntityCopyWith<$Res> implements $CalendarReminderEntityCopyWith<$Res> {
  factory _$CalendarReminderEntityCopyWith(_CalendarReminderEntity value, $Res Function(_CalendarReminderEntity) _then) = __$CalendarReminderEntityCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, int minutes, String userId, String? email, String eventId, String deviceId, String calendarId, String calendarName, String provider, DateTime targetDateTime, DateTime startDate, DateTime endDate, String locale, bool isAllDay, bool isEncrypted, String iv
});




}
/// @nodoc
class __$CalendarReminderEntityCopyWithImpl<$Res>
    implements _$CalendarReminderEntityCopyWith<$Res> {
  __$CalendarReminderEntityCopyWithImpl(this._self, this._then);

  final _CalendarReminderEntity _self;
  final $Res Function(_CalendarReminderEntity) _then;

/// Create a copy of CalendarReminderEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? minutes = null,Object? userId = null,Object? email = freezed,Object? eventId = null,Object? deviceId = null,Object? calendarId = null,Object? calendarName = null,Object? provider = null,Object? targetDateTime = null,Object? startDate = null,Object? endDate = null,Object? locale = null,Object? isAllDay = null,Object? isEncrypted = null,Object? iv = null,}) {
  return _then(_CalendarReminderEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,minutes: null == minutes ? _self.minutes : minutes // ignore: cast_nullable_to_non_nullable
as int,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,eventId: null == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String,deviceId: null == deviceId ? _self.deviceId : deviceId // ignore: cast_nullable_to_non_nullable
as String,calendarId: null == calendarId ? _self.calendarId : calendarId // ignore: cast_nullable_to_non_nullable
as String,calendarName: null == calendarName ? _self.calendarName : calendarName // ignore: cast_nullable_to_non_nullable
as String,provider: null == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as String,targetDateTime: null == targetDateTime ? _self.targetDateTime : targetDateTime // ignore: cast_nullable_to_non_nullable
as DateTime,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,endDate: null == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime,locale: null == locale ? _self.locale : locale // ignore: cast_nullable_to_non_nullable
as String,isAllDay: null == isAllDay ? _self.isAllDay : isAllDay // ignore: cast_nullable_to_non_nullable
as bool,isEncrypted: null == isEncrypted ? _self.isEncrypted : isEncrypted // ignore: cast_nullable_to_non_nullable
as bool,iv: null == iv ? _self.iv : iv // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
