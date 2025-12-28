import 'dart:async';
import 'dart:convert';

import 'package:Visir/config/providers.dart';
import 'package:Visir/features/auth/application/auth_controller.dart';
import 'package:Visir/features/common/domain/failures/failure.dart';
import 'package:Visir/features/common/presentation/utils/extensions/list_extension.dart';
import 'package:Visir/features/common/provider.dart';
import 'package:Visir/features/mail/domain/entities/mail_entity.dart';
import 'package:Visir/features/mail/domain/entities/mail_label_entity.dart';
import 'package:Visir/features/mail/infrastructure/models/outlook_mail_message.dart';
import 'package:Visir/features/mail/infrastructure/repositories/mail_repository.dart';
import 'package:Visir/features/mail/providers.dart';
import 'package:Visir/features/preference/application/local_pref_controller.dart';
import 'package:Visir/features/preference/domain/entities/oauth_entity.dart';
import 'package:collection/collection.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:googleapis/gmail/v1.dart' as Gmail;
import 'package:riverpod_annotation/experimental/persist.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'mail_thread_list_controller.g.dart';

@riverpod
class MailThreadListController extends _$MailThreadListController {
  static final String Function(TabType tabType) stringKey = (tabType) => '${tabType.name}:mail_threads';

  late OAuthEntity _oauth;
  late MailThreadListControllerInternal _controller;

  @override
  List<MailEntity> build({required TabType tabType}) {
    final isSignedIn = ref.watch(authControllerProvider.select((v) => v.requireValue.isSignedIn));
    final label = ref.watch(mailConditionProvider(tabType).select((v) => v.label));
    final threadId = ref.watch(mailConditionProvider(tabType).select((v) => v.threadId));
    final threadEmail = ref.watch(mailConditionProvider(tabType).select((v) => v.threadEmail));
    final type = ref.watch(mailConditionProvider(tabType).select((v) => v.type));
    final threads = ref.watch(mailConditionProvider(tabType).select((v) => v.threads));

    if (type == null) return [];
    if (threadEmail == null) return [];
    if (threadId == null) return [];

    ref.watch(
      localPrefControllerProvider.select((v) {
        final uniqueIds = v.value?.mailOAuths?.map((e) => e.uniqueId).toList() ?? [];
        uniqueIds.sort();
        return uniqueIds.join(',');
      }),
    );

    _oauth = ref.read(localPrefControllerProvider.select((v) => v.value?.mailOAuths?.firstWhereOrNull((e) => e.email == threadEmail)))!;

    _controller = ref.watch(
      mailThreadListControllerInternalProvider(
        isSignedIn: isSignedIn,
        type: type,
        label: label,
        email: threadEmail,
        threadId: threadId,
        threads: threads,
        oAuthUniqueId: _oauth.uniqueId,
      ).notifier,
    );

    ref.listen(
      mailThreadListControllerInternalProvider(
        isSignedIn: isSignedIn,
        type: type,
        label: label,
        email: threadEmail,
        threadId: threadId,
        threads: threads,
        oAuthUniqueId: _oauth.uniqueId,
      ).select((v) => v.value ?? []),
      (previous, next) {
        updateState(next);
      },
    );

    SchedulerBinding.instance.addPostFrameCallback((_) {
      loadThread();
    });

    return [];
  }

  Timer? timer;
  void updateState(List<MailEntity> data) {
    if (timer == null) state = data;
    timer?.cancel();
    timer = Timer(const Duration(milliseconds: kControllerDebouncMillisecond), () {
      state = data;
      timer = null;
    });
  }

  Future<void> loadThread() async {
    return _controller.loadThread();
  }

  Future<void> read({required List<String> threadIds, required TabType targetTab}) async {
    return _controller.read(threadIds: threadIds, targetTab: targetTab);
  }

  Future<void> unread({required List<String> threadIds, required TabType targetTab}) async {
    return _controller.unread(threadIds: threadIds, targetTab: targetTab);
  }

  Future<void> pin({required List<String> threadIds, required TabType targetTab}) async {
    return _controller.pin(threadIds: threadIds, targetTab: targetTab);
  }

  Future<void> unpin({required List<String> threadIds, required TabType targetTab}) async {
    return _controller.unpin(threadIds: threadIds, targetTab: targetTab);
  }

  Future<void> archive({required List<String> threadIds, required TabType targetTab}) async {
    return _controller.archive(threadIds: threadIds, targetTab: targetTab);
  }

  Future<void> unarchive({required List<String> threadIds, required TabType targetTab}) async {
    return _controller.unarchive(threadIds: threadIds, targetTab: targetTab);
  }

  Future<void> trash({required List<String> threadIds, required TabType targetTab}) async {
    return _controller.trash(threadIds: threadIds, targetTab: targetTab);
  }

  Future<void> untrash({required List<String> threadIds, required TabType targetTab}) async {
    return _controller.untrash(threadIds: threadIds, targetTab: targetTab);
  }

