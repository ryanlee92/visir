import 'package:Visir/features/common/presentation/widgets/visir_button.dart';
import 'package:flutter/material.dart';

class ButtonRow extends StatelessWidget {
  const ButtonRow({super.key, required this.onSavePressed});

  final void Function() onSavePressed;

  @override
  Widget build(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
          child: VisirButton(
            type: VisirButtonAnimationType.scaleAndOpacity,
            style: VisirButtonStyle(),
            onTap: () {
              Navigator.of(context).pop<DateTime>();
            },
            child: Text(
              localizations.cancelButtonLabel,
            ),
          ),
        ),
        const SizedBox(
          height: 20,
          child: VerticalDivider(),
        ),
        Expanded(
          child: VisirButton(
            type: VisirButtonAnimationType.scaleAndOpacity,
            style: VisirButtonStyle(),
            onTap: onSavePressed,
            child: Text(
              localizations.okButtonLabel,
            ),
          ),
        ),
      ],
    );
  }
}
