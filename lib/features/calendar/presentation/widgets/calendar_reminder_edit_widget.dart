import 'package:Visir/dependency/contextmenu/src/ContextMenuArea.dart';
import 'package:Visir/dependency/modal_bottom_sheet/src/utils/modal_scroll_controller.dart';
import 'package:Visir/features/calendar/domain/entities/event_reminder_entity.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/common/presentation/widgets/desktop_scaffold.dart';
import 'package:Visir/features/common/presentation/widgets/popup_menu.dart';
import 'package:Visir/features/common/presentation/widgets/selection_widget.dart';
import 'package:Visir/features/common/presentation/widgets/visir_button.dart';
import 'package:Visir/features/common/presentation/widgets/visir_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum CalendarReminderIntervalType { minutes, hours, days, weeks }

extension CalendarReminderIntervalTypeX on CalendarReminderIntervalType {
  String getTitle(BuildContext context) {
    switch (this) {
      case CalendarReminderIntervalType.minutes:
        return context.tr.minutes;
      case CalendarReminderIntervalType.hours:
        return context.tr.hours;
      case CalendarReminderIntervalType.days:
        return context.tr.days;
      case CalendarReminderIntervalType.weeks:
        return context.tr.weeks;
    }
  }
}

enum CalendarReminderPushType { email, push }

extension CalendarReminderPushTypeX on CalendarReminderPushType {
  String getTitle(BuildContext context) {
    switch (this) {
      case CalendarReminderPushType.email:
        return context.tr.mail;
      case CalendarReminderPushType.push:
        return context.tr.push_notification;
    }
  }
}

enum CalendarReminderAllDayIntervalType { days, weeks }

extension CalendarReminderAllDayIntervalTypeX on CalendarReminderAllDayIntervalType {
  String getTitle(BuildContext context) {
    switch (this) {
      case CalendarReminderAllDayIntervalType.days:
        return context.tr.days;
      case CalendarReminderAllDayIntervalType.weeks:
        return context.tr.weeks;
    }
  }
}

class CalendarReminderEditWidget extends StatefulWidget {
  final EventReminderEntity? initialReminder;
  final bool isAllDay;

  final void Function(EventReminderEntity reminder) onReminderChanged;

  const CalendarReminderEditWidget({super.key, this.initialReminder, required this.onReminderChanged, required this.isAllDay});

  @override
  State<CalendarReminderEditWidget> createState() => _CalendarReminderEditWidgetState();
}

class _CalendarReminderEditWidgetState extends State<CalendarReminderEditWidget> {
  CalendarReminderAllDayIntervalType allDayIntervalType = CalendarReminderAllDayIntervalType.days;
  List<TimeOfDay> timesWithInterval30Minutes = [
    TimeOfDay(hour: 0, minute: 0),
    TimeOfDay(hour: 0, minute: 30),
    TimeOfDay(hour: 1, minute: 0),
    TimeOfDay(hour: 1, minute: 30),
    TimeOfDay(hour: 2, minute: 0),
    TimeOfDay(hour: 2, minute: 30),
    TimeOfDay(hour: 3, minute: 0),
    TimeOfDay(hour: 3, minute: 30),
    TimeOfDay(hour: 4, minute: 0),
    TimeOfDay(hour: 4, minute: 30),
    TimeOfDay(hour: 5, minute: 0),
    TimeOfDay(hour: 5, minute: 30),
    TimeOfDay(hour: 6, minute: 0),
    TimeOfDay(hour: 6, minute: 30),
    TimeOfDay(hour: 7, minute: 0),
    TimeOfDay(hour: 7, minute: 30),
    TimeOfDay(hour: 8, minute: 0),
    TimeOfDay(hour: 8, minute: 30),
    TimeOfDay(hour: 9, minute: 0),
    TimeOfDay(hour: 9, minute: 30),
    TimeOfDay(hour: 10, minute: 0),
    TimeOfDay(hour: 10, minute: 30),
    TimeOfDay(hour: 11, minute: 0),
    TimeOfDay(hour: 11, minute: 30),
    TimeOfDay(hour: 12, minute: 0),
    TimeOfDay(hour: 12, minute: 30),
    TimeOfDay(hour: 13, minute: 0),
    TimeOfDay(hour: 13, minute: 30),
    TimeOfDay(hour: 14, minute: 0),
    TimeOfDay(hour: 14, minute: 30),
    TimeOfDay(hour: 15, minute: 0),
    TimeOfDay(hour: 15, minute: 30),
    TimeOfDay(hour: 16, minute: 0),
    TimeOfDay(hour: 16, minute: 30),
    TimeOfDay(hour: 17, minute: 0),
    TimeOfDay(hour: 17, minute: 30),
    TimeOfDay(hour: 18, minute: 0),
    TimeOfDay(hour: 18, minute: 30),
    TimeOfDay(hour: 19, minute: 0),
    TimeOfDay(hour: 19, minute: 30),
    TimeOfDay(hour: 20, minute: 0),
    TimeOfDay(hour: 20, minute: 30),
    TimeOfDay(hour: 21, minute: 0),
    TimeOfDay(hour: 21, minute: 30),
    TimeOfDay(hour: 22, minute: 0),
    TimeOfDay(hour: 22, minute: 30),
    TimeOfDay(hour: 23, minute: 0),
    TimeOfDay(hour: 23, minute: 30),
  ];
  late TimeOfDay time;

