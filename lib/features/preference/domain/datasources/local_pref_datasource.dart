import 'package:Visir/features/preference/domain/entities/local_pref_entity.dart';

abstract class LocalPrefDatasource {
  Future<LocalPrefEntity> getPref();
}
