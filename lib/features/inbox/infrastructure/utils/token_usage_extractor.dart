/// Token usage information extracted from API responses
class TokenUsage {
  final int promptTokens;
  final int completionTokens;
  final int totalTokens;

  TokenUsage({
    required this.promptTokens,
    required this.completionTokens,
    required this.totalTokens,
  });
}

/// Utility class for extracting token usage from API responses
class TokenUsageExtractor {
  /// Extract token usage from OpenAI API response
  /// 
  /// OpenAI API response format:
  /// {
  ///   "usage": {
  ///     "prompt_tokens": 10,
  ///     "completion_tokens": 20,
  ///     "total_tokens": 30
  ///   }
  /// }
  static TokenUsage? extractFromOpenAi(Map<String, dynamic> response) {
    try {
      final usage = response['usage'] as Map<String, dynamic>?;
      if (usage == null) return null;

      final promptTokens = usage['prompt_tokens'] as int? ?? 0;
      final completionTokens = usage['completion_tokens'] as int? ?? 0;
      final totalTokens = usage['total_tokens'] as int? ?? (promptTokens + completionTokens);

      return TokenUsage(
        promptTokens: promptTokens,
        completionTokens: completionTokens,
        totalTokens: totalTokens,
      );
    } catch (e) {
      return null;
    }
  }

  /// Extract token usage from Google AI API response
  /// 
  /// Google AI API response format:
  /// {
  ///   "usageMetadata": {
  ///     "promptTokenCount": 10,
  ///     "candidatesTokenCount": 20,
  ///     "totalTokenCount": 30
  ///   }
  /// }
  static TokenUsage? extractFromGoogleAi(Map<String, dynamic> response) {
    try {
      final usageMetadata = response['usageMetadata'] as Map<String, dynamic>?;
      if (usageMetadata == null) return null;

      final promptTokens = usageMetadata['promptTokenCount'] as int? ?? 0;
      final completionTokens = usageMetadata['candidatesTokenCount'] as int? ?? 0;
      final totalTokens = usageMetadata['totalTokenCount'] as int? ?? (promptTokens + completionTokens);

      return TokenUsage(
        promptTokens: promptTokens,
        completionTokens: completionTokens,
        totalTokens: totalTokens,
      );
    } catch (e) {
      return null;
    }
  }

  /// Extract token usage from Anthropic API response
  /// 
  /// Anthropic API response format:
  /// {
  ///   "usage": {
  ///     "input_tokens": 10,
  ///     "output_tokens": 20
  ///   }
  /// }
  static TokenUsage? extractFromAnthropic(Map<String, dynamic> response) {
    try {
      final usage = response['usage'] as Map<String, dynamic>?;
      if (usage == null) return null;

      final promptTokens = usage['input_tokens'] as int? ?? 0;
      final completionTokens = usage['output_tokens'] as int? ?? 0;
      final totalTokens = promptTokens + completionTokens;

      return TokenUsage(
        promptTokens: promptTokens,
        completionTokens: completionTokens,
        totalTokens: totalTokens,
      );
    } catch (e) {
      return null;
    }
  }
}

