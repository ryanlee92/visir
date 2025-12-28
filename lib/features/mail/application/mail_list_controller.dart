import 'dart:async';
import 'dart:convert';

import 'package:Visir/config/providers.dart';
import 'package:Visir/features/auth/application/auth_controller.dart';
import 'package:Visir/features/common/domain/entities/linked_item_entity.dart';
import 'package:Visir/features/common/presentation/utils/constants.dart';
import 'package:Visir/features/common/presentation/utils/extensions/list_extension.dart';
import 'package:Visir/features/common/provider.dart';
import 'package:Visir/features/mail/domain/entities/mail_entity.dart';
import 'package:Visir/features/mail/domain/entities/mail_fetch_result_entity.dart';
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
import 'package:googleapis/gmail/v1.dart';
import 'package:riverpod_annotation/experimental/persist.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'mail_list_controller.g.dart';

enum LocalUpdateType { updateLabel, removeMail, addMail }

@riverpod
class MailListController extends _$MailListController {
  static final String stringKey = '${TabType.mail.name}:mail_list';

  late List<OAuthEntity> mailOAuths;
  Map<String, MailListControllerInternal> _controllers = {};

  @override
  MailListResultEntity build() {
    final isSignedIn = ref.watch(authControllerProvider.select((v) => v.requireValue.isSignedIn));
    final label = ref.watch(mailConditionProvider(TabType.mail).select((v) => v.label));
    final email = ref.watch(mailConditionProvider(TabType.mail).select((v) => v.email));
    final query = ref.watch(mailConditionProvider(TabType.mail).select((v) => v.query));

    MailListResultEntity data = MailListResultEntity(mails: {}, email: email, label: label);

    ref.watch(
      localPrefControllerProvider.select((v) {
        final uniqueIds = v.value?.mailOAuths?.map((e) => e.uniqueId).toList() ?? [];
        uniqueIds.sort();
        return uniqueIds.join(',');
      }),
    );
    mailOAuths = ref.read(
      localPrefControllerProvider.select(
        (v) =>
            v.value?.mailOAuths?.where((e) {
              if (email == null) return true;
              return e.email == email;
            }).toList() ??
            [],
      ),
    );

    _controllers.clear();

    mailOAuths.forEach((e) {
      _controllers[e.uniqueId] = ref.watch(
        mailListControllerInternalProvider(isSignedIn: isSignedIn, label: label, email: e.email, query: query, oAuthUniqueId: e.uniqueId).notifier,
      );
      ref.listen(mailListControllerInternalProvider(isSignedIn: isSignedIn, label: label, email: e.email, query: query, oAuthUniqueId: e.uniqueId).select((v) => v.value), (
        previous,
        next,
      ) {
        data = MailListResultEntity(mails: {...data.mails, ...(next?.mails ?? {})}, email: email, label: label);
        updateState(data);
      });
    });

    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      refresh();
    });

    return data;
  }

  Timer? timer;
  void updateState(MailListResultEntity data) {
    if (timer == null) state = data;
    timer?.cancel();
    timer = Timer(const Duration(milliseconds: kControllerDebouncMillisecond), () {
      state = data;
      timer = null;
    });
  }

  bool get isAbleToLoadMore {
    return _controllers.values.where((e) => e.isAbleToLoadMore).isNotEmpty;
  }

  Future<void> refresh() async {
    Completer<void> completer = Completer();
    int resultCount = 0;
    ref.read(loadingStatusProvider.notifier).update(stringKey, LoadingState.loading);
    _controllers.forEach((key, value) {
      value
          .refresh()
          .then((value) {
            resultCount++;
            if (resultCount != _controllers.length) return;
            ref.read(loadingStatusProvider.notifier).update(stringKey, LoadingState.success);
            completer.complete();
          })
          .catchError((error) {
            resultCount++;
            if (resultCount != _controllers.length) return;
            ref.read(loadingStatusProvider.notifier).update(stringKey, LoadingState.error);
            completer.complete();
          });
    });
    return completer.future;
  }

  Future<void> loadMore() async {
    Completer<void> completer = Completer();
    int resultCount = 0;
    ref.read(loadingStatusProvider.notifier).update(stringKey, LoadingState.loading);
    _controllers.forEach((key, value) {
      value
          .loadMore()
          .then((value) {
            resultCount++;
            if (resultCount != _controllers.length) return;
            ref.read(loadingStatusProvider.notifier).update(stringKey, LoadingState.success);
            completer.complete();
          })
          .catchError((error) {
            resultCount++;
            if (resultCount != _controllers.length) return;
            ref.read(loadingStatusProvider.notifier).update(stringKey, LoadingState.error);
            completer.complete();
          });
    });
    return completer.future;
  }

  Future<void> search({required bool loadMore}) async {
    Completer<void> completer = Completer();
    int resultCount = 0;
    ref.read(loadingStatusProvider.notifier).update(stringKey, LoadingState.loading);
    _controllers.forEach((key, value) {
      value
          .search(loadMore: loadMore)
          .then((value) {
            resultCount++;
            if (resultCount != _controllers.length) return;
            ref.read(loadingStatusProvider.notifier).update(stringKey, LoadingState.success);
            completer.complete();
          })
          .catchError((error) {
            resultCount++;
            if (resultCount != _controllers.length) return;
            ref.read(loadingStatusProvider.notifier).update(stringKey, LoadingState.error);
            completer.complete();
          });
    });
    return completer.future;
  }

  Future<void> loadRecent() async {
    Completer<void> completer = Completer();
    int resultCount = 0;
    ref.read(loadingStatusProvider.notifier).update(stringKey, LoadingState.loading);
    _controllers.forEach((key, value) {
      value
          .loadRecent()
          .then((value) {
            resultCount++;
            if (resultCount != _controllers.length) return;
            ref.read(loadingStatusProvider.notifier).update(stringKey, LoadingState.success);
            completer.complete();
          })
          .catchError((error) {
            resultCount++;
            if (resultCount != _controllers.length) return;
            ref.read(loadingStatusProvider.notifier).update(stringKey, LoadingState.error);
            completer.complete();
          });
    });
    return completer.future;
  }

  Future<void> load({bool? refresh}) async {
    Completer<void> completer = Completer();
    int resultCount = 0;
    ref.read(loadingStatusProvider.notifier).update(stringKey, LoadingState.loading);
    _controllers.forEach((key, value) {
      value
          .load(refresh: refresh)
          .then((value) {
            resultCount++;
            if (resultCount != _controllers.length) return;
            ref.read(loadingStatusProvider.notifier).update(stringKey, LoadingState.success);
            completer.complete();
          })
          .catchError((error) {
            resultCount++;
            if (resultCount != _controllers.length) return;
            ref.read(loadingStatusProvider.notifier).update(stringKey, LoadingState.error);
            completer.complete();
          });
    });
    return completer.future;
  }

  Future<Map<String, Uint8List?>?> fetchAttachments({required String email, required String messageId, required MailEntityType type, required List<String> attachmentIds}) async {
    Completer<Map<String, Uint8List?>> completer = Completer();
    Map<String, Uint8List?> result = {};
    int resultCount = 0;
    ref.read(loadingStatusProvider.notifier).update(stringKey, LoadingState.loading);
    _controllers.forEach((key, value) {
      value
          .fetchAttachments(email: email, messageId: messageId, type: type, attachmentIds: attachmentIds)
          .then((value) {
            result.addAll((value ?? {}));
            resultCount++;
            if (resultCount != _controllers.length) return;
            ref.read(loadingStatusProvider.notifier).update(stringKey, LoadingState.success);
            completer.complete(result);
          })
          .catchError((error) {
            resultCount++;
            if (resultCount != _controllers.length) return;
            ref.read(loadingStatusProvider.notifier).update(stringKey, LoadingState.error);
            completer.complete(result);
          });
    });
    return completer.future;
  }

  List<String> canceldMailIds = [];

  Future<MailEntity?> send({required MailEntity mail}) async {
    final oauth = mailOAuths.firstWhereOrNull((e) => e.email == mail.hostEmail);
    return _controllers[oauth?.uniqueId ?? '']?.send(mail: mail) ?? null;
  }

  Future<MailEntity?> draft({required MailEntity mail}) async {
    final oauth = mailOAuths.firstWhereOrNull((e) => e.email == mail.hostEmail);
    return _controllers[oauth?.uniqueId ?? '']?.draft(mail: mail) ?? null;
  }

  Future<bool> undraft({required MailEntity mail}) async {
    final oauth = mailOAuths.firstWhereOrNull((e) => e.email == mail.hostEmail);
    return _controllers[oauth?.uniqueId ?? '']?.undraft(mail: mail) ?? false;
  }

  Future<void> deleteAllMailsInLabel({required String labelId, String? email}) async {
    Completer<void> completer = Completer();
    int resultCount = 0;
    final oauths = mailOAuths.where((e) => email == null ? true : email == e.email).toList();
    oauths.forEach((e) {
      _controllers[e.uniqueId]
          ?.deleteAllMailsInLabel(labelId: labelId)
          .then((e) {
            resultCount++;
            if (resultCount != oauths.length) return;
            completer.complete();
          })
          .catchError((e) {
            resultCount++;
            if (resultCount != oauths.length) return;
            completer.complete();
          });
    });
    return completer.future;
  }

  void undoSend(String id) {
    _controllers.values.forEach((e) {
      e.undoSend(id);
    });
  }

  Future<bool> readThreads({required List<MailEntity> mails}) async {
    Completer<bool> completer = Completer();
    bool result = true;
    int resultCount = 0;
    final groupedMails = groupBy(mails, (e) => e.hostEmail);
    groupedMails.forEach((key, value) {
      final oauth = mailOAuths.firstWhereOrNull((e) => e.email == key);
      _controllers[oauth?.uniqueId ?? '']
          ?.readThreads(mails: value)
          .then((e) {
            result = result && e;
            resultCount++;
            if (resultCount != groupedMails.length) return;
            completer.complete(e);
          })
          .catchError((e) {
            result = false;
            resultCount++;
            if (resultCount != groupedMails.length) return;
            completer.complete(e);
          });
    });
    return completer.future;
  }

  Future<bool> unreadThreads({required List<MailEntity> mails}) async {
    Completer<bool> completer = Completer();
    int resultCount = 0;
    bool result = true;
    final groupedMails = groupBy(mails, (e) => e.hostEmail);
    groupedMails.forEach((key, value) {
      final oauth = mailOAuths.firstWhereOrNull((e) => e.email == key);
      _controllers[oauth?.uniqueId ?? '']
          ?.unreadThreads(mails: value)
          .then((e) {
            result = result && e;
            resultCount++;
            if (resultCount != groupedMails.length) return;
            completer.complete(e);
          })
          .catchError((e) {
            result = false;
            resultCount++;
            if (resultCount != groupedMails.length) return;
            completer.complete(e);
          });
    });
    return completer.future;
  }

  Future<bool> pinThreads({required List<MailEntity> mails}) async {
    Completer<bool> completer = Completer();
    int resultCount = 0;
    bool result = true;
    final groupedMails = groupBy(mails, (e) => e.hostEmail);
    groupedMails.forEach((key, value) {
      final oauth = mailOAuths.firstWhereOrNull((e) => e.email == key);
      _controllers[oauth?.uniqueId ?? '']
          ?.pinThreads(mails: value)
          .then((e) {
            result = result && e;
            resultCount++;
            if (resultCount != groupedMails.length) return;
            completer.complete(e);
          })
          .catchError((e) {
            result = false;
            resultCount++;
            if (resultCount != groupedMails.length) return;
            completer.complete(e);
          });
    });
    return completer.future;
  }

  Future<bool> unpinThreads({required List<MailEntity> mails}) async {
    Completer<bool> completer = Completer();
    int resultCount = 0;
    bool result = true;
    final groupedMails = groupBy(mails, (e) => e.hostEmail);
    groupedMails.forEach((key, value) {
      final oauth = mailOAuths.firstWhereOrNull((e) => e.email == key);
      _controllers[oauth?.uniqueId ?? '']
          ?.unpinThreads(mails: value)
          .then((e) {
            result = result && e;
            resultCount++;
            if (resultCount != groupedMails.length) return;
            completer.complete(e);
          })
          .catchError((e) {
            result = false;
            resultCount++;
            if (resultCount != groupedMails.length) return;
            completer.complete(e);
          });
    });
    return completer.future;
  }

  Future<bool> archiveThreads({required List<MailEntity> mails}) async {
    Completer<bool> completer = Completer();
    int resultCount = 0;
    bool result = true;
    final groupedMails = groupBy(mails, (e) => e.hostEmail);
    groupedMails.forEach((key, value) {
      final oauth = mailOAuths.firstWhereOrNull((e) => e.email == key);
      _controllers[oauth?.uniqueId ?? '']
          ?.archiveThreads(mails: value)
          .then((e) {
            result = result && e;
            resultCount++;
            if (resultCount != groupedMails.length) return;
            completer.complete(e);
          })
          .catchError((e) {
            result = false;
            resultCount++;
            if (resultCount != groupedMails.length) return;
            completer.complete(e);
          });
    });
    return completer.future;
  }

  Future<bool> unarchiveThreads({required List<MailEntity> mails}) async {
    Completer<bool> completer = Completer();
    int resultCount = 0;
    bool result = true;
    final groupedMails = groupBy(mails, (e) => e.hostEmail);
    groupedMails.forEach((key, value) {
      final oauth = mailOAuths.firstWhereOrNull((e) => e.email == key);
      _controllers[oauth?.uniqueId ?? '']
          ?.unarchiveThreads(mails: value)
          .then((e) {
            result = result && e;
            resultCount++;
            if (resultCount != groupedMails.length) return;
            completer.complete(e);
          })
          .catchError((e) {
            result = false;
            resultCount++;
            if (resultCount != groupedMails.length) return;
            completer.complete(e);
          });
    });
    return completer.future;
  }

  Future<bool> spamThreads({required List<MailEntity> mails}) async {
    Completer<bool> completer = Completer();
    int resultCount = 0;
    bool result = true;
    final groupedMails = groupBy(mails, (e) => e.hostEmail);
    groupedMails.forEach((key, value) {
      final oauth = mailOAuths.firstWhereOrNull((e) => e.email == key);
      _controllers[oauth?.uniqueId ?? '']
          ?.spamThreads(mails: value)
          .then((e) {
            result = result && e;
            resultCount++;
            if (resultCount != groupedMails.length) return;
            completer.complete(e);
          })
          .catchError((e) {
            result = false;
            resultCount++;
            if (resultCount != groupedMails.length) return;
            completer.complete(e);
          });
    });
    return completer.future;
  }

  Future<bool> unspamThreads({required List<MailEntity> mails}) async {
    Completer<bool> completer = Completer();
    int resultCount = 0;
    bool result = true;
    final groupedMails = groupBy(mails, (e) => e.hostEmail);
    groupedMails.forEach((key, value) {
      final oauth = mailOAuths.firstWhereOrNull((e) => e.email == key);
      _controllers[oauth?.uniqueId ?? '']
          ?.unspamThreads(mails: value)
          .then((e) {
            result = result && e;
            resultCount++;
            if (resultCount != groupedMails.length) return;
            completer.complete(e);
          })
          .catchError((e) {
            result = false;
            resultCount++;
            if (resultCount != groupedMails.length) return;
            completer.complete(e);
          });
    });
    return completer.future;
  }

  Future<bool> trashThreads({required List<MailEntity> mails}) async {
    Completer<bool> completer = Completer();
    int resultCount = 0;
    bool result = true;
    final groupedMails = groupBy(mails, (e) => e.hostEmail);
    groupedMails.forEach((key, value) {
      final oauth = mailOAuths.firstWhereOrNull((e) => e.email == key);
      _controllers[oauth?.uniqueId ?? '']
          ?.trashThreads(mails: value)
          .then((e) {
            result = result && e;
            resultCount++;
            if (resultCount != groupedMails.length) return;
            completer.complete(e);
          })
          .catchError((e) {
            result = false;
            resultCount++;
            if (resultCount != groupedMails.length) return;
            completer.complete(e);
          });
    });
    return completer.future;
  }

  Future<bool> untrashThreads({required List<MailEntity> mails}) async {
    Completer<bool> completer = Completer();
    int resultCount = 0;
    bool result = true;
    final groupedMails = groupBy(mails, (e) => e.hostEmail);
    groupedMails.forEach((key, value) {
      final oauth = mailOAuths.firstWhereOrNull((e) => e.email == key);
      _controllers[oauth?.uniqueId ?? '']
          ?.untrashThreads(mails: value)
          .then((e) {
            result = result && e;
            resultCount++;
            if (resultCount != groupedMails.length) return;
            completer.complete(e);
          })
          .catchError((e) {
            result = false;
            resultCount++;
            if (resultCount != groupedMails.length) return;
            completer.complete(e);
          });
    });
    return completer.future;
  }

  Future<bool> deleteThreads({required List<MailEntity> mails}) async {
    Completer<bool> completer = Completer();
    int resultCount = 0;
    bool result = true;
    final groupedMails = groupBy(mails, (e) => e.hostEmail);
    groupedMails.forEach((key, value) {
      final oauth = mailOAuths.firstWhereOrNull((e) => e.email == key);
      _controllers[oauth?.uniqueId ?? '']
          ?.deleteThreads(mails: value)
          .then((e) {
            result = result && e;
            resultCount++;
            if (resultCount != groupedMails.length) return;
            completer.complete(e);
          })
          .catchError((e) {
            result = false;
            resultCount++;
            if (resultCount != groupedMails.length) return;
            completer.complete(e);
          });
    });
    return completer.future;
  }

  void addMailLocal(List<MailEntity> mails, {List<String>? labelIds}) {
    final groupedMails = groupBy(mails, (e) => e.hostEmail);
    groupedMails.forEach((key, value) {
      final oauth = mailOAuths.firstWhereOrNull((e) => e.email == key);
      _controllers[oauth?.uniqueId ?? '']?.addMailLocal(value, labelIds: labelIds);
    });
  }

  void removeMailLocal(List<TempMailEntity> mails) {
    final groupedMails = groupBy(mails, (e) => e.hostEmail);
    groupedMails.forEach((key, value) {
      final oauth = mailOAuths.firstWhereOrNull((e) => e.email == key);
      _controllers[oauth?.uniqueId ?? '']?.removeMailLocal(value);
    });
  }

  void addLabelsLocal(List<MailEntity> mails, List<String> addLabelIds) {
    final groupedMails = groupBy(mails, (e) => e.hostEmail);
    groupedMails.forEach((key, value) {
      final oauth = mailOAuths.firstWhereOrNull((e) => e.email == key);
      _controllers[oauth?.uniqueId ?? '']?.addLabelsLocal(value, addLabelIds);
    });
  }

  void removeLabelsLocal(List<MailEntity> mails, List<String> removeLabelIds) {
    final groupedMails = groupBy(mails, (e) => e.hostEmail);
    groupedMails.forEach((key, value) {
      final oauth = mailOAuths.firstWhereOrNull((e) => e.email == key);
      _controllers[oauth?.uniqueId ?? '']?.removeLabelsLocal(value, removeLabelIds);
    });
  }

  List<MailEntity>? getThreadsFromTaskMailLocally(LinkedMailEntity? taskMail) {
    final oauth = mailOAuths.firstWhereOrNull((e) => e.email == taskMail?.hostMail);
    return _controllers[oauth?.uniqueId ?? '']?.getThreadsFromTaskMailLocally(taskMail);
  }
}

