import 'dart:async';

import 'package:Visir/features/chat/infrastructure/repositories/message_repository.dart';
import 'package:Visir/features/chat/providers.dart';
import 'package:Visir/features/preference/application/local_pref_controller.dart';
import 'package:Visir/features/preference/domain/entities/oauth_entity.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'messenger_integration_list_controller.g.dart';

@riverpod
class MessengerIntegrationListController extends _$MessengerIntegrationListController {
  late ChatRepository _repository;

  @override
  AsyncValue<List<OAuthEntity>> build() {
    final _chatOAuths = ref.watch(localPrefControllerProvider.select((e) => e.value?.messengerOAuths ?? []));
    _repository = ref.watch(chatRepositoryProvider);
    return AsyncData([..._chatOAuths]);
  }

  Future<bool> integrate({required OAuthType type}) async {
    final _chatOAuths = ref.read(localPrefControllerProvider.select((e) => e.value?.messengerOAuths ?? []));
    final result = await _repository.integrate(type: type);

    return await result.fold((l) async => false, (r) async {
      List<OAuthEntity> newOAuths = [..._chatOAuths];
      newOAuths.removeWhere((o) => o.email == r.email && o.type == r.type && o.teamId == r.teamId);
      newOAuths.removeWhere((o) => o.team == null);
      newOAuths.add(r);
      await ref.read(localPrefControllerProvider.notifier).set(messengerOAuths: newOAuths);
      state = AsyncData(newOAuths);
      return true;
    });
  }

  Future<void> unintegrate({required OAuthEntity oauth}) async {
    final _chatOAuths = ref.read(localPrefControllerProvider.select((e) => e.value?.messengerOAuths ?? []));
    List<OAuthEntity> newOAuths = [..._chatOAuths];
    newOAuths.removeWhere((o) => (o.email == oauth.email && o.type == oauth.type && o.teamId == oauth.teamId));
    await ref.read(localPrefControllerProvider.notifier).set(messengerOAuths: newOAuths);
    state = AsyncData(newOAuths);
  }
}
