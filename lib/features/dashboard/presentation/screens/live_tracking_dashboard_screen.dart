import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../../core/theme/derbi_colors.dart';

class LiveTrackingDashboardView extends StatefulWidget {
  const LiveTrackingDashboardView({super.key});

  @override
  State<LiveTrackingDashboardView> createState() => _LiveTrackingDashboardViewState();
}

class _LiveTrackingDashboardViewState extends State<LiveTrackingDashboardView> {
  bool _isLoading = true;
  String? _errorMessage;
  
  // خريطة لتخزين الإحصائيات السبعة القادمة من الباك إند
  Map<String, dynamic> _statsData = {};

  @override
  void initState() {
    super.initState();
    _fetchDashboardStats();
  }

  // دالة جلب الإحصائيات من الـ Endpoint الحقيقي
  Future<void> _fetchDashboardStats() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final url = Uri.parse('http://localhost:8000/api/admin/dashboard/stats');
      const String adminToken = 'YOUR_ADMIN_TOKEN'; 

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $adminToken',
        },
      ).timeout(const Duration(seconds: 12));

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);
        
        if (decodedResponse['success'] == true || decodedResponse['status'] == true) {
          setState(() {
            _statsData = decodedResponse['data'] ?? {};
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = decodedResponse['message'] ?? 'فشل في استرجاع البيانات من الخادم.';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = 'خطأ في الخادم (رمز الاستجابة: ${response.statusCode})';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'تعذر الاتصال بالخادم. تأكد من اتصال الإنترنت أو صحة رابط الـ API.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header & Refresh Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
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
                    'مرتبط مباشرة بقاعدة بيانات منظومة دَرْبي (Laravel API - Dashboard Stats)',
                    style: TextStyle(
                      fontSize: 12,
                      color: DerbiColors.textSecondary,
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: DerbiColors.primaryBlue,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: _fetchDashboardStats,
                icon: const Icon(Icons.refresh_rounded, size: 16, color: Colors.white),
                label: const Text('تحديث البيانات', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                    onPressed: _fetchDashboardStats,
                    child: const Text('إعادة المحاولة', style: TextStyle(color: DerbiColors.primaryBlue)),
                  )
                ],
              ),
            )
          else ...[
            // 3. The 7 Official Stats Cards Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: MediaQuery.of(context).size.width > 1200 ? 4 : (MediaQuery.of(context).size.width > 800 ? 3 : 2),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 2.1,
              ),
              itemCount: _statsData.keys.length,
              itemBuilder: (context, index) {
                final key = _statsData.keys.elementAt(index);
                final item = _statsData[key] ?? {};
                
                return _ApiStatCard(
                  title: item['label'] ?? key,
                  value: '${item['value'] ?? '0'}',
                  change: item['change'] ?? '',
                  trend: item['trend'] ?? 'info',
                  icon: _getIconForStatKey(key),
                );
              },
            ),
            const SizedBox(height: 24),

            // 4. Radar / Operational Status Box
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: DerbiColors.surfaceCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: DerbiColors.borderSlate),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: DerbiColors.successEmerald.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.verified_user_rounded, color: DerbiColors.successEmerald, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'حالة الربط مع خادم قاعدة البيانات نشطة وآمنة',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'جميع المؤشرات أعلاه تُسترجع في الوقت الفعلي عبر الـ API باستخدام الاستعلامات المعتمدة.',
                          style: TextStyle(color: DerbiColors.textSecondary, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: DerbiColors.primaryBlue.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Sanctum Verified',
                      style: TextStyle(color: DerbiColors.primaryBlue, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ربط الأيقونات المناسبة حسب مفتاح الإحصائية القادم من الباك إند
  IconData _getIconForStatKey(String key) {
    switch (key) {
      case 'total_users':
        return Icons.group_rounded;
      case 'active_drivers':
        return Icons.badge_rounded;
      case 'total_parents':
        return Icons.family_restroom_rounded;
      case 'subscribed_children':
        return Icons.child_care_rounded;
      case 'daily_subscriptions':
        return Icons.today_rounded;
      case 'monthly_subscriptions':
        return Icons.calendar_month_rounded;
      case 'drivers_with_active_trips':
        return Icons.navigation_rounded;
      default:
        return Icons.analytics_rounded;
    }
  }
}

// Widget مخصص لعرض كارد الإحصائية بشكل أنيق ومتوافق مع بيانات الـ API
class _ApiStatCard extends StatelessWidget {
  final String title;
  final String value;
  final String change;
  final String trend;
  final IconData icon;

  const _ApiStatCard({
    required this.title,
    required this.value,
    required this.change,
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
    } else {
      trendColor = DerbiColors.textMuted;
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  change,
                  style: TextStyle(fontSize: 9, color: trendColor, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}