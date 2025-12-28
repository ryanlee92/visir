import 'package:Visir/features/mail/infrastructure/repositories/mail_repository.dart';
import 'package:Visir/features/mail/providers.dart';
import 'package:Visir/features/preference/application/local_pref_controller.dart';
import 'package:Visir/features/preference/domain/entities/oauth_entity.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'mail_integration_list_controller.g.dart';

@riverpod
class MailIntegrationListController extends _$MailIntegrationListController {
  late MailRepository _repository;

  @override
  AsyncValue<List<OAuthEntity>> build() {
    final _mailOAuths = ref.watch(localPrefControllerProvider.select((e) => e.value?.mailOAuths ?? []));
    _repository = ref.watch(mailRepositoryProvider);
    return AsyncData([..._mailOAuths]);
  }

  Future<OAuthEntity?> integrate({required OAuthType type}) async {
    final result = await _repository.integrate(type: type);
    return result.fold((l) => null, (r) async {
      final _mailOAuths = ref.read(localPrefControllerProvider.select((e) => e.value?.mailOAuths ?? []));

      List<OAuthEntity> newOAuths = [..._mailOAuths];
      newOAuths.removeWhere((o) => o.email == r.email && o.type == r.type);
      newOAuths.add(r);
      await ref.read(localPrefControllerProvider.notifier).set(mailOAuths: newOAuths);

      state = AsyncData(newOAuths);
      return r;
    });
  }

  Future<List<OAuthEntity>?> unintegrate({required OAuthEntity oauth}) async {
    final _mailOAuths = ref.read(localPrefControllerProvider.select((e) => e.value?.mailOAuths ?? []));

    List<OAuthEntity> newOAuths = [..._mailOAuths];
    newOAuths.removeWhere((o) => (o.email == oauth.email && o.type == oauth.type));
    await ref.read(localPrefControllerProvider.notifier).set(mailOAuths: newOAuths);

    state = AsyncData(newOAuths);
    return newOAuths.toList();
  }

  Future<List<String>> fetchSignature({required OAuthEntity oauth}) async {
    final result = await _repository.fetchSignature(oauth: oauth);
    return result.fold((l) => [], (r) async {
      return r;
    });
  }
}
