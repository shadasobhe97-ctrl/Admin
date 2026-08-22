import 'package:flutter/material.dart';

import '../../../../core/utils/admin_theme_context.dart';

/// خيار جاهز لقائمة اختيار الأب (بلدية كبرى أو محلة).
class GeoParentOption {
  final int id;
  final String label;

  const GeoParentOption({required this.id, required this.label});
}

/// نوع العنصر الجغرافي الذي يحرّره النموذج.
enum GeoFormKind { municipality, subMunicipality, zone }

/// نموذج موحّد لإضافة وتعديل المستويات الجغرافية الثلاثة.
///
/// يرجع القيم عبر [onSubmit] فقط ولا ينفّذ أي استدعاء شبكة بنفسه.
class GeoFormDialog extends StatefulWidget {
  final GeoFormKind kind;

  /// الاسم الحالي عند التعديل، و`null` عند الإضافة.
  final String? initialName;

  /// معرّف الأب المختار مسبقاً (البلدية الكبرى أو المحلة).
  final int? initialParentId;

  /// خيارات الأب المتاحة؛ فارغة إذا كان المستوى بلا أب.
  final List<GeoParentOption> parentOptions;

  final void Function(String name, int? parentId) onSubmit;

  const GeoFormDialog({
    super.key,
    required this.kind,
    this.initialName,
    this.initialParentId,
    this.parentOptions = const [],
    required this.onSubmit,
  });

  @override
  State<GeoFormDialog> createState() => _GeoFormDialogState();
}

class _GeoFormDialogState extends State<GeoFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  int? _selectedParentId;

  bool get _isEditing => widget.initialName != null;

  /// البلدية الفرعية تتطلب بلدية كبرى، بينما `sub_municipality_id` اختياري
  /// للمنطقة الدقيقة حسب العقد.
  bool get _isParentRequired =>
      widget.kind == GeoFormKind.subMunicipality ||
      (widget.kind == GeoFormKind.zone && widget.parentOptions.isNotEmpty);

  bool get _hasParentField => widget.kind != GeoFormKind.municipality;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName ?? '');

    final hasMatchingOption = widget.parentOptions
        .any((option) => option.id == widget.initialParentId);
    _selectedParentId = hasMatchingOption
        ? widget.initialParentId
        : (widget.parentOptions.length == 1 ? widget.parentOptions.first.id : null);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  String get _title {
    switch (widget.kind) {
      case GeoFormKind.municipality:
        return _isEditing ? 'تعديل البلدية الكبرى' : 'إضافة بلدية كبرى جديدة';
      case GeoFormKind.subMunicipality:
        return _isEditing
            ? 'تعديل البلدية الفرعية'
            : 'إضافة بلدية فرعية (محلة) جديدة';
      case GeoFormKind.zone:
        return _isEditing ? 'تعديل المنطقة الدقيقة' : 'إضافة منطقة دقيقة جديدة';
    }
  }

  String get _nameLabel {
    switch (widget.kind) {
      case GeoFormKind.municipality:
        return 'اسم البلدية الكبرى';
      case GeoFormKind.subMunicipality:
        return 'اسم البلدية الفرعية / المحلة';
      case GeoFormKind.zone:
        return 'اسم المنطقة الدقيقة';
    }
  }

  String get _nameHint {
    switch (widget.kind) {
      case GeoFormKind.municipality:
        return 'مثال: طرابلس الكبرى';
      case GeoFormKind.subMunicipality:
        return 'مثال: محلة قرقارش';
      case GeoFormKind.zone:
        return 'مثال: حي الأندلس';
    }
  }

  String get _parentLabel => widget.kind == GeoFormKind.subMunicipality
      ? 'البلدية الكبرى التابعة لها'
      : 'البلدية الفرعية التابعة لها';

  String? _validateName(String? value) {
    final name = value?.trim() ?? '';
    if (name.isEmpty) return 'يرجى إدخال الاسم';
    // قيود العقد على اسم المنطقة الدقيقة.
    if (widget.kind == GeoFormKind.zone) {
      if (name.length < 3) return 'الاسم يجب ألا يقل عن 3 أحرف';
      if (name.length > 100) return 'الاسم يجب ألا يتجاوز 100 حرف';
    }
    return null;
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_isParentRequired && _selectedParentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.kind == GeoFormKind.subMunicipality
                ? 'يرجى اختيار البلدية الكبرى التابعة لها'
                : 'يرجى اختيار البلدية الفرعية / المحلة التابعة لها',
          ),
          backgroundColor: context.dangerColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    widget.onSubmit(_nameController.text.trim(), _selectedParentId);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        backgroundColor: context.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          _title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: context.textPrimary,
          ),
        ),
        content: SizedBox(
          width: 420,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  autofocus: true,
                  style: TextStyle(fontSize: 13, color: context.textPrimary),
                  decoration: InputDecoration(
                    labelText: _nameLabel,
                    hintText: _nameHint,
                  ),
                  validator: _validateName,
                  onFieldSubmitted: (_) => _submit(),
                ),
                if (_hasParentField) ...[
                  const SizedBox(height: 14),
                  DropdownButtonFormField<int?>(
                    initialValue: (widget.parentOptions.any((o) => o.id == _selectedParentId) || (!_isParentRequired && _selectedParentId == null))
                        ? _selectedParentId
                        : null,
                    isExpanded: true,
                    dropdownColor: context.cardColor,
                    style: TextStyle(fontSize: 13, color: context.textPrimary),
                    decoration: InputDecoration(labelText: _parentLabel),
                    items: [
                      if (!_isParentRequired)
                        DropdownMenuItem<int?>(
                          value: null,
                          child: Text(
                            'بدون — غير مرتبطة بمحلة',
                            style: TextStyle(
                              fontSize: 12,
                              color: context.textMuted,
                            ),
                          ),
                        ),
                      ...widget.parentOptions.map(
                        (option) => DropdownMenuItem<int?>(
                          value: option.id,
                          child: Text(
                            option.label,
                            style: const TextStyle(fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                    onChanged: (value) =>
                        setState(() => _selectedParentId = value),
                  ),
                ],
              ],
            ),
          ),
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: context.primaryColor,
              foregroundColor: context.onPrimary,
            ),
            onPressed: _submit,
            icon: const Icon(Icons.check_rounded, size: 16),
            label: Text(_isEditing ? 'حفظ التعديل' : 'إضافة'),
          ),
        ],
      ),
    );
  }
}
