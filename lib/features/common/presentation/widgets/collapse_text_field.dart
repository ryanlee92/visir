import 'package:flutter/material.dart';

/// 포커스가 없을 때는 3줄까지 ellipsis로 접고,
/// 포커스가 생기면 실제 입력 가능한 TextFormField로 전환.
class CollapsingTextFormField extends StatefulWidget {
  const CollapsingTextFormField({
    super.key,
    this.controller,
    this.decoration = const InputDecoration(),
    this.collapsedLines,
    this.onChanged,
    this.enabled = true,
    this.focusNode,
    this.initialValue = '',
    this.textInputAction = TextInputAction.next,
    this.onFieldSubmitted,
    this.style,
    this.autofocus = false,
  });

  // enabled: isModifiable && !isRequest,
  // focusNode: titleFocusNode,
  // onFieldSubmitted: onTextFieldSubmitted,
  // initialValue: title ?? '',

  final TextStyle? style;
  final bool autofocus;
  final void Function(String text)? onFieldSubmitted;
  final bool enabled;
  final FocusNode? focusNode;
  final TextInputAction textInputAction;
  final String initialValue;
  final int? collapsedLines;
  final ValueChanged<String>? onChanged;

  final TextEditingController? controller;
  final InputDecoration decoration;

  @override
  State<CollapsingTextFormField> createState() => _CollapsingTextFormFieldState();
}

class _CollapsingTextFormFieldState extends State<CollapsingTextFormField> {
  late final FocusNode _focusNode;
  bool _hasFocus = false;
  TextEditingController? _controller;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(() {
      setState(() => _hasFocus = _focusNode.hasFocus);
    });
    _controller = widget.controller ?? TextEditingController(text: widget.initialValue);
    if (widget.autofocus) _hasFocus = true;
  }

  @override
  void dispose() {
    if (widget.focusNode == null) _focusNode.dispose();
    if (widget.controller == null) _controller?.dispose();
    super.dispose();
  }

  String _truncateText(String text, int? maxLines) {
    if (maxLines == null || maxLines <= 0) return text;
    
    final lines = text.split('\n');
    if (lines.length <= maxLines) return text;
    
    // maxLines만큼만 표시하고 나머지는 ellipsis로 처리
    final truncatedLines = lines.take(maxLines).join('\n');
    return truncatedLines;
  }

  @override
  Widget build(BuildContext context) {
    final text = _controller?.text ?? '';

    final hintText = widget.decoration.hintText;

    final decoration = widget.decoration.copyWith(
      hintText: hintText == null
          ? null
          : hintText.length > 100
          ? '${hintText.substring(0, 100).trim()}...'
          : hintText,
    );

    // collapsedLines를 넘는 경우 텍스트를 잘라내고 ellipsis 표시
    final displayText = text.isEmpty 
        ? text 
        : _truncateText(text, widget.collapsedLines);
    final hasMoreLines = text.isNotEmpty && 
        widget.collapsedLines != null && 
        text.split('\n').length > widget.collapsedLines!;

    return AnimatedCrossFade(
      duration: const Duration(milliseconds: 160),
      crossFadeState: _hasFocus ? CrossFadeState.showSecond : CrossFadeState.showFirst,
      // Collapsed(읽기 형태) 뷰: ellipsis 적용
      firstChild: MouseRegion(
        cursor: SystemMouseCursors.text,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            _hasFocus = true;
            setState(() {});
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _focusNode.requestFocus();
            });
          },
          child: InputDecorator(
            decoration: decoration,
            isFocused: false,
            isEmpty: text.isEmpty,
            child: text.isEmpty
                ? Text(decoration.hintText ?? '', style: widget.decoration.hintStyle)
                : Text(
                    hasMoreLines ? '$displayText...' : displayText,
                    maxLines: widget.collapsedLines,
                    overflow: TextOverflow.ellipsis,
                    style: widget.style,
                  ),
          ),
        ),
      ),
      // Expanded(입력 가능) 뷰: maxLines = null 로 무제한 확장
      secondChild: TextFormField(
        controller: _controller,
        focusNode: _focusNode,
        maxLines: null, // 포커스 중에는 높이 제한 없음
        minLines: 1,
        decoration: decoration,
        onChanged: widget.onChanged,
        textInputAction: widget.textInputAction,
        style: widget.style,
        autofocus: true,
        onFieldSubmitted: widget.onFieldSubmitted,
        enabled: widget.enabled,
      ),
    );
  }
}
