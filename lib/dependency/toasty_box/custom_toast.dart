import 'package:flutter/material.dart';

class CustomToast extends StatefulWidget {
  final String? message;
  final TextStyle? messageStyle;
  final Widget? child;
  final Widget? leading;
  final Color? backgroundColor;
  final Color? shadowColor;
  final AnimationController? controller;
  final bool isInFront;
  final VoidCallback onTap;
  final VoidCallback? onClose;
  final Curve? curve;
  final double? width;
  final bool? isClosable;

  const CustomToast({
    super.key,
    this.isInFront = false,
    required this.onTap,
    this.onClose,
    this.message,
    this.messageStyle,
    this.leading,
    this.width,
    this.child,
    this.isClosable,
    this.backgroundColor,
    this.shadowColor,
    required this.controller,
    this.curve,
  }) : assert((message != null || message != '') || child != null);

  @override
  State<CustomToast> createState() => _CustomToastState();
}

class _CustomToastState extends State<CustomToast> {
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller!,
      builder: (context, _) {
        return Material(
          color: Colors.transparent,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 0.0),
              end: const Offset(0.0, 0.0),
            ).animate(CurvedAnimation(parent: widget.controller!, curve: widget.curve ?? Curves.easeInOut, reverseCurve: widget.curve ?? Curves.easeInOut)),
            child: Align(
              alignment: Alignment.bottomRight,
              child: GestureDetector(
                onTap: widget.onTap,
                child: (widget.child != null)
                    ? widget.child
                    : Row(
                        children: [
                          if (widget.leading != null) ...[widget.leading!, const SizedBox(width: 10)],
                          if (widget.message != null) Expanded(child: Text(widget.message!, style: widget.messageStyle)),
                        ],
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}
