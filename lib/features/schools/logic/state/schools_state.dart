import '../../../zones/data/models/zone_model.dart';
import '../../data/models/school_model.dart';

abstract class SchoolsState {
  const SchoolsState();
}

class SchoolsInitial extends SchoolsState {
  const SchoolsInitial();
}

class SchoolsLoading extends SchoolsState {
  const SchoolsLoading();
}

class SchoolsLoaded extends SchoolsState {
  /// المدارس بعد تطبيق البحث والفلترة محلياً.
  final List<SchoolModel> schools;
  final List<ZoneModel> zones;
  final String? searchQuery;

  /// فلتر الحالة المطبّق حالياً (`approved` / `pending`)، أو `null` للكل.
  final String? statusFilter;

  /// إجمالي المدارس قبل الفلترة، لعرضه في العدّاد.
  final int totalCount;

  const SchoolsLoaded({
    required this.schools,
    required this.zones,
    required this.totalCount,
    this.searchQuery,
    this.statusFilter,
  });
}

class SchoolsEmpty extends SchoolsState {
  final List<ZoneModel> zones;
  final String? searchQuery;
  final String? statusFilter;

  /// `true` إذا كانت القائمة فارغة بسبب البحث أو الفلترة لا لعدم وجود بيانات.
  final bool isFiltered;

  const SchoolsEmpty({
    this.zones = const [],
    this.searchQuery,
    this.statusFilter,
    this.isFiltered = false,
  });
}

class SchoolsError extends SchoolsState {
  final String message;
  const SchoolsError(this.message);
}

class SchoolDetailsLoading extends SchoolsState {
  const SchoolDetailsLoading();
}

class SchoolDetailsLoaded extends SchoolsState {
  final SchoolModel school;
  const SchoolDetailsLoaded(this.school);
}

class SchoolActionLoading extends SchoolsState {
  const SchoolActionLoading();
}

class SchoolActionSuccess extends SchoolsState {
  final String message;
  const SchoolActionSuccess(this.message);
}

class SchoolActionError extends SchoolsState {
  final String message;
  const SchoolActionError(this.message);
}
