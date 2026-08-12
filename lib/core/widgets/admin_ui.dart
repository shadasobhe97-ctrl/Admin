import 'package:flutter/material.dart';
// `TextDirection` مخفي لتفادي تعارضه مع النوع المطابق في Flutter.
import 'package:intl/intl.dart' hide TextDirection;

import '../../../../core/utils/admin_theme_context.dart';

/// تنسيق موحّد للمبالغ والتواريخ داخل الميزة المالية.
class AdminFormat {
  const AdminFormat._();

  static final NumberFormat _money = NumberFormat('#,##0.00', 'en');
  static final NumberFormat _count = NumberFormat('#,##0', 'en');
  static final DateFormat _dateTime = DateFormat('yyyy/MM/dd — HH:mm', 'en');
  static final DateFormat _date = DateFormat('yyyy/MM/dd', 'en');

  static String money(num? value) =>
      value == null ? '—' : '${_money.format(value)} د.ل';

  static String count(num? value) =>
      value == null ? '—' : _count.format(value);

  static String dateTime(DateTime? value) =>
      value == null ? '—' : _dateTime.format(value.toLocal());

  static String date(DateTime? value) =>
      value == null ? '—' : _date.format(value.toLocal());

  /// صيغة التاريخ التي يقبلها الخادم في فلاتر `date_from` / `date_to`.
  static String queryDate(DateTime value) =>
      DateFormat('yyyy-MM-dd', 'en').format(value);

  static String orDash(String? value) =>
      (value == null || value.trim().isEmpty) ? '—' : value;
}

/// تحويل حالات الخادم النصية إلى ألوان وتسميات، اعتماداً على الـ Theme الحالي
/// فقط ودون أي لون ثابت.
class AdminStatusPalette {
  const AdminStatusPalette._();

  static Color color(BuildContext context, String? status) {
    switch (status?.toLowerCase()) {
      case 'completed':
      case 'approved':
      case 'resolved':
      case 'paid':
      case 'settled':
        return context.successColor;
      case 'pending':
      case 'processing':
      case 'open':
      case 'pending_settlement':
        return context.warningColor;
      case 'rejected':
      case 'failed':
      case 'cancelled':
      case 'unpaid':
        return context.dangerColor;
      default:
        return context.infoColor;
    }
  }

  static Color background(BuildContext context, String? status) =>
      color(context, status).withValues(alpha: 0.12);

  static String label(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return 'معلّق';
      case 'processing':
        return 'قيد المعالجة';
      case 'completed':
        return 'مكتمل';
      case 'approved':
        return 'مقبول';
      case 'rejected':
        return 'مرفوض';
      case 'failed':
        return 'فاشل';
      case 'cancelled':
        return 'ملغي';
      case 'open':
        return 'مفتوح';
      case 'resolved':
        return 'محلول';
      case 'paid':
        return 'مدفوعة';
      case 'unpaid':
        return 'غير مدفوعة';
      case 'pending_settlement':
        return 'بانتظار التسوية';
      default:
        return AdminFormat.orDash(status);
    }
  }
}

/// شارة حالة موحّدة.
class AdminStatusChip extends StatelessWidget {
  final String? status;
  final String? overrideLabel;

  const AdminStatusChip({super.key, this.status, this.overrideLabel});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AdminStatusPalette.background(context, status),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AdminStatusPalette.color(context, status).withValues(alpha: 0.35),
        ),
      ),
      child: Text(
        overrideLabel ?? AdminStatusPalette.label(status),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: AdminStatusPalette.color(context, status),
        ),
      ),
    );
  }
}

/// بطاقة قسم بحدود وخلفية متوافقة مع الـ Theme.
class AdminPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const AdminPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderSoft),
      ),
      child: child,
    );
  }
}

/// صف "عنوان: قيمة" مستعمل في كل شاشات التفاصيل والمعاينات.
class AdminInfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool emphasized;

  const AdminInfoRow({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
    this.emphasized = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 180,
            child: Text(
              label,
              style: TextStyle(fontSize: 12, color: context.textMuted),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: emphasized ? 14 : 12.5,
                fontWeight: emphasized ? FontWeight.w900 : FontWeight.w600,
                color: valueColor ?? context.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// حالة التحميل الموحّدة.
class AdminLoadingView extends StatelessWidget {
  final String? message;
  const AdminLoadingView({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(strokeWidth: 2.5),
          if (message != null) ...[
            const SizedBox(height: 12),
            Text(
              message!,
              style: TextStyle(fontSize: 12, color: context.textMuted),
            ),
          ],
        ],
      ),
    );
  }
}

/// حالة "لا توجد بيانات" الموحّدة.
class AdminEmptyView extends StatelessWidget {
  final String message;
  final String? hint;
  final IconData icon;
  final VoidCallback? onRefresh;

  const AdminEmptyView({
    super.key,
    required this.message,
    this.hint,
    this.icon = Icons.inbox_rounded,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 44, color: context.textMuted),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: context.textSecondary,
            ),
          ),
          if (hint != null) ...[
            const SizedBox(height: 6),
            Text(
              hint!,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11.5, color: context.textMuted),
            ),
          ],
          if (onRefresh != null) ...[
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('إعادة التحميل'),
            ),
          ],
        ],
      ),
    );
  }
}

/// حالة الخطأ الموحّدة — تعرض رسالة الخادم كما هي دون استبدالها.
class AdminErrorView extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const AdminErrorView({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, size: 44, color: context.dangerColor),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: context.dangerColor,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('إعادة المحاولة'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// إشعار موحّد لرسائل الخادم (نجاح/خطأ).
void showAdminSnackBar(
  BuildContext context,
  String message, {
  required bool isError,
}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? context.dangerColor : context.successColor,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: isError ? 6 : 4),
      ),
    );
}

/// حوار تأكيد موحّد لكل عملية تُغيّر بيانات مالية.
Future<bool> showAdminConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  bool isDestructive = false,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        backgroundColor: dialogContext.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: dialogContext.textPrimary,
          ),
        ),
        content: Text(
          message,
          style: TextStyle(fontSize: 13, color: dialogContext.textSecondary),
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isDestructive
                  ? dialogContext.dangerColor
                  : dialogContext.primaryColor,
              foregroundColor: dialogContext.onPrimary,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(confirmLabel),
          ),
        ],
      ),
    ),
  );
  return confirmed ?? false;
}
