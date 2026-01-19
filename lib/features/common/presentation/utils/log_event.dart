import 'dart:convert';

import 'package:Visir/config/providers.dart';
import 'package:Visir/features/auth/domain/entities/user_entity.dart';
import 'package:Visir/features/calendar/presentation/widgets/calendar_simple_create_widget.dart';
import 'package:Visir/features/common/infrastructure/entities/environment.dart';
import 'package:Visir/features/common/presentation/utils/extensions/platform_extension.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/flavors.dart';
import 'package:change_case/change_case.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> logAnalyticsEvent({required String eventName, String? userId, Map<String, dynamic>? properties}) async {
  try {
    final deviceId = Utils.ref.read(deviceIdProvider).asData?.value;

    final configFile = await rootBundle.loadString('assets/config/${F.envFileName}');
    final env = Environment.fromJson(json.decode(configFile) as Map<String, dynamic>);
    // Edge Function에서 가져온 키 사용, 없으면 config.json에서 가져오기 (fallback)
    final finalMixpanelToken = mixpanelToken.isNotEmpty ? mixpanelToken : env.mixpanelToken;
    if (finalMixpanelToken.isNotEmpty != true) {
      return;
    } else {
      Map<String, dynamic> eventData = {
        "event": eventName.toSnakeCase(),
        "properties": {
          "token": finalMixpanelToken,
          "platform": PlatformX.name,
          "distinct_id": userId ?? Supabase.instance.client.auth.currentUser?.id,
          if (deviceId != null) "device_id": deviceId,
          if (properties != null) ...properties,
        },
      };

      http.post(
        Uri.parse("https://api.mixpanel.com/track?ip=1"),
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: {"data": base64Encode(utf8.encode(jsonEncode(eventData)))}, // Mixpanel API는 "data" 필드에 Base64 인코딩된 JSON을 요구함
      );
    }
  } catch (e) {}
}

Future<void> setAnalyticsUserProfile({required UserEntity user, int? moneySaved}) async {
  String moneySavedUserPropertyName = "Money Saved";

  try {
    final configFile = await rootBundle.loadString('assets/config/${F.envFileName}');
    final env = Environment.fromJson(json.decode(configFile) as Map<String, dynamic>);
    // Edge Function에서 가져온 키 사용, 없으면 config.json에서 가져오기 (fallback)
    final finalMixpanelToken = mixpanelToken.isNotEmpty ? mixpanelToken : env.mixpanelToken;

    if (finalMixpanelToken.isNotEmpty != true) {
      return;
    } else {
      Map<String, dynamic> profileData = {
        "\$token": finalMixpanelToken,
        "\$distinct_id": user.id,
        "\$set": {"\$email": user.email, "user_id": user.id, if (moneySaved != null) moneySavedUserPropertyName: moneySaved},
      };

      http.post(
        Uri.parse("https://api.mixpanel.com/engage?ip=1#profile-set"),
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: {"data": base64Encode(utf8.encode(jsonEncode(profileData)))}, // Mixpanel API는 "data" 필드에 Base64 인코딩된 JSON을 요구함
      );
    }
  } catch (e) {}
}

void logCalendarTaskCreateEvent({
  required CalendarTaskEditSourceType calendarTaskEditSourceType,
  required TabType tabType,
  required bool isEvent,
  required bool isLinkedWithMessages,
  required bool isLinkedWithMails,
  required bool isChannel,
  required bool isRepeat,
  required DateTime startDate,
}) {
  String eventName = calendarTaskEditSourceType.getAnalyticsEventTitle(
    tabType: tabType,
    isEvent: isEvent,
    isLinkedWithMessages: isLinkedWithMessages,
    isLinkedWithMails: isLinkedWithMails,
    isChannel: isChannel,
  );
  if (eventName.isNotEmpty) {
    logAnalyticsEvent(
      eventName: eventName,
      properties: calendarTaskEditSourceType.getAnalyticsEventProperties(tabType: tabType, isChannel: isChannel, isRepeat: isRepeat, startAt: startDate),
    );
  }
}

/// Logs app installation with GA4 client ID and UTM params for funnel tracking
/// Should be called on first app launch after installation
Future<void> logAppInstall({
  String? gaClientId,
  String? utmSource,
  String? utmMedium,
  String? utmCampaign,
  String? utmTerm,
  String? utmContent,
  String? userId,
}) async {
  await logAnalyticsEvent(
    eventName: 'app_install',
    userId: userId,
    properties: {
      'platform': PlatformX.name,
      if (gaClientId != null) 'ga_client_id': gaClientId,
      if (utmSource != null) 'utm_source': utmSource,
      if (utmMedium != null) 'utm_medium': utmMedium,
      if (utmCampaign != null) 'utm_campaign': utmCampaign,
      if (utmTerm != null) 'utm_term': utmTerm,
      if (utmContent != null) 'utm_content': utmContent,
    },
  );
}

/// Logs when user completes signup
Future<void> logSignupCompleted({
  required String userId,
  required String signupMethod,
  String? gaClientId,
  String? utmSource,
}) async {
  await logAnalyticsEvent(
    eventName: 'signup_completed',
    userId: userId,
    properties: {
      'signup_method': signupMethod,
      if (gaClientId != null) 'ga_client_id': gaClientId,
      if (utmSource != null) 'utm_source': utmSource,
    },
  );
}

/// Logs first-time feature usage for funnel tracking
Future<void> logFirstTimeFeature({
  required String featureName,
  required String userId,
  Map<String, dynamic>? additionalProperties,
}) async {
  await logAnalyticsEvent(
    eventName: 'first_${featureName}_usage',
    userId: userId,
    properties: {
      'feature_name': featureName,
      if (additionalProperties != null) ...additionalProperties,
    },
  );
}

/// Logs when user starts a subscription
Future<void> logSubscriptionStarted({
  required String userId,
  required String plan,
  required double amount,
  String? currency,
  String? billingInterval,
}) async {
  await logAnalyticsEvent(
    eventName: 'subscription_started',
    userId: userId,
    properties: {
      'plan': plan,
      'amount': amount,
      'currency': currency ?? 'USD',
      if (billingInterval != null) 'billing_interval': billingInterval,
    },
  );
}

/// Logs when user cancels a subscription
Future<void> logSubscriptionCancelled({
  required String userId,
  required String plan,
  String? reason,
}) async {
  await logAnalyticsEvent(
    eventName: 'subscription_cancelled',
    userId: userId,
    properties: {
      'plan': plan,
      if (reason != null) 'cancellation_reason': reason,
    },
  );
}

/// Logs when user's subscription is renewed
Future<void> logSubscriptionRenewed({
  required String userId,
  required String plan,
  required double amount,
}) async {
  await logAnalyticsEvent(
    eventName: 'subscription_renewed',
    userId: userId,
    properties: {
      'plan': plan,
      'amount': amount,
    },
  );
}
