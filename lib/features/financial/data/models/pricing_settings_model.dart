import '../../../../core/utils/json_parsers.dart';
import 'location_change_fee_tier_model.dart';

/// نموذج إعدادات التسعير الموحدة (يشمل خصومات الأطفال، التسعير بالكيلومتر، ورسوم تغيير الموقع).
/// GET|POST|PUT /api/admin/financial/pricing-settings
class PricingSettingsModel {
  final int? id;
  final double discountOneChild;
  final double discountTwoChildren;
  final double discountThreePlusChildren;
  final double platformCommissionRate;
  final double pricePerKmAc;
  final double pricePerKmNonAc;

  // الحقول الجديدة (اختيارية للتوافق مع الإصدارات السابقة)
  final double? locationChangeFee;
  final double? locationChangeFeeUnder2Km;
  final double? locationChangeFee2To6Km;
  final double? locationChangeFee6To10Km;
  final List<LocationChangeFeeTierModel>? locationChangeFeeTiers;
  final double? maxLocationChangeDistanceKm;
  final String? currency;
  final String? updatedAt;

  const PricingSettingsModel({
    this.id,
    required this.discountOneChild,
    required this.discountTwoChildren,
    required this.discountThreePlusChildren,
    required this.platformCommissionRate,
    required this.pricePerKmAc,
    required this.pricePerKmNonAc,
    this.locationChangeFee,
    this.locationChangeFeeUnder2Km,
    this.locationChangeFee2To6Km,
    this.locationChangeFee6To10Km,
    this.locationChangeFeeTiers,
    this.maxLocationChangeDistanceKm,
    this.currency,
    this.updatedAt,
  });

  factory PricingSettingsModel.fromJson(Map<String, dynamic> json) {
    return PricingSettingsModel(
      id: JsonParsers.optionalInt(json['id']),
      discountOneChild: JsonParsers.doubleValue(json['discount_one_child']),
      discountTwoChildren:
          JsonParsers.doubleValue(json['discount_two_children']),
      discountThreePlusChildren:
          JsonParsers.doubleValue(json['discount_three_plus_children']),
      platformCommissionRate:
          JsonParsers.doubleValue(json['platform_commission_rate']),
      pricePerKmAc: JsonParsers.doubleValue(json['price_per_km_ac']),
      pricePerKmNonAc: JsonParsers.doubleValue(json['price_per_km_non_ac']),
      locationChangeFee:
          JsonParsers.optionalDouble(json['location_change_fee']),
      locationChangeFeeUnder2Km:
          JsonParsers.optionalDouble(json['location_change_fee_under_2km']),
      locationChangeFee2To6Km:
          JsonParsers.optionalDouble(json['location_change_fee_2_to_6km']),
      locationChangeFee6To10Km:
          JsonParsers.optionalDouble(json['location_change_fee_6_to_10km']),
      locationChangeFeeTiers: json['location_change_fee_tiers'] is List
          ? JsonParsers.listOf(
              json['location_change_fee_tiers'],
              LocationChangeFeeTierModel.fromJson,
            )
          : null,
      maxLocationChangeDistanceKm: JsonParsers.optionalDouble(
        json['max_location_change_distance_km'],
      ),
      currency: JsonParsers.optionalString(json['currency']),
      updatedAt: JsonParsers.optionalString(json['updated_at']),
    );
  }

  /// تحضير البيانات لطلب التعديل/الإرسال POST/PUT.
  /// يحمل الحقول الستة الإلزامية وحقول رسوم تغيير الموقع المدخلة،
  /// واستبعاد حقول المخرجات والنظام المعروضة في GET فقط (مثل id, currency, updated_at, location_change_fee_tiers).
  Map<String, dynamic> toRequestJson() {
    return <String, dynamic>{
      'discount_one_child': discountOneChild,
      'discount_two_children': discountTwoChildren,
      'discount_three_plus_children': discountThreePlusChildren,
      'platform_commission_rate': platformCommissionRate,
      'price_per_km_ac': pricePerKmAc,
      'price_per_km_non_ac': pricePerKmNonAc,
      if (locationChangeFee != null)
        'location_change_fee': locationChangeFee,
      if (locationChangeFeeUnder2Km != null)
        'location_change_fee_under_2km': locationChangeFeeUnder2Km,
      if (locationChangeFee2To6Km != null)
        'location_change_fee_2_to_6km': locationChangeFee2To6Km,
      if (locationChangeFee6To10Km != null)
        'location_change_fee_6_to_10km': locationChangeFee6To10Km,
      if (maxLocationChangeDistanceKm != null)
        'max_location_change_distance_km': maxLocationChangeDistanceKm,
    };
  }

  Map<String, dynamic> toJson() => toRequestJson();

  PricingSettingsModel copyWith({
    int? id,
    double? discountOneChild,
    double? discountTwoChildren,
    double? discountThreePlusChildren,
    double? platformCommissionRate,
    double? pricePerKmAc,
    double? pricePerKmNonAc,
    double? locationChangeFee,
    double? locationChangeFeeUnder2Km,
    double? locationChangeFee2To6Km,
    double? locationChangeFee6To10Km,
    List<LocationChangeFeeTierModel>? locationChangeFeeTiers,
    double? maxLocationChangeDistanceKm,
    String? currency,
    String? updatedAt,
  }) {
    return PricingSettingsModel(
      id: id ?? this.id,
      discountOneChild: discountOneChild ?? this.discountOneChild,
      discountTwoChildren: discountTwoChildren ?? this.discountTwoChildren,
      discountThreePlusChildren:
          discountThreePlusChildren ?? this.discountThreePlusChildren,
      platformCommissionRate:
          platformCommissionRate ?? this.platformCommissionRate,
      pricePerKmAc: pricePerKmAc ?? this.pricePerKmAc,
      pricePerKmNonAc: pricePerKmNonAc ?? this.pricePerKmNonAc,
      locationChangeFee: locationChangeFee ?? this.locationChangeFee,
      locationChangeFeeUnder2Km:
          locationChangeFeeUnder2Km ?? this.locationChangeFeeUnder2Km,
      locationChangeFee2To6Km:
          locationChangeFee2To6Km ?? this.locationChangeFee2To6Km,
      locationChangeFee6To10Km:
          locationChangeFee6To10Km ?? this.locationChangeFee6To10Km,
      locationChangeFeeTiers:
          locationChangeFeeTiers ?? this.locationChangeFeeTiers,
      maxLocationChangeDistanceKm:
          maxLocationChangeDistanceKm ?? this.maxLocationChangeDistanceKm,
      currency: currency ?? this.currency,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
