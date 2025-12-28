import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:flutter/material.dart';

Container buildDropdown({required Widget child, required BuildContext context}) {
  return Container(
    height: kMinInteractiveDimension,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      color: context.surface,
    ),
    width: double.maxFinite,
    padding: Theme.of(context).buttonTheme.padding,
    child: DropdownButtonHideUnderline(
      child: child,
    ),
  );
}

Column buildElement({
  String? title,
  required Widget child,
  required TextStyle style,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (title != null)
        Padding(
          padding: EdgeInsets.only(left: 8, right: 8, bottom: 12),
          child: Text(
            title,
            style: style,
          ),
        )
      else
        Container(),
      child,
    ],
  );
}

Widget buildContainer({required Widget child}) {
  return child;
}

Widget buildToggleItem({
  required Widget child,
  required void Function(bool) onChanged,
  required String title,
  required bool value,
  required TextStyle style,
}) {
  if (!value) {
    return buildContainer(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 8, right: 8),
              child: Text(
                title,
                style: style,
              ),
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
  return buildContainer(
    child: Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 8, right: 8),
                child: Text(
                  title,
                  style: style,
                ),
              ),
            ),
            Switch(value: value, onChanged: onChanged),
          ],
        ),
        child,
      ],
    ),
  );
}