@riverpod
class MailListControllerInternal extends _$MailListControllerInternal {
  late MailRepository _repository;
  String? _historyId;

  String? get historyId => _historyId;

  OAuthEntity get oauth => ref.read(localPrefControllerProvider.select((value) => value.value?.mailOAuths?.firstWhereOrNull((e) => e.uniqueId == oAuthUniqueId)))!;

  @override
  Future<MailListResultEntity> build({required bool isSignedIn, required String label, required String email, required String? query, required String oAuthUniqueId}) async {
    _repository = ref.watch(mailRepositoryProvider);

    if (ref.watch(shouldUseMockDataProvider)) {
      getMockMails();
      return MailListResultEntity(mails: {}, email: email, label: label);
    }

    final userId = ref.watch(authControllerProvider.select((value) => value.requireValue.id));

    await persist(
      ref.watch(storageProvider.future),
      key: '${MailListController.stringKey}:${isSignedIn}:${label}:${email}:${query}:${oAuthUniqueId}',
      encode: (MailListResultEntity state) => jsonEncode(state.toJson()),
      decode: (String encoded) {
        final trimmed = encoded.trim();
        if (trimmed.isEmpty || trimmed == 'null') {
          return MailListResultEntity(mails: {}, email: email, label: label);
        }
        return MailListResultEntity.fromJson(jsonDecode(trimmed) as Map<String, dynamic>);
      },
      options: StorageOptions(destroyKey: userId),
    ).future;

    if (!ref.mounted) return MailListResultEntity(mails: {}, email: email, label: label);
    return state.value ?? MailListResultEntity(mails: {}, email: email, label: label);
  }

