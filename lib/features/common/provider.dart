import 'dart:convert';

import 'package:Visir/config/providers.dart';
import 'package:Visir/features/auth/application/auth_controller.dart';
import 'package:Visir/features/common/domain/entities/ai_provider_entity.dart';
import 'package:Visir/features/inbox/domain/entities/agent_model_entity.dart';
import 'package:Visir/features/calendar/presentation/widgets/calendar_sidebar.dart';
import 'package:Visir/features/chat/presentation/widgets/chat_sidebar.dart';
import 'package:Visir/features/common/presentation/utils/extensions/platform_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/common/presentation/widgets/mesh_loading_background.dart';
import 'package:Visir/features/common/presentation/widgets/mobile_scaffold.dart';
import 'package:Visir/features/inbox/presentation/widgets/inbox_sidebar.dart';
import 'package:Visir/features/mail/presentation/widgets/mail_side_bar.dart';
import 'package:Visir/features/preference/application/local_pref_controller.dart';
import 'package:Visir/features/preference/domain/entities/local_pref_entity.dart' show InboxLastCreateEventType;
import 'package:Visir/features/time_saved/presentation/screens/time_saved_screen.dart' show TimeSavedViewType;
import 'package:Visir/features/task/presentation/widgets/task_side_bar.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'provider.g.dart';

EdgeInsets get scrollViewBottomPadding => EdgeInsets.only(bottom: Utils.mainContext.padding.bottom + 60);

MeshLoadingBackground meshLoadingBackground = const MeshLoadingBackground();

@Riverpod(keepAlive: true)
class ResizableClosableWidget extends _$ResizableClosableWidget {
  @override
  ResizableWidget? build(TabType tabType) {
    return null;
  }

  void setWidget(ResizableWidget? widget) {
    state = widget;
  }
}

class ResizableWidget {
  final Widget? widget;
  final double? minWidth;

  ResizableWidget({required this.widget, required this.minWidth});
}

@Riverpod(keepAlive: true)
class ResizableClosableDrawer extends _$ResizableClosableDrawer {
  bool get breakpoint => Utils.mainContext.screenSize.width < 1200;
  Widget? saved;
  bool showSidebar = false;

  @override
  Widget? build(TabType tabType) {
    showSidebar = ref.watch(desktopShowSidebarProvider);

    switch (tabType) {
      case TabType.chat:
        saved = ChatSideBar(tabType: tabType);
      case TabType.mail:
        saved = MailSideBar(tabType: tabType);
      case TabType.calendar:
        saved = CalendarSideBar(tabType: tabType);
      case TabType.task:
        saved = TaskSideBar(tabType: tabType);
      case TabType.home:
        saved = InboxSideBar(tabType: tabType);
    }

    saved = Row(
      children: [
        Container(
          width: 0.5,
          margin: EdgeInsets.only(top: 6, bottom: 6, right: 6, left: 3),
          height: double.infinity,
          color: Utils.mainContext.surfaceVariant.withValues(alpha: 0.2),
        ),
        Expanded(child: saved ?? SizedBox.shrink()),
      ],
    );

    if (breakpoint) return null;
    if (!showSidebar) return null;
    return saved;
  }

  void update() {
    if (breakpoint || !showSidebar) {
      state = null;
    } else {
      state = saved;
    }
  }
}

final defaultRatio = PlatformX.isMobile ? kMobileDevicePixelRatio : 1.0;

@Riverpod(keepAlive: true)
class ZoomRatio extends _$ZoomRatio {
  @override
  double build() {
    if (PlatformX.isMobile) return kMobileDevicePixelRatio;
    if (ref.watch(shouldUseMockDataProvider)) return defaultRatio;

    // sharedPref에서 읽기
    final sharedPrefAsync = ref.read(sharedPreferencesProvider);
    final sharedPref = sharedPrefAsync.asData?.value;
    if (sharedPref == null) return defaultRatio;
    return sharedPref.getDouble('zoom_ratio') ?? defaultRatio;
  }

