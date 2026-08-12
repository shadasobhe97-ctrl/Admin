import 'package:flutter/material.dart';

import '../../../../core/utils/admin_theme_context.dart';
import '../../data/models/recharge_model.dart';
import '../../../../core/widgets/admin_ui.dart';

/// نتيجة حوار معالجة عملية الشحن.
class RechargeActionRequest {
  final String action;
  final String? reason;

  const RechargeActionRequest({required this.action, this.reason});
}

/// حوار معالجة عملية شحن: إتمام أو تسجيل إخفاق مع سبب إلزامي.
class RechargeActionDialog extends StatefulWidget {
  final RechargeModel recharge;

  const RechargeActionDialog({super.key, required this.recharge});

  static Future<RechargeActionRequest?> show(
    BuildContext context,
    RechargeModel recharge,
  ) {
    return showDialog<RechargeActionRequest>(
      context: context,
      barrierDismissible: false,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: RechargeActionDialog(recharge: recharge),
      ),
    );
  }

  @override
  State<RechargeActionDialog> createState() => _RechargeActionDialogState();
}

class _RechargeActionDialogState extends State<RechargeActionDialog> {
  final TextEditingController _reasonController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isFailing = false;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  void _submitComplete() {
    Navigator.pop(context, const RechargeActionRequest(action: 'complete'));
  }

  void _submitFail() {
    if (!_isFailing) {
      setState(() => _isFailing = true);
      return;
    }
    if (_formKey.currentState?.validate() != true) return;

    Navigator.pop(
      context,
      RechargeActionRequest(
        action: 'fail',
        reason: _reasonController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: context.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: Text(
        'معالجة عملية الشحن #${widget.recharge.id}',
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
                label: 'ولي الأمر',
                value: widget.recharge.parentName,
              ),
              AdminInfoRow(
                label: 'المبلغ',
                value: AdminFormat.money(widget.recharge.amount),
                emphasized: true,
              ),
              AdminInfoRow(
                label: 'الرقم المرجعي',
                value:
                    AdminFormat.orDash(widget.recharge.referenceNumber),
              ),
              if (_isFailing) ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: _reasonController,
                  maxLines: 3,
                  autofocus: true,
                  style: TextStyle(fontSize: 12.5, color: context.textPrimary),
                  decoration: const InputDecoration(
                    labelText: 'سبب الإخفاق (إلزامي)',
                    alignLabelWithHint: true,
                  ),
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'يجب إدخال سبب الإخفاق قبل إرسال الطلب.'
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
          onPressed: _submitFail,
          icon: Icon(Icons.close_rounded, size: 16, color: context.dangerColor),
          label: Text(
            _isFailing ? 'تأكيد الإخفاق' : 'تسجيل إخفاق',
            style: TextStyle(color: context.dangerColor),
          ),
        ),
        if (!_isFailing)
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: context.successColor,
              foregroundColor: context.onPrimary,
            ),
            onPressed: _submitComplete,
            icon: const Icon(Icons.check_rounded, size: 16),
            label: const Text('إتمام الشحن وإضافة الرصيد'),
          ),
      ],
    );
  }
}
