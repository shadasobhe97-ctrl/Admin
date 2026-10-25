import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/admin_colors.dart';
import '../../../../core/utils/admin_theme_context.dart';
import '../../data/models/active_trip_model.dart';
import '../../data/models/trip_emergency_detail_model.dart';
import '../../data/repositories/dashboard_repository.dart';

class TripEmergencyInspectorModal extends StatefulWidget {
  final int? dispatchId;
  final int? tripId;
  final ActiveTripModel? initialTrip;

  const TripEmergencyInspectorModal({
    super.key,
    this.dispatchId,
    this.tripId,
    this.initialTrip,
  });

  static Future<void> show(
    BuildContext context, {
    int? dispatchId,
    int? tripId,
    ActiveTripModel? trip,
  }) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Material(
        color: Colors.transparent,
        child: Container(
          height: MediaQuery.of(context).size.height * 0.92,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: TripEmergencyInspectorModal(
            dispatchId: dispatchId ?? trip?.emergencyDispatchId,
            tripId: tripId ?? trip?.tripId,
            initialTrip: trip,
          ),
        ),
      ),
    );
  }

  @override
  State<TripEmergencyInspectorModal> createState() =>
      _TripEmergencyInspectorModalState();
}

class _TripEmergencyInspectorModalState
    extends State<TripEmergencyInspectorModal> {
  final DashboardRepository _repository = sl<DashboardRepository>();

  TripEmergencyDetailModel? _emergencyData;
  bool _isLoading = true;
  String? _errorMessage;
  bool _isActionInProgress = false;

  @override
  void initState() {
    super.initState();
    _loadEmergencyData();
  }

  Future<void> _loadEmergencyData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      dynamic targetId = widget.dispatchId;
      if (targetId == null || targetId == 0) {
        if (widget.initialTrip?.emergencyDispatchId != null &&
            widget.initialTrip!.emergencyDispatchId != 0) {
          targetId = widget.initialTrip!.emergencyDispatchId;
        }
      }

      // إذا لم يتوفر dispatchId مباشرة وكان لدينا tripId فقط، نبحث في قائمة الطوارئ
      if (targetId == null || targetId == 0) {
        final fallbackTripId = widget.tripId ?? widget.initialTrip?.tripId;
        if (fallbackTripId != null && fallbackTripId != 0) {
          try {
            final res = await _repository.getEmergenciesList(page: 1);
            final match = res.items
                .where(
                    (e) => e.tripId == fallbackTripId || e.id == fallbackTripId)
                .firstOrNull;
            if (match != null) {
              targetId = match.dispatchId > 0 ? match.dispatchId : match.id;
            }
          } catch (_) {}
          targetId ??= fallbackTripId;
        }
      }

      if (targetId == null || targetId == 0) {
        setState(() {
          _errorMessage = 'لم يتم العثور على معرّف لبلاغ الطوارئ.';
          _isLoading = false;
        });
        return;
      }

      final data = await _repository.getEmergencyDetails(targetId);
      if (mounted) {
        setState(() {
          _emergencyData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        final errStr = e.toString().replaceAll('Exception: ', '').trim();
        setState(() {
          _errorMessage =
              errStr.isNotEmpty ? errStr : 'تعذر تحميل تفاصيل الطوارئ.';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _resolveEmergency() async {
    final dispatchId = _emergencyData?.dispatchId ?? widget.dispatchId;
    if (dispatchId == null || dispatchId == 0) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حل وإغلاق حالة الطوارئ'),
        content: const Text(
          'هل تم الانتهاء من معالجة العطل ونقل كافة الأطفال بسلام؟ سيتم إغلاق البلاغ نهائياً.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AdminColors.statusSuccess,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('تأكيد الإغلاق'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isActionInProgress = true);
    try {
      await _repository.resolveEmergency(dispatchId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AdminColors.statusSuccess,
            content: Text('تم حل وإغلاق حالة الطوارئ بنجاح.'),
          ),
        );
        _loadEmergencyData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AdminColors.statusDanger,
            content: Text(
                'فشل إغلاق البلاغ: ${e.toString().replaceAll('Exception: ', '')}'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isActionInProgress = false);
      }
    }
  }

  Future<void> _assignSubstituteDriver(int driverId, String driverName) async {
    final dispatchId = _emergencyData?.dispatchId ?? widget.dispatchId;
    if (dispatchId == null || dispatchId == 0) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تكليف سائق بديل للرحلة'),
        content: Text(
          'هل أنت متأكد من تكليف السائق "$driverName" كبديل لإنقاذ هذه الرحلة المعطلة وتوصيل الأطفال؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AdminColors.brandPrimary,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('تأكيد التكليف'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isActionInProgress = true);
    try {
      await _repository.assignSubstituteDriver(dispatchId, driverId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AdminColors.statusSuccess,
            content: Text('تم تكليف السائق $driverName بنجاح لهذه الرحلة.'),
          ),
        );
        _loadEmergencyData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AdminColors.statusDanger,
            content: Text(
                'فشل تكليف السائق: ${e.toString().replaceAll('Exception: ', '')}'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isActionInProgress = false);
      }
    }
  }

  void _copyText(String text, String label) {
    if (text.trim().isEmpty) return;
    Clipboard.setData(ClipboardData(text: text.trim()));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم نسخ $label ($text)'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _formatDateTimeArabic(String? raw) {
    if (raw == null || raw.trim().isEmpty) return '-';
    try {
      final dt = DateTime.parse(raw).toLocal();
      const months = [
        'يناير',
        'فبراير',
        'مارس',
        'أبريل',
        'مايو',
        'يونيو',
        'يوليو',
        'أغسطس',
        'سبتمبر',
        'أكتوبر',
        'نوفمبر',
        'ديسمبر'
      ];
      const weekdays = [
        'الإثنين',
        'الثلاثاء',
        'الأربعاء',
        'الخميس',
        'الجمعة',
        'السبت',
        'الأحد'
      ];

      final weekday = weekdays[dt.weekday - 1];
      final day = dt.day;
      final month = months[dt.month - 1];
      final year = dt.year;

      int hour = dt.hour;
      final period = hour >= 12 ? 'مساءً' : 'صباحاً';
      if (hour == 0) {
        hour = 12;
      } else if (hour > 12) {
        hour -= 12;
      }
      final hourStr = hour.toString().padLeft(2, '0');
      final minuteStr = dt.minute.toString().padLeft(2, '0');

      return '$weekday، $day $month $year • $hourStr:$minuteStr $period';
    } catch (_) {
      return raw;
    }
  }

  String _translateShiftSlot(String raw) {
    switch (raw.trim().toLowerCase()) {
      case 'morning_go':
        return 'ذهاب صباحي (إلى المدرسة)';
      case 'morning_back':
      case 'morning_return':
        return 'عودة صباحية (إلى المنزل)';
      case 'afternoon_go':
        return 'ذهاب بعد الظهر (إلى المدرسة)';
      case 'afternoon_back':
      case 'afternoon_return':
        return 'عودة بعد الظهر (إلى المنزل)';
      case 'evening_go':
        return 'ذهاب مسائي';
      case 'evening_back':
        return 'عودة مسائية';
      default:
        return raw;
    }
  }

  String _translateTripType(String raw) {
    switch (raw.trim().toLowerCase()) {
      case 'morning':
        return 'صباحية';
      case 'afternoon':
        return 'بعد الظهر';
      case 'evening':
        return 'مسائية';
      case 'daily':
        return 'يومية';
      default:
        return raw;
    }
  }

  String _translateColor(String color) {
    const colorMap = {
      'white': 'أبيض',
      'black': 'أسود',
      'silver': 'فضي',
      'grey': 'رمادي',
      'gray': 'رمادي',
      'yellow': 'أصفر',
      'blue': 'أزرق',
      'red': 'أحمر',
      'green': 'أخضر',
      'gold': 'ذهبي',
      'brown': 'بني',
      'orange': 'برتقالي',
    };
    return colorMap[color.trim().toLowerCase()] ?? color.trim();
  }

  String _translateVehicle(String brand, String model, [String color = '']) {
    const brandMap = {
      'ford': 'فورد',
      'toyota': 'تويوتا',
      'hyundai': 'هيونداي',
      'mercedes': 'مرسيدس',
      'mercedes-benz': 'مرسيدس',
      'nissan': 'نيسان',
      'mitsubishi': 'ميتسوبيشي',
      'kia': 'كيا',
      'isuzu': 'إيسوزو',
      'peugeot': 'بيجو',
      'renault': 'رينو',
      'chevrolet': 'شيفروليه',
      'volkswagen': 'فولكس فاجن',
      'fiat': 'فيات',
    };
    const modelMap = {
      'coaster': 'كوستر',
      'hiace': 'هاي إيس',
      'transit': 'ترانزيت',
      'h1': 'إتش 1',
      'urvan': 'أورفان',
      'sprinter': 'سبرينتر',
      'boxer': 'بوكسر',
    };

    final b = brandMap[brand.trim().toLowerCase()] ?? brand.trim();
    final m = modelMap[model.trim().toLowerCase()] ?? model.trim();
    final c = color.isNotEmpty ? ' (${_translateColor(color)})' : '';
    return '$b $m$c'.trim();
  }

  String _formatGrade(int grade) {
    const gradeNames = {
      1: 'الأول',
      2: 'الثاني',
      3: 'الثالث',
      4: 'الرابع',
      5: 'الخامس',
      6: 'السادس',
      7: 'السابع',
      8: 'الثامن',
      9: 'التاسع',
      10: 'الأول ثانوي',
      11: 'الثاني ثانوي',
      12: 'الثالث ثانوي',
    };
    if (gradeNames.containsKey(grade)) {
      return 'الصف ${gradeNames[grade]}';
    }
    return grade > 0 ? 'الصف $grade' : '';
  }

  Future<void> _openMap(String mapsUrl, double lat, double lng) async {
    final urlStr =
        mapsUrl.isNotEmpty ? mapsUrl : 'https://maps.google.com/?q=$lat,$lng';
    final uri = Uri.parse(urlStr);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(uri);
      }
    } catch (_) {
      _copyText(urlStr, 'رابط الموقع في خرائط Google');
    }
  }

  Widget _buildLocationCard(TripEmergencyDetailModel data) {
    final lat = data.breakdownLocation.latitude;
    final lng = data.breakdownLocation.longitude;
    final hasCoords = lat != 0 && lng != 0;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AdminColors.statusDanger.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AdminColors.statusDanger.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AdminColors.statusDanger.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.location_on_rounded,
              color: AdminColors.statusDanger,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'موقع تعطل الحافلة',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: context.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  hasCoords
                      ? 'تم تحديد إحداثيات التوقف بدقة عبر نظام التتبع GPS'
                      : 'الموقع مسجل ومحدد على الخريطة',
                  style: TextStyle(
                    fontSize: 11,
                    color: context.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          if (data.breakdownLocation.mapsUrl.isNotEmpty || hasCoords) ...[
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AdminColors.statusDanger,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              onPressed: () =>
                  _openMap(data.breakdownLocation.mapsUrl, lat, lng),
              icon: const Icon(Icons.map_rounded, size: 18),
              label: const Text(
                'فتح في خرائط Google',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.copy_rounded, size: 18),
              tooltip: 'نسخ رابط الموقع في خرائط Google',
              onPressed: () => _copyText(
                data.breakdownLocation.mapsUrl.isNotEmpty
                    ? data.breakdownLocation.mapsUrl
                    : 'https://maps.google.com/?q=$lat,$lng',
                'رابط الموقع',
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getStatusBgColor(String status) {
    switch (status) {
      case 'accepted':
      case 'completed':
        return AdminColors.statusSuccess.withValues(alpha: 0.12);
      case 'broadcasted':
      case 'pending':
        return AdminColors.statusWarning.withValues(alpha: 0.12);
      case 'declined_all':
      case 'unresolved':
        return AdminColors.statusDanger.withValues(alpha: 0.12);
      case 'expired':
      case 'cancelled':
      default:
        return Colors.grey.withValues(alpha: 0.12);
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status) {
      case 'accepted':
      case 'completed':
        return AdminColors.statusSuccess;
      case 'broadcasted':
      case 'pending':
        return AdminColors.statusWarning;
      case 'declined_all':
      case 'unresolved':
        return AdminColors.statusDanger;
      case 'expired':
      case 'cancelled':
      default:
        return Colors.grey.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: Column(
        children: [
          // 1. ترويسة اللوحة العلوية
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: context.surfaceVariant.withValues(alpha: 0.4),
              border: Border(bottom: BorderSide(color: context.borderSoft)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      'طوارئ الرحلة المعطلة',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: context.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (_emergencyData != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: context.surfaceVariant,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: context.borderSoft),
                        ),
                        child: Text(
                          'بلاغ #${_emergencyData!.dispatchId}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: context.primaryColor,
                          ),
                        ),
                      ),
                  ],
                ),
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: _isLoading ? null : _loadEmergencyData,
                      icon: const Icon(Icons.refresh_rounded, size: 16),
                      label: const Text('تحديث البيانات'),
                    ),
                    const SizedBox(width: 6),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 2. المحتوى التفاعلي
          Expanded(
            child: _buildBody(theme),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'تعذر تحميل تفاصيل الطوارئ',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: context.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                style: TextStyle(fontSize: 12, color: context.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadEmergencyData,
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        ),
      );
    }

    final data = _emergencyData!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // شريط حالة البلاغ الرئيسي
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _getStatusBgColor(data.status),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: _getStatusTextColor(data.status).withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'الحالة الحالية للبلاغ:',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: context.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        data.cleanStatusLabel,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: _getStatusTextColor(data.status),
                        ),
                      ),
                    ],
                  ),
                ),
                if (data.status != 'completed' && data.status != 'cancelled')
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AdminColors.statusSuccess,
                      side: const BorderSide(color: AdminColors.statusSuccess),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                    ),
                    onPressed: _isActionInProgress ? null : _resolveEmergency,
                    child: _isActionInProgress
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text(
                            'إغلاق وحل الطوارئ',
                            style: TextStyle(
                                fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // بطاقة تفاصيل العطل وموقع الحافلة
          _buildSectionCard(
            title: 'تفاصيل العطل وموقع الحافلة',
            children: [
              _buildInfoRow('سبب التوقف:', data.reason),
              _buildInfoRow(
                  'وقت بلاغ الطوارئ:', _formatDateTimeArabic(data.dispatchedAt)),
              if (data.expiresAt != null && data.expiresAt!.isNotEmpty)
                _buildInfoRow(
                    'انتهاء الصلاحية:', _formatDateTimeArabic(data.expiresAt)),
              if (data.acceptedAt != null && data.acceptedAt!.isNotEmpty)
                _buildInfoRow(
                    'وقت قبول المهمة:', _formatDateTimeArabic(data.acceptedAt)),
              if (data.completedAt != null && data.completedAt!.isNotEmpty)
                _buildInfoRow(
                    'وقت إنهاء البلاغ:', _formatDateTimeArabic(data.completedAt)),
              const SizedBox(height: 12),
              _buildLocationCard(data),
            ],
          ),
          const SizedBox(height: 16),

          // بطاقة الحافلة والسائق المعطل
          _buildSectionCard(
            title: 'السائق والحافلة المعطلة الأصلية',
            children: [
              _buildInfoRow('اسم السائق الأساسي:', data.originalDriver.name),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: _buildInfoRow(
                        'رقم الهاتف:', data.originalDriver.phone,
                        isLtr: true),
                  ),
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    ),
                    onPressed: () => _copyText(
                        data.originalDriver.phone, 'رقم هاتف السائق الأصلي'),
                    icon: const Icon(Icons.copy_rounded, size: 14),
                    label: const Text('نسخ الرقم', style: TextStyle(fontSize: 11)),
                  ),
                ],
              ),
              if (data.originalDriver.vehicle != null) ...[
                _buildInfoRow(
                  'المركبة:',
                  _translateVehicle(
                    data.originalDriver.vehicle!.brand,
                    data.originalDriver.vehicle!.model,
                    data.originalDriver.vehicle!.color,
                  ),
                ),
                _buildInfoRow(
                  'رقم اللوحة والسعة:',
                  '${data.originalDriver.vehicle!.plateNumber} (سعة: ${data.originalDriver.vehicle!.capacity} راكب)',
                ),
              ],
              _buildInfoRow(
                'الرحلة الأصلية:',
                '#${data.originalTrip.id} - ${data.originalTrip.routeName} (${_translateTripType(data.originalTrip.tripType)} • ${_translateShiftSlot(data.originalTrip.shiftSlot)})',
              ),
            ],
          ),
          const SizedBox(height: 16),

          // بطاقة السائق البديل المكلف (إن وجد)
          _buildSubstituteSection(data),
          const SizedBox(height: 16),

          // قسم السائقين المرشحين للتكليف (يظهر عندما يكون البحث جارياً ولم يقبل سائق بعد)
          _buildCandidatesSection(data),
          const SizedBox(height: 16),

          // قسم الأطفال العالقين
          _buildChildrenSection(data),
        ],
      ),
    );
  }

  Widget _buildSubstituteSection(TripEmergencyDetailModel data) {
    if (data.substituteDriver != null) {
      final sub = data.substituteDriver!;
      return _buildSectionCard(
        title: 'السائق البديل المكلف بالمهمة',
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AdminColors.statusSuccess.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: AdminColors.statusSuccess.withValues(alpha: 0.25)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('اسم السائق البديل:', sub.name),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child:
                          _buildInfoRow('رقم الهاتف:', sub.phone, isLtr: true),
                    ),
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      ),
                      onPressed: () =>
                          _copyText(sub.phone, 'رقم هاتف السائق البديل'),
                      icon: const Icon(Icons.copy_rounded, size: 14),
                      label: const Text('نسخ الرقم',
                          style: TextStyle(fontSize: 11)),
                    ),
                  ],
                ),
                if (sub.vehicle != null)
                  _buildInfoRow(
                    'المركبة البديلة:',
                    '${_translateVehicle(sub.vehicle!.brand, sub.vehicle!.model, sub.vehicle!.color)} - اللوحة: ${sub.vehicle!.plateNumber}',
                  ),
              ],
            ),
          ),
        ],
      );
    }

    return _buildSectionCard(
      title: 'السائق البديل',
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Icon(Icons.info_outline, size: 18, color: context.textTertiary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'لم يتم قبول المهمة من سائق بديل حتى الآن (الطلب معلق أو قيد البحث).',
                  style: TextStyle(fontSize: 12, color: context.textSecondary),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// قسم السائقين المرشحين للتكليف
  /// يظهر عندما لا يوجد سائق بديل مكلف بعد، أو عندما تكون هناك قائمة بالسائقين المرشحين
  Widget _buildCandidatesSection(TripEmergencyDetailModel data) {
    final hasAcceptedSubstitute = data.substituteDriver != null;
    final candidates = data.candidates;

    // إذا كان السائق البديل قد قَبِل بالفعل، فلا داعي لعرض قائمة الترشيح اليدوي إلا كإشارة
    if (hasAcceptedSubstitute && candidates.isEmpty) {
      return const SizedBox.shrink();
    }

    return _buildSectionCard(
      title: 'السائقون البدلاء المرشحون للتكليف المباشر',
      children: [
        if (candidates.isEmpty)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AdminColors.statusWarning.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AdminColors.statusWarning.withValues(alpha: 0.25),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.radar_rounded,
                  color: AdminColors.statusWarning,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'جاري بث البلاغ والبحث عن سائقين بدلاء متوفرين',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: context.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'يقوم النظام بالبث التلقائي للسائقين المتواجدين في محيط موقع الحافلة المعطلة.',
                        style: TextStyle(
                          fontSize: 11,
                          color: context.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        else ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              'يمكنك تكليف أحد السائقين المتوفرين في المحيط مباشرة لنقل الأطفال وحل العطل:',
              style: TextStyle(fontSize: 12, color: context.textSecondary),
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: candidates.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (ctx, i) {
              final driver = candidates[i];
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: context.surfaceVariant.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: context.borderSoft),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor:
                          context.primaryColor.withValues(alpha: 0.1),
                      child: Icon(
                        Icons.directions_bus_filled_rounded,
                        color: context.primaryColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            driver.name,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: context.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Text(
                                'هاتف: ${driver.phone}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: context.textSecondary,
                                ),
                                textDirection: TextDirection.ltr,
                              ),
                              if (driver.plateNumber.isNotEmpty) ...[
                                Text(
                                  ' • اللوحة: ${driver.plateNumber}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: context.textTertiary,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AdminColors.brandPrimary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      onPressed: _isActionInProgress
                          ? null
                          : () => _assignSubstituteDriver(driver.id, driver.name),
                      icon: const Icon(Icons.person_add_alt_1_rounded, size: 16),
                      label: const Text(
                        'تكليف السائق',
                        style: TextStyle(
                            fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ],
    );
  }

  Widget _buildChildrenSection(TripEmergencyDetailModel data) {
    final summary = data.childrenSummary;

    return _buildSectionCard(
      title: 'الأطفال العالقون بالرحلة وبيانات أولياء الأمور',
      children: [
        // بطاقات الأرقام الإحصائية البسيطة
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildStatBadge(
              'إجمالي العالقين',
              '${summary.totalStrandedCount}',
              context.primaryColor,
            ),
            _buildStatBadge(
              'داخل الحافلة المعطلة',
              '${summary.boardedInBusCount}',
              AdminColors.statusDanger,
            ),
            _buildStatBadge(
              'ينتظر في نقطة التجمع',
              '${summary.waitingAtPickupCount}',
              AdminColors.statusWarning,
            ),
            _buildStatBadge(
              'تم التوصيل بسلام',
              '${summary.deliveredCount}',
              AdminColors.statusSuccess,
            ),
          ],
        ),
        const SizedBox(height: 16),

        // قائمة الأطفال
        if (data.childrenDetails.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'لا توجد تفاصيل أطفال مسجلة في هذا البلاغ.',
              style: TextStyle(fontSize: 12, color: context.textTertiary),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: data.childrenDetails.length,
            separatorBuilder: (_, __) =>
                Divider(height: 20, color: context.borderSoft),
            itemBuilder: (ctx, i) {
              final child = data.childrenDetails[i];
              final gradeText = _formatGrade(child.grade);
              final genderText = child.gender.toLowerCase() == 'male'
                  ? 'ذكر'
                  : (child.gender.toLowerCase() == 'female'
                      ? 'أنثى'
                      : child.gender);

              final metaList = <String>[];
              if (gradeText.isNotEmpty) metaList.add(gradeText);
              if (genderText.isNotEmpty) metaList.add(genderText);
              final metaStr =
                  metaList.isNotEmpty ? ' (${metaList.join(' • ')})' : '';

              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.surfaceVariant.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: context.borderSoft),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${child.fullName}$metaStr',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: context.textPrimary,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: child.isStrandedInBrokenBus
                                ? AdminColors.statusDanger
                                    .withValues(alpha: 0.12)
                                : (child.isDelivered
                                    ? AdminColors.statusSuccess
                                        .withValues(alpha: 0.12)
                                    : AdminColors.statusWarning
                                        .withValues(alpha: 0.12)),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            child.cleanStatusLabel,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: child.isStrandedInBrokenBus
                                  ? AdminColors.statusDanger
                                  : (child.isDelivered
                                      ? AdminColors.statusSuccess
                                      : AdminColors.statusWarning),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (child.parent != null) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'ولي الأمر: ${child.parent!.name}',
                            style: TextStyle(
                              fontSize: 12,
                              color: context.textSecondary,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                child.parent!.phone,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: context.textPrimary,
                                ),
                                textDirection: TextDirection.ltr,
                              ),
                              const SizedBox(width: 4),
                              TextButton(
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                onPressed: () => _copyText(
                                    child.parent!.phone, 'رقم ولي الأمر'),
                                child: const Text('نسخ',
                                    style: TextStyle(fontSize: 11)),
                              ),
                            ],
                          ),
                        ],
                      ),
                      if (child.parent!.alternativePhone.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'هاتف بديل للطوارئ:',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: context.textTertiary,
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    child.parent!.alternativePhone,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: context.textSecondary,
                                    ),
                                    textDirection: TextDirection.ltr,
                                  ),
                                  const SizedBox(width: 4),
                                  TextButton(
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      minimumSize: Size.zero,
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    onPressed: () => _copyText(
                                        child.parent!.alternativePhone,
                                        'الهاتف البديل'),
                                    child: const Text('نسخ',
                                        style: TextStyle(fontSize: 11)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                    ],
                    if (child.school != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'المدرسة: ${child.school!.name}',
                        style: TextStyle(
                            fontSize: 11, color: context.textTertiary),
                      ),
                    ],
                    if (child.homeAddressLabel.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        'العنوان: ${child.homeAddressLabel}',
                        style: TextStyle(
                            fontSize: 11, color: context.textTertiary),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.borderSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: context.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isLtr = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(fontSize: 12, color: context.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : '-',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: context.textPrimary,
              ),
              textDirection: isLtr ? TextDirection.ltr : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBadge(String label, String count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            count,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
