import 'package:flutter/material.dart';
import 'package:visir_ui/visir_ui.dart';

import 'showcase_component_sidebar.dart';
import 'showcase_sections.dart';

const showcaseScrollViewKey = ValueKey('showcase-scroll-view');

class ShowcasePage extends StatefulWidget {
  const ShowcasePage({
    super.key,
    this.themeMode = ThemeMode.light,
    this.onThemeModeChanged,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode>? onThemeModeChanged;

  @override
  State<ShowcasePage> createState() => _ShowcasePageState();
}

class _ShowcasePageState extends State<ShowcasePage> {
  String _activeSectionId = showcaseSectionIds.first;

  void _selectSection(String id) {
    if (_activeSectionId == id) {
      return;
    }

    setState(() => _activeSectionId = id);
  }

  Widget _buildActiveSection() {
    final ids = showcaseSectionIds;
    final sectionIndex = ids.indexOf(_activeSectionId);

    return IndexedStack(
      index: sectionIndex < 0 ? 0 : sectionIndex,
      children: [
        for (final id in ids)
          KeyedSubtree(
            key: ValueKey('showcase-section-$id'),
            child: showcaseSectionById(id).builder(context),
          ),
      ],
    );
  }

  Widget _buildMainPane(BuildContext context, bool isCompact) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final visirTheme = VisirTheme.of(context);
    final surfaceSpacing = visirTheme.components.surface.padding;
    final contentSpacing = visirTheme.components.content;
    final horizontalPadding = isCompact
        ? surfaceSpacing.comfortable
        : surfaceSpacing.spacious;

    return Container(
      color: colors.surface,
      child: SingleChildScrollView(
        key: showcaseScrollViewKey,
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: surfaceSpacing.comfortable + contentSpacing.compactSpacing,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: _buildActiveSection(),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isCompact = MediaQuery.sizeOf(context).width < 900;

    return Scaffold(
      body: SafeArea(
        top: true,
        child: isCompact
            ? Column(
                children: [
                  SizedBox(
                    height: 112,
                    child: ShowcaseComponentSidebar(
                      groups: showcaseSectionGroups,
                      activeSectionId: _activeSectionId,
                      onSelected: _selectSection,
                      themeMode: widget.themeMode,
                      onThemeModeChanged: widget.onThemeModeChanged,
                    ),
                  ),
                  Expanded(child: _buildMainPane(context, true)),
                ],
              )
            : Row(
                children: [
                  SizedBox(
                    width: 280,
                    child: ShowcaseComponentSidebar(
                      groups: showcaseSectionGroups,
                      activeSectionId: _activeSectionId,
                      onSelected: _selectSection,
                      themeMode: widget.themeMode,
                      onThemeModeChanged: widget.onThemeModeChanged,
                    ),
                  ),
                  Expanded(child: _buildMainPane(context, false)),
                ],
              ),
      ),
    );
  }
}
