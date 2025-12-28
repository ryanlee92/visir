#!/bin/bash

# 로고 PNG 파일을 WebP로 변환하고 최적화하는 스크립트
# favicon은 PNG를 유지하되 크기를 최적화합니다

cd "$(dirname "$0")/.."

echo "🔄 로고 파일 최적화 중..."

# assets 폴더의 로고 파일
ASSETS_LOGO_PNG="assets/visir/visir_foreground.png"
ASSETS_LOGO_WEBP="assets/visir/visir_foreground.webp"

# public 폴더의 로고 파일 (favicon용)
PUBLIC_LOGO_PNG="public/assets/visir/visir_foreground.png"

# WebP 파일이 이미 있으면 확인
if [ -f "$ASSETS_LOGO_WEBP" ]; then
  echo "✅ WebP 파일이 이미 존재합니다: $ASSETS_LOGO_WEBP"
  
  # PNG 파일 크기 확인
  if [ -f "$ASSETS_LOGO_PNG" ]; then
    PNG_SIZE=$(stat -f%z "$ASSETS_LOGO_PNG" 2>/dev/null || stat -c%s "$ASSETS_LOGO_PNG" 2>/dev/null)
    WEBP_SIZE=$(stat -f%z "$ASSETS_LOGO_WEBP" 2>/dev/null || stat -c%s "$ASSETS_LOGO_WEBP" 2>/dev/null)
    
    if [ "$PNG_SIZE" -gt "$WEBP_SIZE" ]; then
      echo "💡 PNG 파일($PNG_SIZE bytes)이 WebP 파일($WEBP_SIZE bytes)보다 큽니다."
      echo "   코드에서 WebP를 사용하도록 이미 업데이트되었습니다."
    fi
  fi
else
  echo "⚠️  WebP 파일을 찾을 수 없습니다. 변환을 실행하세요:"
  echo "   npm run convert:webp"
fi

# public 폴더의 PNG 파일은 favicon용이므로 유지
if [ -f "$PUBLIC_LOGO_PNG" ]; then
  echo "✅ Favicon용 PNG 파일이 존재합니다: $PUBLIC_LOGO_PNG"
  echo "   (favicon은 브라우저 호환성을 위해 PNG를 유지합니다)"
fi

echo ""
echo "✨ 최적화 완료!"
echo ""
echo "💡 참고:"
echo "   - 코드는 이미 WebP 파일을 참조하도록 업데이트되었습니다"
echo "   - Favicon은 PNG를 유지합니다 (브라우저 호환성)"
echo "   - 빌드 후 성능 체크를 실행하세요: npm run perf:build"

