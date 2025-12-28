import 'package:Visir/config/providers.dart';
import 'package:Visir/dependency/contextmenu/src/ContextMenuArea.dart';
import 'package:Visir/dependency/modal_bottom_sheet/src/utils/modal_scroll_controller.dart';
import 'package:Visir/dependency/omni_datetime_picker/omni_datetime_picker.dart';
import 'package:Visir/dependency/omni_datetime_picker/src/omni_datetime_picker.dart';
import 'package:Visir/dependency/rrule/rrule.dart';
import 'package:Visir/dependency/rrule/src/utils.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/common/presentation/widgets/desktop_scaffold.dart';
import 'package:Visir/features/common/presentation/widgets/popup_menu.dart';
import 'package:Visir/features/common/presentation/widgets/selection_widget.dart';
import 'package:Visir/features/common/presentation/widgets/visir_button.dart';
import 'package:Visir/features/common/presentation/widgets/visir_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

extension FrequecyX on Frequency {
  String getTitle(BuildContext context) {
    switch (this) {
      case Frequency.daily:
        return context.tr.calendar_recurrence_daily;
      case Frequency.weekly:
        return context.tr.calendar_recurrence_weekly;
      case Frequency.monthly:
        return context.tr.calendar_recurrence_monthly;
      case Frequency.yearly:
        return context.tr.calendar_recurrence_yearly;
    }
    return '';
  }
}

enum CalendarEndType { never, after, date }

extension CalendarEndTypeX on CalendarEndType {
  String getTitle(BuildContext context) {
    switch (this) {
      case CalendarEndType.never:
        return context.tr.calendar_recurrence_ends_never;
      case CalendarEndType.after:
        return context.tr.calendar_recurrence_ends_after;
      case CalendarEndType.date:
        return context.tr.calendar_recurrence_ends_on_date;
    }
  }
}

enum CalendarOnType { date, weekday }

class CalendarRruleEditWidget extends ConsumerStatefulWidget {
  final DateTime startDate;
  final RecurrenceRule? initialRrule;

  final void Function(RecurrenceRule? rrule) onRruleChanged;

  const CalendarRruleEditWidget({super.key, required this.onRruleChanged, this.initialRrule, required this.startDate});

  @override
  ConsumerState createState() => _CalendarRruleEditState();
}

class _CalendarRruleEditState extends ConsumerState<CalendarRruleEditWidget> {
  RruleL10n? rruleL10n;
  late RecurrenceRule rrule;
  ScrollController? _scrollController;

  @override
  void initState() {
    super.initState();
    rruleL10n = ref.read(rruleL10nEnProvider).asData?.value;
    rrule = widget.initialRrule ?? RecurrenceRule(frequency: Frequency.daily);
  }

  @override
  void dispose() {
    _scrollController?.dispose();
    super.dispose();
  }

  String numberString(int number) {
    if (number == 1) return context.tr.first;
    if (number == 2) return context.tr.second;
    if (number == 3) return context.tr.third;
    return context.tr.number(number);
  }

  String weekString(int number) {
    if (number == 1) return 'Mon';
    if (number == 2) return 'Tue';
    if (number == 3) return 'Wed';
    if (number == 4) return "Thu";
    if (number == 5) return 'Fri';
    if (number == 6) return 'Sat';
    return 'Sun';
  }

