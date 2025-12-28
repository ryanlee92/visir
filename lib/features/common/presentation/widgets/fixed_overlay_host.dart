import 'package:Visir/features/common/presentation/screens/main_screen.dart';
import 'package:flutter/material.dart';

class FixedOverlayHost extends StatefulWidget {
  final Widget child;
  final String overlayKey;

  FixedOverlayHost({super.key, required this.child, required this.overlayKey}) {
    if (overlayKey == MainScreen.routeName) {
      FixedOverlayHost._overlayKey[overlayKey] = GlobalKey<OverlayState>();
    } else if (overlayKey != MainScreen.routeName) {
      FixedOverlayHost._overlayKey[overlayKey] = GlobalKey<OverlayState>();
    }
  }

  @override
  State<FixedOverlayHost> createState() => _FixedOverlayHostState();

  static Map<String, GlobalKey<OverlayState>> _overlayKey = {};
  static Map<String, Offset?> _stackOffset = {};
  static Map<String, Size?> _stackSize = {};

  static Map<String, Map<String, OverlayEntry>> _overlayEntries = {};

  static void insert(String overlayKey, String entryId, OverlayEntry entry) {
    // remove(overlayKey, entryId);
    if (_overlayEntries[overlayKey] == null) _overlayEntries[overlayKey] = {};
    _overlayKey[overlayKey]?.currentState?.insert(entry);
    _overlayEntries[overlayKey]?[entryId] = entry;
  }

  static void remove(String overlayKey, String entryId) {
    final entry = _overlayEntries[overlayKey]?[entryId];
    entry?.remove();
    entry?.dispose();
    _overlayEntries[overlayKey]?.remove(entryId);
  }

  static OverlayState? getOverlayKey(String overlayKey) => _overlayKey[overlayKey]?.currentState;

  static Offset? getStackOffset(String overlayKey) => _stackOffset[overlayKey];
  static Size? getStackSize(String overlayKey) => _stackSize[overlayKey];
}

class _FixedOverlayHostState extends State<FixedOverlayHost> {
  GlobalKey stackKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    if (FixedOverlayHost._overlayKey[widget.overlayKey] == null) {
      FixedOverlayHost._overlayKey[widget.overlayKey] = GlobalKey<OverlayState>();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      getStackOffset();
    });
  }

  @override
  void dispose() {
    super.dispose();
    FixedOverlayHost._stackOffset.remove(widget.overlayKey);
    FixedOverlayHost._stackSize.remove(widget.overlayKey);

    FixedOverlayHost._overlayEntries[widget.overlayKey]?.forEach((entryId, entry) {
      entry.remove();
      entry.dispose();
    });

    FixedOverlayHost._overlayEntries.remove(widget.overlayKey);
  }

  void getStackOffset() {
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return null;
    final offset = renderBox.localToGlobal(Offset.zero);
    FixedOverlayHost._stackOffset[widget.overlayKey] = offset;
    FixedOverlayHost._stackSize[widget.overlayKey] = renderBox.size;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.overlayKey == MainScreen.routeName) {
      return Stack(
        key: stackKey,
        children: [
          Positioned.fill(child: widget.child),
          Positioned.fill(child: Overlay(key: FixedOverlayHost._overlayKey[widget.overlayKey])),
        ],
      );
    }

    return Stack(
      key: stackKey,
      children: [
        widget.child,
        Overlay(key: FixedOverlayHost._overlayKey[widget.overlayKey]),
      ],
    );
  }
}
