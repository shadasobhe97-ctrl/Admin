import '../../../../core/utils/json_parsers.dart';

/// نموذج نتيجة عنصر البحث الجغرافي القادم من الخادم.
class GeographyItemModel {
  final int id;
  final String name;
  final int? municipalityId;

  const GeographyItemModel({
    required this.id,
    required this.name,
    this.municipalityId,
  });

  factory GeographyItemModel.fromJson(Map<String, dynamic> json) {
    return GeographyItemModel(
      id: JsonParsers.intValue(json['id']),
      name: JsonParsers.stringValue(json['name']),
      municipalityId: JsonParsers.optionalInt(json['municipality_id']),
    );
  }

  GeographyItemModel copyWith({
    int? id,
    String? name,
    int? municipalityId,
  }) {
    return GeographyItemModel(
      id: id ?? this.id,
      name: name ?? this.name,
      municipalityId: municipalityId ?? this.municipalityId,
    );
  }
}
