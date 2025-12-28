# Riverpod Persist 최적화 가이드

## 개요

Riverpod persist 기능의 성능을 향상시키기 위해 다음과 같은 최적화를 적용했습니다.

## 주요 최적화 사항

### 1. HiveStorage 최적화

**개선 내용:**
- **읽기 캐싱 추가**: LRU(Least Recently Used) 캐시 전략을 사용하여 자주 접근하는 데이터를 메모리에 캐싱
- **쓰기 시 캐시 즉시 업데이트**: 쓰기 작업 시 디스크에 저장하기 전에 캐시를 먼저 업데이트하여 후속 읽기 성능 향상

**성능 향상:**
- 캐시 히트 시 디스크 I/O 없이 즉시 반환
- 최대 캐시 크기: 100개 항목 (LRU 전략으로 자동 관리)

### 2. SerializedSqliteStorage 개선

**개선 내용:**
- **읽기 병렬화**: SQLite의 읽기 동시 접근을 활용하여 읽기 작업을 병렬 처리
- **쓰기 직렬화 유지**: 쓰기 작업만 직렬화하여 데이터 일관성 보장

**성능 향상:**
- 읽기 작업이 많을 때 성능 크게 향상
- 쓰기 작업은 여전히 직렬화되어 데이터 무결성 보장

### 3. HybridStorage 메타데이터 추적

**개선 내용:**
- **키 위치 추적**: 각 키가 Hive 또는 SQLite 중 어디에 저장되어 있는지 메타데이터로 추적
- **스마트 읽기**: 메타데이터를 활용하여 불필요한 스토리지 접근 방지

**성능 향상:**
- 읽기 시 한 번의 스토리지 접근만 필요 (이전에는 최대 2번)
- 삭제 시에도 해당 위치에서만 삭제하여 불필요한 작업 제거

### 4. BatchedSqliteStorage

**현재 구현:**
- 배치 쓰기 디바운싱 (100ms)
- 읽기 캐싱 (LRU, 최대 100개)
- 쓰기 시 캐시 즉시 업데이트

**참고:**
- JsonSqFliteStorage가 내부적으로 트랜잭션을 사용하지 않으므로, 배치 쓰기는 순차 실행으로 처리됩니다.

## 사용 방법

현재 `providers.dart`에서 `SerializedSqliteStorage`를 사용하고 있으며, 최적화가 자동으로 적용됩니다:

```dart
final storageProvider = FutureProvider<Storage<String, String>>((ref) async {
  // ... SQLite 초기화 ...
  final baseStorage = await JsonSqFliteStorage.open(dbPath);
  return SerializedSqliteStorage(baseStorage); // 최적화된 래퍼 사용
});
```

## 성능 모니터링

### 캐시 히트율 확인

각 Storage 구현체는 캐시를 사용하므로, 자주 접근하는 데이터는 메모리에서 즉시 반환됩니다.

### 읽기/쓰기 비율

- 읽기가 많은 경우: `SerializedSqliteStorage`의 병렬 읽기로 성능 향상
- 쓰기가 많은 경우: 배치 쓰기 디바운싱으로 디스크 I/O 감소

## 추가 최적화 가능 사항

### 1. JSON 인코딩/디코딩 최적화

현재 `persist` 함수에서 `jsonEncode`/`jsonDecode`를 사용하는 경우, 다음과 같은 최적화를 고려할 수 있습니다:

- 자주 변경되지 않는 데이터는 인코딩 결과를 캐싱
- 큰 객체의 경우 압축 고려

### 2. 배치 읽기

여러 키를 한 번에 읽는 경우, 배치 읽기 API를 사용하면 성능을 더 향상시킬 수 있습니다.

### 3. StorageOptions 활용

`StorageOptions`의 `cacheTime`을 적절히 설정하여 불필요한 디스크 읽기를 방지할 수 있습니다.

## 주의사항

1. **메모리 사용량**: 캐시 크기는 제한되어 있지만, 큰 데이터를 많이 캐싱하면 메모리 사용량이 증가할 수 있습니다.

2. **데이터 일관성**: 쓰기 작업은 직렬화되어 처리되므로 데이터 일관성이 보장됩니다.

3. **앱 종료 시**: 중요한 데이터는 앱 종료 전에 `dispose()` 메서드를 호출하여 대기 중인 쓰기를 완료해야 합니다.

## 참고 자료

- [Riverpod Persist 문서](https://riverpod.dev/docs/concepts/about_persist)
- [SQLite WAL 모드](https://www.sqlite.org/wal.html)
- [LRU 캐시 알고리즘](https://en.wikipedia.org/wiki/Cache_replacement_policies#Least_recently_used_(LRU))

