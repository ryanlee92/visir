// visir/packages/visir_design_system/lib/visir_design_system.dart
//
// Library entry for the `visir_design_system` package.
//
// This file re-exports widgets implemented under `lib/src/widgets/` so consumers
// can import a single library import:
//
//   import 'package:visir_design_system/visir_design_system.dart';
//
// and access `VisirButton`, `VisirIcon`, and any other exported design system
// primitives implemented in `lib/src/`.
library visir_design_system;

/// Re-export the individual widget implementations living in `lib/src/widgets/`.
export 'src/widgets/visir_button.dart';
export 'src/widgets/visir_icon.dart';
