import 'package:flutter/material.dart';

import '../../../../core/utils/admin_theme_context.dart';
import '../../../../core/widgets/admin_ui.dart';
import '../../data/models/audit_dictionaries.dart';
import '../../data/models/audit_log_filters.dart';

/// شريط فلاتر السجل — كل الفلاتر تُطبَّق على الخادم، بلا فلترة محلية.
class AuditLogFilterBar extends StatefulWidget {
  final AuditLogFilters filters;
  final bool enabled;
  final ValueChanged<String?> onSearch;
  final ValueChanged<String?> onActionGroupChanged;
  final ValueChanged<String?> onEntityTypeChanged;
  final void Function(DateTime from, DateTime to) onDateRangeSelected;
  final VoidCallback onDateRangeCleared;
  final VoidCallback onClearAll;

  const AuditLogFilterBar({
    super.key,
    required this.filters,
    required this.onSearch,
    required this.onActionGroupChanged,
    required this.onEntityTypeChanged,
    required this.onDateRangeSelected,
    required this.onDateRangeCleared,
    required this.onClearAll,
    this.enabled = true,
  });

  @override
  State<AuditLogFilterBar> createState() => _AuditLogFilterBarState();
}

class _AuditLogFilterBarState extends State<AuditLogFilterBar> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.filters.search ?? '');
    // بدون هذا المستمع لا يظهر زر المسح ولا يتحدّث زر البحث أثناء الكتابة.
    _searchController.addListener(_onSearchTextChanged);
  }

  @override
  void didUpdateWidget(covariant AuditLogFilterBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // مزامنة الحقل عند تغيير البحث من خارج الشريط (إلغاء كل الفلاتر مثلاً).
    final incoming = widget.filters.search ?? '';
    if (incoming != (oldWidget.filters.search ?? '') &&
        incoming != _searchController.text) {
      _searchController.text = incoming;
    }
  }

  void _onSearchTextChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchTextChanged);
    _searchController.dispose();
    super.dispose();
  }

  /// نفس السلوك سواء ضغط المستخدم Enter أو زر البحث.
  void _submitSearch() {
    final query = _searchController.text.trim();
    widget.onSearch(query.isEmpty ? null : query);
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 1, 12, 31),
      initialDateRange: widget.filters.hasDateRange
          ? DateTimeRange(
              start: widget.filters.dateFrom!,
              end: widget.filters.dateTo!,
            )
          : null,
      builder: (dialogContext, child) => Directionality(
        textDirection: TextDirection.rtl,
        child: child ?? const SizedBox.shrink(),
      ),
    );

    if (picked != null) widget.onDateRangeSelected(picked.start, picked.end);
  }

  @override
  Widget build(BuildContext context) {
    final filters = widget.filters;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                enabled: widget.enabled,
                style: TextStyle(fontSize: 13, color: context.textPrimary),
                decoration: InputDecoration(
                  isDense: true,
                  hintText: 'بحث باسم المشرف أو العنصر أو السبب…',
                  hintStyle: TextStyle(
                    fontSize: 12,
                    color: context.textTertiary,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    size: 18,
                    color: context.textTertiary,
                  ),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_searchController.text.isNotEmpty)
                        IconButton(
                          tooltip: 'مسح البحث',
                          icon: Icon(
                            Icons.close_rounded,
                            size: 17,
                            color: context.dangerColor,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            widget.onSearch(null);
                          },
                        ),
                      // زر بحث صريح — لا يعتمد المستخدم على Enter وحده.
                      IconButton(
                        tooltip: 'تنفيذ البحث',
                        icon: Icon(
                          Icons.arrow_circle_left_rounded,
                          size: 20,
                          color: widget.enabled
                              ? context.primaryColor
                              : context.textTertiary,
                        ),
                        onPressed: widget.enabled ? _submitSearch : null,
                      ),
                    ],
                  ),
                ),
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => _submitSearch(),
              ),
            ),
            const SizedBox(width: 10),
            _FilterDropdown(
              hint: 'كل الأنواع',
              value: filters.actionGroup,
              enabled: widget.enabled,
              icon: Icons.category_rounded,
              items: {
                for (final group in AuditActionGroup.all)
                  group: AuditActionGroup.label(group),
              },
              onChanged: widget.onActionGroupChanged,
            ),
            const SizedBox(width: 10),
            _FilterDropdown(
              hint: 'كل العناصر',
              value: filters.entityType,
              enabled: widget.enabled,
              icon: Icons.adjust_rounded,
              items: {
                for (final type in AuditEntityType.filterable)
                  type: AuditEntityType.label(type),
              },
              onChanged: widget.onEntityTypeChanged,
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: widget.enabled ? _pickDateRange : null,
              icon: const Icon(Icons.date_range_rounded, size: 16),
              label: Text(
                filters.hasDateRange
                    ? '${AdminFormat.queryDate(filters.dateFrom!)}  ←  ${AdminFormat.queryDate(filters.dateTo!)}'
                    : 'نطاق تاريخ',
                style: const TextStyle(fontSize: 11.5),
              ),
            ),
            if (filters.hasDateRange) ...[
              const SizedBox(width: 4),
              IconButton(
                tooltip: 'إلغاء نطاق التاريخ',
                onPressed:
                    widget.enabled ? widget.onDateRangeCleared : null,
                icon: Icon(
                  Icons.close_rounded,
                  size: 16,
                  color: context.dangerColor,
                ),
              ),
            ],
            const Spacer(),
            if (filters.hasActiveFilters)
              TextButton.icon(
                onPressed: widget.enabled
                    ? () {
                        _searchController.clear();
                        widget.onClearAll();
                      }
                    : null,
                icon: const Icon(Icons.filter_alt_off_rounded, size: 16),
                label: const Text(
                  'إلغاء كل الفلاتر',
                  style: TextStyle(fontSize: 11.5),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  final String hint;
  final String? value;
  final bool enabled;
  final IconData icon;
  final Map<String, String> items;
  final ValueChanged<String?> onChanged;

  const _FilterDropdown({
    required this.hint,
    required this.value,
    required this.enabled,
    required this.icon,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: context.surfaceVariant,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: context.borderSoft),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: value,
          isDense: true,
          dropdownColor: context.cardColor,
          icon: Icon(icon, size: 16, color: context.textTertiary),
          style: TextStyle(fontSize: 12, color: context.textPrimary),
          hint: Text(
            hint,
            style: TextStyle(fontSize: 12, color: context.textMuted),
          ),
          items: [
            DropdownMenuItem<String?>(
              value: null,
              child: Text(
                hint,
                style: TextStyle(fontSize: 12, color: context.textMuted),
              ),
            ),
            ...items.entries.map(
              (entry) => DropdownMenuItem<String?>(
                value: entry.key,
                child: Text(
                  entry.value,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ),
          ],
          onChanged: enabled ? onChanged : null,
        ),
      ),
    );
  }
}
