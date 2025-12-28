import 'dart:math';

import 'package:Visir/config/providers.dart';
import 'package:Visir/dependency/contextmenu/src/ContextMenuArea.dart';
import 'package:Visir/dependency/custom_dialog/flutter_custom_dialog.dart';
import 'package:Visir/dependency/master_detail_flow/src/details_item.dart';
import 'package:Visir/dependency/modal_bottom_sheet/src/utils/modal_scroll_controller.dart';
import 'package:Visir/features/auth/application/auth_controller.dart';
import 'package:Visir/features/common/presentation/utils/extensions/color_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/list_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/platform_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/common/presentation/widgets/desktop_scaffold.dart';
import 'package:Visir/features/common/presentation/widgets/popup_menu.dart';
import 'package:Visir/features/common/presentation/widgets/visir_button.dart';
import 'package:Visir/features/common/presentation/widgets/visir_icon.dart';
import 'package:Visir/features/common/presentation/widgets/visir_list_item.dart';
import 'package:Visir/features/common/presentation/widgets/visir_list_section.dart';
import 'package:Visir/features/task/application/project_list_controller.dart';
import 'package:Visir/features/task/domain/entities/project_entity.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

class ProjectManagementScreen extends ConsumerStatefulWidget {
  final bool isSmall;

  final VoidCallback? onClose;

  const ProjectManagementScreen({super.key, required this.isSmall, this.onClose});

  @override
  ConsumerState<ProjectManagementScreen> createState() => _ProjectManagementScreenState();
}

class _ProjectManagementScreenState extends ConsumerState<ProjectManagementScreen> {
  String? _creatingProjectParentId;
  ProjectEntity? _editingProject;

  ScrollController? _scrollController;

  bool isDragging = false;
  final double spacing = 12.0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _scrollController?.dispose();
    widget.onClose?.call();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _scrollController ??= ModalScrollController.ofSyncGroup(context)?.addAndGet() ?? ScrollController();
    final userId = ref.read(authControllerProvider.select((e) => e.requireValue.id));
    final projects = ref.watch(projectListControllerProvider.select((v) => [...v])).unique((e) => e.uniqueId).toList()
      ..sort(
        (b, a) => a.uniqueId == userId
            ? 1
            : b.uniqueId == userId
            ? -1
            : (a.updatedAt ?? a.createdAt ?? DateTime(0)).compareTo(b.updatedAt ?? b.createdAt ?? DateTime(0)),
      );

    // Build hierarchy
    final List<ProjectEntity> rootProjects = projects.where((e) => e.parentId == null).toList();

