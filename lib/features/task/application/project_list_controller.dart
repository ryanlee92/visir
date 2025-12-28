import 'dart:async';
import 'dart:convert';

import 'package:Visir/config/providers.dart';
import 'package:Visir/features/auth/application/auth_controller.dart';
import 'package:Visir/features/common/presentation/utils/extensions/color_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/common/presentation/widgets/visir_icon.dart';
import 'package:Visir/features/common/provider.dart';
import 'package:Visir/features/task/domain/entities/project_entity.dart';
import 'package:Visir/features/task/domain/repositories/project_repository.dart';
import 'package:Visir/features/task/providers.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/experimental/persist.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'project_list_controller.g.dart';

@riverpod
class ProjectListController extends _$ProjectListController {
  late bool isSignedIn;
  static final String stringKey = 'global:project_list';
  late ProjectListControllerInternal _controller;

  @override
  List<ProjectEntity> build() {
    isSignedIn = ref.watch(authControllerProvider.select((v) => v.requireValue.isSignedIn));
    _controller = ref.watch(projectListControllerInternalProvider(isSignedIn: isSignedIn).notifier);

    if (ref.watch(shouldUseMockDataProvider)) {
      // Mock data 사용 시 즉시 mock projects 반환
      final mockProjects = _controller.getMockProjects();
      return mockProjects;
    }

    if (ref.watch(shouldUseMockDataProvider)) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        updateState([]);
      });
      return [];
    }

    ref.listen(projectListControllerInternalProvider(isSignedIn: isSignedIn), (previous, next) {
      updateState(next.value ?? []);
    });

    SchedulerBinding.instance.addPostFrameCallback((_) {
      load();
    });

    return [];
  }

  Future<List<ProjectEntity>> load() async {
    return _controller.load();
  }

  Future<void> addProject(ProjectEntity project) async {
    await _controller.addProject(project);
  }

  Future<void> deleteProject(String projectId) async {
    await _controller.deleteProject(projectId);
  }

  Future<void> moveProject(String projectId, String? newParentId) async {
    await _controller.moveProject(projectId, newParentId);
  }

  Timer? timer;
  List<ProjectEntity> updateState(List<ProjectEntity> projects) {
    if (timer == null) _updateState(projects);
    timer?.cancel();
    timer = Timer(const Duration(milliseconds: kControllerDebouncMillisecond), () {
      _updateState(projects);
      timer = null;
    });

    return projects;
  }

  void _updateState(List<ProjectEntity> projects) {
    final userId = ref.read(authControllerProvider.select((e) => e.requireValue.id));
    if (projects.any((e) => e.isDefault)) {
      state = [
        ...projects.where((e) => e.isDefault),
        ...projects.where((e) => !e.isDefault).toList()..sort((b, a) => (a.updatedAt ?? a.createdAt ?? DateTime(0)).compareTo(b.updatedAt ?? b.createdAt ?? DateTime(0))),
      ];
      return;
    }

    state = [
      ProjectEntity(id: userId, name: 'My Project', color: Utils.mainContext.primary, icon: VisirIconType.star, parentId: null, ownerId: userId),
      ...projects..sort((b, a) => (a.updatedAt ?? a.createdAt ?? DateTime(0)).compareTo(b.updatedAt ?? b.createdAt ?? DateTime(0))),
    ];
  }
}

@riverpod
class ProjectListControllerInternal extends _$ProjectListControllerInternal {
  late ProjectRepository _repository;

  @override
  Future<List<ProjectEntity>> build({required bool isSignedIn}) async {
    _repository = ref.watch(projectRepositoryProvider);

    if (ref.watch(shouldUseMockDataProvider)) {
      return getMockProjects();
    }

    persist(
      ref.watch(storageProvider.future),
      key: '${ProjectListController.stringKey}:${isSignedIn}',
      encode: (List<ProjectEntity> state) => jsonEncode(state.map((e) => e.toJson()).toList()),
      decode: (String encoded) {
        final trimmed = encoded.trim();
        if (trimmed.isEmpty || trimmed == 'null') return [];
        return (jsonDecode(trimmed) as List).map((e) => ProjectEntity.fromJson(e)).toList();
      },
    );

    return load();
  }

  Future<List<ProjectEntity>> load() async {
    if (ref.read(shouldUseMockDataProvider)) {
      return getMockProjects();
    }
    final userId = ref.read(authControllerProvider.select((e) => e.requireValue.id));
    try {
      final projects = await _repository.fetchProjects(userId: userId);
      return projects;
    } catch (e) {
      return state.value ?? [];
    }
  }

