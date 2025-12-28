// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'failure.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Failure {

 StackTrace get stackTrace;
/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FailureCopyWith<Failure> get copyWith => _$FailureCopyWithImpl<Failure>(this as Failure, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Failure&&(identical(other.stackTrace, stackTrace) || other.stackTrace == stackTrace));
}


@override
int get hashCode => Object.hash(runtimeType,stackTrace);

@override
String toString() {
  return 'Failure(stackTrace: $stackTrace)';
}


}

/// @nodoc
abstract mixin class $FailureCopyWith<$Res>  {
  factory $FailureCopyWith(Failure value, $Res Function(Failure) _then) = _$FailureCopyWithImpl;
@useResult
$Res call({
 StackTrace stackTrace
});




}
/// @nodoc
class _$FailureCopyWithImpl<$Res>
    implements $FailureCopyWith<$Res> {
  _$FailureCopyWithImpl(this._self, this._then);

  final Failure _self;
  final $Res Function(Failure) _then;

/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? stackTrace = null,}) {
  return _then(_self.copyWith(
stackTrace: null == stackTrace ? _self.stackTrace : stackTrace // ignore: cast_nullable_to_non_nullable
as StackTrace,
  ));
}

}


/// Adds pattern-matching-related methods to [Failure].
extension FailurePatterns on Failure {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _EmptyFailure value)?  empty,TResult Function( _UnprocessableEntityFailure value)?  unprocessableEntity,TResult Function( _UnauthorizedFailure value)?  unauthorized,TResult Function( _BadRequestFailure value)?  badRequest,TResult Function( _InsufficientCreditsFailure value)?  insufficientCredits,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EmptyFailure() when empty != null:
return empty(_that);case _UnprocessableEntityFailure() when unprocessableEntity != null:
return unprocessableEntity(_that);case _UnauthorizedFailure() when unauthorized != null:
return unauthorized(_that);case _BadRequestFailure() when badRequest != null:
return badRequest(_that);case _InsufficientCreditsFailure() when insufficientCredits != null:
return insufficientCredits(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _EmptyFailure value)  empty,required TResult Function( _UnprocessableEntityFailure value)  unprocessableEntity,required TResult Function( _UnauthorizedFailure value)  unauthorized,required TResult Function( _BadRequestFailure value)  badRequest,required TResult Function( _InsufficientCreditsFailure value)  insufficientCredits,}){
final _that = this;
switch (_that) {
case _EmptyFailure():
return empty(_that);case _UnprocessableEntityFailure():
return unprocessableEntity(_that);case _UnauthorizedFailure():
return unauthorized(_that);case _BadRequestFailure():
return badRequest(_that);case _InsufficientCreditsFailure():
return insufficientCredits(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _EmptyFailure value)?  empty,TResult? Function( _UnprocessableEntityFailure value)?  unprocessableEntity,TResult? Function( _UnauthorizedFailure value)?  unauthorized,TResult? Function( _BadRequestFailure value)?  badRequest,TResult? Function( _InsufficientCreditsFailure value)?  insufficientCredits,}){
final _that = this;
switch (_that) {
case _EmptyFailure() when empty != null:
return empty(_that);case _UnprocessableEntityFailure() when unprocessableEntity != null:
return unprocessableEntity(_that);case _UnauthorizedFailure() when unauthorized != null:
return unauthorized(_that);case _BadRequestFailure() when badRequest != null:
return badRequest(_that);case _InsufficientCreditsFailure() when insufficientCredits != null:
return insufficientCredits(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( StackTrace stackTrace,  String? message)?  empty,TResult Function( StackTrace stackTrace,  String message)?  unprocessableEntity,TResult Function( StackTrace stackTrace,  String? message)?  unauthorized,TResult Function( StackTrace stackTrace,  String? message)?  badRequest,TResult Function( StackTrace stackTrace,  double required,  double available)?  insufficientCredits,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EmptyFailure() when empty != null:
return empty(_that.stackTrace,_that.message);case _UnprocessableEntityFailure() when unprocessableEntity != null:
return unprocessableEntity(_that.stackTrace,_that.message);case _UnauthorizedFailure() when unauthorized != null:
return unauthorized(_that.stackTrace,_that.message);case _BadRequestFailure() when badRequest != null:
return badRequest(_that.stackTrace,_that.message);case _InsufficientCreditsFailure() when insufficientCredits != null:
return insufficientCredits(_that.stackTrace,_that.required,_that.available);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( StackTrace stackTrace,  String? message)  empty,required TResult Function( StackTrace stackTrace,  String message)  unprocessableEntity,required TResult Function( StackTrace stackTrace,  String? message)  unauthorized,required TResult Function( StackTrace stackTrace,  String? message)  badRequest,required TResult Function( StackTrace stackTrace,  double required,  double available)  insufficientCredits,}) {final _that = this;
switch (_that) {
case _EmptyFailure():
return empty(_that.stackTrace,_that.message);case _UnprocessableEntityFailure():
return unprocessableEntity(_that.stackTrace,_that.message);case _UnauthorizedFailure():
return unauthorized(_that.stackTrace,_that.message);case _BadRequestFailure():
return badRequest(_that.stackTrace,_that.message);case _InsufficientCreditsFailure():
return insufficientCredits(_that.stackTrace,_that.required,_that.available);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( StackTrace stackTrace,  String? message)?  empty,TResult? Function( StackTrace stackTrace,  String message)?  unprocessableEntity,TResult? Function( StackTrace stackTrace,  String? message)?  unauthorized,TResult? Function( StackTrace stackTrace,  String? message)?  badRequest,TResult? Function( StackTrace stackTrace,  double required,  double available)?  insufficientCredits,}) {final _that = this;
switch (_that) {
case _EmptyFailure() when empty != null:
return empty(_that.stackTrace,_that.message);case _UnprocessableEntityFailure() when unprocessableEntity != null:
return unprocessableEntity(_that.stackTrace,_that.message);case _UnauthorizedFailure() when unauthorized != null:
return unauthorized(_that.stackTrace,_that.message);case _BadRequestFailure() when badRequest != null:
return badRequest(_that.stackTrace,_that.message);case _InsufficientCreditsFailure() when insufficientCredits != null:
return insufficientCredits(_that.stackTrace,_that.required,_that.available);case _:
  return null;

}
}

}

