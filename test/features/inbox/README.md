# AI Agent 기능 테스트

이 디렉토리에는 AI Agent 관련 기능들의 자동화된 테스트가 포함되어 있습니다.

## 테스트 구조

```
test/features/inbox/
├── application/
│   ├── mcp_function_executor_test.dart      # MCP 함수 파싱 테스트
│   ├── parallel_execution_test.dart          # 병렬 실행 및 의존성 분석 테스트
│   └── batch_confirmation_test.dart          # 일괄 확인 기능 테스트
├── presentation/
│   └── widgets/
│       ├── entity_tag_parsing_test.dart      # Entity 태그 파싱 테스트
│       └── markdown_entity_rendering_test.dart # Markdown 내 entity 렌더링 테스트
└── integration/
    └── ai_agent_integration_test.dart        # 통합 테스트
```

## 테스트 실행 방법

### 모든 테스트 실행
```bash
flutter test test/features/inbox/
```

### 특정 테스트 파일 실행
```bash
flutter test test/features/inbox/application/mcp_function_executor_test.dart
```

### 특정 테스트 그룹 실행
```bash
flutter test --name "McpFunctionExecutor"
```

### 커버리지 포함 실행
```bash
flutter test --coverage test/features/inbox/
```

## 테스트 항목

### 1. MCP 함수 파싱 테스트 (`mcp_function_executor_test.dart`)
- 단일 함수 호출 파싱
- 여러 함수 호출 파싱
- `function_call` 태그 형식 파싱
- `can_parallelize` 기본값 테스트
- 잘못된 형식 처리

### 2. Entity 태그 파싱 테스트 (`entity_tag_parsing_test.dart`)
- `inapp_task` 태그 파싱
- `inapp_event` 태그 파싱
- `inapp_mail_entity` 태그 파싱
- `inapp_message` 태그 파싱
- 여러 entity 태그 동시 파싱
- Markdown/HTML 내 태그 파싱

### 3. Markdown Entity 렌더링 테스트 (`markdown_entity_rendering_test.dart`)
- Markdown 내 단일 entity 태그 추출
- 여러 entity 태그 추출
- Placeholder 교체 로직
- Markdown과 entity 태그 혼합 처리

### 4. 병렬 실행 테스트 (`parallel_execution_test.dart`)
- 독립적인 함수들의 병렬 실행 가능 여부
- 의존성이 있는 함수들의 순차 실행
- 함수 그룹화 로직
- 의존성 체인 확인
- 복잡한 의존성 그래프 처리

### 5. 일괄 확인 테스트 (`batch_confirmation_test.dart`)
- 여러 액션 선택 및 확인
- 전체 선택/해제
- 개별 액션 선택 토글
- 선택된 액션 수 확인

### 6. 통합 테스트 (`ai_agent_integration_test.dart`)
- 전체 플로우: 함수 호출 파싱 → 실행 → 결과 표시
- Entity 태그가 포함된 AI 응답 처리
- Markdown 응답 내 Entity 태그 처리
- 함수 호출과 Entity 표시 혼합
- 일괄 확인 플로우

## 테스트 작성 가이드

새로운 테스트를 추가할 때는 다음 가이드를 따르세요:

1. **테스트 파일 위치**: 기능에 맞는 디렉토리에 배치
   - Application 로직: `application/`
   - Presentation 로직: `presentation/widgets/`
   - 통합 테스트: `integration/`

2. **테스트 그룹화**: 관련된 테스트는 `group()` 블록으로 묶기
   ```dart
   group('Feature Name', () {
     test('specific test case', () {
       // 테스트 코드
     });
   });
   ```

3. **명확한 테스트 이름**: 테스트가 무엇을 검증하는지 명확하게 작성

4. **독립성**: 각 테스트는 독립적으로 실행 가능해야 함

5. **Mock 사용**: 외부 의존성은 mock 객체 사용

## CI/CD 통합

이 테스트들은 CI/CD 파이프라인에서 자동으로 실행됩니다:

```yaml
# 예시 GitHub Actions
- name: Run AI Agent Tests
  run: flutter test test/features/inbox/
```

## 문제 해결

### 테스트 실행 실패 시
1. `flutter pub get` 실행하여 의존성 확인
2. `flutter clean` 후 다시 실행
3. 특정 테스트만 실행하여 문제 격리

### Mock 객체 필요 시
`test/mock_state_notifier.dart`를 참고하여 mock 객체 생성



