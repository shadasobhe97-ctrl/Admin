import 'package:flutter/material.dart';
import '../../../../core/network/admin_api_service.dart';
import '../../../../core/theme/derbi_colors.dart';

/// 💰 الخزينة ودفتر الحسابات — محرك القيد المزدوج
/// يغطي: فحص الملاءة المالية، سجل الحركات (Ledger)، والعمليات المالية المتقدمة.
class TreasuryLedgerView extends StatefulWidget {
  const TreasuryLedgerView({super.key});

  @override
  State<TreasuryLedgerView> createState() => _TreasuryLedgerViewState();
}

class _TreasuryLedgerViewState extends State<TreasuryLedgerView>
    with SingleTickerProviderStateMixin {
  final AdminApiService _apiService = AdminApiService();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
        const Text(
          'الخزينة ودفتر الحسابات (محرك القيد المزدوج)',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.white),
        ),
        const SizedBox(height: 4),
        const Text(
          'مراقبة أرصدة المنصة، تدقيق الحركات المالية غير القابلة للمسح، وتنفيذ التسويات.',
          style: TextStyle(fontSize: 12, color: DerbiColors.textSecondary),
        ),
        const SizedBox(height: 20),

        TabBar(
          controller: _tabController,
          indicatorColor: DerbiColors.primaryBlue,
          labelColor: Colors.white,
          unselectedLabelColor: DerbiColors.textMuted,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(text: 'الملاءة المالية والأرصدة'),
            Tab(text: 'سجل الحركات (Ledger)'),
            Tab(text: 'العمليات والتسويات'),
          ],
        ),
        const SizedBox(height: 20),

        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _SolvencyTab(apiService: _apiService),
              _LedgerTab(apiService: _apiService),
              _OperationsTab(apiService: _apiService),
            ],
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 1. تبويب الملاءة المالية
// ═══════════════════════════════════════════════════════════════════════════

class _SolvencyTab extends StatefulWidget {
  final AdminApiService apiService;
  const _SolvencyTab({required this.apiService});

  @override
  State<_SolvencyTab> createState() => _SolvencyTabState();
}

