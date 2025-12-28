import 'package:Visir/config/providers.dart';
import 'package:Visir/dependency/contextmenu/src/ContextMenuArea.dart';
import 'package:Visir/dependency/master_detail_flow/src/details_item.dart';
import 'package:Visir/dependency/modal_bottom_sheet/src/utils/modal_scroll_controller.dart';
import 'package:Visir/features/auth/application/auth_controller.dart';
import 'package:Visir/features/auth/domain/entities/user_entity.dart';
import 'package:Visir/features/calendar/application/calendar_list_controller.dart';
import 'package:Visir/features/calendar/domain/entities/calendar_entity.dart';
import 'package:Visir/features/common/presentation/utils/extensions/color_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/list_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/platform_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/utils/log_event.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/common/presentation/widgets/popup_menu.dart';
import 'package:Visir/features/common/presentation/widgets/selection_widget.dart';
import 'package:Visir/features/common/presentation/widgets/visir_button.dart';
import 'package:Visir/features/common/presentation/widgets/visir_icon.dart';
import 'package:Visir/features/common/presentation/widgets/visir_list_item.dart';
import 'package:Visir/features/common/presentation/widgets/visir_list_section.dart';
import 'package:Visir/features/common/provider.dart' hide TextScaler;
import 'package:Visir/features/preference/presentation/screens/preference_screen.dart';
import 'package:Visir/features/preference/presentation/widgets/notification/calendar_notification_preference_widget.dart';
import 'package:Visir/features/preference/presentation/widgets/timezone_picker_widget.dart';
import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CalendarPrefScreen extends ConsumerStatefulWidget {
  final bool isSmall;
  final VoidCallback? onClose;

  const CalendarPrefScreen({super.key, required this.isSmall, this.onClose});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CalendarPrefScreenState();
}

class _CalendarPrefScreenState extends ConsumerState<CalendarPrefScreen> {
  ScrollController? _scrollController;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _scrollController?.dispose();

