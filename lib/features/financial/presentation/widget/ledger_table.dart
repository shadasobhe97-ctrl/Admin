import 'package:flutter/material.dart';

import '../../../../core/utils/admin_theme_context.dart';
import '../../data/models/ledger_entry_model.dart';
import '../../../../core/widgets/admin_ui.dart';

/// جدول سجل الحركات المالية.
class LedgerTable extends StatelessWidget {
  final List<LedgerEntryModel> entries;

  const LedgerTable({super.key, required this.entries});

  @override
  Widget build(BuildContext context) {
    return AdminPanel(
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 980),
            child: DataTable(
              headingRowColor:
                  WidgetStatePropertyAll(context.surfaceVariant),
              headingTextStyle: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.bold,
                color: context.textSecondary,
              ),
              dataTextStyle: TextStyle(
                fontSize: 12,
                color: context.textPrimary,
              ),
              dividerThickness: 0.6,
              columns: const [
                DataColumn(label: Text('#')),
                DataColumn(label: Text('الرقم المرجعي')),
                DataColumn(label: Text('الحساب المصدر')),
                DataColumn(label: Text('الحساب الوجهة')),
                DataColumn(label: Text('المبلغ')),
                DataColumn(label: Text('النوع')),
                DataColumn(label: Text('الحالة')),
                DataColumn(label: Text('التاريخ')),
              ],
              rows: [
                for (final entry in entries)
                  DataRow(
                    cells: [
                      DataCell(Text('${entry.id}')),
                      DataCell(
                        Text(
                          entry.referenceNumber,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataCell(_AccountChip(account: entry.sourceAccount)),
                      DataCell(_AccountChip(account: entry.destinationAccount)),
                      DataCell(
                        Text(
                          AdminFormat.money(entry.amount),
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                      DataCell(Text(AdminFormat.orDash(entry.type))),
                      DataCell(AdminStatusChip(status: entry.status)),
                      DataCell(Text(AdminFormat.dateTime(entry.createdAt))),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// عرض اسم الحساب المحاسبي كما أرسله الخادم دون تعديله.
class _AccountChip extends StatelessWidget {
  final String? account;

  const _AccountChip({required this.account});

  @override
  Widget build(BuildContext context) {
    if (account == null) {
      return Text('—', style: TextStyle(color: context.textMuted));
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: context.surfaceVariant,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: context.borderSoft),
      ),
      child: Text(
        account!,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
          color: context.textSecondary,
        ),
      ),
    );
  }
}
