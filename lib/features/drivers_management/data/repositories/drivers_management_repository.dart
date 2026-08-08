import '../datasources/drivers_management_remote_data_source.dart';
import '../models/driver_change_details_model.dart';
import '../models/driver_change_request_model.dart';
import '../models/driver_details_model.dart';
import '../models/driver_review_model.dart';

class DriversManagementRepository {
  final DriversManagementRemoteDataSource _remoteDataSource;

  DriversManagementRepository(this._remoteDataSource);

  Future<DriversListResult> getDrivers({
    String? status,
    String? search,
    int page = 1,
  }) async {
    try {
      return await _remoteDataSource.getDrivers(status: status, search: search, page: page);
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<DriverDetailsModel> getDriverDetails(int id) async {
    try {
      return await _remoteDataSource.getDriverDetails(id);
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<String> reviewDriver({
    required int id,
    required String action,
    String? rejectionReason,
  }) async {
    try {
      return await _remoteDataSource.reviewDriver(
        id: id,
        action: action,
        rejectionReason: rejectionReason,
      );
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<List<DriverChangeRequestModel>> getPendingDriverChanges() async {
    try {
      return await _remoteDataSource.getPendingDriverChanges();
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<DriverChangeDetailsModel> getPendingDriverChangeDetails(int id) async {
    try {
      return await _remoteDataSource.getPendingDriverChangeDetails(id);
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<String> reviewDriverChange({
    required int id,
    required String decision,
    String? rejectionReason,
  }) async {
    try {
      return await _remoteDataSource.reviewDriverChange(
        id: id,
        decision: decision,
        rejectionReason: rejectionReason,
      );
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<List<DriverReviewModel>> getAllDriverReviews() async {
    try {
      return await _remoteDataSource.getAllDriverReviews();
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<List<DriverReviewModel>> getDriverReviewsForDriver(int driverId) async {
    try {
      return await _remoteDataSource.getDriverReviewsForDriver(driverId);
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<String> deleteDriverReview(int reviewId) async {
    try {
      return await _remoteDataSource.deleteDriverReview(reviewId);
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }
}
