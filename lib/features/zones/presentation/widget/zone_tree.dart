import 'package:flutter/material.dart';
import '../../../schools/data/models/zone_model.dart';

class ZoneTreeWidget extends StatelessWidget {
  final List<ZoneModel> treeZones;
  final Function(ZoneModel zone) onAddChild;
  final Function(ZoneModel zone) onEdit;
  final Function(ZoneModel zone) onDelete;

  const ZoneTreeWidget({
    super.key,
    required this.treeZones,
    required this.onAddChild,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (treeZones.isEmpty) {
      return const SizedBox.shrink();
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: treeZones.length,
      itemBuilder: (ctx, index) {
        return _ZoneTreeNode(
          zone: treeZones[index],
          level: 0,
          onAddChild: onAddChild,
          onEdit: onEdit,
          onDelete: onDelete,
        );
      },
    );
  }
}

class _ZoneTreeNode extends StatefulWidget {
  final ZoneModel zone;
  final int level;
  final Function(ZoneModel zone) onAddChild;
  final Function(ZoneModel zone) onEdit;
  final Function(ZoneModel zone) onDelete;

  const _ZoneTreeNode({
    required this.zone,
    required this.level,
    required this.onAddChild,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<_ZoneTreeNode> createState() => _ZoneTreeNodeState();
}

class _ZoneTreeNodeState extends State<_ZoneTreeNode> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final hasChildren = widget.zone.children.isNotEmpty;

    final indentPadding = EdgeInsets.only(
      right: widget.level * 20.0,
      bottom: 8.0,
    );

    return Padding(
      padding: indentPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: widget.level == 0
                    ? theme.colorScheme.primary.withValues(alpha: 0.3)
                    : theme.colorScheme.outlineVariant,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              leading: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (hasChildren)
                    IconButton(
                      icon: Icon(
                        _isExpanded
                            ? Icons.keyboard_arrow_down_rounded
                            : Icons.keyboard_arrow_left_rounded,
                        size: 20,
                        color: theme.colorScheme.primary,
                      ),
                      onPressed: () {
                        setState(() {
                          _isExpanded = !_isExpanded;
                        });
                      },
                    )
                  else
                    const SizedBox(width: 24),
                  Icon(
                    widget.level == 0
                        ? Icons.account_tree_rounded
                        : Icons.subdirectory_arrow_left_rounded,
                    size: 18,
                    color: theme.colorScheme.primary,
                  ),
                ],
              ),
              title: Text(
                widget.zone.name.isNotEmpty ? widget.zone.name : 'منطقة بدون اسم',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: widget.level == 0 ? FontWeight.bold : FontWeight.w600,
                  fontSize: widget.level == 0 ? 15 : 13,
                ),
              ),
              subtitle: hasChildren
                  ? Text(
                      'تضم ${widget.zone.children.length} منطقة فرعية',
                      style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                    )
                  : null,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: 'إضافة فرع جديد',
                    icon: Icon(
                      Icons.add_circle_outline_rounded,
                      color: theme.colorScheme.primary,
                      size: 18,
                    ),
                    onPressed: () => widget.onAddChild(widget.zone),
                  ),
                  IconButton(
                    tooltip: 'تعديل الاسم',
                    icon: Icon(
                      Icons.edit_outlined,
                      color: theme.colorScheme.primary,
                      size: 18,
                    ),
                    onPressed: () => widget.onEdit(widget.zone),
                  ),
                  IconButton(
                    tooltip: 'حذف',
                    icon: Icon(
                      Icons.delete_outline_rounded,
                      color: theme.colorScheme.error,
                      size: 18,
                    ),
                    onPressed: () => widget.onDelete(widget.zone),
                  ),
                ],
              ),
            ),
          ),

          // Render Children recursively if expanded
          if (hasChildren && _isExpanded)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Column(
                children: widget.zone.children.map((childZone) {
                  return _ZoneTreeNode(
                    zone: childZone,
                    level: widget.level + 1,
                    onAddChild: widget.onAddChild,
                    onEdit: widget.onEdit,
                    onDelete: widget.onDelete,
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}
