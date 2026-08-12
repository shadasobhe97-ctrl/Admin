import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/utils/admin_theme_context.dart';
import '../../logic/cubit/financial_cubit.dart';
import '../../logic/state/financial_state.dart';
import '../../../../core/widgets/admin_ui.dart';

/// تفاصيل الفاتورة (قراءة فقط).
class InvoiceDetailsScreen extends StatelessWidget {
  final int invoiceId;

  const InvoiceDetailsScreen({super.key, required this.invoiceId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<FinancialCubit>(
      create: (_) => sl<FinancialCubit>()..loadInvoiceDetails(invoiceId),
      child: _InvoiceDetailsView(invoiceId: invoiceId),
    );
  }
}

class _InvoiceDetailsView extends StatelessWidget {
  final int invoiceId;

  const _InvoiceDetailsView({required this.invoiceId});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text('تفاصيل الفاتورة #$invoiceId'),
          actions: [
            IconButton(
              tooltip: 'تحديث',
              onPressed: () => context
                  .read<FinancialCubit>()
                  .loadInvoiceDetails(invoiceId),
              icon: const Icon(Icons.refresh_rounded),
            ),
          ],
        ),
        body: BlocBuilder<FinancialCubit, FinancialState>(
          builder: (context, state) {
            if (state is InvoiceDetailsLoading || state is FinancialInitial) {
              return const AdminLoadingView(
                message: 'جارٍ جلب تفاصيل الفاتورة...',
              );
            }

            if (state is InvoicesError) {
              return AdminErrorView(
                message: state.message,
                onRetry: () => context
                    .read<FinancialCubit>()
                    .loadInvoiceDetails(invoiceId),
              );
            }

            if (state is InvoiceDetailsLoaded) {
              final invoice = state.invoice;
              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: AdminPanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              AdminFormat.orDash(invoice.invoiceNumber),
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                                color: context.textPrimary,
                              ),
                            ),
                          ),
                          AdminStatusChip(status: invoice.status),
                        ],
                      ),
                      Divider(color: context.dividerLine, height: 24),
                      AdminInfoRow(
                        label: 'رقم الفاتورة الداخلي',
                        value: '#${invoice.id}',
                      ),
                      AdminInfoRow(
                        label: 'النوع',
                        value: AdminFormat.orDash(invoice.type),
                      ),
                      AdminInfoRow(
                        label: 'المبلغ',
                        value: AdminFormat.money(invoice.amount),
                        emphasized: true,
                      ),
                      AdminInfoRow(
                        label: 'تاريخ الإصدار',
                        value: AdminFormat.dateTime(invoice.createdAt),
                      ),
                      // الحقول غير الموثّقة في العقد تُعرض كما وردت من الخادم.
                      if (invoice.extras.isNotEmpty) ...[
                        Divider(color: context.dividerLine, height: 24),
                        Text(
                          'حقول إضافية من الخادم',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: context.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        for (final entry in invoice.extras.entries)
                          AdminInfoRow(
                            label: entry.key,
                            value: '${entry.value}',
                          ),
                      ],
                    ],
                  ),
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