  CalendarReminderIntervalType intervalType = CalendarReminderIntervalType.minutes;
  CalendarReminderPushType pushType = CalendarReminderPushType.push;
  int interval = 10;

  ScrollController? _scrollController;

  @override
  void initState() {
    super.initState();

    pushType = widget.initialReminder?.method == 'email' ? CalendarReminderPushType.email : CalendarReminderPushType.push;
    if (widget.isAllDay) {
      interval = widget.initialReminder?.minutes ?? 900;

      int days = interval ~/ (60 * 24);
      if (days != interval / 60 / 24) days += 1;

      final minutesInDay = interval % (60 * 24);
      allDayIntervalType = days % 7 == 0 ? CalendarReminderAllDayIntervalType.weeks : CalendarReminderAllDayIntervalType.days;
      interval = allDayIntervalType == CalendarReminderAllDayIntervalType.days ? days : days ~/ 7;
      final minutes = minutesInDay == 0 ? 0 : 60 * 24 - minutesInDay;
      final hour = minutes ~/ 60;
      final minute = minutes % 60;

      time = TimeOfDay(hour: hour, minute: minute);
    } else {
      interval = widget.initialReminder?.minutes ?? 10;
      intervalType = interval % 60 != 0
          ? CalendarReminderIntervalType.minutes
          : interval % (60 * 24) != 0
          ? CalendarReminderIntervalType.hours
          : interval % (60 * 24 * 7) != 0
          ? CalendarReminderIntervalType.days
          : CalendarReminderIntervalType.weeks;

      interval = intervalType == CalendarReminderIntervalType.minutes
          ? interval
          : intervalType == CalendarReminderIntervalType.hours
          ? interval ~/ 60
          : intervalType == CalendarReminderIntervalType.days
          ? interval ~/ (60 * 24)
          : interval ~/ (60 * 24 * 7);
    }
  }

