import 'package:flutter/material.dart';
import '../../../../core/utils/admin_theme_context.dart';
import '../../data/models/ai_alert_model.dart';
import '../../data/models/ai_decision_audit_model.dart';
import '../../data/utils/ai_alerts_translator.dart';

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

    final rawComment = meta['review_text']?.toString() ??
        meta['review_comment']?.toString() ??
        meta['comment']?.toString() ??
        (alert.message.isNotEmpty ? alert.message : null);

    return AiExplainabilityModal(
      title: AiAlertsTranslator.translateTitle(alert.title),
      driverName: alert.displayDriverName,
      reviewComment: rawComment != null
          ? AiAlertsTranslator.cleanCommentText(rawComment)
          : null,
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
      title: audit.decisionCode.label,
      driverName: audit.driverName ?? 'سائق غير معرف',
      reviewComment: audit.reviewComment != null
          ? AiAlertsTranslator.cleanCommentText(audit.reviewComment!)
          : null,
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
                                _translateCategory(aiCategory!),
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
                          Builder(
                            builder: (context) {
                              final diff = ratingAfter! - ratingBefore!;
                              final pct = ratingBefore! > 0
                                  ? ((diff / ratingBefore!) * 100).round()
                                  : 0;
                              final isDecrease = diff < 0;
                              final badgeColor = isDecrease
                                  ? const Color(0xFFDC2626)
                                  : const Color(0xFF059669);
                              final badgeBg = isDecrease
                                  ? const Color(0xFFFEF2F2)
                                  : const Color(0xFFECFDF5);
                              final badgeBorder = isDecrease
                                  ? const Color(0xFFFCA5A5)
                                  : const Color(0xFFA7F3D0);

                              return Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: badgeBg,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: badgeBorder),
                                ),
                                child: Text(
                                  '${pct > 0 ? '+' : ''}$pct%',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: badgeColor,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // ── 3. الإجراءات المطبقة تلقائياً ─────────────────────────────
              if (actions.isNotEmpty) ...[
                Text(
                  'الإجراءات التي تم تطبيقها تلقائياً:',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: context.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: actions.map((act) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: context.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: context.primaryColor.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle_outline_rounded,
                            size: 14,
                            color: context.primaryColor,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _translateAction(act),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: context.primaryColor,
                            ),
                          ),
                        ],
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

  String _translateAction(String act) => AiAlertsTranslator.translateAction(act);

  String _translateCategory(String category) =>
      AiAlertsTranslator.translateCategory(category);
}
