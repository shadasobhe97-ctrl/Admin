import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/services/permission_helper.dart';
import '../../../../core/utils/admin_theme_context.dart';
import '../../logic/cubit/financial_cubit.dart';
import '../../logic/state/financial_state.dart';
import '../widget/dispute_card.dart';
import '../../../../core/widgets/admin_pagination.dart';
import '../widget/financial_status_filter_bar.dart';
import '../../../../core/widgets/admin_ui.dart';
import 'dispute_details_screen.dart';

/// قائمة النزاعات المالية.
class DisputesScreen extends StatelessWidget {
  const DisputesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (!PermissionHelper.hasPermission('financial.resolve_disputes')) {
      return Scaffold(
        backgroundColor: context.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: context.cardColor,
          elevation: 0,
          title: Text('النزاعات المالية', style: TextStyle(color: context.textPrimary, fontWeight: FontWeight.bold)),
        ),
        body: Center(
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
                  'استعراض والبت في النزاعات المالية يتطلب صلاحية (financial.resolve_disputes).',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: context.textMuted),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return BlocProvider<FinancialCubit>(
      create: (_) => sl<FinancialCubit>()..loadDisputes(),
      child: const _DisputesView(),
    );
  }
}

class _DisputesView extends StatefulWidget {
  const _DisputesView();

  @override
  State<_DisputesView> createState() => _DisputesViewState();
}

class _DisputesViewState extends State<_DisputesView> {
  String? _status;

  static const Map<String, String> _statusOptions = {
    'open': 'مفتوح',
    'resolved': 'محلول',
  };

  void _applyStatus(String? status) {
    setState(() => _status = status);
    context.read<FinancialCubit>().loadDisputes(status: status);
  }

  Future<void> _openDetails(int id) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => DisputeDetailsScreen(disputeId: id)),
    );
    if (!mounted) return;
    if (changed == true) {
      context.read<FinancialCubit>().refreshDisputes();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('النزاعات المالية'),
          actions: [
            IconButton(
              tooltip: 'تحديث',
              onPressed: () =>
                  context.read<FinancialCubit>().loadDisputes(status: _status),
              icon: const Icon(Icons.refresh_rounded),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FinancialStatusFilterBar(
                options: _statusOptions,
                selected: _status,
                onChanged: _applyStatus,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: BlocConsumer<FinancialCubit, FinancialState>(
                  listener: (context, state) {
                    if (state is DisputeError) {
                      showAdminSnackBar(context, state.message,
                          isError: true);
                    }
                  },
                  builder: (context, state) {
                    if (state is DisputesLoading || state is FinancialInitial) {
                      return const AdminLoadingView(
                        message: 'جارٍ جلب النزاعات من الخادم...',
                      );
                    }

                    if (state is DisputesEmpty) {
                      return AdminEmptyView(
                        message: 'لا توجد نزاعات مطابقة',
                        hint: _status == null
                            ? 'لم يُسجَّل أي نزاع مالي حتى الآن.'
                            : 'لا توجد نزاعات بحالة "${_statusOptions[_status] ?? _status}".',
                        icon: Icons.verified_user_rounded,
                        onRefresh: () => _applyStatus(_status),
                      );
                    }

                    if (state is DisputeError) {
                      return AdminErrorView(
                        message: state.message,
                        onRetry: () => _applyStatus(_status),
                      );
                    }

                    if (state is DisputesLoaded) {
                      return Column(
                        children: [
                          Expanded(
                            child: ListView.builder(
                              itemCount: state.result.items.length,
                              itemBuilder: (context, index) {
                                final dispute = state.result.items[index];
                                return DisputeCard(
                                  dispute: dispute,
                                  onOpenDetails: () => _openDetails(dispute.id),
                                );
                              },
                            ),
                          ),
                          AdminPagination(
                            meta: state.result.meta,
                            onPageChanged: (page) => context
                                .read<FinancialCubit>()
                                .loadDisputes(status: _status, page: page),
                          ),
                        ],
                      );
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
