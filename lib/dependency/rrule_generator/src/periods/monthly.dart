import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:ficonsax/ficonsax.dart';
import 'package:flutter/material.dart';

import '../../localizations/text_delegate.dart';
import '../pickers/helpers.dart';
import '../pickers/interval.dart';
import '../rrule_generator_config.dart';
import './period.dart';

class Monthly extends StatelessWidget implements Period {
  @override
  final RRuleGeneratorConfig config;
  @override
  final RRuleTextDelegate textDelegate;
  @override
  final void Function() onChange;
  @override
  final String initialRRule;
  @override
  final DateTime initialDate;

  final monthTypeNotifier = ValueNotifier(0);
  final monthDayNotifier = ValueNotifier(1);
  final weekdayNotifier = ValueNotifier(0);
  final dayNotifier = ValueNotifier(1);
  final intervalController = TextEditingController(text: '1');

  Monthly(this.config, this.textDelegate, this.onChange, this.initialRRule, this.initialDate, {super.key}) {
    if (initialRRule.contains('MONTHLY')) {
      handleInitialRRule();
    } else {
      dayNotifier.value = initialDate.day;
      weekdayNotifier.value = initialDate.weekday - 1;
    }
  }

  @override
  void handleInitialRRule() {
    if (initialRRule.contains('BYMONTHDAY')) {
      monthTypeNotifier.value = 1;
      int dayIndex = initialRRule.indexOf('BYMONTHDAY=') + 11;
      String day = initialRRule.substring(dayIndex, dayIndex + (initialRRule.length > dayIndex + 1 ? 2 : 1));
      if (day.length == 1 || day[1] != ';') {
        dayNotifier.value = int.parse(day);
      } else {
        dayNotifier.value = int.parse(day[0]);
      }

      if (initialRRule.contains('INTERVAL=')) {
        final intervalIndex = initialRRule.indexOf('INTERVAL=') + 9;
        int intervalEnd = initialRRule.indexOf(';', intervalIndex);
        intervalEnd = intervalEnd == -1 ? initialRRule.length : intervalEnd;
        String interval = initialRRule.substring(intervalIndex, intervalEnd == -1 ? initialRRule.length : intervalEnd);
        intervalController.text = interval;
      }
    } else {
      monthTypeNotifier.value = 0;

      if (initialRRule.contains('BYSETPOS=')) {
        int monthDayIndex = initialRRule.indexOf('BYSETPOS=') + 9;
        String monthDay = initialRRule.substring(monthDayIndex, monthDayIndex + 1);

        if (monthDay == '-') {
          monthDayNotifier.value = 4;
        } else {
          monthDayNotifier.value = int.parse(monthDay) - 1;
        }
      }

      if (initialRRule.contains('BYDAY=')) {
        int weekdayIndex = initialRRule.indexOf('BYDAY=') + 6;
        String weekday = initialRRule.substring(weekdayIndex, weekdayIndex + 2);
        weekdayNotifier.value = weekdaysShort.indexOf(weekday);
      }
    }
  }

