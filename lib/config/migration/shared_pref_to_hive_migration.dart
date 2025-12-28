import 'package:shared_preferences/shared_preferences.dart';

import '../hive_storage.dart';

/// SharedPreferences에서 Hive로 데이터를 마이그레이션하는 유틸리티
class SharedPrefToHiveMigration {
  static const String _migrationFlagKey = '_hive_migration_completed';

  /// 마이그레이션이 완료되었는지 확인
  static Future<bool> isMigrationCompleted() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_migrationFlagKey) ?? false;
    } catch (e) {
      return false;
    }
  }

  /// 마이그레이션 실행
  static Future<void> migrate() async {
    // 이미 마이그레이션 완료되었으면 스킵
    if (await isMigrationCompleted()) {
      return;
    }

    try {
      // Hive 초기화
      await HiveStorage.initialize();
      final hiveStorage = HiveStorage();

      // SharedPreferences에서 모든 데이터 읽기
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();

      // 마이그레이션할 키 목록 (작은 설정값들)
      final keysToMigrate = [
        'zoom_ratio',
        'window_size_x',
        'window_size_y',
        'window_size_width',
        'window_size_height',
        'desktop_show_sidebar',
        'theme_mode',
        'all_day_panel_expanded',
        'hide_unread_indicator',
        'show_tasks_on_home_tab',
        'text_scaler',
        'inbox_last_create_event_type',
        'show_task_notification',
        'hourly_wage',
        'default_timezone',
        'secondary_timezone',
        'is_message_integration_tutorial_completed',
        'create_task_from_mail_tutorial_done',
        'oauth_disconnected_ignored',
        'last_time_saved_view_type',
        'home_calendar_ratio',
        'hidden_task_colors_on_home_tab',
        'frequently_used_emoji_ids',
      ];

      // tab_hidden_* 키들 마이그레이션
      for (final key in keys) {
        if (key.startsWith('tab_hidden_')) {
          keysToMigrate.add(key);
        }
      }

      // calendar_hide_* 키들 마이그레이션
      for (final key in keys) {
        if (key.startsWith('calendar_hide_')) {
          keysToMigrate.add(key);
        }
      }

      // project_hide_* 키들 마이그레이션
      for (final key in keys) {
        if (key.startsWith('project_hide_')) {
          keysToMigrate.add(key);
        }
      }

      // 각 키를 Hive로 마이그레이션
      for (final key in keysToMigrate) {
        if (!keys.contains(key)) continue;

        try {
          final value = prefs.get(key);
          if (value != null) {
            // 값을 문자열로 변환하여 Hive에 저장
            String stringValue;
            if (value is String) {
              stringValue = value;
            } else if (value is bool) {
              stringValue = value.toString();
            } else if (value is int) {
              stringValue = value.toString();
            } else if (value is double) {
              stringValue = value.toString();
            } else {
              continue; // 지원하지 않는 타입은 스킵
            }

            await hiveStorage.write(key, stringValue);
          }
        } catch (e) {
          // 개별 키 마이그레이션 실패는 무시하고 계속 진행
        }
      }

      // 마이그레이션 완료 플래그 설정
      await prefs.setBool(_migrationFlagKey, true);
    } catch (e) {
      // 마이그레이션 실패는 무시 (앱은 계속 동작)
    }
  }
}