class _SolvencyTabState extends State<_SolvencyTab> {
  bool _isLoading = true;
  bool _isReleasing = false;
  String? _message;
  Map<String, dynamic> _data = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final res = await widget.apiService.getSolvencyCheck();
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _data = res['data'] is Map<String, dynamic> ? res['data'] : {};
      _message = res['message'];
    });
  }

  Future<void> _releaseEscrows() async {
    setState(() => _isReleasing = true);
    final res = await widget.apiService.releaseEscrows();
    if (!mounted) return;
    setState(() => _isReleasing = false);

    final success = res['success'] == true || res['status'] == true;
    final count = res['data'] is Map ? res['data']['released_count'] : null;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          res['message'] ??
              (success ? 'تم تحرير الأرباح المعلقة بنجاح.' : 'تعذر تحرير الأرباح المعلقة.'),
        ),
        backgroundColor: success ? DerbiColors.successEmerald : DerbiColors.dangerRose,
      ),
    );
    if (success) {
      if (count != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('عدد الرحلات المحرَّرة: $count'),
            backgroundColor: DerbiColors.primaryBlue,
          ),
        );
      }
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: DerbiColors.primaryBlue));
    }

    final isSolvent = _data['is_solvent'] == true;
    final discrepancy = _data['discrepancy_cents'] ?? 0;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // شريط حالة الاتساق المالي
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: (isSolvent ? DerbiColors.successEmerald : DerbiColors.dangerRose)
                  .withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: (isSolvent ? DerbiColors.successEmerald : DerbiColors.dangerRose)
                    .withValues(alpha: 0.35),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (isSolvent ? DerbiColors.successEmerald : DerbiColors.dangerRose)
                        .withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isSolvent ? Icons.verified_rounded : Icons.warning_amber_rounded,
                    color: isSolvent ? DerbiColors.successEmerald : DerbiColors.dangerRose,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isSolvent ? 'النظام متسق مالياً' : 'تحذير: يوجد خلل في المعادلة المالية',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _message ?? 'فرق التسوية: $discrepancy قرش',
                        style: const TextStyle(color: DerbiColors.textSecondary, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: DerbiColors.borderSlate),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: _load,
                  icon: const Icon(Icons.refresh_rounded, size: 16, color: DerbiColors.primaryBlue),
                  label: const Text('إعادة الفحص', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          const Text(
            'أرصدة المحافظ الرئيسية',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 12),

          GridView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: MediaQuery.of(context).size.width > 1200 ? 4 : 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 2.0,
            ),
            children: [
              _PoolCard(
                label: 'أمانات أولياء الأمور',
                hint: 'محجوزة مقابل رحلات لم تُنفَّذ بعد',
                value: _data['parents_escrow_pool'],
                icon: Icons.lock_clock_rounded,
                color: DerbiColors.warningAmber,
              ),
              _PoolCard(
                label: 'أرباح السائقين المعلقة',
                hint: 'بانتظار مرور 24 ساعة للتحرير',
                value: _data['driver_pending_pool'],
                icon: Icons.hourglass_bottom_rounded,
                color: DerbiColors.infoCyan,
              ),
              _PoolCard(
                label: 'أرصدة السائقين المتاحة',
                hint: 'قابلة للسحب فوراً',
                value: _data['driver_available_pool'],
                icon: Icons.account_balance_wallet_rounded,
                color: DerbiColors.successEmerald,
              ),
              _PoolCard(
                label: 'إيرادات المنصة',
                hint: 'العمولات المحصَّلة',
                value: _data['platform_revenue_pool'],
                icon: Icons.trending_up_rounded,
                color: DerbiColors.primaryBlue,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // إجمالي الخزينة + إجراء تحرير الأرباح
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: DerbiColors.surfaceCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: DerbiColors.borderSlate),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'إجمالي الخزينة المحسوب',
                        style: TextStyle(color: DerbiColors.textSecondary, fontSize: 11),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _formatDinar(_data['total_calculated_dinar']),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 26,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'تحرير الأرباح المعلقة',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'ينقل أرباح الرحلات المكتملة منذ أكثر من 24 ساعة إلى رصيد السائق المتاح، مع اقتطاع عمولة المنصة.',
                        style: TextStyle(color: DerbiColors.textMuted, fontSize: 11),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: DerbiColors.successEmerald,
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: _isReleasing ? null : _confirmRelease,
                        icon: _isReleasing
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.lock_open_rounded, size: 16, color: Colors.white),
                        label: const Text(
                          'تنفيذ تحرير الأرباح الآن',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmRelease() {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: DerbiColors.surfaceCard,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            'تأكيد تحرير الأرباح المعلقة',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          content: const Text(
            'سيتم نقل أرباح كل الرحلات المستحقة إلى الأرصدة المتاحة للسائقين واقتطاع عمولة المنصة. هذه العملية تُسجَّل في دفتر الحسابات ولا يمكن التراجع عنها.',
            style: TextStyle(color: DerbiColors.textSecondary, fontSize: 13),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء', style: TextStyle(color: DerbiColors.textMuted)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: DerbiColors.successEmerald),
              onPressed: () {
                Navigator.pop(ctx);
                _releaseEscrows();
              },
              child: const Text('تأكيد التنفيذ'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PoolCard extends StatelessWidget {
  final String label;
  final String hint;
  final dynamic value;
  final IconData icon;
  final Color color;

  const _PoolCard({
    required this.label,
    required this.hint,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DerbiColors.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: DerbiColors.borderSlate),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: DerbiColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Icon(icon, color: color, size: 18),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _formatDinar(value),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Text(
            hint,
            style: const TextStyle(fontSize: 10, color: DerbiColors.textMuted),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

String _formatDinar(dynamic value) {
  if (value == null) return '0.00 د.ل';
  final numeric = value is num ? value : num.tryParse(value.toString()) ?? 0;
  return '${numeric.toStringAsFixed(2)} د.ل';
}

// ═══════════════════════════════════════════════════════════════════════════
// 2. تبويب سجل الحركات (Ledger)
// ═══════════════════════════════════════════════════════════════════════════

class _LedgerTab extends StatefulWidget {
  final AdminApiService apiService;
  const _LedgerTab({required this.apiService});

  @override
  State<_LedgerTab> createState() => _LedgerTabState();
}

class _LedgerTabState extends State<_LedgerTab> {
  bool _isLoading = true;
  List<dynamic> _entries = [];
  String? _selectedType;
  int _page = 1;

  /// أنواع الحركات المالية المعتمدة في المحرك
  static const Map<String?, String> _types = {
    null: 'كل الأنواع',
    'trip_hold': 'حجز مبلغ رحلة',
    'trip_release': 'تحرير أرباح رحلة',
    'wallet_recharge': 'شحن محفظة',
    'withdrawal': 'سحب أرباح',
    'commission': 'عمولة المنصة',
    'refund': 'استرجاع مبلغ',
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final res = await widget.apiService.getLedger(type: _selectedType, page: _page);
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _entries = res['data'] is List ? res['data'] : [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // شريط الفلترة
        Row(
          children: [
            const Icon(Icons.filter_alt_outlined, size: 18, color: DerbiColors.textMuted),
            const SizedBox(width: 8),
            const Text(
              'تصفية حسب نوع الحركة:',
              style: TextStyle(color: DerbiColors.textSecondary, fontSize: 12),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _types.entries.map((e) {
                  final isSel = _selectedType == e.key;
                  return ChoiceChip(
                    label: Text(e.value),
                    selected: isSel,
                    selectedColor: DerbiColors.primaryBlue,
                    backgroundColor: DerbiColors.surfaceCard,
                    labelStyle: TextStyle(
                      color: isSel ? Colors.white : DerbiColors.textSecondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                    onSelected: (_) {
                      setState(() {
                        _selectedType = e.key;
                        _page = 1;
                      });
                      _load();
                    },
                  );
                }).toList(),
              ),
            ),
            IconButton(
              tooltip: 'تحديث السجل',
              icon: const Icon(Icons.refresh, color: DerbiColors.primaryBlue),
              onPressed: _load,
            ),
          ],
        ),
        const SizedBox(height: 16),

        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: DerbiColors.primaryBlue))
              : _entries.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.receipt_long_outlined, size: 60, color: DerbiColors.textMuted),
                          SizedBox(height: 12),
                          Text(
                            'لا توجد حركات مالية مطابقة لهذه التصفية',
                            style: TextStyle(color: DerbiColors.textMuted),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _entries.length,
                      itemBuilder: (ctx, i) => _LedgerEntryCard(entry: _entries[i], types: _types),
                    ),
        ),

        // شريط الترقيم
        if (!_isLoading && (_entries.isNotEmpty || _page > 1))
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: DerbiColors.borderSlate),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _page > 1
                      ? () {
                          setState(() => _page--);
                          _load();
                        }
                      : null,
                  icon: const Icon(Icons.chevron_right, size: 16),
                  label: const Text('السابق'),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'صفحة $_page',
                    style: const TextStyle(
                      color: DerbiColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: DerbiColors.borderSlate),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _entries.isEmpty
                      ? null
                      : () {
                          setState(() => _page++);
                          _load();
                        },
                  icon: const Icon(Icons.chevron_left, size: 16),
                  label: const Text('التالي'),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _LedgerEntryCard extends StatelessWidget {
  final Map<String, dynamic> entry;
  final Map<String?, String> types;

  const _LedgerEntryCard({required this.entry, required this.types});

  @override
  Widget build(BuildContext context) {
    final type = entry['type']?.toString();
    final typeLabel = types[type] ?? type ?? 'حركة';
    final isCompleted = entry['status'] == 'completed';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: DerbiColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DerbiColors.borderSlate),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: DerbiColors.primaryBlue.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.swap_horiz_rounded,
                    color: DerbiColors.primaryBlue, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          typeLabel,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: DerbiColors.background,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: DerbiColors.borderSlate),
                          ),
                          child: Text(
                            entry['reference_number']?.toString() ?? '—',
                            style: const TextStyle(
                              fontSize: 10,
                              color: DerbiColors.textMuted,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: (isCompleted
                                    ? DerbiColors.successEmerald
                                    : DerbiColors.warningAmber)
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isCompleted ? 'مكتملة' : (entry['status']?.toString() ?? 'معلقة'),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isCompleted
                                  ? DerbiColors.successEmerald
                                  : DerbiColors.warningAmber,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'التاريخ: ${entry['created_at'] ?? '—'}   •   المعرّف: ${entry['transaction_id'] ?? '—'}',
                      style: const TextStyle(fontSize: 10, color: DerbiColors.textMuted),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Text(
                _formatDinar(entry['amount_dinar']),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(color: DerbiColors.borderSlate, height: 1),
          const SizedBox(height: 14),

          // مسار القيد المزدوج: من حساب ← إلى حساب
          Row(
            children: [
              Expanded(
                child: _AccountChip(
                  title: 'من حساب',
                  account: entry['source_account']?.toString() ?? '—',
                  color: DerbiColors.dangerRose,
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Icon(Icons.arrow_back_rounded, color: DerbiColors.textMuted, size: 18),
              ),
              Expanded(
                child: _AccountChip(
                  title: 'إلى حساب',
                  account: entry['destination_account']?.toString() ?? '—',
                  color: DerbiColors.successEmerald,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'الرصيد قبل ← بعد',
                      style: TextStyle(fontSize: 10, color: DerbiColors.textMuted),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${entry['balance_before'] ?? '—'}  ←  ${entry['balance_after'] ?? '—'}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: DerbiColors.textSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AccountChip extends StatelessWidget {
  final String title;
  final String account;
  final Color color;

  const _AccountChip({required this.title, required this.account, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(
            account,
            style: const TextStyle(fontSize: 11, color: Colors.white),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 3. تبويب العمليات والتسويات
// ═══════════════════════════════════════════════════════════════════════════

class _OperationsTab extends StatefulWidget {
  final AdminApiService apiService;
  const _OperationsTab({required this.apiService});

  @override
  State<_OperationsTab> createState() => _OperationsTabState();
}

class _OperationsTabState extends State<_OperationsTab> {
  final _disputeIdController = TextEditingController();
  final _disputeNotesController = TextEditingController();
  String _disputeResolution = 'resolve_parent_refunded';

  final _settleContractIdController = TextEditingController();
  final _terminateContractIdController = TextEditingController();
  String _terminatedBy = 'parent';
  bool _isArbitraryParent = false;

  final _tripIdController = TextEditingController();
  String _cancelledBy = 'parent';

  bool _busy = false;

  @override
  void dispose() {
    _disputeIdController.dispose();
    _disputeNotesController.dispose();
    _settleContractIdController.dispose();
    _terminateContractIdController.dispose();
    _tripIdController.dispose();
    super.dispose();
  }

  void _snack(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
  }

  Future<void> _run(Future<Map<String, dynamic>> Function() action,
      {required String Function(Map<String, dynamic>) onSuccess}) async {
    setState(() => _busy = true);
    final res = await action();
    if (!mounted) return;
    setState(() => _busy = false);

    final success = res['success'] == true || res['status'] == true;
    _snack(
      success ? onSuccess(res) : (res['message'] ?? 'تعذر تنفيذ العملية.'),
      success ? DerbiColors.successEmerald : DerbiColors.dangerRose,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _OperationCard(
            icon: Icons.gavel_rounded,
            color: DerbiColors.warningAmber,
            title: 'فض النزاع المالي',
            description:
                'حسم نزاع مالي بين ولي الأمر والسائق، وتحديد الجهة المستحقة للمبلغ المتنازع عليه.',
            fields: [
              _idField(_disputeIdController, 'رقم النزاع (Dispute ID)'),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _disputeResolution,
                dropdownColor: DerbiColors.surfaceCard,
                style: const TextStyle(color: Colors.white, fontSize: 12),
                decoration: const InputDecoration(labelText: 'قرار الحسم'),
                items: const [
                  DropdownMenuItem(
                    value: 'resolve_parent_refunded',
                    child: Text('لصالح ولي الأمر (إرجاع المبلغ)'),
                  ),
                  DropdownMenuItem(
                    value: 'resolve_driver_paid',
                    child: Text('لصالح السائق (صرف المبلغ)'),
                  ),
                ],
                onChanged: (v) => setState(() => _disputeResolution = v ?? _disputeResolution),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _disputeNotesController,
                maxLines: 2,
                style: const TextStyle(color: Colors.white, fontSize: 12),
                decoration: const InputDecoration(labelText: 'ملاحظات القرار'),
              ),
            ],
            actionLabel: 'تنفيذ حسم النزاع',
            actionColor: DerbiColors.warningAmber,
            onAction: _busy || _disputeIdController.text.trim().isEmpty
                ? null
                : () => _run(
                      () => widget.apiService.resolveDispute(
                        _disputeIdController.text.trim(),
                        resolution: _disputeResolution,
                        notes: _disputeNotesController.text.trim(),
                      ),
                      onSuccess: (res) => res['message'] ?? 'تم حل النزاع المالي بنجاح.',
                    ),
          ),
          const SizedBox(height: 16),

          _OperationCard(
            icon: Icons.fact_check_rounded,
            color: DerbiColors.successEmerald,
            title: 'التسوية الشهرية للعقد',
            description:
                'إجراء المقاصة النهائية للعقد الشهري: احتساب المبلغ المستحق نهائياً وترحيل رصيد الرحلات غير المنفذة.',
            fields: [_idField(_settleContractIdController, 'رقم العقد (Contract ID)')],
            actionLabel: 'تنفيذ التسوية الشهرية',
            actionColor: DerbiColors.successEmerald,
            onAction: _busy || _settleContractIdController.text.trim().isEmpty
                ? null
                : () => _run(
                      () => widget.apiService
                          .settleContractMonthly(_settleContractIdController.text.trim()),
                      onSuccess: (res) {
                        final d = res['data'];
                        if (d is Map) {
                          return 'تمت تسوية العقد ${d['contract_number'] ?? ''} — '
                              'المبلغ النهائي: ${_formatDinar(d['final_settled_amount'])} '
                              '• رصيد مرحَّل: ${_formatDinar(d['rollover_refund_credit'])}';
                        }
                        return 'تمت التسوية الشهرية بنجاح.';
                      },
                    ),
          ),
          const SizedBox(height: 16),

          _OperationCard(
            icon: Icons.event_busy_rounded,
            color: DerbiColors.dangerRose,
            title: 'إنهاء العقد في منتصف الشهر',
            description:
                'الإلغاء المبكر للعقد مع احتساب تكلفة ما تم تنفيذه والمبلغ المسترجع لولي الأمر.',
            fields: [
              _idField(_terminateContractIdController, 'رقم العقد (Contract ID)'),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _terminatedBy,
                dropdownColor: DerbiColors.surfaceCard,
                style: const TextStyle(color: Colors.white, fontSize: 12),
                decoration: const InputDecoration(labelText: 'جهة الإنهاء'),
                items: const [
                  DropdownMenuItem(value: 'parent', child: Text('ولي الأمر')),
                  DropdownMenuItem(value: 'driver', child: Text('السائق')),
                ],
                onChanged: (v) => setState(() => _terminatedBy = v ?? _terminatedBy),
              ),
              const SizedBox(height: 4),
              CheckboxListTile(
                value: _isArbitraryParent,
                onChanged: (v) => setState(() => _isArbitraryParent = v ?? false),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                dense: true,
                activeColor: DerbiColors.dangerRose,
                title: const Text(
                  'إنهاء تعسفي من ولي الأمر (تُطبَّق غرامة)',
                  style: TextStyle(color: DerbiColors.textSecondary, fontSize: 12),
                ),
              ),
            ],
            actionLabel: 'تنفيذ الإنهاء المبكر',
            actionColor: DerbiColors.dangerRose,
            onAction: _busy || _terminateContractIdController.text.trim().isEmpty
                ? null
                : () => _confirmDestructive(
                      'تأكيد إنهاء العقد مبكراً',
                      'سيتم إنهاء العقد رقم ${_terminateContractIdController.text.trim()} واحتساب المقاصة المالية. لا يمكن التراجع عن هذه العملية.',
                      () => _run(
                        () => widget.apiService.terminateContractMidMonth(
                          _terminateContractIdController.text.trim(),
                          terminatedBy: _terminatedBy,
                          isArbitraryParent: _isArbitraryParent,
                        ),
                        onSuccess: (res) {
                          final d = res['data'];
                          if (d is Map) {
                            return 'تم إنهاء العقد — التكلفة المنفَّذة: ${_formatDinar(d['executed_cost'])} '
                                '• المسترجع لولي الأمر: ${_formatDinar(d['refunded_to_parent'])}';
                          }
                          return 'تم إنهاء العقد بنجاح.';
                        },
                      ),
                    ),
          ),
          const SizedBox(height: 16),

          _OperationCard(
            icon: Icons.rule_rounded,
            color: DerbiColors.infoCyan,
            title: 'إلغاء رحلة بمصفوفة الغرامات',
            description:
                'إلغاء رحلة محددة وتطبيق سياسة مصفوفة الغرامات لتحديد المسترجع لولي الأمر والمستحق للسائق.',
            fields: [
              _idField(_tripIdController, 'رقم الرحلة (Trip ID)'),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _cancelledBy,
                dropdownColor: DerbiColors.surfaceCard,
                style: const TextStyle(color: Colors.white, fontSize: 12),
                decoration: const InputDecoration(labelText: 'جهة الإلغاء'),
                items: const [
                  DropdownMenuItem(value: 'parent', child: Text('ولي الأمر')),
                  DropdownMenuItem(value: 'driver', child: Text('السائق')),
                ],
                onChanged: (v) => setState(() => _cancelledBy = v ?? _cancelledBy),
              ),
            ],
            actionLabel: 'إلغاء الرحلة وتطبيق المصفوفة',
            actionColor: DerbiColors.infoCyan,
            onAction: _busy || _tripIdController.text.trim().isEmpty
                ? null
                : () => _confirmDestructive(
                      'تأكيد إلغاء الرحلة',
                      'سيتم إلغاء الرحلة رقم ${_tripIdController.text.trim()} وتطبيق مصفوفة الغرامات مالياً.',
                      () => _run(
                        () => widget.apiService.cancelTripWithMatrix(
                          _tripIdController.text.trim(),
                          cancelledBy: _cancelledBy,
                        ),
                        onSuccess: (res) {
                          final d = res['data'];
                          if (d is Map) {
                            return 'تم الإلغاء — المسترجع لولي الأمر: ${_formatDinar(d['parent_refund_dinar'])} '
                                '• المستحق للسائق: ${_formatDinar(d['driver_pay_dinar'])}';
                          }
                          return 'تم إلغاء الرحلة بنجاح.';
                        },
                      ),
                    ),
          ),
        ],
      ),
    );
  }

  Widget _idField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      style: const TextStyle(color: Colors.white, fontSize: 12),
      decoration: InputDecoration(labelText: label),
      onChanged: (_) => setState(() {}), // لتفعيل/تعطيل زر التنفيذ
    );
  }

  void _confirmDestructive(String title, String body, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: DerbiColors.surfaceCard,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(title,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          content: Text(body,
              style: const TextStyle(color: DerbiColors.textSecondary, fontSize: 13)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء', style: TextStyle(color: DerbiColors.textMuted)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: DerbiColors.dangerRose),
              onPressed: () {
                Navigator.pop(ctx);
                onConfirm();
              },
              child: const Text('تأكيد التنفيذ'),
            ),
          ],
        ),
      ),
    );
  }
}

class _OperationCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String description;
  final List<Widget> fields;
  final String actionLabel;
  final Color actionColor;
  final VoidCallback? onAction;

  const _OperationCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
    required this.fields,
    required this.actionLabel,
    required this.actionColor,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: DerbiColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DerbiColors.borderSlate),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(color: DerbiColors.textMuted, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: DerbiColors.borderSlate, height: 1),
          const SizedBox(height: 16),
          ...fields,
          const SizedBox(height: 16),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: actionColor,
                disabledBackgroundColor: DerbiColors.borderSlate,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: onAction,
              icon: const Icon(Icons.play_arrow_rounded, size: 18, color: Colors.white),
              label: Text(
                actionLabel,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
