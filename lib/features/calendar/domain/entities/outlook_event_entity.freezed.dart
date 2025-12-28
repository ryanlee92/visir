// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'outlook_event_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$OutlookEventEntity {

 bool? get allowNewTimeProposals; List<Attendee>? get attendees; ItemBody? get body; String? get bodyPreview; List<String>? get cancelledOccurrences; List<OutlookEventEntity>? get exceptionOccurrences; String? get occurrenceId; List<String>? get categories; String? get changeKey; String? get createdDateTime; DateTimeTimeZone? get end; bool? get hasAttachments; bool? get hideAttendees; String? get iCalUId; String? get id; String? get importance; bool? get isAllDay; bool? get isCancelled; bool? get isDraft; bool? get isOnlineMeeting; bool? get isOrganizer; bool? get isReminderOn; String? get lastModifiedDateTime; Location? get location; List<Location>? get locations; OnlineMeetingInfo? get onlineMeeting; OnlineMeetingProviderType? get onlineMeetingProvider; String? get onlineMeetingUrl; Recipient? get organizer; String? get originalEndTimeZone; String? get originalStart; String? get originalStartTimeZone; PatternedRecurrence? get recurrence; int? get reminderMinutesBeforeStart; bool? get responseRequested; ResponseStatus? get responseStatus; String? get sensitivity; String? get seriesMasterId; String? get showAs; DateTimeTimeZone? get start; String? get subject; String? get transactionId; String? get type; String? get webLink; List<Attachment>? get attachments;
/// Create a copy of OutlookEventEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OutlookEventEntityCopyWith<OutlookEventEntity> get copyWith => _$OutlookEventEntityCopyWithImpl<OutlookEventEntity>(this as OutlookEventEntity, _$identity);

  /// Serializes this OutlookEventEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OutlookEventEntity&&(identical(other.allowNewTimeProposals, allowNewTimeProposals) || other.allowNewTimeProposals == allowNewTimeProposals)&&const DeepCollectionEquality().equals(other.attendees, attendees)&&(identical(other.body, body) || other.body == body)&&(identical(other.bodyPreview, bodyPreview) || other.bodyPreview == bodyPreview)&&const DeepCollectionEquality().equals(other.cancelledOccurrences, cancelledOccurrences)&&const DeepCollectionEquality().equals(other.exceptionOccurrences, exceptionOccurrences)&&(identical(other.occurrenceId, occurrenceId) || other.occurrenceId == occurrenceId)&&const DeepCollectionEquality().equals(other.categories, categories)&&(identical(other.changeKey, changeKey) || other.changeKey == changeKey)&&(identical(other.createdDateTime, createdDateTime) || other.createdDateTime == createdDateTime)&&(identical(other.end, end) || other.end == end)&&(identical(other.hasAttachments, hasAttachments) || other.hasAttachments == hasAttachments)&&(identical(other.hideAttendees, hideAttendees) || other.hideAttendees == hideAttendees)&&(identical(other.iCalUId, iCalUId) || other.iCalUId == iCalUId)&&(identical(other.id, id) || other.id == id)&&(identical(other.importance, importance) || other.importance == importance)&&(identical(other.isAllDay, isAllDay) || other.isAllDay == isAllDay)&&(identical(other.isCancelled, isCancelled) || other.isCancelled == isCancelled)&&(identical(other.isDraft, isDraft) || other.isDraft == isDraft)&&(identical(other.isOnlineMeeting, isOnlineMeeting) || other.isOnlineMeeting == isOnlineMeeting)&&(identical(other.isOrganizer, isOrganizer) || other.isOrganizer == isOrganizer)&&(identical(other.isReminderOn, isReminderOn) || other.isReminderOn == isReminderOn)&&(identical(other.lastModifiedDateTime, lastModifiedDateTime) || other.lastModifiedDateTime == lastModifiedDateTime)&&(identical(other.location, location) || other.location == location)&&const DeepCollectionEquality().equals(other.locations, locations)&&(identical(other.onlineMeeting, onlineMeeting) || other.onlineMeeting == onlineMeeting)&&(identical(other.onlineMeetingProvider, onlineMeetingProvider) || other.onlineMeetingProvider == onlineMeetingProvider)&&(identical(other.onlineMeetingUrl, onlineMeetingUrl) || other.onlineMeetingUrl == onlineMeetingUrl)&&(identical(other.organizer, organizer) || other.organizer == organizer)&&(identical(other.originalEndTimeZone, originalEndTimeZone) || other.originalEndTimeZone == originalEndTimeZone)&&(identical(other.originalStart, originalStart) || other.originalStart == originalStart)&&(identical(other.originalStartTimeZone, originalStartTimeZone) || other.originalStartTimeZone == originalStartTimeZone)&&(identical(other.recurrence, recurrence) || other.recurrence == recurrence)&&(identical(other.reminderMinutesBeforeStart, reminderMinutesBeforeStart) || other.reminderMinutesBeforeStart == reminderMinutesBeforeStart)&&(identical(other.responseRequested, responseRequested) || other.responseRequested == responseRequested)&&(identical(other.responseStatus, responseStatus) || other.responseStatus == responseStatus)&&(identical(other.sensitivity, sensitivity) || other.sensitivity == sensitivity)&&(identical(other.seriesMasterId, seriesMasterId) || other.seriesMasterId == seriesMasterId)&&(identical(other.showAs, showAs) || other.showAs == showAs)&&(identical(other.start, start) || other.start == start)&&(identical(other.subject, subject) || other.subject == subject)&&(identical(other.transactionId, transactionId) || other.transactionId == transactionId)&&(identical(other.type, type) || other.type == type)&&(identical(other.webLink, webLink) || other.webLink == webLink)&&const DeepCollectionEquality().equals(other.attachments, attachments));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,allowNewTimeProposals,const DeepCollectionEquality().hash(attendees),body,bodyPreview,const DeepCollectionEquality().hash(cancelledOccurrences),const DeepCollectionEquality().hash(exceptionOccurrences),occurrenceId,const DeepCollectionEquality().hash(categories),changeKey,createdDateTime,end,hasAttachments,hideAttendees,iCalUId,id,importance,isAllDay,isCancelled,isDraft,isOnlineMeeting,isOrganizer,isReminderOn,lastModifiedDateTime,location,const DeepCollectionEquality().hash(locations),onlineMeeting,onlineMeetingProvider,onlineMeetingUrl,organizer,originalEndTimeZone,originalStart,originalStartTimeZone,recurrence,reminderMinutesBeforeStart,responseRequested,responseStatus,sensitivity,seriesMasterId,showAs,start,subject,transactionId,type,webLink,const DeepCollectionEquality().hash(attachments)]);

@override
String toString() {
  return 'OutlookEventEntity(allowNewTimeProposals: $allowNewTimeProposals, attendees: $attendees, body: $body, bodyPreview: $bodyPreview, cancelledOccurrences: $cancelledOccurrences, exceptionOccurrences: $exceptionOccurrences, occurrenceId: $occurrenceId, categories: $categories, changeKey: $changeKey, createdDateTime: $createdDateTime, end: $end, hasAttachments: $hasAttachments, hideAttendees: $hideAttendees, iCalUId: $iCalUId, id: $id, importance: $importance, isAllDay: $isAllDay, isCancelled: $isCancelled, isDraft: $isDraft, isOnlineMeeting: $isOnlineMeeting, isOrganizer: $isOrganizer, isReminderOn: $isReminderOn, lastModifiedDateTime: $lastModifiedDateTime, location: $location, locations: $locations, onlineMeeting: $onlineMeeting, onlineMeetingProvider: $onlineMeetingProvider, onlineMeetingUrl: $onlineMeetingUrl, organizer: $organizer, originalEndTimeZone: $originalEndTimeZone, originalStart: $originalStart, originalStartTimeZone: $originalStartTimeZone, recurrence: $recurrence, reminderMinutesBeforeStart: $reminderMinutesBeforeStart, responseRequested: $responseRequested, responseStatus: $responseStatus, sensitivity: $sensitivity, seriesMasterId: $seriesMasterId, showAs: $showAs, start: $start, subject: $subject, transactionId: $transactionId, type: $type, webLink: $webLink, attachments: $attachments)';
}


}

