import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_exception.dart';
import '../../data/models/geo_action_result.dart';
import '../../data/models/geo_search_result.dart';
import '../../data/models/municipality_model.dart';
import '../../data/models/sub_municipality_model.dart';
import '../../data/models/zone_model.dart';
import '../../data/repositories/zones_repository_impl.dart';
import '../state/zones_state.dart';

/// منطق التدرّج الجغرافي بثلاثة مستويات:
/// البلديات الكبرى ← البلديات الفرعية ← المناطق الدقيقة.
///
/// الهرمية تأتي جاهزة من `GET /admin/zones-tree` ولا تُبنى في العميل إطلاقاً.
class ZonesCubit extends Cubit<ZonesState> {
  final ZonesRepository _repository;

  ZonesCubit(this._repository) : super(const ZonesInitial());

  /// آخر شجرة تم جلبها من الخادم؛ مصدر التنقل بين المستويات.
  List<MunicipalityModel> _tree = const [];
  List<ZoneModel> _unassignedZones = const [];

  int? _selectedMunicipalityId;
  int? _selectedSubMunicipalityId;
  String _searchQuery = '';

  List<MunicipalityModel> get municipalities => _tree;
  String get searchQuery => _searchQuery;

  /// المستوى المعروض حالياً، لتحديد سلوك أزرار الإضافة والرجوع.
  GeoLevel get currentLevel {
    if (_searchQuery.isNotEmpty) return GeoLevel.search;
    if (_selectedSubMunicipalityId != null) return GeoLevel.zones;
    if (_selectedMunicipalityId != null) return GeoLevel.subMunicipalities;
    return GeoLevel.municipalities;
  }

  String _messageOf(Object error) {
    if (error is ApiException) return error.detailedMessage;
    return error.toString().replaceAll('Exception: ', '');
  }

  void _emitIfOpen(ZonesState state) {
    if (!isClosed) emit(state);
  }

  // ── البحث الجغرافي الشامل ──────────────────────────────────────────────────

  void search(String query) {
    _searchQuery = query.trim();
    _emitCurrentLevel();
  }

  void clearSearch() {
    _searchQuery = '';
    _emitCurrentLevel();
  }

  List<GeoSearchResult> _performSearch(String query) {
    final results = <GeoSearchResult>[];
    final q = query.toLowerCase();

    for (final municipality in _tree) {
      // 1. البلديات الكبرى
      if (municipality.name.toLowerCase().contains(q)) {
        results.add(GeoSearchResult(
          type: GeoSearchResultType.municipality,
          name: municipality.name,
          municipality: municipality,
        ));
      }

      for (final sub in municipality.subMunicipalities) {
        // 2. المحلات (البلديات الفرعية)
        if (sub.name.toLowerCase().contains(q)) {
          results.add(GeoSearchResult(
            type: GeoSearchResultType.subMunicipality,
            name: sub.name,
            subtitle: 'تابعة لـ ${municipality.name}',
            municipality: municipality,
            subMunicipality: sub,
          ));
        }

        for (final zone in sub.zones) {
          // 3. المناطق الدقيقة
          if (zone.name.toLowerCase().contains(q)) {
            results.add(GeoSearchResult(
              type: GeoSearchResultType.zone,
              name: zone.name,
              subtitle: '${municipality.name} ← ${sub.name}',
              municipality: municipality,
              subMunicipality: sub,
              zone: zone,
            ));
          }
        }
      }
    }

    // 4. مناطق غير مرتبطة بأي محلة
    for (final zone in _unassignedZones) {
      if (zone.name.toLowerCase().contains(q)) {
        results.add(GeoSearchResult(
          type: GeoSearchResultType.zone,
          name: zone.name,
          subtitle: 'غير مرتبطة بمحلة',
          zone: zone,
        ));
      }
    }

    return results;
  }

  // ── جلب الشجرة ────────────────────────────────────────────────────────────

