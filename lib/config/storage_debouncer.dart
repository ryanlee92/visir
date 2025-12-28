import 'dart:async';
import 'package:riverpod_sqflite/riverpod_sqflite.dart';
import 'package:riverpod_annotation/experimental/persist.dart';

/// 쓰기 디바운싱을 처리하는 클래스
/// 
/// 짧은 시간 내 여러 쓰기 요청을 묶어서 배치로 처리하여
/// SQLite 접근 횟수를 줄입니다.
class StorageDebouncer {
  final JsonSqFliteStorage _storage;
  final Map<String, String> _pendingWrites = {};
  Timer? _timer;
  final Duration _debounceDelay;
  final Completer<void>? _flushCompleter;
  
  /// [storage] 대상 스토리지
  /// [debounceDelay] 디바운스 지연 시간 (기본값: 500ms)
  StorageDebouncer(
    this._storage, {
    Duration? debounceDelay,
  }) : _debounceDelay = debounceDelay ?? const Duration(milliseconds: 500),
       _flushCompleter = null;
  
  /// 쓰기 요청을 디바운스합니다
  /// 
  /// [key] 저장할 키
  /// [value] 저장할 값
  /// 
  /// 실제 쓰기는 [debounceDelay] 시간 후에 배치로 수행됩니다.
  void debounceWrite(String key, String value) {
    _pendingWrites[key] = value;
    
    // 기존 타이머 취소
    _timer?.cancel();
    
    // 새 타이머 시작
    _timer = Timer(_debounceDelay, () {
      flush();
    });
  }
  
  /// 대기 중인 모든 쓰기를 즉시 실행합니다
  /// 
  /// 앱 종료 시나 중요한 데이터 저장 시 호출해야 합니다.
  Future<void> flush() async {
    // 타이머 취소
    _timer?.cancel();
    _timer = null;
    
    // 대기 중인 쓰기가 없으면 즉시 반환
    if (_pendingWrites.isEmpty) {
      _flushCompleter?.complete();
      return;
    }
    
    // 현재 대기 중인 쓰기를 복사
    final writesToFlush = Map<String, String>.from(_pendingWrites);
    _pendingWrites.clear();
    
    // 배치로 쓰기 수행 (순차 실행으로 변경하여 잠금 방지)
    try {
      // Future.wait 대신 순차 실행으로 변경하여 동시 접근 방지
      for (final entry in writesToFlush.entries) {
        await _storage.write(entry.key, entry.value, const StorageOptions());
      }
    } catch (e) {
      // 에러 발생 시 대기 중인 쓰기에 다시 추가하지 않음
      // (무한 루프 방지)
    }
    
    _flushCompleter?.complete();
  }
  
  /// 대기 중인 쓰기가 있는지 확인합니다
  bool get hasPendingWrites => _pendingWrites.isNotEmpty;
  
  /// 대기 중인 쓰기 개수를 반환합니다
  int get pendingWriteCount => _pendingWrites.length;
  
  /// 디바운서를 정리합니다
  /// 
  /// 앱 종료 시 호출해야 합니다.
  void dispose() {
    _timer?.cancel();
    _timer = null;
    // dispose 시에는 flush하지 않음 (사용자가 명시적으로 flush 호출 필요)
  }
}

