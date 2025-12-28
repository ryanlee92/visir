import 'package:Visir/features/common/domain/failures/failure.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/preference/domain/entities/local_pref_entity.dart';
import 'package:Visir/features/preference/domain/entities/oauth_entity.dart';
import 'package:Visir/features/time_saved/domain/datasources/user_action_switch_datasource.dart';
import 'package:Visir/features/time_saved/domain/entities/user_action_switch_count_entity.dart';
import 'package:Visir/features/time_saved/domain/entities/user_action_switch_entity.dart';
import 'package:fpdart/fpdart.dart';

class UserActionSwitchRepository {
  final Map<DatasourceType, UserActionSwitchDatasource> datasources;

  List<DatasourceType> get remoteDatasourceTypes => DatasourceType.values;

  UserActionSwitchRepository({required this.datasources});

  Future<Either<Failure, List<UserActionSwitchCountEntity>>> fetchUserActionSwitchList({
    required LocalPrefEntity pref,
    required String userId,
    required DateTime createdAtAfter,
    DateTime? lastItemCreatedAt,
    bool? fetchLocal,
  }) async {
    try {
      final list = remoteDatasourceTypes
          .map((d) => datasources[d]?.fetchUserActionSwitchList(
                userId: userId,
                createdAtAfter: createdAtAfter,
                lastItemCreatedAt: lastItemCreatedAt,
              ))
          .whereType<Future<List<UserActionSwitchCountEntity>>>();
      final result = await Future.wait(list);

      return right(result.fold([], (map1, map2) => [...map1, ...map2]));
    } catch (e) {
      return Utils.debugLeft(e);
    }
  }

  Future<void> cacheUserActionSwitchList({required List<UserActionSwitchCountEntity> list}) async {
    // Local caching removed - use persist or shared_preferences if needed
  }

  Future<Either<Failure, UserActionSwitchEntity>> saveUserActionSwitch({required UserActionSwitchEntity userActionSwitch}) async {
    try {
      final list = remoteDatasourceTypes
          .map((d) => datasources[d]?.saveUserActionSwitch(userActionSwitch: userActionSwitch))
          .whereType<Future<UserActionSwitchEntity>>();
      await Future.wait(list);
      return right(userActionSwitch);
    } catch (e) {
      return Utils.debugLeft(e);
    }
  }

  Future<Either<Failure, Map<DateTime, List<UserActionSwitchCountEntity>>>> fetchUserActionSwitchListByDate({
    required String userId,
    required DateTime createdAtAfter,
    bool? fetchLocal,
  }) async {
    try {
      final list = remoteDatasourceTypes
          .map((d) => datasources[d]?.fetchUserActionSwitchListByDate(
                userId: userId,
                createdAtAfter: createdAtAfter,
              ))
          .whereType<Future<Map<DateTime, List<UserActionSwitchCountEntity>>>>();

      final result = await Future.wait(list);

      return right(result.fold({}, (map1, map2) => {...map1, ...map2}));
    } catch (e) {
      return Utils.debugLeft(e);
    }
  }

  Future<void> cacheUserActionSwitchListByDate({required Map<DateTime, List<UserActionSwitchCountEntity>> list}) async {
    // Local caching removed - use persist or shared_preferences if needed
  }
}