  @override
  void dispose() {
    _scrollController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _scrollController ??= ModalScrollController.ofSyncGroup(context)?.addAndGet() ?? ScrollController();
    final topMargin = 6.0;
    final borderRaidus = DesktopScaffold.cardPadding;
    final inputHeight = 32.0;
    final tagHeight = 32.0;
    final tagWidth = 60.0;
    final tagStyle = context.bodyLarge;

    return widget.isAllDay
        ? Container(
            child: Padding(
              padding: EdgeInsets.only(top: 8, bottom: 2, left: 6, right: 6),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: tagWidth,
                        height: tagHeight,
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(borderRaidus), color: context.tertiary),
                        alignment: Alignment.center,
                        child: Text(context.tr.calendar_reminder_before, style: tagStyle?.textColor(context.onTertiary)),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          height: inputHeight,
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(borderRaidus), color: context.surfaceVariant),
                          width: double.maxFinite,
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              return PopupMenu(
                                forcePopup: true,
                                location: PopupMenuLocation.bottom,
                                width: constraints.maxWidth,
                                borderRadius: 6,
                                type: ContextMenuActionType.tap,
                                style: VisirButtonStyle(
                                  height: 32,
                                  width: double.maxFinite,
                                  borderRadius: BorderRadius.circular(borderRaidus),
                                  backgroundColor: context.surfaceVariant,
                                  padding: EdgeInsets.symmetric(horizontal: 12),
                                ),
                                popup: SelectionWidget<int>(
                                  current: interval,
                                  items: List.generate(99, (index) => index + 1),
                                  getTitle: (item) => item.toString(),
                                  onSelect: (interval) {
                                    this.interval = interval;
                                    setState(() {});
                                  },
                                ),
                                child: Row(
                                  children: [
                                    Expanded(child: Text(interval.toString(), style: context.bodyMedium?.textColor(context.outlineVariant))),
                                    SizedBox(width: 6),
                                    VisirIcon(type: VisirIconType.arrowDown, size: 12),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          height: inputHeight,
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(borderRaidus), color: context.surfaceVariant),
                          width: double.maxFinite,
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              return PopupMenu(
                                forcePopup: true,
                                location: PopupMenuLocation.bottom,
                                width: constraints.maxWidth,
                                borderRadius: 6,
                                type: ContextMenuActionType.tap,
                                popup: SelectionWidget<CalendarReminderAllDayIntervalType>(
                                  current: allDayIntervalType,
                                  getTitle: (item) => item.getTitle(context),
                                  items: CalendarReminderAllDayIntervalType.values,
                                  onSelect: (interval) {
                                    allDayIntervalType = interval;
                                    setState(() {});
                                  },
                                ),
                                style: VisirButtonStyle(
                                  height: 32,
                                  width: double.maxFinite,
                                  borderRadius: BorderRadius.circular(borderRaidus),
                                  backgroundColor: context.surfaceVariant,
                                  padding: EdgeInsets.symmetric(horizontal: 12),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(child: Text(allDayIntervalType.getTitle(context), style: context.bodyMedium?.textColor(context.outlineVariant))),
                                    SizedBox(width: 6),
                                    VisirIcon(type: VisirIconType.arrowDown, size: 12),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: topMargin),
                  Row(
                    children: [
                      Container(
                        width: tagWidth,
                        height: tagHeight,
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(borderRaidus), color: context.tertiary),
                        alignment: Alignment.center,
                        child: Text(context.tr.calendar_reminder_at, style: tagStyle?.textColor(context.onTertiary)),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          height: inputHeight,
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(borderRaidus), color: context.surfaceVariant),
                          width: double.maxFinite,
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              return PopupMenu(
                                forcePopup: true,
                                location: PopupMenuLocation.bottom,
                                width: constraints.maxWidth,
                                borderRadius: 6,
                                type: ContextMenuActionType.tap,
                                popup: SelectionWidget<TimeOfDay>(
                                  current: time,
                                  items: timesWithInterval30Minutes,
                                  getTitle: (item) => item.format(context),
                                  onSelect: (time) {
                                    this.time = time;
                                    setState(() {});
                                  },
                                ),
                                style: VisirButtonStyle(
                                  height: 32,
                                  width: double.maxFinite,
                                  borderRadius: BorderRadius.circular(borderRaidus),
                                  backgroundColor: context.surfaceVariant,
                                  padding: EdgeInsets.symmetric(horizontal: 12),
                                ),
                                child: Container(
                                  child: Row(
                                    children: [
                                      Expanded(child: Text(time.format(context), style: context.bodyMedium?.textColor(context.outlineVariant))),
                                      SizedBox(width: 6),
                                      VisirIcon(type: VisirIconType.arrowDown, size: 12),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: topMargin),
                  Row(
                    children: [
                      Container(
                        width: tagWidth,
                        height: tagHeight,
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(borderRaidus), color: context.tertiary),
                        alignment: Alignment.center,
                        child: Text(context.tr.calendar_reminder_by, style: tagStyle?.textColor(context.onTertiary)),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          height: inputHeight,
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(borderRaidus), color: context.surfaceVariant),
                          width: double.maxFinite,
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              return PopupMenu(
                                forcePopup: true,
                                location: PopupMenuLocation.bottom,
                                width: constraints.maxWidth,
                                borderRadius: 6,
                                type: ContextMenuActionType.tap,
                                popup: SelectionWidget<CalendarReminderPushType>(
                                  current: pushType,
                                  items: CalendarReminderPushType.values,
                                  getTitle: (item) => item.getTitle(context),
                                  onSelect: (time) {
                                    this.pushType = time;
                                    setState(() {});
                                  },
                                ),
                                style: VisirButtonStyle(
                                  height: 32,
                                  width: double.maxFinite,
                                  borderRadius: BorderRadius.circular(borderRaidus),
                                  backgroundColor: context.surfaceVariant,
                                  padding: EdgeInsets.symmetric(horizontal: 12),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(child: Text(pushType.getTitle(context), style: context.bodyMedium?.textColor(context.outlineVariant))),
                                    SizedBox(width: 6),
                                    VisirIcon(type: VisirIconType.arrowDown, size: 12),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )
        : Container(
            child: Padding(
              padding: EdgeInsets.only(top: 8, bottom: 2, left: 6, right: 6),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: tagWidth,
                        height: tagHeight,
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(borderRaidus), color: context.tertiary),
                        alignment: Alignment.center,
                        child: Text(context.tr.calendar_reminder_before, style: tagStyle?.textColor(context.onTertiary)),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: SizedBox(
                          height: inputHeight,
                          child: TextFormField(
                            initialValue: interval.toString(),
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                            style: context.bodyMedium?.textColor(context.outlineVariant),
                            decoration: InputDecoration(
                              hintText: context.tr.type_title,
                              hintStyle: context.bodyMedium?.textColor(context.surfaceTint),
                              fillColor: context.surfaceVariant,
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                              hoverColor: Colors.transparent,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(borderRaidus), borderSide: BorderSide.none),
                            ),
                            onChanged: (text) {
                              interval = int.tryParse(text) ?? 0;
                              setState(() {});
                            },
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          height: inputHeight,
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(borderRaidus), color: context.surfaceVariant),
                          width: double.maxFinite,
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              return PopupMenu(
                                forcePopup: true,
                                location: PopupMenuLocation.bottom,
                                width: constraints.maxWidth,
                                borderRadius: 6,
                                type: ContextMenuActionType.tap,
                                popup: SelectionWidget<CalendarReminderIntervalType>(
                                  current: intervalType,
                                  getTitle: (item) => item.getTitle(context),
                                  items: CalendarReminderIntervalType.values,
                                  onSelect: (interval) {
                                    intervalType = interval;
                                    setState(() {});
                                  },
                                ),
                                style: VisirButtonStyle(
                                  height: 32,
                                  width: double.maxFinite,
                                  borderRadius: BorderRadius.circular(borderRaidus),
                                  backgroundColor: context.surfaceVariant,
                                  padding: EdgeInsets.symmetric(horizontal: 12),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(child: Text(intervalType.getTitle(context), style: context.bodyMedium?.textColor(context.outlineVariant))),
                                    SizedBox(width: 6),
                                    VisirIcon(type: VisirIconType.arrowDown, size: 12),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: topMargin),
                  Row(
                    children: [
                      Container(
                        width: tagWidth,
                        height: tagHeight,
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(borderRaidus), color: context.tertiary),
                        alignment: Alignment.center,
                        child: Text(context.tr.calendar_reminder_by, style: tagStyle?.textColor(context.onTertiary)),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          height: inputHeight,
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(borderRaidus), color: context.surfaceVariant),
                          width: double.maxFinite,
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              return PopupMenu(
                                forcePopup: true,
                                location: PopupMenuLocation.bottom,
                                width: constraints.maxWidth,
                                borderRadius: 6,
                                type: ContextMenuActionType.tap,
                                popup: SelectionWidget<CalendarReminderPushType>(
                                  current: pushType,
                                  items: CalendarReminderPushType.values,
                                  getTitle: (item) => item.getTitle(context),
                                  onSelect: (time) {
                                    this.pushType = time;
                                    setState(() {});
                                  },
                                ),
                                style: VisirButtonStyle(
                                  height: 32,
                                  width: double.maxFinite,
                                  borderRadius: BorderRadius.circular(borderRaidus),
                                  backgroundColor: context.surfaceVariant,
                                  padding: EdgeInsets.symmetric(horizontal: 12),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(child: Text(pushType.getTitle(context), style: context.bodyMedium?.textColor(context.outlineVariant))),
                                    SizedBox(width: 6),
                                    VisirIcon(type: VisirIconType.arrowDown, size: 12),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6),

                  VisirButton(
                    type: VisirButtonAnimationType.scaleAndOpacity,
                    style: VisirButtonStyle(
                      width: double.maxFinite,
                      padding: EdgeInsets.all(8),
                      backgroundColor: context.primary,
                      borderRadius: BorderRadius.circular(DesktopScaffold.cardRadius),
                    ),
                    options: VisirButtonOptions(
                      shortcuts: [
                        VisirButtonKeyboardShortcut(message: context.tr.save, keys: [LogicalKeyboardKey.enter]),
                      ],
                    ),
                    onTap: () {
                      widget.onReminderChanged(EventReminderEntity(minutes: interval, method: pushType == CalendarReminderPushType.email ? 'email' : 'push'));
                      if (Navigator.of(Utils.mainContext).canPop()) Navigator.of(Utils.mainContext).pop();
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        VisirIcon(type: VisirIconType.checkWithCircle, size: 14, color: context.onPrimary, isSelected: true),
                        SizedBox(width: 6),
                        Text(context.tr.save, style: context.bodyLarge?.textColor(context.onPrimary)),
                      ],
                    ),
                  ),
                  SizedBox(height: 6),
                ],
              ),
            ),
          );
  }
}
