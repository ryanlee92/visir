import 'package:Visir/features/preference/domain/entities/oauth_entity.dart';
import 'package:Visir/features/time_saved/infrastructure/datasources/supabase_user_action_switch_datasource.dart';
import 'package:Visir/features/time_saved/infrastructure/datasources/supabase_user_last_action_datasource.dart';
import 'package:Visir/features/time_saved/infrastructure/repositories/user_action_switch_repository.dart';
import 'package:Visir/features/time_saved/infrastructure/repositories/user_last_action_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'providers.g.dart';

@riverpod
SupabaseUserActionSwitchDatasource supabaseUserActionSwitchDatasource(Ref ref) {
  return SupabaseUserActionSwitchDatasource();
}

@riverpod
UserActionSwitchRepository userActionSwitchRepository(Ref ref) {
  return UserActionSwitchRepository(datasources: {DatasourceType.supabase: ref.watch(supabaseUserActionSwitchDatasourceProvider)});
}

@riverpod
SupabaseUserLastActionDatasource supabaseUserLastActionDatasource(Ref ref) {
  return SupabaseUserLastActionDatasource();
}

@riverpod
UserLastActionRepository userLastActionRepository(Ref ref) {
  return UserLastActionRepository(datasources: {DatasourceType.supabase: ref.watch(supabaseUserLastActionDatasourceProvider)});
}
