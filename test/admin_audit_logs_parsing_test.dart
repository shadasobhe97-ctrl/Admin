import 'package:admin_panel/core/utils/json_parsers.dart';
import 'package:admin_panel/features/admin_audit_logs/data/models/audit_log_model.dart';
import 'package:flutter_test/flutter_test.dart';

/// يتحقق أن الواجهة تقرأ إجراءات السجل كما ينص العقد —
/// خصوصاً إجراءات غير السائقين مثل إضافة مدرسة بواسطة مشرف.
void main() {
  group('تحليل استجابة سجل الإجراءات', () {
    test('إجراء «إضافة مدرسة» بواسطة مشرف يُقرأ كاملاً', () {
      final body = {
        'success': true,
        'message': 'تم جلب سجل إجراءات المشرفين بنجاح.',
        'data': [
          {
            'id': 77,
            'admin_id': 5,
            'admin_name': 'سالم المشرف',
            'admin_role': 'مشرف',
            'action': 'create_school',
            'action_label': 'إضافة مدرسة',
            'action_group': 'update',
            'entity_type': 'school',
            'entity_id': 12,
            'entity_name': 'مدرسة الجيل الجديد الأهلية',
            'result': null,
            'reason': null,
            'changes': [
              {
                'field': 'name',
                'label': 'اسم المدرسة',
                'old_value': null,
                'new_value': 'مدرسة الجيل الجديد الأهلية',
              },
            ],
            'created_at': '2026-08-15T09:30:00.000000Z',
          }
        ],
        'meta': {
          'current_page': 1,
          'last_page': 1,
          'per_page': 20,
          'total': 1,
        },
      };

      final items =
          JsonParsers.extractList(body).map(AuditLogModel.fromJson).toList();

      expect(items, hasLength(1), reason: 'يجب ألا يُسقط أي عنصر');

      final log = items.single;
      expect(log.id, 77);
      expect(log.adminName, 'سالم المشرف');
      expect(log.adminRole, 'مشرف');
      expect(log.action, 'create_school');
      expect(log.actionLabel, 'إضافة مدرسة');
      expect(log.actionGroup, 'update');
      expect(log.entityType, 'school');
      expect(log.entityTypeLabel, 'مدرسة');
      expect(log.entityDescription, 'مدرسة الجيل الجديد الأهلية');
      expect(log.createdAt, isNotNull);

      // إجراءات الإنشاء: القيمة القديمة فارغة والجديدة موجودة.
      expect(log.hasChanges, isTrue);
      expect(log.changes.single.isAddition, isTrue);
      expect(log.changes.single.newValue, 'مدرسة الجيل الجديد الأهلية');
    });

    test('العنصر يُقرأ حتى لو غابت الحقول الاختيارية كلها', () {
      final log = AuditLogModel.fromJson({
        'id': 3,
        'admin_name': 'مشرف',
        'action': 'create_school',
      });

      expect(log.actionLabel, 'create_school', reason: 'بديل آمن عند غياب التسمية');
      expect(log.changes, isEmpty);
      expect(log.hasResult, isFalse);
      expect(log.entityDescription, isNotEmpty);
    });

    test('meta تُقرأ من الاستجابة لا من طول القائمة', () {
      final meta = JsonParsers.extractMeta({
        'data': [],
        'meta': {
          'current_page': 2,
          'last_page': 9,
          'per_page': 20,
          'total': 174,
        },
      });

      expect(meta, isNotNull);
      expect(meta!['total'], 174);
      expect(meta['last_page'], 9);
    });
  });
}
