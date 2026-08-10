class ZoneModel {
  final int id;
  final String name;
  final int? parentId;
  final List<ZoneModel> children;

  const ZoneModel({
    required this.id,
    required this.name,
    this.parentId,
    this.children = const [],
  });

  factory ZoneModel.fromJson(Map<String, dynamic> json) {
    List<ZoneModel> childrenList = [];
    if (json['children'] is List) {
      childrenList = (json['children'] as List)
          .map((item) => ZoneModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } else if (json['sub_zones'] is List) {
      childrenList = (json['sub_zones'] as List)
          .map((item) => ZoneModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return ZoneModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      parentId: json['parent_id'] != null ? int.tryParse(json['parent_id'].toString()) : null,
      children: childrenList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (parentId != null) 'parent_id': parentId,
      if (children.isNotEmpty) 'children': children.map((c) => c.toJson()).toList(),
    };
  }

  ZoneModel copyWith({
    int? id,
    String? name,
    int? parentId,
    List<ZoneModel>? children,
  }) {
    return ZoneModel(
      id: id ?? this.id,
      name: name ?? this.name,
      parentId: parentId ?? this.parentId,
      children: children ?? this.children,
    );
  }
}
