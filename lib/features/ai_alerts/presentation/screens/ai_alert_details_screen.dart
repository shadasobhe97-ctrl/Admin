import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/admin_theme_context.dart';
import '../../data/models/ai_alert_model.dart';
import '../../logic/cubit/ai_alerts_cubit.dart';
import '../../logic/state/ai_alerts_state.dart';
import '../widgets/ai_alert_severity_badge.dart';

/// تفاصيل تنبيه ذكاء اصطناعي واحد — شاشة مراقبة فقط، لا Action يدوي هنا.
class AiAlertDetailsScreen extends StatelessWidget {
  final int alertId;
  final VoidCallback? onBack;

  const AiAlertDetailsScreen({
    super.key,
    required this.alertId,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: BlocConsumer<AiAlertsCubit, AiAlertsState>(
        listener: (context, state) {
          if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: context.dangerColor,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.isDetailsLoading && state.selectedAlertDetails == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final alert = state.selectedAlertDetails;
          if (alert == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline_rounded, size: 48, color: context.textMuted),
                  const SizedBox(height: 12),
                  Text(
                    'تعذّر تحميل تفاصيل التنبيه المطلوب.',
                    style: TextStyle(color: context.textMuted),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: onBack ?? () => Navigator.of(context).maybePop(),
                    child: const Text('العودة للقائمة'),
                  ),
                ],
              ),
            );
          }

          return Scaffold(
            backgroundColor: context.scaffoldBackgroundColor,
            appBar: AppBar(
              backgroundColor: context.cardColor,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: onBack ?? () => Navigator.of(context).maybePop(),
              ),
              title: Text(
                'تفاصيل التنبيه #${alert.id}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: context.textPrimary,
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Center(
                    child: AiAlertSeverityBadge(
                      riskLevel: alert.riskLevel,
                      isCritical: alert.isCritical,
                    ),
                  ),
                ),
              ],
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _AlertInfoCard(alert: alert),
                  const SizedBox(height: 16),
                  if (alert.driver != null) ...[
                    _DriverInfoCard(driver: alert.driver!),
                    const SizedBox(height: 16),
                  ],
                  _AiResultCard(alert: alert),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: context.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: context.borderSoft),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: context.primaryColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: context.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Divider(color: context.borderSoft),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

Widget _detailRow(BuildContext context, String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 5.0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 150,
          child: Text(
            label,
            style: TextStyle(fontSize: 12, color: context.textMuted),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: context.textPrimary,
            ),
          ),
        ),
      ],
    ),
  );
}

class _AlertInfoCard extends StatelessWidget {
  final AiAlertModel alert;

  const _AlertInfoCard({required this.alert});

  @override
  Widget build(BuildContext context) {
    final alertTypeLabel = switch (alert.alertType) {
      'ai_critical' => 'تنبيه حرج (AI Critical)',
      'ai_warning' => 'تنبيه تحذيري (AI Warning)',
      _ => alert.alertType.isNotEmpty ? alert.alertType : 'غير محدد',
    };

    return _SectionCard(
      title: 'معلومات التنبيه',
      icon: Icons.smart_toy_outlined,
      children: [
        if (alert.title.isNotEmpty) ...[
          Text(
            alert.title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: context.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
        ],
        if (alert.message.isNotEmpty) ...[
          Text(
            alert.message,
            style: TextStyle(fontSize: 13, height: 1.5, color: context.textSecondary),
          ),
          const SizedBox(height: 12),
          Divider(color: context.borderSoft),
          const SizedBox(height: 8),
        ],
        _detailRow(context, 'نوع التنبيه', alertTypeLabel),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0),
          child: Row(
            children: [
              SizedBox(
                width: 150,
                child: Text('حالة التنبيه',
                    style: TextStyle(fontSize: 12, color: context.textMuted)),
              ),
              AiAlertResolvedBadge(isResolved: alert.isResolved),
            ],
          ),
        ),
        if (alert.createdAt != null && alert.createdAt!.isNotEmpty)
          _detailRow(context, 'تاريخ الإنشاء', alert.createdAt!),
      ],
    );
  }
}

class _DriverInfoCard extends StatelessWidget {
  final AiAlertDriverModel driver;

  const _DriverInfoCard({required this.driver});

