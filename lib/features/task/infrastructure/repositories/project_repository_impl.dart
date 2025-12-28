import 'package:Visir/features/task/domain/datasources/project_datasource.dart';
import 'package:Visir/features/task/domain/entities/project_entity.dart';
import 'package:Visir/features/task/domain/repositories/project_repository.dart';

class ProjectRepositoryImpl implements ProjectRepository {
  final ProjectDatasource datasource;

  ProjectRepositoryImpl({required this.datasource});

  @override
  Future<List<ProjectEntity>> fetchProjects({required String userId}) {
    return datasource.fetchProjects(userId: userId);
  }

  @override
  Future<void> saveProject({required ProjectEntity project}) {
    return datasource.saveProject(project: project);
  }

  @override
  Future<void> deleteProject({required String projectId}) {
    return datasource.deleteProject(projectId: projectId);
  }

  @override
  Future<void> inviteUserToProject({required String projectId, required String email}) {
    return datasource.inviteUserToProject(projectId: projectId, email: email);
  }

  @override
  Future<void> removeUserFromProject({required String projectId, required String userId}) {
    return datasource.removeUserFromProject(projectId: projectId, userId: userId);
  }

  @override
  Future<void> moveProject({required String projectId, required String? newParentId}) {
    return datasource.moveProject(projectId: projectId, newParentId: newParentId);
  }
}
