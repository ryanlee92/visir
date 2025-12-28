import 'package:Visir/features/calendar/infrastructure/repositories/calendar_repository.dart';
import 'package:Visir/features/calendar/providers.dart';
import 'package:Visir/features/preference/application/local_pref_controller.dart';
import 'package:Visir/features/preference/domain/entities/oauth_entity.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'calendar_integration_list_controller.g.dart';

@riverpod
class CalendarIntegrationListController extends _$CalendarIntegrationListController {
  late CalendarRepository _repository;

  @override
  AsyncValue<List<OAuthEntity>> build() {
    final _calendarOAuths = ref.watch(localPrefControllerProvider.select((e) => e.value?.calendarOAuths ?? []));
    _repository = ref.watch(calendarRepositoryProvider);
    return AsyncData([..._calendarOAuths]);
  }

  Future<bool> integrate({required OAuthType type}) async {
    final result = await _repository.integrate(type: type);
    return result.fold((l) => false, (r) async {
      final _calendarOAuths = ref.read(localPrefControllerProvider.select((e) => e.value?.calendarOAuths ?? []));

      List<OAuthEntity> newOAuths = [..._calendarOAuths];
      newOAuths.removeWhere((o) => o.email == r.email && o.type == r.type);
      newOAuths.add(r);
      await ref.read(localPrefControllerProvider.notifier).set(calendarOAuths: newOAuths);
      state = AsyncData(newOAuths);
      return true;
    });
  }

  Future<void> unintegrate({required OAuthEntity oauth}) async {
    var _calendarOAuths = ref.read(localPrefControllerProvider.select((e) => e.value?.calendarOAuths ?? []));

    List<OAuthEntity> newOAuths = [..._calendarOAuths];
    newOAuths.removeWhere((o) => (o.email == oauth.email && o.type == oauth.type));
    await ref.read(localPrefControllerProvider.notifier).set(calendarOAuths: newOAuths);
    state = AsyncData(newOAuths);
  }
}
