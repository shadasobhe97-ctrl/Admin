import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/utils/admin_theme_context.dart';
import '../../../../core/widgets/admin_ui.dart';
import '../../data/models/geography_item_model.dart';
import '../../data/models/geography_type.dart';
import '../../data/models/municipality_model.dart';
import '../../data/models/sub_municipality_model.dart';
import '../../data/models/zone_model.dart';
import '../../logic/cubit/zones_cubit.dart';
import '../../logic/state/zones_state.dart';
import '../widget/geo_breadcrumb.dart';
import '../widget/geo_form_dialog.dart';
import '../widget/geo_node_card.dart';
import '../widget/geography_search_bar.dart';

class ZonesScreen extends StatelessWidget {
  const ZonesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ZonesCubit>(
      create: (_) => sl<ZonesCubit>()..loadGeography(),
      child: const ZonesViewContent(),
    );
  }
}

class ZonesViewContent extends StatefulWidget {
  const ZonesViewContent({super.key});

  @override
  State<ZonesViewContent> createState() => _ZonesViewContentState();
}

class _ZonesViewContentState extends State<ZonesViewContent> {
  final TextEditingController _searchController = TextEditingController();
  GeographyType _selectedFilterType = GeographyType.municipality;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showSnack(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? context.dangerColor : context.successColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ── نماذج الإضافة والتعديل ────────────────────────────────────────────────

  void _openMunicipalityForm(
    BuildContext context, {
    MunicipalityModel? municipality,
  }) {
    final cubit = context.read<ZonesCubit>();
    showDialog(
      context: context,
      builder: (_) => GeoFormDialog(
        kind: GeoFormKind.municipality,
        initialName: municipality?.name,
        onSubmit: (name, _) {
          if (municipality == null) {
            cubit.addMunicipality(name);
          } else {
            cubit.updateMunicipality(municipality.id, name);
          }
        },
      ),
    );
  }

  void _openSubMunicipalityForm(
    BuildContext context, {
    required MunicipalityModel municipality,
    SubMunicipalityModel? subMunicipality,
  }) {
    final cubit = context.read<ZonesCubit>();
    showDialog(
      context: context,
      builder: (_) => GeoFormDialog(
        kind: GeoFormKind.subMunicipality,
        initialName: subMunicipality?.name,
        initialParentId: subMunicipality?.municipalityId ?? municipality.id,
        parentOptions: cubit.municipalities
            .map((item) => GeoParentOption(id: item.id, label: item.name))
            .toList(),
        onSubmit: (name, parentId) {
          if (parentId == null) return;
          if (subMunicipality == null) {
            cubit.addSubMunicipality(name, parentId);
          } else {
            cubit.updateSubMunicipality(subMunicipality.id, name, parentId);
          }
        },
      ),
    );
  }

  void _openZoneForm(
    BuildContext context, {
    int? presetSubMunicipalityId,
    ZoneModel? zone,
  }) {
    final cubit = context.read<ZonesCubit>();
    showDialog(
      context: context,
      builder: (_) => GeoFormDialog(
        kind: GeoFormKind.zone,
        initialName: zone?.name,
        initialParentId: zone?.subMunicipalityId ?? presetSubMunicipalityId,
        parentOptions: _allSubMunicipalityOptions(cubit.municipalities),
        onSubmit: (name, parentId) {
          if (zone == null) {
            cubit.addZone(name, subMunicipalityId: parentId);
          } else {
            cubit.updateZone(zone.id, name, subMunicipalityId: parentId);
          }
        },
      ),
    );
  }

  List<GeoParentOption> _allSubMunicipalityOptions(
    List<MunicipalityModel> municipalities,
  ) {
    return [
      for (final municipality in municipalities)
        for (final sub in municipality.subMunicipalities)
          GeoParentOption(
            id: sub.id,
            label: '${municipality.name} ← ${sub.name}',
          ),
    ];
  }

  // ── تأكيد الحذف ───────────────────────────────────────────────────────────

  void _confirmDelete(
    BuildContext context, {
    required String title,
    required String body,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: dialogContext.cardColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: dialogContext.textPrimary,
            ),
          ),
          content: Text(
            body,
            style: TextStyle(fontSize: 13, color: dialogContext.textSecondary),
          ),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: dialogContext.dangerColor,
                foregroundColor: dialogContext.onPrimary,
              ),
              onPressed: () {
                Navigator.pop(dialogContext);
                onConfirm();
              },
              child: const Text('تأكيد الحذف'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ZonesCubit, ZonesState>(
      listener: (context, state) {
        if (state is GeoActionSuccess) {
          _showSnack(context, state.message);
        } else if (state is GeoActionError) {
          _showSnack(context, state.message, isError: true);
        }
      },
      buildWhen: (_, state) =>
          state is! GeoActionSuccess && state is! GeoActionError,
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _GeoHeader(state: state, onAdd: () => _handleAdd(context, state)),
            const SizedBox(height: 12),
            GeographySearchBar(
              controller: _searchController,
              currentType: _selectedFilterType,
              onTypeChanged: (newType) {
                setState(() {
                  _selectedFilterType = newType;
                });
                if (_searchController.text.trim().isNotEmpty) {
                  context.read<ZonesCubit>().searchGeography(
                        query: _searchController.text,
                        type: newType,
                      );
                }
              },
              onChanged: (text) {
                context.read<ZonesCubit>().searchGeography(
                      query: text,
                      type: _selectedFilterType,
                    );
              },
              onClear: () {
                context.read<ZonesCubit>().clearSearch();
              },
            ),
            const SizedBox(height: 14),
            Expanded(child: _buildMainContent(context, state)),
          ],
        );
      },
    );
  }

  void _handleAdd(BuildContext context, ZonesState state) {
    if (state is SubMunicipalitiesLoaded) {
      _openSubMunicipalityForm(context, municipality: state.municipality);
    } else if (state is ZonesLoaded) {
      _openZoneForm(
        context,
        presetSubMunicipalityId: state.subMunicipality.id,
      );
    } else {
      _openMunicipalityForm(context);
    }
  }

  Widget _buildMainContent(BuildContext context, ZonesState state) {
    if (state is GeoSearchLoading) {
      return const AdminLoadingView(
        message: 'جاري البحث في البيانات الجغرافية...',
      );
    }

    if (state is GeoSearchError) {
      return AdminErrorView(
        message: state.message,
        onRetry: () => context.read<ZonesCubit>().retrySearch(),
      );
    }

    if (state is GeoSearchEmpty) {
      return AdminEmptyView(
        icon: Icons.search_off_rounded,
        message: 'لا توجد نتائج مطابقة للبحث',
        hint: 'جرّب البحث باسم آخر أو اختيار نوع جغرافي مختلف.',
        onRefresh: () {
          _searchController.clear();
          context.read<ZonesCubit>().clearSearch();
        },
      );
    }

    if (state is GeoSearchSuccess) {
      return _buildSearchResultsList(
        context,
        state.results,
        state.type,
      );
    }

    // عند عدم وجود بحث نشط، نعرض شجرة البيانات الحالية
    return _buildBody(context, state);
  }

  Widget _buildSearchResultsList(
    BuildContext context,
    List<GeographyItemModel> results,
    GeographyType type,
  ) {
    final zonesCubit = context.read<ZonesCubit>();

    IconData icon;
    String badgeLabel;

    switch (type) {
      case GeographyType.municipality:
        icon = Icons.location_city_rounded;
        badgeLabel = 'بلدية كبرى';
      case GeographyType.subMunicipality:
        icon = Icons.holiday_village_rounded;
        badgeLabel = 'بلدية فرعية';
      case GeographyType.region:
        icon = Icons.place_rounded;
        badgeLabel = 'منطقة دقيقة';
    }

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            'نتائج البحث (${results.length})',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: context.primaryColor,
            ),
          ),
        ),
        for (final item in results)
          GeoNodeCard(
            icon: icon,
            title: item.name,
            subtitle: zonesCubit.getHierarchySubtitle(item, type),
            badges: [badgeLabel],
            onTap: () {
              if (type == GeographyType.municipality) {
                _searchController.clear();
                zonesCubit.clearSearch();
                zonesCubit.openMunicipality(item.id);
              }
            },
          ),
      ],
    );
  }

  Widget _buildBody(BuildContext context, ZonesState state) {
    if (state is ZonesLoading || state is GeoActionLoading) {
      return Center(
        child: CircularProgressIndicator(color: context.primaryColor),
      );
    }

    if (state is ZonesError) {
      return _GeoMessage(
        icon: Icons.cloud_off_rounded,
        color: context.dangerColor,
        title: 'تعذّر تحميل البيانات الجغرافية',
        body: state.message,
        actionLabel: 'إعادة المحاولة',
        onAction: () => context.read<ZonesCubit>().loadGeography(),
      );
    }

    if (state is MunicipalitiesLoaded) {
      return _buildMunicipalitiesList(context, state);
    }

    if (state is SubMunicipalitiesLoaded) {
      return _buildSubMunicipalitiesList(context, state);
    }

    if (state is ZonesLoaded) {
      return _buildZonesList(context, state);
    }

    return const SizedBox.shrink();
  }

  // ── المستوى الأول: البلديات الكبرى ────────────────────────────────────────

  Widget _buildMunicipalitiesList(
    BuildContext context,
    MunicipalitiesLoaded state,
  ) {
    if (state.isEmpty) {
      return _GeoMessage(
        icon: Icons.location_city_rounded,
        color: context.textMuted,
        title: 'لا توجد بلديات كبرى مسجّلة',
        body: 'ابدأ بإضافة بلدية كبرى، ثم أضف المحلات والمناطق التابعة لها.',
        actionLabel: 'إضافة بلدية كبرى',
        onAction: () => _openMunicipalityForm(context),
      );
    }

    final cubit = context.read<ZonesCubit>();

    return ListView(
      children: [
        for (final municipality in state.municipalities)
          GeoNodeCard(
            icon: Icons.location_city_rounded,
            title: municipality.name,
            badges: [
              '${municipality.subMunicipalitiesCount} بلدية فرعية',
              '${municipality.zonesCount} منطقة',
            ],
            onTap: () => cubit.openMunicipality(municipality.id),
            onEdit: () =>
                _openMunicipalityForm(context, municipality: municipality),
            onDelete: () => _confirmDelete(
              context,
              title: 'حذف البلدية الكبرى',
              body: 'هل تريد حذف "${municipality.name}"؟ '
                  'لا يمكن الحذف إذا كانت تتبعها بلديات فرعية قائمة.',
              onConfirm: () => cubit.deleteMunicipality(municipality.id),
            ),
          ),
        if (state.unassignedZones.isNotEmpty) ...[
          const SizedBox(height: 10),
          _SectionLabel(
            label:
                'مناطق غير مرتبطة بأي بلدية فرعية (${state.unassignedZones.length})',
          ),
          const SizedBox(height: 8),
          for (final zone in state.unassignedZones)
            GeoNodeCard(
              icon: Icons.wrong_location_rounded,
              title: zone.name,
              subtitle: 'غير مرتبطة ببلدية فرعية — يمكن ربطها بالتعديل',
              onEdit: () => _openZoneForm(context, zone: zone),
              onDelete: () => _confirmDelete(
                context,
                title: 'حذف المنطقة',
                body: 'هل تريد حذف منطقة "${zone.name}"؟ '
                    'لا يمكن الحذف إذا كان بها سائقون نشطون.',
                onConfirm: () => cubit.deleteZone(zone.id),
              ),
            ),
        ],
      ],
    );
  }

  // ── المستوى الثاني: البلديات الفرعية ───────────────────────────────────────

  Widget _buildSubMunicipalitiesList(
    BuildContext context,
    SubMunicipalitiesLoaded state,
  ) {
    final cubit = context.read<ZonesCubit>();

    if (state.isEmpty) {
      return _GeoMessage(
        icon: Icons.holiday_village_rounded,
        color: context.textMuted,
        title: 'لا توجد بلديات فرعية تابعة لـ "${state.municipality.name}"',
        body: 'أضف بلدية فرعية لتتمكن من إضافة المناطق الدقيقة بداخلها.',
        actionLabel: 'إضافة بلدية فرعية',
        onAction: () => _openSubMunicipalityForm(
          context,
          municipality: state.municipality,
        ),
      );
    }

    return ListView(
      children: [
        for (final sub in state.subMunicipalities)
          GeoNodeCard(
            icon: Icons.holiday_village_rounded,
            title: sub.name,
            subtitle: 'تابعة لـ ${state.municipality.name}',
            badges: ['${sub.zonesCount} منطقة'],
            onTap: () => cubit.openSubMunicipality(sub.id),
            onEdit: () => _openSubMunicipalityForm(
              context,
              municipality: state.municipality,
              subMunicipality: sub,
            ),
            onDelete: () => _confirmDelete(
              context,
              title: 'حذف البلدية الفرعية',
              body: 'هل تريد حذف "${sub.name}"؟ '
                  'لا يمكن الحذف إذا كانت تتبعها مناطق قائمة.',
              onConfirm: () => cubit.deleteSubMunicipality(sub.id),
            ),
          ),
      ],
    );
  }

  // ── المستوى الثالث: المناطق الدقيقة ───────────────────────────────────────

  Widget _buildZonesList(BuildContext context, ZonesLoaded state) {
    final cubit = context.read<ZonesCubit>();

    if (state.isEmpty) {
      return _GeoMessage(
        icon: Icons.map_rounded,
        color: context.textMuted,
        title: 'لا توجد مناطق في "${state.subMunicipality.name}"',
        body: 'أضف أول منطقة دقيقة داخل هذه البلدية الفرعية.',
        actionLabel: 'إضافة منطقة',
        onAction: () => _openZoneForm(
          context,
          presetSubMunicipalityId: state.subMunicipality.id,
        ),
      );
    }

    return ListView(
      children: [
        for (final zone in state.zones)
          GeoNodeCard(
            icon: Icons.place_rounded,
            title: zone.name,
            subtitle:
                '${state.municipality.name} ← ${state.subMunicipality.name}',
            onEdit: () => _openZoneForm(context, zone: zone),
            onDelete: () => _confirmDelete(
              context,
              title: 'حذف المنطقة',
              body: 'هل تريد حذف منطقة "${zone.name}"؟ '
                  'لا يمكن الحذف إذا كان بها سائقون نشطون.',
              onConfirm: () => cubit.deleteZone(zone.id),
            ),
          ),
      ],
    );
  }
}

