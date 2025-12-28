import 'package:flutter/material.dart';

import '../../../omni_datetime_picker.dart';
import '../../components/calendar.dart';
import '../../components/time_picker_spinner.dart';

class OmniDtpBasic extends StatelessWidget {
  const OmniDtpBasic({
    super.key,
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
    this.constraints,
    this.type,
    this.selectableDayPredicate,
    required this.onDateChanged,
    this.backgroundColor,
  });

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
  final BoxConstraints? constraints;
  final OmniDateTimePickerType? type;
  final bool Function(DateTime)? selectableDayPredicate;
  final void Function(DateTime) onDateChanged;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);

    DateTime selectedDateTime = initialDate ?? DateTime.now();
    if (type == OmniDateTimePickerType.date) {
      return Calendar(
        initialDate: initialDate,
        firstDate: firstDate,
        lastDate: lastDate,
        onDateChanged: (value) {
          DateTime tempDateTime = DateTime(
            value.year,
            value.month,
            value.day,
            selectedDateTime.hour,
            selectedDateTime.minute,
            isShowSeconds ?? false ? selectedDateTime.second : 0,
          );

          selectedDateTime = tempDateTime;
          onDateChanged.call(tempDateTime);
        },
        selectableDayPredicate: selectableDayPredicate,
      );
    } else if (type == OmniDateTimePickerType.time) {
      return TimePickerSpinner(
        time: initialDate?.toLocal(),
        amText: localizations.anteMeridiemAbbreviation,
        pmText: localizations.postMeridiemAbbreviation,
        isShowSeconds: isShowSeconds ?? false,
        is24HourMode: is24HourMode ?? false,
        minutesInterval: minutesInterval ?? 1,
        secondsInterval: secondsInterval ?? 1,
        isForce2Digits: isForce2Digits ?? false,
        onTimeChange: (value) {
          DateTime tempDateTime = DateTime(
            selectedDateTime.year,
            selectedDateTime.month,
            selectedDateTime.day,
            value.hour,
            value.minute,
            isShowSeconds ?? false ? value.second : 0,
          );

          selectedDateTime = tempDateTime;
          onDateChanged.call(tempDateTime);
        },
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (title != null) title!,
        if (title != null && separator != null) separator!,
        if (type == OmniDateTimePickerType.dateAndTime || type == OmniDateTimePickerType.time)
          Calendar(
            initialDate: initialDate,
            firstDate: firstDate,
            lastDate: lastDate,
            onDateChanged: (value) {
              DateTime tempDateTime = DateTime(
                value.year,
                value.month,
                value.day,
                selectedDateTime.hour,
                selectedDateTime.minute,
                isShowSeconds ?? false ? selectedDateTime.second : 0,
              );

              selectedDateTime = tempDateTime;
              onDateChanged.call(tempDateTime);
            },
            selectableDayPredicate: selectableDayPredicate,
          ),
        if (type == OmniDateTimePickerType.dateAndTime && (separator != null)) separator!,
        if (type == OmniDateTimePickerType.dateAndTime || type == OmniDateTimePickerType.time)
          Container(
            width: 248,
            height: 156,
            child: TimePickerSpinner(
              time: initialDate?.toLocal(),
              amText: localizations.anteMeridiemAbbreviation,
              pmText: localizations.postMeridiemAbbreviation,
              isShowSeconds: isShowSeconds ?? false,
              is24HourMode: is24HourMode ?? false,
              minutesInterval: minutesInterval ?? 1,
              secondsInterval: secondsInterval ?? 1,
              isForce2Digits: isForce2Digits ?? false,
              onTimeChange: (value) {
                DateTime tempDateTime = DateTime(
                  selectedDateTime.year,
                  selectedDateTime.month,
                  selectedDateTime.day,
                  value.hour,
                  value.minute,
                  isShowSeconds ?? false ? value.second : 0,
                );

                selectedDateTime = tempDateTime;
                onDateChanged.call(tempDateTime);
              },
            ),
          ),
      ],
    );
  }
}
