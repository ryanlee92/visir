import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../rrule_generator_config.dart';

class IntervalPicker extends StatefulWidget {
  const IntervalPicker(
    this.controller,
    this.onChange, {
    super.key,
    required this.config,
  });

  final RRuleGeneratorConfig config;

  final void Function() onChange;
  final TextEditingController controller;

  @override
  State<IntervalPicker> createState() => _IntervalPickerState();
}

class _IntervalPickerState extends State<IntervalPicker> {
  @override
  Widget build(BuildContext context) => Container(
        height: kMinInteractiveDimension,
        alignment: Alignment.centerLeft,
        child: TextFormField(
          controller: widget.controller,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          onFieldSubmitted: (_) {
            final currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
          },
          onChanged: (text) => widget.onChange(),
          onEditingComplete: widget.onChange,
        ),
      );
}
