import 'dart:async';
import 'dart:convert';
import 'dart:collection';

import 'package:hive_flutter_ce/hive_flutter_ce.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/experimental/persist.dart';

/// Hive 기반 Storage 구현
/// Riverpod persist 함수에서 사용하는 Storage 인터페이스를 구현합니다.
final class HiveStorage extends Storage<String, String> {
  static const String _boxName = 'riverpod_persist';
  static Box? _box;
  static bool _initialized = false;

  // 배치 쓰기를 위한 디바운싱
  final Map<String, String> _pendingWrites = {};
  Timer? _debounceTimer;
  static const Duration _debounceDelay = Duration(milliseconds: 100);

  // 읽기 캐싱 (LRU)
  final LinkedHashMap<String, String> _readCache = LinkedHashMap();
  static const int _maxCacheSize = 100;

  /// Hive 초기화
  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      final appDir = await getApplicationSupportDirectory();
      Hive.init(appDir.path);
      _box = await Hive.openBox(_boxName);
      _initialized = true;
    } catch (e) {
      // 이미 초기화된 경우 무시
      if (_box == null) {
        _box = await Hive.openBox(_boxName);
      }
      _initialized = true;
    }
  }

  /// 박스 가져오기 (초기화 확인)
  Future<Box> _getBox() async {
    if (!_initialized || _box == null) {
      await initialize();
    }
    return _box!;
  }

  @override
  Future<PersistedData<String>?> read(String key) async {
    // 캐시에서 먼저 확인
    if (_readCache.containsKey(key)) {
      // LRU: 사용된 항목을 맨 뒤로 이동
      final value = _readCache.remove(key);
      _readCache[key] = value!;
      return PersistedData(value);
    }

    try {
      final box = await _getBox();
      final value = box.get(key);
      if (value == null) return null;
      final stringValue = value is String ? value : value.toString();
      // 캐시에 추가 (LRU)
      _addToCache(key, stringValue);
      return PersistedData(stringValue);
    } catch (e) {
      return null;
    }
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

  @override
  Future<void> write(String key, String value, [StorageOptions? options]) async {
    // 캐시 업데이트 (즉시 반영)
    _addToCache(key, value);

    // 배치 쓰기 큐에 추가
    _pendingWrites[key] = value;

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
    // Hive는 TTL을 지원하지 않으므로 구현하지 않음
    // 필요 시 수동으로 오래된 키 삭제
  }

  /// 대기 중인 모든 쓰기를 실행
  Future<void> _flushWrites() async {
    if (_pendingWrites.isEmpty) return;

    final writes = Map<String, String>.from(_pendingWrites);
    _pendingWrites.clear();

    try {
      final box = await _getBox();
      await box.putAll(writes);
    } catch (e) {
      // 에러 발생 시 개별 쓰기로 폴백
      final box = await _getBox();
      for (final entry in writes.entries) {
        try {
          await box.put(entry.key, entry.value);
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
      final box = await _getBox();
      await box.delete(key);
    } catch (e) {
      // 삭제 실패는 무시
    }
  }

  /// 모든 키 삭제 (destroyKey 사용 시)
  Future<void> clear() async {
    _pendingWrites.clear();
    _debounceTimer?.cancel();
    try {
      final box = await _getBox();
      await box.clear();
    } catch (e) {
      // 클리어 실패는 무시
    }
  }

  /// destroyKey로 시작하는 모든 키 삭제
  Future<void> clearByPrefix(String prefix) async {
    _pendingWrites.removeWhere((key, _) => key.startsWith(prefix));
    try {
      final box = await _getBox();
      final keysToDelete = <String>[];
      for (final key in box.keys) {
        if (key.toString().startsWith(prefix)) {
          keysToDelete.add(key.toString());
        }
      }
      await box.deleteAll(keysToDelete);
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

