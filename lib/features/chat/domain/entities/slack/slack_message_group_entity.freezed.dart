// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'slack_message_group_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SlackMessageGroupEntity {

@JsonKey(includeIfNull: false) String? get id;@JsonKey(includeIfNull: false) String? get teamId;@JsonKey(includeIfNull: false) bool? get isUsergroup;@JsonKey(includeIfNull: false) String? get name;@JsonKey(includeIfNull: false) String? get description;@JsonKey(includeIfNull: false) String? get handle;@JsonKey(includeIfNull: false) bool? get isExternal;@JsonKey(includeIfNull: false) int? get dateCreate;@JsonKey(includeIfNull: false) int? get dateUpdate;@JsonKey(includeIfNull: false) int? get dateDelete;@JsonKey(includeIfNull: false) String? get autoType;@JsonKey(includeIfNull: false) String? get createdBy;@JsonKey(includeIfNull: false) String? get updatedBy;@JsonKey(includeIfNull: false) String? get deletedBy;@JsonKey(includeIfNull: false) Map<String, dynamic>? get prefs;@JsonKey(includeIfNull: false) List<String>? get users;@JsonKey(includeIfNull: false) int? get userCount;
/// Create a copy of SlackMessageGroupEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SlackMessageGroupEntityCopyWith<SlackMessageGroupEntity> get copyWith => _$SlackMessageGroupEntityCopyWithImpl<SlackMessageGroupEntity>(this as SlackMessageGroupEntity, _$identity);

  /// Serializes this SlackMessageGroupEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SlackMessageGroupEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.teamId, teamId) || other.teamId == teamId)&&(identical(other.isUsergroup, isUsergroup) || other.isUsergroup == isUsergroup)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.handle, handle) || other.handle == handle)&&(identical(other.isExternal, isExternal) || other.isExternal == isExternal)&&(identical(other.dateCreate, dateCreate) || other.dateCreate == dateCreate)&&(identical(other.dateUpdate, dateUpdate) || other.dateUpdate == dateUpdate)&&(identical(other.dateDelete, dateDelete) || other.dateDelete == dateDelete)&&(identical(other.autoType, autoType) || other.autoType == autoType)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.updatedBy, updatedBy) || other.updatedBy == updatedBy)&&(identical(other.deletedBy, deletedBy) || other.deletedBy == deletedBy)&&const DeepCollectionEquality().equals(other.prefs, prefs)&&const DeepCollectionEquality().equals(other.users, users)&&(identical(other.userCount, userCount) || other.userCount == userCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,teamId,isUsergroup,name,description,handle,isExternal,dateCreate,dateUpdate,dateDelete,autoType,createdBy,updatedBy,deletedBy,const DeepCollectionEquality().hash(prefs),const DeepCollectionEquality().hash(users),userCount);

@override
String toString() {
  return 'SlackMessageGroupEntity(id: $id, teamId: $teamId, isUsergroup: $isUsergroup, name: $name, description: $description, handle: $handle, isExternal: $isExternal, dateCreate: $dateCreate, dateUpdate: $dateUpdate, dateDelete: $dateDelete, autoType: $autoType, createdBy: $createdBy, updatedBy: $updatedBy, deletedBy: $deletedBy, prefs: $prefs, users: $users, userCount: $userCount)';
}


}

