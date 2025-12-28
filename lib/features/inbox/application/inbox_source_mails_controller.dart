import 'dart:convert';

import 'package:Visir/config/providers.dart';
import 'package:Visir/features/auth/application/auth_controller.dart';
import 'package:Visir/features/auth/domain/entities/user_entity.dart';
import 'package:Visir/features/common/presentation/utils/constants.dart';
import 'package:Visir/features/common/presentation/utils/extensions/list_extension.dart';
import 'package:Visir/features/common/provider.dart';
import 'package:Visir/features/mail/application/mail_list_controller.dart';
import 'package:Visir/features/mail/domain/entities/mail_entity.dart';
import 'package:Visir/features/mail/domain/entities/mail_fetch_result_entity.dart';
import 'package:Visir/features/mail/domain/entities/mail_label_entity.dart';
import 'package:Visir/features/mail/infrastructure/models/outlook_mail_message.dart';
import 'package:Visir/features/mail/infrastructure/repositories/mail_repository.dart';
import 'package:Visir/features/mail/providers.dart';
import 'package:microsoft_graph_api/models/models.dart' as Ms;
import 'package:Visir/features/preference/application/local_pref_controller.dart';
import 'package:Visir/features/preference/domain/entities/oauth_entity.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/experimental/persist.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:googleapis/gmail/v1.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'inbox_source_mails_controller.g.dart';

@riverpod
class InboxSourceMailsController extends _$InboxSourceMailsController {
  static String stringKey = '${TabType.home.name}:inbox_source_mail';
  late MailRepository _mailRepository;

  DateTime get date => DateTime(year, month, day);

  OAuthEntity? get oauth => ref.read(localPrefControllerProvider.select((value) => value.value?.mailOAuths?.firstWhereOrNull((e) => e.uniqueId == oauthUniqueId)));

  MailInboxFilterType get inboxFilterTypes => ref.read(authControllerProvider.select((v) => v.requireValue.mailInboxFilterTypes?[oauth?.email] ?? MailInboxFilterType.all));
  List<String> get inboxFilterLabelIds => ref.read(authControllerProvider.select((v) => v.requireValue.mailInboxFilterLabelIds?[oauth?.email] ?? []));

  @override
  Future<MailListResultEntity> build({
    required bool isSearch,
    required String oauthUniqueId,
    required int year,
    required int month,
    required int day,
    required bool isSignedIn,
  }) async {
    _mailRepository = ref.watch(mailRepositoryProvider);

    if (ref.watch(shouldUseMockDataProvider)) {
      return MailListResultEntity(
        mails: await getMockMails(date: date),
        email: '',
        label: CommonMailLabels.inbox.id,
      );
    }

    if (oauth == null) {
      return MailListResultEntity(mails: {}, email: '', label: CommonMailLabels.inbox.id);
    }

    // decode 콜백에서 사용할 값들을 미리 캡처
    final oauthEmail = oauth!.email;

    await persist(
      ref.watch(storageProvider.future),
      key: '${stringKey}:${isSignedIn}:${oauthUniqueId}:${this.isSearch ? 'search' : '${year}_${month}_${day}'}',
      encode: (MailListResultEntity state) => jsonEncode(state.toJson()),
      decode: (String encoded) {
        final trimmed = encoded.trim();
        if (trimmed.isEmpty || trimmed == 'null') {
          return MailListResultEntity(mails: {}, email: oauthEmail, label: CommonMailLabels.inbox.id);
        }
        return MailListResultEntity.fromJson(jsonDecode(trimmed) as Map<String, dynamic>);
      },
    ).future;

    return state.value ?? MailListResultEntity(mails: {}, email: oauth!.email, label: CommonMailLabels.inbox.id);
  }

