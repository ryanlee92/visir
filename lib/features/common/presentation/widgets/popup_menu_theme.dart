import 'package:Visir/features/common/presentation/utils/extensions/platform_extension.dart';
import 'package:flutter/material.dart';

extension ThemeDataX on ThemeData {
  ThemeData get popupTheme => PlatformX.isMobileView
      ? this.copyWith(
          appBarTheme: this.appBarTheme.copyWith(
                titleSpacing: 0,
              ),
        )
      : this.copyWith(
          appBarTheme: this.appBarTheme.copyWith(
                toolbarHeight: 44,
                iconTheme: this.iconTheme.copyWith(size: 20),
                titleTextStyle: this.textTheme.titleSmall,
                titleSpacing: 0,
                shadowColor: Colors.transparent,
                shape: Border(bottom: BorderSide(color: Colors.transparent, width: 0)),
              ),
        );
}