  Future<void> getMockMails() async {
    final values = await Future.wait([rootBundle.loadString('assets/mock/mail/gmail/index.json'), rootBundle.loadString('assets/mock/mail/outlook/index.json')]);

    final gmailIds = (jsonDecode(values[0]) as List<dynamic>).map((e) => e['id'] as String).toList();
    final outlookIds = (jsonDecode(values[1]) as List<dynamic>).map((e) => e['messageIds'] as List<dynamic>).expand((e) => e).toList();
    final gmailValues = await Future.wait(gmailIds.map((e) => rootBundle.loadString('assets/mock/mail/gmail/threads/$e.json')));
    final outlookValues = await Future.wait(outlookIds.map((e) => rootBundle.loadString('assets/mock/mail/outlook/threads/$e.json')));
    final gmailThreads = gmailValues
        .map((e) => jsonDecode(e)['messages'] as List<dynamic>)
        .map((e) => e.map((e) => MailEntity.fromGmail(message: Message.fromJson(e), hostEmail: fakeUserEmail)).toList())
        .map((e) => e.lastWhereOrNull((e) => e.labelIds?.contains(label) == true)?.copyWith(threads: e))
        .whereType<MailEntity>()
        .toList();
    final outlookThreadsData = outlookValues
        .map((e) {
          final outlook = OutlookMailMessage.fromJson(jsonDecode(e));
          final labelIds = <String>[];
          if (outlook.parentFolderId == 'drafts') {
            labelIds.add(CommonMailLabels.draft.id);
          } else if (outlook.parentFolderId == 'sentitems') {
            labelIds.add(CommonMailLabels.sent.id);
          } else if (outlook.parentFolderId == 'junkemail') {
            labelIds.add(CommonMailLabels.spam.id);
          } else if (outlook.parentFolderId == 'deleteditems') {
            labelIds.add(CommonMailLabels.trash.id);
          } else if (outlook.isRead == false) {
            labelIds.add(CommonMailLabels.inbox.id);
            labelIds.add(CommonMailLabels.unread.id);
          } else if (outlook.followupFlag?.flagStatus == 'flagged') {
            labelIds.add(CommonMailLabels.inbox.id);
            labelIds.add(CommonMailLabels.pinned.id);
          } else {
            labelIds.add(CommonMailLabels.inbox.id);
          }

          return MailEntity.fromOutlook(
            message: outlook.copyWith(labelIds: labelIds),
            hostEmail: companyEmail,
          );
        })
        .whereType<MailEntity>()
        .toList();

    final threads = groupBy(outlookThreadsData, (e) => e.threadId);
    final outlookThreads = threads
        .map((key, value) => MapEntry(key, value.lastWhereOrNull((e) => e.labelIds?.contains(label) == true)?.copyWith(threads: value)))
        .values
        .whereType<MailEntity>()
        .toList();

    state = AsyncData(
      MailListResultEntity(
        email: email,
        label: label,
        mails: {
          fakeUserEmail: MailFetchResultEntity(messages: gmailThreads.where((e) => e.labelIds?.contains(label) == true).toList(), nextPageToken: null, hasMore: false),
          companyEmail: MailFetchResultEntity(messages: outlookThreads.where((e) => e.labelIds?.contains(label) == true).toList(), nextPageToken: null, hasMore: false),
        },
      ),
    );
  }

