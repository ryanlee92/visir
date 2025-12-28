import 'package:Visir/features/inbox/domain/entities/agent_model_entity.dart';

/// AI Pricing Calculator
/// 
/// 토큰 기반 비용 계산 및 크레딧 변환 유틸리티
class AiPricingCalculator {
  // Ultra Plan 기준: $10 = 500K 토큰 = 토큰당 $0.00002
  static const double baseTokenPrice = 0.00002; // 토큰당 기본 가격 ($)
  
  // 크레딧 패키지별 프리미엄 (패키지별 차등 적용)
  static const double premium5 = 1.5; // 50% 프리미엄
  static const double premium10 = 1.4; // 40% 프리미엄
  static const double premium20 = 1.3; // 30% 프리미엄
  static const double premium50 = 1.2; // 20% 프리미엄 + 25% 보너스

  /// Provider와 모델별 실제 API 토큰 가격 (per 1M tokens)
  /// 
  /// OpenAI 가격 (2024 기준)
  static const Map<String, double> openaiInputPrices = {
    'gpt-4.1-mini': 0.40,
    'gpt-4o-mini': 0.15,
    'gpt-5': 0.15, // 예상 가격
    'gpt-5.1': 0.15,
    'gpt-5-mini': 0.10,
  };

  static const Map<String, double> openaiOutputPrices = {
    'gpt-4.1-mini': 1.60,
    'gpt-4o-mini': 0.60,
    'gpt-5': 0.60,
    'gpt-5.1': 0.60,
    'gpt-5-mini': 0.40,
  };

  /// Google AI 가격 (2024 기준)
  static const Map<String, double> googleInputPrices = {
    'gemini-3-pro-preview': 0.15,
    'gemini-2.5-flash': 0.15,
    'gemini-2.5-flash-lite': 0.075,
    'gemini-2.5-pro': 0.15,
  };

  static const Map<String, double> googleOutputPrices = {
    'gemini-3-pro-preview': 0.60,
    'gemini-2.5-flash': 0.60,
    'gemini-2.5-flash-lite': 0.30,
    'gemini-2.5-pro': 0.60,
  };

  /// Anthropic 가격 (2024 기준)
  static const Map<String, double> anthropicInputPrices = {
    'claude-sonnet-4-5': 0.30,
    'claude-haiku-4-5': 0.10,
    'claude-opus-4-5': 1.50,
  };

  static const Map<String, double> anthropicOutputPrices = {
    'claude-sonnet-4-5': 1.50,
    'claude-haiku-4-5': 0.40,
    'claude-opus-4-5': 7.50,
  };

  /// Provider와 모델에 따른 입력 토큰 가격 조회
  static double getInputTokenPrice(String provider, String model) {
    switch (provider.toLowerCase()) {
      case 'openai':
        return openaiInputPrices[model] ?? openaiInputPrices['gpt-4o-mini']!;
      case 'google':
        return googleInputPrices[model] ?? googleInputPrices['gemini-2.5-flash']!;
      case 'anthropic':
        return anthropicInputPrices[model] ?? anthropicInputPrices['claude-haiku-4-5']!;
      default:
        return 0.15; // 기본값
    }
  }

  /// Provider와 모델에 따른 출력 토큰 가격 조회
  static double getOutputTokenPrice(String provider, String model) {
    switch (provider.toLowerCase()) {
      case 'openai':
        return openaiOutputPrices[model] ?? openaiOutputPrices['gpt-4o-mini']!;
      case 'google':
        return googleOutputPrices[model] ?? googleOutputPrices['gemini-2.5-flash']!;
      case 'anthropic':
        return anthropicOutputPrices[model] ?? anthropicOutputPrices['claude-haiku-4-5']!;
      default:
        return 0.60; // 기본값
    }
  }

