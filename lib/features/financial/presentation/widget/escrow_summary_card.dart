import 'package:flutter/material.dart';

import '../../../../core/utils/admin_theme_context.dart';
import '../../data/models/escrow_summary_model.dart';
import '../../../../core/widgets/admin_ui.dart';

/// بطاقة ملخّص الأمانات مع زر التحرير.
/// التنفيذ لا يبدأ إلا عبر [onRelease] بعد تأكيد المستخدم في الشاشة.
class EscrowSummaryCard extends StatelessWidget {
  final EscrowSummaryModel escrows;
  final bool isReleasing;
  final VoidCallback onRelease;

  const EscrowSummaryCard({
    super.key,
    required this.escrows,
    required this.isReleasing,
    required this.onRelease,
  });

  @override
  Widget build(BuildContext context) {
    final canRelease = escrows.hasReleasableEscrows && !isReleasing;

    return AdminPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lock_clock_rounded,
                  size: 20, color: context.warningColor),
              const SizedBox(width: 8),
              Text(
                'الأمانات المحتجزة',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: context.textPrimary,
                ),
              ),
            ],
          ),
          Divider(color: context.dividerLine, height: 24),
          AdminInfoRow(
            label: 'المبلغ المحتجز (Pending)',
            value: AdminFormat.money(escrows.pendingAmount),
            emphasized: true,
          ),
          AdminInfoRow(
            label: 'المبلغ المستحق للتحرير (Eligible)',
            value: AdminFormat.money(escrows.eligibleAmount),
            valueColor: context.successColor,
            emphasized: true,
          ),
          AdminInfoRow(
            label: 'عدد الرحلات المحتجزة',
            value: AdminFormat.count(escrows.tripsCount),
          ),
          AdminInfoRow(
            label: 'عدد الرحلات المستحقة',
            value: AdminFormat.count(escrows.eligibleCount),
          ),
          AdminInfoRow(
            label: 'أقدم أمانة',
            value: AdminFormat.dateTime(escrows.oldestEscrow),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  canRelease
                      ? 'سيؤدي التحرير إلى نقل الأرباح المستحقة إلى أرصدة السائقين المتاحة.'
                      : isReleasing
                          ? 'جارٍ تنفيذ عملية التحرير على الخادم...'
                          : 'لا توجد أمانات مستحقة للتحرير حالياً حسب بيانات الخادم.',
                  style:
                      TextStyle(fontSize: 12, color: context.textSecondary),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: canRelease ? onRelease : null,
                icon: isReleasing
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.lock_open_rounded, size: 16),
                label: Text(
                  isReleasing ? 'جارٍ التحرير...' : 'تحرير الأمانات المستحقة',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
