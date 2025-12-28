import 'package:Visir/dependency/html_editor/html_editor.dart' hide HtmlEditorController;
import 'package:Visir/dependency/html_editor/src/html_editor_controller_mobile.dart';
import 'package:Visir/dependency/html_editor/src/widgets/html_editor_widget_mobile.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// HtmlEditor class for mobile
class HtmlEditor extends StatelessWidget {
  HtmlEditor({
    Key? key,
    required this.controller,
    this.callbacks,
    this.htmlEditorOptions = const HtmlEditorOptions(
      backgroundColor: Colors.white,
      defaultFontColor: Colors.black,
      placeholderColor: Colors.grey,
      defaultFontSize: 14,
      defaultLineHeight: 22,
    ),
    this.htmlToolbarOptions = const HtmlToolbarOptions(),
    this.otherOptions = const OtherOptions(),
    this.onScrollInsideIframe = null,
    this.plugins = const [],
  }) : super(key: key);

  /// The controller that is passed to the widget, which allows multiple [HtmlEditor]
  /// widgets to be used on the same page independently.
  final HtmlEditorController controller;

  /// Sets & activates Summernote's callbacks. See the functions available in
  /// [Callbacks] for more details.
  final Callbacks? callbacks;

  /// Defines options for the html editor
  final HtmlEditorOptions htmlEditorOptions;

  /// Defines options for the editor toolbar
  final HtmlToolbarOptions htmlToolbarOptions;

  /// Defines other options
  final OtherOptions otherOptions;

  /// Sets the list of Summernote plugins enabled in the editor.
  final List<Plugins> plugins;

  final void Function(double dx, double dy)? onScrollInsideIframe;

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) {
      return HtmlEditorWidget(
        controller: controller,
        callbacks: callbacks,
        plugins: plugins,
        htmlEditorOptions: htmlEditorOptions,
        htmlToolbarOptions: htmlToolbarOptions,
        otherOptions: otherOptions,
      );
    } else {
      return Text('Flutter Web environment detected, please make sure you are importing package:html_editor_enhanced/html_editor.dart');
    }
  }
}
