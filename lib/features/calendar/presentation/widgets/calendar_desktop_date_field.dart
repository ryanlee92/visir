import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:time/time.dart';

class CalendarDesktopDateField extends StatefulWidget {
  final DateTime selectedDateTime;
  final bool isAllDay;
  final void Function(DateTime dateTime) onDateChanged;

  const CalendarDesktopDateField({super.key, required this.selectedDateTime, required this.isAllDay, required this.onDateChanged});

  @override
  State<CalendarDesktopDateField> createState() => CalendarDesktopDateFieldState();
}

class CalendarDesktopDateFieldState extends State<CalendarDesktopDateField> {
  late DateTime selectedDateTime;
  FocusNode yearFocusNode = FocusNode();
  FocusNode monthFocusNode = FocusNode();
  FocusNode dayFocusNode = FocusNode();

  late TextEditingController yearController;
  late TextEditingController monthController;
  late TextEditingController dayController;

  late String year;
  late String month;
  late String day;

  bool get isFocused => yearFocusNode.hasFocus || monthFocusNode.hasFocus || dayFocusNode.hasFocus;

  @override
  void initState() {
    super.initState();
    selectedDateTime = widget.selectedDateTime;
    year = DateFormat('yyyy').format(selectedDateTime);
    month = DateFormat('MM').format(selectedDateTime);
    day = DateFormat('dd').format(selectedDateTime);

    yearController = TextEditingController(text: year);
    monthController = TextEditingController(text: month);
    dayController = TextEditingController(text: day);

    yearFocusNode.addListener(updateYearView);
    monthFocusNode.addListener(updateMonthView);
    dayFocusNode.addListener(updateDayView);
  }

  @override
  void dispose() {
    yearFocusNode.removeListener(updateYearView);
    monthFocusNode.removeListener(updateMonthView);
    dayFocusNode.removeListener(updateDayView);
    yearFocusNode.dispose();
    monthFocusNode.dispose();
    dayFocusNode.dispose();

    yearController.dispose();
    monthController.dispose();
    dayController.dispose();

    super.dispose();
  }

  @override
  void didUpdateWidget(covariant CalendarDesktopDateField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (selectedDateTime != widget.selectedDateTime) {
      selectedDateTime = widget.selectedDateTime;
      year = DateFormat('yyyy').format(selectedDateTime);
      month = DateFormat('MM').format(selectedDateTime);
      day = DateFormat('dd').format(selectedDateTime);

      yearController.text = year;
      monthController.text = month;
      dayController.text = day;
    }
  }

  void updateYearView() {
    if (yearFocusNode.hasFocus) {
      yearController.text = '';
      setState(() {});
    } else {
      if (year.isEmpty) {
        year = DateFormat('yyyy').format(DateTime.now());
      } else if (year.length == 1) {
        year = '${DateFormat('yyyy').format(DateTime.now()).substring(0, 3)}$year';
      } else if (year.length == 2) {
        year = '${DateFormat('yyyy').format(DateTime.now()).substring(0, 2)}$year';
      } else if (year.length == 3) {
        year = '${DateFormat('yyyy').format(DateTime.now()).substring(0, 1)}$year';
      }
      selectedDateTime = DateTime(int.parse(year), int.parse(month), int.parse(day), selectedDateTime.hour, selectedDateTime.minute);
      setState(() {});
      widget.onDateChanged(selectedDateTime);
    }
  }

  void updateMonthView() {
    if (monthFocusNode.hasFocus) {
      monthController.text = '';
      setState(() {});
    } else {
      if (month.isEmpty) {
        month = DateFormat('MM').format(DateTime.now());
      } else if (month.length == 1) {
        month = '0$month';
      }

      if (int.parse(month) > 12) month = '12';

      selectedDateTime = DateTime(int.parse(year), int.parse(month), int.parse(day), selectedDateTime.hour, selectedDateTime.minute);
      setState(() {});
      widget.onDateChanged(selectedDateTime);
    }
  }

  void updateDayView() {
    if (dayFocusNode.hasFocus) {
      dayController.text = '';
      setState(() {});
    } else {
      if (day.isEmpty) {
        day = DateFormat('dd').format(DateTime.now());
      } else if (day.length == 1) {
        day = '0$day';
      }

      if (int.parse(day) > DateTime(int.parse(year), int.parse(month)).daysInMonth) day = DateTime(int.parse(year), int.parse(month)).daysInMonth.toString();

      selectedDateTime = DateTime(int.parse(year), int.parse(month), int.parse(day), selectedDateTime.hour, selectedDateTime.minute);
      setState(() {});
      widget.onDateChanged(selectedDateTime);
    }
  }

  void updateWithArrow(bool increase) {
    if (yearFocusNode.hasFocus) {
      year = increase ? (int.parse(year) + 1).toString() : (int.parse(year) - 1).toString();
      setState(() {});
    } else if (monthFocusNode.hasFocus) {
      int monthNum = increase ? (int.parse(month) + 1) : (int.parse(month) - 1);
      if (monthNum < 1) {
        month = '12';
        year = (int.parse(year) - 1).toString();
      } else if (monthNum > 12) {
        month = '01';
        year = (int.parse(year) + 1).toString();
      } else {
        month = (100 + monthNum).toString().substring(1);
      }
      setState(() {});
    } else if (dayFocusNode.hasFocus) {
      updateDayWithTimeArrow(increase);
    }
  }

