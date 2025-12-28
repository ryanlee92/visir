// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserEntity {

 String get id;@JsonKey(includeIfNull: false) String? get name;@JsonKey(includeIfNull: false) String? get email;@JsonKey(includeIfNull: false) String? get avatarUrl;@JsonKey(includeIfNull: false) DateTime? get createdAt;@JsonKey(includeIfNull: false) DateTime? get updatedAt;@JsonKey(includeIfNull: false) DateTime? get subscriptionEndAt;@JsonKey(includeIfNull: false) int? get badge;@JsonKey(includeIfNull: false) Map<String, String>? get calendarColors;@JsonKey(includeIfNull: false) Map<String, String>? get mailColors;@JsonKey(includeIfNull: false) List<MailSignatureEntity>? get mailSignatures;@JsonKey(includeIfNull: false) Map<String, int>? get defaultSignatures;@JsonKey(includeIfNull: false) Map<String, MailInboxFilterType>? get mailInboxFilterTypes;@JsonKey(includeIfNull: false) Map<String, List<String>>? get mailInboxFilterLabelIds;@JsonKey(includeIfNull: false) Map<String, ChatInboxFilterType>? get messageDmInboxFilterTypes;@JsonKey(includeIfNull: false) Map<String, ChatInboxFilterType>? get messageChannelInboxFilterTypes;@JsonKey(includeIfNull: false) String? get taskColorHex;@JsonKey(includeIfNull: false) int? get taskDefaultDurationInMinutes;@JsonKey(includeIfNull: false) InboxCalendarActionType? get inboxCalendarDoubleClickActionType;@JsonKey(includeIfNull: false) InboxCalendarActionType? get inboxCalendarDragActionType;@JsonKey(includeIfNull: false) InboxCalendarActionType? get inboxFloatingButtonActionType;@JsonKey(includeIfNull: false) TaskReminderOptionType? get defaultTaskReminderType;@JsonKey(includeIfNull: false) TaskReminderOptionType? get defaultAllDayTaskReminderType;@JsonKey(includeIfNull: false) CompletedTaskOptionType? get completedTaskOptionType;@JsonKey(includeIfNull: false) bool? get showUnreadChannelsOnly;@JsonKey(includeIfNull: false) bool? get showUnreadDmsOnly;@JsonKey(includeIfNull: false) SortChannelType? get sortChannelType;@JsonKey(includeIfNull: false) List<String>? get excludedChannelIds;@JsonKey(includeIfNull: false) MailPrefSwipeActionType? get mailSwipeRightActionType;@JsonKey(includeIfNull: false) MailPrefSwipeActionType? get mailSwipeLeftActionType;@JsonKey(includeIfNull: false) MailContentThemeType? get mailContentThemeType;@JsonKey(includeIfNull: false) int? get firstDayOfWeek;@JsonKey(includeIfNull: false) int? get weekViewStartWeekday;@JsonKey(includeIfNull: false) int? get defaultDurationInMinutes;@JsonKey(includeIfNull: false) String? get defaultCalendarId;@JsonKey(includeIfNull: false) Map<String, String>? get lastGmailHistoryIds;@JsonKey(includeIfNull: false) UpdateChannel? get updateChannel;@JsonKey(includeIfNull: false) bool? get taskCompletionSound;@JsonKey(includeIfNull: false) bool? get mobileAppOpened;@JsonKey(includeIfNull: false) bool? get desktopAppOpened;@JsonKey(includeIfNull: false) List<Map<String, String?>>? get quickLinks;@JsonKey(includeIfNull: false) UserSubscriptionEntity? get subscription;@JsonKey(includeIfNull: false) int? get lemonSqueezyCustomerId;@JsonKey(includeIfNull: false) bool? get isAdmin;@JsonKey(includeIfNull: false) bool? get includeConferenceLinkOnHomeTab;@JsonKey(includeIfNull: false) bool? get includeConferenceLinkOnCalendarTab;@JsonKey(includeIfNull: false) bool? get isFreeUser;@JsonKey(includeIfNull: false) List<UserTutorialType>? get userTutorialDoneList;@JsonKey(includeIfNull: false) double? get aiCredits;@JsonKey(includeIfNull: false) DateTime? get aiCreditsUpdatedAt;
/// Create a copy of UserEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserEntityCopyWith<UserEntity> get copyWith => _$UserEntityCopyWithImpl<UserEntity>(this as UserEntity, _$identity);

  /// Serializes this UserEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.email, email) || other.email == email)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.subscriptionEndAt, subscriptionEndAt) || other.subscriptionEndAt == subscriptionEndAt)&&(identical(other.badge, badge) || other.badge == badge)&&const DeepCollectionEquality().equals(other.calendarColors, calendarColors)&&const DeepCollectionEquality().equals(other.mailColors, mailColors)&&const DeepCollectionEquality().equals(other.mailSignatures, mailSignatures)&&const DeepCollectionEquality().equals(other.defaultSignatures, defaultSignatures)&&const DeepCollectionEquality().equals(other.mailInboxFilterTypes, mailInboxFilterTypes)&&const DeepCollectionEquality().equals(other.mailInboxFilterLabelIds, mailInboxFilterLabelIds)&&const DeepCollectionEquality().equals(other.messageDmInboxFilterTypes, messageDmInboxFilterTypes)&&const DeepCollectionEquality().equals(other.messageChannelInboxFilterTypes, messageChannelInboxFilterTypes)&&(identical(other.taskColorHex, taskColorHex) || other.taskColorHex == taskColorHex)&&(identical(other.taskDefaultDurationInMinutes, taskDefaultDurationInMinutes) || other.taskDefaultDurationInMinutes == taskDefaultDurationInMinutes)&&(identical(other.inboxCalendarDoubleClickActionType, inboxCalendarDoubleClickActionType) || other.inboxCalendarDoubleClickActionType == inboxCalendarDoubleClickActionType)&&(identical(other.inboxCalendarDragActionType, inboxCalendarDragActionType) || other.inboxCalendarDragActionType == inboxCalendarDragActionType)&&(identical(other.inboxFloatingButtonActionType, inboxFloatingButtonActionType) || other.inboxFloatingButtonActionType == inboxFloatingButtonActionType)&&(identical(other.defaultTaskReminderType, defaultTaskReminderType) || other.defaultTaskReminderType == defaultTaskReminderType)&&(identical(other.defaultAllDayTaskReminderType, defaultAllDayTaskReminderType) || other.defaultAllDayTaskReminderType == defaultAllDayTaskReminderType)&&(identical(other.completedTaskOptionType, completedTaskOptionType) || other.completedTaskOptionType == completedTaskOptionType)&&(identical(other.showUnreadChannelsOnly, showUnreadChannelsOnly) || other.showUnreadChannelsOnly == showUnreadChannelsOnly)&&(identical(other.showUnreadDmsOnly, showUnreadDmsOnly) || other.showUnreadDmsOnly == showUnreadDmsOnly)&&(identical(other.sortChannelType, sortChannelType) || other.sortChannelType == sortChannelType)&&const DeepCollectionEquality().equals(other.excludedChannelIds, excludedChannelIds)&&(identical(other.mailSwipeRightActionType, mailSwipeRightActionType) || other.mailSwipeRightActionType == mailSwipeRightActionType)&&(identical(other.mailSwipeLeftActionType, mailSwipeLeftActionType) || other.mailSwipeLeftActionType == mailSwipeLeftActionType)&&(identical(other.mailContentThemeType, mailContentThemeType) || other.mailContentThemeType == mailContentThemeType)&&(identical(other.firstDayOfWeek, firstDayOfWeek) || other.firstDayOfWeek == firstDayOfWeek)&&(identical(other.weekViewStartWeekday, weekViewStartWeekday) || other.weekViewStartWeekday == weekViewStartWeekday)&&(identical(other.defaultDurationInMinutes, defaultDurationInMinutes) || other.defaultDurationInMinutes == defaultDurationInMinutes)&&(identical(other.defaultCalendarId, defaultCalendarId) || other.defaultCalendarId == defaultCalendarId)&&const DeepCollectionEquality().equals(other.lastGmailHistoryIds, lastGmailHistoryIds)&&(identical(other.updateChannel, updateChannel) || other.updateChannel == updateChannel)&&(identical(other.taskCompletionSound, taskCompletionSound) || other.taskCompletionSound == taskCompletionSound)&&(identical(other.mobileAppOpened, mobileAppOpened) || other.mobileAppOpened == mobileAppOpened)&&(identical(other.desktopAppOpened, desktopAppOpened) || other.desktopAppOpened == desktopAppOpened)&&const DeepCollectionEquality().equals(other.quickLinks, quickLinks)&&(identical(other.subscription, subscription) || other.subscription == subscription)&&(identical(other.lemonSqueezyCustomerId, lemonSqueezyCustomerId) || other.lemonSqueezyCustomerId == lemonSqueezyCustomerId)&&(identical(other.isAdmin, isAdmin) || other.isAdmin == isAdmin)&&(identical(other.includeConferenceLinkOnHomeTab, includeConferenceLinkOnHomeTab) || other.includeConferenceLinkOnHomeTab == includeConferenceLinkOnHomeTab)&&(identical(other.includeConferenceLinkOnCalendarTab, includeConferenceLinkOnCalendarTab) || other.includeConferenceLinkOnCalendarTab == includeConferenceLinkOnCalendarTab)&&(identical(other.isFreeUser, isFreeUser) || other.isFreeUser == isFreeUser)&&const DeepCollectionEquality().equals(other.userTutorialDoneList, userTutorialDoneList)&&(identical(other.aiCredits, aiCredits) || other.aiCredits == aiCredits)&&(identical(other.aiCreditsUpdatedAt, aiCreditsUpdatedAt) || other.aiCreditsUpdatedAt == aiCreditsUpdatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,name,email,avatarUrl,createdAt,updatedAt,subscriptionEndAt,badge,const DeepCollectionEquality().hash(calendarColors),const DeepCollectionEquality().hash(mailColors),const DeepCollectionEquality().hash(mailSignatures),const DeepCollectionEquality().hash(defaultSignatures),const DeepCollectionEquality().hash(mailInboxFilterTypes),const DeepCollectionEquality().hash(mailInboxFilterLabelIds),const DeepCollectionEquality().hash(messageDmInboxFilterTypes),const DeepCollectionEquality().hash(messageChannelInboxFilterTypes),taskColorHex,taskDefaultDurationInMinutes,inboxCalendarDoubleClickActionType,inboxCalendarDragActionType,inboxFloatingButtonActionType,defaultTaskReminderType,defaultAllDayTaskReminderType,completedTaskOptionType,showUnreadChannelsOnly,showUnreadDmsOnly,sortChannelType,const DeepCollectionEquality().hash(excludedChannelIds),mailSwipeRightActionType,mailSwipeLeftActionType,mailContentThemeType,firstDayOfWeek,weekViewStartWeekday,defaultDurationInMinutes,defaultCalendarId,const DeepCollectionEquality().hash(lastGmailHistoryIds),updateChannel,taskCompletionSound,mobileAppOpened,desktopAppOpened,const DeepCollectionEquality().hash(quickLinks),subscription,lemonSqueezyCustomerId,isAdmin,includeConferenceLinkOnHomeTab,includeConferenceLinkOnCalendarTab,isFreeUser,const DeepCollectionEquality().hash(userTutorialDoneList),aiCredits,aiCreditsUpdatedAt]);

