import 'package:Visir/features/common/presentation/widgets/visir_button.dart';
import 'package:flutter/material.dart';

import '../../localizations/text_delegate.dart';
import '../rrule_generator_config.dart';

class WeekdayPicker extends StatelessWidget {
  const WeekdayPicker(
    this.weekdayNotifiers,
    this.textDelegate,
    this.onChange, {
    super.key,
    required this.config,
  });

  final RRuleTextDelegate textDelegate;
  final Function onChange;

  final RRuleGeneratorConfig config;

  final List<ValueNotifier<bool>> weekdayNotifiers;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Row(
          children: List.generate(
            7,
            (index) => ValueListenableBuilder(
              valueListenable: weekdayNotifiers[index],
              builder: (context, value, child) => Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: VisirButton(
                      type: VisirButtonAnimationType.scaleAndOpacity,
                      style: VisirButtonStyle(
                        alignment: Alignment.center,
                        height: kMinInteractiveDimension,
                        backgroundColor: value ? config.weekdaySelectedBackgroundColor : config.weekdayBackgroundColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Container(
                        child: Text(
                          textDelegate.weekdays[index].substring(0, 3),
                          style: config.textStyle.copyWith(color: value ? config.weekdaySelectedColor : config.weekdayColor),
                        ),
                      ),
                      onTap: () {
                        weekdayNotifiers[index].value = !value;
                        onChange();
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}
