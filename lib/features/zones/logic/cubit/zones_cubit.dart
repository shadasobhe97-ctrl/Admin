import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_exception.dart';
import '../../data/models/geo_action_result.dart';
import '../../data/models/geo_search_result.dart';
import '../../data/models/geography_item_model.dart';
import '../../data/models/geography_type.dart';
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

  // ── جلب الشجرة من السيرفر ──────────────────────────────────────────────────

  Future<void> loadGeography() async {
    _emitIfOpen(const ZonesLoading());
    await _fetchTree();
    _emitCurrentLevel();
  }

  Future<void> _fetchTree() async {
    try {
      _tree = await _repository.getZonesTree();
      _unassignedZones = const [];
    } catch (error) {
      _emitIfOpen(ZonesError(_messageOf(error)));
    }
  }

  /// يصدر الحالة المطابقة للمستوى الحالي أو نتائج البحث المحلي.
  void _emitCurrentLevel() {
    if (_searchQuery.isNotEmpty) {
      final results = _performLocalSearch(_searchQuery);
      _emitIfOpen(GeoSearchResultsLoaded(
        query: _searchQuery,
        results: results,
      ));
      return;
    }

    if (_selectedSubMunicipalityId != null && _selectedMunicipalityId != null) {
      final parentM = _findMunicipality(_selectedMunicipalityId);
      final sub = parentM != null
          ? _findSubMunicipality(parentM, _selectedSubMunicipalityId)
          : null;

      if (parentM != null && sub != null) {
        _emitIfOpen(ZonesLoaded(
          municipality: parentM,
          subMunicipality: sub,
          zones: sub.zones,
        ));
        return;
      }
    }

    if (_selectedMunicipalityId != null) {
      final parentM = _findMunicipality(_selectedMunicipalityId);
      if (parentM != null) {
        _emitIfOpen(SubMunicipalitiesLoaded(
          municipality: parentM,
          subMunicipalities: parentM.subMunicipalities,
        ));
        return;
      }
    }

    _emitIfOpen(MunicipalitiesLoaded(
      _tree,
      unassignedZones: _unassignedZones,
    ));
  }

  // ── البحث الجغرافي المحلي والشامل ──────────────────────────────────────────

  void search(String query) {
    _searchQuery = query.trim();
    _emitCurrentLevel();
  }

  List<GeoSearchResult> _performLocalSearch(String query) {
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
          subtitle: 'منطقة مستقلة (غير مرتبطة ببلدية فرعية)',
          zone: zone,
        ));
      }
    }

    return results;
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

  void openMunicipality(int municipalityId) {
    _searchQuery = '';
    _selectedMunicipalityId = municipalityId;
    _selectedSubMunicipalityId = null;
    _emitCurrentLevel();
  }

  void openSubMunicipality(int subMunicipalityId) {
    _searchQuery = '';
    _selectedSubMunicipalityId = subMunicipalityId;
    _emitCurrentLevel();
  }

  void openSubMunicipalityWithParent(int municipalityId, int subMunicipalityId) {
    _searchQuery = '';
    _selectedMunicipalityId = municipalityId;
    _selectedSubMunicipalityId = subMunicipalityId;
    _emitCurrentLevel();
  }

  void goBack() {
    _searchQuery = '';
    if (_selectedSubMunicipalityId != null) {
      _selectedSubMunicipalityId = null;
    } else {
      _selectedMunicipalityId = null;
    }
    _emitCurrentLevel();
  }

  void goToRoot() {
    _searchQuery = '';
    _selectedMunicipalityId = null;
    _selectedSubMunicipalityId = null;
    _emitCurrentLevel();
  }

  // ── تنفيذ عمليات الكتابة ──────────────────────────────────────────────────

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
      _emitCurrentLevel();
    }
  }

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

  Timer? _debounceTimer;
  String _lastSearchQuery = '';
  GeographyType? _lastSearchType;

  String? getHierarchySubtitle(GeographyItemModel item, GeographyType type) {
    switch (type) {
      case GeographyType.municipality:
        final m = _findMunicipality(item.id);
        if (m != null) {
          return '${m.subMunicipalitiesCount} بلدية فرعية • ${m.zonesCount} منطقة';
        }
        return 'بلدية كبرى مسجلة في النظام';

      case GeographyType.subMunicipality:
        if (item.municipalityId != null) {
          final parentM = _findMunicipality(item.municipalityId);
          if (parentM != null) {
            return 'تابعة لـ ${parentM.name}';
          }
        }
        for (final m in _tree) {
          for (final sub in m.subMunicipalities) {
            if (sub.id == item.id) {
              return 'تابعة لـ ${m.name}';
            }
          }
        }
        return 'بلدية فرعية';

      case GeographyType.region:
        for (final m in _tree) {
          for (final sub in m.subMunicipalities) {
            for (final z in sub.zones) {
              if (z.id == item.id) {
                return '${m.name} ← ${sub.name}';
              }
            }
          }
        }
        if (item.municipalityId != null) {
          final parentM = _findMunicipality(item.municipalityId);
          if (parentM != null) {
            return 'تابعة لـ ${parentM.name}';
          }
        }
        return 'منطقة دقيقة';
    }
  }

  Future<void> loadZoneDetails(int id) async {
    _emitIfOpen(const ZoneDetailsLoading());
    try {
      final zone = await _repository.getZoneDetails(id);
      _emitIfOpen(ZoneDetailsLoaded(zone));
    } catch (error) {
      _emitIfOpen(GeoActionError(_messageOf(error)));
    }
  }

  // ── 5. البحث في البيانات الجغرافية عبر API ─────────────────────────────────

  void searchGeography({
    required String query,
    required GeographyType type,
  }) {
    final trimmed = query.trim();
    _lastSearchQuery = trimmed;
    _lastSearchType = type;

    _debounceTimer?.cancel();

    if (trimmed.isEmpty) {
      clearSearch();
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      _performRemoteSearch(query: trimmed, type: type);
    });
  }

  void retrySearch() {
    final currentState = state;
    if (currentState is GeoSearchError) {
      _performRemoteSearch(query: currentState.query, type: currentState.type);
    } else if (_lastSearchQuery.isNotEmpty && _lastSearchType != null) {
      _performRemoteSearch(query: _lastSearchQuery, type: _lastSearchType!);
    }
  }

  Future<void> _performRemoteSearch({
    required String query,
    required GeographyType type,
  }) async {
    if (isClosed) return;
    _emitIfOpen(GeoSearchLoading(query: query, type: type));

    try {
      final results = await _repository.searchGeography(
        searchKeyword: query,
        type: type,
      );

      if (isClosed) return;

      if (results.isEmpty) {
        _emitIfOpen(GeoSearchEmpty(query: query, type: type));
      } else {
        _emitIfOpen(GeoSearchSuccess(
          results: results,
          query: query,
          type: type,
        ));
      }
    } catch (error) {
      if (isClosed) return;
      _emitIfOpen(GeoSearchError(
        message: _messageOf(error),
        query: query,
        type: type,
      ));
    }
  }

  void clearSearch() {
    _debounceTimer?.cancel();
    _searchQuery = '';
    _lastSearchQuery = '';
    _lastSearchType = null;
    _emitCurrentLevel();
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }
}
