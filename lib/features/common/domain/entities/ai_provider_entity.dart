import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:flutter/material.dart';

// fixme(Ryan): Google AI, Anthrophic commented
// enum AiProvider { openai, anthropic, google }
enum AiProvider { openai }

extension AiProviderX on AiProvider {
  String getDisplayName(BuildContext context) {
    switch (this) {
      case AiProvider.openai:
        return context.tr.agent_pref_provider_openai;
      // case AiProvider.anthropic:
      //   return context.tr.agent_pref_provider_anthropic;
      // case AiProvider.google:
      //   return context.tr.agent_pref_provider_google;
    }
  }

  String getApiKeyHint(BuildContext context) {
    switch (this) {
      case AiProvider.openai:
        return context.tr.agent_pref_api_key_hint;
      // case AiProvider.anthropic:
      //   return context.tr.agent_pref_api_key_hint_anthropic;
      // case AiProvider.google:
      //   return context.tr.agent_pref_api_key_hint_google;
    }
  }

  /// Enum의 name을 문자열로 반환 (저장용)
  String get key => name;
}
