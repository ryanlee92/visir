import 'package:Visir/config/providers.dart';
import 'package:Visir/features/auth/application/auth_controller.dart';
import 'package:Visir/features/common/presentation/utils/extensions/color_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/common/presentation/widgets/visir_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class MailColorPickerWidget extends ConsumerStatefulWidget {
  final String email;

  const MailColorPickerWidget({Key? key, required this.email}) : super(key: key);

  @override
  _MailColorPickerWidgetState createState() => _MailColorPickerWidgetState();
}

class _MailColorPickerWidgetState extends ConsumerState<MailColorPickerWidget> {
  @override
  Widget build(BuildContext context) {
    final mailColors = ref.watch(authControllerProvider.select((e) => e.requireValue.userMailColors));

    return Container(
      width: 180,
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(color: context.surface, borderRadius: BorderRadius.circular(6)),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: accountColors
            .map(
              (c) => VisirButton(
                type: VisirButtonAnimationType.scaleAndOpacity,
                style: VisirButtonStyle(
                  cursor: SystemMouseCursors.click,
                  width: 32,
                  height: 32,
                  backgroundColor: c,
                  borderRadius: BorderRadius.circular(6),
                  border: mailColors[widget.email] == c.toHex()
                      ? Border.all(color: context.primary, width: 3, strokeAlign: BorderSide.strokeAlignOutside)
                      : null,
                ),
                onTap: () async {
                  context.pop();
                  final user = Utils.ref.read(authControllerProvider).requireValue;
                  final mailColors = {...user.userMailColors};
                  mailColors[widget.email] = c.toHex();
                  await Utils.ref.read(authControllerProvider.notifier).updateUser(user: user.copyWith(mailColors: mailColors));
                },
              ),
            )
            .toList(),
      ),
    );
  }
}
