import 'package:flutter/material.dart';

import '../../../../core/utils/admin_theme_context.dart';
import '../../../../core/utils/media_url.dart';
import '../../../../core/widgets/image_viewer_dialog.dart';
import '../../../../core/widgets/remote_image.dart';

/// ويدجت مقارنة طلبات التعديل.
///
/// يعرض التغييرات الحاصلة في طلب التعديل:
/// - الحقول النصية/الرقمية تُعرض في TextView عادي (قبل التعديل وبعد التعديل).
/// - الصور (مثل صورة المركبة أو الوثائق المحدثة) تُعرض بالصورة القديمة والجديدة بنفس أسلوب `DriverDocumentTile` مع التكبير عند النقر.
class DriverChangeComparisonWidget extends StatelessWidget {
  final Map<String, dynamic> currentData;
  final Map<String, dynamic> proposedData;

  const DriverChangeComparisonWidget({
    super.key,
    required this.currentData,
    required this.proposedData,
  });

  bool _isImageField(String key, dynamic oldVal, dynamic newVal) {
    final keyLower = key.toLowerCase();

    // 1. الفحص باسم المفتاح المعرف لملفات الصور والوثائق
    if (keyLower.contains('image') ||
        keyLower.contains('photo') ||
        keyLower.endsWith('_path') ||
        keyLower.endsWith('_url') ||
        (keyLower.startsWith('doc_') &&
            (keyLower.contains('license') ||
                keyLower.contains('logbook') ||
                keyLower.contains('insurance') ||
                keyLower.contains('stamp') ||
                keyLower.contains('inspection') ||
                keyLower.contains('booklet') ||
                keyLower.contains('file')))) {
      return true;
    }

    // 2. الفحص بقيمة القيمة المرسلة (إذا كانت تنتهي بلاحقة صورة أو تبدأ بـ storage/ أو تحتوي مسار ملف)
    bool checkVal(dynamic v) {
      if (v == null) return false;
      final s = v.toString().trim();
      if (s.isEmpty || s == 'null') return false;
      return MediaUrl.isImage(s) ||
          s.startsWith('storage/') ||
          s.startsWith('/storage/') ||
          s.contains('/drivers/documents/') ||
          s.contains('/drivers/vehicles/');
    }

    return checkVal(oldVal) || checkVal(newVal);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // تجميع المفاتيح الموجودة في التعديلات فقط
    final allKeys = {...currentData.keys, ...proposedData.keys}.toList();

    if (allKeys.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: const Center(
          child: Text('لا توجد تفاصيل مقارنة متوفرة في استجابة الخادم.'),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ترويسة الأعمدة
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.surfaceVariant,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    'البيانات الحالية (old_values)',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: context.textTertiary,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    'البيانات المقترحة (new_values)',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: context.primaryColor,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // عرض عناصر التعديل
        ...allKeys.map((key) {
          final currRaw = currentData[key];
          final propRaw = proposedData[key];

          final isImage = _isImageField(key, currRaw, propRaw);

          if (isImage) {
            return _buildImageComparisonRow(context, key, currRaw, propRaw, isDark: isDark);
          } else {
            return _buildTextComparisonRow(context, key, currRaw, propRaw, isDark: isDark);
          }
        }),
      ],
    );
  }

