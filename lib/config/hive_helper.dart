import 'dart:convert';

import 'hive_storage.dart';

/// Hive를 사용하는 헬퍼 함수들
class HiveHelper {
  static final HiveStorage _storage = HiveStorage();

  /// String 값 읽기
  static Future<String?> getString(String key) async {
    try {
      final persistedData = await _storage.read(key);
      return persistedData?.data;
    } catch (e) {
      return null;
    }
  }

  /// String 값 쓰기
  static Future<void> setString(String key, String value) async {
    try {
      await _storage.write(key, value);
    } catch (e) {
      // 쓰기 실패는 무시
    }
  }

  /// bool 값 읽기
  static Future<bool> getBool(String key, {bool defaultValue = false}) async {
    try {
      final persistedData = await _storage.read(key);
      if (persistedData == null) return defaultValue;
      final value = persistedData.data;
      return value.toLowerCase() == 'true';
    } catch (e) {
      return defaultValue;
    }
  }

  /// bool 값 쓰기
  static Future<void> setBool(String key, bool value) async {
    try {
      await _storage.write(key, value.toString());
    } catch (e) {
      // 쓰기 실패는 무시
    }
  }

  /// double 값 읽기
  static Future<double?> getDouble(String key) async {
    try {
      final persistedData = await _storage.read(key);
      if (persistedData == null) return null;
      return double.tryParse(persistedData.data);
    } catch (e) {
      return null;
    }
  }

  /// double 값 쓰기
  static Future<void> setDouble(String key, double value) async {
    try {
      await _storage.write(key, value.toString());
    } catch (e) {
      // 쓰기 실패는 무시
    }
  }

  /// JSON 객체 읽기 (List 또는 Map)
  static Future<T?> getJson<T>(String key) async {
    try {
      final persistedData = await _storage.read(key);
      if (persistedData == null || persistedData.data.isEmpty) return null;
      return jsonDecode(persistedData.data) as T;
    } catch (e) {
      return null;
    }
  }

  /// JSON 객체 쓰기
  static Future<void> setJson(String key, dynamic value) async {
    try {
      await _storage.write(key, jsonEncode(value));
    } catch (e) {
      // 쓰기 실패는 무시
    }
  }

  /// 값 삭제
  static Future<void> remove(String key) async {
    try {
      await _storage.remove(key);
    } catch (e) {
      // 삭제 실패는 무시
    }
  }
}
