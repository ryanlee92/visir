import 'package:freezed_annotation/freezed_annotation.dart';

part 'environment.freezed.dart';
part 'environment.g.dart';

@freezed
abstract class Environment with _$Environment {
  /// Default constructor for the [Environment] model
  /// [supabaseUrl] is the url of the Supabase environment
  /// [supabaseAnonKey] is the anon_key for Supabase

  const factory Environment({
    required String supabaseUrl,
    required String supabaseAnonKey,
    required String googleClientIdDesktop,
    required String googleCliendSecretDesktop,
    required String googleClientCallbackUrlDesktop,
    required String googleClientIdWeb,
    required String googleCliendSecretWeb,
    required String googleClientIdIOS,
    required String googleClientIdAndroid,
    String? supabaseAuthCallbackUrlHostname,
    required String googleAPiWeb,
    required String googleCalendarWebhookUrl,
    required String slackClientId,
    required String encryptAESKey,
    required String fcmWebVapidKey,
    required String mixpanelToken,
    required String lemonSqueezyStoreId,
    required String openAiApiKey,
    required String microsoftClientSecret,
    required String microsoftClientId,
    required String microsoftTenantId,
    required String appleBundleId,
    required String appleTeamId,
    required String appleKey,
    required String applePem,
    required String googleAiKey,
    required String anthropicApiKey,
  }) = _Environment;

  ///
  factory Environment.fromJson(Map<String, dynamic> json) => _$EnvironmentFromJson(json);
}
