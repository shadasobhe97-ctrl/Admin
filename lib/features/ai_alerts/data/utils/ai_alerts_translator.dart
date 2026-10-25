class AiAlertsTranslator {
  const AiAlertsTranslator._();

  /// ترجمة عنوان التنبيه إن كان بالإنجليزية
  static String translateTitle(String title) {
    if (title.trim().isEmpty) return 'تنبيه ذكاء اصطناعي';
    final lower = title.trim().toLowerCase();
    if (lower.contains('negative review') || lower.contains('negative_review')) {
      return 'تنبيه تقييم سلبي متكرر للسائق';
    }
    if (lower.contains('low rating') || lower.contains('rating drop')) {
      return 'تنبيه انخفاض تقييم السائق';
    }
    if (lower.contains('safety alert') || lower.contains('safety_violation')) {
      return 'تنبيه أمان وسلامة الركاب';
    }
    if (lower.contains('formal warning')) {
      return 'تحذير رسمي مسجل للسائق';
    }
    if (lower.contains('critical alert') || lower.contains('ai critical')) {
      return 'تنبيه أمان حرج يتطلب التدخل';
    }
    if (lower.contains('admin review') || lower.contains('review required')) {
      return 'طلب مراجعة وتدخل إداري';
    }
    if (lower.contains('reward') || lower.contains('excellent')) {
      return 'مكافأة وتميز في الخدمة';
    }
    // إذا كان يحتوي على أحرف إنجليزية فقط، لا نعرض الإنجليزي الخام
    if (RegExp(r'^[a-zA-Z0-9_\-\s]+$').hasMatch(title.trim())) {
      return 'تنبيه ذكاء اصطناعي';
    }
    return title;
  }

  /// ترجمة نوع التنبيه
  static String translateAlertType(String type) {
    switch (type.trim().toLowerCase()) {
      case 'ai_critical':
        return 'تنبيه حرج';
      case 'ai_warning':
        return 'تنبيه تحذيري';
      case 'ai_admin_review_required':
        return 'طلب تدخل إداري';
      default:
        return 'تنبيه نظام';
    }
  }

  /// ترجمة مستوى الخطورة
  static String translateRiskLevel(String riskLevel, {bool isCritical = false}) {
    switch (riskLevel.trim().toUpperCase()) {
      case 'CRITICAL':
        return 'خطر حرج';
      case 'HIGH':
        return 'خطر مرتفع';
      case 'MEDIUM':
        return 'خطر متوسط';
      case 'LOW':
        return 'خطر منخفض';
      default:
        return isCritical ? 'خطر حرج' : 'تنبيه عادي';
    }
  }

  /// ترجمة سبب التنبيه (Trigger)
  static String translateTrigger(dynamic v) {
    if (v == null) return '';
    final s = v.toString().trim().toLowerCase();
    switch (s) {
      case 'negative_review_spike':
        return 'ارتفاع ملحوظ في التقييمات السلبية';
      case 'low_rating':
        return 'انخفاض معدل تقييم السائق';
      case 'sentiment_classification':
      case 'negative_sentiment':
        return 'اكتشاف تعليق سلبي عبر تحليل المشاعر';
      case 'safety_alert':
        return 'تنبيه أمان وسلامة';
      case 'complaint':
        return 'شكوى وبلاغ من ولي أمر';
      case 'route_deviation':
        return 'انحراف متكرر عن المسار المحدد';
      case 'speeding':
        return 'تجاوز السرعة المحددة';
      case 'late_arrival':
        return 'تأخر متكرر عن المواعيد';
      default:
        return 'رصد سلوكي آلي';
    }
  }

  /// ترجمة حالة حساب السائق
  static String translateDriverStatus(String status) {
    switch (status.trim().toLowerCase()) {
      case 'active':
        return 'نشط ومفعل';
      case 'suspended':
      case 'blocked':
        return 'موقوف مؤقتاً';
      case 'pending':
        return 'قيد المراجعة والتدقيق';
      case 'inactive':
        return 'غير نشط';
      default:
        return status;
    }
  }

  /// ترجمة الإجراءات المطبقة تلقائياً
  static String translateAction(String act) {
    final normalized = act.trim().toLowerCase();

    // فحص تخفيض التقييم بنسبة معينة ديناميكياً مثل rating_down_5pct أو rating_down_10pct
    final ratingDownMatch =
        RegExp(r'^rating_down_(\d+)pct$').firstMatch(normalized);
    if (ratingDownMatch != null) {
      final pct = ratingDownMatch.group(1);
      return 'تخفيض التقييم بنسبة $pct%';
    }

    switch (normalized) {
      case 'admin_alerted_high':
        return 'إرسال تنبيه عاجل للإدارة';
      case 'admin_alerted_critical':
        return 'إصدار تنبيه أمان حرج للإدارة';
      case 'admin_alerted_medium':
        return 'إشعار الإدارة بمخالفة';
      case 'admin_review_required':
        return 'طلب مراجعة وتدخل إداري';
      case 'warning_incremented':
        return 'تسجيل إنذار رسمي في سجل السائق';
      case 'temporary_search_restriction':
        return 'تقييد مؤقت للظهور في البحث';
      case 'hidden_from_search_precautionary':
        return 'حجب وقائي مؤقت من البحث';
      case 'permanent_suspension':
        return 'إيقاف نهائي للسائق عن الخدمة';
      case 'temporary_suspension':
        return 'إيقاف مؤقت للسائق عن الخدمة';
      case 'reward_granted':
        return 'منح مكافأة تميز';
      case 'trust_badge_awarded':
        return 'منح شارة سائق موثوق';
      case 'trust_badge_revoked':
        return 'سحب شارة السائق الموثوق';
      case 'fine_applied':
        return 'تطبيق غرامة مالية';
      case 'no_action':
        return 'بدون إجراء إضافي';
      case 'rating_decreased':
      case 'rating_down':
        return 'تخفيض تقييم السائق';
      case 'driver_notified':
        return 'إرسال إشعار تنبيهي للسائق';
      case 'parent_notified':
        return 'إشعار ولي الأمر بالإجراء';
      case 'account_review':
        return 'مراجعة حساب السائق';
      default:
        return 'إجراء إداري نظامي';
    }
  }

  /// ترجمة تصنيف الذكاء الاصطناعي للمخالفة
  static String translateCategory(String category) {
    final normalized = category.trim().toLowerCase();
    switch (normalized) {
      case 'vehicle_condition':
        return 'حالة المركبة / النظافة';
      case 'driving_behavior':
        return 'سلوك القيادة / السلامة';
      case 'late_arrival':
        return 'تأخر عن الموعد';
      case 'safety_violation':
        return 'مخالفة معايير الأمان';
      case 'inappropriate_behavior':
        return 'سلوك غير لائق';
      case 'route_deviation':
        return 'انحراف عن المسار';
      case 'pricing_dispute':
        return 'خلاف حول الأجرة';
      case 'general_negative':
        return 'ملاحظة سلبية عامة';
      case 'service_quality':
        return 'جودة الخدمة المقدمة';
      default:
        return 'ملاحظة على معايير الخدمة';
    }
  }

  /// تنظيف نص التعليق من أي معرفات أو بادئات أرقام معرفات (IDs)
  static String cleanCommentText(String text) {
    var cleaned = text.trim();
    // إزالة أي بادئات معرّفات باللغة الإنجليزية أو العربية مثل Review ID #123 أو تقييم #123
    cleaned = cleaned.replaceAll(
      RegExp(r'^(review\s*(id)?|تقييم|تعليق)\s*(#|id|معرف)?\s*\d+\s*[:\-]\s*', caseSensitive: false),
      '',
    );
    // إزالة نمط [ID: 123] أو (ID: 123) إن وُجد
    cleaned = cleaned.replaceAll(
      RegExp(r'[\(\[]\s*(review\s*)?(id|معرف)?\s*#?\s*\d+\s*[\)\]]', caseSensitive: false),
      '',
    );
    return cleaned.trim();
  }
}
