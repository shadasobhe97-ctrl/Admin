import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../schools/data/models/zone_model.dart';
import '../../data/repositories/zones_repository_impl.dart';
import '../state/zones_state.dart';

class ZonesCubit extends Cubit<ZonesState> {
  final ZonesRepository _repository;
  bool _isTreeView = true;

  ZonesCubit(this._repository) : super(const ZonesInitial());

  bool get isTreeView => _isTreeView;

  Future<void> fetchZones() async {
    emit(const ZonesLoading());
    try {
      final flatZones = await _repository.getZones();
      List<ZoneModel> treeResult = await _repository.getZonesTree();

      // Check if treeResult is already nested
      final bool hasNestedChildren = treeResult.any((z) => z.children.isNotEmpty);

      if (!hasNestedChildren && flatZones.isNotEmpty) {
        // Build multi-level tree recursively from flat list using parent_id
        treeResult = _buildTreeFromFlat(flatZones.isNotEmpty ? flatZones : treeResult);
      }

      if (flatZones.isEmpty && treeResult.isEmpty) {
        emit(const ZonesEmpty());
      } else {
        emit(ZonesLoaded(
          flatZones: flatZones.isNotEmpty ? flatZones : _flattenTree(treeResult),
          treeZones: treeResult.isNotEmpty ? treeResult : _buildTreeFromFlat(flatZones),
          isTreeView: _isTreeView,
        ));
      }
    } catch (e) {
      emit(ZonesError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  void toggleViewMode() {
    if (state is ZonesLoaded) {
      final currentState = state as ZonesLoaded;
      _isTreeView = !currentState.isTreeView;
      emit(currentState.copyWith(isTreeView: _isTreeView));
    }
  }

  Future<void> addZone(Map<String, dynamic> data) async {
    emit(const ZoneActionLoading());
    try {
      final res = await _repository.addZone(data);
      emit(ZoneActionSuccess(res['message']?.toString() ?? 'تم إضافة المنطقة بنجاح.'));
      await fetchZones();
    } catch (e) {
      emit(ZoneActionError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> updateZone(int id, Map<String, dynamic> data) async {
    emit(const ZoneActionLoading());
    try {
      // Endpoint uses PUT /api/admin/zones/{id}
      final res = await _repository.updateZone(id, data);
      emit(ZoneActionSuccess(res['message']?.toString() ?? 'تم تعديل المنطقة بنجاح.'));
      await fetchZones();
    } catch (e) {
      emit(ZoneActionError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> deleteZone(int id) async {
    emit(const ZoneActionLoading());
    try {
      final res = await _repository.deleteZone(id);
      emit(ZoneActionSuccess(res['message']?.toString() ?? 'تم حذف المنطقة بنجاح.'));
      await fetchZones();
    } catch (e) {
      emit(ZoneActionError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  List<ZoneModel> _buildTreeFromFlat(List<ZoneModel> flat) {
    if (flat.isEmpty) return [];
    final Map<int, List<ZoneModel>> childrenMap = {};
    final List<ZoneModel> roots = [];

    for (var z in flat) {
      if (z.parentId == null) {
        roots.add(z);
      } else {
        childrenMap.putIfAbsent(z.parentId!, () => []).add(z);
      }
    }

    // Fallback: If no item has parentId == null, treat items with parentId not in flat as roots
    if (roots.isEmpty) {
      final allIds = flat.map((e) => e.id).toSet();
      for (var z in flat) {
        if (z.parentId == null || !allIds.contains(z.parentId)) {
          roots.add(z);
        }
      }
    }

    ZoneModel populateChildren(ZoneModel parent) {
      final kids = childrenMap[parent.id] ?? [];
      if (kids.isEmpty) return parent;
      final populatedKids = kids.map((k) => populateChildren(k)).toList();
      return parent.copyWith(children: populatedKids);
    }

    return roots.map((r) => populateChildren(r)).toList();
  }

  List<ZoneModel> _flattenTree(List<ZoneModel> tree) {
    final List<ZoneModel> flat = [];
    void traverse(ZoneModel node) {
      flat.add(node);
      for (var child in node.children) {
        traverse(child);
      }
    }
    for (var root in tree) {
      traverse(root);
    }
    return flat;
  }
}
