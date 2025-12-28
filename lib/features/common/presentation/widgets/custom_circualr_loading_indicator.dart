import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:flutter/material.dart';

class CustomCircularLoadingIndicator extends StatefulWidget {
  final double size;
  final Color? color;

  CustomCircularLoadingIndicator({Key? key, required this.size, this.color}) : super(key: key);

  @override
  State<CustomCircularLoadingIndicator> createState() => _CustomCircularLoadingIndicatorState();
}

class _CustomCircularLoadingIndicatorState extends State<CustomCircularLoadingIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 1000), vsync: this)..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: CircularProgressIndicator(color: widget.color ?? context.onPrimary, strokeWidth: widget.size / 10),
    );
  }
}
