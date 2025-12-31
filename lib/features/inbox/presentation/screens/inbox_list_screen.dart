import 'dart:async';
import 'dart:math';

import 'package:Visir/config/providers.dart';
import 'package:Visir/dependency/flutter_swipe_action_cell/lib/flutter_swipe_action_cell.dart';
import 'package:Visir/dependency/showcase_tutorial/src/enum.dart';
import 'package:Visir/features/auth/application/auth_controller.dart';
import 'package:Visir/features/auth/domain/entities/user_entity.dart';
import 'package:Visir/features/chat/application/chat_channel_list_controller.dart';
import 'package:Visir/features/chat/domain/entities/message_channel_entity.dart';
import 'package:Visir/features/chat/presentation/screens/chat_list_screen.dart';
import 'package:Visir/features/chat/providers.dart';
import 'package:Visir/features/common/domain/entities/linked_item_entity.dart';
import 'package:Visir/features/common/presentation/utils/constants.dart';
import 'package:Visir/features/common/presentation/utils/extensions/date_time_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/list_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/platform_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/utils/log_event.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/common/presentation/widgets/bottom_dialog_option.dart';
import 'package:Visir/features/common/presentation/widgets/custom_circualr_loading_indicator.dart';
import 'package:Visir/features/common/presentation/widgets/desktop_scaffold.dart';
import 'package:Visir/features/common/presentation/widgets/keyboard_shortcut.dart';
import 'package:Visir/features/common/presentation/widgets/multi_finger_gesture_detector.dart';
import 'package:Visir/features/common/presentation/widgets/platform_scroll_physics.dart';
import 'package:Visir/features/common/presentation/widgets/showcase_wrapper.dart';
import 'package:Visir/features/common/presentation/widgets/visir_app_bar.dart';
import 'package:Visir/features/common/presentation/widgets/visir_button.dart';
import 'package:Visir/features/common/presentation/widgets/visir_empty_widget.dart';
import 'package:Visir/features/common/presentation/widgets/visir_icon.dart';
import 'package:Visir/features/common/presentation/widgets/visir_list_section.dart';
import 'package:Visir/features/common/presentation/widgets/tutorial/feature_tutorial_widget.dart';
import 'package:Visir/features/common/presentation/widgets/wave_refresh_footer.dart';
import 'package:Visir/features/common/presentation/widgets/wave_refresh_header.dart';
import 'package:Visir/features/common/provider.dart';
import 'package:Visir/features/inbox/application/inbox_config_controller.dart';
import 'package:Visir/features/inbox/application/inbox_controller.dart';
import 'package:Visir/features/inbox/application/inbox_suggestion_controller.dart';
import 'package:Visir/features/inbox/domain/entities/inbox_entity.dart';
import 'package:Visir/features/inbox/domain/entities/inbox_suggestion_entity.dart';
import 'package:Visir/features/inbox/presentation/widgets/inbox_appbar.dart';
import 'package:Visir/features/inbox/presentation/widgets/inbox_draggable.dart';
import 'package:Visir/features/inbox/presentation/widgets/inbox_item.dart';
import 'package:Visir/features/inbox/providers.dart';
import 'package:Visir/features/mail/domain/entities/mail_label_entity.dart';
import 'package:Visir/features/mail/presentation/screens/mail_detail_screen.dart';
import 'package:Visir/features/mail/providers.dart';
import 'package:Visir/features/preference/application/local_pref_controller.dart';
import 'package:Visir/features/preference/domain/entities/oauth_entity.dart';
import 'package:Visir/features/preference/presentation/screens/preference_screen.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:collection/collection.dart';
import 'package:easy_debounce/easy_throttle.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:super_context_menu/super_context_menu.dart';
import 'package:super_sliver_list/super_sliver_list.dart';
import 'package:time/time.dart';

enum TimeSectionOfDay { midnight, dawn, sunrise, morning, noon, afternoon, sunset, night }

extension TimeSectionOfDayX on TimeSectionOfDay {
  int get startTime {
    switch (this) {
      case TimeSectionOfDay.midnight:
        return 0;
      case TimeSectionOfDay.dawn:
        return 3;
      case TimeSectionOfDay.sunrise:
        return 6;
      case TimeSectionOfDay.morning:
        return 9;
      case TimeSectionOfDay.noon:
        return 12;
      case TimeSectionOfDay.afternoon:
        return 15;
      case TimeSectionOfDay.sunset:
        return 18;
      case TimeSectionOfDay.night:
        return 21;
    }
  }

  int get endTime {
    switch (this) {
      case TimeSectionOfDay.midnight:
        return 3;
      case TimeSectionOfDay.dawn:
        return 6;
      case TimeSectionOfDay.sunrise:
        return 9;
      case TimeSectionOfDay.morning:
        return 12;
      case TimeSectionOfDay.noon:
        return 15;
      case TimeSectionOfDay.afternoon:
        return 18;
      case TimeSectionOfDay.sunset:
        return 21;
      case TimeSectionOfDay.night:
        return 24;
    }
  }

  String get title {
    switch (this) {
      case TimeSectionOfDay.midnight:
        return 'Midnight';
      case TimeSectionOfDay.dawn:
        return 'Dawn';
      case TimeSectionOfDay.sunrise:
        return 'Sunrise';
      case TimeSectionOfDay.morning:
        return 'Morning';
      case TimeSectionOfDay.noon:
        return 'Noon';
      case TimeSectionOfDay.afternoon:
        return 'Afternoon';
      case TimeSectionOfDay.sunset:
        return 'Sunset';
      case TimeSectionOfDay.night:
        return 'Night';
    }
  }
}

enum InboxAISortOrFilterType {
  section_sort,
  sort_by_recent,
  sort_by_importance,
  sort_by_due,
  section_filter,
  filter_all,
  filter_urgent,
  filter_important,
  filter_action_required,
  filter_none,
}

extension InboxAISortOrFilterTypeX on InboxAISortOrFilterType {
  InboxSuggestionFilterType get inboxSuggestionFilterType {
    switch (this) {
      case InboxAISortOrFilterType.filter_all:
        return InboxSuggestionFilterType.all;
      case InboxAISortOrFilterType.filter_urgent:
        return InboxSuggestionFilterType.urgent;
      case InboxAISortOrFilterType.filter_important:
        return InboxSuggestionFilterType.important;
      case InboxAISortOrFilterType.filter_action_required:
        return InboxSuggestionFilterType.actionRequired;
      case InboxAISortOrFilterType.filter_none:
        return InboxSuggestionFilterType.none;
      default:
        return InboxSuggestionFilterType.none;
    }
  }

  InboxSuggestionSortType get inboxSuggestionSortType {
    switch (this) {
      case InboxAISortOrFilterType.sort_by_recent:
        return InboxSuggestionSortType.date;
      case InboxAISortOrFilterType.sort_by_importance:
        return InboxSuggestionSortType.importance;
      case InboxAISortOrFilterType.sort_by_due:
        return InboxSuggestionSortType.due;
      default:
        return InboxSuggestionSortType.date;
    }
  }
}

extension InboxSortOrFilterTypeX on InboxAISortOrFilterType {
  bool get isSort =>
      this == InboxAISortOrFilterType.section_sort ||
      this == InboxAISortOrFilterType.sort_by_recent ||
      this == InboxAISortOrFilterType.sort_by_importance ||
      this == InboxAISortOrFilterType.sort_by_due;

  bool get isFilter =>
      this == InboxAISortOrFilterType.section_filter ||
      this == InboxAISortOrFilterType.filter_all ||
      this == InboxAISortOrFilterType.filter_urgent ||
      this == InboxAISortOrFilterType.filter_important ||
      this == InboxAISortOrFilterType.filter_action_required ||
      this == InboxAISortOrFilterType.filter_none;

  String get name {
    switch (this) {
      case InboxAISortOrFilterType.sort_by_recent:
        return Utils.mainContext.tr.inbox_sort_recent;
      case InboxAISortOrFilterType.sort_by_importance:
        return Utils.mainContext.tr.inbox_sort_importnace;
      case InboxAISortOrFilterType.sort_by_due:
        return Utils.mainContext.tr.inbox_sort_due;
      case InboxAISortOrFilterType.filter_all:
        return Utils.mainContext.tr.inbox_filter_all;
      case InboxAISortOrFilterType.filter_urgent:
        return Utils.mainContext.tr.inbox_filter_urgent;
      case InboxAISortOrFilterType.filter_important:
        return Utils.mainContext.tr.inbox_filter_important;
      case InboxAISortOrFilterType.filter_action_required:
        return Utils.mainContext.tr.inbox_filter_action_required;
      case InboxAISortOrFilterType.filter_none:
        return Utils.mainContext.tr.inbox_filter_hide_all;
      case InboxAISortOrFilterType.section_sort:
        return Utils.mainContext.tr.inbox_sort_section;
      case InboxAISortOrFilterType.section_filter:
        return Utils.mainContext.tr.inbox_filter_section;
    }
  }

  bool get isSection => this == InboxAISortOrFilterType.section_sort || this == InboxAISortOrFilterType.section_filter;
}

enum InboxRightClickOptionType { read, delete }

extension InboxRightClickOptionTypeX on InboxRightClickOptionType {
  String getName(BuildContext context, List<InboxEntity> totalInboxes, List<MessageChannelEntity> channels) {
    switch (this) {
      case InboxRightClickOptionType.read:
        return totalInboxes.where((e) => e.getIsUnread(channels)).isNotEmpty ? context.tr.inbox_right_click_option_read : context.tr.inbox_right_click_option_unread;
      case InboxRightClickOptionType.delete:
        return totalInboxes.where((e) => e.config?.isDeleted == true).isNotEmpty ? context.tr.inbox_right_click_option_undelete : context.tr.inbox_right_click_option_delete;
    }
  }

  VisirIconType getIcon(List<InboxEntity> totalInboxes, List<MessageChannelEntity> channels) {
    switch (this) {
      case InboxRightClickOptionType.read:
        return totalInboxes.where((e) => e.getIsUnread(channels)).isNotEmpty ? VisirIconType.show : VisirIconType.hide;
      case InboxRightClickOptionType.delete:
        return totalInboxes.where((e) => e.config?.isDeleted != true).isNotEmpty ? VisirIconType.trash : VisirIconType.inboxIn;
    }
  }

  IconData getMenuIcon(List<InboxEntity> totalInboxes, List<MessageChannelEntity> channels) {
    switch (this) {
      case InboxRightClickOptionType.read:
        return totalInboxes.where((e) => e.getIsUnread(channels)).isNotEmpty ? Icons.visibility : Icons.visibility_off;
      case InboxRightClickOptionType.delete:
        return totalInboxes.where((e) => e.config?.isDeleted != true).isNotEmpty ? Icons.delete : Icons.inbox;
    }
  }

  Color getColor(BuildContext context, List<InboxEntity> totalInboxes, List<MessageChannelEntity> channels) {
    switch (this) {
      case InboxRightClickOptionType.read:
        return totalInboxes.where((e) => e.getIsUnread(channels)).isNotEmpty ? context.outlineVariant : context.outlineVariant;
      case InboxRightClickOptionType.delete:
        return totalInboxes.where((e) => e.config?.isDeleted != true).isNotEmpty ? context.error : context.outlineVariant;
    }
  }
}

