import 'package:flutter/material.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import '../../theme/chat_theme.dart';

/// Modern user message bubble with gradient and rounded corners
class UserMessageBubble extends StatelessWidget {
  final String content;
  final DateTime timestamp;
  final bool showTimestamp;

  const UserMessageBubble({
    super.key,
    required this.content,
    required this.timestamp,
    this.showTimestamp = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ChatTheme(context);

    return Align(
      alignment: Alignment.centerRight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            constraints: const BoxConstraints(maxWidth: 600),
            margin: const EdgeInsets.only(left: 48, right: 12, bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: theme.userMessageGradient,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomLeft: Radius.circular(18),
                bottomRight: Radius.circular(4),
              ),
              boxShadow: theme.userMessageShadowList,
            ),
            child: Text(
              content,
              style: context.bodyMedium?.copyWith(
                color: theme.userMessageText,
                fontSize: 14,
                height: 1.6,
                letterSpacing: 0.2,
              ),
            ),
          ),
          if (showTimestamp)
            Padding(
              padding: const EdgeInsets.only(right: 16, bottom: 4),
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
