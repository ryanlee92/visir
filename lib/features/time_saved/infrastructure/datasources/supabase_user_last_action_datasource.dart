import 'package:Visir/features/time_saved/domain/datasources/user_last_action_datasource.dart';
import 'package:Visir/features/time_saved/domain/entities/user_action_entity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseUserLastActionDatasource extends UserLastActionDatasource {
  SupabaseClient get client => Supabase.instance.client;
  final userLastActionDatabaseTable = 'user_last_actions';

  RealtimeChannel? userLastActionChannel;

  @override
  Future<void> saveLastUserAction({required String userId, required UserActionEntity lastAction}) async {
    await client.from(userLastActionDatabaseTable).upsert({'user_id': userId, 'last_action': lastAction.toJson()});
  }

  @override
  Future<void> attachListener({required String userId, required Function(UserActionEntity p1) onUpdate}) async {
    await userLastActionChannel?.unsubscribe();
    userLastActionChannel = client.realtime
        .channel(userLastActionDatabaseTable)
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: userLastActionDatabaseTable,
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) {
            UserActionEntity action = UserActionEntity.fromJson(payload.newRecord['last_action']);
            onUpdate(action);
          },
        )
        .subscribe();
  }

  @override
  Future<UserActionEntity?> fetchLastUserAction({required String userId}) async {
    final result = await client.from(userLastActionDatabaseTable).select().eq('user_id', userId).limit(1);
    return result.map((e) => UserActionEntity.fromJson(e['last_action'])).toList().firstOrNull;
  }
}
