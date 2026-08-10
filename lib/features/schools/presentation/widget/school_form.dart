import 'package:flutter/material.dart';
import '../../data/models/school_model.dart';
import '../../data/models/zone_model.dart';

class SchoolFormDialog extends StatefulWidget {
  final SchoolModel? school;
  final List<ZoneModel> zones;
  final Function(Map<String, dynamic> payload) onSubmit;

  const SchoolFormDialog({
    super.key,
    this.school,
    required this.zones,
    required this.onSubmit,
  });

  @override
  State<SchoolFormDialog> createState() => _SchoolFormDialogState();
}

class _SchoolFormDialogState extends State<SchoolFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _latCtrl;
  late final TextEditingController _lngCtrl;
  int? _selectedZoneId;

  bool get isEditing => widget.school != null;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.school?.name ?? '');
    _addressCtrl = TextEditingController(text: widget.school?.address ?? '');
    _latCtrl = TextEditingController(
      text: widget.school?.latitude?.toString() ?? '32.890000',
    );
    _lngCtrl = TextEditingController(
      text: widget.school?.longitude?.toString() ?? '13.180000',
    );

    if (widget.school?.zoneId != null) {
      _selectedZoneId = widget.school!.zoneId;
    } else if (widget.zones.isNotEmpty) {
      _selectedZoneId = widget.zones.first.id;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _latCtrl.dispose();
    _lngCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final payload = <String, dynamic>{
        'name': _nameCtrl.text.trim(),
        'address': _addressCtrl.text.trim(),
      };

      final lat = double.tryParse(_latCtrl.text.trim());
      if (lat != null) payload['latitude'] = lat;

      final lng = double.tryParse(_lngCtrl.text.trim());
      if (lng != null) payload['longitude'] = lng;

      if (_selectedZoneId != null) {
        payload['zone_id'] = _selectedZoneId;
      }

      widget.onSubmit(payload);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        backgroundColor: theme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          isEditing ? 'تعديل مدرسة: ${widget.school!.name}' : 'إضافة مدرسة جديدة للنظام',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        content: SizedBox(
          width: 440,
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _nameCtrl,
                    style: theme.textTheme.bodyLarge,
                    decoration: const InputDecoration(
                      labelText: 'اسم المدرسة الرسمي',
                      hintText: 'مثال: مدرسة الأمل النموذجية',
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'يرجى إدخال اسم المدرسة';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _addressCtrl,
                    style: theme.textTheme.bodyLarge,
                    decoration: const InputDecoration(
                      labelText: 'العنوان الجغرافي (المنطقة والشارع)',
                      hintText: 'مثال: حي الأندلس، طرابلس',
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'يرجى إدخال عنوان المدرسة';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  // Zone Selection (Loaded from Backend /api/admin/zones)
                  DropdownButtonFormField<int>(
                    initialValue: _selectedZoneId,
                    dropdownColor: theme.cardColor,
                    style: theme.textTheme.bodyMedium,
                    decoration: const InputDecoration(
                      labelText: 'المنطقة الجغرافية',
                    ),
                    items: widget.zones.map((zone) {
                      return DropdownMenuItem<int>(
                        value: zone.id,
                        child: Text(
                          zone.name.isNotEmpty ? zone.name : 'منطقة #${zone.id}',
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedZoneId = val;
                      });
                    },
                  ),
                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _latCtrl,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          style: theme.textTheme.bodyLarge,
                          decoration: const InputDecoration(
                            labelText: 'دائرة العرض (Latitude)',
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: _lngCtrl,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          style: theme.textTheme.bodyLarge,
                          decoration: const InputDecoration(
                            labelText: 'خط الطول (Longitude)',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
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
            label: Text(isEditing ? 'حفظ التغييرات' : 'إضافة المدرسة'),
          ),
        ],
      ),
    );
  }
}
