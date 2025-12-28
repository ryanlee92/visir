# 성능 체크 가이드

브랜딩 페이지의 성능을 측정하고 분석하는 스크립트입니다.

## 설치

먼저 Lighthouse를 설치하세요:

```bash
npm install --save-dev lighthouse
```

또는 전역으로 설치:

```bash
npm install -g lighthouse
```

## 사용법

### 기본 사용 (전체 체크)

```bash
npm run perf
```

이 명령어는:
1. 빌드 폴더 확인 (없으면 빌드 실행)
2. 빌드 크기 분석 (JS, CSS, 이미지, 비디오)
3. Lighthouse 성능 측정 (vite preview 서버 필요)

### 빌드만 체크

```bash
npm run perf:build
```

빌드 크기만 분석하고 Lighthouse는 건너뜁니다.

### Lighthouse만 체크

먼저 preview 서버를 실행한 후:

```bash
# 터미널 1: Preview 서버 실행
npm run preview

# 터미널 2: Lighthouse 실행
npm run perf:lighthouse
```

### 옵션 사용

```bash
# 빌드 건너뛰기
npm run perf -- --skip-build

# Lighthouse 건너뛰기
npm run perf -- --skip-lighthouse

# 다른 URL 사용
npm run perf -- http://localhost:3000
```

## 출력 결과

### 빌드 크기 분석

- 총 빌드 크기
- JavaScript 파일 목록 및 크기
- CSS 파일 목록 및 크기
- 이미지 파일 목록 및 크기
- 비디오 파일 목록 및 크기
- 권장사항

### Lighthouse 리포트

- 성능 점수 (Performance)
- 접근성 점수 (Accessibility)
- 모범 사례 점수 (Best Practices)
- SEO 점수 (SEO)
- 상세 리포트 HTML 파일 (`lighthouse-report.html`)

## 성능 목표

### 빌드 크기 권장사항

- **JavaScript 총합**: 500KB 이하 권장
- **이미지 총합**: 5MB 이하 권장
- **비디오 총합**: 10MB 이하 권장

### Lighthouse 점수 목표

- **Performance**: 90점 이상
- **Accessibility**: 90점 이상
- **Best Practices**: 90점 이상
- **SEO**: 90점 이상

## 문제 해결

### Lighthouse가 실행되지 않는 경우

1. Lighthouse가 설치되어 있는지 확인:
   ```bash
   lighthouse --version
   ```

2. Preview 서버가 실행 중인지 확인:
   ```bash
   npm run preview
   ```

3. URL이 올바른지 확인 (기본값: `http://localhost:4173`)

### 빌드 폴더를 찾을 수 없는 경우

스크립트가 자동으로 빌드를 실행하지만, 수동으로 빌드하려면:

```bash
npm run build
```

## CI/CD 통합

GitHub Actions 예시:

```yaml
- name: Build
  run: npm run build

- name: Performance Check
  run: npm run perf:build
```

## 참고

- Lighthouse 리포트는 `lighthouse-report.html` 파일로 저장됩니다
- 브라우저에서 리포트 파일을 열어 상세 분석을 확인할 수 있습니다
- 성능 점수는 네트워크 상태와 하드웨어에 따라 달라질 수 있습니다

