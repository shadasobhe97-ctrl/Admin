import 'package:flutter/material.dart';
import '../../../../core/utils/admin_theme_context.dart';
import '../../data/models/ai_alert_model.dart';
import '../../data/models/ai_decision_audit_model.dart';

class AiExplainabilityModal extends StatelessWidget {
  final String? title;
  final String? driverName;
  final String? reviewComment;
  final int? reviewRating;
  final String? aiCategory;
  final double? confidence;
  final double? ratingBefore;
  final double? ratingAfter;
  final Map<String, double> probabilities;
  final List<String> actions;

  const AiExplainabilityModal({
    super.key,
    this.title,
    this.driverName,
    this.reviewComment,
    this.reviewRating,
    this.aiCategory,
    this.confidence,
    this.ratingBefore,
    this.ratingAfter,
    this.probabilities = const {},
    this.actions = const [],
  });

  factory AiExplainabilityModal.fromAlert(AiAlertModel alert) {
    final meta = alert.metadata ?? const {};

    return AiExplainabilityModal(
      title: alert.title,
      driverName: alert.displayDriverName,
      reviewComment: alert.message,
      aiCategory: meta['category']?.toString(),
      confidence: (meta['confidence'] as num?)?.toDouble(),
      ratingBefore: (meta['rating_before'] as num?)?.toDouble(),
      ratingAfter: (meta['rating_after'] as num?)?.toDouble(),
      probabilities: meta['probabilities'] is Map
          ? (meta['probabilities'] as Map).map(
              (k, v) => MapEntry(k.toString(), (v as num).toDouble()),
            )
          : const {},
      actions: meta['actions'] is List
          ? (meta['actions'] as List).map((e) => e.toString()).toList()
          : const [],
    );
  }

  factory AiExplainabilityModal.fromAudit(AiDecisionAuditModel audit) {
    return AiExplainabilityModal(
      title: audit.decisionName,
      driverName: audit.driverName ?? 'سائق غير معرف',
      reviewComment: audit.reviewComment,
      reviewRating: audit.reviewRating,
      aiCategory: audit.aiCategory,
      confidence: audit.confidence,
      ratingBefore: audit.ratingBefore,
      ratingAfter: audit.ratingAfter,
      probabilities: audit.probabilities,
      actions: audit.actions,
    );
  }

  static void show(
    BuildContext context, {
    AiAlertModel? alert,
    AiDecisionAuditModel? audit,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 640),
          child: alert != null
              ? AiExplainabilityModal.fromAlert(alert)
              : audit != null
                  ? AiExplainabilityModal.fromAudit(audit)
                  : const SizedBox(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.analytics_outlined,
                          color: context.primaryColor, size: 22),
                      const SizedBox(width: 8),
                      Text(
                        'حيثيات وتفسير قرار الذكاء الاصطناعي',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: context.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              if (driverName != null) ...[
                Text(
                  'السائق: $driverName',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: context.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // ── 1. تعليق ولي الأمر والتصنيف ──────────────────────────────
              if (reviewComment != null && reviewComment!.isNotEmpty) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: context.isDarkMode
                        ? const Color(0xFF0F172A)
                        : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: context.dividerLine),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'نص تعليق ولي الأمر / الملاحظة',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: context.textTertiary,
                            ),
                          ),
                          if (aiCategory != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: context.dangerColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                aiCategory!,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: context.dangerColor,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        reviewComment!,
                        style: TextStyle(
                          fontSize: 13,
                          color: context.textPrimary,
                          height: 1.4,
                        ),
                      ),
                      if (reviewRating != null) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Text(
                              'التقييم الأصلي: ',
                              style: TextStyle(
                                  fontSize: 12, color: context.textTertiary),
                            ),
                            ...List.generate(
                              5,
                              (index) => Icon(
                                index < reviewRating!
                                    ? Icons.star_rounded
                                    : Icons.star_border_rounded,
                                size: 16,
                                color: Colors.amber,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // ── 2. أثر التغيير في التقييم ──────────────────────────────────
              if (ratingBefore != null && ratingAfter != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: context.dividerLine),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'معدّل التغيير في تقييم السائق:',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: context.textPrimary,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            ratingBefore!.toStringAsFixed(2),
                            style: TextStyle(
                              fontSize: 13,
                              color: context.textTertiary,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_rounded, size: 14),
                          const SizedBox(width: 8),
                          Text(
                            ratingAfter!.toStringAsFixed(2),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFDC2626),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF2F2),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: const Color(0xFFFCA5A5)),
                            ),
                            child: const Text(
                              '-10%',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFDC2626),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // ── 3. توزيع احتمالات Softmax ────────────────────────────────
              Text(
                'توزيع احتمالات نموذج الذكاء الاصطناعي (Softmax Confidence)',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: context.textPrimary,
                ),
              ),
              const SizedBox(height: 10),

              _buildProbabilitiesDistribution(context),
              const SizedBox(height: 20),

              // ── 4. الإجراءات المطبقة تلقائياً ─────────────────────────────
              if (actions.isNotEmpty) ...[
                Text(
                  'الإجراءات التي تم تطبيقها تلقائياً:',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: context.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: actions.map((act) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: context.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: context.primaryColor.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        _translateAction(act),
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: context.primaryColor,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProbabilitiesDistribution(BuildContext context) {
    final Map<int, String> labels = {
      0: '0 - بدون إجراء (NO_ACTION)',
      1: '1 - مكافأة وتقييم (REWARD)',
      2: '2 - مخالفة متوسطة (MODERATE_VIOLATION)',
      3: '3 - تحذير رسمي (FORMAL_WARNING)',
      4: '4 - مراجعة وتدخل إداري (ADMIN_REVIEW_REQUIRED)',
      5: '5 - إيقاف نهائي (PERMANENT_SUSPENSION)',
    };

    return Column(
      children: labels.entries.map((entry) {
        final code = entry.key;
        final label = entry.value;
        final prob = probabilities['$code'] ?? probabilities['code_$code'] ?? 0.0;
        final percent = (prob * 100).toStringAsFixed(1);
        final isHighest = confidence != null && (prob - confidence!).abs() < 0.05 || (code == 4 && prob > 0.5);

        Color barColor;
        if (code == 4 || code == 5) {
          barColor = isHighest ? const Color(0xFFDC2626) : const Color(0xFF94A3B8);
        } else if (code == 1) {
          barColor = isHighest ? const Color(0xFF059669) : const Color(0xFF94A3B8);
        } else {
          barColor = isHighest ? const Color(0xFFD97706) : const Color(0xFF94A3B8);
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isHighest ? FontWeight.bold : FontWeight.normal,
                      color: isHighest ? context.textPrimary : context.textTertiary,
                    ),
                  ),
                  Text(
                    '$percent%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: barColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: prob.clamp(0.0, 1.0),
                  minHeight: 8,
                  backgroundColor: context.isDarkMode
                      ? const Color(0xFF334155)
                      : const Color(0xFFE2E8F0),
                  valueColor: AlwaysStoppedAnimation<Color>(barColor),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  String _translateAction(String act) {
    switch (act) {
      case 'hidden_from_search_precautionary':
        return 'حجب وقائي مؤقت من البحث';
      case 'rating_down_10pct':
        return 'إعادة تخفيض التقييم بنسبة 10%';
      case 'admin_review_required':
        return 'تنبيه الأدمن للمراجعة العاجلة';
      case 'admin_alerted_critical':
        return 'إصدار تنبيه أمان حرج';
      default:
        return act;
    }
  }
}