  /// يجلب الشجرة الكاملة ثم يعرض المستوى الحالي.
  Future<void> loadGeography() async {
    _emitIfOpen(const ZonesLoading());
    try {
      await _fetchTree();
      _emitCurrentLevel();
    } catch (error) {
      _emitIfOpen(ZonesError(_messageOf(error)));
    }
  }

  Future<void> _fetchTree() async {
    _tree = await _repository.getZonesTree();

    // المناطق التي لا تتبع أي محلة لا تظهر في الشجرة، فتُجلب من القائمة المسطّحة.
    final allZones = await _repository.getZones();
    _unassignedZones =
        allZones.where((zone) => zone.subMunicipalityId == null).toList();
  }

  /// يعيد إصدار حالة المستوى المعروض حالياً اعتماداً على آخر شجرة.
  void _emitCurrentLevel() {
    if (_searchQuery.isNotEmpty) {
      final results = _performSearch(_searchQuery);
      _emitIfOpen(GeoSearchResultsLoaded(query: _searchQuery, results: results));
      return;
    }

    final municipality = _findMunicipality(_selectedMunicipalityId);

    // البلدية المحددة قد تكون حُذفت أثناء العملية الأخيرة.
    if (_selectedMunicipalityId != null && municipality == null) {
      _selectedMunicipalityId = null;
      _selectedSubMunicipalityId = null;
      _emitIfOpen(MunicipalitiesLoaded(_tree, unassignedZones: _unassignedZones));
      return;
    }

    if (municipality == null) {
      _emitIfOpen(MunicipalitiesLoaded(_tree, unassignedZones: _unassignedZones));
      return;
    }

    final subMunicipality = _findSubMunicipality(
      municipality,
      _selectedSubMunicipalityId,
    );

    if (_selectedSubMunicipalityId != null && subMunicipality == null) {
      _selectedSubMunicipalityId = null;
      _emitIfOpen(
        SubMunicipalitiesLoaded(
          municipality: municipality,
          subMunicipalities: municipality.subMunicipalities,
        ),
      );
      return;
    }

    if (subMunicipality == null) {
      _emitIfOpen(
        SubMunicipalitiesLoaded(
          municipality: municipality,
          subMunicipalities: municipality.subMunicipalities,
        ),
      );
      return;
    }

    _emitIfOpen(
      ZonesLoaded(
        municipality: municipality,
        subMunicipality: subMunicipality,
        zones: subMunicipality.zones,
      ),
    );
  }

  MunicipalityModel? _findMunicipality(int? id) {
    if (id == null) return null;
    for (final municipality in _tree) {
      if (municipality.id == id) return municipality;
    }
    return null;
  }

  SubMunicipalityModel? _findSubMunicipality(
    MunicipalityModel municipality,
    int? id,
  ) {
    if (id == null) return null;
    for (final sub in municipality.subMunicipalities) {
      if (sub.id == id) return sub;
    }
    return null;
  }

  // ── التنقل بين المستويات ──────────────────────────────────────────────────

  /// ينزل من البلدية الكبرى إلى محلاتها.
  void openMunicipality(int municipalityId) {
    _searchQuery = '';
    _selectedMunicipalityId = municipalityId;
    _selectedSubMunicipalityId = null;
    _emitCurrentLevel();
  }

  /// ينزل من المحلة إلى مناطقها الدقيقة (داخل البلدية المحددة حالياً).
  void openSubMunicipality(int subMunicipalityId) {
    _searchQuery = '';
    _selectedSubMunicipalityId = subMunicipalityId;
    _emitCurrentLevel();
  }

  /// ينزل مباشرة من نتائج البحث إلى محلة داخل بلديتها الكبرى.
  void openSubMunicipalityWithParent(int municipalityId, int subMunicipalityId) {
    _searchQuery = '';
    _selectedMunicipalityId = municipalityId;
    _selectedSubMunicipalityId = subMunicipalityId;
    _emitCurrentLevel();
  }

