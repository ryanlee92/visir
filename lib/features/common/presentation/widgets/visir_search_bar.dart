import 'package:Visir/features/common/presentation/utils/extensions/platform_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/widgets/custom_circualr_loading_indicator.dart';
import 'package:Visir/features/common/presentation/widgets/desktop_scaffold.dart';
import 'package:Visir/features/common/presentation/widgets/visir_button.dart';
import 'package:Visir/features/common/presentation/widgets/visir_icon.dart';
import 'package:flutter/material.dart';

class VisirSearchBar extends StatefulWidget {
  final String? initialValue;
  final String hintText;
  final Future<void> Function(String) onSubmitted;
  final Function(String)? onChanged;
  final VoidCallback onClose;

  final FocusNode? focusNode;
  final Widget? leading;
  final EdgeInsetsGeometry? padding;
  final bool? autoFocus;
  final bool? isDismissible;
  final TextEditingController? textEditingController;
  final bool? alwaysOn;

  const VisirSearchBar({
    super.key,
    this.initialValue,
    required this.hintText,
    required this.onSubmitted,
    required this.onClose,
    this.focusNode,
    this.leading,
    this.alwaysOn,
    this.onChanged,
    this.padding,
    this.autoFocus,
    this.textEditingController,
    this.isDismissible,
  });

  @override
  State<VisirSearchBar> createState() => _VisirSearchBarState();
}

class _VisirSearchBarState extends State<VisirSearchBar> {
  bool get showMobileUI => PlatformX.isMobileView;
  bool get isDarkMode => context.isDarkMode;
  bool get isDismissible => widget.isDismissible ?? true;

  bool isLoading = false;

  Future<void> onSubmitted(String text) async {
    if (isLoading) return;
    isLoading = true;
    setState(() {});
    await widget.onSubmitted.call(text);
    isLoading = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding ?? const EdgeInsets.only(left: 0, right: 0, top: 0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(DesktopScaffold.cardRadius),
          border: widget.alwaysOn == true ? null : Border.all(color: context.outline.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            SizedBox(width: 15),
            if (widget.leading != null) widget.leading!,
            if (widget.leading == null) VisirIcon(type: VisirIconType.search, size: 16, isSelected: true),
            SizedBox(width: 0),
            Expanded(
              child: TextFormField(
                controller: widget.textEditingController,
                autofocus: widget.autoFocus ?? false,
                style: context.titleSmall?.textColor(context.onBackground),
                initialValue: widget.textEditingController == null ? widget.initialValue ?? '' : null,
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  hintStyle: context.titleSmall?.textColor(context.surfaceTint),
                  isDense: true,
                  filled: false,
                  contentPadding: EdgeInsets.all(8),
                ),
                focusNode: widget.focusNode,
                onFieldSubmitted: onSubmitted,
                onChanged: widget.onChanged,
                maxLines: 1,
              ),
            ),
            if (isLoading) CustomCircularLoadingIndicator(size: 14),
            if (widget.alwaysOn != true && !isLoading && isDismissible || widget.textEditingController?.text.isNotEmpty == true)
              VisirButton(
                type: VisirButtonAnimationType.scaleAndOpacity,
                style: VisirButtonStyle(padding: EdgeInsets.all(6), hoverColor: Colors.transparent),
                onTap: widget.onClose,
                child: VisirIcon(type: VisirIconType.closeWithCircle, size: 14, isSelected: true),
              ),
            SizedBox(width: 6),
          ],
        ),
      ),
    );
  }
}