/// @nodoc
abstract mixin class $SlackMessageGroupEntityCopyWith<$Res>  {
  factory $SlackMessageGroupEntityCopyWith(SlackMessageGroupEntity value, $Res Function(SlackMessageGroupEntity) _then) = _$SlackMessageGroupEntityCopyWithImpl;
@useResult
$Res call({
@JsonKey(includeIfNull: false) String? id,@JsonKey(includeIfNull: false) String? teamId,@JsonKey(includeIfNull: false) bool? isUsergroup,@JsonKey(includeIfNull: false) String? name,@JsonKey(includeIfNull: false) String? description,@JsonKey(includeIfNull: false) String? handle,@JsonKey(includeIfNull: false) bool? isExternal,@JsonKey(includeIfNull: false) int? dateCreate,@JsonKey(includeIfNull: false) int? dateUpdate,@JsonKey(includeIfNull: false) int? dateDelete,@JsonKey(includeIfNull: false) String? autoType,@JsonKey(includeIfNull: false) String? createdBy,@JsonKey(includeIfNull: false) String? updatedBy,@JsonKey(includeIfNull: false) String? deletedBy,@JsonKey(includeIfNull: false) Map<String, dynamic>? prefs,@JsonKey(includeIfNull: false) List<String>? users,@JsonKey(includeIfNull: false) int? userCount
});




}
/// @nodoc
class _$SlackMessageGroupEntityCopyWithImpl<$Res>
    implements $SlackMessageGroupEntityCopyWith<$Res> {
  _$SlackMessageGroupEntityCopyWithImpl(this._self, this._then);

  final SlackMessageGroupEntity _self;
  final $Res Function(SlackMessageGroupEntity) _then;

/// Create a copy of SlackMessageGroupEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? teamId = freezed,Object? isUsergroup = freezed,Object? name = freezed,Object? description = freezed,Object? handle = freezed,Object? isExternal = freezed,Object? dateCreate = freezed,Object? dateUpdate = freezed,Object? dateDelete = freezed,Object? autoType = freezed,Object? createdBy = freezed,Object? updatedBy = freezed,Object? deletedBy = freezed,Object? prefs = freezed,Object? users = freezed,Object? userCount = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,teamId: freezed == teamId ? _self.teamId : teamId // ignore: cast_nullable_to_non_nullable
as String?,isUsergroup: freezed == isUsergroup ? _self.isUsergroup : isUsergroup // ignore: cast_nullable_to_non_nullable
as bool?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,handle: freezed == handle ? _self.handle : handle // ignore: cast_nullable_to_non_nullable
as String?,isExternal: freezed == isExternal ? _self.isExternal : isExternal // ignore: cast_nullable_to_non_nullable
as bool?,dateCreate: freezed == dateCreate ? _self.dateCreate : dateCreate // ignore: cast_nullable_to_non_nullable
as int?,dateUpdate: freezed == dateUpdate ? _self.dateUpdate : dateUpdate // ignore: cast_nullable_to_non_nullable
as int?,dateDelete: freezed == dateDelete ? _self.dateDelete : dateDelete // ignore: cast_nullable_to_non_nullable
as int?,autoType: freezed == autoType ? _self.autoType : autoType // ignore: cast_nullable_to_non_nullable
as String?,createdBy: freezed == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String?,updatedBy: freezed == updatedBy ? _self.updatedBy : updatedBy // ignore: cast_nullable_to_non_nullable
as String?,deletedBy: freezed == deletedBy ? _self.deletedBy : deletedBy // ignore: cast_nullable_to_non_nullable
as String?,prefs: freezed == prefs ? _self.prefs : prefs // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,users: freezed == users ? _self.users : users // ignore: cast_nullable_to_non_nullable
as List<String>?,userCount: freezed == userCount ? _self.userCount : userCount // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [SlackMessageGroupEntity].
extension SlackMessageGroupEntityPatterns on SlackMessageGroupEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SlackMessageGroupEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SlackMessageGroupEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SlackMessageGroupEntity value)  $default,){
final _that = this;
switch (_that) {
case _SlackMessageGroupEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SlackMessageGroupEntity value)?  $default,){
final _that = this;
switch (_that) {
case _SlackMessageGroupEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(includeIfNull: false)  String? id, @JsonKey(includeIfNull: false)  String? teamId, @JsonKey(includeIfNull: false)  bool? isUsergroup, @JsonKey(includeIfNull: false)  String? name, @JsonKey(includeIfNull: false)  String? description, @JsonKey(includeIfNull: false)  String? handle, @JsonKey(includeIfNull: false)  bool? isExternal, @JsonKey(includeIfNull: false)  int? dateCreate, @JsonKey(includeIfNull: false)  int? dateUpdate, @JsonKey(includeIfNull: false)  int? dateDelete, @JsonKey(includeIfNull: false)  String? autoType, @JsonKey(includeIfNull: false)  String? createdBy, @JsonKey(includeIfNull: false)  String? updatedBy, @JsonKey(includeIfNull: false)  String? deletedBy, @JsonKey(includeIfNull: false)  Map<String, dynamic>? prefs, @JsonKey(includeIfNull: false)  List<String>? users, @JsonKey(includeIfNull: false)  int? userCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SlackMessageGroupEntity() when $default != null:
return $default(_that.id,_that.teamId,_that.isUsergroup,_that.name,_that.description,_that.handle,_that.isExternal,_that.dateCreate,_that.dateUpdate,_that.dateDelete,_that.autoType,_that.createdBy,_that.updatedBy,_that.deletedBy,_that.prefs,_that.users,_that.userCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(includeIfNull: false)  String? id, @JsonKey(includeIfNull: false)  String? teamId, @JsonKey(includeIfNull: false)  bool? isUsergroup, @JsonKey(includeIfNull: false)  String? name, @JsonKey(includeIfNull: false)  String? description, @JsonKey(includeIfNull: false)  String? handle, @JsonKey(includeIfNull: false)  bool? isExternal, @JsonKey(includeIfNull: false)  int? dateCreate, @JsonKey(includeIfNull: false)  int? dateUpdate, @JsonKey(includeIfNull: false)  int? dateDelete, @JsonKey(includeIfNull: false)  String? autoType, @JsonKey(includeIfNull: false)  String? createdBy, @JsonKey(includeIfNull: false)  String? updatedBy, @JsonKey(includeIfNull: false)  String? deletedBy, @JsonKey(includeIfNull: false)  Map<String, dynamic>? prefs, @JsonKey(includeIfNull: false)  List<String>? users, @JsonKey(includeIfNull: false)  int? userCount)  $default,) {final _that = this;
switch (_that) {
case _SlackMessageGroupEntity():
return $default(_that.id,_that.teamId,_that.isUsergroup,_that.name,_that.description,_that.handle,_that.isExternal,_that.dateCreate,_that.dateUpdate,_that.dateDelete,_that.autoType,_that.createdBy,_that.updatedBy,_that.deletedBy,_that.prefs,_that.users,_that.userCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(includeIfNull: false)  String? id, @JsonKey(includeIfNull: false)  String? teamId, @JsonKey(includeIfNull: false)  bool? isUsergroup, @JsonKey(includeIfNull: false)  String? name, @JsonKey(includeIfNull: false)  String? description, @JsonKey(includeIfNull: false)  String? handle, @JsonKey(includeIfNull: false)  bool? isExternal, @JsonKey(includeIfNull: false)  int? dateCreate, @JsonKey(includeIfNull: false)  int? dateUpdate, @JsonKey(includeIfNull: false)  int? dateDelete, @JsonKey(includeIfNull: false)  String? autoType, @JsonKey(includeIfNull: false)  String? createdBy, @JsonKey(includeIfNull: false)  String? updatedBy, @JsonKey(includeIfNull: false)  String? deletedBy, @JsonKey(includeIfNull: false)  Map<String, dynamic>? prefs, @JsonKey(includeIfNull: false)  List<String>? users, @JsonKey(includeIfNull: false)  int? userCount)?  $default,) {final _that = this;
switch (_that) {
case _SlackMessageGroupEntity() when $default != null:
return $default(_that.id,_that.teamId,_that.isUsergroup,_that.name,_that.description,_that.handle,_that.isExternal,_that.dateCreate,_that.dateUpdate,_that.dateDelete,_that.autoType,_that.createdBy,_that.updatedBy,_that.deletedBy,_that.prefs,_that.users,_that.userCount);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _SlackMessageGroupEntity implements SlackMessageGroupEntity {
  const _SlackMessageGroupEntity({@JsonKey(includeIfNull: false) this.id, @JsonKey(includeIfNull: false) this.teamId, @JsonKey(includeIfNull: false) this.isUsergroup, @JsonKey(includeIfNull: false) this.name, @JsonKey(includeIfNull: false) this.description, @JsonKey(includeIfNull: false) this.handle, @JsonKey(includeIfNull: false) this.isExternal, @JsonKey(includeIfNull: false) this.dateCreate, @JsonKey(includeIfNull: false) this.dateUpdate, @JsonKey(includeIfNull: false) this.dateDelete, @JsonKey(includeIfNull: false) this.autoType, @JsonKey(includeIfNull: false) this.createdBy, @JsonKey(includeIfNull: false) this.updatedBy, @JsonKey(includeIfNull: false) this.deletedBy, @JsonKey(includeIfNull: false) final  Map<String, dynamic>? prefs, @JsonKey(includeIfNull: false) final  List<String>? users, @JsonKey(includeIfNull: false) this.userCount}): _prefs = prefs,_users = users;
  factory _SlackMessageGroupEntity.fromJson(Map<String, dynamic> json) => _$SlackMessageGroupEntityFromJson(json);

@override@JsonKey(includeIfNull: false) final  String? id;
@override@JsonKey(includeIfNull: false) final  String? teamId;
@override@JsonKey(includeIfNull: false) final  bool? isUsergroup;
@override@JsonKey(includeIfNull: false) final  String? name;
@override@JsonKey(includeIfNull: false) final  String? description;
@override@JsonKey(includeIfNull: false) final  String? handle;
@override@JsonKey(includeIfNull: false) final  bool? isExternal;
@override@JsonKey(includeIfNull: false) final  int? dateCreate;
@override@JsonKey(includeIfNull: false) final  int? dateUpdate;
@override@JsonKey(includeIfNull: false) final  int? dateDelete;
@override@JsonKey(includeIfNull: false) final  String? autoType;
@override@JsonKey(includeIfNull: false) final  String? createdBy;
@override@JsonKey(includeIfNull: false) final  String? updatedBy;
@override@JsonKey(includeIfNull: false) final  String? deletedBy;
 final  Map<String, dynamic>? _prefs;
@override@JsonKey(includeIfNull: false) Map<String, dynamic>? get prefs {
  final value = _prefs;
  if (value == null) return null;
  if (_prefs is EqualUnmodifiableMapView) return _prefs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  List<String>? _users;
@override@JsonKey(includeIfNull: false) List<String>? get users {
  final value = _users;
  if (value == null) return null;
  if (_users is EqualUnmodifiableListView) return _users;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override@JsonKey(includeIfNull: false) final  int? userCount;

/// Create a copy of SlackMessageGroupEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SlackMessageGroupEntityCopyWith<_SlackMessageGroupEntity> get copyWith => __$SlackMessageGroupEntityCopyWithImpl<_SlackMessageGroupEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SlackMessageGroupEntityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SlackMessageGroupEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.teamId, teamId) || other.teamId == teamId)&&(identical(other.isUsergroup, isUsergroup) || other.isUsergroup == isUsergroup)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.handle, handle) || other.handle == handle)&&(identical(other.isExternal, isExternal) || other.isExternal == isExternal)&&(identical(other.dateCreate, dateCreate) || other.dateCreate == dateCreate)&&(identical(other.dateUpdate, dateUpdate) || other.dateUpdate == dateUpdate)&&(identical(other.dateDelete, dateDelete) || other.dateDelete == dateDelete)&&(identical(other.autoType, autoType) || other.autoType == autoType)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.updatedBy, updatedBy) || other.updatedBy == updatedBy)&&(identical(other.deletedBy, deletedBy) || other.deletedBy == deletedBy)&&const DeepCollectionEquality().equals(other._prefs, _prefs)&&const DeepCollectionEquality().equals(other._users, _users)&&(identical(other.userCount, userCount) || other.userCount == userCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,teamId,isUsergroup,name,description,handle,isExternal,dateCreate,dateUpdate,dateDelete,autoType,createdBy,updatedBy,deletedBy,const DeepCollectionEquality().hash(_prefs),const DeepCollectionEquality().hash(_users),userCount);

@override
String toString() {
  return 'SlackMessageGroupEntity(id: $id, teamId: $teamId, isUsergroup: $isUsergroup, name: $name, description: $description, handle: $handle, isExternal: $isExternal, dateCreate: $dateCreate, dateUpdate: $dateUpdate, dateDelete: $dateDelete, autoType: $autoType, createdBy: $createdBy, updatedBy: $updatedBy, deletedBy: $deletedBy, prefs: $prefs, users: $users, userCount: $userCount)';
}


}

/// @nodoc
abstract mixin class _$SlackMessageGroupEntityCopyWith<$Res> implements $SlackMessageGroupEntityCopyWith<$Res> {
  factory _$SlackMessageGroupEntityCopyWith(_SlackMessageGroupEntity value, $Res Function(_SlackMessageGroupEntity) _then) = __$SlackMessageGroupEntityCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(includeIfNull: false) String? id,@JsonKey(includeIfNull: false) String? teamId,@JsonKey(includeIfNull: false) bool? isUsergroup,@JsonKey(includeIfNull: false) String? name,@JsonKey(includeIfNull: false) String? description,@JsonKey(includeIfNull: false) String? handle,@JsonKey(includeIfNull: false) bool? isExternal,@JsonKey(includeIfNull: false) int? dateCreate,@JsonKey(includeIfNull: false) int? dateUpdate,@JsonKey(includeIfNull: false) int? dateDelete,@JsonKey(includeIfNull: false) String? autoType,@JsonKey(includeIfNull: false) String? createdBy,@JsonKey(includeIfNull: false) String? updatedBy,@JsonKey(includeIfNull: false) String? deletedBy,@JsonKey(includeIfNull: false) Map<String, dynamic>? prefs,@JsonKey(includeIfNull: false) List<String>? users,@JsonKey(includeIfNull: false) int? userCount
});




}
/// @nodoc
class __$SlackMessageGroupEntityCopyWithImpl<$Res>
    implements _$SlackMessageGroupEntityCopyWith<$Res> {
  __$SlackMessageGroupEntityCopyWithImpl(this._self, this._then);

  final _SlackMessageGroupEntity _self;
  final $Res Function(_SlackMessageGroupEntity) _then;

/// Create a copy of SlackMessageGroupEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? teamId = freezed,Object? isUsergroup = freezed,Object? name = freezed,Object? description = freezed,Object? handle = freezed,Object? isExternal = freezed,Object? dateCreate = freezed,Object? dateUpdate = freezed,Object? dateDelete = freezed,Object? autoType = freezed,Object? createdBy = freezed,Object? updatedBy = freezed,Object? deletedBy = freezed,Object? prefs = freezed,Object? users = freezed,Object? userCount = freezed,}) {
  return _then(_SlackMessageGroupEntity(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,teamId: freezed == teamId ? _self.teamId : teamId // ignore: cast_nullable_to_non_nullable
as String?,isUsergroup: freezed == isUsergroup ? _self.isUsergroup : isUsergroup // ignore: cast_nullable_to_non_nullable
as bool?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,handle: freezed == handle ? _self.handle : handle // ignore: cast_nullable_to_non_nullable
as String?,isExternal: freezed == isExternal ? _self.isExternal : isExternal // ignore: cast_nullable_to_non_nullable
as bool?,dateCreate: freezed == dateCreate ? _self.dateCreate : dateCreate // ignore: cast_nullable_to_non_nullable
as int?,dateUpdate: freezed == dateUpdate ? _self.dateUpdate : dateUpdate // ignore: cast_nullable_to_non_nullable
as int?,dateDelete: freezed == dateDelete ? _self.dateDelete : dateDelete // ignore: cast_nullable_to_non_nullable
as int?,autoType: freezed == autoType ? _self.autoType : autoType // ignore: cast_nullable_to_non_nullable
as String?,createdBy: freezed == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String?,updatedBy: freezed == updatedBy ? _self.updatedBy : updatedBy // ignore: cast_nullable_to_non_nullable
as String?,deletedBy: freezed == deletedBy ? _self.deletedBy : deletedBy // ignore: cast_nullable_to_non_nullable
as String?,prefs: freezed == prefs ? _self._prefs : prefs // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,users: freezed == users ? _self._users : users // ignore: cast_nullable_to_non_nullable
as List<String>?,userCount: freezed == userCount ? _self.userCount : userCount // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