  Future<Map<String, MailFetchResultEntity>> getMockMails({DateTime? date, String? query}) async {
    await Future.delayed(Duration(seconds: 1));
    final _label = CommonMailLabels.inbox.id;
    return Future.wait([rootBundle.loadString('assets/mock/mail/gmail/index.json'), rootBundle.loadString('assets/mock/mail/outlook/index.json')]).then((values) async {
      final gmailIds = (jsonDecode(values[0]) as List<dynamic>).map((e) => e['id'] as String).toList();
      final outlookIds = (jsonDecode(values[1]) as List<dynamic>).map((e) => e['messageIds'] as List<dynamic>).expand((e) => e).toList();
      final gmailValues = await Future.wait(gmailIds.map((e) => rootBundle.loadString('assets/mock/mail/gmail/threads/$e.json')));
      final outlookValues = await Future.wait(outlookIds.map((e) => rootBundle.loadString('assets/mock/mail/outlook/threads/$e.json')));
      // 이메일 주소에서 기본 이름 생성 함수
      String generateDefaultNameFromEmail(String email) {
        final localPart = email.split('@').first;
        // + 기호 이전 부분만 사용
        final namePart = localPart.split('+').first;
        // 점(.)으로 분리하여 각 단어의 첫 글자를 대문자로
        final parts = namePart.split('.');
        return parts
            .map((part) {
              if (part.isEmpty) return '';
              return part[0].toUpperCase() + part.substring(1);
            })
            .join(' ');
      }

      final gmailThreads = gmailValues
          .map((e) {
            final decoded = jsonDecode(e);
            final messages = (decoded['messages'] as List<dynamic>).map((msg) {
              final msgMap = Map<String, dynamic>.from(msg);
              // payload의 headers에서 "To" 헤더 찾기
              if (msgMap['payload'] != null && msgMap['payload']['headers'] != null) {
                final headers = (msgMap['payload']['headers'] as List<dynamic>).map((header) {
                  final headerMap = Map<String, dynamic>.from(header);
                  if ((headerMap['name'] as String?)?.toLowerCase() == 'to') {
                    final toValue = headerMap['value'] as String? ?? '';
                    // 이메일 주소 추출
                    final emailPattern = RegExp(r'<([^>]+)>');
                    final matches = emailPattern.allMatches(toValue);
                    if (matches.isNotEmpty) {
                      final email = matches.first.group(1) ?? '';
                      // 이름이 비어있거나 null인 경우 기본 이름 생성
                      final namePart = toValue.replaceAll('<${email}>', '').replaceAll('"', '').trim();
                      if (namePart.isEmpty || namePart == 'null') {
                        final defaultName = generateDefaultNameFromEmail(email);
                        headerMap['value'] = '$defaultName <$email>';
                      }
                    }
                  }
                  return headerMap;
                }).toList();
                msgMap['payload'] = {...msgMap['payload'], 'headers': headers};
              }
              return msgMap;
            }).toList();
            return {'messages': messages};
          })
          .map((e) => e['messages'] as List<dynamic>)
          .map((e) => e.map((e) => MailEntity.fromGmail(message: Message.fromJson(e), hostEmail: fakeUserEmail)).toList())
          .map((e) => e.lastWhereOrNull((e) => e.labelIds?.contains(_label) == true)?.copyWith(threads: e))
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

            // toRecipients의 이름이 비어있으면 기본 이름 생성
            final updatedToRecipients = outlook.toRecipients?.map((recipient) {
              final email = recipient.emailAddress?.address ?? '';
              final name = recipient.emailAddress?.name ?? '';
              if (email.isNotEmpty && (name.isEmpty || name == 'null')) {
                final defaultName = generateDefaultNameFromEmail(email);
                // 새로운 Recipient와 EmailAddress 인스턴스 생성
                return Ms.Recipient(
                  emailAddress: Ms.EmailAddress(address: email, name: defaultName),
                );
              }
              return recipient;
            }).toList();

            return MailEntity.fromOutlook(
              message: outlook.copyWith(labelIds: labelIds, toRecipients: updatedToRecipients),
              hostEmail: companyEmail,
            );
          })
          .whereType<MailEntity>()
          .toList();

      final threads = groupBy(outlookThreadsData, (e) => e.threadId);
      final outlookThreads = threads
          .map((key, value) => MapEntry(key, value.lastWhereOrNull((e) => e.labelIds?.contains(_label) == true)?.copyWith(threads: value)))
          .values
          .whereType<MailEntity>()
          .toList();

      // Mock 데이터 사용 시 날짜 필터링 완화 (최근 7일 이내 데이터 포함)
      final now = DateTime.now();
      final sevenDaysAgo = now.subtract(const Duration(days: 7));

      return {
        fakeUserEmail: MailFetchResultEntity(
          messages: gmailThreads
              .where(
                (e) =>
                    e.labelIds?.contains(_label) == true &&
                    (date != null
                        ? (e.date != null && (DateUtils.isSameDay(e.date!, date) || (e.date!.isAfter(sevenDaysAgo) && e.date!.isBefore(now.add(const Duration(days: 1))))))
                        : query != null
                        ? e.subject?.contains(query) == true || e.snippet?.contains(query) == true || e.from?.name?.contains(query) == true || e.from?.email.contains(query) == true
                        : e.date != null && e.date!.isAfter(sevenDaysAgo)),
              )
              .toList(),
          nextPageToken: null,
          hasMore: false,
        ),
        companyEmail: MailFetchResultEntity(
          messages: outlookThreads
              .where(
                (e) =>
                    e.labelIds?.contains(_label) == true &&
                    (date != null
                        ? (e.date != null && (DateUtils.isSameDay(e.date!, date) || (e.date!.isAfter(sevenDaysAgo) && e.date!.isBefore(now.add(const Duration(days: 1))))))
                        : query != null
                        ? e.subject?.contains(query) == true || e.snippet?.contains(query) == true || e.from?.name?.contains(query) == true || e.from?.email.contains(query) == true
                        : e.date != null && e.date!.isAfter(sevenDaysAgo)),
              )
              .toList(),
          nextPageToken: null,
          hasMore: false,
        ),
      };
    });
  }

  Future<bool> load({bool? refresh, String? query}) async {
    if (oauth == null) return false;
    if (ref.read(shouldUseMockDataProvider)) {
      final mockMails = await getMockMails(date: query != null ? null : date, query: query);
      state = AsyncValue.data(
        MailListResultEntity(mails: refresh == true ? mockMails : {...(state.value?.mails ?? {}), ...mockMails}, email: oauth!.email, label: CommonMailLabels.inbox.id),
      );
      return true;
    }
    List<MailEntity> mails = refresh == true ? [] : state.value?.list ?? [];

    final user = ref.read(authControllerProvider.select((v) => v.requireValue));
    final groupedMails = groupBy(mails, (e) => e.hostEmail);
    final mailPageTokens = groupedMails.keys.isEmpty
        ? null
        : groupedMails.map((key, value) {
            final list = [...value];
            list.sort((a, b) => (a.date ?? DateTime(1970)).compareTo(b.date ?? DateTime(1970)));
            return MapEntry(key, list.last.pageToken);
          });
    final _date = query != null ? null : date;
    final mailResult = await _mailRepository.fetchMailsForLabel(
      oauth: oauth!,
      user: user,
      email: null,
      pageToken: mailPageTokens,
      q: query ?? '',
      startDate: _date,
      endDate: _date?.add(Duration(days: 1)),
      isInbox: true,
    );

    return mailResult.fold(
      (l) {
        return false;
      },
      (r) {
        state = AsyncValue.data(MailListResultEntity(mails: refresh == true ? r : {...(state.value?.mails ?? {}), ...r}, email: oauth!.email, label: CommonMailLabels.inbox.id));
        return true;
      },
    );
  }

  Future<void> loadRecent() async {
    if (oauth == null) return;
    if (ref.read(shouldUseMockDataProvider)) return;
    final user = ref.read(authControllerProvider).requireValue;
    if (isSearch) return;

    final mails = (state.value?.list ?? <MailEntity>[]);
    final groupedMails = groupBy(mails, (e) => e.hostEmail);
    final mailPageTokens = groupedMails.keys.isEmpty
        ? null
        : groupedMails.map((key, value) {
            final list = [...value];
            list.sort((a, b) => (a.date ?? DateTime(1970)).compareTo(b.date ?? DateTime(1970)));
            return MapEntry(key, list.first.pageToken);
          });

    final mailResult = await _mailRepository.fetchMailsForLabel(
      oauth: oauth!,
      user: user,
      labelId: CommonMailLabels.inbox.id,
      email: null,
      pageToken: mailPageTokens,
      q: '',
      startDate: date,
      endDate: date.add(Duration(days: 1)),
      isInbox: true,
    );

    mailResult.fold((l) => false, (r) {
      state = AsyncValue.data(MailListResultEntity(mails: {...(state.value?.mails ?? {}), ...r}, email: oauth!.email, label: CommonMailLabels.inbox.id));
      return true;
    });
  }

  void upsertMailInboxLocally(List<MailEntity> mails) async {
    final user = ref.read(authControllerProvider).requireValue;
    final mailInboxFilter = user.userMailInboxFilterTypes;
    final mailInboxFilterLabels = user.mailInboxFilterLabelIds ?? {};
    final oauths = ref.read(localPrefControllerProvider.select((v) => v.value?.mailOAuths)) ?? [];
    final oauth = oauths.where((o) => mails.any((e) => o.email == e.hostEmail)).firstOrNull;
    if (oauth == null) return;
    final inboxFilter = mailInboxFilter['${oauth.email}'];
    final inboxFilterLabels = mailInboxFilterLabels['${oauth.email}'] ?? [];
    if (inboxFilter == MailInboxFilterType.none) return;
    if (inboxFilter == MailInboxFilterType.withSpecificLables && mails.where((e) => (e.labelIds ?? []).where((e) => inboxFilterLabels.contains(e)).isNotEmpty != true).isNotEmpty)
      return;
    if (inboxFilter == MailInboxFilterType.all && mails.where((e) => !(e.labelIds ?? []).contains(CommonMailLabels.inbox.id)).isNotEmpty) return;
    final prevFetchResult = state.value?.mails[oauth.email];
    state = AsyncData(
      MailListResultEntity(
        mails: {
          oauth.email: MailFetchResultEntity(
            messages: [...mails, ...(prevFetchResult?.messages ?? <MailEntity>[])].unique((e) => e.uniqueId).toList(),
            hasMore: prevFetchResult?.hasMore ?? false,
            nextPageToken: prevFetchResult?.nextPageToken,
            hasRecent: prevFetchResult?.hasRecent,
            isRateLimited: prevFetchResult?.isRateLimited,
          ),
        },
        email: state.value?.email,
        label: CommonMailLabels.inbox.id,
      ),
    );
  }

  void removeMailInboxLocally(String mailId) {
    if (oauth == null) return;
    final prevFetchResult = state.value?.mails[oauth!.email];
    state = AsyncData(
      MailListResultEntity(
        mails: {
          oauth!.email: MailFetchResultEntity(
            messages: (prevFetchResult?.messages ?? []).where((e) => e.id != mailId).toList(),
            hasMore: prevFetchResult?.hasMore ?? false,
            nextPageToken: prevFetchResult?.nextPageToken,
            hasRecent: prevFetchResult?.hasRecent,
            isRateLimited: prevFetchResult?.isRateLimited,
          ),
        },
        email: state.value?.email,
        label: CommonMailLabels.inbox.id,
      ),
    );
  }

  void readMailLocally(List<String> threadIds) {
    if (oauth == null) return;
    final prevFetchResult = state.value?.mails[oauth!.email];
    state = AsyncData(
      MailListResultEntity(
        mails: {
          oauth!.email: MailFetchResultEntity(
            messages: (prevFetchResult?.messages ?? []).map((e) {
              if (threadIds.contains(e.threadId)) {
                return e.copyWith(isUnread: false);
              }
              return e;
            }).toList(),
            hasMore: prevFetchResult?.hasMore ?? false,
            nextPageToken: prevFetchResult?.nextPageToken,
            hasRecent: prevFetchResult?.hasRecent,
            isRateLimited: prevFetchResult?.isRateLimited,
          ),
        },
        email: state.value?.email,
        label: CommonMailLabels.inbox.id,
      ),
    );
  }

  void removeMailLocally(List<String> threadIds) {
    if (oauth == null) return;
    final prevFetchResult = state.value?.mails[oauth!.email];
    state = AsyncData(
      MailListResultEntity(
        mails: {
          oauth!.email: MailFetchResultEntity(
            messages: (prevFetchResult?.messages ?? []).where((e) => !threadIds.contains(e.threadId)).toList(),
            hasMore: prevFetchResult?.hasMore ?? false,
            nextPageToken: prevFetchResult?.nextPageToken,
            hasRecent: prevFetchResult?.hasRecent,
            isRateLimited: prevFetchResult?.isRateLimited,
          ),
        },
        email: state.value?.email,
        label: CommonMailLabels.inbox.id,
      ),
    );
  }

  void unreadMailLocally(List<String> threadIds) {
    if (oauth == null) return;
    final prevFetchResult = state.value?.mails[oauth!.email];
    state = AsyncData(
      MailListResultEntity(
        mails: {
          oauth!.email: MailFetchResultEntity(
            messages: (prevFetchResult?.messages ?? []).map((e) {
              if (threadIds.contains(e.threadId)) {
                return e.copyWith(isUnread: true);
              }
              return e;
            }).toList(),
            hasMore: prevFetchResult?.hasMore ?? false,
            nextPageToken: prevFetchResult?.nextPageToken,
            hasRecent: prevFetchResult?.hasRecent,
            isRateLimited: prevFetchResult?.isRateLimited,
          ),
        },
        email: state.value?.email,
        label: CommonMailLabels.inbox.id,
      ),
    );
  }

  void pinMailLocally(List<String> threadIds) {
    if (oauth == null) return;
    final prevFetchResult = state.value?.mails[oauth!.email];
    state = AsyncData(
      MailListResultEntity(
        mails: {
          oauth!.email: MailFetchResultEntity(
            messages: (prevFetchResult?.messages ?? []).map((e) {
              if (threadIds.contains(e.threadId)) {
                return e.copyWith(isPinned: true);
              }
              return e;
            }).toList(),
            hasMore: prevFetchResult?.hasMore ?? false,
            nextPageToken: prevFetchResult?.nextPageToken,
            hasRecent: prevFetchResult?.hasRecent,
            isRateLimited: prevFetchResult?.isRateLimited,
          ),
        },
        email: state.value?.email,
        label: CommonMailLabels.inbox.id,
      ),
    );
  }

  void unpinMailLocally(List<String> threadIds) {
    if (oauth == null) return;
    final prevFetchResult = state.value?.mails[oauth!.email];
    state = AsyncData(
      MailListResultEntity(
        mails: {
          oauth!.email: MailFetchResultEntity(
            messages: (prevFetchResult?.messages ?? []).map((e) {
              if (threadIds.contains(e.threadId)) {
                return e.copyWith(isPinned: false);
              }
              return e;
            }).toList(),
            hasMore: prevFetchResult?.hasMore ?? false,
            nextPageToken: prevFetchResult?.nextPageToken,
            hasRecent: prevFetchResult?.hasRecent,
            isRateLimited: prevFetchResult?.isRateLimited,
          ),
        },
        email: state.value?.email,
        label: CommonMailLabels.inbox.id,
      ),
    );
  }
}
