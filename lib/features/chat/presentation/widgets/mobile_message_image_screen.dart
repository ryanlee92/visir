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
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_view/photo_view_gallery.dart';

class MobileMessageImageScreen extends ConsumerStatefulWidget {
  final MessageFileEntity? imageFile;
  final List<MessageFileEntity> imageFiles;
  final bool isFile;
  final String? imageUrl;
  final OAuthEntity? oauth;

  const MobileMessageImageScreen({required this.imageFile, required this.imageFiles, required this.isFile, required this.imageUrl, required this.oauth});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MobileMessageImageScreenState();
}

class _MobileMessageImageScreenState extends ConsumerState<MobileMessageImageScreen> {
  late PageController _pageController;
  String title = '';
  bool isDownloading = false;

  @override
  void initState() {
    super.initState();
    if (widget.isFile) {
      int index = widget.imageFiles.indexWhere((e) => e.id == widget.imageFile?.id);
      _pageController = PageController(initialPage: index < 0 ? 0 : index);
      title = widget.imageFiles[index].name ?? '';
    } else {
      title = widget.imageUrl?.split('/').lastOrNull ?? '';
    }
  }

  @override
  void dispose() {
    if (widget.isFile) {
      _pageController.dispose();
    }
    super.dispose();
  }

  Future<void> share() async {
    setState(() {
      isDownloading = true;
    });

    final file = widget.imageFiles[_pageController.page?.truncate() ?? 0];

    String downloadUrl = file.downloadUrl ?? widget.imageUrl ?? '';
    String name = file.name ?? widget.imageUrl?.split('/').last ?? '';
    String? extension = file.filetype ?? file.name?.split('.').last ?? widget.imageUrl?.split('.').last;

    await proxyDownload(url: downloadUrl, oauth: widget.oauth, name: name, extension: extension, context: context);

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
              title: title,
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
              child: Center(
                child: widget.isFile
                    ? PhotoViewGallery.builder(
                        itemCount: widget.imageFiles.length,
                        backgroundDecoration: BoxDecoration(color: context.background),
                        pageController: _pageController,
                        builder: (context, index) {
                          return PhotoViewGalleryPageOptions(
                            imageProvider: NetworkImage(proxyUrl(widget.imageFiles[index].downloadUrl ?? ''), headers: widget.oauth?.authorizationHeaders),
                          );
                        },
                        onPageChanged: (index) {
                          setState(() {
                            title = widget.imageFiles[index].name ?? '';
                          });
                        },
                      )
                    : Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(proxyUrl(widget.imageUrl ?? ''), headers: widget.oauth?.authorizationHeaders),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
