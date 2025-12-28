import 'dart:async';
import 'dart:convert';

import 'package:riverpod_annotation/experimental/persist.dart';

import 'batched_sqlite_storage.dart';
import 'hive_storage.dart';

/// 데이터 크기에 따라 Hive 또는 SQLite로 자동 라우팅하는 하이브리드 Storage
/// 
/// 키 위치를 메타데이터로 추적하여 불필요한 읽기를 방지합니다.
final class HybridStorage extends Storage<String, String> {
  final HiveStorage _hiveStorage;
  final BatchedSqliteStorage _sqliteStorage;

  // 데이터 크기 임계값 (1MB)
  static const int _sizeThreshold = 1024 * 1024;

  // 키 위치 추적 (true: Hive, false: SQLite, null: 알 수 없음)
  final Map<String, bool?> _keyLocation = {};
  static const int _maxLocationCacheSize = 500;

  HybridStorage(this._hiveStorage, this._sqliteStorage);

  @override
  Future<PersistedData<String>?> read(String key) async {
    // 메타데이터에서 키 위치 확인
    final location = _keyLocation[key];
    
    if (location == true) {
      // Hive에 있다고 알려진 경우
      final hiveValue = await _hiveStorage.read(key);
      if (hiveValue != null) {
        return hiveValue;
      }
      // Hive에 없으면 메타데이터 업데이트하고 SQLite 확인
      _updateKeyLocation(key, false);
      return await _sqliteStorage.read(key);
    } else if (location == false) {
      // SQLite에 있다고 알려진 경우
      return await _sqliteStorage.read(key);
    } else {
      // 위치를 모르는 경우: 먼저 Hive에서 확인 (일반적으로 더 빠름)
      final hiveValue = await _hiveStorage.read(key);
      if (hiveValue != null) {
        _updateKeyLocation(key, true);
        return hiveValue;
      }
      
      // Hive에 없으면 SQLite에서 확인
      final sqliteValue = await _sqliteStorage.read(key);
      if (sqliteValue != null) {
        _updateKeyLocation(key, false);
      }
      return sqliteValue;
    }
  }

  /// 키 위치 메타데이터 업데이트
  void _updateKeyLocation(String key, bool isHive) {
    if (_keyLocation.length >= _maxLocationCacheSize) {
      // 가장 오래된 항목 제거 (FIFO)
      final firstKey = _keyLocation.keys.first;
      _keyLocation.remove(firstKey);
    }
    _keyLocation[key] = isHive;
  }

  @override
  Future<void> write(String key, String value, [StorageOptions? options]) async {
    final dataSize = utf8.encode(value).length;

    if (dataSize < _sizeThreshold) {
      // 작은 데이터는 Hive에 저장
      final oldLocation = _keyLocation[key];
      if (oldLocation == false) {
        // SQLite에도 있으면 제거 (중복 방지)
        await _sqliteStorage.delete(key);
      }
      await _hiveStorage.write(key, value);
      _updateKeyLocation(key, true);
    } else {
      // 큰 데이터는 SQLite에 저장
      final oldLocation = _keyLocation[key];
      if (oldLocation == true) {
        // Hive에도 있으면 제거 (중복 방지)
        await _hiveStorage.delete(key);
      }
      await _sqliteStorage.write(key, value);
      _updateKeyLocation(key, false);
    }
  }

  @override
  Future<void> delete(String key) async {
    // 메타데이터에서 위치 확인하여 해당 위치에서만 삭제
    final location = _keyLocation[key];
    
    if (location == true) {
      await _hiveStorage.delete(key);
    } else if (location == false) {
      await _sqliteStorage.delete(key);
    } else {
      // 위치를 모르는 경우 양쪽 모두에서 제거
      await Future.wait([
        _hiveStorage.delete(key),
        _sqliteStorage.delete(key),
      ]);
    }
    
    // 메타데이터에서 제거
    _keyLocation.remove(key);
  }

  @override
  Future<void> deleteOutOfDate({Duration? maxAge}) async {
    await Future.wait([
      _hiveStorage.deleteOutOfDate(),
      _sqliteStorage.deleteOutOfDate(),
    ]);
  }

  /// destroyKey로 시작하는 모든 키 삭제
  Future<void> clearByPrefix(String prefix) async {
    // 메타데이터에서 해당 접두사로 시작하는 키 찾기
    final keysToDelete = _keyLocation.keys.where((key) => key.startsWith(prefix)).toList();
    
    // 각 키를 개별적으로 삭제
    for (final key in keysToDelete) {
      await delete(key);
    }
    
    // Hive에서도 접두사로 삭제
    await _hiveStorage.clearByPrefix(prefix);
  }

  /// 앱 종료 시 호출
  Future<void> dispose() async {
    await Future.wait([
      _hiveStorage.dispose(),
      _sqliteStorage.dispose(),
    ]);
  }
}

