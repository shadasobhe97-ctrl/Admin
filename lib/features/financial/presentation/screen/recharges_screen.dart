import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../logic/cubit/financial_cubit.dart';
import '../../logic/state/financial_state.dart';
import '../../../../core/widgets/admin_pagination.dart';
import '../widget/financial_status_filter_bar.dart';
import '../../../../core/widgets/admin_ui.dart';
import '../widget/recharge_card.dart';
import 'recharge_details_screen.dart';

/// قائمة عمليات شحن محافظ أولياء الأمور (GET /api/admin/financial/recharges).
class RechargesScreen extends StatelessWidget {
  const RechargesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<FinancialCubit>(
      create: (_) => sl<FinancialCubit>()..loadRecharges(),
      child: const _RechargesView(),
    );
  }
}

class _RechargesView extends StatefulWidget {
  const _RechargesView();

  @override
  State<_RechargesView> createState() => _RechargesViewState();
}

class _RechargesViewState extends State<_RechargesView> {
  String? _status;
  final TextEditingController _searchController = TextEditingController();
  DateTime? _dateFrom;
  DateTime? _dateTo;

  static const Map<String, String> _statusOptions = {
    'pending': 'معلّق',
    'completed': 'مكتمل',
    'failed': 'فاشل',
  };

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilters({int page = 1}) {
    final search = _searchController.text.trim().isEmpty
        ? null
        : _searchController.text.trim();
    final dateFromStr = _dateFrom?.toIso8601String().substring(0, 10);
    final dateToStr = _dateTo?.toIso8601String().substring(0, 10);

    context.read<FinancialCubit>().loadRecharges(
          status: _status,
          search: search,
          dateFrom: dateFromStr,
          dateTo: dateToStr,
          page: page,
        );
  }

  void _onStatusChanged(String? status) {
    setState(() => _status = status);
    _applyFilters();
  }

  Future<void> _pickDateFrom() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateFrom ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => _dateFrom = picked);
      _applyFilters();
    }
  }

  Future<void> _pickDateTo() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateTo ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => _dateTo = picked);
      _applyFilters();
    }
  }

  void _resetFilters() {
    setState(() {
      _status = null;
      _searchController.clear();
      _dateFrom = null;
      _dateTo = null;
    });
    _applyFilters();
  }

  Future<void> _openDetails(int id) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => RechargeDetailsScreen(rechargeId: id)),
    );
    if (!mounted) return;
    if (changed == true) {
      context.read<FinancialCubit>().refreshRecharges();
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasActiveFilters = _status != null ||
        _searchController.text.isNotEmpty ||
        _dateFrom != null ||
        _dateTo != null;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('طلبات شحن محافظ أولياء الأمور'),
          actions: [
            IconButton(
              tooltip: 'تحديث',
              onPressed: () => _applyFilters(),
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
                onChanged: _onStatusChanged,
              ),
              const SizedBox(height: 12),
              AdminPanel(
                padding: const EdgeInsets.all(12),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    SizedBox(
                      width: 240,
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'البحث باسم ولي الأمر / مرجع...',
                          prefixIcon: const Icon(Icons.search_rounded, size: 18),
                          isDense: true,
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 16),
                                  onPressed: () {
                                    _searchController.clear();
                                    _applyFilters();
                                  },
                                )
                              : null,
                        ),
                        onSubmitted: (_) => _applyFilters(),
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: _pickDateFrom,
                      icon: const Icon(Icons.date_range_rounded, size: 16),
                      label: Text(
                        _dateFrom == null
                            ? 'من تاريخ'
                            : 'من: ${_dateFrom!.toIso8601String().substring(0, 10)}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: _pickDateTo,
                      icon: const Icon(Icons.event_rounded, size: 16),
                      label: Text(
                        _dateTo == null
                            ? 'إلى تاريخ'
                            : 'إلى: ${_dateTo!.toIso8601String().substring(0, 10)}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _applyFilters(),
                      icon: const Icon(Icons.filter_alt_rounded, size: 16),
                      label: const Text('تطبيق الفلترة'),
                    ),
                    if (hasActiveFilters)
                      TextButton.icon(
                        onPressed: _resetFilters,
                        icon: const Icon(Icons.restart_alt_rounded, size: 16),
                        label: const Text('إعادة ضبط'),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: BlocConsumer<FinancialCubit, FinancialState>(
                  listener: (context, state) {
                    if (state is RechargeError) {
                      showAdminSnackBar(context, state.message, isError: true);
                    }
                  },
                  builder: (context, state) {
                    if (state is RechargesLoading || state is FinancialInitial) {
                      return const AdminLoadingView(
                        message: 'جارٍ جلب عمليات الشحن من الخادم...',
                      );
                    }

                    if (state is RechargesEmpty) {
                      return AdminEmptyView(
                        message: 'لا توجد عمليات شحن مطابقة',
                        hint: hasActiveFilters
                            ? 'جرّب تعديل فلاتر البحث أو إعادة التعيين.'
                            : 'لم تُسجَّل أي عملية شحن حتى الآن.',
                        icon: Icons.move_to_inbox_rounded,
                        onRefresh: () => _applyFilters(),
                      );
                    }

                    if (state is RechargeError) {
                      return AdminErrorView(
                        message: state.message,
                        onRetry: () => _applyFilters(),
                      );
                    }

                    if (state is RechargesLoaded) {
                      return Column(
                        children: [
                          Expanded(
                            child: ListView.builder(
                              itemCount: state.result.items.length,
                              itemBuilder: (context, index) {
                                final recharge = state.result.items[index];
                                return RechargeCard(
                                  recharge: recharge,
                                  onOpenDetails: () => _openDetails(recharge.id),
                                );
                              },
                            ),
                          ),
                          AdminPagination(
                            meta: state.result.meta,
                            onPageChanged: (page) => _applyFilters(page: page),
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
