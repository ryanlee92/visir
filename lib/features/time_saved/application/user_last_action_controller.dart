import 'package:Visir/features/auth/application/auth_controller.dart';
import 'package:Visir/features/preference/application/local_pref_controller.dart';
import 'package:Visir/features/time_saved/domain/entities/user_action_entity.dart';
import 'package:Visir/features/time_saved/infrastructure/repositories/user_last_action_repository.dart';
import 'package:Visir/features/time_saved/providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'user_last_action_controller.g.dart';

@riverpod
class UserLastActionController extends _$UserLastActionController {
  late UserLastActionRepository _repository;

  @override
  AsyncValue<UserActionEntity?> build() {
    _repository = ref.watch(userLastActionRepositoryProvider);
    fetchLastUserAction();
    attachListener();
    return AsyncData(null);
  }

  Future<void> fetchLastUserAction() async {
    final _pref = ref.read(localPrefControllerProvider).value;
    final user = ref.read(authControllerProvider).requireValue;
    if (!user.isSignedIn) return;
    if (_pref == null) return;

    final result = await _repository.fetchLastUserAction(userId: user.id);

    return result.fold((l) {}, (r) {
      state = AsyncData(r);
    });
  }

  Future<void> attachListener() async {
    final _pref = ref.read(localPrefControllerProvider).value;
    final user = ref.read(authControllerProvider).requireValue;
    if (!user.isSignedIn) return;
    if (_pref == null) return;

    await _repository.attachListener(
      userId: user.id,
      onUpdate: (UserActionEntity action) {
        state = AsyncData(action);
      },
    );
  }

  Future<void> saveUserLastAction({required UserActionEntity lastAction}) async {
    final _pref = ref.read(localPrefControllerProvider).value;
    final user = ref.read(authControllerProvider).requireValue;
    if (!user.isSignedIn) return;
    if (_pref == null) return;

    final prevState = state.value;
    state = AsyncData(lastAction);

    final result = await _repository.saveLastUserAction(userId: user.id, lastAction: lastAction);

    return result.fold((l) {
      state = AsyncData(prevState);
    }, (r) {});
  }
}