    return DetailsItem(
      title: widget.isSmall ? context.tr.project_pref_title : null,
      appbarColor: context.background,
      bodyColor: context.background,
      scrollController: _scrollController,
      scrollPhysics: Utils.getScrollPhysicsForBottomSheet(context, _scrollController),
      children: [
        DragTarget<String>(
          onAcceptWithDetails: (detilas) {
            final draggedProjectId = detilas.data;
            ref.read(projectListControllerProvider.notifier).moveProject(draggedProjectId, null);
          },
          builder: (BuildContext context, List<String?> candidateData, List<dynamic> rejectedData) {
            return VisirListSection(
              removeTopMargin: true,
              hoverDisabled: !isDragging,
              onTap: isDragging ? () {} : null,
              titleBuilder: (height, baseStyle, subStyle, horizontalSpacing) => TextSpan(text: 'Root', style: baseStyle),
              titleTrailingBuilder: (height, baseStyle, subStyle, horizontalSpacing) => TextSpan(
                children: [
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: VisirButton(
                      type: VisirButtonAnimationType.scale,
                      style: VisirButtonStyle(padding: EdgeInsets.all(6), borderRadius: BorderRadius.circular(6)),
                      onTap: () {
                        _editingProject = null;
                        _creatingProjectParentId = 'root';
                        setState(() {});
                      },
                      child: VisirIcon(
                        type: VisirIconType.addWithCircle,
                        size: context.bodyLarge!.fontSize! * context.bodyLarge!.height!,
                        isSelected: true,
                        color: context.outline,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),

        ...[
          if (_creatingProjectParentId == 'root')
            _InlineProjectCreator(
              parentId: null,
              onCancel: () {
                setState(() {
                  _editingProject = null;
                  _creatingProjectParentId = null;
                });
              },
              onSubmit: (name, color, icon) async {
                setState(() {
                  _editingProject = null;
                  _creatingProjectParentId = null;
                });
              },
            ),

          ...rootProjects.map((p) => _buildProjectTile(p)),

          SizedBox(height: 50),
        ],
      ],
    );
  }

  bool _isProjectInCurrentChild(String draggedProjectId, String targetProjectId) {
    final projects = ref.read(projectListControllerProvider.select((v) => [...v])).unique((e) => e.uniqueId).toList();
    if (draggedProjectId == targetProjectId) return true;
    final parentProject = ref.watch(projectListControllerProvider).firstWhereOrNull((p) => p.uniqueId == draggedProjectId);
    if (parentProject == null) return false;
    if (projects.where((e) => parentProject.isParent(e.parentId ?? 'dump')).any((e) => e.uniqueId == targetProjectId) == true) return true;
    final result = projects.where((e) => parentProject.isParent(e.parentId ?? 'dump')).map((e) => _isProjectInCurrentChild(e.uniqueId, targetProjectId));
    if (result.isEmpty) return false;
    return result.any((e) => e);
  }

  Widget _buildProjectTile(ProjectEntity project, {int depth = 0}) {
    final projects = ref.read(projectListControllerProvider.select((v) => [...v])).unique((e) => e.uniqueId).toList();

    return Column(
      children: [
        if (_editingProject?.uniqueId != project.uniqueId)
          DragTarget<String>(
            onAcceptWithDetails: (detilas) {
              final draggedProjectId = detilas.data;
              if (_isProjectInCurrentChild(draggedProjectId, project.uniqueId)) return;
              ref.read(projectListControllerProvider.notifier).moveProject(draggedProjectId, project.uniqueId);
            },
            builder: (context, candidateData, rejectedData) {
              final feedback = Material(
                elevation: 0,
                borderRadius: BorderRadius.circular(6),
                color: Colors.transparent,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  width: 280,
                  decoration: BoxDecoration(
                    color: context.surface,
                    borderRadius: BorderRadius.circular(DesktopScaffold.cardRadius),
                    boxShadow: PopupMenu.popupShadow,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(6),
                        decoration: BoxDecoration(color: project.color ?? context.primary, borderRadius: BorderRadius.circular(6)),
                        child: VisirIcon(
                          type: project.icon != null
                              ? VisirIconType.values.firstWhere((e) => e.name == project.icon, orElse: () => VisirIconType.project)
                              : VisirIconType.project,
                          size: 14,
                          color: Colors.white,
                          isSelected: true,
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(child: Text(project.name, style: context.bodyLarge?.textColor(context.onBackground))),
                    ],
                  ),
                ),
              );

              final iconType = project.icon;

              final child = Padding(
                padding: EdgeInsets.only(left: depth * spacing),
                child: VisirListItem(
                  addTopMargin: false,
                  verticalMarginOverride: 3,
                  verticalPaddingOverride: 6,
                  sectionBuilder: project.isDefault ? (height, baseStyle, subStyle, horizontalSpacing) => TextSpan(text: context.tr.default_project) : null,
                  titleBuilder: (height, baseStyle, subStyle, horizontalSpacing) => TextSpan(
                    style: baseStyle,
                    children: [
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: Padding(
                          padding: EdgeInsets.only(right: horizontalSpacing + 4),
                          child: Container(
                            width: height * 3 / 2,
                            height: height * 3 / 2,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(color: project.color ?? context.primary, borderRadius: BorderRadius.circular(6)),
                            child: iconType == null ? null : VisirIcon(type: iconType, color: Colors.white, isSelected: true, size: height),
                          ),
                        ),
                      ),
                      TextSpan(text: project.name, style: baseStyle),
                    ],
                  ),

                  titleTrailingBuilder: (height, baseStyle, subStyle, horizontalSpacing) => TextSpan(
                    children: [
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: VisirButton(
                          type: VisirButtonAnimationType.scale,
                          style: VisirButtonStyle(padding: EdgeInsets.all(6), borderRadius: BorderRadius.circular(6)),
                          onTap: () {
                            setState(() {
                              _editingProject = null;
                              _creatingProjectParentId = project.uniqueId;
                            });
                          },
                          child: VisirIcon(type: VisirIconType.addWithCircle, size: height, isSelected: true, color: context.outline),
                        ),
                      ),
                    ],
                  ),
                  detailsBuilder: project.description?.isNotEmpty != true
                      ? null
                      : (height, baseStyle, subStyle, horizontalSpacing) => Text(project.description!, style: baseStyle),
                  onTap: () {
                    _editingProject = project;
                    _creatingProjectParentId = null;
                    setState(() {});
                  },
                ),
              );

              if (project.isDefault) {
                return child;
              }

              if (PlatformX.isDesktop) {
                return Draggable<String>(
                  data: project.uniqueId,
                  feedback: feedback,
                  childWhenDragging: Opacity(opacity: 0.5, child: child),
                  child: child,
                  onDragStarted: () {
                    setState(() {
                      isDragging = true;
                    });
                  },
                  onDragEnd: (details) {
                    setState(() {
                      isDragging = false;
                    });
                  },
                );
              } else {
                return LongPressDraggable<String>(
                  data: project.uniqueId,
                  feedback: feedback,
                  childWhenDragging: Opacity(opacity: 0.5, child: child),
                  child: child,
                  onDragStarted: () {
                    setState(() {
                      isDragging = true;
                    });
                  },
                  onDragEnd: (details) {
                    setState(() {
                      isDragging = false;
                    });
                  },
                );
              }
            },
          ),

        if (_creatingProjectParentId == project.uniqueId || _editingProject?.uniqueId == project.uniqueId)
          Padding(
            padding: EdgeInsets.only(left: _editingProject?.uniqueId == project.uniqueId ? depth * spacing : (depth + 1) * spacing),
            child: _InlineProjectCreator(
              editingProject: _editingProject,
              parentId: _creatingProjectParentId,
              onCancel: () {
                setState(() {
                  _editingProject = null;
                  _creatingProjectParentId = null;
                });
              },
              onSubmit: (name, color, icon) async {
                setState(() {
                  _editingProject = null;
                  _creatingProjectParentId = null;
                });
              },
            ),
          ),

        if (projects.where((e) => project.isParent(e.parentId)).isNotEmpty)
          ...projects.where((e) => project.isParent(e.parentId)).map((child) => _buildProjectTile(child, depth: depth + 1)),
      ],
    );
  }
}

const projectIcons = [
  VisirIconType.rocket,
  VisirIconType.target,
  VisirIconType.flag,
  VisirIconType.star,
  VisirIconType.heart,
  VisirIconType.diamond,
  VisirIconType.crown,
  VisirIconType.medal,
  VisirIconType.fire,
  VisirIconType.flash,
  VisirIconType.leaf,
  VisirIconType.briefcase,
  VisirIconType.book,
  VisirIconType.bulb,
  VisirIconType.puzzle,
  null,
];

class _InlineProjectCreator extends ConsumerStatefulWidget {
  final String? parentId;
  final ProjectEntity? editingProject;
  final VoidCallback onCancel;
  final Function(String name, Color? color, String? icon) onSubmit;

  const _InlineProjectCreator({required this.parentId, required this.onCancel, required this.onSubmit, this.editingProject});

  @override
  ConsumerState<_InlineProjectCreator> createState() => _InlineProjectCreatorState();
}

class _InlineProjectCreatorState extends ConsumerState<_InlineProjectCreator> {
  final FocusNode _focusNode = FocusNode();
  final FocusNode _descFocusNode = FocusNode();

  late Color _selectedColor;
  late VisirIconType? _selectedIcon;
  late TextEditingController _controller;
  late TextEditingController _descriptionController;
  late String? _parentId;
  late String _id;

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
    _selectedColor = widget.editingProject?.color ?? accountColors[Random().nextInt(accountColors.length)];
    _selectedIcon = widget.editingProject?.icon;
    _controller = TextEditingController(text: widget.editingProject?.name);
    _descriptionController = TextEditingController(text: widget.editingProject?.description);
    _parentId = widget.editingProject?.parentId ?? widget.parentId;
    _id = widget.editingProject?.uniqueId ?? Uuid().v4();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _descFocusNode.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_controller.text.isNotEmpty) {
      await _createProject();
      widget.onSubmit(_controller.text, _selectedColor, _selectedIcon?.name);
    } else {
      widget.onCancel();
    }
  }