  Future<void> spam({required List<String> threadIds, required TabType targetTab}) async {
    return _controller.spam(threadIds: threadIds, targetTab: targetTab);
  }

  Future<void> unspam({required List<String> threadIds, required TabType targetTab}) async {
    return _controller.unspam(threadIds: threadIds, targetTab: targetTab);
  }

  Future<void> delete({required List<String> threadIds, required TabType targetTab}) async {
    return _controller.delete(threadIds: threadIds, targetTab: targetTab);
  }

  void addMailLocal(MailEntity mail) {
    return _controller.addMailLocal(mail);
  }

  void removeMailLocal(String mailId) {
    return _controller.removeMailLocal(mailId);
  }

  void addLabelsLocal(List<String> threadIds, List<String> addLabelIds) {
    return _controller.addLabelsLocal(threadIds, addLabelIds);
  }

  void removeLabelsLocal(List<String> threadIds, List<String> removeLabelIds) {
    return _controller.removeLabelsLocal(threadIds, removeLabelIds);
  }

  Future<Map<String, Uint8List?>> fetchAttachments({required MailEntity mail, required List<String> attachmentIds}) async {
    return _controller.fetchAttachments(mail: mail, attachmentIds: attachmentIds);
  }
}

@riverpod
class MailThreadListControllerInternal extends _$MailThreadListControllerInternal {
  String? get threadEmail => email;
  late MailRepository _repository;

  List<MailEntity> get threads => [...(state.value ?? [])];
  OAuthEntity get _oauth => ref.read(localPrefControllerProvider.select((v) => v.value?.mailOAuths?.firstWhereOrNull((e) => e.uniqueId == oAuthUniqueId)))!;

  @override
  Future<List<MailEntity>> build({
    required bool isSignedIn,
    required MailEntityType type,
    required String label,
    required String email,
    required String threadId,
    List<MailEntity>? threads,
    required String oAuthUniqueId,
  }) async {
    _repository = ref.watch(mailRepositoryProvider);

    if (ref.watch(shouldUseMockDataProvider)) {
      loadThreadMock();
      return [];
    }

    if (!ref.watch(shouldUseMockDataProvider)) {
      final userId = ref.watch(authControllerProvider.select((value) => value.requireValue.id));

      await persist(
        ref.watch(storageProvider.future),
        key: '${MailThreadListController.stringKey(TabType.mail)}:${isSignedIn}:${label}:${email}:${threadId}:${oAuthUniqueId}',
        encode: (List<MailEntity> state) => jsonEncode(state.map((e) => e.toJson()).toList()),
        decode: (String encoded) {
          final trimmed = encoded.trim();
          if (trimmed.isEmpty || trimmed == 'null') {
            return [];
          }
          return (jsonDecode(trimmed) as List<dynamic>).map((e) => MailEntity.fromJson(e as Map<String, dynamic>)).toList();
        },
        options: StorageOptions(destroyKey: userId),
      ).future;
    }

    return state.value ?? threads ?? [];
  }

  Future<void> loadThreadMock() async {
    if (type == MailEntityType.google) {
      rootBundle.loadString('assets/mock/mail/gmail/threads/$threadId.json').then((value) {
        final data = jsonDecode(value);
        final threads = data['messages'].map((e) => MailEntity.fromGmail(message: Gmail.Message.fromJson(e), hostEmail: email)).whereType<MailEntity>().toList();
        _updateState(threads);
      });
    } else if (type == MailEntityType.microsoft) {
      rootBundle.loadString('assets/mock/mail/outlook/threads/$threadId.json').then((value) {
        final data = jsonDecode(value);
        final threads = data['messages'].map((e) => MailEntity.fromOutlook(message: OutlookMailMessage.fromJson(e), hostEmail: email)).whereType<MailEntity>().toList();
        _updateState(threads);
      });
    }
  }

  void _updateState(List<MailEntity> data) {
    data = data.unique((e) => e.id)..sort((a, b) => (a.date ?? DateTime.now()).compareTo(b.date ?? DateTime.now()));
    state = AsyncData(data);
  }

  Future<void> loadThread() async {
    if (!isSignedIn) {
      loadThreadMock();
      return;
    }

    final _pref = ref.read(localPrefControllerProvider).value;
    if (_pref == null) throw Failure.unauthorized(StackTrace.current);

    final result = await _repository.fetchThreads(oauth: _oauth, type: type, threadId: threadId, email: email, labelId: label);

    result.fold((l) {}, (r) {
      _updateState(r..sort((a, b) => (a.date ?? DateTime.now()).compareTo(b.date ?? DateTime.now())));
    });
  }

  Future<void> read({required List<String> threadIds, required TabType targetTab}) async {
    final _pref = ref.read(localPrefControllerProvider).value;
    if (_pref == null) throw Failure.unauthorized(StackTrace.current);
    removeLabelsLocal(threadIds, [CommonMailLabels.unread.id]);
  }

