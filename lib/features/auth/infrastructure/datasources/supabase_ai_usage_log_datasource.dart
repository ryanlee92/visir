import 'package:Visir/features/auth/domain/entities/ai_api_usage_log_entity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

/// Supabase datasource for AI API usage logs
class SupabaseAiUsageLogDatasource {
  final SupabaseClient _client;
  final String _tableName = 'ai_api_usage_logs';

  SupabaseAiUsageLogDatasource() : _client = Supabase.instance.client;

  /// AI API 사용 로그 저장
  Future<void> saveUsageLog(AiApiUsageLogEntity log) async {
    await _client.from(_tableName).insert({
      'id': log.id.isEmpty ? const Uuid().v4() : log.id,
      'user_id': log.userId,
      'api_provider': log.apiProvider,
      'model': log.model,
      'function_name': log.functionName,
      'prompt_tokens': log.promptTokens,
      'completion_tokens': log.completionTokens,
      'total_tokens': log.totalTokens,
      'credits_used': log.creditsUsed,
      'used_user_api_key': log.usedUserApiKey,
      'created_at': log.createdAt.toUtc().toIso8601String(),
    });
  }

  /// 사용자의 월간 사용량 조회 (현재 월)
  Future<int> getMonthlyUsage({required String userId, DateTime? startDate, DateTime? endDate}) async {
    final start = startDate ?? DateTime(DateTime.now().year, DateTime.now().month, 1);
    final end = endDate ?? DateTime(DateTime.now().year, DateTime.now().month + 1, 0, 23, 59, 59);

    final response =
        await _client
                .from(_tableName)
                .select('total_tokens')
                .eq('user_id', userId)
                .filter('created_at', 'gte', start.toIso8601String())
                .filter('created_at', 'lte', end.toIso8601String())
            as List;

    int totalTokens = 0;
    for (final row in response) {
      totalTokens += ((row as Map<String, dynamic>)['total_tokens'] as num).toInt();
    }

    return totalTokens;
  }

  /// 사용자의 사용 로그 조회
  Future<List<AiApiUsageLogEntity>> getUsageLogs({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
    int? offset,
  }) async {
    var queryBuilder = _client.from(_tableName).select().eq('user_id', userId);

    if (startDate != null) {
      queryBuilder = queryBuilder.gte('created_at', startDate.toIso8601String());
    }
    if (endDate != null) {
      queryBuilder = queryBuilder.lte('created_at', endDate.toIso8601String());
    }

    final orderedQuery = queryBuilder.order('created_at', ascending: false);

    var paginatedQuery = orderedQuery;
    if (offset != null && offset > 0) {
      paginatedQuery = orderedQuery.range(offset, offset + (limit ?? 1000) - 1);
    } else if (limit != null) {
      paginatedQuery = orderedQuery.limit(limit);
    }

    final response = await paginatedQuery;

    return (response as List).map((row) {
      final rowMap = row as Map<String, dynamic>;

      // DateTime 파싱
      DateTime createdAt;
      try {
        final createdAtStr = rowMap['created_at']?.toString();
        if (createdAtStr != null && createdAtStr.isNotEmpty) {
          createdAt = DateTime.parse(createdAtStr).toLocal();
        } else {
          createdAt = DateTime.now();
        }
      } catch (e) {
        createdAt = DateTime.now();
      }

      return AiApiUsageLogEntity(
        id: rowMap['id']?.toString() ?? '',
        userId: rowMap['user_id']?.toString() ?? '',
        apiProvider: rowMap['api_provider']?.toString() ?? '',
        model: rowMap['model']?.toString() ?? '',
        functionName: rowMap['function_name']?.toString() ?? '',
        promptTokens: (rowMap['prompt_tokens'] as num?)?.toInt() ?? 0,
        completionTokens: (rowMap['completion_tokens'] as num?)?.toInt() ?? 0,
        totalTokens: (rowMap['total_tokens'] as num?)?.toInt() ?? 0,
        creditsUsed: (rowMap['credits_used'] as num?)?.toDouble() ?? 0.0,
        usedUserApiKey: rowMap['used_user_api_key'] ?? false,
        createdAt: createdAt,
      );
    }).toList();
  }
}
