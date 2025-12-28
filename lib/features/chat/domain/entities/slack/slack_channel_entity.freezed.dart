// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'slack_channel_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SlackMessageChannelEntity {

@JsonKey(includeIfNull: false) String? get teamId;//https://api.slack.com/types/channel
@JsonKey(includeIfNull: false) String? get id;@JsonKey(includeIfNull: false) String? get name;@JsonKey(includeIfNull: false) bool? get isChannel;@JsonKey(includeIfNull: false) int? get created;@JsonKey(includeIfNull: false) String? get creator;@JsonKey(includeIfNull: false) bool? get isArchived;@JsonKey(includeIfNull: false) bool? get isGeneral;@JsonKey(includeIfNull: false) String? get nameNormalized;@JsonKey(includeIfNull: false) bool? get isShared;@JsonKey(includeIfNull: false) bool? get isOrgShared;@JsonKey(includeIfNull: false) bool? get isMember;@JsonKey(includeIfNull: false) bool? get isPrivate;@JsonKey(includeIfNull: false) bool? get isMpim;@JsonKey(includeIfNull: false) String? get lastRead;@JsonKey(includeIfNull: false) DateTime? get lastUpdated;@JsonKey(includeIfNull: false) int? get unreadCount;@JsonKey(includeIfNull: false) int? get unreadCountDisplay;@JsonKey(includeIfNull: false) List<String>? get members;@JsonKey(includeIfNull: false) Map<String, dynamic>? get topic;@JsonKey(includeIfNull: false) Map<String, dynamic>? get purpose;@JsonKey(includeIfNull: false) List<String>? get previousNames;//https://api.slack.com/types/group
@JsonKey(includeIfNull: false) bool? get isGroup;//https://api.slack.com/types/im
@JsonKey(includeIfNull: false) bool? get isIm;@JsonKey(includeIfNull: false) String? get user;@JsonKey(includeIfNull: false) bool? get isUserDeleted;//https://api.slack.com/types/mpim
//위 네가지에는 없지만 repsonse에는 있는 parameter들
@JsonKey(includeIfNull: false) int? get updated;@JsonKey(includeIfNull: false) int? get unlinked;@JsonKey(includeIfNull: false) bool? get isPendingExtShared;@JsonKey(includeIfNull: false) String? get contextTeamId;@JsonKey(includeIfNull: false) double? get priority;@JsonKey(includeIfNull: false) bool? get isOpen;
/// Create a copy of SlackMessageChannelEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SlackMessageChannelEntityCopyWith<SlackMessageChannelEntity> get copyWith => _$SlackMessageChannelEntityCopyWithImpl<SlackMessageChannelEntity>(this as SlackMessageChannelEntity, _$identity);

  /// Serializes this SlackMessageChannelEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SlackMessageChannelEntity&&(identical(other.teamId, teamId) || other.teamId == teamId)&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.isChannel, isChannel) || other.isChannel == isChannel)&&(identical(other.created, created) || other.created == created)&&(identical(other.creator, creator) || other.creator == creator)&&(identical(other.isArchived, isArchived) || other.isArchived == isArchived)&&(identical(other.isGeneral, isGeneral) || other.isGeneral == isGeneral)&&(identical(other.nameNormalized, nameNormalized) || other.nameNormalized == nameNormalized)&&(identical(other.isShared, isShared) || other.isShared == isShared)&&(identical(other.isOrgShared, isOrgShared) || other.isOrgShared == isOrgShared)&&(identical(other.isMember, isMember) || other.isMember == isMember)&&(identical(other.isPrivate, isPrivate) || other.isPrivate == isPrivate)&&(identical(other.isMpim, isMpim) || other.isMpim == isMpim)&&(identical(other.lastRead, lastRead) || other.lastRead == lastRead)&&(identical(other.lastUpdated, lastUpdated) || other.lastUpdated == lastUpdated)&&(identical(other.unreadCount, unreadCount) || other.unreadCount == unreadCount)&&(identical(other.unreadCountDisplay, unreadCountDisplay) || other.unreadCountDisplay == unreadCountDisplay)&&const DeepCollectionEquality().equals(other.members, members)&&const DeepCollectionEquality().equals(other.topic, topic)&&const DeepCollectionEquality().equals(other.purpose, purpose)&&const DeepCollectionEquality().equals(other.previousNames, previousNames)&&(identical(other.isGroup, isGroup) || other.isGroup == isGroup)&&(identical(other.isIm, isIm) || other.isIm == isIm)&&(identical(other.user, user) || other.user == user)&&(identical(other.isUserDeleted, isUserDeleted) || other.isUserDeleted == isUserDeleted)&&(identical(other.updated, updated) || other.updated == updated)&&(identical(other.unlinked, unlinked) || other.unlinked == unlinked)&&(identical(other.isPendingExtShared, isPendingExtShared) || other.isPendingExtShared == isPendingExtShared)&&(identical(other.contextTeamId, contextTeamId) || other.contextTeamId == contextTeamId)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.isOpen, isOpen) || other.isOpen == isOpen));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,teamId,id,name,isChannel,created,creator,isArchived,isGeneral,nameNormalized,isShared,isOrgShared,isMember,isPrivate,isMpim,lastRead,lastUpdated,unreadCount,unreadCountDisplay,const DeepCollectionEquality().hash(members),const DeepCollectionEquality().hash(topic),const DeepCollectionEquality().hash(purpose),const DeepCollectionEquality().hash(previousNames),isGroup,isIm,user,isUserDeleted,updated,unlinked,isPendingExtShared,contextTeamId,priority,isOpen]);

