# SEO 이미지 생성 빠른 시작 가이드

## 방법 1: 자동 생성 스크립트 사용 (권장)

### 1단계: 의존성 설치
```bash
cd branding
npm install canvas
```

### 2단계: 이미지 생성
```bash
npm run generate:og-image
```

### 3단계: WebP 변환 (선택사항)
```bash
# ImageMagick 또는 cwebp 필요
cwebp -q 85 public/og-image.png -o public/og-image.webp
```

### 4단계: 확인
생성된 이미지: `branding/public/og-image.png` (또는 `.webp`)

## 방법 2: Figma 사용 (디자인 제어)

### 1단계: Figma 파일 생성
- 프레임 크기: **1200x630px**

### 2단계: 디자인 요소
- **배경**: 그라데이션 (#1C1C1B → #2F2F2F)
- **로고**: 왼쪽 상단, 100x100px
- **제품명**: "Visir", Playfair Display Bold, 96px
- **태그라인**: "Your AI Executive Assistant", Plus Jakarta Sans Medium, 36px
- **서브텍스트**: "Stop juggling apps. Reclaim your focus.", Plus Jakarta Sans Light, 28px

### 3단계: 내보내기
- 형식: PNG (고품질) 또는 WebP
- 파일명: `og-image.webp`
- 위치: `branding/public/og-image.webp`

## 방법 3: Canva 사용 (가장 쉬움)

### 1단계: Canva 열기
https://www.canva.com/

### 2단계: 커스텀 크기 설정
- 크기: 1200x630px
- 템플릿 검색: "Open Graph" 또는 "Social Media"

### 3단계: 디자인
- 배경: 다크 그라데이션
- 로고 업로드: `assets/visir/visir_foreground.webp`
- 텍스트 추가: "Visir", "Your AI Executive Assistant" 등

### 4단계: 다운로드
- 형식: PNG 또는 WebP
- 위치: `branding/public/og-image.webp`

## 이미지 테스트

### Facebook Debugger
https://developers.facebook.com/tools/debug/
1. URL 입력: `https://visir.pro`
2. "Scrape Again" 클릭
3. 이미지 확인

### Twitter Card Validator
https://cards-dev.twitter.com/validator
1. URL 입력
2. 카드 미리보기 확인

### LinkedIn Post Inspector
https://www.linkedin.com/post-inspector/
1. URL 입력
2. 미리보기 확인

## 체크리스트

- [ ] 이미지 크기: 1200x630px
- [ ] 파일 크기: 1MB 이하 (권장: 200-500KB)
- [ ] 형식: WebP (또는 PNG)
- [ ] 로고 포함
- [ ] 제품명 포함
- [ ] 태그라인 포함
- [ ] 브랜드 색상 사용
- [ ] 가독성 확인
- [ ] 파일 위치: `public/og-image.webp`
- [ ] SEO 설정 확인: `lib/seo.ts`
- [ ] Facebook Debugger 테스트
- [ ] Twitter Card Validator 테스트

## 문제 해결

### canvas 패키지 설치 오류
```bash
# macOS
brew install pkg-config cairo pango libpng jpeg giflib librsvg

# Ubuntu/Debian
sudo apt-get install build-essential libcairo2-dev libpango1.0-dev libjpeg-dev libgif-dev librsvg2-dev

# 그 후
npm install canvas
```

### 이미지가 표시되지 않음
1. 파일 경로 확인: `public/og-image.webp`
2. 빌드 후 배포 확인
3. Facebook Debugger에서 "Scrape Again" 클릭

## 추가 리소스

- 상세 가이드: `docs/SEO_IMAGE_GUIDE.md`
- 생성 스크립트: `scripts/generate-og-image.js`

