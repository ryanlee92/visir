import 'package:Visir/features/task/domain/datasources/project_datasource.dart';
import 'package:Visir/features/task/domain/entities/project_entity.dart';
import 'package:collection/collection.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class SupabaseProjectDatasource implements ProjectDatasource {
  SupabaseClient get client => Supabase.instance.client;
  final projectDatabaseTable = 'projects';
  final taskDatabaseTable = 'tasks';

  @override
  Future<List<ProjectEntity>> fetchProjects({required String userId}) async {
    final result = await client.from(projectDatabaseTable).select().eq('owner_id', userId).order('created_at');
    final allProjects = (result as List).map((e) => ProjectEntity.fromJson(e, local: false)).toList(); // Supabase는 암호화됨
    // final nonProjectColors = await client.rpc('get_unique_colors', params: {'uid': userId});

    List<ProjectEntity> colorProjects = [];
    // try {
    //   colorProjects = nonProjectColors
    //       .where((e) => e['color'] != null && !allProjects.any((p) => p.uniqueId == e['color']))
    //       .map(
    //         (e) => ProjectEntity(
    //           id: Uuid().v4(),
    //           color: ColorX.fromHex(e['color']!),
    //           ownerId: userId,
    //           name: ColorX.fromHex(e['color']!).name.toSentenceCase(),
    //           colorId: e['color'],
    //           icon: null,
    //           createdAt: DateTime(0),
    //           updatedAt: DateTime(0),
    //         ),
    //       )
    //       .whereType<ProjectEntity>()
    //       .toList();
    // } catch (e) {}

    final finalProjects = [...allProjects, ...colorProjects];

    return finalProjects.map((e) {
      if (e.parentId == null) return e;
      final parent = finalProjects.firstWhereOrNull((p) => p.isParent(e.parentId!));
      if (parent != null) return e.copyWith(parentId: parent.uniqueId, icon: e.icon);
      return e.copyWith(parentId: null, icon: e.icon);
    }).toList();
  }

  @override
  Future<void> saveProject({required ProjectEntity project}) async {
    await client
        .from(projectDatabaseTable)
        .upsert(
          project
              .copyWith(parentId: project.parentId, icon: project.icon, createdAt: project.createdAt?.year == 0 ? DateTime.now() : project.createdAt, updatedAt: DateTime.now())
              .toJson(local: false), // Supabase는 암호화됨
        );
  }

  @override
  Future<void> deleteProject({required String projectId}) async {
    if (Uuid.isValidUUID(fromString: projectId)) {
      await client.from(projectDatabaseTable).delete().eq('id', projectId);
    } else {
      await client.from(projectDatabaseTable).delete().eq('color_id', projectId);
    }
  }

  @override
  Future<void> inviteUserToProject({required String projectId, required String email}) async {
    final client = Supabase.instance.client;
    // 1. Find user by email
    // Note: This assumes you have a way to look up users by email.
    // If RLS prevents this, you might need an Edge Function or a specific RPC.
    // For now, we'll try to query the 'users' table if exposed, or use a known method.
    // Since standard Supabase auth doesn't expose 'users' table to public,
    // we might need to rely on the user knowing the UUID or having a public profile table.
    // Assuming a 'profiles' table exists or similar public user table.
    // If not, we can't easily look up by email client-side without an Edge Function.

    // WORKAROUND: We will try to insert into project_members directly if we had the ID.
    // But since we only have email, we need to find the ID.
    // Let's assume there is a 'profiles' table or we can use an RPC.
    // For this implementation, I will assume an RPC 'get_user_id_by_email' exists OR
    // I will try to fetch from a 'profiles' table if it exists.

    // Let's check if we can use a simple query on a hypothetical public profiles table.
    // If not, I'll implement a placeholder that throws an error explaining the need for backend logic.

    try {
      // Try to find user in a public 'profiles' table (common pattern)
      final response = await client.from('profiles').select('id').eq('email', email).maybeSingle();

      if (response == null) {
        throw Exception('User not found');
      }

      final userId = response['id'] as String;

      await client.from('project_members').insert({
        'project_id': projectId,
        'user_id': userId,
        'role': 'viewer', // Default role
      });
    } catch (e) {
      // Fallback or rethrow
      throw Exception('Could not invite user. Ensure "profiles" table exists and is accessible, or use an Edge Function.');
    }
  }

  @override
  Future<void> removeUserFromProject({required String projectId, required String userId}) async {
    final client = Supabase.instance.client;
    await client.from('project_members').delete().eq('project_id', projectId).eq('user_id', userId);
  }

  @override
  Future<void> moveProject({required String projectId, required String? newParentId}) async {
    if (Uuid.isValidUUID(fromString: projectId)) {
      await client.from(projectDatabaseTable).update({'parent_id': newParentId}).eq('id', projectId);
    } else {
      await client.from(projectDatabaseTable).update({'parent_id': newParentId}).eq('color_id', projectId);
    }
  }
}
