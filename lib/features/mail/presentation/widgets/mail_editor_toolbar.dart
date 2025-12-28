import 'package:Visir/dependency/html_editor/html_editor.dart';
import 'package:Visir/features/mail/domain/entities/mail_file_entity.dart';
import 'package:Visir/features/mail/domain/entities/mail_signature_entity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MailEditorToolbar extends ConsumerStatefulWidget {
  final HtmlEditorController controller;
  final List<MailSignatureEntity> signatures;
  final void Function(int signature) onChangeSignature;
  final void Function(List<MailFileEntity> files) onFileAdded;
  final GlobalKey<ToolbarWidgetState> toolbarWidgetKey;

  const MailEditorToolbar({
    Key? key,
    required this.controller,
    required this.onChangeSignature,
    required this.signatures,
    required this.onFileAdded,
    required this.toolbarWidgetKey,
  }) : super(key: key);

  @override
  _MailEditorToolbarState createState() => _MailEditorToolbarState();
}

class _MailEditorToolbarState extends ConsumerState<MailEditorToolbar> {
  @override
  Widget build(BuildContext context) {
    return ToolbarWidget(
      key: widget.toolbarWidgetKey,
      controller: widget.controller,
      htmlToolbarOptions: HtmlToolbarOptions(),
      callbacks: Callbacks(),
      signatures: widget.signatures,
      onChangeSignature: widget.onChangeSignature,
      onFileAdded: widget.onFileAdded,
    );
  }
}
