// ignore_for_file: invalid_annotation_target

import 'package:Visir/features/calendar/domain/entities/event_reminder_entity.dart';
import 'package:Visir/features/preference/domain/entities/oauth_entity.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'calendar_entity.freezed.dart';
part 'calendar_entity.g.dart';

enum CalendarEntityType {
  @JsonValue("google")
  google,
  @JsonValue("outlook")
  microsoft,
}

extension CalendarEntityTypeX on CalendarEntityType {
  DatasourceType get datasourceType {
    switch (this) {
      case CalendarEntityType.google:
        return DatasourceType.google;
      case CalendarEntityType.microsoft:
        return DatasourceType.microsoft;
    }
  }

  String get icon => switch (this) {
        CalendarEntityType.google => 'assets/logos/logo_gcal.png',
        CalendarEntityType.microsoft => 'assets/logos/logo_outlook.png',
      };
}

@freezed
abstract class CalendarEntity with _$CalendarEntity {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory CalendarEntity({
    required String id,
    required String name,
    String? email,
    required String backgroundColor,
    required String foregroundColor,
    List<EventReminderEntity>? defaultReminders,
    bool? owned,
    bool? modifiable,
    bool? shareable,
    bool? removable,
    CalendarEntityType? type,
  }) = _CalendarEntity;

  /// Serialization
  factory CalendarEntity.fromJson(Map<String, dynamic> json) => _$CalendarEntityFromJson(json);
}

extension CalendarEntityX on CalendarEntity {
  String get uniqueId => '$id$email';
}
