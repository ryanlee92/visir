import 'package:Visir/features/common/presentation/widgets/visir_button.dart';
import 'package:flutter/material.dart';

class AdminMenuItem {
  const AdminMenuItem({
    this.title,
    this.titleOnExpanded,
    required this.route,
    this.icon,
    this.badge,
    this.email,
    this.subtext,
    this.color,
    this.children = const [],
    this.expansionTileHeight,
    this.height,
    this.isSection = false,
    this.isSelected = false,
    this.isToggle,
    this.options,
    this.titleBold = false,
    this.titleColor,
    this.isDraggable = false,
    this.sectionId,
    this.onDragEnded,
    this.id,
  });

  final String? title;
  final String? titleOnExpanded;
  final bool? titleBold;
  final Color? titleColor;
  final String route;
  final String? email;
  final int? badge;
  final Widget Function(double size)? icon;
  final List<AdminMenuItem> children;
  final bool? subtext;
  final Color? color;
  final double? expansionTileHeight;
  final double? height;
  final bool? isSection;
  final bool? isSelected;
  final bool? isToggle;
  final VisirButtonOptions? options;
  final bool? isDraggable;
  final String? sectionId;
  final Function(String sectionId, AdminMenuItem item)? onDragEnded;
  final String? id;
}
