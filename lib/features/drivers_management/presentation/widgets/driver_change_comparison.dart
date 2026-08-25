import 'package:flutter/material.dart';

import '../../../../core/utils/admin_theme_context.dart';
import '../../../../core/utils/media_url.dart';
import '../../../../core/widgets/image_viewer_dialog.dart';
import '../../../../core/widgets/remote_image.dart';

/// نوع حقل التعديل لتحديد طريقة العرض التفاعلية المناسبة.
enum _ChangeFieldType { text, date, image }

/// تعريف عقد الحقل المعياري المطابق لجدول خادم الباك إند صراحة.
class _FieldContractSpec {
  final String canonicalKey;
  final String arabicLabel;
  final List<String> oldKeys;
  final List<String> newKeys;
  final _ChangeFieldType type;

  const _FieldContractSpec({
    required this.canonicalKey,
    required this.arabicLabel,
    required this.oldKeys,
    required this.newKeys,
    required this.type,
  });
}

/// عنصر حقل تعديل فردي مُستخرج ومُعالج بأمان لعرض المقارنة.
class _ChangeFieldItem {
  final String key;
  final String label;
  final _ChangeFieldType type;
  final dynamic oldValue;
  final dynamic newValue;

  const _ChangeFieldItem({
    required this.key,
    required this.label,
    required this.type,
    this.oldValue,
    this.newValue,
  });
}

/// ويدجت مقارنة طلبات التعديل المحسّنة والمطوّرة وفقاً لجدول عقود الباك إند الصريح بالكامل.
class DriverChangeComparisonWidget extends StatelessWidget {
  final Map<String, dynamic> currentData;
  final Map<String, dynamic> proposedData;

  const DriverChangeComparisonWidget({
    super.key,
    required this.currentData,
    required this.proposedData,
  });

