import '../../../../core/models/pagination_meta_model.dart';

class ComplaintUserModel {
  final int id;
  final String name;
  final String? phone;

  const ComplaintUserModel({
    required this.id,
    required this.name,
    this.phone,
  });

  factory ComplaintUserModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const ComplaintUserModel(id: 0, name: 'غير معروف');
    }
    return ComplaintUserModel(
      id: json['id'] is int
          ? json['id']
          : (int.tryParse(json['id']?.toString() ?? '0') ?? 0),
      name: json['name']?.toString() ?? 'غير معروف',
      phone: json['phone']?.toString(),
    );
  }
}

class ComplaintDriverModel {
  final int id;
  final String name;
  final String? phone;

  const ComplaintDriverModel({
    required this.id,
    required this.name,
    this.phone,
  });

  factory ComplaintDriverModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const ComplaintDriverModel(id: 0, name: 'غير محدد');
    }
    return ComplaintDriverModel(
      id: json['id'] is int
          ? json['id']
          : (int.tryParse(json['id']?.toString() ?? '0') ?? 0),
      name: json['name']?.toString() ?? 'غير محدد',
      phone: json['phone']?.toString(),
    );
  }
}

class ComplaintTripModel {
  final int id;
  final String status;

  const ComplaintTripModel({
    required this.id,
    required this.status,
  });

  factory ComplaintTripModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const ComplaintTripModel(id: 0, status: 'غير محدد');
    }
    return ComplaintTripModel(
      id: json['id'] is int
          ? json['id']
          : (int.tryParse(json['id']?.toString() ?? '0') ?? 0),
      status: json['status']?.toString() ?? 'غير محدد',
    );
  }
}

class ComplaintModel {
  final int id;
  final String title;
  final String description;
  final String status; // 'pending' | 'completed' | 'dismissed'
  final String actionTaken; // 'none' | 'warning' | 'suspension' | 'dismiss'
  final String? actionDetails;
  final ComplaintUserModel? submittedBy;
  final ComplaintDriverModel? driver;
  final ComplaintTripModel? trip;
  final String? createdAt;

  const ComplaintModel({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.actionTaken,
    this.actionDetails,
    this.submittedBy,
    this.driver,
    this.trip,
    this.createdAt,
  });

  factory ComplaintModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const ComplaintModel(
        id: 0,
        title: '',
        description: '',
        status: 'pending',
        actionTaken: 'none',
      );
    }
    return ComplaintModel(
      id: json['id'] is int
          ? json['id']
          : (int.tryParse(json['id']?.toString() ?? '0') ?? 0),
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      actionTaken: json['action_taken']?.toString() ?? 'none',
      actionDetails: json['action_details']?.toString(),
      submittedBy: json['submitted_by'] != null
          ? ComplaintUserModel.fromJson(
              json['submitted_by'] as Map<String, dynamic>?)
          : null,
      driver: json['driver'] != null
          ? ComplaintDriverModel.fromJson(
              json['driver'] as Map<String, dynamic>?)
          : null,
      trip: json['trip'] != null
          ? ComplaintTripModel.fromJson(json['trip'] as Map<String, dynamic>?)
          : null,
      createdAt: json['created_at']?.toString(),
    );
  }
}

class ComplaintsListResult {
  final List<ComplaintModel> complaints;
  final PaginationMetaModel meta;

  const ComplaintsListResult({
    required this.complaints,
    required this.meta,
  });

  factory ComplaintsListResult.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    final List<ComplaintModel> items = [];
    if (rawData is List) {
      for (final item in rawData) {
        if (item is Map<String, dynamic>) {
          items.add(ComplaintModel.fromJson(item));
        }
      }
    }

    final rawPagination = json['pagination'] as Map<String, dynamic>?;
    final meta = PaginationMetaModel.fromJson(rawPagination);

    return ComplaintsListResult(
      complaints: items,
      meta: meta,
    );
  }
}
