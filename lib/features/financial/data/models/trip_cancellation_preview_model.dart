import '../../../../core/utils/json_parsers.dart';

/// الجهة الملغية للرحلة، حسب القيم المسموح بها من الخادم.
class CancelledBy {
  const CancelledBy._();

  static const String parent = 'parent';
  static const String driver = 'driver';
  static const String noShow = 'no_show';

  static const List<String> all = [parent, driver, noShow];

  static String label(String value) {
    switch (value) {
      case parent:
        return 'ولي الأمر';
      case driver:
        return 'السائق';
      case noShow:
        return 'عدم حضور (No Show)';
      default:
        return value;
    }
  }
}

/// GET /api/admin/financial/trips/{tripId}/cancel-preview
///
/// معاينة فقط — لا تُنفّذ أي إلغاء للرحلة.
class TripCancellationPreviewModel {
  final int tripId;
  final String cancelledBy;
  final double tripPriceDinar;
  final double parentRefundDinar;
  final double driverPayDinar;
  final double platformAmountDinar;
  final double penaltyDinar;

  const TripCancellationPreviewModel({
    required this.tripId,
    required this.cancelledBy,
    required this.tripPriceDinar,
    required this.parentRefundDinar,
    required this.driverPayDinar,
    required this.platformAmountDinar,
    required this.penaltyDinar,
  });

  factory TripCancellationPreviewModel.fromJson(Map<String, dynamic> json) {
    return TripCancellationPreviewModel(
      tripId: JsonParsers.intValue(json['trip_id']),
      cancelledBy: JsonParsers.stringValue(json['cancelled_by']),
      tripPriceDinar: JsonParsers.doubleValue(json['trip_price_dinar']),
      parentRefundDinar: JsonParsers.doubleValue(json['parent_refund_dinar']),
      driverPayDinar: JsonParsers.doubleValue(json['driver_pay_dinar']),
      platformAmountDinar:
          JsonParsers.doubleValue(json['platform_amount_dinar']),
      penaltyDinar: JsonParsers.doubleValue(json['penalty_dinar']),
    );
  }

  TripCancellationPreviewModel copyWith({
    int? tripId,
    String? cancelledBy,
    double? tripPriceDinar,
    double? parentRefundDinar,
    double? driverPayDinar,
    double? platformAmountDinar,
    double? penaltyDinar,
  }) {
    return TripCancellationPreviewModel(
      tripId: tripId ?? this.tripId,
      cancelledBy: cancelledBy ?? this.cancelledBy,
      tripPriceDinar: tripPriceDinar ?? this.tripPriceDinar,
      parentRefundDinar: parentRefundDinar ?? this.parentRefundDinar,
      driverPayDinar: driverPayDinar ?? this.driverPayDinar,
      platformAmountDinar: platformAmountDinar ?? this.platformAmountDinar,
      penaltyDinar: penaltyDinar ?? this.penaltyDinar,
    );
  }
}
