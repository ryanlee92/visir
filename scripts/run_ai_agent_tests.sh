#!/bin/bash

# AI Agent 기능 테스트 실행 스크립트

set -e

echo "🧪 AI Agent 기능 테스트 시작..."
echo ""

# 테스트 디렉토리로 이동
cd "$(dirname "$0")/.."

# Flutter 의존성 확인
echo "📦 Flutter 의존성 확인 중..."
flutter pub get

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 각 테스트 파일 실행
echo "1️⃣  MCP 함수 파싱 테스트 실행 중..."
flutter test test/features/inbox/application/mcp_function_executor_test.dart
echo "✅ MCP 함수 파싱 테스트 완료"
echo ""

echo "2️⃣  Entity 태그 파싱 테스트 실행 중..."
flutter test test/features/inbox/presentation/widgets/entity_tag_parsing_test.dart
echo "✅ Entity 태그 파싱 테스트 완료"
echo ""

echo "3️⃣  Markdown Entity 렌더링 테스트 실행 중..."
flutter test test/features/inbox/presentation/widgets/markdown_entity_rendering_test.dart
echo "✅ Markdown Entity 렌더링 테스트 완료"
echo ""

echo "4️⃣  병렬 실행 테스트 실행 중..."
flutter test test/features/inbox/application/parallel_execution_test.dart
echo "✅ 병렬 실행 테스트 완료"
echo ""

echo "5️⃣  일괄 확인 테스트 실행 중..."
flutter test test/features/inbox/application/batch_confirmation_test.dart
echo "✅ 일괄 확인 테스트 완료"
echo ""

echo "6️⃣  통합 테스트 실행 중..."
flutter test test/features/inbox/integration/ai_agent_integration_test.dart
echo "✅ 통합 테스트 완료"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "🎉 모든 테스트 완료!"

# 전체 테스트 실행 (옵션)
if [ "$1" == "--all" ]; then
    echo ""
    echo "전체 테스트 스위트 실행 중..."
    flutter test test/features/inbox/
fi

