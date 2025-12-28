# Firebase Hosting 배포 가이드

## 사전 요구사항

1. Firebase CLI 설치
```bash
npm install -g firebase-tools
```

2. Firebase 로그인
```bash
firebase login
```

## 환경 변수 설정

**중요**: Firebase Hosting은 정적 파일만 호스팅하므로, 환경 변수는 **빌드 시점에 번들에 포함**됩니다.

### 로컬 개발
`.env` 파일을 생성하고 환경 변수를 설정하세요:
```
VITE_SUPABASE_URL=your_supabase_url
VITE_SUPABASE_ANON_KEY=your_supabase_anon_key
VITE_GA4_ID=G-XXXXXXXXXX
```

**주의**: `.env` 파일은 `.gitignore`에 포함되어 Git에 커밋되지 않습니다.

### 프로덕션 배포

환경 변수를 공개하지 않으려면 다음 방법 중 하나를 사용하세요:

#### 방법 1: 환경 변수를 직접 설정하여 빌드 (권장)
```bash
cd branding
VITE_SUPABASE_URL=your_url VITE_SUPABASE_ANON_KEY=your_key VITE_GA4_ID=G-XXXXXXXXXX npm run build
cd ..
firebase deploy --only hosting:visir-app
```

#### 방법 2: .env 파일 사용 (로컬 배포 시)
```bash
cd branding
# .env 파일이 있는지 확인
npm run build
cd ..
firebase deploy --only hosting:visir-app
```

#### 방법 3: CI/CD에서 환경 변수 설정
GitHub Actions, GitLab CI 등에서 환경 변수를 Secret으로 설정하고 빌드:
```yaml
# 예시: GitHub Actions
- name: Build
  env:
    VITE_SUPABASE_URL: ${{ secrets.VITE_SUPABASE_URL }}
    VITE_SUPABASE_ANON_KEY: ${{ secrets.VITE_SUPABASE_ANON_KEY }}
    VITE_GA4_ID: ${{ secrets.VITE_GA4_ID }}
  run: npm run build
```

#### 방법 4: Firebase Hosting 환경 변수 사용 (CI/CD에서)
Firebase CLI를 사용하여 환경 변수를 설정할 수 있습니다:
```bash
# Firebase CLI로 환경 변수 설정 (로컬에서)
export VITE_GA4_ID=G-XXXXXXXXXX

# 또는 CI/CD에서 환경 변수로 설정
# GitHub Actions 예시:
- name: Build and Deploy
  env:
    VITE_GA4_ID: ${{ secrets.VITE_GA4_ID }}
  run: npm run dp
```

## 배포 방법

### 방법 1: npm 스크립트 사용 (가장 간단)
```bash
cd branding

# 옵션 A: .env 파일 사용 (가장 간단)
npm run dp

# 옵션 B: 인자로 전달
npm run dp url key

# 옵션 C: 환경 변수로 전달
VITE_SUPABASE_URL=your_url VITE_SUPABASE_ANON_KEY=your_key npm run dp
```

이 명령어는 자동으로:
1. 환경 변수 확인
2. `npm run build` - 프로젝트 빌드
3. `firebase deploy --only hosting:visir-app` - Firebase에 배포

### 방법 2: 자동 배포 스크립트 (로컬 .env 사용)
```bash
cd branding
npm run deploy
```

이 명령어는 다음을 수행합니다:
1. `npm run build` - 프로젝트 빌드 (.env 파일 사용)
2. `firebase deploy --only hosting:visir-app` - Firebase에 배포

### 방법 3: 수동 배포
```bash
# 1. 빌드 (환경 변수 설정 필요)
cd branding
npm run build

# 2. 배포 (루트 디렉토리에서)
cd ..
firebase deploy --only hosting:visir-app
```

## Firebase 프로젝트 설정

Firebase Console에서:
1. Hosting 섹션으로 이동
2. 새 사이트 추가 (또는 기존 사이트 사용)
3. 사이트 ID를 `visir-app`으로 설정 (또는 원하는 이름으로 변경)

현재 설정 (`firebase.json`):
- 사이트: `visir-app`
- Public 디렉토리: `branding/dist`
- Rewrites: 모든 경로를 `index.html`로 리다이렉트 (React Router 지원)

## 배포 전 체크리스트

- [ ] 환경 변수가 설정되어 있는지 확인 (`.env` 파일 또는 환경 변수)
- [ ] `npm run build`가 성공적으로 완료되는지 확인
- [ ] `branding/dist` 폴더에 빌드된 파일이 생성되었는지 확인
- [ ] Firebase CLI가 로그인되어 있는지 확인 (`firebase login`)

## 보안 주의사항

- ✅ `.env` 파일은 `.gitignore`에 포함되어 Git에 커밋되지 않습니다
- ✅ 환경 변수는 빌드 시점에 번들에 포함되지만, `.env` 파일 자체는 배포되지 않습니다
- ⚠️ 빌드된 JavaScript 파일에는 환경 변수 값이 포함됩니다 (브라우저에서 볼 수 있음)
- ℹ️ Supabase anon key는 공개되어도 RLS로 보호되지만, 가능하면 공개하지 않는 것이 좋습니다

## 주의사항

- React Router의 BrowserRouter를 사용하고 있어서 rewrites 설정이 필요합니다 (이미 설정됨)
- 빌드된 파일은 `branding/dist` 폴더에 생성됩니다
- 배포 전에 항상 빌드를 먼저 실행하세요
- 환경 변수는 빌드 시점에 번들에 포함되므로, 배포 후 변경하려면 다시 빌드해야 합니다

## 문제 해결

### 환경 변수가 적용되지 않는 경우
1. `.env` 파일이 `branding/` 디렉토리에 있는지 확인
2. 환경 변수 이름이 `VITE_` 접두사로 시작하는지 확인
3. 빌드 후 브라우저 콘솔에서 `import.meta.env`를 확인하여 값이 포함되었는지 확인

### 배포 실패 시
1. Firebase CLI 버전 확인: `firebase --version`
2. Firebase 로그인 상태 확인: `firebase projects:list`
3. 빌드 로그 확인: `npm run build` 출력 확인
