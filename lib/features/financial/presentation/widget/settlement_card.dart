import 'package:flutter/material.dart';

import '../../../../core/utils/admin_theme_context.dart';
import '../../data/models/settlement_contract_model.dart';
import '../../../../core/widgets/admin_ui.dart';

/// بطاقة عقد جاهز للتسوية الشهرية.
/// لا تُنفّذ التسوية عند العرض — فقط عبر [onSettle] بعد تأكيد المستخدم.
class SettlementCard extends StatelessWidget {
  final SettlementContractModel contract;
  final bool isProcessing;
  final bool actionsEnabled;
  final VoidCallback onSettle;
  final VoidCallback onPreviewTermination;

  const SettlementCard({
    super.key,
    required this.contract,
    required this.isProcessing,
    required this.actionsEnabled,
    required this.onSettle,
    required this.onPreviewTermination,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AdminPanel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'عقد ${contract.contractNumber}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: context.textPrimary,
                    ),
                  ),
                ),
                AdminStatusChip(status: contract.settlementStatus),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'ولي الأمر: ${AdminFormat.orDash(contract.parent)}'
              '  •  السائق: ${AdminFormat.orDash(contract.driver)}',
              style: TextStyle(fontSize: 11.5, color: context.textMuted),
            ),
            Divider(color: context.dividerLine, height: 20),
            Wrap(
              spacing: 24,
              runSpacing: 8,
              children: [
                _Metric(
                  label: 'إجمالي العقد',
                  value: AdminFormat.money(contract.totalAmount),
                ),
                _Metric(
                  label: 'المنفَّذ',
                  value: AdminFormat.money(contract.executedAmount),
                  color: context.successColor,
                ),
                _Metric(
                  label: 'المتبقّي',
                  value: AdminFormat.money(contract.pendingAmount),
                  color: context.warningColor,
                ),
                _Metric(
                  label: 'الرحلات المكتملة',
                  value: AdminFormat.count(contract.completedTrips),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: contract.executionRatio,
                minHeight: 6,
                backgroundColor: context.surfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: actionsEnabled ? onPreviewTermination : null,
                  icon: const Icon(Icons.preview_rounded, size: 16),
                  label: const Text('معاينة إنهاء العقد'),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed:
                      actionsEnabled && !isProcessing ? onSettle : null,
                  icon: isProcessing
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.done_all_rounded, size: 16),
                  label: Text(
                    isProcessing ? 'جارٍ التسوية...' : 'تنفيذ التسوية الشهرية',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const _Metric({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: TextStyle(fontSize: 11, color: context.textMuted)),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w900,
            color: color ?? context.textPrimary,
          ),
        ),
      ],
    );
  }
}
