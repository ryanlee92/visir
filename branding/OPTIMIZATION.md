# 성능 최적화 가이드

## 현재 최적화 적용 사항

### 1. 코드 스플리팅
- React, React DOM, React Router를 별도 청크로 분리
- 아이콘 라이브러리를 별도 청크로 분리
- **라우트 기반 코드 스플리팅 적용** (React.lazy 사용)
- 페이지별로 코드 분리하여 초기 번들 크기 감소
- 초기 로딩 시간 단축

### 2. 이미지 최적화
- **모든 이미지에 `loading="lazy"`, `decoding="async"` 추가**
- FeatureSection의 모든 이미지 지연 로딩 적용
- 이미지 지연 로딩으로 초기 로딩 시간 단축

### 3. 비디오 최적화
- **비디오 preload를 "metadata"로 변경** (기존 "auto"에서)
- **Intersection Observer를 사용한 비디오 지연 로딩**
- 비디오가 뷰포트에 가까워질 때만 로드

### 4. 컴포넌트 최적화
- **React.memo 적용**: FeatureSection, MeshBackground, Navbar
- **useCallback으로 이벤트 핸들러 최적화**
- 불필요한 리렌더링 방지

### 5. 외부 스크립트 최적화
- **Intersection Observer를 사용한 외부 스크립트 지연 로딩**
- 스크립트에 `async`, `defer` 속성 추가
- 컴포넌트가 뷰포트에 가까워질 때만 로드

### 6. 빌드 최적화
- **Vite 빌드 설정 최적화**
- CSS 압축 활성화
- 소스맵 비활성화 (프로덕션)
- 작은 에셋 인라인화 (4kb 미만)

### 7. 불필요한 의존성 제거
- 사용하지 않는 `lucide-react` 제거

### 8. 폰트 최적화
- 폰트 로딩을 비동기로 처리하여 렌더링 차단 방지
- 폰트 서브셋팅 추가 (`subset=latin`)

### 9. 리소스 힌트 최적화
- **DNS Prefetch 추가**: fonts.googleapis.com, fonts.gstatic.com, cdn.jsdelivr.net, esm.sh
- **Preconnect 추가**: 폰트 리소스에 대한 사전 연결
- 외부 리소스 로딩 시간 단축

### 10. 이미지 우선순위 최적화
- **Navbar 로고**: `fetchPriority="high"`, `loading="eager"` (즉시 로드)
- **Footer 로고**: `loading="lazy"` (지연 로드)
- 중요한 이미지는 즉시 로드, 덜 중요한 이미지는 지연 로드

### 11. 추가 컴포넌트 메모이제이션
- **CTA 컴포넌트**: React.memo 적용
- **Footer 컴포넌트**: React.memo 및 useCallback 적용
- 불필요한 리렌더링 추가 방지

## 추가 최적화 권장 사항

### 1. GIF 파일 최적화 (가장 중요!)
현재 GIF 파일이 28-31MB로 매우 큽니다. 다음 방법을 권장합니다:

**옵션 A: 비디오로 변환 (가장 효과적)**
```bash
# MP4로 변환 (H.264 코덱 사용)
ffmpeg -i app-demo-dark.gif -vf "scale=1920:-1" -c:v libx264 -preset slow -crf 22 -pix_fmt yuv420p app-demo-dark.mp4

# WebM으로 변환 (더 작은 파일 크기)
ffmpeg -i app-demo-dark.gif -vf "scale=1920:-1" -c:v libvpx-vp9 -crf 30 -b:v 0 app-demo-dark.webm
```

HTML에서:
```html
<video autoplay loop muted playsinline>
  <source src="app-demo-dark.webm" type="video/webm">
  <source src="app-demo-dark.mp4" type="video/mp4">
</video>
```

**옵션 B: GIF 최적화**
```bash
# gifsicle 사용
gifsicle -O3 --lossy=80 -o app-demo-dark-optimized.gif app-demo-dark.gif
```

**옵션 C: WebP 애니메이션**
```bash
# WebP로 변환 (더 작은 크기)
gif2webp -q 80 app-demo-dark.gif -o app-demo-dark.webp
```

### 2. 이미지 최적화 ✅ 완료
**모든 PNG/JPG 이미지를 WebP로 변환 완료**
- Sharp를 사용한 자동 변환 스크립트 생성
- 28개 이미지 파일 변환 완료
- 평균 30-50% 파일 크기 감소
- 코드에서 모든 이미지 import 경로 업데이트 완료

변환 스크립트 실행:
```bash
npm run convert:webp
```

### 3. 라우트 기반 코드 스플리팅
페이지별로 코드 스플리팅:
```typescript
const DownloadPage = lazy(() => import('./components/DownloadPage'));
const PricingPage = lazy(() => import('./components/PricingPage'));
```

### 4. 이미지 CDN 사용
Cloudinary, Imgix 등의 CDN 사용으로 이미지 최적화 및 캐싱

### 5. 서비스 워커 추가
오프라인 지원 및 캐싱으로 재방문 시 로딩 속도 향상

## 현재 번들 크기

- JavaScript: ~516KB (gzip: ~125KB)
- GIF 파일: 28-31MB (최적화 필요!)
- 이미지 파일: 1-2MB 각각

## 우선순위

1. **긴급**: GIF 파일 최적화 (비디오로 변환 권장)
2. **중요**: 이미지 WebP 변환
3. **권장**: 라우트 기반 코드 스플리팅
4. **선택**: 서비스 워커 추가