@override
String toString() {
  return 'UserEntity(id: $id, name: $name, email: $email, avatarUrl: $avatarUrl, createdAt: $createdAt, updatedAt: $updatedAt, subscriptionEndAt: $subscriptionEndAt, badge: $badge, calendarColors: $calendarColors, mailColors: $mailColors, mailSignatures: $mailSignatures, defaultSignatures: $defaultSignatures, mailInboxFilterTypes: $mailInboxFilterTypes, mailInboxFilterLabelIds: $mailInboxFilterLabelIds, messageDmInboxFilterTypes: $messageDmInboxFilterTypes, messageChannelInboxFilterTypes: $messageChannelInboxFilterTypes, taskColorHex: $taskColorHex, taskDefaultDurationInMinutes: $taskDefaultDurationInMinutes, inboxCalendarDoubleClickActionType: $inboxCalendarDoubleClickActionType, inboxCalendarDragActionType: $inboxCalendarDragActionType, inboxFloatingButtonActionType: $inboxFloatingButtonActionType, defaultTaskReminderType: $defaultTaskReminderType, defaultAllDayTaskReminderType: $defaultAllDayTaskReminderType, completedTaskOptionType: $completedTaskOptionType, showUnreadChannelsOnly: $showUnreadChannelsOnly, showUnreadDmsOnly: $showUnreadDmsOnly, sortChannelType: $sortChannelType, excludedChannelIds: $excludedChannelIds, mailSwipeRightActionType: $mailSwipeRightActionType, mailSwipeLeftActionType: $mailSwipeLeftActionType, mailContentThemeType: $mailContentThemeType, firstDayOfWeek: $firstDayOfWeek, weekViewStartWeekday: $weekViewStartWeekday, defaultDurationInMinutes: $defaultDurationInMinutes, defaultCalendarId: $defaultCalendarId, lastGmailHistoryIds: $lastGmailHistoryIds, updateChannel: $updateChannel, taskCompletionSound: $taskCompletionSound, mobileAppOpened: $mobileAppOpened, desktopAppOpened: $desktopAppOpened, quickLinks: $quickLinks, subscription: $subscription, lemonSqueezyCustomerId: $lemonSqueezyCustomerId, isAdmin: $isAdmin, includeConferenceLinkOnHomeTab: $includeConferenceLinkOnHomeTab, includeConferenceLinkOnCalendarTab: $includeConferenceLinkOnCalendarTab, isFreeUser: $isFreeUser, userTutorialDoneList: $userTutorialDoneList, aiCredits: $aiCredits, aiCreditsUpdatedAt: $aiCreditsUpdatedAt)';
}


}

/// @nodoc
abstract mixin class $UserEntityCopyWith<$Res>  {
  factory $UserEntityCopyWith(UserEntity value, $Res Function(UserEntity) _then) = _$UserEntityCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(includeIfNull: false) String? name,@JsonKey(includeIfNull: false) String? email,@JsonKey(includeIfNull: false) String? avatarUrl,@JsonKey(includeIfNull: false) DateTime? createdAt,@JsonKey(includeIfNull: false) DateTime? updatedAt,@JsonKey(includeIfNull: false) DateTime? subscriptionEndAt,@JsonKey(includeIfNull: false) int? badge,@JsonKey(includeIfNull: false) Map<String, String>? calendarColors,@JsonKey(includeIfNull: false) Map<String, String>? mailColors,@JsonKey(includeIfNull: false) List<MailSignatureEntity>? mailSignatures,@JsonKey(includeIfNull: false) Map<String, int>? defaultSignatures,@JsonKey(includeIfNull: false) Map<String, MailInboxFilterType>? mailInboxFilterTypes,@JsonKey(includeIfNull: false) Map<String, List<String>>? mailInboxFilterLabelIds,@JsonKey(includeIfNull: false) Map<String, ChatInboxFilterType>? messageDmInboxFilterTypes,@JsonKey(includeIfNull: false) Map<String, ChatInboxFilterType>? messageChannelInboxFilterTypes,@JsonKey(includeIfNull: false) String? taskColorHex,@JsonKey(includeIfNull: false) int? taskDefaultDurationInMinutes,@JsonKey(includeIfNull: false) InboxCalendarActionType? inboxCalendarDoubleClickActionType,@JsonKey(includeIfNull: false) InboxCalendarActionType? inboxCalendarDragActionType,@JsonKey(includeIfNull: false) InboxCalendarActionType? inboxFloatingButtonActionType,@JsonKey(includeIfNull: false) TaskReminderOptionType? defaultTaskReminderType,@JsonKey(includeIfNull: false) TaskReminderOptionType? defaultAllDayTaskReminderType,@JsonKey(includeIfNull: false) CompletedTaskOptionType? completedTaskOptionType,@JsonKey(includeIfNull: false) bool? showUnreadChannelsOnly,@JsonKey(includeIfNull: false) bool? showUnreadDmsOnly,@JsonKey(includeIfNull: false) SortChannelType? sortChannelType,@JsonKey(includeIfNull: false) List<String>? excludedChannelIds,@JsonKey(includeIfNull: false) MailPrefSwipeActionType? mailSwipeRightActionType,@JsonKey(includeIfNull: false) MailPrefSwipeActionType? mailSwipeLeftActionType,@JsonKey(includeIfNull: false) MailContentThemeType? mailContentThemeType,@JsonKey(includeIfNull: false) int? firstDayOfWeek,@JsonKey(includeIfNull: false) int? weekViewStartWeekday,@JsonKey(includeIfNull: false) int? defaultDurationInMinutes,@JsonKey(includeIfNull: false) String? defaultCalendarId,@JsonKey(includeIfNull: false) Map<String, String>? lastGmailHistoryIds,@JsonKey(includeIfNull: false) UpdateChannel? updateChannel,@JsonKey(includeIfNull: false) bool? taskCompletionSound,@JsonKey(includeIfNull: false) bool? mobileAppOpened,@JsonKey(includeIfNull: false) bool? desktopAppOpened,@JsonKey(includeIfNull: false) List<Map<String, String?>>? quickLinks,@JsonKey(includeIfNull: false) UserSubscriptionEntity? subscription,@JsonKey(includeIfNull: false) int? lemonSqueezyCustomerId,@JsonKey(includeIfNull: false) bool? isAdmin,@JsonKey(includeIfNull: false) bool? includeConferenceLinkOnHomeTab,@JsonKey(includeIfNull: false) bool? includeConferenceLinkOnCalendarTab,@JsonKey(includeIfNull: false) bool? isFreeUser,@JsonKey(includeIfNull: false) List<UserTutorialType>? userTutorialDoneList,@JsonKey(includeIfNull: false) double? aiCredits,@JsonKey(includeIfNull: false) DateTime? aiCreditsUpdatedAt
});