  void setRatio(double ratio) async {
    if (PlatformX.isMobile) return;
    // sharedPref에 저장
    final sharedPref = await ref.read(sharedPreferencesProvider.future);
    await sharedPref.setDouble('zoom_ratio', ratio);
    state = ratio;
  }
}

@Riverpod(keepAlive: true)
class WindowSize extends _$WindowSize {
  @override
  Future<Rect?> build() async {
    // sharedPref에서 읽기
    final sharedPref = await ref.read(sharedPreferencesProvider.future);
    final x = sharedPref.getDouble('window_size_x');
    final y = sharedPref.getDouble('window_size_y');
    final width = sharedPref.getDouble('window_size_width');
    final height = sharedPref.getDouble('window_size_height');

    if (x == null || y == null || width == null || height == null) return null;
    return Rect.fromLTWH(x, y, width, height);
  }

  void updateSize(Rect size) async {
    // sharedPref에 저장
    final sharedPref = await ref.read(sharedPreferencesProvider.future);
    await sharedPref.setDouble('window_size_x', size.left);
    await sharedPref.setDouble('window_size_y', size.top);
    await sharedPref.setDouble('window_size_width', size.width);
    await sharedPref.setDouble('window_size_height', size.height);
    // WindowSize provider의 state도 직접 업데이트하여 즉시 반영
    state = AsyncData(Rect.fromLTWH(size.left, size.top, size.width, size.height));
  }
}

@Riverpod(keepAlive: true)
class DesktopShowSidebar extends _$DesktopShowSidebar {
  @override
  bool build() {
    if (ref.watch(shouldUseMockDataProvider)) return true;

    // sharedPref에서 읽기 (동기적으로 읽기 위해 asData 사용)
    final sharedPrefAsync = ref.read(sharedPreferencesProvider);
    final sharedPref = sharedPrefAsync.asData?.value;
    if (sharedPref == null) return true;
    return sharedPref.getBool('desktop_show_sidebar') ?? true;
  }

  void update(bool show) async {
    // sharedPref에 저장
    final sharedPref = await ref.read(sharedPreferencesProvider.future);
    await sharedPref.setBool('desktop_show_sidebar', show);
    state = show;
  }
}

@Riverpod(keepAlive: true)
class TabLoaded extends _$TabLoaded {
  @override
  bool build(TabType tabType) {
    return false;
  }

  void update(bool loaded) {
    state = loaded;
  }
}

@Riverpod(keepAlive: true)
class TabHidden extends _$TabHidden {
  @override
  bool build(TabType tabType) {
    if (ref.watch(shouldUseMockDataProvider)) return false;

    // sharedPref에서 읽기
    final sharedPrefAsync = ref.read(sharedPreferencesProvider);
    final sharedPref = sharedPrefAsync.asData?.value;
    if (sharedPref == null) return false;
    return sharedPref.getBool('tab_hidden_${tabType.name}') ?? false;
  }

  void update(TabType tabType, bool hidden) async {
    // sharedPref에 저장
    final sharedPref = await ref.read(sharedPreferencesProvider.future);
    await sharedPref.setBool('tab_hidden_${tabType.name}', hidden);
    state = hidden;
  }
}

@Riverpod(keepAlive: true)
class ThemeSwitch extends _$ThemeSwitch {
  @override
  ThemeMode build() {
    if (ref.watch(shouldUseMockDataProvider)) return ThemeMode.system;

    // sharedPref에서 읽기 (동기적으로 읽기 위해 asData 사용)
    final sharedPrefAsync = ref.read(sharedPreferencesProvider);
    final sharedPref = sharedPrefAsync.asData?.value;
    if (sharedPref == null) return ThemeMode.system;
    final themeModeName = sharedPref.getString('theme_mode') ?? 'system';
    return ThemeMode.values.firstWhere((e) => e.name == themeModeName, orElse: () => ThemeMode.system);
  }

