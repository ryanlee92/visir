import 'package:flutter/material.dart';

import '../omni_datetime_picker.dart';
import './variants/omni_datetime_picker_variants/omni_dtp_basic.dart';

class OmniDateTimePicker extends StatelessWidget {
  const OmniDateTimePicker(
      {super.key,
      this.separator,
      this.title,
      this.initialDate,
      this.firstDate,
      this.lastDate,
      this.isShowSeconds,
      this.is24HourMode,
      this.minutesInterval,
      this.secondsInterval,
      this.isForce2Digits,
      this.borderRadius,
      this.constraints,
      required this.type,
      required this.onDateChanged,
      this.backgroundColor,
      this.selectableDayPredicate});

  /// A widget that separates the [title] - if not null - and the calendar, also separates between date and time pickers
  final Widget? separator;
  final Widget? title;
  final DateTime? initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final bool? isShowSeconds;
  final bool? is24HourMode;
  final int? minutesInterval;
  final int? secondsInterval;
  final bool? isForce2Digits;
  final BorderRadiusGeometry? borderRadius;
  final BoxConstraints? constraints;
  final OmniDateTimePickerType type;
  final bool Function(DateTime)? selectableDayPredicate;
  final void Function(DateTime) onDateChanged;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      child: OmniDtpBasic(
        title: title,
        separator: separator,
        initialDate: initialDate,
        firstDate: firstDate,
        lastDate: lastDate,
        is24HourMode: is24HourMode,
        isShowSeconds: isShowSeconds,
        minutesInterval: minutesInterval,
        secondsInterval: secondsInterval,
        isForce2Digits: isForce2Digits,
        constraints: constraints,
        type: type,
        selectableDayPredicate: selectableDayPredicate,
        onDateChanged: (dateTime) {
          onDateChanged(dateTime);
          if (type == OmniDateTimePickerType.date) {
            Navigator.of(context).maybePop();
          }
        },
      ),
    );
  }
}
