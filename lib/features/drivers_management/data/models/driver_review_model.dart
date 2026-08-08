class DriverReviewModel {
  final int id;
  final int driverId;
  final String driverName;
  final String? parentName;
  final int rating;
  final String comment;
  final String? createdAt;

  DriverReviewModel({
    required this.id,
    required this.driverId,
    required this.driverName,
    this.parentName,
    required this.rating,
    required this.comment,
    this.createdAt,
  });

  factory DriverReviewModel.fromJson(Map<String, dynamic> json) {
    int parsedId = 0;
    if (json['id'] != null) {
      parsedId = json['id'] is int ? json['id'] : (int.tryParse(json['id'].toString()) ?? 0);
    } else if (json['review_id'] != null) {
      parsedId = json['review_id'] is int ? json['review_id'] : (int.tryParse(json['review_id'].toString()) ?? 0);
    }

    int parsedDriverId = 0;
    if (json['driver_id'] != null) {
      parsedDriverId = json['driver_id'] is int ? json['driver_id'] : (int.tryParse(json['driver_id'].toString()) ?? 0);
    }

    int parsedRating = 5;
    if (json['rating'] != null) {
      parsedRating = json['rating'] is int ? json['rating'] : (int.tryParse(json['rating'].toString()) ?? 5);
    }

    return DriverReviewModel(
      id: parsedId,
      driverId: parsedDriverId,
      driverName: json['driver_name']?.toString() ?? json['driver']?['full_name']?.toString() ?? 'سائق',
      parentName: json['parent_name']?.toString() ?? json['user_name']?.toString() ?? json['parent']?['name']?.toString() ?? 'ولي أمر',
      rating: parsedRating,
      comment: json['comment']?.toString() ?? json['notes']?.toString() ?? '',
      createdAt: json['created_at']?.toString(),
    );
  }
}
