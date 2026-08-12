import '../../../../core/utils/json_parsers.dart';

/// نتيجة أي عملية كتابة جغرافية (إضافة / تعديل / حذف).
/// تحمل رسالة الخادم كما هي دون استبدالها.
class GeoActionResult {
  final String message;
  final Map<String, dynamic> data;

  const GeoActionResult({required this.message, this.data = const {}});

  factory GeoActionResult.fromResponse(
    dynamic body, {
    required String fallbackMessage,
  }) {
    return GeoActionResult(
      message: JsonParsers.extractMessage(body) ?? fallbackMessage,
      data:
          JsonParsers.optionalMap(body is Map ? body['data'] : null) ?? const {},
    );
  }
}
