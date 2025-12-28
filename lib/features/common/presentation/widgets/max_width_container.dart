import 'package:Visir/config/app_layout.dart';
import 'package:flutter/material.dart';

class MaxWidthContainer extends StatefulWidget {
  final Widget child;
  final EdgeInsets? padding;

  const MaxWidthContainer({Key? key, required this.child, this.padding}) : super(key: key);

  @override
  State<MaxWidthContainer> createState() => _MaxWidthContainerState();
}

class _MaxWidthContainerState extends State<MaxWidthContainer> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topCenter,
      padding: widget.padding,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: AppLayout.tabletBreakdownWidth),
        child: widget.child,
      ),
    );
  }
}
