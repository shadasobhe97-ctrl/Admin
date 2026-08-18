// قواميس القيم الثابتة التي يحدّدها عقد الخادم.
//
// الخادم يرسل `action_label` جاهزاً بالعربية، لذلك لا تُترجَم الإجراءات هنا.
// هذه القواميس تخص القيم التي لا يرسل لها الخادم تسمية: `action_group`
// و`result` و`entity_type`.

/// عائلات الإجراءات كما يحدّدها العقد.
class AuditActionGroup {
  const AuditActionGroup._();

  static const String decision = 'decision';
  static const String update = 'update';
  static const String operation = 'operation';

  static const List<String> all = [decision, update, operation];

  static String label(String? group) {
    switch (group) {
      case decision:
        return 'قرارات';
      case update:
        return 'تعديلات بيانات';
      case operation:
        return 'عمليات تنفيذية';
      default:
        return group ?? '—';
    }
  }
}

/// دلالة نتيجة الإجراء — تُستخدم لاختيار لون العرض من الثيم.
enum AuditResultTone { positive, negative, neutral, warning }

/// قيم `result` الموثّقة في العقد.
class AuditResult {
  const AuditResult._();

  // قرارات عامة
  static const String approved = 'approved';
  static const String rejected = 'rejected';
  static const String completed = 'completed';
  static const String failed = 'failed';

  // الشكاوى
  static const String resolved = 'resolved';
  static const String escalated = 'escalated';
  static const String dismissed = 'dismissed';

  // النزاعات المالية
  static const String refundParent = 'refund_parent';
  static const String payoutDriver = 'payout_driver';

  // العمليات التنفيذية
  static const String success = 'success';

  /// طلب تعديل من السائق تم تجاوزه بتعديل إداري مباشر.
  static const String superseded = 'superseded';

  static String label(String? result) {
    switch (result) {
      case approved:
        return 'تمت الموافقة';
      case rejected:
        return 'مرفوض';
      case completed:
        return 'مكتمل';
      case failed:
        return 'فشل';
      case resolved:
        return 'تم الحل';
      case escalated:
        return 'تم التصعيد';
      case dismissed:
        return 'حُفظت';
      case refundParent:
        return 'تعويض ولي الأمر';
      case payoutDriver:
        return 'صرف للسائق';
      case success:
        return 'نُفّذت بنجاح';
      case superseded:
        return 'تم تجاوزه بتعديل إداري';
      default:
        return result ?? '—';
    }
  }

  /// لا تُحدَّد الألوان هنا — تُشتق من الثيم في طبقة العرض حسب هذه الدلالة.
  static AuditResultTone tone(String? result) {
    switch (result) {
      case approved:
      case completed:
      case resolved:
      case success:
      case payoutDriver:
        return AuditResultTone.positive;
      case rejected:
      case failed:
        return AuditResultTone.negative;
      case escalated:
      case dismissed:
      case superseded:
      case refundParent:
        return AuditResultTone.warning;
      default:
        return AuditResultTone.neutral;
    }
  }
}

/// أنواع الكيانات المتأثرة، لاستخدامها في الفلترة والعرض.
class AuditEntityType {
  const AuditEntityType._();

  static const String driver = 'driver';
  static const String driverChange = 'driver_change';
  static const String driverReview = 'driver_review';
  static const String admin = 'admin';
  static const String school = 'school';
  static const String zone = 'zone';
  static const String municipality = 'municipality';
  static const String subMunicipality = 'sub_municipality';
  static const String complaint = 'complaint';
  static const String withdrawal = 'withdrawal';
  static const String recharge = 'recharge';
  static const String dispute = 'dispute';
  static const String escrow = 'escrow';
  static const String contract = 'contract';
  static const String trip = 'trip';

  /// الأنواع المعروضة في قائمة الفلترة، بالترتيب.
  static const List<String> filterable = [
    driver,
    driverChange,
    admin,
    school,
    zone,
    complaint,
    withdrawal,
    recharge,
    dispute,
    contract,
    trip,
  ];

  static String label(String? type) {
    switch (type) {
      case driver:
        return 'سائق';
      case driverChange:
        return 'طلب تعديل سائق';
      case driverReview:
        return 'تقييم سائق';
      case admin:
        return 'مشرف';
      case school:
        return 'مدرسة';
      case zone:
        return 'منطقة';
      case municipality:
        return 'بلدية كبرى';
      case subMunicipality:
        return 'بلدية فرعية';
      case complaint:
        return 'شكوى';
      case withdrawal:
        return 'طلب سحب';
      case recharge:
        return 'شحن محفظة';
      case dispute:
        return 'نزاع مالي';
      case escrow:
        return 'أمانات';
      case contract:
        return 'عقد';
      case trip:
        return 'رحلة';
      default:
        return type ?? '—';
    }
  }
}
