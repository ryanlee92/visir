#!/bin/bash

# 비디오 파일 교체 스크립트
# 최적화된 파일을 원본 파일로 교체합니다

cd "$(dirname "$0")/../assets"

echo "🔄 비디오 파일 교체 중..."

# 백업 생성
if [ -f "app-demo-dark.webm" ]; then
  cp app-demo-dark.webm app-demo-dark.webm.backup
  echo "✅ app-demo-dark.webm 백업 완료"
fi

if [ -f "app-demo-light.webm" ]; then
  cp app-demo-light.webm app-demo-light.webm.backup
  echo "✅ app-demo-light.webm 백업 완료"
fi

# 최적화된 파일로 교체
if [ -f "app-demo-dark-optimized.webm" ]; then
  cp app-demo-dark-optimized.webm app-demo-dark.webm
  echo "✅ app-demo-dark.webm 교체 완료"
else
  echo "⚠️  app-demo-dark-optimized.webm 파일을 찾을 수 없습니다"
fi

if [ -f "app-demo-light-optimized.webm" ]; then
  cp app-demo-light-optimized.webm app-demo-light.webm
  echo "✅ app-demo-light.webm 교체 완료"
else
  echo "⚠️  app-demo-light-optimized.webm 파일을 찾을 수 없습니다"
fi

echo ""
echo "✨ 교체 완료!"
echo ""
echo "💡 참고:"
echo "   - 백업 파일: *.webm.backup"
echo "   - 코드는 이미 최적화된 파일을 참조하도록 업데이트되었습니다"
echo "   - 원본 파일로 되돌리려면 백업 파일을 복원하세요"

