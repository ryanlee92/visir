import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/widgets/visir_icon.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class MessageTemporaryFileListVideoWidget extends ConsumerStatefulWidget {
  final PlatformFile file;
  final bool isFailed;

  const MessageTemporaryFileListVideoWidget({required this.file, required this.isFailed});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MessageTemporaryFileListVideoWidgetState();
}

class _MessageTemporaryFileListVideoWidgetState extends ConsumerState<MessageTemporaryFileListVideoWidget> {
  late Player player = Player();
  late Media playable;
  late VideoController controller = VideoController(player);

  @override
  void initState() {
    super.initState();
    initializeVideo();
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  Future<void> initializeVideo() async {
    playable = await Media.memory(await widget.file.bytes!);
    await player.open(playable, play: false);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Container(
            width: 64,
            height: 64,
            decoration: ShapeDecoration(
              color: context.surface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
            child: widget.isFailed
                ? Center(
                    child: VisirIcon(type: VisirIconType.caution, size: 24, color: context.surfaceTint),
                  )
                : Video(controller: controller, width: 64, height: 64, fit: BoxFit.cover, controls: (state) => const SizedBox.shrink()),
          ),
        ),
        Positioned(
          bottom: 0,
          child: Opacity(
            opacity: 0.50,
            child: Container(
              width: 64,
              height: 22,
              decoration: ShapeDecoration(
                color: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(4), bottomRight: Radius.circular(4)),
                ),
              ),
              child: Center(child: Text('video', style: context.bodyMedium?.textColor(context.outlineVariant))),
            ),
          ),
        ),
      ],
    );
  }
}
