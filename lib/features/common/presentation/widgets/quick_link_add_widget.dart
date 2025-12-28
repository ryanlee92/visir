import 'package:Visir/config/providers.dart';
import 'package:Visir/features/auth/application/auth_controller.dart';
import 'package:Visir/features/common/presentation/utils/extensions/platform_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/common/presentation/widgets/popup_menu.dart';
import 'package:Visir/features/common/presentation/widgets/popup_menu_container.dart';
import 'package:Visir/features/common/presentation/widgets/popup_menu_theme.dart';
import 'package:Visir/features/common/presentation/widgets/proxy_network_image.dart';
import 'package:Visir/features/common/presentation/widgets/visir_button.dart';
import 'package:Visir/features/common/presentation/widgets/visir_icon.dart';
import 'package:Visir/features/preference/application/local_pref_controller.dart';
import 'package:any_link_preview/any_link_preview.dart';
import 'package:favicon/favicon.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class QuickLinkAddWidget extends ConsumerStatefulWidget {
  final String? title;
  final String? link;
  final String? favicon;
  final int? index;
  const QuickLinkAddWidget({Key? key, this.title, this.link, this.favicon, this.index}) : super(key: key);

  @override
  _QuickLinkAddWidgetState createState() => _QuickLinkAddWidgetState();
}

class _QuickLinkAddWidgetState extends ConsumerState<QuickLinkAddWidget> {
  String? favicon;
  String? link;
  String? title;

  bool onFavLoading = false;

  @override
  void initState() {
    super.initState();
    favicon = widget.favicon;
    link = widget.link;
    title = widget.title;
  }

  void save() {
    if (link?.isNotEmpty != true && title?.isNotEmpty != true) return;
    if (onFavLoading) return;

    final user = Utils.ref.read(authControllerProvider).requireValue;

    final userQuickLinks = ref.read(authControllerProvider.select((v) => v.requireValue.quickLinks));
    final quickLinks = List<Map<String, String?>>.from(
      userQuickLinks ?? (ref.read(localPrefControllerProvider.select((v) => v.value?.quickLinks ?? [])) ?? []),
    );

    if (widget.index != null) quickLinks.removeAt(widget.index!);

    ref
        .read(authControllerProvider.notifier)
        .updateUser(
          user: user.copyWith(
            quickLinks: [
              ...quickLinks,
              {'title': title, 'link': link, 'favicon': favicon},
            ],
          ),
        );

    Navigator.of(Utils.mainContext).maybePop();
  }

