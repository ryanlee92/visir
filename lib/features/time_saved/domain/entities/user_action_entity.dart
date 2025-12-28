// ignore_for_file: invalid_annotation_target

import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/preference/domain/entities/oauth_entity.dart';
import 'package:Visir/features/preference/presentation/widgets/integration/calendar_integration_widget.dart';
import 'package:Visir/features/preference/presentation/widgets/integration/mail_integration_widget.dart';
import 'package:Visir/features/preference/presentation/widgets/integration/chat_integration_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_action_entity.freezed.dart';
part 'user_action_entity.g.dart';

enum UserActionType {
  task,
  calendar,
  message,
  mail,
}

@freezed
abstract class UserActionEntity with _$UserActionEntity {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory UserActionEntity({
    String? id,
    DateTime? createdAt,
    required UserActionType type,
    OAuthType? oAuthType, //task는 oAuthType == null
    String? identifier, //calendar, email, task는 email, message는 teamName
  }) = _UserActionEntity;

  /// Serialization
  factory UserActionEntity.fromJson(Map<String, dynamic> json) => _$UserActionEntityFromJson(json);
}

extension UserActionEntityX on UserActionEntity {
  String getDescription(BuildContext context) {
    switch (type) {
      case UserActionType.task:
        return context.tr.time_saved_todo;
      case UserActionType.calendar:
        return oAuthType?.getCalendarOAuthTitle(context) ?? '';
      case UserActionType.message:
        return '${oAuthType?.getMessengerOAuthTitle(context) ?? ''} (${identifierName})';
      case UserActionType.mail:
        return '${oAuthType?.getMailOAuthTitle(context) ?? ''} (${identifierName})';
    }
  }

  String get assetPath {
    switch (type) {
      case UserActionType.task:
        return '${(kDebugMode && kIsWeb) ? "" : "assets/"}logos/logo_todo.png';
      case UserActionType.calendar:
        return OAuthTypeCalendarX(oAuthType)?.calendarOAuthAssetPath ?? '';
      case UserActionType.message:
        return OAuthTypeMessengerX(oAuthType)?.messengerOAuthAssetPath ?? '';
      case UserActionType.mail:
        return OAuthTypeMailX(oAuthType)?.mailOAuthAssetPath ?? '';
    }
  }

  String get transitionAssetPath {
    switch (type) {
      case UserActionType.task:
        return '${(kDebugMode && kIsWeb) ? "" : "assets/"}logos/icon_todo_transition.png';
      case UserActionType.calendar:
        return '${(kDebugMode && kIsWeb) ? "" : "assets/"}logos/icon_gcal_transition.png';
      case UserActionType.message:
        return '${(kDebugMode && kIsWeb) ? "" : "assets/"}logos/icon_slack_transition.png';
      case UserActionType.mail:
        return oAuthType == OAuthType.google
            ? '${(kDebugMode && kIsWeb) ? "" : "assets/"}logos/icon_gmail_transition.png'
            : '${(kDebugMode && kIsWeb) ? "" : "assets/"}logos/icon_outlook_transition.png';
    }
  }

  String get identifierName {
    switch (type) {
      case UserActionType.task:
      case UserActionType.calendar:
        return '';
      case UserActionType.message:
      case UserActionType.mail:
        return identifier ?? '';
    }
  }

  String get typeWithIdentifier => '${type}_${oAuthType?.name}_${identifier}';

  bool get isError {
    switch (type) {
      case UserActionType.task:
        return false;
      case UserActionType.calendar:
        return oAuthType == null || oAuthType == OAuthType.slack || assetPath.isEmpty;
      case UserActionType.message:
      case UserActionType.mail:
        return oAuthType == null || identifier == null || assetPath.isEmpty;
    }
  }
}
