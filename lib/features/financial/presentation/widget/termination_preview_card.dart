import 'package:flutter/material.dart';

import '../../../../core/utils/admin_theme_context.dart';
import '../../data/models/termination_preview_model.dart';
import '../../../../core/widgets/admin_ui.dart';

/// بطاقة معاينة إنهاء العقد — عرض فقط، لا تنفّذ أي عملية.
class TerminationPreviewCard extends StatelessWidget {
  final TerminationPreviewModel preview;
  final String terminatedBy;
  final bool isArbitraryParent;

  const TerminationPreviewCard({
    super.key,
    required this.preview,
    required this.terminatedBy,
    required this.isArbitraryParent,
  });

  @override
  Widget build(BuildContext context) {
    return AdminPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.preview_rounded, size: 20, color: context.infoColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'معاينة إنهاء العقد ${preview.contractNumber}',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: context.textPrimary,
                  ),
                ),
              ),
              const AdminStatusChip(
                status: 'preview',
                overrideLabel: 'معاينة فقط',
              ),
            ],
          ),
          Divider(color: context.dividerLine, height: 24),
          AdminInfoRow(
            label: 'الجهة المُنهية للعقد',
            value: TerminatedBy.label(terminatedBy),
          ),
          AdminInfoRow(
            label: 'إنهاء تعسّفي من ولي الأمر',
            value: isArbitraryParent ? 'نعم' : 'لا',
          ),
          Divider(color: context.dividerLine, height: 24),
          AdminInfoRow(
            label: 'إجمالي قيمة العقد',
            value: AdminFormat.money(preview.totalContractValue),
          ),
          AdminInfoRow(
            label: 'تكلفة الجزء المنفَّذ',
            value: AdminFormat.money(preview.completedTripsCost),
          ),
          AdminInfoRow(
            label: 'الأمانة المتبقية',
            value: AdminFormat.money(preview.remainingEscrow),
          ),
          AdminInfoRow(
            label: 'الغرامة',
            value: AdminFormat.money(preview.penaltyFee),
            valueColor: context.dangerColor,
          ),
          AdminInfoRow(
            label: 'المبلغ المسترجَع لولي الأمر',
            value: AdminFormat.money(preview.refundToParent),
            valueColor: context.successColor,
            emphasized: true,
          ),
          AdminInfoRow(
            label: 'مستحقات السائق',
            value: AdminFormat.money(preview.payoutToDriver),
            valueColor: context.infoColor,
            emphasized: true,
          ),
        ],
      ),
    );
  }
}
