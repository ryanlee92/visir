import 'package:flutter/material.dart';

class MainTabButton extends StatefulWidget {
  final IconData icon;
  final String text;
  final Color selectedBackgroundColor;
  final bool isSelected;
  final VoidCallback onPressed;

  const MainTabButton(
      {super.key, required this.icon, required this.text, required this.isSelected, required this.onPressed, required this.selectedBackgroundColor});

  @override
  State<MainTabButton> createState() => _MainTabButtonState();
}

class _MainTabButtonState extends State<MainTabButton> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
