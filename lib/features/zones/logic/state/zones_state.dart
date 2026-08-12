import '../../data/models/municipality_model.dart';
import '../../data/models/sub_municipality_model.dart';
import '../../data/models/zone_model.dart';

/// المستوى المعروض حالياً في التدرّج الجغرافي.
enum GeoLevel { municipalities, subMunicipalities, zones }

abstract class ZonesState {
  const ZonesState();
}

class ZonesInitial extends ZonesState {
  const ZonesInitial();
}

class ZonesLoading extends ZonesState {
  const ZonesLoading();
}

class ZonesError extends ZonesState {
  final String message;
  const ZonesError(this.message);
}

/// المستوى الأول: قائمة البلديات الكبرى.
class MunicipalitiesLoaded extends ZonesState {
  final List<MunicipalityModel> municipalities;

  /// مناطق دقيقة أنشئت بدون `sub_municipality_id`، فلا تظهر في الشجرة.
  /// تُعرض منفصلة حتى يمكن ربطها أو حذفها بدل أن تبقى غير مرئية.
  final List<ZoneModel> unassignedZones;

  const MunicipalitiesLoaded(
    this.municipalities, {
    this.unassignedZones = const [],
  });

  bool get isEmpty => municipalities.isEmpty && unassignedZones.isEmpty;
}

/// المستوى الثاني: محلات بلدية كبرى محددة.
class SubMunicipalitiesLoaded extends ZonesState {
  final MunicipalityModel municipality;
  final List<SubMunicipalityModel> subMunicipalities;

  const SubMunicipalitiesLoaded({
    required this.municipality,
    required this.subMunicipalities,
  });

  bool get isEmpty => subMunicipalities.isEmpty;
}

/// المستوى الثالث: مناطق محلة محددة.
class ZonesLoaded extends ZonesState {
  final MunicipalityModel municipality;
  final SubMunicipalityModel subMunicipality;
  final List<ZoneModel> zones;

  const ZonesLoaded({
    required this.municipality,
    required this.subMunicipality,
    required this.zones,
  });

  bool get isEmpty => zones.isEmpty;
}

/// تفاصيل منطقة دقيقة واحدة (GET /admin/zones/{id}).
class ZoneDetailsLoading extends ZonesState {
  const ZoneDetailsLoading();
}

class ZoneDetailsLoaded extends ZonesState {
  final ZoneModel zone;
  const ZoneDetailsLoaded(this.zone);
}

// ── حالات عمليات الكتابة (مشتركة بين المستويات الثلاثة) ─────────────────────

class GeoActionLoading extends ZonesState {
  const GeoActionLoading();
}

class GeoActionSuccess extends ZonesState {
  final String message;
  const GeoActionSuccess(this.message);
}

class GeoActionError extends ZonesState {
  final String message;
  const GeoActionError(this.message);
}
