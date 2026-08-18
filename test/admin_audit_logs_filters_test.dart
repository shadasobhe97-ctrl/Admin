import 'package:admin_panel/core/models/paginated_result.dart';
import 'package:admin_panel/core/models/pagination_meta_model.dart';
import 'package:admin_panel/features/admin_audit_logs/data/models/audit_dictionaries.dart';
import 'package:admin_panel/features/admin_audit_logs/data/models/audit_log_filters.dart';
import 'package:admin_panel/features/admin_audit_logs/data/models/audit_log_model.dart';
import 'package:admin_panel/features/admin_audit_logs/data/repositories/audit_logs_repository_impl.dart';
import 'package:admin_panel/features/admin_audit_logs/logic/cubit/audit_logs_cubit.dart';
import 'package:admin_panel/features/admin_audit_logs/logic/state/audit_logs_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

/// مستودع وهمي للاختبار فقط — يسجّل الفلاتر التي وصلته
/// ويسمح بالتحكم في زمن الاستجابة لمحاكاة بطء الشبكة.
class _FakeRepository implements AuditLogsRepository {
  final List<AuditLogFilters> receivedFilters = [];
  Duration delay;
  int itemsToReturn;

  _FakeRepository({this.delay = Duration.zero, this.itemsToReturn = 1});

  @override
  Future<PaginatedResult<AuditLogModel>> getAuditLogs(
    AuditLogFilters filters,
  ) async {
    receivedFilters.add(filters);
    if (delay > Duration.zero) await Future<void>.delayed(delay);

    return PaginatedResult<AuditLogModel>(
      items: List.generate(
        itemsToReturn,
        (index) => AuditLogModel(
          id: index + 1,
          adminName: 'مشرف اختبار',
          action: 'update_driver',
          actionLabel: 'تعديل بيانات سائق',
        ),
      ),
      meta: const PaginationMetaModel(currentPage: 1, lastPage: 1, total: 1),
    );
  }

  @override
  Future<AuditLogModel> getAuditLogDetails(int id) async {
    throw UnimplementedError();
  }
}

void main() {
  // في التطبيق تُهيَّأ بيانات اللغة عبر flutter_localizations،
  // وفي الاختبار تُهيَّأ يدوياً لأن AdminFormat يستعمل DateFormat.
  setUpAll(() async => initializeDateFormatting('en'));

  group('AuditLogFilters.toQuery', () {
    test('لا يرسل أي فلتر غير محدد', () {
      final query = const AuditLogFilters().toQuery();

      expect(query.keys, containsAll(<String>['page', 'per_page']));
      expect(query.containsKey('entity_type'), isFalse);
      expect(query.containsKey('action_group'), isFalse);
      expect(query.containsKey('search'), isFalse);
      expect(query.containsKey('date_from'), isFalse);
    });

    test('يرسل الفلاتر المحددة بأسماء العقد الصحيحة', () {
      final query = const AuditLogFilters(
        adminId: 5,
        entityType: AuditEntityType.driver,
        actionGroup: AuditActionGroup.decision,
        search: '  أحمد  ',
      ).toQuery();

      expect(query['admin_id'], 5);
      expect(query['entity_type'], 'driver');
      expect(query['action_group'], 'decision');
      expect(query['search'], 'أحمد'); // يُقصّ الفراغ
    });

    test('نطاق التاريخ لا يُرسل إلا بطرفيه معاً', () {
      final onlyFrom =
          AuditLogFilters(dateFrom: DateTime(2026, 8, 1)).toQuery();
      expect(onlyFrom.containsKey('date_from'), isFalse);

      final both = AuditLogFilters(
        dateFrom: DateTime(2026, 8, 1),
        dateTo: DateTime(2026, 8, 14),
      ).toQuery();
      expect(both['date_from'], '2026-08-01');
      expect(both['date_to'], '2026-08-14');
    });

    test('copyWith يمسح الفلتر عند طلب المسح صراحةً', () {
      const original = AuditLogFilters(entityType: 'driver', search: 'أحمد');

      expect(original.copyWith(clearEntityType: true).entityType, isNull);
      expect(original.copyWith(clearSearch: true).search, isNull);
      // المسح لا يمس بقية الفلاتر
      expect(original.copyWith(clearEntityType: true).search, 'أحمد');
    });
  });

  group('AuditLogsCubit — تطبيق الفلاتر', () {
    test('تغيير نوع العنصر يصل فعلاً إلى المستودع', () async {
      final repository = _FakeRepository();
      final cubit = AuditLogsCubit(repository);

      await cubit.filterByEntityType(AuditEntityType.withdrawal);

      expect(repository.receivedFilters.last.entityType, 'withdrawal');
      expect(cubit.filters.entityType, 'withdrawal');
      await cubit.close();
    });

    test('تغيير الفلتر يعيد الترقيم إلى الصفحة الأولى', () async {
      final repository = _FakeRepository();
      final cubit = AuditLogsCubit(repository);

      await cubit.changePage(4);
      expect(cubit.filters.page, 4);

      await cubit.filterByActionGroup(AuditActionGroup.update);
      expect(cubit.filters.page, 1);
      await cubit.close();
    });

    test('إلغاء كل الفلاتر يعيدها لحالتها الأصلية', () async {
      final repository = _FakeRepository();
      final cubit = AuditLogsCubit(repository);

      await cubit.filterByEntityType(AuditEntityType.driver);
      await cubit.search('أحمد');
      await cubit.clearAllFilters();

      expect(cubit.filters.hasActiveFilters, isFalse);
      expect(repository.receivedFilters.last.entityType, isNull);
      expect(repository.receivedFilters.last.search, isNull);
      await cubit.close();
    });

    /// هذا هو العطل الذي أُصلح: تغيير فلتر أثناء طلب جارٍ كان يُرمى بصمت.
    test('تغيير الفلتر أثناء طلب بطيء لا يضيع ويُعاد الجلب به', () async {
      final repository = _FakeRepository(
        delay: const Duration(milliseconds: 120),
      );
      final cubit = AuditLogsCubit(repository);

      // طلب أول بطيء، ثم تغيير فلتر أثناءه دون انتظار.
      final firstCall = cubit.loadLogs();
      await Future<void>.delayed(const Duration(milliseconds: 20));
      final secondCall = cubit.filterByEntityType(AuditEntityType.dispute);

      await Future.wait([firstCall, secondCall]);

      expect(
        cubit.filters.entityType,
        'dispute',
        reason: 'الفلتر الجديد يجب أن يُحفظ لا أن يُلغى',
      );
      expect(
        repository.receivedFilters.last.entityType,
        'dispute',
        reason: 'يجب إعادة الجلب بالفلتر الجديد بعد انتهاء الطلب الجاري',
      );
      await cubit.close();
    });

    test('القائمة الفارغة مع فلاتر نشطة تُعلَّم كنتيجة فلترة', () async {
      final repository = _FakeRepository(itemsToReturn: 0);
      final cubit = AuditLogsCubit(repository);

      await cubit.filterByEntityType(AuditEntityType.school);

      final state = cubit.state;
      expect(state, isA<AuditLogsEmpty>());
      expect((state as AuditLogsEmpty).isFiltered, isTrue);
      await cubit.close();
    });

    test('القائمة الفارغة بلا فلاتر لا تُعلَّم كنتيجة فلترة', () async {
      final repository = _FakeRepository(itemsToReturn: 0);
      final cubit = AuditLogsCubit(repository);

      await cubit.loadLogs();

      expect((cubit.state as AuditLogsEmpty).isFiltered, isFalse);
      await cubit.close();
    });
  });
}