/// @nodoc
abstract mixin class $OutlookEventEntityCopyWith<$Res>  {
  factory $OutlookEventEntityCopyWith(OutlookEventEntity value, $Res Function(OutlookEventEntity) _then) = _$OutlookEventEntityCopyWithImpl;
@useResult
$Res call({
 bool? allowNewTimeProposals, List<Attendee>? attendees, ItemBody? body, String? bodyPreview, List<String>? cancelledOccurrences, List<OutlookEventEntity>? exceptionOccurrences, String? occurrenceId, List<String>? categories, String? changeKey, String? createdDateTime, DateTimeTimeZone? end, bool? hasAttachments, bool? hideAttendees, String? iCalUId, String? id, String? importance, bool? isAllDay, bool? isCancelled, bool? isDraft, bool? isOnlineMeeting, bool? isOrganizer, bool? isReminderOn, String? lastModifiedDateTime, Location? location, List<Location>? locations, OnlineMeetingInfo? onlineMeeting, OnlineMeetingProviderType? onlineMeetingProvider, String? onlineMeetingUrl, Recipient? organizer, String? originalEndTimeZone, String? originalStart, String? originalStartTimeZone, PatternedRecurrence? recurrence, int? reminderMinutesBeforeStart, bool? responseRequested, ResponseStatus? responseStatus, String? sensitivity, String? seriesMasterId, String? showAs, DateTimeTimeZone? start, String? subject, String? transactionId, String? type, String? webLink, List<Attachment>? attachments
});


$DateTimeTimeZoneCopyWith<$Res>? get end;$LocationCopyWith<$Res>? get location;$OnlineMeetingInfoCopyWith<$Res>? get onlineMeeting;$RecipientCopyWith<$Res>? get organizer;$PatternedRecurrenceCopyWith<$Res>? get recurrence;$ResponseStatusCopyWith<$Res>? get responseStatus;$DateTimeTimeZoneCopyWith<$Res>? get start;

}
/// @nodoc
class _$OutlookEventEntityCopyWithImpl<$Res>
    implements $OutlookEventEntityCopyWith<$Res> {
  _$OutlookEventEntityCopyWithImpl(this._self, this._then);

  final OutlookEventEntity _self;
  final $Res Function(OutlookEventEntity) _then;

/// Create a copy of OutlookEventEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? allowNewTimeProposals = freezed,Object? attendees = freezed,Object? body = freezed,Object? bodyPreview = freezed,Object? cancelledOccurrences = freezed,Object? exceptionOccurrences = freezed,Object? occurrenceId = freezed,Object? categories = freezed,Object? changeKey = freezed,Object? createdDateTime = freezed,Object? end = freezed,Object? hasAttachments = freezed,Object? hideAttendees = freezed,Object? iCalUId = freezed,Object? id = freezed,Object? importance = freezed,Object? isAllDay = freezed,Object? isCancelled = freezed,Object? isDraft = freezed,Object? isOnlineMeeting = freezed,Object? isOrganizer = freezed,Object? isReminderOn = freezed,Object? lastModifiedDateTime = freezed,Object? location = freezed,Object? locations = freezed,Object? onlineMeeting = freezed,Object? onlineMeetingProvider = freezed,Object? onlineMeetingUrl = freezed,Object? organizer = freezed,Object? originalEndTimeZone = freezed,Object? originalStart = freezed,Object? originalStartTimeZone = freezed,Object? recurrence = freezed,Object? reminderMinutesBeforeStart = freezed,Object? responseRequested = freezed,Object? responseStatus = freezed,Object? sensitivity = freezed,Object? seriesMasterId = freezed,Object? showAs = freezed,Object? start = freezed,Object? subject = freezed,Object? transactionId = freezed,Object? type = freezed,Object? webLink = freezed,Object? attachments = freezed,}) {
  return _then(_self.copyWith(
allowNewTimeProposals: freezed == allowNewTimeProposals ? _self.allowNewTimeProposals : allowNewTimeProposals // ignore: cast_nullable_to_non_nullable
as bool?,attendees: freezed == attendees ? _self.attendees : attendees // ignore: cast_nullable_to_non_nullable
as List<Attendee>?,body: freezed == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as ItemBody?,bodyPreview: freezed == bodyPreview ? _self.bodyPreview : bodyPreview // ignore: cast_nullable_to_non_nullable
as String?,cancelledOccurrences: freezed == cancelledOccurrences ? _self.cancelledOccurrences : cancelledOccurrences // ignore: cast_nullable_to_non_nullable
as List<String>?,exceptionOccurrences: freezed == exceptionOccurrences ? _self.exceptionOccurrences : exceptionOccurrences // ignore: cast_nullable_to_non_nullable
as List<OutlookEventEntity>?,occurrenceId: freezed == occurrenceId ? _self.occurrenceId : occurrenceId // ignore: cast_nullable_to_non_nullable
as String?,categories: freezed == categories ? _self.categories : categories // ignore: cast_nullable_to_non_nullable
as List<String>?,changeKey: freezed == changeKey ? _self.changeKey : changeKey // ignore: cast_nullable_to_non_nullable
as String?,createdDateTime: freezed == createdDateTime ? _self.createdDateTime : createdDateTime // ignore: cast_nullable_to_non_nullable
as String?,end: freezed == end ? _self.end : end // ignore: cast_nullable_to_non_nullable
as DateTimeTimeZone?,hasAttachments: freezed == hasAttachments ? _self.hasAttachments : hasAttachments // ignore: cast_nullable_to_non_nullable
as bool?,hideAttendees: freezed == hideAttendees ? _self.hideAttendees : hideAttendees // ignore: cast_nullable_to_non_nullable
as bool?,iCalUId: freezed == iCalUId ? _self.iCalUId : iCalUId // ignore: cast_nullable_to_non_nullable
as String?,id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,importance: freezed == importance ? _self.importance : importance // ignore: cast_nullable_to_non_nullable
as String?,isAllDay: freezed == isAllDay ? _self.isAllDay : isAllDay // ignore: cast_nullable_to_non_nullable
as bool?,isCancelled: freezed == isCancelled ? _self.isCancelled : isCancelled // ignore: cast_nullable_to_non_nullable
as bool?,isDraft: freezed == isDraft ? _self.isDraft : isDraft // ignore: cast_nullable_to_non_nullable
as bool?,isOnlineMeeting: freezed == isOnlineMeeting ? _self.isOnlineMeeting : isOnlineMeeting // ignore: cast_nullable_to_non_nullable
as bool?,isOrganizer: freezed == isOrganizer ? _self.isOrganizer : isOrganizer // ignore: cast_nullable_to_non_nullable
as bool?,isReminderOn: freezed == isReminderOn ? _self.isReminderOn : isReminderOn // ignore: cast_nullable_to_non_nullable
as bool?,lastModifiedDateTime: freezed == lastModifiedDateTime ? _self.lastModifiedDateTime : lastModifiedDateTime // ignore: cast_nullable_to_non_nullable
as String?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as Location?,locations: freezed == locations ? _self.locations : locations // ignore: cast_nullable_to_non_nullable
as List<Location>?,onlineMeeting: freezed == onlineMeeting ? _self.onlineMeeting : onlineMeeting // ignore: cast_nullable_to_non_nullable
as OnlineMeetingInfo?,onlineMeetingProvider: freezed == onlineMeetingProvider ? _self.onlineMeetingProvider : onlineMeetingProvider // ignore: cast_nullable_to_non_nullable
as OnlineMeetingProviderType?,onlineMeetingUrl: freezed == onlineMeetingUrl ? _self.onlineMeetingUrl : onlineMeetingUrl // ignore: cast_nullable_to_non_nullable
as String?,organizer: freezed == organizer ? _self.organizer : organizer // ignore: cast_nullable_to_non_nullable
as Recipient?,originalEndTimeZone: freezed == originalEndTimeZone ? _self.originalEndTimeZone : originalEndTimeZone // ignore: cast_nullable_to_non_nullable
as String?,originalStart: freezed == originalStart ? _self.originalStart : originalStart // ignore: cast_nullable_to_non_nullable
as String?,originalStartTimeZone: freezed == originalStartTimeZone ? _self.originalStartTimeZone : originalStartTimeZone // ignore: cast_nullable_to_non_nullable
as String?,recurrence: freezed == recurrence ? _self.recurrence : recurrence // ignore: cast_nullable_to_non_nullable
as PatternedRecurrence?,reminderMinutesBeforeStart: freezed == reminderMinutesBeforeStart ? _self.reminderMinutesBeforeStart : reminderMinutesBeforeStart // ignore: cast_nullable_to_non_nullable
as int?,responseRequested: freezed == responseRequested ? _self.responseRequested : responseRequested // ignore: cast_nullable_to_non_nullable
as bool?,responseStatus: freezed == responseStatus ? _self.responseStatus : responseStatus // ignore: cast_nullable_to_non_nullable
as ResponseStatus?,sensitivity: freezed == sensitivity ? _self.sensitivity : sensitivity // ignore: cast_nullable_to_non_nullable
as String?,seriesMasterId: freezed == seriesMasterId ? _self.seriesMasterId : seriesMasterId // ignore: cast_nullable_to_non_nullable
as String?,showAs: freezed == showAs ? _self.showAs : showAs // ignore: cast_nullable_to_non_nullable
as String?,start: freezed == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as DateTimeTimeZone?,subject: freezed == subject ? _self.subject : subject // ignore: cast_nullable_to_non_nullable
as String?,transactionId: freezed == transactionId ? _self.transactionId : transactionId // ignore: cast_nullable_to_non_nullable
as String?,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String?,webLink: freezed == webLink ? _self.webLink : webLink // ignore: cast_nullable_to_non_nullable
as String?,attachments: freezed == attachments ? _self.attachments : attachments // ignore: cast_nullable_to_non_nullable
as List<Attachment>?,
  ));
}
/// Create a copy of OutlookEventEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DateTimeTimeZoneCopyWith<$Res>? get end {
    if (_self.end == null) {
    return null;
  }

  return $DateTimeTimeZoneCopyWith<$Res>(_self.end!, (value) {
    return _then(_self.copyWith(end: value));
  });
}/// Create a copy of OutlookEventEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocationCopyWith<$Res>? get location {
    if (_self.location == null) {
    return null;
  }

  return $LocationCopyWith<$Res>(_self.location!, (value) {
    return _then(_self.copyWith(location: value));
  });
}/// Create a copy of OutlookEventEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OnlineMeetingInfoCopyWith<$Res>? get onlineMeeting {
    if (_self.onlineMeeting == null) {
    return null;
  }

  return $OnlineMeetingInfoCopyWith<$Res>(_self.onlineMeeting!, (value) {
    return _then(_self.copyWith(onlineMeeting: value));
  });
}/// Create a copy of OutlookEventEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RecipientCopyWith<$Res>? get organizer {
    if (_self.organizer == null) {
    return null;
  }

  return $RecipientCopyWith<$Res>(_self.organizer!, (value) {
    return _then(_self.copyWith(organizer: value));
  });
}/// Create a copy of OutlookEventEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PatternedRecurrenceCopyWith<$Res>? get recurrence {
    if (_self.recurrence == null) {
    return null;
  }

  return $PatternedRecurrenceCopyWith<$Res>(_self.recurrence!, (value) {
    return _then(_self.copyWith(recurrence: value));
  });
}/// Create a copy of OutlookEventEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ResponseStatusCopyWith<$Res>? get responseStatus {
    if (_self.responseStatus == null) {
    return null;
  }

  return $ResponseStatusCopyWith<$Res>(_self.responseStatus!, (value) {
    return _then(_self.copyWith(responseStatus: value));
  });
}/// Create a copy of OutlookEventEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DateTimeTimeZoneCopyWith<$Res>? get start {
    if (_self.start == null) {
    return null;
  }

  return $DateTimeTimeZoneCopyWith<$Res>(_self.start!, (value) {
    return _then(_self.copyWith(start: value));
  });
}
}


