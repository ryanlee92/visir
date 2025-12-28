# SEO용 Open Graph 이미지 생성 가이드

## 이미지 사양

### 필수 요구사항
- **크기**: 1200x630px (Open Graph 표준)
- **비율**: 1.91:1 (가로:세로)
- **형식**: PNG 또는 WebP (WebP 권장)
- **파일 크기**: 1MB 이하 (권장: 200-500KB)

### 디자인 가이드라인

#### 1. 기본 레이아웃
```
┌─────────────────────────────────────────┐
│  [배경: 그라데이션 또는 앱 스크린샷]      │
│                                         │
│  [Visir 로고]  Visir                    │
│                                         │
│  Your AI Executive Assistant            │
│                                         │
│  Stop juggling apps.                    │
│  Reclaim your focus.                    │
│                                         │
└─────────────────────────────────────────┘
```

#### 2. 색상 팔레트
- **Primary**: #7C5DFF (보라색)
- **Background**: #1C1C1B (다크 모드) 또는 #ECECEC (라이트 모드)
- **Text**: #FFFFFF (다크 배경) 또는 #000000 (라이트 배경)
- **Accent**: 그라데이션 (indigo-400 → purple-400 → pink-400)

#### 3. 타이포그래피
- **제품명**: Playfair Display, Bold, 72px
- **태그라인**: Plus Jakarta Sans, Medium, 32px
- **서브텍스트**: Plus Jakarta Sans, Light, 24px

## 생성 방법

### 방법 1: Figma 사용 (권장)

1. **새 Figma 파일 생성**
   - 프레임 크기: 1200x630px

2. **배경 레이어**
   - 그라데이션 배경 또는 앱 스크린샷 사용
   - 다크 모드: `#1C1C1B` → `#2F2F2F` 그라데이션
   - 라이트 모드: `#ECECEC` → `#FFFFFF` 그라데이션

3. **로고 배치**
   - 왼쪽 상단 또는 중앙 상단
   - 크기: 80x80px
   - 파일: `visir_foreground.webp`

4. **텍스트 추가**
   ```
   Visir
   Your AI Executive Assistant
   
   Stop juggling apps.
   Reclaim your focus.
   ```

5. **내보내기**
   - 형식: PNG (고품질) 또는 WebP
   - 파일명: `og-image.webp` 또는 `og-image.png`
   - 위치: `branding/public/og-image.webp`

### 방법 2: 온라인 도구 사용

