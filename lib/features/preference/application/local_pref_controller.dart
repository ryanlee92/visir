import 'dart:convert';

import 'package:Visir/config/providers.dart';
import 'package:Visir/features/auth/application/auth_controller.dart';
import 'package:Visir/features/common/presentation/utils/constants.dart';
import 'package:Visir/features/common/provider.dart';
import 'package:Visir/features/preference/domain/entities/local_pref_entity.dart';
import 'package:Visir/features/preference/domain/entities/oauth_entity.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/experimental/persist.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'local_pref_controller.g.dart';

final localPrefControllerProvider = Provider.autoDispose<AsyncValue<LocalPrefEntity>>((ref) {
  final isSignedIn = ref.watch(authControllerProvider.select((v) => v.value?.isSignedIn ?? false));
  return ref.watch(localPrefControllerInternalProvider(isSignedIn: isSignedIn));
});

final _localPrefControllerNotifierProvider = Provider.autoDispose<LocalPrefControllerInternal>((ref) {
  final isSignedIn = ref.watch(authControllerProvider.select((v) => v.value?.isSignedIn ?? false));
  return ref.watch(localPrefControllerInternalProvider(isSignedIn: isSignedIn).notifier);
});

extension LocalPrefControllerProviderX on ProviderListenable<AsyncValue<LocalPrefEntity>> {
  ProviderListenable<LocalPrefControllerInternal> get notifier => _localPrefControllerNotifierProvider;
}

@riverpod
class LocalPrefControllerInternal extends _$LocalPrefControllerInternal {
  bool isFirstLoad = false;

  @override
  Future<LocalPrefEntity> build({required bool isSignedIn}) async {
    if (ref.read(shouldUseMockDataProvider)) return fakeLocalPref;

    // 순환 의존성 방지를 위해 authControllerProvider를 직접 watch하지 않고
    // isSignedIn 파라미터를 사용하여 userId를 얻기
    final userId = ref.read(authControllerProvider.select((v) => v.value!.id));

    await persist(
      ref.watch(storageProvider.future),
      key: 'local_pref_${isSignedIn}',
      encode: (LocalPrefEntity state) => jsonEncode(state.toJson()),
      decode: (String encoded) => LocalPrefEntity.fromJson(jsonDecode(encoded) as Map<String, dynamic>),
      options: StorageOptions(cacheTime: StorageCacheTime.unsafe_forever, destroyKey: userId),
    ).future;

    if (state.value == null || state.value == LocalPrefEntity()) {
      isFirstLoad = true;
      return LocalPrefEntity();
    }

    return state.value!;
  }

  void _updateState({required LocalPrefEntity pref}) {
    if (pref == state.value) return;
    state = AsyncData(pref);
  }

  Future<void> set({
    List<OAuthEntity>? calendarOAuths,
    List<OAuthEntity>? mailOAuths,
    List<OAuthEntity>? messengerOAuths,
    bool? removeNotificationPayload,
    Map<String, String>? notificationPayload,
    Map<String, bool>? showCalendarNotifications,
    Map<String, MailNotificationFilterType>? mailNotificationFilterTypes,
    Map<String, List<String>>? mailNotificationFilterLabelIds,
    Map<String, MessagNotificationFilterType>? messageDmNotificationFilterTypes,
    Map<String, MessagNotificationFilterType>? messageChannelNotificationFilterTypes,
    Map<String, String?>? googleConnectionSyncToken,
    List<Map<String, String?>>? quickLinks,
    Map<String, String>? aiApiKeys,
    Map<String, dynamic>? selectedAgentModel,
    Map<String, String>? calendarType,
    Map<String, double>? calendarIntervalScale,
    List<String>? lastUsedCalendarId,
    List<String>? lastUsedProjectId,
    Map<String, String>? chatChannelStateList,
    Map<String, List<String>>? chatLastChannel,
    Map<String, String>? inboxSuggestionSort,
    Map<String, String>? inboxSuggestionFilter,
  }) async {
    final pref = state.value;
    final basePref = pref ?? const LocalPrefEntity();

    // copyWith에 null이 아닌 경우에만 전달하여 기존 값이 덮어씌워지지 않도록 함
    // Freezed의 copyWith는 null을 전달하면 해당 필드를 null로 설정하므로,
    // null이 아닐 때만 전달하거나 기존 값을 유지해야 함
    final newPref = basePref.copyWith(
      calendarOAuths: calendarOAuths ?? basePref.calendarOAuths,
      mailOAuths: mailOAuths ?? basePref.mailOAuths,
      messengerOAuths: messengerOAuths ?? basePref.messengerOAuths,
      notificationPayload: removeNotificationPayload == true ? null : (notificationPayload ?? basePref.notificationPayload),
      showCalendarNotifications: showCalendarNotifications ?? basePref.showCalendarNotifications,
      mailNotificationFilterTypes: mailNotificationFilterTypes ?? basePref.mailNotificationFilterTypes,
      mailNotificationFilterLabelIds: mailNotificationFilterLabelIds ?? basePref.mailNotificationFilterLabelIds,
      messageDmNotificationFilterTypes: messageDmNotificationFilterTypes ?? basePref.messageDmNotificationFilterTypes,
      messageChannelNotificationFilterTypes: messageChannelNotificationFilterTypes ?? basePref.messageChannelNotificationFilterTypes,
      googleConnectionSyncToken: googleConnectionSyncToken ?? basePref.googleConnectionSyncToken,
      quickLinks: quickLinks ?? basePref.quickLinks,
      aiApiKeys: aiApiKeys ?? basePref.aiApiKeys,
      selectedAgentModel: selectedAgentModel ?? basePref.selectedAgentModel,
      calendarType: calendarType ?? (basePref.prefCalendarType.isEmpty ? null : basePref.prefCalendarType),
      calendarIntervalScale: calendarIntervalScale ?? (basePref.prefCalendarIntervalScale.isEmpty ? null : basePref.prefCalendarIntervalScale),
      lastUsedCalendarId: lastUsedCalendarId ?? (basePref.prefLastUsedCalendarId.isEmpty ? null : basePref.prefLastUsedCalendarId),
      lastUsedProjectId: lastUsedProjectId ?? (basePref.prefLastUsedProjectId.isEmpty ? null : basePref.prefLastUsedProjectId),
      chatChannelStateList: chatChannelStateList ?? (basePref.prefChatChannelStateList.isEmpty ? null : basePref.prefChatChannelStateList),
      chatLastChannel: chatLastChannel ?? (basePref.prefChatLastChannel.isEmpty ? null : basePref.prefChatLastChannel),
      inboxSuggestionSort: inboxSuggestionSort ?? (basePref.prefInboxSuggestionSort.isEmpty ? null : basePref.prefInboxSuggestionSort),
      inboxSuggestionFilter: inboxSuggestionFilter ?? (basePref.prefInboxSuggestionFilter.isEmpty ? null : basePref.prefInboxSuggestionFilter),
    );

    _updateState(pref: newPref);
  }
}
