import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/utils/admin_theme_context.dart';
import '../../data/models/driver_details_model.dart';
import '../../data/models/driver_document_model.dart';
import '../../data/models/driver_model.dart';
import '../../data/models/update_driver_payload.dart';
import 'driver_file_field.dart';

/// نموذج تعديل بيانات السائق الكاملة.
///
/// يغطّي الأقسام الثلاثة التي يقبلها `PUT /admin/drivers/{id}`:
/// بيانات الحساب، بيانات المركبة، وتواريخ الوثائق وملفاتها.
/// يبني حمولة مُصنَّفة عبر [UpdateDriverPayload] ولا ينفّذ أي استدعاء شبكة —
/// يعيدها للشاشة لتمرّرها إلى الـ Cubit.
class DriverEditDialog extends StatefulWidget {
  final DriverModel driver;

  /// تفاصيل السائق الكاملة — مصدر بيانات المركبة والوثائق الحالية.
  final DriverDetailsModel? details;

  /// `true` عند فتح النموذج ضمن تدفّق المراجعة قبل الاعتماد.
  final bool isReviewFlow;

  const DriverEditDialog({
    super.key,
    required this.driver,
    this.details,
    this.isReviewFlow = false,
  });

  @override
  State<DriverEditDialog> createState() => _DriverEditDialogState();
}

class _DriverEditDialogState extends State<DriverEditDialog> {
  final _formKey = GlobalKey<FormState>();

  // بيانات الحساب
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _nationalIdController;
  late final TextEditingController _licenseNumberController;
  late final TextEditingController _licenseExpiryController;
  late final TextEditingController _reasonController;

  // بيانات المركبة
  late final TextEditingController _plateController;
  late final TextEditingController _brandController;
  late final TextEditingController _modelController;
  late final TextEditingController _colorController;
  late final TextEditingController _typeController;
  late final TextEditingController _yearController;
  late final TextEditingController _capacityController;

  // تواريخ الوثائق
  late final TextEditingController _insuranceExpiryController;
  late final TextEditingController _stampExpiryController;
  late final TextEditingController _technicalExpiryController;

  late bool _isActive;
  late String? _status;
  bool? _hasAc;

  PickedUpload? _vehicleImage;
  final Map<String, PickedUpload> _documents = {};

  @override
  void initState() {
    super.initState();
    final driver = widget.driver;
    final vehicle = widget.details?.vehicle;
    final docs = widget.details?.documents ?? const [];

    /// أول تاريخ غير فارغ من نوع معيّن عبر كل الوثائق.
    String firstDate(String? Function(DriverDocumentModel doc) pick) {
      for (final DriverDocumentModel doc in docs) {
        final value = pick(doc);
        if (value != null && value.isNotEmpty) return value;
      }
      return '';
    }

    _nameController = TextEditingController(text: driver.fullName);
    _phoneController = TextEditingController(text: driver.phoneNumber);
    _nationalIdController = TextEditingController(text: driver.nationalId ?? '');
    _licenseNumberController =
        TextEditingController(text: driver.licenseNumber ?? '');
    _licenseExpiryController =
        TextEditingController(text: driver.licenseExpiry ?? '');
    _reasonController = TextEditingController();

    _plateController =
        TextEditingController(text: _cleanValue(vehicle?.plateNumber));
    _brandController = TextEditingController(text: _cleanValue(vehicle?.brand));
    _modelController = TextEditingController(text: _cleanValue(vehicle?.model));
    _colorController = TextEditingController(text: _cleanValue(vehicle?.color));
    _typeController = TextEditingController(text: _cleanValue(vehicle?.type));
    _yearController = TextEditingController(text: _cleanValue(vehicle?.year));
    _capacityController =
        TextEditingController(text: vehicle?.capacity?.toString() ?? '');

    _insuranceExpiryController =
        TextEditingController(text: firstDate((doc) => doc.insuranceExpiry));
    _stampExpiryController =
        TextEditingController(text: firstDate((doc) => doc.stampExpiry));
    _technicalExpiryController = TextEditingController(
      text: firstDate((doc) => doc.technicalInspectionExpiry),
    );

    _isActive = driver.isActive;
    _status = DriverStatusValue.normalize(driver.status);
    _hasAc = vehicle?.hasAc;
  }

