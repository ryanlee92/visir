import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:flutter/material.dart';

/// Default error page
class ErrorScreen extends StatelessWidget {
  /// Default constructor for the [ErrorScreen]
  const ErrorScreen({required this.message, super.key});

  /// Error message displayed on the [ErrorScreen]
  final String message;

  @override
  Widget build(BuildContext context) {
    // Todo: let's stylize it at some point
    return Material(
      color: context.background,
      child: Center(child: Text(message)),
    );
  }
}