  /// جدول عقود الباك إند الصريح والشامل لكافة حقول ومفتاح المخرجات (Old Values vs New Values).
  static const List<_FieldContractSpec> _allContractSpecs = [
    // 1. البيانات الشخصية
    _FieldContractSpec(
      canonicalKey: 'full_name',
      arabicLabel: 'الاسم الكامل',
      oldKeys: ['full_name', 'name', 'driver_name'],
      newKeys: ['full_name', 'name', 'driver_name'],
      type: _ChangeFieldType.text,
    ),
    _FieldContractSpec(
      canonicalKey: 'phone_number',
      arabicLabel: 'رقم الهاتف الأساسي',
      oldKeys: ['phone_number', 'phone', 'driver_phone'],
      newKeys: ['phone_number', 'phone', 'driver_phone'],
      type: _ChangeFieldType.text,
    ),
    _FieldContractSpec(
      canonicalKey: 'alternative_phone',
      arabicLabel: 'رقم الهاتف الاحتياطي',
      oldKeys: ['alternative_phone', 'alt_phone', 'second_phone'],
      newKeys: ['alternative_phone', 'alt_phone', 'second_phone'],
      type: _ChangeFieldType.text,
    ),
    _FieldContractSpec(
      canonicalKey: 'avatar',
      arabicLabel: 'الصورة الشخصية للسائق',
      oldKeys: ['avatar_url', 'avatar', 'profile_photo', 'photo'],
      newKeys: ['avatar_url', 'avatar', 'profile_photo', 'photo'],
      type: _ChangeFieldType.image,
    ),

    // 2. بيانات وتفاصيل المركبة
    _FieldContractSpec(
      canonicalKey: 'plate_number',
      arabicLabel: 'رقم اللوحة',
      oldKeys: ['plate_number', 'plate'],
      newKeys: ['plate_number', 'plate'],
      type: _ChangeFieldType.text,
    ),
    _FieldContractSpec(
      canonicalKey: 'brand',
      arabicLabel: 'ماركة المركبة',
      oldKeys: ['brand', 'make'],
      newKeys: ['brand', 'make'],
      type: _ChangeFieldType.text,
    ),
    _FieldContractSpec(
      canonicalKey: 'model',
      arabicLabel: 'موديل المركبة',
      oldKeys: ['model'],
      newKeys: ['model'],
      type: _ChangeFieldType.text,
    ),
    _FieldContractSpec(
      canonicalKey: 'year',
      arabicLabel: 'سنة الصنع',
      oldKeys: ['year', 'manufacturing_year'],
      newKeys: ['year', 'manufacturing_year'],
      type: _ChangeFieldType.text,
    ),
    _FieldContractSpec(
      canonicalKey: 'color',
      arabicLabel: 'لون المركبة',
      oldKeys: ['color'],
      newKeys: ['color'],
      type: _ChangeFieldType.text,
    ),
    _FieldContractSpec(
      canonicalKey: 'type',
      arabicLabel: 'نوع المركبة',
      oldKeys: ['type', 'vehicle_type'],
      newKeys: ['type', 'vehicle_type'],
      type: _ChangeFieldType.text,
    ),
    _FieldContractSpec(
      canonicalKey: 'capacity_manual',
      arabicLabel: 'سعة الركاب',
      oldKeys: ['capacity_manual', 'capacity'],
      newKeys: ['capacity_manual', 'capacity'],
      type: _ChangeFieldType.text,
    ),
    _FieldContractSpec(
      canonicalKey: 'has_ac',
      arabicLabel: 'التكييف بالمركبة',
      oldKeys: ['has_ac', 'ac'],
      newKeys: ['has_ac', 'ac'],
      type: _ChangeFieldType.text,
    ),
    _FieldContractSpec(
      canonicalKey: 'vehicle_image',
      arabicLabel: 'صورة المركبة',
      oldKeys: ['vehicle_image_url', 'vehicle_image_path', 'vehicle_image', 'vehicle_photo'],
      newKeys: ['vehicle_image_path', 'vehicle_image_url', 'vehicle_image', 'vehicle_photo'],
      type: _ChangeFieldType.image,
    ),

    // 3. البيانات القانونية والوثائق الرسمية والمستندات
    _FieldContractSpec(
      canonicalKey: 'national_id',
      arabicLabel: 'الرقم الوطني',
      oldKeys: ['national_id', 'national_number'],
      newKeys: ['national_id', 'national_number'],
      type: _ChangeFieldType.text,
    ),
    _FieldContractSpec(
      canonicalKey: 'license_number',
      arabicLabel: 'رقم رخصة القيادة',
      oldKeys: ['license_number', 'driver_license_number'],
      newKeys: ['license_number', 'driver_license_number'],
      type: _ChangeFieldType.text,
    ),
    _FieldContractSpec(
      canonicalKey: 'license_expiry',
      arabicLabel: 'تاريخ انتهاء الرخصة',
      oldKeys: ['license_expiry', 'license_expiry_date'],
      newKeys: ['license_expiry', 'license_expiry_date'],
      type: _ChangeFieldType.date,
    ),
    _FieldContractSpec(
      canonicalKey: 'doc_license',
      arabicLabel: 'ملف صورة رخصة القيادة',
      oldKeys: ['doc_license_path', 'doc_license', 'license_photo'],
      newKeys: ['doc_license_path', 'doc_license', 'license_photo'],
      type: _ChangeFieldType.image,
    ),
    _FieldContractSpec(
      canonicalKey: 'doc_logbook',
      arabicLabel: 'ملف صورة كتيب المركبة',
      oldKeys: ['doc_logbook_path', 'doc_logbook', 'logbook_photo'],
      newKeys: ['doc_logbook_path', 'doc_logbook', 'logbook_photo'],
      type: _ChangeFieldType.image,
    ),
    _FieldContractSpec(
      canonicalKey: 'doc_insurance',
      arabicLabel: 'ملف وثيقة التأمين',
      oldKeys: ['doc_insurance_path', 'doc_insurance', 'insurance_photo'],
      newKeys: ['doc_insurance_path', 'doc_insurance', 'insurance_photo'],
      type: _ChangeFieldType.image,
    ),
    _FieldContractSpec(
      canonicalKey: 'doc_booklet_page',
      arabicLabel: 'ملف الصفحة الشخصية بالكتيب',
      oldKeys: ['doc_booklet_page_path', 'doc_booklet_page'],
      newKeys: ['doc_booklet_page_path', 'doc_booklet_page'],
      type: _ChangeFieldType.image,
    ),
    _FieldContractSpec(
      canonicalKey: 'doc_stamp',
      arabicLabel: 'ملف طابع ورسوم المركبة',
      oldKeys: ['doc_stamp_path', 'doc_stamp'],
      newKeys: ['doc_stamp_path', 'doc_stamp'],
      type: _ChangeFieldType.image,
    ),
    _FieldContractSpec(
      canonicalKey: 'doc_technical_inspection',
      arabicLabel: 'ملف شهادة الفحص الفني',
      oldKeys: ['doc_technical_inspection_path', 'doc_technical_inspection'],
      newKeys: ['doc_technical_inspection_path', 'doc_technical_inspection'],
      type: _ChangeFieldType.image,
    ),
    _FieldContractSpec(
      canonicalKey: 'insurance_expiry',
      arabicLabel: 'تاريخ انتهاء التأمين',
      oldKeys: ['insurance_expiry', 'insurance_expiry_date'],
      newKeys: ['insurance_expiry', 'insurance_expiry_date'],
      type: _ChangeFieldType.date,
    ),
    _FieldContractSpec(
      canonicalKey: 'stamp_expiry',
      arabicLabel: 'تاريخ انتهاء الطابع',
      oldKeys: ['stamp_expiry', 'stamp_expiry_date'],
      newKeys: ['stamp_expiry', 'stamp_expiry_date'],
      type: _ChangeFieldType.date,
    ),
    _FieldContractSpec(
      canonicalKey: 'technical_inspection_expiry',
      arabicLabel: 'تاريخ انتهاء الفحص الفني',
      oldKeys: ['technical_inspection_expiry', 'technical_expiry', 'inspection_expiry'],
      newKeys: ['technical_inspection_expiry', 'technical_expiry', 'inspection_expiry'],
      type: _ChangeFieldType.date,
    ),
  ];

