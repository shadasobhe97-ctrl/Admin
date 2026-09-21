import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/parent_model.dart';

abstract class ParentsRemoteDataSource {
  Future<List<ParentModel>> getParents();
  Future<ParentModel> getParentDetails(int id);
  Future<Map<String, dynamic>> activateParent(int id);
}

class ParentsRemoteDataSourceImpl implements ParentsRemoteDataSource {
  final ApiClient _apiClient;

  ParentsRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<ParentModel>> getParents() async {
    final response = await _apiClient.get(ApiEndpoints.parents);
    final data = response.data;
    if (data != null && data['data'] is List) {
      return (data['data'] as List)
          .map((item) => ParentModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  @override
  Future<ParentModel> getParentDetails(int id) async {
    final response = await _apiClient.get(ApiEndpoints.parentDetails(id));
    final data = response.data;
    if (data != null && data['data'] != null && data['data'] is Map<String, dynamic>) {
      return ParentModel.fromJson(data['data'] as Map<String, dynamic>);
    }
    throw Exception('لم يتم العثور على بيانات ولي الأمر المطلوبة.');
  }

  @override
  Future<Map<String, dynamic>> activateParent(int id) async {
    final response = await _apiClient.post(ApiEndpoints.parentActivate(id));
    final data = response.data;
    if (data != null && data is Map<String, dynamic>) {
      return data;
    }
    return {'status': true, 'message': 'تم تفعيل الحساب بنجاح'};
  }
}
