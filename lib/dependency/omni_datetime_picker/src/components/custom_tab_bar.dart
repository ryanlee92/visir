import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:flutter/material.dart';

class CustomTabBar extends StatelessWidget {
  const CustomTabBar({super.key, required this.tabController});

  final TabController tabController;

  @override
  Widget build(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);

    return TabBar(
      controller: tabController,
      indicatorSize: Theme
          .of(context)
          .tabBarTheme
          .indicatorSize ?? TabBarIndicatorSize.tab,
      onTap: (index) {
        tabController.animateTo(index);
      },
      tabs: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            localizations.dateRangeStartLabel,
            style: context.bodyMedium?.textColor(context.onBackground),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            localizations.dateRangeEndLabel,
            style: context.bodyMedium?.textColor(context.onBackground),
          ),
        ),
      ],
    );
  }
}
