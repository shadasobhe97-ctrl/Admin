import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/permission_helper.dart';
import '../../../../core/utils/admin_theme_context.dart';
import '../../../../core/widgets/admin_pagination.dart';
import '../../logic/cubit/complaints_cubit.dart';
import '../../logic/state/complaints_state.dart';
import '../widgets/complaint_card.dart';
import '../widgets/complaint_filter_bar.dart';
import 'complaint_details_screen.dart';

import '../../../../core/permissions/authorization_service.dart';

class ComplaintsScreen extends StatefulWidget {
  const ComplaintsScreen({super.key});

  @override
  State<ComplaintsScreen> createState() => _ComplaintsScreenState();
}

class _ComplaintsScreenState extends State<ComplaintsScreen> {
  dynamic _activeDetailsComplaintId;

  @override
  Widget build(BuildContext context) {
    if (!AuthorizationService.hasPermission('complaints.view') &&
        !PermissionHelper.hasPermission('complaints.view') &&
        !AuthorizationService.hasPermission('*')) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_person_rounded, size: 56, color: context.warningColor),
              const SizedBox(height: 16),
              Text(
                'صلاحية غير كافية',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: context.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'استعراض قسم الشكاوى والبلاغات يتطلب صلاحية (complaints.view).',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: context.textMuted),
              ),
            ],
          ),
        ),
      );
    }

    if (_activeDetailsComplaintId != null) {
      return ComplaintDetailsScreen(
        complaintId: _activeDetailsComplaintId,
        onBack: () {
          setState(() {
            _activeDetailsComplaintId = null;
          });
        },
      );
    }

    return BlocConsumer<ComplaintsCubit, ComplaintsState>(
      listener: (context, state) {
        if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: context.dangerColor,
            ),
          );
        }
      },
      builder: (context, state) {
        final cubit = context.read<ComplaintsCubit>();

        return RefreshIndicator(
          onRefresh: () async {
            await cubit.fetchComplaints(page: state.meta.currentPage);
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Screen Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'إدارة الشكاوى والقرارات الإدارية',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: context.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'متابعة ومراجعة الشكاوى الميدانية واتخاذ القرارات الإدارية المناسبة بحق السائقين.',
                        style: TextStyle(
                          fontSize: 12,
                          color: context.textMuted,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    tooltip: 'إعادة تحديث القائمة',
                    icon: Icon(Icons.refresh_rounded,
                        color: context.primaryColor),
                    onPressed: () =>
                        cubit.fetchComplaints(page: state.meta.currentPage),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // 1.5 Quick KPI Cards
              _buildComplaintStats(context, state, cubit),

              const SizedBox(height: 16),

              // 2. Filter Bar
              ComplaintFilterBar(
                selectedStatus: state.selectedStatus,
                onStatusChanged: (status) => cubit.changeStatusFilter(status),
                selectedDriverName: state.selectedDriverName,
                onClearDriverFilter: () => cubit.clearDriverFilter(),
              ),

              const SizedBox(height: 16),

              // 3. Body States: Loading / Error / Empty / Loaded
              Expanded(
                child: _buildBodyContent(context, state, cubit),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildComplaintStats(
    BuildContext context,
    ComplaintsState state,
    ComplaintsCubit cubit,
  ) {
    final total =
        state.meta.total > 0 ? state.meta.total : state.complaints.length;
    final pending = state.complaints
        .where((c) => c.status.toLowerCase() == 'pending')
        .length;
    final completed = state.complaints
        .where((c) =>
            c.status.toLowerCase() == 'completed' ||
            c.status.toLowerCase() == 'resolved')
        .length;
    final dismissed = state.complaints
        .where((c) =>
            c.status.toLowerCase() == 'dismissed' ||
            c.status.toLowerCase() == 'rejected')
        .length;

    final cards = [
      _ComplaintStatItem(
        title: 'إجمالي الشكاوى',
        count: total,
        statusKey: 'all',
        icon: Icons.assignment_rounded,
        color: context.primaryColor,
        bgColor: context.surfaceVariant,
      ),
      _ComplaintStatItem(
        title: 'قيد الانتظار',
        count: pending,
        statusKey: 'pending',
        icon: Icons.hourglass_top_rounded,
        color: context.warningColor,
        bgColor: context.warningBg,
      ),
      _ComplaintStatItem(
        title: 'معالجة ومكتملة',
        count: completed,
        statusKey: 'completed',
        icon: Icons.check_circle_rounded,
        color: context.successColor,
        bgColor: context.successBg,
      ),
      _ComplaintStatItem(
        title: 'مرفوضة / متجاهلة',
        count: dismissed,
        statusKey: 'dismissed',
        icon: Icons.cancel_rounded,
        color: context.textMuted,
        bgColor: context.surfaceVariant,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 720;
        if (isWide) {
          return Row(
            children: [
              for (var i = 0; i < cards.length; i++) ...[
                Expanded(
                  child: _buildStatCard(
                    context,
                    item: cards[i],
                    isSelected: state.selectedStatus == cards[i].statusKey,
                    onTap: () => cubit.changeStatusFilter(cards[i].statusKey),
                  ),
                ),
                if (i != cards.length - 1) const SizedBox(width: 12),
              ],
            ],
          );
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (var i = 0; i < cards.length; i++) ...[
                SizedBox(
                  width: 170,
                  child: _buildStatCard(
                    context,
                    item: cards[i],
                    isSelected: state.selectedStatus == cards[i].statusKey,
                    onTap: () => cubit.changeStatusFilter(cards[i].statusKey),
                  ),
                ),
                if (i != cards.length - 1) const SizedBox(width: 10),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required _ComplaintStatItem item,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? item.color : context.borderSoft,
            width: isSelected ? 1.8 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: item.color.withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: item.bgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(item.icon, size: 20, color: item.color),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.title,
                    style: TextStyle(
                      fontSize: 11,
                      color: isSelected ? item.color : context.textMuted,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${item.count}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: context.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBodyContent(
    BuildContext context,
    ComplaintsState state,
    ComplaintsCubit cubit,
  ) {
    if (state.isLoading && state.complaints.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (state.errorMessage != null && state.complaints.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 48,
              color: context.dangerColor,
            ),
            const SizedBox(height: 12),
            Text(
              state.errorMessage!,
              style: TextStyle(color: context.textPrimary, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => cubit.fetchComplaints(page: 1),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    if (state.complaints.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_rounded,
              size: 56,
              color: context.textMuted,
            ),
            const SizedBox(height: 12),
            Text(
              'لا توجد شكاوى مسجلة تطابق التصفية الحالية.',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: context.textSecondary,
              ),
            ),
            if (state.selectedStatus != 'all' ||
                state.selectedDriverId != null) ...[
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () {
                  cubit.clearDriverFilter();
                  cubit.changeStatusFilter('all');
                },
                child: const Text('عرض جميع الشكاوى'),
              ),
            ],
          ],
        ),
      );
    }

    return Column(
      children: [
        // Complaint List
        Expanded(
          child: ListView.separated(
            itemCount: state.complaints.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = state.complaints[index];
              return ComplaintCard(
                complaint: item,
                onTap: () {
                  cubit.fetchComplaintDetails(item.id);
                  setState(() {
                    _activeDetailsComplaintId = item.id;
                  });
                },
              );
            },
          ),
        ),

        // 4. Pagination Footer
        if (state.meta.lastPage > 1 || state.meta.total > 0)
          AdminPagination(
            meta: state.meta,
            enabled: !state.isLoading,
            onPageChanged: (newPage) {
              cubit.fetchComplaints(page: newPage);
            },
          ),
      ],
    );
  }
}

class _ComplaintStatItem {
  final String title;
  final int count;
  final String statusKey;
  final IconData icon;
  final Color color;
  final Color bgColor;

  const _ComplaintStatItem({
    required this.title,
    required this.count,
    required this.statusKey,
    required this.icon,
    required this.color,
    required this.bgColor,
  });
}

