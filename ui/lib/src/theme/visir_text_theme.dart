import 'package:flutter/material.dart';

import '../foundation/visir_colors.dart';

@immutable
class VisirTextThemeData {
  const VisirTextThemeData({
    required this.hero,
    required this.title,
    required this.body,
    required this.label,
    required this.caption,
  });

  final TextStyle hero;
  final TextStyle title;
  final TextStyle body;
  final TextStyle label;
  final TextStyle caption;

  factory VisirTextThemeData.fallback(VisirColors colors) {
    return VisirTextThemeData(
      hero: TextStyle(
        color: colors.text,
        fontSize: 30,
        fontWeight: FontWeight.w800,
        height: 1.1,
      ),
      title: TextStyle(
        color: colors.text,
        fontSize: 22,
        fontWeight: FontWeight.w700,
        height: 1.15,
      ),
      body: TextStyle(
        color: colors.text,
        fontSize: 15,
        fontWeight: FontWeight.w400,
        height: 1.45,
      ),
      label: TextStyle(
        color: colors.text,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        height: 1.2,
      ),
      caption: TextStyle(
        color: colors.textMuted,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.35,
      ),
    );
  }

  VisirTextThemeData copyWith({
    TextStyle? hero,
    TextStyle? title,
    TextStyle? body,
    TextStyle? label,
    TextStyle? caption,
  }) {
    return VisirTextThemeData(
      hero: hero ?? this.hero,
      title: title ?? this.title,
      body: body ?? this.body,
      label: label ?? this.label,
      caption: caption ?? this.caption,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is VisirTextThemeData &&
            hero == other.hero &&
            title == other.title &&
            body == other.body &&
            label == other.label &&
            caption == other.caption;
  }

  @override
  int get hashCode => Object.hash(hero, title, body, label, caption);
}
