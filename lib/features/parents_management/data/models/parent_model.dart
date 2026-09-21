class ParentAddressModel {
  final int id;
  final String label;
  final double? lat;
  final double? lng;

  const ParentAddressModel({
    required this.id,
    required this.label,
    this.lat,
    this.lng,
  });

  factory ParentAddressModel.fromJson(Map<String, dynamic> json) {
    return ParentAddressModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      label: json['label']?.toString() ?? '',
      lat: json['lat'] != null ? double.tryParse(json['lat'].toString()) : null,
      lng: json['lng'] != null ? double.tryParse(json['lng'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'lat': lat,
      'lng': lng,
    };
  }
}

class ParentChildModel {
  final int id;
  final String fullName;
  final String? birthDate;
  final int? age;
  final String? gender;
  final dynamic grade;
  final String? schoolStage;
  final String? schoolName;
  final String? photoUrl;
  final bool isActive;

  const ParentChildModel({
    required this.id,
    required this.fullName,
    this.birthDate,
    this.age,
    this.gender,
    this.grade,
    this.schoolStage,
    this.schoolName,
    this.photoUrl,
    required this.isActive,
  });

  factory ParentChildModel.fromJson(Map<String, dynamic> json) {
    return ParentChildModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      fullName: json['full_name']?.toString() ?? '',
      birthDate: json['birth_date']?.toString(),
      age: json['age'] != null ? int.tryParse(json['age'].toString()) : null,
      gender: json['gender']?.toString(),
      grade: json['grade'],
      schoolStage: json['school_stage']?.toString(),
      schoolName: json['school_name']?.toString(),
      photoUrl: json['photo_url']?.toString(),
      isActive: json['is_active'] == true || json['is_active'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'birth_date': birthDate,
      'age': age,
      'gender': gender,
      'grade': grade,
      'school_stage': schoolStage,
      'school_name': schoolName,
      'photo_url': photoUrl,
      'is_active': isActive,
    };
  }
}

class ParentModel {
  final int id;
  final String fullName;
  final String? email;
  final String phoneNumber;
  final String? alternativePhone;
  final String? gender;
  final String? avatarUrl;
  final bool isActive;
  final bool isTrusted;
  final bool phoneVerified;
  final String? lastLoginAt;
  final String? createdAt;
  final ParentAddressModel? defaultAddress;
  final int childrenCount;
  final List<ParentChildModel> children;

  const ParentModel({
    required this.id,
    required this.fullName,
    this.email,
    required this.phoneNumber,
    this.alternativePhone,
    this.gender,
    this.avatarUrl,
    required this.isActive,
    required this.isTrusted,
    required this.phoneVerified,
    this.lastLoginAt,
    this.createdAt,
    this.defaultAddress,
    required this.childrenCount,
    required this.children,
  });

  factory ParentModel.fromJson(Map<String, dynamic> json) {
    List<ParentChildModel> parsedChildren = [];
    if (json['children'] != null && json['children'] is List) {
      parsedChildren = (json['children'] as List)
          .map((item) => ParentChildModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return ParentModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      fullName: json['full_name']?.toString() ?? '',
      email: json['email']?.toString(),
      phoneNumber: json['phone_number']?.toString() ?? '',
      alternativePhone: json['alternative_phone']?.toString(),
      gender: json['gender']?.toString(),
      avatarUrl: json['avatar_url']?.toString(),
      isActive: json['is_active'] == true || json['is_active'] == 1,
      isTrusted: json['is_trusted'] == true || json['is_trusted'] == 1,
      phoneVerified: json['phone_verified'] == true || json['phone_verified'] == 1,
      lastLoginAt: json['last_login_at']?.toString(),
      createdAt: json['created_at']?.toString(),
      defaultAddress: json['default_address'] != null && json['default_address'] is Map<String, dynamic>
          ? ParentAddressModel.fromJson(json['default_address'] as Map<String, dynamic>)
          : null,
      childrenCount: json['children_count'] != null
          ? (int.tryParse(json['children_count'].toString()) ?? parsedChildren.length)
          : parsedChildren.length,
      children: parsedChildren,
    );
  }

  ParentModel copyWith({
    int? id,
    String? fullName,
    String? email,
    String? phoneNumber,
    String? alternativePhone,
    String? gender,
    String? avatarUrl,
    bool? isActive,
    bool? isTrusted,
    bool? phoneVerified,
    String? lastLoginAt,
    String? createdAt,
    ParentAddressModel? defaultAddress,
    int? childrenCount,
    List<ParentChildModel>? children,
  }) {
    return ParentModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      alternativePhone: alternativePhone ?? this.alternativePhone,
      gender: gender ?? this.gender,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isActive: isActive ?? this.isActive,
      isTrusted: isTrusted ?? this.isTrusted,
      phoneVerified: phoneVerified ?? this.phoneVerified,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      createdAt: createdAt ?? this.createdAt,
      defaultAddress: defaultAddress ?? this.defaultAddress,
      childrenCount: childrenCount ?? this.childrenCount,
      children: children ?? this.children,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'phone_number': phoneNumber,
      'alternative_phone': alternativePhone,
      'gender': gender,
      'avatar_url': avatarUrl,
      'is_active': isActive,
      'is_trusted': isTrusted,
      'phone_verified': phoneVerified,
      'last_login_at': lastLoginAt,
      'created_at': createdAt,
      'default_address': defaultAddress?.toJson(),
      'children_count': childrenCount,
      'children': children.map((c) => c.toJson()).toList(),
    };
  }
}
