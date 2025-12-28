import 'package:Visir/features/time_saved/domain/entities/user_action_switch_count_entity.dart';
import 'package:Visir/features/time_saved/domain/entities/user_action_switch_entity.dart';

abstract class UserActionSwitchDatasource {
  Future<void> saveUserActionSwitch({
    required UserActionSwitchEntity userActionSwitch,
  });

  Future<List<UserActionSwitchCountEntity>> fetchUserActionSwitchList({
    required String userId,
    required DateTime createdAtAfter,
    DateTime? lastItemCreatedAt,
  });

  Future<void> cacheUserActionSwtichList({
    required List<UserActionSwitchCountEntity> list,
  });

  Future<Map<DateTime, List<UserActionSwitchCountEntity>>> fetchUserActionSwitchListByDate({
    required String userId,
    required DateTime createdAtAfter,
  });

  Future<void> cacheUserActionSwitchListByDate({
    required Map<DateTime, List<UserActionSwitchCountEntity>> list,
  });
}