  void _updateState(Map<String, MailFetchResultEntity> data, DateTime updatedAt) {
    if (ref.read(shouldUseMockDataProvider)) return;
    final prevState = state.value?.mails ?? {};
    state = AsyncData(
      MailListResultEntity(
        mails: data.map((key, value) {
          final prevValue = prevState[key]?.messages ?? [];
          return MapEntry(
            key,
            value.copyWith(
              messages: [...value.messages]
                  .map((e) {
                    final prevMail = prevValue.firstWhereOrNull((element) => element.id == e.id);
                    if (prevMail?.localUpdatedAt != null && prevMail!.localUpdatedAt!.isAfter(updatedAt)) {
                      return prevMail;
                    }
                    return e;
                  })
                  .where((e) {
                    if (label == CommonMailLabels.inbox.id) return e.labelIds?.contains(CommonMailLabels.inbox.id) == true;
                    return true;
                  })
                  .toList(),
            ),
          );
        }),
        email: email,
        label: label,
      ),
    );
  }

  Future<void> refresh() async {
    if (query != null) {
      await search(loadMore: false);
    } else {
      await load(refresh: true);
    }
  }

  Future<void> loadMore() async {
    await load();
  }

  Future<void> search({required bool loadMore}) async {
    if (ref.read(shouldUseMockDataProvider)) return;
    final _pref = ref.read(localPrefControllerProvider).value;
    final user = ref.read(authControllerProvider).requireValue;
    if (_pref == null) return;

    final newPageTokens = !loadMore
        ? null
        : state.value?.mails.isNotEmpty == true
        ? ({...state.value?.mails ?? {}}).map((key, value) => MapEntry(key, value.nextPageToken))
        : null;

    final fetchStartDateTime = DateTime.now();
    final result = await _repository.fetchMailsForLabel(oauth: oauth, user: user, labelId: null, email: null, pageToken: newPageTokens, q: query, isInbox: false);

    result.fold((l) {}, (r) {
      if (!loadMore) {
        _updateState(r, fetchStartDateTime);
      } else {
        final newValue = {...r};
        final oldValue = state.value?.mails ?? {};

        oldValue.forEach((k, v) {
          if (newValue.containsKey(k)) {
            newValue[k] = v.copyWith(messages: [...v.messages, ...newValue[k]!.messages]);
          } else {
            newValue[k] = oldValue[k]!;
          }
        });

        final value = newValue.map(
          (key, value) => MapEntry(
            key,
            value.copyWith(
              messages: [...value.messages]
                ..sort((a, b) => b.date!.compareTo(a.date!))
                ..unique((e) => e.id),
            ),
          ),
        );
        _updateState(value, fetchStartDateTime);
      }
    });
  }

