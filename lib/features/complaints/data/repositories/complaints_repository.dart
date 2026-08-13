import '../../../../core/network/api_exception.dart';
import '../datasources/complaints_remote_datasource.dart';
import '../models/complaint_action_result_model.dart';
import '../models/complaint_model.dart';

abstract class ComplaintsRepository {
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

class ComplaintsRepositoryImpl implements ComplaintsRepository {
  final ComplaintsRemoteDataSource _remoteDataSource;

  ComplaintsRepositoryImpl(this._remoteDataSource);

  @override
  Future<ComplaintsListResult> getComplaints({
    String? status,
    dynamic driverId,
    int page = 1,
  }) async {
    try {
      return await _remoteDataSource.getComplaints(
        status: status,
        driverId: driverId,
        page: page,
      );
    } catch (e) {
      throw ApiErrorMapper.map(
        e,
        fallbackMessage: 'فشل في جلب قائمة الشكاوى والبلاغات.',
      );
    }
  }

  @override
  Future<ComplaintModel> getComplaintDetails(dynamic id) async {
    try {
      return await _remoteDataSource.getComplaintDetails(id);
    } catch (e) {
      throw ApiErrorMapper.map(
        e,
        fallbackMessage: 'فشل في جلب تفاصيل الشكوى.',
      );
    }
  }

  @override
  Future<ComplaintsListResult> getDriverComplaints(
    dynamic driverId, {
    int page = 1,
  }) async {
    try {
      return await _remoteDataSource.getDriverComplaints(
        driverId,
        page: page,
      );
    } catch (e) {
      throw ApiErrorMapper.map(
        e,
        fallbackMessage: 'فشل في جلب سجل شكاوى السائق.',
      );
    }
  }

  @override
  Future<ComplaintActionResultModel> reviewComplaint(
    dynamic id, {
    required String action,
    String? actionDetails,
  }) async {
    try {
      return await _remoteDataSource.reviewComplaint(
        id,
        action: action,
        actionDetails: actionDetails,
      );
    } catch (e) {
      throw ApiErrorMapper.map(
        e,
        fallbackMessage: 'فشل في حفظ القرار الإداري في الشكوى.',
      );
    }
  }
}
