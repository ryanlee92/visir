import 'package:Visir/app.dart';
import 'package:Visir/config/providers.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class KeyboardShortcut extends StatefulWidget {
  final String? debugKey;
  final bool Function(KeyEvent event)? onKeyUp;
  final bool Function(KeyEvent event)? onKeyDown;
  final bool Function(KeyEvent event)? onKeyRepeat;
  final Widget child;
  final TabType? targetTab;
  final bool? bypassTextField;
  final bool? bypassMailEditScreen;
  final void Function()? onPushOrPopNext;

  const KeyboardShortcut({
    this.onKeyUp,
    this.onKeyDown,
    this.onKeyRepeat,
    required this.child,
    this.targetTab,
    this.debugKey,
    this.bypassTextField,
    this.bypassMailEditScreen,
    this.onPushOrPopNext,
    super.key,
  });

  @override
  _KeyboardShortcutState createState() => _KeyboardShortcutState();
}

class _KeyboardShortcutState extends State<KeyboardShortcut> with RouteAware {
  bool _enableKeyboard = true;

  @override
  void initState() {
    super.initState();
    ServicesBinding.instance.keyboard.addHandler(onKey);
    keyboardResetNotifier.addListener(updateKeyboard);
    mailInputDraftEditKeyboardResetNotifier.addListener(didPopNext);
  }

  void updateKeyboard() {
    ServicesBinding.instance.keyboard.removeHandler(onKey);
    ServicesBinding.instance.keyboard.addHandler(onKey);
  }

  @override
  void dispose() {
    ServicesBinding.instance.keyboard.removeHandler(onKey);
    keyboardResetNotifier.removeListener(updateKeyboard);
    mailInputDraftEditKeyboardResetNotifier.removeListener(didPopNext);
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  bool onKey(KeyEvent event) {
    final key = event.logicalKey;
    if (!_enableKeyboard) return false;

    final logicalKeysPressed = ServicesBinding.instance.keyboard.logicalKeysPressed;

    if (FocusManager.instance.primaryFocus != Utils.mainFocus) {
      if (widget.bypassTextField != true &&
          (FocusManager.instance.primaryFocus?.hasFocus == true && FocusManager.instance.primaryFocus?.children.isNotEmpty != true) &&
          FocusManager.instance.primaryFocus?.onKeyEvent != null) {
        if (event is KeyDownEvent) {
          if (logicalKeysPressed.length == 1 && key == LogicalKeyboardKey.escape) {
            FocusManager.instance.primaryFocus?.unfocus();
          }
        }
        return false;
      }
    }

    if (widget.bypassMailEditScreen != true) {
      if (mailInputDraftEditListener.value != null) {
        return false;
      }
    }

    // if (PlatformX.getIsMobileView(context)) return false;

    if (widget.targetTab != null && tabNotifier.value != widget.targetTab!) return false;

    if (event is KeyDownEvent) {
      final result = widget.onKeyDown?.call(event) ?? false;
      if (result) return result;
    }

    if (event is KeyRepeatEvent) {
      final result = widget.onKeyRepeat?.call(event) ?? false;
      if (result) return result;
    }

    if (event is KeyUpEvent) {
      final result = widget.onKeyUp?.call(event) ?? false;
      if (result) return result;
    }

    return false;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (ModalRoute.of(context) == null) return;
    routeObserver.subscribe(this, ModalRoute.of(context) as ModalRoute<void>);
  }

  @override
  void didPopNext() {
    _enableKeyboard = true;
    widget.onPushOrPopNext?.call();
  }

  @override
  void didPush() {
    _enableKeyboard = true;
    widget.onPushOrPopNext?.call();
  }

  @override
  void didPop() {
    _enableKeyboard = false;
  }

  @override
  void didPushNext() {
    _enableKeyboard = false;
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
