// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'calendar_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CalendarEntity {

 String get id; String get name; String? get email; String get backgroundColor; String get foregroundColor; List<EventReminderEntity>? get defaultReminders; bool? get owned; bool? get modifiable; bool? get shareable; bool? get removable; CalendarEntityType? get type;
/// Create a copy of CalendarEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CalendarEntityCopyWith<CalendarEntity> get copyWith => _$CalendarEntityCopyWithImpl<CalendarEntity>(this as CalendarEntity, _$identity);

  /// Serializes this CalendarEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CalendarEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.email, email) || other.email == email)&&(identical(other.backgroundColor, backgroundColor) || other.backgroundColor == backgroundColor)&&(identical(other.foregroundColor, foregroundColor) || other.foregroundColor == foregroundColor)&&const DeepCollectionEquality().equals(other.defaultReminders, defaultReminders)&&(identical(other.owned, owned) || other.owned == owned)&&(identical(other.modifiable, modifiable) || other.modifiable == modifiable)&&(identical(other.shareable, shareable) || other.shareable == shareable)&&(identical(other.removable, removable) || other.removable == removable)&&(identical(other.type, type) || other.type == type));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,email,backgroundColor,foregroundColor,const DeepCollectionEquality().hash(defaultReminders),owned,modifiable,shareable,removable,type);

@override
String toString() {
  return 'CalendarEntity(id: $id, name: $name, email: $email, backgroundColor: $backgroundColor, foregroundColor: $foregroundColor, defaultReminders: $defaultReminders, owned: $owned, modifiable: $modifiable, shareable: $shareable, removable: $removable, type: $type)';
}


}

/// @nodoc
abstract mixin class $CalendarEntityCopyWith<$Res>  {
  factory $CalendarEntityCopyWith(CalendarEntity value, $Res Function(CalendarEntity) _then) = _$CalendarEntityCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? email, String backgroundColor, String foregroundColor, List<EventReminderEntity>? defaultReminders, bool? owned, bool? modifiable, bool? shareable, bool? removable, CalendarEntityType? type
});




}
/// @nodoc
class _$CalendarEntityCopyWithImpl<$Res>
    implements $CalendarEntityCopyWith<$Res> {
  _$CalendarEntityCopyWithImpl(this._self, this._then);

  final CalendarEntity _self;
  final $Res Function(CalendarEntity) _then;

/// Create a copy of CalendarEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? email = freezed,Object? backgroundColor = null,Object? foregroundColor = null,Object? defaultReminders = freezed,Object? owned = freezed,Object? modifiable = freezed,Object? shareable = freezed,Object? removable = freezed,Object? type = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,backgroundColor: null == backgroundColor ? _self.backgroundColor : backgroundColor // ignore: cast_nullable_to_non_nullable
as String,foregroundColor: null == foregroundColor ? _self.foregroundColor : foregroundColor // ignore: cast_nullable_to_non_nullable
as String,defaultReminders: freezed == defaultReminders ? _self.defaultReminders : defaultReminders // ignore: cast_nullable_to_non_nullable
as List<EventReminderEntity>?,owned: freezed == owned ? _self.owned : owned // ignore: cast_nullable_to_non_nullable
as bool?,modifiable: freezed == modifiable ? _self.modifiable : modifiable // ignore: cast_nullable_to_non_nullable
as bool?,shareable: freezed == shareable ? _self.shareable : shareable // ignore: cast_nullable_to_non_nullable
as bool?,removable: freezed == removable ? _self.removable : removable // ignore: cast_nullable_to_non_nullable
as bool?,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as CalendarEntityType?,
  ));
}

}


