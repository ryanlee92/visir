import 'package:Visir/config/providers.dart';
import 'package:Visir/features/auth/application/auth_controller.dart';
import 'package:Visir/features/common/provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'last_app_open_close_date_controller.g.dart';

@Riverpod(keepAlive: true)
DateTime? lastAppOpenCloseDate(Ref ref) {
  final isSignedIn = ref.watch(authControllerProvider.select((v) => v.requireValue.isSignedIn));
  if (!isSignedIn) return null;
  return ref.watch(lastAppOpenCloseDateControllerInternalProvider(isSignedIn: isSignedIn));
}

final lastAppOpenCloseDateControllerNotifierProvider = Provider<LastAppOpenCloseDateControllerInternal>((ref) {
  final isSignedIn = ref.watch(authControllerProvider.select((v) => v.requireValue.isSignedIn));
  return ref.watch(lastAppOpenCloseDateControllerInternalProvider(isSignedIn: isSignedIn).notifier);
});

@Riverpod(keepAlive: true)
class LastAppOpenCloseDateControllerInternal extends _$LastAppOpenCloseDateControllerInternal {
  @override
  DateTime? build({required bool isSignedIn}) {
    if (ref.watch(shouldUseMockDataProvider)) return null;
    if (!isSignedIn) return null;

    // SharedPreferences에서 읽기
    final sharedPrefAsync = ref.read(sharedPreferencesProvider);
    final sharedPref = sharedPrefAsync.asData?.value;
    if (sharedPref == null) return null;
    
    final dateString = sharedPref.getString('last_app_open_close_date');
    if (dateString == null || dateString.isEmpty) return null;
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  Future<void> set(DateTime date) async {
    // SharedPreferences에 저장
    final sharedPref = await ref.read(sharedPreferencesProvider.future);
    await sharedPref.setString('last_app_open_close_date', date.toIso8601String());
    state = date;
  }
}
