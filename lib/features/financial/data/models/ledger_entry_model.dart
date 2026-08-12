import '../../../../core/utils/json_parsers.dart';

/// عنصر واحد من سجل الحركات المالية.
/// GET /api/admin/financial/ledger
class LedgerEntryModel {
  final int id;
  final String referenceNumber;
  final String? sourceAccount;
  final String? destinationAccount;

  /// المبلغ كما أرسله الخادم في حقل `amount`.
  final double amount;
  final String type;
  final String status;
  final DateTime? createdAt;

  const LedgerEntryModel({
    required this.id,
    required this.referenceNumber,
    this.sourceAccount,
    this.destinationAccount,
    required this.amount,
    required this.type,
    required this.status,
    this.createdAt,
  });

  factory LedgerEntryModel.fromJson(Map<String, dynamic> json) {
    return LedgerEntryModel(
      id: JsonParsers.intValue(json['id']),
      referenceNumber: JsonParsers.stringValue(json['reference_number']),
      sourceAccount: JsonParsers.optionalString(json['source_account']),
      destinationAccount:
          JsonParsers.optionalString(json['destination_account']),
      amount: JsonParsers.doubleValue(json['amount']),
      type: JsonParsers.stringValue(json['type']),
      status: JsonParsers.stringValue(json['status']),
      createdAt: JsonParsers.optionalDate(json['created_at']),
    );
  }

  LedgerEntryModel copyWith({
    int? id,
    String? referenceNumber,
    String? sourceAccount,
    String? destinationAccount,
    double? amount,
    String? type,
    String? status,
    DateTime? createdAt,
  }) {
    return LedgerEntryModel(
      id: id ?? this.id,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      sourceAccount: sourceAccount ?? this.sourceAccount,
      destinationAccount: destinationAccount ?? this.destinationAccount,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// فلاتر سجل الحركات كما يقبلها الخادم.
class LedgerFilters {
  final int page;
  final int perPage;
  final String? type;
  final String? status;
  final String? search;
  final String? dateFrom;
  final String? dateTo;

  const LedgerFilters({
    this.page = 1,
    this.perPage = 20,
    this.type,
    this.status,
    this.search,
    this.dateFrom,
    this.dateTo,
  });

  Map<String, dynamic> toQuery() {
    return <String, dynamic>{
      'page': page,
      'per_page': perPage,
      if (type != null && type!.isNotEmpty) 'type': type,
      if (status != null && status!.isNotEmpty) 'status': status,
      if (search != null && search!.trim().isNotEmpty) 'search': search!.trim(),
      if (dateFrom != null && dateFrom!.isNotEmpty) 'date_from': dateFrom,
      if (dateTo != null && dateTo!.isNotEmpty) 'date_to': dateTo,
    };
  }

  bool get hasActiveFilters =>
      (type != null && type!.isNotEmpty) ||
      (status != null && status!.isNotEmpty) ||
      (search != null && search!.trim().isNotEmpty) ||
      (dateFrom != null && dateFrom!.isNotEmpty) ||
      (dateTo != null && dateTo!.isNotEmpty);

  LedgerFilters copyWith({
    int? page,
    int? perPage,
    String? type,
    String? status,
    String? search,
    String? dateFrom,
    String? dateTo,
    bool clearType = false,
    bool clearStatus = false,
    bool clearSearch = false,
    bool clearDateFrom = false,
    bool clearDateTo = false,
  }) {
    return LedgerFilters(
      page: page ?? this.page,
      perPage: perPage ?? this.perPage,
      type: clearType ? null : (type ?? this.type),
      status: clearStatus ? null : (status ?? this.status),
      search: clearSearch ? null : (search ?? this.search),
      dateFrom: clearDateFrom ? null : (dateFrom ?? this.dateFrom),
      dateTo: clearDateTo ? null : (dateTo ?? this.dateTo),
    );
  }
}
