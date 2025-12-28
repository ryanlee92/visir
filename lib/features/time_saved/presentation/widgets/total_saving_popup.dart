import 'package:Visir/features/common/presentation/utils/extensions/platform_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/common/presentation/widgets/visir_app_bar.dart';
import 'package:Visir/features/common/presentation/widgets/visir_button.dart';
import 'package:Visir/features/common/presentation/widgets/visir_icon.dart';
import 'package:Visir/features/common/provider.dart';
import 'package:Visir/features/time_saved/application/user_action_switch_list_controller.dart';
import 'package:Visir/features/time_saved/domain/entities/user_action_switch_count_entity.dart';
import 'package:Visir/features/time_saved/presentation/screens/time_saved_screen.dart';
import 'package:Visir/features/time_saved/presentation/widgets/your_saving_widget.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_confetti/flutter_confetti.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TotalSavingPopup extends ConsumerStatefulWidget {
  const TotalSavingPopup({super.key});

  @override
  ConsumerState<TotalSavingPopup> createState() => _TotalSavingPopupState();
}

class _TotalSavingPopupState extends ConsumerState<TotalSavingPopup> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Confetti.launch(
        context,
        options: ConfettiOptions(
          particleCount: 300,
          angle: 90,
          spread: 360,
          startVelocity: 30,
          decay: 0.90,
          gravity: 0.8,
          drift: 0,
          flat: false,
          ticks: 300,
          scalar: 1.0,
          x: PlatformX.isWindows ? 0.15 : 0.85,
          y: 0.3,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final prefHourlyWage = ref.watch(hourlyWageProvider);
    final list = ref.watch(userActionSwitchListControllerProvider(TimeSavedViewType.total).select((v) => v.value));
    list?.sort((a, b) => b.count.compareTo(a.count));

    final timeSaved = list?.totalWastedTime ?? 0;
    final moneySaved = timeSaved * prefHourlyWage;

    return Container(
      decoration: BoxDecoration(color: context.surface, borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          VisirAppBar(
            title: context.tr.time_saved_taskey_helped_you_save_total(Utils.numberFormatter(moneySaved)),
            leadings: [],
            trailings: [
              VisirAppBarButton(
                icon: VisirIconType.close,
                onTap: () => Navigator.pop(context),
                options: VisirButtonOptions(
                  tooltipLocation: VisirButtonTooltipLocation.left,
                  bypassMailEditScreen: true,
                  shortcuts: [
                    VisirButtonKeyboardShortcut(message: context.tr.close, keys: [LogicalKeyboardKey.escape]),
                  ],
                ),
              ),
            ],
          ),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: YourSavingWidget(isTotalSavedPopup: true)),
        ],
      ),
    );
  }
}
