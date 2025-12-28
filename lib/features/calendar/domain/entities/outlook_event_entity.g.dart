// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'outlook_event_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_OutlookEventEntity _$OutlookEventEntityFromJson(Map<String, dynamic> json) =>
    _OutlookEventEntity(
      allowNewTimeProposals: json['allowNewTimeProposals'] as bool?,
      attendees: (json['attendees'] as List<dynamic>?)
          ?.map((e) => Attendee.fromJson(e as Map<String, dynamic>))
          .toList(),
      body: json['body'] == null
          ? null
          : ItemBody.fromJson(json['body'] as Map<String, dynamic>),
      bodyPreview: json['bodyPreview'] as String?,
      cancelledOccurrences: (json['cancelledOccurrences'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      exceptionOccurrences: (json['exceptionOccurrences'] as List<dynamic>?)
          ?.map((e) => OutlookEventEntity.fromJson(e as Map<String, dynamic>))
          .toList(),
      occurrenceId: json['occurrenceId'] as String?,
      categories: (json['categories'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      changeKey: json['changeKey'] as String?,
      createdDateTime: json['createdDateTime'] as String?,
      end: json['end'] == null
          ? null
          : DateTimeTimeZone.fromJson(json['end'] as Map<String, dynamic>),
      hasAttachments: json['hasAttachments'] as bool?,
      hideAttendees: json['hideAttendees'] as bool?,
      iCalUId: json['iCalUId'] as String?,
      id: json['id'] as String?,
      importance: json['importance'] as String?,
      isAllDay: json['isAllDay'] as bool?,
      isCancelled: json['isCancelled'] as bool?,
      isDraft: json['isDraft'] as bool?,
      isOnlineMeeting: json['isOnlineMeeting'] as bool?,
      isOrganizer: json['isOrganizer'] as bool?,
      isReminderOn: json['isReminderOn'] as bool?,
      lastModifiedDateTime: json['lastModifiedDateTime'] as String?,
      location: json['location'] == null
          ? null
          : Location.fromJson(json['location'] as Map<String, dynamic>),
      locations: (json['locations'] as List<dynamic>?)
          ?.map((e) => Location.fromJson(e as Map<String, dynamic>))
          .toList(),
      onlineMeeting: json['onlineMeeting'] == null
          ? null
          : OnlineMeetingInfo.fromJson(
              json['onlineMeeting'] as Map<String, dynamic>,
            ),
      onlineMeetingProvider: $enumDecodeNullable(
        _$OnlineMeetingProviderTypeEnumMap,
        json['onlineMeetingProvider'],
      ),
      onlineMeetingUrl: json['onlineMeetingUrl'] as String?,
      organizer: json['organizer'] == null
          ? null
          : Recipient.fromJson(json['organizer'] as Map<String, dynamic>),
      originalEndTimeZone: json['originalEndTimeZone'] as String?,
      originalStart: json['originalStart'] as String?,
      originalStartTimeZone: json['originalStartTimeZone'] as String?,
      recurrence: json['recurrence'] == null
          ? null
          : PatternedRecurrence.fromJson(
              json['recurrence'] as Map<String, dynamic>,
            ),
      reminderMinutesBeforeStart: (json['reminderMinutesBeforeStart'] as num?)
          ?.toInt(),
      responseRequested: json['responseRequested'] as bool?,
      responseStatus: json['responseStatus'] == null
          ? null
          : ResponseStatus.fromJson(
              json['responseStatus'] as Map<String, dynamic>,
            ),
      sensitivity: json['sensitivity'] as String?,
      seriesMasterId: json['seriesMasterId'] as String?,
      showAs: json['showAs'] as String?,
      start: json['start'] == null
          ? null
          : DateTimeTimeZone.fromJson(json['start'] as Map<String, dynamic>),
      subject: json['subject'] as String?,
      transactionId: json['transactionId'] as String?,
      type: json['type'] as String?,
      webLink: json['webLink'] as String?,
      attachments: (json['attachments'] as List<dynamic>?)
          ?.map((e) => Attachment.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$OutlookEventEntityToJson(_OutlookEventEntity instance) =>
    <String, dynamic>{
      'allowNewTimeProposals': ?instance.allowNewTimeProposals,
      'attendees': ?instance.attendees?.map((e) => e.toJson()).toList(),
      'body': ?instance.body?.toJson(),
      'bodyPreview': ?instance.bodyPreview,
      'cancelledOccurrences': ?instance.cancelledOccurrences,
      'exceptionOccurrences': ?instance.exceptionOccurrences
          ?.map((e) => e.toJson())
          .toList(),
      'occurrenceId': ?instance.occurrenceId,
      'categories': ?instance.categories,
      'changeKey': ?instance.changeKey,
      'createdDateTime': ?instance.createdDateTime,
      'end': ?instance.end?.toJson(),
      'hasAttachments': ?instance.hasAttachments,
      'hideAttendees': ?instance.hideAttendees,
      'iCalUId': ?instance.iCalUId,
      'id': ?instance.id,
      'importance': ?instance.importance,
      'isAllDay': ?instance.isAllDay,
      'isCancelled': ?instance.isCancelled,
      'isDraft': ?instance.isDraft,
      'isOnlineMeeting': ?instance.isOnlineMeeting,
      'isOrganizer': ?instance.isOrganizer,
      'isReminderOn': ?instance.isReminderOn,
      'lastModifiedDateTime': ?instance.lastModifiedDateTime,
      'location': ?instance.location?.toJson(),
      'locations': ?instance.locations?.map((e) => e.toJson()).toList(),
      'onlineMeeting': ?instance.onlineMeeting?.toJson(),
      'onlineMeetingProvider':
          ?_$OnlineMeetingProviderTypeEnumMap[instance.onlineMeetingProvider],
      'onlineMeetingUrl': ?instance.onlineMeetingUrl,
      'organizer': ?instance.organizer?.toJson(),
      'originalEndTimeZone': ?instance.originalEndTimeZone,
      'originalStart': ?instance.originalStart,
      'originalStartTimeZone': ?instance.originalStartTimeZone,
      'recurrence': ?instance.recurrence?.toJson(),
      'reminderMinutesBeforeStart': ?instance.reminderMinutesBeforeStart,
      'responseRequested': ?instance.responseRequested,
      'responseStatus': ?instance.responseStatus?.toJson(),
      'sensitivity': ?instance.sensitivity,
      'seriesMasterId': ?instance.seriesMasterId,
      'showAs': ?instance.showAs,
      'start': ?instance.start?.toJson(),
      'subject': ?instance.subject,
      'transactionId': ?instance.transactionId,
      'type': ?instance.type,
      'webLink': ?instance.webLink,
      'attachments': ?instance.attachments?.map((e) => e.toJson()).toList(),
    };

const _$OnlineMeetingProviderTypeEnumMap = {
  OnlineMeetingProviderType.unknown: 'unknown',
  OnlineMeetingProviderType.teamsForBusiness: 'teamsForBusiness',
  OnlineMeetingProviderType.skypeForBusiness: 'skypeForBusiness',
  OnlineMeetingProviderType.skypeForConsumer: 'skypeForConsumer',
};

_Location _$LocationFromJson(Map<String, dynamic> json) => _Location(
  displayName: json['displayName'] as String?,
  locationEmailAddress: json['locationEmailAddress'] as String?,
  address: json['address'] == null
      ? null
      : Address.fromJson(json['address'] as Map<String, dynamic>),
  coordinates: json['coordinates'] == null
      ? null
      : GeoCoordinates.fromJson(json['coordinates'] as Map<String, dynamic>),
);

Map<String, dynamic> _$LocationToJson(_Location instance) => <String, dynamic>{
  'displayName': ?instance.displayName,
  'locationEmailAddress': ?instance.locationEmailAddress,
  'address': ?instance.address?.toJson(),
  'coordinates': ?instance.coordinates?.toJson(),
};

_RecurrencePattern _$RecurrencePatternFromJson(Map<String, dynamic> json) =>
    _RecurrencePattern(
      type: json['type'] as String?,
      interval: (json['interval'] as num?)?.toInt(),
      month: (json['month'] as num?)?.toInt(),
      dayOfMonth: (json['dayOfMonth'] as num?)?.toInt(),
      daysOfWeek: (json['daysOfWeek'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      firstDayOfWeek: json['firstDayOfWeek'] as String?,
      index: json['index'] as String?,
    );

Map<String, dynamic> _$RecurrencePatternToJson(_RecurrencePattern instance) =>
    <String, dynamic>{
      'type': ?instance.type,
      'interval': ?instance.interval,
      'month': ?instance.month,
      'dayOfMonth': ?instance.dayOfMonth,
      'daysOfWeek': ?instance.daysOfWeek,
      'firstDayOfWeek': ?instance.firstDayOfWeek,
      'index': ?instance.index,
    };

_ResponseStatus _$ResponseStatusFromJson(Map<String, dynamic> json) =>
    _ResponseStatus(
      response: json['response'] as String?,
      time: json['time'] as String?,
    );

Map<String, dynamic> _$ResponseStatusToJson(_ResponseStatus instance) =>
    <String, dynamic>{'response': ?instance.response, 'time': ?instance.time};

_PatternedRecurrence _$PatternedRecurrenceFromJson(Map<String, dynamic> json) =>
    _PatternedRecurrence(
      pattern: json['pattern'] == null
          ? null
          : RecurrencePattern.fromJson(json['pattern'] as Map<String, dynamic>),
      range: json['range'] == null
          ? null
          : RecurrenceRange.fromJson(json['range'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PatternedRecurrenceToJson(
  _PatternedRecurrence instance,
) => <String, dynamic>{
  'pattern': ?instance.pattern?.toJson(),
  'range': ?instance.range?.toJson(),
};

_DateTimeTimeZone _$DateTimeTimeZoneFromJson(Map<String, dynamic> json) =>
    _DateTimeTimeZone(
      dateTime: json['dateTime'] as String?,
      timeZone: json['timeZone'] as String?,
    );

Map<String, dynamic> _$DateTimeTimeZoneToJson(_DateTimeTimeZone instance) =>
    <String, dynamic>{
      'dateTime': ?instance.dateTime,
      'timeZone': ?instance.timeZone,
    };

_Recipient _$RecipientFromJson(Map<String, dynamic> json) => _Recipient(
  emailAddress: json['emailAddress'] == null
      ? null
      : EmailAddress.fromJson(json['emailAddress'] as Map<String, dynamic>),
);

Map<String, dynamic> _$RecipientToJson(_Recipient instance) =>
    <String, dynamic>{'emailAddress': ?instance.emailAddress?.toJson()};

_RecurrenceRange _$RecurrenceRangeFromJson(Map<String, dynamic> json) =>
    _RecurrenceRange(
      endDate: json['endDate'] as String?,
      numberOfOccurrences: (json['numberOfOccurrences'] as num?)?.toInt(),
      recurrenceTimeZone: json['recurrenceTimeZone'] as String?,
      startDate: json['startDate'] as String?,
      type: json['type'] as String?,
    );

Map<String, dynamic> _$RecurrenceRangeToJson(_RecurrenceRange instance) =>
    <String, dynamic>{
      'endDate': ?instance.endDate,
      'numberOfOccurrences': ?instance.numberOfOccurrences,
      'recurrenceTimeZone': ?instance.recurrenceTimeZone,
      'startDate': ?instance.startDate,
      'type': ?instance.type,
    };

_OnlineMeetingInfo _$OnlineMeetingInfoFromJson(Map<String, dynamic> json) =>
    _OnlineMeetingInfo(
      conferenceId: json['conferenceId'] as String?,
      joinUrl: json['joinUrl'] as String?,
      phones: (json['phones'] as List<dynamic>?)
          ?.map((e) => Phone.fromJson(e as Map<String, dynamic>))
          .toList(),
      quickDial: json['quickDial'] as String?,
      tollFreeNumbers: (json['tollFreeNumbers'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      tollNumber: json['tollNumber'] as String?,
    );

Map<String, dynamic> _$OnlineMeetingInfoToJson(_OnlineMeetingInfo instance) =>
    <String, dynamic>{
      'conferenceId': ?instance.conferenceId,
      'joinUrl': ?instance.joinUrl,
      'phones': ?instance.phones?.map((e) => e.toJson()).toList(),
      'quickDial': ?instance.quickDial,
      'tollFreeNumbers': ?instance.tollFreeNumbers,
      'tollNumber': ?instance.tollNumber,
    };

_Phone _$PhoneFromJson(Map<String, dynamic> json) =>
    _Phone(number: json['number'] as String?, type: json['type'] as String?);

Map<String, dynamic> _$PhoneToJson(_Phone instance) => <String, dynamic>{
  'number': ?instance.number,
  'type': ?instance.type,
};