class InboxListScreen extends ConsumerStatefulWidget {
  final TabType tabType;
  final void Function(InboxEntity inbox)? onDragStart;
  final void Function(InboxEntity inbox, Offset offset)? onDragUpdate;
  final void Function(InboxEntity inbox, Offset offset)? onDragEnd;

  final void Function()? onRemoveCreateShadow;
  final void Function()? onSaved;
  final void Function(String? title)? onTitleChanged;
  final void Function(Color? color)? onColorChanged;
  final void Function(DateTime startTime, DateTime endTime, bool isAllDay)? onTimeChanged;
  final void Function(bool isTask)? updateIsTask;
  final void Function(DateTime startTime, DateTime endTime, bool isAllDay)? onShowCreateShadow;
  final void Function() onSidebarButtonPressed;

  InboxListScreen({
    super.key,
    this.onDragStart,
    this.onDragUpdate,
    this.onDragEnd,
    required this.tabType,
    this.onRemoveCreateShadow,
    this.onSaved,
    this.onTitleChanged,
    this.onColorChanged,
    this.onTimeChanged,
    this.updateIsTask,
    this.onShowCreateShadow,
    required this.onSidebarButtonPressed,
  });

  @override
  InboxListScreenState createState() => InboxListScreenState();
}

class InboxListScreenState extends ConsumerState<InboxListScreen> {
  bool isToday = true;
  String? searchQuery;
  InboxEntity? selectedInbox;
  List<String> selectedInboxIds = [];
  int selectedInboxSelctedCount = 0;
  Timer? refreshTimer;

  Offset lastPosition = Offset.zero;
  RefreshController refreshController = RefreshController();
  bool isLoadingMore = false;
  bool onMoveToDate = false;
  FocusNode searchFocusNode = FocusNode();

  List<InboxEntity> totalInboxes = [];

  ListController listController = ListController();
  ScrollController scrollController = ScrollController();

  double popupWidth = 480.0;
  double popupHeight = 0;

  Map<TimeSectionOfDay, Map<DateTime, List<List<InboxEntity>>>> currentInboxes = {};
  List<InboxEntity> suggestionInboxes = [];

  ValueNotifier<bool> showLoadingNotifier = ValueNotifier(false);

  bool get showMobileUI => PlatformX.isMobileView;

  bool get isDetailOpened => Navigator.of(context).canPop();

  List<String> unmodifiedUnreadInboxIds = [];

  GlobalKey<ChatListScreenState> chatListScreenKey = GlobalKey();

  GlobalKey smartRefresherKey = GlobalKey();
  bool get isDarkMode => context.isDarkMode;

  PlatformScrollController platformScrollController = PlatformScrollController(enableTwoFingerDrag: true);

  List<MessageChannelEntity> get channels => ref.watch(chatChannelListControllerProvider.select((v) => v.values.expand((e) => e.channels).toList()));

  bool get _isSearch => ref.read(inboxListIsSearchProvider);
  DateTime get _currentDate => ref.read(inboxListDateProvider);
  InboxFilterType get _inboxFilter => ref.read(inboxFilterProvider(widget.tabType));

  void closeDetails() {
    if (showMobileUI) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else {
      final resizableClosableWidget = Utils.ref.read(resizableClosableWidgetProvider(widget.tabType));
      if (resizableClosableWidget == null) return;
      Utils.ref.read(resizableClosableWidgetProvider(widget.tabType).notifier).setWidget(null);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        mailViewportSyncVisibleNotifier[widget.tabType]!.value = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    refreshTimer = Timer.periodic(Duration(minutes: 1), (timer) {
      if (isToday && !DateUtils.isSameDay(DateTime.now(), _currentDate)) {
        moveToDate(DateUtils.dateOnly(DateTime.now()));
      }
    });

    searchFocusNode.onKeyEvent = onKeyEventTextField;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      showLoadingOnMobile();
      showInboxDragTutorialPopupOnMobile();
      onShowcaseOnListener();
    });