  Future<void> loadRecent() async {
    if (query != null) return;
    if (ref.read(shouldUseMockDataProvider)) return;
    final _pref = ref.read(localPrefControllerProvider).value;
    final user = ref.read(authControllerProvider).requireValue;
    if (ref.read(shouldUseMockDataProvider)) return;
    if (_pref == null) return;

    final fetchStartDateTime = DateTime.now();
    final result = await _repository.fetchMailsForLabel(oauth: oauth, user: user, labelId: label, email: email, pageToken: null, isInbox: false);

    await result.fold((l) {}, (r) async {
      if (!ref.mounted) return;

      final newValue = {...r};
      final oldValue = state.value?.mails ?? {};

      oldValue.forEach((k, v) {
        if (newValue.containsKey(k)) {
          newValue[k] = v.copyWith(messages: [...v.messages, ...newValue[k]!.messages]);
        } else {
          newValue[k] = oldValue[k]!;
        }
      });

      final value = newValue.map(
        (key, value) => MapEntry(
          key,
          value.copyWith(
            messages: [...value.messages]
              ..sort((a, b) => (b.date ?? DateTime.now()).compareTo(a.date ?? DateTime.now()))
              ..unique((e) => e.id),
          ),
        ),
      );
      _updateState(value, fetchStartDateTime);
    });
  }

  bool get isAbleToLoadMore {
    final newPageTokens = state.value?.mails.isNotEmpty == true ? ({...state.value?.mails ?? {}}).map((key, value) => MapEntry(key, value.nextPageToken)) : null;
    return newPageTokens != null && newPageTokens.values.where((e) => e != null).isNotEmpty;
  }

  Future<void> load({bool? refresh}) async {
    if (!ref.mounted) return;
    if (ref.read(shouldUseMockDataProvider)) return;
    final _pref = ref.read(localPrefControllerProvider).value;
    final user = ref.read(authControllerProvider).requireValue;
    if (_pref == null) return;

    final newPageTokens = refresh == true
        ? null
        : state.value?.mails.isNotEmpty == true
        ? ({...state.value?.mails ?? {}}).map((key, value) => MapEntry(key, value.nextPageToken))
        : null;

    final fetchStartDateTime = DateTime.now();
    final result = await _repository.fetchMailsForLabel(oauth: oauth, user: user, labelId: label, email: email, pageToken: newPageTokens, isInbox: false);

    await result.fold((l) {}, (r) async {
      if (refresh == true) {
        _updateState(r, fetchStartDateTime);
      } else {
        final newValue = {...r};
        final oldValue = state.value?.mails ?? {};

        final value = oldValue.map((key, value) {
          if (newValue.containsKey(key)) {
            return MapEntry(key, newValue[key]!.copyWith(messages: [...value.messages, ...newValue[key]!.messages]));
          } else {
            return MapEntry(key, value.copyWith(messages: [...value.messages]..unique((e) => e.threadId)));
          }
        });

        _updateState(value, fetchStartDateTime);
      }
    });
  }

  Future<Map<String, Uint8List?>?> fetchAttachments({required String email, required String messageId, required MailEntityType type, required List<String> attachmentIds}) async {
    final _pref = ref.read(localPrefControllerProvider).value;
    if (_pref == null) return null;

    if (ref.read(shouldUseMockDataProvider)) return {};

    final result = await _repository.fetchAttachments(oauth: oauth, email: email, messageId: messageId, attachmentIds: attachmentIds);

    return result.fold(
      (l) {
        return null;
      },
      (r) {
        return r;
      },
    );
  }

  List<String> canceldMailIds = [];

  Future<MailEntity?> send({required MailEntity mail}) async {
    final _pref = ref.read(localPrefControllerProvider).value;
    if (_pref == null) return null;
    await Future.delayed(Duration(seconds: 5));
    if (canceldMailIds.contains(mail.id)) return mail;
    if (ref.read(shouldUseMockDataProvider)) return mail;
    final result = await _repository.send(mail: mail, oauth: oauth);
    return result.fold((l) => null, (r) => r);
  }

  Future<MailEntity?> draft({required MailEntity mail}) async {
    final _pref = ref.read(localPrefControllerProvider).value;
    if (_pref == null) return null;
    addMailLocal([mail], labelIds: [CommonMailLabels.draft.id]);
    final result = await _repository.draft(mail: mail, oauth: oauth);
    return result.fold((l) {
      removeMailLocal([TempMailEntity(id: mail.id ?? mail.draftId!, hostEmail: mail.hostEmail, labelIds: mail.labelIds ?? [])]);
      return null;
    }, (r) => r);
  }

  Future<bool> undraft({required MailEntity mail}) async {
    final _pref = ref.read(localPrefControllerProvider).value;
    if (_pref == null) return false;
    removeMailLocal([TempMailEntity(id: mail.id ?? mail.draftId!, hostEmail: mail.hostEmail, labelIds: mail.labelIds ?? [])]);
    final result = await _repository.undraft(mail: mail, oauth: oauth);
    return result.fold(
      (l) {
        addMailLocal([mail]);
        return false;
      },
      (r) {
        return r;
      },
    );
  }

  Future<void> deleteAllMailsInLabel({required String labelId, String? email}) async {
    final _pref = ref.read(localPrefControllerProvider).value;
    if (_pref == null) return;

    final prevState = state.value;
    if (prevState == null) return;

    _updateState({}, DateTime.now());
    final result = await _repository.deleteAllMailsInLabel(labelId: labelId, oauth: oauth);
    result.fold((l) {
      state = AsyncData(prevState);
    }, (r) async {});
  }

  void undoSend(String id) {
    canceldMailIds.add(id);
  }

  Future<bool> readThreads({required List<MailEntity> mails}) async {
    final _pref = ref.read(localPrefControllerProvider).value;
    if (_pref == null) return false;
    if (ref.read(shouldUseMockDataProvider)) return true;

    final prevState = state.value;
    if (prevState == null) return false;
    final entries = Map.fromEntries(
      prevState.mails.entries.map((entry) {
        final list = entry.value.messages.map((e) => mails.any((m) => m.threadId == e.threadId) ? e.copyWith(isUnread: false) : e).toList();
        return MapEntry(entry.key, entry.value.copyWith(messages: list));
      }),
    );

    _updateState(entries, DateTime.now());

    final result = await _repository.read(oauth: oauth, mails: mails);
    return result.fold(
      (l) async {
        state = AsyncData(prevState);
        return false;
      },
      (r) {
        return true;
      },
    );
  }

  Future<bool> unreadThreads({required List<MailEntity> mails}) async {
    final _pref = ref.read(localPrefControllerProvider).value;
    if (_pref == null) return false;
    if (ref.read(shouldUseMockDataProvider)) return true;

    final prevState = state.value;
    if (prevState == null) return false;
    final entries = Map.fromEntries(
      prevState.mails.entries.map((entry) {
        final list = entry.value.messages.map((e) => mails.any((m) => m.threadId == e.threadId) ? e.copyWith(isUnread: true) : e).toList();
        return MapEntry(entry.key, entry.value.copyWith(messages: list));
      }),
    );

    _updateState(entries, DateTime.now());

    final result = await _repository.unread(oauth: oauth, mails: mails);
    return result.fold(
      (l) async {
        state = AsyncData(prevState);
        return false;
      },
      (r) {
        return true;
      },
    );
  }

