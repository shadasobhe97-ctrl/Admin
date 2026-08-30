import 'municipality_model.dart';
import 'sub_municipality_model.dart';
import 'zone_model.dart';

enum GeoSearchResultType {
  municipality,
  subMunicipality,
  zone,
}

class GeoSearchResult {
  final GeoSearchResultType type;
  final String name;
  final String? subtitle;
  final MunicipalityModel? municipality;
  final SubMunicipalityModel? subMunicipality;
  final ZoneModel? zone;

  const GeoSearchResult({
    required this.type,
    required this.name,
    this.subtitle,
    this.municipality,
    this.subMunicipality,
    this.zone,
  });
}
