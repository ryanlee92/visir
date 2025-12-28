import 'package:freezed_annotation/freezed_annotation.dart';

part 'ai_api_usage_log_entity.freezed.dart';
part 'ai_api_usage_log_entity.g.dart';

@freezed
abstract class AiApiUsageLogEntity with _$AiApiUsageLogEntity {
  const AiApiUsageLogEntity._();

  const factory AiApiUsageLogEntity({
    required String id,
    required String userId,
    required String apiProvider, // 'openai', 'google', 'anthropic'
    required String model,
    required String functionName,
    required int promptTokens,
    required int completionTokens,
    required int totalTokens,
    required double creditsUsed,
    @Default(false) bool usedUserApiKey,
    required DateTime createdAt,
  }) = _AiApiUsageLogEntity;

  factory AiApiUsageLogEntity.fromJson(Map<String, dynamic> json) => _$AiApiUsageLogEntityFromJson(json);
}
