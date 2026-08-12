import '../../../../core/utils/json_parsers.dart';

/// الجهة التي أنهت العقد، حسب ما يقبله الخادم.
class TerminatedBy {
  const TerminatedBy._();

  static const String parent = 'parent';
  static const String driver = 'driver';

  static const List<String> all = [parent, driver];

  static String label(String value) {
    switch (value) {
      case parent:
        return 'ولي الأمر';
      case driver:
        return 'السائق';
      default:
        return value;
    }
  }
}

/// GET /api/admin/financial/contracts/{contractId}/termination-preview
///
/// معاينة فقط — لا تُنفّذ أي إنهاء للعقد.
class TerminationPreviewModel {
  final int contractId;
  final String contractNumber;
  final double totalPrice;
  final double executedCost;
  final double remainingBalance;
  final double cancellationFee;
  final double refundedToParent;

  const TerminationPreviewModel({
    required this.contractId,
    required this.contractNumber,
    required this.totalPrice,
    required this.executedCost,
    required this.remainingBalance,
    required this.cancellationFee,
    required this.refundedToParent,
  });

  factory TerminationPreviewModel.fromJson(Map<String, dynamic> json) {
    return TerminationPreviewModel(
      contractId: JsonParsers.intValue(json['contract_id']),
      contractNumber: JsonParsers.stringValue(json['contract_number']),
      totalPrice: JsonParsers.doubleValue(json['total_price']),
      executedCost: JsonParsers.doubleValue(json['executed_cost']),
      remainingBalance: JsonParsers.doubleValue(json['remaining_balance']),
      cancellationFee: JsonParsers.doubleValue(json['cancellation_fee']),
      refundedToParent: JsonParsers.doubleValue(json['refunded_to_parent']),
    );
  }

  TerminationPreviewModel copyWith({
    int? contractId,
    String? contractNumber,
    double? totalPrice,
    double? executedCost,
    double? remainingBalance,
    double? cancellationFee,
    double? refundedToParent,
  }) {
    return TerminationPreviewModel(
      contractId: contractId ?? this.contractId,
      contractNumber: contractNumber ?? this.contractNumber,
      totalPrice: totalPrice ?? this.totalPrice,
      executedCost: executedCost ?? this.executedCost,
      remainingBalance: remainingBalance ?? this.remainingBalance,
      cancellationFee: cancellationFee ?? this.cancellationFee,
      refundedToParent: refundedToParent ?? this.refundedToParent,
    );
  }
}
