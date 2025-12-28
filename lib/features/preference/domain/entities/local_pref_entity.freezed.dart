// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'local_pref_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LocalPrefEntity {

@JsonKey(includeIfNull: false) List<OAuthEntity>? get calendarOAuths;@JsonKey(includeIfNull: false) List<OAuthEntity>? get mailOAuths;@JsonKey(includeIfNull: false) List<OAuthEntity>? get messengerOAuths;@JsonKey(includeIfNull: false) Map<String, String>? get notificationPayload;@JsonKey(includeIfNull: false) Map<String, bool>? get showCalendarNotifications;@JsonKey(includeIfNull: false) Map<String, MailNotificationFilterType>? get mailNotificationFilterTypes;@JsonKey(includeIfNull: false) Map<String, List<String>>? get mailNotificationFilterLabelIds;@JsonKey(includeIfNull: false) Map<String, MessagNotificationFilterType>? get messageDmNotificationFilterTypes;@JsonKey(includeIfNull: false) Map<String, MessagNotificationFilterType>? get messageChannelNotificationFilterTypes;@JsonKey(includeIfNull: false) Map<String, String?>? get googleConnectionSyncToken;@JsonKey(includeIfNull: false) List<Map<String, String?>>? get quickLinks;@JsonKey(includeIfNull: false) Map<String, String>? get aiApiKeys;@JsonKey(includeIfNull: false) Map<String, dynamic>? get selectedAgentModel;@JsonKey(includeIfNull: false) Map<String, String>? get calendarType;@JsonKey(includeIfNull: false) Map<String, double>? get calendarIntervalScale;@JsonKey(includeIfNull: false) List<String>? get lastUsedCalendarId;@JsonKey(includeIfNull: false) List<String>? get lastUsedProjectId;@JsonKey(includeIfNull: false) Map<String, String>? get chatChannelStateList;@JsonKey(includeIfNull: false) Map<String, List<String>>? get chatLastChannel;@JsonKey(includeIfNull: false) Map<String, String>? get inboxSuggestionSort;@JsonKey(includeIfNull: false) Map<String, String>? get inboxSuggestionFilter;
/// Create a copy of LocalPrefEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LocalPrefEntityCopyWith<LocalPrefEntity> get copyWith => _$LocalPrefEntityCopyWithImpl<LocalPrefEntity>(this as LocalPrefEntity, _$identity);

  /// Serializes this LocalPrefEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LocalPrefEntity&&const DeepCollectionEquality().equals(other.calendarOAuths, calendarOAuths)&&const DeepCollectionEquality().equals(other.mailOAuths, mailOAuths)&&const DeepCollectionEquality().equals(other.messengerOAuths, messengerOAuths)&&const DeepCollectionEquality().equals(other.notificationPayload, notificationPayload)&&const DeepCollectionEquality().equals(other.showCalendarNotifications, showCalendarNotifications)&&const DeepCollectionEquality().equals(other.mailNotificationFilterTypes, mailNotificationFilterTypes)&&const DeepCollectionEquality().equals(other.mailNotificationFilterLabelIds, mailNotificationFilterLabelIds)&&const DeepCollectionEquality().equals(other.messageDmNotificationFilterTypes, messageDmNotificationFilterTypes)&&const DeepCollectionEquality().equals(other.messageChannelNotificationFilterTypes, messageChannelNotificationFilterTypes)&&const DeepCollectionEquality().equals(other.googleConnectionSyncToken, googleConnectionSyncToken)&&const DeepCollectionEquality().equals(other.quickLinks, quickLinks)&&const DeepCollectionEquality().equals(other.aiApiKeys, aiApiKeys)&&const DeepCollectionEquality().equals(other.selectedAgentModel, selectedAgentModel)&&const DeepCollectionEquality().equals(other.calendarType, calendarType)&&const DeepCollectionEquality().equals(other.calendarIntervalScale, calendarIntervalScale)&&const DeepCollectionEquality().equals(other.lastUsedCalendarId, lastUsedCalendarId)&&const DeepCollectionEquality().equals(other.lastUsedProjectId, lastUsedProjectId)&&const DeepCollectionEquality().equals(other.chatChannelStateList, chatChannelStateList)&&const DeepCollectionEquality().equals(other.chatLastChannel, chatLastChannel)&&const DeepCollectionEquality().equals(other.inboxSuggestionSort, inboxSuggestionSort)&&const DeepCollectionEquality().equals(other.inboxSuggestionFilter, inboxSuggestionFilter));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,const DeepCollectionEquality().hash(calendarOAuths),const DeepCollectionEquality().hash(mailOAuths),const DeepCollectionEquality().hash(messengerOAuths),const DeepCollectionEquality().hash(notificationPayload),const DeepCollectionEquality().hash(showCalendarNotifications),const DeepCollectionEquality().hash(mailNotificationFilterTypes),const DeepCollectionEquality().hash(mailNotificationFilterLabelIds),const DeepCollectionEquality().hash(messageDmNotificationFilterTypes),const DeepCollectionEquality().hash(messageChannelNotificationFilterTypes),const DeepCollectionEquality().hash(googleConnectionSyncToken),const DeepCollectionEquality().hash(quickLinks),const DeepCollectionEquality().hash(aiApiKeys),const DeepCollectionEquality().hash(selectedAgentModel),const DeepCollectionEquality().hash(calendarType),const DeepCollectionEquality().hash(calendarIntervalScale),const DeepCollectionEquality().hash(lastUsedCalendarId),const DeepCollectionEquality().hash(lastUsedProjectId),const DeepCollectionEquality().hash(chatChannelStateList),const DeepCollectionEquality().hash(chatLastChannel),const DeepCollectionEquality().hash(inboxSuggestionSort),const DeepCollectionEquality().hash(inboxSuggestionFilter)]);