  /// تفكيك الكائنات المتداخلة في الـ JSON وإخراج المفاتيح المسطّحة بأمان.
  Map<String, dynamic> _flattenMap(Map<String, dynamic> input, [String prefix = '']) {
    final result = <String, dynamic>{};
    input.forEach((key, val) {
      if (val == null) return;
      final newKey = prefix.isEmpty ? key : '${prefix}_$key';
      if (val is Map<String, dynamic>) {
        result.addAll(_flattenMap(val, newKey));
      } else if (val is List && val.isNotEmpty && val.first is Map<String, dynamic>) {
        for (int i = 0; i < val.length; i++) {
          if (val[i] is Map<String, dynamic>) {
            result.addAll(_flattenMap(val[i] as Map<String, dynamic>, '${newKey}_$i'));
          }
        }
      } else {
        result[newKey] = val;
      }
    });
    return result;
  }

  /// البحث عن قيمة حقل ضمن الخريطة بدلالة قائمة المفاتيح المحتملة.
  dynamic _pickValue(Map<String, dynamic> map, List<String> possibleKeys) {
    for (final k in possibleKeys) {
      if (map.containsKey(k) && map[k] != null) {
        final str = map[k].toString().trim();
        if (str.isNotEmpty && str != 'null') return map[k];
      }
    }
    // تجربة البحث بعد تجاهل الأحرف الكبيرة والبادئات
    final lowerMap = map.map((key, value) => MapEntry(key.toLowerCase(), value));
    for (final k in possibleKeys) {
      final lk = k.toLowerCase();
      if (lowerMap.containsKey(lk) && lowerMap[lk] != null) {
        final str = lowerMap[lk].toString().trim();
        if (str.isNotEmpty && str != 'null') return lowerMap[lk];
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final flatCurrent = _flattenMap(currentData);
    final flatProposed = _flattenMap(proposedData);

    final List<_ChangeFieldItem> items = [];
    final Set<String> matchedKeysInProposed = {};

    // 1. استخراج الحقول المعرفّة في جدول العقد والتي توجد لها قيمة جديدة مقترحة في الطلب
    for (final spec in _allContractSpecs) {
      final newVal = _pickValue(flatProposed, spec.newKeys);
      if (newVal != null) {
        final oldVal = _pickValue(flatCurrent, spec.oldKeys);

        // حفظ المفاتيح المطابقة لمنع تكرارها
        for (final k in spec.newKeys) {
          matchedKeysInProposed.add(k.toLowerCase());
        }

        items.add(_ChangeFieldItem(
          key: spec.canonicalKey,
          label: spec.arabicLabel,
          type: spec.type,
          oldValue: oldVal,
          newValue: newVal,
        ));
      }
    }

    // 2. كبديل احتياطي (Fallback): إضافة أي حقول إضافية غير معروفة وُجدت في flatProposed ولم تُطابق العقد
    flatProposed.forEach((key, newVal) {
      if (newVal == null) return;
      final valStr = newVal.toString().trim();
      if (valStr.isEmpty || valStr == 'null') return;
      if (matchedKeysInProposed.contains(key.toLowerCase())) return;

      final oldVal = flatCurrent[key];
      _ChangeFieldType type = _ChangeFieldType.text;

      final k = key.toLowerCase();
      if (k.contains('image') || k.contains('photo') || k.contains('avatar') || k.startsWith('doc_')) {
        type = _ChangeFieldType.image;
      } else if (k.contains('expiry') || k.contains('date')) {
        type = _ChangeFieldType.date;
      }

      items.add(_ChangeFieldItem(
        key: key,
        label: key,
        type: type,
        oldValue: oldVal,
        newValue: newVal,
      ));
    });

    if (items.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: context.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.dividerColor),
        ),
        child: const Center(
          child: Text('لا توجد تفاصيل مقارنة متوفرة في استجابة الخادم.'),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ترويسة المقارنة التوضيحية
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: context.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.dividerColor),
          ),
          child: Row(
            children: [
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.history_rounded, size: 16, color: context.textTertiary),
                    const SizedBox(width: 6),
                    Text(
                      'البيانات الحالية (Old Data)',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: context.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.new_releases_outlined, size: 16, color: context.primaryColor),
                    const SizedBox(width: 6),
                    Text(
                      'البيانات المقترحة (Proposed Data)',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: context.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // قائمة كروت التعديلات المعنونة والديناميكية
        ...items.map((item) => _buildItemWidget(context, item, isDark)),
      ],
    );
  }

