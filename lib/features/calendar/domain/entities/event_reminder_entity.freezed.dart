// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'event_reminder_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$EventReminderEntity {

 String? get method; int? get minutes;
/// Create a copy of EventReminderEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EventReminderEntityCopyWith<EventReminderEntity> get copyWith => _$EventReminderEntityCopyWithImpl<EventReminderEntity>(this as EventReminderEntity, _$identity);

  /// Serializes this EventReminderEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EventReminderEntity&&(identical(other.method, method) || other.method == method)&&(identical(other.minutes, minutes) || other.minutes == minutes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,method,minutes);

@override
String toString() {
  return 'EventReminderEntity(method: $method, minutes: $minutes)';
}


}

/// @nodoc
abstract mixin class $EventReminderEntityCopyWith<$Res>  {
  factory $EventReminderEntityCopyWith(EventReminderEntity value, $Res Function(EventReminderEntity) _then) = _$EventReminderEntityCopyWithImpl;
@useResult
$Res call({
 String? method, int? minutes
});




}
/// @nodoc
class _$EventReminderEntityCopyWithImpl<$Res>
    implements $EventReminderEntityCopyWith<$Res> {
  _$EventReminderEntityCopyWithImpl(this._self, this._then);

  final EventReminderEntity _self;
  final $Res Function(EventReminderEntity) _then;

/// Create a copy of EventReminderEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? method = freezed,Object? minutes = freezed,}) {
  return _then(_self.copyWith(
method: freezed == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as String?,minutes: freezed == minutes ? _self.minutes : minutes // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [EventReminderEntity].
extension EventReminderEntityPatterns on EventReminderEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EventReminderEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EventReminderEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EventReminderEntity value)  $default,){
final _that = this;
switch (_that) {
case _EventReminderEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EventReminderEntity value)?  $default,){
final _that = this;
switch (_that) {
case _EventReminderEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? method,  int? minutes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EventReminderEntity() when $default != null:
return $default(_that.method,_that.minutes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? method,  int? minutes)  $default,) {final _that = this;
switch (_that) {
case _EventReminderEntity():
return $default(_that.method,_that.minutes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? method,  int? minutes)?  $default,) {final _that = this;
switch (_that) {
case _EventReminderEntity() when $default != null:
return $default(_that.method,_that.minutes);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _EventReminderEntity implements EventReminderEntity {
  const _EventReminderEntity({this.method, this.minutes});
  factory _EventReminderEntity.fromJson(Map<String, dynamic> json) => _$EventReminderEntityFromJson(json);

@override final  String? method;
@override final  int? minutes;

/// Create a copy of EventReminderEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EventReminderEntityCopyWith<_EventReminderEntity> get copyWith => __$EventReminderEntityCopyWithImpl<_EventReminderEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EventReminderEntityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EventReminderEntity&&(identical(other.method, method) || other.method == method)&&(identical(other.minutes, minutes) || other.minutes == minutes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,method,minutes);

@override
String toString() {
  return 'EventReminderEntity(method: $method, minutes: $minutes)';
}


}

/// @nodoc
abstract mixin class _$EventReminderEntityCopyWith<$Res> implements $EventReminderEntityCopyWith<$Res> {
  factory _$EventReminderEntityCopyWith(_EventReminderEntity value, $Res Function(_EventReminderEntity) _then) = __$EventReminderEntityCopyWithImpl;
@override @useResult
$Res call({
 String? method, int? minutes
});




}
/// @nodoc
class __$EventReminderEntityCopyWithImpl<$Res>
    implements _$EventReminderEntityCopyWith<$Res> {
  __$EventReminderEntityCopyWithImpl(this._self, this._then);

  final _EventReminderEntity _self;
  final $Res Function(_EventReminderEntity) _then;

/// Create a copy of EventReminderEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? method = freezed,Object? minutes = freezed,}) {
  return _then(_EventReminderEntity(
method: freezed == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as String?,minutes: freezed == minutes ? _self.minutes : minutes // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