  String onString(bool isWeekdays, bool isYearly, DateTime date) {
    String on = '';
    if (isYearly) {
      on += DateFormat('MMM').format(date);
      on += ' ';
    }

    if (isWeekdays) {
      on += numberString(date.weekOfMonth);
      on += ' ';
      on += DateFormat('EEE').format(date);
    } else {
      on += numberString(date.day);
    }
    return on;
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

    return Container(
      child: Padding(
        padding: EdgeInsets.only(top: 8, bottom: 2, left: 6, right: 6),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: tagWidth,
                  height: 32,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(DesktopScaffold.cardPadding), color: context.tertiary),
                  alignment: Alignment.center,
                  child: Text(context.tr.calendar_recurrence_every, style: tagStyle?.textColor(context.onTertiary)),
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
                          height: 240,
                          borderRadius: 6,
                          type: ContextMenuActionType.tap,
                          popup: SelectionWidget<int>(
                            current: rrule.actualInterval,
                            items: List.generate(99, (index) => index + 1),
                            getTitle: (item) => item.toString(),
                            onSelect: (interval) {
                              rrule = rrule.copyWith(interval: interval);
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
                              Expanded(child: Text(rrule.actualInterval.toString(), style: (context.bodyMedium)?.textColor(context.outlineVariant))),
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
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(DesktopScaffold.cardPadding), color: context.surfaceVariant),
                    width: double.maxFinite,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return PopupMenu(
                          forcePopup: true,
                          location: PopupMenuLocation.bottom,
                          width: constraints.maxWidth,
                          borderRadius: 6,
                          type: ContextMenuActionType.tap,
                          popup: SelectionWidget<Frequency>(
                            current: rrule.frequency,
                            getTitle: (item) => item.getTitle(context) + (rrule.actualInterval > 1 ? 's' : ''),
                            items: [Frequency.daily, Frequency.weekly, Frequency.monthly, Frequency.yearly],
                            onSelect: (frequency) {
                              switch (frequency) {
                                case Frequency.daily:
                                  rrule = RecurrenceRule(frequency: Frequency.daily);
                                  break;
                                case Frequency.weekly:
                                  rrule = RecurrenceRule(frequency: Frequency.weekly, byWeekDays: [ByWeekDayEntry(widget.startDate.weekday)]);
                                  break;
                                case Frequency.monthly:
                                  rrule = RecurrenceRule(frequency: Frequency.monthly, byMonthDays: [widget.startDate.day]);
                                  break;
                                case Frequency.yearly:
                                  rrule = RecurrenceRule(frequency: Frequency.yearly, byMonthDays: [widget.startDate.day], byMonths: [widget.startDate.month]);
                                  break;
                              }
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
                              Expanded(
                                child: Text(
                                  rrule.frequency.getTitle(context) + (rrule.actualInterval > 1 ? 's' : ''),
                                  style: context.bodyMedium?.textColor(context.outlineVariant),
                                ),
                              ),
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
            if (rrule.frequency != Frequency.daily) SizedBox(height: topMargin),
            if (rrule.frequency == Frequency.weekly)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: tagWidth,
                    height: tagHeight,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(DesktopScaffold.cardPadding), color: context.tertiary),
                    alignment: Alignment.center,
                    child: Text(context.tr.calendar_recurrence_on, style: tagStyle?.textColor(context.onTertiary)),
                  ),
                  SizedBox(height: 8),
                  SizedBox(
                    width: double.maxFinite,
                    height: 28,
                    child: Row(
                      children: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12].map((e) {
                        if (e % 2 == 1) return SizedBox(width: 8);

                        bool isPressed = rrule.byWeekDays.where((w) => w.day == (e ~/ 2 + 1)).isNotEmpty;
                        return Expanded(
                          child: VisirButton(
                            type: VisirButtonAnimationType.scaleAndOpacity,
                            isSelected: isPressed,
                            style: VisirButtonStyle(
                              width: double.maxFinite,
                              height: 28,
                              padding: EdgeInsets.zero,
                              selectedColor: context.primary,
                              borderRadius: BorderRadius.circular(6),
                              border: isPressed ? null : Border.all(color: context.surfaceVariant, width: 1),
                            ),
                            onTap: () {
                              if (isPressed) {
                                rrule.byWeekDays.removeWhere((w) => w.day == (e ~/ 2 + 1));
                              } else {
                                rrule.byWeekDays.add(ByWeekDayEntry(e ~/ 2 + 1));
                              }
                              setState(() {});
                            },
                            child: Text(weekString(e ~/ 2 + 1), style: context.bodyMedium?.textColor(isPressed ? context.onPrimary : context.outlineVariant)),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            if (rrule.frequency == Frequency.monthly || rrule.frequency == Frequency.yearly)
              Row(
                children: [
                  Container(
                    width: tagWidth,
                    height: tagHeight,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(DesktopScaffold.cardPadding), color: context.tertiary),
                    alignment: Alignment.center,
                    child: Text(context.tr.calendar_recurrence_on, style: tagStyle?.textColor(context.onTertiary)),
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
                            popup: SelectionWidget<CalendarOnType>(
                              current: rrule.hasByWeekDays ? CalendarOnType.weekday : CalendarOnType.date,
                              items: CalendarOnType.values,
                              getTitle: (item) => onString(item == CalendarOnType.weekday, rrule.frequency == Frequency.yearly, widget.startDate),
                              onSelect: (item) {
                                switch (item) {
                                  case CalendarOnType.date:
                                    rrule = rrule.copyWith(byWeekDays: [], byMonthDays: [widget.startDate.day]);
                                    break;
                                  case CalendarOnType.weekday:
                                    rrule = rrule.copyWith(
                                      byWeekDays: [ByWeekDayEntry(widget.startDate.weekday, widget.startDate.weekOfMonth)],
                                      byMonthDays: [],
                                    );
                                    break;
                                }
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
                                Expanded(
                                  child: Text(
                                    onString(rrule.hasByWeekDays, rrule.frequency == Frequency.yearly, widget.startDate),
                                    style: context.bodyMedium?.textColor(context.outlineVariant),
                                  ),
                                ),
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
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(DesktopScaffold.cardPadding), color: context.tertiary),
                  alignment: Alignment.center,
                  child: Text(context.tr.calendar_recurrence_ends, style: tagStyle?.textColor(context.onTertiary)),
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
                          popup: SelectionWidget<CalendarEndType>(
                            current: rrule.until != null
                                ? CalendarEndType.date
                                : rrule.count != null
                                ? CalendarEndType.after
                                : CalendarEndType.never,
                            items: CalendarEndType.values,
                            getTitle: (item) => item.getTitle(context),
                            onSelect: (item) {
                              switch (item) {
                                case CalendarEndType.never:
                                  rrule = rrule.copyWith(clearCount: true, clearUntil: true);
                                  break;
                                case CalendarEndType.after:
                                  rrule = rrule.copyWith(clearUntil: true, count: 1);
                                  break;
                                case CalendarEndType.date:
                                  rrule = rrule.copyWith(until: widget.startDate, clearCount: true);
                                  break;
                              }
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
                              Expanded(
                                child: Text(
                                  (rrule.until != null
                                          ? CalendarEndType.date
                                          : rrule.count != null
                                          ? CalendarEndType.after
                                          : CalendarEndType.never)
                                      .getTitle(context),
                                  style: context.bodyMedium?.textColor(context.outlineVariant),
                                ),
                              ),
                              VisirIcon(type: VisirIconType.arrowDown, size: 12),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
                if (rrule.until != null || rrule.count != null) SizedBox(width: 8),
                if (rrule.until != null || rrule.count != null)
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
                            width: rrule.until != null ? 296 : constraints.maxWidth,
                            height: rrule.until != null ? 300 : null,
                            borderRadius: 6,
                            type: ContextMenuActionType.tap,
                            popup: rrule.count != null
                                ? SelectionWidget<int>(
                                    current: rrule.count ?? 1,
                                    items: List.generate(99, (index) => index + 1),
                                    getTitle: (item) => context.tr.calendar_recurrence_count_times(item),
                                    onSelect: (item) {
                                      rrule = rrule.copyWith(count: item);
                                      setState(() {});
                                    },
                                  )
                                : OmniDateTimePicker(
                                    type: OmniDateTimePickerType.date,
                                    initialDate: rrule.until ?? widget.startDate,
                                    onDateChanged: (dateTime) {
                                      rrule = rrule.copyWith(until: dateTime);
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
                                Expanded(
                                  child: Text(
                                    rrule.until != null
                                        ? DateFormat('yyyy/MM/dd').format(rrule.until!)
                                        : rrule.count != null
                                        ? context.tr.calendar_recurrence_count_times(rrule.count!)
                                        : '',
                                    style: context.bodyMedium?.textColor(context.outlineVariant),
                                  ),
                                ),
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
                widget.onRruleChanged(rrule);
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
          ],
        ),
      ),
    );
  }
}
