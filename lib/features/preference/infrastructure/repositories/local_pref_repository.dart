import 'package:Visir/features/common/domain/failures/failure.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/preference/domain/datasources/local_pref_datasource.dart';
import 'package:Visir/features/preference/domain/entities/local_pref_entity.dart';
import 'package:fpdart/src/either.dart';

class LocalPrefRepository {
  LocalPrefDatasource datasource;

  LocalPrefRepository({required this.datasource});

  Future<Either<Failure, LocalPrefEntity>> getPref() async {
    try {
      final pref = await datasource.getPref();
      return right(pref);
    } catch (e) {
      return Utils.debugLeft(e);
    }
  }
}
