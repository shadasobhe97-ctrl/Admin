import 'package:flutter/material.dart';

import '../../../../core/utils/admin_theme_context.dart';
import '../../data/models/payment_method_model.dart';

/// حوار إضافة/تعديل طريقة دفع.
class PaymentMethodFormDialog extends StatefulWidget {
  final PaymentMethodModel? initialMethod;
  final ValueChanged<PaymentMethodModel> onSubmit;

  const PaymentMethodFormDialog({
    super.key,
    this.initialMethod,
    required this.onSubmit,
  });

  @override
  State<PaymentMethodFormDialog> createState() =>
      _PaymentMethodFormDialogState();
}

class _PaymentMethodFormDialogState extends State<PaymentMethodFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameArController;
  late final TextEditingController _codeController;
  late final TextEditingController _nameEnController;
  late final TextEditingController _accountNameController;
  late final TextEditingController _accountNumberController;
  late final TextEditingController _ibanController;
  late final TextEditingController _walletNumberController;
  late final TextEditingController _minAmountController;
  late final TextEditingController _maxAmountController;
  late final TextEditingController _instructionsArController;
  late final TextEditingController _instructionsEnController;
  late final TextEditingController _sortOrderController;

  late String _targetAudience;
  late String _processingType;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    final m = widget.initialMethod;
    _nameArController = TextEditingController(text: m?.nameAr ?? '');
    _codeController = TextEditingController(text: m?.code ?? '');
    _nameEnController = TextEditingController(text: m?.nameEn ?? '');
    _accountNameController = TextEditingController(text: m?.accountName ?? '');
    _accountNumberController =
        TextEditingController(text: m?.accountNumber ?? '');
    _ibanController = TextEditingController(text: m?.iban ?? '');
    _walletNumberController =
        TextEditingController(text: m?.walletNumber ?? '');
    _minAmountController =
        TextEditingController(text: m?.minAmount?.toString() ?? '');
    _maxAmountController =
        TextEditingController(text: m?.maxAmount?.toString() ?? '');
    _instructionsArController =
        TextEditingController(text: m?.instructionsAr ?? '');
    _instructionsEnController =
        TextEditingController(text: m?.instructionsEn ?? '');
    _sortOrderController =
        TextEditingController(text: m?.sortOrder.toString() ?? '0');

    _targetAudience = m?.targetAudience ?? 'both';
    _processingType = m?.processingType ?? 'manual_proof';
    _isActive = m?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameArController.dispose();
    _codeController.dispose();
    _nameEnController.dispose();
    _accountNameController.dispose();
    _accountNumberController.dispose();
    _ibanController.dispose();
    _walletNumberController.dispose();
    _minAmountController.dispose();
    _maxAmountController.dispose();
    _instructionsArController.dispose();
    _instructionsEnController.dispose();
    _sortOrderController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final minAmt = _minAmountController.text.trim().isEmpty
        ? null
        : double.tryParse(_minAmountController.text.trim());
    final maxAmt = _maxAmountController.text.trim().isEmpty
        ? null
        : double.tryParse(_maxAmountController.text.trim());
    final sortOrd = int.tryParse(_sortOrderController.text.trim()) ?? 0;

    final model = PaymentMethodModel(
      id: widget.initialMethod?.id,
      nameAr: _nameArController.text.trim(),
      code: _codeController.text.trim(),
      targetAudience: _targetAudience,
      processingType: _processingType,
      nameEn: _nameEnController.text.trim().isEmpty
          ? null
          : _nameEnController.text.trim(),
      accountName: _accountNameController.text.trim().isEmpty
          ? null
          : _accountNameController.text.trim(),
      accountNumber: _accountNumberController.text.trim().isEmpty
          ? null
          : _accountNumberController.text.trim(),
      iban: _ibanController.text.trim().isEmpty
          ? null
          : _ibanController.text.trim(),
      walletNumber: _walletNumberController.text.trim().isEmpty
          ? null
          : _walletNumberController.text.trim(),
      minAmount: minAmt,
      maxAmount: maxAmt,
      instructionsAr: _instructionsArController.text.trim().isEmpty
          ? null
          : _instructionsArController.text.trim(),
      instructionsEn: _instructionsEnController.text.trim().isEmpty
          ? null
          : _instructionsEnController.text.trim(),
      isActive: _isActive,
      sortOrder: sortOrd,
    );

    widget.onSubmit(model);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialMethod != null;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 650,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      isEditing ? Icons.edit_rounded : Icons.add_rounded,
                      color: context.primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isEditing ? 'تعديل طريقة الدفع' : 'إضافة طريقة دفع جديدة',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: context.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const Divider(height: 24),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _nameArController,
                                style: TextStyle(
                                    fontSize: 13, color: context.textPrimary),
                                decoration: const InputDecoration(
                                  labelText: 'اسم الطريقة بالعربية *',
                                  hintText: 'مثال: سداد الإلكتروني',
                                  isDense: true,
                                ),
                                validator: (val) => val == null || val.trim().isEmpty
                                    ? 'هذا الحقل إجباري'
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _codeController,
                                style: TextStyle(
                                    fontSize: 13, color: context.textPrimary),
                                decoration: const InputDecoration(
                                  labelText: 'الكود (Code) *',
                                  hintText: 'مثال: SADAD',
                                  isDense: true,
                                ),
                                validator: (val) => val == null || val.trim().isEmpty
                                    ? 'هذا الحقل إجباري'
                                    : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                initialValue: _targetAudience,
                                style: TextStyle(
                                    fontSize: 13, color: context.textPrimary),
                                decoration: const InputDecoration(
                                  labelText: 'الجمهور المستهدف *',
                                  isDense: true,
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: 'parent',
                                    child: Text('أولياء الأمور'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'driver',
                                    child: Text('السائقون'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'both',
                                    child: Text('الجميع'),
                                  ),
                                ],
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() => _targetAudience = val);
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                initialValue: _processingType,
                                style: TextStyle(
                                    fontSize: 13, color: context.textPrimary),
                                decoration: const InputDecoration(
                                  labelText: 'نوع المعالجة *',
                                  isDense: true,
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: 'manual_proof',
                                    child: Text('إثبات يدوي'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'instant_simulation',
                                    child: Text('دفع فوري'),
                                  ),
                                ],
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() => _processingType = val);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _nameEnController,
                                style: TextStyle(
                                    fontSize: 13, color: context.textPrimary),
                                decoration: const InputDecoration(
                                  labelText: 'اسم الطريقة بالإنجليزية (اختياري)',
                                  isDense: true,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _sortOrderController,
                                keyboardType: TextInputType.number,
                                style: TextStyle(
                                    fontSize: 13, color: context.textPrimary),
                                decoration: const InputDecoration(
                                  labelText: 'الترتيب (Sort Order)',
                                  isDense: true,
                                ),
                                validator: (val) {
                                  if (val != null && val.isNotEmpty) {
                                    if (int.tryParse(val) == null) {
                                      return 'يرجى إدخال رقم صحيح';
                                    }
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _accountNameController,
                                style: TextStyle(
                                    fontSize: 13, color: context.textPrimary),
                                decoration: const InputDecoration(
                                  labelText: 'اسم الحساب (اختياري)',
                                  isDense: true,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _accountNumberController,
                                style: TextStyle(
                                    fontSize: 13, color: context.textPrimary),
                                decoration: const InputDecoration(
                                  labelText: 'رقم الحساب (اختياري)',
                                  isDense: true,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _ibanController,
                                style: TextStyle(
                                    fontSize: 13, color: context.textPrimary),
                                decoration: const InputDecoration(
                                  labelText: 'IBAN (اختياري)',
                                  isDense: true,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _walletNumberController,
                                style: TextStyle(
                                    fontSize: 13, color: context.textPrimary),
                                decoration: const InputDecoration(
                                  labelText: 'رقم المحفظة (اختياري)',
                                  isDense: true,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _minAmountController,
                                keyboardType: const TextInputType.numberWithOptions(
                                    decimal: true),
                                style: TextStyle(
                                    fontSize: 13, color: context.textPrimary),
                                decoration: const InputDecoration(
                                  labelText: 'الحد الأدنى (اختياري)',
                                  isDense: true,
                                ),
                                validator: (val) {
                                  if (val != null && val.trim().isNotEmpty) {
                                    if (double.tryParse(val.trim()) == null) {
                                      return 'يرجى إدخال رقم عشري مقبول';
                                    }
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _maxAmountController,
                                keyboardType: const TextInputType.numberWithOptions(
                                    decimal: true),
                                style: TextStyle(
                                    fontSize: 13, color: context.textPrimary),
                                decoration: const InputDecoration(
                                  labelText: 'الحد الأقصى (اختياري)',
                                  isDense: true,
                                ),
                                validator: (val) {
                                  if (val != null && val.trim().isNotEmpty) {
                                    if (double.tryParse(val.trim()) == null) {
                                      return 'يرجى إدخال رقم عشري مقبول';
                                    }
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _instructionsArController,
                          maxLines: 2,
                          style: TextStyle(
                              fontSize: 13, color: context.textPrimary),
                          decoration: const InputDecoration(
                            labelText: 'تعليمات بالعربية (اختياري)',
                            alignLabelWithHint: true,
                          ),
                        ),
                        const SizedBox(height: 14),
                        SwitchListTile(
                          title: const Text('تفعيل طريقة الدفع (Active)'),
                          value: _isActive,
                          onChanged: (val) => setState(() => _isActive = val),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('إلغاء'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _submit,
                      child: Text(isEditing ? 'تحديث' : 'إضافة'),
                    ),
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
