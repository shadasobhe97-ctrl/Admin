import '../../../../core/utils/json_parsers.dart';

/// الجهة التي أنهت العقد، حسب ما يقبله الخادم.
class TerminatedBy {
  const TerminatedBy._();

  static const String parent = 'parent';
  static const String driver = 'driver';
  static const String admin = 'admin';

  static const List<String> all = [parent, driver, admin];

  static String label(String value) {
    switch (value) {
      case parent:
        return 'ولي الأمر';
      case driver:
        return 'السائق';
      case admin:
        return 'الإدارة';
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
  final double totalContractValue;
  final double completedTripsCost;
  final double remainingEscrow;
  final double penaltyFee;
  final double refundToParent;
  final double payoutToDriver;

  const TerminationPreviewModel({
    required this.contractId,
    required this.contractNumber,
    required this.totalContractValue,
    required this.completedTripsCost,
    required this.remainingEscrow,
    required this.penaltyFee,
    required this.refundToParent,
    required this.payoutToDriver,
  });

  factory TerminationPreviewModel.fromJson(Map<String, dynamic> json) {
    return TerminationPreviewModel(
      contractId: JsonParsers.intValue(json['contract_id']),
      contractNumber: JsonParsers.stringValue(json['contract_number']),
      totalContractValue: JsonParsers.doubleValue(json['total_contract_value']),
      completedTripsCost: JsonParsers.doubleValue(json['completed_trips_cost']),
      remainingEscrow: JsonParsers.doubleValue(json['remaining_escrow']),
      penaltyFee: JsonParsers.doubleValue(json['penalty_fee']),
      refundToParent: JsonParsers.doubleValue(json['refund_to_parent']),
      payoutToDriver: JsonParsers.doubleValue(json['payout_to_driver']),
    );
  }

  TerminationPreviewModel copyWith({
    int? contractId,
    String? contractNumber,
    double? totalContractValue,
    double? completedTripsCost,
    double? remainingEscrow,
    double? penaltyFee,
    double? refundToParent,
    double? payoutToDriver,
  }) {
    return TerminationPreviewModel(
      contractId: contractId ?? this.contractId,
      contractNumber: contractNumber ?? this.contractNumber,
      totalContractValue: totalContractValue ?? this.totalContractValue,
      completedTripsCost: completedTripsCost ?? this.completedTripsCost,
      remainingEscrow: remainingEscrow ?? this.remainingEscrow,
      penaltyFee: penaltyFee ?? this.penaltyFee,
      refundToParent: refundToParent ?? this.refundToParent,
      payoutToDriver: payoutToDriver ?? this.payoutToDriver,
    );
  }
}