/// Adds pattern-matching-related methods to [OutlookEventEntity].
extension OutlookEventEntityPatterns on OutlookEventEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OutlookEventEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OutlookEventEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OutlookEventEntity value)  $default,){
final _that = this;
switch (_that) {
case _OutlookEventEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OutlookEventEntity value)?  $default,){
final _that = this;
switch (_that) {
case _OutlookEventEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool? allowNewTimeProposals,  List<Attendee>? attendees,  ItemBody? body,  String? bodyPreview,  List<String>? cancelledOccurrences,  List<OutlookEventEntity>? exceptionOccurrences,  String? occurrenceId,  List<String>? categories,  String? changeKey,  String? createdDateTime,  DateTimeTimeZone? end,  bool? hasAttachments,  bool? hideAttendees,  String? iCalUId,  String? id,  String? importance,  bool? isAllDay,  bool? isCancelled,  bool? isDraft,  bool? isOnlineMeeting,  bool? isOrganizer,  bool? isReminderOn,  String? lastModifiedDateTime,  Location? location,  List<Location>? locations,  OnlineMeetingInfo? onlineMeeting,  OnlineMeetingProviderType? onlineMeetingProvider,  String? onlineMeetingUrl,  Recipient? organizer,  String? originalEndTimeZone,  String? originalStart,  String? originalStartTimeZone,  PatternedRecurrence? recurrence,  int? reminderMinutesBeforeStart,  bool? responseRequested,  ResponseStatus? responseStatus,  String? sensitivity,  String? seriesMasterId,  String? showAs,  DateTimeTimeZone? start,  String? subject,  String? transactionId,  String? type,  String? webLink,  List<Attachment>? attachments)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OutlookEventEntity() when $default != null:
return $default(_that.allowNewTimeProposals,_that.attendees,_that.body,_that.bodyPreview,_that.cancelledOccurrences,_that.exceptionOccurrences,_that.occurrenceId,_that.categories,_that.changeKey,_that.createdDateTime,_that.end,_that.hasAttachments,_that.hideAttendees,_that.iCalUId,_that.id,_that.importance,_that.isAllDay,_that.isCancelled,_that.isDraft,_that.isOnlineMeeting,_that.isOrganizer,_that.isReminderOn,_that.lastModifiedDateTime,_that.location,_that.locations,_that.onlineMeeting,_that.onlineMeetingProvider,_that.onlineMeetingUrl,_that.organizer,_that.originalEndTimeZone,_that.originalStart,_that.originalStartTimeZone,_that.recurrence,_that.reminderMinutesBeforeStart,_that.responseRequested,_that.responseStatus,_that.sensitivity,_that.seriesMasterId,_that.showAs,_that.start,_that.subject,_that.transactionId,_that.type,_that.webLink,_that.attachments);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool? allowNewTimeProposals,  List<Attendee>? attendees,  ItemBody? body,  String? bodyPreview,  List<String>? cancelledOccurrences,  List<OutlookEventEntity>? exceptionOccurrences,  String? occurrenceId,  List<String>? categories,  String? changeKey,  String? createdDateTime,  DateTimeTimeZone? end,  bool? hasAttachments,  bool? hideAttendees,  String? iCalUId,  String? id,  String? importance,  bool? isAllDay,  bool? isCancelled,  bool? isDraft,  bool? isOnlineMeeting,  bool? isOrganizer,  bool? isReminderOn,  String? lastModifiedDateTime,  Location? location,  List<Location>? locations,  OnlineMeetingInfo? onlineMeeting,  OnlineMeetingProviderType? onlineMeetingProvider,  String? onlineMeetingUrl,  Recipient? organizer,  String? originalEndTimeZone,  String? originalStart,  String? originalStartTimeZone,  PatternedRecurrence? recurrence,  int? reminderMinutesBeforeStart,  bool? responseRequested,  ResponseStatus? responseStatus,  String? sensitivity,  String? seriesMasterId,  String? showAs,  DateTimeTimeZone? start,  String? subject,  String? transactionId,  String? type,  String? webLink,  List<Attachment>? attachments)  $default,) {final _that = this;
switch (_that) {
case _OutlookEventEntity():
return $default(_that.allowNewTimeProposals,_that.attendees,_that.body,_that.bodyPreview,_that.cancelledOccurrences,_that.exceptionOccurrences,_that.occurrenceId,_that.categories,_that.changeKey,_that.createdDateTime,_that.end,_that.hasAttachments,_that.hideAttendees,_that.iCalUId,_that.id,_that.importance,_that.isAllDay,_that.isCancelled,_that.isDraft,_that.isOnlineMeeting,_that.isOrganizer,_that.isReminderOn,_that.lastModifiedDateTime,_that.location,_that.locations,_that.onlineMeeting,_that.onlineMeetingProvider,_that.onlineMeetingUrl,_that.organizer,_that.originalEndTimeZone,_that.originalStart,_that.originalStartTimeZone,_that.recurrence,_that.reminderMinutesBeforeStart,_that.responseRequested,_that.responseStatus,_that.sensitivity,_that.seriesMasterId,_that.showAs,_that.start,_that.subject,_that.transactionId,_that.type,_that.webLink,_that.attachments);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool? allowNewTimeProposals,  List<Attendee>? attendees,  ItemBody? body,  String? bodyPreview,  List<String>? cancelledOccurrences,  List<OutlookEventEntity>? exceptionOccurrences,  String? occurrenceId,  List<String>? categories,  String? changeKey,  String? createdDateTime,  DateTimeTimeZone? end,  bool? hasAttachments,  bool? hideAttendees,  String? iCalUId,  String? id,  String? importance,  bool? isAllDay,  bool? isCancelled,  bool? isDraft,  bool? isOnlineMeeting,  bool? isOrganizer,  bool? isReminderOn,  String? lastModifiedDateTime,  Location? location,  List<Location>? locations,  OnlineMeetingInfo? onlineMeeting,  OnlineMeetingProviderType? onlineMeetingProvider,  String? onlineMeetingUrl,  Recipient? organizer,  String? originalEndTimeZone,  String? originalStart,  String? originalStartTimeZone,  PatternedRecurrence? recurrence,  int? reminderMinutesBeforeStart,  bool? responseRequested,  ResponseStatus? responseStatus,  String? sensitivity,  String? seriesMasterId,  String? showAs,  DateTimeTimeZone? start,  String? subject,  String? transactionId,  String? type,  String? webLink,  List<Attachment>? attachments)?  $default,) {final _that = this;
switch (_that) {
case _OutlookEventEntity() when $default != null:
return $default(_that.allowNewTimeProposals,_that.attendees,_that.body,_that.bodyPreview,_that.cancelledOccurrences,_that.exceptionOccurrences,_that.occurrenceId,_that.categories,_that.changeKey,_that.createdDateTime,_that.end,_that.hasAttachments,_that.hideAttendees,_that.iCalUId,_that.id,_that.importance,_that.isAllDay,_that.isCancelled,_that.isDraft,_that.isOnlineMeeting,_that.isOrganizer,_that.isReminderOn,_that.lastModifiedDateTime,_that.location,_that.locations,_that.onlineMeeting,_that.onlineMeetingProvider,_that.onlineMeetingUrl,_that.organizer,_that.originalEndTimeZone,_that.originalStart,_that.originalStartTimeZone,_that.recurrence,_that.reminderMinutesBeforeStart,_that.responseRequested,_that.responseStatus,_that.sensitivity,_that.seriesMasterId,_that.showAs,_that.start,_that.subject,_that.transactionId,_that.type,_that.webLink,_that.attachments);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OutlookEventEntity implements OutlookEventEntity {
  const _OutlookEventEntity({this.allowNewTimeProposals, final  List<Attendee>? attendees, this.body, this.bodyPreview, final  List<String>? cancelledOccurrences, final  List<OutlookEventEntity>? exceptionOccurrences, this.occurrenceId, final  List<String>? categories, this.changeKey, this.createdDateTime, this.end, this.hasAttachments, this.hideAttendees, this.iCalUId, this.id, this.importance, this.isAllDay, this.isCancelled, this.isDraft, this.isOnlineMeeting, this.isOrganizer, this.isReminderOn, this.lastModifiedDateTime, this.location, final  List<Location>? locations, this.onlineMeeting, this.onlineMeetingProvider, this.onlineMeetingUrl, this.organizer, this.originalEndTimeZone, this.originalStart, this.originalStartTimeZone, this.recurrence, this.reminderMinutesBeforeStart, this.responseRequested, this.responseStatus, this.sensitivity, this.seriesMasterId, this.showAs, this.start, this.subject, this.transactionId, this.type, this.webLink, final  List<Attachment>? attachments}): _attendees = attendees,_cancelledOccurrences = cancelledOccurrences,_exceptionOccurrences = exceptionOccurrences,_categories = categories,_locations = locations,_attachments = attachments;
  factory _OutlookEventEntity.fromJson(Map<String, dynamic> json) => _$OutlookEventEntityFromJson(json);

@override final  bool? allowNewTimeProposals;
 final  List<Attendee>? _attendees;
@override List<Attendee>? get attendees {
  final value = _attendees;
  if (value == null) return null;
  if (_attendees is EqualUnmodifiableListView) return _attendees;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  ItemBody? body;
@override final  String? bodyPreview;
 final  List<String>? _cancelledOccurrences;
@override List<String>? get cancelledOccurrences {
  final value = _cancelledOccurrences;
  if (value == null) return null;
  if (_cancelledOccurrences is EqualUnmodifiableListView) return _cancelledOccurrences;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<OutlookEventEntity>? _exceptionOccurrences;
@override List<OutlookEventEntity>? get exceptionOccurrences {
  final value = _exceptionOccurrences;
  if (value == null) return null;
  if (_exceptionOccurrences is EqualUnmodifiableListView) return _exceptionOccurrences;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  String? occurrenceId;
 final  List<String>? _categories;
@override List<String>? get categories {
  final value = _categories;
  if (value == null) return null;
  if (_categories is EqualUnmodifiableListView) return _categories;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  String? changeKey;
@override final  String? createdDateTime;
@override final  DateTimeTimeZone? end;
@override final  bool? hasAttachments;
@override final  bool? hideAttendees;
@override final  String? iCalUId;
@override final  String? id;
@override final  String? importance;
@override final  bool? isAllDay;
@override final  bool? isCancelled;
@override final  bool? isDraft;
@override final  bool? isOnlineMeeting;
@override final  bool? isOrganizer;
@override final  bool? isReminderOn;
@override final  String? lastModifiedDateTime;
@override final  Location? location;
 final  List<Location>? _locations;
@override List<Location>? get locations {
  final value = _locations;
  if (value == null) return null;
  if (_locations is EqualUnmodifiableListView) return _locations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  OnlineMeetingInfo? onlineMeeting;
@override final  OnlineMeetingProviderType? onlineMeetingProvider;
@override final  String? onlineMeetingUrl;
@override final  Recipient? organizer;
@override final  String? originalEndTimeZone;
@override final  String? originalStart;
@override final  String? originalStartTimeZone;
@override final  PatternedRecurrence? recurrence;
@override final  int? reminderMinutesBeforeStart;
@override final  bool? responseRequested;
@override final  ResponseStatus? responseStatus;
@override final  String? sensitivity;
@override final  String? seriesMasterId;
@override final  String? showAs;
@override final  DateTimeTimeZone? start;
@override final  String? subject;
@override final  String? transactionId;
@override final  String? type;
@override final  String? webLink;
 final  List<Attachment>? _attachments;
@override List<Attachment>? get attachments {
  final value = _attachments;
  if (value == null) return null;
  if (_attachments is EqualUnmodifiableListView) return _attachments;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of OutlookEventEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OutlookEventEntityCopyWith<_OutlookEventEntity> get copyWith => __$OutlookEventEntityCopyWithImpl<_OutlookEventEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OutlookEventEntityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OutlookEventEntity&&(identical(other.allowNewTimeProposals, allowNewTimeProposals) || other.allowNewTimeProposals == allowNewTimeProposals)&&const DeepCollectionEquality().equals(other._attendees, _attendees)&&(identical(other.body, body) || other.body == body)&&(identical(other.bodyPreview, bodyPreview) || other.bodyPreview == bodyPreview)&&const DeepCollectionEquality().equals(other._cancelledOccurrences, _cancelledOccurrences)&&const DeepCollectionEquality().equals(other._exceptionOccurrences, _exceptionOccurrences)&&(identical(other.occurrenceId, occurrenceId) || other.occurrenceId == occurrenceId)&&const DeepCollectionEquality().equals(other._categories, _categories)&&(identical(other.changeKey, changeKey) || other.changeKey == changeKey)&&(identical(other.createdDateTime, createdDateTime) || other.createdDateTime == createdDateTime)&&(identical(other.end, end) || other.end == end)&&(identical(other.hasAttachments, hasAttachments) || other.hasAttachments == hasAttachments)&&(identical(other.hideAttendees, hideAttendees) || other.hideAttendees == hideAttendees)&&(identical(other.iCalUId, iCalUId) || other.iCalUId == iCalUId)&&(identical(other.id, id) || other.id == id)&&(identical(other.importance, importance) || other.importance == importance)&&(identical(other.isAllDay, isAllDay) || other.isAllDay == isAllDay)&&(identical(other.isCancelled, isCancelled) || other.isCancelled == isCancelled)&&(identical(other.isDraft, isDraft) || other.isDraft == isDraft)&&(identical(other.isOnlineMeeting, isOnlineMeeting) || other.isOnlineMeeting == isOnlineMeeting)&&(identical(other.isOrganizer, isOrganizer) || other.isOrganizer == isOrganizer)&&(identical(other.isReminderOn, isReminderOn) || other.isReminderOn == isReminderOn)&&(identical(other.lastModifiedDateTime, lastModifiedDateTime) || other.lastModifiedDateTime == lastModifiedDateTime)&&(identical(other.location, location) || other.location == location)&&const DeepCollectionEquality().equals(other._locations, _locations)&&(identical(other.onlineMeeting, onlineMeeting) || other.onlineMeeting == onlineMeeting)&&(identical(other.onlineMeetingProvider, onlineMeetingProvider) || other.onlineMeetingProvider == onlineMeetingProvider)&&(identical(other.onlineMeetingUrl, onlineMeetingUrl) || other.onlineMeetingUrl == onlineMeetingUrl)&&(identical(other.organizer, organizer) || other.organizer == organizer)&&(identical(other.originalEndTimeZone, originalEndTimeZone) || other.originalEndTimeZone == originalEndTimeZone)&&(identical(other.originalStart, originalStart) || other.originalStart == originalStart)&&(identical(other.originalStartTimeZone, originalStartTimeZone) || other.originalStartTimeZone == originalStartTimeZone)&&(identical(other.recurrence, recurrence) || other.recurrence == recurrence)&&(identical(other.reminderMinutesBeforeStart, reminderMinutesBeforeStart) || other.reminderMinutesBeforeStart == reminderMinutesBeforeStart)&&(identical(other.responseRequested, responseRequested) || other.responseRequested == responseRequested)&&(identical(other.responseStatus, responseStatus) || other.responseStatus == responseStatus)&&(identical(other.sensitivity, sensitivity) || other.sensitivity == sensitivity)&&(identical(other.seriesMasterId, seriesMasterId) || other.seriesMasterId == seriesMasterId)&&(identical(other.showAs, showAs) || other.showAs == showAs)&&(identical(other.start, start) || other.start == start)&&(identical(other.subject, subject) || other.subject == subject)&&(identical(other.transactionId, transactionId) || other.transactionId == transactionId)&&(identical(other.type, type) || other.type == type)&&(identical(other.webLink, webLink) || other.webLink == webLink)&&const DeepCollectionEquality().equals(other._attachments, _attachments));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,allowNewTimeProposals,const DeepCollectionEquality().hash(_attendees),body,bodyPreview,const DeepCollectionEquality().hash(_cancelledOccurrences),const DeepCollectionEquality().hash(_exceptionOccurrences),occurrenceId,const DeepCollectionEquality().hash(_categories),changeKey,createdDateTime,end,hasAttachments,hideAttendees,iCalUId,id,importance,isAllDay,isCancelled,isDraft,isOnlineMeeting,isOrganizer,isReminderOn,lastModifiedDateTime,location,const DeepCollectionEquality().hash(_locations),onlineMeeting,onlineMeetingProvider,onlineMeetingUrl,organizer,originalEndTimeZone,originalStart,originalStartTimeZone,recurrence,reminderMinutesBeforeStart,responseRequested,responseStatus,sensitivity,seriesMasterId,showAs,start,subject,transactionId,type,webLink,const DeepCollectionEquality().hash(_attachments)]);

@override
String toString() {
  return 'OutlookEventEntity(allowNewTimeProposals: $allowNewTimeProposals, attendees: $attendees, body: $body, bodyPreview: $bodyPreview, cancelledOccurrences: $cancelledOccurrences, exceptionOccurrences: $exceptionOccurrences, occurrenceId: $occurrenceId, categories: $categories, changeKey: $changeKey, createdDateTime: $createdDateTime, end: $end, hasAttachments: $hasAttachments, hideAttendees: $hideAttendees, iCalUId: $iCalUId, id: $id, importance: $importance, isAllDay: $isAllDay, isCancelled: $isCancelled, isDraft: $isDraft, isOnlineMeeting: $isOnlineMeeting, isOrganizer: $isOrganizer, isReminderOn: $isReminderOn, lastModifiedDateTime: $lastModifiedDateTime, location: $location, locations: $locations, onlineMeeting: $onlineMeeting, onlineMeetingProvider: $onlineMeetingProvider, onlineMeetingUrl: $onlineMeetingUrl, organizer: $organizer, originalEndTimeZone: $originalEndTimeZone, originalStart: $originalStart, originalStartTimeZone: $originalStartTimeZone, recurrence: $recurrence, reminderMinutesBeforeStart: $reminderMinutesBeforeStart, responseRequested: $responseRequested, responseStatus: $responseStatus, sensitivity: $sensitivity, seriesMasterId: $seriesMasterId, showAs: $showAs, start: $start, subject: $subject, transactionId: $transactionId, type: $type, webLink: $webLink, attachments: $attachments)';
}


}

/// @nodoc
abstract mixin class _$OutlookEventEntityCopyWith<$Res> implements $OutlookEventEntityCopyWith<$Res> {
  factory _$OutlookEventEntityCopyWith(_OutlookEventEntity value, $Res Function(_OutlookEventEntity) _then) = __$OutlookEventEntityCopyWithImpl;
@override @useResult
$Res call({
 bool? allowNewTimeProposals, List<Attendee>? attendees, ItemBody? body, String? bodyPreview, List<String>? cancelledOccurrences, List<OutlookEventEntity>? exceptionOccurrences, String? occurrenceId, List<String>? categories, String? changeKey, String? createdDateTime, DateTimeTimeZone? end, bool? hasAttachments, bool? hideAttendees, String? iCalUId, String? id, String? importance, bool? isAllDay, bool? isCancelled, bool? isDraft, bool? isOnlineMeeting, bool? isOrganizer, bool? isReminderOn, String? lastModifiedDateTime, Location? location, List<Location>? locations, OnlineMeetingInfo? onlineMeeting, OnlineMeetingProviderType? onlineMeetingProvider, String? onlineMeetingUrl, Recipient? organizer, String? originalEndTimeZone, String? originalStart, String? originalStartTimeZone, PatternedRecurrence? recurrence, int? reminderMinutesBeforeStart, bool? responseRequested, ResponseStatus? responseStatus, String? sensitivity, String? seriesMasterId, String? showAs, DateTimeTimeZone? start, String? subject, String? transactionId, String? type, String? webLink, List<Attachment>? attachments
});


@override $DateTimeTimeZoneCopyWith<$Res>? get end;@override $LocationCopyWith<$Res>? get location;@override $OnlineMeetingInfoCopyWith<$Res>? get onlineMeeting;@override $RecipientCopyWith<$Res>? get organizer;@override $PatternedRecurrenceCopyWith<$Res>? get recurrence;@override $ResponseStatusCopyWith<$Res>? get responseStatus;@override $DateTimeTimeZoneCopyWith<$Res>? get start;

}
/// @nodoc
class __$OutlookEventEntityCopyWithImpl<$Res>
    implements _$OutlookEventEntityCopyWith<$Res> {
  __$OutlookEventEntityCopyWithImpl(this._self, this._then);

  final _OutlookEventEntity _self;
  final $Res Function(_OutlookEventEntity) _then;

/// Create a copy of OutlookEventEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? allowNewTimeProposals = freezed,Object? attendees = freezed,Object? body = freezed,Object? bodyPreview = freezed,Object? cancelledOccurrences = freezed,Object? exceptionOccurrences = freezed,Object? occurrenceId = freezed,Object? categories = freezed,Object? changeKey = freezed,Object? createdDateTime = freezed,Object? end = freezed,Object? hasAttachments = freezed,Object? hideAttendees = freezed,Object? iCalUId = freezed,Object? id = freezed,Object? importance = freezed,Object? isAllDay = freezed,Object? isCancelled = freezed,Object? isDraft = freezed,Object? isOnlineMeeting = freezed,Object? isOrganizer = freezed,Object? isReminderOn = freezed,Object? lastModifiedDateTime = freezed,Object? location = freezed,Object? locations = freezed,Object? onlineMeeting = freezed,Object? onlineMeetingProvider = freezed,Object? onlineMeetingUrl = freezed,Object? organizer = freezed,Object? originalEndTimeZone = freezed,Object? originalStart = freezed,Object? originalStartTimeZone = freezed,Object? recurrence = freezed,Object? reminderMinutesBeforeStart = freezed,Object? responseRequested = freezed,Object? responseStatus = freezed,Object? sensitivity = freezed,Object? seriesMasterId = freezed,Object? showAs = freezed,Object? start = freezed,Object? subject = freezed,Object? transactionId = freezed,Object? type = freezed,Object? webLink = freezed,Object? attachments = freezed,}) {
  return _then(_OutlookEventEntity(
allowNewTimeProposals: freezed == allowNewTimeProposals ? _self.allowNewTimeProposals : allowNewTimeProposals // ignore: cast_nullable_to_non_nullable
as bool?,attendees: freezed == attendees ? _self._attendees : attendees // ignore: cast_nullable_to_non_nullable
as List<Attendee>?,body: freezed == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as ItemBody?,bodyPreview: freezed == bodyPreview ? _self.bodyPreview : bodyPreview // ignore: cast_nullable_to_non_nullable
as String?,cancelledOccurrences: freezed == cancelledOccurrences ? _self._cancelledOccurrences : cancelledOccurrences // ignore: cast_nullable_to_non_nullable
as List<String>?,exceptionOccurrences: freezed == exceptionOccurrences ? _self._exceptionOccurrences : exceptionOccurrences // ignore: cast_nullable_to_non_nullable
as List<OutlookEventEntity>?,occurrenceId: freezed == occurrenceId ? _self.occurrenceId : occurrenceId // ignore: cast_nullable_to_non_nullable
as String?,categories: freezed == categories ? _self._categories : categories // ignore: cast_nullable_to_non_nullable
as List<String>?,changeKey: freezed == changeKey ? _self.changeKey : changeKey // ignore: cast_nullable_to_non_nullable
as String?,createdDateTime: freezed == createdDateTime ? _self.createdDateTime : createdDateTime // ignore: cast_nullable_to_non_nullable
as String?,end: freezed == end ? _self.end : end // ignore: cast_nullable_to_non_nullable
as DateTimeTimeZone?,hasAttachments: freezed == hasAttachments ? _self.hasAttachments : hasAttachments // ignore: cast_nullable_to_non_nullable
as bool?,hideAttendees: freezed == hideAttendees ? _self.hideAttendees : hideAttendees // ignore: cast_nullable_to_non_nullable
as bool?,iCalUId: freezed == iCalUId ? _self.iCalUId : iCalUId // ignore: cast_nullable_to_non_nullable
as String?,id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,importance: freezed == importance ? _self.importance : importance // ignore: cast_nullable_to_non_nullable
as String?,isAllDay: freezed == isAllDay ? _self.isAllDay : isAllDay // ignore: cast_nullable_to_non_nullable
as bool?,isCancelled: freezed == isCancelled ? _self.isCancelled : isCancelled // ignore: cast_nullable_to_non_nullable
as bool?,isDraft: freezed == isDraft ? _self.isDraft : isDraft // ignore: cast_nullable_to_non_nullable
as bool?,isOnlineMeeting: freezed == isOnlineMeeting ? _self.isOnlineMeeting : isOnlineMeeting // ignore: cast_nullable_to_non_nullable
as bool?,isOrganizer: freezed == isOrganizer ? _self.isOrganizer : isOrganizer // ignore: cast_nullable_to_non_nullable
as bool?,isReminderOn: freezed == isReminderOn ? _self.isReminderOn : isReminderOn // ignore: cast_nullable_to_non_nullable
as bool?,lastModifiedDateTime: freezed == lastModifiedDateTime ? _self.lastModifiedDateTime : lastModifiedDateTime // ignore: cast_nullable_to_non_nullable
as String?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as Location?,locations: freezed == locations ? _self._locations : locations // ignore: cast_nullable_to_non_nullable
as List<Location>?,onlineMeeting: freezed == onlineMeeting ? _self.onlineMeeting : onlineMeeting // ignore: cast_nullable_to_non_nullable
as OnlineMeetingInfo?,onlineMeetingProvider: freezed == onlineMeetingProvider ? _self.onlineMeetingProvider : onlineMeetingProvider // ignore: cast_nullable_to_non_nullable
as OnlineMeetingProviderType?,onlineMeetingUrl: freezed == onlineMeetingUrl ? _self.onlineMeetingUrl : onlineMeetingUrl // ignore: cast_nullable_to_non_nullable
as String?,organizer: freezed == organizer ? _self.organizer : organizer // ignore: cast_nullable_to_non_nullable
as Recipient?,originalEndTimeZone: freezed == originalEndTimeZone ? _self.originalEndTimeZone : originalEndTimeZone // ignore: cast_nullable_to_non_nullable
as String?,originalStart: freezed == originalStart ? _self.originalStart : originalStart // ignore: cast_nullable_to_non_nullable
as String?,originalStartTimeZone: freezed == originalStartTimeZone ? _self.originalStartTimeZone : originalStartTimeZone // ignore: cast_nullable_to_non_nullable
as String?,recurrence: freezed == recurrence ? _self.recurrence : recurrence // ignore: cast_nullable_to_non_nullable
as PatternedRecurrence?,reminderMinutesBeforeStart: freezed == reminderMinutesBeforeStart ? _self.reminderMinutesBeforeStart : reminderMinutesBeforeStart // ignore: cast_nullable_to_non_nullable
as int?,responseRequested: freezed == responseRequested ? _self.responseRequested : responseRequested // ignore: cast_nullable_to_non_nullable
as bool?,responseStatus: freezed == responseStatus ? _self.responseStatus : responseStatus // ignore: cast_nullable_to_non_nullable
as ResponseStatus?,sensitivity: freezed == sensitivity ? _self.sensitivity : sensitivity // ignore: cast_nullable_to_non_nullable
as String?,seriesMasterId: freezed == seriesMasterId ? _self.seriesMasterId : seriesMasterId // ignore: cast_nullable_to_non_nullable
as String?,showAs: freezed == showAs ? _self.showAs : showAs // ignore: cast_nullable_to_non_nullable
as String?,start: freezed == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as DateTimeTimeZone?,subject: freezed == subject ? _self.subject : subject // ignore: cast_nullable_to_non_nullable
as String?,transactionId: freezed == transactionId ? _self.transactionId : transactionId // ignore: cast_nullable_to_non_nullable
as String?,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String?,webLink: freezed == webLink ? _self.webLink : webLink // ignore: cast_nullable_to_non_nullable
as String?,attachments: freezed == attachments ? _self._attachments : attachments // ignore: cast_nullable_to_non_nullable
as List<Attachment>?,
  ));
}

/// Create a copy of OutlookEventEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DateTimeTimeZoneCopyWith<$Res>? get end {
    if (_self.end == null) {
    return null;
  }

  return $DateTimeTimeZoneCopyWith<$Res>(_self.end!, (value) {
    return _then(_self.copyWith(end: value));
  });
}/// Create a copy of OutlookEventEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocationCopyWith<$Res>? get location {
    if (_self.location == null) {
    return null;
  }

  return $LocationCopyWith<$Res>(_self.location!, (value) {
    return _then(_self.copyWith(location: value));
  });
}/// Create a copy of OutlookEventEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OnlineMeetingInfoCopyWith<$Res>? get onlineMeeting {
    if (_self.onlineMeeting == null) {
    return null;
  }

  return $OnlineMeetingInfoCopyWith<$Res>(_self.onlineMeeting!, (value) {
    return _then(_self.copyWith(onlineMeeting: value));
  });
}/// Create a copy of OutlookEventEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RecipientCopyWith<$Res>? get organizer {
    if (_self.organizer == null) {
    return null;
  }

  return $RecipientCopyWith<$Res>(_self.organizer!, (value) {
    return _then(_self.copyWith(organizer: value));
  });
}/// Create a copy of OutlookEventEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PatternedRecurrenceCopyWith<$Res>? get recurrence {
    if (_self.recurrence == null) {
    return null;
  }

  return $PatternedRecurrenceCopyWith<$Res>(_self.recurrence!, (value) {
    return _then(_self.copyWith(recurrence: value));
  });
}/// Create a copy of OutlookEventEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ResponseStatusCopyWith<$Res>? get responseStatus {
    if (_self.responseStatus == null) {
    return null;
  }

  return $ResponseStatusCopyWith<$Res>(_self.responseStatus!, (value) {
    return _then(_self.copyWith(responseStatus: value));
  });
}/// Create a copy of OutlookEventEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DateTimeTimeZoneCopyWith<$Res>? get start {
    if (_self.start == null) {
    return null;
  }

  return $DateTimeTimeZoneCopyWith<$Res>(_self.start!, (value) {
    return _then(_self.copyWith(start: value));
  });
}
}