@override
String toString() {
  return 'LocalPrefEntity(calendarOAuths: $calendarOAuths, mailOAuths: $mailOAuths, messengerOAuths: $messengerOAuths, notificationPayload: $notificationPayload, showCalendarNotifications: $showCalendarNotifications, mailNotificationFilterTypes: $mailNotificationFilterTypes, mailNotificationFilterLabelIds: $mailNotificationFilterLabelIds, messageDmNotificationFilterTypes: $messageDmNotificationFilterTypes, messageChannelNotificationFilterTypes: $messageChannelNotificationFilterTypes, googleConnectionSyncToken: $googleConnectionSyncToken, quickLinks: $quickLinks, aiApiKeys: $aiApiKeys, selectedAgentModel: $selectedAgentModel, calendarType: $calendarType, calendarIntervalScale: $calendarIntervalScale, lastUsedCalendarId: $lastUsedCalendarId, lastUsedProjectId: $lastUsedProjectId, chatChannelStateList: $chatChannelStateList, chatLastChannel: $chatLastChannel, inboxSuggestionSort: $inboxSuggestionSort, inboxSuggestionFilter: $inboxSuggestionFilter)';
}


}

/// @nodoc
abstract mixin class $LocalPrefEntityCopyWith<$Res>  {
  factory $LocalPrefEntityCopyWith(LocalPrefEntity value, $Res Function(LocalPrefEntity) _then) = _$LocalPrefEntityCopyWithImpl;
@useResult
$Res call({
@JsonKey(includeIfNull: false) List<OAuthEntity>? calendarOAuths,@JsonKey(includeIfNull: false) List<OAuthEntity>? mailOAuths,@JsonKey(includeIfNull: false) List<OAuthEntity>? messengerOAuths,@JsonKey(includeIfNull: false) Map<String, String>? notificationPayload,@JsonKey(includeIfNull: false) Map<String, bool>? showCalendarNotifications,@JsonKey(includeIfNull: false) Map<String, MailNotificationFilterType>? mailNotificationFilterTypes,@JsonKey(includeIfNull: false) Map<String, List<String>>? mailNotificationFilterLabelIds,@JsonKey(includeIfNull: false) Map<String, MessagNotificationFilterType>? messageDmNotificationFilterTypes,@JsonKey(includeIfNull: false) Map<String, MessagNotificationFilterType>? messageChannelNotificationFilterTypes,@JsonKey(includeIfNull: false) Map<String, String?>? googleConnectionSyncToken,@JsonKey(includeIfNull: false) List<Map<String, String?>>? quickLinks,@JsonKey(includeIfNull: false) Map<String, String>? aiApiKeys,@JsonKey(includeIfNull: false) Map<String, dynamic>? selectedAgentModel,@JsonKey(includeIfNull: false) Map<String, String>? calendarType,@JsonKey(includeIfNull: false) Map<String, double>? calendarIntervalScale,@JsonKey(includeIfNull: false) List<String>? lastUsedCalendarId,@JsonKey(includeIfNull: false) List<String>? lastUsedProjectId,@JsonKey(includeIfNull: false) Map<String, String>? chatChannelStateList,@JsonKey(includeIfNull: false) Map<String, List<String>>? chatLastChannel,@JsonKey(includeIfNull: false) Map<String, String>? inboxSuggestionSort,@JsonKey(includeIfNull: false) Map<String, String>? inboxSuggestionFilter
});




}
/// @nodoc
class _$LocalPrefEntityCopyWithImpl<$Res>
    implements $LocalPrefEntityCopyWith<$Res> {
  _$LocalPrefEntityCopyWithImpl(this._self, this._then);

  final LocalPrefEntity _self;
  final $Res Function(LocalPrefEntity) _then;

/// Create a copy of LocalPrefEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? calendarOAuths = freezed,Object? mailOAuths = freezed,Object? messengerOAuths = freezed,Object? notificationPayload = freezed,Object? showCalendarNotifications = freezed,Object? mailNotificationFilterTypes = freezed,Object? mailNotificationFilterLabelIds = freezed,Object? messageDmNotificationFilterTypes = freezed,Object? messageChannelNotificationFilterTypes = freezed,Object? googleConnectionSyncToken = freezed,Object? quickLinks = freezed,Object? aiApiKeys = freezed,Object? selectedAgentModel = freezed,Object? calendarType = freezed,Object? calendarIntervalScale = freezed,Object? lastUsedCalendarId = freezed,Object? lastUsedProjectId = freezed,Object? chatChannelStateList = freezed,Object? chatLastChannel = freezed,Object? inboxSuggestionSort = freezed,Object? inboxSuggestionFilter = freezed,}) {
  return _then(_self.copyWith(
calendarOAuths: freezed == calendarOAuths ? _self.calendarOAuths : calendarOAuths // ignore: cast_nullable_to_non_nullable
as List<OAuthEntity>?,mailOAuths: freezed == mailOAuths ? _self.mailOAuths : mailOAuths // ignore: cast_nullable_to_non_nullable
as List<OAuthEntity>?,messengerOAuths: freezed == messengerOAuths ? _self.messengerOAuths : messengerOAuths // ignore: cast_nullable_to_non_nullable
as List<OAuthEntity>?,notificationPayload: freezed == notificationPayload ? _self.notificationPayload : notificationPayload // ignore: cast_nullable_to_non_nullable
as Map<String, String>?,showCalendarNotifications: freezed == showCalendarNotifications ? _self.showCalendarNotifications : showCalendarNotifications // ignore: cast_nullable_to_non_nullable
as Map<String, bool>?,mailNotificationFilterTypes: freezed == mailNotificationFilterTypes ? _self.mailNotificationFilterTypes : mailNotificationFilterTypes // ignore: cast_nullable_to_non_nullable
as Map<String, MailNotificationFilterType>?,mailNotificationFilterLabelIds: freezed == mailNotificationFilterLabelIds ? _self.mailNotificationFilterLabelIds : mailNotificationFilterLabelIds // ignore: cast_nullable_to_non_nullable
as Map<String, List<String>>?,messageDmNotificationFilterTypes: freezed == messageDmNotificationFilterTypes ? _self.messageDmNotificationFilterTypes : messageDmNotificationFilterTypes // ignore: cast_nullable_to_non_nullable
as Map<String, MessagNotificationFilterType>?,messageChannelNotificationFilterTypes: freezed == messageChannelNotificationFilterTypes ? _self.messageChannelNotificationFilterTypes : messageChannelNotificationFilterTypes // ignore: cast_nullable_to_non_nullable
as Map<String, MessagNotificationFilterType>?,googleConnectionSyncToken: freezed == googleConnectionSyncToken ? _self.googleConnectionSyncToken : googleConnectionSyncToken // ignore: cast_nullable_to_non_nullable
as Map<String, String?>?,quickLinks: freezed == quickLinks ? _self.quickLinks : quickLinks // ignore: cast_nullable_to_non_nullable
as List<Map<String, String?>>?,aiApiKeys: freezed == aiApiKeys ? _self.aiApiKeys : aiApiKeys // ignore: cast_nullable_to_non_nullable
as Map<String, String>?,selectedAgentModel: freezed == selectedAgentModel ? _self.selectedAgentModel : selectedAgentModel // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,calendarType: freezed == calendarType ? _self.calendarType : calendarType // ignore: cast_nullable_to_non_nullable
as Map<String, String>?,calendarIntervalScale: freezed == calendarIntervalScale ? _self.calendarIntervalScale : calendarIntervalScale // ignore: cast_nullable_to_non_nullable
as Map<String, double>?,lastUsedCalendarId: freezed == lastUsedCalendarId ? _self.lastUsedCalendarId : lastUsedCalendarId // ignore: cast_nullable_to_non_nullable
as List<String>?,lastUsedProjectId: freezed == lastUsedProjectId ? _self.lastUsedProjectId : lastUsedProjectId // ignore: cast_nullable_to_non_nullable
as List<String>?,chatChannelStateList: freezed == chatChannelStateList ? _self.chatChannelStateList : chatChannelStateList // ignore: cast_nullable_to_non_nullable
as Map<String, String>?,chatLastChannel: freezed == chatLastChannel ? _self.chatLastChannel : chatLastChannel // ignore: cast_nullable_to_non_nullable
as Map<String, List<String>>?,inboxSuggestionSort: freezed == inboxSuggestionSort ? _self.inboxSuggestionSort : inboxSuggestionSort // ignore: cast_nullable_to_non_nullable
as Map<String, String>?,inboxSuggestionFilter: freezed == inboxSuggestionFilter ? _self.inboxSuggestionFilter : inboxSuggestionFilter // ignore: cast_nullable_to_non_nullable
as Map<String, String>?,
  ));
}

}


