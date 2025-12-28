import 'dart:convert';

import 'package:Visir/features/preference/domain/datasources/local_pref_datasource.dart';
import 'package:Visir/features/preference/domain/entities/local_pref_entity.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesLocalPrefDatasource extends LocalPrefDatasource {
  final SharedPreferences sharedPreferences;

  SharedPreferencesLocalPrefDatasource({required this.sharedPreferences});

  @override
  Future<LocalPrefEntity> getPref() async {
    final prefJson = sharedPreferences.getString('pref');
    if (prefJson == null) return LocalPrefEntity();
    try {
      return LocalPrefEntity.fromJson(jsonDecode(prefJson) as Map<String, dynamic>);
    } catch (e) {
      return LocalPrefEntity();
    }
  }
}
