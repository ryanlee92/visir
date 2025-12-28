import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CalendarDesktopTimeField extends StatefulWidget {
  final DateTime selectedDateTime;
  final bool isAllDay;
  final void Function(DateTime dateTime) onDateChanged;

  const CalendarDesktopTimeField({super.key, required this.selectedDateTime, required this.isAllDay, required this.onDateChanged});

  @override
  State<CalendarDesktopTimeField> createState() => CalendarDesktopTimeFieldState();
}

class CalendarDesktopTimeFieldState extends State<CalendarDesktopTimeField> {
  late DateTime selectedDateTime;
  FocusNode hourFocusNode = FocusNode();
  FocusNode minuteFocusNode = FocusNode();

  late TextEditingController hourController;
  late TextEditingController minuteController;

  late String hour;
  late String minute;

  bool get isFocused => hourFocusNode.hasFocus || minuteFocusNode.hasFocus;

  @override
  void initState() {
    super.initState();
    selectedDateTime = widget.selectedDateTime;
    hour = DateFormat('HH').format(selectedDateTime);
    minute = DateFormat('mm').format(selectedDateTime);
    hourController = TextEditingController(text: hour);
    minuteController = TextEditingController(text: minute);

    hourFocusNode.addListener(updateHourView);
    minuteFocusNode.addListener(updateMinuteView);
  }

  @override
  void dispose() {
    hourFocusNode.removeListener(updateHourView);
    minuteFocusNode.removeListener(updateMinuteView);

    hourFocusNode.dispose();
    minuteFocusNode.dispose();

    hourController.dispose();
    minuteController.dispose();

    super.dispose();
  }

  @override
  void didUpdateWidget(covariant CalendarDesktopTimeField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (selectedDateTime != widget.selectedDateTime) {
      selectedDateTime = widget.selectedDateTime;
      hour = DateFormat('HH').format(selectedDateTime);
      minute = DateFormat('mm').format(selectedDateTime);
      hourController.text = hour;
      minuteController.text = minute;
    }
  }

  void updateHourView() {
    if (hourFocusNode.hasFocus) {
      hourController.text = '';
      setState(() {});
    } else {
      if (hour.isEmpty) {
        hour = '00';
      } else if (hour.length == 1) {
        hour = '0$hour';
      }

      if (int.parse(hour) >= 24) {
        hour = (int.parse(hour) % 24 + 100).toString().substring(1);
      }

      selectedDateTime = DateTime(selectedDateTime.year, selectedDateTime.month, selectedDateTime.day, int.parse(hour), int.parse(minute));
      setState(() {});
      widget.onDateChanged(selectedDateTime);
    }
  }

  void updateMinuteView() {
    if (minuteFocusNode.hasFocus) {
      minuteController.text = '';
      setState(() {});
    } else {
      if (minute.isEmpty) {
        minute = '00';
      } else if (minute.length == 1) {
        minute = '0$minute';
      }

      if (int.parse(minute) >= 60) {
        minute = (int.parse(minute) % 60 + 100).toString().substring(1);
      }

      selectedDateTime = DateTime(selectedDateTime.year, selectedDateTime.month, selectedDateTime.day, int.parse(hour), int.parse(minute));
      setState(() {});
      widget.onDateChanged(selectedDateTime);
    }
  }

  bool updateWithArrow(bool increase) {
    if (hourFocusNode.hasFocus) {
      int hourNum = increase ? (int.parse(hour) + 1) : (int.parse(hour) - 1);
      if (hourNum < 0) {
        hour = '23';
        setState(() {});
        return true;
      } else if (hourNum > 23) {
        hour = '00';
        setState(() {});
        return true;
      } else {
        hour = (100 + hourNum).toString().substring(1);
      }
    } else if (minuteFocusNode.hasFocus) {
      int minuteNum = increase ? (int.parse(minute) + 1) : (int.parse(minute) - 1);
      if (minuteNum < 0) {
        minute = '59';
        int hourNum = int.parse(hour) - 1;
        if (hourNum < 0) {
          hour = '23';
          setState(() {});
          return true;
        } else {
          hour = (100 + hourNum).toString().substring(1);
        }
      } else if (minuteNum > 59) {
        minute = '00';

        int hourNum = (int.parse(hour) + 1);
        if (hourNum > 23) {
          hour = '00';
          setState(() {});
          return true;
        } else {
          hour = (100 + hourNum).toString().substring(1);
        }
      } else {
        minute = (100 + minuteNum).toString().substring(1);
      }
    }
    setState(() {});
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final numberWidth = 7.5;
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            minuteFocusNode.unfocus();
            hourFocusNode.requestFocus();
          },
          child: Container(
            width: numberWidth * 2 + 2,
            height: 16,
            decoration: BoxDecoration(
              color: hourFocusNode.hasFocus ? context.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Stack(
              children: [
                Text(
                  hour,
                  style: context.bodyLarge?.textColor(hourFocusNode.hasFocus ? context.onPrimary : context.outlineVariant).appFont(context).copyWith(
                    fontFeatures: <FontFeature>[
                      FontFeature.tabularFigures(),
                    ],
                  ),
                ),
                IgnorePointer(
                  child: Opacity(
                    opacity: 0,
                    child: TextFormField(
                      focusNode: hourFocusNode,
                      controller: hourController,
                      textInputAction: TextInputAction.none,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      maxLength: 2,
                      onChanged: (value) {
                        hour = value;
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
          ':',
          style: context.bodyLarge?.textColor(context.outlineVariant).appFont(context).copyWith(
            fontFeatures: <FontFeature>[
              FontFeature.tabularFigures(),
            ],
          ),
        ),
        GestureDetector(
          onTap: () {
            hourFocusNode.unfocus();
            minuteFocusNode.requestFocus();
          },
          child: Container(
            width: numberWidth * 2 + 2,
            height: 16,
            decoration: BoxDecoration(
              color: minuteFocusNode.hasFocus ? context.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Stack(
              children: [
                Text(
                  minute,
                  style: context.bodyLarge?.textColor(minuteFocusNode.hasFocus ? context.onPrimary : context.outlineVariant).appFont(context).copyWith(
                    fontFeatures: <FontFeature>[
                      FontFeature.tabularFigures(),
                    ],
                  ),
                ),
                IgnorePointer(
                  child: Opacity(
                    opacity: 0,
                    child: TextFormField(
                      focusNode: minuteFocusNode,
                      controller: minuteController,
                      textInputAction: TextInputAction.none,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      maxLength: 2,
                      onChanged: (value) {
                        minute = value;
                        setState(() {});
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
