/*
 * Copyright (c) 2021 Simform Solutions
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

import 'package:Visir/features/common/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'showcase_widget.dart';

typedef OverlayBuilderCallback = Widget Function(BuildContext, Rect anchorBounds, Offset anchor);

/// Displays an overlay Widget anchored directly above the center of this
/// [AnchoredOverlay].
///
/// The overlay Widget is created by invoking the provided [overlayBuilder].
///
/// The [anchor] position is provided to the [overlayBuilder], but the builder
/// does not have to respect it. In other words, the [overlayBuilder] can
/// interpret the meaning of "anchor" however it wants - the overlay will not
/// be forced to be centered about the [anchor].
///
/// The overlay built by this [AnchoredOverlay] can be conditionally shown
/// and hidden by settings the [showOverlay] property to true or false.
///
/// The [overlayBuilder] is invoked every time this Widget is rebuilt.
///
class AnchoredOverlay extends ConsumerWidget {
  final bool showOverlay;
  final OverlayBuilderCallback? overlayBuilder;
  final Widget? child;
  final OverlayState? targetState;
  final Offset? stackOffset;
  final bool? forTutorial;

  AnchoredOverlay({super.key, this.showOverlay = false, this.overlayBuilder, this.child, this.targetState, this.stackOffset, this.forTutorial});

  final GlobalKey overlayKey = GlobalKey();

  final LayerLink _overlayLink = LayerLink();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ratio = ref.watch(zoomRatioProvider);

    return OverlayBuilder(
      key: overlayKey,
      showOverlay: showOverlay,
      targetState: targetState,
      overlayBuilder: (overlayContext) {
        final element = context as Element;
        if (!element.mounted) {
          return const SizedBox.shrink();
        }
        final ro = element.renderObject;
        if (ro is! RenderBox || !ro.attached) {
          return const SizedBox.shrink();
        }
        final box = ro;
        final size = box.size;
        final origin = box.localToGlobal(const Offset(0.0, 0.0));

        Rect anchorBounds;
        anchorBounds = Rect.fromLTWH(origin.dx, origin.dy, size.width, size.height);
        final anchorCenter = origin + Offset(size.width / 2, size.height / 2);

        return Positioned(
          top: forTutorial == true ? 0 : (origin.dy / ratio - (stackOffset?.dy ?? 0)),
          left: forTutorial == true ? 0 : (origin.dx / ratio - (stackOffset?.dx ?? 0)),
          width: forTutorial == true ? null : size.width,
          height: forTutorial == true ? null : size.height,
          right: forTutorial == true ? 0 : null,
          bottom: forTutorial == true ? 0 : null,
          child: forTutorial == true
              ? overlayBuilder!(overlayContext, anchorBounds, anchorCenter)
              : CompositedTransformFollower(link: _overlayLink, child: overlayBuilder!(overlayContext, anchorBounds, anchorCenter)),
        );
      },
      child: forTutorial == true ? child : CompositedTransformTarget(link: _overlayLink, child: child),
    );
  }
}

/// Displays an overlay Widget as constructed by the given [overlayBuilder].
///
/// The overlay built by the [overlayBuilder] can be conditionally shown and
/// hidden by settings the [showOverlay] property to true or false.
///
/// The [overlayBuilder] is invoked every time this Widget is rebuilt.
///
/// Implementation note: the reason we rebuild the overlay every time our state
/// changes is because there doesn't seem to be any better way to invalidate the
/// overlay itself than to invalidate this Widget. Remember, overlay Widgets
/// exist in [OverlayEntry]s which are inaccessible to outside Widgets. But if
/// a better approach is found then feel free to use it.
class OverlayBuilder extends StatefulWidget {
  final bool showOverlay;
  final WidgetBuilder? overlayBuilder;
  final Widget? child;
  final OverlayState? targetState;

  const OverlayBuilder({super.key, this.showOverlay = false, this.overlayBuilder, this.child, this.targetState});

  @override
  State<OverlayBuilder> createState() => _OverlayBuilderState();
}

class _OverlayBuilderState extends State<OverlayBuilder> {
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();

    if (widget.showOverlay) {
      WidgetsBinding.instance.addPostFrameCallback((_) => showOverlay());
    }
  }

  @override
  void didUpdateWidget(OverlayBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) => syncWidgetAndOverlay());
  }

  @override
  void reassemble() {
    super.reassemble();
    WidgetsBinding.instance.addPostFrameCallback((_) => syncWidgetAndOverlay());
  }

  @override
  void dispose() {
    if (isShowingOverlay()) {
      hideOverlay();
    }

    super.dispose();
  }

  bool isShowingOverlay() => _overlayEntry != null;

  void showOverlay() {
    if (_overlayEntry == null) {
      // Create the overlay.
      _overlayEntry = OverlayEntry(builder: (context) => widget.overlayBuilder!(context));
      addToOverlay(_overlayEntry!, targetState: widget.targetState);
    } else {
      // Rebuild overlay.
      buildOverlay();
    }
  }

  void addToOverlay(OverlayEntry overlayEntry, {OverlayState? targetState}) async {
    if (mounted) {
      if (targetState != null) {
        targetState.insert(overlayEntry);
      } else {
        final showCaseContext = ShowCaseWidget.of(context).context;
        if (Overlay.maybeOf(showCaseContext) != null) {
          Overlay.of(showCaseContext).insert(overlayEntry);
        } else if (Overlay.maybeOf(context) != null) {
          Overlay.of(context).insert(overlayEntry);
        }
      }
    }
  }

  void hideOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
  }

  void syncWidgetAndOverlay() {
    if (isShowingOverlay() && !widget.showOverlay) {
      hideOverlay();
    } else if (!isShowingOverlay() && widget.showOverlay) {
      showOverlay();
    }
  }

  void buildOverlay() async {
    WidgetsBinding.instance.addPostFrameCallback((_) => _overlayEntry?.markNeedsBuild());
  }

  @override
  Widget build(BuildContext context) {
    buildOverlay();

    return widget.child!;
  }
}
