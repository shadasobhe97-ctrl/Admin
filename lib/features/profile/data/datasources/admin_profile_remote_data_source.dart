import 'package:flutter/foundation.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_exception.dart';
import '../models/admin_profile_model.dart';
import '../models/email_change_status_model.dart';
import '../models/profile_update_request.dart';

abstract class AdminProfileRemoteDataSource {
  Future<AdminProfileModel> getProfile();
  Future<Map<String, dynamic>> updateProfile(ProfileUpdateRequest request);
  Future<EmailChangeStatusModel> getEmailChangeStatus();
  Future<String> cancelEmailChange();
  Future<String> resendEmailVerification();
}

class AdminProfileRemoteDataSourceImpl implements AdminProfileRemoteDataSource {
  final ApiClient _apiClient;

  AdminProfileRemoteDataSourceImpl(this._apiClient);

  @override
  Future<AdminProfileModel> getProfile() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.profile);
      final data = response.data;

      if (data is Map<String, dynamic>) {
        final isSuccess = data['status'] == true || data['success'] == true || data['data'] != null;
        if (isSuccess && data['data'] is Map<String, dynamic>) {
          return AdminProfileModel.fromJson(data['data'] as Map<String, dynamic>);
        } else if (data['id'] != null || data['full_name'] != null) {
          return AdminProfileModel.fromJson(data);
        }
        throw ApiException(data['message']?.toString() ?? 'فشل جلب بيانات البروفايل من الخادم');
      }
      throw const ApiException('استجابة غير متوافقة من الخادم عند جلب البروفايل');
    } catch (e) {
      debugPrint('[PROFILE API ERROR GET] $e');
      throw ApiErrorMapper.map(e, fallbackMessage: 'فشل جلب بيانات البروفايل');
    }
  }

  @override
  Future<Map<String, dynamic>> updateProfile(ProfileUpdateRequest request) async {
    final endpoint = ApiEndpoints.profile;
    try {
      final formData = request.toFormData();
      final response = await _apiClient.post(endpoint, data: formData);
      final data = response.data;

      if (data is Map<String, dynamic>) {
        final isSuccess = data['status'] == true || data['success'] == true;
        if (isSuccess) {
          AdminProfileModel? updatedModel;
          if (data['data'] is Map<String, dynamic>) {
            updatedModel = AdminProfileModel.fromJson(data['data'] as Map<String, dynamic>);
          }

          EmailVerificationInfo? emailVerification;
          if (data['email_verification'] is Map<String, dynamic>) {
            emailVerification = EmailVerificationInfo.fromJson(
              data['email_verification'] as Map<String, dynamic>,
            );
          }

          return {
            'status': true,
            'message': data['message']?.toString() ?? 'تم تحديث ملفك الشخصي بنجاح.',
            'profile': updatedModel,
            'email_verification': emailVerification,
          };
        }
        throw ApiException(data['message']?.toString() ?? 'تعذر تحديث البروفايل');
      }
      throw const ApiException('استجابة غير متوقعة من الخادم عند التحديث');
    } catch (e) {
      debugPrint('[PROFILE API ERROR POST] $e');
      throw ApiErrorMapper.map(e, fallbackMessage: 'تعذر تحديث البروفايل');
    }
  }

  @override
  Future<EmailChangeStatusModel> getEmailChangeStatus() async {
    final endpoint = ApiEndpoints.profileEmailChangeStatus;
    try {
      final response = await _apiClient.get(endpoint);
      final data = response.data;

      if (data is Map<String, dynamic>) {
        final isSuccess = data['status'] == true || data['success'] == true;
        if (isSuccess && data['data'] is Map<String, dynamic>) {
          return EmailChangeStatusModel.fromJson(data['data'] as Map<String, dynamic>);
        }
        if (data['data'] is Map<String, dynamic>) {
          return EmailChangeStatusModel.fromJson(data['data'] as Map<String, dynamic>);
        }
      }
      return const EmailChangeStatusModel(pending: false);
    } catch (e) {
      debugPrint('[PROFILE EMAIL STATUS ERROR] $e');
      throw ApiErrorMapper.map(e, fallbackMessage: 'تعذر جلب حالة تغيير البريد الإلكتروني');
    }
  }

  @override
  Future<String> cancelEmailChange() async {
    final endpoint = ApiEndpoints.profileEmailChangeCancel;
    try {
      final response = await _apiClient.post(endpoint);
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return data['message']?.toString() ?? 'تم إلغاء طلب تغيير البريد الإلكتروني بنجاح.';
      }
      return 'تم إلغاء طلب تغيير البريد الإلكتروني بنجاح.';
    } catch (e) {
      debugPrint('[PROFILE EMAIL CANCEL ERROR] $e');
      throw ApiErrorMapper.map(e, fallbackMessage: 'تعذر إلغاء طلب تغيير البريد الإلكتروني');
    }
  }

  @override
  Future<String> resendEmailVerification() async {
    final endpoint = ApiEndpoints.profileEmailChangeResend;
    try {
      final response = await _apiClient.post(endpoint);
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return data['message']?.toString() ?? 'تمت إعادة إرسال رابط تأكيد البريد الإلكتروني بنجاح.';
      }
      return 'تمت إعادة إرسال رابط تأكيد البريد الإلكتروني بنجاح.';
    } catch (e) {
      debugPrint('[PROFILE EMAIL RESEND ERROR] $e');
      throw ApiErrorMapper.map(e, fallbackMessage: 'تعذر إعادة إرسال رابط تأكيد البريد الإلكتروني');
    }
  }
}
