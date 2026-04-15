import 'package:flutter/material.dart';

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
      padding: const EdgeInsets.all(20),
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
          const SizedBox(height: 8),
          Text(description, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 16),
          content,
        ],
      ),
    );
  }

  Widget _buildPlaceholderSection(String id, ColorScheme colors) {
    return Container(
      constraints: const BoxConstraints(minHeight: 120),
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
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

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          key: showcaseScrollViewKey,
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
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
                  const SizedBox(height: 12),
                  Text(
                    'Live Visir component playground',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 24),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: featuredShowcaseJumpSectionIds.map((id) {
                      return TextButton(
                        onPressed: () => _jumpTo(id),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 12,
                          ),
                          backgroundColor: colors.primaryContainer,
                          foregroundColor: colors.onPrimaryContainer,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text('Jump to ${prettySectionTitle(id)}'),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 32),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: showcaseSectionIds
                        .map(
                          (id) => Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: _buildSection(id, colors),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Component area coming soon',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.outline,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
