import 'package:Visir/features/time_saved/domain/entities/user_action_entity.dart';

abstract class UserLastActionDatasource {
  Future<void> attachListener({required String userId, required Function(UserActionEntity) onUpdate});

  Future<void> saveLastUserAction({
    required String userId,
    required UserActionEntity lastAction,
  });

  Future<UserActionEntity?> fetchLastUserAction({required String userId});
}