/// @nodoc
mixin _$Location {

 String? get displayName; String? get locationEmailAddress; Address? get address; GeoCoordinates? get coordinates;
/// Create a copy of Location
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LocationCopyWith<Location> get copyWith => _$LocationCopyWithImpl<Location>(this as Location, _$identity);

  /// Serializes this Location to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Location&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.locationEmailAddress, locationEmailAddress) || other.locationEmailAddress == locationEmailAddress)&&(identical(other.address, address) || other.address == address)&&(identical(other.coordinates, coordinates) || other.coordinates == coordinates));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,displayName,locationEmailAddress,address,coordinates);

@override
String toString() {
  return 'Location(displayName: $displayName, locationEmailAddress: $locationEmailAddress, address: $address, coordinates: $coordinates)';
}


}

/// @nodoc
abstract mixin class $LocationCopyWith<$Res>  {
  factory $LocationCopyWith(Location value, $Res Function(Location) _then) = _$LocationCopyWithImpl;
@useResult
$Res call({
 String? displayName, String? locationEmailAddress, Address? address, GeoCoordinates? coordinates
});




}
/// @nodoc
class _$LocationCopyWithImpl<$Res>
    implements $LocationCopyWith<$Res> {
  _$LocationCopyWithImpl(this._self, this._then);

  final Location _self;
  final $Res Function(Location) _then;

/// Create a copy of Location
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? displayName = freezed,Object? locationEmailAddress = freezed,Object? address = freezed,Object? coordinates = freezed,}) {
  return _then(_self.copyWith(
displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,locationEmailAddress: freezed == locationEmailAddress ? _self.locationEmailAddress : locationEmailAddress // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as Address?,coordinates: freezed == coordinates ? _self.coordinates : coordinates // ignore: cast_nullable_to_non_nullable
as GeoCoordinates?,
  ));
}

}


