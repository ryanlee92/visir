import 'package:flutter/material.dart';

class CuratedIconOption {
  const CuratedIconOption({
    required this.id,
    required this.label,
    required this.iconData,
    required this.iconExpression,
  });

  final String id;
  final String label;
  final IconData iconData;
  final String iconExpression;
}

const List<CuratedIconOption> curatedIconOptions = [
  CuratedIconOption(
    id: 'add',
    label: 'Add',
    iconData: Icons.add,
    iconExpression: 'Icons.add',
  ),
  CuratedIconOption(
    id: 'arrow-forward',
    label: 'Arrow Forward',
    iconData: Icons.arrow_forward,
    iconExpression: 'Icons.arrow_forward',
  ),
  CuratedIconOption(
    id: 'search',
    label: 'Search',
    iconData: Icons.search,
    iconExpression: 'Icons.search',
  ),
  CuratedIconOption(
    id: 'mail',
    label: 'Mail',
    iconData: Icons.mail_outline,
    iconExpression: 'Icons.mail_outline',
  ),
  CuratedIconOption(
    id: 'star',
    label: 'Star',
    iconData: Icons.star_outline,
    iconExpression: 'Icons.star_outline',
  ),
];

CuratedIconOption? curatedIconById(String id) {
  for (final option in curatedIconOptions) {
    if (option.id == id) {
      return option;
    }
  }
  return null;
}
