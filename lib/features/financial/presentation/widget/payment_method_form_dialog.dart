import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/utils/admin_theme_context.dart';
import '../../../../core/widgets/remote_image.dart';
import '../../data/models/payment_method_model.dart';

/// حوار إضافة/تعديل طريقة دفع — يعكس عقد Backend حرفياً.
///
/// حقول Backend المسموحة: `name_ar`, `code`, `min_amount`, `max_amount`,
/// `sort_order`, `icon` (ملف). حقل `is_active` يُعدَّل فقط عبر
/// `PATCH /toggle-status`، فلا يظهر هنا.
///
/// في وضع التعديل: كل الحقول اختيارية، وتُبنى نموذج جديد يمرَّر مع النموذج
/// الأصلي إلى الـ Cubit ليحسب الحقول المتغيّرة فقط (Partial Update).
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
  late final TextEditingController _minAmountController;
  late final TextEditingController _maxAmountController;
  late final TextEditingController _sortOrderController;

  Uint8List? _iconBytes;
  String? _iconFileName;

  bool get _isEditing => widget.initialMethod != null;

  @override
  void initState() {
    super.initState();
    final m = widget.initialMethod;
    _nameArController = TextEditingController(text: m?.nameAr ?? '');
    _codeController = TextEditingController(text: m?.code ?? '');
    _minAmountController =
        TextEditingController(text: m?.minAmount?.toString() ?? '');
    _maxAmountController =
        TextEditingController(text: m?.maxAmount?.toString() ?? '');
    _sortOrderController =
        TextEditingController(text: (m?.sortOrder ?? 0).toString());
  }

  @override
  void dispose() {
    _nameArController.dispose();
    _codeController.dispose();
    _minAmountController.dispose();
    _maxAmountController.dispose();
    _sortOrderController.dispose();
    super.dispose();
  }

  Future<void> _pickIcon() async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 90,
      );
      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _iconBytes = bytes;
          _iconFileName = image.name;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تعذر اختيار الصورة: ${e.toString()}')),
        );
      }
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    // في الإضافة، الأيقونة إجبارية وفق العقد.
    if (!_isEditing && (_iconBytes == null || _iconBytes!.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يجب اختيار أيقونة طريقة الدفع.')),
      );
      return;
    }

    final minAmt = _minAmountController.text.trim().isEmpty
        ? null
        : double.tryParse(_minAmountController.text.trim());
    final maxAmt = _maxAmountController.text.trim().isEmpty
        ? null
        : double.tryParse(_maxAmountController.text.trim());
    final sortOrd = int.tryParse(_sortOrderController.text.trim()) ??
        (widget.initialMethod?.sortOrder ?? 0);

    final model = PaymentMethodModel(
      id: widget.initialMethod?.id,
      nameAr: _nameArController.text.trim(),
      code: _codeController.text.trim(),
      iconUrl: widget.initialMethod?.iconUrl,
      minAmount: minAmt,
      maxAmount: maxAmt,
      isActive: widget.initialMethod?.isActive ?? true,
      sortOrder: sortOrd,
      createdAt: widget.initialMethod?.createdAt,
      updatedAt: widget.initialMethod?.updatedAt,
      iconBytes: _iconBytes,
      iconFileName: _iconFileName,
    );

    widget.onSubmit(model);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 560,
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
                      _isEditing ? Icons.edit_rounded : Icons.add_rounded,
                      color: context.primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isEditing
                          ? 'تعديل طريقة الدفع'
                          : 'إضافة طريقة دفع جديدة',
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
                        _buildIconPicker(context),
                        const SizedBox(height: 16),
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
                                validator: (val) {
                                  if (_isEditing) return null;
                                  if (val == null || val.trim().isEmpty) {
                                    return 'هذا الحقل إجباري';
                                  }
                                  return null;
                                },
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
                                validator: (val) {
                                  if (_isEditing) return null;
                                  if (val == null || val.trim().isEmpty) {
                                    return 'هذا الحقل إجباري';
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
                                controller: _minAmountController,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
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
                                keyboardType:
                                    const TextInputType.numberWithOptions(
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
                          controller: _sortOrderController,
                          keyboardType: TextInputType.number,
                          style: TextStyle(
                              fontSize: 13, color: context.textPrimary),
                          decoration: const InputDecoration(
                            labelText: 'ترتيب الظهور (Sort Order)',
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
                      child: Text(_isEditing ? 'تحديث' : 'إضافة'),
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

  Widget _buildIconPicker(BuildContext context) {
    final hasNewIcon = _iconBytes != null && _iconBytes!.isNotEmpty;
    final currentUrl = widget.initialMethod?.iconUrl;

    return Row(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: context.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.borderSoft),
          ),
          clipBehavior: Clip.antiAlias,
          child: hasNewIcon
              ? Image.memory(_iconBytes!, fit: BoxFit.cover)
              : (currentUrl != null && currentUrl.isNotEmpty
                  ? RemoteImage(
                      rawUrl: currentUrl,
                      fit: BoxFit.cover,
                      fallback: Icon(Icons.image_outlined,
                          color: context.textMuted, size: 28),
                    )
                  : Icon(Icons.image_outlined,
                      color: context.textMuted, size: 28)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isEditing
                    ? 'الأيقونة الحالية (اختر صورة جديدة لاستبدالها)'
                    : 'أيقونة طريقة الدفع *',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  color: context.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: _pickIcon,
                    icon: const Icon(Icons.upload_file_rounded, size: 16),
                    label: Text(hasNewIcon ? 'تغيير الصورة' : 'اختيار صورة'),
                  ),
                  if (hasNewIcon) ...[
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () => setState(() {
                        _iconBytes = null;
                        _iconFileName = null;
                      }),
                      icon: const Icon(Icons.clear_rounded, size: 16),
                      label: const Text('إلغاء الاختيار'),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
