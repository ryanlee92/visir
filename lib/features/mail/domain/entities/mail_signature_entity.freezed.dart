// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'mail_signature_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MailSignatureEntity {

 int get number; String get signature;
/// Create a copy of MailSignatureEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MailSignatureEntityCopyWith<MailSignatureEntity> get copyWith => _$MailSignatureEntityCopyWithImpl<MailSignatureEntity>(this as MailSignatureEntity, _$identity);

  /// Serializes this MailSignatureEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MailSignatureEntity&&(identical(other.number, number) || other.number == number)&&(identical(other.signature, signature) || other.signature == signature));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,number,signature);

@override
String toString() {
  return 'MailSignatureEntity(number: $number, signature: $signature)';
}


}

/// @nodoc
abstract mixin class $MailSignatureEntityCopyWith<$Res>  {
  factory $MailSignatureEntityCopyWith(MailSignatureEntity value, $Res Function(MailSignatureEntity) _then) = _$MailSignatureEntityCopyWithImpl;
@useResult
$Res call({
 int number, String signature
});




}
/// @nodoc
class _$MailSignatureEntityCopyWithImpl<$Res>
    implements $MailSignatureEntityCopyWith<$Res> {
  _$MailSignatureEntityCopyWithImpl(this._self, this._then);

  final MailSignatureEntity _self;
  final $Res Function(MailSignatureEntity) _then;

/// Create a copy of MailSignatureEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? number = null,Object? signature = null,}) {
  return _then(_self.copyWith(
number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as int,signature: null == signature ? _self.signature : signature // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [MailSignatureEntity].
extension MailSignatureEntityPatterns on MailSignatureEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MailSignatureEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MailSignatureEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MailSignatureEntity value)  $default,){
final _that = this;
switch (_that) {
case _MailSignatureEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MailSignatureEntity value)?  $default,){
final _that = this;
switch (_that) {
case _MailSignatureEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int number,  String signature)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MailSignatureEntity() when $default != null:
return $default(_that.number,_that.signature);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int number,  String signature)  $default,) {final _that = this;
switch (_that) {
case _MailSignatureEntity():
return $default(_that.number,_that.signature);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int number,  String signature)?  $default,) {final _that = this;
switch (_that) {
case _MailSignatureEntity() when $default != null:
return $default(_that.number,_that.signature);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _MailSignatureEntity implements MailSignatureEntity {
  const _MailSignatureEntity({required this.number, required this.signature});
  factory _MailSignatureEntity.fromJson(Map<String, dynamic> json) => _$MailSignatureEntityFromJson(json);

@override final  int number;
@override final  String signature;

/// Create a copy of MailSignatureEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MailSignatureEntityCopyWith<_MailSignatureEntity> get copyWith => __$MailSignatureEntityCopyWithImpl<_MailSignatureEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MailSignatureEntityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MailSignatureEntity&&(identical(other.number, number) || other.number == number)&&(identical(other.signature, signature) || other.signature == signature));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,number,signature);

@override
String toString() {
  return 'MailSignatureEntity(number: $number, signature: $signature)';
}


}

/// @nodoc
abstract mixin class _$MailSignatureEntityCopyWith<$Res> implements $MailSignatureEntityCopyWith<$Res> {
  factory _$MailSignatureEntityCopyWith(_MailSignatureEntity value, $Res Function(_MailSignatureEntity) _then) = __$MailSignatureEntityCopyWithImpl;
@override @useResult
$Res call({
 int number, String signature
});




}
/// @nodoc
class __$MailSignatureEntityCopyWithImpl<$Res>
    implements _$MailSignatureEntityCopyWith<$Res> {
  __$MailSignatureEntityCopyWithImpl(this._self, this._then);

  final _MailSignatureEntity _self;
  final $Res Function(_MailSignatureEntity) _then;

/// Create a copy of MailSignatureEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? number = null,Object? signature = null,}) {
  return _then(_MailSignatureEntity(
number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as int,signature: null == signature ? _self.signature : signature // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
