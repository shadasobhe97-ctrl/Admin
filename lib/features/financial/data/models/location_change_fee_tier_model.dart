import '../../../../core/utils/json_parsers.dart';

/// نموذج شريحة رسوم تغيير الموقع (Location Change Fee Tier).
class LocationChangeFeeTierModel {
  final String? tier;
  final String? label;
  final double? minKm;
  final double? maxKm;
  final bool? maxInclusive;
  final double? fee;

  const LocationChangeFeeTierModel({
    this.tier,
    this.label,
    this.minKm,
    this.maxKm,
    this.maxInclusive,
    this.fee,
  });

  factory LocationChangeFeeTierModel.fromJson(Map<String, dynamic> json) {
    return LocationChangeFeeTierModel(
      tier: JsonParsers.optionalString(json['tier']),
      label: JsonParsers.optionalString(json['label']),
      minKm: JsonParsers.optionalDouble(json['min_km']),
      maxKm: JsonParsers.optionalDouble(json['max_km']),
      maxInclusive: JsonParsers.optionalBool(json['max_inclusive']),
      fee: JsonParsers.optionalDouble(json['fee']),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      if (tier != null) 'tier': tier,
      if (label != null) 'label': label,
      if (minKm != null) 'min_km': minKm,
      if (maxKm != null) 'max_km': maxKm,
      if (maxInclusive != null) 'max_inclusive': maxInclusive,
      if (fee != null) 'fee': fee,
    };
  }
}
