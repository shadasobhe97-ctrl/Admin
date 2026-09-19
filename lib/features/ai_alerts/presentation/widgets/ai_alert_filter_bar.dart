import 'package:flutter/material.dart';
import '../../../../core/utils/admin_theme_context.dart';

class AiAlertFilterBar extends StatefulWidget {
  final String selectedRiskLevel;
  final ValueChanged<String> onRiskLevelChanged;
  final bool? selectedIsResolved;
  final ValueChanged<bool?> onResolvedChanged;
  final int? selectedDriverId;
  final ValueChanged<int> onDriverIdApplied;
  final VoidCallback onClearDriverFilter;

  const AiAlertFilterBar({
    super.key,
    required this.selectedRiskLevel,
    required this.onRiskLevelChanged,
    required this.selectedIsResolved,
    required this.onResolvedChanged,
    required this.selectedDriverId,
    required this.onDriverIdApplied,
    required this.onClearDriverFilter,
  });

  @override
  State<AiAlertFilterBar> createState() => _AiAlertFilterBarState();
}

class _AiAlertFilterBarState extends State<AiAlertFilterBar> {
  late final TextEditingController _driverIdController;

  @override
  void initState() {
    super.initState();
    _driverIdController = TextEditingController(
      text: widget.selectedDriverId?.toString() ?? '',
    );
  }

  @override
  void didUpdateWidget(AiAlertFilterBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedDriverId == null && _driverIdController.text.isNotEmpty) {
      _driverIdController.clear();
    }
  }

  @override
  void dispose() {
    _driverIdController.dispose();
    super.dispose();
  }

  void _submitDriverId(String value) {
    final id = int.tryParse(value.trim());
    if (id != null) widget.onDriverIdApplied(id);
  }

  @override
  Widget build(BuildContext context) {
    final riskItems = [
      {'key': 'all', 'label': 'كل المستويات'},
      {'key': 'CRITICAL', 'label': 'حرج'},
      {'key': 'HIGH', 'label': 'مرتفع'},
    ];

    final resolvedItems = [
      {'key': null, 'label': 'الكل'},
      {'key': false, 'label': 'قيد المتابعة'},
      {'key': true, 'label': 'تم الحل'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...riskItems.map((item) {
              final key = item['key'] as String;
              final label = item['label'] as String;
              final isSelected = widget.selectedRiskLevel == key;
              return ChoiceChip(
                label: Text(label),
                selected: isSelected,
                onSelected: (_) => widget.onRiskLevelChanged(key),
                selectedColor: context.primaryColor,
                backgroundColor: context.surfaceVariant,
                side: BorderSide(
                  color: isSelected ? context.primaryColor : context.borderSoft,
                ),
                labelStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? context.onPrimary : context.textSecondary,
                ),
              );
            }),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            ...resolvedItems.map((item) {
              final key = item['key'] as bool?;
              final label = item['label'] as String;
              final isSelected = widget.selectedIsResolved == key;
              return ChoiceChip(
                label: Text(label),
                selected: isSelected,
                onSelected: (_) => widget.onResolvedChanged(key),
                selectedColor: context.primaryColor.withValues(alpha: 0.85),
                backgroundColor: context.surfaceVariant,
                side: BorderSide(
                  color: isSelected ? context.primaryColor : context.borderSoft,
                ),
                labelStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? context.onPrimary : context.textSecondary,
                ),
              );
            }),
            SizedBox(
              width: 160,
              child: TextField(
                controller: _driverIdController,
                keyboardType: TextInputType.number,
                onSubmitted: _submitDriverId,
                style: TextStyle(fontSize: 12, color: context.textPrimary),
                decoration: InputDecoration(
                  isDense: true,
                  hintText: 'رقم السائق (driver_id)',
                  hintStyle: TextStyle(fontSize: 11.5, color: context.textMuted),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  filled: true,
                  fillColor: context.surfaceVariant,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: context.borderSoft),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: context.borderSoft),
                  ),
                  suffixIcon: widget.selectedDriverId != null
                      ? IconButton(
                          tooltip: 'إزالة فلتر السائق',
                          icon: Icon(Icons.close_rounded,
                              size: 16, color: context.textMuted),
                          onPressed: () {
                            _driverIdController.clear();
                            widget.onClearDriverFilter();
                          },
                        )
                      : IconButton(
                          tooltip: 'تطبيق',
                          icon: Icon(Icons.search_rounded,
                              size: 16, color: context.primaryColor),
                          onPressed: () =>
                              _submitDriverId(_driverIdController.text),
                        ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