  Widget _buildItemWidget(BuildContext context, _ChangeFieldItem item, bool isDark) {
    switch (item.type) {
      case _ChangeFieldType.image:
        return _ImageComparisonTile(item: item, isDark: isDark);
      case _ChangeFieldType.date:
        return _DateComparisonTile(item: item, isDark: isDark);
      case _ChangeFieldType.text:
        return _TextComparisonTile(item: item, isDark: isDark);
    }
  }
}

/// 1. كرت مقارنة النصوص والبيانات العادية المعالجة بدقة بحسب عقد الباك إند
class _TextComparisonTile extends StatelessWidget {
  final _ChangeFieldItem item;
  final bool isDark;

  const _TextComparisonTile({required this.item, required this.isDark});

  IconData _getFieldIcon(String key) {
    final k = key.toLowerCase();
    if (k.contains('plate')) return Icons.pin_outlined;
    if (k.contains('brand') || k.contains('make')) return Icons.business_rounded;
    if (k.contains('model') || k.contains('year')) return Icons.calendar_today_outlined;
    if (k.contains('color')) return Icons.palette_outlined;
    if (k.contains('phone')) return Icons.phone_outlined;
    if (k.contains('email')) return Icons.email_outlined;
    if (k.contains('gender')) return Icons.wc_outlined;
    if (k.contains('national')) return Icons.badge_outlined;
    if (k.contains('capacity')) return Icons.airline_seat_recline_normal_rounded;
    if (k.contains('ac')) return Icons.ac_unit_rounded;
    if (k.contains('type')) return Icons.directions_car_outlined;
    return Icons.info_outline_rounded;
  }

