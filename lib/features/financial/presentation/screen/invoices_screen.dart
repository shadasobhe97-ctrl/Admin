import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/utils/admin_theme_context.dart';
import '../../data/models/financial_invoice_model.dart';
import '../../logic/cubit/financial_cubit.dart';
import '../../logic/state/financial_state.dart';
import '../../../../core/widgets/admin_pagination.dart';
import '../widget/financial_status_filter_bar.dart';
import '../../../../core/widgets/admin_ui.dart';
import 'invoice_details_screen.dart';

/// قائمة الفواتير.
/// تستخدم المسار المعتمد في المشروع: `/admin/financial/invoices`.
class InvoicesScreen extends StatelessWidget {
  const InvoicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<FinancialCubit>(
      create: (_) => sl<FinancialCubit>()..loadInvoices(),
      child: const _InvoicesView(),
    );
  }
}

class _InvoicesView extends StatefulWidget {
  const _InvoicesView();

  @override
  State<_InvoicesView> createState() => _InvoicesViewState();
}

class _InvoicesViewState extends State<_InvoicesView> {
  String? _status;

  static const Map<String, String> _statusOptions = {
    'paid': 'مدفوعة',
    'unpaid': 'غير مدفوعة',
  };

  void _applyStatus(String? status) {
    setState(() => _status = status);
    context.read<FinancialCubit>().loadInvoices(status: status);
  }

  void _openDetails(int id) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => InvoiceDetailsScreen(invoiceId: id)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('الفواتير'),
          actions: [
            IconButton(
              tooltip: 'تحديث',
              onPressed: () =>
                  context.read<FinancialCubit>().loadInvoices(status: _status),
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
                child: BlocBuilder<FinancialCubit, FinancialState>(
                  builder: (context, state) {
                    if (state is InvoicesLoading || state is FinancialInitial) {
                      return const AdminLoadingView(
                        message: 'جارٍ جلب الفواتير من الخادم...',
                      );
                    }

                    if (state is InvoicesEmpty) {
                      return AdminEmptyView(
                        message: 'لا توجد فواتير مطابقة',
                        hint: 'لم يصدر الخادم أي فاتورة ضمن هذا الفلتر.',
                        icon: Icons.receipt_rounded,
                        onRefresh: () => _applyStatus(_status),
                      );
                    }

                    if (state is InvoicesError) {
                      return AdminErrorView(
                        message: state.message,
                        onRetry: () => _applyStatus(_status),
                      );
                    }

                    if (state is InvoicesLoaded) {
                      return Column(
                        children: [
                          Expanded(
                            child: ListView.builder(
                              itemCount: state.result.items.length,
                              itemBuilder: (context, index) {
                                final invoice = state.result.items[index];
                                return _InvoiceRow(
                                  invoice: invoice,
                                  onOpen: () => _openDetails(invoice.id),
                                );
                              },
                            ),
                          ),
                          AdminPagination(
                            meta: state.result.meta,
                            onPageChanged: (page) => context
                                .read<FinancialCubit>()
                                .loadInvoices(status: _status, page: page),
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

class _InvoiceRow extends StatelessWidget {
  final FinancialInvoiceModel invoice;
  final VoidCallback onOpen;

  const _InvoiceRow({required this.invoice, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AdminPanel(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor:
                  AdminStatusPalette.background(context, invoice.status),
              child: Icon(
                Icons.receipt_long_rounded,
                size: 18,
                color: AdminStatusPalette.color(context, invoice.status),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AdminFormat.orDash(invoice.invoiceNumber),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: context.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '#${invoice.id}'
                    '  •  ${AdminFormat.orDash(invoice.type)}'
                    '  •  ${AdminFormat.dateTime(invoice.createdAt)}',
                    style: TextStyle(fontSize: 11, color: context.textMuted),
                  ),
                ],
              ),
            ),
            Text(
              AdminFormat.money(invoice.amount),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: context.textPrimary,
              ),
            ),
            const SizedBox(width: 12),
            AdminStatusChip(status: invoice.status),
            const SizedBox(width: 8),
            TextButton.icon(
              onPressed: onOpen,
              icon: const Icon(Icons.open_in_new_rounded, size: 15),
              label: const Text('التفاصيل'),
            ),
          ],
        ),
      ),
    );
  }
}
