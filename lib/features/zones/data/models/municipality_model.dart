import '../../../../core/utils/json_parsers.dart';
import 'sub_municipality_model.dart';

/// المستوى الأول: البلدية الكبرى.
///
/// GET /api/admin/municipalities  → `sub_municipalities` قد تأتي فارغة
/// GET /api/admin/zones-tree      → `sub_municipalities` محمّلة ومعها مناطقها
class MunicipalityModel {
  final int id;
  final String name;
  final List<SubMunicipalityModel> subMunicipalities;

  const MunicipalityModel({
    required this.id,
    required this.name,
    this.subMunicipalities = const [],
  });

  factory MunicipalityModel.fromJson(Map<String, dynamic> json) {
    return MunicipalityModel(
      id: JsonParsers.intValue(json['id']),
      name: JsonParsers.stringValue(json['name']),
      subMunicipalities: JsonParsers.listOf(
        json['sub_municipalities'],
        SubMunicipalityModel.fromJson,
      ),
    );
  }

  int get subMunicipalitiesCount => subMunicipalities.length;

  /// إجمالي المناطق الدقيقة عبر كل المحلات التابعة (من بيانات الشجرة).
  int get zonesCount =>
      subMunicipalities.fold(0, (sum, sub) => sum + sub.zonesCount);

  MunicipalityModel copyWith({
    int? id,
    String? name,
    List<SubMunicipalityModel>? subMunicipalities,
  }) {
    return MunicipalityModel(
      id: id ?? this.id,
      name: name ?? this.name,
      subMunicipalities: subMunicipalities ?? this.subMunicipalities,
    );
  }
}