/// شريط العنوان: مسار التنقل + زر الإضافة المناسب للمستوى الحالي.
class _GeoHeader extends StatelessWidget {
  final ZonesState state;
  final VoidCallback onAdd;

  const _GeoHeader({required this.state, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ZonesCubit>();

    final items = <GeoBreadcrumbItem>[
      GeoBreadcrumbItem(
        label: 'البلديات الكبرى',
        onTap: state is MunicipalitiesLoaded ? null : cubit.goToRoot,
      ),
    ];

    String addLabel = 'إضافة بلدية كبرى';
    IconData addIcon = Icons.add_business_rounded;

    if (state is SubMunicipalitiesLoaded) {
      final current = state as SubMunicipalitiesLoaded;
      items.add(GeoBreadcrumbItem(label: current.municipality.name));
      addLabel = 'إضافة بلدية فرعية';
      addIcon = Icons.add_home_work_rounded;
    } else if (state is ZonesLoaded) {
      final current = state as ZonesLoaded;
      items.add(
        GeoBreadcrumbItem(
          label: current.municipality.name,
          onTap: cubit.goBack,
        ),
      );
      items.add(GeoBreadcrumbItem(label: current.subMunicipality.name));
      addLabel = 'إضافة منطقة';
      addIcon = Icons.add_location_alt_rounded;
    }

    final canGoBack = state is SubMunicipalitiesLoaded || state is ZonesLoaded;

    return Row(
      children: [
        if (canGoBack)
          IconButton(
            tooltip: 'رجوع',
            onPressed: () {
              cubit.clearSearch();
              cubit.goBack();
            },
            icon: Icon(
              Icons.arrow_forward_rounded,
              size: 19,
              color: context.primaryColor,
            ),
          ),
        Expanded(child: GeoBreadcrumb(items: items)),
        IconButton(
          tooltip: 'تحديث',
          onPressed: () {
            cubit.clearSearch();
            cubit.loadGeography();
          },
          icon: Icon(
            Icons.refresh_rounded,
            size: 19,
            color: context.textTertiary,
          ),
        ),
        const SizedBox(width: 6),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: context.primaryColor,
            foregroundColor: context.onPrimary,
          ),
          onPressed: onAdd,
          icon: Icon(addIcon, size: 16),
          label: Text(addLabel, style: const TextStyle(fontSize: 12)),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.info_outline_rounded, size: 15, color: context.warningColor),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: context.warningColor,
          ),
        ),
      ],
    );
  }
}

/// حالة فارغة أو خطأ بتنسيق موحّد.
class _GeoMessage extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String body;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _GeoMessage({
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 46, color: color),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: context.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              body,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: context.textMuted),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 18),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.primaryColor,
                  foregroundColor: context.onPrimary,
                ),
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
