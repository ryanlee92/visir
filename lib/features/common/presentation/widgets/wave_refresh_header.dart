import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/widgets/custom_circualr_loading_indicator.dart';
import 'package:Visir/features/common/presentation/widgets/visir_icon.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

class WaveRefreshHeader extends StatelessWidget {
  const WaveRefreshHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return ClassicHeader(
      idleText: '',
      releaseText: '',
      refreshingText: '',
      completeText: '',
      failedText: '',
      completeDuration: Duration(milliseconds: 250),
      idleIcon: CircleAvatar(
        backgroundColor: context.background,
        radius: 12,
        child: VisirIcon(type: VisirIconType.arrowDown, size: 16),
      ),
      releaseIcon: CircleAvatar(
        backgroundColor: context.background,
        radius: 12,
        child: VisirIcon(type: VisirIconType.refresh, size: 16),
      ),
      refreshingIcon: CircleAvatar(
        backgroundColor: context.background,
        radius: 12,
        child: CustomCircularLoadingIndicator(size: 12, color: context.onBackground),
      ),
      completeIcon: CircleAvatar(
        backgroundColor: context.background,
        radius: 12,
        child: VisirIcon(type: VisirIconType.check, size: 16),
      ),
      failedIcon: CircleAvatar(
        backgroundColor: context.background,
        radius: 12,
        child: VisirIcon(type: VisirIconType.close, size: 16),
      ),
      spacing: 0,
    );
  }
}
