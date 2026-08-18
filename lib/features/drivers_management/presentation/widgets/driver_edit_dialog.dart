import 'package:flutter/material.dart';

import '../../../../core/utils/admin_theme_context.dart';
import '../../data/models/driver_model.dart';
import '../../data/models/update_driver_payload.dart';

/// نموذج تعديل بيانات السائق قبل اعتماده.
///
/// يبني حمولة مُصنَّفة عبر [UpdateDriverPayload] ولا ينفّذ أي استدعاء شبكة —
/// يعيدها للشاشة لتمرّرها إلى الـ Cubit.
class DriverEditDialog extends StatefulWidget {
  final DriverModel driver;

  /// `true` عند فتح النموذج ضمن تدفّق المراجعة قبل الاعتماد.
  final bool isReviewFlow;

  const DriverEditDialog({
    super.key,
    required this.driver,
    this.isReviewFlow = false,
  });

  @override
  State<DriverEditDialog> createState() => _DriverEditDialogState();
}

class _DriverEditDialogState extends State<DriverEditDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _nationalIdController;
  late final TextEditingController _licenseNumberController;
  late final TextEditingController _licenseExpiryController;
  late final TextEditingController _reasonController;

  late bool _isActive;

  @override
  void initState() {
    super.initState();
    final driver = widget.driver;

    _nameController = TextEditingController(text: driver.fullName);
    _phoneController = TextEditingController(text: driver.phoneNumber);
    _nationalIdController = TextEditingController(text: driver.nationalId ?? '');
    _licenseNumberController =
        TextEditingController(text: driver.licenseNumber ?? '');
    _licenseExpiryController =
        TextEditingController(text: driver.licenseExpiry ?? '');
    _reasonController = TextEditingController();

    _isActive = driver.isActive;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _nationalIdController.dispose();
    _licenseNumberController.dispose();
    _licenseExpiryController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _pickExpiryDate() async {
    final now = DateTime.now();
    final current = DateTime.tryParse(_licenseExpiryController.text.trim());

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
      _licenseExpiryController.text =
          '${picked.year.toString().padLeft(4, '0')}-'
          '${picked.month.toString().padLeft(2, '0')}-'
          '${picked.day.toString().padLeft(2, '0')}';
    }
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final payload = UpdateDriverPayload.diff(
      original: widget.driver,
      reason: _reasonController.text,
      fullName: _nameController.text,
      phoneNumber: _phoneController.text,
      nationalId: _nationalIdController.text,
      licenseNumber: _licenseNumberController.text,
      licenseExpiry: _licenseExpiryController.text,
      isActive: _isActive,
    );

    Navigator.of(context).pop(payload);
  }

  @override
  Widget build(BuildContext context) {
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
          width: 480,
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.isReviewFlow) _ReviewNotice(),
                  if (widget.isReviewFlow) const SizedBox(height: 16),

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

                  TextFormField(
                    controller: _nationalIdController,
                    keyboardType: TextInputType.number,
                    style: TextStyle(fontSize: 13, color: context.textPrimary),
                    decoration: const InputDecoration(
                      labelText: 'الرقم الوطني',
                    ),
                  ),
                  const SizedBox(height: 14),

                  TextFormField(
                    controller: _licenseNumberController,
                    style: TextStyle(fontSize: 13, color: context.textPrimary),
                    decoration: const InputDecoration(
                      labelText: 'رقم رخصة القيادة',
                    ),
                  ),
                  const SizedBox(height: 14),

                  TextFormField(
                    controller: _licenseExpiryController,
                    readOnly: true,
                    onTap: _pickExpiryDate,
                    style: TextStyle(fontSize: 13, color: context.textPrimary),
                    decoration: InputDecoration(
                      labelText: 'تاريخ انتهاء الرخصة',
                      hintText: 'YYYY-MM-DD',
                      suffixIcon: Icon(
                        Icons.calendar_today_rounded,
                        size: 17,
                        color: context.textTertiary,
                      ),
                    ),
                    validator: DriverValidation.validateOptionalDate,
                  ),
                  const SizedBox(height: 6),

                  SwitchListTile(
                    value: _isActive,
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'الحساب مفعّل',
                      style: TextStyle(
                        fontSize: 13,
                        color: context.textPrimary,
                      ),
                    ),
                    onChanged: (value) => setState(() => _isActive = value),
                  ),
                  const SizedBox(height: 8),

                  Divider(color: context.dividerLine, height: 1),
                  const SizedBox(height: 14),

                  // سبب التعديل إلزامي ويُحفظ في سجل إجراءات المشرفين.
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

/// تنبيه يوضّح أن التعديل يسبق قرار الاعتماد.
class _ReviewNotice extends StatelessWidget {
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
          Icon(Icons.info_outline_rounded, size: 16, color: context.infoColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'صحّح البيانات حسب الوثائق التي فحصتها في المقابلة، '
              'ثم اعتمد السائق بعد الحفظ.',
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