  void update(ThemeMode themeMode) async {
    if (ref.read(shouldUseMockDataProvider)) {
      state = themeMode;
      return;
    }

    // sharedPref에 저장
    final sharedPref = await ref.read(sharedPreferencesProvider.future);
    await sharedPref.setString('theme_mode', themeMode.name);
    state = themeMode;
  }
}

enum LoadingState { idle, loading, success, error }

@Riverpod(keepAlive: true)
class LoadingStatus extends _$LoadingStatus {
  @override
  Map<String, LoadingState> build() {
    return {};
  }

  void update(String key, LoadingState value) {
    state = {...state, key: value};
  }

  bool isLoading(TabType tabType) {
    if (ref.read(shouldUseMockDataProvider)) return false;
    return state.entries.where((e) => e.key.startsWith(tabType.name) || e.key.startsWith('global')).any((e) => e.value == LoadingState.loading);
  }

  bool isError(TabType tabType) {
    if (ref.read(shouldUseMockDataProvider)) return false;
    return state.entries.where((e) => e.key.startsWith(tabType.name) || e.key.startsWith('global')).any((e) => e.value == LoadingState.error);
  }
}

@Riverpod(keepAlive: true)
class HomeCalendarRatio extends _$HomeCalendarRatio {
  @override
  List<int> build() {
    if (ref.watch(shouldUseMockDataProvider)) return [1, 1];

    // sharedPref에서 읽기
    final sharedPrefAsync = ref.read(sharedPreferencesProvider);
    final sharedPref = sharedPrefAsync.asData?.value;
    if (sharedPref == null) return [1, 1];
    final jsonString = sharedPref.getString('home_calendar_ratio');
    if (jsonString == null || jsonString.isEmpty) return [1, 1];
    try {
      final List<dynamic> decoded = jsonDecode(jsonString) as List<dynamic>;
      return decoded.cast<int>();
    } catch (e) {
      return [1, 1];
    }
  }

  void update(List<int> ratio) async {
    // sharedPref에 저장
    final sharedPref = await ref.read(sharedPreferencesProvider.future);
    await sharedPref.setString('home_calendar_ratio', jsonEncode(ratio));
    state = ratio;
  }
}

@Riverpod(keepAlive: true)
class AllDayPanelExpanded extends _$AllDayPanelExpanded {
  @override
  bool build() {
    if (ref.watch(shouldUseMockDataProvider)) return true;

    // sharedPref에서 읽기
    final sharedPrefAsync = ref.read(sharedPreferencesProvider);
    final sharedPref = sharedPrefAsync.asData?.value;
    if (sharedPref == null) return true;
    return sharedPref.getBool('all_day_panel_expanded') ?? true;
  }

  void update(bool expanded) async {
    // sharedPref에 저장
    final sharedPref = await ref.read(sharedPreferencesProvider.future);
    await sharedPref.setBool('all_day_panel_expanded', expanded);
    state = expanded;
  }
}

@Riverpod(keepAlive: true)
class HideUnreadIndicator extends _$HideUnreadIndicator {
  @override
  bool build() {
    if (ref.watch(shouldUseMockDataProvider)) return false;

    // sharedPref에서 읽기
    final sharedPrefAsync = ref.read(sharedPreferencesProvider);
    final sharedPref = sharedPrefAsync.asData?.value;
    if (sharedPref == null) return false;
    return sharedPref.getBool('hide_unread_indicator') ?? false;
  }

  void update(bool hide) async {
    // sharedPref에 저장
    final sharedPref = await ref.read(sharedPreferencesProvider.future);
    await sharedPref.setBool('hide_unread_indicator', hide);
    state = hide;
  }
}

@Riverpod(keepAlive: true)
class ShowTasksOnHomeTab extends _$ShowTasksOnHomeTab {
  @override
  bool build() {
    if (ref.watch(shouldUseMockDataProvider)) return true;

    // sharedPref에서 읽기
    final sharedPrefAsync = ref.read(sharedPreferencesProvider);
    final sharedPref = sharedPrefAsync.asData?.value;
    if (sharedPref == null) return true;
    return sharedPref.getBool('show_tasks_on_home_tab') ?? true;
  }

