import 'package:Visir/features/auth/application/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/misc.dart';

import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    UncontrolledProviderScope(
      container: ProviderContainer(overrides: [isSignedInProvider], retry: retryOnError),
      child: const ExampleApp(),
    ),
  );
}

Duration? retryOnError(int retryCount, Object error) {
  if (error is ProviderException) return null;
  return Duration(milliseconds: 5000 * (1 << retryCount));
}
