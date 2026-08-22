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
  final String? rawSubMunicipalityName;
  final int? rawMunicipalityId;
  final String? rawMunicipalityName;
  final ZoneSubMunicipalityRef? subMunicipality;
  final String? rawFullPath;
  final String? createdAt;
  final String? updatedAt;

  const ZoneModel({
    required this.id,
    required this.name,
    this.zoneName,
    this.subMunicipalityId,
    this.rawSubMunicipalityName,
    this.rawMunicipalityId,
    this.rawMunicipalityName,
    this.subMunicipality,
    this.rawFullPath,
    this.createdAt,
    this.updatedAt,
  });

  factory ZoneModel.fromJson(Map<String, dynamic> json) {
    final subMunicipalityJson = JsonParsers.optionalMap(json['sub_municipality']);

    return ZoneModel(
      id: JsonParsers.intValue(json['id']),
      // في شجرة الجغرافيا يأتي الاسم في `name` فقط، وفي القائمة يأتي الاثنان.
      name: JsonParsers.optionalString(json['name']) ??
          JsonParsers.stringValue(json['zone_name']),
      zoneName: JsonParsers.optionalString(json['zone_name']),
      subMunicipalityId: JsonParsers.optionalInt(json['sub_municipality_id']) ??
          (subMunicipalityJson != null
              ? JsonParsers.optionalInt(subMunicipalityJson['id'])
              : null),
      rawSubMunicipalityName:
          JsonParsers.optionalString(json['sub_municipality_name']),
      rawMunicipalityId: JsonParsers.optionalInt(json['municipality_id']),
      rawMunicipalityName: JsonParsers.optionalString(json['municipality_name']),
      subMunicipality: subMunicipalityJson == null
          ? null
          : ZoneSubMunicipalityRef.fromJson(subMunicipalityJson),
      rawFullPath: JsonParsers.optionalString(json['full_path']),
      createdAt: JsonParsers.optionalString(json['created_at']),
      updatedAt: JsonParsers.optionalString(json['updated_at']),
    );
  }

  /// اسم المحلة التابعة لها المنطقة، من الحقل المباشر أو الكائن المتداخل.
  String? get subMunicipalityName =>
      rawSubMunicipalityName ?? subMunicipality?.name;

  /// معرّف البلدية الكبرى، من الحقل المباشر أو الكائن المتداخل.
  int? get municipalityId =>
      rawMunicipalityId ?? subMunicipality?.municipalityId;

  /// اسم البلدية الكبرى، من الحقل المباشر أو الكائن المتداخل.
  String? get municipalityName =>
      rawMunicipalityName ?? subMunicipality?.municipalityName;

  /// المسار الجغرافي الكامل للعرض.
  String get fullPath {
    if (rawFullPath != null && rawFullPath!.isNotEmpty) {
      return rawFullPath!;
    }
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
    String? rawSubMunicipalityName,
    int? rawMunicipalityId,
    String? rawMunicipalityName,
    ZoneSubMunicipalityRef? subMunicipality,
    String? rawFullPath,
    String? createdAt,
    String? updatedAt,
  }) {
    return ZoneModel(
      id: id ?? this.id,
      name: name ?? this.name,
      zoneName: zoneName ?? this.zoneName,
      subMunicipalityId: subMunicipalityId ?? this.subMunicipalityId,
      rawSubMunicipalityName:
          rawSubMunicipalityName ?? this.rawSubMunicipalityName,
      rawMunicipalityId: rawMunicipalityId ?? this.rawMunicipalityId,
      rawMunicipalityName: rawMunicipalityName ?? this.rawMunicipalityName,
      subMunicipality: subMunicipality ?? this.subMunicipality,
      rawFullPath: rawFullPath ?? this.rawFullPath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
