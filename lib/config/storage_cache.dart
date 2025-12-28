import 'dart:collection';

/// 메모리 캐시 아이템
class _CachedItem {
  final String value;
  final DateTime timestamp;
  
  _CachedItem(this.value, this.timestamp);
}

/// LRU 캐시 전략을 사용하는 메모리 캐시
class StorageCache {
  final LinkedHashMap<String, _CachedItem> _cache = LinkedHashMap();
  final int maxSize;
  final Duration? maxAge;
  
  /// [maxSize] 최대 캐시 크기 (기본값: 100)
  /// [maxAge] 캐시 아이템의 최대 유지 시간 (null이면 무제한)
  StorageCache({
    this.maxSize = 100,
    this.maxAge,
  });
  
  /// 캐시에서 값을 가져옵니다
  String? get(String key) {
    final item = _cache[key];
    if (item == null) return null;
    
    // 만료 시간 확인
    if (maxAge != null) {
      final age = DateTime.now().difference(item.timestamp);
      if (age > maxAge!) {
        _cache.remove(key);
        return null;
      }
    }
    
    // LRU: 접근한 아이템을 맨 뒤로 이동
    _cache.remove(key);
    _cache[key] = item;
    
    return item.value;
  }
  
  /// 캐시에 값을 저장합니다
  void put(String key, String value) {
    // 이미 존재하는 경우 업데이트
    if (_cache.containsKey(key)) {
      _cache.remove(key);
    }
    // 최대 크기 초과 시 가장 오래된 항목 제거 (LRU)
    else if (_cache.length >= maxSize) {
      final firstKey = _cache.keys.first;
      _cache.remove(firstKey);
    }
    
    _cache[key] = _CachedItem(value, DateTime.now());
  }
  
  /// 특정 키를 캐시에서 제거합니다
  void invalidate(String key) {
    _cache.remove(key);
  }
  
  /// 특정 접두사로 시작하는 모든 키를 캐시에서 제거합니다
  void invalidatePrefix(String prefix) {
    final keysToRemove = _cache.keys
        .where((key) => key.startsWith(prefix))
        .toList();
    for (final key in keysToRemove) {
      _cache.remove(key);
    }
  }
  
  /// 모든 캐시를 제거합니다
  void clear() {
    _cache.clear();
  }
  
  /// 현재 캐시 크기를 반환합니다
  int get size => _cache.length;
  
  /// 캐시가 비어있는지 확인합니다
  bool get isEmpty => _cache.isEmpty;
  
  /// 캐시가 비어있지 않은지 확인합니다
  bool get isNotEmpty => _cache.isNotEmpty;
}

