import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:Visir/config/providers.dart';
import 'package:Visir/features/auth/application/auth_controller.dart';
import 'package:Visir/features/common/domain/failures/failure.dart';
import 'package:Visir/features/common/provider.dart';
import 'package:Visir/features/mail/domain/entities/mail_entity.dart';
import 'package:Visir/features/mail/domain/entities/mail_label_entity.dart';
import 'package:Visir/features/mail/infrastructure/models/outlook_mail_label.dart';
import 'package:Visir/features/mail/infrastructure/repositories/mail_repository.dart';
import 'package:Visir/features/mail/providers.dart';
import 'package:Visir/features/preference/application/local_pref_controller.dart';
import 'package:Visir/features/preference/domain/entities/oauth_entity.dart';
import 'package:emoji_extension/emoji_extension.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:googleapis/gmail/v1.dart';
import 'package:riverpod_annotation/experimental/persist.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'mail_label_list_controller.g.dart';

@riverpod
class MailLabelListController extends _$MailLabelListController {
  static String get stringKey => 'global:mail_label_list';
  static Map<String, List<MailLabelEntity>> labels = {};

  late List<OAuthEntity> mailOAuths;
  Map<String, MailLabelListControllerInternal> _controllers = {};
  @override
  Map<String, List<MailLabelEntity>> build() {
    final isSignedIn = ref.watch(authControllerProvider.select((v) => v.requireValue.isSignedIn));
    Map<String, List<MailLabelEntity>> data = {};
    ref.watch(
      localPrefControllerProvider.select((v) {
        final uniqueIds = v.value?.mailOAuths?.map((e) => e.uniqueId).toList() ?? [];
        uniqueIds.sort();
        return uniqueIds.join(',');
      }),
    );
    _controllers.clear();

    mailOAuths = ref.read(localPrefControllerProvider.select((v) => v.value?.mailOAuths ?? []));
    mailOAuths.forEach((e) {
      _controllers[e.uniqueId] = ref.watch(mailLabelListControllerInternalProvider(isSignedIn: isSignedIn, oAuthUniqueId: e.uniqueId).notifier);
      ref.listen(mailLabelListControllerInternalProvider(isSignedIn: isSignedIn, oAuthUniqueId: e.uniqueId).select((v) => v.value ?? {}), (previous, next) {
        data = {...data, ...next};
        updateState(data);
      });
    });

    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      load();
    });
    return data;
  }

  Timer? timer;
  void updateState(Map<String, List<MailLabelEntity>> data) {
    labels = data;
    if (timer == null) state = data;
    timer?.cancel();
    timer = Timer(const Duration(milliseconds: kControllerDebouncMillisecond), () {
      state = data;
      timer = null;
    });
  }

  Future<void> load({bool? mergeNegativeBadge}) async {
    Completer<void> completer = Completer();
    int resultCount = 0;
    ref.read(loadingStatusProvider.notifier).update(stringKey, LoadingState.loading);
    _controllers.forEach((key, value) {
      value
          .load()
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

  Future<void> addDraft(String email) async {
    final oauth = mailOAuths.firstWhere((e) => e.email == email);
    _controllers[oauth.uniqueId]?.addDraft(email);
  }

  Future<void> removeDraft(String email) async {
    final oauth = mailOAuths.firstWhere((e) => e.email == email);
    _controllers[oauth.uniqueId]?.removeDraft(email);
  }

  Future<void> readInbox(List<MailEntity> mails, {int? unreadCount}) async {
    final groupedMails = groupBy(mails, (e) => e.hostEmail);
    groupedMails.entries.forEach((entry) {
      final oauth = mailOAuths.firstWhere((e) => e.email == entry.key);
      _controllers[oauth.uniqueId]?.readInbox(entry.value, unreadCount: unreadCount);
    });
  }

  Future<void> unreadInbox(List<MailEntity> mails) async {
    final groupedMails = groupBy(mails, (e) => e.hostEmail);
    groupedMails.entries.forEach((entry) {
      final oauth = mailOAuths.firstWhere((e) => e.email == entry.key);
      _controllers[oauth.uniqueId]?.unreadInbox(entry.value);
    });
  }

  Future<void> pinLabel(List<MailEntity> mails) async {
    final groupedMails = groupBy(mails, (e) => e.hostEmail);
    groupedMails.entries.forEach((entry) {
      final oauth = mailOAuths.firstWhere((e) => e.email == entry.key);
      _controllers[oauth.uniqueId]?.pinLabel(entry.value);
    });
  }

  Future<void> unpinLabel(List<MailEntity> mails) async {
    final groupedMails = groupBy(mails, (e) => e.hostEmail);
    groupedMails.entries.forEach((entry) {
      final oauth = mailOAuths.firstWhere((e) => e.email == entry.key);
      _controllers[oauth.uniqueId]?.unpinLabel(entry.value);
    });
  }

  Future<void> spamLabel(List<MailEntity> mails) async {
    final groupedMails = groupBy(mails, (e) => e.hostEmail);
    groupedMails.entries.forEach((entry) {
      final oauth = mailOAuths.firstWhere((e) => e.email == entry.key);
      _controllers[oauth.uniqueId]?.spamLabel(entry.value);
    });
  }

  Future<void> unspamLabel(List<MailEntity> mails) async {
    final groupedMails = groupBy(mails, (e) => e.hostEmail);
    groupedMails.entries.forEach((entry) {
      final oauth = mailOAuths.firstWhere((e) => e.email == entry.key);
      _controllers[oauth.uniqueId]?.unspamLabel(entry.value);
    });
  }

  Future<void> addMailLocal(List<MailEntity> mails) async {
    final groupedMails = groupBy(mails, (e) => e.hostEmail);
    groupedMails.entries.forEach((entry) {
      final oauth = mailOAuths.firstWhere((e) => e.email == entry.key);
      _controllers[oauth.uniqueId]?.addMailLocal(entry.value);
    });
  }

  Future<void> removeMailLocal(List<TempMailEntity> mails) async {
    final groupedMails = groupBy(mails, (e) => e.hostEmail);
    groupedMails.entries.forEach((entry) {
      final oauth = mailOAuths.firstWhere((e) => e.email == entry.key);
      _controllers[oauth.uniqueId]?.removeMailLocal(entry.value);
    });
  }

  Future<void> addLabelsLocal(List<MailEntity> mails, List<String> addedLabelIds) async {
    final groupedMails = groupBy(mails, (e) => e.hostEmail);
    groupedMails.entries.forEach((entry) {
      final oauth = mailOAuths.firstWhere((e) => e.email == entry.key);
      _controllers[oauth.uniqueId]?.addLabelsLocal(entry.value, addedLabelIds);
    });
  }

  Future<void> removeLabelsLocal(List<MailEntity> mails, List<String> removedLabelIds) async {
    final groupedMails = groupBy(mails, (e) => e.hostEmail);
    groupedMails.entries.forEach((entry) {
      final oauth = mailOAuths.firstWhere((e) => e.email == entry.key);
      _controllers[oauth.uniqueId]?.removeLabelsLocal(entry.value, removedLabelIds);
    });
  }

  Future<void> clearLabel(String? hostMail, String labelId) async {
    final oauth = mailOAuths.firstWhere((e) => e.email == hostMail);
    _controllers[oauth.uniqueId]?.clearLabel(hostMail, labelId);
  }

  Future<Map<String, String>?> attachMailChangeListener() async {
    if (ref.read(shouldUseMockDataProvider)) return null;
    Completer<Map<String, String>> completer = Completer();
    int resultCount = 0;
    Map<String, String> data = {};
    mailOAuths.forEach((e) {
      _controllers[e.uniqueId]?.attachMailChangeListener().then((e) {
        data = {...data, ...(e ?? {})};
        resultCount++;
        if (resultCount != mailOAuths.length) return;
        completer.complete(data);
      });
    });
    return completer.future;
  }
}

@riverpod
class MailLabelListControllerInternal extends _$MailLabelListControllerInternal {
  late MailRepository _repository;

  OAuthEntity get oauth => ref.read(localPrefControllerProvider.select((value) => value.value?.mailOAuths?.firstWhereOrNull((e) => e.uniqueId == oAuthUniqueId)))!;

  @override
  Future<Map<String, List<MailLabelEntity>>> build({required bool isSignedIn, required String oAuthUniqueId}) async {
    _repository = ref.watch(mailRepositoryProvider);
    if (ref.watch(shouldUseMockDataProvider)) return getMockLabels();

    final userId = ref.watch(authControllerProvider.select((value) => value.requireValue.id));

    await persist(
      ref.watch(storageProvider.future),
      key: '${MailLabelListController.stringKey}:${isSignedIn}:${oAuthUniqueId}',
      encode: (Map<String, List<MailLabelEntity>> state) =>
          jsonEncode(Map.fromEntries(state.entries.map((e) => MapEntry(e.key, e.value.map((e) => e.toJson()).toList())).toList())),
      decode: (String encoded) {
        final trimmed = encoded.trim();
        if (trimmed.isEmpty || trimmed == 'null') {
          return {};
        }
        return Map.fromEntries(
          (jsonDecode(trimmed) as Map<String, dynamic>).entries
              .map((e) => MapEntry(e.key, (e.value as List<dynamic>).map((item) => MailLabelEntity.fromJson(item as Map<String, dynamic>)).toList()))
              .toList(),
        );
      },
      options: StorageOptions(destroyKey: userId),
    ).future;

    return state.value ?? {};
  }

  Map<String, List<MailLabelEntity>> getMockLabels() {
    final mailOAuths = ref.watch(localPrefControllerProvider.select((v) => v.value?.mailOAuths ?? []));
    final labels = Map.fromEntries(
      mailOAuths
          .map(
            (e) => MapEntry(
              e.email,
              CommonMailLabels.values
                  .where((e) => e.id != CommonMailLabels.all.id)
                  .map(
                    (e) => MailLabelEntity(
                      msLabel: OutlookMailLabel(id: e.id, displayName: e.name, wellKnownName: e.name),
                      googleLabel: Label(id: e.id, name: e.name, messagesTotal: 0, messagesUnread: 0),
                    ),
                  )
                  .toList(),
            ),
          )
          .toList(),
    );
    return labels;
  }

  void _updateState(Map<String, List<MailLabelEntity>> data) {
    state = AsyncData(data);
  }

  Future<void> load({bool? mergeNegativeBadge}) async {
    if (ref.read(shouldUseMockDataProvider)) return;

    final _pref = ref.read(localPrefControllerProvider).value;
    if (_pref == null) throw Failure.unauthorized(StackTrace.current);

    final labels = await _repository.fetchLabels(oauth: oauth);

    labels.fold((l) {}, (r) {
      if (mergeNegativeBadge == true) {
        r = r.map(
          (key, value) => MapEntry(
            key,
            value.map((e) {
              final prev = state.value?[key]?.where((l) => l.id == e.id).firstOrNull;
              if (prev == null) return e;
              if (prev.unread < 0) e = e.copyWith(messagesUnread: e.unread + prev.unread);
              if (prev.total < 0) e = e.copyWith(messagesUnread: e.total + prev.total);
              if (prev.wellKnownName != null) e = e.copyWith(wellKnownName: prev.wellKnownName);
              return e;
            }).toList(),
          ),
        );
      }
      _updateState(r);
    });
  }

  Future<void> addDraft(String? email) async {
    final labels = state.value;
    if (labels != null) {
      _updateState(
        labels.map((key, value) {
          return MapEntry(
            key,
            value.map((MailLabelEntity label) {
              if (key == email) {
                if (label.id == CommonMailLabels.draft.id) {
                  return label.copyWith(messagesTotal: label.total + 1);
                }
              }
              return label;
            }).toList(),
          );
        }),
      );
    }
  }

  Future<void> removeDraft(String? email) async {
    final labels = state.value;
    if (labels != null) {
      _updateState(
        labels.map((key, value) {
          return MapEntry(
            key,
            value.map((MailLabelEntity label) {
              if (key == email) {
                if (label.id == CommonMailLabels.draft.id) {
                  return label.copyWith(messagesTotal: label.total - 1);
                }
              }
              return label;
            }).toList(),
          );
        }),
      );
    }
  }

  Future<void> readInbox(List<MailEntity> mails, {int? unreadCount}) async {
    final labels = state.value;
    if (labels != null) {
      _updateState(
        labels.map((key, value) {
          return MapEntry(
            key,
            value.map((MailLabelEntity label) {
              if (mails.any((e) => e.hostEmail == key)) {
                if (label.id == CommonMailLabels.inbox.id) {
                  return label.copyWith(messagesUnread: label.unread - (unreadCount ?? mails.where((e) => e.hostEmail == key && e.isUnread).length));
                }
              }
              return label;
            }).toList(),
          );
        }),
      );
    }
  }

  Future<void> unreadInbox(List<MailEntity> mails) async {
    final labels = state.value;
    if (labels != null) {
      _updateState(
        labels.map((key, value) {
          return MapEntry(
            key,
            value.map((MailLabelEntity label) {
              if (mails.any((e) => e.hostEmail == key)) {
                if (label.id == CommonMailLabels.inbox.id) {
                  return label.copyWith(messagesUnread: label.unread + mails.where((e) => e.hostEmail == key && e.isUnread).length);
                }
              }
              return label;
            }).toList(),
          );
        }),
      );
    }
  }

  Future<void> pinLabel(List<MailEntity> mails) async {
    final labels = state.value;
    if (labels != null) {
      _updateState(
        labels.map((key, value) {
          return MapEntry(
            key,
            value.map((MailLabelEntity label) {
              if (mails.any((e) => e.hostEmail == key)) {
                if (label.id == CommonMailLabels.pinned.id) {
                  return label.copyWith(messagesTotal: label.total + mails.where((e) => e.hostEmail == key).length);
                }
              }
              return label;
            }).toList(),
          );
        }),
      );
    }
  }

  Future<void> unpinLabel(List<MailEntity> mails) async {
    final labels = state.value;
    if (labels != null) {
      _updateState(
        labels.map((key, value) {
          return MapEntry(
            key,
            value.map((MailLabelEntity label) {
              if (mails.any((e) => e.hostEmail == key)) {
                if (label.id == CommonMailLabels.pinned.id) {
                  return label.copyWith(messagesTotal: label.total - mails.where((e) => e.hostEmail == key).length);
                }
              }
              return label;
            }).toList(),
          );
        }),
      );
    }
  }

  Future<void> spamLabel(List<MailEntity> mails) async {
    final labels = state.value;
    if (labels != null) {
      _updateState(
        labels.map((key, value) {
          return MapEntry(
            key,
            value.map((MailLabelEntity label) {
              if (mails.any((e) => e.hostEmail == key)) {
                if (label.id == CommonMailLabels.spam.id) {
                  return label.copyWith(
                    messagesTotal: label.total + mails.where((e) => e.hostEmail == key).length,
                    messagesUnread: label.unread + mails.where((e) => e.hostEmail == key && e.isUnread).length,
                  );
                }
              }
              return label;
            }).toList(),
          );
        }),
      );
    }
  }

  Future<void> unspamLabel(List<MailEntity> mails) async {
    final labels = state.value;
    if (labels != null) {
      _updateState(
        labels.map((key, value) {
          return MapEntry(
            key,
            value.map((MailLabelEntity label) {
              if (mails.any((e) => e.hostEmail == key)) {
                if (label.id == CommonMailLabels.spam.id) {
                  return label.copyWith(
                    messagesTotal: label.total - mails.where((e) => e.hostEmail == key).length,
                    messagesUnread: label.unread - mails.where((e) => e.hostEmail == key && e.isUnread).length,
                  );
                }
              }
              return label;
            }).toList(),
          );
        }),
      );
    }
  }

  Future<void> addMailLocal(List<MailEntity> mails) async {
    final labels = state.value;
    if (labels != null) {
      _updateState(
        labels.map((key, value) {
          return MapEntry(
            key,
            value.map((MailLabelEntity label) {
              if (mails.any((e) => e.hostEmail == key)) {
                if (mails.any((e) => e.labelIds?.contains(label.id) == true) && label.id != CommonMailLabels.draft.id) {
                  return label.copyWith(
                    messagesTotal: max(0, label.total) + mails.where((e) => e.hostEmail == key).length,
                    messagesUnread: mails.any((e) => e.isUnread) ? max(0, label.unread) + mails.where((e) => e.hostEmail == key && e.isUnread).length : max(0, label.unread),
                  );
                }
              }
              return label;
            }).toList(),
          );
        }),
      );
    }
  }

  Future<void> removeMailLocal(List<TempMailEntity> mails) async {
    final labels = state.value;
    if (labels != null) {
      _updateState(
        labels.map((key, value) {
          return MapEntry(
            key,
            value.map((MailLabelEntity label) {
              if (mails.any((e) => e.hostEmail == key)) {
                if (mails.any((e) => e.labelIds.contains(label.id) == true) && label.id != CommonMailLabels.draft.id) {
                  return label.copyWith(
                    messagesTotal: label.total - mails.where((e) => e.hostEmail == key).length,
                    messagesUnread: label.unread - mails.where((e) => e.hostEmail == key && e.labelIds.contains(CommonMailLabels.unread.id)).length,
                  );
                }
              }
              return label;
            }).toList(),
          );
        }),
      );
    }
  }

  Future<void> addLabelsLocal(List<MailEntity> mails, List<String> addedLabelIds) async {
    final labels = state.value;
    if (labels != null) {
      _updateState(
        labels.map((key, value) {
          return MapEntry(
            key,
            value.map((MailLabelEntity label) {
              if (mails.any((e) => e.hostEmail == key)) {
                if (addedLabelIds.contains(label.id) && label.id != CommonMailLabels.draft.id) {
                  return label.copyWith(
                    messagesTotal: label.total + mails.where((e) => e.hostEmail == key).length,
                    messagesUnread: addedLabelIds.contains(CommonMailLabels.unread.id) ? label.unread + mails.where((e) => e.hostEmail == key && e.isUnread).length : label.unread,
                  );
                }
              }
              return label;
            }).toList(),
          );
        }),
      );
    }
  }

  Future<void> removeLabelsLocal(List<MailEntity> mails, List<String> removedLabelIds) async {
    final labels = state.value;
    if (labels != null) {
      _updateState(
        labels.map((key, value) {
          return MapEntry(
            key,
            value.map((MailLabelEntity label) {
              if (mails.any((e) => e.hostEmail == key)) {
                if (removedLabelIds.contains(label.id) && label.id != CommonMailLabels.draft.id) {
                  return label.copyWith(
                    messagesTotal: label.total - mails.where((e) => e.hostEmail == key).length,
                    messagesUnread: label.unread - mails.where((e) => e.hostEmail == key && e.labelIds?.contains(CommonMailLabels.unread.id) == true).length,
                  );
                }
              }
              return label;
            }).toList(),
          );
        }),
      );
    }
  }

  Future<void> clearLabel(String? hostMail, String labelId) async {
    final labels = state.value;
    if (labels != null) {
      _updateState(
        labels.map((key, value) {
          if (hostMail != null && key != hostMail) return MapEntry(key, value);
          return MapEntry(
            key,
            value.map((MailLabelEntity label) {
              if (labelId == label.id) {
                return label.copyWith(messagesTotal: 0, messagesUnread: 0);
              }

              return label;
            }).toList(),
          );
        }),
      );
    }
  }

  Future<Map<String, String>?> attachMailChangeListener() async {
    if (ref.read(shouldUseMockDataProvider)) return null;
    final user = ref.read(authControllerProvider).requireValue;
    final pref = ref.read(localPrefControllerProvider).value;
    if (pref == null) throw Failure.unauthorized(StackTrace.current);
    final result = await _repository.attachMailChangeListener(user: user, oauth: oauth);
    return result.fold((l) => null, (r) => r);
  }
}
