import 'package:Visir/features/auth/domain/entities/ai_api_usage_log_entity.dart';
import 'package:Visir/features/auth/domain/entities/user_entity.dart';
import 'package:Visir/features/auth/domain/repositories/auth_repository_interface.dart';
import 'package:Visir/features/auth/infrastructure/datasources/supabase_ai_usage_log_datasource.dart';
import 'package:Visir/features/common/domain/failures/failure.dart';
import 'package:Visir/features/common/utils/ai_pricing_calculator.dart';
import 'package:Visir/features/inbox/domain/entities/agent_model_entity.dart';
import 'package:Visir/features/inbox/infrastructure/utils/token_usage_extractor.dart';
import 'package:uuid/uuid.dart';

/// AI 크레딧 체크 및 차감 서비스
class AiCreditsService {
  final AuthRepositoryInterface _authRepository;
  final SupabaseAiUsageLogDatasource _usageLogDatasource;

  AiCreditsService({
    required AuthRepositoryInterface authRepository,
    required SupabaseAiUsageLogDatasource usageLogDatasource,
  })  : _authRepository = authRepository,
        _usageLogDatasource = usageLogDatasource;

  /// AI 호출 전 크레딧 사전 체크
  /// 
  /// [userId] 사용자 ID
  /// [model] 사용될 모델
  /// [estimatedPromptTokens] 예상 입력 토큰 수
  /// [estimatedCompletionTokens] 예상 출력 토큰 수 (기본값: 500)
  /// [usedUserApiKey] 사용자 API 키 사용 여부
  /// 
  /// Throws Failure.insufficientCredits if credits are insufficient
  Future<void> checkCreditsBeforeCall({
    required String userId,
    required AgentModel model,
    required int estimatedPromptTokens,
    int estimatedCompletionTokens = 500,
    required bool usedUserApiKey,
  }) async {
    // 사용자 API 키 사용 시 크레딧 체크 스킵
    if (usedUserApiKey) {
      return;
    }

    // UserEntity 가져오기
    final userResult = await _authRepository.getUser(userId: userId);
    final user = userResult.fold(
      (failure) => throw Exception('Failed to get user: $failure'),
      (user) => user,
    );

    // Ultra Plan 사용자의 경우 기본 제공량 확인
    final isUltraPlan = _isUltraPlan(user);
    if (isUltraPlan) {
      final monthlyUsage = await _usageLogDatasource.getMonthlyUsage(userId: userId);
      if (monthlyUsage < AiPricingCalculator.ultraPlanMonthlyTokens) {
        // 기본 제공량 내에서 사용 중이면 크레딧 체크 스킵
        return;
      }
    }

    // 예상 크레딧 비용 계산
    final estimatedCreditsCost = AiPricingCalculator.calculateCreditsCostFromModel(
      promptTokens: estimatedPromptTokens,
      completionTokens: estimatedCompletionTokens,
      model: model,
    );

    // 현재 크레딧 조회
    final currentCreditsResult = await _authRepository.getAiCredits(userId: userId);
    final currentCredits = currentCreditsResult.fold(
      (failure) => 0.0,
      (credits) => credits,
    );

    // 크레딧 부족 체크
    if (currentCredits < estimatedCreditsCost) {
      throw Failure.insufficientCredits(
        StackTrace.current,
        required: estimatedCreditsCost,
        available: currentCredits,
      );
    }
  }

