import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_exception.dart';
import '../../data/models/geo_action_result.dart';
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

  List<MunicipalityModel> get municipalities => _tree;

  /// المستوى المعروض حالياً، لتحديد سلوك أزرار الإضافة والرجوع.
  GeoLevel get currentLevel {
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
    _selectedMunicipalityId = municipalityId;
    _selectedSubMunicipalityId = null;
    _emitCurrentLevel();
  }

  /// ينزل من المحلة إلى مناطقها الدقيقة.
  void openSubMunicipality(int subMunicipalityId) {
    _selectedSubMunicipalityId = subMunicipalityId;
    _emitCurrentLevel();
  }

  /// يرجع مستوى واحداً للأعلى.
  void goBack() {
    if (_selectedSubMunicipalityId != null) {
      _selectedSubMunicipalityId = null;
    } else {
      _selectedMunicipalityId = null;
    }
    _emitCurrentLevel();
  }

  /// يرجع مباشرة إلى قائمة البلديات الكبرى.
  void goToRoot() {
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

  Timer? _debounceTimer;
  String _lastSearchQuery = '';
  GeographyType? _lastSearchType;

  /// يرجع التسلسل الجغرافي الكامل كـ Subtitle لعنصر نتيجة البحث.
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

  // ── 5. البحث في البيانات الجغرافية ─────────────────────────────────────────

  /// ينفّذ عملية البحث مع التأكّد من التمهل (Debounce 400ms) وتنظيف النص.
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
      _performSearch(query: trimmed, type: type);
    });
  }

  /// إعادة المحاولة الفورية لنفس النص ونفس نوع الجغرافيا عند حدوث خطأ.
  void retrySearch() {
    final currentState = state;
    if (currentState is GeoSearchError) {
      _performSearch(query: currentState.query, type: currentState.type);
    } else if (_lastSearchQuery.isNotEmpty && _lastSearchType != null) {
      _performSearch(query: _lastSearchQuery, type: _lastSearchType!);
    }
  }

  Future<void> _performSearch({
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

  /// إعادة ضبط حالة البحث وتفريغ النتائج والعودة للشجرة الأصلية المحفوظة في الذاكرة بدون طلب شبكة.
  void clearSearch() {
    _debounceTimer?.cancel();
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
