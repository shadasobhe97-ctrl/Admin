class RoleModel {
  final int id;
  final String key;
  final String name;
  final String? description;
  final List<String> permissions;

  const RoleModel({
    required this.id,
    required this.key,
    required this.name,
    this.description,
    this.permissions = const [],
  });

  factory RoleModel.fromJson(Map<String, dynamic> json) {
    int parseId(dynamic val) {
      if (val is int) return val;
      return int.tryParse(val?.toString() ?? '0') ?? 0;
    }

    List<String> parsePermissions(dynamic val) {
      if (val is List) {
        return val.map((e) {
          if (e is Map<String, dynamic>) {
            return e['key']?.toString() ?? e['name']?.toString() ?? '';
          }
          return e.toString();
        }).where((element) => element.isNotEmpty).toList();
      }
      return [];
    }

    return RoleModel(
      id: parseId(json['id']),
      key: json['key']?.toString() ?? json['role_key']?.toString() ?? '',
      name: json['name']?.toString() ?? json['role_name']?.toString() ?? '',
      description: json['description']?.toString(),
      permissions: parsePermissions(json['permissions']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'key': key,
      'name': name,
      if (description != null) 'description': description,
      'permissions': permissions,
    };
  }
}

class PermissionModel {
  final String key;
  final String name;
  final String? description;

  const PermissionModel({
    required this.key,
    required this.name,
    this.description,
  });

  factory PermissionModel.fromJson(Map<String, dynamic> json) {
    return PermissionModel(
      key: json['key']?.toString() ?? '',
      name: json['name']?.toString() ?? json['key']?.toString() ?? '',
      description: json['description']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'name': name,
      if (description != null) 'description': description,
    };
  }
}

class PermissionGroupModel {
  final String groupKey;
  final String groupName;
  final List<PermissionModel> permissions;

  const PermissionGroupModel({
    required this.groupKey,
    required this.groupName,
    required this.permissions,
  });

  factory PermissionGroupModel.fromJson(Map<String, dynamic> json) {
    List<PermissionModel> parsePermissions(dynamic val) {
      if (val is List) {
        return val
            .map((e) => e is Map<String, dynamic>
                ? PermissionModel.fromJson(e)
                : PermissionModel(key: e.toString(), name: e.toString()))
            .toList();
      }
      return [];
    }

    return PermissionGroupModel(
      groupKey: json['group_key']?.toString() ?? json['key']?.toString() ?? '',
      groupName: json['group_name']?.toString() ?? json['name']?.toString() ?? '',
      permissions: parsePermissions(json['permissions']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'group_key': groupKey,
      'group_name': groupName,
      'permissions': permissions.map((e) => e.toJson()).toList(),
    };
  }
}

class RolesPermissionsResponseModel {
  final List<RoleModel> roles;
  final List<PermissionGroupModel> permissionsTree;

  const RolesPermissionsResponseModel({
    required this.roles,
    required this.permissionsTree,
  });

  factory RolesPermissionsResponseModel.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> dataMap = json;
    if (json['data'] is Map<String, dynamic>) {
      dataMap = json['data'] as Map<String, dynamic>;
    }

    List<RoleModel> parseRoles(dynamic val) {
      if (val is List) {
        return val
            .whereType<Map<String, dynamic>>()
            .map((item) => RoleModel.fromJson(item))
            .toList();
      }
      return [];
    }

    List<PermissionGroupModel> parseTree(dynamic val) {
      if (val is List) {
        return val
            .whereType<Map<String, dynamic>>()
            .map((item) => PermissionGroupModel.fromJson(item))
            .toList();
      }
      return [];
    }

    return RolesPermissionsResponseModel(
      roles: parseRoles(dataMap['roles']),
      permissionsTree:
          parseTree(dataMap['permissions_tree'] ?? dataMap['permissions']),
    );
  }
}
