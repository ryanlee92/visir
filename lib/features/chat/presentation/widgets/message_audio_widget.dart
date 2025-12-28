import 'package:Visir/config/providers.dart';
import 'package:Visir/features/chat/domain/entities/message_file_entity.dart';
import 'package:Visir/features/common/presentation/utils/extensions/platform_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/common/presentation/widgets/custom_circualr_loading_indicator.dart';
import 'package:Visir/features/common/presentation/widgets/fgbg_detector.dart';
import 'package:Visir/features/common/presentation/widgets/visir_button.dart';
import 'package:Visir/features/common/presentation/widgets/visir_icon.dart';
import 'package:Visir/features/preference/domain/entities/oauth_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';

class MessageAudioWidget extends ConsumerStatefulWidget {
  final MessageFileEntity file;
  final OAuthEntity? oauth;

  const MessageAudioWidget({required this.file, required this.oauth});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MessageAudioWidgetState();
}

class _MessageAudioWidgetState extends ConsumerState<MessageAudioWidget> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  bool isDownloading = false;

  bool get isDarkMode => context.isDarkMode;

  late Player player = Player();
  late Media playable;

  @override
  void initState() {
    super.initState();
    initializeAudio();
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  Future<void> initializeAudio() async {
    playable = await proxyMedia(url: widget.file.downloadUrl ?? '', oauth: widget.oauth);
    await player.open(playable, play: false);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FGBGDetector(
      onChanged: (isForeground, isFirst) {
        if (!isForeground) {
          player.pause();
        }
      },
      child: StreamBuilder(
        stream: player.stream.duration,
        builder: (context, durationStream) {
          Duration duration = durationStream.data ?? Duration.zero;

          return StreamBuilder(
            stream: player.stream.position,
            builder: (context, positionStream) {
              Duration position = positionStream.data ?? Duration.zero;

              String formatDuration = position != Duration.zero
                  ? '${Utils.durtaionFormatter(position)} / ${Utils.durtaionFormatter(duration)}'
                  : '${Utils.durtaionFormatter(duration)}';

              return StreamBuilder(
                stream: player.stream.playing,
                builder: (context, playingStream) {
                  bool isPlaying = playingStream.data ?? false;

                  return Container(
                    width: 260,
                    height: 56,
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: ShapeDecoration(
                      color: (PlatformX.isMobileView
                          ? context.surfaceVariant
                          : context.isDarkMode
                          ? context.outline
                          : context.surfaceVariant),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Row(
                      children: [
                        UnconstrainedBox(
                          child: VisirButton(
                            type: VisirButtonAnimationType.scaleAndOpacity,
                            style: VisirButtonStyle(
                              cursor: WidgetStateMouseCursor.clickable,
                              margin: EdgeInsets.all(6),
                              width: 32,
                              height: 32,
                              backgroundColor: context.primary,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            onTap: () async {
                              if (isPlaying) {
                                await player.pause();
                              } else {
                                await player.play();
                              }
                            },
                            child: VisirIcon(
                              type: isPlaying ? VisirIconType.pause : VisirIconType.play,
                              size: 16,
                              color: isDarkMode ? context.outlineVariant : context.outline,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 6, top: 4, bottom: 4, right: 6),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  widget.file.name ?? '',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: context.titleSmall?.textBold.textColor(context.outlineVariant),
                                ),
                                const SizedBox(height: 4),
                                Text(formatDuration, style: context.labelMedium?.textColor(context.onInverseSurface)),
                              ],
                            ),
                          ),
                        ),
                        UnconstrainedBox(
                          child: VisirButton(
                            type: VisirButtonAnimationType.scaleAndOpacity,
                            style: VisirButtonStyle(
                              width: 36,
                              height: 36,
                              padding: EdgeInsets.symmetric(horizontal: 6),
                              cursor: SystemMouseCursors.click,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: isDownloading
                                ? CustomCircularLoadingIndicator(size: 18, color: context.outlineVariant)
                                : VisirIcon(
                                    type: PlatformX.isMobileView
                                        ? PlatformX.isAndroid
                                              ? VisirIconType.more
                                              : VisirIconType.share
                                        : VisirIconType.download,
                                    color: context.outlineVariant,
                                    size: 18,
                                  ),
                            onTap: () async {
                              setState(() {
                                isDownloading = true;
                              });

                              String downloadUrl = widget.file.downloadUrl ?? '';

                              await proxyDownload(
                                url: downloadUrl,
                                oauth: widget.oauth,
                                name: widget.file.name!,
                                extension: widget.file.filetype,
                                context: context,
                              );

                              setState(() {
                                isDownloading = false;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
