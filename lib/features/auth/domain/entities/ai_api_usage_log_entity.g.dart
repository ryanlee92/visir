// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_api_usage_log_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AiApiUsageLogEntity _$AiApiUsageLogEntityFromJson(Map<String, dynamic> json) =>
    _AiApiUsageLogEntity(
      id: json['id'] as String,
      userId: json['userId'] as String,
      apiProvider: json['apiProvider'] as String,
      model: json['model'] as String,
      functionName: json['functionName'] as String,
      promptTokens: (json['promptTokens'] as num).toInt(),
      completionTokens: (json['completionTokens'] as num).toInt(),
      totalTokens: (json['totalTokens'] as num).toInt(),
      creditsUsed: (json['creditsUsed'] as num).toDouble(),
      usedUserApiKey: json['usedUserApiKey'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$AiApiUsageLogEntityToJson(
  _AiApiUsageLogEntity instance,
) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'apiProvider': instance.apiProvider,
  'model': instance.model,
  'functionName': instance.functionName,
  'promptTokens': instance.promptTokens,
  'completionTokens': instance.completionTokens,
  'totalTokens': instance.totalTokens,
  'creditsUsed': instance.creditsUsed,
  'usedUserApiKey': instance.usedUserApiKey,
  'createdAt': instance.createdAt.toIso8601String(),
};
