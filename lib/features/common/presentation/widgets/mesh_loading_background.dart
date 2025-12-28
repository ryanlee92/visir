import 'dart:async';
import 'dart:math';

import 'package:Visir/config/providers.dart';
import 'package:Visir/features/common/presentation/utils/extensions/platform_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/provider.dart';
import 'package:color_mesh/color_mesh.dart';
import 'package:color_mesh/src/widgets/shader_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

List<Offset> gradientPosition = [
  Offset(Random().nextDouble(), Random().nextDouble()),
  Offset(Random().nextDouble(), Random().nextDouble()),
  Offset(Random().nextDouble(), Random().nextDouble()),
  Offset(Random().nextDouble(), Random().nextDouble()),
];

class MeshLoadingBackground extends ConsumerStatefulWidget {
  final bool doNotAnimate;
  const MeshLoadingBackground({super.key, this.doNotAnimate = false});

  @override
  ConsumerState<MeshLoadingBackground> createState() => _MeshLoadingBackgroundState();
}

class _MeshLoadingBackgroundState extends ConsumerState<MeshLoadingBackground> with SingleTickerProviderStateMixin {
  List<Offset> prevPositions = gradientPosition;
  List<Offset> nextPositions = gradientPosition;

  Timer? timer;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    timer?.cancel();
    timer = null;
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(themeSwitchProvider);
    return ValueListenableBuilder(
      valueListenable: tabNotifier,
      builder: (context, tabType, child) {
        final isSomethingLoading = ref.watch(shouldUseMockDataProvider)
            ? false
            : ref.watch(loadingStatusProvider.select((v) => v.entries.any((e) => e.value == LoadingState.loading)));
        final result = isSomethingLoading;

        if (result && !widget.doNotAnimate) {
          timer ??= Timer.periodic(Duration(milliseconds: 500), (_) {
            prevPositions = [...nextPositions];
            nextPositions = [
              Offset(Random().nextDouble(), Random().nextDouble()),
              Offset(Random().nextDouble(), Random().nextDouble()),
              Offset(Random().nextDouble(), Random().nextDouble()),
              Offset(Random().nextDouble(), Random().nextDouble()),
            ];
            setState(() {});
          });
        } else {
          timer?.cancel();
          timer = null;
        }

        return Opacity(
          opacity: PlatformX.isMobileView ? 0.25 : 0.1,
          child: ShaderLoader(
            builder: (context, init) => AnimatedContainer(
              duration: Duration(milliseconds: 500),
              decoration: BoxDecoration(
                gradient: MeshGradient(
                  colors: [context.primary, context.secondary, context.error, context.errorContainer],
                  offsets: nextPositions,
                  strengths: [1, 1, 1, 1],
                  sigmas: [0.5, 0.2, 0.3, 0.2],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