  @override
  Widget build(BuildContext context) {
    final isHidden = driver.isTrusted == false;

    return _SectionCard(
      title: 'بيانات السائق',
      icon: Icons.directions_bus_rounded,
      children: [
        if (driver.name != null && driver.name!.isNotEmpty)
          _detailRow(context, 'الاسم', driver.name!),
        if (driver.phone != null && driver.phone!.isNotEmpty)
          _detailRow(context, 'رقم الهاتف', driver.phone!),
        if (driver.rating != null)
          _detailRow(context, 'التقييم الحالي', driver.rating!.toStringAsFixed(2)),
        if (driver.status != null && driver.status!.isNotEmpty)
          _detailRow(context, 'حالة الحساب', driver.status!),
        if (isHidden) ...[
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: context.dangerBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: context.dangerBorder),
            ),
            child: Row(
              children: [
                Icon(Icons.visibility_off_rounded, size: 18, color: context.dangerColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'السائق غير موثوق حالياً، وهو مخفي من نتائج البحث.',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: context.dangerColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _AiResultCard extends StatelessWidget {
  final AiAlertModel alert;

  const _AiResultCard({required this.alert});

  @override
  Widget build(BuildContext context) {
    final metadata = alert.metadata;
    final ratingBefore = _asDouble(metadata?['rating_before']);
    final ratingAfter = _asDouble(metadata?['rating_after']);
    final reviewText = _asNonEmptyString(metadata?['review_text']);

    final metaRows = <MapEntry<String, String>>[];
    void addIfPresent(String key, String label, [String Function(dynamic)? format]) {
      final raw = metadata?[key];
      if (raw == null) return;
      final text = format != null ? format(raw) : raw.toString();
      if (text.trim().isEmpty) return;
      metaRows.add(MapEntry(label, text));
    }

    addIfPresent('trigger', 'سبب التنبيه');
    addIfPresent('review_id', 'رقم التقييم المرتبط');
    addIfPresent('window_start', 'بداية فترة الرصد');
    addIfPresent('distinct_negative_children', 'عدد الأطفال المعلّقين سلبًا');
    addIfPresent('active_children_total', 'إجمالي الأطفال النشطين بالفترة');
    addIfPresent('negative_ratio', 'نسبة التعليقات السلبية', (v) {
      final ratio = _asDouble(v);
      if (ratio == null) return v.toString();
      final percent = ratio <= 1 ? ratio * 100 : ratio;
      return '${percent.toStringAsFixed(0)}%';
    });

    final hasActionsTaken = alert.actionsTaken != null && alert.actionsTaken!.isNotEmpty;
    final hasAnything = hasActionsTaken ||
        (ratingBefore != null && ratingAfter != null) ||
        reviewText != null ||
        metaRows.isNotEmpty;

    if (!hasAnything) {
      return _SectionCard(
        title: 'نتيجة تحليل الذكاء الاصطناعي',
        icon: Icons.insights_rounded,
        children: [
          Text(
            'لا تتوفر تفاصيل إضافية عن نتيجة التحليل لهذا التنبيه حتى الآن.',
            style: TextStyle(fontSize: 12.5, color: context.textMuted),
          ),
        ],
      );
    }

    return _SectionCard(
      title: 'نتيجة تحليل الذكاء الاصطناعي',
      icon: Icons.insights_rounded,
      children: [
        if (hasActionsTaken) ...[
          _detailRow(context, 'الإجراء المتخذ', alert.actionsTaken!),
          const SizedBox(height: 6),
        ],
        if (ratingBefore != null && ratingAfter != null) ...[
          _RatingChangeRow(before: ratingBefore, after: ratingAfter),
          const SizedBox(height: 6),
        ],
        ...metaRows.map((e) => _detailRow(context, e.key, e.value)),
        if (reviewText != null) ...[
          const SizedBox(height: 8),
          Text(
            'نص التعليق المرتبط:',
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.bold,
              color: context.textMuted,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: context.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '"$reviewText"',
              style: TextStyle(fontSize: 12.5, color: context.textPrimary, height: 1.5),
            ),
          ),
        ],
      ],
    );
  }

  static double? _asDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString());
  }

  static String? _asNonEmptyString(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }
}

class _RatingChangeRow extends StatelessWidget {
  final double before;
  final double after;

  const _RatingChangeRow({required this.before, required this.after});

  @override
  Widget build(BuildContext context) {
    final isIncrease = after > before;
    final isDecrease = after < before;
    final color = isDecrease
        ? context.dangerColor
        : isIncrease
            ? context.successColor
            : context.textMuted;
    final icon = isDecrease
        ? Icons.trending_down_rounded
        : isIncrease
            ? Icons.trending_up_rounded
            : Icons.trending_flat_rounded;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        children: [
          SizedBox(
            width: 150,
            child: Text('تقييم السائق',
                style: TextStyle(fontSize: 12, color: context.textMuted)),
          ),
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            '${before.toStringAsFixed(2)} → ${after.toStringAsFixed(2)}',
            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }
}