  /// 실제 API 비용 계산 (달러 단위)
  /// 
  /// [promptTokens] 입력 토큰 수
  /// [completionTokens] 출력 토큰 수
  /// [provider] API 제공자 ('openai', 'google', 'anthropic')
  /// [model] 모델 이름
  /// 
  /// Returns 실제 API 비용 ($)
  static double calculateActualApiCost({
    required int promptTokens,
    required int completionTokens,
    required String provider,
    required String model,
  }) {
    final inputPrice = getInputTokenPrice(provider, model);
    final outputPrice = getOutputTokenPrice(provider, model);

    final inputCost = (promptTokens / 1000000) * inputPrice;
    final outputCost = (completionTokens / 1000000) * outputPrice;

    return inputCost + outputCost;
  }

  /// 크레딧 비용 계산 (Visir 크레딧 단위)
  /// 
  /// Ultra Plan 기준: $10 = 500K 토큰 = 토큰당 $0.00002
  /// 일회성 결제는 프리미엄 적용
  /// 
  /// [promptTokens] 입력 토큰 수
  /// [completionTokens] 출력 토큰 수
  /// [isOneTimePayment] 일회성 결제 여부 (프리미엄 적용)
  /// [packageAmount] 패키지 금액 ($5, $10, $20, $50) - 프리미엄 결정용
  /// 
  /// Returns 크레딧 비용 ($)
  static double calculateCreditsCost({
    required int promptTokens,
    required int completionTokens,
    bool isOneTimePayment = false,
    double? packageAmount,
  }) {
    final totalTokens = promptTokens + completionTokens;
    
    // 기본 가격 (Ultra Plan 기준)
    double tokenPrice = baseTokenPrice;
    
    // 일회성 결제 프리미엄 적용
    if (isOneTimePayment && packageAmount != null) {
      double premium;
      if (packageAmount <= 5) {
        premium = premium5; // 50%
      } else if (packageAmount <= 10) {
        premium = premium10; // 40%
      } else if (packageAmount <= 20) {
        premium = premium20; // 30%
      } else {
        premium = premium50; // 20%
      }
      tokenPrice = baseTokenPrice * premium;
    }
    
    return totalTokens * tokenPrice;
  }

  /// AgentModel을 사용한 크레딧 비용 계산
  static double calculateCreditsCostFromModel({
    required int promptTokens,
    required int completionTokens,
    required AgentModel model,
    bool isOneTimePayment = false,
    double? packageAmount,
  }) {
    return calculateCreditsCost(
      promptTokens: promptTokens,
      completionTokens: completionTokens,
      isOneTimePayment: isOneTimePayment,
      packageAmount: packageAmount,
    );
  }

  /// 크레딧 패키지별 토큰 수 계산
  /// 
  /// [amount] 패키지 금액 ($5, $10, $20, $50)
  /// [includeBonus] $50 패키지의 경우 25% 보너스 포함 여부
  /// 
  /// Returns 토큰 수
  /// 크레딧(달러)에서 토큰 수 계산
  /// 
  /// [credits] 크레딧 금액 ($)
  /// 
  /// Returns 토큰 수
  static int calculateTokensFromCredits(double credits) {
    if (credits <= 0) return 0;
    return (credits / baseTokenPrice).round();
  }

  static int calculateTokensFromPackage({
    required double amount,
    bool includeBonus = false,
  }) {
    double tokenPrice = baseTokenPrice;
    
    // 프리미엄 적용
    if (amount <= 5) {
      tokenPrice = baseTokenPrice * premium5;
    } else if (amount <= 10) {
      tokenPrice = baseTokenPrice * premium10;
    } else if (amount <= 20) {
      tokenPrice = baseTokenPrice * premium20;
    } else {
      tokenPrice = baseTokenPrice * premium50;
    }
    
    int tokens = (amount / tokenPrice).round();
    
    // $50 패키지의 경우 25% 보너스
    if (includeBonus && amount >= 50) {
      tokens = (tokens * 1.25).round();
    }
    
    return tokens;
  }

  /// Ultra Plan 기본 제공량 (월간 500K 토큰)
  static const int ultraPlanMonthlyTokens = 500000;
}

