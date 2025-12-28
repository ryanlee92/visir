# Analytics 설정 가이드

브랜딩 페이지에 Google Analytics 4 (GA4)를 통합했습니다.

## 설정 방법

### 1. 환경 변수 설정

GA4 ID를 설정하는 방법은 두 가지가 있습니다:

#### 방법 1: 로컬 개발용 `.env` 파일 (권장)

프로젝트 루트(`branding/`)에 `.env` 파일을 생성하고 다음 변수를 추가하세요:

```bash
# Google Analytics 4 Measurement ID (예: G-XXXXXXXXXX)
VITE_GA4_ID=G-XXXXXXXXXX
```

**주의**: `.env` 파일은 `.gitignore`에 포함되어 Git에 커밋되지 않습니다.

#### 방법 2: Firebase Hosting 배포 시 환경 변수 사용

Firebase Hosting은 정적 호스팅이므로 환경 변수는 **빌드 시점에 번들에 포함**됩니다.

배포 시 환경 변수를 설정하려면:

```bash
# 방법 A: 환경 변수로 직접 설정
cd branding
VITE_GA4_ID=G-XXXXXXXXXX npm run build
cd ..
firebase deploy --only hosting:visir-app

# 방법 B: 배포 스크립트 사용 (환경 변수 포함)
cd branding
VITE_GA4_ID=G-XXXXXXXXXX npm run dp

# 방법 C: CI/CD에서 환경 변수 설정
# GitHub Actions 예시:
- name: Build and Deploy
  env:
    VITE_GA4_ID: ${{ secrets.VITE_GA4_ID }}
  run: npm run dp
```

### 2. GA4 Measurement ID 얻기

#### 방법 1: 기존 GA4 속성이 있는 경우

1. [Google Analytics](https://analytics.google.com/)에 로그인
2. 좌측 하단의 **관리** (톱니바퀴 아이콘) 클릭
3. **속성** 열에서 원하는 속성 선택
4. **데이터 스트림** 클릭
5. **웹 스트림** 클릭 (또는 기존 웹 스트림 선택)
6. **Measurement ID** 복사 (형식: `G-XXXXXXXXXX`)

#### 방법 2: 새 GA4 속성 생성

1. [Google Analytics](https://analytics.google.com/)에 로그인
2. 좌측 하단의 **관리** 클릭
3. **속성 만들기** 클릭
4. 속성 이름 입력 (예: "Visir Website")
5. 보고 시간대 및 통화 선택
6. **다음** 클릭
7. 비즈니스 정보 입력 후 **만들기** 클릭
8. **데이터 스트림** 섹션에서 **웹** 선택
9. 웹사이트 URL 입력: `https://visir.pro`
10. 스트림 이름 입력 (예: "Visir Production")
11. **스트림 만들기** 클릭
12. 생성된 **Measurement ID** 복사 (형식: `G-XXXXXXXXXX`)

#### 빠른 확인 방법

- GA4 대시보드에서 우측 상단의 **관리** > **데이터 스트림** > 웹 스트림을 클릭하면 Measurement ID가 표시됩니다
- 형식은 항상 `G-`로 시작하는 영문자와 숫자 조합입니다 (예: `G-ABC123XYZ`)

## 기능

### 자동 추적

- **페이지뷰**: 라우트 변경 시 자동으로 추적됩니다

### 수동 이벤트 추적

`lib/analytics.ts`에서 제공하는 함수들을 사용할 수 있습니다:

```typescript
import { trackEvent, trackButtonClick, trackCTA, trackDownload } from './lib/analytics';

// 커스텀 이벤트
trackEvent('custom_event', {
  category: 'engagement',
  value: 100
});

// 버튼 클릭
trackButtonClick('Get Started', '/');

// CTA 클릭
trackCTA('Hero CTA', '/');

// 다운로드 추적
trackDownload('macOS');
```

### 사용 가능한 함수

- `trackPageView(path, title?)` - 페이지뷰 추적
- `trackEvent(eventName, params?)` - 커스텀 이벤트
- `trackButtonClick(buttonName, location?)` - 버튼 클릭
- `trackLinkClick(linkUrl, linkText?)` - 링크 클릭
- `trackDownload(platform)` - 다운로드 추적
- `trackSignup(method)` - 회원가입 추적
- `trackCTA(ctaName, location?)` - CTA 클릭
- `setUserProperties(properties)` - 사용자 속성 설정
- `identifyUser(userId, traits?)` - 사용자 식별

## 성능 최적화

- **Partytown 사용**: 분석 스크립트를 Web Worker에서 실행하여 메인 스레드 성능에 영향을 주지 않습니다
- **지연 로딩**: 분석 스크립트는 필요할 때만 로드됩니다
- **조건부 로딩**: 환경 변수가 설정되지 않으면 스크립트가 로드되지 않습니다

## 개발 환경

개발 환경에서는 환경 변수가 없어도 앱이 정상적으로 작동합니다. 분석 추적만 비활성화됩니다.

## 프로덕션 배포

프로덕션 배포 전에 `.env` 파일에 실제 GA4 ID를 설정했는지 확인하세요.

## 문제 해결

### 분석 데이터가 보이지 않음

1. 환경 변수가 올바르게 설정되었는지 확인
2. 브라우저 콘솔에서 오류 확인
3. GA4 대시보드에서 실시간 데이터 확인 (약간의 지연이 있을 수 있음)

### Partytown 오류

Partytown이 제대로 작동하지 않으면:
1. 빌드 후 `dist/~partytown` 디렉토리가 생성되었는지 확인
2. 브라우저 콘솔에서 Partytown 관련 오류 확인