  void update(bool show) async {
    // sharedPref에 저장
    final sharedPref = await ref.read(sharedPreferencesProvider.future);
    await sharedPref.setBool('show_tasks_on_home_tab', show);
    state = show;
  }
}

@Riverpod(keepAlive: true)
class HiddenTaskColorsOnHomeTab extends _$HiddenTaskColorsOnHomeTab {
  @override
  List<String> build() {
    if (ref.watch(shouldUseMockDataProvider)) return [];

    // sharedPref에서 읽기
    final sharedPrefAsync = ref.read(sharedPreferencesProvider);
    final sharedPref = sharedPrefAsync.asData?.value;
    if (sharedPref == null) return [];
    final jsonString = sharedPref.getString('hidden_task_colors_on_home_tab');
    if (jsonString == null || jsonString.isEmpty) return [];
    try {
      final List<dynamic> decoded = jsonDecode(jsonString) as List<dynamic>;
      return decoded.cast<String>();
    } catch (e) {
      return [];
    }
  }

  void update(List<String> colors) async {
    // sharedPref에 저장
    final sharedPref = await ref.read(sharedPreferencesProvider.future);
    await sharedPref.setString('hidden_task_colors_on_home_tab', jsonEncode(colors));
    state = colors;
  }
}

@Riverpod(keepAlive: true)
class FrequentlyUsedEmojiIds extends _$FrequentlyUsedEmojiIds {
  @override
  List<String> build() {
    if (ref.watch(shouldUseMockDataProvider)) return [];

    // sharedPref에서 읽기
    final sharedPrefAsync = ref.read(sharedPreferencesProvider);
    final sharedPref = sharedPrefAsync.asData?.value;
    if (sharedPref == null) return [];
    final jsonString = sharedPref.getString('frequently_used_emoji_ids');
    if (jsonString == null || jsonString.isEmpty) return [];
    try {
      final List<dynamic> decoded = jsonDecode(jsonString) as List<dynamic>;
      return decoded.cast<String>();
    } catch (e) {
      return [];
    }
  }

  void update(List<String> emojiIds) async {
    // sharedPref에 저장
    final sharedPref = await ref.read(sharedPreferencesProvider.future);
    await sharedPref.setString('frequently_used_emoji_ids', jsonEncode(emojiIds));
    state = emojiIds;
  }

  void addEmoji(String emojiId) async {
    final currentList = state;
    final newList = [emojiId, ...currentList.where((e) => e != emojiId)].take(20).toList();
    // sharedPref에 저장
    final sharedPref = await ref.read(sharedPreferencesProvider.future);
    await sharedPref.setString('frequently_used_emoji_ids', jsonEncode(newList));
    state = newList;
  }
}

@Riverpod(keepAlive: true)
class TextScaler extends _$TextScaler {
  @override
  double build() {
    if (ref.watch(shouldUseMockDataProvider)) return 1.0;

    // sharedPref에서 읽기
    final sharedPrefAsync = ref.read(sharedPreferencesProvider);
    final sharedPref = sharedPrefAsync.asData?.value;
    if (sharedPref == null) return 1.0;
    return sharedPref.getDouble('text_scaler') ?? 1.0;
  }

  void update(double scaler) async {
    // sharedPref에 저장
    final sharedPref = await ref.read(sharedPreferencesProvider.future);
    await sharedPref.setDouble('text_scaler', scaler);
    state = scaler;
  }
}

@Riverpod(keepAlive: true)
class InboxLastCreateEventTypeNotifier extends _$InboxLastCreateEventTypeNotifier {
  @override
  InboxLastCreateEventType build() {
    if (ref.watch(shouldUseMockDataProvider)) return InboxLastCreateEventType.calendar;

    // sharedPref에서 읽기
    final sharedPrefAsync = ref.read(sharedPreferencesProvider);
    final sharedPref = sharedPrefAsync.asData?.value;
    if (sharedPref == null) return InboxLastCreateEventType.calendar;
    final typeName = sharedPref.getString('inbox_last_create_event_type');
    if (typeName == null || typeName.isEmpty) return InboxLastCreateEventType.calendar;
    try {
      return InboxLastCreateEventType.values.firstWhere((e) => e.name == typeName, orElse: () => InboxLastCreateEventType.calendar);
    } catch (e) {
      return InboxLastCreateEventType.calendar;
    }
  }

