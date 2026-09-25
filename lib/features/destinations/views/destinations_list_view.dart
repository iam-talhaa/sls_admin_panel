import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_color_scheme.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/status_badge.dart';
import '../data/models/destination_admin_model.dart';
import '../data/repositories/destinations_repository.dart';

class DestinationsListView extends ConsumerStatefulWidget {
  const DestinationsListView({super.key});

  @override
  ConsumerState<DestinationsListView> createState() => _DestinationsListViewState();
}

class _DestinationsListViewState extends ConsumerState<DestinationsListView> {
  String _searchQuery = '';
  bool _isSyncing = false;

  Future<void> _deleteDestination(DestinationAdminModel dest) async {
    final colors = context.colors;
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Delete Destination',
      message: 'Are you sure you want to delete "${dest.title.en}"? This action cannot be undone.',
      confirmLabel: 'Delete',
      isDestructive: true,
    );

    if (confirmed && mounted) {
      try {
        await ref.read(destinationsRepositoryProvider).deleteDestination(dest.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: const Text('Destination deleted successfully'), backgroundColor: colors.success),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting destination: $e'), backgroundColor: colors.error),
          );
        }
      }
    }
  }

  Future<void> _duplicateDestination(DestinationAdminModel dest) async {
    final colors = context.colors;
    try {
      final newId = 'dest_${DateTime.now().millisecondsSinceEpoch}';
      final duplicate = dest.copyWith(
        id: newId,
        title: dest.title.copyWith(en: '${dest.title.en} (Copy)'),
        order: dest.order + 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await ref.read(destinationsRepositoryProvider).saveDestination(duplicate);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text('Destination duplicated successfully in Firebase'), backgroundColor: colors.success),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error duplicating destination: $e'), backgroundColor: colors.error),
        );
      }
    }
  }

  Future<void> _onReorder(List<DestinationAdminModel> currentList, int oldIndex, int newIndex) async {
    final colors = context.colors;
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final items = List<DestinationAdminModel>.from(currentList);
    final movedItem = items.removeAt(oldIndex);
    items.insert(newIndex, movedItem);

    try {
      await ref.read(destinationsRepositoryProvider).updateDestinationsOrder(items);
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
    final destsAsync = ref.watch(destinationsListStreamProvider);

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
                Text('Destinations & Routes', style: AppTextStyles.headingMedium.copyWith(color: colors.textPrimary)),
                const SizedBox(height: 4),
                Text('Manage VIP travel routes, alpine ski hubs, and global event destinations.', style: AppTextStyles.subtitle.copyWith(color: colors.textSecondary)),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Tooltip(
                  message: 'Force-sync all 10 default destinations to Firebase Firestore',
                  child: OutlinedButton.icon(
                    onPressed: _isSyncing
                        ? null
                        : () async {
                            final colors = context.colors;
                            final messenger = ScaffoldMessenger.of(context);

                            final confirmed = await ConfirmDialog.show(
                              context,
                              title: 'Sync Destinations to Firebase',
                              message:
                                  'This will sync all 10 default destinations with complete multilingual content (English, German, Arabic) and placeholder images to Firestore.\n\nProceed?',
                              confirmLabel: 'Sync Now',
                              icon: Icons.cloud_sync_outlined,
                            );

                            if (confirmed && mounted) {
                              setState(() => _isSyncing = true);
                              try {
                                await ref
                                    .read(destinationsRepositoryProvider)
                                    .seedInitialDestinations(force: true);
                                if (mounted) {
                                  messenger.showSnackBar(
                                    SnackBar(
                                      content: const Text(
                                          '✅ All 10 destinations synced to Firebase successfully!'),
                                      backgroundColor: colors.success,
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (mounted) {
                                  messenger.showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Sync error: $e\n(Make sure you are logged in and Firestore rules allow writes)'),
                                      backgroundColor: colors.error,
                                      duration: const Duration(seconds: 6),
                                    ),
                                  );
                                }
                              } finally {
                                if (mounted) {
                                  setState(() => _isSyncing = false);
                                }
                              }
                            }
                          },
                    icon: _isSyncing
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.cloud_sync_outlined, size: 18),
                    label: Text(_isSyncing ? 'Syncing...' : 'Sync to Firebase'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colors.textSecondary,
                      side: BorderSide(color: colors.border),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () => context.go('/destinations/new'),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Destination'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primaryRed,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Search Bar
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
                width: 320,
                height: 40,
                child: TextField(
                  style: AppTextStyles.inputText.copyWith(color: colors.textPrimary, fontSize: 13),
                  onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
                  decoration: InputDecoration(
                    hintText: 'Search destinations by title or route...',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    prefixIcon: Icon(Icons.search, size: 18, color: colors.textSecondary),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Destinations List
        destsAsync.when(
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
            child: Text('Error loading destinations: $err', style: TextStyle(color: colors.error)),
          ),
          data: (destinations) {
            final filtered = destinations.where((d) {
              return _searchQuery.isEmpty ||
                  d.title.en.toLowerCase().contains(_searchQuery) ||
                  d.category.en.toLowerCase().contains(_searchQuery) ||
                  (d.route?.en.toLowerCase().contains(_searchQuery) ?? false);
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
                  title: 'No destinations found',
                  message: 'No destinations match your search or the collection is empty.',
                  actionLabel: 'Add Destination',
                  onAction: () => context.go('/destinations/new'),
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
                                const SizedBox(width: 32),
                                SizedBox(
                                  width: 80,
                                  child: Text('IMAGE', style: TextStyle(color: colors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Text('DESTINATION & ROUTE', style: TextStyle(color: colors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text('CATEGORY & DURATION', style: TextStyle(color: colors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                                ),
                                SizedBox(
                                  width: 120,
                                  child: Text('CONTENT BLOCKS', style: TextStyle(color: colors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
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

                          // Reorderable List
                          ReorderableListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: filtered.length,
                            onReorder: (oldIdx, newIdx) => _onReorder(filtered, oldIdx, newIdx),
                            buildDefaultDragHandles: false,
                            itemBuilder: (context, index) {
                              final dest = filtered[index];
                              return Container(
                                key: ValueKey(dest.id.isNotEmpty ? dest.id : 'dest_$index'),
                                decoration: BoxDecoration(
                                  border: Border(bottom: BorderSide(color: colors.border)),
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () => context.go('/destinations/${dest.id}'),
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
                                            child: dest.imageUrl.isNotEmpty
                                                ? (dest.imageUrl.startsWith('http')
                                                    ? Image.network(dest.imageUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Icon(Icons.location_on, color: colors.textSecondary, size: 18))
                                                    : Image.asset(dest.imageUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Icon(Icons.location_on, color: colors.textSecondary, size: 18)))
                                                : Icon(Icons.location_on, color: colors.textSecondary, size: 18),
                                          ),
                                          const SizedBox(width: 20),

                                          // Title & Route
                                          Expanded(
                                            flex: 3,
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  dest.title.en.isNotEmpty ? dest.title.en : 'Untitled Destination',
                                                  style: AppTextStyles.bodyMedium.copyWith(color: colors.textPrimary, fontWeight: FontWeight.w600),
                                                ),
                                                if (dest.route != null && dest.route!.en.isNotEmpty)
                                                  Text(
                                                    dest.route!.en,
                                                    style: AppTextStyles.bodySmall.copyWith(color: colors.textSecondary),
                                                  ),
                                              ],
                                            ),
                                          ),

                                          // Category & Duration
                                          Expanded(
                                            flex: 2,
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(dest.category.en, style: AppTextStyles.bodySmall.copyWith(color: colors.textPrimary)),
                                                if (dest.duration.isNotEmpty)
                                                  Text('⏱ ${dest.duration}', style: AppTextStyles.bodySmall.copyWith(color: colors.textMuted, fontSize: 11)),
                                              ],
                                            ),
                                          ),

                                          // Content blocks chip
                                          SizedBox(
                                            width: 120,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                              decoration: BoxDecoration(
                                                color: colors.surfaceElevatedHigher,
                                                borderRadius: BorderRadius.circular(6),
                                                border: Border.all(color: colors.border),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(Icons.layers_outlined, size: 14, color: colors.textSecondary),
                                                  const SizedBox(width: 6),
                                                  Text(
                                                    '${dest.contentBlocks.length} Blocks',
                                                    style: AppTextStyles.bodySmall.copyWith(color: colors.textPrimary, fontSize: 11),
                                                  ),
                                                ],
                                              ),
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
                                                    value: dest.isActive,
                                                    onChanged: (val) {
                                                      ref.read(destinationsRepositoryProvider).toggleDestinationStatus(dest.id, val);
                                                    },
                                                  ),
                                                ),
                                                const SizedBox(width: 4),
                                                StatusBadge.fromStatus(dest.isActive ? 'Active' : 'Inactive'),
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
                                                  onPressed: () => context.go('/destinations/${dest.id}'),
                                                  tooltip: 'Edit Destination',
                                                ),
                                                IconButton(
                                                  icon: Icon(Icons.copy_outlined, size: 18, color: colors.textSecondary),
                                                  onPressed: () => _duplicateDestination(dest),
                                                  tooltip: 'Duplicate Destination',
                                                ),
                                                IconButton(
                                                  icon: Icon(Icons.delete_outline, size: 18, color: colors.error),
                                                  onPressed: () => _deleteDestination(dest),
                                                  tooltip: 'Delete Destination',
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
