import 'package:flutter/material.dart';

import '../../../../core/utils/admin_theme_context.dart';
import '../../data/models/financial_dispute_model.dart';
import '../../../../core/widgets/admin_ui.dart';

/// نتيجة حوار حل النزاع.
class DisputeResolutionRequest {
  final String resolution;
  final String? notes;

  const DisputeResolutionRequest({required this.resolution, this.notes});
}

/// حوار اختيار قرار حل النزاع من القيم المسموح بها في العقد فقط.
class DisputeResolutionDialog extends StatefulWidget {
  final FinancialDisputeModel dispute;

  const DisputeResolutionDialog({super.key, required this.dispute});

  static Future<DisputeResolutionRequest?> show(
    BuildContext context,
    FinancialDisputeModel dispute,
  ) {
    return showDialog<DisputeResolutionRequest>(
      context: context,
      barrierDismissible: false,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: DisputeResolutionDialog(dispute: dispute),
      ),
    );
  }

  @override
  State<DisputeResolutionDialog> createState() =>
      _DisputeResolutionDialogState();
}

class _DisputeResolutionDialogState extends State<DisputeResolutionDialog> {
  String _resolution = DisputeResolution.parentRefunded;
  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _submit() {
    Navigator.pop(
      context,
      DisputeResolutionRequest(
        resolution: _resolution,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: context.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: Text(
        'حل النزاع #${widget.dispute.id}',
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: context.textPrimary,
        ),
      ),
      content: SizedBox(
        width: 460,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AdminInfoRow(
              label: 'المبلغ محل النزاع',
              value: AdminFormat.money(widget.dispute.amount),
              emphasized: true,
            ),
            const SizedBox(height: 8),
            Text(
              'قرار الحل',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: context.textSecondary,
              ),
            ),
            for (final option in DisputeResolution.all)
              RadioListTile<String>(
                value: option,
                // ignore: deprecated_member_use
                groupValue: _resolution,
                // ignore: deprecated_member_use
                onChanged: (value) =>
                    setState(() => _resolution = value ?? _resolution),
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text(
                  DisputeResolution.label(option),
                  style: TextStyle(fontSize: 12.5, color: context.textPrimary),
                ),
              ),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              maxLines: 3,
              style: TextStyle(fontSize: 12.5, color: context.textPrimary),
              decoration: const InputDecoration(
                labelText: 'ملاحظات الحل (اختياري)',
                alignLabelWithHint: true,
              ),
            ),
          ],
        ),
      ),
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        ElevatedButton.icon(
          onPressed: _submit,
          icon: const Icon(Icons.gavel_rounded, size: 16),
          label: const Text('متابعة'),
        ),
      ],
    );
  }
}