  void update(InboxLastCreateEventType type) async {
    // sharedPref에 저장
    final sharedPref = await ref.read(sharedPreferencesProvider.future);
    await sharedPref.setString('inbox_last_create_event_type', type.name);
    state = type;
  }
}

@Riverpod(keepAlive: true)
class AiApiKeys extends _$AiApiKeys {
  @override
  Map<String, String> build() {
    if (ref.watch(shouldUseMockDataProvider)) return {};

    final localPref = ref.watch(localPrefControllerProvider).value;
    return localPref?.prefAiApiKeys ?? {};
  }

  /// 구독 상태 확인
  bool _hasActiveSubscription() {
    return ref.read(authControllerProvider.select((value) => value.requireValue.onSubscription));
  }

  Future<void> setApiKey(AiProvider provider, String apiKey) async {
    // 사용자 API 키는 구독 상태와 관계없이 설정 가능
    final localPref = ref.read(localPrefControllerProvider).value;
    final currentState = Map<String, String>.from(localPref?.prefAiApiKeys ?? {});
    final newState = <String, String>{...currentState};
    if (apiKey.isEmpty) {
      newState.remove(provider.key);
    } else {
      newState[provider.key] = apiKey;
    }
    ref.read(localPrefControllerProvider.notifier).set(aiApiKeys: newState);
  }

  Future<void> removeApiKey(AiProvider provider) async {
    final localPref = ref.read(localPrefControllerProvider).value;
    final currentState = Map<String, String>.from(localPref?.prefAiApiKeys ?? {});
    final newState = <String, String>{...currentState};
    newState.remove(provider.key);
    ref.read(localPrefControllerProvider.notifier).set(aiApiKeys: newState);
  }

  String? getApiKey(AiProvider provider) {
    final localPref = ref.read(localPrefControllerProvider).value;
    return localPref?.prefAiApiKeys[provider.key];
  }

  /// 구독 상태에 따라 AI 기능 사용 가능 여부 확인
  bool canUseAiFeatures() {
    return _hasActiveSubscription();
  }
}

@Riverpod(keepAlive: true)
class DefaultAgentAiProvider extends _$DefaultAgentAiProvider {
  @override
  AiProvider? build() {
    if (ref.watch(shouldUseMockDataProvider)) return null;

    final onSubscription = ref.watch(authControllerProvider.select((value) => value.requireValue.onSubscription));

    // 구독 상태 확인
    if (!onSubscription) {
      return null;
    }

    // SharedPreferences에서 읽기
    final sharedPrefAsync = ref.read(sharedPreferencesProvider);
    final sharedPref = sharedPrefAsync.asData?.value;
    if (sharedPref == null) return null;

    final providerKey = sharedPref.getString('default_agent_ai_provider');
    if (providerKey == null || providerKey.isEmpty || providerKey == 'none') return null;
    try {
      return AiProvider.values.firstWhere((p) => p.key == providerKey, orElse: () => AiProvider.openai);
    } catch (e) {
      return null;
    }
  }

  Future<void> setProvider(AiProvider? provider) async {
    // 구독 상태 확인
    final onSubscription = ref.read(authControllerProvider.select((value) => value.requireValue.onSubscription));
    if (!onSubscription) {
      // 구독이 없으면 설정 불가
      return;
    }
    // SharedPreferences에 저장
    final sharedPref = await ref.read(sharedPreferencesProvider.future);
    await sharedPref.setString('default_agent_ai_provider', provider?.key ?? 'none');
    state = provider;
  }
}

class SelectedAgentModelData {
  final AgentModel model;
  final bool useUserApiKey;

  SelectedAgentModelData({required this.model, required this.useUserApiKey});

