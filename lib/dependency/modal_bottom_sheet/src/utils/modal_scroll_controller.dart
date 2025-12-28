import 'package:Visir/dependency/sync_scroll_controller.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Associates a [ScrollController] with a subtree.
///
/// This mechanism can be used to provide default behavior for scroll views in a
/// subtree inside a modal bottom sheet.
///
/// We want to remove this and use [PrimaryScrollController].
/// This issue should be solved first https://github.com/flutter/flutter/issues/64236
///
/// See [PrimaryScrollController]
class ModalScrollController extends InheritedWidget {
  /// Creates a widget that associates a [ScrollController] with a subtree.
  ModalScrollController({super.key, required this.controller, required this.scrollControllerSyncGroup, required Widget child})
    : super(
        child: PrimaryScrollController(controller: controller, child: child),
      );

  /// The [ScrollController] associated with the subtree.
  ///
  /// See also:
  ///
  ///  * [ScrollView.controller], which discusses the purpose of specifying a
  ///    scroll controller.
  final ScrollController controller;
  final SyncScrollControllerGroup scrollControllerSyncGroup;

  /// Returns the [ScrollController] most closely associated with the given
  /// context.
  ///
  /// Returns null if there is no [ScrollController] associated with the given
  /// context.
  static ScrollController? of(BuildContext context) {
    final result = context.dependOnInheritedWidgetOfExactType<ModalScrollController>();
    return result?.controller;
  }

  static SyncScrollControllerGroup? ofSyncGroup(BuildContext context) {
    final result = context.dependOnInheritedWidgetOfExactType<ModalScrollController>();
    return result?.scrollControllerSyncGroup;
  }

  @override
  bool updateShouldNotify(ModalScrollController oldWidget) => controller != oldWidget.controller;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<ScrollController>('controller', controller, ifNull: 'no controller', showName: false));
  }
}
