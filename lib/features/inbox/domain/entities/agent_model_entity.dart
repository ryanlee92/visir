import 'package:Visir/features/common/domain/entities/ai_provider_entity.dart';

enum AgentModel {
  // OpenAI models (from platform.openai.com/docs/models)
  gpt5,
  gpt51,
  gpt52,
  gpt5Mini,
  gpt4oMini,
  gpt41Mini,
  // Google AI models
  gemini3ProPreview,
  gemini25Flash,
  gemini25FlashLite,
  gemini25Pro,
  // Anthropic models
  claudeSonnet45,
  claudeHaiku45,
  claudeOpus45;

  AiProvider get provider {
    switch (this) {
      case AgentModel.gpt5:
      case AgentModel.gpt51:
      case AgentModel.gpt52:
      case AgentModel.gpt5Mini:
      case AgentModel.gpt4oMini:
      case AgentModel.gpt41Mini:
        return AiProvider.openai;
      case AgentModel.gemini3ProPreview:
      case AgentModel.gemini25Flash:
      case AgentModel.gemini25FlashLite:
      case AgentModel.gemini25Pro:
        return AiProvider.google;
      case AgentModel.claudeSonnet45:
      case AgentModel.claudeHaiku45:
      case AgentModel.claudeOpus45:
        return AiProvider.anthropic;
    }
  }

  String get modelName {
    switch (this) {
      case AgentModel.gpt5:
        return 'gpt-5';
      case AgentModel.gpt51:
        return 'gpt-5.1';
      case AgentModel.gpt52:
        return 'gpt-5.2';
      case AgentModel.gpt5Mini:
        return 'gpt-5-mini';
      case AgentModel.gpt4oMini:
        return 'gpt-4o-mini';
      case AgentModel.gpt41Mini:
        return 'gpt-4.1-mini';
      case AgentModel.gemini3ProPreview:
        return 'gemini-3-pro-preview';
      case AgentModel.gemini25Flash:
        return 'gemini-2.5-flash';
      case AgentModel.gemini25FlashLite:
        return 'gemini-2.5-flash-lite';
      case AgentModel.gemini25Pro:
        return 'gemini-2.5-pro';
      case AgentModel.claudeSonnet45:
        return 'claude-sonnet-4-5';
      case AgentModel.claudeHaiku45:
        return 'claude-haiku-4-5';
      case AgentModel.claudeOpus45:
        return 'claude-opus-4-5';
    }
  }

  String get displayName {
    switch (this) {
      case AgentModel.gpt5:
        return 'GPT-5';
      case AgentModel.gpt51:
        return 'GPT-5.1';
      case AgentModel.gpt52:
        return 'GPT-5.2';
      case AgentModel.gpt5Mini:
        return 'GPT-5 Mini';
      case AgentModel.gpt4oMini:
        return 'GPT-4o Mini';
      case AgentModel.gpt41Mini:
        return 'GPT-4.1 Mini';
      case AgentModel.gemini3ProPreview:
        return 'Gemini 3 Pro Preview';
      case AgentModel.gemini25Flash:
        return 'Gemini 2.5 Flash';
      case AgentModel.gemini25FlashLite:
        return 'Gemini 2.5 Flash Lite';
      case AgentModel.gemini25Pro:
        return 'Gemini 2.5 Pro';
      case AgentModel.claudeSonnet45:
        return 'Claude Sonnet 4.5';
      case AgentModel.claudeHaiku45:
        return 'Claude Haiku 4.5';
      case AgentModel.claudeOpus45:
        return 'Claude Opus 4.5';
    }
  }

  bool get isDefault {
    switch (this) {
      case AgentModel.gpt4oMini:
      case AgentModel.gemini25Flash:
      case AgentModel.claudeHaiku45:
        return true;
      default:
        return false;
    }
  }
}