  Map<String, dynamic> toJson() => {'model': model.name, 'useUserApiKey': useUserApiKey};

  factory SelectedAgentModelData.fromJson(Map<String, dynamic> json) {
    final modelName = json['model'] as String? ?? '';
    final useUserApiKey = json['useUserApiKey'] as bool? ?? false;

    AgentModel model;
    if (modelName == '') {
      model = AgentModel.gpt52;
    } else {
      try {
        model = AgentModel.values.firstWhere((m) => m.name == modelName, orElse: () => AgentModel.gpt52);
      } catch (e) {
        model = AgentModel.gpt52;
      }
    }

    return SelectedAgentModelData(model: model, useUserApiKey: useUserApiKey);
  }
}

@Riverpod(keepAlive: true)
class SelectedAgentModel extends _$SelectedAgentModel {
  @override
  Future<SelectedAgentModelData> build() async {
    final defaultData = SelectedAgentModelData(model: AgentModel.gpt52, useUserApiKey: false);
    if (ref.watch(shouldUseMockDataProvider)) {
      state = AsyncData(defaultData);
      return defaultData;
    }

    final onSubscription = ref.watch(authControllerProvider.select((value) => value.requireValue.onSubscription));

    // 구독 상태 확인 - 사용자 API 키를 사용하는 경우 구독 없이도 사용 가능

    final localPref = ref.watch(localPrefControllerProvider).value;
    final savedModelMap = localPref?.prefSelectedAgentModel;

    SelectedAgentModelData? savedData;
    if (savedModelMap != null) {
      try {
        savedData = SelectedAgentModelData.fromJson(savedModelMap);
      } catch (e) {
        savedData = null;
      }
    }

    // 저장된 모델이 없거나 유효하지 않으면 기본 모델로 설정
    if (savedData == null || !AgentModel.values.contains(savedData.model)) {
      state = AsyncData(defaultData);
      return defaultData;
    }

    // 구독이 없고 사용자 API 키를 사용하지 않는 경우 기본값 반환
    if (!onSubscription && !savedData.useUserApiKey) {
      state = AsyncData(defaultData);
      return defaultData;
    }

    state = AsyncData(savedData);
    return savedData;
  }

  Future<void> setModel(AgentModel model, bool useUserApiKey) async {
    // 사용자 API 키를 사용하는 경우 구독 없이도 설정 가능
    if (!useUserApiKey) {
      final onSubscription = ref.read(authControllerProvider.select((value) => value.requireValue.onSubscription));
      if (!onSubscription) {
        // 구독이 없고 사용자 API 키를 사용하지 않으면 설정 불가
        return;
      }
    }
    final modelData = SelectedAgentModelData(model: model, useUserApiKey: useUserApiKey);
    ref.read(localPrefControllerProvider.notifier).set(selectedAgentModel: modelData.toJson());
    state = AsyncData(modelData);
  }
}

@Riverpod(keepAlive: true)
class SubscriptionTestMode extends _$SubscriptionTestMode {
  @override
  bool build() {
    final isSignedIn = ref.watch(isSignedInProvider);
    if (!isSignedIn) return false;

    // SharedPreferences에서 읽기
    final sharedPrefAsync = ref.read(sharedPreferencesProvider);
    final sharedPref = sharedPrefAsync.asData?.value;
    if (sharedPref == null) return false;
    return sharedPref.getBool('subscription_test_mode') ?? false;
  }

  Future<void> setTestMode(bool isTestMode) async {
    // SharedPreferences에 저장
    final sharedPref = await ref.read(sharedPreferencesProvider.future);
    await sharedPref.setBool('subscription_test_mode', isTestMode);
    state = isTestMode;
  }
}

// 브랜딩 페이지용 더미 데이터 사용 여부
const bool useBrandingPageData = false;

@Riverpod(keepAlive: true)
class ShouldUseMockData extends _$ShouldUseMockData {
  @override
  bool build() {
    final isSignedIn = ref.watch(isSignedInProvider);
    return !isSignedIn || useBrandingPageData;
  }
}

