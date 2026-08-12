import 'package:flutter/material.dart';

import '../../../../core/utils/admin_theme_context.dart';
import '../../data/models/financial_dispute_model.dart';
import '../../../../core/widgets/admin_ui.dart';

/// عرض تفاصيل النزاع المالي كما وردت من الخادم.
class DisputeDetailsPanel extends StatelessWidget {
  final FinancialDisputeModel dispute;

  const DisputeDetailsPanel({super.key, required this.dispute});

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
                  'نزاع مالي رقم #${dispute.id}',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: context.textPrimary,
                  ),
                ),
              ),
              AdminStatusChip(status: dispute.status),
            ],
          ),
          Divider(color: context.dividerLine, height: 24),
          AdminInfoRow(
            label: 'رقم الرحلة',
            value: dispute.tripId == null ? '—' : '#${dispute.tripId}',
          ),
          AdminInfoRow(
            label: 'المبلغ محل النزاع',
            value: AdminFormat.money(dispute.amount),
            emphasized: true,
          ),
          AdminInfoRow(
            label: 'سبب النزاع',
            value: AdminFormat.orDash(dispute.reason),
          ),
          Divider(color: context.dividerLine, height: 24),
          _PartyRow(title: 'ولي الأمر', party: dispute.parent),
          _PartyRow(title: 'السائق', party: dispute.driver),
          Divider(color: context.dividerLine, height: 24),
          AdminInfoRow(
            label: 'تاريخ فتح النزاع',
            value: AdminFormat.dateTime(dispute.createdAt),
          ),
          AdminInfoRow(
            label: 'ملاحظات الحل',
            value: AdminFormat.orDash(dispute.resolutionNotes),
          ),
        ],
      ),
    );
  }
}

class _PartyRow extends StatelessWidget {
  final String title;
  final DisputePartyModel? party;

  const _PartyRow({required this.title, required this.party});

  @override
  Widget build(BuildContext context) {
    if (party == null) {
      return AdminInfoRow(label: title, value: '—');
    }
    final phone = party!.phone;
    return AdminInfoRow(
      label: title,
      value: phone == null ? party!.name : '${party!.name} — $phone',
    );
  }
}