$UserSubscriptionEntityCopyWith<$Res>? get subscription;

}
/// @nodoc
class _$UserEntityCopyWithImpl<$Res>
    implements $UserEntityCopyWith<$Res> {
  _$UserEntityCopyWithImpl(this._self, this._then);

  final UserEntity _self;
  final $Res Function(UserEntity) _then;

/// Create a copy of UserEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = freezed,Object? email = freezed,Object? avatarUrl = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? subscriptionEndAt = freezed,Object? badge = freezed,Object? calendarColors = freezed,Object? mailColors = freezed,Object? mailSignatures = freezed,Object? defaultSignatures = freezed,Object? mailInboxFilterTypes = freezed,Object? mailInboxFilterLabelIds = freezed,Object? messageDmInboxFilterTypes = freezed,Object? messageChannelInboxFilterTypes = freezed,Object? taskColorHex = freezed,Object? taskDefaultDurationInMinutes = freezed,Object? inboxCalendarDoubleClickActionType = freezed,Object? inboxCalendarDragActionType = freezed,Object? inboxFloatingButtonActionType = freezed,Object? defaultTaskReminderType = freezed,Object? defaultAllDayTaskReminderType = freezed,Object? completedTaskOptionType = freezed,Object? showUnreadChannelsOnly = freezed,Object? showUnreadDmsOnly = freezed,Object? sortChannelType = freezed,Object? excludedChannelIds = freezed,Object? mailSwipeRightActionType = freezed,Object? mailSwipeLeftActionType = freezed,Object? mailContentThemeType = freezed,Object? firstDayOfWeek = freezed,Object? weekViewStartWeekday = freezed,Object? defaultDurationInMinutes = freezed,Object? defaultCalendarId = freezed,Object? lastGmailHistoryIds = freezed,Object? updateChannel = freezed,Object? taskCompletionSound = freezed,Object? mobileAppOpened = freezed,Object? desktopAppOpened = freezed,Object? quickLinks = freezed,Object? subscription = freezed,Object? lemonSqueezyCustomerId = freezed,Object? isAdmin = freezed,Object? includeConferenceLinkOnHomeTab = freezed,Object? includeConferenceLinkOnCalendarTab = freezed,Object? isFreeUser = freezed,Object? userTutorialDoneList = freezed,Object? aiCredits = freezed,Object? aiCreditsUpdatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,subscriptionEndAt: freezed == subscriptionEndAt ? _self.subscriptionEndAt : subscriptionEndAt // ignore: cast_nullable_to_non_nullable
as DateTime?,badge: freezed == badge ? _self.badge : badge // ignore: cast_nullable_to_non_nullable
as int?,calendarColors: freezed == calendarColors ? _self.calendarColors : calendarColors // ignore: cast_nullable_to_non_nullable
as Map<String, String>?,mailColors: freezed == mailColors ? _self.mailColors : mailColors // ignore: cast_nullable_to_non_nullable
as Map<String, String>?,mailSignatures: freezed == mailSignatures ? _self.mailSignatures : mailSignatures // ignore: cast_nullable_to_non_nullable
as List<MailSignatureEntity>?,defaultSignatures: freezed == defaultSignatures ? _self.defaultSignatures : defaultSignatures // ignore: cast_nullable_to_non_nullable
as Map<String, int>?,mailInboxFilterTypes: freezed == mailInboxFilterTypes ? _self.mailInboxFilterTypes : mailInboxFilterTypes // ignore: cast_nullable_to_non_nullable
as Map<String, MailInboxFilterType>?,mailInboxFilterLabelIds: freezed == mailInboxFilterLabelIds ? _self.mailInboxFilterLabelIds : mailInboxFilterLabelIds // ignore: cast_nullable_to_non_nullable
as Map<String, List<String>>?,messageDmInboxFilterTypes: freezed == messageDmInboxFilterTypes ? _self.messageDmInboxFilterTypes : messageDmInboxFilterTypes // ignore: cast_nullable_to_non_nullable
as Map<String, ChatInboxFilterType>?,messageChannelInboxFilterTypes: freezed == messageChannelInboxFilterTypes ? _self.messageChannelInboxFilterTypes : messageChannelInboxFilterTypes // ignore: cast_nullable_to_non_nullable
as Map<String, ChatInboxFilterType>?,taskColorHex: freezed == taskColorHex ? _self.taskColorHex : taskColorHex // ignore: cast_nullable_to_non_nullable
as String?,taskDefaultDurationInMinutes: freezed == taskDefaultDurationInMinutes ? _self.taskDefaultDurationInMinutes : taskDefaultDurationInMinutes // ignore: cast_nullable_to_non_nullable
as int?,inboxCalendarDoubleClickActionType: freezed == inboxCalendarDoubleClickActionType ? _self.inboxCalendarDoubleClickActionType : inboxCalendarDoubleClickActionType // ignore: cast_nullable_to_non_nullable
as InboxCalendarActionType?,inboxCalendarDragActionType: freezed == inboxCalendarDragActionType ? _self.inboxCalendarDragActionType : inboxCalendarDragActionType // ignore: cast_nullable_to_non_nullable
as InboxCalendarActionType?,inboxFloatingButtonActionType: freezed == inboxFloatingButtonActionType ? _self.inboxFloatingButtonActionType : inboxFloatingButtonActionType // ignore: cast_nullable_to_non_nullable
as InboxCalendarActionType?,defaultTaskReminderType: freezed == defaultTaskReminderType ? _self.defaultTaskReminderType : defaultTaskReminderType // ignore: cast_nullable_to_non_nullable
as TaskReminderOptionType?,defaultAllDayTaskReminderType: freezed == defaultAllDayTaskReminderType ? _self.defaultAllDayTaskReminderType : defaultAllDayTaskReminderType // ignore: cast_nullable_to_non_nullable
as TaskReminderOptionType?,completedTaskOptionType: freezed == completedTaskOptionType ? _self.completedTaskOptionType : completedTaskOptionType // ignore: cast_nullable_to_non_nullable
as CompletedTaskOptionType?,showUnreadChannelsOnly: freezed == showUnreadChannelsOnly ? _self.showUnreadChannelsOnly : showUnreadChannelsOnly // ignore: cast_nullable_to_non_nullable
as bool?,showUnreadDmsOnly: freezed == showUnreadDmsOnly ? _self.showUnreadDmsOnly : showUnreadDmsOnly // ignore: cast_nullable_to_non_nullable
as bool?,sortChannelType: freezed == sortChannelType ? _self.sortChannelType : sortChannelType // ignore: cast_nullable_to_non_nullable
as SortChannelType?,excludedChannelIds: freezed == excludedChannelIds ? _self.excludedChannelIds : excludedChannelIds // ignore: cast_nullable_to_non_nullable
as List<String>?,mailSwipeRightActionType: freezed == mailSwipeRightActionType ? _self.mailSwipeRightActionType : mailSwipeRightActionType // ignore: cast_nullable_to_non_nullable
as MailPrefSwipeActionType?,mailSwipeLeftActionType: freezed == mailSwipeLeftActionType ? _self.mailSwipeLeftActionType : mailSwipeLeftActionType // ignore: cast_nullable_to_non_nullable
as MailPrefSwipeActionType?,mailContentThemeType: freezed == mailContentThemeType ? _self.mailContentThemeType : mailContentThemeType // ignore: cast_nullable_to_non_nullable
as MailContentThemeType?,firstDayOfWeek: freezed == firstDayOfWeek ? _self.firstDayOfWeek : firstDayOfWeek // ignore: cast_nullable_to_non_nullable
as int?,weekViewStartWeekday: freezed == weekViewStartWeekday ? _self.weekViewStartWeekday : weekViewStartWeekday // ignore: cast_nullable_to_non_nullable
as int?,defaultDurationInMinutes: freezed == defaultDurationInMinutes ? _self.defaultDurationInMinutes : defaultDurationInMinutes // ignore: cast_nullable_to_non_nullable
as int?,defaultCalendarId: freezed == defaultCalendarId ? _self.defaultCalendarId : defaultCalendarId // ignore: cast_nullable_to_non_nullable
as String?,lastGmailHistoryIds: freezed == lastGmailHistoryIds ? _self.lastGmailHistoryIds : lastGmailHistoryIds // ignore: cast_nullable_to_non_nullable
as Map<String, String>?,updateChannel: freezed == updateChannel ? _self.updateChannel : updateChannel // ignore: cast_nullable_to_non_nullable
as UpdateChannel?,taskCompletionSound: freezed == taskCompletionSound ? _self.taskCompletionSound : taskCompletionSound // ignore: cast_nullable_to_non_nullable
as bool?,mobileAppOpened: freezed == mobileAppOpened ? _self.mobileAppOpened : mobileAppOpened // ignore: cast_nullable_to_non_nullable
as bool?,desktopAppOpened: freezed == desktopAppOpened ? _self.desktopAppOpened : desktopAppOpened // ignore: cast_nullable_to_non_nullable
as bool?,quickLinks: freezed == quickLinks ? _self.quickLinks : quickLinks // ignore: cast_nullable_to_non_nullable
as List<Map<String, String?>>?,subscription: freezed == subscription ? _self.subscription : subscription // ignore: cast_nullable_to_non_nullable
as UserSubscriptionEntity?,lemonSqueezyCustomerId: freezed == lemonSqueezyCustomerId ? _self.lemonSqueezyCustomerId : lemonSqueezyCustomerId // ignore: cast_nullable_to_non_nullable
as int?,isAdmin: freezed == isAdmin ? _self.isAdmin : isAdmin // ignore: cast_nullable_to_non_nullable
as bool?,includeConferenceLinkOnHomeTab: freezed == includeConferenceLinkOnHomeTab ? _self.includeConferenceLinkOnHomeTab : includeConferenceLinkOnHomeTab // ignore: cast_nullable_to_non_nullable
as bool?,includeConferenceLinkOnCalendarTab: freezed == includeConferenceLinkOnCalendarTab ? _self.includeConferenceLinkOnCalendarTab : includeConferenceLinkOnCalendarTab // ignore: cast_nullable_to_non_nullable
as bool?,isFreeUser: freezed == isFreeUser ? _self.isFreeUser : isFreeUser // ignore: cast_nullable_to_non_nullable
as bool?,userTutorialDoneList: freezed == userTutorialDoneList ? _self.userTutorialDoneList : userTutorialDoneList // ignore: cast_nullable_to_non_nullable
as List<UserTutorialType>?,aiCredits: freezed == aiCredits ? _self.aiCredits : aiCredits // ignore: cast_nullable_to_non_nullable
as double?,aiCreditsUpdatedAt: freezed == aiCreditsUpdatedAt ? _self.aiCreditsUpdatedAt : aiCreditsUpdatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of UserEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserSubscriptionEntityCopyWith<$Res>? get subscription {
    if (_self.subscription == null) {
    return null;
  }

  return $UserSubscriptionEntityCopyWith<$Res>(_self.subscription!, (value) {
    return _then(_self.copyWith(subscription: value));
  });
}
}


