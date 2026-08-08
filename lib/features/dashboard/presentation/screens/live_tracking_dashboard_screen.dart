import 'package:flutter/material.dart';
import '../../../../core/network/admin_api_service.dart';
import '../../../../core/theme/derbi_colors.dart';

class LiveTrackingDashboardView extends StatefulWidget {
  const LiveTrackingDashboardView({super.key});

  @override
  State<LiveTrackingDashboardView> createState() => _LiveTrackingDashboardViewState();
}

class _LiveTrackingDashboardViewState extends State<LiveTrackingDashboardView> {
  final AdminApiService _apiService = AdminApiService();

  bool _isLoading = true;
  bool _isGenerating = false;
  String? _errorMessage;

  Map<String, dynamic> _statsData = {};
  List<dynamic> _activeTrips = [];

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final statsRes = await _apiService.getDashboardStats();
      final trips = await _apiService.getActiveTrips();

      if (!mounted) return;

      final success = statsRes['success'] == true || statsRes['status'] == true;
      if (success) {
        setState(() {
          _statsData = statsRes['data'] is Map<String, dynamic> ? statsRes['data'] : {};
          _activeTrips = trips;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = statsRes['message'] ?? 'فشل في استرجاع البيانات من الخادم.';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'تعذر الاتصال بالخادم. تأكد من اتصال الإنترنت أو صحة رابط الـ API.';
        _isLoading = false;
      });
    }
  }

  Future<void> _generateDailyTrips() async {
    setState(() => _isGenerating = true);
    final res = await _apiService.generateDailyTrips();
    if (!mounted) return;
    setState(() => _isGenerating = false);

    final success = res['success'] == true || res['status'] == true;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          res['message'] ?? (success ? 'تم توليد رحلات اليوم بنجاح.' : 'تعذر توليد رحلات اليوم.'),
        ),
        backgroundColor: success ? DerbiColors.successEmerald : DerbiColors.dangerRose,
      ),
    );
    if (success) {
      _fetchDashboardData();
    }
  }

  static const Map<String, _StatMeta> _statMeta = {
    'total_users': _StatMeta('إجمالي المستخدمين', Icons.group_rounded, 'up'),
    'total_drivers': _StatMeta('إجمالي السائقين', Icons.badge_rounded, 'up'),
    'pending_drivers': _StatMeta('سائقون بانتظار المراجعة', Icons.hourglass_top_rounded, 'warning'),
    'total_parents': _StatMeta('إجمالي أولياء الأمور', Icons.family_restroom_rounded, 'info'),
    'active_subscriptions': _StatMeta('الاشتراكات النشطة', Icons.verified_rounded, 'up'),
    'active_trips_today': _StatMeta('الرحلات النشطة اليوم', Icons.navigation_rounded, 'live'),
    'total_revenue_dinar': _StatMeta('إجمالي الإيرادات (د.ل)', Icons.payments_rounded, 'info'),
  };

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header & Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'لوحة المتابعة الشاملة والإحصائيات الحية',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'مرتبط مباشرة بقاعدة بيانات منظومة دَرْبي (Laravel API)',
                    style: TextStyle(
                      fontSize: 12,
                      color: DerbiColors.textSecondary,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: DerbiColors.borderSlate),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: _isGenerating ? null : _generateDailyTrips,
                    icon: _isGenerating
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2, color: DerbiColors.primaryBlue),
                          )
                        : const Icon(Icons.auto_awesome_rounded, size: 16, color: DerbiColors.primaryBlue),
                    label: const Text('توليد رحلات اليوم', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DerbiColors.primaryBlue,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: _isLoading ? null : _fetchDashboardData,
                    icon: const Icon(Icons.refresh_rounded, size: 16, color: Colors.white),
                    label: const Text('تحديث البيانات', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 2. Loading State / Error State / Data Display
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(50.0),
                child: CircularProgressIndicator(color: DerbiColors.primaryBlue),
              ),
            )
          else if (_errorMessage != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: DerbiColors.dangerRose.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: DerbiColors.dangerRose.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: DerbiColors.dangerRose),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                  TextButton(
                    onPressed: _fetchDashboardData,
                    child: const Text('إعادة المحاولة', style: TextStyle(color: DerbiColors.primaryBlue)),
                  )
                ],
              ),
            )
          else ...[
            // 3. Stats Cards Grid (مطابقة لتوثيق /admin/dashboard/stats)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: MediaQuery.of(context).size.width > 1200 ? 4 : (MediaQuery.of(context).size.width > 800 ? 3 : 2),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 2.1,
              ),
              itemCount: _statMeta.length,
              itemBuilder: (context, index) {
                final key = _statMeta.keys.elementAt(index);
                final meta = _statMeta[key]!;
                final rawValue = _statsData[key];

                return _ApiStatCard(
                  title: meta.label,
                  value: _formatStatValue(key, rawValue),
                  trend: meta.trend,
                  icon: meta.icon,
                );
              },
            ),
            const SizedBox(height: 24),

            // 4. Radar / Active Trips Now
            Container(
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
                          color: DerbiColors.successEmerald.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.radar_rounded, color: DerbiColors.successEmerald, size: 22),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'الرادار الحي للرحلات النشطة الآن',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: DerbiColors.primaryBlue.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${_activeTrips.length} رحلة نشطة',
                          style: const TextStyle(color: DerbiColors.primaryBlue, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_activeTrips.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Text('لا توجد رحلات نشطة في الوقت الحالي', style: TextStyle(color: DerbiColors.textMuted, fontSize: 12)),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _activeTrips.length,
                      separatorBuilder: (_, __) => const Divider(color: DerbiColors.borderSlate, height: 20),
                      itemBuilder: (ctx, i) {
                        final trip = _activeTrips[i] as Map<String, dynamic>;
                        return Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: DerbiColors.successEmerald.withValues(alpha: 0.15),
                              child: const Icon(Icons.local_shipping_rounded, color: DerbiColors.successEmerald, size: 18),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    trip['driver_name'] ?? 'سائق غير معروف',
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'رحلة #${trip['trip_id']} • بدأت ${trip['started_at'] ?? ''} • ${trip['students_count'] ?? 0} طالب',
                                    style: const TextStyle(color: DerbiColors.textMuted, fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: DerbiColors.successEmerald.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                _tripStatusLabel(trip['status']),
                                style: const TextStyle(color: DerbiColors.successEmerald, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatStatValue(String key, dynamic value) {
    if (value == null) return '0';
    if (key == 'total_revenue_dinar') {
      final numeric = value is num ? value : num.tryParse(value.toString()) ?? 0;
      return '${numeric.toStringAsFixed(2)} د.ل';
    }
    return value.toString();
  }

  String _tripStatusLabel(dynamic status) {
    switch (status) {
      case 'in_progress':
        return 'قيد التنفيذ';
      case 'completed':
        return 'مكتملة';
      case 'pending':
        return 'بالانتظار';
      default:
        return status?.toString() ?? 'غير معروف';
    }
  }
}

class _StatMeta {
  final String label;
  final IconData icon;
  final String trend;
  const _StatMeta(this.label, this.icon, this.trend);
}

// Widget مخصص لعرض كارد الإحصائية بشكل أنيق ومتوافق مع بيانات الـ API
class _ApiStatCard extends StatelessWidget {
  final String title;
  final String value;
  final String trend;
  final IconData icon;

  const _ApiStatCard({
    required this.title,
    required this.value,
    required this.trend,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    Color trendColor;
    if (trend == 'up') {
      trendColor = DerbiColors.successEmerald;
    } else if (trend == 'live') {
      trendColor = DerbiColors.primaryBlue;
    } else if (trend == 'warning') {
      trendColor = DerbiColors.warningAmber;
    } else {
      trendColor = DerbiColors.infoCyan;
    }

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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 11, color: DerbiColors.textSecondary, fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Icon(icon, color: trendColor, size: 18),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
