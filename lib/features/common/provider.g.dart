// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ResizableClosableWidget)
const resizableClosableWidgetProvider = ResizableClosableWidgetFamily._();

final class ResizableClosableWidgetProvider
    extends $NotifierProvider<ResizableClosableWidget, ResizableWidget?> {
  const ResizableClosableWidgetProvider._({
    required ResizableClosableWidgetFamily super.from,
    required TabType super.argument,
  }) : super(
         retry: null,
         name: r'resizableClosableWidgetProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$resizableClosableWidgetHash();

  @override
  String toString() {
    return r'resizableClosableWidgetProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ResizableClosableWidget create() => ResizableClosableWidget();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ResizableWidget? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ResizableWidget?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ResizableClosableWidgetProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$resizableClosableWidgetHash() =>
    r'e9a9aef6d46f11481be9213d11cb7f6b951e8a1f';

final class ResizableClosableWidgetFamily extends $Family
    with
        $ClassFamilyOverride<
          ResizableClosableWidget,
          ResizableWidget?,
          ResizableWidget?,
          ResizableWidget?,
          TabType
        > {
  const ResizableClosableWidgetFamily._()
    : super(
        retry: null,
        name: r'resizableClosableWidgetProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  ResizableClosableWidgetProvider call(TabType tabType) =>
      ResizableClosableWidgetProvider._(argument: tabType, from: this);

  @override
  String toString() => r'resizableClosableWidgetProvider';
}

abstract class _$ResizableClosableWidget extends $Notifier<ResizableWidget?> {
  late final _$args = ref.$arg as TabType;
  TabType get tabType => _$args;

  ResizableWidget? build(TabType tabType);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref = this.ref as $Ref<ResizableWidget?, ResizableWidget?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ResizableWidget?, ResizableWidget?>,
              ResizableWidget?,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(ResizableClosableDrawer)
const resizableClosableDrawerProvider = ResizableClosableDrawerFamily._();

final class ResizableClosableDrawerProvider
    extends $NotifierProvider<ResizableClosableDrawer, Widget?> {
  const ResizableClosableDrawerProvider._({
    required ResizableClosableDrawerFamily super.from,
    required TabType super.argument,
  }) : super(
         retry: null,
         name: r'resizableClosableDrawerProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$resizableClosableDrawerHash();

  @override
  String toString() {
    return r'resizableClosableDrawerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ResizableClosableDrawer create() => ResizableClosableDrawer();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Widget? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Widget?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ResizableClosableDrawerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$resizableClosableDrawerHash() =>
    r'055f35cdeb0da3474de1877d5893a1731414e027';

final class ResizableClosableDrawerFamily extends $Family
    with
        $ClassFamilyOverride<
          ResizableClosableDrawer,
          Widget?,
          Widget?,
          Widget?,
          TabType
        > {
  const ResizableClosableDrawerFamily._()
    : super(
        retry: null,
        name: r'resizableClosableDrawerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  ResizableClosableDrawerProvider call(TabType tabType) =>
      ResizableClosableDrawerProvider._(argument: tabType, from: this);

  @override
  String toString() => r'resizableClosableDrawerProvider';
}

abstract class _$ResizableClosableDrawer extends $Notifier<Widget?> {
  late final _$args = ref.$arg as TabType;
  TabType get tabType => _$args;

  Widget? build(TabType tabType);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref = this.ref as $Ref<Widget?, Widget?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Widget?, Widget?>,
              Widget?,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(ZoomRatio)
const zoomRatioProvider = ZoomRatioProvider._();

final class ZoomRatioProvider extends $NotifierProvider<ZoomRatio, double> {
  const ZoomRatioProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'zoomRatioProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$zoomRatioHash();

  @$internal
  @override
  ZoomRatio create() => ZoomRatio();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(double value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<double>(value),
    );
  }
}

String _$zoomRatioHash() => r'f75db054d9941f27f03cfe4c69eda1a4b468ba40';

abstract class _$ZoomRatio extends $Notifier<double> {
  double build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<double, double>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<double, double>,
              double,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(WindowSize)
const windowSizeProvider = WindowSizeProvider._();

final class WindowSizeProvider
    extends $AsyncNotifierProvider<WindowSize, Rect?> {
  const WindowSizeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'windowSizeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$windowSizeHash();

  @$internal
  @override
  WindowSize create() => WindowSize();
}

String _$windowSizeHash() => r'7bdb3b8d978729fa749fd894ed3ce8d069b33ac1';

abstract class _$WindowSize extends $AsyncNotifier<Rect?> {
  FutureOr<Rect?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<Rect?>, Rect?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Rect?>, Rect?>,
              AsyncValue<Rect?>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(DesktopShowSidebar)
const desktopShowSidebarProvider = DesktopShowSidebarProvider._();

final class DesktopShowSidebarProvider
    extends $NotifierProvider<DesktopShowSidebar, bool> {
  const DesktopShowSidebarProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'desktopShowSidebarProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$desktopShowSidebarHash();

  @$internal
  @override
  DesktopShowSidebar create() => DesktopShowSidebar();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$desktopShowSidebarHash() =>
    r'0b303944f32d4602e5da43474e7065aafdd42bda';

abstract class _$DesktopShowSidebar extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(TabLoaded)
const tabLoadedProvider = TabLoadedFamily._();

final class TabLoadedProvider extends $NotifierProvider<TabLoaded, bool> {
  const TabLoadedProvider._({
    required TabLoadedFamily super.from,
    required TabType super.argument,
  }) : super(
         retry: null,
         name: r'tabLoadedProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$tabLoadedHash();

  @override
  String toString() {
    return r'tabLoadedProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  TabLoaded create() => TabLoaded();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is TabLoadedProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$tabLoadedHash() => r'adee04bccc1231867da877ce45329434572cccbd';

final class TabLoadedFamily extends $Family
    with $ClassFamilyOverride<TabLoaded, bool, bool, bool, TabType> {
  const TabLoadedFamily._()
    : super(
        retry: null,
        name: r'tabLoadedProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  TabLoadedProvider call(TabType tabType) =>
      TabLoadedProvider._(argument: tabType, from: this);

  @override
  String toString() => r'tabLoadedProvider';
}

abstract class _$TabLoaded extends $Notifier<bool> {
  late final _$args = ref.$arg as TabType;
  TabType get tabType => _$args;

  bool build(TabType tabType);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(TabHidden)
const tabHiddenProvider = TabHiddenFamily._();

final class TabHiddenProvider extends $NotifierProvider<TabHidden, bool> {
  const TabHiddenProvider._({
    required TabHiddenFamily super.from,
    required TabType super.argument,
  }) : super(
         retry: null,
         name: r'tabHiddenProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$tabHiddenHash();

  @override
  String toString() {
    return r'tabHiddenProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  TabHidden create() => TabHidden();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is TabHiddenProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$tabHiddenHash() => r'2c6dc7f6685181af1843af7e8170bb6c0d306eac';

final class TabHiddenFamily extends $Family
    with $ClassFamilyOverride<TabHidden, bool, bool, bool, TabType> {
  const TabHiddenFamily._()
    : super(
        retry: null,
        name: r'tabHiddenProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  TabHiddenProvider call(TabType tabType) =>
      TabHiddenProvider._(argument: tabType, from: this);

  @override
  String toString() => r'tabHiddenProvider';
}

abstract class _$TabHidden extends $Notifier<bool> {
  late final _$args = ref.$arg as TabType;
  TabType get tabType => _$args;

  bool build(TabType tabType);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(ThemeSwitch)
const themeSwitchProvider = ThemeSwitchProvider._();

final class ThemeSwitchProvider
    extends $NotifierProvider<ThemeSwitch, ThemeMode> {
  const ThemeSwitchProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'themeSwitchProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$themeSwitchHash();

  @$internal
  @override
  ThemeSwitch create() => ThemeSwitch();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ThemeMode value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ThemeMode>(value),
    );
  }
}

String _$themeSwitchHash() => r'0784024f26f3640e6760e340a72f5f42a36f638f';

abstract class _$ThemeSwitch extends $Notifier<ThemeMode> {
  ThemeMode build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<ThemeMode, ThemeMode>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ThemeMode, ThemeMode>,
              ThemeMode,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(LoadingStatus)
const loadingStatusProvider = LoadingStatusProvider._();

final class LoadingStatusProvider
    extends $NotifierProvider<LoadingStatus, Map<String, LoadingState>> {
  const LoadingStatusProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'loadingStatusProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$loadingStatusHash();

  @$internal
  @override
  LoadingStatus create() => LoadingStatus();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, LoadingState> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, LoadingState>>(value),
    );
  }
}

String _$loadingStatusHash() => r'5d78bad6ba8394e13f2d7e41c008fafc021b2e3f';

abstract class _$LoadingStatus extends $Notifier<Map<String, LoadingState>> {
  Map<String, LoadingState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref as $Ref<Map<String, LoadingState>, Map<String, LoadingState>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Map<String, LoadingState>, Map<String, LoadingState>>,
              Map<String, LoadingState>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(HomeCalendarRatio)
const homeCalendarRatioProvider = HomeCalendarRatioProvider._();

final class HomeCalendarRatioProvider
    extends $NotifierProvider<HomeCalendarRatio, List<int>> {
  const HomeCalendarRatioProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'homeCalendarRatioProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$homeCalendarRatioHash();

  @$internal
  @override
  HomeCalendarRatio create() => HomeCalendarRatio();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<int> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<int>>(value),
    );
  }
}

String _$homeCalendarRatioHash() => r'd780e661a8ce63f31161f52a33ec1e28bd643105';

abstract class _$HomeCalendarRatio extends $Notifier<List<int>> {
  List<int> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<List<int>, List<int>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<int>, List<int>>,
              List<int>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(AllDayPanelExpanded)
const allDayPanelExpandedProvider = AllDayPanelExpandedProvider._();

final class AllDayPanelExpandedProvider
    extends $NotifierProvider<AllDayPanelExpanded, bool> {
  const AllDayPanelExpandedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'allDayPanelExpandedProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$allDayPanelExpandedHash();

  @$internal
  @override
  AllDayPanelExpanded create() => AllDayPanelExpanded();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$allDayPanelExpandedHash() =>
    r'57d519bca785eeea5c0b0f426b01d308d57b4f43';

abstract class _$AllDayPanelExpanded extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(HideUnreadIndicator)
const hideUnreadIndicatorProvider = HideUnreadIndicatorProvider._();

final class HideUnreadIndicatorProvider
    extends $NotifierProvider<HideUnreadIndicator, bool> {
  const HideUnreadIndicatorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'hideUnreadIndicatorProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$hideUnreadIndicatorHash();

  @$internal
  @override
  HideUnreadIndicator create() => HideUnreadIndicator();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$hideUnreadIndicatorHash() =>
    r'2f0fa12f8817dc40d8827bdff1a96eee3a4f9b2d';

abstract class _$HideUnreadIndicator extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(ShowTasksOnHomeTab)
const showTasksOnHomeTabProvider = ShowTasksOnHomeTabProvider._();

final class ShowTasksOnHomeTabProvider
    extends $NotifierProvider<ShowTasksOnHomeTab, bool> {
  const ShowTasksOnHomeTabProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'showTasksOnHomeTabProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$showTasksOnHomeTabHash();

  @$internal
  @override
  ShowTasksOnHomeTab create() => ShowTasksOnHomeTab();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$showTasksOnHomeTabHash() =>
    r'68e70c6ea6dc5521e9e1d94a947f863c6b1988c4';

abstract class _$ShowTasksOnHomeTab extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(HiddenTaskColorsOnHomeTab)
const hiddenTaskColorsOnHomeTabProvider = HiddenTaskColorsOnHomeTabProvider._();

final class HiddenTaskColorsOnHomeTabProvider
    extends $NotifierProvider<HiddenTaskColorsOnHomeTab, List<String>> {
  const HiddenTaskColorsOnHomeTabProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'hiddenTaskColorsOnHomeTabProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$hiddenTaskColorsOnHomeTabHash();

  @$internal
  @override
  HiddenTaskColorsOnHomeTab create() => HiddenTaskColorsOnHomeTab();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<String>>(value),
    );
  }
}

String _$hiddenTaskColorsOnHomeTabHash() =>
    r'49e01969d2ffbc5a8fb0d984c890f6ceb0f3f3cc';

abstract class _$HiddenTaskColorsOnHomeTab extends $Notifier<List<String>> {
  List<String> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<List<String>, List<String>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<String>, List<String>>,
              List<String>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(FrequentlyUsedEmojiIds)
const frequentlyUsedEmojiIdsProvider = FrequentlyUsedEmojiIdsProvider._();

final class FrequentlyUsedEmojiIdsProvider
    extends $NotifierProvider<FrequentlyUsedEmojiIds, List<String>> {
  const FrequentlyUsedEmojiIdsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'frequentlyUsedEmojiIdsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$frequentlyUsedEmojiIdsHash();

  @$internal
  @override
  FrequentlyUsedEmojiIds create() => FrequentlyUsedEmojiIds();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<String>>(value),
    );
  }
}

String _$frequentlyUsedEmojiIdsHash() =>
    r'20a4f0a9bf6a1467f606303ab427175886db12ed';

abstract class _$FrequentlyUsedEmojiIds extends $Notifier<List<String>> {
  List<String> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<List<String>, List<String>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<String>, List<String>>,
              List<String>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(TextScaler)
const textScalerProvider = TextScalerProvider._();

final class TextScalerProvider extends $NotifierProvider<TextScaler, double> {
  const TextScalerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'textScalerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$textScalerHash();

  @$internal
  @override
  TextScaler create() => TextScaler();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(double value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<double>(value),
    );
  }
}

String _$textScalerHash() => r'784069345b398e875f6376397105b044c4b84c05';

abstract class _$TextScaler extends $Notifier<double> {
  double build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<double, double>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<double, double>,
              double,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(InboxLastCreateEventTypeNotifier)
const inboxLastCreateEventTypeProvider =
    InboxLastCreateEventTypeNotifierProvider._();

final class InboxLastCreateEventTypeNotifierProvider
    extends
        $NotifierProvider<
          InboxLastCreateEventTypeNotifier,
          InboxLastCreateEventType
        > {
  const InboxLastCreateEventTypeNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'inboxLastCreateEventTypeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$inboxLastCreateEventTypeNotifierHash();

  @$internal
  @override
  InboxLastCreateEventTypeNotifier create() =>
      InboxLastCreateEventTypeNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(InboxLastCreateEventType value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<InboxLastCreateEventType>(value),
    );
  }
}

String _$inboxLastCreateEventTypeNotifierHash() =>
    r'dd7c84c3ffb23ce91a820e29393731934d43f8d2';

abstract class _$InboxLastCreateEventTypeNotifier
    extends $Notifier<InboxLastCreateEventType> {
  InboxLastCreateEventType build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref as $Ref<InboxLastCreateEventType, InboxLastCreateEventType>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<InboxLastCreateEventType, InboxLastCreateEventType>,
              InboxLastCreateEventType,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(AiApiKeys)
const aiApiKeysProvider = AiApiKeysProvider._();

final class AiApiKeysProvider
    extends $NotifierProvider<AiApiKeys, Map<String, String>> {
  const AiApiKeysProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'aiApiKeysProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$aiApiKeysHash();

  @$internal
  @override
  AiApiKeys create() => AiApiKeys();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, String>>(value),
    );
  }
}

String _$aiApiKeysHash() => r'0957abfb59ec1ed02561f6e13a9942d2a13d76bd';

abstract class _$AiApiKeys extends $Notifier<Map<String, String>> {
  Map<String, String> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<Map<String, String>, Map<String, String>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Map<String, String>, Map<String, String>>,
              Map<String, String>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(DefaultAgentAiProvider)
const defaultAgentAiProviderProvider = DefaultAgentAiProviderProvider._();

final class DefaultAgentAiProviderProvider
    extends $NotifierProvider<DefaultAgentAiProvider, AiProvider?> {
  const DefaultAgentAiProviderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'defaultAgentAiProviderProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$defaultAgentAiProviderHash();

  @$internal
  @override
  DefaultAgentAiProvider create() => DefaultAgentAiProvider();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AiProvider? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AiProvider?>(value),
    );
  }
}

String _$defaultAgentAiProviderHash() =>
    r'e1ba9f10174ecfe0c4e2b38274342b2e596920c1';

abstract class _$DefaultAgentAiProvider extends $Notifier<AiProvider?> {
  AiProvider? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AiProvider?, AiProvider?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AiProvider?, AiProvider?>,
              AiProvider?,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(SelectedAgentModel)
const selectedAgentModelProvider = SelectedAgentModelProvider._();

final class SelectedAgentModelProvider
    extends $AsyncNotifierProvider<SelectedAgentModel, SelectedAgentModelData> {
  const SelectedAgentModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedAgentModelProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedAgentModelHash();

  @$internal
  @override
  SelectedAgentModel create() => SelectedAgentModel();
}

String _$selectedAgentModelHash() =>
    r'9d7deec6801cd3c8d31bbb891e3d10ace53af353';

abstract class _$SelectedAgentModel
    extends $AsyncNotifier<SelectedAgentModelData> {
  FutureOr<SelectedAgentModelData> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref
            as $Ref<AsyncValue<SelectedAgentModelData>, SelectedAgentModelData>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<SelectedAgentModelData>,
                SelectedAgentModelData
              >,
              AsyncValue<SelectedAgentModelData>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(SubscriptionTestMode)
const subscriptionTestModeProvider = SubscriptionTestModeProvider._();

final class SubscriptionTestModeProvider
    extends $NotifierProvider<SubscriptionTestMode, bool> {
  const SubscriptionTestModeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'subscriptionTestModeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$subscriptionTestModeHash();

  @$internal
  @override
  SubscriptionTestMode create() => SubscriptionTestMode();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$subscriptionTestModeHash() =>
    r'19d99ebf31eea2343a3c7ee4e0fddaef80e4b197';

abstract class _$SubscriptionTestMode extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(ShouldUseMockData)
const shouldUseMockDataProvider = ShouldUseMockDataProvider._();

final class ShouldUseMockDataProvider
    extends $NotifierProvider<ShouldUseMockData, bool> {
  const ShouldUseMockDataProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'shouldUseMockDataProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$shouldUseMockDataHash();

  @$internal
  @override
  ShouldUseMockData create() => ShouldUseMockData();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$shouldUseMockDataHash() => r'42652e9dd08a501f225527b3e31b296f8651802f';

abstract class _$ShouldUseMockData extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(AgentSystemPrompt)
const agentSystemPromptProvider = AgentSystemPromptProvider._();

final class AgentSystemPromptProvider
    extends $NotifierProvider<AgentSystemPrompt, String?> {
  const AgentSystemPromptProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'agentSystemPromptProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$agentSystemPromptHash();

  @$internal
  @override
  AgentSystemPrompt create() => AgentSystemPrompt();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$agentSystemPromptHash() => r'2e94b07993fc2c7eb4ea7e8cc06e6c7cf082b7c6';

abstract class _$AgentSystemPrompt extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String?, String?>,
              String?,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(ShowTaskNotification)
const showTaskNotificationProvider = ShowTaskNotificationProvider._();

final class ShowTaskNotificationProvider
    extends $NotifierProvider<ShowTaskNotification, bool> {
  const ShowTaskNotificationProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'showTaskNotificationProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$showTaskNotificationHash();

  @$internal
  @override
  ShowTaskNotification create() => ShowTaskNotification();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$showTaskNotificationHash() =>
    r'4e182c5e69ee7693077163204b330c7721f4477d';

abstract class _$ShowTaskNotification extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(HourlyWage)
const hourlyWageProvider = HourlyWageProvider._();

final class HourlyWageProvider extends $NotifierProvider<HourlyWage, double> {
  const HourlyWageProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'hourlyWageProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$hourlyWageHash();

  @$internal
  @override
  HourlyWage create() => HourlyWage();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(double value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<double>(value),
    );
  }
}

String _$hourlyWageHash() => r'98c69346820685e91408dcaaf9af687dd1baba10';

abstract class _$HourlyWage extends $Notifier<double> {
  double build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<double, double>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<double, double>,
              double,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(DefaultTimezone)
const defaultTimezoneProvider = DefaultTimezoneProvider._();

final class DefaultTimezoneProvider
    extends $NotifierProvider<DefaultTimezone, String?> {
  const DefaultTimezoneProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'defaultTimezoneProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$defaultTimezoneHash();

  @$internal
  @override
  DefaultTimezone create() => DefaultTimezone();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$defaultTimezoneHash() => r'1792081f2387c9b74e25c06e4f2b6b0804f7d0f3';

abstract class _$DefaultTimezone extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String?, String?>,
              String?,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(SecondaryTimezone)
const secondaryTimezoneProvider = SecondaryTimezoneProvider._();

final class SecondaryTimezoneProvider
    extends $NotifierProvider<SecondaryTimezone, String?> {
  const SecondaryTimezoneProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'secondaryTimezoneProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$secondaryTimezoneHash();

  @$internal
  @override
  SecondaryTimezone create() => SecondaryTimezone();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$secondaryTimezoneHash() => r'4f31e96218a3c5ccf5a11130a4427e8b9c99e800';

abstract class _$SecondaryTimezone extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String?, String?>,
              String?,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(IsMessageIntegrationTutorialCompleted)
const isMessageIntegrationTutorialCompletedProvider =
    IsMessageIntegrationTutorialCompletedProvider._();

final class IsMessageIntegrationTutorialCompletedProvider
    extends $NotifierProvider<IsMessageIntegrationTutorialCompleted, bool> {
  const IsMessageIntegrationTutorialCompletedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'isMessageIntegrationTutorialCompletedProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() =>
      _$isMessageIntegrationTutorialCompletedHash();

  @$internal
  @override
  IsMessageIntegrationTutorialCompleted create() =>
      IsMessageIntegrationTutorialCompleted();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$isMessageIntegrationTutorialCompletedHash() =>
    r'7e869a44c4612ffdc972e947bd2c47b6034e9129';

abstract class _$IsMessageIntegrationTutorialCompleted extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(CreateTaskFromMailTutorialDone)
const createTaskFromMailTutorialDoneProvider =
    CreateTaskFromMailTutorialDoneProvider._();

final class CreateTaskFromMailTutorialDoneProvider
    extends $NotifierProvider<CreateTaskFromMailTutorialDone, bool> {
  const CreateTaskFromMailTutorialDoneProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'createTaskFromMailTutorialDoneProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$createTaskFromMailTutorialDoneHash();

  @$internal
  @override
  CreateTaskFromMailTutorialDone create() => CreateTaskFromMailTutorialDone();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$createTaskFromMailTutorialDoneHash() =>
    r'cd088f3297f150533cb3fa487e99bae0d2b4092c';

abstract class _$CreateTaskFromMailTutorialDone extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(OAuthDisconnectedIgnored)
const oAuthDisconnectedIgnoredProvider = OAuthDisconnectedIgnoredProvider._();

final class OAuthDisconnectedIgnoredProvider
    extends $NotifierProvider<OAuthDisconnectedIgnored, bool> {
  const OAuthDisconnectedIgnoredProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'oAuthDisconnectedIgnoredProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$oAuthDisconnectedIgnoredHash();

  @$internal
  @override
  OAuthDisconnectedIgnored create() => OAuthDisconnectedIgnored();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$oAuthDisconnectedIgnoredHash() =>
    r'a05b4d66709b5881aa6456c5fddb6324f0133dd9';

abstract class _$OAuthDisconnectedIgnored extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(LastTimeSavedViewType)
const lastTimeSavedViewTypeProvider = LastTimeSavedViewTypeProvider._();

final class LastTimeSavedViewTypeProvider
    extends $NotifierProvider<LastTimeSavedViewType, TimeSavedViewType> {
  const LastTimeSavedViewTypeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'lastTimeSavedViewTypeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$lastTimeSavedViewTypeHash();

  @$internal
  @override
  LastTimeSavedViewType create() => LastTimeSavedViewType();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TimeSavedViewType value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TimeSavedViewType>(value),
    );
  }
}

String _$lastTimeSavedViewTypeHash() =>
    r'90b957e6b1bc60e3c3f2de0ef18dafa6a367556a';

abstract class _$LastTimeSavedViewType extends $Notifier<TimeSavedViewType> {
  TimeSavedViewType build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<TimeSavedViewType, TimeSavedViewType>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<TimeSavedViewType, TimeSavedViewType>,
              TimeSavedViewType,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(TotalSavedTime)
const totalSavedTimeProvider = TotalSavedTimeProvider._();

final class TotalSavedTimeProvider
    extends $NotifierProvider<TotalSavedTime, double> {
  const TotalSavedTimeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'totalSavedTimeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$totalSavedTimeHash();

  @$internal
  @override
  TotalSavedTime create() => TotalSavedTime();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(double value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<double>(value),
    );
  }
}

String _$totalSavedTimeHash() => r'dd1b84e7fe31d1dc0405f61269315ff7f179e7e4';

abstract class _$TotalSavedTime extends $Notifier<double> {
  double build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<double, double>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<double, double>,
              double,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
