import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/utils/admin_theme_context.dart';
import '../../data/models/payment_method_model.dart';
import '../../logic/cubit/financial_cubit.dart';
import '../../logic/state/financial_state.dart';
import '../../../../core/widgets/admin_ui.dart';
import '../widget/payment_method_form_dialog.dart';

/// شاشة إدارة طرق الدفع للإدارة المالية.
/// GET|POST|PUT|PATCH|DELETE /api/admin/payment-methods
class PaymentMethodsScreen extends StatelessWidget {
  const PaymentMethodsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<FinancialCubit>(
      create: (_) => sl<FinancialCubit>()..loadPaymentMethods(),
      child: const _PaymentMethodsView(),
    );
  }
}

class _PaymentMethodsView extends StatelessWidget {
  const _PaymentMethodsView();

  void _openFormDialog(
    BuildContext context, {
    PaymentMethodModel? methodToEdit,
  }) {
    showDialog(
      context: context,
      builder: (_) => PaymentMethodFormDialog(
        initialMethod: methodToEdit,
        onSubmit: (method) {
          final cubit = context.read<FinancialCubit>();
          if (methodToEdit != null && methodToEdit.id != null) {
            cubit.updatePaymentMethod(methodToEdit.id!, method);
          } else {
            cubit.createPaymentMethod(method);
          }
        },
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    PaymentMethodModel method,
  ) async {
    if (method.id == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('تأكيد الحذف'),
          content: Text(
            'هل أنت متأكد من رغبتك في حذف طريقة الدفع "${method.nameAr}"؟\n'
            'لا يمكن التراجع عن هذا الإجراء.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: ctx.errorColor,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('حذف'),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true && context.mounted) {
      context.read<FinancialCubit>().deletePaymentMethod(method.id!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('إدارة طرق الدفع'),
          actions: [
            IconButton(
              tooltip: 'تحديث القائمة',
              onPressed: () =>
                  context.read<FinancialCubit>().loadPaymentMethods(),
              icon: const Icon(Icons.refresh_rounded),
            ),
          ],
        ),
        body: BlocConsumer<FinancialCubit, FinancialState>(
          listener: (context, state) {
            if (state is PaymentMethodActionSuccess) {
              showAdminSnackBar(context, state.message, isError: false);
            } else if (state is PaymentMethodsError) {
              showAdminSnackBar(context, state.message, isError: true);
            }
          },
          builder: (context, state) {
            if (state is PaymentMethodsLoading || state is FinancialInitial) {
              return const AdminLoadingView(
                message: 'جارٍ جلب طرق الدفع من الخادم...',
              );
            }

            if (state is PaymentMethodsError && state is! PaymentMethodsLoaded) {
              return AdminErrorView(
                message: state.message,
                onRetry: () =>
                    context.read<FinancialCubit>().loadPaymentMethods(),
              );
            }

            final methods = state is PaymentMethodsLoaded
                ? state.methods
                : <PaymentMethodModel>[];
            final actionId = state is PaymentMethodsLoaded
                ? state.actionMethodId
                : null;

            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'قائمة طرق الدفع المعتمدة',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: context.textPrimary,
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _openFormDialog(context),
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text('إضافة طريقة دفع'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (methods.isEmpty)
                  const AdminEmptyView(
                    message: 'لا توجد طرق دفع',
                    hint: 'لم يتم إضافة أية طرق دفع حتى الآن.',
                  )
                else
                  AdminPanel(
                    padding: EdgeInsets.zero,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minWidth: MediaQuery.of(context).size.width - 80,
                        ),
                        child: DataTable(
                          headingRowHeight: 44,
                          dataRowMaxHeight: 56,
                          columns: const [
                            DataColumn(label: Text('اسم الطريقة')),
                            DataColumn(label: Text('الكود (Code)')),
                            DataColumn(label: Text('الجمهور')),
                            DataColumn(label: Text('نوع المعالجة')),
                            DataColumn(label: Text('الترتيب')),
                            DataColumn(label: Text('الحالة')),
                            DataColumn(label: Text('الإجراءات')),
                          ],
                          rows: [
                            for (final item in methods)
                              DataRow(
                                cells: [
                                  DataCell(
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.nameAr,
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: context.textPrimary,
                                          ),
                                        ),
                                        if (item.nameEn != null &&
                                            item.nameEn!.isNotEmpty)
                                          Text(
                                            item.nameEn!,
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: context.textMuted,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      item.code,
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        fontFamily: 'monospace',
                                        color: context.textPrimary,
                                      ),
                                    ),
                                  ),
                                  DataCell(Text(item.targetAudienceLabel)),
                                  DataCell(Text(item.processingTypeLabel)),
                                  DataCell(Text('${item.sortOrder}')),
                                  DataCell(
                                    _buildStatusChip(context, item.isActive),
                                  ),
                                  DataCell(
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          tooltip: item.isActive
                                              ? 'تعطيل الطريقة'
                                              : 'تفعيل الطريقة',
                                          icon: actionId == item.id
                                              ? const SizedBox(
                                                  width: 16,
                                                  height: 16,
                                                  child:
                                                      CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                  ),
                                                )
                                              : Icon(
                                                  item.isActive
                                                      ? Icons.toggle_on_rounded
                                                      : Icons.toggle_off_rounded,
                                                  color: item.isActive
                                                      ? context.successColor
                                                      : context.textMuted,
                                                  size: 24,
                                                ),
                                          onPressed: actionId != null
                                              ? null
                                              : () {
                                                  if (item.id != null) {
                                                    context
                                                        .read<FinancialCubit>()
                                                        .togglePaymentMethodStatus(
                                                          item.id!,
                                                        );
                                                  }
                                                },
                                        ),
                                        IconButton(
                                          tooltip: 'تعديل',
                                          icon: Icon(
                                            Icons.edit_rounded,
                                            size: 18,
                                            color: context.primaryColor,
                                          ),
                                          onPressed: actionId != null
                                              ? null
                                              : () => _openFormDialog(
                                                    context,
                                                    methodToEdit: item,
                                                  ),
                                        ),
                                        IconButton(
                                          tooltip: 'حذف',
                                          icon: Icon(
                                            Icons.delete_outline_rounded,
                                            size: 18,
                                            color: context.errorColor,
                                          ),
                                          onPressed: actionId != null
                                              ? null
                                              : () =>
                                                  _confirmDelete(context, item),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: (isActive ? context.successColor : context.textMuted)
            .withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (isActive ? context.successColor : context.textMuted)
              .withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        isActive ? 'مفعلة' : 'غير مفعلة',
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.bold,
          color: isActive ? context.successColor : context.textMuted,
        ),
      ),
    );
  }
}
