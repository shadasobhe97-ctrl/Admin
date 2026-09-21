import '../datasources/parents_remote_datasource.dart';
import '../models/parent_model.dart';

abstract class ParentsRepository {
  Future<List<ParentModel>> getParents();
  Future<ParentModel> getParentDetails(int id);
  Future<Map<String, dynamic>> activateParent(int id);
}

class ParentsRepositoryImpl implements ParentsRepository {
  final ParentsRemoteDataSource _remoteDataSource;

  ParentsRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<ParentModel>> getParents() async {
    return await _remoteDataSource.getParents();
  }

  @override
  Future<ParentModel> getParentDetails(int id) async {
    return await _remoteDataSource.getParentDetails(id);
  }

  @override
  Future<Map<String, dynamic>> activateParent(int id) async {
    return await _remoteDataSource.activateParent(id);
  }
}
