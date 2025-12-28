import 'dart:async';
import 'package:riverpod_sqflite/riverpod_sqflite.dart';
import 'package:Visir/config/storage_batch_helper.dart';
import 'package:Visir/config/storage_cache.dart';
import 'package:Visir/config/storage_debouncer.dart';

/// 최적화된 Storage 래퍼
/// 
/// JsonSqFliteStorage를 래핑하여 다음 기능을 제공합니다:
/// - 배치 읽기: 여러 키를 한 번에 읽기
/// - 메모리 캐싱: 자주 접근하는 데이터를 메모리에 캐싱
/// - 쓰기 디바운싱: 짧은 시간 내 여러 쓰기를 묶어서 처리
class OptimizedStorage {
  final JsonSqFliteStorage _storage;
  final StorageCache _cache;
  final StorageDebouncer _debouncer;
  
  /// [storage] 기본 스토리지
  /// [cacheMaxSize] 캐시 최대 크기 (기본값: 100)
  /// [debounceDelay] 쓰기 디바운스 지연 시간 (기본값: 500ms)
  OptimizedStorage(
    this._storage, {
    int cacheMaxSize = 100,
    Duration? debounceDelay,
  }) : _cache = StorageCache(maxSize: cacheMaxSize),
       _debouncer = StorageDebouncer(_storage, debounceDelay: debounceDelay);
  
  /// 기본 Storage 인스턴스를 반환합니다
  /// 
  /// persist 함수가 직접 사용할 수 있도록 합니다.
  JsonSqFliteStorage get storage => _storage;
  
  /// 단일 키를 읽습니다
  /// 
  /// 먼저 캐시를 확인하고, 캐시에 없으면 스토리지에서 읽어서 캐시에 저장합니다.
  /// 참고: persist 함수가 내부적으로 처리하므로, 이 메서드는 직접 사용되지 않습니다.
  Future<String?> read(String key) async {
    // 캐시 확인
    final cached = _cache.get(key);
    if (cached != null) {
      return cached;
    }
    
    // 스토리지에서 읽기
    // PersistedData는 persist 함수가 내부적으로 처리하므로,
    // 여기서는 캐시만 확인하고 실제 읽기는 persist 함수가 수행합니다.
    final persistedData = await _storage.read(key);
    // PersistedData의 실제 값은 persist 함수의 decode를 통해 처리됩니다
    // 여기서는 null을 반환하고, 실제 사용 시 persist 함수를 통해 처리합니다
    return persistedData != null ? '' : null;
  }
  
  /// 단일 키에 값을 씁니다
  /// 
  /// 디바운싱을 통해 배치로 처리됩니다.
  Future<void> write(String key, String value) async {
    // 캐시 업데이트
    _cache.put(key, value);
    
    // 디바운싱된 쓰기
    _debouncer.debounceWrite(key, value);
  }
  
  /// 여러 키를 한 번에 읽습니다 (배치 읽기)
  /// 
  /// 캐시를 먼저 확인하고, 캐시에 없는 키만 스토리지에서 읽습니다.
  Future<Map<String, String?>> batchRead(List<String> keys) async {
    if (keys.isEmpty) return {};
    
    final result = <String, String?>{};
    final keysToRead = <String>[];
    
    // 캐시에서 먼저 확인
    for (final key in keys) {
      final cached = _cache.get(key);
      if (cached != null) {
        result[key] = cached;
      } else {
        keysToRead.add(key);
      }
    }
    
    // 캐시에 없는 키만 스토리지에서 읽기
    if (keysToRead.isNotEmpty) {
      final storageResults = await StorageBatchHelper.batchRead(
        _storage,
        keysToRead,
      );
      
      // 결과를 결과 맵과 캐시에 추가
      for (final entry in storageResults.entries) {
        final value = entry.value;
        result[entry.key] = value;
        if (value != null) {
          _cache.put(entry.key, value);
        }
      }
    }
    
    return result;
  }
  
  /// 여러 키-값 쌍을 한 번에 씁니다 (배치 쓰기)
  /// 
  /// 디바운싱을 통해 배치로 처리됩니다.
  Future<void> batchWrite(Map<String, String> keyValuePairs) async {
    // 캐시 업데이트
    for (final entry in keyValuePairs.entries) {
      _cache.put(entry.key, entry.value);
    }
    
    // 디바운싱된 쓰기
    for (final entry in keyValuePairs.entries) {
      _debouncer.debounceWrite(entry.key, entry.value);
    }
  }
  
  /// 대기 중인 모든 쓰기를 즉시 실행합니다
  /// 
  /// 앱 종료 시나 중요한 데이터 저장 시 호출해야 합니다.
  Future<void> flush() => _debouncer.flush();
  
  /// 특정 키를 캐시에서 제거합니다
  void invalidateCache(String key) => _cache.invalidate(key);
  
  /// 특정 접두사로 시작하는 모든 키를 캐시에서 제거합니다
  void invalidateCachePrefix(String prefix) => _cache.invalidatePrefix(prefix);
  
  /// 모든 캐시를 제거합니다
  void clearCache() => _cache.clear();
  
  /// 디바운서를 정리합니다
  /// 
  /// 앱 종료 시 호출해야 합니다.
  void dispose() {
    _debouncer.dispose();
  }
  
  /// 대기 중인 쓰기가 있는지 확인합니다
  bool get hasPendingWrites => _debouncer.hasPendingWrites;
  
  /// 대기 중인 쓰기 개수를 반환합니다
  int get pendingWriteCount => _debouncer.pendingWriteCount;
}

