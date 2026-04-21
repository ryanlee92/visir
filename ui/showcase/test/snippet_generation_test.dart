import 'package:flutter_test/flutter_test.dart';
import 'package:visir_ui_showcase/data/button_snippets.dart';
import 'package:visir_ui_showcase/data/card_snippets.dart';
import 'package:visir_ui_showcase/data/icon_options.dart';
import 'package:visir_ui_showcase/data/input_snippets.dart';
import 'package:visir_ui/visir_ui.dart';

void main() {
  test('button snippet omits default props', () {
    final code = buildButtonSnippet(label: 'Continue');

    expect(code, contains("label: 'Continue'"));
    expect(code, isNot(contains('variant:')));
    expect(code, isNot(contains('size:')));
    expect(code, isNot(contains('isLoading:')));
    expect(code, isNot(contains('isExpanded:')));
    expect(code, contains('onPressed: () {},'));
  });

  test('button snippet includes non-default props', () {
    final code = buildButtonSnippet(
      label: 'Continue',
      variant: VisirButtonVariant.danger,
      size: VisirButtonSize.lg,
      isLoading: true,
      isExpanded: true,
      leadingIcon: curatedIconOptions.first,
      tooltip: 'Delete item',
      enabled: false,
    );

    expect(code, contains('VisirButtonVariant.danger'));
    expect(code, contains('VisirButtonSize.lg'));
    expect(code, contains('isLoading: true'));
    expect(code, contains('isExpanded: true'));
    expect(code, contains('leading: const Icon('));
    expect(code, contains("tooltip: 'Delete item'"));
    expect(code, contains('onPressed: null,'));
  });

  test('icon button snippet uses curated icon output', () {
    final code = buildIconButtonSnippet(
      icon: curatedIconOptions.firstWhere((option) => option.id == 'search'),
      semanticLabel: 'Search',
    );

    expect(code, contains('VisirIconButton('));
    expect(code, contains('icon: const Icon(Icons.search)'));
    expect(code, contains("semanticLabel: 'Search'"));
    expect(code, isNot(contains('variant:')));
  });

  test('input snippet includes only meaningful fields', () {
    final code = buildInputSnippet(
      label: 'Email',
      hintText: 'name@example.com',
      suffixIcon: curatedIconOptions.firstWhere(
        (option) => option.id == 'mail',
      ),
      errorText: 'Invalid address',
      enabled: false,
    );

    expect(code, contains('VisirInput('));
    expect(code, contains("label: 'Email'"));
    expect(code, contains("hintText: 'name@example.com'"));
    expect(code, contains('suffix: const Icon(Icons.mail_outline)'));
    expect(code, contains("errorText: 'Invalid address'"));
    expect(code, contains('enabled: false'));
  });

  test('input snippet omits label when empty', () {
    final code = buildInputSnippet(label: '', hintText: 'name@example.com');

    expect(code, contains('VisirInput('));
    expect(code, contains("hintText: 'name@example.com'"));
    expect(code, isNot(contains('label:')));
  });

  test('input snippet emits border mode when non-default', () {
    final code = buildInputSnippet(
      label: 'Email',
      hintText: 'name@example.com',
      border: VisirInputBorder.success,
    );

    expect(code, contains('VisirInput('));
    expect(code, contains('border: VisirInputBorder.success'));
  });

  test('input snippet includes search mode output when requested', () {
    final code = buildInputSnippet(
      label: 'Search',
      hintText: 'Find projects',
      leadingIcon: curatedIconOptions.firstWhere(
        (option) => option.id == 'search',
      ),
      isLoading: true,
      showClearButton: true,
      maxLines: 3,
    );

    expect(code, contains('VisirInput('));
    expect(code, contains("label: 'Search'"));
    expect(code, contains("hintText: 'Find projects'"));
    expect(code, contains('leading: const Icon(Icons.search)'));
    expect(code, contains('isLoading: true'));
    expect(code, contains('showClearButton: true'));
    expect(code, contains('maxLines: 3'));
    expect(code, isNot(contains('prefix:')));
  });

  test('card snippet omits defaults and adds onTap when interactive', () {
    final defaultCode = buildCardSnippet();
    expect(defaultCode, contains('VisirCard('));
    expect(defaultCode, isNot(contains('variant:')));
    expect(defaultCode, isNot(contains('density:')));
    expect(defaultCode, isNot(contains('border:')));
    expect(defaultCode, isNot(contains('showShadow:')));
    expect(defaultCode, isNot(contains('onTap:')));

    final interactiveCode = buildCardSnippet(
      variant: VisirCardVariant.outlined,
      density: VisirCardDensity.compact,
      border: VisirCardBorder.base,
      showShadow: false,
      isInteractive: true,
    );
    expect(interactiveCode, contains('VisirCardVariant.outlined'));
    expect(interactiveCode, contains('VisirCardDensity.compact'));
    expect(interactiveCode, contains('border: VisirCardBorder.base'));
    expect(interactiveCode, contains('showShadow: false'));
    expect(interactiveCode, contains('onTap: () {},'));
  });
}
