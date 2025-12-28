// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ai_api_usage_log_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AiApiUsageLogEntity {

 String get id; String get userId; String get apiProvider;// 'openai', 'google', 'anthropic'
 String get model; String get functionName; int get promptTokens; int get completionTokens; int get totalTokens; double get creditsUsed; bool get usedUserApiKey; DateTime get createdAt;
/// Create a copy of AiApiUsageLogEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AiApiUsageLogEntityCopyWith<AiApiUsageLogEntity> get copyWith => _$AiApiUsageLogEntityCopyWithImpl<AiApiUsageLogEntity>(this as AiApiUsageLogEntity, _$identity);

  /// Serializes this AiApiUsageLogEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AiApiUsageLogEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.apiProvider, apiProvider) || other.apiProvider == apiProvider)&&(identical(other.model, model) || other.model == model)&&(identical(other.functionName, functionName) || other.functionName == functionName)&&(identical(other.promptTokens, promptTokens) || other.promptTokens == promptTokens)&&(identical(other.completionTokens, completionTokens) || other.completionTokens == completionTokens)&&(identical(other.totalTokens, totalTokens) || other.totalTokens == totalTokens)&&(identical(other.creditsUsed, creditsUsed) || other.creditsUsed == creditsUsed)&&(identical(other.usedUserApiKey, usedUserApiKey) || other.usedUserApiKey == usedUserApiKey)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,apiProvider,model,functionName,promptTokens,completionTokens,totalTokens,creditsUsed,usedUserApiKey,createdAt);