/// Adds pattern-matching-related methods to [CalendarEntity].
extension CalendarEntityPatterns on CalendarEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CalendarEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CalendarEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CalendarEntity value)  $default,){
final _that = this;
switch (_that) {
case _CalendarEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CalendarEntity value)?  $default,){
final _that = this;
switch (_that) {
case _CalendarEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String? email,  String backgroundColor,  String foregroundColor,  List<EventReminderEntity>? defaultReminders,  bool? owned,  bool? modifiable,  bool? shareable,  bool? removable,  CalendarEntityType? type)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CalendarEntity() when $default != null:
return $default(_that.id,_that.name,_that.email,_that.backgroundColor,_that.foregroundColor,_that.defaultReminders,_that.owned,_that.modifiable,_that.shareable,_that.removable,_that.type);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String? email,  String backgroundColor,  String foregroundColor,  List<EventReminderEntity>? defaultReminders,  bool? owned,  bool? modifiable,  bool? shareable,  bool? removable,  CalendarEntityType? type)  $default,) {final _that = this;
switch (_that) {
case _CalendarEntity():
return $default(_that.id,_that.name,_that.email,_that.backgroundColor,_that.foregroundColor,_that.defaultReminders,_that.owned,_that.modifiable,_that.shareable,_that.removable,_that.type);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String? email,  String backgroundColor,  String foregroundColor,  List<EventReminderEntity>? defaultReminders,  bool? owned,  bool? modifiable,  bool? shareable,  bool? removable,  CalendarEntityType? type)?  $default,) {final _that = this;
switch (_that) {
case _CalendarEntity() when $default != null:
return $default(_that.id,_that.name,_that.email,_that.backgroundColor,_that.foregroundColor,_that.defaultReminders,_that.owned,_that.modifiable,_that.shareable,_that.removable,_that.type);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _CalendarEntity implements CalendarEntity {
  const _CalendarEntity({required this.id, required this.name, this.email, required this.backgroundColor, required this.foregroundColor, final  List<EventReminderEntity>? defaultReminders, this.owned, this.modifiable, this.shareable, this.removable, this.type}): _defaultReminders = defaultReminders;
  factory _CalendarEntity.fromJson(Map<String, dynamic> json) => _$CalendarEntityFromJson(json);

@override final  String id;
@override final  String name;
@override final  String? email;
@override final  String backgroundColor;
@override final  String foregroundColor;
 final  List<EventReminderEntity>? _defaultReminders;
@override List<EventReminderEntity>? get defaultReminders {
  final value = _defaultReminders;
  if (value == null) return null;
  if (_defaultReminders is EqualUnmodifiableListView) return _defaultReminders;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  bool? owned;
@override final  bool? modifiable;
@override final  bool? shareable;
@override final  bool? removable;
@override final  CalendarEntityType? type;

/// Create a copy of CalendarEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CalendarEntityCopyWith<_CalendarEntity> get copyWith => __$CalendarEntityCopyWithImpl<_CalendarEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CalendarEntityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CalendarEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.email, email) || other.email == email)&&(identical(other.backgroundColor, backgroundColor) || other.backgroundColor == backgroundColor)&&(identical(other.foregroundColor, foregroundColor) || other.foregroundColor == foregroundColor)&&const DeepCollectionEquality().equals(other._defaultReminders, _defaultReminders)&&(identical(other.owned, owned) || other.owned == owned)&&(identical(other.modifiable, modifiable) || other.modifiable == modifiable)&&(identical(other.shareable, shareable) || other.shareable == shareable)&&(identical(other.removable, removable) || other.removable == removable)&&(identical(other.type, type) || other.type == type));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,email,backgroundColor,foregroundColor,const DeepCollectionEquality().hash(_defaultReminders),owned,modifiable,shareable,removable,type);

@override
String toString() {
  return 'CalendarEntity(id: $id, name: $name, email: $email, backgroundColor: $backgroundColor, foregroundColor: $foregroundColor, defaultReminders: $defaultReminders, owned: $owned, modifiable: $modifiable, shareable: $shareable, removable: $removable, type: $type)';
}


}

/// @nodoc
abstract mixin class _$CalendarEntityCopyWith<$Res> implements $CalendarEntityCopyWith<$Res> {
  factory _$CalendarEntityCopyWith(_CalendarEntity value, $Res Function(_CalendarEntity) _then) = __$CalendarEntityCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? email, String backgroundColor, String foregroundColor, List<EventReminderEntity>? defaultReminders, bool? owned, bool? modifiable, bool? shareable, bool? removable, CalendarEntityType? type
});




}
/// @nodoc
class __$CalendarEntityCopyWithImpl<$Res>
    implements _$CalendarEntityCopyWith<$Res> {
  __$CalendarEntityCopyWithImpl(this._self, this._then);

  final _CalendarEntity _self;
  final $Res Function(_CalendarEntity) _then;

/// Create a copy of CalendarEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? email = freezed,Object? backgroundColor = null,Object? foregroundColor = null,Object? defaultReminders = freezed,Object? owned = freezed,Object? modifiable = freezed,Object? shareable = freezed,Object? removable = freezed,Object? type = freezed,}) {
  return _then(_CalendarEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,backgroundColor: null == backgroundColor ? _self.backgroundColor : backgroundColor // ignore: cast_nullable_to_non_nullable
as String,foregroundColor: null == foregroundColor ? _self.foregroundColor : foregroundColor // ignore: cast_nullable_to_non_nullable
as String,defaultReminders: freezed == defaultReminders ? _self._defaultReminders : defaultReminders // ignore: cast_nullable_to_non_nullable
as List<EventReminderEntity>?,owned: freezed == owned ? _self.owned : owned // ignore: cast_nullable_to_non_nullable
as bool?,modifiable: freezed == modifiable ? _self.modifiable : modifiable // ignore: cast_nullable_to_non_nullable
as bool?,shareable: freezed == shareable ? _self.shareable : shareable // ignore: cast_nullable_to_non_nullable
as bool?,removable: freezed == removable ? _self.removable : removable // ignore: cast_nullable_to_non_nullable
as bool?,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as CalendarEntityType?,
  ));
}


}

// dart format on
