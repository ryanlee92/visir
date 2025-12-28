import 'package:Visir/features/feedback/infrastructure/datasources/supabse_feedback_datasource.dart';
import 'package:Visir/features/feedback/infrastructure/repositories/feedback_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'providers.g.dart';

@riverpod
SupabseFeedbackDatasource supabaseFeedbackDatasource(Ref ref) {
  return SupabseFeedbackDatasource();
}

@riverpod
FeedbackRepository feedbackRepository(Ref ref) {
  return FeedbackRepository(datasource: ref.watch(supabaseFeedbackDatasourceProvider));
}
