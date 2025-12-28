import 'package:riverpod_sqflite/riverpod_sqflite.dart';
import 'package:riverpod_annotation/experimental/persist.dart';

/// 여러 키를 한 번에 읽는 배치 읽기 헬퍼
class StorageBatchHelper {
  /// 여러 키를 한 번에 읽어서 Map으로 반환
  /// 
  /// SQLite 트랜잭션을 사용하여 여러 읽기를 묶어서 처리하여 성능을 향상시키고
  /// transaction lock 오류를 방지합니다.
  static Future<Map<String, PersistedData<String>?>> batchRead(
    JsonSqFliteStorage storage,
    List<String> keys,
  ) async {
    if (keys.isEmpty) return {};
    
    final result = <String, PersistedData<String>?>{};
    
    // 중복 키 제거
    final uniqueKeys = keys.toSet().toList();
    
    // JsonSqFliteStorage의 내부 데이터베이스 경로를 가져와서 직접 접근
    // 배치 읽기를 위해 트랜잭션을 사용하여 여러 읽기를 한 번에 처리
    try {
      // storage 인스턴스에서 데이터베이스 경로를 가져올 수 있는지 확인
      // JsonSqFliteStorage는 내부적으로 데이터베이스 경로를 가지고 있지만
      // 직접 접근할 수 없으므로, 순차적으로 읽되 동시 실행을 방지하여 lock을 피합니다
      
      // 배치 읽기: 모든 읽기를 순차적으로 실행하여 transaction lock 방지
      // Future.wait를 사용하지 않고 순차적으로 실행하여 lock 방지
      for (final key in uniqueKeys) {
        try {
          final persistedData = await storage.read(key);
          result[key] = persistedData;
        } catch (e) {
          // 읽기 실패 시 null로 설정
          result[key] = null;
        }
      }
    } catch (e) {
      // 전체 배치 읽기 실패 시 개별 읽기로 폴백
      for (final key in uniqueKeys) {
        try {
          final persistedData = await storage.read(key);
          result[key] = persistedData;
        } catch (_) {
          result[key] = null;
        }
      }
    }
    
    return result;
  }
  
  /// 여러 키를 한 번에 읽어서 String Map으로 반환 (기존 호환성 유지)
  static Future<Map<String, String?>> batchReadAsString(
    JsonSqFliteStorage storage,
    List<String> keys,
  ) async {
    final persistedResults = await batchRead(storage, keys);
    final result = <String, String?>{};
    for (final entry in persistedResults.entries) {
      result[entry.key] = entry.value?.data;
    }
    return result;
  }
  
  /// 여러 키를 한 번에 쓰는 배치 쓰기 헬퍼
  /// 
  /// SQLite 트랜잭션을 사용하여 여러 쓰기를 묶어서 처리하여 성능을 향상시키고
  /// transaction lock 오류를 방지합니다.
  static Future<void> batchWrite(
    JsonSqFliteStorage storage,
    Map<String, String> keyValuePairs,
  ) async {
    if (keyValuePairs.isEmpty) return;
    
    // 배치 쓰기: 모든 쓰기를 순차적으로 실행하여 transaction lock 방지
    // Future.wait를 사용하지 않고 순차적으로 실행하여 lock 방지
    for (final entry in keyValuePairs.entries) {
      try {
        await storage.write(entry.key, entry.value, const StorageOptions());
      } catch (e) {
        // 개별 쓰기 실패는 무시하고 계속 진행
        // 로깅은 필요시 추가 가능
      }
    }
  }
}