@override
String toString() {
  return 'SlackMessageChannelEntity(teamId: $teamId, id: $id, name: $name, isChannel: $isChannel, created: $created, creator: $creator, isArchived: $isArchived, isGeneral: $isGeneral, nameNormalized: $nameNormalized, isShared: $isShared, isOrgShared: $isOrgShared, isMember: $isMember, isPrivate: $isPrivate, isMpim: $isMpim, lastRead: $lastRead, lastUpdated: $lastUpdated, unreadCount: $unreadCount, unreadCountDisplay: $unreadCountDisplay, members: $members, topic: $topic, purpose: $purpose, previousNames: $previousNames, isGroup: $isGroup, isIm: $isIm, user: $user, isUserDeleted: $isUserDeleted, updated: $updated, unlinked: $unlinked, isPendingExtShared: $isPendingExtShared, contextTeamId: $contextTeamId, priority: $priority, isOpen: $isOpen)';
}


}

/// @nodoc
abstract mixin class $SlackMessageChannelEntityCopyWith<$Res>  {
  factory $SlackMessageChannelEntityCopyWith(SlackMessageChannelEntity value, $Res Function(SlackMessageChannelEntity) _then) = _$SlackMessageChannelEntityCopyWithImpl;
@useResult
$Res call({
@JsonKey(includeIfNull: false) String? teamId,@JsonKey(includeIfNull: false) String? id,@JsonKey(includeIfNull: false) String? name,@JsonKey(includeIfNull: false) bool? isChannel,@JsonKey(includeIfNull: false) int? created,@JsonKey(includeIfNull: false) String? creator,@JsonKey(includeIfNull: false) bool? isArchived,@JsonKey(includeIfNull: false) bool? isGeneral,@JsonKey(includeIfNull: false) String? nameNormalized,@JsonKey(includeIfNull: false) bool? isShared,@JsonKey(includeIfNull: false) bool? isOrgShared,@JsonKey(includeIfNull: false) bool? isMember,@JsonKey(includeIfNull: false) bool? isPrivate,@JsonKey(includeIfNull: false) bool? isMpim,@JsonKey(includeIfNull: false) String? lastRead,@JsonKey(includeIfNull: false) DateTime? lastUpdated,@JsonKey(includeIfNull: false) int? unreadCount,@JsonKey(includeIfNull: false) int? unreadCountDisplay,@JsonKey(includeIfNull: false) List<String>? members,@JsonKey(includeIfNull: false) Map<String, dynamic>? topic,@JsonKey(includeIfNull: false) Map<String, dynamic>? purpose,@JsonKey(includeIfNull: false) List<String>? previousNames,@JsonKey(includeIfNull: false) bool? isGroup,@JsonKey(includeIfNull: false) bool? isIm,@JsonKey(includeIfNull: false) String? user,@JsonKey(includeIfNull: false) bool? isUserDeleted,@JsonKey(includeIfNull: false) int? updated,@JsonKey(includeIfNull: false) int? unlinked,@JsonKey(includeIfNull: false) bool? isPendingExtShared,@JsonKey(includeIfNull: false) String? contextTeamId,@JsonKey(includeIfNull: false) double? priority,@JsonKey(includeIfNull: false) bool? isOpen
});




}
/// @nodoc
class _$SlackMessageChannelEntityCopyWithImpl<$Res>
    implements $SlackMessageChannelEntityCopyWith<$Res> {
  _$SlackMessageChannelEntityCopyWithImpl(this._self, this._then);

  final SlackMessageChannelEntity _self;
  final $Res Function(SlackMessageChannelEntity) _then;

/// Create a copy of SlackMessageChannelEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? teamId = freezed,Object? id = freezed,Object? name = freezed,Object? isChannel = freezed,Object? created = freezed,Object? creator = freezed,Object? isArchived = freezed,Object? isGeneral = freezed,Object? nameNormalized = freezed,Object? isShared = freezed,Object? isOrgShared = freezed,Object? isMember = freezed,Object? isPrivate = freezed,Object? isMpim = freezed,Object? lastRead = freezed,Object? lastUpdated = freezed,Object? unreadCount = freezed,Object? unreadCountDisplay = freezed,Object? members = freezed,Object? topic = freezed,Object? purpose = freezed,Object? previousNames = freezed,Object? isGroup = freezed,Object? isIm = freezed,Object? user = freezed,Object? isUserDeleted = freezed,Object? updated = freezed,Object? unlinked = freezed,Object? isPendingExtShared = freezed,Object? contextTeamId = freezed,Object? priority = freezed,Object? isOpen = freezed,}) {
  return _then(_self.copyWith(
teamId: freezed == teamId ? _self.teamId : teamId // ignore: cast_nullable_to_non_nullable
as String?,id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,isChannel: freezed == isChannel ? _self.isChannel : isChannel // ignore: cast_nullable_to_non_nullable
as bool?,created: freezed == created ? _self.created : created // ignore: cast_nullable_to_non_nullable
as int?,creator: freezed == creator ? _self.creator : creator // ignore: cast_nullable_to_non_nullable
as String?,isArchived: freezed == isArchived ? _self.isArchived : isArchived // ignore: cast_nullable_to_non_nullable
as bool?,isGeneral: freezed == isGeneral ? _self.isGeneral : isGeneral // ignore: cast_nullable_to_non_nullable
as bool?,nameNormalized: freezed == nameNormalized ? _self.nameNormalized : nameNormalized // ignore: cast_nullable_to_non_nullable
as String?,isShared: freezed == isShared ? _self.isShared : isShared // ignore: cast_nullable_to_non_nullable
as bool?,isOrgShared: freezed == isOrgShared ? _self.isOrgShared : isOrgShared // ignore: cast_nullable_to_non_nullable
as bool?,isMember: freezed == isMember ? _self.isMember : isMember // ignore: cast_nullable_to_non_nullable
as bool?,isPrivate: freezed == isPrivate ? _self.isPrivate : isPrivate // ignore: cast_nullable_to_non_nullable
as bool?,isMpim: freezed == isMpim ? _self.isMpim : isMpim // ignore: cast_nullable_to_non_nullable
as bool?,lastRead: freezed == lastRead ? _self.lastRead : lastRead // ignore: cast_nullable_to_non_nullable
as String?,lastUpdated: freezed == lastUpdated ? _self.lastUpdated : lastUpdated // ignore: cast_nullable_to_non_nullable
as DateTime?,unreadCount: freezed == unreadCount ? _self.unreadCount : unreadCount // ignore: cast_nullable_to_non_nullable
as int?,unreadCountDisplay: freezed == unreadCountDisplay ? _self.unreadCountDisplay : unreadCountDisplay // ignore: cast_nullable_to_non_nullable
as int?,members: freezed == members ? _self.members : members // ignore: cast_nullable_to_non_nullable
as List<String>?,topic: freezed == topic ? _self.topic : topic // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,purpose: freezed == purpose ? _self.purpose : purpose // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,previousNames: freezed == previousNames ? _self.previousNames : previousNames // ignore: cast_nullable_to_non_nullable
as List<String>?,isGroup: freezed == isGroup ? _self.isGroup : isGroup // ignore: cast_nullable_to_non_nullable
as bool?,isIm: freezed == isIm ? _self.isIm : isIm // ignore: cast_nullable_to_non_nullable
as bool?,user: freezed == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as String?,isUserDeleted: freezed == isUserDeleted ? _self.isUserDeleted : isUserDeleted // ignore: cast_nullable_to_non_nullable
as bool?,updated: freezed == updated ? _self.updated : updated // ignore: cast_nullable_to_non_nullable
as int?,unlinked: freezed == unlinked ? _self.unlinked : unlinked // ignore: cast_nullable_to_non_nullable
as int?,isPendingExtShared: freezed == isPendingExtShared ? _self.isPendingExtShared : isPendingExtShared // ignore: cast_nullable_to_non_nullable
as bool?,contextTeamId: freezed == contextTeamId ? _self.contextTeamId : contextTeamId // ignore: cast_nullable_to_non_nullable
as String?,priority: freezed == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as double?,isOpen: freezed == isOpen ? _self.isOpen : isOpen // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}

}


/// Adds pattern-matching-related methods to [SlackMessageChannelEntity].
extension SlackMessageChannelEntityPatterns on SlackMessageChannelEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SlackMessageChannelEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SlackMessageChannelEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SlackMessageChannelEntity value)  $default,){
final _that = this;
switch (_that) {
case _SlackMessageChannelEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SlackMessageChannelEntity value)?  $default,){
final _that = this;
switch (_that) {
case _SlackMessageChannelEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(includeIfNull: false)  String? teamId, @JsonKey(includeIfNull: false)  String? id, @JsonKey(includeIfNull: false)  String? name, @JsonKey(includeIfNull: false)  bool? isChannel, @JsonKey(includeIfNull: false)  int? created, @JsonKey(includeIfNull: false)  String? creator, @JsonKey(includeIfNull: false)  bool? isArchived, @JsonKey(includeIfNull: false)  bool? isGeneral, @JsonKey(includeIfNull: false)  String? nameNormalized, @JsonKey(includeIfNull: false)  bool? isShared, @JsonKey(includeIfNull: false)  bool? isOrgShared, @JsonKey(includeIfNull: false)  bool? isMember, @JsonKey(includeIfNull: false)  bool? isPrivate, @JsonKey(includeIfNull: false)  bool? isMpim, @JsonKey(includeIfNull: false)  String? lastRead, @JsonKey(includeIfNull: false)  DateTime? lastUpdated, @JsonKey(includeIfNull: false)  int? unreadCount, @JsonKey(includeIfNull: false)  int? unreadCountDisplay, @JsonKey(includeIfNull: false)  List<String>? members, @JsonKey(includeIfNull: false)  Map<String, dynamic>? topic, @JsonKey(includeIfNull: false)  Map<String, dynamic>? purpose, @JsonKey(includeIfNull: false)  List<String>? previousNames, @JsonKey(includeIfNull: false)  bool? isGroup, @JsonKey(includeIfNull: false)  bool? isIm, @JsonKey(includeIfNull: false)  String? user, @JsonKey(includeIfNull: false)  bool? isUserDeleted, @JsonKey(includeIfNull: false)  int? updated, @JsonKey(includeIfNull: false)  int? unlinked, @JsonKey(includeIfNull: false)  bool? isPendingExtShared, @JsonKey(includeIfNull: false)  String? contextTeamId, @JsonKey(includeIfNull: false)  double? priority, @JsonKey(includeIfNull: false)  bool? isOpen)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SlackMessageChannelEntity() when $default != null:
return $default(_that.teamId,_that.id,_that.name,_that.isChannel,_that.created,_that.creator,_that.isArchived,_that.isGeneral,_that.nameNormalized,_that.isShared,_that.isOrgShared,_that.isMember,_that.isPrivate,_that.isMpim,_that.lastRead,_that.lastUpdated,_that.unreadCount,_that.unreadCountDisplay,_that.members,_that.topic,_that.purpose,_that.previousNames,_that.isGroup,_that.isIm,_that.user,_that.isUserDeleted,_that.updated,_that.unlinked,_that.isPendingExtShared,_that.contextTeamId,_that.priority,_that.isOpen);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(includeIfNull: false)  String? teamId, @JsonKey(includeIfNull: false)  String? id, @JsonKey(includeIfNull: false)  String? name, @JsonKey(includeIfNull: false)  bool? isChannel, @JsonKey(includeIfNull: false)  int? created, @JsonKey(includeIfNull: false)  String? creator, @JsonKey(includeIfNull: false)  bool? isArchived, @JsonKey(includeIfNull: false)  bool? isGeneral, @JsonKey(includeIfNull: false)  String? nameNormalized, @JsonKey(includeIfNull: false)  bool? isShared, @JsonKey(includeIfNull: false)  bool? isOrgShared, @JsonKey(includeIfNull: false)  bool? isMember, @JsonKey(includeIfNull: false)  bool? isPrivate, @JsonKey(includeIfNull: false)  bool? isMpim, @JsonKey(includeIfNull: false)  String? lastRead, @JsonKey(includeIfNull: false)  DateTime? lastUpdated, @JsonKey(includeIfNull: false)  int? unreadCount, @JsonKey(includeIfNull: false)  int? unreadCountDisplay, @JsonKey(includeIfNull: false)  List<String>? members, @JsonKey(includeIfNull: false)  Map<String, dynamic>? topic, @JsonKey(includeIfNull: false)  Map<String, dynamic>? purpose, @JsonKey(includeIfNull: false)  List<String>? previousNames, @JsonKey(includeIfNull: false)  bool? isGroup, @JsonKey(includeIfNull: false)  bool? isIm, @JsonKey(includeIfNull: false)  String? user, @JsonKey(includeIfNull: false)  bool? isUserDeleted, @JsonKey(includeIfNull: false)  int? updated, @JsonKey(includeIfNull: false)  int? unlinked, @JsonKey(includeIfNull: false)  bool? isPendingExtShared, @JsonKey(includeIfNull: false)  String? contextTeamId, @JsonKey(includeIfNull: false)  double? priority, @JsonKey(includeIfNull: false)  bool? isOpen)  $default,) {final _that = this;
switch (_that) {
case _SlackMessageChannelEntity():
return $default(_that.teamId,_that.id,_that.name,_that.isChannel,_that.created,_that.creator,_that.isArchived,_that.isGeneral,_that.nameNormalized,_that.isShared,_that.isOrgShared,_that.isMember,_that.isPrivate,_that.isMpim,_that.lastRead,_that.lastUpdated,_that.unreadCount,_that.unreadCountDisplay,_that.members,_that.topic,_that.purpose,_that.previousNames,_that.isGroup,_that.isIm,_that.user,_that.isUserDeleted,_that.updated,_that.unlinked,_that.isPendingExtShared,_that.contextTeamId,_that.priority,_that.isOpen);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(includeIfNull: false)  String? teamId, @JsonKey(includeIfNull: false)  String? id, @JsonKey(includeIfNull: false)  String? name, @JsonKey(includeIfNull: false)  bool? isChannel, @JsonKey(includeIfNull: false)  int? created, @JsonKey(includeIfNull: false)  String? creator, @JsonKey(includeIfNull: false)  bool? isArchived, @JsonKey(includeIfNull: false)  bool? isGeneral, @JsonKey(includeIfNull: false)  String? nameNormalized, @JsonKey(includeIfNull: false)  bool? isShared, @JsonKey(includeIfNull: false)  bool? isOrgShared, @JsonKey(includeIfNull: false)  bool? isMember, @JsonKey(includeIfNull: false)  bool? isPrivate, @JsonKey(includeIfNull: false)  bool? isMpim, @JsonKey(includeIfNull: false)  String? lastRead, @JsonKey(includeIfNull: false)  DateTime? lastUpdated, @JsonKey(includeIfNull: false)  int? unreadCount, @JsonKey(includeIfNull: false)  int? unreadCountDisplay, @JsonKey(includeIfNull: false)  List<String>? members, @JsonKey(includeIfNull: false)  Map<String, dynamic>? topic, @JsonKey(includeIfNull: false)  Map<String, dynamic>? purpose, @JsonKey(includeIfNull: false)  List<String>? previousNames, @JsonKey(includeIfNull: false)  bool? isGroup, @JsonKey(includeIfNull: false)  bool? isIm, @JsonKey(includeIfNull: false)  String? user, @JsonKey(includeIfNull: false)  bool? isUserDeleted, @JsonKey(includeIfNull: false)  int? updated, @JsonKey(includeIfNull: false)  int? unlinked, @JsonKey(includeIfNull: false)  bool? isPendingExtShared, @JsonKey(includeIfNull: false)  String? contextTeamId, @JsonKey(includeIfNull: false)  double? priority, @JsonKey(includeIfNull: false)  bool? isOpen)?  $default,) {final _that = this;
switch (_that) {
case _SlackMessageChannelEntity() when $default != null:
return $default(_that.teamId,_that.id,_that.name,_that.isChannel,_that.created,_that.creator,_that.isArchived,_that.isGeneral,_that.nameNormalized,_that.isShared,_that.isOrgShared,_that.isMember,_that.isPrivate,_that.isMpim,_that.lastRead,_that.lastUpdated,_that.unreadCount,_that.unreadCountDisplay,_that.members,_that.topic,_that.purpose,_that.previousNames,_that.isGroup,_that.isIm,_that.user,_that.isUserDeleted,_that.updated,_that.unlinked,_that.isPendingExtShared,_that.contextTeamId,_that.priority,_that.isOpen);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _SlackMessageChannelEntity implements SlackMessageChannelEntity {
  const _SlackMessageChannelEntity({@JsonKey(includeIfNull: false) this.teamId, @JsonKey(includeIfNull: false) this.id, @JsonKey(includeIfNull: false) this.name, @JsonKey(includeIfNull: false) this.isChannel, @JsonKey(includeIfNull: false) this.created, @JsonKey(includeIfNull: false) this.creator, @JsonKey(includeIfNull: false) this.isArchived, @JsonKey(includeIfNull: false) this.isGeneral, @JsonKey(includeIfNull: false) this.nameNormalized, @JsonKey(includeIfNull: false) this.isShared, @JsonKey(includeIfNull: false) this.isOrgShared, @JsonKey(includeIfNull: false) this.isMember, @JsonKey(includeIfNull: false) this.isPrivate, @JsonKey(includeIfNull: false) this.isMpim, @JsonKey(includeIfNull: false) this.lastRead, @JsonKey(includeIfNull: false) this.lastUpdated, @JsonKey(includeIfNull: false) this.unreadCount, @JsonKey(includeIfNull: false) this.unreadCountDisplay, @JsonKey(includeIfNull: false) final  List<String>? members, @JsonKey(includeIfNull: false) final  Map<String, dynamic>? topic, @JsonKey(includeIfNull: false) final  Map<String, dynamic>? purpose, @JsonKey(includeIfNull: false) final  List<String>? previousNames, @JsonKey(includeIfNull: false) this.isGroup, @JsonKey(includeIfNull: false) this.isIm, @JsonKey(includeIfNull: false) this.user, @JsonKey(includeIfNull: false) this.isUserDeleted, @JsonKey(includeIfNull: false) this.updated, @JsonKey(includeIfNull: false) this.unlinked, @JsonKey(includeIfNull: false) this.isPendingExtShared, @JsonKey(includeIfNull: false) this.contextTeamId, @JsonKey(includeIfNull: false) this.priority, @JsonKey(includeIfNull: false) this.isOpen}): _members = members,_topic = topic,_purpose = purpose,_previousNames = previousNames;
  factory _SlackMessageChannelEntity.fromJson(Map<String, dynamic> json) => _$SlackMessageChannelEntityFromJson(json);

@override@JsonKey(includeIfNull: false) final  String? teamId;
//https://api.slack.com/types/channel
@override@JsonKey(includeIfNull: false) final  String? id;
@override@JsonKey(includeIfNull: false) final  String? name;
@override@JsonKey(includeIfNull: false) final  bool? isChannel;
@override@JsonKey(includeIfNull: false) final  int? created;
@override@JsonKey(includeIfNull: false) final  String? creator;
@override@JsonKey(includeIfNull: false) final  bool? isArchived;
@override@JsonKey(includeIfNull: false) final  bool? isGeneral;
@override@JsonKey(includeIfNull: false) final  String? nameNormalized;
@override@JsonKey(includeIfNull: false) final  bool? isShared;
@override@JsonKey(includeIfNull: false) final  bool? isOrgShared;
@override@JsonKey(includeIfNull: false) final  bool? isMember;
@override@JsonKey(includeIfNull: false) final  bool? isPrivate;
@override@JsonKey(includeIfNull: false) final  bool? isMpim;
@override@JsonKey(includeIfNull: false) final  String? lastRead;
@override@JsonKey(includeIfNull: false) final  DateTime? lastUpdated;
@override@JsonKey(includeIfNull: false) final  int? unreadCount;
@override@JsonKey(includeIfNull: false) final  int? unreadCountDisplay;
 final  List<String>? _members;
@override@JsonKey(includeIfNull: false) List<String>? get members {
  final value = _members;
  if (value == null) return null;
  if (_members is EqualUnmodifiableListView) return _members;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  Map<String, dynamic>? _topic;
@override@JsonKey(includeIfNull: false) Map<String, dynamic>? get topic {
  final value = _topic;
  if (value == null) return null;
  if (_topic is EqualUnmodifiableMapView) return _topic;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  Map<String, dynamic>? _purpose;
@override@JsonKey(includeIfNull: false) Map<String, dynamic>? get purpose {
  final value = _purpose;
  if (value == null) return null;
  if (_purpose is EqualUnmodifiableMapView) return _purpose;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  List<String>? _previousNames;
@override@JsonKey(includeIfNull: false) List<String>? get previousNames {
  final value = _previousNames;
  if (value == null) return null;
  if (_previousNames is EqualUnmodifiableListView) return _previousNames;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

//https://api.slack.com/types/group
@override@JsonKey(includeIfNull: false) final  bool? isGroup;
//https://api.slack.com/types/im
@override@JsonKey(includeIfNull: false) final  bool? isIm;
@override@JsonKey(includeIfNull: false) final  String? user;
@override@JsonKey(includeIfNull: false) final  bool? isUserDeleted;
//https://api.slack.com/types/mpim
//위 네가지에는 없지만 repsonse에는 있는 parameter들
@override@JsonKey(includeIfNull: false) final  int? updated;
@override@JsonKey(includeIfNull: false) final  int? unlinked;
@override@JsonKey(includeIfNull: false) final  bool? isPendingExtShared;
@override@JsonKey(includeIfNull: false) final  String? contextTeamId;
@override@JsonKey(includeIfNull: false) final  double? priority;
@override@JsonKey(includeIfNull: false) final  bool? isOpen;

/// Create a copy of SlackMessageChannelEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SlackMessageChannelEntityCopyWith<_SlackMessageChannelEntity> get copyWith => __$SlackMessageChannelEntityCopyWithImpl<_SlackMessageChannelEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SlackMessageChannelEntityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SlackMessageChannelEntity&&(identical(other.teamId, teamId) || other.teamId == teamId)&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.isChannel, isChannel) || other.isChannel == isChannel)&&(identical(other.created, created) || other.created == created)&&(identical(other.creator, creator) || other.creator == creator)&&(identical(other.isArchived, isArchived) || other.isArchived == isArchived)&&(identical(other.isGeneral, isGeneral) || other.isGeneral == isGeneral)&&(identical(other.nameNormalized, nameNormalized) || other.nameNormalized == nameNormalized)&&(identical(other.isShared, isShared) || other.isShared == isShared)&&(identical(other.isOrgShared, isOrgShared) || other.isOrgShared == isOrgShared)&&(identical(other.isMember, isMember) || other.isMember == isMember)&&(identical(other.isPrivate, isPrivate) || other.isPrivate == isPrivate)&&(identical(other.isMpim, isMpim) || other.isMpim == isMpim)&&(identical(other.lastRead, lastRead) || other.lastRead == lastRead)&&(identical(other.lastUpdated, lastUpdated) || other.lastUpdated == lastUpdated)&&(identical(other.unreadCount, unreadCount) || other.unreadCount == unreadCount)&&(identical(other.unreadCountDisplay, unreadCountDisplay) || other.unreadCountDisplay == unreadCountDisplay)&&const DeepCollectionEquality().equals(other._members, _members)&&const DeepCollectionEquality().equals(other._topic, _topic)&&const DeepCollectionEquality().equals(other._purpose, _purpose)&&const DeepCollectionEquality().equals(other._previousNames, _previousNames)&&(identical(other.isGroup, isGroup) || other.isGroup == isGroup)&&(identical(other.isIm, isIm) || other.isIm == isIm)&&(identical(other.user, user) || other.user == user)&&(identical(other.isUserDeleted, isUserDeleted) || other.isUserDeleted == isUserDeleted)&&(identical(other.updated, updated) || other.updated == updated)&&(identical(other.unlinked, unlinked) || other.unlinked == unlinked)&&(identical(other.isPendingExtShared, isPendingExtShared) || other.isPendingExtShared == isPendingExtShared)&&(identical(other.contextTeamId, contextTeamId) || other.contextTeamId == contextTeamId)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.isOpen, isOpen) || other.isOpen == isOpen));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,teamId,id,name,isChannel,created,creator,isArchived,isGeneral,nameNormalized,isShared,isOrgShared,isMember,isPrivate,isMpim,lastRead,lastUpdated,unreadCount,unreadCountDisplay,const DeepCollectionEquality().hash(_members),const DeepCollectionEquality().hash(_topic),const DeepCollectionEquality().hash(_purpose),const DeepCollectionEquality().hash(_previousNames),isGroup,isIm,user,isUserDeleted,updated,unlinked,isPendingExtShared,contextTeamId,priority,isOpen]);

@override
String toString() {
  return 'SlackMessageChannelEntity(teamId: $teamId, id: $id, name: $name, isChannel: $isChannel, created: $created, creator: $creator, isArchived: $isArchived, isGeneral: $isGeneral, nameNormalized: $nameNormalized, isShared: $isShared, isOrgShared: $isOrgShared, isMember: $isMember, isPrivate: $isPrivate, isMpim: $isMpim, lastRead: $lastRead, lastUpdated: $lastUpdated, unreadCount: $unreadCount, unreadCountDisplay: $unreadCountDisplay, members: $members, topic: $topic, purpose: $purpose, previousNames: $previousNames, isGroup: $isGroup, isIm: $isIm, user: $user, isUserDeleted: $isUserDeleted, updated: $updated, unlinked: $unlinked, isPendingExtShared: $isPendingExtShared, contextTeamId: $contextTeamId, priority: $priority, isOpen: $isOpen)';
}


}

/// @nodoc
abstract mixin class _$SlackMessageChannelEntityCopyWith<$Res> implements $SlackMessageChannelEntityCopyWith<$Res> {
  factory _$SlackMessageChannelEntityCopyWith(_SlackMessageChannelEntity value, $Res Function(_SlackMessageChannelEntity) _then) = __$SlackMessageChannelEntityCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(includeIfNull: false) String? teamId,@JsonKey(includeIfNull: false) String? id,@JsonKey(includeIfNull: false) String? name,@JsonKey(includeIfNull: false) bool? isChannel,@JsonKey(includeIfNull: false) int? created,@JsonKey(includeIfNull: false) String? creator,@JsonKey(includeIfNull: false) bool? isArchived,@JsonKey(includeIfNull: false) bool? isGeneral,@JsonKey(includeIfNull: false) String? nameNormalized,@JsonKey(includeIfNull: false) bool? isShared,@JsonKey(includeIfNull: false) bool? isOrgShared,@JsonKey(includeIfNull: false) bool? isMember,@JsonKey(includeIfNull: false) bool? isPrivate,@JsonKey(includeIfNull: false) bool? isMpim,@JsonKey(includeIfNull: false) String? lastRead,@JsonKey(includeIfNull: false) DateTime? lastUpdated,@JsonKey(includeIfNull: false) int? unreadCount,@JsonKey(includeIfNull: false) int? unreadCountDisplay,@JsonKey(includeIfNull: false) List<String>? members,@JsonKey(includeIfNull: false) Map<String, dynamic>? topic,@JsonKey(includeIfNull: false) Map<String, dynamic>? purpose,@JsonKey(includeIfNull: false) List<String>? previousNames,@JsonKey(includeIfNull: false) bool? isGroup,@JsonKey(includeIfNull: false) bool? isIm,@JsonKey(includeIfNull: false) String? user,@JsonKey(includeIfNull: false) bool? isUserDeleted,@JsonKey(includeIfNull: false) int? updated,@JsonKey(includeIfNull: false) int? unlinked,@JsonKey(includeIfNull: false) bool? isPendingExtShared,@JsonKey(includeIfNull: false) String? contextTeamId,@JsonKey(includeIfNull: false) double? priority,@JsonKey(includeIfNull: false) bool? isOpen
});




}
/// @nodoc
class __$SlackMessageChannelEntityCopyWithImpl<$Res>
    implements _$SlackMessageChannelEntityCopyWith<$Res> {
  __$SlackMessageChannelEntityCopyWithImpl(this._self, this._then);

  final _SlackMessageChannelEntity _self;
  final $Res Function(_SlackMessageChannelEntity) _then;

/// Create a copy of SlackMessageChannelEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? teamId = freezed,Object? id = freezed,Object? name = freezed,Object? isChannel = freezed,Object? created = freezed,Object? creator = freezed,Object? isArchived = freezed,Object? isGeneral = freezed,Object? nameNormalized = freezed,Object? isShared = freezed,Object? isOrgShared = freezed,Object? isMember = freezed,Object? isPrivate = freezed,Object? isMpim = freezed,Object? lastRead = freezed,Object? lastUpdated = freezed,Object? unreadCount = freezed,Object? unreadCountDisplay = freezed,Object? members = freezed,Object? topic = freezed,Object? purpose = freezed,Object? previousNames = freezed,Object? isGroup = freezed,Object? isIm = freezed,Object? user = freezed,Object? isUserDeleted = freezed,Object? updated = freezed,Object? unlinked = freezed,Object? isPendingExtShared = freezed,Object? contextTeamId = freezed,Object? priority = freezed,Object? isOpen = freezed,}) {
  return _then(_SlackMessageChannelEntity(
teamId: freezed == teamId ? _self.teamId : teamId // ignore: cast_nullable_to_non_nullable
as String?,id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,isChannel: freezed == isChannel ? _self.isChannel : isChannel // ignore: cast_nullable_to_non_nullable
as bool?,created: freezed == created ? _self.created : created // ignore: cast_nullable_to_non_nullable
as int?,creator: freezed == creator ? _self.creator : creator // ignore: cast_nullable_to_non_nullable
as String?,isArchived: freezed == isArchived ? _self.isArchived : isArchived // ignore: cast_nullable_to_non_nullable
as bool?,isGeneral: freezed == isGeneral ? _self.isGeneral : isGeneral // ignore: cast_nullable_to_non_nullable
as bool?,nameNormalized: freezed == nameNormalized ? _self.nameNormalized : nameNormalized // ignore: cast_nullable_to_non_nullable
as String?,isShared: freezed == isShared ? _self.isShared : isShared // ignore: cast_nullable_to_non_nullable
as bool?,isOrgShared: freezed == isOrgShared ? _self.isOrgShared : isOrgShared // ignore: cast_nullable_to_non_nullable
as bool?,isMember: freezed == isMember ? _self.isMember : isMember // ignore: cast_nullable_to_non_nullable
as bool?,isPrivate: freezed == isPrivate ? _self.isPrivate : isPrivate // ignore: cast_nullable_to_non_nullable
as bool?,isMpim: freezed == isMpim ? _self.isMpim : isMpim // ignore: cast_nullable_to_non_nullable
as bool?,lastRead: freezed == lastRead ? _self.lastRead : lastRead // ignore: cast_nullable_to_non_nullable
as String?,lastUpdated: freezed == lastUpdated ? _self.lastUpdated : lastUpdated // ignore: cast_nullable_to_non_nullable
as DateTime?,unreadCount: freezed == unreadCount ? _self.unreadCount : unreadCount // ignore: cast_nullable_to_non_nullable
as int?,unreadCountDisplay: freezed == unreadCountDisplay ? _self.unreadCountDisplay : unreadCountDisplay // ignore: cast_nullable_to_non_nullable
as int?,members: freezed == members ? _self._members : members // ignore: cast_nullable_to_non_nullable
as List<String>?,topic: freezed == topic ? _self._topic : topic // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,purpose: freezed == purpose ? _self._purpose : purpose // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,previousNames: freezed == previousNames ? _self._previousNames : previousNames // ignore: cast_nullable_to_non_nullable
as List<String>?,isGroup: freezed == isGroup ? _self.isGroup : isGroup // ignore: cast_nullable_to_non_nullable
as bool?,isIm: freezed == isIm ? _self.isIm : isIm // ignore: cast_nullable_to_non_nullable
as bool?,user: freezed == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as String?,isUserDeleted: freezed == isUserDeleted ? _self.isUserDeleted : isUserDeleted // ignore: cast_nullable_to_non_nullable
as bool?,updated: freezed == updated ? _self.updated : updated // ignore: cast_nullable_to_non_nullable
as int?,unlinked: freezed == unlinked ? _self.unlinked : unlinked // ignore: cast_nullable_to_non_nullable
as int?,isPendingExtShared: freezed == isPendingExtShared ? _self.isPendingExtShared : isPendingExtShared // ignore: cast_nullable_to_non_nullable
as bool?,contextTeamId: freezed == contextTeamId ? _self.contextTeamId : contextTeamId // ignore: cast_nullable_to_non_nullable
as String?,priority: freezed == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as double?,isOpen: freezed == isOpen ? _self.isOpen : isOpen // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}


}

// dart format on
