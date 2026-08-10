import '../../data/models/school_model.dart';
import '../../data/models/zone_model.dart';

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
  final List<SchoolModel> schools;
  final List<ZoneModel> zones;
  final String? searchQuery;

  const SchoolsLoaded({
    required this.schools,
    required this.zones,
    this.searchQuery,
  });
}

class SchoolsEmpty extends SchoolsState {
  final String? searchQuery;
  final List<ZoneModel> zones;

  const SchoolsEmpty({
    this.searchQuery,
    this.zones = const [],
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
