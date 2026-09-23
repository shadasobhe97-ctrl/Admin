import '../../../../core/models/pagination_meta_model.dart';

enum DecisionCode {
  noAction(0, 'بدون إجراء', 'NO_ACTION'),
  reward(1, 'مكافأة وتقييم ممتاز', 'REWARD'),
  moderateViolation(2, 'مخالفة متوسطة', 'MODERATE_VIOLATION'),
  formalWarning(3, 'تحذير رسمي', 'FORMAL_WARNING'),
  adminReviewRequired(4, 'مراجعة وتدخل إداري', 'ADMIN_REVIEW_REQUIRED'),
  permanentSuspension(5, 'إيقاف نهائي', 'PERMANENT_SUSPENSION');

  final int code;
  final String label;
  final String name;

  const DecisionCode(this.code, this.label, this.name);

  static DecisionCode fromCode(dynamic value) {
    final intCode = value is int ? value : int.tryParse('$value') ?? 0;
    return DecisionCode.values.firstWhere(
      (e) => e.code == intCode,
      orElse: () => DecisionCode.noAction,
    );
  }
}

class AiDecisionAuditModel {
  final int id;
  final int driverId;
  final int? reviewId;
  final DecisionCode decisionCode;
  final String decisionName;
  final double confidence;
  final Map<String, double> probabilities;
  final List<String> actions;
  final double? ratingBefore;
  final double? ratingAfter;
  final String? suspendedUntil;
  final String? createdAt;
  final String? driverName;
  final String? driverPhone;
  final int? reviewRating;
  final String? reviewComment;
  final String? aiCategory;

  const AiDecisionAuditModel({
    required this.id,
    required this.driverId,
    this.reviewId,
    required this.decisionCode,
    required this.decisionName,
    required this.confidence,
    this.probabilities = const {},
    this.actions = const [],
    this.ratingBefore,
    this.ratingAfter,
    this.suspendedUntil,
    this.createdAt,
    this.driverName,
    this.driverPhone,
    this.reviewRating,
    this.reviewComment,
    this.aiCategory,
  });

  factory AiDecisionAuditModel.fromJson(Map<String, dynamic> json) {
    final probsRaw = json['probabilities'];
    final Map<String, double> probs = {};
    if (probsRaw is Map) {
      probsRaw.forEach((k, v) {
        final val = v is num ? v.toDouble() : double.tryParse('$v') ?? 0.0;
        probs[k.toString()] = val;
      });
    }

    final actionDetails = json['action_details'] is Map<String, dynamic>
        ? json['action_details'] as Map<String, dynamic>
        : const <String, dynamic>{};

    final actionsList = actionDetails['actions'] is List
        ? (actionDetails['actions'] as List).map((e) => e.toString()).toList()
        : <String>[];

    final driverJson = json['driver'] is Map<String, dynamic>
        ? json['driver'] as Map<String, dynamic>
        : null;
    final userJson = driverJson?['user'] is Map<String, dynamic>
        ? driverJson!['user'] as Map<String, dynamic>
        : null;

    final reviewJson = json['review'] is Map<String, dynamic>
        ? json['review'] as Map<String, dynamic>
        : null;

    return AiDecisionAuditModel(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      driverId: json['driver_id'] is int
          ? json['driver_id']
          : int.tryParse('${json['driver_id']}') ?? 0,
      reviewId: json['review_id'] is int
          ? json['review_id']
          : int.tryParse('${json['review_id']}'),
      decisionCode: DecisionCode.fromCode(json['decision_code']),
      decisionName: json['decision_name']?.toString() ?? '',
      confidence: json['confidence'] is num
          ? (json['confidence'] as num).toDouble()
          : double.tryParse('${json['confidence']}') ?? 0.0,
      probabilities: probs,
      actions: actionsList,
      ratingBefore: (actionDetails['rating_before'] as num?)?.toDouble(),
      ratingAfter: (actionDetails['rating_after'] as num?)?.toDouble(),
      suspendedUntil: actionDetails['suspended_until']?.toString(),
      createdAt: json['created_at']?.toString(),
      driverName: userJson?['full_name']?.toString() ??
          driverJson?['name']?.toString() ??
          json['driver_name']?.toString(),
      driverPhone: userJson?['phone_number']?.toString() ??
          driverJson?['phone']?.toString() ??
          json['driver_phone']?.toString(),
      reviewRating: reviewJson?['rating'] is int
          ? reviewJson!['rating']
          : int.tryParse('${reviewJson?['rating']}'),
      reviewComment: reviewJson?['comment']?.toString(),
      aiCategory: reviewJson?['ai_category']?.toString(),
    );
  }
}

class AiAuditsListResult {
  final List<AiDecisionAuditModel> audits;
  final PaginationMetaModel meta;

  const AiAuditsListResult({
    required this.audits,
    required this.meta,
  });

  factory AiAuditsListResult.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    final List<AiDecisionAuditModel> items = [];
    if (rawData is List) {
      for (final item in rawData) {
        if (item is Map<String, dynamic>) {
          items.add(AiDecisionAuditModel.fromJson(item));
        }
      }
    }

    final metaData = json['meta'] is Map<String, dynamic>
        ? json['meta'] as Map<String, dynamic>
        : null;

    return AiAuditsListResult(
      audits: items,
      meta: PaginationMetaModel.fromJson(metaData),
    );
  }
}
