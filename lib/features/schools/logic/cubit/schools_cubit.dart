import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/zone_model.dart';
import '../../data/repositories/schools_repository_impl.dart';
import '../state/schools_state.dart';

class SchoolsCubit extends Cubit<SchoolsState> {
  final SchoolsRepository _repository;
  List<ZoneModel> _cachedZones = [];
  String? _currentSearchQuery;

  SchoolsCubit(this._repository) : super(const SchoolsInitial());

  List<ZoneModel> get cachedZones => _cachedZones;

  Future<void> fetchSchools({String? search}) async {
    _currentSearchQuery = search;
    emit(const SchoolsLoading());
    try {
      if (_cachedZones.isEmpty) {
        _cachedZones = await _repository.getZones();
      }
      final schools = await _repository.getSchools(search: search);
      if (schools.isEmpty) {
        emit(SchoolsEmpty(searchQuery: search, zones: _cachedZones));
      } else {
        emit(SchoolsLoaded(
          schools: schools,
          zones: _cachedZones,
          searchQuery: search,
        ));
      }
    } catch (e) {
      emit(SchoolsError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> fetchSchoolDetails(int id) async {
    emit(const SchoolDetailsLoading());
    try {
      final school = await _repository.getSchoolDetails(id);
      emit(SchoolDetailsLoaded(school));
    } catch (e) {
      emit(SchoolActionError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> addSchool(Map<String, dynamic> data) async {
    emit(const SchoolActionLoading());
    try {
      final res = await _repository.addSchool(data);
      emit(SchoolActionSuccess(res['message']?.toString() ?? 'تم إضافة المدرسة بنجاح.'));
      await fetchSchools(search: _currentSearchQuery);
    } catch (e) {
      emit(SchoolActionError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> updateSchool(int id, Map<String, dynamic> data) async {
    emit(const SchoolActionLoading());
    try {
      final res = await _repository.updateSchool(id, data);
      emit(SchoolActionSuccess(res['message']?.toString() ?? 'تم تحديث البيانات بنجاح.'));
      await fetchSchools(search: _currentSearchQuery);
    } catch (e) {
      emit(SchoolActionError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> deleteSchool(int id) async {
    emit(const SchoolActionLoading());
    try {
      final res = await _repository.deleteSchool(id);
      emit(SchoolActionSuccess(res['message']?.toString() ?? 'تم حذف المدرسة بنجاح.'));
      await fetchSchools(search: _currentSearchQuery);
    } catch (e) {
      emit(SchoolActionError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