    widget.onClose?.call();
    super.dispose();
  }

  String getThemeString(bool? weekday) {
    return '';
  }

  String getDateString(int? weekday) {
    if (weekday == null) return context.tr.today;
    if (weekday == 7) return context.tr.sunday;
    if (weekday == 1) return context.tr.monday;
    return '';
  }

  String getWeekStartString(int? weekday) {
    if (weekday == 0) return context.tr.today;
    if (weekday == 7) return context.tr.sunday;
    if (weekday == 1) return context.tr.monday;
    return '';
  }

  @override
  Widget build(BuildContext context) {
    _scrollController ??= ModalScrollController.ofSyncGroup(context)?.addAndGet() ?? ScrollController();
    bool isMobileView = PlatformX.isMobileView;
    final calendarMap = ref.watch(calendarListControllerProvider);

    List<CalendarEntity> calendars = calendarMap.values.expand((e) => e).where((e) => e.modifiable != false).toList().unique((e) => e.uniqueId);

    String? defaultCalendarId = ref.watch(authControllerProvider.select((e) => e.requireValue.userDefaultCalendarId));
    CalendarEntity? defaultCalendar = calendarMap.values.expand((e) => e).where((e) => e.uniqueId == defaultCalendarId).firstOrNull;

    final firstDayOfWeek = ref.watch(authControllerProvider.select((e) => e.requireValue.userFirstDayOfWeek));
    final weekViewStartWeekday = ref.watch(authControllerProvider.select((e) => e.requireValue.userWeekViewStartWeekday));
    final defaultDurationInMinutes = ref.watch(authControllerProvider.select((e) => e.requireValue.userDefaultDurationInMinutes));
    final includeConferenceLinkOnCalendarTab = ref.watch(authControllerProvider.select((e) => e.requireValue.userIncludeConferenceLinkOnCalendarTab));

    final inboxCalendarDoubleClickActionType = ref.watch(authControllerProvider.select((e) => e.requireValue.userInboxCalendarDoubleClickActionType));
    final inboxCalendarDragActionType = ref.watch(authControllerProvider.select((e) => e.requireValue.userInboxCalendarDragActionType));

    final buttonWidth = PreferenceScreen.buttonWidth;
    final buttonHeight = PreferenceScreen.buttonHeight;

    return DetailsItem(
      title: widget.isSmall ? context.tr.calendar_pref_title : null,
      hideBackButton: !widget.isSmall,
      scrollController: _scrollController,
      scrollPhysics: Utils.getScrollPhysicsForBottomSheet(context, _scrollController),
      appbarColor: context.background,
      bodyColor: context.background,
      dividerColor: isMobileView ? context.outline : null,
      children: [
        VisirListSection(
          removeTopMargin: true,
          titleBuilder: (height, baseStyle, subStyle, horizontalSpacing) => TextSpan(text: context.tr.default_pref, style: baseStyle),
        ),

        VisirListItem(
          verticalPaddingOverride: 0,
          titleBuilder: (height, baseStyle, subStyle, horizontalSpacing) => TextSpan(text: context.tr.calendar_pref_start_title, style: baseStyle),
          titleTrailingBuilder: (height, baseStyle, subStyle, horizontalSpacing) => TextSpan(
            children: [
              WidgetSpan(
                child: PopupMenu(
                  forcePopup: true,
                  location: PopupMenuLocation.bottom,
                  width: buttonWidth,
                  borderRadius: 6,
                  type: ContextMenuActionType.tap,
                  popup: SelectionWidget<int>(
                    current: firstDayOfWeek,
                    items: [7, 1],
                    getTitle: (item) => getDateString(item),
                    onSelect: (firstDayOfWeek) async {
                      final user = ref.read(authControllerProvider).requireValue;
                      logAnalyticsEvent(eventName: 'start_week_on', properties: {'option': getDateString(firstDayOfWeek)});
                      await ref.read(authControllerProvider.notifier).updateUser(user: user.copyWith(firstDayOfWeek: firstDayOfWeek));
                    },
                  ),
                  style: VisirButtonStyle(width: buttonWidth, height: buttonHeight, backgroundColor: context.surface, borderRadius: BorderRadius.circular(6)),
                  child: Row(
                    children: [
                      SizedBox(width: 12),
                      Expanded(child: Text(getDateString(firstDayOfWeek), style: context.bodyMedium?.textColor(context.outlineVariant))),
                      SizedBox(width: 6),
                      VisirIcon(type: VisirIconType.arrowDown, size: 12, color: context.outlineVariant),
                      SizedBox(width: 10),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        VisirListItem(
          verticalPaddingOverride: 0,
          titleBuilder: (height, baseStyle, subStyle, horizontalSpacing) => TextSpan(text: context.tr.calendar_pref_week_title, style: baseStyle),
          titleTrailingBuilder: (height, baseStyle, subStyle, horizontalSpacing) => TextSpan(
            children: [
              WidgetSpan(
                child: PopupMenu(
                  forcePopup: true,
                  location: PopupMenuLocation.bottom,
                  width: buttonWidth,
                  borderRadius: 6,
                  type: ContextMenuActionType.tap,
                  popup: SelectionWidget<int?>(
                    current: weekViewStartWeekday,
                    items: [0, 7, 1],
                    getTitle: (item) => getWeekStartString(item),
                    onSelect: (weekViewStartWeekday) async {
                      final user = ref.read(authControllerProvider).requireValue;
                      logAnalyticsEvent(eventName: 'week_view_start_day', properties: {'option': getWeekStartString(weekViewStartWeekday)});
                      await ref.read(authControllerProvider.notifier).updateUser(user: user.copyWith(weekViewStartWeekday: weekViewStartWeekday));
                    },
                  ),
                  style: VisirButtonStyle(width: buttonWidth, height: buttonHeight, backgroundColor: context.surface, borderRadius: BorderRadius.circular(6)),
                  child: Row(
                    children: [
                      SizedBox(width: 12),
                      Expanded(child: Text(getWeekStartString(weekViewStartWeekday), style: context.bodyMedium?.textColor(context.outlineVariant))),
                      SizedBox(width: 6),
                      VisirIcon(type: VisirIconType.arrowDown, size: 12, color: context.outlineVariant),
                      SizedBox(width: 10),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        VisirListItem(
          verticalPaddingOverride: 0,
          titleBuilder: (height, baseStyle, subStyle, horizontalSpacing) => TextSpan(text: context.tr.calendar_pref_default, style: baseStyle),
          titleTrailingBuilder: (height, baseStyle, subStyle, horizontalSpacing) => TextSpan(
            children: [
              WidgetSpan(
                child: PopupMenu(
                  forcePopup: true,
                  location: PopupMenuLocation.bottom,
                  width: buttonWidth,
                  borderRadius: 6,
                  type: ContextMenuActionType.tap,
                  popup: SelectionWidget<String?>(
                    current: defaultCalendarId,
                    items: [null, ...calendars.map((e) => e.uniqueId).toList().unique((e) => e)],
                    getChild: (item) {
                      if (item == null) {
                        return Row(
                          children: [
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                context.tr.calendar_pref_last_used,
                                style: context.bodyMedium?.textColor(context.outlineVariant),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(width: 12),
                          ],
                        );
                      }
                      final calendar = calendars.where((e) => e.uniqueId == item).firstOrNull;
                      return Row(
                        children: [
                          SizedBox(width: 12),
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(color: ColorX.fromHex(calendar!.backgroundColor), borderRadius: BorderRadius.circular(4)),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              calendar.name,
                              style: context.bodyLarge!.textColor(context.outlineVariant),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 12),
                        ],
                      );
                    },
                    onSelect: (defaultCalendarId) async {
                      final user = ref.read(authControllerProvider).requireValue;
                      await ref.read(authControllerProvider.notifier).updateUser(user: user.copyWith(defaultCalendarId: defaultCalendarId ?? ''));
                    },
                  ),
                  style: VisirButtonStyle(width: buttonWidth, height: buttonHeight, backgroundColor: context.surface, borderRadius: BorderRadius.circular(6)),
                  child: Row(
                    children: [
                      SizedBox(width: 12),

                      if (defaultCalendar != null)
                        Container(
                          width: 4,
                          height: 14,
                          decoration: BoxDecoration(color: ColorX.fromHex(defaultCalendar.backgroundColor), borderRadius: BorderRadius.circular(2)),
                        ),
                      if (defaultCalendar != null) SizedBox(width: 6),

                      Expanded(
                        child: Text(defaultCalendar?.name ?? context.tr.calendar_pref_last_used, style: context.bodyMedium?.textColor(context.outlineVariant)),
                      ),
                      SizedBox(width: 6),
                      VisirIcon(type: VisirIconType.arrowDown, size: 12, color: context.outlineVariant),
                      SizedBox(width: 10),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        VisirListItem(
          verticalPaddingOverride: 0,
          titleBuilder: (height, baseStyle, subStyle, horizontalSpacing) => TextSpan(text: context.tr.calendar_pref_duration, style: baseStyle),
          titleTrailingBuilder: (height, baseStyle, subStyle, horizontalSpacing) => TextSpan(
            children: [
              WidgetSpan(
                child: PopupMenu(
                  forcePopup: true,
                  location: PopupMenuLocation.bottom,
                  width: buttonWidth,
                  borderRadius: 6,
                  type: ContextMenuActionType.tap,
                  popup: SelectionWidget<int>(
                    current: defaultDurationInMinutes,
                    items: [15, 30, 45, 60, 90, 120],
                    getTitle: (item) => Utils.getTimeString(context, item),
                    onSelect: (defaultDurationInMinutes) async {
                      final user = ref.read(authControllerProvider).requireValue;
                      await ref.read(authControllerProvider.notifier).updateUser(user: user.copyWith(defaultDurationInMinutes: defaultDurationInMinutes));
                    },
                  ),
                  style: VisirButtonStyle(width: buttonWidth, height: buttonHeight, backgroundColor: context.surface, borderRadius: BorderRadius.circular(6)),
                  child: Row(
                    children: [
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(Utils.getTimeString(context, defaultDurationInMinutes), style: context.bodyMedium?.textColor(context.outlineVariant)),
                      ),
                      SizedBox(width: 6),
                      VisirIcon(type: VisirIconType.arrowDown, size: 12, color: context.outlineVariant),
                      SizedBox(width: 10),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        VisirListItem(
          verticalPaddingOverride: 0,
          titleBuilder: (height, baseStyle, subStyle, horizontalSpacing) => TextSpan(text: context.tr.calendar_pref_include_conference_link, style: baseStyle),
          titleTrailingBuilder: (height, baseStyle, subStyle, horizontalSpacing) => TextSpan(
            children: [
              WidgetSpan(
                child: AnimatedToggleSwitch<bool>.rolling(
                  current: includeConferenceLinkOnCalendarTab,
                  values: [false, true],
                  height: buttonHeight,
                  indicatorSize: Size(buttonWidth / 2, buttonHeight),
                  indicatorIconScale: 1,
                  iconOpacity: 0.5,
                  borderWidth: 0,
                  onChanged: (includeConferenceLinkOnCalendarTab) async {
                    final user = ref.read(authControllerProvider).requireValue;
                    await ref
                        .read(authControllerProvider.notifier)
                        .updateUser(user: user.copyWith(includeConferenceLinkOnCalendarTab: includeConferenceLinkOnCalendarTab));
                  },
                  iconBuilder: (includeConferenceLinkOnCalendarTab, selected) => VisirIcon(
                    type: includeConferenceLinkOnCalendarTab ? VisirIconType.videoCall : VisirIconType.videoCallOff,
                    size: 16,
                    color: selected
                        ? includeConferenceLinkOnCalendarTab
                              ? context.onBackground
                              : context.error
                        : context.onBackground,
                    isSelected: true,
                  ),
                  style: ToggleStyle(
                    backgroundColor: context.surface,
                    borderRadius: BorderRadius.circular(6),
                    borderColor: context.surface.withValues(alpha: 1),
                    indicatorColor: context.surfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),

        VisirListItem(
          titleBuilder: (height, baseStyle, subStyle, horizontalSpacing) => TextSpan(text: context.tr.calendar_pref_event_reminder, style: baseStyle),
          detailsBuilder: (height, baseStyle, subStyle, horizontalSpacing) => Text.rich(
            TextSpan(
              text: context.tr.calendar_pref_event_reminder_body,
              style: context.bodyMedium?.textColor(context.inverseSurface),
              children: [
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: IntrinsicWidth(
                    child: VisirButton(
                      style: VisirButtonStyle(hoverColor: Colors.transparent),
                      type: VisirButtonAnimationType.scaleAndOpacity,
                      onTap: () => Utils.launchUrlExternal(url: 'https://calendar.google.com/calendar/r/settings'),
                      builder: (isHover) => Text(
                        context.tr.calendar_pref_event_reminder_link,
                        style: context.bodyMedium?.textColor(context.secondary).copyWith(decoration: isHover ? TextDecoration.underline : TextDecoration.none),
                        textScaler: TextScaler.noScaling,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        VisirListSection(
          titleBuilder: (height, baseStyle, subStyle, horizontalSpacing) => TextSpan(text: context.tr.pref_actions, style: baseStyle),
        ),

        VisirListItem(
          verticalPaddingOverride: 0,
          titleBuilder: (height, baseStyle, subStyle, horizontalSpacing) => TextSpan(text: context.tr.home_pref_double_click_action, style: baseStyle),
          titleTrailingBuilder: (height, baseStyle, subStyle, horizontalSpacing) => TextSpan(
            children: [
              WidgetSpan(
                child: PopupMenu(
                  forcePopup: true,
                  location: PopupMenuLocation.bottom,
                  width: buttonWidth,
                  borderRadius: 6,
                  type: ContextMenuActionType.tap,
                  popup: SelectionWidget<InboxCalendarActionType>(
                    current: inboxCalendarDoubleClickActionType,
                    items: InboxCalendarActionType.values,
                    getTitle: (item) => item.getTitle(context),
                    onSelect: (item) async {
                      final user = ref.read(authControllerProvider).requireValue;
                      logAnalyticsEvent(eventName: 'double_click_action', properties: {'option': item.getTitle(context)});
                      await ref.read(authControllerProvider.notifier).updateUser(user: user.copyWith(inboxCalendarDoubleClickActionType: item));
                    },
                  ),
                  style: VisirButtonStyle(width: buttonWidth, height: buttonHeight, backgroundColor: context.surface, borderRadius: BorderRadius.circular(6)),
                  child: Row(
                    children: [
                      SizedBox(width: 12),
                      Expanded(child: Text(inboxCalendarDoubleClickActionType.getTitle(context), style: context.bodyMedium?.textColor(context.outlineVariant))),
                      SizedBox(width: 6),
                      VisirIcon(type: VisirIconType.arrowDown, size: 12, color: context.outlineVariant),
                      SizedBox(width: 10),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        VisirListItem(
          verticalPaddingOverride: 0,
          titleBuilder: (height, baseStyle, subStyle, horizontalSpacing) => TextSpan(text: context.tr.home_pref_drag_action, style: baseStyle),
          titleTrailingBuilder: (height, baseStyle, subStyle, horizontalSpacing) => TextSpan(
            children: [
              WidgetSpan(
                child: PopupMenu(
                  forcePopup: true,
                  location: PopupMenuLocation.bottom,
                  width: buttonWidth,
                  borderRadius: 6,
                  type: ContextMenuActionType.tap,
                  popup: SelectionWidget<InboxCalendarActionType>(
                    current: inboxCalendarDragActionType,
                    items: InboxCalendarActionType.values,
                    getTitle: (item) => item.getTitle(context),
                    onSelect: (item) async {
                      final user = ref.read(authControllerProvider).requireValue;
                      logAnalyticsEvent(eventName: 'drag_action', properties: {'option': item.getTitle(context)});
                      await ref.read(authControllerProvider.notifier).updateUser(user: user.copyWith(inboxCalendarDragActionType: item));
                    },
                  ),
                  style: VisirButtonStyle(width: buttonWidth, height: buttonHeight, backgroundColor: context.surface, borderRadius: BorderRadius.circular(6)),
                  child: Row(
                    children: [
                      SizedBox(width: 12),
                      Expanded(child: Text(inboxCalendarDragActionType.getTitle(context), style: context.bodyMedium?.textColor(context.outlineVariant))),
                      SizedBox(width: 6),
                      VisirIcon(type: VisirIconType.arrowDown, size: 12, color: context.outlineVariant),
                      SizedBox(width: 10),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        VisirListSection(
          titleBuilder: (height, baseStyle, subStyle, horizontalSpacing) => TextSpan(text: "Timezone", style: baseStyle),
        ),

        // Builder(
        //   builder: (context) {
        //     final systemTimezone = ref.watch(timezoneProvider).value ?? 'UTC';
        //     final defaultTimezone = ref.watch(localPrefControllerProvider.select((v) => v.value?.prefDefaultTimezone));
        //     final displayTimezone = defaultTimezone ?? systemTimezone;

        //     String getTimezoneDisplayName(String tz) {
        //       final parts = tz.split('/');
        //       return parts.length > 1 ? parts.last.replaceAll('_', ' ') : tz;
        //     }

        //     return VisirListItem(
        //       verticalPaddingOverride: 0,
        //       titleBuilder: (height, baseStyle, subStyle, horizontalSpacing) => TextSpan(text: context.tr.calendar_pref_duration, style: baseStyle),
        //       titleTrailingBuilder: (height, baseStyle, subStyle, horizontalSpacing) => TextSpan(
        //         children: [
        //           WidgetSpan(
        //             child: PopupMenu(
        //               forcePopup: true,
        //               location: PopupMenuLocation.bottom,
        //               width: buttonWidth,
        //               borderRadius: 6,
        //               type: ContextMenuActionType.tap,
        //               popup: TimezonePickerWidget(
        //                 currentTimezone: displayTimezone,
        //                 deviceTimezone: systemTimezone,
        //                 onSelected: (timezone) {
        //                   ref.read(localPrefControllerProvider.notifier).set(defaultTimezone: timezone, removeDefaultTimezone: timezone == null);
        //                 },
        //                 allowNone: false,
        //                 allowDeviceDefault: true,
        //               ),
        //               style: VisirButtonStyle(
        //                 width: buttonWidth,
        //                 height: buttonHeight,
        //                 backgroundColor: context.surface,
        //                 borderRadius: BorderRadius.circular(6),
        //               ),
        //               child: Row(
        //                 children: [
        //                   SizedBox(width: 12),
        //                   Expanded(
        //                     child: Text(
        //                       defaultTimezone == null ? 'Device Default' : getTimezoneDisplayName(displayTimezone),
        //                       style: context.bodyMedium?.textColor(context.outlineVariant),
        //                     ),
        //                   ),
        //                   SizedBox(width: 6),
        //                   VisirIcon(type: VisirIconType.arrowDown, size: 12, color: context.outlineVariant),
        //                   SizedBox(width: 10),
        //                 ],
        //               ),
        //             ),
        //           ),
        //         ],
        //       ),
        //     );
        //   },
        // ),
        Builder(
          builder: (context) {
            final secondaryTimezone = ref.watch(secondaryTimezoneProvider);

            String getTimezoneDisplayName(String? tz) {
              if (tz == null) return 'None';
              return tz;
            }

            return VisirListItem(
              verticalPaddingOverride: 0,
              titleBuilder: (height, baseStyle, subStyle, horizontalSpacing) => TextSpan(text: context.tr.secondary_timezone, style: baseStyle),
              titleTrailingBuilder: (height, baseStyle, subStyle, horizontalSpacing) => TextSpan(
                children: [
                  WidgetSpan(
                    child: PopupMenu(
                      forcePopup: true,
                      location: PopupMenuLocation.bottom,
                      width: 180,
                      borderRadius: 6,
                      type: ContextMenuActionType.tap,
                      popup: TimezonePickerWidget(
                        currentTimezone: secondaryTimezone,
                        deviceTimezone: ref.watch(timezoneProvider).value,
                        onSelected: (timezone) {
                          ref.read(secondaryTimezoneProvider.notifier).update(timezone);
                        },
                        allowNone: true,
                        allowDeviceDefault: false,
                      ),
                      style: VisirButtonStyle(
                        width: buttonWidth,
                        height: buttonHeight,
                        backgroundColor: context.surface,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          SizedBox(width: 12),
                          Expanded(child: Text(getTimezoneDisplayName(secondaryTimezone), style: context.bodyMedium?.textColor(context.outlineVariant))),
                          SizedBox(width: 6),
                          VisirIcon(type: VisirIconType.arrowDown, size: 12, color: context.outlineVariant),
                          SizedBox(width: 10),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),

        VisirListSection(
          titleBuilder: (height, baseStyle, subStyle, horizontalSpacing) => TextSpan(text: context.tr.notification_pref_title, style: baseStyle),
        ),

        CalendarNotificationPreferenceWidget(),
      ],
    );
  }
}
