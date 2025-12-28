// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'slack_message_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SlackMessageEntity {

@JsonKey(includeIfNull: false) String? get type;@JsonKey(includeIfNull: false) String? get user;@JsonKey(includeIfNull: false) String? get text;@JsonKey(includeIfNull: false) String? get team;@JsonKey(includeIfNull: false) String? get ts;@JsonKey(includeIfNull: false) String? get channel;@JsonKey(includeIfNull: false) SlackMessageEntitySubtype? get subtype;@JsonKey(includeIfNull: false) String? get deletedTs;@JsonKey(includeIfNull: false) String? get eventTs;@JsonKey(includeIfNull: false) String? get threadTs;@JsonKey(includeIfNull: false) String? get latestReply;@JsonKey(includeIfNull: false) int? get replyCount;@JsonKey(includeIfNull: false) int? get replyUsersCount;@JsonKey(includeIfNull: false) List<String>? get replyUsers;@JsonKey(includeIfNull: false) bool? get isStarred;@JsonKey(includeIfNull: false) bool? get hidden;@JsonKey(includeIfNull: false) bool? get isLocked;@JsonKey(includeIfNull: false) bool? get subscribed;@JsonKey(includeIfNull: false) List<String>? get pinnedTo;@JsonKey(includeIfNull: false) List<SlackMessageAttachmentEntity>? get attachments;@JsonKey(includeIfNull: false) Map<String, dynamic>? get edited;@JsonKey(includeIfNull: false) List<SlackMessageReactionEntity>? get reactions;@JsonKey(includeIfNull: false) String? get clientMsgId;@JsonKey(includeIfNull: false) String? get parentUserId;@JsonKey(includeIfNull: false) List<SlackMessageFileEntity>? get files;@JsonKey(includeIfNull: false) List<SlackMessageBlockEntity>? get blocks;@JsonKey(includeIfNull: false) String? get botId;//for local
@JsonKey(includeIfNull: false) bool? get isLocalTempMessage;@JsonKey(includeIfNull: false) String? get link;
/// Create a copy of SlackMessageEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SlackMessageEntityCopyWith<SlackMessageEntity> get copyWith => _$SlackMessageEntityCopyWithImpl<SlackMessageEntity>(this as SlackMessageEntity, _$identity);

  /// Serializes this SlackMessageEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SlackMessageEntity&&(identical(other.type, type) || other.type == type)&&(identical(other.user, user) || other.user == user)&&(identical(other.text, text) || other.text == text)&&(identical(other.team, team) || other.team == team)&&(identical(other.ts, ts) || other.ts == ts)&&(identical(other.channel, channel) || other.channel == channel)&&(identical(other.subtype, subtype) || other.subtype == subtype)&&(identical(other.deletedTs, deletedTs) || other.deletedTs == deletedTs)&&(identical(other.eventTs, eventTs) || other.eventTs == eventTs)&&(identical(other.threadTs, threadTs) || other.threadTs == threadTs)&&(identical(other.latestReply, latestReply) || other.latestReply == latestReply)&&(identical(other.replyCount, replyCount) || other.replyCount == replyCount)&&(identical(other.replyUsersCount, replyUsersCount) || other.replyUsersCount == replyUsersCount)&&const DeepCollectionEquality().equals(other.replyUsers, replyUsers)&&(identical(other.isStarred, isStarred) || other.isStarred == isStarred)&&(identical(other.hidden, hidden) || other.hidden == hidden)&&(identical(other.isLocked, isLocked) || other.isLocked == isLocked)&&(identical(other.subscribed, subscribed) || other.subscribed == subscribed)&&const DeepCollectionEquality().equals(other.pinnedTo, pinnedTo)&&const DeepCollectionEquality().equals(other.attachments, attachments)&&const DeepCollectionEquality().equals(other.edited, edited)&&const DeepCollectionEquality().equals(other.reactions, reactions)&&(identical(other.clientMsgId, clientMsgId) || other.clientMsgId == clientMsgId)&&(identical(other.parentUserId, parentUserId) || other.parentUserId == parentUserId)&&const DeepCollectionEquality().equals(other.files, files)&&const DeepCollectionEquality().equals(other.blocks, blocks)&&(identical(other.botId, botId) || other.botId == botId)&&(identical(other.isLocalTempMessage, isLocalTempMessage) || other.isLocalTempMessage == isLocalTempMessage)&&(identical(other.link, link) || other.link == link));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,type,user,text,team,ts,channel,subtype,deletedTs,eventTs,threadTs,latestReply,replyCount,replyUsersCount,const DeepCollectionEquality().hash(replyUsers),isStarred,hidden,isLocked,subscribed,const DeepCollectionEquality().hash(pinnedTo),const DeepCollectionEquality().hash(attachments),const DeepCollectionEquality().hash(edited),const DeepCollectionEquality().hash(reactions),clientMsgId,parentUserId,const DeepCollectionEquality().hash(files),const DeepCollectionEquality().hash(blocks),botId,isLocalTempMessage,link]);

