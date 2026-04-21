import 'dart:ui' show SemanticsAction, Tristate;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../ui/visir_ui.dart';
import '../test_ui_widget.dart';

void main() {
  testWidgets('VisirInput renders label and hint text', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: makeUiTestableWidget(
            child: const VisirInput(
              label: 'Email',
              hintText: 'name@example.com',
            ),
          ),
        ),
      ),
    );

    expect(find.text('Email'), findsOneWidget);
    expect(find.text('name@example.com'), findsOneWidget);
  });

  testWidgets('VisirInput renders the label outside the field', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: makeUiTestableWidget(
            child: const VisirInput(
              label: 'Email',
              hintText: 'name@example.com',
            ),
          ),
        ),
      ),
    );

    expect(find.text('Email'), findsOneWidget);
    expect(find.byKey(const ValueKey('visir-input-shell')), findsOneWidget);
  });

  testWidgets(
    'VisirInput renders leading and trailing buttons outside the text field',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: makeUiTestableWidget(
              child: const VisirInput(
                label: 'Email',
                leading: Icon(Icons.mail_outline),
                suffix: Icon(Icons.arrow_forward),
              ),
            ),
          ),
        ),
      );

      expect(find.byKey(const ValueKey('visir-input-leading')), findsOneWidget);
      expect(find.byKey(const ValueKey('visir-input-suffix')), findsOneWidget);
      expect(find.byType(VisirIconButton), findsNWidgets(2));
    },
  );

  testWidgets('VisirInput shell radius follows control tokens', (tester) async {
    const borders = VisirBorderStates(
      base: VisirBorderState(color: Color(0xFF4263EB), width: 2),
      hover: VisirBorderState(color: Color(0xFF4263EB), width: 2),
      focus: VisirBorderState(color: Color(0xFFD9480F), width: 4),
      disabled: VisirBorderState(color: Color(0xFFADB5BD), width: 2),
    );
    const radius = 28.0;
    final baseTheme = VisirThemeData.fallback();
    final themedData = baseTheme.copyWith(
      components: baseTheme.components.copyWith(
        control: baseTheme.components.control.copyWith(
          borders: borders,
          radius: radius,
        ),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Directionality(
            textDirection: TextDirection.ltr,
            child: VisirTheme(
              data: themedData,
              child: const VisirInput(label: 'Email'),
            ),
          ),
        ),
      ),
    );

    final shell = find.byKey(const ValueKey('visir-input-shell'));
    final baseShell = tester.widget<Container>(shell);
    final baseDecoration = baseShell.decoration as BoxDecoration;
    expect(baseDecoration.borderRadius, BorderRadius.circular(radius));
    expect(baseDecoration.border, isNull);

    await tester.tap(find.byType(TextField));
    await tester.pumpAndSettle();

    final focusedShell = tester.widget<Container>(shell);
    final focusedDecoration = focusedShell.decoration as BoxDecoration;
    expect(focusedDecoration.borderRadius, BorderRadius.circular(radius));
    expect(focusedDecoration.border, isNull);
  });

  testWidgets('VisirCard density changes padding profile', (tester) async {
    await tester.pumpWidget(
      makeUiTestableWidget(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            SizedBox(
              key: ValueKey('compact-card'),
              child: VisirCard(
                density: VisirCardDensity.compact,
                child: Text('Compact'),
              ),
            ),
            SizedBox(
              key: ValueKey('spacious-card'),
              child: VisirCard(
                density: VisirCardDensity.spacious,
                child: Text('Spacious'),
              ),
            ),
          ],
        ),
      ),
    );

    final compact = tester.getSize(find.byKey(const ValueKey('compact-card')));
    final spacious = tester.getSize(
      find.byKey(const ValueKey('spacious-card')),
    );
    expect(spacious.height, greaterThan(compact.height));
  });

  testWidgets('elevated card stays borderless by default', (tester) async {
    await tester.pumpWidget(
      makeUiTestableWidget(
        child: const VisirCard(
          variant: VisirCardVariant.elevated,
          child: Text('Elevated'),
        ),
      ),
    );

    final card = tester.widget<Container>(
      find.descendant(
        of: find.byType(VisirCard),
        matching: find.byType(Container),
      ),
    );
    expect((card.decoration as BoxDecoration).border, isNull);
  });

  testWidgets('outlined card can opt into base border', (tester) async {
    await tester.pumpWidget(
      makeUiTestableWidget(
        child: const VisirCard(
          variant: VisirCardVariant.outlined,
          border: VisirCardBorder.base,
          child: Text('Outlined'),
        ),
      ),
    );

    final theme = VisirTheme.of(tester.element(find.byType(VisirCard)));
    final card = tester.widget<Container>(
      find.descendant(
        of: find.byType(VisirCard),
        matching: find.byType(Container),
      ),
    );
    final border = (card.decoration as BoxDecoration).border! as Border;
    expect(border.top.color, theme.components.control.borders.base.color);
    expect(border.top.width, theme.components.control.borders.base.width);
  });

  testWidgets('shadow can be disabled without removing focus treatment', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: makeUiTestableWidget(
            child: VisirCard(
              variant: VisirCardVariant.elevated,
              showShadow: false,
              onTap: () {},
              child: const Text('Focusable'),
            ),
          ),
        ),
      ),
    );

    final cardFinder = find.byType(VisirCard);
    final decorationFinder = find.descendant(
      of: cardFinder,
      matching: find.byWidgetPredicate(
        (widget) => widget is Container && widget.decoration is BoxDecoration,
      ),
    );
    final unfocused =
        tester.widget<Container>(decorationFinder).decoration! as BoxDecoration;
    expect(unfocused.boxShadow, isEmpty);

    final focusNode = Focus.of(tester.element(find.text('Focusable')));
    focusNode.requestFocus();
    await tester.pump();

    final focused =
        tester.widget<Container>(decorationFinder).decoration! as BoxDecoration;
    expect(focused.boxShadow, isNotEmpty);
  });

  testWidgets(
    'VisirCard reads surface role tokens for padding and decoration',
    (tester) async {
      const borders = VisirBorderStates(
        base: VisirBorderState(color: Color(0xFF2B8A3E), width: 3),
        hover: VisirBorderState(color: Color(0xFF2B8A3E), width: 3),
        focus: VisirBorderState(color: Color(0xFFC92A2A), width: 5),
        disabled: VisirBorderState(color: Color(0xFF868E96), width: 2),
      );
      const elevation = VisirSurfaceElevation(
        baseBlur: 9,
        baseOffsetY: 7,
        baseOpacity: 0.41,
        focusBlur: 13,
        focusSpread: 4,
        focusOpacity: 0.67,
      );
      final baseTheme = VisirThemeData.fallback();
      final themedData = baseTheme.copyWith(
        components: baseTheme.components.copyWith(
          surface: baseTheme.components.surface.copyWith(
            padding: const VisirSurfaceDensityScale(
              compact: 14,
              comfortable: 18,
              spacious: 26,
            ),
            radius: 31,
            borders: borders,
            elevation: elevation,
          ),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Directionality(
              textDirection: TextDirection.ltr,
              child: VisirTheme(
                data: themedData,
                child: VisirCard(
                  onTap: () {},
                  density: VisirCardDensity.compact,
                  child: const Text('Token card'),
                ),
              ),
            ),
          ),
        ),
      );

      final decorationFinder = find.descendant(
        of: find.byType(VisirCard),
        matching: find.byWidgetPredicate(
          (widget) => widget is Container && widget.decoration is BoxDecoration,
        ),
      );
      final unfocusedContainer = tester.widget<Container>(decorationFinder);
      final unfocusedDecoration =
          unfocusedContainer.decoration! as BoxDecoration;

      expect(unfocusedContainer.padding, const EdgeInsets.all(14));
      expect(unfocusedDecoration.borderRadius, BorderRadius.circular(31));
      expect(unfocusedDecoration.border, isNull);
      expect(unfocusedDecoration.boxShadow, hasLength(1));
      expect(
        unfocusedDecoration.boxShadow!.single.blurRadius,
        elevation.baseBlur,
      );
      expect(
        unfocusedDecoration.boxShadow!.single.offset.dy,
        elevation.baseOffsetY,
      );
      expect(
        unfocusedDecoration.boxShadow!.single.color,
        themedData.tokens.colors.accent.withValues(
          alpha: elevation.baseOpacity,
        ),
      );

      final focusNode = Focus.of(tester.element(find.text('Token card')));
      focusNode.requestFocus();
      await tester.pump();

      final focusedDecoration =
          tester.widget<Container>(decorationFinder).decoration!
              as BoxDecoration;

      expect(focusedDecoration.border, isNull);
      expect(focusedDecoration.boxShadow, hasLength(2));
      expect(focusedDecoration.boxShadow!.last.blurRadius, elevation.focusBlur);
      expect(
        focusedDecoration.boxShadow!.last.spreadRadius,
        elevation.focusSpread,
      );
      expect(
        focusedDecoration.boxShadow!.last.color,
        themedData.tokens.colors.accent.withValues(
          alpha: elevation.focusOpacity,
        ),
      );
    },
  );

  testWidgets('VisirBadge shows label', (tester) async {
    await tester.pumpWidget(
      makeUiTestableWidget(child: const VisirBadge(label: 'Beta')),
    );

    expect(find.text('Beta'), findsOneWidget);

    final label = tester.widget<Text>(find.text('Beta'));
    final theme = VisirTheme.of(tester.element(find.byType(VisirBadge)));

    expect(label.style?.fontSize, theme.text.label.fontSize);
    expect(label.style?.fontWeight, theme.text.label.fontWeight);
    expect(label.style?.height, theme.text.label.height);
    expect(label.style?.color, theme.tokens.colors.text);
  });

  testWidgets('VisirBadge reads content role tokens for padding and radius', (
    tester,
  ) async {
    final baseTheme = VisirThemeData.fallback();
    final themedData = baseTheme.copyWith(
      components: baseTheme.components.copyWith(
        content: baseTheme.components.content.copyWith(
          paddingHorizontal: 21,
          paddingVertical: 9,
          radius: 17,
        ),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Directionality(
            textDirection: TextDirection.ltr,
            child: VisirTheme(
              data: themedData,
              child: const VisirBadge(label: 'Beta'),
            ),
          ),
        ),
      ),
    );

    final container = tester.widget<Container>(
      find.descendant(
        of: find.byType(VisirBadge),
        matching: find.byType(Container),
      ),
    );
    final decoration = container.decoration! as BoxDecoration;

    expect(
      container.padding,
      const EdgeInsets.symmetric(horizontal: 21, vertical: 9),
    );
    expect(decoration.borderRadius, BorderRadius.circular(17));
  });

  testWidgets(
    'actionable VisirCard exposes button semantics and keyboard activation',
    (tester) async {
      final semantics = tester.ensureSemantics();
      var tapCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: makeUiTestableWidget(
              child: VisirCard(
                onTap: () => tapCount += 1,
                child: const Text('Open task'),
              ),
            ),
          ),
        ),
      );

      final semanticsData = tester
          .getSemantics(find.byType(VisirCard))
          .getSemanticsData();
      expect(semanticsData.label, 'Open task');
      expect(semanticsData.flagsCollection.isButton, isTrue);
      expect(semanticsData.flagsCollection.isFocused, isNot(Tristate.none));
      expect(semanticsData.flagsCollection.isEnabled, Tristate.isTrue);
      expect(semanticsData.hasAction(SemanticsAction.tap), isTrue);
      expect(semanticsData.hasAction(SemanticsAction.focus), isTrue);

      final focusNode = Focus.of(tester.element(find.text('Open task')));
      focusNode.requestFocus();
      await tester.pump();

      expect(focusNode.hasPrimaryFocus, isTrue);

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();

      expect(tapCount, 1);

      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();

      expect(tapCount, 2);

      semantics.dispose();
    },
  );

  testWidgets('actionable VisirCard shows a visible focus treatment', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: makeUiTestableWidget(
            child: VisirCard(
              variant: VisirCardVariant.outlined,
              border: VisirCardBorder.base,
              onTap: () {},
              child: const Text('Focusable card'),
            ),
          ),
        ),
      ),
    );

    final decorationFinder = find.descendant(
      of: find.byType(VisirCard),
      matching: find.byWidgetPredicate(
        (widget) => widget is Container && widget.decoration is BoxDecoration,
      ),
    );
    final unfocusedDecoration =
        tester.widget<Container>(decorationFinder).decoration! as BoxDecoration;

    final theme = VisirTheme.of(tester.element(find.byType(VisirCard)));
    final unfocusedBorder = unfocusedDecoration.border! as Border;
    expect(
      unfocusedBorder.top.color,
      theme.components.control.borders.base.color,
    );
    expect(
      unfocusedBorder.top.width,
      theme.components.control.borders.base.width,
    );

    final focusNode = Focus.of(tester.element(find.text('Focusable card')));
    focusNode.requestFocus();
    await tester.pump();

    final focusedDecoration =
        tester.widget<Container>(decorationFinder).decoration! as BoxDecoration;
    final focusedBorder = focusedDecoration.border! as Border;
    expect(
      focusedBorder.top.color,
      theme.components.control.borders.focus.color,
    );
    expect(
      focusedBorder.top.width,
      theme.components.control.borders.focus.width,
    );
  });

  testWidgets('VisirSection renders title and child', (tester) async {
    await tester.pumpWidget(
      makeUiTestableWidget(
        child: const VisirSection(
          title: 'Workspace',
          child: Text('Panel body'),
        ),
      ),
    );

    expect(find.text('Workspace'), findsOneWidget);
    expect(find.text('Panel body'), findsOneWidget);

    final title = tester.widget<Text>(find.text('Workspace'));
    final theme = VisirTheme.of(tester.element(find.byType(VisirSection)));

    expect(title.style?.fontSize, theme.text.title.fontSize);
    expect(title.style?.fontWeight, theme.text.title.fontWeight);
    expect(title.style?.height, theme.text.title.height);
  });

  testWidgets('VisirSection reads spacing from surface role tokens', (
    tester,
  ) async {
    final baseTheme = VisirThemeData.fallback();
    final themedData = baseTheme.copyWith(
      components: baseTheme.components.copyWith(
        surface: baseTheme.components.surface.copyWith(
          padding: const VisirSurfaceDensityScale(
            compact: 23,
            comfortable: 16,
            spacious: 24,
          ),
        ),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Directionality(
            textDirection: TextDirection.ltr,
            child: VisirTheme(
              data: themedData,
              child: const VisirSection(
                title: 'Workspace',
                child: Text('Panel body'),
              ),
            ),
          ),
        ),
      ),
    );

    expect(
      find.descendant(
        of: find.byType(VisirSection),
        matching: find.byWidgetPredicate(
          (widget) => widget is SizedBox && widget.height == 23,
        ),
      ),
      findsOneWidget,
    );
  });

  testWidgets('VisirDivider renders a 1px line across available width', (
    tester,
  ) async {
    await tester.pumpWidget(
      makeUiTestableWidget(
        child: const SizedBox(width: 200, child: VisirDivider()),
      ),
    );

    final sizedBox = tester.widget<SizedBox>(
      find.descendant(
        of: find.byType(VisirDivider),
        matching: find.byWidgetPredicate(
          (widget) => widget is SizedBox && widget.height == 1,
        ),
      ),
    );

    expect(sizedBox.height, 1);
  });

  testWidgets('VisirDivider reads surface border tokens for line thickness', (
    tester,
  ) async {
    const borders = VisirBorderStates(
      base: VisirBorderState(color: Color(0xFF5C7CFA), width: 3),
      hover: VisirBorderState(color: Color(0xFF5C7CFA), width: 3),
      focus: VisirBorderState(color: Color(0xFF5C7CFA), width: 3),
      disabled: VisirBorderState(color: Color(0xFFADB5BD), width: 1),
    );
    final baseTheme = VisirThemeData.fallback();
    final themedData = baseTheme.copyWith(
      components: baseTheme.components.copyWith(
        surface: baseTheme.components.surface.copyWith(borders: borders),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Directionality(
            textDirection: TextDirection.ltr,
            child: VisirTheme(
              data: themedData,
              child: const SizedBox(width: 200, child: VisirDivider()),
            ),
          ),
        ),
      ),
    );

    final sizedBox = tester.widget<SizedBox>(
      find.descendant(
        of: find.byType(VisirDivider),
        matching: find.byWidgetPredicate(
          (widget) => widget is SizedBox && widget.height == borders.base.width,
        ),
      ),
    );
    final coloredBox = tester.widget<ColoredBox>(
      find.descendant(
        of: find.byType(VisirDivider),
        matching: find.byType(ColoredBox),
      ),
    );

    expect(sizedBox.height, borders.base.width);
    expect(coloredBox.color, borders.base.color);
  });

  testWidgets('VisirSpinner renders circular progress with expected size', (
    tester,
  ) async {
    await tester.pumpWidget(
      makeUiTestableWidget(
        child: const VisirSpinner(size: VisirSpinnerSize.lg),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is SizedBox && widget.width == 20 && widget.height == 20,
      ),
      findsOneWidget,
    );
    expect(find.byType(RotationTransition), findsOneWidget);
  });

  testWidgets('VisirSpinner reads feedback role tokens for size and stroke', (
    tester,
  ) async {
    final baseTheme = VisirThemeData.fallback();
    final themedData = baseTheme.copyWith(
      components: baseTheme.components.copyWith(
        feedback: baseTheme.components.feedback.copyWith(
          size: const VisirFeedbackSizeScale(sm: 15, md: 19, lg: 27),
          strokeWidth: 5,
        ),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Directionality(
            textDirection: TextDirection.ltr,
            child: VisirTheme(
              data: themedData,
              child: const VisirSpinner(size: VisirSpinnerSize.lg),
            ),
          ),
        ),
      ),
    );

    final sizedBox = tester.widget<SizedBox>(
      find.descendant(
        of: find.byType(VisirSpinner),
        matching: find.byType(SizedBox),
      ),
    );
    final progress = tester.widget<CircularProgressIndicator>(
      find.byType(CircularProgressIndicator),
    );

    expect(sizedBox.width, 27);
    expect(sizedBox.height, 27);
    expect(progress.strokeWidth, 5);
  });

  testWidgets('VisirSpinner tones resolve to distinct theme colors', (
    tester,
  ) async {
    final baseTheme = VisirThemeData.fallback();
    final themedData = baseTheme.copyWith(
      tokens: baseTheme.tokens.copyWith(
        colors: baseTheme.tokens.colors.copyWith(
          accent: const Color(0xFF0057B8),
          text: const Color(0xFF222222),
          textMuted: const Color(0xFF666666),
          textInverse: const Color(0xFFF2F2F2),
        ),
      ),
    );

    Future<Color> resolveTone(VisirSpinnerTone tone) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Directionality(
              textDirection: TextDirection.ltr,
              child: VisirTheme(
                data: themedData,
                child: VisirSpinner(size: VisirSpinnerSize.md, tone: tone),
              ),
            ),
          ),
        ),
      );

      final spinner = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );
      return (spinner.valueColor as AlwaysStoppedAnimation<Color>).value;
    }

    final neutral = await resolveTone(VisirSpinnerTone.neutral);
    final primary = await resolveTone(VisirSpinnerTone.primary);
    final inverse = await resolveTone(VisirSpinnerTone.inverse);

    expect(neutral, const Color(0xFF666666));
    expect(primary, const Color(0xFF0057B8));
    expect(inverse, const Color(0xFFF2F2F2));
    expect(neutral, isNot(primary));
    expect(primary, isNot(inverse));
    expect(neutral, isNot(inverse));
  });

  testWidgets('VisirEmptyState renders title description and action', (
    tester,
  ) async {
    await tester.pumpWidget(
      makeUiTestableWidget(
        child: VisirEmptyState(
          title: 'No tasks',
          description: 'Create one to get started',
          action: VisirButton(label: 'Create', onPressed: () {}),
        ),
      ),
    );

    expect(find.text('No tasks'), findsOneWidget);
    expect(find.text('Create one to get started'), findsOneWidget);
    expect(find.text('Create'), findsOneWidget);

    final theme = VisirTheme.of(tester.element(find.byType(VisirEmptyState)));
    final title = tester.widget<Text>(find.text('No tasks'));
    final description = tester.widget<Text>(
      find.text('Create one to get started'),
    );

    expect(title.style?.fontSize, theme.text.title.fontSize);
    expect(title.style?.fontWeight, theme.text.title.fontWeight);
    expect(title.style?.height, theme.text.title.height);
    expect(description.style?.fontSize, theme.text.body.fontSize);
    expect(description.style?.fontWeight, theme.text.body.fontWeight);
    expect(description.style?.height, theme.text.body.height);
  });

  testWidgets('VisirEmptyState reads content and surface spacing tokens', (
    tester,
  ) async {
    final baseTheme = VisirThemeData.fallback();
    final themedData = baseTheme.copyWith(
      components: baseTheme.components.copyWith(
        surface: baseTheme.components.surface.copyWith(
          padding: const VisirSurfaceDensityScale(
            compact: 12,
            comfortable: 27,
            spacious: 24,
          ),
        ),
        content: baseTheme.components.content.copyWith(inlineSpacing: 11),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Directionality(
            textDirection: TextDirection.ltr,
            child: VisirTheme(
              data: themedData,
              child: VisirEmptyState(
                title: 'No tasks',
                description: 'Create one to get started',
                action: VisirButton(label: 'Create', onPressed: () {}),
              ),
            ),
          ),
        ),
      ),
    );

    final gaps = tester
        .widgetList<SizedBox>(
          find.descendant(
            of: find.byType(VisirEmptyState),
            matching: find.byType(SizedBox),
          ),
        )
        .map((widget) => widget.height)
        .toList();

    expect(gaps, containsAll(<double?>[11, 27]));
  });
}
