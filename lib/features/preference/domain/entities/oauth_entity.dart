// ignore_for_file: invalid_annotation_target

import 'package:Visir/features/calendar/domain/entities/calendar_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_channel_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_team_entity.dart';
import 'package:Visir/features/mail/domain/entities/mail_entity.dart';
import 'package:Visir/features/preference/presentation/widgets/integration/calendar_integration_widget.dart';
import 'package:Visir/features/preference/presentation/widgets/integration/chat_integration_widget.dart';
import 'package:Visir/features/preference/presentation/widgets/integration/mail_integration_widget.dart';
import 'package:flutter/widgets.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'oauth_entity.freezed.dart';
part 'oauth_entity.g.dart';

enum DatasourceType { supabase, openai, firebase, google, apple, microsoft, slack, discord }

enum OAuthType {
  @JsonValue("google")
  google,
  @JsonValue("apple")
  apple,
  @JsonValue("microsoft")
  microsoft,
  @JsonValue("slack")
  slack,
  @JsonValue("discord")
  discord,
}

extension OAuthTypeX on OAuthType {
  DatasourceType get datasourceType {
    switch (this) {
      case OAuthType.google:
        return DatasourceType.google;
      case OAuthType.apple:
        return DatasourceType.apple;
      case OAuthType.microsoft:
        return DatasourceType.microsoft;
      case OAuthType.slack:
        return DatasourceType.slack;
      case OAuthType.discord:
        return DatasourceType.discord;
    }
  }

  MessageEntityType? get messageType {
    switch (this) {
      case OAuthType.slack:
        return MessageEntityType.slack;
      default:
        return null;
    }
  }

  MessageChannelEntityType? get chatChannelType {
    switch (this) {
      case OAuthType.slack:
        return MessageChannelEntityType.slack;
      default:
        return null;
    }
  }

  MailEntityType? get mailType {
    switch (this) {
      case OAuthType.google:
        return MailEntityType.google;
      case OAuthType.microsoft:
        return MailEntityType.microsoft;
      default:
        return null;
    }
  }

  CalendarEntityType? get calendarType {
    switch (this) {
      case OAuthType.google:
        return CalendarEntityType.google;
      case OAuthType.microsoft:
        return CalendarEntityType.microsoft;
      default:
        return null;
    }
  }

  String getAnalyticsServiceName({required bool isCalendar, required bool isMail}) {
    switch (this) {
      case OAuthType.google:
        return isCalendar ? 'google_calendar' : 'gmail';
      case OAuthType.microsoft:
        return isCalendar ? 'outlook_calendar' : 'outlook_mail';
      case OAuthType.apple:
        return '';
      case OAuthType.slack:
        return 'slack';
      case OAuthType.discord:
        return 'discord';
    }
  }

  String getOAuthProviderName({required BuildContext context, required bool isMail}) {
    switch (this) {
      case OAuthType.google:
        return isMail ? this.getMailOAuthTitle(context) : this.getCalendarOAuthTitle(context);
      case OAuthType.microsoft:
        return isMail ? this.getMailOAuthTitle(context) : this.getCalendarOAuthTitle(context);
      case OAuthType.slack:
      case OAuthType.discord:
        return this.getMessengerOAuthTitle(context);
      case OAuthType.apple:
        return '';
    }
  }
}

@freezed
abstract class OAuthEntity with _$OAuthEntity {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory OAuthEntity({
    required String email,
    String? name,
    String? imageUrl,
    String? notificationUrl,
    String? serverCode,
    required Map<String, dynamic> accessToken,
    required String refreshToken,
    required OAuthType type,
    MessageTeamEntity? team,
    bool? needReAuth,
  }) = _OAuthEntity;

  /// Serialization
  factory OAuthEntity.fromJson(Map<String, dynamic> json) => _$OAuthEntityFromJson(json);
}

extension OAuthEntityX on OAuthEntity {
  Map<String, String>? get authorizationHeaders {
    switch (type) {
      case OAuthType.slack:
        if (accessToken.containsKey('cookie')) return {'Authorization': 'Bearer ${accessToken['access_token']}', 'cookie': 'd=${accessToken['cookie']}'};
        return {'Authorization': 'Bearer ${accessToken['access_token']}'};
      default:
        return null;
    }
  }

  bool get isAppAuth {
    switch (type) {
      case OAuthType.slack:
        if (accessToken.containsKey('cookie')) return false;
        return true;
      default:
        return true;
    }
  }

  String? get teamId => team?.id;

  String? get teamName => team?.name;

  String get uniqueId => '${type.name}_${email}_${teamId}';
}
