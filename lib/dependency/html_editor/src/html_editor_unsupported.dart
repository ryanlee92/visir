import 'package:Visir/dependency/html_editor/html_editor.dart';
import 'package:flutter/material.dart';

/// Fallback HtmlEditor class (should never be called)
class HtmlEditor extends StatelessWidget {
  HtmlEditor({
    Key? key,
    required this.controller,
    this.callbacks,
    this.htmlEditorOptions = const HtmlEditorOptions(
        backgroundColor: Colors.white, defaultFontColor: Colors.black, placeholderColor: Colors.grey, defaultFontSize: 14, defaultLineHeight: 22),
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
    return Text('Unsupported in this environment');
  }
}