/// Adds pattern-matching-related methods to [UserEntity].
extension UserEntityPatterns on UserEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserEntity value)  $default,){
final _that = this;
switch (_that) {
case _UserEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserEntity value)?  $default,){
final _that = this;
switch (_that) {
case _UserEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(includeIfNull: false)  String? name, @JsonKey(includeIfNull: false)  String? email, @JsonKey(includeIfNull: false)  String? avatarUrl, @JsonKey(includeIfNull: false)  DateTime? createdAt, @JsonKey(includeIfNull: false)  DateTime? updatedAt, @JsonKey(includeIfNull: false)  DateTime? subscriptionEndAt, @JsonKey(includeIfNull: false)  int? badge, @JsonKey(includeIfNull: false)  Map<String, String>? calendarColors, @JsonKey(includeIfNull: false)  Map<String, String>? mailColors, @JsonKey(includeIfNull: false)  List<MailSignatureEntity>? mailSignatures, @JsonKey(includeIfNull: false)  Map<String, int>? defaultSignatures, @JsonKey(includeIfNull: false)  Map<String, MailInboxFilterType>? mailInboxFilterTypes, @JsonKey(includeIfNull: false)  Map<String, List<String>>? mailInboxFilterLabelIds, @JsonKey(includeIfNull: false)  Map<String, ChatInboxFilterType>? messageDmInboxFilterTypes, @JsonKey(includeIfNull: false)  Map<String, ChatInboxFilterType>? messageChannelInboxFilterTypes, @JsonKey(includeIfNull: false)  String? taskColorHex, @JsonKey(includeIfNull: false)  int? taskDefaultDurationInMinutes, @JsonKey(includeIfNull: false)  InboxCalendarActionType? inboxCalendarDoubleClickActionType, @JsonKey(includeIfNull: false)  InboxCalendarActionType? inboxCalendarDragActionType, @JsonKey(includeIfNull: false)  InboxCalendarActionType? inboxFloatingButtonActionType, @JsonKey(includeIfNull: false)  TaskReminderOptionType? defaultTaskReminderType, @JsonKey(includeIfNull: false)  TaskReminderOptionType? defaultAllDayTaskReminderType, @JsonKey(includeIfNull: false)  CompletedTaskOptionType? completedTaskOptionType, @JsonKey(includeIfNull: false)  bool? showUnreadChannelsOnly, @JsonKey(includeIfNull: false)  bool? showUnreadDmsOnly, @JsonKey(includeIfNull: false)  SortChannelType? sortChannelType, @JsonKey(includeIfNull: false)  List<String>? excludedChannelIds, @JsonKey(includeIfNull: false)  MailPrefSwipeActionType? mailSwipeRightActionType, @JsonKey(includeIfNull: false)  MailPrefSwipeActionType? mailSwipeLeftActionType, @JsonKey(includeIfNull: false)  MailContentThemeType? mailContentThemeType, @JsonKey(includeIfNull: false)  int? firstDayOfWeek, @JsonKey(includeIfNull: false)  int? weekViewStartWeekday, @JsonKey(includeIfNull: false)  int? defaultDurationInMinutes, @JsonKey(includeIfNull: false)  String? defaultCalendarId, @JsonKey(includeIfNull: false)  Map<String, String>? lastGmailHistoryIds, @JsonKey(includeIfNull: false)  UpdateChannel? updateChannel, @JsonKey(includeIfNull: false)  bool? taskCompletionSound, @JsonKey(includeIfNull: false)  bool? mobileAppOpened, @JsonKey(includeIfNull: false)  bool? desktopAppOpened, @JsonKey(includeIfNull: false)  List<Map<String, String?>>? quickLinks, @JsonKey(includeIfNull: false)  UserSubscriptionEntity? subscription, @JsonKey(includeIfNull: false)  int? lemonSqueezyCustomerId, @JsonKey(includeIfNull: false)  bool? isAdmin, @JsonKey(includeIfNull: false)  bool? includeConferenceLinkOnHomeTab, @JsonKey(includeIfNull: false)  bool? includeConferenceLinkOnCalendarTab, @JsonKey(includeIfNull: false)  bool? isFreeUser, @JsonKey(includeIfNull: false)  List<UserTutorialType>? userTutorialDoneList, @JsonKey(includeIfNull: false)  double? aiCredits, @JsonKey(includeIfNull: false)  DateTime? aiCreditsUpdatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserEntity() when $default != null:
return $default(_that.id,_that.name,_that.email,_that.avatarUrl,_that.createdAt,_that.updatedAt,_that.subscriptionEndAt,_that.badge,_that.calendarColors,_that.mailColors,_that.mailSignatures,_that.defaultSignatures,_that.mailInboxFilterTypes,_that.mailInboxFilterLabelIds,_that.messageDmInboxFilterTypes,_that.messageChannelInboxFilterTypes,_that.taskColorHex,_that.taskDefaultDurationInMinutes,_that.inboxCalendarDoubleClickActionType,_that.inboxCalendarDragActionType,_that.inboxFloatingButtonActionType,_that.defaultTaskReminderType,_that.defaultAllDayTaskReminderType,_that.completedTaskOptionType,_that.showUnreadChannelsOnly,_that.showUnreadDmsOnly,_that.sortChannelType,_that.excludedChannelIds,_that.mailSwipeRightActionType,_that.mailSwipeLeftActionType,_that.mailContentThemeType,_that.firstDayOfWeek,_that.weekViewStartWeekday,_that.defaultDurationInMinutes,_that.defaultCalendarId,_that.lastGmailHistoryIds,_that.updateChannel,_that.taskCompletionSound,_that.mobileAppOpened,_that.desktopAppOpened,_that.quickLinks,_that.subscription,_that.lemonSqueezyCustomerId,_that.isAdmin,_that.includeConferenceLinkOnHomeTab,_that.includeConferenceLinkOnCalendarTab,_that.isFreeUser,_that.userTutorialDoneList,_that.aiCredits,_that.aiCreditsUpdatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(includeIfNull: false)  String? name, @JsonKey(includeIfNull: false)  String? email, @JsonKey(includeIfNull: false)  String? avatarUrl, @JsonKey(includeIfNull: false)  DateTime? createdAt, @JsonKey(includeIfNull: false)  DateTime? updatedAt, @JsonKey(includeIfNull: false)  DateTime? subscriptionEndAt, @JsonKey(includeIfNull: false)  int? badge, @JsonKey(includeIfNull: false)  Map<String, String>? calendarColors, @JsonKey(includeIfNull: false)  Map<String, String>? mailColors, @JsonKey(includeIfNull: false)  List<MailSignatureEntity>? mailSignatures, @JsonKey(includeIfNull: false)  Map<String, int>? defaultSignatures, @JsonKey(includeIfNull: false)  Map<String, MailInboxFilterType>? mailInboxFilterTypes, @JsonKey(includeIfNull: false)  Map<String, List<String>>? mailInboxFilterLabelIds, @JsonKey(includeIfNull: false)  Map<String, ChatInboxFilterType>? messageDmInboxFilterTypes, @JsonKey(includeIfNull: false)  Map<String, ChatInboxFilterType>? messageChannelInboxFilterTypes, @JsonKey(includeIfNull: false)  String? taskColorHex, @JsonKey(includeIfNull: false)  int? taskDefaultDurationInMinutes, @JsonKey(includeIfNull: false)  InboxCalendarActionType? inboxCalendarDoubleClickActionType, @JsonKey(includeIfNull: false)  InboxCalendarActionType? inboxCalendarDragActionType, @JsonKey(includeIfNull: false)  InboxCalendarActionType? inboxFloatingButtonActionType, @JsonKey(includeIfNull: false)  TaskReminderOptionType? defaultTaskReminderType, @JsonKey(includeIfNull: false)  TaskReminderOptionType? defaultAllDayTaskReminderType, @JsonKey(includeIfNull: false)  CompletedTaskOptionType? completedTaskOptionType, @JsonKey(includeIfNull: false)  bool? showUnreadChannelsOnly, @JsonKey(includeIfNull: false)  bool? showUnreadDmsOnly, @JsonKey(includeIfNull: false)  SortChannelType? sortChannelType, @JsonKey(includeIfNull: false)  List<String>? excludedChannelIds, @JsonKey(includeIfNull: false)  MailPrefSwipeActionType? mailSwipeRightActionType, @JsonKey(includeIfNull: false)  MailPrefSwipeActionType? mailSwipeLeftActionType, @JsonKey(includeIfNull: false)  MailContentThemeType? mailContentThemeType, @JsonKey(includeIfNull: false)  int? firstDayOfWeek, @JsonKey(includeIfNull: false)  int? weekViewStartWeekday, @JsonKey(includeIfNull: false)  int? defaultDurationInMinutes, @JsonKey(includeIfNull: false)  String? defaultCalendarId, @JsonKey(includeIfNull: false)  Map<String, String>? lastGmailHistoryIds, @JsonKey(includeIfNull: false)  UpdateChannel? updateChannel, @JsonKey(includeIfNull: false)  bool? taskCompletionSound, @JsonKey(includeIfNull: false)  bool? mobileAppOpened, @JsonKey(includeIfNull: false)  bool? desktopAppOpened, @JsonKey(includeIfNull: false)  List<Map<String, String?>>? quickLinks, @JsonKey(includeIfNull: false)  UserSubscriptionEntity? subscription, @JsonKey(includeIfNull: false)  int? lemonSqueezyCustomerId, @JsonKey(includeIfNull: false)  bool? isAdmin, @JsonKey(includeIfNull: false)  bool? includeConferenceLinkOnHomeTab, @JsonKey(includeIfNull: false)  bool? includeConferenceLinkOnCalendarTab, @JsonKey(includeIfNull: false)  bool? isFreeUser, @JsonKey(includeIfNull: false)  List<UserTutorialType>? userTutorialDoneList, @JsonKey(includeIfNull: false)  double? aiCredits, @JsonKey(includeIfNull: false)  DateTime? aiCreditsUpdatedAt)  $default,) {final _that = this;
switch (_that) {
case _UserEntity():
return $default(_that.id,_that.name,_that.email,_that.avatarUrl,_that.createdAt,_that.updatedAt,_that.subscriptionEndAt,_that.badge,_that.calendarColors,_that.mailColors,_that.mailSignatures,_that.defaultSignatures,_that.mailInboxFilterTypes,_that.mailInboxFilterLabelIds,_that.messageDmInboxFilterTypes,_that.messageChannelInboxFilterTypes,_that.taskColorHex,_that.taskDefaultDurationInMinutes,_that.inboxCalendarDoubleClickActionType,_that.inboxCalendarDragActionType,_that.inboxFloatingButtonActionType,_that.defaultTaskReminderType,_that.defaultAllDayTaskReminderType,_that.completedTaskOptionType,_that.showUnreadChannelsOnly,_that.showUnreadDmsOnly,_that.sortChannelType,_that.excludedChannelIds,_that.mailSwipeRightActionType,_that.mailSwipeLeftActionType,_that.mailContentThemeType,_that.firstDayOfWeek,_that.weekViewStartWeekday,_that.defaultDurationInMinutes,_that.defaultCalendarId,_that.lastGmailHistoryIds,_that.updateChannel,_that.taskCompletionSound,_that.mobileAppOpened,_that.desktopAppOpened,_that.quickLinks,_that.subscription,_that.lemonSqueezyCustomerId,_that.isAdmin,_that.includeConferenceLinkOnHomeTab,_that.includeConferenceLinkOnCalendarTab,_that.isFreeUser,_that.userTutorialDoneList,_that.aiCredits,_that.aiCreditsUpdatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(includeIfNull: false)  String? name, @JsonKey(includeIfNull: false)  String? email, @JsonKey(includeIfNull: false)  String? avatarUrl, @JsonKey(includeIfNull: false)  DateTime? createdAt, @JsonKey(includeIfNull: false)  DateTime? updatedAt, @JsonKey(includeIfNull: false)  DateTime? subscriptionEndAt, @JsonKey(includeIfNull: false)  int? badge, @JsonKey(includeIfNull: false)  Map<String, String>? calendarColors, @JsonKey(includeIfNull: false)  Map<String, String>? mailColors, @JsonKey(includeIfNull: false)  List<MailSignatureEntity>? mailSignatures, @JsonKey(includeIfNull: false)  Map<String, int>? defaultSignatures, @JsonKey(includeIfNull: false)  Map<String, MailInboxFilterType>? mailInboxFilterTypes, @JsonKey(includeIfNull: false)  Map<String, List<String>>? mailInboxFilterLabelIds, @JsonKey(includeIfNull: false)  Map<String, ChatInboxFilterType>? messageDmInboxFilterTypes, @JsonKey(includeIfNull: false)  Map<String, ChatInboxFilterType>? messageChannelInboxFilterTypes, @JsonKey(includeIfNull: false)  String? taskColorHex, @JsonKey(includeIfNull: false)  int? taskDefaultDurationInMinutes, @JsonKey(includeIfNull: false)  InboxCalendarActionType? inboxCalendarDoubleClickActionType, @JsonKey(includeIfNull: false)  InboxCalendarActionType? inboxCalendarDragActionType, @JsonKey(includeIfNull: false)  InboxCalendarActionType? inboxFloatingButtonActionType, @JsonKey(includeIfNull: false)  TaskReminderOptionType? defaultTaskReminderType, @JsonKey(includeIfNull: false)  TaskReminderOptionType? defaultAllDayTaskReminderType, @JsonKey(includeIfNull: false)  CompletedTaskOptionType? completedTaskOptionType, @JsonKey(includeIfNull: false)  bool? showUnreadChannelsOnly, @JsonKey(includeIfNull: false)  bool? showUnreadDmsOnly, @JsonKey(includeIfNull: false)  SortChannelType? sortChannelType, @JsonKey(includeIfNull: false)  List<String>? excludedChannelIds, @JsonKey(includeIfNull: false)  MailPrefSwipeActionType? mailSwipeRightActionType, @JsonKey(includeIfNull: false)  MailPrefSwipeActionType? mailSwipeLeftActionType, @JsonKey(includeIfNull: false)  MailContentThemeType? mailContentThemeType, @JsonKey(includeIfNull: false)  int? firstDayOfWeek, @JsonKey(includeIfNull: false)  int? weekViewStartWeekday, @JsonKey(includeIfNull: false)  int? defaultDurationInMinutes, @JsonKey(includeIfNull: false)  String? defaultCalendarId, @JsonKey(includeIfNull: false)  Map<String, String>? lastGmailHistoryIds, @JsonKey(includeIfNull: false)  UpdateChannel? updateChannel, @JsonKey(includeIfNull: false)  bool? taskCompletionSound, @JsonKey(includeIfNull: false)  bool? mobileAppOpened, @JsonKey(includeIfNull: false)  bool? desktopAppOpened, @JsonKey(includeIfNull: false)  List<Map<String, String?>>? quickLinks, @JsonKey(includeIfNull: false)  UserSubscriptionEntity? subscription, @JsonKey(includeIfNull: false)  int? lemonSqueezyCustomerId, @JsonKey(includeIfNull: false)  bool? isAdmin, @JsonKey(includeIfNull: false)  bool? includeConferenceLinkOnHomeTab, @JsonKey(includeIfNull: false)  bool? includeConferenceLinkOnCalendarTab, @JsonKey(includeIfNull: false)  bool? isFreeUser, @JsonKey(includeIfNull: false)  List<UserTutorialType>? userTutorialDoneList, @JsonKey(includeIfNull: false)  double? aiCredits, @JsonKey(includeIfNull: false)  DateTime? aiCreditsUpdatedAt)?  $default,) {final _that = this;
switch (_that) {
case _UserEntity() when $default != null:
return $default(_that.id,_that.name,_that.email,_that.avatarUrl,_that.createdAt,_that.updatedAt,_that.subscriptionEndAt,_that.badge,_that.calendarColors,_that.mailColors,_that.mailSignatures,_that.defaultSignatures,_that.mailInboxFilterTypes,_that.mailInboxFilterLabelIds,_that.messageDmInboxFilterTypes,_that.messageChannelInboxFilterTypes,_that.taskColorHex,_that.taskDefaultDurationInMinutes,_that.inboxCalendarDoubleClickActionType,_that.inboxCalendarDragActionType,_that.inboxFloatingButtonActionType,_that.defaultTaskReminderType,_that.defaultAllDayTaskReminderType,_that.completedTaskOptionType,_that.showUnreadChannelsOnly,_that.showUnreadDmsOnly,_that.sortChannelType,_that.excludedChannelIds,_that.mailSwipeRightActionType,_that.mailSwipeLeftActionType,_that.mailContentThemeType,_that.firstDayOfWeek,_that.weekViewStartWeekday,_that.defaultDurationInMinutes,_that.defaultCalendarId,_that.lastGmailHistoryIds,_that.updateChannel,_that.taskCompletionSound,_that.mobileAppOpened,_that.desktopAppOpened,_that.quickLinks,_that.subscription,_that.lemonSqueezyCustomerId,_that.isAdmin,_that.includeConferenceLinkOnHomeTab,_that.includeConferenceLinkOnCalendarTab,_that.isFreeUser,_that.userTutorialDoneList,_that.aiCredits,_that.aiCreditsUpdatedAt);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _UserEntity extends UserEntity {
  const _UserEntity({required this.id, @JsonKey(includeIfNull: false) this.name, @JsonKey(includeIfNull: false) this.email, @JsonKey(includeIfNull: false) this.avatarUrl, @JsonKey(includeIfNull: false) this.createdAt, @JsonKey(includeIfNull: false) this.updatedAt, @JsonKey(includeIfNull: false) this.subscriptionEndAt, @JsonKey(includeIfNull: false) this.badge, @JsonKey(includeIfNull: false) final  Map<String, String>? calendarColors, @JsonKey(includeIfNull: false) final  Map<String, String>? mailColors, @JsonKey(includeIfNull: false) final  List<MailSignatureEntity>? mailSignatures, @JsonKey(includeIfNull: false) final  Map<String, int>? defaultSignatures, @JsonKey(includeIfNull: false) final  Map<String, MailInboxFilterType>? mailInboxFilterTypes, @JsonKey(includeIfNull: false) final  Map<String, List<String>>? mailInboxFilterLabelIds, @JsonKey(includeIfNull: false) final  Map<String, ChatInboxFilterType>? messageDmInboxFilterTypes, @JsonKey(includeIfNull: false) final  Map<String, ChatInboxFilterType>? messageChannelInboxFilterTypes, @JsonKey(includeIfNull: false) this.taskColorHex, @JsonKey(includeIfNull: false) this.taskDefaultDurationInMinutes, @JsonKey(includeIfNull: false) this.inboxCalendarDoubleClickActionType, @JsonKey(includeIfNull: false) this.inboxCalendarDragActionType, @JsonKey(includeIfNull: false) this.inboxFloatingButtonActionType, @JsonKey(includeIfNull: false) this.defaultTaskReminderType, @JsonKey(includeIfNull: false) this.defaultAllDayTaskReminderType, @JsonKey(includeIfNull: false) this.completedTaskOptionType, @JsonKey(includeIfNull: false) this.showUnreadChannelsOnly, @JsonKey(includeIfNull: false) this.showUnreadDmsOnly, @JsonKey(includeIfNull: false) this.sortChannelType, @JsonKey(includeIfNull: false) final  List<String>? excludedChannelIds, @JsonKey(includeIfNull: false) this.mailSwipeRightActionType, @JsonKey(includeIfNull: false) this.mailSwipeLeftActionType, @JsonKey(includeIfNull: false) this.mailContentThemeType, @JsonKey(includeIfNull: false) this.firstDayOfWeek, @JsonKey(includeIfNull: false) this.weekViewStartWeekday, @JsonKey(includeIfNull: false) this.defaultDurationInMinutes, @JsonKey(includeIfNull: false) this.defaultCalendarId, @JsonKey(includeIfNull: false) final  Map<String, String>? lastGmailHistoryIds, @JsonKey(includeIfNull: false) this.updateChannel, @JsonKey(includeIfNull: false) this.taskCompletionSound, @JsonKey(includeIfNull: false) this.mobileAppOpened, @JsonKey(includeIfNull: false) this.desktopAppOpened, @JsonKey(includeIfNull: false) final  List<Map<String, String?>>? quickLinks, @JsonKey(includeIfNull: false) this.subscription, @JsonKey(includeIfNull: false) this.lemonSqueezyCustomerId, @JsonKey(includeIfNull: false) this.isAdmin, @JsonKey(includeIfNull: false) this.includeConferenceLinkOnHomeTab, @JsonKey(includeIfNull: false) this.includeConferenceLinkOnCalendarTab, @JsonKey(includeIfNull: false) this.isFreeUser, @JsonKey(includeIfNull: false) final  List<UserTutorialType>? userTutorialDoneList, @JsonKey(includeIfNull: false) this.aiCredits, @JsonKey(includeIfNull: false) this.aiCreditsUpdatedAt}): _calendarColors = calendarColors,_mailColors = mailColors,_mailSignatures = mailSignatures,_defaultSignatures = defaultSignatures,_mailInboxFilterTypes = mailInboxFilterTypes,_mailInboxFilterLabelIds = mailInboxFilterLabelIds,_messageDmInboxFilterTypes = messageDmInboxFilterTypes,_messageChannelInboxFilterTypes = messageChannelInboxFilterTypes,_excludedChannelIds = excludedChannelIds,_lastGmailHistoryIds = lastGmailHistoryIds,_quickLinks = quickLinks,_userTutorialDoneList = userTutorialDoneList,super._();
  factory _UserEntity.fromJson(Map<String, dynamic> json) => _$UserEntityFromJson(json);

@override final  String id;
@override@JsonKey(includeIfNull: false) final  String? name;
@override@JsonKey(includeIfNull: false) final  String? email;
@override@JsonKey(includeIfNull: false) final  String? avatarUrl;
@override@JsonKey(includeIfNull: false) final  DateTime? createdAt;
@override@JsonKey(includeIfNull: false) final  DateTime? updatedAt;
@override@JsonKey(includeIfNull: false) final  DateTime? subscriptionEndAt;
@override@JsonKey(includeIfNull: false) final  int? badge;
 final  Map<String, String>? _calendarColors;
@override@JsonKey(includeIfNull: false) Map<String, String>? get calendarColors {
  final value = _calendarColors;
  if (value == null) return null;
  if (_calendarColors is EqualUnmodifiableMapView) return _calendarColors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  Map<String, String>? _mailColors;
@override@JsonKey(includeIfNull: false) Map<String, String>? get mailColors {
  final value = _mailColors;
  if (value == null) return null;
  if (_mailColors is EqualUnmodifiableMapView) return _mailColors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  List<MailSignatureEntity>? _mailSignatures;
@override@JsonKey(includeIfNull: false) List<MailSignatureEntity>? get mailSignatures {
  final value = _mailSignatures;
  if (value == null) return null;
  if (_mailSignatures is EqualUnmodifiableListView) return _mailSignatures;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  Map<String, int>? _defaultSignatures;
@override@JsonKey(includeIfNull: false) Map<String, int>? get defaultSignatures {
  final value = _defaultSignatures;
  if (value == null) return null;
  if (_defaultSignatures is EqualUnmodifiableMapView) return _defaultSignatures;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  Map<String, MailInboxFilterType>? _mailInboxFilterTypes;
@override@JsonKey(includeIfNull: false) Map<String, MailInboxFilterType>? get mailInboxFilterTypes {
  final value = _mailInboxFilterTypes;
  if (value == null) return null;
  if (_mailInboxFilterTypes is EqualUnmodifiableMapView) return _mailInboxFilterTypes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  Map<String, List<String>>? _mailInboxFilterLabelIds;
@override@JsonKey(includeIfNull: false) Map<String, List<String>>? get mailInboxFilterLabelIds {
  final value = _mailInboxFilterLabelIds;
  if (value == null) return null;
  if (_mailInboxFilterLabelIds is EqualUnmodifiableMapView) return _mailInboxFilterLabelIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  Map<String, ChatInboxFilterType>? _messageDmInboxFilterTypes;
@override@JsonKey(includeIfNull: false) Map<String, ChatInboxFilterType>? get messageDmInboxFilterTypes {
  final value = _messageDmInboxFilterTypes;
  if (value == null) return null;
  if (_messageDmInboxFilterTypes is EqualUnmodifiableMapView) return _messageDmInboxFilterTypes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  Map<String, ChatInboxFilterType>? _messageChannelInboxFilterTypes;
@override@JsonKey(includeIfNull: false) Map<String, ChatInboxFilterType>? get messageChannelInboxFilterTypes {
  final value = _messageChannelInboxFilterTypes;
  if (value == null) return null;
  if (_messageChannelInboxFilterTypes is EqualUnmodifiableMapView) return _messageChannelInboxFilterTypes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override@JsonKey(includeIfNull: false) final  String? taskColorHex;
@override@JsonKey(includeIfNull: false) final  int? taskDefaultDurationInMinutes;
@override@JsonKey(includeIfNull: false) final  InboxCalendarActionType? inboxCalendarDoubleClickActionType;
@override@JsonKey(includeIfNull: false) final  InboxCalendarActionType? inboxCalendarDragActionType;
@override@JsonKey(includeIfNull: false) final  InboxCalendarActionType? inboxFloatingButtonActionType;
@override@JsonKey(includeIfNull: false) final  TaskReminderOptionType? defaultTaskReminderType;
@override@JsonKey(includeIfNull: false) final  TaskReminderOptionType? defaultAllDayTaskReminderType;
@override@JsonKey(includeIfNull: false) final  CompletedTaskOptionType? completedTaskOptionType;
@override@JsonKey(includeIfNull: false) final  bool? showUnreadChannelsOnly;
@override@JsonKey(includeIfNull: false) final  bool? showUnreadDmsOnly;
@override@JsonKey(includeIfNull: false) final  SortChannelType? sortChannelType;
 final  List<String>? _excludedChannelIds;
@override@JsonKey(includeIfNull: false) List<String>? get excludedChannelIds {
  final value = _excludedChannelIds;
  if (value == null) return null;
  if (_excludedChannelIds is EqualUnmodifiableListView) return _excludedChannelIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override@JsonKey(includeIfNull: false) final  MailPrefSwipeActionType? mailSwipeRightActionType;
@override@JsonKey(includeIfNull: false) final  MailPrefSwipeActionType? mailSwipeLeftActionType;
@override@JsonKey(includeIfNull: false) final  MailContentThemeType? mailContentThemeType;
@override@JsonKey(includeIfNull: false) final  int? firstDayOfWeek;
@override@JsonKey(includeIfNull: false) final  int? weekViewStartWeekday;
@override@JsonKey(includeIfNull: false) final  int? defaultDurationInMinutes;
@override@JsonKey(includeIfNull: false) final  String? defaultCalendarId;
 final  Map<String, String>? _lastGmailHistoryIds;
@override@JsonKey(includeIfNull: false) Map<String, String>? get lastGmailHistoryIds {
  final value = _lastGmailHistoryIds;
  if (value == null) return null;
  if (_lastGmailHistoryIds is EqualUnmodifiableMapView) return _lastGmailHistoryIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override@JsonKey(includeIfNull: false) final  UpdateChannel? updateChannel;
@override@JsonKey(includeIfNull: false) final  bool? taskCompletionSound;
@override@JsonKey(includeIfNull: false) final  bool? mobileAppOpened;
@override@JsonKey(includeIfNull: false) final  bool? desktopAppOpened;
 final  List<Map<String, String?>>? _quickLinks;
@override@JsonKey(includeIfNull: false) List<Map<String, String?>>? get quickLinks {
  final value = _quickLinks;
  if (value == null) return null;
  if (_quickLinks is EqualUnmodifiableListView) return _quickLinks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override@JsonKey(includeIfNull: false) final  UserSubscriptionEntity? subscription;
@override@JsonKey(includeIfNull: false) final  int? lemonSqueezyCustomerId;
@override@JsonKey(includeIfNull: false) final  bool? isAdmin;
@override@JsonKey(includeIfNull: false) final  bool? includeConferenceLinkOnHomeTab;
@override@JsonKey(includeIfNull: false) final  bool? includeConferenceLinkOnCalendarTab;
@override@JsonKey(includeIfNull: false) final  bool? isFreeUser;
 final  List<UserTutorialType>? _userTutorialDoneList;
@override@JsonKey(includeIfNull: false) List<UserTutorialType>? get userTutorialDoneList {
  final value = _userTutorialDoneList;
  if (value == null) return null;
  if (_userTutorialDoneList is EqualUnmodifiableListView) return _userTutorialDoneList;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override@JsonKey(includeIfNull: false) final  double? aiCredits;
@override@JsonKey(includeIfNull: false) final  DateTime? aiCreditsUpdatedAt;

/// Create a copy of UserEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserEntityCopyWith<_UserEntity> get copyWith => __$UserEntityCopyWithImpl<_UserEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserEntityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.email, email) || other.email == email)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.subscriptionEndAt, subscriptionEndAt) || other.subscriptionEndAt == subscriptionEndAt)&&(identical(other.badge, badge) || other.badge == badge)&&const DeepCollectionEquality().equals(other._calendarColors, _calendarColors)&&const DeepCollectionEquality().equals(other._mailColors, _mailColors)&&const DeepCollectionEquality().equals(other._mailSignatures, _mailSignatures)&&const DeepCollectionEquality().equals(other._defaultSignatures, _defaultSignatures)&&const DeepCollectionEquality().equals(other._mailInboxFilterTypes, _mailInboxFilterTypes)&&const DeepCollectionEquality().equals(other._mailInboxFilterLabelIds, _mailInboxFilterLabelIds)&&const DeepCollectionEquality().equals(other._messageDmInboxFilterTypes, _messageDmInboxFilterTypes)&&const DeepCollectionEquality().equals(other._messageChannelInboxFilterTypes, _messageChannelInboxFilterTypes)&&(identical(other.taskColorHex, taskColorHex) || other.taskColorHex == taskColorHex)&&(identical(other.taskDefaultDurationInMinutes, taskDefaultDurationInMinutes) || other.taskDefaultDurationInMinutes == taskDefaultDurationInMinutes)&&(identical(other.inboxCalendarDoubleClickActionType, inboxCalendarDoubleClickActionType) || other.inboxCalendarDoubleClickActionType == inboxCalendarDoubleClickActionType)&&(identical(other.inboxCalendarDragActionType, inboxCalendarDragActionType) || other.inboxCalendarDragActionType == inboxCalendarDragActionType)&&(identical(other.inboxFloatingButtonActionType, inboxFloatingButtonActionType) || other.inboxFloatingButtonActionType == inboxFloatingButtonActionType)&&(identical(other.defaultTaskReminderType, defaultTaskReminderType) || other.defaultTaskReminderType == defaultTaskReminderType)&&(identical(other.defaultAllDayTaskReminderType, defaultAllDayTaskReminderType) || other.defaultAllDayTaskReminderType == defaultAllDayTaskReminderType)&&(identical(other.completedTaskOptionType, completedTaskOptionType) || other.completedTaskOptionType == completedTaskOptionType)&&(identical(other.showUnreadChannelsOnly, showUnreadChannelsOnly) || other.showUnreadChannelsOnly == showUnreadChannelsOnly)&&(identical(other.showUnreadDmsOnly, showUnreadDmsOnly) || other.showUnreadDmsOnly == showUnreadDmsOnly)&&(identical(other.sortChannelType, sortChannelType) || other.sortChannelType == sortChannelType)&&const DeepCollectionEquality().equals(other._excludedChannelIds, _excludedChannelIds)&&(identical(other.mailSwipeRightActionType, mailSwipeRightActionType) || other.mailSwipeRightActionType == mailSwipeRightActionType)&&(identical(other.mailSwipeLeftActionType, mailSwipeLeftActionType) || other.mailSwipeLeftActionType == mailSwipeLeftActionType)&&(identical(other.mailContentThemeType, mailContentThemeType) || other.mailContentThemeType == mailContentThemeType)&&(identical(other.firstDayOfWeek, firstDayOfWeek) || other.firstDayOfWeek == firstDayOfWeek)&&(identical(other.weekViewStartWeekday, weekViewStartWeekday) || other.weekViewStartWeekday == weekViewStartWeekday)&&(identical(other.defaultDurationInMinutes, defaultDurationInMinutes) || other.defaultDurationInMinutes == defaultDurationInMinutes)&&(identical(other.defaultCalendarId, defaultCalendarId) || other.defaultCalendarId == defaultCalendarId)&&const DeepCollectionEquality().equals(other._lastGmailHistoryIds, _lastGmailHistoryIds)&&(identical(other.updateChannel, updateChannel) || other.updateChannel == updateChannel)&&(identical(other.taskCompletionSound, taskCompletionSound) || other.taskCompletionSound == taskCompletionSound)&&(identical(other.mobileAppOpened, mobileAppOpened) || other.mobileAppOpened == mobileAppOpened)&&(identical(other.desktopAppOpened, desktopAppOpened) || other.desktopAppOpened == desktopAppOpened)&&const DeepCollectionEquality().equals(other._quickLinks, _quickLinks)&&(identical(other.subscription, subscription) || other.subscription == subscription)&&(identical(other.lemonSqueezyCustomerId, lemonSqueezyCustomerId) || other.lemonSqueezyCustomerId == lemonSqueezyCustomerId)&&(identical(other.isAdmin, isAdmin) || other.isAdmin == isAdmin)&&(identical(other.includeConferenceLinkOnHomeTab, includeConferenceLinkOnHomeTab) || other.includeConferenceLinkOnHomeTab == includeConferenceLinkOnHomeTab)&&(identical(other.includeConferenceLinkOnCalendarTab, includeConferenceLinkOnCalendarTab) || other.includeConferenceLinkOnCalendarTab == includeConferenceLinkOnCalendarTab)&&(identical(other.isFreeUser, isFreeUser) || other.isFreeUser == isFreeUser)&&const DeepCollectionEquality().equals(other._userTutorialDoneList, _userTutorialDoneList)&&(identical(other.aiCredits, aiCredits) || other.aiCredits == aiCredits)&&(identical(other.aiCreditsUpdatedAt, aiCreditsUpdatedAt) || other.aiCreditsUpdatedAt == aiCreditsUpdatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,name,email,avatarUrl,createdAt,updatedAt,subscriptionEndAt,badge,const DeepCollectionEquality().hash(_calendarColors),const DeepCollectionEquality().hash(_mailColors),const DeepCollectionEquality().hash(_mailSignatures),const DeepCollectionEquality().hash(_defaultSignatures),const DeepCollectionEquality().hash(_mailInboxFilterTypes),const DeepCollectionEquality().hash(_mailInboxFilterLabelIds),const DeepCollectionEquality().hash(_messageDmInboxFilterTypes),const DeepCollectionEquality().hash(_messageChannelInboxFilterTypes),taskColorHex,taskDefaultDurationInMinutes,inboxCalendarDoubleClickActionType,inboxCalendarDragActionType,inboxFloatingButtonActionType,defaultTaskReminderType,defaultAllDayTaskReminderType,completedTaskOptionType,showUnreadChannelsOnly,showUnreadDmsOnly,sortChannelType,const DeepCollectionEquality().hash(_excludedChannelIds),mailSwipeRightActionType,mailSwipeLeftActionType,mailContentThemeType,firstDayOfWeek,weekViewStartWeekday,defaultDurationInMinutes,defaultCalendarId,const DeepCollectionEquality().hash(_lastGmailHistoryIds),updateChannel,taskCompletionSound,mobileAppOpened,desktopAppOpened,const DeepCollectionEquality().hash(_quickLinks),subscription,lemonSqueezyCustomerId,isAdmin,includeConferenceLinkOnHomeTab,includeConferenceLinkOnCalendarTab,isFreeUser,const DeepCollectionEquality().hash(_userTutorialDoneList),aiCredits,aiCreditsUpdatedAt]);

@override
String toString() {
  return 'UserEntity(id: $id, name: $name, email: $email, avatarUrl: $avatarUrl, createdAt: $createdAt, updatedAt: $updatedAt, subscriptionEndAt: $subscriptionEndAt, badge: $badge, calendarColors: $calendarColors, mailColors: $mailColors, mailSignatures: $mailSignatures, defaultSignatures: $defaultSignatures, mailInboxFilterTypes: $mailInboxFilterTypes, mailInboxFilterLabelIds: $mailInboxFilterLabelIds, messageDmInboxFilterTypes: $messageDmInboxFilterTypes, messageChannelInboxFilterTypes: $messageChannelInboxFilterTypes, taskColorHex: $taskColorHex, taskDefaultDurationInMinutes: $taskDefaultDurationInMinutes, inboxCalendarDoubleClickActionType: $inboxCalendarDoubleClickActionType, inboxCalendarDragActionType: $inboxCalendarDragActionType, inboxFloatingButtonActionType: $inboxFloatingButtonActionType, defaultTaskReminderType: $defaultTaskReminderType, defaultAllDayTaskReminderType: $defaultAllDayTaskReminderType, completedTaskOptionType: $completedTaskOptionType, showUnreadChannelsOnly: $showUnreadChannelsOnly, showUnreadDmsOnly: $showUnreadDmsOnly, sortChannelType: $sortChannelType, excludedChannelIds: $excludedChannelIds, mailSwipeRightActionType: $mailSwipeRightActionType, mailSwipeLeftActionType: $mailSwipeLeftActionType, mailContentThemeType: $mailContentThemeType, firstDayOfWeek: $firstDayOfWeek, weekViewStartWeekday: $weekViewStartWeekday, defaultDurationInMinutes: $defaultDurationInMinutes, defaultCalendarId: $defaultCalendarId, lastGmailHistoryIds: $lastGmailHistoryIds, updateChannel: $updateChannel, taskCompletionSound: $taskCompletionSound, mobileAppOpened: $mobileAppOpened, desktopAppOpened: $desktopAppOpened, quickLinks: $quickLinks, subscription: $subscription, lemonSqueezyCustomerId: $lemonSqueezyCustomerId, isAdmin: $isAdmin, includeConferenceLinkOnHomeTab: $includeConferenceLinkOnHomeTab, includeConferenceLinkOnCalendarTab: $includeConferenceLinkOnCalendarTab, isFreeUser: $isFreeUser, userTutorialDoneList: $userTutorialDoneList, aiCredits: $aiCredits, aiCreditsUpdatedAt: $aiCreditsUpdatedAt)';
}


}

/// @nodoc
abstract mixin class _$UserEntityCopyWith<$Res> implements $UserEntityCopyWith<$Res> {
  factory _$UserEntityCopyWith(_UserEntity value, $Res Function(_UserEntity) _then) = __$UserEntityCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(includeIfNull: false) String? name,@JsonKey(includeIfNull: false) String? email,@JsonKey(includeIfNull: false) String? avatarUrl,@JsonKey(includeIfNull: false) DateTime? createdAt,@JsonKey(includeIfNull: false) DateTime? updatedAt,@JsonKey(includeIfNull: false) DateTime? subscriptionEndAt,@JsonKey(includeIfNull: false) int? badge,@JsonKey(includeIfNull: false) Map<String, String>? calendarColors,@JsonKey(includeIfNull: false) Map<String, String>? mailColors,@JsonKey(includeIfNull: false) List<MailSignatureEntity>? mailSignatures,@JsonKey(includeIfNull: false) Map<String, int>? defaultSignatures,@JsonKey(includeIfNull: false) Map<String, MailInboxFilterType>? mailInboxFilterTypes,@JsonKey(includeIfNull: false) Map<String, List<String>>? mailInboxFilterLabelIds,@JsonKey(includeIfNull: false) Map<String, ChatInboxFilterType>? messageDmInboxFilterTypes,@JsonKey(includeIfNull: false) Map<String, ChatInboxFilterType>? messageChannelInboxFilterTypes,@JsonKey(includeIfNull: false) String? taskColorHex,@JsonKey(includeIfNull: false) int? taskDefaultDurationInMinutes,@JsonKey(includeIfNull: false) InboxCalendarActionType? inboxCalendarDoubleClickActionType,@JsonKey(includeIfNull: false) InboxCalendarActionType? inboxCalendarDragActionType,@JsonKey(includeIfNull: false) InboxCalendarActionType? inboxFloatingButtonActionType,@JsonKey(includeIfNull: false) TaskReminderOptionType? defaultTaskReminderType,@JsonKey(includeIfNull: false) TaskReminderOptionType? defaultAllDayTaskReminderType,@JsonKey(includeIfNull: false) CompletedTaskOptionType? completedTaskOptionType,@JsonKey(includeIfNull: false) bool? showUnreadChannelsOnly,@JsonKey(includeIfNull: false) bool? showUnreadDmsOnly,@JsonKey(includeIfNull: false) SortChannelType? sortChannelType,@JsonKey(includeIfNull: false) List<String>? excludedChannelIds,@JsonKey(includeIfNull: false) MailPrefSwipeActionType? mailSwipeRightActionType,@JsonKey(includeIfNull: false) MailPrefSwipeActionType? mailSwipeLeftActionType,@JsonKey(includeIfNull: false) MailContentThemeType? mailContentThemeType,@JsonKey(includeIfNull: false) int? firstDayOfWeek,@JsonKey(includeIfNull: false) int? weekViewStartWeekday,@JsonKey(includeIfNull: false) int? defaultDurationInMinutes,@JsonKey(includeIfNull: false) String? defaultCalendarId,@JsonKey(includeIfNull: false) Map<String, String>? lastGmailHistoryIds,@JsonKey(includeIfNull: false) UpdateChannel? updateChannel,@JsonKey(includeIfNull: false) bool? taskCompletionSound,@JsonKey(includeIfNull: false) bool? mobileAppOpened,@JsonKey(includeIfNull: false) bool? desktopAppOpened,@JsonKey(includeIfNull: false) List<Map<String, String?>>? quickLinks,@JsonKey(includeIfNull: false) UserSubscriptionEntity? subscription,@JsonKey(includeIfNull: false) int? lemonSqueezyCustomerId,@JsonKey(includeIfNull: false) bool? isAdmin,@JsonKey(includeIfNull: false) bool? includeConferenceLinkOnHomeTab,@JsonKey(includeIfNull: false) bool? includeConferenceLinkOnCalendarTab,@JsonKey(includeIfNull: false) bool? isFreeUser,@JsonKey(includeIfNull: false) List<UserTutorialType>? userTutorialDoneList,@JsonKey(includeIfNull: false) double? aiCredits,@JsonKey(includeIfNull: false) DateTime? aiCreditsUpdatedAt
});


@override $UserSubscriptionEntityCopyWith<$Res>? get subscription;

}
/// @nodoc
class __$UserEntityCopyWithImpl<$Res>
    implements _$UserEntityCopyWith<$Res> {
  __$UserEntityCopyWithImpl(this._self, this._then);

  final _UserEntity _self;
  final $Res Function(_UserEntity) _then;

/// Create a copy of UserEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = freezed,Object? email = freezed,Object? avatarUrl = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? subscriptionEndAt = freezed,Object? badge = freezed,Object? calendarColors = freezed,Object? mailColors = freezed,Object? mailSignatures = freezed,Object? defaultSignatures = freezed,Object? mailInboxFilterTypes = freezed,Object? mailInboxFilterLabelIds = freezed,Object? messageDmInboxFilterTypes = freezed,Object? messageChannelInboxFilterTypes = freezed,Object? taskColorHex = freezed,Object? taskDefaultDurationInMinutes = freezed,Object? inboxCalendarDoubleClickActionType = freezed,Object? inboxCalendarDragActionType = freezed,Object? inboxFloatingButtonActionType = freezed,Object? defaultTaskReminderType = freezed,Object? defaultAllDayTaskReminderType = freezed,Object? completedTaskOptionType = freezed,Object? showUnreadChannelsOnly = freezed,Object? showUnreadDmsOnly = freezed,Object? sortChannelType = freezed,Object? excludedChannelIds = freezed,Object? mailSwipeRightActionType = freezed,Object? mailSwipeLeftActionType = freezed,Object? mailContentThemeType = freezed,Object? firstDayOfWeek = freezed,Object? weekViewStartWeekday = freezed,Object? defaultDurationInMinutes = freezed,Object? defaultCalendarId = freezed,Object? lastGmailHistoryIds = freezed,Object? updateChannel = freezed,Object? taskCompletionSound = freezed,Object? mobileAppOpened = freezed,Object? desktopAppOpened = freezed,Object? quickLinks = freezed,Object? subscription = freezed,Object? lemonSqueezyCustomerId = freezed,Object? isAdmin = freezed,Object? includeConferenceLinkOnHomeTab = freezed,Object? includeConferenceLinkOnCalendarTab = freezed,Object? isFreeUser = freezed,Object? userTutorialDoneList = freezed,Object? aiCredits = freezed,Object? aiCreditsUpdatedAt = freezed,}) {
  return _then(_UserEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,subscriptionEndAt: freezed == subscriptionEndAt ? _self.subscriptionEndAt : subscriptionEndAt // ignore: cast_nullable_to_non_nullable
as DateTime?,badge: freezed == badge ? _self.badge : badge // ignore: cast_nullable_to_non_nullable
as int?,calendarColors: freezed == calendarColors ? _self._calendarColors : calendarColors // ignore: cast_nullable_to_non_nullable
as Map<String, String>?,mailColors: freezed == mailColors ? _self._mailColors : mailColors // ignore: cast_nullable_to_non_nullable
as Map<String, String>?,mailSignatures: freezed == mailSignatures ? _self._mailSignatures : mailSignatures // ignore: cast_nullable_to_non_nullable
as List<MailSignatureEntity>?,defaultSignatures: freezed == defaultSignatures ? _self._defaultSignatures : defaultSignatures // ignore: cast_nullable_to_non_nullable
as Map<String, int>?,mailInboxFilterTypes: freezed == mailInboxFilterTypes ? _self._mailInboxFilterTypes : mailInboxFilterTypes // ignore: cast_nullable_to_non_nullable
as Map<String, MailInboxFilterType>?,mailInboxFilterLabelIds: freezed == mailInboxFilterLabelIds ? _self._mailInboxFilterLabelIds : mailInboxFilterLabelIds // ignore: cast_nullable_to_non_nullable
as Map<String, List<String>>?,messageDmInboxFilterTypes: freezed == messageDmInboxFilterTypes ? _self._messageDmInboxFilterTypes : messageDmInboxFilterTypes // ignore: cast_nullable_to_non_nullable
as Map<String, ChatInboxFilterType>?,messageChannelInboxFilterTypes: freezed == messageChannelInboxFilterTypes ? _self._messageChannelInboxFilterTypes : messageChannelInboxFilterTypes // ignore: cast_nullable_to_non_nullable
as Map<String, ChatInboxFilterType>?,taskColorHex: freezed == taskColorHex ? _self.taskColorHex : taskColorHex // ignore: cast_nullable_to_non_nullable
as String?,taskDefaultDurationInMinutes: freezed == taskDefaultDurationInMinutes ? _self.taskDefaultDurationInMinutes : taskDefaultDurationInMinutes // ignore: cast_nullable_to_non_nullable
as int?,inboxCalendarDoubleClickActionType: freezed == inboxCalendarDoubleClickActionType ? _self.inboxCalendarDoubleClickActionType : inboxCalendarDoubleClickActionType // ignore: cast_nullable_to_non_nullable
as InboxCalendarActionType?,inboxCalendarDragActionType: freezed == inboxCalendarDragActionType ? _self.inboxCalendarDragActionType : inboxCalendarDragActionType // ignore: cast_nullable_to_non_nullable
as InboxCalendarActionType?,inboxFloatingButtonActionType: freezed == inboxFloatingButtonActionType ? _self.inboxFloatingButtonActionType : inboxFloatingButtonActionType // ignore: cast_nullable_to_non_nullable
as InboxCalendarActionType?,defaultTaskReminderType: freezed == defaultTaskReminderType ? _self.defaultTaskReminderType : defaultTaskReminderType // ignore: cast_nullable_to_non_nullable
as TaskReminderOptionType?,defaultAllDayTaskReminderType: freezed == defaultAllDayTaskReminderType ? _self.defaultAllDayTaskReminderType : defaultAllDayTaskReminderType // ignore: cast_nullable_to_non_nullable
as TaskReminderOptionType?,completedTaskOptionType: freezed == completedTaskOptionType ? _self.completedTaskOptionType : completedTaskOptionType // ignore: cast_nullable_to_non_nullable
as CompletedTaskOptionType?,showUnreadChannelsOnly: freezed == showUnreadChannelsOnly ? _self.showUnreadChannelsOnly : showUnreadChannelsOnly // ignore: cast_nullable_to_non_nullable
as bool?,showUnreadDmsOnly: freezed == showUnreadDmsOnly ? _self.showUnreadDmsOnly : showUnreadDmsOnly // ignore: cast_nullable_to_non_nullable
as bool?,sortChannelType: freezed == sortChannelType ? _self.sortChannelType : sortChannelType // ignore: cast_nullable_to_non_nullable
as SortChannelType?,excludedChannelIds: freezed == excludedChannelIds ? _self._excludedChannelIds : excludedChannelIds // ignore: cast_nullable_to_non_nullable
as List<String>?,mailSwipeRightActionType: freezed == mailSwipeRightActionType ? _self.mailSwipeRightActionType : mailSwipeRightActionType // ignore: cast_nullable_to_non_nullable
as MailPrefSwipeActionType?,mailSwipeLeftActionType: freezed == mailSwipeLeftActionType ? _self.mailSwipeLeftActionType : mailSwipeLeftActionType // ignore: cast_nullable_to_non_nullable
as MailPrefSwipeActionType?,mailContentThemeType: freezed == mailContentThemeType ? _self.mailContentThemeType : mailContentThemeType // ignore: cast_nullable_to_non_nullable
as MailContentThemeType?,firstDayOfWeek: freezed == firstDayOfWeek ? _self.firstDayOfWeek : firstDayOfWeek // ignore: cast_nullable_to_non_nullable
as int?,weekViewStartWeekday: freezed == weekViewStartWeekday ? _self.weekViewStartWeekday : weekViewStartWeekday // ignore: cast_nullable_to_non_nullable
as int?,defaultDurationInMinutes: freezed == defaultDurationInMinutes ? _self.defaultDurationInMinutes : defaultDurationInMinutes // ignore: cast_nullable_to_non_nullable
as int?,defaultCalendarId: freezed == defaultCalendarId ? _self.defaultCalendarId : defaultCalendarId // ignore: cast_nullable_to_non_nullable
as String?,lastGmailHistoryIds: freezed == lastGmailHistoryIds ? _self._lastGmailHistoryIds : lastGmailHistoryIds // ignore: cast_nullable_to_non_nullable
as Map<String, String>?,updateChannel: freezed == updateChannel ? _self.updateChannel : updateChannel // ignore: cast_nullable_to_non_nullable
as UpdateChannel?,taskCompletionSound: freezed == taskCompletionSound ? _self.taskCompletionSound : taskCompletionSound // ignore: cast_nullable_to_non_nullable
as bool?,mobileAppOpened: freezed == mobileAppOpened ? _self.mobileAppOpened : mobileAppOpened // ignore: cast_nullable_to_non_nullable
as bool?,desktopAppOpened: freezed == desktopAppOpened ? _self.desktopAppOpened : desktopAppOpened // ignore: cast_nullable_to_non_nullable
as bool?,quickLinks: freezed == quickLinks ? _self._quickLinks : quickLinks // ignore: cast_nullable_to_non_nullable
as List<Map<String, String?>>?,subscription: freezed == subscription ? _self.subscription : subscription // ignore: cast_nullable_to_non_nullable
as UserSubscriptionEntity?,lemonSqueezyCustomerId: freezed == lemonSqueezyCustomerId ? _self.lemonSqueezyCustomerId : lemonSqueezyCustomerId // ignore: cast_nullable_to_non_nullable
as int?,isAdmin: freezed == isAdmin ? _self.isAdmin : isAdmin // ignore: cast_nullable_to_non_nullable
as bool?,includeConferenceLinkOnHomeTab: freezed == includeConferenceLinkOnHomeTab ? _self.includeConferenceLinkOnHomeTab : includeConferenceLinkOnHomeTab // ignore: cast_nullable_to_non_nullable
as bool?,includeConferenceLinkOnCalendarTab: freezed == includeConferenceLinkOnCalendarTab ? _self.includeConferenceLinkOnCalendarTab : includeConferenceLinkOnCalendarTab // ignore: cast_nullable_to_non_nullable
as bool?,isFreeUser: freezed == isFreeUser ? _self.isFreeUser : isFreeUser // ignore: cast_nullable_to_non_nullable
as bool?,userTutorialDoneList: freezed == userTutorialDoneList ? _self._userTutorialDoneList : userTutorialDoneList // ignore: cast_nullable_to_non_nullable
as List<UserTutorialType>?,aiCredits: freezed == aiCredits ? _self.aiCredits : aiCredits // ignore: cast_nullable_to_non_nullable
as double?,aiCreditsUpdatedAt: freezed == aiCreditsUpdatedAt ? _self.aiCreditsUpdatedAt : aiCreditsUpdatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of UserEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserSubscriptionEntityCopyWith<$Res>? get subscription {
    if (_self.subscription == null) {
    return null;
  }

  return $UserSubscriptionEntityCopyWith<$Res>(_self.subscription!, (value) {
    return _then(_self.copyWith(subscription: value));
  });
}
}

// dart format on