  /// 1. صف المقارنة للحقول النصية والرقمية (TextView عادي قبل وبعد التعديل)
  Widget _buildTextComparisonRow(
    BuildContext context,
    String key,
    dynamic oldVal,
    dynamic newVal, {
    required bool isDark,
  }) {
    final theme = Theme.of(context);
    final currStr = oldVal?.toString().trim() ?? '';
    final propStr = newVal?.toString().trim() ?? '';
    final isChanged = currStr != propStr;

    final oldText = currStr.isEmpty || currStr == 'null' ? 'غير محدد' : currStr;
    final newText = propStr.isEmpty || propStr == 'null' ? 'غير محدد' : propStr;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isChanged
            ? (isDark ? const Color(0xFF78350F).withValues(alpha: 0.2) : const Color(0xFFFFFBEB))
            : theme.cardColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isChanged ? const Color(0xFFF59E0B).withValues(alpha: 0.5) : theme.dividerColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _translateFieldKey(key),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: context.textTertiary,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  oldText,
                  style: TextStyle(
                    fontSize: 13,
                    color: context.textSecondary,
                    decoration: isChanged ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Icon(Icons.arrow_back_rounded, size: 16, color: Color(0xFFD97706)),
              ),
              Expanded(
                child: Text(
                  newText,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isChanged ? FontWeight.bold : FontWeight.normal,
                    color: isChanged ? const Color(0xFFD97706) : context.textPrimary,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 2. صف المقارنة للصور والوثائق المحدثة (يعرض الصورة القديمة والجديدة بأسلوب DriverDocumentTile)
  Widget _buildImageComparisonRow(
    BuildContext context,
    String key,
    dynamic oldVal,
    dynamic newVal, {
    required bool isDark,
  }) {
    final label = _translateFieldKey(key);

    final oldUrlStr = oldVal?.toString().trim() ?? '';
    final newUrlStr = newVal?.toString().trim() ?? '';

    final resolvedOldUrl = MediaUrl.resolve(oldUrlStr);
    final resolvedNewUrl = MediaUrl.resolve(newUrlStr);

    final hasOldFile = resolvedOldUrl != null && resolvedOldUrl.isNotEmpty;
    final hasNewFile = resolvedNewUrl != null && resolvedNewUrl.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF78350F).withValues(alpha: 0.15) : const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.image_outlined, size: 16, color: context.primaryColor),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: context.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              // 1. الصورة القديمة (الحالية)
              Expanded(
                child: _buildImageTile(
                  context,
                  title: '$label (قبل التعديل)',
                  url: resolvedOldUrl,
                  hasFile: hasOldFile,
                  badgeLabel: 'الحالية',
                  badgeColor: Colors.grey,
                ),
              ),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Icon(Icons.arrow_back_rounded, size: 20, color: Color(0xFFD97706)),
              ),

              // 2. الصورة الجديدة (المطلوبة)
              Expanded(
                child: _buildImageTile(
                  context,
                  title: '$label (بعد التعديل)',
                  url: resolvedNewUrl,
                  hasFile: hasNewFile,
                  badgeLabel: 'المقترحة',
                  badgeColor: const Color(0xFFD97706),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// كارت مصغرة الصورة بنفس تصميم DriverDocumentTile مع إمكانية المعاينة والتكبير عند النقر
  Widget _buildImageTile(
    BuildContext context, {
    required String title,
    required String? url,
    required bool hasFile,
    required String badgeLabel,
    required Color badgeColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: context.isDarkMode ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.dividerLine),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: hasFile
              ? () => ImageViewerDialog.show(
                    context,
                    title: title,
                    rawUrl: url!,
                  )
              : null,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                // مصغّرة الصورة بالضبط كما في DriverDocumentTile (_Thumbnail)
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: context.primaryColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: RemoteImage(
                    rawUrl: url,
                    fit: BoxFit.cover,
                    fallback: Icon(
                      hasFile
                          ? (MediaUrl.isPdf(url ?? '')
                              ? Icons.picture_as_pdf_rounded
                              : Icons.insert_drive_file_rounded)
                          : Icons.image_not_supported_outlined,
                      size: 22,
                      color: context.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: badgeColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          badgeLabel,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: badgeColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        hasFile ? 'اضغط لعرض الوثيقة' : 'لا يوجد ملف مرفوع',
                        style: TextStyle(
                          fontSize: 11,
                          color: context.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  hasFile ? Icons.visibility_outlined : Icons.image_not_supported_outlined,
                  size: 18,
                  color: hasFile ? context.primaryColor : context.textTertiary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _translateFieldKey(String key) {
    switch (key) {
      case 'plate_number':
      case 'plate':
        return 'رقم اللوحة المعدنية';
      case 'make':
      case 'brand':
        return 'الشركة المصنعة';
      case 'model':
        return 'موديل المركبة';
      case 'color':
        return 'لون المركبة';
      case 'year':
        return 'سنة الصنع';
      case 'vehicle_id':
        return 'معرف المركبة (ID)';
      case 'vehicle_image_url':
      case 'vehicle_image_path':
      case 'vehicle_image':
        return 'صورة المركبة';
      case 'doc_license_path':
      case 'doc_license_url':
      case 'doc_license':
        return 'صورة رخصة القيادة';
      case 'doc_logbook_path':
      case 'doc_logbook_url':
      case 'doc_logbook':
        return 'صورة كتيب الملكية';
      case 'doc_insurance_path':
      case 'doc_insurance_url':
      case 'doc_insurance':
        return 'صورة وثيقة التأمين';
      case 'doc_stamp_path':
      case 'doc_stamp_url':
      case 'doc_stamp':
        return 'صورة الدمغ (إذن تجول)';
      case 'doc_technical_inspection_path':
      case 'doc_technical_inspection_url':
      case 'doc_technical_inspection':
        return 'صورة الفحص الفني';
      case 'doc_booklet_page_path':
      case 'doc_booklet_page_url':
      case 'doc_booklet_page':
        return 'صورة كتيب أوصاف المركبة';
      case 'phone_number':
      case 'phone':
      case 'driver_phone':
        return 'رقم الهاتف';
      case 'full_name':
      case 'name':
      case 'driver_name':
        return 'اسم السائق';
      case 'national_id':
        return 'الرقم الوطني / الهوية';
      case 'license_number':
        return 'رقم رخصة القيادة';
      case 'license_expiry':
        return 'تاريخ انتهاء الرخصة';
      case 'insurance_expiry':
        return 'تاريخ انتهاء التأمين';
      case 'stamp_expiry':
        return 'تاريخ انتهاء الدمغ';
      case 'technical_inspection_expiry':
        return 'تاريخ انتهاء الفحص الفني';
      case 'rejection_reason':
        return 'سبب الرفض المسبب';
      case 'status':
        return 'الحالة';
      default:
        return key;
    }
  }
}
