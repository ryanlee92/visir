import 'dart:math';

import 'package:Visir/config/providers.dart';
import 'package:Visir/features/chat/domain/entities/message_file_entity.dart';
import 'package:Visir/features/common/presentation/utils/extensions/platform_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/common/presentation/widgets/custom_circualr_loading_indicator.dart';
import 'package:Visir/features/common/presentation/widgets/desktop_scaffold.dart';
import 'package:Visir/features/common/presentation/widgets/keyboard_shortcut.dart';
import 'package:Visir/features/common/presentation/widgets/visir_button.dart';
import 'package:Visir/features/common/presentation/widgets/visir_icon.dart';
import 'package:Visir/features/preference/domain/entities/oauth_entity.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class MessageVideoScreen extends ConsumerStatefulWidget {
  final MessageFileEntity file;
  final double width;
  final double height;
  final OAuthEntity? oauth;
  final TabType tabType;

  const MessageVideoScreen({required this.file, required this.width, required this.height, required this.oauth, required this.tabType});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MessageVideoScreenState();
}

class _MessageVideoScreenState extends ConsumerState<MessageVideoScreen> {
  bool isDownloading = false;

  ValueNotifier<bool> isHoveringNotifier = ValueNotifier(false);

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
    isHoveringNotifier.dispose();
    super.dispose();
  }

  Future<void> initializeVideo() async {
    playable = await proxyMedia(url: widget.file.downloadUrl ?? '', oauth: widget.oauth);
    await player.setVolume(100.0);
    await player.open(playable, play: false);
    await player.play();
  }

  bool _onKeyDown(KeyEvent event, {required VideoState state, required bool isMute, required Duration duration, required Duration position}) {
    final key = event.logicalKey;
    if (event is KeyDownEvent) {
      if (key == LogicalKeyboardKey.arrowRight) {
        state.widget.controller.player.seek(Duration(milliseconds: min(duration.inMilliseconds, position.inMilliseconds + 10 * 1000)));
        return true;
      } else if (key == LogicalKeyboardKey.arrowLeft) {
        state.widget.controller.player.seek(Duration(milliseconds: max(0, position.inMilliseconds - 10 * 1000)));
        return true;
      }
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: PlatformX.isDesktopView ? Colors.transparent : context.background,
      child: Center(
        child: TapRegion(
          onTapOutside: (event) {
            Navigator.of(context, rootNavigator: true).pop();
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(DesktopScaffold.cardRadius),
            child: Video(
              width: widget.width,
              height: widget.height,
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

                                return KeyboardShortcut(
                                  targetTab: widget.tabType,
                                  onKeyDown: (event) => _onKeyDown(event, state: state, duration: duration, position: position, isMute: isMute),
                                  child: MouseRegion(
                                    onEnter: (event) {
                                      setState(() {
                                        isHoveringNotifier.value = true;
                                      });
                                    },
                                    onExit: (event) {
                                      setState(() {
                                        isHoveringNotifier.value = false;
                                      });
                                    },
                                    child: Opacity(
                                      opacity: isHoveringNotifier.value ? 1 : 0,
                                      child: Stack(
                                        children: [
                                          Positioned(
                                            height: 100,
                                            left: 0,
                                            right: 0,
                                            bottom: 0,
                                            child: Container(
                                              height: 100,
                                              width: double.maxFinite,
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  begin: Alignment.bottomCenter,
                                                  end: Alignment.topCenter,
                                                  colors: [Colors.black.withValues(alpha: 0.5), Colors.black.withValues(alpha: 0)],
                                                ),
                                              ),
                                            ),
                                          ),
                                          Column(
                                            children: [
                                              Expanded(
                                                child: VisirButton(
                                                  type: VisirButtonAnimationType.scaleAndOpacity,
                                                  style: VisirButtonStyle(cursor: SystemMouseCursors.basic, hoverColor: Colors.transparent),
                                                  onTap: () async {
                                                    await state.widget.controller.player.playOrPause();
                                                  },
                                                  child: Container(color: Colors.transparent),
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.all(16),
                                                child: Column(
                                                  children: [
                                                    MouseRegion(
                                                      cursor: SystemMouseCursors.click,
                                                      child: Container(
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
                                                    ),
                                                    const SizedBox(height: 7),
                                                    Row(
                                                      children: [
                                                        VisirButton(
                                                          key: ValueKey('message_video_screen:play${isPlay}'),
                                                          type: VisirButtonAnimationType.scaleAndOpacity,
                                                          style: VisirButtonStyle(
                                                            hoverColor: Colors.black.withValues(alpha: 0.3),
                                                            borderRadius: BorderRadius.circular(6),
                                                            padding: EdgeInsets.all(8),
                                                          ),
                                                          options: VisirButtonOptions(
                                                            tabType: widget.tabType,
                                                            shortcuts: [
                                                              VisirButtonKeyboardShortcut(
                                                                message: isPlay ? context.tr.pause : context.tr.play,
                                                                keys: [LogicalKeyboardKey.space],
                                                              ),
                                                            ],
                                                          ),
                                                          onTap: () => state.widget.controller.player.playOrPause(),
                                                          child: VisirIcon(
                                                            type: isPlay ? VisirIconType.pause : VisirIconType.play,
                                                            color: context.onPrimary,
                                                            size: 20,
                                                          ),
                                                        ),
                                                        const SizedBox(width: 12),
                                                        VisirButton(
                                                          key: ValueKey('message_video_screen:mute${isMute}'),
                                                          type: VisirButtonAnimationType.scaleAndOpacity,
                                                          style: VisirButtonStyle(
                                                            hoverColor: Colors.black.withValues(alpha: 0.3),
                                                            borderRadius: BorderRadius.circular(6),
                                                            padding: EdgeInsets.all(8),
                                                          ),
                                                          options: VisirButtonOptions(
                                                            tabType: widget.tabType,
                                                            shortcuts: [
                                                              VisirButtonKeyboardShortcut(
                                                                message: isMute ? context.tr.unmute : context.tr.mute,
                                                                keys: [LogicalKeyboardKey.keyM],
                                                              ),
                                                            ],
                                                          ),
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
                                          Positioned(
                                            top: 12,
                                            right: 12,
                                            child: Container(
                                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: ShapeDecoration(
                                                color: Colors.black.withValues(alpha: 0.5),
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  VisirButton(
                                                    type: VisirButtonAnimationType.scaleAndOpacity,
                                                    style: VisirButtonStyle(
                                                      hoverColor: Colors.white.withValues(alpha: 0.1),
                                                      borderRadius: BorderRadius.circular(6),
                                                      padding: EdgeInsets.all(4),
                                                    ),
                                                    options: VisirButtonOptions(message: context.tr.file_options_download),
                                                    child: isDownloading
                                                        ? CustomCircularLoadingIndicator(size: 20)
                                                        : VisirIcon(type: VisirIconType.download, color: context.onPrimary, size: 20),
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
                                                  const SizedBox(width: 8),
                                                  VisirButton(
                                                    type: VisirButtonAnimationType.scaleAndOpacity,
                                                    style: VisirButtonStyle(
                                                      padding: EdgeInsets.all(4),
                                                      hoverColor: Colors.white.withValues(alpha: 0.1),
                                                      borderRadius: BorderRadius.circular(6),
                                                      cursor: SystemMouseCursors.click,
                                                    ),
                                                    options: VisirButtonOptions(
                                                      tabType: widget.tabType,
                                                      shortcuts: [
                                                        VisirButtonKeyboardShortcut(
                                                          message: context.tr.mail_detail_tooltip_close,
                                                          keys: [LogicalKeyboardKey.escape],
                                                        ),
                                                      ],
                                                    ),
                                                    onTap: Navigator.of(context, rootNavigator: true).pop,
                                                    child: VisirIcon(type: VisirIconType.close, color: context.onPrimary, size: 20),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
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
        ),
      ),
    );
  }
}