  /// ترجمة وتحويل قيم الباك إند الحصرية إلى مسميات عربية مفهومة
  String _formatValue(String key, dynamic val) {
    if (val == null) return 'لا يوجد سابقاً';

    final k = key.toLowerCase();
    final s = val.toString().trim();
    if (s.isEmpty || s == 'null') return 'لا يوجد سابقاً';

    // 1. ترجمة نوع المركبة الإنجليزي حصرياً (Sedan / Van / Bus) إلى العربي
    if (k == 'type' || k == 'vehicle_type') {
      final typeLower = s.toLowerCase();
      if (typeLower == 'sedan') return 'سيارة سدان';
      if (typeLower == 'van') return 'حافلة صغيرة (فان)';
      if (typeLower == 'bus') return 'حافلة ركاب (باص)';
      return s;
    }

    // 2. ترجمة الجنس (male / female) إلى العربي
    if (k == 'gender') {
      final genderLower = s.toLowerCase();
      if (genderLower == 'male') return 'ذكر';
      if (genderLower == 'female') return 'أنثى';
      return s;
    }

    // 3. تحويل التكييف (1 نعم / 0 لا)
    if (k == 'has_ac' || k == 'ac') {
      if (val == 1 || s == '1' || val == true || s.toLowerCase() == 'true') {
        return 'نعم (مزوّد بتكييف)';
      }
      if (val == 0 || s == '0' || val == false || s.toLowerCase() == 'false') {
        return 'لا (غير مزوّد)';
      }
    }

    // 4. تنسيق السعة الاستيعابية للمقاعد
    if (k == 'capacity_manual' || k == 'capacity') {
      final parsed = int.tryParse(s);
      if (parsed != null) return '$parsed مقاعد';
    }

    return s;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final oldText = _formatValue(item.key, item.oldValue);
    final newText = _formatValue(item.key, item.newValue);
    final isChanged = oldText != newText;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isChanged
            ? (isDark ? const Color(0xFF78350F).withValues(alpha: 0.2) : const Color(0xFFFFFBEB))
            : theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isChanged ? const Color(0xFFF59E0B).withValues(alpha: 0.6) : theme.dividerColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_getFieldIcon(item.key), size: 16, color: context.textTertiary),
              const SizedBox(width: 6),
              Text(
                item.label,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  color: context.textPrimary,
                ),
              ),
              if (isChanged) ...[
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'تم التعديل',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFD97706)),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.black12 : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    oldText,
                    style: TextStyle(
                      fontSize: 13,
                      color: context.textSecondary,
                      decoration: isChanged ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Icon(Icons.arrow_back_rounded, size: 18, color: Color(0xFFD97706)),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: isChanged
                        ? const Color(0xFFF59E0B).withValues(alpha: 0.15)
                        : (isDark ? Colors.black12 : const Color(0xFFF1F5F9)),
                    borderRadius: BorderRadius.circular(8),
                    border: isChanged ? Border.all(color: const Color(0xFFD97706).withValues(alpha: 0.4)) : null,
                  ),
                  child: Text(
                    newText,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isChanged ? FontWeight.bold : FontWeight.normal,
                      color: isChanged ? const Color(0xFFD97706) : context.textPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 2. كرت مقارنة التواريخ المخصص مع أيقونة تقويم وشارة السريان
class _DateComparisonTile extends StatelessWidget {
  final _ChangeFieldItem item;
  final bool isDark;

  const _DateComparisonTile({required this.item, required this.isDark});

  String _formatDate(dynamic val) {
    if (val == null) return 'لا يوجد تاريخ سابق';
    final s = val.toString().trim();
    if (s.isEmpty || s == 'null') return 'لا يوجد تاريخ سابق';
    if (s.contains('T')) return s.split('T').first;
    if (s.contains(' ')) return s.split(' ').first;
    return s;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final oldDate = _formatDate(item.oldValue);
    final newDate = _formatDate(item.newValue);
    final isChanged = oldDate != newDate;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isChanged
            ? (isDark ? const Color(0xFF064E3B).withValues(alpha: 0.2) : const Color(0xFFECFDF5))
            : theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isChanged ? const Color(0xFF10B981).withValues(alpha: 0.5) : theme.dividerColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_today_rounded, size: 16, color: context.primaryColor),
              const SizedBox(width: 6),
              Text(
                item.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: context.textPrimary,
                ),
              ),
              if (isChanged) ...[
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'تاريخ جديد ساري المفعول',
                    style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF059669)),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.black12 : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('التاريخ الحالي', style: TextStyle(fontSize: 10.5, color: context.textTertiary)),
                      const SizedBox(height: 2),
                      Text(
                        oldDate,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: context.textSecondary,
                          decoration: isChanged ? TextDecoration.lineThrough : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Icon(Icons.arrow_back_rounded, size: 18, color: Color(0xFF10B981)),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isChanged
                        ? const Color(0xFF10B981).withValues(alpha: 0.15)
                        : (isDark ? Colors.black12 : const Color(0xFFF1F5F9)),
                    borderRadius: BorderRadius.circular(8),
                    border: isChanged ? Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.4)) : null,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('التاريخ المقترح', style: TextStyle(fontSize: 10.5, color: context.primaryColor)),
                      const SizedBox(height: 2),
                      Text(
                        newDate,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isChanged ? const Color(0xFF059669) : context.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 3. كرت مقارنة الصور والوثائق المرفقة (Multipart Files) المطابق لأسلوب DriverDocumentTile
class _ImageComparisonTile extends StatelessWidget {
  final _ChangeFieldItem item;
  final bool isDark;

  const _ImageComparisonTile({required this.item, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final oldUrlStr = item.oldValue?.toString().trim() ?? '';
    final newUrlStr = item.newValue?.toString().trim() ?? '';

    final resolvedOldUrl = MediaUrl.resolve(oldUrlStr);
    final resolvedNewUrl = MediaUrl.resolve(newUrlStr);

    final hasOldFile = resolvedOldUrl != null && resolvedOldUrl.isNotEmpty;
    final hasNewFile = resolvedNewUrl != null && resolvedNewUrl.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1B4B).withValues(alpha: 0.2) : const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF6366F1).withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.image_outlined, size: 18, color: context.primaryColor),
              const SizedBox(width: 8),
              Text(
                item.label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: context.textPrimary,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'وثيقة / صورة مرفقة',
                  style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // 1. الوثيقة الحالية (قبل التعديل)
              Expanded(
                child: _buildDocTile(
                  context,
                  title: '${item.label} (قبل التعديل)',
                  url: resolvedOldUrl,
                  hasFile: hasOldFile,
                  badgeLabel: 'الحالية',
                  badgeColor: Colors.grey,
                ),
              ),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Icon(Icons.arrow_back_rounded, size: 20, color: Color(0xFF6366F1)),
              ),

              // 2. الوثيقة المقترحة (بعد التعديل)
              Expanded(
                child: _buildDocTile(
                  context,
                  title: '${item.label} (بعد التعديل)',
                  url: resolvedNewUrl,
                  hasFile: hasNewFile,
                  badgeLabel: 'المقترحة الجديدة',
                  badgeColor: const Color(0xFF4F46E5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDocTile(
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
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: badgeColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          badgeLabel,
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                            color: badgeColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        hasFile ? 'اضغط التكبير' : 'لا يوجد ملف سابق',
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
}
