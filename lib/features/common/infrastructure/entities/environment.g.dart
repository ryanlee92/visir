// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'environment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Environment _$EnvironmentFromJson(Map<String, dynamic> json) => _Environment(
  supabaseUrl: json['supabaseUrl'] as String,
  supabaseAnonKey: json['supabaseAnonKey'] as String,
  googleClientIdDesktop: json['googleClientIdDesktop'] as String,
  googleCliendSecretDesktop: json['googleCliendSecretDesktop'] as String,
  googleClientCallbackUrlDesktop:
      json['googleClientCallbackUrlDesktop'] as String,
  googleClientIdWeb: json['googleClientIdWeb'] as String,
  googleCliendSecretWeb: json['googleCliendSecretWeb'] as String,
  googleClientIdIOS: json['googleClientIdIOS'] as String,
  googleClientIdAndroid: json['googleClientIdAndroid'] as String,
  supabaseAuthCallbackUrlHostname:
      json['supabaseAuthCallbackUrlHostname'] as String?,
  googleAPiWeb: json['googleAPiWeb'] as String,
  googleCalendarWebhookUrl: json['googleCalendarWebhookUrl'] as String,
  slackClientId: json['slackClientId'] as String,
  encryptAESKey: json['encryptAESKey'] as String,
  fcmWebVapidKey: json['fcmWebVapidKey'] as String,
  mixpanelToken: json['mixpanelToken'] as String,
  lemonSqueezyStoreId: json['lemonSqueezyStoreId'] as String,
  openAiApiKey: json['openAiApiKey'] as String,
  microsoftClientSecret: json['microsoftClientSecret'] as String,
  microsoftClientId: json['microsoftClientId'] as String,
  microsoftTenantId: json['microsoftTenantId'] as String,
  appleBundleId: json['appleBundleId'] as String,
  appleTeamId: json['appleTeamId'] as String,
  appleKey: json['appleKey'] as String,
  applePem: json['applePem'] as String,
  googleAiKey: json['googleAiKey'] as String,
  anthropicApiKey: json['anthropicApiKey'] as String,
);

Map<String, dynamic> _$EnvironmentToJson(
  _Environment instance,
) => <String, dynamic>{
  'supabaseUrl': instance.supabaseUrl,
  'supabaseAnonKey': instance.supabaseAnonKey,
  'googleClientIdDesktop': instance.googleClientIdDesktop,
  'googleCliendSecretDesktop': instance.googleCliendSecretDesktop,
  'googleClientCallbackUrlDesktop': instance.googleClientCallbackUrlDesktop,
  'googleClientIdWeb': instance.googleClientIdWeb,
  'googleCliendSecretWeb': instance.googleCliendSecretWeb,
  'googleClientIdIOS': instance.googleClientIdIOS,
  'googleClientIdAndroid': instance.googleClientIdAndroid,
  'supabaseAuthCallbackUrlHostname': ?instance.supabaseAuthCallbackUrlHostname,
  'googleAPiWeb': instance.googleAPiWeb,
  'googleCalendarWebhookUrl': instance.googleCalendarWebhookUrl,
  'slackClientId': instance.slackClientId,
  'encryptAESKey': instance.encryptAESKey,
  'fcmWebVapidKey': instance.fcmWebVapidKey,
  'mixpanelToken': instance.mixpanelToken,
  'lemonSqueezyStoreId': instance.lemonSqueezyStoreId,
  'openAiApiKey': instance.openAiApiKey,
  'microsoftClientSecret': instance.microsoftClientSecret,
  'microsoftClientId': instance.microsoftClientId,
  'microsoftTenantId': instance.microsoftTenantId,
  'appleBundleId': instance.appleBundleId,
  'appleTeamId': instance.appleTeamId,
  'appleKey': instance.appleKey,
  'applePem': instance.applePem,
  'googleAiKey': instance.googleAiKey,
  'anthropicApiKey': instance.anthropicApiKey,
};