  @override
  String getRRule() {
    if (monthTypeNotifier.value == 1) {
      final byMonthDay = dayNotifier.value;
      final interval = int.tryParse(intervalController.text) ?? 0;
      return 'FREQ=MONTHLY;BYMONTHDAY=$byMonthDay;INTERVAL=${interval > 0 ? interval : 1}';
    } else {
      final byDay = weekdaysShort[weekdayNotifier.value];
      final bySetPos = (monthDayNotifier.value < 4) ? monthDayNotifier.value + 1 : -1;
      final interval = int.tryParse(intervalController.text) ?? 0;
      return 'FREQ=MONTHLY;INTERVAL=${interval > 0 ? interval : 1};'
          'BYDAY=$byDay;BYSETPOS=$bySetPos';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        buildElement(
          title: textDelegate.every,
          style: config.textStyle,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 0),
            child: Row(
              children: [
                Expanded(
                    child: IntervalPicker(
                  intervalController,
                  onChange,
                  config: config,
                )),
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Text(
                    textDelegate.months,
                    style: config.textStyle,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 20),
        ValueListenableBuilder(
          valueListenable: monthTypeNotifier,
          builder: (context, monthType, child) => Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8, right: 8),
                      child: Text(
                        textDelegate.byDayInMonth,
                        style: config.textStyle,
                      ),
                    ),
                  ),
                  Switch(
                    value: monthType == 0,
                    activeColor: context.onPrimary,
                    activeTrackColor: context.primary,
                    inactiveTrackColor: context.primary,
                    inactiveThumbColor: context.onPrimary,
                    trackOutlineWidth: WidgetStateProperty.all(0),
                    trackOutlineColor: WidgetStateProperty.all(context.primary),
                    thumbIcon: WidgetStateProperty.all(Icon(Icons.add, size: 16, color: Colors.transparent)),
                    onChanged: (selected) {
                      monthTypeNotifier.value = selected ? 0 : 1;
                      onChange();
                    },
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8, right: 8),
                      child: Text(
                        textDelegate.byNthDayInMonth,
                        style: config.textStyle,
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 6),
              if (monthType == 1)
                buildDropdown(
                  context: context,
                  child: ValueListenableBuilder(
                    valueListenable: dayNotifier,
                    builder: (context, day, _) => DropdownButton(
                      icon: Icon(IconsaxOutline.arrow_down_1),
                      iconSize: 16,
                      dropdownColor: context.surfaceVariant,
                      enableFeedback: true,
                      borderRadius: BorderRadius.circular(20),
                      isExpanded: true,
                      focusColor: Colors.transparent,
                      elevation: 0,
                      value: day,
                      onChanged: (newDay) {
                        dayNotifier.value = newDay!;
                        onChange();
                      },
                      items: List.generate(
                        31,
                        (index) => DropdownMenuItem(
                          value: index + 1,
                          child: Text(
                            '${index + 1}.',
                            style: config.textStyle,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              if (monthType == 0)
                Column(
                  children: [
                    ValueListenableBuilder(
                      valueListenable: monthDayNotifier,
                      builder: (context, dayInMonth, _) => Row(
                        children: [
                          Expanded(
                            child: buildDropdown(
                              context: context,
                              child: DropdownButton(
                                icon: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                  child: Icon(IconsaxOutline.arrow_down_1),
                                ),
                                iconSize: 16,
                                dropdownColor: context.surfaceVariant,
                                enableFeedback: true,
                                borderRadius: BorderRadius.circular(20),
                                isExpanded: true,
                                focusColor: Colors.transparent,
                                elevation: 0,
                                value: dayInMonth,
                                onChanged: (dayInMonth) {
                                  monthDayNotifier.value = dayInMonth!;
                                  onChange();
                                },
                                items: List.generate(
                                  5,
                                  (index) => DropdownMenuItem(
                                    value: index,
                                    child: Text(
                                      textDelegate.daysInMonth[index],
                                      style: config.textStyle,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: buildDropdown(
                              context: context,
                              child: ValueListenableBuilder(
                                valueListenable: weekdayNotifier,
                                builder: (context, weekday, _) => DropdownButton(
                                  icon: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                    child: Icon(IconsaxOutline.arrow_down_1),
                                  ),
                                  iconSize: 16,
                                  dropdownColor: context.surfaceVariant,
                                  enableFeedback: true,
                                  borderRadius: BorderRadius.circular(20),
                                  isExpanded: true,
                                  focusColor: Colors.transparent,
                                  elevation: 0,
                                  value: weekday,
                                  onChanged: (newWeekday) {
                                    weekdayNotifier.value = newWeekday!;
                                    onChange();
                                  },
                                  items: List.generate(
                                    7,
                                    (index) => DropdownMenuItem(
                                      value: index,
                                      child: Text(
                                        textDelegate.weekdays[index].toString(),
                                        style: config.textStyle,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              SizedBox(height: 20),
            ],
          ),
        )
      ],
    );
  }
}
