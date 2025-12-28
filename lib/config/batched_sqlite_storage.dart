import 'dart:async';
import 'dart:collection';

import 'package:riverpod_annotation/experimental/persist.dart';
import 'package:riverpod_sqflite/riverpod_sqflite.dart';

/// 배치 쓰기와 캐싱을 지원하는 SQLite Storage 구현
final class BatchedSqliteStorage extends Storage<String, String> {
  final JsonSqFliteStorage _storage;

  // 배치 쓰기를 위한 디바운싱
  final Map<String, String> _pendingWrites = {};
  Timer? _debounceTimer;
  static const Duration _debounceDelay = Duration(milliseconds: 100);

  // 읽기 캐싱 (LRU)
  final LinkedHashMap<String, String> _readCache = LinkedHashMap();
  static const int _maxCacheSize = 100;

  BatchedSqliteStorage(this._storage);

  @override
  Future<PersistedData<String>?> read(String key) async {
    // 캐시에서 먼저 확인
    if (_readCache.containsKey(key)) {
      // LRU: 사용된 항목을 맨 뒤로 이동
      final value = _readCache.remove(key);
      _readCache[key] = value!;
      return PersistedData(value);
    }

    // 캐시 미스 시 데이터베이스에서 읽기
    final persistedData = await _storage.read(key);
    if (persistedData != null) {
      final value = persistedData.data;
      // 캐시에 추가 (LRU)
      _addToCache(key, value);
      return PersistedData(value);
    }
    return null;
  }

  /// 캐시에 추가 (LRU)
  void _addToCache(String key, String value) {
    if (_readCache.containsKey(key)) {
      _readCache.remove(key);
    } else if (_readCache.length >= _maxCacheSize) {
      // 가장 오래된 항목 제거
      _readCache.remove(_readCache.keys.first);
    }
    _readCache[key] = value;
  }

  StorageOptions? _lastOptions;

  @override
  Future<void> write(String key, String value, [StorageOptions? options]) async {
    // 캐시 업데이트
    _addToCache(key, value);

    // 배치 쓰기 큐에 추가
    _pendingWrites[key] = value;
    _lastOptions = options ?? _lastOptions;

    // 디바운스 타이머 재시작
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDelay, () async {
      await _flushWrites();
    });
  }

  @override
  Future<void> delete(String key) async {
    await remove(key);
  }

  @override
  Future<void> deleteOutOfDate({Duration? maxAge}) async {
    // JsonSqFliteStorage의 deleteOutOfDate 사용
    await _storage.deleteOutOfDate();
  }

  /// 대기 중인 모든 쓰기를 배치로 실행
  Future<void> _flushWrites() async {
    if (_pendingWrites.isEmpty) return;

    final writes = Map<String, String>.from(_pendingWrites);
    _pendingWrites.clear();

      // 트랜잭션으로 배치 쓰기
    try {
      // JsonSqFliteStorage는 내부적으로 트랜잭션을 사용하지 않으므로
      // 개별 쓰기를 순차적으로 실행
      // 향후 개선: JsonSqFliteStorage에 배치 쓰기 메서드 추가 고려
      final options = _lastOptions ?? const StorageOptions();
      for (final entry in writes.entries) {
        await _storage.write(entry.key, entry.value, options);
      }
    } catch (e) {
      // 에러 발생 시 개별 쓰기로 폴백
      final options = _lastOptions ?? const StorageOptions();
      for (final entry in writes.entries) {
        try {
          await _storage.write(entry.key, entry.value, options);
        } catch (_) {
          // 개별 쓰기 실패는 무시
        }
      }
    }
  }

  Future<void> remove(String key) async {
    // 캐시에서 제거
    _readCache.remove(key);
    _pendingWrites.remove(key);

    try {
      await _storage.delete(key);
    } catch (e) {
      // 삭제 실패는 무시
    }
  }

  /// 앱 종료 시 호출하여 대기 중인 쓰기 완료
  Future<void> dispose() async {
    _debounceTimer?.cancel();
    await _flushWrites();
  }

  /// 캐시 클리어
  void clearCache() {
    _readCache.clear();
  }
}

