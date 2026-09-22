import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_color_scheme.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/status_badge.dart';
import '../data/models/jet_admin_model.dart';
import '../data/repositories/fleet_repository.dart';

class FleetListView extends ConsumerStatefulWidget {
  const FleetListView({super.key});

  @override
  ConsumerState<FleetListView> createState() => _FleetListViewState();
}

class _FleetListViewState extends ConsumerState<FleetListView> {
  String _searchQuery = '';
  String _selectedCategory = 'ALL';

  Future<void> _deleteJet(JetAdminModel jet) async {
    final colors = context.colors;
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Delete Jet',
      message: 'Are you sure you want to delete "${jet.name.en}"? This action cannot be undone.',
      confirmLabel: 'Delete',
      isDestructive: true,
    );

    if (confirmed && mounted) {
      try {
        await ref.read(fleetRepositoryProvider).deleteJet(jet.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: const Text('Jet deleted successfully'), backgroundColor: colors.success),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting jet: $e'), backgroundColor: colors.error),
          );
        }
      }
    }
  }

  Future<void> _duplicateJet(JetAdminModel jet) async {
    final colors = context.colors;
    try {
      final duplicate = jet.copyWith(
        id: '',
        name: jet.name.copyWith(en: '${jet.name.en} (Copy)'),
        order: jet.order + 1,
      );
      await ref.read(fleetRepositoryProvider).saveJet(duplicate);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text('Jet duplicated successfully'), backgroundColor: colors.success),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error duplicating jet: $e'), backgroundColor: colors.error),
        );
      }
    }
  }

  Future<void> _onReorder(List<JetAdminModel> currentList, int oldIndex, int newIndex) async {
    final colors = context.colors;
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final items = List<JetAdminModel>.from(currentList);
    final movedItem = items.removeAt(oldIndex);
    items.insert(newIndex, movedItem);

    try {
      await ref.read(fleetRepositoryProvider).updateJetsOrder(items);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving new order: $e'), backgroundColor: colors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final fleetAsync = ref.watch(fleetListStreamProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Action Header
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 12,
          runSpacing: 12,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Fleet Aircraft', style: AppTextStyles.headingMedium.copyWith(color: colors.textPrimary)),
                const SizedBox(height: 4),
                Text('Manage private jets and helicopters in the charter fleet.', style: AppTextStyles.subtitle.copyWith(color: colors.textSecondary)),
              ],
            ),
            ElevatedButton.icon(
              onPressed: () => context.go('/fleet/new'),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Aircraft'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primaryRed,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Filter and Search Toolbar
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.surfaceElevated,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.border, width: 1),
            boxShadow: [
              BoxShadow(
                color: colors.shadow,
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Wrap(
            spacing: 16,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: 280,
                height: 40,
                child: TextField(
                  style: AppTextStyles.inputText.copyWith(color: colors.textPrimary, fontSize: 13),
                  onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
                  decoration: InputDecoration(
                    hintText: 'Search by aircraft name...',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    prefixIcon: Icon(Icons.search, size: 18, color: colors.textSecondary),
                  ),
                ),
              ),
              DropdownButton<String>(
                value: _selectedCategory,
                dropdownColor: colors.surfaceElevated,
                style: AppTextStyles.bodyMedium.copyWith(color: colors.textPrimary),
                underline: const SizedBox(),
                items: const [
                  DropdownMenuItem(value: 'ALL', child: Text('All Categories')),
                  DropdownMenuItem(value: 'LIGHT JET', child: Text('Light Jets')),
                  DropdownMenuItem(value: 'MIDSIZE JET', child: Text('Midsize Jets')),
                  DropdownMenuItem(value: 'HEAVY JET', child: Text('Heavy Jets')),
                  DropdownMenuItem(value: 'HELICOPTER', child: Text('Helicopters')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _selectedCategory = val);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Reorderable Fleet List
        fleetAsync.when(
          loading: () => SizedBox(
            height: 300,
            child: Center(child: CircularProgressIndicator(color: colors.primaryRed)),
          ),
          error: (err, _) => Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colors.surfaceElevated,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.border),
            ),
            child: Text('Error loading fleet: $err', style: TextStyle(color: colors.error)),
          ),
          data: (jets) {
            final filtered = jets.where((j) {
              final matchesQuery = _searchQuery.isEmpty ||
                  j.name.en.toLowerCase().contains(_searchQuery) ||
                  j.category.toLowerCase().contains(_searchQuery);
              final matchesCategory = _selectedCategory == 'ALL' ||
                  j.category.toUpperCase() == _selectedCategory.toUpperCase();
              return matchesQuery && matchesCategory;
            }).toList();

            if (filtered.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: colors.surfaceElevated,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colors.border),
                  boxShadow: [
                    BoxShadow(
                      color: colors.shadow,
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: EmptyState(
                  title: 'No aircraft found',
                  message: 'No jets match your filter criteria or the fleet is empty.',
                  actionLabel: 'Add Aircraft',
                  onAction: () => context.go('/fleet/new'),
                ),
              );
            }

            return Container(
              decoration: BoxDecoration(
                color: colors.surfaceElevated,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colors.border, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: colors.shadow,
                    blurRadius: 12,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  const double minTableWidth = 920;
                  final effectiveWidth = constraints.maxWidth < minTableWidth ? minTableWidth : constraints.maxWidth;

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: effectiveWidth,
                      child: Column(
                        children: [
                          // Table Header
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: colors.surfaceElevatedHigher,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(11),
                                topRight: Radius.circular(11),
                              ),
                            ),
                            child: Row(
                              children: [
                                const SizedBox(width: 32), // Drag handle spacing
                                SizedBox(
                                  width: 80,
                                  child: Text('IMAGE', style: TextStyle(color: colors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Text('AIRCRAFT NAME', style: TextStyle(color: colors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text('CATEGORY', style: TextStyle(color: colors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text('SEATING & RANGE', style: TextStyle(color: colors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                                ),
                                SizedBox(
                                  width: 145,
                                  child: Text('STATUS', style: TextStyle(color: colors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                                ),
                                SizedBox(
                                  width: 130,
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Text('ACTIONS', style: TextStyle(color: colors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Divider(height: 1, color: colors.border),

                          // Reorderable Items
                          ReorderableListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: filtered.length,
                            onReorder: (oldIdx, newIdx) => _onReorder(filtered, oldIdx, newIdx),
                            buildDefaultDragHandles: false,
                            itemBuilder: (context, index) {
                              final jet = filtered[index];
                              return Container(
                                key: ValueKey(jet.id.isNotEmpty ? jet.id : 'jet_$index'),
                                decoration: BoxDecoration(
                                  border: Border(bottom: BorderSide(color: colors.border)),
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () => context.go('/fleet/${jet.id}'),
                                    hoverColor: colors.tableRowHover,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      child: Row(
                                        children: [
                                          // Drag Handle
                                          ReorderableDragStartListener(
                                            index: index,
                                            child: MouseRegion(
                                              cursor: SystemMouseCursors.grab,
                                              child: Padding(
                                                padding: const EdgeInsets.only(right: 12.0),
                                                child: Icon(Icons.drag_indicator, color: colors.textSecondary, size: 20),
                                              ),
                                            ),
                                          ),

                                          // Thumbnail
                                          Container(
                                            width: 60,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              color: colors.surfaceElevatedHigher,
                                              borderRadius: BorderRadius.circular(6),
                                              border: Border.all(color: colors.border),
                                            ),
                                            clipBehavior: Clip.antiAlias,
                                            child: jet.imageUrl.isNotEmpty
                                                ? (jet.imageUrl.startsWith('http')
                                                    ? Image.network(jet.imageUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Icon(Icons.flight, color: colors.textSecondary, size: 18))
                                                    : Image.asset(jet.imageUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Icon(Icons.flight, color: colors.textSecondary, size: 18)))
                                                : Icon(Icons.flight, color: colors.textSecondary, size: 18),
                                          ),
                                          const SizedBox(width: 20),

                                          // Name
                                          Expanded(
                                            flex: 3,
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  jet.name.en.isNotEmpty ? jet.name.en : 'Untitled Jet',
                                                  style: AppTextStyles.bodyMedium.copyWith(color: colors.textPrimary, fontWeight: FontWeight.w600),
                                                ),
                                                if (jet.name.fr.isNotEmpty || jet.name.de.isNotEmpty || jet.name.ar.isNotEmpty)
                                                  Text(
                                                    'FR: ${jet.name.fr} • DE: ${jet.name.de}',
                                                    style: AppTextStyles.bodySmall.copyWith(color: colors.textSecondary, fontSize: 11),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                              ],
                                            ),
                                          ),

                                          // Category
                                          Expanded(
                                            flex: 2,
                                            child: Text(jet.category, style: AppTextStyles.bodySmall.copyWith(color: colors.textPrimary)),
                                          ),

                                          // Seating & Range
                                          Expanded(
                                            flex: 2,
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(jet.seating.en, style: AppTextStyles.bodySmall.copyWith(color: colors.textPrimary)),
                                                Text(jet.range.en, style: AppTextStyles.bodySmall.copyWith(color: colors.textMuted)),
                                              ],
                                            ),
                                          ),

                                          // Active Toggle
                                          SizedBox(
                                            width: 145,
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Transform.scale(
                                                  scale: 0.8,
                                                  child: Switch(
                                                    value: jet.isActive,
                                                    onChanged: (val) {
                                                      ref.read(fleetRepositoryProvider).toggleJetStatus(jet.id, val);
                                                    },
                                                  ),
                                                ),
                                                const SizedBox(width: 4),
                                                StatusBadge.fromStatus(jet.isActive ? 'Active' : 'Inactive'),
                                              ],
                                            ),
                                          ),

                                          // Actions
                                          SizedBox(
                                            width: 130,
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: [
                                                IconButton(
                                                  icon: Icon(Icons.edit_outlined, size: 18, color: colors.textPrimary),
                                                  onPressed: () => context.go('/fleet/${jet.id}'),
                                                  tooltip: 'Edit Jet',
                                                ),
                                                IconButton(
                                                  icon: Icon(Icons.copy_outlined, size: 18, color: colors.textSecondary),
                                                  onPressed: () => _duplicateJet(jet),
                                                  tooltip: 'Duplicate Jet',
                                                ),
                                                IconButton(
                                                  icon: Icon(Icons.delete_outline, size: 18, color: colors.error),
                                                  onPressed: () => _deleteJet(jet),
                                                  tooltip: 'Delete Jet',
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}