**추천 도구:**
- [Canva](https://www.canva.com/) - 무료, 템플릿 제공
- [Bannerbear](https://www.bannerbear.com/) - API로 자동 생성 가능
- [Cloudinary](https://cloudinary.com/) - 이미지 변환 및 최적화

**템플릿 설정:**
- 크기: 1200x630px
- 배경: 그라데이션 또는 단색
- 로고: 중앙 또는 왼쪽 상단
- 텍스트: 중앙 정렬

### 방법 3: 코드로 생성 (고급)

#### HTML/CSS 기반 생성
```html
<!DOCTYPE html>
<html>
<head>
  <style>
    body {
      width: 1200px;
      height: 630px;
      margin: 0;
      background: linear-gradient(135deg, #1C1C1B 0%, #2F2F2F 100%);
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      font-family: 'Playfair Display', serif;
      color: white;
    }
    .logo {
      width: 80px;
      height: 80px;
      margin-bottom: 20px;
    }
    h1 {
      font-size: 72px;
      margin: 0;
      font-weight: bold;
    }
    .tagline {
      font-size: 32px;
      margin-top: 10px;
      font-family: 'Plus Jakarta Sans', sans-serif;
      font-weight: 500;
    }
    .subtitle {
      font-size: 24px;
      margin-top: 20px;
      font-family: 'Plus Jakarta Sans', sans-serif;
      font-weight: 300;
      text-align: center;
    }
  </style>
</head>
<body>
  <img src="visir_foreground.webp" alt="Visir" class="logo" />
  <h1>Visir</h1>
  <div class="tagline">Your AI Executive Assistant</div>
  <div class="subtitle">Stop juggling apps.<br/>Reclaim your focus.</div>
</body>
</html>
```

#### Node.js + Canvas로 생성
```javascript
const { createCanvas, loadImage } = require('canvas');
const fs = require('fs');

async function generateOGImage() {
  const width = 1200;
  const height = 630;
  const canvas = createCanvas(width, height);
  const ctx = canvas.getContext('2d');

  // 배경 그라데이션
  const gradient = ctx.createLinearGradient(0, 0, width, height);
  gradient.addColorStop(0, '#1C1C1B');
  gradient.addColorStop(1, '#2F2F2F');
  ctx.fillStyle = gradient;
  ctx.fillRect(0, 0, width, height);

  // 로고 로드 및 그리기
  const logo = await loadImage('./assets/visir/visir_foreground.webp');
  ctx.drawImage(logo, 100, 100, 80, 80);

  // 텍스트
  ctx.fillStyle = '#FFFFFF';
  ctx.font = 'bold 72px "Playfair Display"';
  ctx.fillText('Visir', 200, 150);
  
  ctx.font = '500 32px "Plus Jakarta Sans"';
  ctx.fillText('Your AI Executive Assistant', 200, 200);
  
  ctx.font = '300 24px "Plus Jakarta Sans"';
  ctx.fillText('Stop juggling apps. Reclaim your focus.', 200, 250);

  // 저장
  const buffer = canvas.toBuffer('image/png');
  fs.writeFileSync('./public/og-image.png', buffer);
}
```

## 이미지 최적화

### WebP 변환
```bash
# ImageMagick 사용
convert og-image.png -quality 85 -resize 1200x630 og-image.webp

# 또는 cwebp 사용
cwebp -q 85 og-image.png -o og-image.webp
```

### 파일 크기 최적화
- PNG: TinyPNG 또는 ImageOptim 사용
- WebP: `cwebp -q 85` (품질 85% 권장)

## 파일 위치

생성된 이미지를 다음 위치에 저장:
```
branding/public/og-image.webp
```

또는

```
branding/assets/og-image.webp
```

## SEO 설정 업데이트

이미지 생성 후 `lib/seo.ts`의 `defaultSEO.ogImage`를 업데이트:

```typescript
ogImage: `${baseUrl}/og-image.webp`,
```

## 테스트 방법

### 1. Facebook Debugger
https://developers.facebook.com/tools/debug/
- URL 입력 후 "Scrape Again" 클릭
- 이미지가 올바르게 표시되는지 확인

### 2. Twitter Card Validator
https://cards-dev.twitter.com/validator
- URL 입력 후 카드 미리보기 확인

### 3. LinkedIn Post Inspector
https://www.linkedin.com/post-inspector/
- URL 입력 후 미리보기 확인

## 디자인 예시

### 다크 모드 버전
- 배경: 다크 그라데이션 (#1C1C1B → #2F2F2F)
- 텍스트: 흰색 (#FFFFFF)
- 로고: 원본 색상 유지

### 라이트 모드 버전 (선택사항)
- 배경: 라이트 그라데이션 (#ECECEC → #FFFFFF)
- 텍스트: 검은색 (#000000)
- 로고: 원본 색상 유지

## 권장 디자인 요소

1. **로고 위치**: 왼쪽 상단 또는 중앙 상단
2. **제품명**: 큰 글씨로 강조
3. **태그라인**: 제품명 아래 중간 크기
4. **서브텍스트**: 하단 또는 중앙
5. **배경**: 그라데이션 또는 앱 스크린샷
6. **여백**: 충분한 여백으로 가독성 확보

## 체크리스트

- [ ] 이미지 크기: 1200x630px
- [ ] 파일 크기: 1MB 이하
- [ ] 형식: WebP (또는 PNG)
- [ ] 로고 포함
- [ ] 제품명 포함
- [ ] 태그라인 포함
- [ ] 브랜드 색상 사용
- [ ] 가독성 확인
- [ ] Facebook Debugger 테스트
- [ ] Twitter Card Validator 테스트
- [ ] SEO 설정 업데이트