  /// يرجع مستوى واحداً للأعلى.
  void goBack() {
    _searchQuery = '';
    if (_selectedSubMunicipalityId != null) {
      _selectedSubMunicipalityId = null;
    } else {
      _selectedMunicipalityId = null;
    }
    _emitCurrentLevel();
  }

  /// يرجع مباشرة إلى قائمة البلديات الكبرى.
  void goToRoot() {
    _searchQuery = '';
    _selectedMunicipalityId = null;
    _selectedSubMunicipalityId = null;
    _emitCurrentLevel();
  }

  // ── تنفيذ عمليات الكتابة ──────────────────────────────────────────────────

  /// ينفّذ عملية كتابة ثم يعيد تحميل الشجرة من الخادم ويعرض المستوى الحالي.
  Future<void> _runAction(
    Future<GeoActionResult> Function() action,
    String fallbackMessage,
  ) async {
    _emitIfOpen(const GeoActionLoading());
    try {
      final result = await action();
      _emitIfOpen(GeoActionSuccess(
        result.message.isEmpty ? fallbackMessage : result.message,
      ));
      await _fetchTree();
      _emitCurrentLevel();
    } catch (error) {
      _emitIfOpen(GeoActionError(_messageOf(error)));
      // إعادة عرض البيانات الحالية حتى لا تبقى الشاشة على حالة الخطأ.
      _emitCurrentLevel();
    }
  }

  // المستوى الأول: البلديات الكبرى

  Future<void> addMunicipality(String name) => _runAction(
        () => _repository.addMunicipality(name: name),
        'تم إضافة البلدية الكبرى بنجاح.',
      );

  Future<void> updateMunicipality(int id, String name) => _runAction(
        () => _repository.updateMunicipality(id, name: name),
        'تم تحديث اسم البلدية بنجاح.',
      );

  Future<void> deleteMunicipality(int id) => _runAction(
        () => _repository.deleteMunicipality(id),
        'تم حذف البلدية بنجاح.',
      );

  // المستوى الثاني: البلديات الفرعية

  Future<void> addSubMunicipality(String name, int municipalityId) =>
      _runAction(
        () => _repository.addSubMunicipality(
          name: name,
          municipalityId: municipalityId,
        ),
        'تم إضافة البلدية الفرعية بنجاح.',
      );

  Future<void> updateSubMunicipality(
    int id,
    String name,
    int municipalityId,
  ) =>
      _runAction(
        () => _repository.updateSubMunicipality(
          id,
          name: name,
          municipalityId: municipalityId,
        ),
        'تم تحديث بيانات البلدية الفرعية بنجاح.',
      );

  Future<void> deleteSubMunicipality(int id) => _runAction(
        () => _repository.deleteSubMunicipality(id),
        'تم حذف البلدية الفرعية بنجاح.',
      );

  // المستوى الثالث: المناطق الدقيقة

  Future<void> addZone(String name, {int? subMunicipalityId}) => _runAction(
        () => _repository.addZone(
          name: name,
          subMunicipalityId: subMunicipalityId,
        ),
        'تم إضافة المنطقة بنجاح.',
      );

  Future<void> updateZone(
    int id,
    String name, {
    int? subMunicipalityId,
  }) =>
      _runAction(
        () => _repository.updateZone(
          id,
          name: name,
          subMunicipalityId: subMunicipalityId,
        ),
        'تم تحديث بيانات المنطقة بنجاح.',
      );

  Future<void> deleteZone(int id) => _runAction(
        () => _repository.deleteZone(id),
        'تم حذف المنطقة من النظام بنجاح.',
      );

  /// تفاصيل منطقة دقيقة من الخادم (GET /admin/zones/{id}).
  Future<void> loadZoneDetails(int id) async {
    _emitIfOpen(const ZoneDetailsLoading());
    try {
      final zone = await _repository.getZoneDetails(id);
      _emitIfOpen(ZoneDetailsLoaded(zone));
    } catch (error) {
      _emitIfOpen(GeoActionError(_messageOf(error)));
    }
  }
}
