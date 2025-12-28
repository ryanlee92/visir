// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'event_attendee_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$EventAttendeeEntity {

 String? get comment; String? get displayName; String? get email; String? get id; bool? get organizer; EventAttendeeResponseStatus? get responseStatus;
/// Create a copy of EventAttendeeEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EventAttendeeEntityCopyWith<EventAttendeeEntity> get copyWith => _$EventAttendeeEntityCopyWithImpl<EventAttendeeEntity>(this as EventAttendeeEntity, _$identity);

  /// Serializes this EventAttendeeEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EventAttendeeEntity&&(identical(other.comment, comment) || other.comment == comment)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.email, email) || other.email == email)&&(identical(other.id, id) || other.id == id)&&(identical(other.organizer, organizer) || other.organizer == organizer)&&(identical(other.responseStatus, responseStatus) || other.responseStatus == responseStatus));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,comment,displayName,email,id,organizer,responseStatus);

@override
String toString() {
  return 'EventAttendeeEntity(comment: $comment, displayName: $displayName, email: $email, id: $id, organizer: $organizer, responseStatus: $responseStatus)';
}


}

/// @nodoc
abstract mixin class $EventAttendeeEntityCopyWith<$Res>  {
  factory $EventAttendeeEntityCopyWith(EventAttendeeEntity value, $Res Function(EventAttendeeEntity) _then) = _$EventAttendeeEntityCopyWithImpl;
@useResult
$Res call({
 String? comment, String? displayName, String? email, String? id, bool? organizer, EventAttendeeResponseStatus? responseStatus
});




}
/// @nodoc
class _$EventAttendeeEntityCopyWithImpl<$Res>
    implements $EventAttendeeEntityCopyWith<$Res> {
  _$EventAttendeeEntityCopyWithImpl(this._self, this._then);

  final EventAttendeeEntity _self;
  final $Res Function(EventAttendeeEntity) _then;

/// Create a copy of EventAttendeeEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? comment = freezed,Object? displayName = freezed,Object? email = freezed,Object? id = freezed,Object? organizer = freezed,Object? responseStatus = freezed,}) {
  return _then(_self.copyWith(
comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,organizer: freezed == organizer ? _self.organizer : organizer // ignore: cast_nullable_to_non_nullable
as bool?,responseStatus: freezed == responseStatus ? _self.responseStatus : responseStatus // ignore: cast_nullable_to_non_nullable
as EventAttendeeResponseStatus?,
  ));
}

}


/// Adds pattern-matching-related methods to [EventAttendeeEntity].
extension EventAttendeeEntityPatterns on EventAttendeeEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EventAttendeeEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EventAttendeeEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EventAttendeeEntity value)  $default,){
final _that = this;
switch (_that) {
case _EventAttendeeEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EventAttendeeEntity value)?  $default,){
final _that = this;
switch (_that) {
case _EventAttendeeEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? comment,  String? displayName,  String? email,  String? id,  bool? organizer,  EventAttendeeResponseStatus? responseStatus)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EventAttendeeEntity() when $default != null:
return $default(_that.comment,_that.displayName,_that.email,_that.id,_that.organizer,_that.responseStatus);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? comment,  String? displayName,  String? email,  String? id,  bool? organizer,  EventAttendeeResponseStatus? responseStatus)  $default,) {final _that = this;
switch (_that) {
case _EventAttendeeEntity():
return $default(_that.comment,_that.displayName,_that.email,_that.id,_that.organizer,_that.responseStatus);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? comment,  String? displayName,  String? email,  String? id,  bool? organizer,  EventAttendeeResponseStatus? responseStatus)?  $default,) {final _that = this;
switch (_that) {
case _EventAttendeeEntity() when $default != null:
return $default(_that.comment,_that.displayName,_that.email,_that.id,_that.organizer,_that.responseStatus);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _EventAttendeeEntity implements EventAttendeeEntity {
  const _EventAttendeeEntity({this.comment, this.displayName, this.email, this.id, this.organizer, this.responseStatus});
  factory _EventAttendeeEntity.fromJson(Map<String, dynamic> json) => _$EventAttendeeEntityFromJson(json);

@override final  String? comment;
@override final  String? displayName;
@override final  String? email;
@override final  String? id;
@override final  bool? organizer;
@override final  EventAttendeeResponseStatus? responseStatus;

/// Create a copy of EventAttendeeEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EventAttendeeEntityCopyWith<_EventAttendeeEntity> get copyWith => __$EventAttendeeEntityCopyWithImpl<_EventAttendeeEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EventAttendeeEntityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EventAttendeeEntity&&(identical(other.comment, comment) || other.comment == comment)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.email, email) || other.email == email)&&(identical(other.id, id) || other.id == id)&&(identical(other.organizer, organizer) || other.organizer == organizer)&&(identical(other.responseStatus, responseStatus) || other.responseStatus == responseStatus));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,comment,displayName,email,id,organizer,responseStatus);

@override
String toString() {
  return 'EventAttendeeEntity(comment: $comment, displayName: $displayName, email: $email, id: $id, organizer: $organizer, responseStatus: $responseStatus)';
}


}

/// @nodoc
abstract mixin class _$EventAttendeeEntityCopyWith<$Res> implements $EventAttendeeEntityCopyWith<$Res> {
  factory _$EventAttendeeEntityCopyWith(_EventAttendeeEntity value, $Res Function(_EventAttendeeEntity) _then) = __$EventAttendeeEntityCopyWithImpl;
@override @useResult
$Res call({
 String? comment, String? displayName, String? email, String? id, bool? organizer, EventAttendeeResponseStatus? responseStatus
});




}
/// @nodoc
class __$EventAttendeeEntityCopyWithImpl<$Res>
    implements _$EventAttendeeEntityCopyWith<$Res> {
  __$EventAttendeeEntityCopyWithImpl(this._self, this._then);

  final _EventAttendeeEntity _self;
  final $Res Function(_EventAttendeeEntity) _then;

/// Create a copy of EventAttendeeEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? comment = freezed,Object? displayName = freezed,Object? email = freezed,Object? id = freezed,Object? organizer = freezed,Object? responseStatus = freezed,}) {
  return _then(_EventAttendeeEntity(
comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,organizer: freezed == organizer ? _self.organizer : organizer // ignore: cast_nullable_to_non_nullable
as bool?,responseStatus: freezed == responseStatus ? _self.responseStatus : responseStatus // ignore: cast_nullable_to_non_nullable
as EventAttendeeResponseStatus?,
  ));
}


}

// dart format on
