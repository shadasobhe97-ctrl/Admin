import 'package:flutter/material.dart';
import '../../../../core/network/admin_api_service.dart';
import '../../../../core/theme/derbi_colors.dart';
import '../../../../core/widgets/stat_card.dart';

class FinancialCashoutView extends StatefulWidget {
  const FinancialCashoutView({super.key});

  @override
  State<FinancialCashoutView> createState() => _FinancialCashoutViewState();
}

class _FinancialCashoutViewState extends State<FinancialCashoutView> with SingleTickerProviderStateMixin {
  final AdminApiService _apiService = AdminApiService();
  late TabController _tabController;
  bool _isLoading = true;

  List<dynamic> _invoices = [];
  List<dynamic> _withdrawals = [];
  List<dynamic> _recharges = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadFinancialData();
  }

  Future<void> _loadFinancialData() async {
    setState(() => _isLoading = true);
    final invRes = await _apiService.getInvoices();
    final withRes = await _apiService.getWithdrawals();
    final rechRes = await _apiService.getRecharges();

    if (mounted) {
      setState(() {
        _isLoading = false;
        _invoices = invRes['data'] is List ? invRes['data'] : [];
        _withdrawals = withRes['data'] is List ? withRes['data'] : [];
        _recharges = rechRes['data'] is List ? rechRes['data'] : [];
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Stat Cards Summary
        Row(
          children: [
            Expanded(child: StatCard(title: 'طلبات سحب الأرباح', value: '${_withdrawals.length} طلبات', icon: Icons.account_balance, color: DerbiColors.primaryBlue, subtitle: 'سحوبات السائقين المصرفية')),
            const SizedBox(width: 16),
            Expanded(child: StatCard(title: 'طلبات شحن المحافظ', value: '${_recharges.length} عمليات', icon: Icons.account_balance_wallet, color: DerbiColors.successEmerald, subtitle: 'محافظ أولياء الأمور')),
            const SizedBox(width: 16),
            Expanded(child: StatCard(title: 'إجمالي الفواتير الصادرة', value: '${_invoices.length} فواتير', icon: Icons.receipt_long, color: DerbiColors.warningAmber, subtitle: 'فواتير المنصة الكلية')),
          ],
        ),
        const SizedBox(height: 20),

        // Tabs Selector
        TabBar(
          controller: _tabController,
          indicatorColor: DerbiColors.primaryBlue,
          labelColor: Colors.white,
          unselectedLabelColor: DerbiColors.textMuted,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(text: 'طلبات سحب الأرباح (Withdrawals)'),
            Tab(text: 'طلبات شحن المحافظ (Recharges)'),
            Tab(text: 'الفواتير والعمليات (Invoices)'),
          ],
        ),
        const SizedBox(height: 16),

        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildWithdrawalsList(),
                    _buildRechargesList(),
                    _buildInvoicesList(),
                  ],
                ),
        )
      ],
    );
  }

  Widget _buildWithdrawalsList() {
    if (_withdrawals.isEmpty) {
      return const Center(child: Text('لا توجد طلبات سحب أرباح معلقة', style: TextStyle(color: DerbiColors.textMuted)));
    }
    return ListView.builder(
      itemCount: _withdrawals.length,
      itemBuilder: (ctx, i) {
        final w = _withdrawals[i];
        final isApproved = w['status'] == 'approved';

        return Card(
          color: DerbiColors.surfaceCard,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: DerbiColors.borderSlate)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isApproved ? DerbiColors.successEmerald.withValues(alpha: 0.15) : DerbiColors.warningAmber.withValues(alpha: 0.15),
              child: Icon(isApproved ? Icons.check_circle : Icons.account_balance, color: isApproved ? DerbiColors.successEmerald : DerbiColors.warningAmber),
            ),
            title: Text('طلب سحب: ${w['driver_name']} (${w['phone'] ?? ''})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
            subtitle: Text('المبلغ: ${w['amount']} • المصرف: ${w['bank_name']} • IBAN: ${w['iban']}', style: const TextStyle(fontSize: 11, color: DerbiColors.textMuted)),
            trailing: isApproved
                ? const Text('تم القبول', style: TextStyle(color: DerbiColors.successEmerald, fontWeight: FontWeight.bold, fontSize: 11))
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: DerbiColors.successEmerald),
                    onPressed: () => _processWithdrawalModal(context, w),
                    child: const Text('معالجة طلب السحب'),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildRechargesList() {
    if (_recharges.isEmpty) {
      return const Center(child: Text('لا توجد طلبات شحن محافظ', style: TextStyle(color: DerbiColors.textMuted)));
    }
    return ListView.builder(
      itemCount: _recharges.length,
      itemBuilder: (ctx, i) {
        final r = _recharges[i];
        final isCompleted = r['status'] == 'completed';

        return Card(
          color: DerbiColors.surfaceCard,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: DerbiColors.borderSlate)),
          child: ListTile(
            leading: const CircleAvatar(backgroundColor: DerbiColors.primaryBlue, child: Icon(Icons.account_balance_wallet, color: Colors.white)),
            title: Text('شحن محفظة: ${r['user_name']} (${r['phone'] ?? ''})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
            subtitle: Text('المبلغ: ${r['amount']} • الوسيلة: ${r['payment_method'] ?? 'سداد/موبي كاش'}', style: const TextStyle(fontSize: 11, color: DerbiColors.textMuted)),
            trailing: isCompleted
                ? const Text('مكتمل ومضاف', style: TextStyle(color: DerbiColors.successEmerald, fontWeight: FontWeight.bold, fontSize: 11))
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: DerbiColors.primaryBlue),
                    onPressed: () => _processRechargeModal(context, r),
                    child: const Text('تأكيد وإضافة الرصيد'),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildInvoicesList() {
    if (_invoices.isEmpty) {
      return const Center(child: Text('لا توجد فواتير صادرة', style: TextStyle(color: DerbiColors.textMuted)));
    }
    return ListView.builder(
      itemCount: _invoices.length,
      itemBuilder: (ctx, i) {
        final inv = _invoices[i];
        final isPaid = inv['status'] == 'paid';

        return Card(
          color: DerbiColors.surfaceCard,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: DerbiColors.borderSlate)),
          child: ListTile(
            leading: const CircleAvatar(backgroundColor: DerbiColors.surfaceCard, child: Icon(Icons.receipt, color: Colors.white)),
            title: Text('فاتورة رقم: ${inv['invoice_number']} • النوع: ${inv['type'] ?? 'اشتراك'}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
            subtitle: Text('المبلغ: ${inv['amount']} • التاريخ: ${inv['created_at']}', style: const TextStyle(fontSize: 11, color: DerbiColors.textMuted)),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isPaid ? DerbiColors.successEmerald.withValues(alpha: 0.15) : DerbiColors.dangerRose.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(isPaid ? 'مدفوعة' : 'غير مدفوعة', style: TextStyle(color: isPaid ? DerbiColors.successEmerald : DerbiColors.dangerRose, fontWeight: FontWeight.bold, fontSize: 11)),
            ),
          ),
        );
      },
    );
  }

  void _processWithdrawalModal(BuildContext context, Map<String, dynamic> w) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: DerbiColors.surfaceCard,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('معالجة طلب سحب: ${w['driver_name']}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          content: Text('المبلغ المستحق: ${w['amount']}\nالمصرف: ${w['bank_name']}\nIBAN: ${w['iban']}', style: const TextStyle(color: Colors.white, fontSize: 12)),
          actions: [
            TextButton(
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                final res = await _apiService.processWithdrawal(w['id'], action: 'reject', rejectionReason: 'بيانات غير مطابقة');
                if (ctx.mounted) Navigator.pop(ctx);
                messenger.showSnackBar(SnackBar(content: Text(res['message'] ?? 'تم رفض الطلب'), backgroundColor: DerbiColors.dangerRose));
                _loadFinancialData();
              },
              child: const Text('رفض الطلب', style: TextStyle(color: DerbiColors.dangerRose)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: DerbiColors.successEmerald),
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                final res = await _apiService.processWithdrawal(w['id'], action: 'approve');
                if (ctx.mounted) Navigator.pop(ctx);
                messenger.showSnackBar(SnackBar(content: Text(res['message'] ?? 'تمت الموافقة بنجاح!'), backgroundColor: DerbiColors.successEmerald));
                _loadFinancialData();
              },
              child: const Text('موافقة وصرف الأرباح'),
            ),
          ],
        ),
      ),
    );
  }

  void _processRechargeModal(BuildContext context, Map<String, dynamic> r) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: DerbiColors.surfaceCard,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('تأكيد شحن محفظة: ${r['user_name']}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          content: Text('مبلغ الشحن: ${r['amount']}\nوسيلة الدفع: ${r['payment_method'] ?? 'سداد'}', style: const TextStyle(color: Colors.white, fontSize: 12)),
          actions: [
            TextButton(
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                final res = await _apiService.processRecharge(r['id'], action: 'fail', reason: 'عدم توفر الرصيد');
                if (ctx.mounted) Navigator.pop(ctx);
                messenger.showSnackBar(SnackBar(content: Text(res['message'] ?? 'تم إلغاء الشحن'), backgroundColor: DerbiColors.dangerRose));
                _loadFinancialData();
              },
              child: const Text('إلغاء الشحن', style: TextStyle(color: DerbiColors.dangerRose)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: DerbiColors.primaryBlue),
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                final res = await _apiService.processRecharge(r['id'], action: 'complete');
                if (ctx.mounted) Navigator.pop(ctx);
                messenger.showSnackBar(SnackBar(content: Text(res['message'] ?? 'تم إضافة الرصيد للمحفظة بنجاح!'), backgroundColor: DerbiColors.successEmerald));
                _loadFinancialData();
              },
              child: const Text('إتمام وتأكيد الشحن'),
            ),
          ],
        ),
      ),
    );
  }
}
