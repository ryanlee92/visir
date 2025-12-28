import 'package:flutter/material.dart';
import 'package:flutterlifecyclehooks/flutterlifecyclehooks.dart';

class FGBGDetector extends StatefulWidget {
  final Widget child;
  final void Function(bool foreground, bool isFirst) onChanged;

  const FGBGDetector({super.key, required this.child, required this.onChanged});

  @override
  State<FGBGDetector> createState() => _FGBGDetectorState();
}

class _FGBGDetectorState extends State<FGBGDetector> with LifecycleMixin {
  bool isForeground = false;

  @override
  void initState() {
    isForeground = true;
    widget.onChanged(isForeground, true);
    super.initState();
  }

  @override
  void dispose() {
    widget.onChanged(false, false);
    super.dispose();
  }

  @override
  void onAppLifecycleChange(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (isForeground) return;
      isForeground = true;
      widget.onChanged(isForeground, false);
    } else {
      if (!isForeground) return;
      isForeground = false;
      widget.onChanged(isForeground, false);
    }
  }

  @override
  void onAppResume() {
    if (isForeground) return;
    isForeground = true;
    widget.onChanged(isForeground, false);
  }

  @override
  void onAppPause() {
    if (!isForeground) return;
    isForeground = false;
    widget.onChanged(isForeground, false);
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