@override
String toString() {
  return 'SlackMessageEntity(type: $type, user: $user, text: $text, team: $team, ts: $ts, channel: $channel, subtype: $subtype, deletedTs: $deletedTs, eventTs: $eventTs, threadTs: $threadTs, latestReply: $latestReply, replyCount: $replyCount, replyUsersCount: $replyUsersCount, replyUsers: $replyUsers, isStarred: $isStarred, hidden: $hidden, isLocked: $isLocked, subscribed: $subscribed, pinnedTo: $pinnedTo, attachments: $attachments, edited: $edited, reactions: $reactions, clientMsgId: $clientMsgId, parentUserId: $parentUserId, files: $files, blocks: $blocks, botId: $botId, isLocalTempMessage: $isLocalTempMessage, link: $link)';
}


}

/// @nodoc
abstract mixin class $SlackMessageEntityCopyWith<$Res>  {
  factory $SlackMessageEntityCopyWith(SlackMessageEntity value, $Res Function(SlackMessageEntity) _then) = _$SlackMessageEntityCopyWithImpl;
@useResult
$Res call({
@JsonKey(includeIfNull: false) String? type,@JsonKey(includeIfNull: false) String? user,@JsonKey(includeIfNull: false) String? text,@JsonKey(includeIfNull: false) String? team,@JsonKey(includeIfNull: false) String? ts,@JsonKey(includeIfNull: false) String? channel,@JsonKey(includeIfNull: false) SlackMessageEntitySubtype? subtype,@JsonKey(includeIfNull: false) String? deletedTs,@JsonKey(includeIfNull: false) String? eventTs,@JsonKey(includeIfNull: false) String? threadTs,@JsonKey(includeIfNull: false) String? latestReply,@JsonKey(includeIfNull: false) int? replyCount,@JsonKey(includeIfNull: false) int? replyUsersCount,@JsonKey(includeIfNull: false) List<String>? replyUsers,@JsonKey(includeIfNull: false) bool? isStarred,@JsonKey(includeIfNull: false) bool? hidden,@JsonKey(includeIfNull: false) bool? isLocked,@JsonKey(includeIfNull: false) bool? subscribed,@JsonKey(includeIfNull: false) List<String>? pinnedTo,@JsonKey(includeIfNull: false) List<SlackMessageAttachmentEntity>? attachments,@JsonKey(includeIfNull: false) Map<String, dynamic>? edited,@JsonKey(includeIfNull: false) List<SlackMessageReactionEntity>? reactions,@JsonKey(includeIfNull: false) String? clientMsgId,@JsonKey(includeIfNull: false) String? parentUserId,@JsonKey(includeIfNull: false) List<SlackMessageFileEntity>? files,@JsonKey(includeIfNull: false) List<SlackMessageBlockEntity>? blocks,@JsonKey(includeIfNull: false) String? botId,@JsonKey(includeIfNull: false) bool? isLocalTempMessage,@JsonKey(includeIfNull: false) String? link
});




}
/// @nodoc
class _$SlackMessageEntityCopyWithImpl<$Res>
    implements $SlackMessageEntityCopyWith<$Res> {
  _$SlackMessageEntityCopyWithImpl(this._self, this._then);

  final SlackMessageEntity _self;
  final $Res Function(SlackMessageEntity) _then;

/// Create a copy of SlackMessageEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = freezed,Object? user = freezed,Object? text = freezed,Object? team = freezed,Object? ts = freezed,Object? channel = freezed,Object? subtype = freezed,Object? deletedTs = freezed,Object? eventTs = freezed,Object? threadTs = freezed,Object? latestReply = freezed,Object? replyCount = freezed,Object? replyUsersCount = freezed,Object? replyUsers = freezed,Object? isStarred = freezed,Object? hidden = freezed,Object? isLocked = freezed,Object? subscribed = freezed,Object? pinnedTo = freezed,Object? attachments = freezed,Object? edited = freezed,Object? reactions = freezed,Object? clientMsgId = freezed,Object? parentUserId = freezed,Object? files = freezed,Object? blocks = freezed,Object? botId = freezed,Object? isLocalTempMessage = freezed,Object? link = freezed,}) {
  return _then(_self.copyWith(
type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String?,user: freezed == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as String?,text: freezed == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String?,team: freezed == team ? _self.team : team // ignore: cast_nullable_to_non_nullable
as String?,ts: freezed == ts ? _self.ts : ts // ignore: cast_nullable_to_non_nullable
as String?,channel: freezed == channel ? _self.channel : channel // ignore: cast_nullable_to_non_nullable
as String?,subtype: freezed == subtype ? _self.subtype : subtype // ignore: cast_nullable_to_non_nullable
as SlackMessageEntitySubtype?,deletedTs: freezed == deletedTs ? _self.deletedTs : deletedTs // ignore: cast_nullable_to_non_nullable
as String?,eventTs: freezed == eventTs ? _self.eventTs : eventTs // ignore: cast_nullable_to_non_nullable
as String?,threadTs: freezed == threadTs ? _self.threadTs : threadTs // ignore: cast_nullable_to_non_nullable
as String?,latestReply: freezed == latestReply ? _self.latestReply : latestReply // ignore: cast_nullable_to_non_nullable
as String?,replyCount: freezed == replyCount ? _self.replyCount : replyCount // ignore: cast_nullable_to_non_nullable
as int?,replyUsersCount: freezed == replyUsersCount ? _self.replyUsersCount : replyUsersCount // ignore: cast_nullable_to_non_nullable
as int?,replyUsers: freezed == replyUsers ? _self.replyUsers : replyUsers // ignore: cast_nullable_to_non_nullable
as List<String>?,isStarred: freezed == isStarred ? _self.isStarred : isStarred // ignore: cast_nullable_to_non_nullable
as bool?,hidden: freezed == hidden ? _self.hidden : hidden // ignore: cast_nullable_to_non_nullable
as bool?,isLocked: freezed == isLocked ? _self.isLocked : isLocked // ignore: cast_nullable_to_non_nullable
as bool?,subscribed: freezed == subscribed ? _self.subscribed : subscribed // ignore: cast_nullable_to_non_nullable
as bool?,pinnedTo: freezed == pinnedTo ? _self.pinnedTo : pinnedTo // ignore: cast_nullable_to_non_nullable
as List<String>?,attachments: freezed == attachments ? _self.attachments : attachments // ignore: cast_nullable_to_non_nullable
as List<SlackMessageAttachmentEntity>?,edited: freezed == edited ? _self.edited : edited // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,reactions: freezed == reactions ? _self.reactions : reactions // ignore: cast_nullable_to_non_nullable
as List<SlackMessageReactionEntity>?,clientMsgId: freezed == clientMsgId ? _self.clientMsgId : clientMsgId // ignore: cast_nullable_to_non_nullable
as String?,parentUserId: freezed == parentUserId ? _self.parentUserId : parentUserId // ignore: cast_nullable_to_non_nullable
as String?,files: freezed == files ? _self.files : files // ignore: cast_nullable_to_non_nullable
as List<SlackMessageFileEntity>?,blocks: freezed == blocks ? _self.blocks : blocks // ignore: cast_nullable_to_non_nullable
as List<SlackMessageBlockEntity>?,botId: freezed == botId ? _self.botId : botId // ignore: cast_nullable_to_non_nullable
as String?,isLocalTempMessage: freezed == isLocalTempMessage ? _self.isLocalTempMessage : isLocalTempMessage // ignore: cast_nullable_to_non_nullable
as bool?,link: freezed == link ? _self.link : link // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [SlackMessageEntity].
extension SlackMessageEntityPatterns on SlackMessageEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SlackMessageEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SlackMessageEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SlackMessageEntity value)  $default,){
final _that = this;
switch (_that) {
case _SlackMessageEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SlackMessageEntity value)?  $default,){
final _that = this;
switch (_that) {
case _SlackMessageEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(includeIfNull: false)  String? type, @JsonKey(includeIfNull: false)  String? user, @JsonKey(includeIfNull: false)  String? text, @JsonKey(includeIfNull: false)  String? team, @JsonKey(includeIfNull: false)  String? ts, @JsonKey(includeIfNull: false)  String? channel, @JsonKey(includeIfNull: false)  SlackMessageEntitySubtype? subtype, @JsonKey(includeIfNull: false)  String? deletedTs, @JsonKey(includeIfNull: false)  String? eventTs, @JsonKey(includeIfNull: false)  String? threadTs, @JsonKey(includeIfNull: false)  String? latestReply, @JsonKey(includeIfNull: false)  int? replyCount, @JsonKey(includeIfNull: false)  int? replyUsersCount, @JsonKey(includeIfNull: false)  List<String>? replyUsers, @JsonKey(includeIfNull: false)  bool? isStarred, @JsonKey(includeIfNull: false)  bool? hidden, @JsonKey(includeIfNull: false)  bool? isLocked, @JsonKey(includeIfNull: false)  bool? subscribed, @JsonKey(includeIfNull: false)  List<String>? pinnedTo, @JsonKey(includeIfNull: false)  List<SlackMessageAttachmentEntity>? attachments, @JsonKey(includeIfNull: false)  Map<String, dynamic>? edited, @JsonKey(includeIfNull: false)  List<SlackMessageReactionEntity>? reactions, @JsonKey(includeIfNull: false)  String? clientMsgId, @JsonKey(includeIfNull: false)  String? parentUserId, @JsonKey(includeIfNull: false)  List<SlackMessageFileEntity>? files, @JsonKey(includeIfNull: false)  List<SlackMessageBlockEntity>? blocks, @JsonKey(includeIfNull: false)  String? botId, @JsonKey(includeIfNull: false)  bool? isLocalTempMessage, @JsonKey(includeIfNull: false)  String? link)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SlackMessageEntity() when $default != null:
return $default(_that.type,_that.user,_that.text,_that.team,_that.ts,_that.channel,_that.subtype,_that.deletedTs,_that.eventTs,_that.threadTs,_that.latestReply,_that.replyCount,_that.replyUsersCount,_that.replyUsers,_that.isStarred,_that.hidden,_that.isLocked,_that.subscribed,_that.pinnedTo,_that.attachments,_that.edited,_that.reactions,_that.clientMsgId,_that.parentUserId,_that.files,_that.blocks,_that.botId,_that.isLocalTempMessage,_that.link);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(includeIfNull: false)  String? type, @JsonKey(includeIfNull: false)  String? user, @JsonKey(includeIfNull: false)  String? text, @JsonKey(includeIfNull: false)  String? team, @JsonKey(includeIfNull: false)  String? ts, @JsonKey(includeIfNull: false)  String? channel, @JsonKey(includeIfNull: false)  SlackMessageEntitySubtype? subtype, @JsonKey(includeIfNull: false)  String? deletedTs, @JsonKey(includeIfNull: false)  String? eventTs, @JsonKey(includeIfNull: false)  String? threadTs, @JsonKey(includeIfNull: false)  String? latestReply, @JsonKey(includeIfNull: false)  int? replyCount, @JsonKey(includeIfNull: false)  int? replyUsersCount, @JsonKey(includeIfNull: false)  List<String>? replyUsers, @JsonKey(includeIfNull: false)  bool? isStarred, @JsonKey(includeIfNull: false)  bool? hidden, @JsonKey(includeIfNull: false)  bool? isLocked, @JsonKey(includeIfNull: false)  bool? subscribed, @JsonKey(includeIfNull: false)  List<String>? pinnedTo, @JsonKey(includeIfNull: false)  List<SlackMessageAttachmentEntity>? attachments, @JsonKey(includeIfNull: false)  Map<String, dynamic>? edited, @JsonKey(includeIfNull: false)  List<SlackMessageReactionEntity>? reactions, @JsonKey(includeIfNull: false)  String? clientMsgId, @JsonKey(includeIfNull: false)  String? parentUserId, @JsonKey(includeIfNull: false)  List<SlackMessageFileEntity>? files, @JsonKey(includeIfNull: false)  List<SlackMessageBlockEntity>? blocks, @JsonKey(includeIfNull: false)  String? botId, @JsonKey(includeIfNull: false)  bool? isLocalTempMessage, @JsonKey(includeIfNull: false)  String? link)  $default,) {final _that = this;
switch (_that) {
case _SlackMessageEntity():
return $default(_that.type,_that.user,_that.text,_that.team,_that.ts,_that.channel,_that.subtype,_that.deletedTs,_that.eventTs,_that.threadTs,_that.latestReply,_that.replyCount,_that.replyUsersCount,_that.replyUsers,_that.isStarred,_that.hidden,_that.isLocked,_that.subscribed,_that.pinnedTo,_that.attachments,_that.edited,_that.reactions,_that.clientMsgId,_that.parentUserId,_that.files,_that.blocks,_that.botId,_that.isLocalTempMessage,_that.link);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(includeIfNull: false)  String? type, @JsonKey(includeIfNull: false)  String? user, @JsonKey(includeIfNull: false)  String? text, @JsonKey(includeIfNull: false)  String? team, @JsonKey(includeIfNull: false)  String? ts, @JsonKey(includeIfNull: false)  String? channel, @JsonKey(includeIfNull: false)  SlackMessageEntitySubtype? subtype, @JsonKey(includeIfNull: false)  String? deletedTs, @JsonKey(includeIfNull: false)  String? eventTs, @JsonKey(includeIfNull: false)  String? threadTs, @JsonKey(includeIfNull: false)  String? latestReply, @JsonKey(includeIfNull: false)  int? replyCount, @JsonKey(includeIfNull: false)  int? replyUsersCount, @JsonKey(includeIfNull: false)  List<String>? replyUsers, @JsonKey(includeIfNull: false)  bool? isStarred, @JsonKey(includeIfNull: false)  bool? hidden, @JsonKey(includeIfNull: false)  bool? isLocked, @JsonKey(includeIfNull: false)  bool? subscribed, @JsonKey(includeIfNull: false)  List<String>? pinnedTo, @JsonKey(includeIfNull: false)  List<SlackMessageAttachmentEntity>? attachments, @JsonKey(includeIfNull: false)  Map<String, dynamic>? edited, @JsonKey(includeIfNull: false)  List<SlackMessageReactionEntity>? reactions, @JsonKey(includeIfNull: false)  String? clientMsgId, @JsonKey(includeIfNull: false)  String? parentUserId, @JsonKey(includeIfNull: false)  List<SlackMessageFileEntity>? files, @JsonKey(includeIfNull: false)  List<SlackMessageBlockEntity>? blocks, @JsonKey(includeIfNull: false)  String? botId, @JsonKey(includeIfNull: false)  bool? isLocalTempMessage, @JsonKey(includeIfNull: false)  String? link)?  $default,) {final _that = this;
switch (_that) {
case _SlackMessageEntity() when $default != null:
return $default(_that.type,_that.user,_that.text,_that.team,_that.ts,_that.channel,_that.subtype,_that.deletedTs,_that.eventTs,_that.threadTs,_that.latestReply,_that.replyCount,_that.replyUsersCount,_that.replyUsers,_that.isStarred,_that.hidden,_that.isLocked,_that.subscribed,_that.pinnedTo,_that.attachments,_that.edited,_that.reactions,_that.clientMsgId,_that.parentUserId,_that.files,_that.blocks,_that.botId,_that.isLocalTempMessage,_that.link);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _SlackMessageEntity implements SlackMessageEntity {
  const _SlackMessageEntity({@JsonKey(includeIfNull: false) this.type, @JsonKey(includeIfNull: false) this.user, @JsonKey(includeIfNull: false) this.text, @JsonKey(includeIfNull: false) this.team, @JsonKey(includeIfNull: false) this.ts, @JsonKey(includeIfNull: false) this.channel, @JsonKey(includeIfNull: false) this.subtype, @JsonKey(includeIfNull: false) this.deletedTs, @JsonKey(includeIfNull: false) this.eventTs, @JsonKey(includeIfNull: false) this.threadTs, @JsonKey(includeIfNull: false) this.latestReply, @JsonKey(includeIfNull: false) this.replyCount, @JsonKey(includeIfNull: false) this.replyUsersCount, @JsonKey(includeIfNull: false) final  List<String>? replyUsers, @JsonKey(includeIfNull: false) this.isStarred, @JsonKey(includeIfNull: false) this.hidden, @JsonKey(includeIfNull: false) this.isLocked, @JsonKey(includeIfNull: false) this.subscribed, @JsonKey(includeIfNull: false) final  List<String>? pinnedTo, @JsonKey(includeIfNull: false) final  List<SlackMessageAttachmentEntity>? attachments, @JsonKey(includeIfNull: false) final  Map<String, dynamic>? edited, @JsonKey(includeIfNull: false) final  List<SlackMessageReactionEntity>? reactions, @JsonKey(includeIfNull: false) this.clientMsgId, @JsonKey(includeIfNull: false) this.parentUserId, @JsonKey(includeIfNull: false) final  List<SlackMessageFileEntity>? files, @JsonKey(includeIfNull: false) final  List<SlackMessageBlockEntity>? blocks, @JsonKey(includeIfNull: false) this.botId, @JsonKey(includeIfNull: false) this.isLocalTempMessage, @JsonKey(includeIfNull: false) this.link}): _replyUsers = replyUsers,_pinnedTo = pinnedTo,_attachments = attachments,_edited = edited,_reactions = reactions,_files = files,_blocks = blocks;
  factory _SlackMessageEntity.fromJson(Map<String, dynamic> json) => _$SlackMessageEntityFromJson(json);

@override@JsonKey(includeIfNull: false) final  String? type;
@override@JsonKey(includeIfNull: false) final  String? user;
@override@JsonKey(includeIfNull: false) final  String? text;
@override@JsonKey(includeIfNull: false) final  String? team;
@override@JsonKey(includeIfNull: false) final  String? ts;
@override@JsonKey(includeIfNull: false) final  String? channel;
@override@JsonKey(includeIfNull: false) final  SlackMessageEntitySubtype? subtype;
@override@JsonKey(includeIfNull: false) final  String? deletedTs;
@override@JsonKey(includeIfNull: false) final  String? eventTs;
@override@JsonKey(includeIfNull: false) final  String? threadTs;
@override@JsonKey(includeIfNull: false) final  String? latestReply;
@override@JsonKey(includeIfNull: false) final  int? replyCount;
@override@JsonKey(includeIfNull: false) final  int? replyUsersCount;
 final  List<String>? _replyUsers;
@override@JsonKey(includeIfNull: false) List<String>? get replyUsers {
  final value = _replyUsers;
  if (value == null) return null;
  if (_replyUsers is EqualUnmodifiableListView) return _replyUsers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override@JsonKey(includeIfNull: false) final  bool? isStarred;
@override@JsonKey(includeIfNull: false) final  bool? hidden;
@override@JsonKey(includeIfNull: false) final  bool? isLocked;
@override@JsonKey(includeIfNull: false) final  bool? subscribed;
 final  List<String>? _pinnedTo;
@override@JsonKey(includeIfNull: false) List<String>? get pinnedTo {
  final value = _pinnedTo;
  if (value == null) return null;
  if (_pinnedTo is EqualUnmodifiableListView) return _pinnedTo;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<SlackMessageAttachmentEntity>? _attachments;
@override@JsonKey(includeIfNull: false) List<SlackMessageAttachmentEntity>? get attachments {
  final value = _attachments;
  if (value == null) return null;
  if (_attachments is EqualUnmodifiableListView) return _attachments;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  Map<String, dynamic>? _edited;
@override@JsonKey(includeIfNull: false) Map<String, dynamic>? get edited {
  final value = _edited;
  if (value == null) return null;
  if (_edited is EqualUnmodifiableMapView) return _edited;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  List<SlackMessageReactionEntity>? _reactions;
@override@JsonKey(includeIfNull: false) List<SlackMessageReactionEntity>? get reactions {
  final value = _reactions;
  if (value == null) return null;
  if (_reactions is EqualUnmodifiableListView) return _reactions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override@JsonKey(includeIfNull: false) final  String? clientMsgId;
@override@JsonKey(includeIfNull: false) final  String? parentUserId;
 final  List<SlackMessageFileEntity>? _files;
@override@JsonKey(includeIfNull: false) List<SlackMessageFileEntity>? get files {
  final value = _files;
  if (value == null) return null;
  if (_files is EqualUnmodifiableListView) return _files;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<SlackMessageBlockEntity>? _blocks;
@override@JsonKey(includeIfNull: false) List<SlackMessageBlockEntity>? get blocks {
  final value = _blocks;
  if (value == null) return null;
  if (_blocks is EqualUnmodifiableListView) return _blocks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override@JsonKey(includeIfNull: false) final  String? botId;
//for local
@override@JsonKey(includeIfNull: false) final  bool? isLocalTempMessage;
@override@JsonKey(includeIfNull: false) final  String? link;

/// Create a copy of SlackMessageEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SlackMessageEntityCopyWith<_SlackMessageEntity> get copyWith => __$SlackMessageEntityCopyWithImpl<_SlackMessageEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SlackMessageEntityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SlackMessageEntity&&(identical(other.type, type) || other.type == type)&&(identical(other.user, user) || other.user == user)&&(identical(other.text, text) || other.text == text)&&(identical(other.team, team) || other.team == team)&&(identical(other.ts, ts) || other.ts == ts)&&(identical(other.channel, channel) || other.channel == channel)&&(identical(other.subtype, subtype) || other.subtype == subtype)&&(identical(other.deletedTs, deletedTs) || other.deletedTs == deletedTs)&&(identical(other.eventTs, eventTs) || other.eventTs == eventTs)&&(identical(other.threadTs, threadTs) || other.threadTs == threadTs)&&(identical(other.latestReply, latestReply) || other.latestReply == latestReply)&&(identical(other.replyCount, replyCount) || other.replyCount == replyCount)&&(identical(other.replyUsersCount, replyUsersCount) || other.replyUsersCount == replyUsersCount)&&const DeepCollectionEquality().equals(other._replyUsers, _replyUsers)&&(identical(other.isStarred, isStarred) || other.isStarred == isStarred)&&(identical(other.hidden, hidden) || other.hidden == hidden)&&(identical(other.isLocked, isLocked) || other.isLocked == isLocked)&&(identical(other.subscribed, subscribed) || other.subscribed == subscribed)&&const DeepCollectionEquality().equals(other._pinnedTo, _pinnedTo)&&const DeepCollectionEquality().equals(other._attachments, _attachments)&&const DeepCollectionEquality().equals(other._edited, _edited)&&const DeepCollectionEquality().equals(other._reactions, _reactions)&&(identical(other.clientMsgId, clientMsgId) || other.clientMsgId == clientMsgId)&&(identical(other.parentUserId, parentUserId) || other.parentUserId == parentUserId)&&const DeepCollectionEquality().equals(other._files, _files)&&const DeepCollectionEquality().equals(other._blocks, _blocks)&&(identical(other.botId, botId) || other.botId == botId)&&(identical(other.isLocalTempMessage, isLocalTempMessage) || other.isLocalTempMessage == isLocalTempMessage)&&(identical(other.link, link) || other.link == link));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,type,user,text,team,ts,channel,subtype,deletedTs,eventTs,threadTs,latestReply,replyCount,replyUsersCount,const DeepCollectionEquality().hash(_replyUsers),isStarred,hidden,isLocked,subscribed,const DeepCollectionEquality().hash(_pinnedTo),const DeepCollectionEquality().hash(_attachments),const DeepCollectionEquality().hash(_edited),const DeepCollectionEquality().hash(_reactions),clientMsgId,parentUserId,const DeepCollectionEquality().hash(_files),const DeepCollectionEquality().hash(_blocks),botId,isLocalTempMessage,link]);

@override
String toString() {
  return 'SlackMessageEntity(type: $type, user: $user, text: $text, team: $team, ts: $ts, channel: $channel, subtype: $subtype, deletedTs: $deletedTs, eventTs: $eventTs, threadTs: $threadTs, latestReply: $latestReply, replyCount: $replyCount, replyUsersCount: $replyUsersCount, replyUsers: $replyUsers, isStarred: $isStarred, hidden: $hidden, isLocked: $isLocked, subscribed: $subscribed, pinnedTo: $pinnedTo, attachments: $attachments, edited: $edited, reactions: $reactions, clientMsgId: $clientMsgId, parentUserId: $parentUserId, files: $files, blocks: $blocks, botId: $botId, isLocalTempMessage: $isLocalTempMessage, link: $link)';
}


}

/// @nodoc
abstract mixin class _$SlackMessageEntityCopyWith<$Res> implements $SlackMessageEntityCopyWith<$Res> {
  factory _$SlackMessageEntityCopyWith(_SlackMessageEntity value, $Res Function(_SlackMessageEntity) _then) = __$SlackMessageEntityCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(includeIfNull: false) String? type,@JsonKey(includeIfNull: false) String? user,@JsonKey(includeIfNull: false) String? text,@JsonKey(includeIfNull: false) String? team,@JsonKey(includeIfNull: false) String? ts,@JsonKey(includeIfNull: false) String? channel,@JsonKey(includeIfNull: false) SlackMessageEntitySubtype? subtype,@JsonKey(includeIfNull: false) String? deletedTs,@JsonKey(includeIfNull: false) String? eventTs,@JsonKey(includeIfNull: false) String? threadTs,@JsonKey(includeIfNull: false) String? latestReply,@JsonKey(includeIfNull: false) int? replyCount,@JsonKey(includeIfNull: false) int? replyUsersCount,@JsonKey(includeIfNull: false) List<String>? replyUsers,@JsonKey(includeIfNull: false) bool? isStarred,@JsonKey(includeIfNull: false) bool? hidden,@JsonKey(includeIfNull: false) bool? isLocked,@JsonKey(includeIfNull: false) bool? subscribed,@JsonKey(includeIfNull: false) List<String>? pinnedTo,@JsonKey(includeIfNull: false) List<SlackMessageAttachmentEntity>? attachments,@JsonKey(includeIfNull: false) Map<String, dynamic>? edited,@JsonKey(includeIfNull: false) List<SlackMessageReactionEntity>? reactions,@JsonKey(includeIfNull: false) String? clientMsgId,@JsonKey(includeIfNull: false) String? parentUserId,@JsonKey(includeIfNull: false) List<SlackMessageFileEntity>? files,@JsonKey(includeIfNull: false) List<SlackMessageBlockEntity>? blocks,@JsonKey(includeIfNull: false) String? botId,@JsonKey(includeIfNull: false) bool? isLocalTempMessage,@JsonKey(includeIfNull: false) String? link
});




}
/// @nodoc
class __$SlackMessageEntityCopyWithImpl<$Res>
    implements _$SlackMessageEntityCopyWith<$Res> {
  __$SlackMessageEntityCopyWithImpl(this._self, this._then);

  final _SlackMessageEntity _self;
  final $Res Function(_SlackMessageEntity) _then;

/// Create a copy of SlackMessageEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = freezed,Object? user = freezed,Object? text = freezed,Object? team = freezed,Object? ts = freezed,Object? channel = freezed,Object? subtype = freezed,Object? deletedTs = freezed,Object? eventTs = freezed,Object? threadTs = freezed,Object? latestReply = freezed,Object? replyCount = freezed,Object? replyUsersCount = freezed,Object? replyUsers = freezed,Object? isStarred = freezed,Object? hidden = freezed,Object? isLocked = freezed,Object? subscribed = freezed,Object? pinnedTo = freezed,Object? attachments = freezed,Object? edited = freezed,Object? reactions = freezed,Object? clientMsgId = freezed,Object? parentUserId = freezed,Object? files = freezed,Object? blocks = freezed,Object? botId = freezed,Object? isLocalTempMessage = freezed,Object? link = freezed,}) {
  return _then(_SlackMessageEntity(
type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String?,user: freezed == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as String?,text: freezed == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String?,team: freezed == team ? _self.team : team // ignore: cast_nullable_to_non_nullable
as String?,ts: freezed == ts ? _self.ts : ts // ignore: cast_nullable_to_non_nullable
as String?,channel: freezed == channel ? _self.channel : channel // ignore: cast_nullable_to_non_nullable
as String?,subtype: freezed == subtype ? _self.subtype : subtype // ignore: cast_nullable_to_non_nullable
as SlackMessageEntitySubtype?,deletedTs: freezed == deletedTs ? _self.deletedTs : deletedTs // ignore: cast_nullable_to_non_nullable
as String?,eventTs: freezed == eventTs ? _self.eventTs : eventTs // ignore: cast_nullable_to_non_nullable
as String?,threadTs: freezed == threadTs ? _self.threadTs : threadTs // ignore: cast_nullable_to_non_nullable
as String?,latestReply: freezed == latestReply ? _self.latestReply : latestReply // ignore: cast_nullable_to_non_nullable
as String?,replyCount: freezed == replyCount ? _self.replyCount : replyCount // ignore: cast_nullable_to_non_nullable
as int?,replyUsersCount: freezed == replyUsersCount ? _self.replyUsersCount : replyUsersCount // ignore: cast_nullable_to_non_nullable
as int?,replyUsers: freezed == replyUsers ? _self._replyUsers : replyUsers // ignore: cast_nullable_to_non_nullable
as List<String>?,isStarred: freezed == isStarred ? _self.isStarred : isStarred // ignore: cast_nullable_to_non_nullable
as bool?,hidden: freezed == hidden ? _self.hidden : hidden // ignore: cast_nullable_to_non_nullable
as bool?,isLocked: freezed == isLocked ? _self.isLocked : isLocked // ignore: cast_nullable_to_non_nullable
as bool?,subscribed: freezed == subscribed ? _self.subscribed : subscribed // ignore: cast_nullable_to_non_nullable
as bool?,pinnedTo: freezed == pinnedTo ? _self._pinnedTo : pinnedTo // ignore: cast_nullable_to_non_nullable
as List<String>?,attachments: freezed == attachments ? _self._attachments : attachments // ignore: cast_nullable_to_non_nullable
as List<SlackMessageAttachmentEntity>?,edited: freezed == edited ? _self._edited : edited // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,reactions: freezed == reactions ? _self._reactions : reactions // ignore: cast_nullable_to_non_nullable
as List<SlackMessageReactionEntity>?,clientMsgId: freezed == clientMsgId ? _self.clientMsgId : clientMsgId // ignore: cast_nullable_to_non_nullable
as String?,parentUserId: freezed == parentUserId ? _self.parentUserId : parentUserId // ignore: cast_nullable_to_non_nullable
as String?,files: freezed == files ? _self._files : files // ignore: cast_nullable_to_non_nullable
as List<SlackMessageFileEntity>?,blocks: freezed == blocks ? _self._blocks : blocks // ignore: cast_nullable_to_non_nullable
as List<SlackMessageBlockEntity>?,botId: freezed == botId ? _self.botId : botId // ignore: cast_nullable_to_non_nullable
as String?,isLocalTempMessage: freezed == isLocalTempMessage ? _self.isLocalTempMessage : isLocalTempMessage // ignore: cast_nullable_to_non_nullable
as bool?,link: freezed == link ? _self.link : link // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
