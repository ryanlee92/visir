import 'package:Visir/config/providers.dart';
import 'package:Visir/features/chat/domain/entities/message_file_entity.dart';
import 'package:Visir/features/common/presentation/utils/extensions/platform_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/common/presentation/widgets/custom_circualr_loading_indicator.dart';
import 'package:Visir/features/common/presentation/widgets/visir_app_bar.dart';
import 'package:Visir/features/common/presentation/widgets/visir_button.dart';
import 'package:Visir/features/common/presentation/widgets/visir_icon.dart';
import 'package:Visir/features/preference/domain/entities/oauth_entity.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class MobileMessageVideoScreen extends ConsumerStatefulWidget {
  final MessageFileEntity file;
  final OAuthEntity? oauth;

  const MobileMessageVideoScreen({required this.file, required this.oauth});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MobileMessageVideoScreenState();
}

class _MobileMessageVideoScreenState extends ConsumerState<MobileMessageVideoScreen> {
  bool isDownloading = false;
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
    playable = await proxyMedia(url: widget.file.downloadUrl ?? '', oauth: widget.oauth);
    await player.setVolume(100.0);
    await player.open(playable, play: false);
    await player.play();
  }

  Future<void> share() async {
    setState(() {
      isDownloading = true;
    });

    String downloadUrl = widget.file.downloadUrl ?? '';
    await proxyDownload(url: downloadUrl, oauth: widget.oauth, name: widget.file.name!, extension: widget.file.filetype, context: context);

    setState(() {
      isDownloading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.background,
      child: SafeArea(
        child: Column(
          children: [
            VisirAppBar(
              title: widget.file.name ?? '',
              leadings: [
                VisirAppBarButton(
                  icon: VisirIconType.close,
                  onTap: Utils.mainContext.pop,
                  options: VisirButtonOptions(
                    tooltipLocation: VisirButtonTooltipLocation.right,
                    shortcuts: [
                      VisirButtonKeyboardShortcut(message: context.tr.close, keys: [LogicalKeyboardKey.escape]),
                    ],
                  ),
                ),
              ],
              trailings: [
                VisirAppBarButton(
                  onTap: share,
                  icon: isDownloading
                      ? null
                      : PlatformX.isAndroid
                      ? VisirIconType.more
                      : VisirIconType.share,
                  child: isDownloading ? CustomCircularLoadingIndicator(size: 24, color: context.outlineVariant) : null,
                ),
              ],
            ),
            Expanded(
              child: Video(
                fill: context.background,
                controller: controller,
                controls: (state) {
                  return StreamBuilder<Duration>(
                    stream: state.widget.controller.player.stream.duration,
                    builder: (context, durationStream) {
                      Duration duration = durationStream.data ?? Duration.zero;

                      return StreamBuilder<Duration>(
                        stream: state.widget.controller.player.stream.position,
                        builder: (context, positionStream) {
                          Duration position = positionStream.data ?? Duration.zero;

                          return StreamBuilder<double>(
                            stream: state.widget.controller.player.stream.volume,
                            builder: (context, volumeStream) {
                              bool isMute = volumeStream.data != null && volumeStream.data == 0;

                              return StreamBuilder<bool>(
                                stream: state.widget.controller.player.stream.playing,
                                builder: (context, playingStream) {
                                  bool isPlay = playingStream.data ?? false;

                                  return Stack(
                                    children: [
                                      Column(
                                        children: [
                                          Expanded(
                                            child: VisirButton(
                                              type: VisirButtonAnimationType.scaleAndOpacity,
                                              style: VisirButtonStyle(cursor: WidgetStateMouseCursor.clickable),
                                              onTap: () async {
                                                await state.widget.controller.player.playOrPause();
                                              },
                                              child: Container(color: Colors.transparent),
                                            ),
                                          ),
                                          Container(
                                            padding: EdgeInsets.all(16),
                                            color: context.background.withValues(alpha: 0.2),
                                            child: Column(
                                              children: [
                                                Container(
                                                  height: 24,
                                                  child: Center(
                                                    child: ProgressBar(
                                                      barHeight: 6,
                                                      thumbRadius: 12,
                                                      thumbColor: Colors.transparent,
                                                      timeLabelLocation: TimeLabelLocation.none,
                                                      baseBarColor: context.onPrimary.withValues(alpha: 0.5),
                                                      progressBarColor: context.primary,
                                                      thumbGlowRadius: 0,
                                                      progress: position,
                                                      total: duration,
                                                      onSeek: (value) async {
                                                        await state.widget.controller.player.seek(value);
                                                      },
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(height: 7),
                                                Row(
                                                  children: [
                                                    VisirButton(
                                                      type: VisirButtonAnimationType.scaleAndOpacity,
                                                      style: VisirButtonStyle(hoverColor: Colors.transparent, padding: EdgeInsets.all(8)),
                                                      onTap: state.widget.controller.player.playOrPause,
                                                      child: VisirIcon(
                                                        type: isPlay ? VisirIconType.pause : VisirIconType.play,
                                                        color: context.onPrimary,
                                                        size: 20,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 12),
                                                    VisirButton(
                                                      type: VisirButtonAnimationType.scaleAndOpacity,
                                                      style: VisirButtonStyle(hoverColor: Colors.transparent, padding: EdgeInsets.all(8)),
                                                      onTap: () => state.widget.controller.player.setVolume(isMute ? 100 : 0),
                                                      child: VisirIcon(
                                                        type: isMute ? VisirIconType.soundOff : VisirIconType.soundOn,
                                                        color: context.onPrimary,
                                                        size: 20,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 16),
                                                    Text(
                                                      '${Utils.durtaionFormatter(position)} / ${Utils.durtaionFormatter(duration)}',
                                                      style: context.titleMedium?.textColor(context.onPrimary),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
