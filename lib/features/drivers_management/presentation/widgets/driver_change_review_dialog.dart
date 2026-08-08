import 'package:flutter/material.dart';

class DriverChangeReviewDialog extends StatefulWidget {
  final int changeId;
  final String changeType;
  final Function(String decision, String? rejectionReason) onSubmit;

  const DriverChangeReviewDialog({
    super.key,
    required this.changeId,
    required this.changeType,
    required this.onSubmit,
  });

  @override
  State<DriverChangeReviewDialog> createState() => _DriverChangeReviewDialogState();
}

class _DriverChangeReviewDialogState extends State<DriverChangeReviewDialog> {
  bool _isRejecting = false;
  final _reasonController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'اعتماد تعديلات بيانات المركبة والسائق',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'طلب رقم: #${widget.changeId} | النوع: ${widget.changeType}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2563EB),
                ),
              ),
              const SizedBox(height: 16),

              if (!_isRejecting) ...[
                const Text('هل ترغب بتطبيق البيانات المقترحة فوراً على حساب المركبة والسائق؟'),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFE11D48),
                          side: const BorderSide(color: Color(0xFFE11D48)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () => setState(() => _isRejecting = true),
                        icon: const Icon(Icons.cancel_outlined, size: 18),
                        label: const Text('رفض التعديلات', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          widget.onSubmit('Approved', null);
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.check_circle_outline, size: 18),
                        label: const Text('الموافقة وتطبيق التعديل', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _reasonController,
                        maxLines: 3,
                        style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A), fontSize: 13),
                        decoration: const InputDecoration(
                          labelText: 'سبب الرفض (مطلوب عند الرفض)',
                          hintText: 'مثال: رقم اللوحة غير مطابق لكتيب الملكية المرفق...',
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'يرجى توضيح سبب رفض طلب التعديل';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => setState(() => _isRejecting = false),
                            child: const Text('تراجع'),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE11D48),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: () {
                              if (_formKey.currentState?.validate() ?? false) {
                                widget.onSubmit('Rejected', _reasonController.text.trim());
                                Navigator.pop(context);
                              }
                            },
                            icon: const Icon(Icons.send_rounded, size: 16),
                            label: const Text('تأكيد رفض التعديل', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
