import '../../../../core/utils/json_parsers.dart';

/// نتيجة أي عملية POST مالية.
/// تحمل رسالة الخادم كما هي بالإضافة إلى كائن `data` الخام لمن يحتاجه.
class FinancialActionResult {
  final String message;
  final Map<String, dynamic> data;

  const FinancialActionResult({
    required this.message,
    this.data = const {},
  });

  factory FinancialActionResult.fromResponse(
    dynamic body, {
    required String fallbackMessage,
  }) {
    return FinancialActionResult(
      message: JsonParsers.extractMessage(body) ?? fallbackMessage,
      data: JsonParsers.mapValue(body is Map ? body['data'] : null),
    );
  }
}
