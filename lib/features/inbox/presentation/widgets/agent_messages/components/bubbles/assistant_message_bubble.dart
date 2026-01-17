import 'package:flutter/material.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/widgets/visir_icon.dart';
import '../../theme/chat_theme.dart';

/// Modern assistant message bubble with avatar and subtle background
class AssistantMessageBubble extends StatelessWidget {
  final Widget content;
  final DateTime timestamp;
  final bool showTimestamp;
  final bool showAvatar;

  const AssistantMessageBubble({
    super.key,
    required this.content,
    required this.timestamp,
    this.showTimestamp = true,
    this.showAvatar = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ChatTheme(context);

    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showAvatar) ...[
                Container(
                  width: 32,
                  height: 32,
                  margin: const EdgeInsets.only(left: 12, top: 4),
                  decoration: BoxDecoration(
                    gradient: theme.avatarGradient,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF7C5DFF).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: VisirIcon(
                      type: VisirIconType.agent,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ] else
                const SizedBox(width: 56),
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 700),
                  margin: const EdgeInsets.only(right: 48, bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: theme.assistantMessageBg,
                    borderRadius: BorderRadius.only(
                      topLeft: showAvatar ? const Radius.circular(4) : const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: const Radius.circular(18),
                      bottomRight: const Radius.circular(18),
                    ),
                    border: Border.all(
                      color: theme.assistantMessageBorder,
                      width: 1,
                    ),
                  ),
                  child: content,
                ),
              ),
            ],
          ),
          if (showTimestamp)
            Padding(
              padding: const EdgeInsets.only(left: 56, bottom: 4),
              child: Text(
                _formatTimestamp(timestamp),
                style: context.bodySmall?.copyWith(
                  color: context.onSurface.withOpacity(0.5),
                  fontSize: 11,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';

    return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }
}
