import 'package:Visir/features/common/domain/failures/failure.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/preference/domain/entities/oauth_entity.dart';
import 'package:Visir/features/time_saved/domain/datasources/user_last_action_datasource.dart';
import 'package:Visir/features/time_saved/domain/entities/user_action_entity.dart';
import 'package:Visir/features/time_saved/domain/entities/user_action_switch_entity.dart';
import 'package:fpdart/fpdart.dart';

class UserLastActionRepository {
  final Map<DatasourceType, UserLastActionDatasource> datasources;

  List<DatasourceType> get remoteDatasourceTypes => DatasourceType.values;

  UserLastActionRepository({required this.datasources});

  Future<Either<Failure, UserActionEntity?>> fetchLastUserAction({required String userId}) async {
    try {
      final list = remoteDatasourceTypes.map((d) => datasources[d]?.fetchLastUserAction(userId: userId)).whereType<Future<UserActionEntity?>>();
      final result = await Future.wait(list).then((value) {
        return value;
      });
      return right(result.firstOrNull);
    } catch (e) {
      return Utils.debugLeft(e);
    }
  }

  Future<Either<Failure, void>> attachListener({
    required String userId,
    required void Function(UserActionEntity action) onUpdate,
  }) async {
    try {
      final list =
          remoteDatasourceTypes.map((d) => datasources[d]?.attachListener(userId: userId, onUpdate: onUpdate)).whereType<Future<UserActionSwitchEntity>>();
      await Future.wait(list);
      return right(null);
    } catch (e) {
      return Utils.debugLeft(e);
    }
  }

  Future<Either<Failure, UserActionEntity>> saveLastUserAction({required String userId, required UserActionEntity lastAction}) async {
    try {
      final list = remoteDatasourceTypes
          .map((d) => datasources[d]?.saveLastUserAction(userId: userId, lastAction: lastAction))
          .whereType<Future<UserActionSwitchEntity>>();
      await Future.wait(list);
      return right(lastAction);
    } catch (e) {
      return Utils.debugLeft(e);
    }
  }
}
