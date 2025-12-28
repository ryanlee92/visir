// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project_list_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ProjectListController)
const projectListControllerProvider = ProjectListControllerProvider._();

final class ProjectListControllerProvider
    extends $NotifierProvider<ProjectListController, List<ProjectEntity>> {
  const ProjectListControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'projectListControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$projectListControllerHash();

  @$internal
  @override
  ProjectListController create() => ProjectListController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<ProjectEntity> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<ProjectEntity>>(value),
    );
  }
}

String _$projectListControllerHash() =>
    r'4c9c7243e3d87fe7aed47746b14e04989210fe04';

abstract class _$ProjectListController extends $Notifier<List<ProjectEntity>> {
  List<ProjectEntity> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<List<ProjectEntity>, List<ProjectEntity>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<ProjectEntity>, List<ProjectEntity>>,
              List<ProjectEntity>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(ProjectListControllerInternal)
const projectListControllerInternalProvider =
    ProjectListControllerInternalFamily._();

final class ProjectListControllerInternalProvider
    extends
        $AsyncNotifierProvider<
          ProjectListControllerInternal,
          List<ProjectEntity>
        > {
  const ProjectListControllerInternalProvider._({
    required ProjectListControllerInternalFamily super.from,
    required bool super.argument,
  }) : super(
         retry: null,
         name: r'projectListControllerInternalProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$projectListControllerInternalHash();

  @override
  String toString() {
    return r'projectListControllerInternalProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ProjectListControllerInternal create() => ProjectListControllerInternal();

  @override
  bool operator ==(Object other) {
    return other is ProjectListControllerInternalProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$projectListControllerInternalHash() =>
    r'cb01e8b323c5c5541dc5e022d8fefd116d5376eb';

final class ProjectListControllerInternalFamily extends $Family
    with
        $ClassFamilyOverride<
          ProjectListControllerInternal,
          AsyncValue<List<ProjectEntity>>,
          List<ProjectEntity>,
          FutureOr<List<ProjectEntity>>,
          bool
        > {
  const ProjectListControllerInternalFamily._()
    : super(
        retry: null,
        name: r'projectListControllerInternalProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ProjectListControllerInternalProvider call({required bool isSignedIn}) =>
      ProjectListControllerInternalProvider._(argument: isSignedIn, from: this);

  @override
  String toString() => r'projectListControllerInternalProvider';
}

abstract class _$ProjectListControllerInternal
    extends $AsyncNotifier<List<ProjectEntity>> {
  late final _$args = ref.$arg as bool;
  bool get isSignedIn => _$args;

  FutureOr<List<ProjectEntity>> build({required bool isSignedIn});
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(isSignedIn: _$args);
    final ref =
        this.ref as $Ref<AsyncValue<List<ProjectEntity>>, List<ProjectEntity>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<ProjectEntity>>, List<ProjectEntity>>,
              AsyncValue<List<ProjectEntity>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