  void delete() {
    final user = Utils.ref.read(authControllerProvider).requireValue;

    final userQuickLinks = ref.read(authControllerProvider.select((v) => v.requireValue.quickLinks));
    final quickLinks = List<Map<String, String?>>.from(
      userQuickLinks ?? (ref.read(localPrefControllerProvider.select((v) => v.value?.quickLinks ?? [])) ?? []),
    );

    if (widget.index != null) quickLinks.removeAt(widget.index!);

    ref.read(authControllerProvider.notifier).updateUser(user: user.copyWith(quickLinks: quickLinks));

    Navigator.of(Utils.mainContext).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: context.theme.popupTheme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Container(
              height: 28,
              padding: EdgeInsets.symmetric(horizontal: 3, vertical: 2),
              decoration: BoxDecoration(color: context.surface, borderRadius: BorderRadius.circular(6), boxShadow: PopupMenu.popupShadow),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.link != null)
                    VisirButton(
                      type: VisirButtonAnimationType.scaleAndOpacity,
                      style: VisirButtonStyle(width: 24, height: 24, borderRadius: BorderRadius.circular(4), margin: EdgeInsets.only(right: 4)),
                      options: VisirButtonOptions(
                        bypassTextField: true,
                        shortcuts: [
                          VisirButtonKeyboardShortcut(
                            message: context.tr.task_action_delete,
                            keys: [
                              LogicalKeyboardKey.backspace,
                              if (PlatformX.isApple) LogicalKeyboardKey.meta,
                              if (!PlatformX.isApple) LogicalKeyboardKey.control,
                            ],
                            subkeys: [
                              [LogicalKeyboardKey.delete, if (PlatformX.isApple) LogicalKeyboardKey.meta, if (!PlatformX.isApple) LogicalKeyboardKey.control],
                            ],
                          ),
                        ],
                      ),
                      onTap: delete,
                      child: VisirIcon(type: VisirIconType.trash, color: context.onInverseSurface, size: 14),
                    ),
                  VisirButton(
                    enabled: link != null,
                    type: VisirButtonAnimationType.scaleAndOpacity,
                    style: VisirButtonStyle(width: 24, height: 24, borderRadius: BorderRadius.circular(4), margin: EdgeInsets.only(right: 4)),
                    options: VisirButtonOptions(
                      bypassTextField: true,
                      shortcuts: [
                        VisirButtonKeyboardShortcut(message: context.tr.confirm, keys: [LogicalKeyboardKey.enter]),
                      ],
                    ),
                    onTap: save,
                    child: VisirIcon(type: VisirIconType.check, color: context.onInverseSurface, size: 14),
                  ),
                  VisirButton(
                    type: VisirButtonAnimationType.scaleAndOpacity,
                    style: VisirButtonStyle(width: 24, height: 24, borderRadius: BorderRadius.circular(4)),
                    options: VisirButtonOptions(
                      bypassTextField: true,
                      shortcuts: [
                        VisirButtonKeyboardShortcut(message: context.tr.cancel, keys: [LogicalKeyboardKey.escape]),
                      ],
                    ),
                    onTap: Navigator.of(Utils.mainContext).maybePop,
                    child: VisirIcon(type: VisirIconType.close, color: context.onInverseSurface, size: 14),
                  ),
                ],
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), boxShadow: PopupMenu.popupShadow, color: context.surface),
            child: PopupMenuContainer(
              horizontalPadding: 0,
              backgroundColor: context.surface,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
                    child: TextFormField(
                      textInputAction: TextInputAction.none,
                      autofocus: true,
                      initialValue: link,
                      minLines: 1,
                      style: context.titleSmall?.textColor(context.outlineVariant),
                      decoration: InputDecoration(
                        constraints: BoxConstraints(minHeight: 20),
                        hintText: context.tr.quick_link_hint_link,
                        hintStyle: context.titleSmall?.textColor(context.surfaceTint),
                        filled: false,
                        contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 4),
                        hoverColor: Colors.transparent,
                        isDense: true,
                      ),
                      onChanged: (text) {
                        if (!text.startsWith('https://') && !text.startsWith('http://')) {
                          text = 'https://${text}';
                        }

                        text = text.replaceFirst('://www.', '://');

                        final bool _isUrlValid = Uri.parse(text).isAbsolute && AnyLinkPreview.isValidLink(text, protocols: ['http', 'https']);

                        if (!_isUrlValid) {
                          link = null;
                          title = null;
                          favicon = null;
                        }

                        if (_isUrlValid) {
                          onFavLoading = true;
                          link = text;
                          AnyLinkPreview.getMetadata(link: proxyUrl(text), cache: const Duration(days: 7)).then((metadata) {
                            if (metadata?.title == null) return;
                            title = metadata?.title;
                            setState(() {});
                          });

                          FaviconFinder.getBest(proxyUrl(text))
                              .then((fav) {
                                favicon = fav?.url;
                                onFavLoading = false;
                                setState(() {});
                              })
                              .catchError((e) {
                                onFavLoading = false;
                                setState(() {});
                              });
                        }

                        setState(() {});
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 16, right: 16, top: 14, bottom: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!onFavLoading && favicon != null)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ProxyNetworkImage(imageUrl: favicon!, width: 18, height: 18),
                          ),
                        if (onFavLoading)
                          Container(
                            margin: const EdgeInsets.only(right: 8),
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 1.5, color: context.secondary),
                          ),
                        Expanded(
                          child: TextFormField(
                            key: ValueKey('quick_link_add_title:${title}'),
                            textInputAction: TextInputAction.none,
                            style: (context.titleSmall)?.copyWith(color: context.outlineVariant),
                            initialValue: title,
                            maxLines: null,
                            minLines: 1,
                            decoration: InputDecoration(
                              hintText: context.tr.quick_link_hint_title,
                              contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 3),
                              fillColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              filled: false,
                              isDense: true,
                              hintStyle: context.titleSmall?.copyWith(color: context.surfaceTint),
                            ),
                            onChanged: (text) {
                              title = text;
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