@override
String toString() {
  return 'AiApiUsageLogEntity(id: $id, userId: $userId, apiProvider: $apiProvider, model: $model, functionName: $functionName, promptTokens: $promptTokens, completionTokens: $completionTokens, totalTokens: $totalTokens, creditsUsed: $creditsUsed, usedUserApiKey: $usedUserApiKey, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $AiApiUsageLogEntityCopyWith<$Res>  {
  factory $AiApiUsageLogEntityCopyWith(AiApiUsageLogEntity value, $Res Function(AiApiUsageLogEntity) _then) = _$AiApiUsageLogEntityCopyWithImpl;
@useResult
$Res call({
 String id, String userId, String apiProvider, String model, String functionName, int promptTokens, int completionTokens, int totalTokens, double creditsUsed, bool usedUserApiKey, DateTime createdAt
});




}
/// @nodoc
class _$AiApiUsageLogEntityCopyWithImpl<$Res>
    implements $AiApiUsageLogEntityCopyWith<$Res> {
  _$AiApiUsageLogEntityCopyWithImpl(this._self, this._then);

  final AiApiUsageLogEntity _self;
  final $Res Function(AiApiUsageLogEntity) _then;

/// Create a copy of AiApiUsageLogEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? apiProvider = null,Object? model = null,Object? functionName = null,Object? promptTokens = null,Object? completionTokens = null,Object? totalTokens = null,Object? creditsUsed = null,Object? usedUserApiKey = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,apiProvider: null == apiProvider ? _self.apiProvider : apiProvider // ignore: cast_nullable_to_non_nullable
as String,model: null == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String,functionName: null == functionName ? _self.functionName : functionName // ignore: cast_nullable_to_non_nullable
as String,promptTokens: null == promptTokens ? _self.promptTokens : promptTokens // ignore: cast_nullable_to_non_nullable
as int,completionTokens: null == completionTokens ? _self.completionTokens : completionTokens // ignore: cast_nullable_to_non_nullable
as int,totalTokens: null == totalTokens ? _self.totalTokens : totalTokens // ignore: cast_nullable_to_non_nullable
as int,creditsUsed: null == creditsUsed ? _self.creditsUsed : creditsUsed // ignore: cast_nullable_to_non_nullable
as double,usedUserApiKey: null == usedUserApiKey ? _self.usedUserApiKey : usedUserApiKey // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [AiApiUsageLogEntity].
extension AiApiUsageLogEntityPatterns on AiApiUsageLogEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AiApiUsageLogEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AiApiUsageLogEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AiApiUsageLogEntity value)  $default,){
final _that = this;
switch (_that) {
case _AiApiUsageLogEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AiApiUsageLogEntity value)?  $default,){
final _that = this;
switch (_that) {
case _AiApiUsageLogEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  String apiProvider,  String model,  String functionName,  int promptTokens,  int completionTokens,  int totalTokens,  double creditsUsed,  bool usedUserApiKey,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AiApiUsageLogEntity() when $default != null:
return $default(_that.id,_that.userId,_that.apiProvider,_that.model,_that.functionName,_that.promptTokens,_that.completionTokens,_that.totalTokens,_that.creditsUsed,_that.usedUserApiKey,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  String apiProvider,  String model,  String functionName,  int promptTokens,  int completionTokens,  int totalTokens,  double creditsUsed,  bool usedUserApiKey,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _AiApiUsageLogEntity():
return $default(_that.id,_that.userId,_that.apiProvider,_that.model,_that.functionName,_that.promptTokens,_that.completionTokens,_that.totalTokens,_that.creditsUsed,_that.usedUserApiKey,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  String apiProvider,  String model,  String functionName,  int promptTokens,  int completionTokens,  int totalTokens,  double creditsUsed,  bool usedUserApiKey,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _AiApiUsageLogEntity() when $default != null:
return $default(_that.id,_that.userId,_that.apiProvider,_that.model,_that.functionName,_that.promptTokens,_that.completionTokens,_that.totalTokens,_that.creditsUsed,_that.usedUserApiKey,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AiApiUsageLogEntity extends AiApiUsageLogEntity {
  const _AiApiUsageLogEntity({required this.id, required this.userId, required this.apiProvider, required this.model, required this.functionName, required this.promptTokens, required this.completionTokens, required this.totalTokens, required this.creditsUsed, this.usedUserApiKey = false, required this.createdAt}): super._();
  factory _AiApiUsageLogEntity.fromJson(Map<String, dynamic> json) => _$AiApiUsageLogEntityFromJson(json);

@override final  String id;
@override final  String userId;
@override final  String apiProvider;
// 'openai', 'google', 'anthropic'
@override final  String model;
@override final  String functionName;
@override final  int promptTokens;
@override final  int completionTokens;
@override final  int totalTokens;
@override final  double creditsUsed;
@override@JsonKey() final  bool usedUserApiKey;
@override final  DateTime createdAt;

/// Create a copy of AiApiUsageLogEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AiApiUsageLogEntityCopyWith<_AiApiUsageLogEntity> get copyWith => __$AiApiUsageLogEntityCopyWithImpl<_AiApiUsageLogEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AiApiUsageLogEntityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AiApiUsageLogEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.apiProvider, apiProvider) || other.apiProvider == apiProvider)&&(identical(other.model, model) || other.model == model)&&(identical(other.functionName, functionName) || other.functionName == functionName)&&(identical(other.promptTokens, promptTokens) || other.promptTokens == promptTokens)&&(identical(other.completionTokens, completionTokens) || other.completionTokens == completionTokens)&&(identical(other.totalTokens, totalTokens) || other.totalTokens == totalTokens)&&(identical(other.creditsUsed, creditsUsed) || other.creditsUsed == creditsUsed)&&(identical(other.usedUserApiKey, usedUserApiKey) || other.usedUserApiKey == usedUserApiKey)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,apiProvider,model,functionName,promptTokens,completionTokens,totalTokens,creditsUsed,usedUserApiKey,createdAt);

@override
String toString() {
  return 'AiApiUsageLogEntity(id: $id, userId: $userId, apiProvider: $apiProvider, model: $model, functionName: $functionName, promptTokens: $promptTokens, completionTokens: $completionTokens, totalTokens: $totalTokens, creditsUsed: $creditsUsed, usedUserApiKey: $usedUserApiKey, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$AiApiUsageLogEntityCopyWith<$Res> implements $AiApiUsageLogEntityCopyWith<$Res> {
  factory _$AiApiUsageLogEntityCopyWith(_AiApiUsageLogEntity value, $Res Function(_AiApiUsageLogEntity) _then) = __$AiApiUsageLogEntityCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, String apiProvider, String model, String functionName, int promptTokens, int completionTokens, int totalTokens, double creditsUsed, bool usedUserApiKey, DateTime createdAt
});




}
/// @nodoc
class __$AiApiUsageLogEntityCopyWithImpl<$Res>
    implements _$AiApiUsageLogEntityCopyWith<$Res> {
  __$AiApiUsageLogEntityCopyWithImpl(this._self, this._then);

  final _AiApiUsageLogEntity _self;
  final $Res Function(_AiApiUsageLogEntity) _then;

/// Create a copy of AiApiUsageLogEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? apiProvider = null,Object? model = null,Object? functionName = null,Object? promptTokens = null,Object? completionTokens = null,Object? totalTokens = null,Object? creditsUsed = null,Object? usedUserApiKey = null,Object? createdAt = null,}) {
  return _then(_AiApiUsageLogEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,apiProvider: null == apiProvider ? _self.apiProvider : apiProvider // ignore: cast_nullable_to_non_nullable
as String,model: null == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String,functionName: null == functionName ? _self.functionName : functionName // ignore: cast_nullable_to_non_nullable
as String,promptTokens: null == promptTokens ? _self.promptTokens : promptTokens // ignore: cast_nullable_to_non_nullable
as int,completionTokens: null == completionTokens ? _self.completionTokens : completionTokens // ignore: cast_nullable_to_non_nullable
as int,totalTokens: null == totalTokens ? _self.totalTokens : totalTokens // ignore: cast_nullable_to_non_nullable
as int,creditsUsed: null == creditsUsed ? _self.creditsUsed : creditsUsed // ignore: cast_nullable_to_non_nullable
as double,usedUserApiKey: null == usedUserApiKey ? _self.usedUserApiKey : usedUserApiKey // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