/// Adds pattern-matching-related methods to [Location].
extension LocationPatterns on Location {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Location value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Location() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Location value)  $default,){
final _that = this;
switch (_that) {
case _Location():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Location value)?  $default,){
final _that = this;
switch (_that) {
case _Location() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? displayName,  String? locationEmailAddress,  Address? address,  GeoCoordinates? coordinates)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Location() when $default != null:
return $default(_that.displayName,_that.locationEmailAddress,_that.address,_that.coordinates);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? displayName,  String? locationEmailAddress,  Address? address,  GeoCoordinates? coordinates)  $default,) {final _that = this;
switch (_that) {
case _Location():
return $default(_that.displayName,_that.locationEmailAddress,_that.address,_that.coordinates);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? displayName,  String? locationEmailAddress,  Address? address,  GeoCoordinates? coordinates)?  $default,) {final _that = this;
switch (_that) {
case _Location() when $default != null:
return $default(_that.displayName,_that.locationEmailAddress,_that.address,_that.coordinates);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Location implements Location {
  const _Location({this.displayName, this.locationEmailAddress, this.address, this.coordinates});
  factory _Location.fromJson(Map<String, dynamic> json) => _$LocationFromJson(json);

@override final  String? displayName;
@override final  String? locationEmailAddress;
@override final  Address? address;
@override final  GeoCoordinates? coordinates;

/// Create a copy of Location
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LocationCopyWith<_Location> get copyWith => __$LocationCopyWithImpl<_Location>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LocationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Location&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.locationEmailAddress, locationEmailAddress) || other.locationEmailAddress == locationEmailAddress)&&(identical(other.address, address) || other.address == address)&&(identical(other.coordinates, coordinates) || other.coordinates == coordinates));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,displayName,locationEmailAddress,address,coordinates);

@override
String toString() {
  return 'Location(displayName: $displayName, locationEmailAddress: $locationEmailAddress, address: $address, coordinates: $coordinates)';
}


}

/// @nodoc
abstract mixin class _$LocationCopyWith<$Res> implements $LocationCopyWith<$Res> {
  factory _$LocationCopyWith(_Location value, $Res Function(_Location) _then) = __$LocationCopyWithImpl;
@override @useResult
$Res call({
 String? displayName, String? locationEmailAddress, Address? address, GeoCoordinates? coordinates
});




}
/// @nodoc
class __$LocationCopyWithImpl<$Res>
    implements _$LocationCopyWith<$Res> {
  __$LocationCopyWithImpl(this._self, this._then);

  final _Location _self;
  final $Res Function(_Location) _then;

/// Create a copy of Location
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? displayName = freezed,Object? locationEmailAddress = freezed,Object? address = freezed,Object? coordinates = freezed,}) {
  return _then(_Location(
displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,locationEmailAddress: freezed == locationEmailAddress ? _self.locationEmailAddress : locationEmailAddress // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as Address?,coordinates: freezed == coordinates ? _self.coordinates : coordinates // ignore: cast_nullable_to_non_nullable
as GeoCoordinates?,
  ));
}


}


/// @nodoc
mixin _$RecurrencePattern {

 String? get type; int? get interval; int? get month; int? get dayOfMonth; List<String>? get daysOfWeek; String? get firstDayOfWeek; String? get index;
/// Create a copy of RecurrencePattern
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecurrencePatternCopyWith<RecurrencePattern> get copyWith => _$RecurrencePatternCopyWithImpl<RecurrencePattern>(this as RecurrencePattern, _$identity);

  /// Serializes this RecurrencePattern to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecurrencePattern&&(identical(other.type, type) || other.type == type)&&(identical(other.interval, interval) || other.interval == interval)&&(identical(other.month, month) || other.month == month)&&(identical(other.dayOfMonth, dayOfMonth) || other.dayOfMonth == dayOfMonth)&&const DeepCollectionEquality().equals(other.daysOfWeek, daysOfWeek)&&(identical(other.firstDayOfWeek, firstDayOfWeek) || other.firstDayOfWeek == firstDayOfWeek)&&(identical(other.index, index) || other.index == index));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,interval,month,dayOfMonth,const DeepCollectionEquality().hash(daysOfWeek),firstDayOfWeek,index);

@override
String toString() {
  return 'RecurrencePattern(type: $type, interval: $interval, month: $month, dayOfMonth: $dayOfMonth, daysOfWeek: $daysOfWeek, firstDayOfWeek: $firstDayOfWeek, index: $index)';
}


}

