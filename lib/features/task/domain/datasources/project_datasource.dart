import 'package:Visir/features/task/domain/entities/project_entity.dart';

abstract class ProjectDatasource {
  Future<List<ProjectEntity>> fetchProjects({required String userId});
  Future<void> saveProject({required ProjectEntity project});
  Future<void> deleteProject({required String projectId});
  Future<void> inviteUserToProject({required String projectId, required String email});
  Future<void> removeUserFromProject({required String projectId, required String userId});
  Future<void> moveProject({required String projectId, required String? newParentId});
}
