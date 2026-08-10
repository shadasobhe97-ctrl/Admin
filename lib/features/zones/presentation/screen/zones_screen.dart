import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/service_locator.dart';
import '../../../schools/data/models/zone_model.dart';
import '../../logic/cubit/zones_cubit.dart';
import '../../logic/state/zones_state.dart';
import '../widget/zone_card.dart';
import '../widget/zone_form.dart';
import '../widget/zone_tree.dart';

class ZonesScreen extends StatelessWidget {
  const ZonesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ZonesCubit>(
      create: (_) => sl<ZonesCubit>()..fetchZones(),
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
  void _showSnack(String msg, {bool isError = false}) {
    if (!mounted) return;
    final theme = Theme.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? theme.colorScheme.error : theme.colorScheme.secondary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _openAddZoneModal(BuildContext context, {int? initialParentId, List<ZoneModel> availableZones = const []}) {
    showDialog(
      context: context,
      builder: (_) => ZoneFormDialog(
        initialParentId: initialParentId,
        availableZones: availableZones,
        onSubmit: (payload) {
          context.read<ZonesCubit>().addZone(payload);
        },
      ),
    );
  }

  void _openEditZoneModal(BuildContext context, ZoneModel zone, List<ZoneModel> availableZones) {
    showDialog(
      context: context,
      builder: (_) => ZoneFormDialog(
        zone: zone,
        availableZones: availableZones,
        onSubmit: (payload) {
          // Uses PUT /api/admin/zones/{id}
          context.read<ZonesCubit>().updateZone(zone.id, payload);
        },
      ),
    );
  }

  void _confirmDeleteZone(BuildContext context, ZoneModel zone) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: theme.cardColor,
          title: const Text('تأكيد حذف المنطقة الجغرافية'),
          content: Text('هل أنت متأكد من رغبتك في حذف منطقة "${zone.name}" من النظام؟'),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(ctx);
                context.read<ZonesCubit>().deleteZone(zone.id);
              },
              child: const Text('حذف المنطقة'),
            ),
          ],
        ),
      ),
    );
  }

  String _getParentName(int parentId, List<ZoneModel> flatZones) {
    final match = flatZones.firstWhere(
      (z) => z.id == parentId,
      orElse: () => ZoneModel(id: parentId, name: '#$parentId'),
    );
    return match.name;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<ZonesCubit, ZonesState>(
      listener: (context, state) {
        if (state is ZoneActionSuccess) {
          _showSnack(state.message, isError: false);
        } else if (state is ZoneActionError) {
          _showSnack(state.message, isError: true);
        }
      },
      builder: (context, state) {
        List<ZoneModel> flatZones = [];
        List<ZoneModel> treeZones = [];
        bool isTreeView = true;
        bool isLoading = false;
        String? errorMessage;

        if (state is ZonesLoading || state is ZoneActionLoading) {
          isLoading = true;
        } else if (state is ZonesLoaded) {
          flatZones = state.flatZones;
          treeZones = state.treeZones;
          isTreeView = state.isTreeView;
        } else if (state is ZonesError) {
          errorMessage = state.message;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Bar & View Switcher
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'إدارة المناطق الجغرافية والبلديات',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      tooltip: isTreeView ? 'تحويل للعرض القائم' : 'تحويل للعرض الشجري',
                      icon: Icon(
                        isTreeView ? Icons.view_list_rounded : Icons.account_tree_rounded,
                        color: theme.colorScheme.primary,
                      ),
                      onPressed: () {
                        context.read<ZonesCubit>().toggleViewMode();
                      },
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => _openAddZoneModal(
                        context,
                        availableZones: flatZones,
                      ),
                      icon: const Icon(Icons.add_location_alt_rounded, size: 16),
                      label: const Text('إضافة منطقة جديدة'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Content Section
            Expanded(
              child: isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: theme.colorScheme.primary,
                      ),
                    )
                  : errorMessage != null
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline_rounded,
                                  size: 50,
                                  color: theme.colorScheme.error,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  errorMessage,
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.error,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () => context.read<ZonesCubit>().fetchZones(),
                                  child: const Text('إعادة المحاولة'),
                                ),
                              ],
                            ),
                          ),
                        )
                      : (flatZones.isEmpty && treeZones.isEmpty)
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.map_outlined,
                                    size: 60,
                                    color: theme.colorScheme.outline,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'لا توجد مناطق جغرافية مسجلة حالياً في النظام',
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton.icon(
                                    onPressed: () => _openAddZoneModal(
                                      context,
                                      availableZones: flatZones,
                                    ),
                                    icon: const Icon(Icons.add_location_alt_rounded),
                                    label: const Text('إضافة منطقة جديدة'),
                                  ),
                                ],
                              ),
                            )
                          : isTreeView
                              ? ZoneTreeWidget(
                                  treeZones: treeZones,
                                  onAddChild: (parentZone) {
                                    _openAddZoneModal(
                                      context,
                                      initialParentId: parentZone.id,
                                      availableZones: flatZones,
                                    );
                                  },
                                  onEdit: (zone) {
                                    _openEditZoneModal(context, zone, flatZones);
                                  },
                                  onDelete: (zone) {
                                    _confirmDeleteZone(context, zone);
                                  },
                                )
                              : ListView.builder(
                                  physics: const BouncingScrollPhysics(),
                                  itemCount: flatZones.length,
                                  itemBuilder: (ctx, index) {
                                    final zone = flatZones[index];
                                    return ZoneCard(
                                      zone: zone,
                                      parentName: zone.parentId != null
                                          ? _getParentName(zone.parentId!, flatZones)
                                          : null,
                                      onAddChild: () {
                                        _openAddZoneModal(
                                          context,
                                          initialParentId: zone.id,
                                          availableZones: flatZones,
                                        );
                                      },
                                      onEdit: () {
                                        _openEditZoneModal(context, zone, flatZones);
                                      },
                                      onDelete: () {
                                        _confirmDeleteZone(context, zone);
                                      },
                                    );
                                  },
                                ),
            ),
          ],
        );
      },
    );
  }
}
