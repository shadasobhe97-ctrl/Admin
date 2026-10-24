class EmergencyStatsModel {
  final int totalEmergencies;
  final int activeNow;
  final int unresolvedCount;
  final int completedCount;

  EmergencyStatsModel({
    required this.totalEmergencies,
    required this.activeNow,
    required this.unresolvedCount,
    required this.completedCount,
  });

  factory EmergencyStatsModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return EmergencyStatsModel(
        totalEmergencies: 0,
        activeNow: 0,
        unresolvedCount: 0,
        completedCount: 0,
      );
    }
    int parseI(dynamic v) {
      if (v is num) return v.toInt();
      return int.tryParse(v?.toString() ?? '') ?? 0;
    }

    return EmergencyStatsModel(
      totalEmergencies: parseI(json['total_emergencies']),
      activeNow: parseI(json['active_now']),
      unresolvedCount: parseI(json['unresolved_count']),
      completedCount: parseI(json['completed_count']),
    );
  }
}

class EmergencyDriverInfo {
  final int? id;
  final String name;
  final String? phone;

  EmergencyDriverInfo({
    this.id,
    required this.name,
    this.phone,
  });

  factory EmergencyDriverInfo.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return EmergencyDriverInfo(id: null, name: 'غير محدد', phone: null);
    }
    return EmergencyDriverInfo(
      id: int.tryParse(json['id']?.toString() ?? ''),
      name: json['name']?.toString() ?? 'غير محدد',
      phone: json['phone']?.toString(),
    );
  }
}

class EmergencyLocationInfo {
  final double latitude;
  final double longitude;
  final String mapsUrl;

  EmergencyLocationInfo({
    required this.latitude,
    required this.longitude,
    required this.mapsUrl,
  });

  factory EmergencyLocationInfo.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return EmergencyLocationInfo(latitude: 0.0, longitude: 0.0, mapsUrl: '');
    }
    double parseD(dynamic v) {
      if (v is num) return v.toDouble();
      return double.tryParse(v?.toString() ?? '') ?? 0.0;
    }

    final lat = parseD(json['latitude'] ?? json['lat']);
    final lng = parseD(json['longitude'] ?? json['lng']);
    final url = json['maps_url']?.toString() ??
        (lat != 0.0 && lng != 0.0 ? 'https://maps.google.com/?q=$lat,$lng' : '');

    return EmergencyLocationInfo(
      latitude: lat,
      longitude: lng,
      mapsUrl: url,
    );
  }
}

class EmergencyTripItemModel {
  final int id;
  final int dispatchId;
  final int tripId;
  final String status;
  final String statusLabel;
  final String reason;
  final int strandedChildrenCount;
  final double tripFareAmount;
  final EmergencyLocationInfo breakdownLocation;
  final EmergencyDriverInfo originalDriver;
  final EmergencyDriverInfo? substituteDriver;
  final int? substituteTripId;
  final String dispatchedAt;
  final String? expiresAt;
  final String? acceptedAt;

  EmergencyTripItemModel({
    required this.id,
    required this.dispatchId,
    required this.tripId,
    required this.status,
    required this.statusLabel,
    required this.reason,
    required this.strandedChildrenCount,
    required this.tripFareAmount,
    required this.breakdownLocation,
    required this.originalDriver,
    this.substituteDriver,
    this.substituteTripId,
    required this.dispatchedAt,
    this.expiresAt,
    this.acceptedAt,
  });

  factory EmergencyTripItemModel.fromJson(Map<String, dynamic> json) {
    int parseI(dynamic v) {
      if (v is num) return v.toInt();
      return int.tryParse(v?.toString() ?? '') ?? 0;
    }

    double parseD(dynamic v) {
      if (v is num) return v.toDouble();
      return double.tryParse(v?.toString() ?? '') ?? 0.0;
    }

    // تنظيف نص الحالة من الإيموجيات للحصول على واجهة نظيفة وبسيطة
    String cleanLabel(String raw) {
      return raw.replaceAll(RegExp(r'[\u{1F300}-\u{1F9FF}]', unicode: true), '').trim();
    }

    final rawLabel = json['status_label']?.toString() ?? '';

    return EmergencyTripItemModel(
      id: parseI(json['id']),
      dispatchId: parseI(json['dispatch_id'] ?? json['id']),
      tripId: parseI(json['trip_id']),
      status: json['status']?.toString() ?? 'pending',
      statusLabel: cleanLabel(rawLabel).isNotEmpty ? cleanLabel(rawLabel) : rawLabel,
      reason: json['reason']?.toString() ?? 'عطل بالحافلة',
      strandedChildrenCount: parseI(json['stranded_children_count']),
      tripFareAmount: parseD(json['trip_fare_amount']),
      breakdownLocation: EmergencyLocationInfo.fromJson(
        json['breakdown_location'] is Map<String, dynamic>
            ? json['breakdown_location']
            : null,
      ),
      originalDriver: EmergencyDriverInfo.fromJson(
        json['original_driver'] is Map<String, dynamic>
            ? json['original_driver']
            : null,
      ),
      substituteDriver: json['substitute_driver'] is Map<String, dynamic>
          ? EmergencyDriverInfo.fromJson(json['substitute_driver'])
          : null,
      substituteTripId: json['substitute_trip_id'] != null
          ? parseI(json['substitute_trip_id'])
          : null,
      dispatchedAt: json['dispatched_at']?.toString() ?? '',
      expiresAt: json['expires_at']?.toString(),
      acceptedAt: json['accepted_at']?.toString(),
    );
  }

  /// هل هناك سائق بديل معين
  bool get hasSubstituteDriver => substituteDriver != null && (substituteDriver?.name.isNotEmpty ?? false);

  /// هل تم حل أو إغلاق البلاغ
  bool get isCompleted => status == 'completed' || status == 'resolved';
}

class EmergenciesListResult {
  final EmergencyStatsModel stats;
  final List<EmergencyTripItemModel> items;
  final int total;
  final int currentPage;
  final int lastPage;

  EmergenciesListResult({
    required this.stats,
    required this.items,
    required this.total,
    required this.currentPage,
    required this.lastPage,
  });

  factory EmergenciesListResult.fromJson(Map<String, dynamic> json) {
    final stats = EmergencyStatsModel.fromJson(
      json['stats'] is Map<String, dynamic> ? json['stats'] : null,
    );

    final itemsList = <EmergencyTripItemModel>[];
    if (json['data'] is List) {
      for (final it in json['data']) {
        if (it is Map<String, dynamic>) {
          itemsList.add(EmergencyTripItemModel.fromJson(it));
        }
      }
    }

    final pagination = json['pagination'] is Map<String, dynamic> ? json['pagination'] : {};
    final total = pagination['total'] is num ? (pagination['total'] as num).toInt() : itemsList.length;
    final curPage = pagination['current_page'] is num ? (pagination['current_page'] as num).toInt() : 1;
    final lastP = pagination['last_page'] is num ? (pagination['last_page'] as num).toInt() : 1;

    return EmergenciesListResult(
      stats: stats,
      items: itemsList,
      total: total,
      currentPage: curPage,
      lastPage: lastP,
    );
  }
}
