class SchoolModel {
  final int id;
  final String name;
  final String address;
  final double? latitude;
  final double? longitude;
  final int? zoneId;
  final String? zoneName;

  const SchoolModel({
    required this.id,
    required this.name,
    required this.address,
    this.latitude,
    this.longitude,
    this.zoneId,
    this.zoneName,
  });

  factory SchoolModel.fromJson(Map<String, dynamic> json) {
    return SchoolModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      latitude: json['latitude'] != null ? double.tryParse(json['latitude'].toString()) : null,
      longitude: json['longitude'] != null ? double.tryParse(json['longitude'].toString()) : null,
      zoneId: json['zone_id'] != null ? int.tryParse(json['zone_id'].toString()) : null,
      zoneName: json['zone_name']?.toString() ?? json['zone']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (zoneId != null) 'zone_id': zoneId,
      if (zoneName != null) 'zone_name': zoneName,
    };
  }

  SchoolModel copyWith({
    int? id,
    String? name,
    String? address,
    double? latitude,
    double? longitude,
    int? zoneId,
    String? zoneName,
  }) {
    return SchoolModel(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      zoneId: zoneId ?? this.zoneId,
      zoneName: zoneName ?? this.zoneName,
    );
  }
}