  Future<bool> pinThreads({required List<MailEntity> mails}) async {
    final _pref = ref.read(localPrefControllerProvider).value;
    if (_pref == null) return false;
    if (ref.read(shouldUseMockDataProvider)) return true;

    final prevState = state.value;
    if (prevState == null) return false;
    final entries = Map.fromEntries(
      prevState.mails.entries.map((entry) {
        final list = entry.value.messages.map((e) => mails.any((m) => m.threadId == e.threadId) ? e.copyWith(isPinned: true) : e).toList();
        return MapEntry(entry.key, entry.value.copyWith(messages: list));
      }),
    );

    _updateState(entries, DateTime.now());

    final result = await _repository.pin(oauth: oauth, mails: mails);
    return result.fold(
      (l) async {
        state = AsyncData(prevState);
        return false;
      },
      (r) {
        return true;
      },
    );
  }

  Future<bool> unpinThreads({required List<MailEntity> mails}) async {
    final _pref = ref.read(localPrefControllerProvider).value;
    if (_pref == null) return false;
    if (ref.read(shouldUseMockDataProvider)) return true;

    final prevState = state.value;
    if (prevState == null) return false;
    final entries = Map.fromEntries(
      prevState.mails.entries.map((entry) {
        final list = entry.value.messages.map((e) => mails.any((m) => m.threadId == e.threadId) ? e.copyWith(isPinned: false) : e).toList();
        return MapEntry(entry.key, entry.value.copyWith(messages: list));
      }),
    );

    _updateState(entries, DateTime.now());

    final result = await _repository.unpin(oauth: oauth, mails: mails);
    return result.fold(
      (l) async {
        state = AsyncData(prevState);
        return false;
      },
      (r) {
        Map<String, List<MailEntity>> cachedUpdateMails = {};
        prevState.mails.forEach((key, value) {
          value.messages.forEach((e) {
            e.labelIds?.forEach((l) {
              if (l != label && e.labelIds?.contains(CommonMailLabels.pinned.id) == true) {
                cachedUpdateMails[l] = [...cachedUpdateMails[l] ?? [], e];
              }
            });
          });
        });

        return true;
      },
    );
  }

  Future<bool> archiveThreads({required List<MailEntity> mails}) async {
    final _pref = ref.read(localPrefControllerProvider).value;
    if (_pref == null) return false;
    if (ref.read(shouldUseMockDataProvider)) return true;

    final prevState = state.value;
    if (prevState == null) return false;
    final entries = Map.fromEntries(
      prevState.mails.entries.map((entry) {
        if (label == CommonMailLabels.inbox.id) {
          final list = entry.value.messages.where((e) => !mails.any((m) => m.threadId == e.threadId)).toList();
          return MapEntry(entry.key, entry.value.copyWith(messages: list));
        } else {
          final list = entry.value.messages.map((e) => mails.any((m) => m.threadId == e.threadId) ? e.copyWith(isArchive: true) : e).toList();
          return MapEntry(entry.key, entry.value.copyWith(messages: list));
        }
      }),
    );

    _updateState(entries, DateTime.now());

    final result = await _repository.archive(oauth: oauth, mails: mails);
    return result.fold(
      (l) async {
        state = AsyncData(prevState);
        return false;
      },
      (r) {
        Map<String, List<MailEntity>> cachedUpdateMails = {};
        prevState.mails.forEach((key, value) {
          value.messages.forEach((e) {
            e.labelIds?.forEach((l) {
              if (l != label && e.labelIds?.contains(CommonMailLabels.inbox.id) == true) {
                cachedUpdateMails[l] = [...cachedUpdateMails[l] ?? [], e];
              }
            });
          });
        });

        return true;
      },
    );
  }

  Future<bool> unarchiveThreads({required List<MailEntity> mails}) async {
    final _pref = ref.read(localPrefControllerProvider).value;
    if (_pref == null) return false;
    if (ref.read(shouldUseMockDataProvider)) return true;

    final prevState = state.value;
    if (prevState == null) return false;
    final entries = Map.fromEntries(
      prevState.mails.entries.map((entry) {
        final list = entry.value.messages.map((e) => mails.any((m) => m.threadId == e.threadId) ? e.copyWith(isArchive: false) : e).toList();
        return MapEntry(entry.key, entry.value.copyWith(messages: list));
      }),
    );

    _updateState(entries, DateTime.now());

    final result = await _repository.unarchive(oauth: oauth, mails: mails);
    return result.fold(
      (l) async {
        state = AsyncData(prevState);
        return false;
      },
      (r) {
        Map<String, List<MailEntity>> cachedUpdateMails = {};
        prevState.mails.forEach((key, value) {
          value.messages.forEach((e) {
            e.labelIds?.forEach((l) {
              if (l != label && e.labelIds?.contains(CommonMailLabels.inbox.id) == false) {
                cachedUpdateMails[l] = [...cachedUpdateMails[l] ?? [], e];
              }
            });
          });
        });

        return true;
      },
    );
  }

  Future<bool> spamThreads({required List<MailEntity> mails}) async {
    final _pref = ref.read(localPrefControllerProvider).value;
    if (_pref == null) return false;
    if (ref.read(shouldUseMockDataProvider)) return true;

    final prevState = state.value;
    if (prevState == null) return false;
    final entries = Map.fromEntries(
      prevState.mails.entries.map((entry) {
        final list = entry.value.messages.where((e) => !mails.any((m) => m.threadId == e.threadId)).toList();
        return MapEntry(entry.key, entry.value.copyWith(messages: list));
      }),
    );

    _updateState(entries, DateTime.now());

    final result = await _repository.spam(oauth: oauth, mails: mails);
    return result.fold(
      (l) async {
        state = AsyncData(prevState);
        return false;
      },
      (r) {
        Map<String, List<MailEntity>> cachedUpdateMails = {};
        prevState.mails.forEach((key, value) {
          value.messages.forEach((e) {
            e.labelIds?.forEach((l) {
              if (l != label && e.labelIds?.contains(CommonMailLabels.spam.id) == false) {
                cachedUpdateMails[l] = [...cachedUpdateMails[l] ?? [], e];
              }
            });
          });
        });

        return true;
      },
    );
  }

  Future<bool> unspamThreads({required List<MailEntity> mails}) async {
    final _pref = ref.read(localPrefControllerProvider).value;
    if (_pref == null) return false;
    if (ref.read(shouldUseMockDataProvider)) return true;

    final prevState = state.value;
    if (prevState == null) return false;
    final entries = Map.fromEntries(
      prevState.mails.entries.map((entry) {
        final list = entry.value.messages.where((e) => !mails.any((m) => m.threadId == e.threadId)).toList();
        return MapEntry(entry.key, entry.value.copyWith(messages: list));
      }),
    );

    _updateState(entries, DateTime.now());

    final result = await _repository.unspam(oauth: oauth, mails: mails);
    return result.fold(
      (l) async {
        state = AsyncData(prevState);
        return false;
      },
      (r) {
        Map<String, List<MailEntity>> cachedUpdateMails = {};
        prevState.mails.forEach((key, value) {
          value.messages.forEach((e) {
            e.labelIds?.forEach((l) {
              if (l != label && e.labelIds?.contains(CommonMailLabels.spam.id) == true) {
                cachedUpdateMails[l] = [...cachedUpdateMails[l] ?? [], e];
              }
            });
          });
        });

        return true;
      },
    );
  }