  List<ProjectEntity> getMockProjects() {
    final userId = ref.read(authControllerProvider.select((e) => e.requireValue.id));
    final now = DateTime.now();

    // 작은 규모 스타트업 CEO/프리렌서용 mock project 생성
    return [
      // 디폴트 프로젝트 (맨 앞에 배치)
      ProjectEntity(
        id: userId,
        ownerId: userId,
        parentId: null,
        name: 'Personal Development',
        description: 'Learning and skill development',
        color: ColorX.fromHex('#9E9E9E'), // Grey
        icon: VisirIconType.star,
        createdAt: now.subtract(const Duration(days: 12)),
        updatedAt: now.subtract(const Duration(days: 3)),
      ),
      // 일반 프로젝트들
      ProjectEntity(
        id: 'proj_001',
        ownerId: userId,
        parentId: null,
        name: 'Product Launch',
        description: 'Product launch preparation and execution',
        color: ColorX.fromHex('#9C27B0'), // Purple
        icon: VisirIconType.rocket,
        createdAt: now.subtract(const Duration(days: 45)),
        updatedAt: now.subtract(const Duration(days: 2)),
      ),
      ProjectEntity(
        id: 'proj_002',
        ownerId: userId,
        parentId: null,
        name: 'Marketing',
        description: 'Marketing campaigns and brand awareness',
        color: ColorX.fromHex('#2196F3'), // Blue
        icon: VisirIconType.share,
        createdAt: now.subtract(const Duration(days: 40)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
      ProjectEntity(
        id: 'proj_003',
        ownerId: userId,
        parentId: null,
        name: 'Sales & Business Development',
        description: 'Sales pipeline and client acquisition',
        color: ColorX.fromHex('#4CAF50'), // Green
        icon: VisirIconType.integration,
        createdAt: now.subtract(const Duration(days: 35)),
        updatedAt: now.subtract(const Duration(hours: 6)),
      ),
      ProjectEntity(
        id: 'proj_004',
        ownerId: userId,
        parentId: null,
        name: 'Client Projects',
        description: 'Active client work and deliverables',
        color: ColorX.fromHex('#FF9800'), // Orange
        icon: VisirIconType.briefcase,
        createdAt: now.subtract(const Duration(days: 30)),
        updatedAt: now.subtract(const Duration(hours: 3)),
      ),
      ProjectEntity(
        id: 'proj_005',
        ownerId: userId,
        parentId: null,
        name: 'Operations',
        description: 'Administrative and financial operations',
        color: ColorX.fromHex('#795548'), // Brown
        icon: VisirIconType.file,
        createdAt: now.subtract(const Duration(days: 25)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
      ProjectEntity(
        id: 'proj_006',
        ownerId: userId,
        parentId: null,
        name: 'Hiring & Team Building',
        description: 'Recruitment and talent acquisition',
        color: ColorX.fromHex('#f44336'), // Red
        icon: VisirIconType.profile,
        createdAt: now.subtract(const Duration(days: 20)),
        updatedAt: now.subtract(const Duration(hours: 12)),
      ),
      ProjectEntity(
        id: 'proj_007',
        ownerId: userId,
        parentId: null,
        name: 'Finance & Accounting',
        description: 'Budget planning and financial tracking',
        color: ColorX.fromHex('#009688'), // Teal
        icon: VisirIconType.list,
        createdAt: now.subtract(const Duration(days: 18)),
        updatedAt: now.subtract(const Duration(days: 2)),
      ),
      ProjectEntity(
        id: 'proj_008',
        ownerId: userId,
        parentId: null,
        name: 'Customer Support',
        description: 'Customer service and support tickets',
        color: ColorX.fromHex('#00BCD4'), // Cyan
        icon: VisirIconType.chat,
        createdAt: now.subtract(const Duration(days: 15)),
        updatedAt: now.subtract(const Duration(hours: 4)),
      ),
    ];
  }

  Future<void> addProject(ProjectEntity project) async {
    final prevState = state.value ?? [];
    state = AsyncData([...(state.value ?? []).where((e) => e.uniqueId != project.uniqueId), project]);
    try {
      await _repository.saveProject(project: project);
    } catch (e) {
      state = AsyncData(prevState);
    }
  }

  Future<void> deleteProject(String projectId) async {
    final prevState = state.value ?? [];
    state = AsyncData([...(state.value ?? []).where((e) => e.uniqueId != projectId)]);
    try {
      await _repository.deleteProject(projectId: projectId);
    } catch (e) {
      state = AsyncData(prevState);
    }
  }

  Future<void> moveProject(String projectId, String? newParentId) async {
    final prevState = state.value ?? [];
    state = AsyncData((state.value ?? []).map((e) => e.uniqueId == projectId ? e.copyWith(parentId: newParentId, icon: e.icon) : e).toList());
    try {
      await _repository.moveProject(projectId: projectId, newParentId: newParentId);
    } catch (e) {
      state = AsyncData(prevState);
    }
  }
}
