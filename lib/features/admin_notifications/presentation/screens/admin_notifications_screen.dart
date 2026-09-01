import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/admin_theme_context.dart';
import '../../data/models/admin_notification_model.dart';
import '../../logic/cubit/admin_notifications_cubit.dart';
import '../../logic/cubit/admin_notifications_state.dart';
import '../widgets/notification_filters_bar.dart';
import '../widgets/notification_item_card.dart';

class AdminNotificationsScreen extends StatefulWidget {
  final Function(String targetScreen, Map<String, dynamic>? payload, String? entityId)? onNavigateToScreen;

  const AdminNotificationsScreen({
    super.key,
    this.onNavigateToScreen,
  });

  @override
  State<AdminNotificationsScreen> createState() => _AdminNotificationsScreenState();
}

class _AdminNotificationsScreenState extends State<AdminNotificationsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminNotificationsCubit>().fetchNotifications();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<AdminNotificationsCubit>().loadMoreNotifications();
    }
  }

  void _handleNotificationTap(AdminNotificationModel notification) {
    context.read<AdminNotificationsCubit>().markAsRead(notification.id);

    if (notification.isDriverAbsence) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('📋 ${notification.title}: هذا الإشعار للعلم فقط، تم تمييزه كمقروء.'),
          backgroundColor: context.infoColor,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    final screenName = notification.screen;
    if (screenName != null && screenName.isNotEmpty) {
      if (widget.onNavigateToScreen != null) {
        widget.onNavigateToScreen!(
          screenName,
          notification.payload,
          notification.entityId,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AdminNotificationsCubit, AdminNotificationsState>(
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: context.dangerColor,
            ),
          );
          context.read<AdminNotificationsCubit>().clearMessages();
        }

        if (state.successMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.successMessage!),
              backgroundColor: context.successColor,
            ),
          );
          context.read<AdminNotificationsCubit>().clearMessages();
        }
      },
      builder: (context, state) {
        return Column(
          children: [
            // Top Bar Action Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      'مركز الإشعارات والتنبيهات',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: context.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    if (state.unreadCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: context.dangerBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: context.dangerBorder),
                        ),
                        child: Text(
                          '${state.unreadCount} غير مقروء',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: context.dangerColor,
                          ),
                        ),
                      ),
                  ],
                ),

                // Mark All as Read Button
                ElevatedButton.icon(
                  onPressed: (state.isActionLoading || state.notifications.isEmpty)
                      ? null
                      : () => context.read<AdminNotificationsCubit>().markAllAsRead(),
                  icon: state.isActionLoading
                      ? SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: context.onPrimary,
                          ),
                        )
                      : const Icon(Icons.done_all_rounded, size: 16),
                  label: const Text('تمييز الكل كمقروء'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.primaryColor,
                    foregroundColor: context.onPrimary,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Filters Bar
            NotificationFiltersBar(
              unreadOnly: state.unreadOnlyFilter,
              onUnreadOnlyChanged: (val) {
                context.read<AdminNotificationsCubit>().changeUnreadFilter(val);
              },
              onRefresh: () {
                context.read<AdminNotificationsCubit>().fetchNotifications(refresh: true);
              },
            ),

            const SizedBox(height: 16),

            // List Content View
            Expanded(
              child: state.isLoading
                  ? Center(
                      child: CircularProgressIndicator(color: context.primaryColor),
                    )
                  : state.notifications.isEmpty
                      ? _buildEmptyState(context, state.unreadOnlyFilter)
                      : RefreshIndicator(
                          onRefresh: () async {
                            await context
                                .read<AdminNotificationsCubit>()
                                .fetchNotifications(refresh: true);
                          },
                          child: ListView.builder(
                            controller: _scrollController,
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: state.notifications.length + (state.isLoadingMore ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index == state.notifications.length) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: context.primaryColor,
                                      strokeWidth: 2.5,
                                    ),
                                  ),
                                );
                              }

                              final notification = state.notifications[index];
                              return NotificationItemCard(
                                notification: notification,
                                onTap: () => _handleNotificationTap(notification),
                              );
                            },
                          ),
                        ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, bool unreadOnly) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            unreadOnly ? Icons.mark_email_read_rounded : Icons.notifications_none_rounded,
            size: 64,
            color: context.textMuted.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 12),
          Text(
            unreadOnly ? 'لا توجد إشعارات غير مقروءة حالياً' : 'لا توجد إشعارات متاحة في الوقت الحالي',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: context.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            unreadOnly
                ? 'جميع الإشعارات الخاصة بك تمت قراءتها ومراجعتها.'
                : 'سيتم عرض أي تنبيهات أو طلبات جديدة فور وصولها من الخادم.',
            style: TextStyle(
              fontSize: 12,
              color: context.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
