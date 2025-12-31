import 'package:Visir/features/common/presentation/utils/extensions/platform_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/common/presentation/widgets/popup_menu.dart';
import 'package:Visir/features/common/presentation/widgets/popup_menu_container.dart';
import 'package:Visir/features/common/presentation/widgets/popup_menu_theme.dart';
import 'package:Visir/features/common/presentation/widgets/visir_button.dart';
import 'package:Visir/features/common/presentation/widgets/visir_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CustomActionPromptAddWidget extends ConsumerStatefulWidget {
  final String? title;
  final String? prompt;
  final int? index;
  final Function(String title, String prompt)? onSave;
  
  const CustomActionPromptAddWidget({
    Key? key,
    this.title,
    this.prompt,
    this.index,
    this.onSave,
  }) : super(key: key);

  @override
  _CustomActionPromptAddWidgetState createState() => _CustomActionPromptAddWidgetState();
}

class _CustomActionPromptAddWidgetState extends ConsumerState<CustomActionPromptAddWidget> {
  String? title;
  String? prompt;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _promptController = TextEditingController();

  @override
  void initState() {
    super.initState();
    title = widget.title;
    prompt = widget.prompt;
    if (widget.title != null) {
      _titleController.text = widget.title!;
    }
    if (widget.prompt != null) {
      _promptController.text = widget.prompt!;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _promptController.dispose();
    super.dispose();
  }

  void save() {
    final titleText = _titleController.text.trim();
    final promptText = _promptController.text.trim();
    
    if (titleText.isEmpty && promptText.isEmpty) return;

    widget.onSave?.call(titleText, promptText);
    Navigator.of(Utils.mainContext).maybePop();
  }

  void delete() {
    if (widget.index != null && widget.onSave != null) {
      widget.onSave?.call('', '');
    }
    Navigator.of(Utils.mainContext).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: context.theme.popupTheme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Container(
              height: 28,
              padding: EdgeInsets.symmetric(horizontal: 3, vertical: 2),
              decoration: BoxDecoration(
                color: context.surface,
                borderRadius: BorderRadius.circular(6),
                boxShadow: PopupMenu.popupShadow,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.index != null)
                    VisirButton(
                      type: VisirButtonAnimationType.scaleAndOpacity,
                      style: VisirButtonStyle(
                        width: 24,
                        height: 24,
                        borderRadius: BorderRadius.circular(4),
                        margin: EdgeInsets.only(right: 4),
                      ),
                      options: VisirButtonOptions(
                        bypassTextField: true,
                        shortcuts: [
                          VisirButtonKeyboardShortcut(
                            message: context.tr.task_action_delete,
                            keys: [
                              LogicalKeyboardKey.backspace,
                              if (PlatformX.isApple) LogicalKeyboardKey.meta,
                              if (!PlatformX.isApple) LogicalKeyboardKey.control,
                            ],
                            subkeys: [
                              [
                                LogicalKeyboardKey.delete,
                                if (PlatformX.isApple) LogicalKeyboardKey.meta,
                                if (!PlatformX.isApple) LogicalKeyboardKey.control,
                              ],
                            ],
                          ),
                        ],
                      ),
                      onTap: delete,
                      child: VisirIcon(
                        type: VisirIconType.trash,
                        color: context.onInverseSurface,
                        size: 14,
                      ),
                    ),
                  VisirButton(
                    enabled: _titleController.text.trim().isNotEmpty || _promptController.text.trim().isNotEmpty,
                    type: VisirButtonAnimationType.scaleAndOpacity,
                    style: VisirButtonStyle(
                      width: 24,
                      height: 24,
                      borderRadius: BorderRadius.circular(4),
                      margin: EdgeInsets.only(right: 4),
                    ),
                    options: VisirButtonOptions(
                      bypassTextField: true,
                      shortcuts: [
                        VisirButtonKeyboardShortcut(
                          message: context.tr.confirm,
                          keys: [LogicalKeyboardKey.enter],
                        ),
                      ],
                    ),
                    onTap: save,
                    child: VisirIcon(
                      type: VisirIconType.check,
                      color: context.onInverseSurface,
                      size: 14,
                    ),
                  ),
                  VisirButton(
                    type: VisirButtonAnimationType.scaleAndOpacity,
                    style: VisirButtonStyle(
                      width: 24,
                      height: 24,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    options: VisirButtonOptions(
                      bypassTextField: true,
                      shortcuts: [
                        VisirButtonKeyboardShortcut(
                          message: context.tr.cancel,
                          keys: [LogicalKeyboardKey.escape],
                        ),
                      ],
                    ),
                    onTap: Navigator.of(Utils.mainContext).maybePop,
                    child: VisirIcon(
                      type: VisirIconType.close,
                      color: context.onInverseSurface,
                      size: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: PopupMenu.popupShadow,
              color: context.surface,
            ),
            child: PopupMenuContainer(
              horizontalPadding: 0,
              backgroundColor: context.surface,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
                    child: TextFormField(
                      controller: _titleController,
                      textInputAction: TextInputAction.next,
                      autofocus: true,
                      minLines: 1,
                      style: context.titleSmall?.textColor(context.outlineVariant),
                      decoration: InputDecoration(
                        constraints: BoxConstraints(minHeight: 20),
                        hintText: '제목',
                        hintStyle: context.titleSmall?.textColor(context.surfaceTint),
                        filled: false,
                        contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 4),
                        hoverColor: Colors.transparent,
                        isDense: true,
                      ),
                      onChanged: (text) {
                        setState(() {});
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 16, right: 16, top: 14, bottom: 16),
                    child: TextFormField(
                      controller: _promptController,
                      textInputAction: TextInputAction.none,
                      style: (context.titleSmall)?.copyWith(color: context.outlineVariant),
                      maxLines: null,
                      minLines: 3,
                      decoration: InputDecoration(
                        hintText: '프롬프트',
                        contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 3),
                        fillColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        filled: false,
                        isDense: true,
                        hintStyle: context.titleSmall?.copyWith(color: context.surfaceTint),
                      ),
                      onChanged: (text) {
                        setState(() {});
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

