import '../../../../core/utils/json_parsers.dart';

/// نموذج إعدادات التسعير الموحدة.
/// GET|POST|PUT /api/admin/financial/pricing-settings
class PricingSettingsModel {
  final double discountOneChild;
  final double discountTwoChildren;
  final double discountThreePlusChildren;
  final double platformCommissionRate;
  final double pricePerKmAc;
  final double pricePerKmNonAc;

  const PricingSettingsModel({
    required this.discountOneChild,
    required this.discountTwoChildren,
    required this.discountThreePlusChildren,
    required this.platformCommissionRate,
    required this.pricePerKmAc,
    required this.pricePerKmNonAc,
  });

  factory PricingSettingsModel.fromJson(Map<String, dynamic> json) {
    return PricingSettingsModel(
      discountOneChild: JsonParsers.doubleValue(json['discount_one_child']),
      discountTwoChildren:
          JsonParsers.doubleValue(json['discount_two_children']),
      discountThreePlusChildren:
          JsonParsers.doubleValue(json['discount_three_plus_children']),
      platformCommissionRate:
          JsonParsers.doubleValue(json['platform_commission_rate']),
      pricePerKmAc: JsonParsers.doubleValue(json['price_per_km_ac']),
      pricePerKmNonAc: JsonParsers.doubleValue(json['price_per_km_non_ac']),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'discount_one_child': discountOneChild,
      'discount_two_children': discountTwoChildren,
      'discount_three_plus_children': discountThreePlusChildren,
      'platform_commission_rate': platformCommissionRate,
      'price_per_km_ac': pricePerKmAc,
      'price_per_km_non_ac': pricePerKmNonAc,
    };
  }

  PricingSettingsModel copyWith({
    double? discountOneChild,
    double? discountTwoChildren,
    double? discountThreePlusChildren,
    double? platformCommissionRate,
    double? pricePerKmAc,
    double? pricePerKmNonAc,
  }) {
    return PricingSettingsModel(
      discountOneChild: discountOneChild ?? this.discountOneChild,
      discountTwoChildren: discountTwoChildren ?? this.discountTwoChildren,
      discountThreePlusChildren:
          discountThreePlusChildren ?? this.discountThreePlusChildren,
      platformCommissionRate:
          platformCommissionRate ?? this.platformCommissionRate,
      pricePerKmAc: pricePerKmAc ?? this.pricePerKmAc,
      pricePerKmNonAc: pricePerKmNonAc ?? this.pricePerKmNonAc,
    );
  }
}
