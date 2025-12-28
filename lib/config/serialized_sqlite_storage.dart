import 'dart:async';
import 'dart:collection';

import 'package:riverpod_annotation/experimental/persist.dart';
import 'package:riverpod_sqflite/riverpod_sqflite.dart';
import 'package:Visir/config/storage_batch_helper.dart';

/// SQLite 접근을 최적화하는 Storage 래퍼
/// 
/// 읽기 작업과 쓰기 작업을 모두 직렬화하여
/// 동시 접근으로 인한 잠금 문제를 방지합니다.
/// 읽기 작업은 배치로 묶어서 처리하여 성능을 향상시킵니다.
final class SerializedSqliteStorage extends Storage<String, String> {
  final JsonSqFliteStorage _storage;
  
  // 쓰기 작업을 위한 직렬화 큐
  final Queue<_WriteOperation> _writeQueue = Queue();
  bool _processingWrites = false;
  
  // 배치 읽기를 위한 대기 중인 읽기 작업들
  final Map<String, Completer<PersistedData<String>?>> _pendingReads = {};
  Timer? _readBatchTimer;
  bool _processingReads = false;
  static const Duration _readBatchDelay = Duration(milliseconds: 50);
  
  final Completer<void>? _shutdownCompleter = Completer<void>();

  SerializedSqliteStorage(this._storage);

  /// 쓰기 작업을 큐에 추가하고 순차 실행
  Future<void> _enqueueWrite(Future<void> Function() operation) async {
    final completer = Completer<void>();
    _writeQueue.add(_WriteOperation(completer, operation));
    _processWriteQueue();
    return completer.future;
  }

  /// 쓰기 큐 처리 (직렬화)
  Future<void> _processWriteQueue() async {
    if (_processingWrites) return;
    if (_writeQueue.isEmpty) return;

    _processingWrites = true;

    while (_writeQueue.isNotEmpty) {
      final operation = _writeQueue.removeFirst();
      try {
        await operation.operation();
        operation.completer.complete();
      } catch (e) {
        if (!operation.completer.isCompleted) {
          operation.completer.completeError(e);
        }
      }
    }

    _processingWrites = false;

    // 종료 대기 중이면 완료
    if (_shutdownCompleter != null && 
        !_shutdownCompleter.isCompleted && 
        _writeQueue.isEmpty && 
        !_processingReads && 
        _pendingReads.isEmpty) {
      _shutdownCompleter.complete();
    }
  }

  @override
  Future<PersistedData<String>?> read(String key) async {
    // 읽기 작업을 배치로 묶어서 처리
    // 짧은 시간 내 여러 읽기 요청이 오면 배치로 처리하여 transaction lock 방지
    final completer = Completer<PersistedData<String>?>();
    
    // 이미 대기 중인 읽기가 있으면 같은 배치에 포함
    if (_pendingReads.containsKey(key)) {
      // 이미 대기 중인 읽기가 있으면 기존 completer를 반환
      return _pendingReads[key]!.future;
    }
    
    _pendingReads[key] = completer;
    
    // 배치 타이머 재시작
    _readBatchTimer?.cancel();
    _readBatchTimer = Timer(_readBatchDelay, () {
      _processReadBatch();
    });
    
    return completer.future;
  }
  
  /// 대기 중인 읽기 작업들을 배치로 처리
  Future<void> _processReadBatch() async {
    if (_pendingReads.isEmpty) return;
    if (_processingReads) return;
    
    _processingReads = true;
    
    // 대기 중인 모든 키를 한 번에 읽기
    final keys = _pendingReads.keys.toList();
    final completers = Map<String, Completer<PersistedData<String>?>>.from(_pendingReads);
    _pendingReads.clear();
    
    try {
      // 배치 읽기 수행
      final results = await StorageBatchHelper.batchRead(_storage, keys);
      
      // 결과를 각 completer에 전달
      for (final entry in results.entries) {
        final completer = completers[entry.key];
        if (completer != null && !completer.isCompleted) {
          completer.complete(entry.value);
        }
      }
      
      // 결과가 없는 키들에 대해 null 완료
      for (final entry in completers.entries) {
        if (!entry.value.isCompleted) {
          entry.value.complete(null);
        }
      }
    } catch (e) {
      // 에러 발생 시 모든 completer에 에러 전달
      for (final completer in completers.values) {
        if (!completer.isCompleted) {
          completer.completeError(e);
        }
      }
    } finally {
      _processingReads = false;
      
      // 모든 작업이 완료되면 종료 완료
      if (_shutdownCompleter != null && 
          !_shutdownCompleter.isCompleted && 
          _writeQueue.isEmpty && 
          _pendingReads.isEmpty) {
        _shutdownCompleter.complete();
      }
    }
  }

  /// 여러 키를 배치로 읽기
  /// 
  /// SQLite 트랜잭션을 사용하여 여러 읽기를 묶어서 처리하여
  /// transaction lock 오류를 방지합니다.
  Future<Map<String, PersistedData<String>?>> batchRead(List<String> keys) async {
    if (keys.isEmpty) return {};
    
    // StorageBatchHelper를 사용하여 배치 읽기 수행
    return await StorageBatchHelper.batchRead(_storage, keys);
  }

  @override
  Future<void> write(String key, String value, [StorageOptions? options]) async {
    // 쓰기는 직렬화하여 처리
    return await _enqueueWrite(() => _storage.write(key, value, options ?? const StorageOptions()));
  }

  @override
  Future<void> delete(String key) async {
    // 삭제도 쓰기 작업으로 간주하여 직렬화
    return await _enqueueWrite(() => _storage.delete(key));
  }

  @override
  Future<void> deleteOutOfDate({Duration? maxAge}) async {
    // 삭제 작업이므로 직렬화
    return await _enqueueWrite(() => _storage.deleteOutOfDate());
  }

  /// 모든 대기 중인 작업이 완료될 때까지 대기
  Future<void> waitForCompletion() async {
    // 대기 중인 읽기 배치 처리
    _readBatchTimer?.cancel();
    if (_pendingReads.isNotEmpty) {
      await _processReadBatch();
    }
    
    if (_writeQueue.isEmpty && 
        !_processingWrites && 
        !_processingReads && 
        _pendingReads.isEmpty) return;
    await _shutdownCompleter?.future;
  }

  /// 내부 스토리지 인스턴스 접근 (필요한 경우)
  JsonSqFliteStorage get storage => _storage;
}

/// 쓰기 작업을 위한 큐 아이템
class _WriteOperation {
  final Completer<void> completer;
  final Future<void> Function() operation;

  _WriteOperation(this.completer, this.operation);
}


