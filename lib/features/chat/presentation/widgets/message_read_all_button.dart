import 'package:Visir/config/providers.dart';
import 'package:Visir/features/chat/application/chat_channel_list_controller.dart';
import 'package:Visir/features/chat/domain/entities/message_channel_entity.dart';
import 'package:Visir/features/common/presentation/utils/extensions/platform_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/widgets/custom_circualr_loading_indicator.dart';
import 'package:Visir/features/common/presentation/widgets/visir_button.dart';
import 'package:Visir/features/common/presentation/widgets/visir_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatReadAllButton extends ConsumerStatefulWidget {
  final List<MessageChannelEntity> unreadChannels;
  const ChatReadAllButton({super.key, required this.unreadChannels});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MessageRealAllButtonState();
}

class _MessageRealAllButtonState extends ConsumerState<ChatReadAllButton> {
  late bool onProcessing;

  bool get isMobileView => PlatformX.isMobileView;

  @override
  void initState() {
    super.initState();
    onProcessing = false;
  }

  @override
  Widget build(BuildContext context) {
    return VisirButton(
      type: VisirButtonAnimationType.scaleAndOpacity,
      style: VisirButtonStyle(
        cursor: SystemMouseCursors.click,
        height: 32,
        backgroundColor: context.primary,
        borderRadius: BorderRadius.circular(6),
        padding: EdgeInsets.symmetric(horizontal: 8),
      ),
      options: VisirButtonOptions(
        tabType: TabType.chat,
        shortcuts: [
          VisirButtonKeyboardShortcut(message: '', keys: [LogicalKeyboardKey.keyR]),
        ],
      ),
      onTap: () async {
        if (onProcessing) return;

        onProcessing = true;
        setState(() {});

        List<Future?> futures = [];
        widget.unreadChannels.forEach((e) {
          futures.add(ref.read(chatChannelListControllerProvider.notifier).setReadCursor(teamId: e.teamId, channelId: e.id, lastReadAt: e.lastUpdated));
        });
        await Future.wait(futures.whereType<Future>());

        Future.delayed(Duration(milliseconds: 3000), () {
          if (mounted) {
            onProcessing = false;
            setState(() {});
          }
        });
      },
      child: Stack(
        children: [
          Row(
            children: [
              VisirIcon(type: VisirIconType.show, color: onProcessing ? Colors.transparent : context.onPrimary, size: 16, isSelected: true),
              SizedBox(width: 6),
              Text(context.tr.chat_read_all, style: context.labelLarge?.textColor(onProcessing ? Colors.transparent : context.onPrimary).appFont(context)),
            ],
          ),
          if (onProcessing)
            Positioned.fill(
              child: Center(child: CustomCircularLoadingIndicator(color: context.onPrimary, size: 16)),
            ),
        ],
      ),
    );
  }
}
