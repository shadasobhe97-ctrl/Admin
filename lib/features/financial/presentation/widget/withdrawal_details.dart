import 'package:flutter/material.dart';

import '../../../../core/utils/admin_theme_context.dart';
import '../../data/models/withdrawal_model.dart';
import '../../../../core/widgets/admin_ui.dart';

/// عرض تفاصيل طلب السحب كما وردت من الخادم.
class WithdrawalDetailsPanel extends StatelessWidget {
  final WithdrawalModel withdrawal;

  const WithdrawalDetailsPanel({super.key, required this.withdrawal});

  @override
  Widget build(BuildContext context) {
    return AdminPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'طلب سحب رقم #${withdrawal.id}',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: context.textPrimary,
                  ),
                ),
              ),
              AdminStatusChip(status: withdrawal.status),
            ],
          ),
          Divider(color: context.dividerLine, height: 24),
          AdminInfoRow(label: 'اسم السائق', value: withdrawal.driverName),
          AdminInfoRow(
            label: 'رقم هاتف السائق',
            value: AdminFormat.orDash(withdrawal.driverPhone),
          ),
          AdminInfoRow(
            label: 'المبلغ المطلوب',
            value: AdminFormat.money(withdrawal.amount),
            emphasized: true,
          ),
          AdminInfoRow(
            label: 'رصيد المحفظة وقت الطلب',
            value: AdminFormat.money(withdrawal.walletBalanceAtReq),
          ),
          AdminInfoRow(
            label: 'بيانات وسيلة الدفع',
            value: AdminFormat.orDash(withdrawal.paymentMethodDetails),
          ),
          AdminInfoRow(
            label: 'تاريخ الطلب',
            value: AdminFormat.dateTime(withdrawal.createdAt),
          ),
          AdminInfoRow(
            label: 'تاريخ المعالجة',
            value: AdminFormat.dateTime(withdrawal.processedAt),
          ),
          AdminInfoRow(
            label: 'المشرف المُعالِج',
            value: AdminFormat.orDash(withdrawal.adminName),
          ),
          if (withdrawal.rejectionReason != null)
            AdminInfoRow(
              label: 'سبب الرفض',
              value: withdrawal.rejectionReason!,
              valueColor: context.dangerColor,
            ),
        ],
      ),
    );
  }
}