/// @nodoc


class _EmptyFailure extends Failure {
  const _EmptyFailure(this.stackTrace, [this.message]): super._();
  

@override final  StackTrace stackTrace;
 final  String? message;

/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EmptyFailureCopyWith<_EmptyFailure> get copyWith => __$EmptyFailureCopyWithImpl<_EmptyFailure>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EmptyFailure&&(identical(other.stackTrace, stackTrace) || other.stackTrace == stackTrace)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,stackTrace,message);

@override
String toString() {
  return 'Failure.empty(stackTrace: $stackTrace, message: $message)';
}


}

/// @nodoc
abstract mixin class _$EmptyFailureCopyWith<$Res> implements $FailureCopyWith<$Res> {
  factory _$EmptyFailureCopyWith(_EmptyFailure value, $Res Function(_EmptyFailure) _then) = __$EmptyFailureCopyWithImpl;
@override @useResult
$Res call({
 StackTrace stackTrace, String? message
});




}
/// @nodoc
class __$EmptyFailureCopyWithImpl<$Res>
    implements _$EmptyFailureCopyWith<$Res> {
  __$EmptyFailureCopyWithImpl(this._self, this._then);

  final _EmptyFailure _self;
  final $Res Function(_EmptyFailure) _then;

/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? stackTrace = null,Object? message = freezed,}) {
  return _then(_EmptyFailure(
null == stackTrace ? _self.stackTrace : stackTrace // ignore: cast_nullable_to_non_nullable
as StackTrace,freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class _UnprocessableEntityFailure extends Failure {
  const _UnprocessableEntityFailure(this.stackTrace, {required this.message}): super._();
  

@override final  StackTrace stackTrace;
 final  String message;

/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UnprocessableEntityFailureCopyWith<_UnprocessableEntityFailure> get copyWith => __$UnprocessableEntityFailureCopyWithImpl<_UnprocessableEntityFailure>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UnprocessableEntityFailure&&(identical(other.stackTrace, stackTrace) || other.stackTrace == stackTrace)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,stackTrace,message);

@override
String toString() {
  return 'Failure.unprocessableEntity(stackTrace: $stackTrace, message: $message)';
}


}

/// @nodoc
abstract mixin class _$UnprocessableEntityFailureCopyWith<$Res> implements $FailureCopyWith<$Res> {
  factory _$UnprocessableEntityFailureCopyWith(_UnprocessableEntityFailure value, $Res Function(_UnprocessableEntityFailure) _then) = __$UnprocessableEntityFailureCopyWithImpl;
@override @useResult
$Res call({
 StackTrace stackTrace, String message
});




}
/// @nodoc
class __$UnprocessableEntityFailureCopyWithImpl<$Res>
    implements _$UnprocessableEntityFailureCopyWith<$Res> {
  __$UnprocessableEntityFailureCopyWithImpl(this._self, this._then);

  final _UnprocessableEntityFailure _self;
  final $Res Function(_UnprocessableEntityFailure) _then;

/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? stackTrace = null,Object? message = null,}) {
  return _then(_UnprocessableEntityFailure(
null == stackTrace ? _self.stackTrace : stackTrace // ignore: cast_nullable_to_non_nullable
as StackTrace,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class _UnauthorizedFailure extends Failure {
  const _UnauthorizedFailure(this.stackTrace, [this.message]): super._();
  

@override final  StackTrace stackTrace;
 final  String? message;

/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UnauthorizedFailureCopyWith<_UnauthorizedFailure> get copyWith => __$UnauthorizedFailureCopyWithImpl<_UnauthorizedFailure>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UnauthorizedFailure&&(identical(other.stackTrace, stackTrace) || other.stackTrace == stackTrace)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,stackTrace,message);

@override
String toString() {
  return 'Failure.unauthorized(stackTrace: $stackTrace, message: $message)';
}


}

/// @nodoc
abstract mixin class _$UnauthorizedFailureCopyWith<$Res> implements $FailureCopyWith<$Res> {
  factory _$UnauthorizedFailureCopyWith(_UnauthorizedFailure value, $Res Function(_UnauthorizedFailure) _then) = __$UnauthorizedFailureCopyWithImpl;
@override @useResult
$Res call({
 StackTrace stackTrace, String? message
});




}
/// @nodoc
class __$UnauthorizedFailureCopyWithImpl<$Res>
    implements _$UnauthorizedFailureCopyWith<$Res> {
  __$UnauthorizedFailureCopyWithImpl(this._self, this._then);

  final _UnauthorizedFailure _self;
  final $Res Function(_UnauthorizedFailure) _then;

/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? stackTrace = null,Object? message = freezed,}) {
  return _then(_UnauthorizedFailure(
null == stackTrace ? _self.stackTrace : stackTrace // ignore: cast_nullable_to_non_nullable
as StackTrace,freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class _BadRequestFailure extends Failure {
  const _BadRequestFailure(this.stackTrace, [this.message]): super._();
  

@override final  StackTrace stackTrace;
 final  String? message;

/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BadRequestFailureCopyWith<_BadRequestFailure> get copyWith => __$BadRequestFailureCopyWithImpl<_BadRequestFailure>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BadRequestFailure&&(identical(other.stackTrace, stackTrace) || other.stackTrace == stackTrace)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,stackTrace,message);

@override
String toString() {
  return 'Failure.badRequest(stackTrace: $stackTrace, message: $message)';
}


}

/// @nodoc
abstract mixin class _$BadRequestFailureCopyWith<$Res> implements $FailureCopyWith<$Res> {
  factory _$BadRequestFailureCopyWith(_BadRequestFailure value, $Res Function(_BadRequestFailure) _then) = __$BadRequestFailureCopyWithImpl;
@override @useResult
$Res call({
 StackTrace stackTrace, String? message
});




}
/// @nodoc
class __$BadRequestFailureCopyWithImpl<$Res>
    implements _$BadRequestFailureCopyWith<$Res> {
  __$BadRequestFailureCopyWithImpl(this._self, this._then);

  final _BadRequestFailure _self;
  final $Res Function(_BadRequestFailure) _then;

/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? stackTrace = null,Object? message = freezed,}) {
  return _then(_BadRequestFailure(
null == stackTrace ? _self.stackTrace : stackTrace // ignore: cast_nullable_to_non_nullable
as StackTrace,freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class _InsufficientCreditsFailure extends Failure {
  const _InsufficientCreditsFailure(this.stackTrace, {required this.required, required this.available}): super._();
  

@override final  StackTrace stackTrace;
 final  double required;
 final  double available;

/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InsufficientCreditsFailureCopyWith<_InsufficientCreditsFailure> get copyWith => __$InsufficientCreditsFailureCopyWithImpl<_InsufficientCreditsFailure>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InsufficientCreditsFailure&&(identical(other.stackTrace, stackTrace) || other.stackTrace == stackTrace)&&(identical(other.required, required) || other.required == required)&&(identical(other.available, available) || other.available == available));
}


@override
int get hashCode => Object.hash(runtimeType,stackTrace,required,available);

@override
String toString() {
  return 'Failure.insufficientCredits(stackTrace: $stackTrace, required: $required, available: $available)';
}


}

/// @nodoc
abstract mixin class _$InsufficientCreditsFailureCopyWith<$Res> implements $FailureCopyWith<$Res> {
  factory _$InsufficientCreditsFailureCopyWith(_InsufficientCreditsFailure value, $Res Function(_InsufficientCreditsFailure) _then) = __$InsufficientCreditsFailureCopyWithImpl;
@override @useResult
$Res call({
 StackTrace stackTrace, double required, double available
});




}
/// @nodoc
class __$InsufficientCreditsFailureCopyWithImpl<$Res>
    implements _$InsufficientCreditsFailureCopyWith<$Res> {
  __$InsufficientCreditsFailureCopyWithImpl(this._self, this._then);

  final _InsufficientCreditsFailure _self;
  final $Res Function(_InsufficientCreditsFailure) _then;

/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? stackTrace = null,Object? required = null,Object? available = null,}) {
  return _then(_InsufficientCreditsFailure(
null == stackTrace ? _self.stackTrace : stackTrace // ignore: cast_nullable_to_non_nullable
as StackTrace,required: null == required ? _self.required : required // ignore: cast_nullable_to_non_nullable
as double,available: null == available ? _self.available : available // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