  Future<bool> trashThreads({required List<MailEntity> mails}) async {
    final _pref = ref.read(localPrefControllerProvider).value;
    if (_pref == null) return false;
    if (ref.read(shouldUseMockDataProvider)) return true;

    final prevState = state.value;
    if (prevState == null) return false;
    final entries = Map.fromEntries(
      prevState.mails.entries.map((entry) {
        final list = entry.value.messages.where((e) => !mails.any((m) => m.threadId == e.threadId)).toList();
        return MapEntry(entry.key, entry.value.copyWith(messages: list));
      }),
    );

    _updateState(entries, DateTime.now());

    final result = await _repository.trash(oauth: oauth, mails: mails);
    return result.fold(
      (l) async {
        state = AsyncData(prevState);
        return false;
      },
      (r) {
        Map<String, List<MailEntity>> cachedUpdateMails = {};
        prevState.mails.forEach((key, value) {
          value.messages.forEach((e) {
            e.labelIds?.forEach((l) {
              if (l != label && e.labelIds?.contains(CommonMailLabels.trash.id) == false) {
                cachedUpdateMails[l] = [...cachedUpdateMails[l] ?? [], e];
              }
            });
          });
        });

        return true;
      },
    );
  }

  Future<bool> untrashThreads({required List<MailEntity> mails}) async {
    final _pref = ref.read(localPrefControllerProvider).value;
    if (_pref == null) return false;
    if (ref.read(shouldUseMockDataProvider)) return true;

    final prevState = state.value;
    if (prevState == null) return false;
    final entries = Map.fromEntries(
      prevState.mails.entries.map((entry) {
        final list = entry.value.messages.where((e) => !mails.any((m) => m.threadId == e.threadId)).toList();
        return MapEntry(entry.key, entry.value.copyWith(messages: list));
      }),
    );

    _updateState(entries, DateTime.now());

    final result = await _repository.untrash(oauth: oauth, mails: mails);
    return result.fold(
      (l) async {
        state = AsyncData(prevState);
        return false;
      },
      (r) {
        Map<String, List<MailEntity>> cachedUpdateMails = {};
        prevState.mails.forEach((key, value) {
          value.messages.forEach((e) {
            e.labelIds?.forEach((l) {
              if (l != label && e.labelIds?.contains(CommonMailLabels.trash.id) == true) {
                cachedUpdateMails[l] = [...cachedUpdateMails[l] ?? [], e];
              }
            });
          });
        });

        return true;
      },
    );
  }

  Future<bool> deleteThreads({required List<MailEntity> mails}) async {
    final _pref = ref.read(localPrefControllerProvider).value;
    if (_pref == null) return false;
    if (ref.read(shouldUseMockDataProvider)) return true;

    final prevState = state.value;
    if (prevState == null) return false;
    final entries = Map.fromEntries(
      prevState.mails.entries.map((entry) {
        final list = entry.value.messages.where((e) => !mails.any((m) => m.threadId == e.threadId)).toList();
        return MapEntry(entry.key, entry.value.copyWith(messages: list));
      }),
    );

    _updateState(entries, DateTime.now());

    final result = await _repository.delete(oauth: oauth, mails: mails);
    return result.fold(
      (l) async {
        state = AsyncData(prevState);
        return false;
      },
      (r) {
        Map<String, List<MailEntity>> cachedUpdateMails = {};
        prevState.mails.forEach((key, value) {
          value.messages.forEach((e) {
            e.labelIds?.forEach((l) {
              if (l != label) {
                cachedUpdateMails[l] = [...cachedUpdateMails[l] ?? [], e];
              }
            });
          });
        });

        return true;
      },
    );
  }

  void addMailLocal(List<MailEntity> mails, {List<String>? labelIds}) {
    final newMails = (state.value?.mails ?? {}).map((key, value) => MapEntry(key, value.copyWith()));
    final localUpdatedAt = DateTime.now();

    final mailGroupedMail = groupBy(mails, (e) => e.hostEmail);

    final result = newMails.map((key, value) {
      final updatingMails = mailGroupedMail[key];
      if (updatingMails != null) {
        final newValue = value.copyWith(
          messages: [
            ...value.messages,
            ...updatingMails.map((mail) => labelIds != null ? mail.copyWith(labelIds: [...(mail.labelIds ?? []), ...labelIds].unique().whereType<String>().toList()) : mail),
          ].unique((e) => e.id),
        );
        return MapEntry(key, newValue);
      }
      return MapEntry(key, value);
    });

    _updateState(result, localUpdatedAt);

    Map<String, List<MailEntity>> cachedUpdateMails = {};
    mails.forEach((e) {
      e.labelIds?.forEach((l) {
        if (l != label) {
          cachedUpdateMails[l] = [...cachedUpdateMails[l] ?? [], e];
        }
      });
    });
  }

  void removeMailLocal(List<TempMailEntity> mails) {
    final newMails = (state.value?.mails ?? {}).map((key, value) => MapEntry(key, value.copyWith()));
    final localUpdatedAt = DateTime.now();

    final mailGroupedMail = groupBy(mails, (e) => e.hostEmail);

    final result = newMails.map((key, value) {
      final updatingMails = mailGroupedMail[key];
      if (updatingMails != null) {
        final newValue = value.copyWith(messages: value.messages.where((e) => !updatingMails.map((m) => m.id).contains(e.id ?? e.draftId)).toList());
        return MapEntry(key, newValue);
      }
      return MapEntry(key, value);
    });
    _updateState(result, localUpdatedAt);

    Map<String, List<TempMailEntity>> cachedUpdateMails = {};
    mails.forEach((e) {
      e.labelIds.forEach((l) {
        if (l != label) {
          cachedUpdateMails[l] = [...cachedUpdateMails[l] ?? [], e];
        }
      });
    });
  }

  void addLabelsLocal(List<MailEntity> mails, List<String> addLabelIds) {
    final newMails = (state.value?.mails ?? {}).map((key, value) => MapEntry(key, value.copyWith()));
    final localUpdatedAt = DateTime.now();

    final mailGroupedMail = groupBy(mails, (e) => e.hostEmail);

    final result = newMails.map((key, value) {
      final updatingMails = mailGroupedMail[key];
      if (updatingMails != null) {
        final newValue = value.copyWith(
          messages: !addLabelIds.contains(label)
              ? [
                  ...value.messages,
                  ...mails.map((e) => e.copyWith(labelIds: [...(e.labelIds ?? []), ...addLabelIds].unique().whereType<String>().toList())),
                ]
              : value.messages.map((e) {
                  if (updatingMails.map((e) => e.id).contains(e.id)) {
                    final newLabelIds = e.labelIds ?? [];
                    newLabelIds.addAll(addLabelIds);
                    return e.copyWith(labelIds: newLabelIds, localUpdatedAt: localUpdatedAt);
                  }
                  return e;
                }).toList(),
        );
        return MapEntry(key, newValue);
      }
      return MapEntry(key, value);
    });
    _updateState(result, localUpdatedAt);

    Map<String, List<MailEntity>> cachedUpdateMails = {};
    mails.forEach((e) {
      e.labelIds?.forEach((l) {
        if (l != label) {
          cachedUpdateMails[l] = [...cachedUpdateMails[l] ?? [], e];
        }
      });
    });
  }