/// @nodoc
abstract mixin class $RecurrencePatternCopyWith<$Res>  {
  factory $RecurrencePatternCopyWith(RecurrencePattern value, $Res Function(RecurrencePattern) _then) = _$RecurrencePatternCopyWithImpl;
@useResult
$Res call({
 String? type, int? interval, int? month, int? dayOfMonth, List<String>? daysOfWeek, String? firstDayOfWeek, String? index
});




}
/// @nodoc
class _$RecurrencePatternCopyWithImpl<$Res>
    implements $RecurrencePatternCopyWith<$Res> {
  _$RecurrencePatternCopyWithImpl(this._self, this._then);

  final RecurrencePattern _self;
  final $Res Function(RecurrencePattern) _then;

/// Create a copy of RecurrencePattern
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = freezed,Object? interval = freezed,Object? month = freezed,Object? dayOfMonth = freezed,Object? daysOfWeek = freezed,Object? firstDayOfWeek = freezed,Object? index = freezed,}) {
  return _then(_self.copyWith(
type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String?,interval: freezed == interval ? _self.interval : interval // ignore: cast_nullable_to_non_nullable
as int?,month: freezed == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as int?,dayOfMonth: freezed == dayOfMonth ? _self.dayOfMonth : dayOfMonth // ignore: cast_nullable_to_non_nullable
as int?,daysOfWeek: freezed == daysOfWeek ? _self.daysOfWeek : daysOfWeek // ignore: cast_nullable_to_non_nullable
as List<String>?,firstDayOfWeek: freezed == firstDayOfWeek ? _self.firstDayOfWeek : firstDayOfWeek // ignore: cast_nullable_to_non_nullable
as String?,index: freezed == index ? _self.index : index // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [RecurrencePattern].
extension RecurrencePatternPatterns on RecurrencePattern {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RecurrencePattern value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RecurrencePattern() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RecurrencePattern value)  $default,){
final _that = this;
switch (_that) {
case _RecurrencePattern():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RecurrencePattern value)?  $default,){
final _that = this;
switch (_that) {
case _RecurrencePattern() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? type,  int? interval,  int? month,  int? dayOfMonth,  List<String>? daysOfWeek,  String? firstDayOfWeek,  String? index)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RecurrencePattern() when $default != null:
return $default(_that.type,_that.interval,_that.month,_that.dayOfMonth,_that.daysOfWeek,_that.firstDayOfWeek,_that.index);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? type,  int? interval,  int? month,  int? dayOfMonth,  List<String>? daysOfWeek,  String? firstDayOfWeek,  String? index)  $default,) {final _that = this;
switch (_that) {
case _RecurrencePattern():
return $default(_that.type,_that.interval,_that.month,_that.dayOfMonth,_that.daysOfWeek,_that.firstDayOfWeek,_that.index);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? type,  int? interval,  int? month,  int? dayOfMonth,  List<String>? daysOfWeek,  String? firstDayOfWeek,  String? index)?  $default,) {final _that = this;
switch (_that) {
case _RecurrencePattern() when $default != null:
return $default(_that.type,_that.interval,_that.month,_that.dayOfMonth,_that.daysOfWeek,_that.firstDayOfWeek,_that.index);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RecurrencePattern implements RecurrencePattern {
  const _RecurrencePattern({this.type, this.interval, this.month, this.dayOfMonth, final  List<String>? daysOfWeek, this.firstDayOfWeek, this.index}): _daysOfWeek = daysOfWeek;
  factory _RecurrencePattern.fromJson(Map<String, dynamic> json) => _$RecurrencePatternFromJson(json);

@override final  String? type;
@override final  int? interval;
@override final  int? month;
@override final  int? dayOfMonth;
 final  List<String>? _daysOfWeek;
@override List<String>? get daysOfWeek {
  final value = _daysOfWeek;
  if (value == null) return null;
  if (_daysOfWeek is EqualUnmodifiableListView) return _daysOfWeek;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  String? firstDayOfWeek;
@override final  String? index;

/// Create a copy of RecurrencePattern
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecurrencePatternCopyWith<_RecurrencePattern> get copyWith => __$RecurrencePatternCopyWithImpl<_RecurrencePattern>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RecurrencePatternToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecurrencePattern&&(identical(other.type, type) || other.type == type)&&(identical(other.interval, interval) || other.interval == interval)&&(identical(other.month, month) || other.month == month)&&(identical(other.dayOfMonth, dayOfMonth) || other.dayOfMonth == dayOfMonth)&&const DeepCollectionEquality().equals(other._daysOfWeek, _daysOfWeek)&&(identical(other.firstDayOfWeek, firstDayOfWeek) || other.firstDayOfWeek == firstDayOfWeek)&&(identical(other.index, index) || other.index == index));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,interval,month,dayOfMonth,const DeepCollectionEquality().hash(_daysOfWeek),firstDayOfWeek,index);

@override
String toString() {
  return 'RecurrencePattern(type: $type, interval: $interval, month: $month, dayOfMonth: $dayOfMonth, daysOfWeek: $daysOfWeek, firstDayOfWeek: $firstDayOfWeek, index: $index)';
}


}

/// @nodoc
abstract mixin class _$RecurrencePatternCopyWith<$Res> implements $RecurrencePatternCopyWith<$Res> {
  factory _$RecurrencePatternCopyWith(_RecurrencePattern value, $Res Function(_RecurrencePattern) _then) = __$RecurrencePatternCopyWithImpl;
@override @useResult
$Res call({
 String? type, int? interval, int? month, int? dayOfMonth, List<String>? daysOfWeek, String? firstDayOfWeek, String? index
});




}
/// @nodoc
class __$RecurrencePatternCopyWithImpl<$Res>
    implements _$RecurrencePatternCopyWith<$Res> {
  __$RecurrencePatternCopyWithImpl(this._self, this._then);

  final _RecurrencePattern _self;
  final $Res Function(_RecurrencePattern) _then;

/// Create a copy of RecurrencePattern
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = freezed,Object? interval = freezed,Object? month = freezed,Object? dayOfMonth = freezed,Object? daysOfWeek = freezed,Object? firstDayOfWeek = freezed,Object? index = freezed,}) {
  return _then(_RecurrencePattern(
type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String?,interval: freezed == interval ? _self.interval : interval // ignore: cast_nullable_to_non_nullable
as int?,month: freezed == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as int?,dayOfMonth: freezed == dayOfMonth ? _self.dayOfMonth : dayOfMonth // ignore: cast_nullable_to_non_nullable
as int?,daysOfWeek: freezed == daysOfWeek ? _self._daysOfWeek : daysOfWeek // ignore: cast_nullable_to_non_nullable
as List<String>?,firstDayOfWeek: freezed == firstDayOfWeek ? _self.firstDayOfWeek : firstDayOfWeek // ignore: cast_nullable_to_non_nullable
as String?,index: freezed == index ? _self.index : index // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$ResponseStatus {

 String? get response; String? get time;
/// Create a copy of ResponseStatus
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ResponseStatusCopyWith<ResponseStatus> get copyWith => _$ResponseStatusCopyWithImpl<ResponseStatus>(this as ResponseStatus, _$identity);

  /// Serializes this ResponseStatus to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ResponseStatus&&(identical(other.response, response) || other.response == response)&&(identical(other.time, time) || other.time == time));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,response,time);

@override
String toString() {
  return 'ResponseStatus(response: $response, time: $time)';
}


}

/// @nodoc
abstract mixin class $ResponseStatusCopyWith<$Res>  {
  factory $ResponseStatusCopyWith(ResponseStatus value, $Res Function(ResponseStatus) _then) = _$ResponseStatusCopyWithImpl;
@useResult
$Res call({
 String? response, String? time
});




}
/// @nodoc
class _$ResponseStatusCopyWithImpl<$Res>
    implements $ResponseStatusCopyWith<$Res> {
  _$ResponseStatusCopyWithImpl(this._self, this._then);

  final ResponseStatus _self;
  final $Res Function(ResponseStatus) _then;

/// Create a copy of ResponseStatus
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? response = freezed,Object? time = freezed,}) {
  return _then(_self.copyWith(
response: freezed == response ? _self.response : response // ignore: cast_nullable_to_non_nullable
as String?,time: freezed == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ResponseStatus].
extension ResponseStatusPatterns on ResponseStatus {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ResponseStatus value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ResponseStatus() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ResponseStatus value)  $default,){
final _that = this;
switch (_that) {
case _ResponseStatus():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ResponseStatus value)?  $default,){
final _that = this;
switch (_that) {
case _ResponseStatus() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? response,  String? time)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ResponseStatus() when $default != null:
return $default(_that.response,_that.time);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? response,  String? time)  $default,) {final _that = this;
switch (_that) {
case _ResponseStatus():
return $default(_that.response,_that.time);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? response,  String? time)?  $default,) {final _that = this;
switch (_that) {
case _ResponseStatus() when $default != null:
return $default(_that.response,_that.time);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ResponseStatus implements ResponseStatus {
  const _ResponseStatus({this.response, this.time});
  factory _ResponseStatus.fromJson(Map<String, dynamic> json) => _$ResponseStatusFromJson(json);

@override final  String? response;
@override final  String? time;

/// Create a copy of ResponseStatus
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ResponseStatusCopyWith<_ResponseStatus> get copyWith => __$ResponseStatusCopyWithImpl<_ResponseStatus>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ResponseStatusToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ResponseStatus&&(identical(other.response, response) || other.response == response)&&(identical(other.time, time) || other.time == time));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,response,time);

@override
String toString() {
  return 'ResponseStatus(response: $response, time: $time)';
}


}

/// @nodoc
abstract mixin class _$ResponseStatusCopyWith<$Res> implements $ResponseStatusCopyWith<$Res> {
  factory _$ResponseStatusCopyWith(_ResponseStatus value, $Res Function(_ResponseStatus) _then) = __$ResponseStatusCopyWithImpl;
@override @useResult
$Res call({
 String? response, String? time
});




}
/// @nodoc
class __$ResponseStatusCopyWithImpl<$Res>
    implements _$ResponseStatusCopyWith<$Res> {
  __$ResponseStatusCopyWithImpl(this._self, this._then);

  final _ResponseStatus _self;
  final $Res Function(_ResponseStatus) _then;

/// Create a copy of ResponseStatus
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? response = freezed,Object? time = freezed,}) {
  return _then(_ResponseStatus(
response: freezed == response ? _self.response : response // ignore: cast_nullable_to_non_nullable
as String?,time: freezed == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$PatternedRecurrence {

 RecurrencePattern? get pattern; RecurrenceRange? get range;
/// Create a copy of PatternedRecurrence
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PatternedRecurrenceCopyWith<PatternedRecurrence> get copyWith => _$PatternedRecurrenceCopyWithImpl<PatternedRecurrence>(this as PatternedRecurrence, _$identity);

  /// Serializes this PatternedRecurrence to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PatternedRecurrence&&(identical(other.pattern, pattern) || other.pattern == pattern)&&(identical(other.range, range) || other.range == range));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,pattern,range);

@override
String toString() {
  return 'PatternedRecurrence(pattern: $pattern, range: $range)';
}


}

/// @nodoc
abstract mixin class $PatternedRecurrenceCopyWith<$Res>  {
  factory $PatternedRecurrenceCopyWith(PatternedRecurrence value, $Res Function(PatternedRecurrence) _then) = _$PatternedRecurrenceCopyWithImpl;
@useResult
$Res call({
 RecurrencePattern? pattern, RecurrenceRange? range
});


$RecurrencePatternCopyWith<$Res>? get pattern;$RecurrenceRangeCopyWith<$Res>? get range;

}
/// @nodoc
class _$PatternedRecurrenceCopyWithImpl<$Res>
    implements $PatternedRecurrenceCopyWith<$Res> {
  _$PatternedRecurrenceCopyWithImpl(this._self, this._then);

  final PatternedRecurrence _self;
  final $Res Function(PatternedRecurrence) _then;

/// Create a copy of PatternedRecurrence
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? pattern = freezed,Object? range = freezed,}) {
  return _then(_self.copyWith(
pattern: freezed == pattern ? _self.pattern : pattern // ignore: cast_nullable_to_non_nullable
as RecurrencePattern?,range: freezed == range ? _self.range : range // ignore: cast_nullable_to_non_nullable
as RecurrenceRange?,
  ));
}
/// Create a copy of PatternedRecurrence
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RecurrencePatternCopyWith<$Res>? get pattern {
    if (_self.pattern == null) {
    return null;
  }

  return $RecurrencePatternCopyWith<$Res>(_self.pattern!, (value) {
    return _then(_self.copyWith(pattern: value));
  });
}/// Create a copy of PatternedRecurrence
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RecurrenceRangeCopyWith<$Res>? get range {
    if (_self.range == null) {
    return null;
  }

  return $RecurrenceRangeCopyWith<$Res>(_self.range!, (value) {
    return _then(_self.copyWith(range: value));
  });
}
}


/// Adds pattern-matching-related methods to [PatternedRecurrence].
extension PatternedRecurrencePatterns on PatternedRecurrence {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PatternedRecurrence value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PatternedRecurrence() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PatternedRecurrence value)  $default,){
final _that = this;
switch (_that) {
case _PatternedRecurrence():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PatternedRecurrence value)?  $default,){
final _that = this;
switch (_that) {
case _PatternedRecurrence() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( RecurrencePattern? pattern,  RecurrenceRange? range)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PatternedRecurrence() when $default != null:
return $default(_that.pattern,_that.range);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( RecurrencePattern? pattern,  RecurrenceRange? range)  $default,) {final _that = this;
switch (_that) {
case _PatternedRecurrence():
return $default(_that.pattern,_that.range);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( RecurrencePattern? pattern,  RecurrenceRange? range)?  $default,) {final _that = this;
switch (_that) {
case _PatternedRecurrence() when $default != null:
return $default(_that.pattern,_that.range);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PatternedRecurrence implements PatternedRecurrence {
  const _PatternedRecurrence({this.pattern, this.range});
  factory _PatternedRecurrence.fromJson(Map<String, dynamic> json) => _$PatternedRecurrenceFromJson(json);

@override final  RecurrencePattern? pattern;
@override final  RecurrenceRange? range;

/// Create a copy of PatternedRecurrence
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PatternedRecurrenceCopyWith<_PatternedRecurrence> get copyWith => __$PatternedRecurrenceCopyWithImpl<_PatternedRecurrence>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PatternedRecurrenceToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PatternedRecurrence&&(identical(other.pattern, pattern) || other.pattern == pattern)&&(identical(other.range, range) || other.range == range));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,pattern,range);

@override
String toString() {
  return 'PatternedRecurrence(pattern: $pattern, range: $range)';
}


}

/// @nodoc
abstract mixin class _$PatternedRecurrenceCopyWith<$Res> implements $PatternedRecurrenceCopyWith<$Res> {
  factory _$PatternedRecurrenceCopyWith(_PatternedRecurrence value, $Res Function(_PatternedRecurrence) _then) = __$PatternedRecurrenceCopyWithImpl;
@override @useResult
$Res call({
 RecurrencePattern? pattern, RecurrenceRange? range
});


@override $RecurrencePatternCopyWith<$Res>? get pattern;@override $RecurrenceRangeCopyWith<$Res>? get range;

}
/// @nodoc
class __$PatternedRecurrenceCopyWithImpl<$Res>
    implements _$PatternedRecurrenceCopyWith<$Res> {
  __$PatternedRecurrenceCopyWithImpl(this._self, this._then);

  final _PatternedRecurrence _self;
  final $Res Function(_PatternedRecurrence) _then;

/// Create a copy of PatternedRecurrence
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? pattern = freezed,Object? range = freezed,}) {
  return _then(_PatternedRecurrence(
pattern: freezed == pattern ? _self.pattern : pattern // ignore: cast_nullable_to_non_nullable
as RecurrencePattern?,range: freezed == range ? _self.range : range // ignore: cast_nullable_to_non_nullable
as RecurrenceRange?,
  ));
}

/// Create a copy of PatternedRecurrence
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RecurrencePatternCopyWith<$Res>? get pattern {
    if (_self.pattern == null) {
    return null;
  }

  return $RecurrencePatternCopyWith<$Res>(_self.pattern!, (value) {
    return _then(_self.copyWith(pattern: value));
  });
}/// Create a copy of PatternedRecurrence
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RecurrenceRangeCopyWith<$Res>? get range {
    if (_self.range == null) {
    return null;
  }

  return $RecurrenceRangeCopyWith<$Res>(_self.range!, (value) {
    return _then(_self.copyWith(range: value));
  });
}
}


/// @nodoc
mixin _$DateTimeTimeZone {

 String? get dateTime; String? get timeZone;
/// Create a copy of DateTimeTimeZone
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DateTimeTimeZoneCopyWith<DateTimeTimeZone> get copyWith => _$DateTimeTimeZoneCopyWithImpl<DateTimeTimeZone>(this as DateTimeTimeZone, _$identity);

  /// Serializes this DateTimeTimeZone to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DateTimeTimeZone&&(identical(other.dateTime, dateTime) || other.dateTime == dateTime)&&(identical(other.timeZone, timeZone) || other.timeZone == timeZone));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,dateTime,timeZone);

@override
String toString() {
  return 'DateTimeTimeZone(dateTime: $dateTime, timeZone: $timeZone)';
}


}

/// @nodoc
abstract mixin class $DateTimeTimeZoneCopyWith<$Res>  {
  factory $DateTimeTimeZoneCopyWith(DateTimeTimeZone value, $Res Function(DateTimeTimeZone) _then) = _$DateTimeTimeZoneCopyWithImpl;
@useResult
$Res call({
 String? dateTime, String? timeZone
});




}
/// @nodoc
class _$DateTimeTimeZoneCopyWithImpl<$Res>
    implements $DateTimeTimeZoneCopyWith<$Res> {
  _$DateTimeTimeZoneCopyWithImpl(this._self, this._then);

  final DateTimeTimeZone _self;
  final $Res Function(DateTimeTimeZone) _then;

/// Create a copy of DateTimeTimeZone
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? dateTime = freezed,Object? timeZone = freezed,}) {
  return _then(_self.copyWith(
dateTime: freezed == dateTime ? _self.dateTime : dateTime // ignore: cast_nullable_to_non_nullable
as String?,timeZone: freezed == timeZone ? _self.timeZone : timeZone // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [DateTimeTimeZone].
extension DateTimeTimeZonePatterns on DateTimeTimeZone {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DateTimeTimeZone value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DateTimeTimeZone() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DateTimeTimeZone value)  $default,){
final _that = this;
switch (_that) {
case _DateTimeTimeZone():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DateTimeTimeZone value)?  $default,){
final _that = this;
switch (_that) {
case _DateTimeTimeZone() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? dateTime,  String? timeZone)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DateTimeTimeZone() when $default != null:
return $default(_that.dateTime,_that.timeZone);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? dateTime,  String? timeZone)  $default,) {final _that = this;
switch (_that) {
case _DateTimeTimeZone():
return $default(_that.dateTime,_that.timeZone);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? dateTime,  String? timeZone)?  $default,) {final _that = this;
switch (_that) {
case _DateTimeTimeZone() when $default != null:
return $default(_that.dateTime,_that.timeZone);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DateTimeTimeZone implements DateTimeTimeZone {
  const _DateTimeTimeZone({this.dateTime, this.timeZone});
  factory _DateTimeTimeZone.fromJson(Map<String, dynamic> json) => _$DateTimeTimeZoneFromJson(json);

@override final  String? dateTime;
@override final  String? timeZone;

/// Create a copy of DateTimeTimeZone
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DateTimeTimeZoneCopyWith<_DateTimeTimeZone> get copyWith => __$DateTimeTimeZoneCopyWithImpl<_DateTimeTimeZone>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DateTimeTimeZoneToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DateTimeTimeZone&&(identical(other.dateTime, dateTime) || other.dateTime == dateTime)&&(identical(other.timeZone, timeZone) || other.timeZone == timeZone));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,dateTime,timeZone);

@override
String toString() {
  return 'DateTimeTimeZone(dateTime: $dateTime, timeZone: $timeZone)';
}


}

/// @nodoc
abstract mixin class _$DateTimeTimeZoneCopyWith<$Res> implements $DateTimeTimeZoneCopyWith<$Res> {
  factory _$DateTimeTimeZoneCopyWith(_DateTimeTimeZone value, $Res Function(_DateTimeTimeZone) _then) = __$DateTimeTimeZoneCopyWithImpl;
@override @useResult
$Res call({
 String? dateTime, String? timeZone
});




}
/// @nodoc
class __$DateTimeTimeZoneCopyWithImpl<$Res>
    implements _$DateTimeTimeZoneCopyWith<$Res> {
  __$DateTimeTimeZoneCopyWithImpl(this._self, this._then);

  final _DateTimeTimeZone _self;
  final $Res Function(_DateTimeTimeZone) _then;

/// Create a copy of DateTimeTimeZone
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? dateTime = freezed,Object? timeZone = freezed,}) {
  return _then(_DateTimeTimeZone(
dateTime: freezed == dateTime ? _self.dateTime : dateTime // ignore: cast_nullable_to_non_nullable
as String?,timeZone: freezed == timeZone ? _self.timeZone : timeZone // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$Recipient {

 EmailAddress? get emailAddress;
/// Create a copy of Recipient
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecipientCopyWith<Recipient> get copyWith => _$RecipientCopyWithImpl<Recipient>(this as Recipient, _$identity);

  /// Serializes this Recipient to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Recipient&&(identical(other.emailAddress, emailAddress) || other.emailAddress == emailAddress));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,emailAddress);

@override
String toString() {
  return 'Recipient(emailAddress: $emailAddress)';
}


}

/// @nodoc
abstract mixin class $RecipientCopyWith<$Res>  {
  factory $RecipientCopyWith(Recipient value, $Res Function(Recipient) _then) = _$RecipientCopyWithImpl;
@useResult
$Res call({
 EmailAddress? emailAddress
});




}
/// @nodoc
class _$RecipientCopyWithImpl<$Res>
    implements $RecipientCopyWith<$Res> {
  _$RecipientCopyWithImpl(this._self, this._then);

  final Recipient _self;
  final $Res Function(Recipient) _then;

/// Create a copy of Recipient
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? emailAddress = freezed,}) {
  return _then(_self.copyWith(
emailAddress: freezed == emailAddress ? _self.emailAddress : emailAddress // ignore: cast_nullable_to_non_nullable
as EmailAddress?,
  ));
}

}


