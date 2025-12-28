# 성능 병목 확인 방법

## Chrome/Edge 개발자 도구 사용법

1. **Performance 탭 열기**
   - F12 또는 Cmd+Option+I (Mac) / Ctrl+Shift+I (Windows)
   - Performance 탭 클릭

2. **성능 기록 시작**
   - Record 버튼 클릭 (빨간 원)
   - 페이지를 사용 (스크롤, 클릭 등)
   - Stop 버튼 클릭

3. **병목 확인**
   - **Main 스레드**: 긴 작업(빨간 막대) 확인
   - **Network**: 큰 파일이나 느린 요청 확인
   - **FPS**: 프레임 드롭 확인
   - **Scripting**: JavaScript 실행 시간 확인
   - **Rendering**: 렌더링 시간 확인

4. **Lighthouse 사용**
   - Lighthouse 탭 클릭
   - Performance 체크
   - Analyze page load 클릭
   - 점수와 권장사항 확인

## 주요 확인 사항

- **Long Tasks**: 50ms 이상 걸리는 작업
- **Layout Shifts**: CLS (Cumulative Layout Shift)
- **Large Bundle**: 큰 JavaScript 번들
- **Unused CSS**: 사용하지 않는 CSS
- **Blocking Resources**: 렌더링을 막는 리소스