@Riverpod(keepAlive: true)
class AgentSystemPrompt extends _$AgentSystemPrompt {
  @override
  String? build() {
    if (ref.watch(shouldUseMockDataProvider)) return null;

    // SharedPreferences에서 읽기
    final sharedPrefAsync = ref.read(sharedPreferencesProvider);
    final sharedPref = sharedPrefAsync.asData?.value;
    if (sharedPref == null) return null;

    final prompt = sharedPref.getString('agent_system_prompt');
    return prompt?.isEmpty == true ? null : prompt;
  }

  Future<void> setSystemPrompt(String? systemPrompt) async {
    // SharedPreferences에 저장
    final sharedPref = await ref.read(sharedPreferencesProvider.future);
    if (systemPrompt == null || systemPrompt.isEmpty) {
      await sharedPref.remove('agent_system_prompt');
    } else {
      await sharedPref.setString('agent_system_prompt', systemPrompt);
    }
    state = systemPrompt;
  }
}

@Riverpod(keepAlive: true)
class ShowTaskNotification extends _$ShowTaskNotification {
  @override
  bool build() {
    if (ref.watch(shouldUseMockDataProvider)) return true;

    // sharedPref에서 읽기
    final sharedPrefAsync = ref.read(sharedPreferencesProvider);
    final sharedPref = sharedPrefAsync.asData?.value;
    if (sharedPref == null) return true;
    return sharedPref.getBool('show_task_notification') ?? true;
  }

  void update(bool show) async {
    // sharedPref에 저장
    final sharedPref = await ref.read(sharedPreferencesProvider.future);
    await sharedPref.setBool('show_task_notification', show);
    state = show;
  }
}

@Riverpod(keepAlive: true)
class HourlyWage extends _$HourlyWage {
  @override
  double build() {
    if (ref.watch(shouldUseMockDataProvider)) return 50.0;

    // sharedPref에서 읽기
    final sharedPrefAsync = ref.read(sharedPreferencesProvider);
    final sharedPref = sharedPrefAsync.asData?.value;
    if (sharedPref == null) return 50.0;
    return sharedPref.getDouble('hourly_wage') ?? 50.0;
  }

  void update(double wage) async {
    // sharedPref에 저장
    final sharedPref = await ref.read(sharedPreferencesProvider.future);
    await sharedPref.setDouble('hourly_wage', wage);
    state = wage;
  }
}

@Riverpod(keepAlive: true)
class DefaultTimezone extends _$DefaultTimezone {
  @override
  String? build() {
    if (ref.watch(shouldUseMockDataProvider)) return null;

    // sharedPref에서 읽기
    final sharedPrefAsync = ref.read(sharedPreferencesProvider);
    final sharedPref = sharedPrefAsync.asData?.value;
    if (sharedPref == null) return null;
    return sharedPref.getString('default_timezone');
  }

  void update(String? timezone) async {
    // sharedPref에 저장
    final sharedPref = await ref.read(sharedPreferencesProvider.future);
    if (timezone == null) {
      await sharedPref.remove('default_timezone');
    } else {
      await sharedPref.setString('default_timezone', timezone);
    }
    state = timezone;
  }
}

@Riverpod(keepAlive: true)
class SecondaryTimezone extends _$SecondaryTimezone {
  @override
  String? build() {
    if (ref.watch(shouldUseMockDataProvider)) return null;

    // sharedPref에서 읽기
    final sharedPrefAsync = ref.read(sharedPreferencesProvider);
    final sharedPref = sharedPrefAsync.asData?.value;
    if (sharedPref == null) return null;
    return sharedPref.getString('secondary_timezone');
  }

  void update(String? timezone) async {
    // sharedPref에 저장
    final sharedPref = await ref.read(sharedPreferencesProvider.future);
    if (timezone == null) {
      await sharedPref.remove('secondary_timezone');
    } else {
      await sharedPref.setString('secondary_timezone', timezone);
    }
    state = timezone;
  }
}

