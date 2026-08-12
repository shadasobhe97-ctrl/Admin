import 'package:flutter/material.dart';

import '../../../../core/utils/admin_theme_context.dart';
import '../../data/models/withdrawal_model.dart';
import '../../../../core/widgets/admin_ui.dart';

/// نتيجة حوار معالجة طلب السحب.
class WithdrawalActionRequest {
  final String action;
  final String? rejectionReason;

  const WithdrawalActionRequest({required this.action, this.rejectionReason});
}

/// حوار معالجة طلب سحب: موافقة أو رفض مع سبب إلزامي عند الرفض.
/// لا يُنفّذ أي استدعاء شبكة — يعيد الطلب فقط لتنفّذه طبقة المنطق.
class WithdrawalActionDialog extends StatefulWidget {
  final WithdrawalModel withdrawal;

  const WithdrawalActionDialog({super.key, required this.withdrawal});

  static Future<WithdrawalActionRequest?> show(
    BuildContext context,
    WithdrawalModel withdrawal,
  ) {
    return showDialog<WithdrawalActionRequest>(
      context: context,
      barrierDismissible: false,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: WithdrawalActionDialog(withdrawal: withdrawal),
      ),
    );
  }

  @override
  State<WithdrawalActionDialog> createState() => _WithdrawalActionDialogState();
}

class _WithdrawalActionDialogState extends State<WithdrawalActionDialog> {
  final TextEditingController _reasonController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isRejecting = false;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  void _submitApprove() {
    Navigator.pop(
      context,
      const WithdrawalActionRequest(action: 'approve'),
    );
  }

  void _submitReject() {
    if (!_isRejecting) {
      setState(() => _isRejecting = true);
      return;
    }
    if (_formKey.currentState?.validate() != true) return;

    Navigator.pop(
      context,
      WithdrawalActionRequest(
        action: 'reject',
        rejectionReason: _reasonController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: context.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: Text(
        'معالجة طلب السحب #${widget.withdrawal.id}',
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: context.textPrimary,
        ),
      ),
      content: SizedBox(
        width: 440,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AdminInfoRow(
                label: 'السائق',
                value: widget.withdrawal.driverName,
              ),
              AdminInfoRow(
                label: 'المبلغ',
                value: AdminFormat.money(widget.withdrawal.amount),
                emphasized: true,
              ),
              AdminInfoRow(
                label: 'وسيلة الدفع',
                value: AdminFormat.orDash(
                  widget.withdrawal.paymentMethodDetails,
                ),
              ),
              if (_isRejecting) ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: _reasonController,
                  maxLines: 3,
                  autofocus: true,
                  style: TextStyle(fontSize: 12.5, color: context.textPrimary),
                  decoration: const InputDecoration(
                    labelText: 'سبب الرفض (إلزامي)',
                    alignLabelWithHint: true,
                  ),
                  validator: (value) =>
                      (value == null || value.trim().isEmpty)
                          ? 'يجب إدخال سبب الرفض قبل إرسال الطلب.'
                          : null,
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('إغلاق', style: TextStyle(color: context.textMuted)),
        ),
        OutlinedButton.icon(
          onPressed: _submitReject,
          icon: Icon(Icons.close_rounded, size: 16, color: context.dangerColor),
          label: Text(
            _isRejecting ? 'تأكيد الرفض' : 'رفض الطلب',
            style: TextStyle(color: context.dangerColor),
          ),
        ),
        if (!_isRejecting)
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: context.successColor,
              foregroundColor: context.onPrimary,
            ),
            onPressed: _submitApprove,
            icon: const Icon(Icons.check_rounded, size: 16),
            label: const Text('الموافقة وصرف المبلغ'),
          ),
      ],
    );
  }
}