    isShowcaseOn.addListener(onShowcaseOnListener);
  }

  void onShowcaseOnListener() {
    if (isShowcaseOn.value == inboxItemShowcaseKeyString) {
      scrollController.jumpTo(0);
    }
  }

  void showLoadingOnMobile() {
    showLoadingNotifier.value = showMobileUI;
  }

  void hideLoadingOnMobile() {
    showLoadingNotifier.value = false;
  }

  @override
  void dispose() {
    refreshTimer?.cancel();
    isShowcaseOn.removeListener(onShowcaseOnListener);
    searchFocusNode.dispose();
    scrollController.dispose();
    refreshController.dispose();
    showLoadingNotifier.dispose();
    super.dispose();
  }

  KeyEventResult onKeyEventTextField(FocusNode node, KeyEvent event) {
    final key = event.logicalKey;
    if (event is KeyDownEvent) {
      if (ServicesBinding.instance.keyboard.logicalKeysPressed.length == 1 && key == LogicalKeyboardKey.escape) {
        unsearch();
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  void unsearch() {
    if (!ref.read(inboxListIsSearchProvider)) return;
    ref.read(inboxListIsSearchProvider.notifier).updateIsSearch(false);
    searchQuery = null;
    selectedInboxIds.clear();
    setState(() {});
    ref.read(inboxControllerProvider.notifier).updateIsSearchDone(false);
  }

  Future<void> moveToDate(DateTime dateTime) async {
    if (dateTime.isAfter(DateUtils.dateOnly(DateTime.now()))) return;
    if (DateUtils.isSameDay(dateTime, _currentDate)) return;

    ref.read(inboxListDateProvider.notifier).updateDate(DateUtils.dateOnly(dateTime));
    selectedInbox = null;
    onMoveToDate = true;

    if (DateUtils.isSameDay(DateTime.now(), _currentDate)) {
      isToday = true;
    } else {
      isToday = false;
    }

    onMoveToDate = false;

    setInboxFilter(InboxFilterType.all);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showInboxDragTutorialPopupOnMobile();
    });
  }

  void setInboxFilter(InboxFilterType type) {
    ref.read(inboxFilterProvider(widget.tabType).notifier).setInboxFilter(type);
  }

  bool toggleDeleteInbox({bool? justReturnResult}) {
    final deleteTargetInboxs = selectedInboxIds.isEmpty
        ? selectedInbox == null
              ? []
              : [selectedInbox]
        : totalInboxes.where((e) => selectedInboxIds.any((o) => e.inboxIdWithCheckSuggestion == o)).toList().unique((e) => e.inboxId);

    if (deleteTargetInboxs.isNotEmpty) {
      if (justReturnResult == true) return true;
      if (!PlatformX.isMobileView) {
        moveNext();
      }

      final date = ref.read(inboxListDateProvider);
      final isSignedIn = ref.read(authControllerProvider.select((v) => v.requireValue.isSignedIn));
      ref
          .read(inboxConfigListControllerProvider(isSearch: false, year: date.year, month: date.month, day: date.day, isSignedIn: isSignedIn).notifier)
          .updateInboxConfig(
            configs: [...deleteTargetInboxs.map((e) => e.config!.copyWith(isDeleted: !(e.config?.isDeleted ?? false), inboxUniqueId: e.uniqueId))],
          );

      Navigator.of(Utils.mainContext).maybePop();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        final originalInboxes = ref.read(inboxControllerProvider.select((v) => v?.inboxes)) ?? [];
        final showDeleted = originalInboxes.where((e) => e.config?.isDeleted ?? false).isEmpty == true;
        if (_inboxFilter == InboxFilterType.deleted && showDeleted) {
          setInboxFilter(InboxFilterType.all);
        }
      });

      selectedInboxIds.clear();
      setState(() {});

      return true;
    }
    return false;
  }

  bool setInboxConfigOnSelectedInboxes({required List<InboxEntity> targetInboxes, bool? isRead, bool? isDeleted}) {
    if (targetInboxes.isNotEmpty) {
      if (isDeleted == true && !PlatformX.isMobileView) {
        moveNext();
      }

      final date = ref.read(inboxListDateProvider);
      final isSignedIn = ref.read(authControllerProvider.select((v) => v.requireValue.isSignedIn));
      ref
          .read(inboxConfigListControllerProvider(isSearch: false, year: date.year, month: date.month, day: date.day, isSignedIn: isSignedIn).notifier)
          .updateInboxConfig(
            configs: [
              ...targetInboxes.map((e) {
                return e.config!.copyWith(isRead: isRead, isDeleted: isDeleted, inboxUniqueId: e.id);
              }),
            ],
          );

      Navigator.of(Utils.mainContext).maybePop();

      if (isDeleted == true) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final originalInboxes = ref.read(inboxControllerProvider.notifier).availableInboxes;
          final showDeleted = originalInboxes.where((e) => e.config?.isDeleted ?? false).isEmpty == true;
          if (_inboxFilter == InboxFilterType.deleted && showDeleted) {
            setInboxFilter(InboxFilterType.all);
          }
        });
      }

      if (PlatformX.isMobileView) {
        selectedInboxIds.clear();
        setState(() {});
      }

      return true;
    }
    return false;
  }

  bool moveNext({bool? doNotMovePrevIfLast, bool? justReturnResult}) {
    final tasks = [...suggestionInboxes, ...currentInboxes.values.expand((e) => e.values.expand((e) => e)).expand((e) => e).toList()];

    final selectedInboxId = selectedInboxIds.lastOrNull ?? selectedInbox?.inboxIdWithCheckSuggestion;
    final index = selectedInboxId == null ? -1 : tasks.indexWhere((e) => e.inboxIdWithCheckSuggestion == selectedInboxId);

    if (index < tasks.length - 1) {
      if (justReturnResult == true) return true;
      final inbox = tasks[index + 1];
      selectedInbox = inbox;
      selectedInboxSelctedCount += 1;
      setState(() {});
      final date = ref.read(inboxListDateProvider);
      final isSignedIn = ref.read(authControllerProvider.select((v) => v.requireValue.isSignedIn));
      ref.read(inboxConfigListControllerProvider(isSearch: false, year: date.year, month: date.month, day: date.day, isSignedIn: isSignedIn).notifier).updateInboxConfig(configs: [inbox.config!.copyWith(isRead: true, inboxUniqueId: inbox.id)]);
      openInbox();

      int? minVisible = listController.visibleRange?.$1;
      int? maxVisible = listController.visibleRange?.$2;
      if (minVisible != null && maxVisible != null) {
        if (index + 1 <= minVisible || index + 1 >= maxVisible) {
          listController.animateToItem(
            index: index + 1,
            scrollController: scrollController,
            alignment: 1,
            duration: (distance) => Duration(milliseconds: 200),
            curve: (distance) => Curves.easeInOut,
          );
        }
      }
      return true;
    } else if (index == tasks.length - 1) {
      if (doNotMovePrevIfLast == true) return false;
      if (justReturnResult == true) return true;
      final inbox = tasks[index - 1];
      selectedInbox = inbox;
      selectedInboxSelctedCount += 1;
      setState(() {});
      final date = ref.read(inboxListDateProvider);
      final isSignedIn = ref.read(authControllerProvider.select((v) => v.requireValue.isSignedIn));
      ref.read(inboxConfigListControllerProvider(isSearch: false, year: date.year, month: date.month, day: date.day, isSignedIn: isSignedIn).notifier).updateInboxConfig(configs: [inbox.config!.copyWith(isRead: true, inboxUniqueId: inbox.id)]);
      openInbox();

      int? minVisible = listController.visibleRange?.$1;
      int? maxVisible = listController.visibleRange?.$2;
      if (minVisible != null && maxVisible != null) {
        if (index - 1 <= minVisible || index - 1 >= maxVisible) {
          listController.animateToItem(
            index: index - 1,
            scrollController: scrollController,
            alignment: 0,
            duration: (distance) => Duration(milliseconds: 200),
            curve: (distance) => Curves.easeInOut,
          );
        }
      }
      return true;
    }

    return false;
  }

  bool movePrev({bool? justReturnResult}) {
    final tasks = [...suggestionInboxes, ...currentInboxes.values.expand((e) => e.values.expand((e) => e)).expand((e) => e).toList()];

    final selectedInboxId = selectedInboxIds.lastOrNull ?? selectedInbox?.inboxIdWithCheckSuggestion;
    final index = selectedInboxId == null ? null : tasks.indexWhere((e) => e.inboxIdWithCheckSuggestion == selectedInboxId);

    if (index != null && index > 0) {
      if (justReturnResult == true) return true;
      final inbox = tasks[index - 1];
      selectedInbox = inbox;
      selectedInboxSelctedCount += 1;
      setState(() {});
      final date = ref.read(inboxListDateProvider);
      final isSignedIn = ref.read(authControllerProvider.select((v) => v.requireValue.isSignedIn));
      ref.read(inboxConfigListControllerProvider(isSearch: false, year: date.year, month: date.month, day: date.day, isSignedIn: isSignedIn).notifier).updateInboxConfig(configs: [inbox.config!.copyWith(isRead: true, inboxUniqueId: inbox.id)]);
      openInbox();

      int? minVisible = listController.visibleRange?.$1;
      int? maxVisible = listController.visibleRange?.$2;
      if (minVisible != null && maxVisible != null) {
        if (index - 1 <= minVisible || index - 1 >= maxVisible) {
          listController.animateToItem(
            index: index - 1,
            scrollController: scrollController,
            alignment: 0,
            duration: (distance) => Duration(milliseconds: 200),
            curve: (distance) => Curves.easeInOut,
          );
        }
      }
      return true;
    }
    return false;
  }

  bool moveNextGroup({bool? justReturnResult}) {
    final tasks = [...suggestionInboxes, ...currentInboxes.values.expand((e) => e.values.expand((e) => e)).expand((e) => e).toList()];

    final selectedInboxId = selectedInboxIds.lastOrNull ?? selectedInbox?.inboxIdWithCheckSuggestion;
    final index = selectedInboxId == null ? null : tasks.lastIndexWhere((e) => e.inboxGroupIdWithCheckSuggestion == selectedInboxId);

    if (index != null && index < tasks.length - 1) {
      if (justReturnResult == true) return true;
      final inbox = tasks[index + 1];
      selectedInbox = inbox;
      selectedInboxSelctedCount += 1;
      setState(() {});
      final date = ref.read(inboxListDateProvider);
      final isSignedIn = ref.read(authControllerProvider.select((v) => v.requireValue.isSignedIn));
      ref.read(inboxConfigListControllerProvider(isSearch: false, year: date.year, month: date.month, day: date.day, isSignedIn: isSignedIn).notifier).updateInboxConfig(configs: [inbox.config!.copyWith(isRead: true, inboxUniqueId: inbox.id)]);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        openInbox();
      });
      return true;
    }

    if (index != null && index == tasks.length - 1) {
      if (justReturnResult == true) return true;
      final inbox = tasks[index - 1];
      selectedInbox = inbox;
      selectedInboxSelctedCount += 1;
      setState(() {});
      final date = ref.read(inboxListDateProvider);
      final isSignedIn = ref.read(authControllerProvider.select((v) => v.requireValue.isSignedIn));
      ref.read(inboxConfigListControllerProvider(isSearch: false, year: date.year, month: date.month, day: date.day, isSignedIn: isSignedIn).notifier).updateInboxConfig(configs: [inbox.config!.copyWith(isRead: true, inboxUniqueId: inbox.id)]);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        openInbox();
      });
      return true;
    }

    return false;
  }

  bool movePrevGroup({bool? justReturnResult}) {
    final tasks = [...suggestionInboxes, ...currentInboxes.values.expand((e) => e.values.expand((e) => e)).expand((e) => e).toList()];

    final selectedInboxId = selectedInboxIds.lastOrNull ?? selectedInbox?.inboxIdWithCheckSuggestion;
    final index = selectedInboxId == null ? null : tasks.indexWhere((e) => e.inboxGroupIdWithCheckSuggestion == selectedInboxId);

    if (index != null && index > 0) {
      if (justReturnResult == true) return true;
      final inbox = tasks[index - 1];
      selectedInbox = inbox;
      selectedInboxSelctedCount += 1;
      setState(() {});
      final date = ref.read(inboxListDateProvider);
      final isSignedIn = ref.read(authControllerProvider.select((v) => v.requireValue.isSignedIn));
      ref.read(inboxConfigListControllerProvider(isSearch: false, year: date.year, month: date.month, day: date.day, isSignedIn: isSignedIn).notifier).updateInboxConfig(configs: [inbox.config!.copyWith(isRead: true, inboxUniqueId: inbox.id)]);
      openInbox();
      return true;
    }
    return false;
  }

  void selectInboxFromId(String inboxId) {
    final inbox = currentInboxes.values.expand((e) => e.values.expand((e) => e)).expand((e) => e).firstWhereOrNull((e) => e.id == inboxId);
    if (inbox == null) return;
    selectedInbox = inbox;
    setState(() {});
  }

  void openInbox() {
    if (selectedInbox == null) return;

    final inbox = selectedInbox!.copyWith();
    List<InboxEntity>? inboxGroup;
    currentInboxes.keys.forEach((timeSection) {
      final sectionGroup = currentInboxes[timeSection];
      sectionGroup?.keys.forEach((date) {
        final dateGroup = sectionGroup[date]!;
        final result = dateGroup.firstWhereOrNull((e) => e.map((e) => e.id).contains(inbox.id));
        if (result != null) inboxGroup = result;
      });
    });

    if (inboxGroup == null) return;

    final channels = ref.read(chatChannelListControllerProvider.select((v) => v.values.expand((e) => e.channels).toList()));
    final channel = channels.firstWhereOrNull((e) => e.id == inbox.linkedMessage?.channelId);

    if (inbox.linkedMessage != null) {
      if (channel == null) return;
      ref.read(chatConditionProvider(widget.tabType).notifier).setThreadAndChannel(inbox.linkedMessage!.threadId, channel, targetMessageId: inbox.linkedMessage!.messageId);
    }

    if (inbox.linkedMail != null) {
      final inboxMail = inbox.linkedMail!;
      ref
          .read(mailConditionProvider(widget.tabType).notifier)
          .openThread(label: CommonMailLabels.inbox.id, email: null, threadId: inboxMail.threadId, threadEmail: inboxMail.hostMail, type: inboxMail.type);
    }

    mailViewportSyncVisibleNotifier[widget.tabType]!.value = false;
    selectedInboxIds.clear();
    setState(() {});

    if (showMobileUI) {
      Navigator.of(context).push(
        CupertinoPageRoute(
          builder: (context) {
            if (inbox.linkedMail != null) {
              return MailDetailScreen(
                tabType: widget.tabType,
                taskMail: inbox.linkedMail!,
                anchorMailId: inbox.linkedMail!.messageId,
                onKeyDown: (event) => _onKeyDown(event, justReturnResult: true),
                onKeyRepeat: (event) => _onKeyRepeat(event, justReturnResult: true),
                deleteTask: () => toggleDeleteInbox(),
                inboxConfig: inbox.config,
                close: closeDetails,
              );
            }

            return ChatListScreen(
              key: chatListScreenKey,
              tabType: widget.tabType,
              taskMessage: inbox.linkedMessage!,
              taskMessageGroupIds: inboxGroup?.map((e) => e.linkedMessage!.messageId).toList(),
              onKeyDown: (event) => _onKeyDown(event, justReturnResult: true),
              onKeyRepeat: (event) => _onKeyRepeat(event, justReturnResult: true),
              deleteTask: () => toggleDeleteInbox(),
              inboxConfig: inbox.config,
              close: closeDetails,
            );
          },
          settings: RouteSettings(name: 'inbox_list_screen_detail'),
        ),
      );
      if (inbox.linkedMail != null) {
        mailViewportSyncVisibleNotifier[widget.tabType]!.value = true;
      }
    } else {
      final run = () {
        if (inbox.linkedMail != null) {
          mailViewportSyncVisibleNotifier[widget.tabType]!.value = true;
          ref
              .read(resizableClosableWidgetProvider(widget.tabType).notifier)
              .setWidget(
                ResizableWidget(
                  widget: MailDetailScreen(
                    key: ValueKey(inbox.id),
                    tabType: widget.tabType,
                    taskMail: inbox.linkedMail!,
                    anchorMailId: inbox.linkedMail!.messageId,
                    onKeyDown: (event) => _onKeyDown(event, justReturnResult: true),
                    onKeyRepeat: (event) => _onKeyRepeat(event, justReturnResult: true),
                    deleteTask: () => toggleDeleteInbox(),
                    inboxConfig: inbox.config,
                    close: closeDetails,
                  ),
                  minWidth: 320,
                ),
              );
        } else if (inbox.linkedMessage != null) {
          ref
              .read(resizableClosableWidgetProvider(widget.tabType).notifier)
              .setWidget(
                ResizableWidget(
                  widget: ChatListScreen(
                    key: ValueKey(inbox.id),
                    tabType: widget.tabType,
                    taskMessage: inbox.linkedMessage!,
                    taskMessageGroupIds: inboxGroup?.map((e) => e.linkedMessage!.messageId).toList(),
                    onKeyDown: (event) => _onKeyDown(event, justReturnResult: true),
                    onKeyRepeat: (event) => _onKeyRepeat(event, justReturnResult: true),
                    deleteTask: () => toggleDeleteInbox(),
                    inboxConfig: inbox.config,
                    close: closeDetails,
                  ),
                  minWidth: 320,
                ),
              );
        }
      };
      EasyThrottle.throttle('inbox_item_clicked', Duration(milliseconds: 500), run, onAfter: run);
    }
  }

  bool _onKeyDown(KeyEvent event, {bool? justReturnResult}) {
    final logicalKeyPressed = HardwareKeyboard.instance.logicalKeysPressed.where((e) => e != LogicalKeyboardKey.escape);
    bool ctrlPressed = (HardwareKeyboard.instance.isMetaPressed && PlatformX.isApple) || (HardwareKeyboard.instance.isControlPressed && !PlatformX.isApple);
    bool shiftPressed = HardwareKeyboard.instance.isShiftPressed;

    if (ServicesBinding.instance.keyboard.logicalKeysPressed.length == 1 && event.logicalKey == LogicalKeyboardKey.escape) {
      if (justReturnResult == true) return true;

      selectedInboxIds.clear();
      setState(() {});

      if (ref.read(resizableClosableWidgetProvider(widget.tabType)) == null) {
        selectedInbox = null;
        selectedInboxSelctedCount = 0;
        setState(() {});
      } else {
        closeDetails();
      }
      return true;
    }

    if (logicalKeyPressed.length == 1) {
      if (logicalKeyPressed.contains(LogicalKeyboardKey.arrowDown)) {
        final result = moveNext(doNotMovePrevIfLast: true, justReturnResult: justReturnResult);
        if (result) return true;
      }

      if (logicalKeyPressed.contains(LogicalKeyboardKey.arrowUp)) {
        final result = movePrev(justReturnResult: justReturnResult);
        if (result) return true;
      }
    }

    if (logicalKeyPressed.length == 2) {
      if (ctrlPressed) {
        if (logicalKeyPressed.contains(LogicalKeyboardKey.arrowDown)) {
          final result = moveNextGroup(justReturnResult: justReturnResult);
          if (result) return true;
        }
        if (logicalKeyPressed.contains(LogicalKeyboardKey.arrowUp)) {
          final result = movePrevGroup(justReturnResult: justReturnResult);
          if (result) return true;
        }

        if (logicalKeyPressed.contains(LogicalKeyboardKey.delete) || logicalKeyPressed.contains(LogicalKeyboardKey.backspace)) {
          final result = toggleDeleteInbox(justReturnResult: justReturnResult);
          if (result) return true;
        }
      }

      if (shiftPressed) {
        if (logicalKeyPressed.contains(LogicalKeyboardKey.arrowDown)) {
          final selectedInboxId = selectedInboxIds.lastOrNull ?? selectedInbox?.inboxIdWithCheckSuggestion;
          final selectedInboxIndex = totalInboxes.indexWhere((e) => e.inboxIdWithCheckSuggestion == selectedInboxId);
          if (selectedInboxIndex >= 0 && totalInboxes.length > selectedInboxIndex - 1) {
            String? targetInboxId = totalInboxes[selectedInboxIndex + 1].inboxIdWithCheckSuggestion;
            if (targetInboxId != null) {
              if (selectedInboxIds.contains(targetInboxId)) targetInboxId = selectedInboxId;
              final targetInbox = totalInboxes.firstWhereOrNull((e) => e.inboxIdWithCheckSuggestion == targetInboxId);
              if (targetInbox != null) {
                final result = selectInboxes(totalInboxes: totalInboxes, targetInbox: targetInbox, containsMidInboxes: true, justReturnResult: justReturnResult);
                if (result) return true;
              }
            }
          }
        }
        if (logicalKeyPressed.contains(LogicalKeyboardKey.arrowUp)) {
          final selectedInboxId = selectedInboxIds.lastOrNull ?? selectedInbox?.inboxIdWithCheckSuggestion;
          final selectedInboxIndex = totalInboxes.indexWhere((e) => e.inboxIdWithCheckSuggestion == selectedInboxId);

          if (selectedInboxIndex > 0 && totalInboxes.length > selectedInboxIndex) {
            String? targetInboxId = totalInboxes[selectedInboxIndex - 1].inboxIdWithCheckSuggestion;
            if (targetInboxId != null) {
              if (selectedInboxIds.contains(targetInboxId)) targetInboxId = selectedInboxId;
              final targetInbox = totalInboxes.firstWhereOrNull((e) => e.inboxIdWithCheckSuggestion == targetInboxId);
              if (targetInbox != null) {
                final result = selectInboxes(totalInboxes: totalInboxes, targetInbox: targetInbox, containsMidInboxes: true, justReturnResult: justReturnResult);
                if (result) return true;
              }
            }
          }
        }
      }
    }

    return false;
  }

  bool _onKeyRepeat(KeyEvent event, {bool? justReturnResult}) {
    final logicalKeyPressed = ServicesBinding.instance.keyboard.logicalKeysPressed.where((e) => e != LogicalKeyboardKey.escape);

    if (logicalKeyPressed.length == 1) {
      if (logicalKeyPressed.contains(LogicalKeyboardKey.arrowDown)) {
        final result = moveNext(doNotMovePrevIfLast: true, justReturnResult: justReturnResult);
        if (result) return true;
      }

      if (logicalKeyPressed.contains(LogicalKeyboardKey.arrowUp)) {
        final result = movePrev(justReturnResult: justReturnResult);
        if (result) return true;
      }
    }
    return false;
  }

  Widget buildInboxFilterButton(InboxFilterType filter) {
    bool isSelected = _inboxFilter == filter;
    return VisirAppBarButton(
      child: Text(filter.getName(context), style: context.bodyMedium?.textColor(isSelected ? context.onPrimary : context.onSurface)),
      margin: EdgeInsets.symmetric(horizontal: 3),
      backgroundColor: isSelected ? context.primary : null,
      foregroundColor: isSelected ? context.onPrimary : null,
      border: isSelected ? Border.all(color: context.primary, width: 1) : Border.all(color: context.surface, width: 1),
      onTap: () => setInboxFilter(filter),
      options: VisirButtonOptions(message: context.tr.today),
    ).getButton(context: context);
  }

  void onSearchButtonPressed() {
    if (_isSearch) {
      searchFocusNode.requestFocus();
      return;
    }

    selectedInbox = null;
    if ([InboxFilterType.unread, InboxFilterType.deleted].contains(_inboxFilter)) {
      ref.read(inboxFilterProvider(widget.tabType).notifier).setInboxFilter(InboxFilterType.all);
    }
    ref.read(inboxControllerProvider.notifier).clear();
    ref.read(inboxListIsSearchProvider.notifier).updateIsSearch(!_isSearch);
    setState(() {});
    searchFocusNode.requestFocus();
  }

  Future<void> refresh() async {
    selectedInbox = null;
    setState(() {});

    if (_isSearch && searchQuery != null) {
      ref.read(inboxControllerProvider.notifier).updateIsSearchDone(false);
      await ref.read(inboxControllerProvider.notifier).search(query: searchQuery!);
      ref.read(inboxControllerProvider.notifier).updateIsSearchDone(true);
    } else {
      await ref.read(inboxControllerProvider.notifier).refresh();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      showInboxDragTutorialPopupOnMobile();
    });
  }

  void showInboxDragTutorialPopupOnMobile() {
    if (!PlatformX.isMobile) return;
    final user = Utils.ref.read(authControllerProvider).requireValue;
    if (!user.isSignedIn) return;

    if (!user.mobileInboxDragTutorialDone && currentInboxes.isNotEmpty) {
      Navigator.of(context).popUntil((route) => route.isFirst);
      Utils.showPopupDialog(
        child: FeatureTutorialWidget(type: FeatureTutorialType.inboxDragAndDrop),
        size: Size(300, 0),
        forcePopup: true,
        barrierDismissible: false,
        isFlexibleHeightPopup: true,
      );
    }
  }

  bool selectInboxes({required List<InboxEntity> totalInboxes, required InboxEntity targetInbox, bool containsMidInboxes = false, bool? justReturnResult, bool? forceRemove}) {
    if (justReturnResult == true) return true;
    final lastIndex = totalInboxes.indexWhere((e) => e.inboxIdWithCheckSuggestion == (selectedInboxIds.lastOrNull ?? selectedInbox?.inboxIdWithCheckSuggestion));

    if (containsMidInboxes && lastIndex >= 0) {
      final currentIndex = totalInboxes.indexWhere((e) => e.inboxIdWithCheckSuggestion == targetInbox.inboxIdWithCheckSuggestion);

      List<String> midInboxesIds = [];

      if (currentIndex > lastIndex) {
        for (int i = lastIndex; i <= currentIndex; i++) {
          midInboxesIds.add(totalInboxes[i].inboxIdWithCheckSuggestion!);
        }
      } else {
        for (int i = lastIndex; i >= currentIndex; i--) {
          midInboxesIds.add(totalInboxes[i].inboxIdWithCheckSuggestion!);
        }
      }

      if (midInboxesIds.any((e) => !selectedInboxIds.contains(e)) && forceRemove != true) {
        selectedInboxIds.addAll(midInboxesIds);
        selectedInbox = null;
      } else {
        final removeLength = selectedInboxIds.where((e) => midInboxesIds.contains(e)).length;
        if (PlatformX.isMobileView && selectedInboxIds.length == removeLength) return false;
        selectedInboxIds.removeWhere((e) => midInboxesIds.contains(e));
        if (midInboxesIds.contains(selectedInbox?.inboxIdWithCheckSuggestion!)) {
          selectedInbox = null;
        }
      }
    } else {
      if (!selectedInboxIds.contains(targetInbox.inboxIdWithCheckSuggestion!) && forceRemove != true) {
        selectedInboxIds.add(targetInbox.inboxIdWithCheckSuggestion!);
        selectedInbox = null;
      } else {
        if (PlatformX.isMobileView && selectedInboxIds.length == 1) return false;
        selectedInboxIds.remove(targetInbox.inboxIdWithCheckSuggestion!);
        if (selectedInbox?.inboxIdWithCheckSuggestion == targetInbox.inboxIdWithCheckSuggestion) {
          selectedInbox = null;
        }
      }
    }
    selectedInboxIds = selectedInboxIds.unique((e) => e).toList();
    setState(() {});
    closeDetails();
    return true;
  }

  void showInboxOptionsBottomDialog({required BuildContext context, required InboxEntity inbox, required List<MessageChannelEntity> channels, required user}) async {
    if (selectedInboxIds.isEmpty) return;
    if (!selectedInboxIds.contains(inbox.inboxIdWithCheckSuggestion!)) {
      selectInboxes(totalInboxes: totalInboxes, targetInbox: inbox);
    }

    List<InboxEntity> targetInboxes = totalInboxes.where((e) => selectedInboxIds.contains(e.inboxIdWithCheckSuggestion)).toList();

    final options = InboxRightClickOptionType.values;

    await Utils.showBottomDialog(
      title: TextSpan(text: context.tr.mail_options),
      body: Column(
        children: [
          ...options
              .map(
                (e) => BottomDialogOption(
                  icon: e.getIcon(targetInboxes, channels),
                  title: e.getName(context, targetInboxes, channels),
                  onTap: () {
                    switch (e) {
                      case InboxRightClickOptionType.read:
                        final isRead = targetInboxes.where((e) => e.getIsUnread(channels)).isNotEmpty;
                        setInboxConfigOnSelectedInboxes(targetInboxes: targetInboxes, isRead: isRead);
                        break;
                      case InboxRightClickOptionType.delete:
                        final isDeleted = targetInboxes.where((e) => e.config?.isDeleted != true).isNotEmpty;
                        setInboxConfigOnSelectedInboxes(targetInboxes: targetInboxes, isDeleted: isDeleted);
                        break;
                    }
                  },
                  isWarning: e.getColor(context, targetInboxes, channels) == context.error,
                ),
              )
              .toList(),
        ],
      ),
    );

    selectedInboxIds.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(inboxFilterProvider(widget.tabType), (prev, next) {
      selectedInboxIds.clear();
      selectedInbox = null;
      setState(() {});
    });

    final ratio = ref.watch(zoomRatioProvider);

    final inboxSuggestionSortType = ref.watch(inboxSuggestionSortProvider(widget.tabType)).value ?? InboxSuggestionSortType.date;
    final inboxSuggestionFilterType = ref.watch(inboxSuggestionFilterProvider(widget.tabType)).value ?? InboxSuggestionFilterType.all;

    final mailInboxFilterTypes = ref.watch(authControllerProvider.select((v) => v.requireValue.mailInboxFilterTypes)) ?? {};
    final mailInboxFilterLabelIds = ref.watch(authControllerProvider.select((v) => v.requireValue.mailInboxFilterLabelIds)) ?? {};

    final messageDmInboxFilterTypes = ref.watch(authControllerProvider.select((v) => v.requireValue.messageDmInboxFilterTypes)) ?? {};
    final messageChannelInboxFilterTypes = ref.watch(authControllerProvider.select((v) => v.requireValue.messageChannelInboxFilterTypes)) ?? {};

    final messengerOAuths = ref.watch(localPrefControllerProvider.select((v) => v.value?.messengerOAuths)) ?? [];
    final mailOAuths = ref.watch(localPrefControllerProvider).value?.mailOAuths ?? [];

    final originalInboxes =
        (ref.watch(
          inboxControllerProvider.select(
            (v) => v?.inboxes.where((e) {
              if (_isSearch) return true;
              // Convert UTC datetime to local time for date comparison
              final inboxDateLocal = e.inboxDatetime.toLocal();
              return inboxDateLocal.isSameDay(_currentDate);
            }).toList(),
          ),
        ) ??
        []);

    final filteredInbox = _isSearch
        ? originalInboxes
        : originalInboxes
              .where((i) {
                switch (_inboxFilter) {
                  case InboxFilterType.all:
                    return !(i.config?.isDeleted ?? false);
                  case InboxFilterType.unread:
                    return unmodifiedUnreadInboxIds.contains(i.inboxId);
                  case InboxFilterType.chat:
                    return i.linkedMessage != null && !(i.config?.isDeleted ?? false);
                  case InboxFilterType.mail:
                    return i.linkedMail != null && !(i.config?.isDeleted ?? false);
                  case InboxFilterType.deleted:
                    return i.config?.isDeleted ?? false;
                }
              })
              .where((i) {
                if (i.linkedMail == null) return true;
                LinkedMailEntity mail = i.linkedMail!;
                MailInboxFilterType _mailInboxFilterType = mailInboxFilterTypes[mail.hostMail] ?? MailInboxFilterType.all;
                List<String> _mailInboxFilterLabelIds = List<String>.from(mailInboxFilterLabelIds[mail.hostMail] ?? []);

                switch (_mailInboxFilterType) {
                  case MailInboxFilterType.none:
                    return false;
                  case MailInboxFilterType.withSpecificLables:
                    return (mail.labelIds ?? []).toSet().intersection(_mailInboxFilterLabelIds.toSet()).toList().isNotEmpty;
                  case MailInboxFilterType.all:
                    return true;
                }
              })
              .where((i) {
                if (i.linkedMessage == null) return true;
                LinkedMessageEntity message = i.linkedMessage!;
                final oAuth = messengerOAuths.firstWhereOrNull((e) => e.teamId == message.teamId);
                if (oAuth == null) return true;
                ChatInboxFilterType _messageDmInboxFilterType = messageDmInboxFilterTypes['${oAuth.teamId}${oAuth.email}'] ?? ChatInboxFilterType.all;
                ChatInboxFilterType _messageChannelInboxFilterType = messageChannelInboxFilterTypes['${oAuth.teamId}${oAuth.email}'] ?? ChatInboxFilterType.mentions;

                if (message.isDm == true) {
                  switch (_messageDmInboxFilterType) {
                    case ChatInboxFilterType.none:
                      return false;
                    case ChatInboxFilterType.mentions:
                      return message.isUserTagged == true;
                    case ChatInboxFilterType.all:
                      return true;
                  }
                } else {
                  switch (_messageChannelInboxFilterType) {
                    case ChatInboxFilterType.none:
                      return false;
                    case ChatInboxFilterType.mentions:
                      return message.isUserTagged == true;
                    case ChatInboxFilterType.all:
                      return true;
                  }
                }
              })
              .toList();

    final separator = ref.read(inboxControllerProvider.select((v) => v?.separator ?? []));

    final timeOfDayInbox = groupBy(filteredInbox, (inbox) {
      if (_isSearch) return TimeSectionOfDay.night;

      TimeSectionOfDay? returnValue;
      TimeSectionOfDay.values.forEach((timeSection) {
        if (timeSection.startTime <= inbox.inboxDatetime.toLocal().hour && timeSection.endTime > inbox.inboxDatetime.toLocal().hour) {
          returnValue = timeSection;
        }
      });

      return returnValue!;
    });

    currentInboxes = timeOfDayInbox.map((key, value) {
      separator.sort((a, b) => b.compareTo(a));
      Map<DateTime, List<InboxEntity>> dateGroupedInbox = {};
      separator.forEach((date) {
        dateGroupedInbox[date] = value.where((e) => !e.inboxDatetime.isBefore(date)).toList();
        value.removeWhere((e) => !e.inboxDatetime.isBefore(date));
      });

      Map<DateTime, List<List<InboxEntity>>> inboxes = {};
      dateGroupedInbox.forEach((key, data) {
        List<List<InboxEntity>> result = [];
        final channelGroupedInbox = groupBy(data, (e) => _isSearch ? e.inboxId : e.inboxGroupId);

        final nonChannelInbox = channelGroupedInbox[null] ?? [];
        channelGroupedInbox.remove(null);
        nonChannelInbox.forEach((e) {
          channelGroupedInbox[_isSearch ? e.inboxId : e.inboxGroupId] = [e];
        });

        channelGroupedInbox.forEach((key, value) {
          value.sort((a, b) => b.inboxDatetime.compareTo(a.inboxDatetime));
          result.add(value);
        });

        result.sort((a, b) => b.last.inboxDatetime.compareTo(a.last.inboxDatetime));
        if (result.isNotEmpty) inboxes[key] = result;
      });

      return MapEntry(key, inboxes);
    });

    separator.sort((a, b) => b.compareTo(a));
    final messageMembers = ref.watch(chatChannelListControllerProvider.select((v) => v.values.expand((e) => e.members).toList()));
    final messageGroups = ref.watch(chatChannelListControllerProvider.select((v) => v.values.expand((e) => e.groups).toList()));
    final messageEmojis = ref.watch(chatChannelListControllerProvider.select((v) => v.values.expand((e) => e.emojis).toList()));

    final inboxes = currentInboxes.values.expand((e) => e.values.expand((e) => e)).expand((e) => e).toList();

    bool isIntegrationListEmpty = mailOAuths.isEmpty && messengerOAuths.isEmpty;

    final userDesktopInboxDragTutorialDone = ref.watch(authControllerProvider.select((v) => v.requireValue.desktopInboxDragTutorialDone));
    bool showDragTutorialOnDesktopOnDesktop = PlatformX.isDesktop && !userDesktopInboxDragTutorialDone && inboxes.isNotEmpty;

    if (_inboxFilter == InboxFilterType.unread) {
      unmodifiedUnreadInboxIds = currentInboxes.values.expand((e) => e.values.expand((e) => e)).expand((e) => e).map((e) => e.inboxId!).toList();
    }

    if (isIntegrationListEmpty) {
      return DesktopCard(
        backgroundColor: context.background,
        child: Center(
          child: VisirEmptyWidget(
            message: context.tr.no_integration_yet_for_inbox,
            buttonText: context.tr.integrate_new_accounts,
            buttonIcon: VisirIconType.integration,
            onButtonTap: () {
              Utils.showPopupDialog(
                child: PreferenceScreen(key: Utils.preferenceScreenKey, initialPreferenceScreenType: PreferenceScreenType.integration),
                size: PlatformX.isMobileView ? null : Size(640, 560),
              );
            },
          ),
        ),
      );
    }

    final _isSuccess = !ref.read(loadingStatusProvider.notifier).isError(TabType.home);
    final _isLoading = ref.read(loadingStatusProvider.notifier).isLoading(TabType.home);
    final _isSuggestionLoading = ref.read(loadingStatusProvider.select((v) => v[InboxSuggestionController.stringKey] == LoadingState.loading));

    return KeyboardShortcut(
      targetTab: widget.tabType,
      onKeyDown: _onKeyDown,
      onKeyRepeat: _onKeyRepeat,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return GestureDetector(
            onTap: closeDetails,
            child: Material(
              color: context.background,
              child: Column(
                children: [
                  InboxAppbar(
                    selectedItemIdsCount: selectedInboxIds.length,
                    onMultipleSelectClearButtonPressed: () {
                      selectedInboxIds.clear();
                      setState(() {});
                    },
                    onSidebarButtonPressed: widget.onSidebarButtonPressed,
                    onTodayButtonPressed: () => moveToDate(DateUtils.dateOnly(DateTime.now())),
                    onPrevButtonPressed: () => moveToDate(_currentDate.subtract(Duration(days: 1))),
                    onNextButtonPressed: () => moveToDate(_currentDate.add(Duration(days: 1))),
                    onRefreshButtonPressed: refresh,
                    focusNode: searchFocusNode,
                    selectedDateTime: _currentDate,
                    onDateButtonPressed: moveToDate,
                    showMobileUI: showMobileUI,
                    isSearch: _isSearch,
                    onSearchButtonPressed: onSearchButtonPressed,
                    unsearch: () async {
                      unsearch();
                    },
                    onSearchFieldSubmitted: (String text) async {
                      if (text.trim().isEmpty) {
                        searchFocusNode.requestFocus();
                        return;
                      }

                      ref.read(inboxControllerProvider.notifier).updateIsSearchDone(false);
                      await ref.read(inboxControllerProvider.notifier).search(query: text);
                      ref.read(inboxControllerProvider.notifier).updateIsSearchDone(true);

                      searchQuery = text;
                      if (!mounted) return;
                      searchFocusNode.requestFocus();
                      logAnalyticsEvent(eventName: 'inbox_search');

                      if (PlatformX.isMobile) {
                        FocusScope.of(context).unfocus();
                      }
                    },
                    tabType: widget.tabType,
                  ),
                  ValueListenableBuilder(
                    valueListenable: ref.read(inboxControllerProvider.notifier).isSearchDoneListenable,
                    builder: (context, isSearchDone, child) {
                      if (!_isLoading && inboxes.isEmpty && _inboxFilter != InboxFilterType.all) {
                        return VisirEmptyWidget(height: constraints.maxHeight - 60, width: constraints.maxWidth, message: context.tr.no_inbox_matched_with_filter);
                      }

                      final now = DateTime.now();

                      final timeSectionOrdered = [...TimeSectionOfDay.values]..sort((b, a) => a.startTime.compareTo(b.startTime));

                      final maxExistsTimeSection = (currentInboxes.keys.toList()..sort((a, b) => a.startTime.compareTo(b.startTime))).firstOrNull;
                      final remainingTimeSection = timeSectionOrdered.where((e) {
                        if (DateUtils.dateOnly(_currentDate).isAtSameMomentAs(DateUtils.dateOnly(now))) {
                          return e.startTime < (maxExistsTimeSection?.startTime ?? -1) && e.startTime < now.hour;
                        }
                        return e.startTime < (maxExistsTimeSection?.startTime ?? -1);
                      });

                      final buildTimeSection = (TimeSectionOfDay? section, int index) => _isSearch
                          ? SizedBox.shrink()
                          : VisirListSection(
                              removeTopMargin: index == 0,
                              titleBuilder: (height, style, subStyle, horizontalSpacing) {
                                return TextSpan(
                                  children: [
                                    TextSpan(text: section?.title ?? context.tr.ai_suggestion, style: style),
                                    if (section != null) WidgetSpan(child: SizedBox(width: horizontalSpacing)),
                                    if (section != null)
                                      TextSpan(
                                        text:
                                            '${DateFormat('h a').format(DateTime(now.year, now.month, now.day, section.startTime))} - ${DateFormat('h a').format(DateTime(now.year, now.month, now.day, section.endTime))}',
                                        style: subStyle,
                                      ),
                                  ],
                                );
                              },
                            );

                      bool isAbleToLoadMore = ref.read(inboxControllerProvider.notifier).isAbleToLoadMore();

                      suggestionInboxes =
                          _isSearch || _inboxFilter == InboxFilterType.deleted
                                ? []
                                : inboxes
                                      .where((e) {
                                        if (e.suggestion == null) return false;

                                        switch (inboxSuggestionFilterType) {
                                          case InboxSuggestionFilterType.urgent:
                                            return e.suggestion?.urgency == InboxSuggestionUrgency.urgent;
                                          case InboxSuggestionFilterType.important:
                                            return e.suggestion?.urgency == InboxSuggestionUrgency.urgent || e.suggestion?.urgency == InboxSuggestionUrgency.important;
                                          case InboxSuggestionFilterType.actionRequired:
                                            return e.suggestion?.urgency == InboxSuggestionUrgency.urgent ||
                                                e.suggestion?.urgency == InboxSuggestionUrgency.important ||
                                                e.suggestion?.urgency == InboxSuggestionUrgency.action_required;
                                          case InboxSuggestionFilterType.all:
                                            return e.suggestion?.urgency == InboxSuggestionUrgency.urgent ||
                                                e.suggestion?.urgency == InboxSuggestionUrgency.important ||
                                                e.suggestion?.urgency == InboxSuggestionUrgency.action_required ||
                                                e.suggestion?.urgency == InboxSuggestionUrgency.need_review;
                                          case InboxSuggestionFilterType.none:
                                            return false;
                                        }
                                      })
                                      .map((e) => e.copyWith(isSuggestion: true))
                                      .toList()
                            ..sort((a, b) {
                              final dateSort = (b.inboxDatetime).compareTo(a.inboxDatetime);
                              final dueSort = (a.suggestion!.target_date ?? DateTime(3000)).compareTo(b.suggestion!.target_date ?? DateTime(3000));
                              final importanceSort = a.suggestion!.urgency.priority.compareTo(b.suggestion!.urgency.priority);

                              switch (inboxSuggestionSortType) {
                                case InboxSuggestionSortType.date:
                                  return dateSort == 0
                                      ? importanceSort == 0
                                            ? dueSort
                                            : importanceSort
                                      : dateSort;
                                case InboxSuggestionSortType.due:
                                  return dueSort == 0
                                      ? dateSort == 0
                                            ? importanceSort
                                            : dateSort
                                      : dueSort;
                                case InboxSuggestionSortType.importance:
                                  return importanceSort == 0
                                      ? dateSort == 0
                                            ? dueSort
                                            : dateSort
                                      : importanceSort;
                              }
                            });

                      totalInboxes = [...suggestionInboxes, ...inboxes];

                      return Expanded(
                        child: ShowcaseWrapper(
                          tooltipPosition: TooltipPosition.top,
                          showcaseKey: inboxListDescriptionShowcaseKeyString,
                          child: Column(
                            children: [
                              if (showDragTutorialOnDesktopOnDesktop)
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  child: FeatureTutorialWidget(type: FeatureTutorialType.inboxDragAndDrop),
                                ),
                              Expanded(
                                child: MultiFingerGestureDetector(
                                  builder: (multiFingerGestureController) => Listener(
                                    onPointerDown: (event) {
                                      platformScrollController.addPointer();
                                    },
                                    onPointerUp: (event) {
                                      platformScrollController.removePointer();
                                    },
                                    onPointerCancel: (event) {
                                      platformScrollController.removePointer();
                                    },
                                    child: SmartRefresher(
                                      key: smartRefresherKey,
                                      controller: refreshController,
                                      enablePullDown: showMobileUI && !_isLoading,
                                      enablePullUp: isAbleToLoadMore,
                                      header: WaveRefreshHeader(),
                                      footer: WaveRefreshFooter(),
                                      onRefresh: () async {
                                        hideLoadingOnMobile();
                                        try {
                                          await refresh();
                                          refreshController.refreshCompleted();
                                        } catch (e) {
                                          refreshController.refreshFailed();
                                        }
                                        showLoadingOnMobile();
                                      },
                                      onLoading: () async {
                                        try {
                                          await ref.read(inboxControllerProvider.notifier).loadMore();
                                          refreshController.loadComplete();
                                        } catch (e) {
                                          refreshController.loadFailed();
                                        }
                                      },
                                      enableTwoLevel: false,
                                      physics: PlatformScrollPhysics(
                                        parent: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                                        controller: platformScrollController,
                                      ),
                                      child: SuperListView(
                                        listController: listController,
                                        controller: scrollController,
                                        addAutomaticKeepAlives: false,
                                        addRepaintBoundaries: true,
                                        padding: scrollViewBottomPadding,
                                        children: [
                                          AnimatedContainer(
                                            height: _isSuggestionLoading ? 42 : 0,
                                            width: double.maxFinite,
                                            duration: Duration(milliseconds: 300),
                                            child: _isSuggestionLoading
                                                ? Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Text('🤔', style: context.titleMedium?.textColor(context.onBackground)),
                                                      SizedBox(width: 6),
                                                      AnimatedTextKit(
                                                        animatedTexts: [
                                                          TypewriterAnimatedText(
                                                            context.tr.ai_thinking,
                                                            textStyle: context.titleMedium?.copyWith(color: context.onBackground),
                                                            speed: const Duration(milliseconds: 250),
                                                          ),
                                                        ],
                                                        repeatForever: true,
                                                        pause: const Duration(milliseconds: 250),
                                                        displayFullTextOnTap: true,
                                                      ),
                                                    ],
                                                  )
                                                : SizedBox.shrink(),
                                          ),
                                          ...(suggestionInboxes.mapIndexed((index, inbox) {
                                            final isSelected = selectedInbox != null && selectedInbox!.inboxId == inbox.inboxId;
                                            final timeSectionOfDay = currentInboxes.keys.firstWhereOrNull((timeSection) {
                                              final timeSectionGroup = currentInboxes[timeSection] ?? {};
                                              return timeSectionGroup.values.expand((e) => e).where((e) => e.contains(inbox)).isNotEmpty == true;
                                            });
                                            final separatedDate = currentInboxes[timeSectionOfDay]?.keys.firstWhereOrNull((date) {
                                              final dateGroup = currentInboxes[timeSectionOfDay]![date] ?? [];
                                              return dateGroup.where((e) => e.contains(inbox)).isNotEmpty == true;
                                            });
                                            final inboxGroup = currentInboxes[timeSectionOfDay]?[separatedDate]?.firstWhereOrNull((list) {
                                              return list.contains(inbox);
                                            });

                                            final feedbackWidget = Material(
                                              color: Colors.transparent,
                                              child: Opacity(
                                                opacity: 0.5,
                                                child: Container(
                                                  constraints: BoxConstraints(maxWidth: 180),
                                                  decoration: BoxDecoration(color: context.surface, borderRadius: BorderRadius.circular(6)),
                                                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                                  child: Text(inbox.suggestion?.summary ?? inbox.shortTitle, style: context.bodyLarge?.textColor(context.onBackground)),
                                                ),
                                              ),
                                            );

                                            final inboxWidget = InboxItem(
                                              key: ValueKey(selectedInbox == null ? null : '${selectedInbox!.inboxId}${selectedInboxSelctedCount.toString()}'),
                                              tabType: widget.tabType,
                                              inbox: inbox,
                                              inboxGroup: inboxGroup,
                                              isFirst: true,
                                              channels: channels,
                                              members: messageMembers,
                                              groups: messageGroups,
                                              emojis: messageEmojis,
                                              isSelected: isSelected,
                                              isSearch: _isSearch,
                                              isSuggestion: true,
                                              searchQuery: searchQuery,
                                              isShowcase: index == 0,
                                              onRemoveCreateShadow: widget.onRemoveCreateShadow,
                                              onSaved: widget.onSaved,
                                              onTitleChanged: widget.onTitleChanged,
                                              onColorChanged: widget.onColorChanged,
                                              onTimeChanged: widget.onTimeChanged,
                                              updateIsTask: widget.updateIsTask,
                                              onShowCreateShadow: widget.onShowCreateShadow,
                                              onLongPress: showMobileUI && selectedInboxIds.isNotEmpty
                                                  ? () => showInboxOptionsBottomDialog(
                                                      context: context,
                                                      user: ref.read(authControllerProvider).requireValue,
                                                      inbox: inbox,
                                                      channels: channels,
                                                    )
                                                  : null,
                                              multiFingerGestureController: multiFingerGestureController,
                                              onTapDown: selectedInboxIds.contains(inbox.inboxIdWithCheckSuggestion)
                                                  ? (details) => multiFingerGestureController.notifyTapDownFromWidgetListeners(selectedInboxIds)
                                                  : null,
                                              onTapUp: selectedInboxIds.contains(inbox.inboxIdWithCheckSuggestion)
                                                  ? (details) => multiFingerGestureController.notifyTapUpFromWidgetListeners(selectedInboxIds)
                                                  : null,
                                              onTapCancel: selectedInboxIds.contains(inbox.inboxIdWithCheckSuggestion)
                                                  ? () => multiFingerGestureController.notifyTapUpFromWidgetListeners(selectedInboxIds)
                                                  : null,
                                              onTwoFingerDragSelect: () {
                                                selectInboxes(totalInboxes: totalInboxes, targetInbox: inbox, containsMidInboxes: true);
                                              },
                                              onTwoFingerDragDisselect: () {
                                                selectInboxes(totalInboxes: totalInboxes, targetInbox: inbox, forceRemove: true);
                                              },
                                              onTap: () {
                                                if (inbox.inboxIdWithCheckSuggestion != null) {
                                                  if (HardwareKeyboard.instance.isShiftPressed) {
                                                    selectInboxes(totalInboxes: totalInboxes, targetInbox: inbox, containsMidInboxes: true);
                                                    return;
                                                  }

                                                  if (PlatformX.isApple ? HardwareKeyboard.instance.isMetaPressed : HardwareKeyboard.instance.isControlPressed) {
                                                    selectInboxes(totalInboxes: totalInboxes, targetInbox: inbox);
                                                    return;
                                                  }
                                                }

                                                if (isSelected && ref.read(resizableClosableWidgetProvider(widget.tabType)) != null) {
                                                  closeDetails();
                                                } else {
                                                  selectedInbox = inbox;
                                                  selectedInboxSelctedCount += 1;
                                                  setState(() {});
                                                  final date = ref.read(inboxListDateProvider);
                                                  final isSignedIn = ref.read(authControllerProvider.select((v) => v.requireValue.isSignedIn));
                                                  ref
                                                      .read(inboxConfigListControllerProvider(isSearch: false, year: date.year, month: date.month, day: date.day, isSignedIn: isSignedIn).notifier)
                                                      .updateInboxConfig(configs: [inbox.config!.copyWith(isRead: true, inboxUniqueId: inbox.id)]);
                                                  openInbox();
                                                }
                                              },
                                            );

                                            final swipeDeleteAction = SwipeAction(
                                              performsFirstActionWithFullSwipe: true,
                                              icon: Container(
                                                width: 24,
                                                height: 24,
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(6), color: context.error),
                                                child: VisirIcon(type: VisirIconType.trash, size: 16, color: context.onError, isSelected: true),
                                              ),
                                              widthSpace: 100,
                                              onTap: (CompletionHandler handler) async {
                                                HapticFeedback.lightImpact();
                                                await handler(true);

                                                final date = ref.read(inboxListDateProvider);
                                                final isSignedIn = ref.read(authControllerProvider.select((v) => v.requireValue.isSignedIn));
                                                ref
                                                    .read(inboxConfigListControllerProvider(isSearch: false, year: date.year, month: date.month, day: date.day, isSignedIn: isSignedIn).notifier)
                                                    .updateInboxConfig(
                                                      configs: [
                                                        ...[inbox].map((e) => e.config!.copyWith(isDeleted: !(e.config?.isDeleted ?? false), inboxUniqueId: e.uniqueId)),
                                                      ],
                                                    );

                                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                                  final originalInboxes = ref.read(inboxControllerProvider.notifier).availableInboxes;
                                                  final showDeleted = originalInboxes.where((e) => e.config?.isDeleted ?? false).isEmpty == true;
                                                  if (_inboxFilter == InboxFilterType.deleted && showDeleted) {
                                                    setInboxFilter(InboxFilterType.all);
                                                  }
                                                });
                                              },
                                              color: Colors.transparent,
                                            );

                                            if (showMobileUI) {
                                              return Column(
                                                children: [
                                                  if (index == 0) buildTimeSection(null, 0),
                                                  SwipeActionCell(
                                                    isDraggable: showMobileUI,
                                                    key: ObjectKey(inbox.id),
                                                    trailingActions: [swipeDeleteAction],
                                                    child: InboxLongPressDraggable(
                                                      scaleFactor: ratio,
                                                      dragAnchorStrategy: (InboxDraggable<Object> d, BuildContext context, Offset point) {
                                                        return Offset(d.feedbackOffset.dx, d.feedbackOffset.dy);
                                                      },
                                                      onDragStarted: () {
                                                        widget.onDragStart?.call(inbox);
                                                      },
                                                      onDragUpdate: (details) {
                                                        widget.onDragUpdate?.call(inbox, details.globalPosition / ratio);
                                                        lastPosition = details.globalPosition;
                                                      },
                                                      onDragEnd: (details) {
                                                        widget.onDragEnd?.call(inbox, lastPosition / ratio);
                                                      },
                                                      hitTestBehavior: HitTestBehavior.opaque,
                                                      feedback: feedbackWidget,
                                                      child: inboxWidget,
                                                    ),
                                                  ),
                                                ],
                                              );
                                            } else {
                                              return Column(
                                                children: [
                                                  if (index == 0) buildTimeSection(null, 0),
                                                  InboxDraggable(
                                                    scaleFactor: ratio,
                                                    dragAnchorStrategy: (InboxDraggable<Object> d, BuildContext context, Offset point) {
                                                      return Offset(d.feedbackOffset.dx, d.feedbackOffset.dy);
                                                    },
                                                    onDragUpdate: (details) {
                                                      widget.onDragUpdate?.call(inbox, details.globalPosition / ratio);
                                                      lastPosition = details.globalPosition;
                                                    },
                                                    onDragEnd: (details) {
                                                      widget.onDragEnd?.call(inbox, lastPosition / ratio);
                                                    },
                                                    hitTestBehavior: HitTestBehavior.opaque,
                                                    feedback: feedbackWidget,
                                                    child: ContextMenuWidget(
                                                      menuProvider: (request) {
                                                        if (!selectedInboxIds.contains(inbox.inboxIdWithCheckSuggestion!)) {
                                                          selectInboxes(totalInboxes: totalInboxes, targetInbox: inbox);
                                                        }

                                                        List<InboxEntity> targetInboxes = totalInboxes
                                                            .where((e) => selectedInboxIds.contains(e.inboxIdWithCheckSuggestion))
                                                            .toList();

                                                        return Menu(
                                                          children: [
                                                            ...InboxRightClickOptionType.values
                                                                .map((e) {
                                                                  return [
                                                                    MenuAction(
                                                                      title: e.getName(context, targetInboxes, channels),
                                                                      image: MenuImage.icon(e.getMenuIcon(targetInboxes, channels)),
                                                                      attributes: MenuActionAttributes(destructive: e.getColor(context, targetInboxes, channels) == context.error),
                                                                      callback: () {
                                                                        if (selectedInboxIds.isEmpty) return;
                                                                        if (!selectedInboxIds.contains(inbox.inboxIdWithCheckSuggestion!)) {
                                                                          selectInboxes(totalInboxes: totalInboxes, targetInbox: inbox);
                                                                        }

                                                                        switch (e) {
                                                                          case InboxRightClickOptionType.read:
                                                                            final isRead = targetInboxes.where((e) => e.getIsUnread(channels)).isNotEmpty;
                                                                            setInboxConfigOnSelectedInboxes(targetInboxes: targetInboxes, isRead: isRead);
                                                                            break;
                                                                          case InboxRightClickOptionType.delete:
                                                                            final isDeleted = targetInboxes.where((e) => e.config?.isDeleted != true).isNotEmpty;
                                                                            setInboxConfigOnSelectedInboxes(targetInboxes: targetInboxes, isDeleted: isDeleted);
                                                                            break;
                                                                        }
                                                                      },
                                                                    ),
                                                                  ];
                                                                })
                                                                .toList()
                                                                .expand((e) => e),
                                                          ],
                                                        );
                                                      },
                                                      child: inboxWidget,
                                                    ),
                                                  ),
                                                ],
                                              );
                                            }
                                          })),
                                          if (inboxes.isEmpty)
                                            ...(TimeSectionOfDay.values.reversed).map((e) {
                                              if (e.startTime > DateTime.now().hour && _currentDate.isAtSameDayAs(DateTime.now())) return SizedBox.shrink();
                                              return buildTimeSection(e, suggestionInboxes.isEmpty ? 0 : 1);
                                            }).toList(),
                                          ...(inboxes
                                                  .mapIndexed((index, element) {
                                                    if (index == inboxes.length) {
                                                      bool showPlaceHolder = !onMoveToDate && _isSuccess;
                                                      if (inboxes.isEmpty && showPlaceHolder && (_isSearch ? (searchQuery ?? '').isNotEmpty && isSearchDone : true)) {
                                                        return [
                                                          Padding(
                                                            padding: const EdgeInsets.all(16),
                                                            child: Container(
                                                              decoration: ShapeDecoration(
                                                                color: context.surface,
                                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                              ),
                                                              padding: EdgeInsets.all(12),
                                                              child: Text(
                                                                _isSearch
                                                                    ? context.tr.inbox_no_search_results
                                                                    : isToday
                                                                    ? context.tr.inbox_you_are_all_set
                                                                    : context.tr.inbox_no_issues_for_this_day,
                                                                style: context.bodyMedium?.textColor(context.inverseSurface),
                                                                textAlign: TextAlign.center,
                                                              ),
                                                            ),
                                                          ),
                                                        ];
                                                      }
                                                      if (!isAbleToLoadMore) return [];

                                                      return [
                                                        Container(
                                                          padding: EdgeInsets.only(top: 24, bottom: 24),
                                                          child: Row(
                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                            children: [
                                                              if (isAbleToLoadMore) SizedBox(width: 8),
                                                              Text(
                                                                context.tr.message_loaded_until(
                                                                  DateFormat(
                                                                    separator.last.year == DateTime.now().year ? 'MMM d HH:mm a' : 'yyyy MMM d HH:mm a',
                                                                  ).format(separator.last),
                                                                ),
                                                                style: context.bodyMedium?.textColor(context.onBackground),
                                                              ),
                                                              if (isLoadingMore && isAbleToLoadMore)
                                                                Padding(
                                                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                                                  child: CustomCircularLoadingIndicator(size: 8, color: context.primary),
                                                                ),
                                                              if (!isLoadingMore && isAbleToLoadMore)
                                                                VisirButton(
                                                                  type: VisirButtonAnimationType.scaleAndOpacity,
                                                                  style: VisirButtonStyle(padding: const EdgeInsets.symmetric(horizontal: 8)),
                                                                  child: Text(context.tr.message_load_more, style: context.bodyMedium?.textColor(context.secondary)),
                                                                  onTap: () async {
                                                                    isLoadingMore = true;
                                                                    setState(() {});
                                                                    await ref.read(inboxControllerProvider.notifier).loadMore();
                                                                    isLoadingMore = false;
                                                                    setState(() {});
                                                                  },
                                                                ),
                                                            ],
                                                          ),
                                                        ),
                                                      ];
                                                    }

                                                    final inbox = inboxes[index];
                                                    final timeSectionOfDay = currentInboxes.keys.firstWhereOrNull((timeSection) {
                                                      final timeSectionGroup = currentInboxes[timeSection] ?? {};
                                                      return timeSectionGroup.values.expand((e) => e).where((e) => e.contains(inbox)).isNotEmpty == true;
                                                    });

                                                    final separatedDate = currentInboxes[timeSectionOfDay]?.keys.firstWhereOrNull((date) {
                                                      final dateGroup = currentInboxes[timeSectionOfDay]![date] ?? [];
                                                      return dateGroup.where((e) => e.contains(inbox)).isNotEmpty == true;
                                                    });
                                                    final inboxGroup = currentInboxes[timeSectionOfDay]?[separatedDate]?.firstWhereOrNull((list) {
                                                      return list.contains(inbox);
                                                    });
                                                    final inboxDateGroupData = currentInboxes[timeSectionOfDay]?.map(
                                                      (key, value) => MapEntry(key, value.expand((e) => e).toList()),
                                                    );

                                                    final isFirstInSection = inboxDateGroupData?.values.expand((e) => e).toList().firstOrNull == inbox;

                                                    final isFirst = inboxGroup?.first == inbox;

                                                    String _searchQuery = (searchQuery ?? '').toLowerCase();
                                                    String titleString = inbox.title.toLowerCase();
                                                    String descriptionString = (inbox.description ?? '').toLowerCase();
                                                    String inboxGroupString =
                                                        (inboxGroup?.length == 1
                                                                ? (inbox.providers.isNotEmpty ? inbox.providers.first.name : '')
                                                                : inboxGroup?.firstOrNull?.linkedMessage?.channelName ?? (inbox.providers.isNotEmpty ? inbox.providers.first.name : ''))
                                                            .toLowerCase();
                                                    bool isSearchMatched = _isSearch
                                                        ? _searchQuery.isEmpty
                                                              ? true
                                                              : titleString.contains(_searchQuery) ||
                                                                    inboxGroupString.contains(_searchQuery) ||
                                                                    descriptionString.contains(_searchQuery)
                                                        : true;

                                                    final isSelected = selectedInbox != null && selectedInbox!.inboxId == inbox.inboxId;
                                                    final inboxWidget = InboxItem(
                                                      key: ValueKey(selectedInbox == null ? null : '${selectedInbox!.inboxId}${selectedInboxSelctedCount.toString()}'),
                                                      tabType: widget.tabType,
                                                      inbox: inbox,
                                                      inboxGroup: inboxGroup,
                                                      isFirst: isFirst,
                                                      channels: channels,
                                                      members: messageMembers,
                                                      groups: messageGroups,
                                                      emojis: messageEmojis,
                                                      isSelected: isSelected,
                                                      isSearch: _isSearch,
                                                      isSuggestion: false,
                                                      searchQuery: searchQuery,
                                                      isShowcase: index == 0 && suggestionInboxes.isEmpty,
                                                      onRemoveCreateShadow: widget.onRemoveCreateShadow,
                                                      onSaved: widget.onSaved,
                                                      onTitleChanged: widget.onTitleChanged,
                                                      onColorChanged: widget.onColorChanged,
                                                      onTimeChanged: widget.onTimeChanged,
                                                      updateIsTask: widget.updateIsTask,
                                                      onShowCreateShadow: widget.onShowCreateShadow,
                                                      onLongPress: showMobileUI && selectedInboxIds.isNotEmpty
                                                          ? () => showInboxOptionsBottomDialog(
                                                              context: context,
                                                              user: ref.read(authControllerProvider).requireValue,
                                                              inbox: inbox,
                                                              channels: channels,
                                                            )
                                                          : null,
                                                      multiFingerGestureController: multiFingerGestureController,
                                                      onTapDown: selectedInboxIds.contains(inbox.inboxIdWithCheckSuggestion)
                                                          ? (details) => multiFingerGestureController.notifyTapDownFromWidgetListeners(selectedInboxIds)
                                                          : null,
                                                      onTapUp: selectedInboxIds.contains(inbox.inboxIdWithCheckSuggestion)
                                                          ? (details) => multiFingerGestureController.notifyTapUpFromWidgetListeners(selectedInboxIds)
                                                          : null,
                                                      onTapCancel: selectedInboxIds.contains(inbox.inboxIdWithCheckSuggestion)
                                                          ? () => multiFingerGestureController.notifyTapUpFromWidgetListeners(selectedInboxIds)
                                                          : null,
                                                      onTwoFingerDragSelect: () {
                                                        selectInboxes(totalInboxes: totalInboxes, targetInbox: inbox, containsMidInboxes: true);
                                                      },
                                                      onTwoFingerDragDisselect: () {
                                                        selectInboxes(totalInboxes: totalInboxes, targetInbox: inbox, forceRemove: true);
                                                      },
                                                      onTap: () {
                                                        if (inbox.inboxIdWithCheckSuggestion != null) {
                                                          if (HardwareKeyboard.instance.isShiftPressed) {
                                                            selectInboxes(totalInboxes: totalInboxes, targetInbox: inbox, containsMidInboxes: true);
                                                            return;
                                                          }

                                                          if (PlatformX.isApple ? HardwareKeyboard.instance.isMetaPressed : HardwareKeyboard.instance.isControlPressed) {
                                                            selectInboxes(totalInboxes: totalInboxes, targetInbox: inbox);
                                                            return;
                                                          }
                                                        }

                                                        if (isSelected && ref.read(resizableClosableWidgetProvider(widget.tabType)) != null) {
                                                          closeDetails();
                                                        } else {
                                                          selectedInbox = inbox;
                                                          selectedInboxSelctedCount += 1;
                                                          setState(() {});
                                                          final date = ref.read(inboxListDateProvider);
                                                          final isSignedIn = ref.read(authControllerProvider.select((v) => v.requireValue.isSignedIn));
                                                          ref
                                                              .read(inboxConfigListControllerProvider(isSearch: false, year: date.year, month: date.month, day: date.day, isSignedIn: isSignedIn).notifier)
                                                              .updateInboxConfig(configs: [inbox.config!.copyWith(isRead: true, inboxUniqueId: inbox.id)]);
                                                          openInbox();
                                                        }
                                                      },
                                                    );

                                                    final feedbackWidget = Material(
                                                      color: Colors.transparent,
                                                      child: Opacity(
                                                        opacity: 0.5,
                                                        child: Container(
                                                          constraints: BoxConstraints(maxWidth: 180),
                                                          decoration: BoxDecoration(color: context.surface, borderRadius: BorderRadius.circular(6)),
                                                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                                          child: Text(inbox.shortTitle, style: context.bodyLarge?.textColor(context.onBackground)),
                                                        ),
                                                      ),
                                                    );

                                                    final swipeDeleteAction = SwipeAction(
                                                      performsFirstActionWithFullSwipe: true,
                                                      icon: Container(
                                                        width: 24,
                                                        height: 24,
                                                        alignment: Alignment.center,
                                                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(6), color: context.error),
                                                        child: VisirIcon(type: VisirIconType.trash, size: 16, color: context.onError, isSelected: true),
                                                      ),
                                                      widthSpace: 100,
                                                      onTap: (CompletionHandler handler) async {
                                                        HapticFeedback.lightImpact();
                                                        await handler(true);

                                                        final date = ref.read(inboxListDateProvider);
                                                        final isSignedIn = ref.read(authControllerProvider.select((v) => v.requireValue.isSignedIn));
                                                        ref
                                                            .read(inboxConfigListControllerProvider(isSearch: false, year: date.year, month: date.month, day: date.day, isSignedIn: isSignedIn).notifier)
                                                            .updateInboxConfig(
                                                              configs: [
                                                                ...[inbox].map((e) => e.config!.copyWith(isDeleted: !(e.config?.isDeleted ?? false), inboxUniqueId: e.uniqueId)),
                                                              ],
                                                            );

                                                        WidgetsBinding.instance.addPostFrameCallback((_) {
                                                          final originalInboxes = ref.read(inboxControllerProvider.notifier).availableInboxes;
                                                          final showDeleted = originalInboxes.where((e) => e.config?.isDeleted ?? false).isEmpty == true;
                                                          if (_inboxFilter == InboxFilterType.deleted && showDeleted) {
                                                            setInboxFilter(InboxFilterType.all);
                                                          }
                                                        });
                                                      },
                                                      color: Colors.transparent,
                                                    );

                                                    final remainingTimeSection = timeSectionOfDay == null
                                                        ? List<TimeSectionOfDay>.from([])
                                                        : timeSectionOrdered.where((e) {
                                                            final orderedCurrentInboxesKeys = (currentInboxes.keys.toList()..sort((b, a) => a.startTime.compareTo(b.startTime)));
                                                            final currentKeyIndex = orderedCurrentInboxesKeys.indexOf(timeSectionOfDay);
                                                            final nextSection = orderedCurrentInboxesKeys[min(max(0, currentKeyIndex - 1), orderedCurrentInboxesKeys.length - 1)];

                                                            if (e == timeSectionOfDay) return true;
                                                            return e.startTime > timeSectionOfDay.startTime &&
                                                                !currentInboxes.keys.contains(e) &&
                                                                nextSection.startTime > e.startTime;
                                                          });

                                                    final sectionWidget = timeSectionOfDay != null && isFirstInSection == true
                                                        ? remainingTimeSection
                                                              .map(
                                                                (e) => buildTimeSection(e, index + remainingTimeSection.toList().indexOf(e) + (suggestionInboxes.isEmpty ? 0 : 1)),
                                                              )
                                                              .toList()
                                                        : [];

                                                    if (showMobileUI) {
                                                      return isSearchMatched
                                                          ? [
                                                              ...sectionWidget,
                                                              Column(
                                                                children: [
                                                                  SwipeActionCell(
                                                                    isDraggable: showMobileUI,
                                                                    key: ObjectKey(inbox.id),
                                                                    leadingActions: [swipeDeleteAction],
                                                                    trailingActions: [swipeDeleteAction],
                                                                    child: InboxLongPressDraggable(
                                                                      scaleFactor: ratio,
                                                                      dragAnchorStrategy: (InboxDraggable<Object> d, BuildContext context, Offset point) {
                                                                        return Offset(d.feedbackOffset.dx, d.feedbackOffset.dy);
                                                                      },
                                                                      onDragStarted: () {
                                                                        widget.onDragStart?.call(inbox);
                                                                      },
                                                                      onDragUpdate: (details) {
                                                                        widget.onDragUpdate?.call(inbox, details.globalPosition / ratio);
                                                                        lastPosition = details.globalPosition;
                                                                      },
                                                                      onDragEnd: (details) {
                                                                        widget.onDragEnd?.call(inbox, lastPosition / ratio);
                                                                      },
                                                                      hitTestBehavior: HitTestBehavior.opaque,
                                                                      feedback: feedbackWidget,
                                                                      child: inboxWidget,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ]
                                                          : List<Widget>.from([]);
                                                    }

                                                    return isSearchMatched
                                                        ? [
                                                            ...sectionWidget,
                                                            Column(
                                                              children: [
                                                                InboxDraggable(
                                                                  scaleFactor: ratio,
                                                                  dragAnchorStrategy: (InboxDraggable<Object> d, BuildContext context, Offset point) {
                                                                    return Offset(d.feedbackOffset.dx, d.feedbackOffset.dy);
                                                                  },
                                                                  onDragUpdate: (details) {
                                                                    widget.onDragUpdate?.call(inbox, details.globalPosition / ratio);
                                                                    lastPosition = details.globalPosition;
                                                                  },
                                                                  onDragEnd: (details) {
                                                                    widget.onDragEnd?.call(inbox, lastPosition / ratio);
                                                                  },
                                                                  hitTestBehavior: HitTestBehavior.opaque,
                                                                  feedback: feedbackWidget,
                                                                  child: ContextMenuWidget(
                                                                    menuProvider: (request) {
                                                                      if (!selectedInboxIds.contains(inbox.inboxIdWithCheckSuggestion!)) {
                                                                        selectInboxes(totalInboxes: totalInboxes, targetInbox: inbox);
                                                                      }

                                                                      List<InboxEntity> targetInboxes = totalInboxes
                                                                          .where((e) => selectedInboxIds.contains(e.inboxIdWithCheckSuggestion))
                                                                          .toList();

                                                                      return Menu(
                                                                        children: [
                                                                          ...InboxRightClickOptionType.values
                                                                              .map((e) {
                                                                                return [
                                                                                  MenuAction(
                                                                                    title: e.getName(context, targetInboxes, channels),
                                                                                    image: MenuImage.icon(e.getMenuIcon(targetInboxes, channels)),
                                                                                    attributes: MenuActionAttributes(
                                                                                      destructive: e.getColor(context, targetInboxes, channels) == context.error,
                                                                                    ),
                                                                                    callback: () {
                                                                                      if (selectedInboxIds.isEmpty) return;
                                                                                      if (!selectedInboxIds.contains(inbox.inboxIdWithCheckSuggestion!)) {
                                                                                        selectInboxes(totalInboxes: totalInboxes, targetInbox: inbox);
                                                                                      }

                                                                                      switch (e) {
                                                                                        case InboxRightClickOptionType.read:
                                                                                          final isRead = targetInboxes.where((e) => e.getIsUnread(channels)).isNotEmpty;
                                                                                          setInboxConfigOnSelectedInboxes(targetInboxes: targetInboxes, isRead: isRead);
                                                                                          break;
                                                                                        case InboxRightClickOptionType.delete:
                                                                                          final isDeleted = targetInboxes.where((e) => e.config?.isDeleted != true).isNotEmpty;
                                                                                          setInboxConfigOnSelectedInboxes(targetInboxes: targetInboxes, isDeleted: isDeleted);
                                                                                          break;
                                                                                      }
                                                                                    },
                                                                                  ),
                                                                                ];
                                                                              })
                                                                              .toList()
                                                                              .expand((e) => e),
                                                                        ],
                                                                      );
                                                                    },
                                                                    child: inboxWidget,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ]
                                                        : List<Widget>.from([]);
                                                  })
                                                  .expand((e) => e))
                                              .whereType<Widget>(),
                                          if (inboxes.isNotEmpty)
                                            ...remainingTimeSection.mapIndexed((index, e) => buildTimeSection(e, inboxes.length + timeSectionOrdered.indexOf(e) + 1)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
