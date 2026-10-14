import 'package:flutter/material.dart';

import '../../../../core/utils/admin_theme_context.dart';
import '../../../../core/widgets/admin_ui.dart';

/// أدوات العرض الخاصة بالتقارير فقط.
/// كل ما هو عام (الألواح، حالات التحميل/الفراغ/الخطأ، التنسيق) يُعاد استخدامه
/// من [AdminPanel] و[AdminLoadingView] و[AdminFormat] في `core/widgets`.

/// النِسَب تأتي جاهزة من الخادم؛ هذه الدالة للعرض فقط.
String formatPercentage(num? value) =>
    value == null ? '—' : '${value.toStringAsFixed(1)}%';

/// بطاقة مؤشّر واحدة: عنوان + قيمة + أيقونة، بلون مشتق من الثيم.
class ReportMetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  /// لون الدلالة — يُمرّر من الثيم دائماً (نجاح/تحذير/خطر/معلومة).
  final Color? accent;
  final String? subtitle;
  final VoidCallback? onTap;

  const ReportMetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.accent,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = accent ?? context.primaryColor;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.borderSoft),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 18, color: color),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: context.textMuted,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w900,
                color: context.textPrimary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                style: TextStyle(fontSize: 10.5, color: context.textTertiary),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// شبكة بطاقات متجاوبة: تحسب عدد الأعمدة من العرض المتاح
/// لتعمل على الشاشات الكبيرة واللوحية معاً.
class ReportMetricsGrid extends StatelessWidget {
  final List<Widget> cards;
  final double minCardWidth;

  const ReportMetricsGrid({
    super.key,
    required this.cards,
    this.minCardWidth = 230,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns =
            (constraints.maxWidth / minCardWidth).floor().clamp(1, 5);
        const spacing = 12.0;
        final width =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final card in cards) SizedBox(width: width, child: card),
          ],
        );
      },
    );
  }
}

/// عنوان قسم داخل شاشة تقرير.
class ReportSectionTitle extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Widget? trailing;

  const ReportSectionTitle({
    super.key,
    required this.title,
    required this.icon,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: context.primaryColor),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: context.textPrimary,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: TextStyle(fontSize: 11, color: context.textMuted),
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

/// سطر يعرض نسبة مع شريط تقدّم، تُمرَّر النسبة جاهزة من الخادم.
class ReportProgressRow extends StatelessWidget {
  final String label;
  final double percentage;
  final String? valueLabel;
  final Color? color;

  const ReportProgressRow({
    super.key,
    required this.label,
    required this.percentage,
    this.valueLabel,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final barColor = color ?? context.primaryColor;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(fontSize: 12, color: context.textSecondary),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                valueLabel ?? formatPercentage(percentage),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: context.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: (percentage / 100).clamp(0.0, 1.0),
              minHeight: 7,
              backgroundColor: context.surfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
            ),
          ),
        ],
      ),
    );
  }
}

/// حالة "لا توجد بيانات لهذا الجزء" داخل قسم من التقرير.
class ReportSectionEmpty extends StatelessWidget {
  final String message;
  final IconData icon;

  const ReportSectionEmpty({
    super.key,
    required this.message,
    this.icon = Icons.inbox_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 26),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 30, color: context.textTertiary),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: context.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}

/// لوحة ألوان السلاسل في الرسوم البيانية، مشتقة من الثيم لا من قيم ثابتة.
List<Color> reportSeriesColors(BuildContext context) => [
      context.primaryColor,
      context.successColor,
      context.warningColor,
      context.infoColor,
      context.dangerColor,
    ];

/// شريط أدوات موحّد أعلى شاشات التقارير:
/// عنوان + فلاتر الفترة (اختيارية) + تحديث + تصدير.
/// كل الأزرار تُعطَّل أثناء التحميل لمنع الطلبات المتزامنة.
class ReportToolbar extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool isBusy;
  final VoidCallback onRefresh;
  final VoidCallback? onExport;

  /// محتوى فلاتر إضافي يُعرض أسفل العنوان (فترة، نطاق تاريخ، فرز…).
  final Widget? filters;

  const ReportToolbar({
    super.key,
    required this.title,
    required this.onRefresh,
    this.subtitle,
    this.isBusy = false,
    this.onExport,
    this.filters,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: context.textPrimary,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: context.textMuted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            IconButton(
              tooltip: 'تحديث',
              onPressed: isBusy ? null : onRefresh,
              icon: Icon(
                Icons.refresh_rounded,
                size: 19,
                color: isBusy ? context.textTertiary : context.primaryColor,
              ),
            ),
            if (onExport != null) ...[
              const SizedBox(width: 6),
              OutlinedButton.icon(
                onPressed: isBusy ? null : onExport,
                icon: const Icon(Icons.download_rounded, size: 16),
                label: const Text(
                  'تصدير',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ],
        ),
        if (filters != null) ...[
          const SizedBox(height: 12),
          filters!,
        ],
      ],
    );
  }
}
