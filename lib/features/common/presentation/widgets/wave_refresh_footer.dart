import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/widgets/custom_circualr_loading_indicator.dart';
import 'package:Visir/features/common/presentation/widgets/visir_icon.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

class WaveRefreshFooter extends StatelessWidget {
  final Color? color;
  final double? size;
  const WaveRefreshFooter({super.key, this.color, this.size});

  @override
  Widget build(BuildContext context) {
    double iconSize = size == null ? 20 : size! * 20 / 12; // 아이콘 크기를 16에서 20으로 증가
    return ClassicFooter(
      idleText: '',
      noDataText: '',
      canLoadingText: '',
      failedText: '',
      loadingText: '',
      idleIcon: VisirIcon(type: VisirIconType.arrowDown, size: iconSize, color: context.outlineVariant),
      loadingIcon: CustomCircularLoadingIndicator(size: size ?? 16, color: color ?? context.onBackground), // 색상을 onBackground로 변경, 크기도 증가
      canLoadingIcon: VisirIcon(type: VisirIconType.more, size: iconSize, color: context.outlineVariant),
      noMoreIcon: VisirIcon(type: VisirIconType.check, size: iconSize, color: context.outlineVariant),
      failedIcon: VisirIcon(type: VisirIconType.close, size: iconSize, color: context.error),
      spacing: 0,
    );
  }
}
