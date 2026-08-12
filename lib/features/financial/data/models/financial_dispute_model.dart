import '../../../../core/utils/json_parsers.dart';

/// طرف في نزاع مالي (ولي أمر أو سائق).
class DisputePartyModel {
  final int? id;
  final String name;
  final String? phone;

  const DisputePartyModel({
    this.id,
    required this.name,
    this.phone,
  });

  /// يقبل الكائن المتداخل `{id, name, phone}` أو الحقول المسطّحة إن وردت.
  factory DisputePartyModel.fromJson(dynamic json) {
    if (json is Map) {
      final map = json.map((key, value) => MapEntry(key.toString(), value));
      return DisputePartyModel(
        id: JsonParsers.optionalInt(map['id']),
        name: JsonParsers.stringValue(map['name']),
        phone: JsonParsers.optionalString(map['phone']),
      );
    }
    return DisputePartyModel(name: JsonParsers.stringValue(json));
  }

  DisputePartyModel copyWith({int? id, String? name, String? phone}) {
    return DisputePartyModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
    );
  }
}

/// قرارات حل النزاع المسموح بها من الخادم.
class DisputeResolution {
  const DisputeResolution._();

  static const String parentRefunded = 'resolve_parent_refunded';
  static const String driverPaid = 'resolve_driver_paid';

  static const List<String> all = [parentRefunded, driverPaid];

  static String label(String resolution) {
    switch (resolution) {
      case parentRefunded:
        return 'تعويض ولي الأمر (استرجاع المبلغ)';
      case driverPaid:
        return 'صرف المبلغ للسائق';
      default:
        return resolution;
    }
  }
}

/// GET /api/admin/financial/disputes
/// GET /api/admin/financial/disputes/{id}
class FinancialDisputeModel {
  final int id;
  final int? tripId;
  final DisputePartyModel? parent;
  final DisputePartyModel? driver;
  final double amount;
  final String? reason;
  final String status;
  final String? resolutionNotes;
  final DateTime? createdAt;

  const FinancialDisputeModel({
    required this.id,
    this.tripId,
    this.parent,
    this.driver,
    required this.amount,
    this.reason,
    required this.status,
    this.resolutionNotes,
    this.createdAt,
  });

  factory FinancialDisputeModel.fromJson(Map<String, dynamic> json) {
    return FinancialDisputeModel(
      id: JsonParsers.intValue(json['id']),
      tripId: JsonParsers.optionalInt(json['trip_id']),
      parent: json['parent'] == null
          ? null
          : DisputePartyModel.fromJson(json['parent']),
      driver: json['driver'] == null
          ? null
          : DisputePartyModel.fromJson(json['driver']),
      amount: JsonParsers.doubleValue(json['amount']),
      reason: JsonParsers.optionalString(json['reason']),
      status: JsonParsers.stringValue(json['status']),
      resolutionNotes: JsonParsers.optionalString(json['resolution_notes']),
      createdAt: JsonParsers.optionalDate(json['created_at']),
    );
  }

  bool get isOpen => status.toLowerCase() == 'open';

  FinancialDisputeModel copyWith({
    int? id,
    int? tripId,
    DisputePartyModel? parent,
    DisputePartyModel? driver,
    double? amount,
    String? reason,
    String? status,
    String? resolutionNotes,
    DateTime? createdAt,
  }) {
    return FinancialDisputeModel(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      parent: parent ?? this.parent,
      driver: driver ?? this.driver,
      amount: amount ?? this.amount,
      reason: reason ?? this.reason,
      status: status ?? this.status,
      resolutionNotes: resolutionNotes ?? this.resolutionNotes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
