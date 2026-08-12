import 'package:flutter/material.dart';

import '../../../../core/utils/admin_theme_context.dart';
import '../../data/models/recharge_model.dart';
import '../../../../core/widgets/admin_ui.dart';

/// عرض تفاصيل عملية شحن المحفظة كما وردت من الخادم.
class RechargeDetailsPanel extends StatelessWidget {
  final RechargeModel recharge;

  const RechargeDetailsPanel({super.key, required this.recharge});

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
                  'عملية شحن رقم #${recharge.id}',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: context.textPrimary,
                  ),
                ),
              ),
              AdminStatusChip(status: recharge.status),
            ],
          ),
          Divider(color: context.dividerLine, height: 24),
          AdminInfoRow(label: 'اسم ولي الأمر', value: recharge.parentName),
          AdminInfoRow(
            label: 'رقم هاتف ولي الأمر',
            value: AdminFormat.orDash(recharge.parentPhone),
          ),
          AdminInfoRow(
            label: 'مبلغ الشحن',
            value: AdminFormat.money(recharge.amount),
            emphasized: true,
          ),
          AdminInfoRow(
            label: 'وسيلة الدفع',
            value: AdminFormat.orDash(recharge.paymentMethod),
          ),
          AdminInfoRow(
            label: 'الرقم المرجعي',
            value: AdminFormat.orDash(recharge.referenceNumber),
          ),
          AdminInfoRow(
            label: 'تاريخ الطلب',
            value: AdminFormat.dateTime(recharge.createdAt),
          ),
          AdminInfoRow(
            label: 'تاريخ المعالجة',
            value: AdminFormat.dateTime(recharge.processedAt),
          ),
          AdminInfoRow(
            label: 'المشرف المُعالِج',
            value: AdminFormat.orDash(recharge.adminName),
          ),
          if (recharge.failureReason != null)
            AdminInfoRow(
              label: 'سبب الإخفاق',
              value: recharge.failureReason!,
              valueColor: context.dangerColor,
            ),
        ],
      ),
    );
  }
}
