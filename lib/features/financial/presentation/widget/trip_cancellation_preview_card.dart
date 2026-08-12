import 'package:flutter/material.dart';

import '../../../../core/utils/admin_theme_context.dart';
import '../../data/models/trip_cancellation_preview_model.dart';
import '../../../../core/widgets/admin_ui.dart';

/// بطاقة معاينة إلغاء الرحلة حسب مصفوفة الغرامات — عرض فقط.
class TripCancellationPreviewCard extends StatelessWidget {
  final TripCancellationPreviewModel preview;

  const TripCancellationPreviewCard({super.key, required this.preview});

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
                  'معاينة إلغاء الرحلة #${preview.tripId}',
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
            label: 'الجهة الملغية',
            value: CancelledBy.label(preview.cancelledBy),
          ),
          AdminInfoRow(
            label: 'سعر الرحلة',
            value: AdminFormat.money(preview.tripPriceDinar),
          ),
          AdminInfoRow(
            label: 'المبلغ المسترجَع لولي الأمر',
            value: AdminFormat.money(preview.parentRefundDinar),
            valueColor: context.successColor,
          ),
          AdminInfoRow(
            label: 'المبلغ المستحق للسائق',
            value: AdminFormat.money(preview.driverPayDinar),
          ),
          AdminInfoRow(
            label: 'حصة المنصة',
            value: AdminFormat.money(preview.platformAmountDinar),
          ),
          AdminInfoRow(
            label: 'الغرامة',
            value: AdminFormat.money(preview.penaltyDinar),
            valueColor: context.dangerColor,
            emphasized: true,
          ),
        ],
      ),
    );
  }
}
