# 레몬 스퀴지 Additional Token 구매 설정 가이드

## 1. 레몬 스퀴지에서 제품 생성

### 1.1 제품 생성
1. 레몬 스퀴지 대시보드에 로그인
2. **Products** 메뉴로 이동
3. **New Product** 클릭
4. 다음 정보 입력:
   - **Product Name**: `Additional AI Tokens` (또는 원하는 이름)
   - **Product Type**: `One-time Payment` (일회성 결제)
   - **Description**: `Purchase additional AI tokens for AI-based orders and summaries`

### 1.2 Variant 생성 (각 패키지별로)

각 금액($5, $10, $20, $50)에 대해 별도의 Variant를 생성해야 합니다:

#### $5 패키지 Variant
- **Name**: `$5 Token Package`
- **Price**: `$5.00`
- **Description**: `Additional AI tokens package`

#### $10 패키지 Variant
- **Name**: `$10 Token Package`
- **Price**: `$10.00`
- **Description**: `Additional AI tokens package`

#### $20 패키지 Variant
- **Name**: `$20 Token Package`
- **Price**: `$20.00`
- **Description**: `Additional AI tokens package`

#### $50 패키지 Variant
- **Name**: `$50 Token Package` (Best Value)
- **Price**: `$50.00`
- **Description**: `Additional AI tokens package with 25% bonus`

### 1.3 Test Mode Variant 생성
Test Mode에서도 동일한 제품과 Variant를 생성해야 합니다:
1. 레몬 스퀴지 대시보드에서 **Test Mode** 토글 활성화
2. 위와 동일한 제품과 Variant 생성
3. 각 Variant의 ID를 기록해두세요 (코드에서 사용)

## 2. Variant ID 매핑

코드에서 사용할 Variant ID를 매핑해야 합니다. 다음 파일을 수정하세요:

### `lib/features/auth/presentation/screens/ai_credits_screen.dart`

각 패키지 금액에 해당하는 Variant ID를 매핑하는 로직 추가:

```dart
// Test Mode Variant IDs
final testModeVariantIds = {
  5.0: 'TEST_VARIANT_ID_5',
  10.0: 'TEST_VARIANT_ID_10',
  20.0: 'TEST_VARIANT_ID_20',
  50.0: 'TEST_VARIANT_ID_50',
};

// Production Mode Variant IDs
final productionVariantIds = {
  5.0: 'PROD_VARIANT_ID_5',
  10.0: 'PROD_VARIANT_ID_10',
  20.0: 'PROD_VARIANT_ID_20',
  50.0: 'PROD_VARIANT_ID_50',
};
```

## 3. Webhook 설정

### 3.1 Webhook URL 설정
1. 레몬 스퀴지 대시보드에서 **Settings** > **Webhooks** 이동
2. **New Webhook** 클릭
3. **URL**: `https://YOUR_PROJECT.supabase.co/functions/v1/lemon_squeezy_webhook_handler`
4. **Events**: 다음 이벤트 선택:
   - `order_created` (일회성 결제용)
   - `subscription_created` (기존 구독용)
   - `subscription_updated` (기존 구독용)

### 3.2 Webhook Signing Key
1. Webhook 생성 후 **Signing Key** 복사
2. Supabase 환경 변수에 추가:
   - `LEMON_SQUEEZY_WEBHOOK_SIGNING_KEY`

## 4. 코드 구현 필요 사항

### 4.1 Webhook 핸들러 수정
`supabase/functions/lemon_squeezy_webhook_handler/index.ts`에 `order_created` 이벤트 처리 추가 필요

### 4.2 구매 플로우 구현
`lib/features/auth/presentation/screens/ai_credits_screen.dart`의 `_purchaseCredits` 메서드 구현 필요

### 4.3 Repository 메서드
`lib/features/auth/infrastructure/repositories/auth_repository.dart`에 토큰 구매용 checkout URL 생성 메서드 확인/추가

## 5. 크레딧 계산 로직

현재 코드에서 사용하는 크레딧 계산:
- $5: 프리미엄 50% 적용
- $10: 프리미엄 40% 적용
- $20: 프리미엄 30% 적용
- $50: 프리미엄 20% 적용 + 25% 보너스

실제 토큰 수는 `AiPricingCalculator.calculateTokensFromPackage()` 메서드로 계산됩니다.

## 6. 테스트 체크리스트

- [ ] Test Mode에서 각 패키지 구매 테스트
- [ ] Production Mode에서 각 패키지 구매 테스트
- [ ] Webhook을 통한 크레딧 추가 확인
- [ ] 중복 구매 방지 확인
- [ ] 크레딧 잔액 업데이트 확인

## 7. 주의사항

1. **Variant ID는 Test Mode와 Production Mode가 다릅니다**
2. **Webhook Signing Key는 보안상 중요하므로 환경 변수로 관리**
3. **일회성 결제는 `order_created` 이벤트로 처리**
4. **구독 결제는 `subscription_created`/`subscription_updated` 이벤트로 처리**
5. **중복 크레딧 추가 방지 로직 필요**

