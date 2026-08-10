import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/admin_management_cubit.dart';

class EmailVerificationWaitingDialog extends StatefulWidget {
  final int adminId;
  final String newEmail;
  final VoidCallback onRefresh;

  const EmailVerificationWaitingDialog({
    super.key,
    required this.adminId,
    required this.newEmail,
    required this.onRefresh,
  });

  static Future<void> show(
    BuildContext context, {
    required int adminId,
    required String newEmail,
    required VoidCallback onRefresh,
  }) {
    final cubit = context.read<AdminManagementCubit>();
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => BlocProvider.value(
        value: cubit,
        child: EmailVerificationWaitingDialog(
          adminId: adminId,
          newEmail: newEmail,
          onRefresh: onRefresh,
        ),
      ),
    );
  }

  @override
  State<EmailVerificationWaitingDialog> createState() =>
      _EmailVerificationWaitingDialogState();
}

class _EmailVerificationWaitingDialogState
    extends State<EmailVerificationWaitingDialog> {
  bool _isChecking = false;
  bool _isResending = false;
  bool _isCancelling = false;

  Future<void> _handleCheckStatus() async {
    if (_isChecking || _isResending || _isCancelling) return;
    setState(() => _isChecking = true);

    final cubit = context.read<AdminManagementCubit>();
    final status = await cubit.checkEmailChangeStatus(widget.adminId);

    if (!mounted) return;
    setState(() => _isChecking = false);

    switch (status) {
      case 'verified':
        Navigator.pop(context);
        widget.onRefresh();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ تم تأكيد البريد الإلكتروني بنجاح!'),
            backgroundColor: Colors.green,
          ),
        );
        break;
      case 'pending':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                '⚠️ لم يتم التأكيد بعد، يرجى فتح الرابط في بريدك الإلكتروني.'),
            backgroundColor: Colors.amber,
          ),
        );
        break;
      case 'rejected':
        Navigator.pop(context);
        widget.onRefresh();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ تم رفض طلب تغيير البريد الإلكتروني.'),
            backgroundColor: Colors.orange,
          ),
        );
        break;
      case 'expired':
      default:
        Navigator.pop(context);
        widget.onRefresh();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⌛ انتهت صلاحية الرابط، يرجى إعادة المحاولة.'),
            backgroundColor: Colors.red,
          ),
        );
        break;
    }
  }

  Future<void> _handleResend() async {
    if (_isChecking || _isResending || _isCancelling) return;
    setState(() => _isResending = true);

    final cubit = context.read<AdminManagementCubit>();
    final ok = await cubit.resendEmailChange(widget.adminId);

    if (!mounted) return;
    setState(() => _isResending = false);

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🔁 تمت إعادة إرسال رابط التأكيد بنجاح.'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _handleCancel() async {
    if (_isChecking || _isResending || _isCancelling) return;
    setState(() => _isCancelling = true);

    final cubit = context.read<AdminManagementCubit>();
    final ok = await cubit.cancelEmailChange(widget.adminId);

    if (!mounted) return;
    setState(() => _isCancelling = false);

    if (ok) {
      Navigator.pop(context);
      widget.onRefresh();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم إلغاء طلب تغيير البريد الإلكتروني.'),
          backgroundColor: Colors.blueGrey,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: PopScope(
        canPop: false, // Prevent back button / dialog dismiss
        child: Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: theme.cardColor,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 480),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.mark_email_unread_rounded,
                    size: 44,
                    color: Colors.amber,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'بانتظار تأكيد البريد الإلكتروني',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.1)
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'أرسلنا رابط تأكيد إلى البريد الإلكتروني الجديدة:',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 6),
                      SelectableText(
                        widget.newEmail,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? const Color(0xFF38BDF8)
                              : const Color(0xFF0284C7),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'يرجى فتح بريدك والضغط على الرابط لتفعيل التغيير.\nالرابط صالح لمدة 30 دقيقة.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? const Color(0xFF64748B)
                              : const Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Action Buttons
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isChecking ? null : _handleCheckStatus,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: _isChecking
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.check_circle_outline_rounded,
                            size: 20),
                    label: const Text(
                      'تم التأكيد',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _isResending ? null : _handleResend,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: _isResending
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.refresh_rounded, size: 18),
                        label: const Text('إعادة الإرسال'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextButton.icon(
                        onPressed: _isCancelling ? null : _handleCancel,
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        icon: _isCancelling
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.red,
                                ),
                              )
                            : const Icon(Icons.cancel_outlined, size: 18),
                        label: const Text('إلغاء التعديل'),
                      ),
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
