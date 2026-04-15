import 'package:flutter/material.dart';

class PlaygroundTextField extends StatefulWidget {
  const PlaygroundTextField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.hintText,
  });

  final String label;
  final String value;
  final ValueChanged<String> onChanged;
  final String? hintText;

  @override
  State<PlaygroundTextField> createState() => _PlaygroundTextFieldState();
}

class _PlaygroundTextFieldState extends State<PlaygroundTextField> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.value,
  );

  @override
  void didUpdateWidget(covariant PlaygroundTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value && _controller.text != widget.value) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        TextField(
          controller: _controller,
          onChanged: widget.onChanged,
          decoration: InputDecoration(
            hintText: widget.hintText,
            border: const OutlineInputBorder(),
            isDense: true,
          ),
        ),
      ],
    );
  }
}
