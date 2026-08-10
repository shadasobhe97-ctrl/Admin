import '../../../schools/data/models/zone_model.dart';

abstract class ZonesState {
  const ZonesState();
}

class ZonesInitial extends ZonesState {
  const ZonesInitial();
}

class ZonesLoading extends ZonesState {
  const ZonesLoading();
}

class ZonesLoaded extends ZonesState {
  final List<ZoneModel> flatZones;
  final List<ZoneModel> treeZones;
  final bool isTreeView;

  const ZonesLoaded({
    required this.flatZones,
    required this.treeZones,
    this.isTreeView = true,
  });

  ZonesLoaded copyWith({
    List<ZoneModel>? flatZones,
    List<ZoneModel>? treeZones,
    bool? isTreeView,
  }) {
    return ZonesLoaded(
      flatZones: flatZones ?? this.flatZones,
      treeZones: treeZones ?? this.treeZones,
      isTreeView: isTreeView ?? this.isTreeView,
    );
  }
}

class ZonesEmpty extends ZonesState {
  const ZonesEmpty();
}

class ZonesError extends ZonesState {
  final String message;
  const ZonesError(this.message);
}

class ZoneActionLoading extends ZonesState {
  const ZoneActionLoading();
}

class ZoneActionSuccess extends ZonesState {
  final String message;
  const ZoneActionSuccess(this.message);
}

class ZoneActionError extends ZonesState {
  final String message;
  const ZoneActionError(this.message);
}
