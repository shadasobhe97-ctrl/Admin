import 'package:flutter/material.dart';
import '../../../../core/utils/admin_theme_context.dart';
import '../../data/models/complaint_model.dart';
import 'complaint_status_badge.dart';

class DriverComplaintsHistoryWidget extends StatelessWidget {
  final List<ComplaintModel> history;
  final bool isLoading;

  const DriverComplaintsHistoryWidget({
    super.key,
    required this.history,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.borderSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.history_rounded,
                size: 18,
                color: context.primaryColor,
              ),
              const SizedBox(width: 8),
              Text(
                'تاريخ شكاوى السائق الميدانية',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: context.textPrimary,
                ),
              ),
              const Spacer(),
              if (isLoading)
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                Text(
                  '(${history.length} شكوى إجمالاً)',
                  style: TextStyle(
                    fontSize: 11,
                    color: context.textMuted,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            )
          else if (history.isEmpty)
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                'لا توجد شكاوى سابقة مسجلة لهذا السائق.',
                style: TextStyle(fontSize: 12, color: context.textMuted),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: history.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final item = history[index];
                return Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: context.cardColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: context.borderSoft),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: context.textPrimary,
                              ),
                            ),
                            if (item.createdAt != null)
                              Text(
                                item.createdAt!,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: context.textMuted,
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      ComplaintStatusBadge(
                        status: item.status,
                        isCompact: true,
                      ),
                      if (item.actionTaken != 'none') ...[
                        const SizedBox(width: 6),
                        ComplaintActionBadge(actionTaken: item.actionTaken),
                      ],
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