/// Adds pattern-matching-related methods to [LocalPrefEntity].
extension LocalPrefEntityPatterns on LocalPrefEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LocalPrefEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LocalPrefEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LocalPrefEntity value)  $default,){
final _that = this;
switch (_that) {
case _LocalPrefEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LocalPrefEntity value)?  $default,){
final _that = this;
switch (_that) {
case _LocalPrefEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(includeIfNull: false)  List<OAuthEntity>? calendarOAuths, @JsonKey(includeIfNull: false)  List<OAuthEntity>? mailOAuths, @JsonKey(includeIfNull: false)  List<OAuthEntity>? messengerOAuths, @JsonKey(includeIfNull: false)  Map<String, String>? notificationPayload, @JsonKey(includeIfNull: false)  Map<String, bool>? showCalendarNotifications, @JsonKey(includeIfNull: false)  Map<String, MailNotificationFilterType>? mailNotificationFilterTypes, @JsonKey(includeIfNull: false)  Map<String, List<String>>? mailNotificationFilterLabelIds, @JsonKey(includeIfNull: false)  Map<String, MessagNotificationFilterType>? messageDmNotificationFilterTypes, @JsonKey(includeIfNull: false)  Map<String, MessagNotificationFilterType>? messageChannelNotificationFilterTypes, @JsonKey(includeIfNull: false)  Map<String, String?>? googleConnectionSyncToken, @JsonKey(includeIfNull: false)  List<Map<String, String?>>? quickLinks, @JsonKey(includeIfNull: false)  Map<String, String>? aiApiKeys, @JsonKey(includeIfNull: false)  Map<String, dynamic>? selectedAgentModel, @JsonKey(includeIfNull: false)  Map<String, String>? calendarType, @JsonKey(includeIfNull: false)  Map<String, double>? calendarIntervalScale, @JsonKey(includeIfNull: false)  List<String>? lastUsedCalendarId, @JsonKey(includeIfNull: false)  List<String>? lastUsedProjectId, @JsonKey(includeIfNull: false)  Map<String, String>? chatChannelStateList, @JsonKey(includeIfNull: false)  Map<String, List<String>>? chatLastChannel, @JsonKey(includeIfNull: false)  Map<String, String>? inboxSuggestionSort, @JsonKey(includeIfNull: false)  Map<String, String>? inboxSuggestionFilter)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LocalPrefEntity() when $default != null:
return $default(_that.calendarOAuths,_that.mailOAuths,_that.messengerOAuths,_that.notificationPayload,_that.showCalendarNotifications,_that.mailNotificationFilterTypes,_that.mailNotificationFilterLabelIds,_that.messageDmNotificationFilterTypes,_that.messageChannelNotificationFilterTypes,_that.googleConnectionSyncToken,_that.quickLinks,_that.aiApiKeys,_that.selectedAgentModel,_that.calendarType,_that.calendarIntervalScale,_that.lastUsedCalendarId,_that.lastUsedProjectId,_that.chatChannelStateList,_that.chatLastChannel,_that.inboxSuggestionSort,_that.inboxSuggestionFilter);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(includeIfNull: false)  List<OAuthEntity>? calendarOAuths, @JsonKey(includeIfNull: false)  List<OAuthEntity>? mailOAuths, @JsonKey(includeIfNull: false)  List<OAuthEntity>? messengerOAuths, @JsonKey(includeIfNull: false)  Map<String, String>? notificationPayload, @JsonKey(includeIfNull: false)  Map<String, bool>? showCalendarNotifications, @JsonKey(includeIfNull: false)  Map<String, MailNotificationFilterType>? mailNotificationFilterTypes, @JsonKey(includeIfNull: false)  Map<String, List<String>>? mailNotificationFilterLabelIds, @JsonKey(includeIfNull: false)  Map<String, MessagNotificationFilterType>? messageDmNotificationFilterTypes, @JsonKey(includeIfNull: false)  Map<String, MessagNotificationFilterType>? messageChannelNotificationFilterTypes, @JsonKey(includeIfNull: false)  Map<String, String?>? googleConnectionSyncToken, @JsonKey(includeIfNull: false)  List<Map<String, String?>>? quickLinks, @JsonKey(includeIfNull: false)  Map<String, String>? aiApiKeys, @JsonKey(includeIfNull: false)  Map<String, dynamic>? selectedAgentModel, @JsonKey(includeIfNull: false)  Map<String, String>? calendarType, @JsonKey(includeIfNull: false)  Map<String, double>? calendarIntervalScale, @JsonKey(includeIfNull: false)  List<String>? lastUsedCalendarId, @JsonKey(includeIfNull: false)  List<String>? lastUsedProjectId, @JsonKey(includeIfNull: false)  Map<String, String>? chatChannelStateList, @JsonKey(includeIfNull: false)  Map<String, List<String>>? chatLastChannel, @JsonKey(includeIfNull: false)  Map<String, String>? inboxSuggestionSort, @JsonKey(includeIfNull: false)  Map<String, String>? inboxSuggestionFilter)  $default,) {final _that = this;
switch (_that) {
case _LocalPrefEntity():
return $default(_that.calendarOAuths,_that.mailOAuths,_that.messengerOAuths,_that.notificationPayload,_that.showCalendarNotifications,_that.mailNotificationFilterTypes,_that.mailNotificationFilterLabelIds,_that.messageDmNotificationFilterTypes,_that.messageChannelNotificationFilterTypes,_that.googleConnectionSyncToken,_that.quickLinks,_that.aiApiKeys,_that.selectedAgentModel,_that.calendarType,_that.calendarIntervalScale,_that.lastUsedCalendarId,_that.lastUsedProjectId,_that.chatChannelStateList,_that.chatLastChannel,_that.inboxSuggestionSort,_that.inboxSuggestionFilter);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(includeIfNull: false)  List<OAuthEntity>? calendarOAuths, @JsonKey(includeIfNull: false)  List<OAuthEntity>? mailOAuths, @JsonKey(includeIfNull: false)  List<OAuthEntity>? messengerOAuths, @JsonKey(includeIfNull: false)  Map<String, String>? notificationPayload, @JsonKey(includeIfNull: false)  Map<String, bool>? showCalendarNotifications, @JsonKey(includeIfNull: false)  Map<String, MailNotificationFilterType>? mailNotificationFilterTypes, @JsonKey(includeIfNull: false)  Map<String, List<String>>? mailNotificationFilterLabelIds, @JsonKey(includeIfNull: false)  Map<String, MessagNotificationFilterType>? messageDmNotificationFilterTypes, @JsonKey(includeIfNull: false)  Map<String, MessagNotificationFilterType>? messageChannelNotificationFilterTypes, @JsonKey(includeIfNull: false)  Map<String, String?>? googleConnectionSyncToken, @JsonKey(includeIfNull: false)  List<Map<String, String?>>? quickLinks, @JsonKey(includeIfNull: false)  Map<String, String>? aiApiKeys, @JsonKey(includeIfNull: false)  Map<String, dynamic>? selectedAgentModel, @JsonKey(includeIfNull: false)  Map<String, String>? calendarType, @JsonKey(includeIfNull: false)  Map<String, double>? calendarIntervalScale, @JsonKey(includeIfNull: false)  List<String>? lastUsedCalendarId, @JsonKey(includeIfNull: false)  List<String>? lastUsedProjectId, @JsonKey(includeIfNull: false)  Map<String, String>? chatChannelStateList, @JsonKey(includeIfNull: false)  Map<String, List<String>>? chatLastChannel, @JsonKey(includeIfNull: false)  Map<String, String>? inboxSuggestionSort, @JsonKey(includeIfNull: false)  Map<String, String>? inboxSuggestionFilter)?  $default,) {final _that = this;
switch (_that) {
case _LocalPrefEntity() when $default != null:
return $default(_that.calendarOAuths,_that.mailOAuths,_that.messengerOAuths,_that.notificationPayload,_that.showCalendarNotifications,_that.mailNotificationFilterTypes,_that.mailNotificationFilterLabelIds,_that.messageDmNotificationFilterTypes,_that.messageChannelNotificationFilterTypes,_that.googleConnectionSyncToken,_that.quickLinks,_that.aiApiKeys,_that.selectedAgentModel,_that.calendarType,_that.calendarIntervalScale,_that.lastUsedCalendarId,_that.lastUsedProjectId,_that.chatChannelStateList,_that.chatLastChannel,_that.inboxSuggestionSort,_that.inboxSuggestionFilter);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _LocalPrefEntity extends LocalPrefEntity {
  const _LocalPrefEntity({@JsonKey(includeIfNull: false) final  List<OAuthEntity>? calendarOAuths, @JsonKey(includeIfNull: false) final  List<OAuthEntity>? mailOAuths, @JsonKey(includeIfNull: false) final  List<OAuthEntity>? messengerOAuths, @JsonKey(includeIfNull: false) final  Map<String, String>? notificationPayload, @JsonKey(includeIfNull: false) final  Map<String, bool>? showCalendarNotifications, @JsonKey(includeIfNull: false) final  Map<String, MailNotificationFilterType>? mailNotificationFilterTypes, @JsonKey(includeIfNull: false) final  Map<String, List<String>>? mailNotificationFilterLabelIds, @JsonKey(includeIfNull: false) final  Map<String, MessagNotificationFilterType>? messageDmNotificationFilterTypes, @JsonKey(includeIfNull: false) final  Map<String, MessagNotificationFilterType>? messageChannelNotificationFilterTypes, @JsonKey(includeIfNull: false) final  Map<String, String?>? googleConnectionSyncToken, @JsonKey(includeIfNull: false) final  List<Map<String, String?>>? quickLinks, @JsonKey(includeIfNull: false) final  Map<String, String>? aiApiKeys, @JsonKey(includeIfNull: false) final  Map<String, dynamic>? selectedAgentModel, @JsonKey(includeIfNull: false) final  Map<String, String>? calendarType, @JsonKey(includeIfNull: false) final  Map<String, double>? calendarIntervalScale, @JsonKey(includeIfNull: false) final  List<String>? lastUsedCalendarId, @JsonKey(includeIfNull: false) final  List<String>? lastUsedProjectId, @JsonKey(includeIfNull: false) final  Map<String, String>? chatChannelStateList, @JsonKey(includeIfNull: false) final  Map<String, List<String>>? chatLastChannel, @JsonKey(includeIfNull: false) final  Map<String, String>? inboxSuggestionSort, @JsonKey(includeIfNull: false) final  Map<String, String>? inboxSuggestionFilter}): _calendarOAuths = calendarOAuths,_mailOAuths = mailOAuths,_messengerOAuths = messengerOAuths,_notificationPayload = notificationPayload,_showCalendarNotifications = showCalendarNotifications,_mailNotificationFilterTypes = mailNotificationFilterTypes,_mailNotificationFilterLabelIds = mailNotificationFilterLabelIds,_messageDmNotificationFilterTypes = messageDmNotificationFilterTypes,_messageChannelNotificationFilterTypes = messageChannelNotificationFilterTypes,_googleConnectionSyncToken = googleConnectionSyncToken,_quickLinks = quickLinks,_aiApiKeys = aiApiKeys,_selectedAgentModel = selectedAgentModel,_calendarType = calendarType,_calendarIntervalScale = calendarIntervalScale,_lastUsedCalendarId = lastUsedCalendarId,_lastUsedProjectId = lastUsedProjectId,_chatChannelStateList = chatChannelStateList,_chatLastChannel = chatLastChannel,_inboxSuggestionSort = inboxSuggestionSort,_inboxSuggestionFilter = inboxSuggestionFilter,super._();
  factory _LocalPrefEntity.fromJson(Map<String, dynamic> json) => _$LocalPrefEntityFromJson(json);

 final  List<OAuthEntity>? _calendarOAuths;
@override@JsonKey(includeIfNull: false) List<OAuthEntity>? get calendarOAuths {
  final value = _calendarOAuths;
  if (value == null) return null;
  if (_calendarOAuths is EqualUnmodifiableListView) return _calendarOAuths;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<OAuthEntity>? _mailOAuths;
@override@JsonKey(includeIfNull: false) List<OAuthEntity>? get mailOAuths {
  final value = _mailOAuths;
  if (value == null) return null;
  if (_mailOAuths is EqualUnmodifiableListView) return _mailOAuths;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<OAuthEntity>? _messengerOAuths;
@override@JsonKey(includeIfNull: false) List<OAuthEntity>? get messengerOAuths {
  final value = _messengerOAuths;
  if (value == null) return null;
  if (_messengerOAuths is EqualUnmodifiableListView) return _messengerOAuths;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  Map<String, String>? _notificationPayload;
@override@JsonKey(includeIfNull: false) Map<String, String>? get notificationPayload {
  final value = _notificationPayload;
  if (value == null) return null;
  if (_notificationPayload is EqualUnmodifiableMapView) return _notificationPayload;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  Map<String, bool>? _showCalendarNotifications;
@override@JsonKey(includeIfNull: false) Map<String, bool>? get showCalendarNotifications {
  final value = _showCalendarNotifications;
  if (value == null) return null;
  if (_showCalendarNotifications is EqualUnmodifiableMapView) return _showCalendarNotifications;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  Map<String, MailNotificationFilterType>? _mailNotificationFilterTypes;
@override@JsonKey(includeIfNull: false) Map<String, MailNotificationFilterType>? get mailNotificationFilterTypes {
  final value = _mailNotificationFilterTypes;
  if (value == null) return null;
  if (_mailNotificationFilterTypes is EqualUnmodifiableMapView) return _mailNotificationFilterTypes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  Map<String, List<String>>? _mailNotificationFilterLabelIds;
@override@JsonKey(includeIfNull: false) Map<String, List<String>>? get mailNotificationFilterLabelIds {
  final value = _mailNotificationFilterLabelIds;
  if (value == null) return null;
  if (_mailNotificationFilterLabelIds is EqualUnmodifiableMapView) return _mailNotificationFilterLabelIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  Map<String, MessagNotificationFilterType>? _messageDmNotificationFilterTypes;
@override@JsonKey(includeIfNull: false) Map<String, MessagNotificationFilterType>? get messageDmNotificationFilterTypes {
  final value = _messageDmNotificationFilterTypes;
  if (value == null) return null;
  if (_messageDmNotificationFilterTypes is EqualUnmodifiableMapView) return _messageDmNotificationFilterTypes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  Map<String, MessagNotificationFilterType>? _messageChannelNotificationFilterTypes;
@override@JsonKey(includeIfNull: false) Map<String, MessagNotificationFilterType>? get messageChannelNotificationFilterTypes {
  final value = _messageChannelNotificationFilterTypes;
  if (value == null) return null;
  if (_messageChannelNotificationFilterTypes is EqualUnmodifiableMapView) return _messageChannelNotificationFilterTypes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  Map<String, String?>? _googleConnectionSyncToken;
@override@JsonKey(includeIfNull: false) Map<String, String?>? get googleConnectionSyncToken {
  final value = _googleConnectionSyncToken;
  if (value == null) return null;
  if (_googleConnectionSyncToken is EqualUnmodifiableMapView) return _googleConnectionSyncToken;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  List<Map<String, String?>>? _quickLinks;
@override@JsonKey(includeIfNull: false) List<Map<String, String?>>? get quickLinks {
  final value = _quickLinks;
  if (value == null) return null;
  if (_quickLinks is EqualUnmodifiableListView) return _quickLinks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  Map<String, String>? _aiApiKeys;
@override@JsonKey(includeIfNull: false) Map<String, String>? get aiApiKeys {
  final value = _aiApiKeys;
  if (value == null) return null;
  if (_aiApiKeys is EqualUnmodifiableMapView) return _aiApiKeys;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  Map<String, dynamic>? _selectedAgentModel;
@override@JsonKey(includeIfNull: false) Map<String, dynamic>? get selectedAgentModel {
  final value = _selectedAgentModel;
  if (value == null) return null;
  if (_selectedAgentModel is EqualUnmodifiableMapView) return _selectedAgentModel;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  Map<String, String>? _calendarType;
@override@JsonKey(includeIfNull: false) Map<String, String>? get calendarType {
  final value = _calendarType;
  if (value == null) return null;
  if (_calendarType is EqualUnmodifiableMapView) return _calendarType;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  Map<String, double>? _calendarIntervalScale;
@override@JsonKey(includeIfNull: false) Map<String, double>? get calendarIntervalScale {
  final value = _calendarIntervalScale;
  if (value == null) return null;
  if (_calendarIntervalScale is EqualUnmodifiableMapView) return _calendarIntervalScale;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  List<String>? _lastUsedCalendarId;
@override@JsonKey(includeIfNull: false) List<String>? get lastUsedCalendarId {
  final value = _lastUsedCalendarId;
  if (value == null) return null;
  if (_lastUsedCalendarId is EqualUnmodifiableListView) return _lastUsedCalendarId;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<String>? _lastUsedProjectId;
@override@JsonKey(includeIfNull: false) List<String>? get lastUsedProjectId {
  final value = _lastUsedProjectId;
  if (value == null) return null;
  if (_lastUsedProjectId is EqualUnmodifiableListView) return _lastUsedProjectId;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  Map<String, String>? _chatChannelStateList;
@override@JsonKey(includeIfNull: false) Map<String, String>? get chatChannelStateList {
  final value = _chatChannelStateList;
  if (value == null) return null;
  if (_chatChannelStateList is EqualUnmodifiableMapView) return _chatChannelStateList;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  Map<String, List<String>>? _chatLastChannel;
@override@JsonKey(includeIfNull: false) Map<String, List<String>>? get chatLastChannel {
  final value = _chatLastChannel;
  if (value == null) return null;
  if (_chatLastChannel is EqualUnmodifiableMapView) return _chatLastChannel;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  Map<String, String>? _inboxSuggestionSort;
@override@JsonKey(includeIfNull: false) Map<String, String>? get inboxSuggestionSort {
  final value = _inboxSuggestionSort;
  if (value == null) return null;
  if (_inboxSuggestionSort is EqualUnmodifiableMapView) return _inboxSuggestionSort;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  Map<String, String>? _inboxSuggestionFilter;
@override@JsonKey(includeIfNull: false) Map<String, String>? get inboxSuggestionFilter {
  final value = _inboxSuggestionFilter;
  if (value == null) return null;
  if (_inboxSuggestionFilter is EqualUnmodifiableMapView) return _inboxSuggestionFilter;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of LocalPrefEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LocalPrefEntityCopyWith<_LocalPrefEntity> get copyWith => __$LocalPrefEntityCopyWithImpl<_LocalPrefEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LocalPrefEntityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LocalPrefEntity&&const DeepCollectionEquality().equals(other._calendarOAuths, _calendarOAuths)&&const DeepCollectionEquality().equals(other._mailOAuths, _mailOAuths)&&const DeepCollectionEquality().equals(other._messengerOAuths, _messengerOAuths)&&const DeepCollectionEquality().equals(other._notificationPayload, _notificationPayload)&&const DeepCollectionEquality().equals(other._showCalendarNotifications, _showCalendarNotifications)&&const DeepCollectionEquality().equals(other._mailNotificationFilterTypes, _mailNotificationFilterTypes)&&const DeepCollectionEquality().equals(other._mailNotificationFilterLabelIds, _mailNotificationFilterLabelIds)&&const DeepCollectionEquality().equals(other._messageDmNotificationFilterTypes, _messageDmNotificationFilterTypes)&&const DeepCollectionEquality().equals(other._messageChannelNotificationFilterTypes, _messageChannelNotificationFilterTypes)&&const DeepCollectionEquality().equals(other._googleConnectionSyncToken, _googleConnectionSyncToken)&&const DeepCollectionEquality().equals(other._quickLinks, _quickLinks)&&const DeepCollectionEquality().equals(other._aiApiKeys, _aiApiKeys)&&const DeepCollectionEquality().equals(other._selectedAgentModel, _selectedAgentModel)&&const DeepCollectionEquality().equals(other._calendarType, _calendarType)&&const DeepCollectionEquality().equals(other._calendarIntervalScale, _calendarIntervalScale)&&const DeepCollectionEquality().equals(other._lastUsedCalendarId, _lastUsedCalendarId)&&const DeepCollectionEquality().equals(other._lastUsedProjectId, _lastUsedProjectId)&&const DeepCollectionEquality().equals(other._chatChannelStateList, _chatChannelStateList)&&const DeepCollectionEquality().equals(other._chatLastChannel, _chatLastChannel)&&const DeepCollectionEquality().equals(other._inboxSuggestionSort, _inboxSuggestionSort)&&const DeepCollectionEquality().equals(other._inboxSuggestionFilter, _inboxSuggestionFilter));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,const DeepCollectionEquality().hash(_calendarOAuths),const DeepCollectionEquality().hash(_mailOAuths),const DeepCollectionEquality().hash(_messengerOAuths),const DeepCollectionEquality().hash(_notificationPayload),const DeepCollectionEquality().hash(_showCalendarNotifications),const DeepCollectionEquality().hash(_mailNotificationFilterTypes),const DeepCollectionEquality().hash(_mailNotificationFilterLabelIds),const DeepCollectionEquality().hash(_messageDmNotificationFilterTypes),const DeepCollectionEquality().hash(_messageChannelNotificationFilterTypes),const DeepCollectionEquality().hash(_googleConnectionSyncToken),const DeepCollectionEquality().hash(_quickLinks),const DeepCollectionEquality().hash(_aiApiKeys),const DeepCollectionEquality().hash(_selectedAgentModel),const DeepCollectionEquality().hash(_calendarType),const DeepCollectionEquality().hash(_calendarIntervalScale),const DeepCollectionEquality().hash(_lastUsedCalendarId),const DeepCollectionEquality().hash(_lastUsedProjectId),const DeepCollectionEquality().hash(_chatChannelStateList),const DeepCollectionEquality().hash(_chatLastChannel),const DeepCollectionEquality().hash(_inboxSuggestionSort),const DeepCollectionEquality().hash(_inboxSuggestionFilter)]);

@override
String toString() {
  return 'LocalPrefEntity(calendarOAuths: $calendarOAuths, mailOAuths: $mailOAuths, messengerOAuths: $messengerOAuths, notificationPayload: $notificationPayload, showCalendarNotifications: $showCalendarNotifications, mailNotificationFilterTypes: $mailNotificationFilterTypes, mailNotificationFilterLabelIds: $mailNotificationFilterLabelIds, messageDmNotificationFilterTypes: $messageDmNotificationFilterTypes, messageChannelNotificationFilterTypes: $messageChannelNotificationFilterTypes, googleConnectionSyncToken: $googleConnectionSyncToken, quickLinks: $quickLinks, aiApiKeys: $aiApiKeys, selectedAgentModel: $selectedAgentModel, calendarType: $calendarType, calendarIntervalScale: $calendarIntervalScale, lastUsedCalendarId: $lastUsedCalendarId, lastUsedProjectId: $lastUsedProjectId, chatChannelStateList: $chatChannelStateList, chatLastChannel: $chatLastChannel, inboxSuggestionSort: $inboxSuggestionSort, inboxSuggestionFilter: $inboxSuggestionFilter)';
}


}

/// @nodoc
abstract mixin class _$LocalPrefEntityCopyWith<$Res> implements $LocalPrefEntityCopyWith<$Res> {
  factory _$LocalPrefEntityCopyWith(_LocalPrefEntity value, $Res Function(_LocalPrefEntity) _then) = __$LocalPrefEntityCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(includeIfNull: false) List<OAuthEntity>? calendarOAuths,@JsonKey(includeIfNull: false) List<OAuthEntity>? mailOAuths,@JsonKey(includeIfNull: false) List<OAuthEntity>? messengerOAuths,@JsonKey(includeIfNull: false) Map<String, String>? notificationPayload,@JsonKey(includeIfNull: false) Map<String, bool>? showCalendarNotifications,@JsonKey(includeIfNull: false) Map<String, MailNotificationFilterType>? mailNotificationFilterTypes,@JsonKey(includeIfNull: false) Map<String, List<String>>? mailNotificationFilterLabelIds,@JsonKey(includeIfNull: false) Map<String, MessagNotificationFilterType>? messageDmNotificationFilterTypes,@JsonKey(includeIfNull: false) Map<String, MessagNotificationFilterType>? messageChannelNotificationFilterTypes,@JsonKey(includeIfNull: false) Map<String, String?>? googleConnectionSyncToken,@JsonKey(includeIfNull: false) List<Map<String, String?>>? quickLinks,@JsonKey(includeIfNull: false) Map<String, String>? aiApiKeys,@JsonKey(includeIfNull: false) Map<String, dynamic>? selectedAgentModel,@JsonKey(includeIfNull: false) Map<String, String>? calendarType,@JsonKey(includeIfNull: false) Map<String, double>? calendarIntervalScale,@JsonKey(includeIfNull: false) List<String>? lastUsedCalendarId,@JsonKey(includeIfNull: false) List<String>? lastUsedProjectId,@JsonKey(includeIfNull: false) Map<String, String>? chatChannelStateList,@JsonKey(includeIfNull: false) Map<String, List<String>>? chatLastChannel,@JsonKey(includeIfNull: false) Map<String, String>? inboxSuggestionSort,@JsonKey(includeIfNull: false) Map<String, String>? inboxSuggestionFilter
});




}
/// @nodoc
class __$LocalPrefEntityCopyWithImpl<$Res>
    implements _$LocalPrefEntityCopyWith<$Res> {
  __$LocalPrefEntityCopyWithImpl(this._self, this._then);

  final _LocalPrefEntity _self;
  final $Res Function(_LocalPrefEntity) _then;

/// Create a copy of LocalPrefEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? calendarOAuths = freezed,Object? mailOAuths = freezed,Object? messengerOAuths = freezed,Object? notificationPayload = freezed,Object? showCalendarNotifications = freezed,Object? mailNotificationFilterTypes = freezed,Object? mailNotificationFilterLabelIds = freezed,Object? messageDmNotificationFilterTypes = freezed,Object? messageChannelNotificationFilterTypes = freezed,Object? googleConnectionSyncToken = freezed,Object? quickLinks = freezed,Object? aiApiKeys = freezed,Object? selectedAgentModel = freezed,Object? calendarType = freezed,Object? calendarIntervalScale = freezed,Object? lastUsedCalendarId = freezed,Object? lastUsedProjectId = freezed,Object? chatChannelStateList = freezed,Object? chatLastChannel = freezed,Object? inboxSuggestionSort = freezed,Object? inboxSuggestionFilter = freezed,}) {
  return _then(_LocalPrefEntity(
calendarOAuths: freezed == calendarOAuths ? _self._calendarOAuths : calendarOAuths // ignore: cast_nullable_to_non_nullable
as List<OAuthEntity>?,mailOAuths: freezed == mailOAuths ? _self._mailOAuths : mailOAuths // ignore: cast_nullable_to_non_nullable
as List<OAuthEntity>?,messengerOAuths: freezed == messengerOAuths ? _self._messengerOAuths : messengerOAuths // ignore: cast_nullable_to_non_nullable
as List<OAuthEntity>?,notificationPayload: freezed == notificationPayload ? _self._notificationPayload : notificationPayload // ignore: cast_nullable_to_non_nullable
as Map<String, String>?,showCalendarNotifications: freezed == showCalendarNotifications ? _self._showCalendarNotifications : showCalendarNotifications // ignore: cast_nullable_to_non_nullable
as Map<String, bool>?,mailNotificationFilterTypes: freezed == mailNotificationFilterTypes ? _self._mailNotificationFilterTypes : mailNotificationFilterTypes // ignore: cast_nullable_to_non_nullable
as Map<String, MailNotificationFilterType>?,mailNotificationFilterLabelIds: freezed == mailNotificationFilterLabelIds ? _self._mailNotificationFilterLabelIds : mailNotificationFilterLabelIds // ignore: cast_nullable_to_non_nullable
as Map<String, List<String>>?,messageDmNotificationFilterTypes: freezed == messageDmNotificationFilterTypes ? _self._messageDmNotificationFilterTypes : messageDmNotificationFilterTypes // ignore: cast_nullable_to_non_nullable
as Map<String, MessagNotificationFilterType>?,messageChannelNotificationFilterTypes: freezed == messageChannelNotificationFilterTypes ? _self._messageChannelNotificationFilterTypes : messageChannelNotificationFilterTypes // ignore: cast_nullable_to_non_nullable
as Map<String, MessagNotificationFilterType>?,googleConnectionSyncToken: freezed == googleConnectionSyncToken ? _self._googleConnectionSyncToken : googleConnectionSyncToken // ignore: cast_nullable_to_non_nullable
as Map<String, String?>?,quickLinks: freezed == quickLinks ? _self._quickLinks : quickLinks // ignore: cast_nullable_to_non_nullable
as List<Map<String, String?>>?,aiApiKeys: freezed == aiApiKeys ? _self._aiApiKeys : aiApiKeys // ignore: cast_nullable_to_non_nullable
as Map<String, String>?,selectedAgentModel: freezed == selectedAgentModel ? _self._selectedAgentModel : selectedAgentModel // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,calendarType: freezed == calendarType ? _self._calendarType : calendarType // ignore: cast_nullable_to_non_nullable
as Map<String, String>?,calendarIntervalScale: freezed == calendarIntervalScale ? _self._calendarIntervalScale : calendarIntervalScale // ignore: cast_nullable_to_non_nullable
as Map<String, double>?,lastUsedCalendarId: freezed == lastUsedCalendarId ? _self._lastUsedCalendarId : lastUsedCalendarId // ignore: cast_nullable_to_non_nullable
as List<String>?,lastUsedProjectId: freezed == lastUsedProjectId ? _self._lastUsedProjectId : lastUsedProjectId // ignore: cast_nullable_to_non_nullable
as List<String>?,chatChannelStateList: freezed == chatChannelStateList ? _self._chatChannelStateList : chatChannelStateList // ignore: cast_nullable_to_non_nullable
as Map<String, String>?,chatLastChannel: freezed == chatLastChannel ? _self._chatLastChannel : chatLastChannel // ignore: cast_nullable_to_non_nullable
as Map<String, List<String>>?,inboxSuggestionSort: freezed == inboxSuggestionSort ? _self._inboxSuggestionSort : inboxSuggestionSort // ignore: cast_nullable_to_non_nullable
as Map<String, String>?,inboxSuggestionFilter: freezed == inboxSuggestionFilter ? _self._inboxSuggestionFilter : inboxSuggestionFilter // ignore: cast_nullable_to_non_nullable
as Map<String, String>?,
  ));
}


}

// dart format on
