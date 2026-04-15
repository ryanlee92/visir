import 'package:flutter/material.dart';

typedef PlaygroundEnumLabelBuilder<T extends Enum> = String Function(T value);

class PlaygroundEnumPicker<T extends Enum> extends StatelessWidget {
  const PlaygroundEnumPicker({
    super.key,
    required this.label,
    required this.values,
    required this.value,
    required this.onChanged,
    this.labelBuilder,
  });

  final String label;
  final List<T> values;
  final T value;
  final ValueChanged<T> onChanged;
  final PlaygroundEnumLabelBuilder<T>? labelBuilder;

  @override
  Widget build(BuildContext context) {
    String displayLabel(T option) {
      return labelBuilder?.call(option) ?? option.name;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: values.map((option) {
            return ChoiceChip(
              label: Text(displayLabel(option)),
              selected: option == value,
              onSelected: (_) => onChanged(option),
            );
          }).toList(),
        ),
      ],
    );
  }
}
