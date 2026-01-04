import 'package:Visir/config/providers.dart';
import 'package:Visir/features/inbox/application/agent_file_list_controller.dart';
import 'package:Visir/features/chat/domain/entities/message_file_entity.dart';
import 'package:Visir/features/chat/presentation/widgets/chat_input/message_temporary_file_list_video_widget.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/widgets/custom_circualr_loading_indicator.dart';
import 'package:Visir/features/common/presentation/widgets/visir_button.dart';
import 'package:Visir/features/common/presentation/widgets/visir_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AgentTemporaryFileList extends ConsumerStatefulWidget {
  final TabType tabType;

  const AgentTemporaryFileList({required this.tabType});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AgentTemporaryFileListState();
}

class _AgentTemporaryFileListState extends ConsumerState<AgentTemporaryFileList> {
  @override
  Widget build(BuildContext context) {
    final fileList = ref.watch(agentFileListControllerProvider(tabType: widget.tabType).select((v) => v));

    return fileList.isEmpty
        ? const SizedBox.shrink()
        : Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 4,
            children: fileList.map((e) {
              final _messageFile = e.file;

              bool isImage = _messageFile.isImage;
              bool isVideo = _messageFile.isVideo;
              bool isOtherFile = !isImage && !isVideo;

              bool onProcess = e.onProcess;
              bool isFailed = !(e.ok ?? true);

              return Stack(
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 12, right: 12),
                    child: isImage
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Container(
                              width: 64,
                              height: 64,
                              decoration: ShapeDecoration(
                                image: isFailed ? null : DecorationImage(image: MemoryImage(e.file.bytes!), fit: BoxFit.cover),
                                color: context.surface,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                              ),
                              child: isFailed
                                  ? Center(
                                      child: VisirIcon(type: VisirIconType.caution, size: 24, color: context.surfaceTint),
                                    )
                                  : const SizedBox.shrink(),
                            ),
                          )
                        : isVideo
                        ? MessageTemporaryFileListVideoWidget(file: e.file, isFailed: isFailed)
                        : Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Container(
                              width: 200,
                              height: 48,
                              decoration: ShapeDecoration(
                                color: context.surface,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                              ),
                              child: isFailed
                                  ? Center(
                                      child: VisirIcon(type: VisirIconType.caution, size: 24, color: context.surfaceTint),
                                    )
                                  : Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                                      child: Text(_messageFile.name, style: context.titleSmall?.textBold.textColor(context.outlineVariant), overflow: TextOverflow.ellipsis),
                                    ),
                            ),
                          ),
                  ),
                  Positioned(
                    top: (isOtherFile ? 8 : 0) + 4,
                    right: 4,
                    child: UnconstrainedBox(
                      child: VisirButton(
                        style: VisirButtonStyle(
                          width: 16,
                          height: 16,
                          backgroundColor: isFailed ? context.error : context.surface,
                          borderRadius: BorderRadius.circular(8),
                          padding: EdgeInsets.only(bottom: onProcess ? 0 : 1),
                        ),
                        type: VisirButtonAnimationType.scaleAndOpacity,
                        onTap: () {
                          if (onProcess) return;
                          ref.read(agentFileListControllerProvider(tabType: widget.tabType).notifier).removeTemporaryFile(file: _messageFile);
                        },
                        child: onProcess ? CustomCircularLoadingIndicator(size: 10) : VisirIcon(type: VisirIconType.close, size: 10, color: context.outlineVariant),
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          );
  }
}
