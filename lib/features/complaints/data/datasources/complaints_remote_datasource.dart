import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/complaint_action_result_model.dart';
import '../models/complaint_model.dart';

abstract class ComplaintsRemoteDataSource {
  Future<ComplaintsListResult> getComplaints({
    String? status,
    dynamic driverId,
    int page = 1,
  });

  Future<ComplaintModel> getComplaintDetails(dynamic id);

  Future<ComplaintsListResult> getDriverComplaints(
    dynamic driverId, {
    int page = 1,
  });

  Future<ComplaintActionResultModel> reviewComplaint(
    dynamic id, {
    required String action,
    String? actionDetails,
  });
}

class ComplaintsRemoteDataSourceImpl implements ComplaintsRemoteDataSource {
  final ApiClient _apiClient;

  ComplaintsRemoteDataSourceImpl(this._apiClient);

  @override
  Future<ComplaintsListResult> getComplaints({
    String? status,
    dynamic driverId,
    int page = 1,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
    };

    if (status != null && status.isNotEmpty && status != 'all') {
      queryParams['status'] = status;
    }
    if (driverId != null && driverId.toString().isNotEmpty) {
      queryParams['driver_id'] = driverId;
    }

    final response = await _apiClient.get(
      ApiEndpoints.complaints,
      queryParameters: queryParams,
    );

    final data = response.data as Map<String, dynamic>;
    return ComplaintsListResult.fromJson(data);
  }

  @override
  Future<ComplaintModel> getComplaintDetails(dynamic id) async {
    final response = await _apiClient.get(
      ApiEndpoints.complaintDetails(id),
    );

    final data = response.data as Map<String, dynamic>;
    final itemData = data['data'] as Map<String, dynamic>?;
    return ComplaintModel.fromJson(itemData);
  }

  @override
  Future<ComplaintsListResult> getDriverComplaints(
    dynamic driverId, {
    int page = 1,
  }) async {
    final response = await _apiClient.get(
      ApiEndpoints.driverComplaints(driverId),
      queryParameters: {'page': page},
    );

    final data = response.data as Map<String, dynamic>;
    return ComplaintsListResult.fromJson(data);
  }

  @override
  Future<ComplaintActionResultModel> reviewComplaint(
    dynamic id, {
    required String action,
    String? actionDetails,
  }) async {
    final body = <String, dynamic>{
      'action': action,
    };
    if (actionDetails != null && actionDetails.trim().isNotEmpty) {
      body['action_details'] = actionDetails.trim();
    }

    final response = await _apiClient.post(
      ApiEndpoints.complaintReview(id),
      data: body,
    );

    final data = response.data as Map<String, dynamic>;
    return ComplaintActionResultModel.fromJson(data);
  }
}
