# 브랜딩 페이지 GIF 가이드

## 📍 GIF 파일 위치

GIF 파일을 다음 위치에 넣어주세요:
```
branding/public/assets/app-demo.gif
```

또는 Vite의 public 폴더를 사용:
```
branding/public/app-demo.gif
```

현재 코드는 `/assets/app-demo.gif` 경로를 사용하므로 `public/assets/app-demo.gif`에 파일을 넣으면 됩니다.

## 🎬 추천 GIF 내용

### 1. **Daily Briefing 화면** (가장 추천)
- AI가 정리한 일정과 우선순위를 보여주는 화면
- 카드들이 나타나고, 일정이 타임라인에 표시되는 애니메이션
- 길이: 5-8초

### 2. **Universal Inbox 탐색**
- 이메일, Slack, Linear가 통합된 뷰
- 스크롤하면서 다양한 알림이 보이는 모습
- 길이: 6-10초

### 3. **Task를 Calendar로 드래그**
- Task를 드래그해서 Calendar에 드롭하는 모션
- 타임블로킹이 자동으로 생성되는 과정
- 길이: 3-5초

### 4. **Command Palette (Cmd+K)**
- Command Palette를 열고 빠르게 액션을 실행하는 모습
- 검색 → 선택 → 실행의 흐름
- 길이: 4-6초

### 5. **AI 요약 생성**
- 이메일이나 회의가 요약되는 과정
- AI가 분석하고 요약 카드를 생성하는 애니메이션
- 길이: 5-7초

## 🛠️ GIF 만드는 방법

### 방법 1: 실제 앱 녹화 (가장 추천)

#### macOS:
1. **QuickTime Player** 사용:
   ```bash
   # QuickTime Player 열기 → 파일 → 새로운 화면 녹화
   # 또는 Cmd+Shift+5 (macOS Mojave 이상)
   ```

2. **Screen Studio** (유료, 추천):
   - 자동으로 부드러운 애니메이션 추가
   - 커서 하이라이트, 줌 인/아웃 효과
   - https://www.screen.studio/

3. **Kap** (무료):
   - 간단한 화면 녹화 및 편집
   - https://getkap.co/

#### Windows:
- **OBS Studio** (무료)
- **ShareX** (무료, GIF 변환 포함)

#### 모바일:
- iOS: 기본 화면 녹화 기능
- Android: 화면 녹화 앱 사용

### 방법 2: 시뮬레이션 도구

1. **Screen Studio**: 자동으로 부드러운 애니메이션 추가
2. **Kapwing**: 브라우저에서 편집 가능
3. **Loom**: 간단한 화면 녹화

### 방법 3: Figma/프로토타이핑 도구

- Figma의 프로토타입을 녹화
- Framer, Principle 등으로 애니메이션 제작 후 녹화

## ⚙️ GIF 최적화 팁

### 해상도
- **권장**: 1920x1200 또는 1440x900 (16:10 비율 유지)
- Hero 컴포넌트의 `aspect-[16/10]` 비율에 맞춰주세요

### 프레임 레이트
- **권장**: 10-15fps (용량 절감)
- 부드러운 애니메이션: 24fps
- 용량 우선: 8-10fps

### 길이
- **권장**: 5-10초
- 너무 길면 사용자가 기다리지 않음
- 루프가 자연스러워야 함

### 용량
- **목표**: 5MB 이하
- **최대**: 10MB (로딩 시간 고려)

### 최적화 도구
1. **ezgif.com**: 온라인 GIF 최적화
2. **ImageOptim** (macOS): 로컬 최적화
3. **Squoosh**: Google의 이미지 압축 도구

### 대안: MP4/WebP 사용
GIF 대신 MP4나 WebP를 사용하면 용량을 크게 줄일 수 있습니다:
- MP4: 용량 1/10 수준
- WebP: 애니메이션 지원, 용량 1/5 수준

## 📝 코드 수정 방법

현재 Hero 컴포넌트는 자동으로 GIF를 감지합니다:
- GIF가 있으면: GIF 표시
- GIF가 없으면: 기존 CSS 목업 표시 (fallback)

### 다른 경로 사용하려면:

`Hero.tsx` 파일의 8번째 줄을 수정하세요:
```typescript
const gifPath = '/assets/app-demo.gif'; // 여기를 변경
```

### MP4 사용하려면:

```typescript
// Hero.tsx 수정
{!gifError ? (
  <video 
    src="/assets/app-demo.mp4"
    autoPlay
    loop
    muted
    playsInline
    className="w-full h-full object-cover"
  />
) : (
  // fallback...
)}
```

## ✅ 체크리스트

- [ ] 실제 앱에서 주요 기능 녹화
- [ ] 해상도 16:10 비율로 조정
- [ ] 길이 5-10초로 편집
- [ ] 용량 5MB 이하로 최적화
- [ ] 루프가 자연스러운지 확인
- [ ] `public/assets/app-demo.gif`에 파일 추가
- [ ] 브라우저에서 테스트

## 🎨 디자인 팁

1. **시작과 끝이 자연스럽게 연결**: 루프가 끊기지 않도록
2. **중요한 부분 하이라이트**: 줌 인/아웃이나 하이라이트 효과 사용
3. **속도 조절**: 너무 빠르면 이해하기 어려움
4. **배경**: 다크 모드에 맞는 어두운 배경 사용
5. **텍스트 가독성**: 작은 텍스트는 확대하거나 하이라이트

## 📚 참고 자료

- [Screen Studio](https://www.screen.studio/)
- [Kap](https://getkap.co/)
- [ezgif.com](https://ezgif.com/)
- [Squoosh](https://squoosh.app/)






