  Future<void> unread({required List<String> threadIds, required TabType targetTab}) async {
    final _pref = ref.read(localPrefControllerProvider).value;
    if (_pref == null) throw Failure.unauthorized(StackTrace.current);
    addLabelsLocal(threadIds, [CommonMailLabels.unread.id]);
  }

  Future<void> pin({required List<String> threadIds, required TabType targetTab}) async {
    final _pref = ref.read(localPrefControllerProvider).value;
    if (_pref == null) throw Failure.unauthorized(StackTrace.current);
    addLabelsLocal(threadIds, [CommonMailLabels.pinned.id]);
  }

  Future<void> unpin({required List<String> threadIds, required TabType targetTab}) async {
    final _pref = ref.read(localPrefControllerProvider).value;
    if (_pref == null) throw Failure.unauthorized(StackTrace.current);
    removeLabelsLocal(threadIds, [CommonMailLabels.pinned.id]);
  }

  Future<void> archive({required List<String> threadIds, required TabType targetTab}) async {
    final _pref = ref.read(localPrefControllerProvider).value;
    if (_pref == null) throw Failure.unauthorized(StackTrace.current);
    removeLabelsLocal(threadIds, [CommonMailLabels.inbox.id]);
  }

  Future<void> unarchive({required List<String> threadIds, required TabType targetTab}) async {
    final _pref = ref.read(localPrefControllerProvider).value;
    if (_pref == null) throw Failure.unauthorized(StackTrace.current);
    addLabelsLocal(threadIds, [CommonMailLabels.inbox.id]);
  }

  Future<void> trash({required List<String> threadIds, required TabType targetTab}) async {
    final _pref = ref.read(localPrefControllerProvider).value;
    if (_pref == null) throw Failure.unauthorized(StackTrace.current);
    addLabelsLocal(threadIds, [CommonMailLabels.trash.id]);
  }

  Future<void> untrash({required List<String> threadIds, required TabType targetTab}) async {
    final _pref = ref.read(localPrefControllerProvider).value;
    if (_pref == null) throw Failure.unauthorized(StackTrace.current);
    removeLabelsLocal(threadIds, [CommonMailLabels.trash.id]);
  }

  Future<void> spam({required List<String> threadIds, required TabType targetTab}) async {
    final _pref = ref.read(localPrefControllerProvider).value;
    if (_pref == null) throw Failure.unauthorized(StackTrace.current);
    addLabelsLocal(threadIds, [CommonMailLabels.spam.id]);
  }

  Future<void> unspam({required List<String> threadIds, required TabType targetTab}) async {
    final _pref = ref.read(localPrefControllerProvider).value;
    if (_pref == null) throw Failure.unauthorized(StackTrace.current);
    removeLabelsLocal(threadIds, [CommonMailLabels.spam.id]);
  }

  Future<void> delete({required List<String> threadIds, required TabType targetTab}) async {
    final _pref = ref.read(localPrefControllerProvider).value;
    if (_pref == null) throw Failure.unauthorized(StackTrace.current);
    state = AsyncData([]);
  }

  void addMailLocal(MailEntity mail) {
    final threadId = state.value?.firstOrNull?.threadId;
    if (threadId == mail.threadId) {
      _updateState(
        (state.value ?? [])
          ..removeWhere((e) => e.id == mail.id)
          ..add(mail),
      );
    }
  }

  void removeMailLocal(String mailId) {
    final _mails = state.value;
    if (_mails != null) {
      final _index = _mails.indexWhere((element) => element.id == mailId);
      if (_index != -1) {
        _updateState(_mails..removeAt(_index));
      }
    }
  }

  void addLabelsLocal(List<String> threadIds, List<String> addLabelIds) {
    if (!threadIds.contains(threadId)) return;
    final _mails = state.value;
    if (_mails != null) {
      _updateState((_mails.map((e) => e.copyWith(labelIds: ([...(e.labelIds ?? []), ...addLabelIds])..sort((a, b) => a.compareTo(b)))).toList()).toList());
    }
  }

  void removeLabelsLocal(List<String> threadIds, List<String> removeLabelIds) {
    if (!threadIds.contains(threadId)) return;
    final _mails = state.value;
    if (_mails != null) {
      _updateState(
        (_mails.map((e) => e.copyWith(labelIds: ((e.labelIds ?? [])..removeWhere((e) => removeLabelIds.contains(e)))..sort((a, b) => a.compareTo(b)))).toList()).toList(),
      );
    }
  }

  Future<Map<String, Uint8List?>> fetchAttachments({required MailEntity mail, required List<String> attachmentIds}) async {
    final _pref = ref.read(localPrefControllerProvider).value;
    if (_pref == null) throw Failure.unauthorized(StackTrace.current);
    if (ref.read(shouldUseMockDataProvider)) return {};
    final result = await _repository.fetchAttachments(email: mail.hostEmail, messageId: mail.id!, oauth: _oauth, attachmentIds: attachmentIds);
    return result.fold((l) => {}, (r) => r);
  }
}