  Future<void> _createProject() async {
    final user = ref.read(authControllerProvider).value;
    if (user != null) {
      final newProject = widget.editingProject != null
          ? widget.editingProject!.copyWith(
              parentId: _parentId,
              name: _controller.text,
              description: _descriptionController.text,
              color: _selectedColor,
              icon: _selectedIcon,
              updatedAt: DateTime.now(),
            )
          : ProjectEntity(
              id: _id,
              ownerId: user.id,
              parentId: _parentId,
              name: _controller.text,
              description: _descriptionController.text,
              color: _selectedColor,
              icon: _selectedIcon,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            );

      await ref.read(projectListControllerProvider.notifier).addProject(newProject);
    }
  }

  @override
  Widget build(BuildContext context) {
    return VisirListItem(
      verticalMarginOverride: 3,
      verticalPaddingOverride: 5,
      border: Border.all(color: context.outline),
      sectionBuilder: widget.editingProject?.isDefault == true
          ? (height, baseStyle, subStyle, horizontalSpacing) => TextSpan(text: context.tr.default_project)
          : null,
      titleWidget: (height, baseStyle, subStyle, horizontalSpacing) => Row(
        children: [
          Padding(
            padding: EdgeInsets.only(right: horizontalSpacing),
            child: PopupMenu(
              child: _selectedIcon == null ? Container(width: height, height: height) : VisirIcon(type: _selectedIcon!, isSelected: true, size: height),
              type: ContextMenuActionType.tap,
              location: PopupMenuLocation.bottom,
              width: 330,
              popup: ProjectColorIconSelector(
                color: _selectedColor,
                icon: _selectedIcon,
                onSubmit: (color, icon) {
                  if (color != null) _selectedColor = color;
                  _selectedIcon = icon;
                  setState(() {});
                },
              ),
              style: VisirButtonStyle(backgroundColor: _selectedColor, borderRadius: BorderRadius.circular(6), width: height * 3 / 2, height: height * 3 / 2),
            ),
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              decoration: InputDecoration(
                hintText: context.tr.create_new_project,
                hintStyle: context.titleMedium?.copyWith(color: context.outline),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
                fillColor: Colors.transparent,
                hoverColor: Colors.transparent,
                focusColor: Colors.transparent,
              ),
              style: context.titleMedium?.copyWith(color: context.onBackground),
              onSubmitted: (_) => _submit(),
              onEditingComplete: () => _submit(),
            ),
          ),
        ],
      ),
      detailsBuilder: (height, baseStyle, subStyle, horizontalSpacing) => Column(
        children: [
          SizedBox(height: 1),
          Transform.translate(
            offset: const Offset(-4, 0),
            child: TextField(
              controller: _descriptionController,
              focusNode: _descFocusNode,
              decoration: InputDecoration(
                hintText: context.tr.create_new_project_description,
                hintStyle: context.bodyLarge?.copyWith(color: context.outline),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
                fillColor: Colors.transparent,
                hoverColor: Colors.transparent,
                focusColor: Colors.transparent,
              ),
              style: baseStyle,
              onSubmitted: (_) => _submit(),
              onEditingComplete: () => _submit(),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              VisirButton(
                type: VisirButtonAnimationType.scale,
                style: VisirButtonStyle(borderRadius: BorderRadius.circular(6), width: 32, height: 32),
                onTap: _submit,
                child: VisirIcon(type: VisirIconType.check, isSelected: true, size: height),
              ),

              VisirButton(
                type: VisirButtonAnimationType.scale,
                style: VisirButtonStyle(borderRadius: BorderRadius.circular(6), width: 32, height: 32),
                onTap: widget.onCancel,
                child: VisirIcon(type: VisirIconType.close, size: height, isSelected: true),
              ),

              if (widget.editingProject != null && widget.editingProject?.isDefault != true)
                VisirButton(
                  type: VisirButtonAnimationType.scale,
                  style: VisirButtonStyle(borderRadius: BorderRadius.circular(6), width: 32, height: 32),
                  onTap: () => _confirmDelete(context, widget.editingProject!.uniqueId),
                  child: VisirIcon(type: VisirIconType.trash, size: height, isSelected: true),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, String projectId) async {
    final dialog = YYDialog().build(Utils.mainContext)
      ..width = 280
      ..borderRadius = 12
      ..backgroundColor = context.surface
      ..text(
        text: context.tr.confirm_delete_project,
        color: context.onBackground,
        fontSize: context.bodyLarge!.fontSize,
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      )
      ..doubleButton(
        gravity: Gravity.right,
        text1: context.tr.cancel,
        color1: context.onSurfaceVariant,
        fontSize1: context.bodyMedium?.fontSize,
        isClickAutoDismiss: true,
        onTap1: () async {},
        text2: context.tr.delete_confirm_title,
        color2: context.error,
        fontSize2: context.bodyMedium?.fontSize,
        onTap2: () async {
          ref.read(projectListControllerProvider.notifier).deleteProject(projectId);
          // Navigator.of(Utils.mainContext).maybePop();
        },
      );
    dialog.show();
  }
}

class ProjectColorIconSelector extends StatefulWidget {
  final Color? color;
  final VisirIconType? icon;

  final void Function(Color? color, VisirIconType? icon) onSubmit;

  const ProjectColorIconSelector({super.key, this.color, this.icon, required this.onSubmit});

  @override
  State<ProjectColorIconSelector> createState() => _ProjectColorIconSelectorState();
}

class _ProjectColorIconSelectorState extends State<ProjectColorIconSelector> {
  Color? color;
  VisirIconType? icon;

  @override
  void initState() {
    super.initState();
    color = widget.color;
    icon = widget.icon;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
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
                        border: color?.toHex() == c.toHex() ? Border.all(color: context.primary, width: 3, strokeAlign: BorderSide.strokeAlignOutside) : null,
                      ),
                      onTap: () async {
                        widget.onSubmit(c, icon);
                        Navigator.of(context).maybePop();
                      },
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
        Expanded(
          child: Container(
            width: 180,
            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            decoration: BoxDecoration(color: context.surface, borderRadius: BorderRadius.circular(6)),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: projectIcons
                  .map(
                    (c) => VisirButton(
                      type: VisirButtonAnimationType.scaleAndOpacity,
                      style: VisirButtonStyle(
                        cursor: SystemMouseCursors.click,
                        width: 32,
                        height: 32,
                        // backgroundColor: c,
                        borderRadius: BorderRadius.circular(6),
                        border: icon == c ? Border.all(color: context.primary, width: 3, strokeAlign: BorderSide.strokeAlignOutside) : null,
                      ),
                      child: c == null ? Container(width: 20, height: 20) : VisirIcon(type: c, isSelected: true, size: 20),
                      onTap: () async {
                        widget.onSubmit(color, c);
                        Navigator.of(context).maybePop();
                      },
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }
}
