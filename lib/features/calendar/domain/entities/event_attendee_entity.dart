// ignore_for_file: invalid_annotation_target

import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:googleapis/calendar/v3.dart' as GoogleCalendar;
import 'package:microsoft_graph_api/models/calendar/attendee_model.dart';
import 'package:microsoft_graph_api/models/calendar/email_address_model.dart';
import 'package:microsoft_graph_api/models/calendar/status_model.dart';

part 'event_attendee_entity.freezed.dart';
part 'event_attendee_entity.g.dart';

enum EventAttendeeResponseStatus {
  @JsonValue("needsAction")
  needsAction,
  @JsonValue("declined")
  declined,
  @JsonValue("tentative")
  tentative,
  @JsonValue("accepted")
  accepted,
}

extension EventAttendeeResponseStatusX on EventAttendeeResponseStatus {
  String get toGoogle {
    return switch (this) {
      EventAttendeeResponseStatus.needsAction => 'needsAction',
      EventAttendeeResponseStatus.declined => 'declined',
      EventAttendeeResponseStatus.tentative => 'tentative',
      EventAttendeeResponseStatus.accepted => 'accepted',
    };
  }

  String get toMs {
    return switch (this) {
      EventAttendeeResponseStatus.needsAction => 'none',
      EventAttendeeResponseStatus.declined => 'declined',
      EventAttendeeResponseStatus.tentative => 'tentativelyAccepted',
      EventAttendeeResponseStatus.accepted => 'accepted',
    };
  }

  String get toMsApi {
    return switch (this) {
      EventAttendeeResponseStatus.needsAction => 'none',
      EventAttendeeResponseStatus.declined => 'decline',
      EventAttendeeResponseStatus.tentative => 'tentativelyAccept',
      EventAttendeeResponseStatus.accepted => 'accept',
    };
  }

  static EventAttendeeResponseStatus fromGoogle(String? value) {
    return switch (value) {
      'needsAction' => EventAttendeeResponseStatus.needsAction,
      'declined' => EventAttendeeResponseStatus.declined,
      'tentative' => EventAttendeeResponseStatus.tentative,
      'accepted' => EventAttendeeResponseStatus.accepted,
      _ => EventAttendeeResponseStatus.needsAction,
    };
  }

  static EventAttendeeResponseStatus fromMs(String? value) {
    return switch (value) {
      'none' => EventAttendeeResponseStatus.needsAction,
      'notResponded' => EventAttendeeResponseStatus.needsAction,
      'declined' => EventAttendeeResponseStatus.declined,
      'tentativelyAccepted' => EventAttendeeResponseStatus.tentative,
      'accepted' => EventAttendeeResponseStatus.accepted,
      'organizer' => EventAttendeeResponseStatus.accepted,
      _ => EventAttendeeResponseStatus.needsAction,
    };
  }

  String getTitle(BuildContext context) {
    switch (this) {
      case EventAttendeeResponseStatus.accepted:
        return context.tr.yes;
      case EventAttendeeResponseStatus.tentative:
        return context.tr.maybe;
      case EventAttendeeResponseStatus.declined:
        return context.tr.no;
      case EventAttendeeResponseStatus.needsAction:
        return context.tr.maybe;
    }
  }

  Color getBackgroundColor(BuildContext context) {
    switch (this) {
      case EventAttendeeResponseStatus.accepted:
        return context.primary;
      case EventAttendeeResponseStatus.tentative:
        return context.secondary;
      case EventAttendeeResponseStatus.declined:
        return context.error;
      case EventAttendeeResponseStatus.needsAction:
        return context.tertiary;
    }
  }

  Color getForegroundColor(BuildContext context) {
    switch (this) {
      case EventAttendeeResponseStatus.accepted:
        return context.onPrimary;
      case EventAttendeeResponseStatus.tentative:
        return context.onSecondary;
      case EventAttendeeResponseStatus.declined:
        return context.onError;
      case EventAttendeeResponseStatus.needsAction:
        return context.onTertiary;
    }
  }
}

@freezed
abstract class EventAttendeeEntity with _$EventAttendeeEntity {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory EventAttendeeEntity({
    String? comment,
    String? displayName,
    String? email,
    String? id,
    bool? organizer,
    EventAttendeeResponseStatus? responseStatus,
  }) = _EventAttendeeEntity;

  /// Serialization
  factory EventAttendeeEntity.fromJson(Map<String, dynamic> json) => _$EventAttendeeEntityFromJson(json);
}

extension EventAttendeeEntityX on EventAttendeeEntity {
  GoogleCalendar.EventAttendee toGoogleCalendarEventAttendee() {
    return GoogleCalendar.EventAttendee(
      comment: comment,
      displayName: displayName,
      email: email,
      id: id,
      organizer: organizer,
      responseStatus: responseStatus?.toGoogle,
    );
  }

  Attendee toMsCalendarEventAttendee() {
    return Attendee(
      emailAddress: EmailAddress(name: displayName, address: email),
      status: Status(response: responseStatus?.toMs, time: DateTime.now().toUtc().toIso8601String()),
    );
  }

  static EventAttendeeEntity fromGoogleCalendarEventAttendee(GoogleCalendar.EventAttendee eventAttendee) {
    return EventAttendeeEntity(
      displayName: eventAttendee.displayName,
      email: eventAttendee.email,
      organizer: eventAttendee.organizer,
      responseStatus: EventAttendeeResponseStatusX.fromGoogle(eventAttendee.responseStatus),
      comment: eventAttendee.comment,
      id: eventAttendee.id,
    );
  }

  static EventAttendeeEntity fromMsCalendarEventAttendee(Attendee eventAttendee) {
    return EventAttendeeEntity(
      displayName: eventAttendee.emailAddress?.name,
      email: eventAttendee.emailAddress?.address,
      organizer: eventAttendee.status?.response == 'organizer',
      responseStatus: EventAttendeeResponseStatusX.fromMs(eventAttendee.status?.response),
    );
  }
}
