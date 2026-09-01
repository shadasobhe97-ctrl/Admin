import 'package:flutter/material.dart';
import '../../../../core/utils/admin_theme_context.dart';
import '../../data/models/admin_notification_model.dart';

class NotificationItemCard extends StatelessWidget {
  final AdminNotificationModel notification;
  final VoidCallback onTap;

  const NotificationItemCard({
    super.key,
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isUnread = !notification.isRead;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isUnread
            ? (context.isDarkMode
                ? context.primaryColor.withValues(alpha: 0.12)
                : context.primaryColor.withValues(alpha: 0.04))
            : context.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUnread ? context.primaryColor.withValues(alpha: 0.3) : context.borderSoft,
          width: isUnread ? 1.5 : 1.0,
        ),
        boxShadow: isUnread
            ? [
                BoxShadow(
                  color: context.primaryColor.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Dot indicator for unread
                    if (isUnread) ...[
                      Container(
                        margin: const EdgeInsets.only(top: 4, left: 8),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: context.primaryColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],

                    // Icon / Type visual
                    _buildIcon(context),

                    const SizedBox(width: 12),

                    // Title & Date
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            notification.title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                              color: context.textPrimary,
                            ),
                          ),
                          if (notification.createdAt != null &&
                              notification.createdAt!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              _formatDate(notification.createdAt!),
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

                    // Status Badge (مقروء / غير مقروء)
                    _buildStatusBadge(context, isUnread),
                  ],
                ),

                const SizedBox(height: 12),

                // Message text
                Text(
                  notification.message,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: isUnread ? context.textPrimary : context.textSecondary,
                  ),
                ),

                // Informational tag for driver absence or action hint
                if (notification.isDriverAbsence) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: context.infoBg,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: context.infoBorder),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.info_outline_rounded, size: 14, color: context.infoColor),
                        const SizedBox(width: 6),
                        Text(
                          'إشعار معلوماتي فقط — لا يتطلب إجراء تنقل',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: context.infoColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(BuildContext context) {
    IconData iconData = Icons.notifications_active_rounded;
    Color iconColor = context.primaryColor;

    if (notification.isDriverAbsence) {
      iconData = Icons.event_busy_rounded;
      iconColor = context.warningColor;
    } else if (notification.type?.contains('complaint') == true) {
      iconData = Icons.support_agent_rounded;
      iconColor = context.dangerColor;
    } else if (notification.type?.contains('financial') == true) {
      iconData = Icons.account_balance_wallet_rounded;
      iconColor = context.successColor;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(iconData, size: 18, color: iconColor),
    );
  }

  Widget _buildStatusBadge(BuildContext context, bool isUnread) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isUnread ? context.dangerBg : context.surfaceVariant,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isUnread ? context.dangerBorder : context.borderSoft,
        ),
      ),
      child: Text(
        isUnread ? 'غير مقروء' : 'مقروء',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: isUnread ? context.dangerColor : context.textMuted,
        ),
      ),
    );
  }

  String _formatDate(String isoDate) {
    try {
      final dt = DateTime.parse(isoDate).toLocal();
      return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return isoDate;
    }
  }
}
