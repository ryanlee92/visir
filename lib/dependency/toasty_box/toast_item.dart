import 'dart:ui';

import 'package:Visir/dependency/toasty_box/model/toast_model.dart';
import 'package:Visir/features/common/presentation/utils/extensions/platform_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/widgets/popup_menu.dart';
import 'package:Visir/features/common/presentation/widgets/visir_button.dart';
import 'package:Visir/features/common/provider.dart';
import 'package:flutter/material.dart';

class ToastItem extends StatefulWidget {
  final VoidCallback onTapClose;
  final ToastModel item;

  ToastItem({Key? key, required this.onTapClose, required this.item}) : super(key: key);

  @override
  State<ToastItem> createState() => _ToastItemState();
}

class _ToastItemState extends State<ToastItem> {
  bool get isMobile => PlatformX.isMobileView;

  @override
  Widget build(BuildContext context) {
    TextStyle toastTextStyle = isMobile ? context.titleSmall! : context.bodyLarge!;

    return RepaintBoundary(
      child: VisirButton(
        type: VisirButtonAnimationType.none,
        style: VisirButtonStyle(boxShadow: PopupMenu.popupShadow, borderRadius: BorderRadius.circular(999)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
            child: Stack(
              children: [
                Positioned.fill(child: meshLoadingBackground),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: context.surface.withValues(alpha: 0.5),
                      border: Border.all(color: context.onBackground.withValues(alpha: 0.1), width: 1),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: PlatformX.isMobileView ? 16 : 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Text.rich(TextSpan(children: [widget.item.message], style: toastTextStyle.textColor(context.onBackground))),
                          ),
                        ),

                        ...(widget.item.buttons.map(
                          (b) => Padding(
                            padding: const EdgeInsets.only(left: 8, top: 8, bottom: 8),
                            child: VisirButton(
                              type: VisirButtonAnimationType.scaleAndOpacity,
                              style: VisirButtonStyle(
                                padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 8, vertical: isMobile ? 8 : 6),
                                backgroundColor: b.color,
                                borderRadius: BorderRadius.circular(isMobile ? 6 : 4),
                              ),
                              onTap: () {
                                b.onTap(widget.item);
                                widget.onTapClose.call();
                              },
                              child: Text(b.text, style: context.bodyLarge?.textColor(b.textColor)),
                            ),
                          ),
                        )),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
