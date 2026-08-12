import 'package:flutter/material.dart';

import '../../../../core/utils/admin_theme_context.dart';
import '../../../zones/data/models/zone_model.dart';
import '../../data/models/school_model.dart';
import '../../data/models/school_payload.dart';
import 'school_location_picker_dialog.dart';

/// نموذج إضافة وتعديل مدرسة.
///
/// يبني حمولة مُصنَّفة عبر [CreateSchoolPayload] / [UpdateSchoolPayload]
/// ولا يبني أي Map خام ولا ينفّذ أي استدعاء شبكة.
class SchoolFormDialog extends StatefulWidget {
  final SchoolModel? school;
  final List<ZoneModel> zones;
  final void Function(CreateSchoolPayload payload)? onCreate;
  final void Function(UpdateSchoolPayload payload)? onUpdate;

  const SchoolFormDialog({
    super.key,
    this.school,
    required this.zones,
    this.onCreate,
    this.onUpdate,
  });

  @override
  State<SchoolFormDialog> createState() => _SchoolFormDialogState();
}

class _SchoolFormDialogState extends State<SchoolFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _addressController;

  double? _selectedLat;
  double? _selectedLng;

  int? _selectedZoneId;
  late String _selectedStatus;

  bool get _isEditing => widget.school != null;

  @override
  void initState() {
    super.initState();
    final school = widget.school;

    _nameController = TextEditingController(text: school?.name ?? '');
    _addressController = TextEditingController(text: school?.address ?? '');
    
    _selectedLat = school?.lat;
    _selectedLng = school?.lng;

    _selectedStatus = school?.status ?? SchoolStatus.approved;

    final zoneExists = widget.zones.any((zone) => zone.id == school?.zoneId);
    _selectedZoneId = zoneExists ? school!.zoneId : null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_selectedZoneId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('يرجى اختيار المنطقة الجغرافية المرتبطة بالمدرسة'),
          backgroundColor: context.dangerColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_selectedLat == null || _selectedLng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('يرجى تحديد موقع المدرسة على الخريطة'),
          backgroundColor: context.dangerColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final lat = _selectedLat!;
    final lng = _selectedLng!;
    final name = _nameController.text.trim();
    final address = _addressController.text.trim();

    final school = widget.school;
    if (school == null) {
      widget.onCreate?.call(
        CreateSchoolPayload(
          name: name,
          lat: lat,
          lng: lng,
          address: address,
          zoneId: _selectedZoneId!,
        ),
      );
    } else {
      widget.onUpdate?.call(
        UpdateSchoolPayload.diff(
          original: school,
          name: name,
          lat: lat,
          lng: lng,
          address: address,
          zoneId: _selectedZoneId!,
          status: _selectedStatus,
        ),
      );
    }

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
          _isEditing
              ? 'تعديل مدرسة: ${widget.school!.name}'
              : 'إضافة مدرسة جديدة للنظام',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: context.textPrimary,
          ),
        ),
        content: SizedBox(
          width: 460,
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _nameController,
                    autofocus: true,
                    maxLength: SchoolValidation.nameMaxLength,
                    style: TextStyle(fontSize: 13, color: context.textPrimary),
                    decoration: const InputDecoration(
                      labelText: 'اسم المدرسة الرسمي',
                      hintText: 'مثال: مدرسة الجيل الجديد الأهلية',
                      counterText: '',
                    ),
                    validator: SchoolValidation.validateName,
                  ),
                  const SizedBox(height: 14),

                  TextFormField(
                    controller: _addressController,
                    maxLength: SchoolValidation.addressMaxLength,
                    style: TextStyle(fontSize: 13, color: context.textPrimary),
                    decoration: const InputDecoration(
                      labelText: 'العنوان التفصيلي',
                      hintText: 'مثال: طرابلس - حي الأندلس بالقرب من الشارع الرئيسي',
                      counterText: '',
                    ),
                    validator: SchoolValidation.validateAddress,
                  ),
                  const SizedBox(height: 14),

                  // المنطقة الجغرافية مطلوبة — `zone_id` إجباري في العقد.
                  DropdownButtonFormField<int>(
                    initialValue: _selectedZoneId,
                    isExpanded: true,
                    dropdownColor: context.cardColor,
                    style: TextStyle(fontSize: 13, color: context.textPrimary),
                    decoration: const InputDecoration(
                      labelText: 'المنطقة الجغرافية المرتبطة',
                    ),
                    items: widget.zones
                        .map(
                          (zone) => DropdownMenuItem<int>(
                            value: zone.id,
                            child: Text(
                              zone.name.isNotEmpty
                                  ? zone.name
                                  : 'منطقة #${zone.id}',
                              style: const TextStyle(fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _selectedZoneId = value),
                    validator: (value) =>
                        value == null ? 'يرجى اختيار المنطقة الجغرافية' : null,
                  ),
                  const SizedBox(height: 14),

                  // ─── Map Location Picker ───
                  InkWell(
                    onTap: () async {
                      final point = await SchoolLocationPickerDialog.show(
                        context,
                        initialLat: _selectedLat,
                        initialLng: _selectedLng,
                      );
                      if (point != null) {
                        setState(() {
                          _selectedLat = point.latitude;
                          _selectedLng = point.longitude;
                        });
                      }
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _selectedLat == null
                              ? context.dangerColor
                              : context.theme.colorScheme.outlineVariant,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.map_rounded,
                            color: context.primaryColor,
                            size: 28,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'الموقع الجغرافي',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: context.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                if (_selectedLat != null && _selectedLng != null)
                                  Text(
                                    'تم التحديد: ${_selectedLat!.toStringAsFixed(5)}, ${_selectedLng!.toStringAsFixed(5)}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: context.primaryColor,
                                      fontFamily: 'monospace',
                                    ),
                                  )
                                else
                                  Text(
                                    'انقر لاختيار الموقع من الخريطة',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: context.dangerColor,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 16,
                            color: context.theme.colorScheme.onSurfaceVariant,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // حالة الاعتماد يقبلها الخادم في التعديل فقط.
                  if (_isEditing) ...[
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedStatus,
                      isExpanded: true,
                      dropdownColor: context.cardColor,
                      style: TextStyle(fontSize: 13, color: context.textPrimary),
                      decoration: const InputDecoration(
                        labelText: 'حالة اعتماد المدرسة',
                      ),
                      items: SchoolStatus.all
                          .map(
                            (status) => DropdownMenuItem<String>(
                              value: status,
                              child: Text(
                                SchoolStatus.label(status),
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) => setState(
                        () => _selectedStatus = value ?? _selectedStatus,
                      ),
                    ),
                  ],
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
              backgroundColor: context.primaryColor,
              foregroundColor: context.onPrimary,
            ),
            onPressed: _submit,
            icon: const Icon(Icons.check_rounded, size: 16),
            label: Text(_isEditing ? 'حفظ التغييرات' : 'إضافة المدرسة'),
          ),
        ],
      ),
    );
  }
}
