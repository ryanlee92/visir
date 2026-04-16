import 'package:flutter/material.dart';
import 'package:visir_ui/visir_ui.dart';

import '../sections/visir_badge_section.dart';
import '../sections/visir_button_section.dart';
import '../sections/visir_card_section.dart';
import '../sections/visir_divider_section.dart';
import '../sections/visir_empty_state_section.dart';
import '../sections/visir_icon_button_section.dart';
import '../sections/visir_input_section.dart';
import '../sections/visir_section_section.dart';
import '../sections/visir_spinner_section.dart';
import 'showcase_sections.dart';

const showcaseScrollViewKey = ValueKey('showcase-scroll-view');

class ShowcasePage extends StatefulWidget {
  const ShowcasePage({super.key});

  @override
  State<ShowcasePage> createState() => _ShowcasePageState();
}

class _ShowcasePageState extends State<ShowcasePage> {
  final ScrollController _scrollController = ScrollController();
  final Map<String, GlobalKey> _sectionKeys = {
    for (final id in showcaseSectionIds) id: GlobalKey(),
  };

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _jumpTo(String id) async {
    assert(
      showcaseSectionIds.contains(id),
      'Jump target $id must exist in showcaseSectionIds.',
    );
    if (!_scrollController.hasClients) return;
    final targetContext = _sectionKeys[id]?.currentContext;
    if (targetContext == null) return;
    final targetBox = targetContext.findRenderObject() as RenderBox?;
    if (targetBox == null) return;
    final scrollStorageContext =
        _scrollController.position.context.storageContext;
    final scrollBox = scrollStorageContext.findRenderObject() as RenderBox?;
    if (scrollBox == null) return;
    final targetDy = targetBox
        .localToGlobal(Offset.zero, ancestor: scrollBox)
        .dy;
    final targetOffset = _scrollController.offset + targetDy;
    final clampedOffset = targetOffset.clamp(
      _scrollController.position.minScrollExtent,
      _scrollController.position.maxScrollExtent,
    );
    await _scrollController.animateTo(
      clampedOffset.toDouble(),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
    );
  }

  Widget _buildSection(String id, ColorScheme colors) {
    final visirTheme = VisirTheme.of(context);
    final surfaceSpacing = visirTheme.components.surface.padding;
    final contentSpacing = visirTheme.components.content;
    final Widget content = switch (id) {
      'button' => const VisirButtonSection(),
      'icon-button' => const VisirIconButtonSection(),
      'input' => const VisirInputSection(),
      'card' => const VisirCardSection(),
      'badge' => const VisirBadgeSection(),
      'section' => const VisirSectionSection(),
      'divider' => const VisirDividerSection(),
      'spinner' => const VisirSpinnerSection(),
      'empty-state' => const VisirEmptyStateSection(),
      _ => _buildPlaceholderSection(id, colors),
    };
    final description = switch (id) {
      'button' =>
        'Compose action buttons with variants, states, and icon slots.',
      'icon-button' =>
        'Build compact icon-led actions with semantic labels and variants.',
      'input' =>
        'Build labeled inputs with hinting, icon affordances, and validation copy.',
      'card' =>
        'Compose bordered, muted, or elevated surfaces with density and tap behavior.',
      'badge' =>
        'Communicate status and category with semantic tones and concise labeling.',
      'section' => 'Group related content under an optional section title.',
      'divider' => 'Separate stacked content with a low-emphasis line divider.',
      'spinner' =>
        'Represent in-flight work with enum-based loading indicator options.',
      'empty-state' =>
        'Guide users with descriptive empty copy and a clear next action.',
      _ => sectionPlaceholderDescription(id),
    };

    return Container(
      key: _sectionKeys[id],
      width: double.infinity,
      padding: EdgeInsets.all(
        surfaceSpacing.comfortable + contentSpacing.compactSpacing,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            prettySectionTitle(id),
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: contentSpacing.inlineSpacing),
          Text(description, style: Theme.of(context).textTheme.bodyMedium),
          SizedBox(height: surfaceSpacing.comfortable),
          content,
        ],
      ),
    );
  }

  Widget _buildPlaceholderSection(String id, ColorScheme colors) {
    final surfaceSpacing = VisirTheme.of(context).components.surface.padding;

    return Container(
      constraints: const BoxConstraints(minHeight: 120),
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: surfaceSpacing.spacious),
          child: Text(
            'Component area coming soon',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: colors.primary),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final visirTheme = VisirTheme.of(context);
    final surfaceSpacing = visirTheme.components.surface.padding;
    final contentSpacing = visirTheme.components.content;
    final horizontalPadding = MediaQuery.sizeOf(context).width < 720
        ? surfaceSpacing.comfortable
        : surfaceSpacing.spacious;
    final verticalPadding =
        surfaceSpacing.spacious + contentSpacing.compactSpacing;
    final sectionSpacing =
        surfaceSpacing.comfortable + contentSpacing.compactSpacing;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colors.primaryContainer.withValues(alpha: 0.45),
                      colors.surface,
                      colors.secondaryContainer.withValues(alpha: 0.45),
                    ],
                  ),
                ),
              ),
            ),
            SingleChildScrollView(
              key: showcaseScrollViewKey,
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: verticalPadding,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Visir UI',
                        style: theme.textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Interactive component showcase for the visir_ui package.',
                        style: theme.textTheme.titleMedium,
                      ),
                      SizedBox(height: sectionSpacing),
                      Wrap(
                        spacing: surfaceSpacing.compact,
                        runSpacing: contentSpacing.inlineSpacing,
                        children: featuredShowcaseJumpSectionIds.map((id) {
                          return FilledButton.tonal(
                            onPressed: () => _jumpTo(id),
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 11,
                              ),
                            ),
                            child: Text('Jump to ${prettySectionTitle(id)}'),
                          );
                        }).toList(),
                      ),
                      SizedBox(height: verticalPadding),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: showcaseSectionIds
                            .map(
                              (id) => Padding(
                                padding: EdgeInsets.only(
                                  bottom: sectionSpacing,
                                ),
                                child: _buildSection(id, colors),
                              ),
                            )
                            .toList(),
                      ),
                      SizedBox(height: contentSpacing.paddingVertical),
                      Text(
                        'Built for internal component exploration and API discovery.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.outline,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
