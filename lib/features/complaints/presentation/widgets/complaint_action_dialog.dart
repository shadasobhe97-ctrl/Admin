import 'package:flutter/material.dart';
import '../../../../core/utils/admin_theme_context.dart';

class ComplaintActionDialog extends StatefulWidget {
  final String action; // 'warning' | 'suspension' | 'dismiss'
  final String driverName;
  final bool isLoading;
  final Future<void> Function(String? actionDetails) onSubmit;

  const ComplaintActionDialog({
    super.key,
    required this.action,
    required this.driverName,
    required this.isLoading,
    required this.onSubmit,
  });

  @override
  State<ComplaintActionDialog> createState() => _ComplaintActionDialogState();
}

class _ComplaintActionDialogState extends State<ComplaintActionDialog> {
  final TextEditingController _detailsController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  String get _title {
    switch (widget.action) {
      case 'warning':
        return 'توجيه إنذار رسمي للسائق';
      case 'suspension':
        return 'إيقاف حساب السائق';
      case 'dismiss':
        return 'تجاهل وحفظ الشكوى';
      default:
        return 'اتخاذ قرار إداري';
    }
  }

  Color _getHeaderColor(BuildContext context) {
    switch (widget.action) {
      case 'warning':
        return context.warningColor;
      case 'suspension':
        return context.dangerColor;
      case 'dismiss':
        return context.textSecondary;
      default:
        return context.primaryColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final headerColor = _getHeaderColor(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: context.cardColor,
      child: Container(
        width: 480,
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Title
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: headerColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      widget.action == 'suspension'
                          ? Icons.block_rounded
                          : widget.action == 'warning'
                              ? Icons.warning_amber_rounded
                              : Icons.gavel_rounded,
                      color: headerColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: context.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'السائق المستهدف: ${widget.driverName}',
                          style: TextStyle(
                            fontSize: 12,
                            color: context.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Suspension Confirmation Notice
              if (widget.action == 'suspension') ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: context.dangerBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: context.dangerBorder),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_rounded,
                        color: context.dangerColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'تحذير: سيتم إيقاف حساب السائق من قِبل السيرفر ولن يستطيع المشاركة في أي رحلة.',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            color: context.dangerColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Details TextField
              Text(
                'تفاصيل القرار الإداري (اختياري - حتى 2000 حرف):',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: context.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _detailsController,
                maxLength: 2000,
                maxLines: 4,
                enabled: !widget.isLoading,
                style: TextStyle(fontSize: 13, color: context.textPrimary),
                decoration: InputDecoration(
                  hintText: widget.action == 'warning'
                      ? 'مثال: تم توجيه إنذار رسمي للكابتن بضرورة الالتزام بمواعيد الانطلاق...'
                      : widget.action == 'suspension'
                          ? 'مثال: تم إيقاف حساب السائق لعدم الالتزام وسوء السلوك...'
                          : 'مثال: تم حفظ وتجاهل الشكوى بعد المراجعة وتبين عدم وجود مخالفة...',
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
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: headerColor),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: widget.isLoading
                        ? null
                        : () => Navigator.of(context).pop(),
                    child: Text(
                      'إلغاء',
                      style: TextStyle(color: context.textMuted),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: widget.isLoading
                        ? null
                        : () async {
                            if (_formKey.currentState!.validate()) {
                              await widget.onSubmit(_detailsController.text);
                              if (context.mounted) {
                                Navigator.of(context).pop();
                              }
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: headerColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    child: widget.isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            widget.action == 'warning'
                                ? 'تأكيد الإنذار'
                                : widget.action == 'suspension'
                                    ? 'تأكيد الإيقاف'
                                    : 'تأكيد التجاهل',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
