#!/bin/bash

# assets 폴더의 WebP 로고를 public 폴더로 복사하는 스크립트
# favicon은 PNG를 유지하되, 실제 사용되는 로고는 WebP로 교체

cd "$(dirname "$0")/.."

echo "🔄 WebP 로고를 public 폴더로 복사 중..."

ASSETS_WEBP="assets/visir/visir_foreground.webp"
PUBLIC_WEBP="public/assets/visir/visir_foreground.webp"

# WebP 파일이 있는지 확인
if [ ! -f "$ASSETS_WEBP" ]; then
  echo "❌ WebP 파일을 찾을 수 없습니다: $ASSETS_WEBP"
  echo "   먼저 WebP 변환을 실행하세요: npm run convert:webp"
  exit 1
fi

# public 폴더 생성
mkdir -p "$(dirname "$PUBLIC_WEBP")"

# WebP 파일 복사
cp "$ASSETS_WEBP" "$PUBLIC_WEBP"

if [ $? -eq 0 ]; then
  echo "✅ WebP 파일을 public 폴더에 복사했습니다: $PUBLIC_WEBP"
  
  # 파일 크기 비교
  if [ -f "public/assets/visir/visir_foreground.png" ]; then
    PNG_SIZE=$(stat -f%z "public/assets/visir/visir_foreground.png" 2>/dev/null || stat -c%s "public/assets/visir/visir_foreground.png" 2>/dev/null)
    WEBP_SIZE=$(stat -f%z "$PUBLIC_WEBP" 2>/dev/null || stat -c%s "$PUBLIC_WEBP" 2>/dev/null)
    
    echo ""
    echo "📊 파일 크기 비교:"
    echo "   PNG:  $(numfmt --to=iec-i --suffix=B $PNG_SIZE 2>/dev/null || echo "${PNG_SIZE} bytes")"
    echo "   WebP: $(numfmt --to=iec-i --suffix=B $WEBP_SIZE 2>/dev/null || echo "${WEBP_SIZE} bytes")"
    
    if [ "$PNG_SIZE" -gt "$WEBP_SIZE" ]; then
      REDUCTION=$((100 - (WEBP_SIZE * 100 / PNG_SIZE)))
      echo "   💡 WebP가 ${REDUCTION}% 더 작습니다"
    fi
  fi
  
  echo ""
  echo "💡 참고:"
  echo "   - PNG 파일은 favicon용으로 유지됩니다 (브라우저 호환성)"
  echo "   - 코드는 이미 WebP를 참조하도록 업데이트되었습니다"
  echo "   - 빌드 후 성능 체크를 실행하세요: npm run perf:build"
else
  echo "❌ 파일 복사 실패"
  exit 1
fi

echo ""
echo "✨ 완료!"

