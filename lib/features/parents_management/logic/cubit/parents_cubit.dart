import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/parent_model.dart';
import '../../data/repositories/parents_repository.dart';
import 'parents_state.dart';

class ParentsCubit extends Cubit<ParentsState> {
  final ParentsRepository _repository;

  ParentsCubit(this._repository) : super(const ParentsState());

  Future<void> fetchParents() async {
    emit(state.copyWith(isLoading: true, clearMessages: true));
    try {
      final parents = await _repository.getParents();
      final filtered = _filterList(parents, state.searchQuery, state.statusFilter);
      emit(state.copyWith(
        isLoading: false,
        parents: parents,
        filteredParents: filtered,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'تعذر جلب قائمة أولياء الأمور: ${e.toString().replaceAll('Exception: ', '')}',
      ));
    }
  }

  Future<void> fetchParentDetails(int id) async {
    emit(state.copyWith(isDetailsLoading: true, clearMessages: true));
    try {
      final parent = await _repository.getParentDetails(id);
      emit(state.copyWith(
        isDetailsLoading: false,
        selectedParent: parent,
      ));
    } catch (e) {
      emit(state.copyWith(
        isDetailsLoading: false,
        errorMessage: 'تعذر جلب تفاصيل ولي الأمر: ${e.toString().replaceAll('Exception: ', '')}',
      ));
    }
  }

  Future<void> activateParent(int id) async {
    emit(state.copyWith(isActionLoading: true, clearMessages: true));
    try {
      final response = await _repository.activateParent(id);
      final msg = response['message']?.toString() ?? 'تم تحديث حالة حساب ولي الأمر بنجاح';

      // Update parent active status locally
      final updatedParents = state.parents.map((p) {
        if (p.id == id) {
          return p.copyWith(isActive: true);
        }
        return p;
      }).toList();

      ParentModel? updatedSelected = state.selectedParent;
      if (updatedSelected != null && updatedSelected.id == id) {
        updatedSelected = updatedSelected.copyWith(isActive: true);
      }

      final filtered = _filterList(updatedParents, state.searchQuery, state.statusFilter);

      emit(state.copyWith(
        isActionLoading: false,
        parents: updatedParents,
        filteredParents: filtered,
        selectedParent: updatedSelected,
        successMessage: msg,
      ));
    } catch (e) {
      emit(state.copyWith(
        isActionLoading: false,
        errorMessage: 'تعذر إعادة تفعيل حساب ولي الأمر: ${e.toString().replaceAll('Exception: ', '')}',
      ));
    }
  }

  void searchParents(String query) {
    final filtered = _filterList(state.parents, query, state.statusFilter);
    emit(state.copyWith(
      searchQuery: query,
      filteredParents: filtered,
    ));
  }

  void setStatusFilter(String filter) {
    final filtered = _filterList(state.parents, state.searchQuery, filter);
    emit(state.copyWith(
      statusFilter: filter,
      filteredParents: filtered,
    ));
  }

  void clearSelectedParent() {
    emit(state.copyWith(clearSelectedParent: true));
  }

  void clearMessages() {
    emit(state.copyWith(clearMessages: true));
  }

  List<ParentModel> _filterList(List<ParentModel> list, String query, String filter) {
    var result = list;

    if (filter == 'active') {
      result = result.where((p) => p.isActive).toList();
    } else if (filter == 'inactive') {
      result = result.where((p) => !p.isActive).toList();
    }

    if (query.trim().isNotEmpty) {
      final q = query.trim().toLowerCase();
      result = result.where((p) {
        final name = p.fullName.toLowerCase();
        final phone = p.phoneNumber.toLowerCase();
        final email = (p.email ?? '').toLowerCase();
        final idStr = p.id.toString();
        return name.contains(q) || phone.contains(q) || email.contains(q) || idStr.contains(q);
      }).toList();
    }

    return result;
  }
}
