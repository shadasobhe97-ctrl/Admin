import '../../../../core/utils/json_parsers.dart';

/// GET /api/admin/financial/invoices
/// GET /api/admin/financial/invoices/{id}
///
/// العقد لا يوثّق شكل عنصر الفاتورة بالتفصيل، لذلك يُقرأ كل حقل بشكل اختياري
/// وتُحفظ بقية الحقول غير المعروفة في [extras] لعرضها كما وردت من الخادم.
class FinancialInvoiceModel {
  final int id;
  final String? invoiceNumber;
  final double? amount;
  final String? status;
  final String? type;
  final DateTime? createdAt;
  final Map<String, dynamic> extras;

  const FinancialInvoiceModel({
    required this.id,
    this.invoiceNumber,
    this.amount,
    this.status,
    this.type,
    this.createdAt,
    this.extras = const {},
  });

  static const Set<String> _knownKeys = {
    'id',
    'invoice_number',
    'amount',
    'status',
    'type',
    'created_at',
  };

  factory FinancialInvoiceModel.fromJson(Map<String, dynamic> json) {
    return FinancialInvoiceModel(
      id: JsonParsers.intValue(json['id']),
      invoiceNumber: JsonParsers.optionalString(json['invoice_number']),
      amount: JsonParsers.optionalDouble(json['amount']),
      status: JsonParsers.optionalString(json['status']),
      type: JsonParsers.optionalString(json['type']),
      createdAt: JsonParsers.optionalDate(json['created_at']),
      extras: Map<String, dynamic>.fromEntries(
        json.entries.where((entry) => !_knownKeys.contains(entry.key)),
      ),
    );
  }

  FinancialInvoiceModel copyWith({
    int? id,
    String? invoiceNumber,
    double? amount,
    String? status,
    String? type,
    DateTime? createdAt,
    Map<String, dynamic>? extras,
  }) {
    return FinancialInvoiceModel(
      id: id ?? this.id,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      extras: extras ?? this.extras,
    );
  }
}