/// Adds pattern-matching-related methods to [Recipient].
extension RecipientPatterns on Recipient {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Recipient value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Recipient() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Recipient value)  $default,){
final _that = this;
switch (_that) {
case _Recipient():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Recipient value)?  $default,){
final _that = this;
switch (_that) {
case _Recipient() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( EmailAddress? emailAddress)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Recipient() when $default != null:
return $default(_that.emailAddress);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( EmailAddress? emailAddress)  $default,) {final _that = this;
switch (_that) {
case _Recipient():
return $default(_that.emailAddress);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( EmailAddress? emailAddress)?  $default,) {final _that = this;
switch (_that) {
case _Recipient() when $default != null:
return $default(_that.emailAddress);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Recipient implements Recipient {
  const _Recipient({this.emailAddress});
  factory _Recipient.fromJson(Map<String, dynamic> json) => _$RecipientFromJson(json);

@override final  EmailAddress? emailAddress;

/// Create a copy of Recipient
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecipientCopyWith<_Recipient> get copyWith => __$RecipientCopyWithImpl<_Recipient>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RecipientToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Recipient&&(identical(other.emailAddress, emailAddress) || other.emailAddress == emailAddress));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,emailAddress);

@override
String toString() {
  return 'Recipient(emailAddress: $emailAddress)';
}


}

/// @nodoc
abstract mixin class _$RecipientCopyWith<$Res> implements $RecipientCopyWith<$Res> {
  factory _$RecipientCopyWith(_Recipient value, $Res Function(_Recipient) _then) = __$RecipientCopyWithImpl;
@override @useResult
$Res call({
 EmailAddress? emailAddress
});




}
/// @nodoc
class __$RecipientCopyWithImpl<$Res>
    implements _$RecipientCopyWith<$Res> {
  __$RecipientCopyWithImpl(this._self, this._then);

  final _Recipient _self;
  final $Res Function(_Recipient) _then;

/// Create a copy of Recipient
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? emailAddress = freezed,}) {
  return _then(_Recipient(
emailAddress: freezed == emailAddress ? _self.emailAddress : emailAddress // ignore: cast_nullable_to_non_nullable
as EmailAddress?,
  ));
}


}


/// @nodoc
mixin _$RecurrenceRange {

 String? get endDate; int? get numberOfOccurrences; String? get recurrenceTimeZone; String? get startDate; String? get type;
/// Create a copy of RecurrenceRange
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecurrenceRangeCopyWith<RecurrenceRange> get copyWith => _$RecurrenceRangeCopyWithImpl<RecurrenceRange>(this as RecurrenceRange, _$identity);

  /// Serializes this RecurrenceRange to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecurrenceRange&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.numberOfOccurrences, numberOfOccurrences) || other.numberOfOccurrences == numberOfOccurrences)&&(identical(other.recurrenceTimeZone, recurrenceTimeZone) || other.recurrenceTimeZone == recurrenceTimeZone)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.type, type) || other.type == type));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,endDate,numberOfOccurrences,recurrenceTimeZone,startDate,type);

@override
String toString() {
  return 'RecurrenceRange(endDate: $endDate, numberOfOccurrences: $numberOfOccurrences, recurrenceTimeZone: $recurrenceTimeZone, startDate: $startDate, type: $type)';
}


}

/// @nodoc
abstract mixin class $RecurrenceRangeCopyWith<$Res>  {
  factory $RecurrenceRangeCopyWith(RecurrenceRange value, $Res Function(RecurrenceRange) _then) = _$RecurrenceRangeCopyWithImpl;
@useResult
$Res call({
 String? endDate, int? numberOfOccurrences, String? recurrenceTimeZone, String? startDate, String? type
});




}
/// @nodoc
class _$RecurrenceRangeCopyWithImpl<$Res>
    implements $RecurrenceRangeCopyWith<$Res> {
  _$RecurrenceRangeCopyWithImpl(this._self, this._then);

  final RecurrenceRange _self;
  final $Res Function(RecurrenceRange) _then;

/// Create a copy of RecurrenceRange
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? endDate = freezed,Object? numberOfOccurrences = freezed,Object? recurrenceTimeZone = freezed,Object? startDate = freezed,Object? type = freezed,}) {
  return _then(_self.copyWith(
endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as String?,numberOfOccurrences: freezed == numberOfOccurrences ? _self.numberOfOccurrences : numberOfOccurrences // ignore: cast_nullable_to_non_nullable
as int?,recurrenceTimeZone: freezed == recurrenceTimeZone ? _self.recurrenceTimeZone : recurrenceTimeZone // ignore: cast_nullable_to_non_nullable
as String?,startDate: freezed == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as String?,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [RecurrenceRange].
extension RecurrenceRangePatterns on RecurrenceRange {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RecurrenceRange value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RecurrenceRange() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RecurrenceRange value)  $default,){
final _that = this;
switch (_that) {
case _RecurrenceRange():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RecurrenceRange value)?  $default,){
final _that = this;
switch (_that) {
case _RecurrenceRange() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? endDate,  int? numberOfOccurrences,  String? recurrenceTimeZone,  String? startDate,  String? type)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RecurrenceRange() when $default != null:
return $default(_that.endDate,_that.numberOfOccurrences,_that.recurrenceTimeZone,_that.startDate,_that.type);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? endDate,  int? numberOfOccurrences,  String? recurrenceTimeZone,  String? startDate,  String? type)  $default,) {final _that = this;
switch (_that) {
case _RecurrenceRange():
return $default(_that.endDate,_that.numberOfOccurrences,_that.recurrenceTimeZone,_that.startDate,_that.type);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? endDate,  int? numberOfOccurrences,  String? recurrenceTimeZone,  String? startDate,  String? type)?  $default,) {final _that = this;
switch (_that) {
case _RecurrenceRange() when $default != null:
return $default(_that.endDate,_that.numberOfOccurrences,_that.recurrenceTimeZone,_that.startDate,_that.type);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RecurrenceRange implements RecurrenceRange {
  const _RecurrenceRange({this.endDate, this.numberOfOccurrences, this.recurrenceTimeZone, this.startDate, this.type});
  factory _RecurrenceRange.fromJson(Map<String, dynamic> json) => _$RecurrenceRangeFromJson(json);

@override final  String? endDate;
@override final  int? numberOfOccurrences;
@override final  String? recurrenceTimeZone;
@override final  String? startDate;
@override final  String? type;

/// Create a copy of RecurrenceRange
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecurrenceRangeCopyWith<_RecurrenceRange> get copyWith => __$RecurrenceRangeCopyWithImpl<_RecurrenceRange>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RecurrenceRangeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecurrenceRange&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.numberOfOccurrences, numberOfOccurrences) || other.numberOfOccurrences == numberOfOccurrences)&&(identical(other.recurrenceTimeZone, recurrenceTimeZone) || other.recurrenceTimeZone == recurrenceTimeZone)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.type, type) || other.type == type));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,endDate,numberOfOccurrences,recurrenceTimeZone,startDate,type);

@override
String toString() {
  return 'RecurrenceRange(endDate: $endDate, numberOfOccurrences: $numberOfOccurrences, recurrenceTimeZone: $recurrenceTimeZone, startDate: $startDate, type: $type)';
}


}

