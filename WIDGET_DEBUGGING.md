# 안드로이드 위젯 디버깅 가이드

## 1. 로그캣으로 로그 확인

위젯 provider에 로그를 추가했습니다. 다음 명령어로 로그를 확인하세요:

```bash
# 모든 NextScheduleWidget 관련 로그 확인
adb logcat | grep NextScheduleWidget

# 또는 더 자세한 로그
adb logcat -s NextScheduleWidget:D *:S

# 위젯 관련 모든 로그
adb logcat | grep -i widget

# 에러만 확인
adb logcat | grep -i "error\|exception\|crash"
```

## 2. 위젯이 등록되었는지 확인

```bash
# 설치된 위젯 provider 확인
adb shell dumpsys package com.wavetogether.fillin | grep -A 10 "receiver"

# 또는
adb shell dumpsys package com.wavetogether.fillin | grep NextScheduleWidgetProvider
```

## 3. 위젯 데이터 확인

```bash
# SharedPreferences 확인 (위젯 데이터 저장 위치)
adb shell run-as com.wavetogether.fillin
cd shared_prefs
cat es.antonborri.home_widget.xml

# 또는 직접 확인
adb shell run-as com.wavetogether.fillin cat shared_prefs/es.antonborri.home_widget.xml | grep nextSchedule
```

## 4. 위젯 강제 업데이트

앱에서 위젯을 업데이트하거나, 다음 명령어로 강제 업데이트:

```bash
# 위젯 업데이트 브로드캐스트 전송
adb shell am broadcast -a android.appwidget.action.APPWIDGET_UPDATE -n com.wavetogether.fillin/.NextScheduleWidgetProvider
```

## 5. 위젯 레이아웃 확인

레이아웃 파일이 제대로 컴파일되었는지 확인:

```bash
# 빌드된 레이아웃 확인
adb shell run-as com.wavetogether.fillin ls -la app/src/main/res/layout/next_schedule_widget.xml

# 또는 빌드 출력 확인
./gradlew :app:assembleDebug 2>&1 | grep -i "next_schedule"
```

## 6. 위젯 정보 파일 확인

```bash
# 위젯 정보가 제대로 등록되었는지 확인
adb shell dumpsys appwidget | grep -A 20 "NextScheduleWidgetProvider"
```

## 7. 앱 재설치 및 위젯 재등록

위젯이 제대로 표시되지 않으면:

1. 앱 완전 삭제 후 재설치
2. 기존 위젯 제거 후 다시 추가
3. 로그 확인

```bash
# 앱 완전 삭제
adb uninstall com.wavetogether.fillin

# 재설치
flutter install

# 위젯 추가 후 로그 확인
adb logcat | grep NextScheduleWidget
```

## 8. 일반적인 문제 해결

### 위젯이 목록에 안 보이는 경우:
- `AndroidManifest.xml`에 receiver가 제대로 등록되었는지 확인
- `next_schedule_widget_info.xml` 파일이 존재하는지 확인
- 위젯 크기(`minWidth`, `minHeight`)가 올바른지 확인

### 위젯이 로드되지 않는 경우:
- 레이아웃 파일에 오류가 없는지 확인
- 리소스 ID가 올바른지 확인
- 로그캣에서 에러 메시지 확인

### 데이터가 표시되지 않는 경우:
- `nextSchedule` 데이터가 SharedPreferences에 저장되었는지 확인
- JSON 형식이 올바른지 확인
- 위젯 provider에서 데이터를 제대로 읽는지 확인

## 9. 실시간 디버깅

위젯을 추가/업데이트할 때 실시간으로 로그 확인:

```bash
# 터미널 1: 로그 모니터링
adb logcat -c && adb logcat | grep -E "NextScheduleWidget|Widget|ERROR"

# 터미널 2: 앱 실행 및 위젯 추가
flutter run
```

## 10. 위젯 상태 확인

```bash
# 현재 등록된 위젯 확인
adb shell dumpsys appwidget | grep -A 30 "com.wavetogether.fillin"
```