  void updateDayWithTimeArrow(bool increase) {
    int dayNum = increase ? (int.parse(day) + 1) : (int.parse(day) - 1);
    int monthDay = DateTime(int.parse(year), int.parse(month)).daysInMonth;
    int prevMonthDay = DateTime(int.parse(year), int.parse(month) - 1).daysInMonth;
    if (dayNum < 1) {
      day = prevMonthDay.toString();
      int monthNum = int.parse(month) - 1;
      if (monthNum < 1) {
        month = '12';
        year = (int.parse(year) - 1).toString();
      } else {
        month = (100 + monthNum).toString().substring(1);
      }
    } else if (dayNum > monthDay) {
      day = '01';
      int monthNum = int.parse(month) + 1;
      if (monthNum > 12) {
        month = '01';
        year = (int.parse(year) + 1).toString();
      } else {
        month = (100 + monthNum).toString().substring(1);
      }
    } else {
      day = (100 + dayNum).toString().substring(1);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final numberWidth = 7.5;
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            monthFocusNode.unfocus();
            dayFocusNode.unfocus();
            yearFocusNode.requestFocus();
          },
          child: Container(
            width: numberWidth * 4 + 1 * 4,
            height: 16,
            decoration: BoxDecoration(
              color: yearFocusNode.hasFocus ? context.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Stack(
              children: [
                Text(
                  year,
                  style: context.bodyLarge
                      ?.textColor(yearFocusNode.hasFocus
                          ? context.onPrimary
                          : widget.isAllDay
                              ? context.outlineVariant
                              : context.inverseSurface)
                      .appFont(context)
                      .copyWith(
                    fontFeatures: <FontFeature>[
                      FontFeature.tabularFigures(),
                    ],
                  ),
                ),
                IgnorePointer(
                  child: Opacity(
                    opacity: 0,
                    child: TextFormField(
                      focusNode: yearFocusNode,
                      controller: yearController,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      maxLength: 4,
                      onChanged: (value) {
                        year = value;
                        setState(() {});
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Text(
          '/',
          style: context.bodyLarge?.textColor(widget.isAllDay ? context.outlineVariant : context.inverseSurface).appFont(context).copyWith(
            fontFeatures: <FontFeature>[
              FontFeature.tabularFigures(),
            ],
          ),
        ),
        GestureDetector(
          onTap: () {
            yearFocusNode.unfocus();
            dayFocusNode.unfocus();
            monthFocusNode.requestFocus();
          },
          child: Container(
            width: numberWidth * 2 + 2,
            height: 16,
            decoration: BoxDecoration(
              color: monthFocusNode.hasFocus ? context.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Stack(
              children: [
                Text(
                  month,
                  style: context.bodyLarge
                      ?.textColor(monthFocusNode.hasFocus
                          ? context.onPrimary
                          : widget.isAllDay
                              ? context.outlineVariant
                              : context.inverseSurface)
                      .appFont(context)
                      .copyWith(
                    fontFeatures: <FontFeature>[
                      FontFeature.tabularFigures(),
                    ],
                  ),
                ),
                IgnorePointer(
                  child: Opacity(
                    opacity: 0,
                    child: TextFormField(
                      focusNode: monthFocusNode,
                      controller: monthController,
                      textInputAction: TextInputAction.none,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      maxLength: 2,
                      onChanged: (value) {
                        month = value;
                        setState(() {});
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Text(
          '/',
          style: context.bodyLarge?.textColor(widget.isAllDay ? context.outlineVariant : context.inverseSurface).appFont(context).copyWith(
            fontFeatures: <FontFeature>[
              FontFeature.tabularFigures(),
            ],
          ),
        ),
        GestureDetector(
          onTap: () {
            yearFocusNode.unfocus();
            monthFocusNode.unfocus();
            dayFocusNode.requestFocus();
          },
          child: Container(
            width: numberWidth * 2 + 2,
            height: 16,
            decoration: BoxDecoration(
              color: dayFocusNode.hasFocus ? context.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Stack(
              children: [
                Text(
                  day,
                  style: context.bodyLarge
                      ?.textColor(dayFocusNode.hasFocus
                          ? context.onPrimary
                          : widget.isAllDay
                              ? context.outlineVariant
                              : context.inverseSurface)
                      .appFont(context)
                      .copyWith(
                    fontFeatures: <FontFeature>[
                      FontFeature.tabularFigures(),
                    ],
                  ),
                ),
                IgnorePointer(
                  child: Opacity(
                    opacity: 0,
                    child: TextFormField(
                      focusNode: dayFocusNode,
                      controller: dayController,
                      textInputAction: TextInputAction.none,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      maxLength: 2,
                      onChanged: (value) {
                        day = value;
                        setState(() {});
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 2),
        Text(
          '(${DateFormat('E').format(selectedDateTime).toUpperCase()})',
          style: context.bodyLarge?.textColor(widget.isAllDay ? context.outlineVariant : context.inverseSurface).appFont(context),
        ),
      ],
    );
  }
}
