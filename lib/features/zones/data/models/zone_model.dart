import '../../../../core/utils/json_parsers.dart';

/// البلدية الفرعية كما تأتي مختصرة داخل كائن المنطقة الدقيقة.
/// GET /api/admin/zones → data[].sub_municipality
class ZoneSubMunicipalityRef {
  final int id;
  final String name;
  final int? municipalityId;
  final String? municipalityName;

  const ZoneSubMunicipalityRef({
    required this.id,
    required this.name,
    this.municipalityId,
    this.municipalityName,
  });

  factory ZoneSubMunicipalityRef.fromJson(Map<String, dynamic> json) {
    return ZoneSubMunicipalityRef(
      id: JsonParsers.intValue(json['id']),
      name: JsonParsers.stringValue(json['name']),
      municipalityId: JsonParsers.optionalInt(json['municipality_id']),
      municipalityName: JsonParsers.optionalString(json['municipality_name']),
    );
  }

  ZoneSubMunicipalityRef copyWith({
    int? id,
    String? name,
    int? municipalityId,
    String? municipalityName,
  }) {
    return ZoneSubMunicipalityRef(
      id: id ?? this.id,
      name: name ?? this.name,
      municipalityId: municipalityId ?? this.municipalityId,
      municipalityName: municipalityName ?? this.municipalityName,
    );
  }
}

/// المستوى الثالث: المنطقة الدقيقة.
///
/// GET /api/admin/zones
/// GET /api/admin/zones/{id}
///
/// الخادم يرسل الاسم في `name` و`zone_name` معاً، ويرسل الانتماء عبر
/// `sub_municipality_id` (وليس `parent_id`).
class ZoneModel {
  final int id;
  final String name;

  /// نسخة الخادم من الاسم في حقل `zone_name` عند توفّرها.
  final String? zoneName;
  final int? subMunicipalityId;
  final ZoneSubMunicipalityRef? subMunicipality;
  final String? createdAt;

  const ZoneModel({
    required this.id,
    required this.name,
    this.zoneName,
    this.subMunicipalityId,
    this.subMunicipality,
    this.createdAt,
  });

  factory ZoneModel.fromJson(Map<String, dynamic> json) {
    final subMunicipalityJson = JsonParsers.optionalMap(json['sub_municipality']);

    return ZoneModel(
      id: JsonParsers.intValue(json['id']),
      // في شجرة الجغرافيا يأتي الاسم في `name` فقط، وفي القائمة يأتي الاثنان.
      name: JsonParsers.optionalString(json['name']) ??
          JsonParsers.stringValue(json['zone_name']),
      zoneName: JsonParsers.optionalString(json['zone_name']),
      subMunicipalityId: JsonParsers.optionalInt(json['sub_municipality_id']),
      subMunicipality: subMunicipalityJson == null
          ? null
          : ZoneSubMunicipalityRef.fromJson(subMunicipalityJson),
      createdAt: JsonParsers.optionalString(json['created_at']),
    );
  }

  /// اسم المحلة التابعة لها المنطقة، من الكائن المتداخل إن توفّر.
  String? get subMunicipalityName => subMunicipality?.name;

  /// اسم البلدية الكبرى، من الكائن المتداخل إن توفّر.
  String? get municipalityName => subMunicipality?.municipalityName;

  /// المسار الجغرافي الكامل للعرض، يُبنى مما أرسله الخادم فقط.
  String get fullPath {
    final parts = <String>[
      if (municipalityName != null) municipalityName!,
      if (subMunicipalityName != null) subMunicipalityName!,
      name,
    ];
    return parts.join(' ← ');
  }

  ZoneModel copyWith({
    int? id,
    String? name,
    String? zoneName,
    int? subMunicipalityId,
    ZoneSubMunicipalityRef? subMunicipality,
    String? createdAt,
  }) {
    return ZoneModel(
      id: id ?? this.id,
      name: name ?? this.name,
      zoneName: zoneName ?? this.zoneName,
      subMunicipalityId: subMunicipalityId ?? this.subMunicipalityId,
      subMunicipality: subMunicipality ?? this.subMunicipality,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