  /// الخادم يرسل «غير محدد» بدل القيمة الفارغة، فلا تُعرض كنص قابل للحفظ.
  String _cleanValue(String? value) {
    final text = value?.trim() ?? '';
    return text == 'غير محدد' ? '' : text;
  }

  @override
  void dispose() {
    for (final controller in [
      _nameController,
      _phoneController,
      _nationalIdController,
      _licenseNumberController,
      _licenseExpiryController,
      _reasonController,
      _plateController,
      _brandController,
      _modelController,
      _colorController,
      _typeController,
      _yearController,
      _capacityController,
      _insuranceExpiryController,
      _stampExpiryController,
      _technicalExpiryController,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _pickDate(TextEditingController controller) async {
    final now = DateTime.now();
    final current = DateTime.tryParse(controller.text.trim());

    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? now,
      firstDate: DateTime(now.year - 10),
      lastDate: DateTime(now.year + 20),
      builder: (dialogContext, child) => Directionality(
        textDirection: TextDirection.rtl,
        child: child ?? const SizedBox.shrink(),
      ),
    );

    if (picked != null) {
      controller.text = '${picked.year.toString().padLeft(4, '0')}-'
          '${picked.month.toString().padLeft(2, '0')}-'
          '${picked.day.toString().padLeft(2, '0')}';
    }
  }

  /// يختار صورة ويقرأ بايتاتها — القراءة كبايتات تعمل على الويب والمكتب معاً.
  Future<PickedUpload?> _pickImage() async {
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 85,
      );
      if (picked == null) return null;

      final bytes = await picked.readAsBytes();
      return PickedUpload(bytes: bytes, fileName: picked.name);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تعذر اختيار الصورة: $e')),
        );
      }
      return null;
    }
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final payload = UpdateDriverPayload.diff(
      original: widget.driver,
      details: widget.details,
      reason: _reasonController.text,
      fullName: _nameController.text,
      phoneNumber: _phoneController.text,
      nationalId: _nationalIdController.text,
      licenseNumber: _licenseNumberController.text,
      licenseExpiry: _licenseExpiryController.text,
      status: _status,
      isActive: _isActive,
      plateNumber: _plateController.text,
      brand: _brandController.text,
      model: _modelController.text,
      color: _colorController.text,
      vehicleType: _typeController.text,
      year: _yearController.text,
      capacityManual: _capacityController.text,
      hasAc: _hasAc,
      vehicleImage: _vehicleImage,
      insuranceExpiry: _insuranceExpiryController.text,
      stampExpiry: _stampExpiryController.text,
      technicalInspectionExpiry: _technicalExpiryController.text,
      documents: Map.unmodifiable(_documents),
    );

    Navigator.of(context).pop(payload);
  }

  @override
  Widget build(BuildContext context) {
    final vehicle = widget.details?.vehicle;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        backgroundColor: context.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'تعديل بيانات السائق',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: context.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.driver.fullName,
              style: TextStyle(fontSize: 12.5, color: context.primaryColor),
            ),
          ],
        ),
        content: SizedBox(
          width: 560,
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.isReviewFlow) ...[
                    const _ReviewNotice(),
                    const SizedBox(height: 16),
                  ],

                  // ── بيانات الحساب ──────────────────────────────────────
                  const _SectionTitle(
                    icon: Icons.person_outline_rounded,
                    title: 'بيانات السائق والحساب',
                  ),
                  TextFormField(
                    controller: _nameController,
                    maxLength: DriverValidation.nameMaxLength,
                    style: TextStyle(fontSize: 13, color: context.textPrimary),
                    decoration: const InputDecoration(
                      labelText: 'الاسم الكامل',
                      counterText: '',
                    ),
                    validator: DriverValidation.validateFullName,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    maxLength: 10,
                    style: TextStyle(fontSize: 13, color: context.textPrimary),
                    decoration: const InputDecoration(
                      labelText: 'رقم الهاتف',
                      hintText: '09XXXXXXXX',
                      counterText: '',
                    ),
                    validator: DriverValidation.validatePhone,
                  ),
                  const SizedBox(height: 14),
                  _TwoColumn(
                    first: TextFormField(
                      controller: _nationalIdController,
                      keyboardType: TextInputType.number,
                      style:
                          TextStyle(fontSize: 13, color: context.textPrimary),
                      decoration:
                          const InputDecoration(labelText: 'الرقم الوطني'),
                    ),
                    second: TextFormField(
                      controller: _licenseNumberController,
                      style:
                          TextStyle(fontSize: 13, color: context.textPrimary),
                      decoration:
                          const InputDecoration(labelText: 'رقم رخصة القيادة'),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _DateField(
                    controller: _licenseExpiryController,
                    label: 'تاريخ انتهاء الرخصة',
                    onTap: () => _pickDate(_licenseExpiryController),
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    initialValue: _status,
                    isExpanded: true,
                    style: TextStyle(fontSize: 13, color: context.textPrimary),
                    decoration: const InputDecoration(labelText: 'حالة السائق'),
                    items: [
                      for (final value in DriverStatusValue.all)
                        DropdownMenuItem(
                          value: value,
                          child: Text(DriverStatusValue.label(value)),
                        ),
                    ],
                    onChanged: (value) => setState(() => _status = value),
                  ),
                  SwitchListTile(
                    value: _isActive,
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'الحساب مفعّل',
                      style:
                          TextStyle(fontSize: 13, color: context.textPrimary),
                    ),
                    onChanged: (value) => setState(() => _isActive = value),
                  ),

                  // ── بيانات المركبة ─────────────────────────────────────
                  const SizedBox(height: 6),
                  const _SectionTitle(
                    icon: Icons.directions_bus_outlined,
                    title: 'بيانات المركبة',
                  ),
                  if (vehicle == null) const _NoVehicleNotice(),
                  const SizedBox(height: 4),
                  _TwoColumn(
                    first: TextFormField(
                      controller: _plateController,
                      style:
                          TextStyle(fontSize: 13, color: context.textPrimary),
                      decoration:
                          const InputDecoration(labelText: 'رقم اللوحة'),
                    ),
                    second: TextFormField(
                      controller: _brandController,
                      style:
                          TextStyle(fontSize: 13, color: context.textPrimary),
                      decoration:
                          const InputDecoration(labelText: 'الشركة المصنّعة'),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _TwoColumn(
                    first: TextFormField(
                      controller: _modelController,
                      style:
                          TextStyle(fontSize: 13, color: context.textPrimary),
                      decoration: const InputDecoration(labelText: 'الموديل'),
                    ),
                    second: TextFormField(
                      controller: _colorController,
                      style:
                          TextStyle(fontSize: 13, color: context.textPrimary),
                      decoration: const InputDecoration(labelText: 'اللون'),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _TwoColumn(
                    first: TextFormField(
                      controller: _typeController,
                      style:
                          TextStyle(fontSize: 13, color: context.textPrimary),
                      decoration:
                          const InputDecoration(labelText: 'نوع المركبة'),
                    ),
                    second: TextFormField(
                      controller: _yearController,
                      keyboardType: TextInputType.number,
                      style:
                          TextStyle(fontSize: 13, color: context.textPrimary),
                      decoration: const InputDecoration(
                        labelText: 'سنة الصنع',
                        hintText: '2018',
                      ),
                      validator: DriverValidation.validateVehicleYear,
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _capacityController,
                    keyboardType: TextInputType.number,
                    style: TextStyle(fontSize: 13, color: context.textPrimary),
                    decoration: const InputDecoration(
                      labelText: 'السعة (عدد الركاب)',
                      hintText: '1 - 60',
                    ),
                    validator: DriverValidation.validateCapacity,
                  ),
                  SwitchListTile(
                    value: _hasAc ?? false,
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'المركبة مزوّدة بتكييف',
                      style:
                          TextStyle(fontSize: 13, color: context.textPrimary),
                    ),
                    onChanged: (value) => setState(() => _hasAc = value),
                  ),
                  const SizedBox(height: 8),
                  DriverFileField(
                    label: 'صورة المركبة',
                    currentUrl: vehicle?.imageUrl,
                    picked: _vehicleImage,
                    onPick: () async {
                      final upload = await _pickImage();
                      if (upload != null) {
                        setState(() => _vehicleImage = upload);
                      }
                    },
                    onClear: _vehicleImage == null
                        ? null
                        : () => setState(() => _vehicleImage = null),
                  ),

                  // ── الوثائق ────────────────────────────────────────────
                  const SizedBox(height: 18),
                  const _SectionTitle(
                    icon: Icons.folder_open_rounded,
                    title: 'الوثائق وتواريخ الانتهاء',
                  ),
                  _DateField(
                    controller: _insuranceExpiryController,
                    label: 'انتهاء التأمين',
                    onTap: () => _pickDate(_insuranceExpiryController),
                  ),
                  const SizedBox(height: 14),
                  _DateField(
                    controller: _stampExpiryController,
                    label: 'انتهاء الدمغ',
                    onTap: () => _pickDate(_stampExpiryController),
                  ),
                  const SizedBox(height: 14),
                  _DateField(
                    controller: _technicalExpiryController,
                    label: 'انتهاء الفحص الفني',
                    onTap: () => _pickDate(_technicalExpiryController),
                  ),
                  const SizedBox(height: 14),
                  for (final field in DriverDocumentField.all) ...[
                    DriverFileField(
                      label: DriverDocumentField.labels[field] ?? field,
                      currentUrl: null,
                      picked: _documents[field],
                      onPick: () async {
                        final upload = await _pickImage();
                        if (upload != null) {
                          setState(() => _documents[field] = upload);
                        }
                      },
                      onClear: _documents[field] == null
                          ? null
                          : () => setState(() => _documents.remove(field)),
                    ),
                    const SizedBox(height: 8),
                  ],

                  // ── سبب التعديل ────────────────────────────────────────
                  const SizedBox(height: 6),
                  Divider(color: context.dividerLine, height: 1),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _reasonController,
                    maxLines: 2,
                    style: TextStyle(fontSize: 13, color: context.textPrimary),
                    decoration: const InputDecoration(
                      labelText: 'سبب التعديل (إلزامي)',
                      hintText: 'مثال: تصحيح بعد مطابقة الوثائق في المقابلة',
                    ),
                    validator: DriverValidation.validateReason,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.history_rounded,
                        size: 13,
                        color: context.textTertiary,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          'سيُسجَّل هذا التعديل باسمك في سجل إجراءات المشرفين.',
                          style: TextStyle(
                            fontSize: 11,
                            color: context.textTertiary,
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
              backgroundColor: context.primaryColor,
              foregroundColor: context.onPrimary,
            ),
            onPressed: _submit,
            icon: const Icon(Icons.save_rounded, size: 16),
            label: const Text('حفظ التعديلات'),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionTitle({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 17, color: context.primaryColor),
          const SizedBox(width: 7),
          Text(
            title,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.bold,
              color: context.primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}

/// حقلان جنباً إلى جنب على الشاشات العريضة، وفوق بعضهما على الضيّقة.
class _TwoColumn extends StatelessWidget {
  final Widget first;
  final Widget second;

  const _TwoColumn({required this.first, required this.second});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 420) {
          return Column(
            children: [first, const SizedBox(height: 14), second],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: first),
            const SizedBox(width: 12),
            Expanded(child: second),
          ],
        );
      },
    );
  }
}

class _DateField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final VoidCallback onTap;

  const _DateField({
    required this.controller,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      onTap: onTap,
      style: TextStyle(fontSize: 13, color: context.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        hintText: 'YYYY-MM-DD',
        suffixIcon: Icon(
          Icons.calendar_today_rounded,
          size: 17,
          color: context.textTertiary,
        ),
      ),
      validator: DriverValidation.validateOptionalDate,
    );
  }
}

/// تنبيه يوضّح أن التعديل يسبق قرار الاعتماد.
class _ReviewNotice extends StatelessWidget {
  const _ReviewNotice();

  @override
  Widget build(BuildContext context) {
    return _Notice(
      icon: Icons.info_outline_rounded,
      message: 'صحّح البيانات حسب الوثائق التي فحصتها في المقابلة، '
          'ثم اعتمد السائق بعد الحفظ.',
    );
  }
}

/// الخادم يرفض حقول المركبة بـ 500 إن لم تكن للسائق مركبة مسجّلة.
class _NoVehicleNotice extends StatelessWidget {
  const _NoVehicleNotice();

  @override
  Widget build(BuildContext context) {
    return _Notice(
      icon: Icons.warning_amber_rounded,
      message: 'لا توجد مركبة مسجّلة لهذا السائق. '
          'ترك حقول المركبة فارغة يتجنّب رفض الخادم للطلب.',
    );
  }
}

class _Notice extends StatelessWidget {
  final IconData icon;
  final String message;

  const _Notice({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.infoBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: context.infoBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: context.infoColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 11.5,
                height: 1.5,
                color: context.infoColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
