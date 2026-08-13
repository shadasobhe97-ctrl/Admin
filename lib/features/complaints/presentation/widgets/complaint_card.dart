import 'package:flutter/material.dart';
import '../../../../core/utils/admin_theme_context.dart';
import '../../data/models/complaint_model.dart';
import 'complaint_status_badge.dart';

class ComplaintCard extends StatelessWidget {
  final ComplaintModel complaint;
  final VoidCallback onTap;

  const ComplaintCard({
    super.key,
    required this.complaint,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: context.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: context.borderSoft),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        hoverColor: context.primaryColor.withValues(alpha: 0.04),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Header: Title & Badges
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: context.primaryColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.report_problem_rounded,
                      color: context.primaryColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          complaint.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: context.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (complaint.createdAt != null &&
                            complaint.createdAt!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            complaint.createdAt!,
                            style: TextStyle(
                              fontSize: 11,
                              color: context.textMuted,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  ComplaintStatusBadge(status: complaint.status),
                ],
              ),

              const SizedBox(height: 12),
              Divider(height: 1, color: context.borderSoft),
              const SizedBox(height: 12),

              // Details Body: Reporter, Driver, Trip
              Row(
                children: [
                  // Reporter
                  Expanded(
                    child: _buildInfoItem(
                      context: context,
                      label: 'مقدم الشكوى:',
                      value: complaint.submittedBy?.name ?? 'غير معروف',
                      icon: Icons.person_outline_rounded,
                    ),
                  ),

                  // Driver
                  Expanded(
                    child: _buildInfoItem(
                      context: context,
                      label: 'السائق:',
                      value: complaint.driver?.name ?? 'غير محدد',
                      icon: Icons.directions_bus_outlined,
                    ),
                  ),

                  // Trip #
                  if (complaint.trip != null)
                    Expanded(
                      child: _buildInfoItem(
                        context: context,
                        label: 'الرحلة:',
                        value: '#${complaint.trip!.id}',
                        icon: Icons.route_outlined,
                      ),
                    ),
                ],
              ),

              if (complaint.actionTaken != 'none') ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text(
                      'الإجراء المتخذ: ',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: context.textMuted,
                      ),
                    ),
                    ComplaintActionBadge(actionTaken: complaint.actionTaken),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required BuildContext context,
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: context.textMuted),
        const SizedBox(width: 4),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10.5,
                  color: context.textMuted,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: context.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
