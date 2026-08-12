import 'package:flutter/material.dart';

import '../../../../core/utils/admin_theme_context.dart';
import '../../data/models/ledger_entry_model.dart';
import '../../../../core/widgets/admin_ui.dart';

/// شريط فلاتر سجل الحركات.
/// يجمع المدخلات فقط ويسلّمها كـ [LedgerFilters] — كل الفلترة تتم على الخادم.
class LedgerFilterBar extends StatefulWidget {
  final LedgerFilters filters;
  final ValueChanged<LedgerFilters> onApply;
  final VoidCallback onReset;
  final bool enabled;

  const LedgerFilterBar({
    super.key,
    required this.filters,
    required this.onApply,
    required this.onReset,
    this.enabled = true,
  });

  @override
  State<LedgerFilterBar> createState() => _LedgerFilterBarState();
}

class _LedgerFilterBarState extends State<LedgerFilterBar> {
  late final TextEditingController _searchController;

  String? _type;
  String? _status;
  DateTime? _dateFrom;
  DateTime? _dateTo;

  /// أنواع الحركات المعروفة في العقد. حقل النوع يبقى حراً عبر البحث النصي
  /// لأي نوع آخر يضيفه الخادم لاحقاً.
  static const Map<String, String> _typeOptions = {
    'trip_hold': 'حجز مبلغ رحلة',
    'trip_release': 'تحرير مبلغ رحلة',
    'withdrawal': 'سحب أرباح',
    'recharge': 'شحن محفظة',
    'penalty': 'غرامة',
    'refund': 'استرجاع',
    'admin_audit_log': 'سجل عملية مشرف',
  };

  static const Map<String, String> _statusOptions = {
    'completed': 'مكتملة',
    'pending': 'معلّقة',
    'failed': 'فاشلة',
  };

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.filters.search ?? '');
    _type = widget.filters.type;
    _status = widget.filters.status;
    _dateFrom = widget.filters.dateFrom == null
        ? null
        : DateTime.tryParse(widget.filters.dateFrom!);
    _dateTo = widget.filters.dateTo == null
        ? null
        : DateTime.tryParse(widget.filters.dateTo!);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _apply() {
    widget.onApply(
      LedgerFilters(
        page: 1,
        perPage: widget.filters.perPage,
        type: _type,
        status: _status,
        search: _searchController.text.trim().isEmpty
            ? null
            : _searchController.text.trim(),
        dateFrom: _dateFrom == null ? null : AdminFormat.queryDate(_dateFrom!),
        dateTo: _dateTo == null ? null : AdminFormat.queryDate(_dateTo!),
      ),
    );
  }

  void _reset() {
    setState(() {
      _searchController.clear();
      _type = null;
      _status = null;
      _dateFrom = null;
      _dateTo = null;
    });
    widget.onReset();
  }

  Future<void> _pickDate({required bool isFrom}) async {
    final initial = (isFrom ? _dateFrom : _dateTo) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(DateTime.now().year + 2),
    );
    if (picked == null) return;
    setState(() {
      if (isFrom) {
        _dateFrom = picked;
      } else {
        _dateTo = picked;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AdminPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: 240,
                child: TextField(
                  controller: _searchController,
                  enabled: widget.enabled,
                  style: TextStyle(fontSize: 12.5, color: context.textPrimary),
                  decoration: const InputDecoration(
                    labelText: 'بحث (رقم مرجعي)',
                    prefixIcon: Icon(Icons.search_rounded, size: 18),
                    isDense: true,
                  ),
                  onSubmitted: (_) => _apply(),
                ),
              ),
              SizedBox(
                width: 200,
                child: DropdownButtonFormField<String?>(
                  initialValue: _type,
                  isDense: true,
                  decoration: const InputDecoration(
                    labelText: 'نوع الحركة',
                    isDense: true,
                  ),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('كل الأنواع'),
                    ),
                    for (final entry in _typeOptions.entries)
                      DropdownMenuItem<String?>(
                        value: entry.key,
                        child: Text(entry.value),
                      ),
                  ],
                  onChanged: widget.enabled
                      ? (value) => setState(() => _type = value)
                      : null,
                ),
              ),
              SizedBox(
                width: 180,
                child: DropdownButtonFormField<String?>(
                  initialValue: _status,
                  isDense: true,
                  decoration: const InputDecoration(
                    labelText: 'الحالة',
                    isDense: true,
                  ),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('كل الحالات'),
                    ),
                    for (final entry in _statusOptions.entries)
                      DropdownMenuItem<String?>(
                        value: entry.key,
                        child: Text(entry.value),
                      ),
                  ],
                  onChanged: widget.enabled
                      ? (value) => setState(() => _status = value)
                      : null,
                ),
              ),
              _DateFieldButton(
                label: 'من تاريخ',
                value: _dateFrom,
                enabled: widget.enabled,
                onTap: () => _pickDate(isFrom: true),
                onClear: () => setState(() => _dateFrom = null),
              ),
              _DateFieldButton(
                label: 'إلى تاريخ',
                value: _dateTo,
                enabled: widget.enabled,
                onTap: () => _pickDate(isFrom: false),
                onClear: () => setState(() => _dateTo = null),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: widget.enabled ? _apply : null,
                icon: const Icon(Icons.filter_alt_rounded, size: 16),
                label: const Text('تطبيق الفلاتر'),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: widget.enabled ? _reset : null,
                icon: const Icon(Icons.filter_alt_off_rounded, size: 16),
                label: const Text('إعادة تعيين'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DateFieldButton extends StatelessWidget {
  final String label;
  final DateTime? value;
  final bool enabled;
  final VoidCallback onTap;
  final VoidCallback onClear;

  const _DateFieldButton({
    required this.label,
    required this.value,
    required this.enabled,
    required this.onTap,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: enabled ? onTap : null,
      icon: const Icon(Icons.event_rounded, size: 16),
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value == null ? label : '$label: ${AdminFormat.date(value)}',
            style: const TextStyle(fontSize: 12),
          ),
          if (value != null) ...[
            const SizedBox(width: 4),
            InkWell(
              onTap: enabled ? onClear : null,
              child: Icon(Icons.close_rounded, size: 14, color: context.textMuted),
            ),
          ],
        ],
      ),
    );
  }
}