/// @nodoc
abstract mixin class _$RecurrenceRangeCopyWith<$Res> implements $RecurrenceRangeCopyWith<$Res> {
  factory _$RecurrenceRangeCopyWith(_RecurrenceRange value, $Res Function(_RecurrenceRange) _then) = __$RecurrenceRangeCopyWithImpl;
@override @useResult
$Res call({
 String? endDate, int? numberOfOccurrences, String? recurrenceTimeZone, String? startDate, String? type
});




}
/// @nodoc
class __$RecurrenceRangeCopyWithImpl<$Res>
    implements _$RecurrenceRangeCopyWith<$Res> {
  __$RecurrenceRangeCopyWithImpl(this._self, this._then);

  final _RecurrenceRange _self;
  final $Res Function(_RecurrenceRange) _then;

/// Create a copy of RecurrenceRange
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? endDate = freezed,Object? numberOfOccurrences = freezed,Object? recurrenceTimeZone = freezed,Object? startDate = freezed,Object? type = freezed,}) {
  return _then(_RecurrenceRange(
endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as String?,numberOfOccurrences: freezed == numberOfOccurrences ? _self.numberOfOccurrences : numberOfOccurrences // ignore: cast_nullable_to_non_nullable
as int?,recurrenceTimeZone: freezed == recurrenceTimeZone ? _self.recurrenceTimeZone : recurrenceTimeZone // ignore: cast_nullable_to_non_nullable
as String?,startDate: freezed == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as String?,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$OnlineMeetingInfo {

 String? get conferenceId; String? get joinUrl; List<Phone>? get phones; String? get quickDial; List<String>? get tollFreeNumbers; String? get tollNumber;
/// Create a copy of OnlineMeetingInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OnlineMeetingInfoCopyWith<OnlineMeetingInfo> get copyWith => _$OnlineMeetingInfoCopyWithImpl<OnlineMeetingInfo>(this as OnlineMeetingInfo, _$identity);

  /// Serializes this OnlineMeetingInfo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OnlineMeetingInfo&&(identical(other.conferenceId, conferenceId) || other.conferenceId == conferenceId)&&(identical(other.joinUrl, joinUrl) || other.joinUrl == joinUrl)&&const DeepCollectionEquality().equals(other.phones, phones)&&(identical(other.quickDial, quickDial) || other.quickDial == quickDial)&&const DeepCollectionEquality().equals(other.tollFreeNumbers, tollFreeNumbers)&&(identical(other.tollNumber, tollNumber) || other.tollNumber == tollNumber));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,conferenceId,joinUrl,const DeepCollectionEquality().hash(phones),quickDial,const DeepCollectionEquality().hash(tollFreeNumbers),tollNumber);

@override
String toString() {
  return 'OnlineMeetingInfo(conferenceId: $conferenceId, joinUrl: $joinUrl, phones: $phones, quickDial: $quickDial, tollFreeNumbers: $tollFreeNumbers, tollNumber: $tollNumber)';
}


}

/// @nodoc
abstract mixin class $OnlineMeetingInfoCopyWith<$Res>  {
  factory $OnlineMeetingInfoCopyWith(OnlineMeetingInfo value, $Res Function(OnlineMeetingInfo) _then) = _$OnlineMeetingInfoCopyWithImpl;
@useResult
$Res call({
 String? conferenceId, String? joinUrl, List<Phone>? phones, String? quickDial, List<String>? tollFreeNumbers, String? tollNumber
});




}
/// @nodoc
class _$OnlineMeetingInfoCopyWithImpl<$Res>
    implements $OnlineMeetingInfoCopyWith<$Res> {
  _$OnlineMeetingInfoCopyWithImpl(this._self, this._then);

  final OnlineMeetingInfo _self;
  final $Res Function(OnlineMeetingInfo) _then;

/// Create a copy of OnlineMeetingInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? conferenceId = freezed,Object? joinUrl = freezed,Object? phones = freezed,Object? quickDial = freezed,Object? tollFreeNumbers = freezed,Object? tollNumber = freezed,}) {
  return _then(_self.copyWith(
conferenceId: freezed == conferenceId ? _self.conferenceId : conferenceId // ignore: cast_nullable_to_non_nullable
as String?,joinUrl: freezed == joinUrl ? _self.joinUrl : joinUrl // ignore: cast_nullable_to_non_nullable
as String?,phones: freezed == phones ? _self.phones : phones // ignore: cast_nullable_to_non_nullable
as List<Phone>?,quickDial: freezed == quickDial ? _self.quickDial : quickDial // ignore: cast_nullable_to_non_nullable
as String?,tollFreeNumbers: freezed == tollFreeNumbers ? _self.tollFreeNumbers : tollFreeNumbers // ignore: cast_nullable_to_non_nullable
as List<String>?,tollNumber: freezed == tollNumber ? _self.tollNumber : tollNumber // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [OnlineMeetingInfo].
extension OnlineMeetingInfoPatterns on OnlineMeetingInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OnlineMeetingInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OnlineMeetingInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OnlineMeetingInfo value)  $default,){
final _that = this;
switch (_that) {
case _OnlineMeetingInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OnlineMeetingInfo value)?  $default,){
final _that = this;
switch (_that) {
case _OnlineMeetingInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? conferenceId,  String? joinUrl,  List<Phone>? phones,  String? quickDial,  List<String>? tollFreeNumbers,  String? tollNumber)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OnlineMeetingInfo() when $default != null:
return $default(_that.conferenceId,_that.joinUrl,_that.phones,_that.quickDial,_that.tollFreeNumbers,_that.tollNumber);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? conferenceId,  String? joinUrl,  List<Phone>? phones,  String? quickDial,  List<String>? tollFreeNumbers,  String? tollNumber)  $default,) {final _that = this;
switch (_that) {
case _OnlineMeetingInfo():
return $default(_that.conferenceId,_that.joinUrl,_that.phones,_that.quickDial,_that.tollFreeNumbers,_that.tollNumber);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? conferenceId,  String? joinUrl,  List<Phone>? phones,  String? quickDial,  List<String>? tollFreeNumbers,  String? tollNumber)?  $default,) {final _that = this;
switch (_that) {
case _OnlineMeetingInfo() when $default != null:
return $default(_that.conferenceId,_that.joinUrl,_that.phones,_that.quickDial,_that.tollFreeNumbers,_that.tollNumber);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OnlineMeetingInfo implements OnlineMeetingInfo {
  const _OnlineMeetingInfo({this.conferenceId, this.joinUrl, final  List<Phone>? phones, this.quickDial, final  List<String>? tollFreeNumbers, this.tollNumber}): _phones = phones,_tollFreeNumbers = tollFreeNumbers;
  factory _OnlineMeetingInfo.fromJson(Map<String, dynamic> json) => _$OnlineMeetingInfoFromJson(json);

@override final  String? conferenceId;
@override final  String? joinUrl;
 final  List<Phone>? _phones;
@override List<Phone>? get phones {
  final value = _phones;
  if (value == null) return null;
  if (_phones is EqualUnmodifiableListView) return _phones;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  String? quickDial;
 final  List<String>? _tollFreeNumbers;
@override List<String>? get tollFreeNumbers {
  final value = _tollFreeNumbers;
  if (value == null) return null;
  if (_tollFreeNumbers is EqualUnmodifiableListView) return _tollFreeNumbers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  String? tollNumber;

/// Create a copy of OnlineMeetingInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OnlineMeetingInfoCopyWith<_OnlineMeetingInfo> get copyWith => __$OnlineMeetingInfoCopyWithImpl<_OnlineMeetingInfo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OnlineMeetingInfoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OnlineMeetingInfo&&(identical(other.conferenceId, conferenceId) || other.conferenceId == conferenceId)&&(identical(other.joinUrl, joinUrl) || other.joinUrl == joinUrl)&&const DeepCollectionEquality().equals(other._phones, _phones)&&(identical(other.quickDial, quickDial) || other.quickDial == quickDial)&&const DeepCollectionEquality().equals(other._tollFreeNumbers, _tollFreeNumbers)&&(identical(other.tollNumber, tollNumber) || other.tollNumber == tollNumber));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,conferenceId,joinUrl,const DeepCollectionEquality().hash(_phones),quickDial,const DeepCollectionEquality().hash(_tollFreeNumbers),tollNumber);

@override
String toString() {
  return 'OnlineMeetingInfo(conferenceId: $conferenceId, joinUrl: $joinUrl, phones: $phones, quickDial: $quickDial, tollFreeNumbers: $tollFreeNumbers, tollNumber: $tollNumber)';
}


}

/// @nodoc
abstract mixin class _$OnlineMeetingInfoCopyWith<$Res> implements $OnlineMeetingInfoCopyWith<$Res> {
  factory _$OnlineMeetingInfoCopyWith(_OnlineMeetingInfo value, $Res Function(_OnlineMeetingInfo) _then) = __$OnlineMeetingInfoCopyWithImpl;
@override @useResult
$Res call({
 String? conferenceId, String? joinUrl, List<Phone>? phones, String? quickDial, List<String>? tollFreeNumbers, String? tollNumber
});




}
/// @nodoc
class __$OnlineMeetingInfoCopyWithImpl<$Res>
    implements _$OnlineMeetingInfoCopyWith<$Res> {
  __$OnlineMeetingInfoCopyWithImpl(this._self, this._then);

  final _OnlineMeetingInfo _self;
  final $Res Function(_OnlineMeetingInfo) _then;

/// Create a copy of OnlineMeetingInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? conferenceId = freezed,Object? joinUrl = freezed,Object? phones = freezed,Object? quickDial = freezed,Object? tollFreeNumbers = freezed,Object? tollNumber = freezed,}) {
  return _then(_OnlineMeetingInfo(
conferenceId: freezed == conferenceId ? _self.conferenceId : conferenceId // ignore: cast_nullable_to_non_nullable
as String?,joinUrl: freezed == joinUrl ? _self.joinUrl : joinUrl // ignore: cast_nullable_to_non_nullable
as String?,phones: freezed == phones ? _self._phones : phones // ignore: cast_nullable_to_non_nullable
as List<Phone>?,quickDial: freezed == quickDial ? _self.quickDial : quickDial // ignore: cast_nullable_to_non_nullable
as String?,tollFreeNumbers: freezed == tollFreeNumbers ? _self._tollFreeNumbers : tollFreeNumbers // ignore: cast_nullable_to_non_nullable
as List<String>?,tollNumber: freezed == tollNumber ? _self.tollNumber : tollNumber // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$Phone {

 String? get number; String? get type;
/// Create a copy of Phone
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PhoneCopyWith<Phone> get copyWith => _$PhoneCopyWithImpl<Phone>(this as Phone, _$identity);

  /// Serializes this Phone to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Phone&&(identical(other.number, number) || other.number == number)&&(identical(other.type, type) || other.type == type));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,number,type);

@override
String toString() {
  return 'Phone(number: $number, type: $type)';
}


}

/// @nodoc
abstract mixin class $PhoneCopyWith<$Res>  {
  factory $PhoneCopyWith(Phone value, $Res Function(Phone) _then) = _$PhoneCopyWithImpl;
@useResult
$Res call({
 String? number, String? type
});




}
/// @nodoc
class _$PhoneCopyWithImpl<$Res>
    implements $PhoneCopyWith<$Res> {
  _$PhoneCopyWithImpl(this._self, this._then);

  final Phone _self;
  final $Res Function(Phone) _then;

/// Create a copy of Phone
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? number = freezed,Object? type = freezed,}) {
  return _then(_self.copyWith(
number: freezed == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as String?,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Phone].
extension PhonePatterns on Phone {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Phone value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Phone() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Phone value)  $default,){
final _that = this;
switch (_that) {
case _Phone():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Phone value)?  $default,){
final _that = this;
switch (_that) {
case _Phone() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? number,  String? type)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Phone() when $default != null:
return $default(_that.number,_that.type);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? number,  String? type)  $default,) {final _that = this;
switch (_that) {
case _Phone():
return $default(_that.number,_that.type);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? number,  String? type)?  $default,) {final _that = this;
switch (_that) {
case _Phone() when $default != null:
return $default(_that.number,_that.type);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Phone implements Phone {
  const _Phone({this.number, this.type});
  factory _Phone.fromJson(Map<String, dynamic> json) => _$PhoneFromJson(json);

@override final  String? number;
@override final  String? type;

/// Create a copy of Phone
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PhoneCopyWith<_Phone> get copyWith => __$PhoneCopyWithImpl<_Phone>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PhoneToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Phone&&(identical(other.number, number) || other.number == number)&&(identical(other.type, type) || other.type == type));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,number,type);

@override
String toString() {
  return 'Phone(number: $number, type: $type)';
}


}

/// @nodoc
abstract mixin class _$PhoneCopyWith<$Res> implements $PhoneCopyWith<$Res> {
  factory _$PhoneCopyWith(_Phone value, $Res Function(_Phone) _then) = __$PhoneCopyWithImpl;
@override @useResult
$Res call({
 String? number, String? type
});




}
/// @nodoc
class __$PhoneCopyWithImpl<$Res>
    implements _$PhoneCopyWith<$Res> {
  __$PhoneCopyWithImpl(this._self, this._then);

  final _Phone _self;
  final $Res Function(_Phone) _then;

/// Create a copy of Phone
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? number = freezed,Object? type = freezed,}) {
  return _then(_Phone(
number: freezed == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as String?,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
