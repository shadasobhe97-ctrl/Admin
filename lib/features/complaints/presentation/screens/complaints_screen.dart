import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/admin_theme_context.dart';
import '../../../../core/widgets/admin_pagination.dart';
import '../../logic/cubit/complaints_cubit.dart';
import '../../logic/state/complaints_state.dart';
import '../widgets/complaint_card.dart';
import '../widgets/complaint_filter_bar.dart';
import 'complaint_details_screen.dart';

class ComplaintsScreen extends StatefulWidget {
  const ComplaintsScreen({super.key});

  @override
  State<ComplaintsScreen> createState() => _ComplaintsScreenState();
}

class _ComplaintsScreenState extends State<ComplaintsScreen> {
  dynamic _activeDetailsComplaintId;

  @override
  Widget build(BuildContext context) {
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
