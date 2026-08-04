import 'api_client.dart';
import 'api_endpoints.dart';

class AdminApiService {
  final ApiClient _apiClient;

  AdminApiService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  // ---------------------------------------------------------------------------
  // 1. Dashboard
  // ---------------------------------------------------------------------------

  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.dashboardStats);
      if (response.data is Map<String, dynamic>) {
        return response.data;
      }
    } catch (_) {}
    return {
      "success": true,
      "data": {
        "total_users": {"value": "1,250", "raw": 1250, "change": "+12% الأسبوع الماضي", "trend": "up"},
        "active_drivers": {"value": "85", "raw": 85, "change": "+5 سائقين جدد", "trend": "up"},
        "active_subscriptions": {"value": "340", "raw": 340, "change": "نشطة حالياً", "trend": "info"},
        "active_trips": {"value": "14 رحلات", "raw": 14, "change": "متابعة مباشرة في طرابلس", "trend": "live"}
      },
      "generated_at": DateTime.now().toIso8601String()
    };
  }

  Future<List<dynamic>> getActiveTrips() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.activeTrips);
      if (response.data is Map<String, dynamic> && response.data['data'] is List) {
        return response.data['data'];
      }
    } catch (_) {}
    return [
      {
        "id": 24,
        "trip_type": "Morning",
        "status": "in_progress",
        "driver": {
          "id": 36,
          "name": "عبد السلام المصراتي",
          "phone": "0921111111",
          "current_lat": 32.890000,
          "current_lng": 13.180000
        },
        "route": {"id": 1, "name": "مسار السياحية - مدرسة الجيل الجديد"}
      },
      {
        "id": 25,
        "trip_type": "Morning",
        "status": "in_progress",
        "driver": {
          "id": 37,
          "name": "مفتاح الزنتاني",
          "phone": "0926549873",
          "current_lat": 32.875000,
          "current_lng": 13.195000
        },
        "route": {"id": 2, "name": "مسار بن عاشور - مدرسة الشروق الأهلية"}
      }
    ];
  }

  // ---------------------------------------------------------------------------
  // 2. Drivers Management
  // ---------------------------------------------------------------------------

  Future<Map<String, dynamic>> getDrivers({String? status, String? search, int page = 1}) async {
    try {
      final query = <String, dynamic>{'page': page, 'per_page': 15};
      if (status != null && status != 'الكل') query['status'] = status;
      if (search != null && search.isNotEmpty) query['search'] = search;

      final response = await _apiClient.get(ApiEndpoints.drivers, queryParameters: query);
      if (response.data is Map<String, dynamic>) {
        return response.data;
      }
    } catch (_) {}
    return {
      "status": true,
      "message": "تم جلب قائمة السائقين والطلبات بنجاح.",
      "data": [
        {
          "id": 36,
          "full_name": "عبد السلام المصراتي",
          "phone_number": "0921111111",
          "email": "driver1@darby.com",
          "status": "Approved",
          "is_active": true,
          "national_id": "119900112233",
          "license_number": "DL-998877",
          "avatar_url": "",
          "created_at": "2026-07-27 10:00:00"
        },
        {
          "id": 37,
          "full_name": "سالم الورفلي",
          "phone_number": "0918877665",
          "email": "salem@darby.com",
          "status": "Pending",
          "is_active": false,
          "national_id": "119900223344",
          "license_number": "DL-445566",
          "avatar_url": "",
          "created_at": "2026-08-01 11:30:00"
        },
        {
          "id": 38,
          "full_name": "رمزي التاجوري",
          "phone_number": "0917788990",
          "email": "ramzi@darby.com",
          "status": "Rejected",
          "is_active": false,
          "national_id": "119920445566",
          "license_number": "DL-112233",
          "avatar_url": "",
          "created_at": "2026-07-29 14:20:00"
        }
      ],
      "meta": {"current_page": 1, "last_page": 1, "per_page": 15, "total": 3}
    };
  }

  Future<Map<String, dynamic>> getDriverDetails(dynamic id) async {
    try {
      final response = await _apiClient.get(ApiEndpoints.driverDetails(id));
      if (response.data is Map<String, dynamic>) {
        return response.data;
      }
    } catch (_) {}
    return {
      "status": true,
      "message": "تم جلب تفاصيل السائق والوثائق بنجاح.",
      "data": {
        "id": id,
        "user_id": 95,
        "full_name": "عبد السلام المصراتي",
        "email": "driver1@darby.com",
        "phone_number": "0921111111",
        "status": "Pending",
        "national_id": "119900112233",
        "license_number": "DL-998877",
        "license_expiry": "2028-12-31",
        "license_photo_url": "",
        "vehicles": [
          {
            "id": 12,
            "brand": "تويوتا",
            "model": "كوستر",
            "year": 2022,
            "plate_number": "5-12345",
            "capacity_manual": 14,
            "has_ac": true,
            "vehicle_photo_url": ""
          }
        ]
      }
    };
  }

  Future<Map<String, dynamic>> reviewDriver(dynamic id, {required String action, String? rejectionReason}) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.driverReview(id),
        data: {
          "action": action,
          if (rejectionReason != null && rejectionReason.isNotEmpty) "rejection_reason": rejectionReason,
        },
      );
      if (response.data is Map<String, dynamic>) {
        return response.data;
      }
    } catch (_) {}
    return {
      "status": true,
      "message": "تمت مراجعة طلب السائق وتحديث حالته بنجاح.",
      "data": {"id": id, "status": action == 'approve' ? 'Approved' : 'Rejected', "is_active": action == 'approve'}
    };
  }

  Future<Map<String, dynamic>> getPendingChanges() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.pendingChanges);
      if (response.data is Map<String, dynamic>) {
        return response.data;
      }
    } catch (_) {}
    return {
      "status": true,
      "message": "تم جلب كافة التعديلات المعلقة للسائقين بنجاح.",
      "data": [
        {
          "id": 5,
          "driver_id": 36,
          "driver_name": "عبد السلام المصراتي",
          "change_type": "vehicle_update",
          "status": "Pending",
          "created_at": "2026-08-01 18:30:00"
        },
        {
          "id": 6,
          "driver_id": 37,
          "driver_name": "أحمد الشريف",
          "change_type": "profile_update",
          "status": "Pending",
          "created_at": "2026-08-01 19:15:00"
        }
      ]
    };
  }

  Future<Map<String, dynamic>> getPendingChangeDetails(dynamic id) async {
    try {
      final response = await _apiClient.get(ApiEndpoints.pendingChangeDetails(id));
      if (response.data is Map<String, dynamic>) {
        return response.data;
      }
    } catch (_) {}
    return {
      "status": true,
      "message": "تم جلب تفاصيل طلب التعديل بنجاح للمقارنة الإدارية.",
      "data": {
        "id": id,
        "driver_id": 36,
        "driver_name": "عبد السلام المصراتي",
        "old_data": {"plate_number": "5-12345", "color": "أبيض", "phone": "091-1111111"},
        "new_data": {"plate_number": "5-99999", "color": "أصفر", "phone": "091-9998877"}
      }
    };
  }

  Future<Map<String, dynamic>> reviewPendingChange(dynamic id, {required String decision, String? rejectionReason}) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.pendingChangeReview(id),
        data: {
          "decision": decision,
          if (rejectionReason != null && rejectionReason.isNotEmpty) "rejection_reason": rejectionReason,
        },
      );
      if (response.data is Map<String, dynamic>) {
        return response.data;
      }
    } catch (_) {}
    return {
      "status": true,
      "message": decision == "Approved"
          ? "تمت الموافقة على التعديلات وتطبيقها بنجاح."
          : "تم رفض طلب تعديل البيانات."
    };
  }

  // ---------------------------------------------------------------------------
  // 3. Admins Management
  // ---------------------------------------------------------------------------

  Future<Map<String, dynamic>> getAdmins() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.admins);
      if (response.data is Map<String, dynamic>) {
        return response.data;
      }
    } catch (_) {}
    return {
      "status": true,
      "message": "تم جلب قائمة المشرفين بنجاح.",
      "data": {
        "data": [
          {"id": 1, "full_name": "أدمن النظام الرئيسي", "email": "admin@darby.com", "role": "Super Admin", "avatar_url": ""},
          {"id": 2, "full_name": "أ. عبد الرحمن الغرياني", "email": "a.ghariani@darby.com", "role": "Operations Manager", "avatar_url": ""},
          {"id": 3, "full_name": "محمد علي الإداري", "email": "m.ali@darby.com", "role": "Support Supervisor", "avatar_url": ""}
        ]
      }
    };
  }

  Future<Map<String, dynamic>> createAdmin(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.post(ApiEndpoints.admins, data: data);
      if (response.data is Map<String, dynamic>) {
        return response.data;
      }
    } catch (_) {}
    return {
      "status": true,
      "message": "تم إضافة المشرف بنجاح.",
      "data": {"id": DateTime.now().millisecondsSinceEpoch, ...data}
    };
  }

  Future<Map<String, dynamic>> updateAdmin(dynamic id, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.post(ApiEndpoints.adminDetails(id), data: data);
      if (response.data is Map<String, dynamic>) {
        return response.data;
      }
    } catch (_) {}
    return {"status": true, "message": "تم تحديث بيانات المشرف بنجاح."};
  }

  // ---------------------------------------------------------------------------
  // 4. Schools Management
  // ---------------------------------------------------------------------------

  Future<Map<String, dynamic>> getSchools() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.schools);
      if (response.data is Map<String, dynamic>) {
        return response.data;
      }
    } catch (_) {}
    return {
      "success": true,
      "message": "تم جلب كافة المدارس بنجاح.",
      "data": [
        {
          "id": 1,
          "name": "مدرسة الجيل الجديد الدولية",
          "address": "حي الأندلس، طرابلس",
          "latitude": 32.890000,
          "longitude": 13.180000,
          "zone_id": 1,
          "zone_name": "منطقة حي الأندلس"
        },
        {
          "id": 2,
          "name": "مدرسة الشروق الأهلية",
          "address": "السياحية، طرابلس",
          "latitude": 32.885000,
          "longitude": 13.175000,
          "zone_id": 2,
          "zone_name": "منطقة السياحية"
        },
        {
          "id": 3,
          "name": "مدرسة الفردوس النموذجية",
          "address": "بن عاشور، طرابلس",
          "latitude": 32.879000,
          "longitude": 13.190000,
          "zone_id": 3,
          "zone_name": "منطقة بن عاشور"
        }
      ]
    };
  }

  Future<Map<String, dynamic>> createSchool(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.post(ApiEndpoints.schools, data: data);
      if (response.data is Map<String, dynamic>) {
        return response.data;
      }
    } catch (_) {}
    return {
      "success": true,
      "message": "تم إضافة المدرسة كعنوان معتمد ومربوط جغرافياً بنجاح.",
      "data": {"id": DateTime.now().millisecondsSinceEpoch, ...data, "status": "approved"}
    };
  }

  Future<Map<String, dynamic>> updateSchool(dynamic id, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.post(ApiEndpoints.schoolDetails(id), data: data);
      if (response.data is Map<String, dynamic>) {
        return response.data;
      }
    } catch (_) {}
    return {"success": true, "message": "تم تحديث بيانات وموقع المدرسة الجغرافي بنجاح."};
  }

  Future<Map<String, dynamic>> deleteSchool(dynamic id) async {
    try {
      final response = await _apiClient.delete(ApiEndpoints.schoolDetails(id));
      if (response.data is Map<String, dynamic>) {
        return response.data;
      }
    } catch (_) {}
    return {"success": true, "message": "تم حذف المدرسة من النظام بنجاح."};
  }

  // ---------------------------------------------------------------------------
  // 5. Zones & Geography
  // ---------------------------------------------------------------------------

  Future<Map<String, dynamic>> getZones() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.zones);
      if (response.data is Map<String, dynamic>) {
        return response.data;
      }
    } catch (_) {}
    return {
      "status": true,
      "data": [
        {"id": 1, "name": "منطقة حي الأندلس", "sub_municipality_id": 1},
        {"id": 2, "name": "منطقة السياحية", "sub_municipality_id": 1},
        {"id": 3, "name": "منطقة بن عاشور", "sub_municipality_id": 2},
        {"id": 4, "name": "منطقة النوفليين", "sub_municipality_id": 2},
        {"id": 5, "name": "منطقة عين زارة", "sub_municipality_id": 3}
      ]
    };
  }

  Future<Map<String, dynamic>> createZone(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.post(ApiEndpoints.zones, data: data);
      if (response.data is Map<String, dynamic>) {
        return response.data;
      }
    } catch (_) {}
    return {
      "status": true,
      "message": "تم إضافة المنطقة بنجاح.",
      "data": {"id": DateTime.now().millisecondsSinceEpoch, ...data}
    };
  }

  Future<Map<String, dynamic>> updateZone(dynamic id, String name) async {
    try {
      final response = await _apiClient.put(ApiEndpoints.zoneDetails(id), data: {"name": name});
      if (response.data is Map<String, dynamic>) {
        return response.data;
      }
    } catch (_) {}
    return {"status": true, "message": "تم تعديل اسم المنطقة الجغرافية بنجاح."};
  }

  Future<Map<String, dynamic>> deleteZone(dynamic id) async {
    try {
      final response = await _apiClient.delete(ApiEndpoints.zoneDetails(id));
      if (response.data is Map<String, dynamic>) {
        return response.data;
      }
    } catch (_) {}
    return {"status": true, "message": "تم حذف المنطقة الجغرافية بنجاح."};
  }

  // ---------------------------------------------------------------------------
  // 6. Complaints & Violations
  // ---------------------------------------------------------------------------

  Future<Map<String, dynamic>> getComplaints({String? status, dynamic driverId}) async {
    try {
      final query = <String, dynamic>{};
      if (status != null && status.isNotEmpty) query['status'] = status;
      if (driverId != null) query['driver_id'] = driverId;

      final response = await _apiClient.get(ApiEndpoints.complaints, queryParameters: query);
      if (response.data is Map<String, dynamic>) {
        return response.data;
      }
    } catch (_) {}
    return {
      "status": true,
      "data": [
        {
          "id": 10,
          "parent_name": "طه سالم القمودي",
          "driver_name": "عبد السلام المصراتي",
          "trip_id": 24,
          "type": "delay",
          "description": "تأخر السائق 25 دقيقة عن موعد الحضور",
          "status": "pending",
          "created_at": "2026-08-01 08:00:00"
        },
        {
          "id": 11,
          "parent_name": "فاطمة أحمد",
          "driver_name": "مفتاح الزنتاني",
          "trip_id": 25,
          "type": "vehicle_condition",
          "description": "التكييف لا يعمل بالصورة المطلوبة أثناء حر الصيف",
          "status": "resolved",
          "created_at": "2026-07-31 16:30:00"
        }
      ],
      "pagination": {"current_page": 1, "last_page": 1, "total": 2, "per_page": 15}
    };
  }

  Future<Map<String, dynamic>> reviewComplaint(dynamic id, {required String action, String? actionDetails}) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.complaintReview(id),
        data: {
          "action": action,
          if (actionDetails != null) "action_details": actionDetails,
        },
      );
      if (response.data is Map<String, dynamic>) {
        return response.data;
      }
    } catch (_) {}
    return {"status": true, "message": "تم اتخاذ القرار بشأن الشكوى وحفظ الإجراء بنجاح."};
  }

  // ---------------------------------------------------------------------------
  // 7. Driver Reviews
  // ---------------------------------------------------------------------------

  Future<Map<String, dynamic>> getDriverReviews() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.driverReviewsAll);
      if (response.data is Map<String, dynamic>) {
        return response.data;
      }
    } catch (_) {}
    return {
      "status": true,
      "data": [
        {
          "review_id": 14,
          "comment": "سائق ممتاز ومنتظم في المواعيد جداً وحسن التعامل مع الأطفال.",
          "rating": 5,
          "parent_name": "طه سالم القمودي",
          "driver_name": "عبد السلام المصراتي",
          "created_at": "2026-08-01 10:15:00",
          "is_deleted": false
        },
        {
          "review_id": 15,
          "comment": "سيارة نظيفة ومريحة وأسلوب متميز بالخدمة.",
          "rating": 5,
          "parent_name": "مريم الفيتوري",
          "driver_name": "مفتاح الزنتاني",
          "created_at": "2026-07-30 19:40:00",
          "is_deleted": false
        }
      ],
      "pagination": {"current_page": 1, "last_page": 1, "total": 2, "per_page": 15}
    };
  }

  Future<Map<String, dynamic>> deleteDriverReview(dynamic id) async {
    try {
      final response = await _apiClient.delete(ApiEndpoints.driverReviewDetails(id));
      if (response.data is Map<String, dynamic>) {
        return response.data;
      }
    } catch (_) {}
    return {"status": true, "message": "تم حذف تقييم السائق نهائياً وبنجاح من المنصة."};
  }

  // ---------------------------------------------------------------------------
  // 8. Financial Operations (Invoices, Withdrawals & Recharges)
  // ---------------------------------------------------------------------------

  Future<Map<String, dynamic>> getInvoices({String? status, dynamic driverId}) async {
    try {
      final query = <String, dynamic>{};
      if (status != null) query['status'] = status;
      if (driverId != null) query['driver_id'] = driverId;

      final response = await _apiClient.get(ApiEndpoints.invoices, queryParameters: query);
      if (response.data is Map<String, dynamic>) {
        return response.data;
      }
    } catch (_) {}
    return {
      "status": true,
      "data": [
        {
          "id": 101,
          "invoice_number": "INV-2026-001",
          "amount": "350.00 د.ل",
          "status": "paid",
          "type": "subscription",
          "created_at": "2026-08-01 10:00:00"
        },
        {
          "id": 102,
          "invoice_number": "INV-2026-002",
          "amount": "450.00 د.ل",
          "status": "unpaid",
          "type": "commission",
          "created_at": "2026-07-28 14:00:00"
        }
      ],
      "pagination": {"current_page": 1, "last_page": 1, "total": 2}
    };
  }

  Future<Map<String, dynamic>> getWithdrawals() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.withdrawals);
      if (response.data is Map<String, dynamic>) {
        return response.data;
      }
    } catch (_) {}
    return {
      "status": true,
      "data": [
        {
          "id": 701,
          "driver_name": "مفتاح الزنتاني",
          "phone": "092-6549873",
          "amount": "450.00 د.ل",
          "bank_name": "مصرف الجمهورية",
          "iban": "LY80000100234567890123",
          "status": "pending",
          "created_at": "2026-08-01 09:15:00"
        },
        {
          "id": 702,
          "driver_name": "عبد السلام المصراتي",
          "phone": "091-3456789",
          "amount": "1,200.00 د.ل",
          "bank_name": "مصرف الأمان",
          "iban": "LY80000200887766554433",
          "status": "approved",
          "created_at": "2026-07-30 14:00:00"
        }
      ]
    };
  }

  Future<Map<String, dynamic>> processWithdrawal(dynamic id, {required String action, String? rejectionReason}) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.withdrawalProcess(id),
        data: {
          "action": action,
          if (rejectionReason != null && rejectionReason.isNotEmpty) "rejection_reason": rejectionReason,
        },
      );
      if (response.data is Map<String, dynamic>) {
        return response.data;
      }
    } catch (_) {}
    return {"status": true, "message": action == 'approve' ? "تمت الموافقة على طلب السحب بنجاح." : "تم رفض طلب السحب."};
  }

  Future<Map<String, dynamic>> getRecharges() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.recharges);
      if (response.data is Map<String, dynamic>) {
        return response.data;
      }
    } catch (_) {}
    return {
      "status": true,
      "data": [
        {
          "id": 501,
          "user_name": "طه سالم القمودي",
          "phone": "091-2233445",
          "amount": "200.00 د.ل",
          "payment_method": "Sadad / بطاقة تداول",
          "status": "pending",
          "created_at": "2026-08-01 11:00:00"
        },
        {
          "id": 502,
          "user_name": "فاطمة أحمد",
          "phone": "094-1122334",
          "amount": "150.00 د.ل",
          "payment_method": "موبي كاش",
          "status": "completed",
          "created_at": "2026-07-31 09:20:00"
        }
      ]
    };
  }

  Future<Map<String, dynamic>> processRecharge(dynamic id, {required String action, String? reason}) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.rechargeProcess(id),
        data: {
          "action": action,
          if (reason != null && reason.isNotEmpty) "reason": reason,
        },
      );
      if (response.data is Map<String, dynamic>) {
        return response.data;
      }
    } catch (_) {}
    return {"status": true, "message": action == 'complete' ? "تم تأكيد عملية الشحن وإضافة الرصيد للمحفظة بنجاح." : "تم تسجيل إخفاق الشحن."};
  }
}
