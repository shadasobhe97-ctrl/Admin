import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_exception.dart';
import '../../../zones/data/models/zone_model.dart';
import '../../data/models/school_model.dart';
import '../../data/models/school_payload.dart';
import '../../data/repositories/schools_repository_impl.dart';
import '../state/schools_state.dart';

class SchoolsCubit extends Cubit<SchoolsState> {
  final SchoolsRepository _repository;

  SchoolsCubit(this._repository) : super(const SchoolsInitial());

  /// القائمة الكاملة كما وردت من الخادم؛ البحث والفلترة يُطبّقان عليها محلياً
  /// لأن العقد لا يوثّق أي Query Parameters لمسار المدارس.
  List<SchoolModel> _allSchools = const [];
  List<ZoneModel> _cachedZones = const [];

  String? _searchQuery;
  String? _statusFilter;

  List<ZoneModel> get cachedZones => _cachedZones;

  String _messageOf(Object error) {
    if (error is ApiException) return error.detailedMessage;
    return error.toString().replaceAll('Exception: ', '');
  }

  void _emitIfOpen(SchoolsState state) {
    if (!isClosed) emit(state);
  }

  // ── الجلب ─────────────────────────────────────────────────────────────────

  Future<void> fetchSchools() async {
    _emitIfOpen(const SchoolsLoading());
    try {
      if (_cachedZones.isEmpty) {
        _cachedZones = await _repository.getZones();
      }
      _allSchools = await _repository.getSchools();
      _emitFilteredList();
    } catch (error) {
      _emitIfOpen(SchoolsError(_messageOf(error)));
    }
  }

  Future<void> fetchSchoolDetails(int id) async {
    _emitIfOpen(const SchoolDetailsLoading());
    try {
      final school = await _repository.getSchoolDetails(id);
      _emitIfOpen(SchoolDetailsLoaded(school));
    } catch (error) {
      _emitIfOpen(SchoolActionError(_messageOf(error)));
    }
  }

  // ── البحث والفلترة (محلياً) ───────────────────────────────────────────────

  void search(String? query) {
    _searchQuery = (query == null || query.trim().isEmpty) ? null : query.trim();
    _emitFilteredList();
  }

  void filterByStatus(String? status) {
    _statusFilter = status;
    _emitFilteredList();
  }

  void clearFilters() {
    _searchQuery = null;
    _statusFilter = null;
    _emitFilteredList();
  }

  /// يطبّق البحث على الاسم والعنوان واسم المنطقة، ثم فلتر الحالة.
  List<SchoolModel> _applyFilters() {
    return _allSchools.where((school) {
      if (_statusFilter != null && school.status != _statusFilter) return false;

      final query = _searchQuery?.toLowerCase();
      if (query == null) return true;

      return school.name.toLowerCase().contains(query) ||
          school.address.toLowerCase().contains(query) ||
          (school.zoneName?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  void _emitFilteredList() {
    final filtered = _applyFilters();
    final hasActiveFilters = _searchQuery != null || _statusFilter != null;

    if (filtered.isEmpty) {
      _emitIfOpen(
        SchoolsEmpty(
          zones: _cachedZones,
          searchQuery: _searchQuery,
          statusFilter: _statusFilter,
          isFiltered: hasActiveFilters && _allSchools.isNotEmpty,
        ),
      );
      return;
    }

    _emitIfOpen(
      SchoolsLoaded(
        schools: filtered,
        zones: _cachedZones,
        totalCount: _allSchools.length,
        searchQuery: _searchQuery,
        statusFilter: _statusFilter,
      ),
    );
  }

  // ── عمليات الكتابة ────────────────────────────────────────────────────────

  /// ينفّذ العملية ثم يعيد جلب القائمة من الخادم مع الحفاظ على الفلاتر.
  Future<void> _runAction(Future<String> Function() action) async {
    _emitIfOpen(const SchoolActionLoading());
    try {
      final message = await action();
      _emitIfOpen(SchoolActionSuccess(message));
      await fetchSchools();
    } catch (error) {
      _emitIfOpen(SchoolActionError(_messageOf(error)));
      // إعادة عرض البيانات الحالية حتى لا تبقى الشاشة عالقة على حالة الخطأ.
      _emitFilteredList();
    }
  }

  Future<void> addSchool(CreateSchoolPayload payload) => _runAction(
        () async => (await _repository.addSchool(payload)).message,
      );

  Future<void> updateSchool(int id, UpdateSchoolPayload payload) async {
    // لا يُرسل طلب إن لم يتغيّر أي حقل.
    if (payload.isEmpty) {
      _emitIfOpen(const SchoolActionSuccess('لم يتم تعديل أي بيانات.'));
      _emitFilteredList();
      return;
    }

    await _runAction(
      () async => (await _repository.updateSchool(id, payload)).message,
    );
  }

  Future<void> deleteSchool(int id) => _runAction(
        () async => (await _repository.deleteSchool(id)).message,
      );
}