  /// 크레딧 체크 및 차감
  /// 
  /// [userId] 사용자 ID
  /// [model] 사용된 모델
  /// [functionName] 호출된 함수명
  /// [tokenUsage] 토큰 사용량
  /// [usedUserApiKey] 사용자 API 키 사용 여부
  /// 
  /// Returns 차감된 크레딧 양 (사용자 API 키 사용 시 0)
  Future<double> checkAndDeductCredits({
    required String userId,
    required AgentModel model,
    required String functionName,
    required TokenUsage tokenUsage,
    required bool usedUserApiKey,
  }) async {
    // UserEntity 가져오기
    final userResult = await _authRepository.getUser(userId: userId);
    final user = userResult.fold(
      (failure) => throw Exception('Failed to get user: $failure'),
      (user) => user,
    );
    // 사용자 API 키 사용 시 크레딧 차감 스킵
    if (usedUserApiKey) {
      return 0.0;
    }

    // Ultra Plan 사용자의 경우 기본 제공량 확인
    final isUltraPlan = _isUltraPlan(user);
    if (isUltraPlan) {
      final monthlyUsage = await _usageLogDatasource.getMonthlyUsage(userId: userId);
      if (monthlyUsage < AiPricingCalculator.ultraPlanMonthlyTokens) {
        // 기본 제공량 내에서 사용 중이면 크레딧 차감 없음
        // 하지만 사용 로그는 기록해야 함
        final creditsUsed = AiPricingCalculator.calculateCreditsCostFromModel(
          promptTokens: tokenUsage.promptTokens,
          completionTokens: tokenUsage.completionTokens,
          model: model,
        );
        
        await _saveUsageLog(
          userId: userId,
          model: model,
          functionName: functionName,
          tokenUsage: tokenUsage,
          creditsUsed: creditsUsed,
          usedUserApiKey: false,
        );
        
        return 0.0;
      }
    }

    // 크레딧 비용 계산
    final creditsCost = AiPricingCalculator.calculateCreditsCostFromModel(
      promptTokens: tokenUsage.promptTokens,
      completionTokens: tokenUsage.completionTokens,
      model: model,
    );

    // 현재 크레딧 조회
    final currentCreditsResult = await _authRepository.getAiCredits(userId: userId);
    final currentCredits = currentCreditsResult.fold(
      (failure) => 0.0,
      (credits) => credits,
    );

    // 크레딧 부족 체크
    if (currentCredits < creditsCost) {
      throw Failure.insufficientCredits(
        StackTrace.current,
        required: creditsCost,
        available: currentCredits,
      );
    }

    // 크레딧 차감
    final updateResult = await _authRepository.updateAiCredits(
      userId: userId,
      amount: -creditsCost,
    );

    updateResult.fold(
      (failure) => throw Exception('Failed to update credits: $failure'),
      (credits) => credits,
    );

    // 사용 로그 저장
    await _saveUsageLog(
      userId: userId,
      model: model,
      functionName: functionName,
      tokenUsage: tokenUsage,
      creditsUsed: creditsCost,
      usedUserApiKey: false,
    );

    return creditsCost;
  }

  /// Ultra Plan 여부 확인
  bool _isUltraPlan(UserEntity user) {
    // Ultra Plan variant ID 확인
    // Ultra Plan variant ID는 아직 정의되지 않았으므로, 일단 productName이나 variantName으로 확인
    final subscription = user.subscription;
    if (subscription == null || subscription.isExpired) {
      return false;
    }

    // TODO: Ultra Plan variant ID가 정의되면 variantId로 확인
    // 예: final ultraPlanVariantIds = ['ultra_monthly_variant_id', 'ultra_yearly_variant_id'];
    // return ultraPlanVariantIds.contains(subscription.variantId);
    
    // 임시로 productName이나 variantName으로 확인 (Ultra Plan이 추가되면 수정 필요)
    final productName = subscription.subscriptionProductName.toLowerCase();
    final variantName = subscription.attributes?.variantName?.toLowerCase() ?? '';
    
    // Ultra Plan은 "ultra" 키워드가 포함되어 있을 것으로 예상
    return productName.contains('ultra') || variantName.contains('ultra');
  }

  /// 사용 로그 저장
  Future<void> _saveUsageLog({
    required String userId,
    required AgentModel model,
    required String functionName,
    required TokenUsage tokenUsage,
    required double creditsUsed,
    required bool usedUserApiKey,
  }) async {
    final log = AiApiUsageLogEntity(
      id: const Uuid().v4(),
      userId: userId,
      apiProvider: model.provider.name,
      model: model.modelName,
      functionName: functionName,
      promptTokens: tokenUsage.promptTokens,
      completionTokens: tokenUsage.completionTokens,
      totalTokens: tokenUsage.totalTokens,
      creditsUsed: creditsUsed,
      usedUserApiKey: usedUserApiKey,
      createdAt: DateTime.now(),
    );

    await _usageLogDatasource.saveUsageLog(log);
  }
}