@Riverpod(keepAlive: true)
class IsMessageIntegrationTutorialCompleted extends _$IsMessageIntegrationTutorialCompleted {
  @override
  bool build() {
    if (ref.watch(shouldUseMockDataProvider)) return false;

    // sharedPref에서 읽기
    final sharedPrefAsync = ref.read(sharedPreferencesProvider);
    final sharedPref = sharedPrefAsync.asData?.value;
    if (sharedPref == null) return false;
    return sharedPref.getBool('is_message_integration_tutorial_completed') ?? false;
  }

  void update(bool completed) async {
    // sharedPref에 저장
    final sharedPref = await ref.read(sharedPreferencesProvider.future);
    await sharedPref.setBool('is_message_integration_tutorial_completed', completed);
    state = completed;
  }
}

@Riverpod(keepAlive: true)
class CreateTaskFromMailTutorialDone extends _$CreateTaskFromMailTutorialDone {
  @override
  bool build() {
    if (ref.watch(shouldUseMockDataProvider)) return false;

    // sharedPref에서 읽기
    final sharedPrefAsync = ref.read(sharedPreferencesProvider);
    final sharedPref = sharedPrefAsync.asData?.value;
    if (sharedPref == null) return false;
    return sharedPref.getBool('create_task_from_mail_tutorial_done') ?? false;
  }

  void update(bool done) async {
    // sharedPref에 저장
    final sharedPref = await ref.read(sharedPreferencesProvider.future);
    await sharedPref.setBool('create_task_from_mail_tutorial_done', done);
    state = done;
  }
}

@Riverpod(keepAlive: true)
class OAuthDisconnectedIgnored extends _$OAuthDisconnectedIgnored {
  @override
  bool build() {
    if (ref.watch(shouldUseMockDataProvider)) return false;

    // sharedPref에서 읽기
    final sharedPrefAsync = ref.read(sharedPreferencesProvider);
    final sharedPref = sharedPrefAsync.asData?.value;
    if (sharedPref == null) return false;
    return sharedPref.getBool('oauth_disconnected_ignored') ?? false;
  }

  void update(bool ignored) async {
    // sharedPref에 저장
    final sharedPref = await ref.read(sharedPreferencesProvider.future);
    await sharedPref.setBool('oauth_disconnected_ignored', ignored);
    state = ignored;
  }
}

@Riverpod(keepAlive: true)
class LastTimeSavedViewType extends _$LastTimeSavedViewType {
  @override
  TimeSavedViewType build() {
    if (ref.watch(shouldUseMockDataProvider)) return TimeSavedViewType.last7days;

    // sharedPref에서 읽기
    final sharedPrefAsync = ref.read(sharedPreferencesProvider);
    final sharedPref = sharedPrefAsync.asData?.value;
    if (sharedPref == null) return TimeSavedViewType.last7days;
    final typeName = sharedPref.getString('last_time_saved_view_type');
    if (typeName == null || typeName.isEmpty) return TimeSavedViewType.last7days;
    try {
      return TimeSavedViewType.values.firstWhere((e) => e.name == typeName, orElse: () => TimeSavedViewType.last7days);
    } catch (e) {
      return TimeSavedViewType.last7days;
    }
  }

  void update(TimeSavedViewType type) async {
    // sharedPref에 저장
    final sharedPref = await ref.read(sharedPreferencesProvider.future);
    await sharedPref.setString('last_time_saved_view_type', type.name);
    state = type;
  }
}

@Riverpod(keepAlive: true)
class TotalSavedTime extends _$TotalSavedTime {
  @override
  double build() {
    // SharedPreferences에서 읽기
    final sharedPrefAsync = ref.read(sharedPreferencesProvider);
    final sharedPref = sharedPrefAsync.asData?.value;
    if (sharedPref == null) return 0.0;
    return sharedPref.getDouble('total_saved_time') ?? 0.0;
  }

  Future<void> update(double time) async {
    // SharedPreferences에 저장
    final sharedPref = await ref.read(sharedPreferencesProvider.future);
    await sharedPref.setDouble('total_saved_time', time);
    state = time;
  }
}
