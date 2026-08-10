import 'package:flutter/material.dart';
import '../../../schools/data/models/zone_model.dart';

class ZoneFormDialog extends StatefulWidget {
  final ZoneModel? zone;
  final int? initialParentId;
  final List<ZoneModel> availableZones;
  final Function(Map<String, dynamic> payload) onSubmit;

  const ZoneFormDialog({
    super.key,
    this.zone,
    this.initialParentId,
    required this.availableZones,
    required this.onSubmit,
  });

  @override
  State<ZoneFormDialog> createState() => _ZoneFormDialogState();
}

class _ZoneFormDialogState extends State<ZoneFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  int? _selectedParentId;

  bool get isEditing => widget.zone != null;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.zone?.name ?? '');

    if (isEditing) {
      _selectedParentId = widget.zone?.parentId;
    } else {
      _selectedParentId = widget.initialParentId;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final payload = <String, dynamic>{
        'name': _nameCtrl.text.trim(),
      };

      if (!isEditing) {
        payload['parent_id'] = _selectedParentId;
      } else {
        if (_selectedParentId != null) {
          payload['parent_id'] = _selectedParentId;
        }
      }

      widget.onSubmit(payload);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Filter out the editing zone itself to prevent self-parenting loop
    final parentOptions = widget.availableZones
        .where((z) => !isEditing || z.id != widget.zone!.id)
        .toList();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        backgroundColor: theme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          isEditing ? 'تعديل المنطقة: ${widget.zone!.name}' : 'إضافة منطقة جغرافية جديدة',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        content: SizedBox(
          width: 400,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameCtrl,
                  style: theme.textTheme.bodyLarge,
                  decoration: const InputDecoration(
                    labelText: 'اسم المنطقة الجغرافية',
                    hintText: 'مثال: منطقة عين زارة',
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'يرجى إدخال اسم المنطقة';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // Parent Zone Selection (Dynamic list from Backend /api/admin/zones)
                DropdownButtonFormField<int?>(
                  initialValue: _selectedParentId,
                  dropdownColor: theme.cardColor,
                  style: theme.textTheme.bodyMedium,
                  decoration: const InputDecoration(
                    labelText: 'المنطقة الأب (اختياري)',
                  ),
                  items: [
                    const DropdownMenuItem<int?>(
                      value: null,
                      child: Text('بدون — منطقة رئيسية'),
                    ),
                    ...parentOptions.map((z) {
                      return DropdownMenuItem<int?>(
                        value: z.id,
                        child: Text(
                          z.name.isNotEmpty ? z.name : 'منطقة #${z.id}',
                        ),
                      );
                    }),
                  ],
                  onChanged: (val) {
                    setState(() {
                      _selectedParentId = val;
                    });
                  },
                ),
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
              backgroundColor: isEditing
                  ? theme.colorScheme.secondary
                  : theme.colorScheme.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: _submit,
            icon: const Icon(Icons.check_rounded, size: 16),
            label: Text(isEditing ? 'حفظ التعديل' : 'إضافة المنطقة'),
          ),
        ],
      ),
    );
  }
}
