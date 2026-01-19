import 'package:shared_preferences/shared_preferences.dart';
import 'package:Visir/features/common/presentation/utils/log_event.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service to track first-time feature usage for funnel analytics
class FirstTimeTracker {
  static const String _prefixKey = 'first_time_';
  static const String _appInstalledKey = 'app_installed';
  static const String _gaClientIdKey = 'ga_client_id';
  static const String _utmSourceKey = 'utm_source';
  static const String _utmMediumKey = 'utm_medium';
  static const String _utmCampaignKey = 'utm_campaign';
  static const String _utmTermKey = 'utm_term';
  static const String _utmContentKey = 'utm_content';

  /// Track feature if it's the first time user uses it
  static Future<void> trackFeatureIfFirst(
    String featureName, {
    Map<String, dynamic>? additionalProperties,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_prefixKey$featureName';
    final hasUsedFeature = prefs.getBool(key) ?? false;

    if (!hasUsedFeature) {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId != null) {
        await logFirstTimeFeature(
          featureName: featureName,
          userId: userId,
          additionalProperties: additionalProperties,
        );

        await prefs.setBool(key, true);
      }
    }
  }

  /// Track app installation on first launch
  static Future<void> trackAppInstallIfFirst({
    String? gaClientId,
    String? utmSource,
    String? utmMedium,
    String? utmCampaign,
    String? utmTerm,
    String? utmContent,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final hasInstalled = prefs.getBool(_appInstalledKey) ?? false;

    if (!hasInstalled) {
      // Store attribution data for later use
      if (gaClientId != null) {
        await prefs.setString(_gaClientIdKey, gaClientId);
      }
      if (utmSource != null) {
        await prefs.setString(_utmSourceKey, utmSource);
      }
      if (utmMedium != null) {
        await prefs.setString(_utmMediumKey, utmMedium);
      }
      if (utmCampaign != null) {
        await prefs.setString(_utmCampaignKey, utmCampaign);
      }
      if (utmTerm != null) {
        await prefs.setString(_utmTermKey, utmTerm);
      }
      if (utmContent != null) {
        await prefs.setString(_utmContentKey, utmContent);
      }

      // Log app install event
      final userId = Supabase.instance.client.auth.currentUser?.id;
      await logAppInstall(
        gaClientId: gaClientId,
        utmSource: utmSource,
        utmMedium: utmMedium,
        utmCampaign: utmCampaign,
        utmTerm: utmTerm,
        utmContent: utmContent,
        userId: userId,
      );

      await prefs.setBool(_appInstalledKey, true);
    }
  }

  /// Get stored attribution data
  static Future<Map<String, String?>> getAttributionData() async {
    final prefs = await SharedPreferences.getInstance();

    return {
      'ga_client_id': prefs.getString(_gaClientIdKey),
      'utm_source': prefs.getString(_utmSourceKey),
      'utm_medium': prefs.getString(_utmMediumKey),
      'utm_campaign': prefs.getString(_utmCampaignKey),
      'utm_term': prefs.getString(_utmTermKey),
      'utm_content': prefs.getString(_utmContentKey),
    };
  }

  /// Check if feature has been used before
  static Future<bool> hasUsedFeature(String featureName) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_prefixKey$featureName';
    return prefs.getBool(key) ?? false;
  }

  /// Reset all first-time flags (for testing only)
  static Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith(_prefixKey) || k == _appInstalledKey);
    for (final key in keys) {
      await prefs.remove(key);
    }
  }
}
