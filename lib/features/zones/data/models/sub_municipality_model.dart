import '../../../../core/utils/json_parsers.dart';
import 'zone_model.dart';

/// البلدية الكبرى كما تأتي مختصرة داخل كائن البلدية الفرعية.
/// GET /api/admin/sub-municipalities → data[].municipality
class SubMunicipalityParentRef {
  final int id;
  final String name;

  const SubMunicipalityParentRef({required this.id, required this.name});

  factory SubMunicipalityParentRef.fromJson(Map<String, dynamic> json) {
    return SubMunicipalityParentRef(
      id: JsonParsers.intValue(json['id']),
      name: JsonParsers.stringValue(json['name']),
    );
  }

  SubMunicipalityParentRef copyWith({int? id, String? name}) {
    return SubMunicipalityParentRef(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }
}

/// المستوى الثاني: البلدية الفرعية / المحلة.
///
/// GET /api/admin/sub-municipalities  → تحمل `municipality` المتداخلة
/// GET /api/admin/zones-tree          → تحمل `zones` التابعة لها
///
/// الحقلان المتداخلان اختياريان لأن كل Endpoint يرسل أحدهما فقط.
class SubMunicipalityModel {
  final int id;
  final String name;
  final int? municipalityId;
  final SubMunicipalityParentRef? municipality;
  final List<ZoneModel> zones;

  const SubMunicipalityModel({
    required this.id,
    required this.name,
    this.municipalityId,
    this.municipality,
    this.zones = const [],
  });

  factory SubMunicipalityModel.fromJson(Map<String, dynamic> json) {
    final municipalityJson = JsonParsers.optionalMap(json['municipality']);

    return SubMunicipalityModel(
      id: JsonParsers.intValue(json['id']),
      name: JsonParsers.stringValue(json['name']),
      municipalityId: JsonParsers.optionalInt(json['municipality_id']),
      municipality: municipalityJson == null
          ? null
          : SubMunicipalityParentRef.fromJson(municipalityJson),
      zones: JsonParsers.listOf(json['zones'], ZoneModel.fromJson),
    );
  }

  /// اسم البلدية الكبرى من الكائن المتداخل إن توفّر.
  String? get municipalityName => municipality?.name;

  int get zonesCount => zones.length;

  SubMunicipalityModel copyWith({
    int? id,
    String? name,
    int? municipalityId,
    SubMunicipalityParentRef? municipality,
    List<ZoneModel>? zones,
  }) {
    return SubMunicipalityModel(
      id: id ?? this.id,
      name: name ?? this.name,
      municipalityId: municipalityId ?? this.municipalityId,
      municipality: municipality ?? this.municipality,
      zones: zones ?? this.zones,
    );
  }
}
