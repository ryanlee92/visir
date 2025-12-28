import 'package:Visir/config/providers.dart';
import 'package:Visir/dependency/contextmenu/contextmenu.dart';
import 'package:Visir/dependency/omni_datetime_picker/omni_datetime_picker.dart';
import 'package:Visir/dependency/omni_datetime_picker/src/omni_datetime_picker.dart';
import 'package:Visir/features/common/presentation/utils/extensions/platform_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/widgets/popup_menu.dart';
import 'package:Visir/features/common/presentation/widgets/visir_app_bar.dart';
import 'package:Visir/features/common/presentation/widgets/visir_button.dart';
import 'package:Visir/features/common/presentation/widgets/visir_icon.dart';
import 'package:Visir/features/common/presentation/widgets/visir_search_bar.dart';
import 'package:Visir/features/common/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class InboxAppbar extends ConsumerStatefulWidget {
  final DateTime selectedDateTime;
  final void Function(DateTime dateTime) onDateButtonPressed;

  final void Function() onTodayButtonPressed;

  final void Function() onPrevButtonPressed;
  final void Function() onNextButtonPressed;

  final void Function() onRefreshButtonPressed;
  final bool showMobileUI;

  final bool isSearch;
  final int selectedItemIdsCount;
  final void Function() onSearchButtonPressed;
  final void Function() unsearch;
  final void Function() onMultipleSelectClearButtonPressed;
  final Future<void> Function(String text) onSearchFieldSubmitted;
  final void Function() onSidebarButtonPressed;

  final FocusNode focusNode;
  final TabType tabType;

  const InboxAppbar({
    super.key,
    required this.tabType,
    required this.focusNode,
    required this.onTodayButtonPressed,
    required this.onPrevButtonPressed,
    required this.onNextButtonPressed,
    required this.onRefreshButtonPressed,
    required this.selectedDateTime,
    required this.onDateButtonPressed,
    required this.showMobileUI,
    required this.isSearch,
    required this.onSearchButtonPressed,
    required this.unsearch,
    required this.onSearchFieldSubmitted,
    required this.selectedItemIdsCount,
    required this.onMultipleSelectClearButtonPressed,
    required this.onSidebarButtonPressed,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _InboxAppbarState();
}

class _InboxAppbarState extends ConsumerState<InboxAppbar> {
  bool get showMobileUI => widget.showMobileUI;

  bool isHoveringCalendarButton = false;

  final DateFormat _monthDayFormat = DateFormat.MMMd();
  // final DateFormat _dayFormat = DateFormat.E();

  @override
  Widget build(BuildContext context) {
    bool showMultipleSelectClearButton = widget.selectedItemIdsCount > 0;

    final resizableClosableDrawer = ref.watch(resizableClosableDrawerProvider(widget.tabType));
    return PreferredSize(
      preferredSize: Size.fromHeight(VisirAppBar.height),
      child: Container(
        height: VisirAppBar.height,
        child: widget.isSearch
            ? VisirSearchBar(
                initialValue: '',
                hintText: context.tr.mail_search_placeholder,
                onClose: widget.unsearch,
                focusNode: widget.focusNode,
                onSubmitted: widget.onSearchFieldSubmitted,
              )
            : Row(
                children: [
                  SizedBox(width: 6),
                  if (resizableClosableDrawer == null)
                    VisirAppBarButton(icon: VisirIconType.control, onTap: widget.onSidebarButtonPressed).getButton(context: context),
                  VisirAppBarButton(
                    icon: VisirIconType.search,
                    onTap: widget.onSearchButtonPressed,
                    options: VisirButtonOptions(
                      tabType: TabType.home,
                      shortcuts: [
                        VisirButtonKeyboardShortcut(
                          message: context.tr.search_inbox,
                          keys: [LogicalKeyboardKey.keyF, if (PlatformX.isApple) LogicalKeyboardKey.meta, if (!PlatformX.isApple) LogicalKeyboardKey.control],
                        ),
                      ],
                    ),
                  ).getButton(context: context),
                  VisirAppBarButton(isDivider: true).getButton(context: context),
                  PopupMenu(
                    width: 296,
                    height: 300,
                    forcePopup: true,
                    location: PopupMenuLocation.bottom,
                    type: ContextMenuActionType.tap,
                    popup: OmniDateTimePicker(
                      type: OmniDateTimePickerType.date,
                      initialDate: widget.selectedDateTime,
                      onDateChanged: (dateTime) {
                        widget.onDateButtonPressed(dateTime);
                      },
                    ),
                    style: VisirButtonStyle(borderRadius: BorderRadius.circular(6), height: 32, padding: EdgeInsets.symmetric(horizontal: 4)),
                    child: Row(
                      children: [
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: DateUtils.isSameDay(widget.selectedDateTime, DateTime.now())
                                    ? context.tr.today
                                    : DateUtils.isSameDay(widget.selectedDateTime, DateTime.now().subtract(Duration(days: 1)))
                                    ? context.tr.yesterday_short
                                    : DateUtils.isSameDay(widget.selectedDateTime, DateTime.now().add(Duration(days: 1)))
                                    ? context.tr.tomorrow
                                    : _monthDayFormat.format(widget.selectedDateTime),
                                style: context.titleLarge?.textColor(context.outlineVariant).appFont(context).textBold,
                              ),
                              // WidgetSpan(child: SizedBox(width: 6)),
                              // TextSpan(
                              //   text: _dayFormat.format(widget.selectedDateTime).toUpperCase(),
                              //   style: (context.labelMedium)?.textColor(context.inverseSurface).appFont(context),
                              // ),
                            ],
                          ),
                        ),
                        SizedBox(width: 6),
                        VisirIcon(type: VisirIconType.arrowDown, size: 16, color: context.inverseSurface),
                      ],
                    ),
                  ),
                  VisirAppBarButton(isDivider: true).getButton(context: context),

                  if (!showMultipleSelectClearButton)
                    Row(
                      children: [
                        VisirAppBarButton(
                          icon: VisirIconType.calendarBefore,
                          onTap: widget.onPrevButtonPressed,
                          options: VisirButtonOptions(message: context.tr.tooltip_prev_day),
                        ).getButton(context: context),
                        VisirAppBarButton(
                          icon: VisirIconType.today,
                          onTap: widget.onTodayButtonPressed,
                          options: VisirButtonOptions(message: context.tr.today),
                        ).getButton(context: context),
                        VisirAppBarButton(
                          icon: VisirIconType.calendarAfter,
                          onTap: widget.onNextButtonPressed,
                          foregroundColor: widget.selectedDateTime.isBefore(DateUtils.dateOnly(DateTime.now())) ? null : VisirIcon.disabledColor(context),
                          options: VisirButtonOptions(message: context.tr.tooltip_next_day),
                        ).getButton(context: context),
                      ],
                    ),
                  SizedBox(width: 6),
                  Expanded(child: SizedBox.shrink()),
                  if (showMultipleSelectClearButton)
                    VisirButton(
                      type: VisirButtonAnimationType.scaleAndOpacity,
                      style: VisirButtonStyle(
                        cursor: SystemMouseCursors.click,
                        height: 32,
                        backgroundColor: context.primary,
                        borderRadius: BorderRadius.circular(6),
                        padding: EdgeInsets.symmetric(horizontal: 8),
                      ),
                      onTap: widget.onMultipleSelectClearButtonPressed,
                      child: Row(
                        children: [
                          Text(context.tr.n_selected(widget.selectedItemIdsCount), style: context.labelLarge?.textColor(context.onPrimary).appFont(context)),
                          SizedBox(width: 6),
                          VisirIcon(type: VisirIconType.closeWithCircle, color: context.onPrimary, size: 16, isSelected: true),
                        ],
                      ),
                    ),
                  SizedBox(width: 12),
                ],
              ),
      ),
    );
  }
}