  void removeLabelsLocal(List<MailEntity> mails, List<String> removeLabelIds) {
    final newMails = (state.value?.mails ?? {}).map((key, value) => MapEntry(key, value.copyWith()));
    final localUpdatedAt = DateTime.now();

    final mailGroupedMail = groupBy(mails, (e) => e.hostEmail);

    final result = newMails.map((key, value) {
      final updatingMails = mailGroupedMail[key];
      if (updatingMails != null) {
        final newValue = value.copyWith(
          messages: removeLabelIds.contains(label)
              ? value.messages.where((e) {
                  return !mails.any((m) => m.id == e.id);
                }).toList()
              : value.messages.map((e) {
                  if (updatingMails.map((e) => e.id).contains(e.id)) {
                    final newLabelIds = e.labelIds ?? [];
                    newLabelIds.removeWhere((element) => removeLabelIds.contains(element));
                    return e.copyWith(labelIds: newLabelIds, localUpdatedAt: localUpdatedAt);
                  }
                  return e;
                }).toList(),
        );
        return MapEntry(key, newValue);
      }
      return MapEntry(key, value);
    });
    _updateState(result, localUpdatedAt);

    Map<String, List<MailEntity>> cachedUpdateMails = {};
    mails.forEach((e) {
      e.labelIds?.forEach((l) {
        if (l != label) {
          cachedUpdateMails[l] = [...cachedUpdateMails[l] ?? [], e];
        }
      });
    });
  }

  List<MailEntity>? getThreadsFromTaskMailLocally(LinkedMailEntity? taskMail) {
    if (taskMail == null) return null;
    String threadId = taskMail.threadId;
    final mails = (state.value?.mails ?? {}).map((key, value) => MapEntry(key, value.copyWith())).values.expand((e) => e.messages).toList();
    List<MailEntity>? thread = mails.where((e) => e.threadId == threadId).firstOrNull?.threads;
    if (thread?.isNotEmpty ?? false) return thread;
    return null;
  }
}

class MailListResultEntity {
  Map<String, MailFetchResultEntity> mails;
  final String? email;
  final String label;

  late List<MailEntity> list;

  MailListResultEntity({required this.mails, required this.email, required this.label}) {
    list = getMails();
  }

  Map<String, dynamic> toJson() {
    return {'mails': Map.fromEntries(mails.entries.map((e) => MapEntry(e.key, e.value.toJson())).toList()), 'email': email, 'label': label};
  }

  static MailListResultEntity fromJson(Map<String, dynamic> json) {
    final rawMails = json['mails'];
    final parsedMails = <String, MailFetchResultEntity>{};

    if (rawMails is Map) {
      rawMails.forEach((key, value) {
        final keyString = key is String ? key : key.toString();
        if (value is Map<String, dynamic>) {
          parsedMails[keyString] = MailFetchResultEntity.fromJson(value);
        } else if (value is Map) {
          parsedMails[keyString] = MailFetchResultEntity.fromJson(Map<String, dynamic>.from(value));
        }
      });
    }

    return MailListResultEntity(mails: parsedMails, email: json['email'], label: json['label']);
  }

  List<MailEntity> getMails() {
    List<DateTime> lastMailTimestamp = [];
    Map<String, String?> nextPageTokens = {};
    mails.forEach((key, data) {
      List<MailEntity> value = data.messages;
      if (value.isNotEmpty && (email == null || key == email)) {
        value = value.where((e) {
          if (![CommonMailLabels.unread.id, CommonMailLabels.pinned.id, CommonMailLabels.all.id].contains(label) && e.labelIds?.contains(label) != true) {
            return false;
          }
          if (label == CommonMailLabels.draft.id || label == CommonMailLabels.sent.id) {
            return e.threadLastDateIncludeSelf != null;
          } else {
            return e.threadLastDate != null;
          }
        }).toList();

        if (value.isNotEmpty && data.nextPageToken != null) {
          if (label == CommonMailLabels.draft.id || label == CommonMailLabels.sent.id) {
            value.sort((a, b) => a.threadLastDateIncludeSelf!.compareTo(b.threadLastDateIncludeSelf!));
            lastMailTimestamp.add(value.first.threadLastDateIncludeSelf!);
            nextPageTokens[key] = value.first.pageToken;
          } else {
            value.sort((a, b) => a.threadLastDate!.compareTo(b.threadLastDate!));
            lastMailTimestamp.add(value.first.threadLastDate!);
            nextPageTokens[key] = value.first.pageToken;
          }
        }
      }
    });

    lastMailTimestamp.sort((a, b) => a.compareTo(b));

    List<MailEntity> list = [];
    mails.forEach((key, data) {
      List<MailEntity> value = data.messages;
      if (email == null || key == email) {
        if (nextPageTokens.values.whereType<String>().isNotEmpty) {
          if (value.isNotEmpty) {
            list.addAll(
              value.where((e) {
                if (![CommonMailLabels.unread.id, CommonMailLabels.pinned.id, CommonMailLabels.all.id].contains(label) && e.labelIds?.contains(label) != true) {
                  return false;
                }
                if (label == CommonMailLabels.draft.id || label == CommonMailLabels.sent.id) {
                  return e.threadLastDateIncludeSelf?.isAfter(lastMailTimestamp.last) == true;
                } else {
                  return e.threadLastDate?.isAfter(lastMailTimestamp.last) == true;
                }
              }),
            );
          }
        } else {
          list.addAll(
            value.where((e) {
              if (![CommonMailLabels.unread.id, CommonMailLabels.pinned.id, CommonMailLabels.all.id].contains(label) && e.labelIds?.contains(label) != true) {
                return false;
              }
              if (label == CommonMailLabels.draft.id || label == CommonMailLabels.sent.id) {
                return e.threadLastDateIncludeSelf != null;
              } else {
                return e.threadLastDate != null;
              }
            }),
          );
        }
      }
    });

    list.sort((a, b) {
      if (label == CommonMailLabels.draft.id || label == CommonMailLabels.sent.id) {
        return (b.threadLastDateIncludeSelf!).compareTo(a.threadLastDateIncludeSelf!);
      } else {
        return (b.threadLastDate!).compareTo(a.threadLastDate!);
      }
    });

    return list.unique((e) => e.id).unique((e) => e.threadId);
  }
}
