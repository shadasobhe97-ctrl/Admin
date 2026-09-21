import '../../data/models/parent_model.dart';

class ParentsState {
  final bool isLoading;
  final bool isDetailsLoading;
  final bool isActionLoading;
  final List<ParentModel> parents;
  final List<ParentModel> filteredParents;
  final ParentModel? selectedParent;
  final String? errorMessage;
  final String? successMessage;
  final String searchQuery;
  final String statusFilter; // 'all', 'active', 'inactive'

  const ParentsState({
    this.isLoading = false,
    this.isDetailsLoading = false,
    this.isActionLoading = false,
    this.parents = const [],
    this.filteredParents = const [],
    this.selectedParent,
    this.errorMessage,
    this.successMessage,
    this.searchQuery = '',
    this.statusFilter = 'all',
  });

  ParentsState copyWith({
    bool? isLoading,
    bool? isDetailsLoading,
    bool? isActionLoading,
    List<ParentModel>? parents,
    List<ParentModel>? filteredParents,
    ParentModel? selectedParent,
    String? errorMessage,
    String? successMessage,
    String? searchQuery,
    String? statusFilter,
    bool clearSelectedParent = false,
    bool clearMessages = false,
  }) {
    return ParentsState(
      isLoading: isLoading ?? this.isLoading,
      isDetailsLoading: isDetailsLoading ?? this.isDetailsLoading,
      isActionLoading: isActionLoading ?? this.isActionLoading,
      parents: parents ?? this.parents,
      filteredParents: filteredParents ?? this.filteredParents,
      selectedParent: clearSelectedParent ? null : (selectedParent ?? this.selectedParent),
      errorMessage: clearMessages ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearMessages ? null : (successMessage ?? this.successMessage),
      searchQuery: searchQuery ?? this.searchQuery,
      statusFilter: statusFilter ?? this.statusFilter,
    );
  }
}
