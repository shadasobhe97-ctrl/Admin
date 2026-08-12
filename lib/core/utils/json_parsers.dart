/// أدوات تحويل آمنة (null-safe) مشتركة بين كل الميزات.
///
/// الهدف: عدم افتراض نوع أي حقل قادم من الخادم، وعدم تكرار منطق التحويل
/// داخل كل Model على حدة.
class JsonParsers {
  const JsonParsers._();

  // ── أنواع أوّلية ───────────────────────────────────────────────────────────

  static int? optionalInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  static int intValue(dynamic value, {int fallback = 0}) =>
      optionalInt(value) ?? fallback;

  static double? optionalDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString().replaceAll(',', ''));
  }

  static double doubleValue(dynamic value, {double fallback = 0}) =>
      optionalDouble(value) ?? fallback;

  static String? optionalString(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  static String stringValue(dynamic value, {String fallback = ''}) =>
      optionalString(value) ?? fallback;

  static bool? optionalBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is num) return value != 0;
    final text = value.toString().toLowerCase().trim();
    if (text == 'true' || text == '1') return true;
    if (text == 'false' || text == '0') return false;
    return null;
  }

  static bool boolValue(dynamic value, {bool fallback = false}) =>
      optionalBool(value) ?? fallback;

  static DateTime? optionalDate(dynamic value) {
    final text = optionalString(value);
    if (text == null) return null;
    return DateTime.tryParse(text);
  }

  // ── كائنات وقوائم ─────────────────────────────────────────────────────────

  /// يحوّل أي قيمة إلى خريطة مفاتيحها نصية، أو `null` إن لم تكن كائناً.
  static Map<String, dynamic>? optionalMap(dynamic value) {
    if (value is Map) {
      return value.map((key, val) => MapEntry(key.toString(), val));
    }
    return null;
  }

  /// مثل [optionalMap] لكن يعيد خريطة فارغة بدل `null`.
  /// مناسب للحقول الديناميكية مثل `metadata`.
  static Map<String, dynamic> mapValue(dynamic value) =>
      optionalMap(value) ?? const {};

  /// يحوّل قائمة كائنات إلى قائمة نماذج، ويتجاهل أي عنصر غير صالح.
  static List<T> listOf<T>(
    dynamic value,
    T Function(Map<String, dynamic> json) parser,
  ) {
    if (value is! List) return const [];
    return value
        .whereType<Map>()
        .map((item) => parser(item.map((k, v) => MapEntry(k.toString(), v))))
        .toList();
  }

  // ── استخراج من غلاف الاستجابة ─────────────────────────────────────────────

  /// يستخرج قائمة العناصر من استجابة قد تكون `{data: [...]}` أو قائمة مباشرة
  /// أو استجابة Laravel المتداخلة `{data: {data: [...]}}`.
  static List<Map<String, dynamic>> extractList(dynamic body) {
    dynamic raw = body;
    if (raw is Map) raw = raw['data'];
    if (raw is Map) raw = raw['data'];
    if (raw is! List) return const [];

    return raw
        .whereType<Map>()
        .map((item) => item.map((k, v) => MapEntry(k.toString(), v)))
        .toList();
  }

  /// يستخرج كائن `data` من الاستجابة، أو الجسم نفسه إن لم يكن مغلّفاً.
  static Map<String, dynamic>? extractObject(dynamic body) {
    if (body is! Map) return null;
    final data = body['data'];
    if (data is Map) {
      return data.map((k, v) => MapEntry(k.toString(), v));
    }
    if (body.containsKey('id') || body.containsKey('contract_id')) {
      return body.map((k, v) => MapEntry(k.toString(), v));
    }
    return null;
  }

  /// يستخرج `meta` الخاصة بالـ Pagination من أي من المواقع المحتملة.
  static Map<String, dynamic>? extractMeta(dynamic body) {
    if (body is! Map) return null;
    final meta = body['meta'] ?? body['pagination'];
    if (meta is Map) {
      return meta.map((k, v) => MapEntry(k.toString(), v));
    }
    final data = body['data'];
    if (data is Map && data['current_page'] != null) {
      return data.map((k, v) => MapEntry(k.toString(), v));
    }
    return null;
  }

  /// رسالة الخادم في استجابات النجاح.
  static String? extractMessage(dynamic body) {
    if (body is Map) return optionalString(body['message']);
    return null;
  }

  /// يحدد ما إذا كانت الاستجابة تعلن الفشل صراحةً.
  /// بعض المسارات تستعمل `success` وبعضها `status`.
  static bool declaresFailure(dynamic body) {
    if (body is! Map) return false;
    final success = body['success'];
    final status = body['status'];
    if (success == false && status != true) return true;
    if (status == false && success != true) return true;
    return false;
  }
}
