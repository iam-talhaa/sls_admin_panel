import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_color_scheme.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/models/localized_text.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/image_uploader.dart';
import '../../../core/widgets/loading_overlay.dart';
import '../../../core/widgets/localized_field_tabs.dart';
import '../../../core/widgets/status_badge.dart';
import '../data/models/concierge_model.dart';
import '../data/services/concierge_service.dart';
import 'widgets/concierge_mobile_preview.dart';

class ConciergeView extends ConsumerStatefulWidget {
  const ConciergeView({super.key});

  @override
  ConsumerState<ConciergeView> createState() => _ConciergeViewState();
}

class _ConciergeViewState extends ConsumerState<ConciergeView> {
  String _searchQuery = '';
  bool _isSavingBanner = false;

  // Local state for banner editing
  bool _isBannerExpanded = true;
  LocalizedText _bannerTitle = LocalizedText.empty;
  LocalizedText _bannerSubtitle = LocalizedText.empty;
  String _bannerImageUrl = '';
  bool _bannerInitialized = false;

  void _initBannerState(ConciergeBanner banner) {
    if (!_bannerInitialized) {
      _bannerTitle = banner.title;
      _bannerSubtitle = banner.subtitle;
      _bannerImageUrl = banner.imageUrl;
      _bannerInitialized = true;
    }
  }

  Future<void> _handleSaveBanner() async {
    final colors = context.colors;
    setState(() => _isSavingBanner = true);

    try {
      final updatedBanner = ConciergeBanner(
        title: _bannerTitle,
        subtitle: _bannerSubtitle,
        imageUrl: _bannerImageUrl,
      );

      await ref.read(conciergeServiceProvider).updateBanner(updatedBanner);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Concierge hero banner saved successfully!'),
            backgroundColor: colors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving hero banner: $e'),
            backgroundColor: colors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSavingBanner = false);
    }
  }

  Future<void> _deleteCategory(ConciergeCategory cat) async {
    final colors = context.colors;
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Delete Concierge Category',
      message: 'Are you sure you want to delete "${cat.tabTitle.en}"? This category tab and its features will be permanently removed.',
      confirmLabel: 'Delete',
      isDestructive: true,
    );

    if (confirmed && mounted) {
      try {
        await ref.read(conciergeServiceProvider).deleteCategory(cat.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Category deleted successfully'),
              backgroundColor: colors.success,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting category: $e'),
              backgroundColor: colors.error,
            ),
          );
        }
      }
    }
  }

  Future<void> _duplicateCategory(ConciergeCategory cat) async {
    final colors = context.colors;
    try {
      final duplicated = cat.copyWith(
        id: 'cat_${DateTime.now().millisecondsSinceEpoch}',
        slug: '${cat.slug}-copy',
        tabTitle: cat.tabTitle.copyWith(en: '${cat.tabTitle.en} (Copy)'),
        title: cat.title.copyWith(en: '${cat.title.en} (Copy)'),
        sortOrder: cat.sortOrder + 1,
      );
      await ref.read(conciergeServiceProvider).createCategory(duplicated);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Category duplicated successfully'),
            backgroundColor: colors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error duplicating category: $e'),
            backgroundColor: colors.error,
          ),
        );
      }
    }
  }

  Future<void> _onReorderCategories(List<ConciergeCategory> currentList, int oldIndex, int newIndex) async {
    final colors = context.colors;
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final items = List<ConciergeCategory>.from(currentList);
    final movedItem = items.removeAt(oldIndex);
    items.insert(newIndex, movedItem);

    try {
      await ref.read(conciergeServiceProvider).reorderCategories(items);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving category order: $e'), backgroundColor: colors.error),
        );
      }
    }
  }

  void _showMobilePreviewDialog(ConciergeBanner banner, List<ConciergeCategory> categories) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: ConciergeMobilePreview(
              banner: banner,
              categories: categories,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final bannerAsync = ref.watch(conciergeBannerStreamProvider);
    final categoriesAsync = ref.watch(conciergeCategoriesStreamProvider);

    return bannerAsync.when(
      loading: () => SizedBox(
        height: 400,
        child: Center(child: CircularProgressIndicator(color: colors.primaryRed)),
      ),
      error: (err, _) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: colors.surfaceElevated,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.border),
        ),
        child: Text('Error loading concierge banner: $err', style: TextStyle(color: colors.error)),
      ),
      data: (banner) {
        _initBannerState(banner);

        return categoriesAsync.when(
          loading: () => SizedBox(
            height: 400,
            child: Center(child: CircularProgressIndicator(color: colors.primaryRed)),
          ),
          error: (err, _) => Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colors.surfaceElevated,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.border),
            ),
            child: Text('Error loading categories: $err', style: TextStyle(color: colors.error)),
          ),
          data: (categories) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Header with Action Buttons
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Concierge Services Management', style: AppTextStyles.headingMedium.copyWith(color: colors.textPrimary)),
                        const SizedBox(height: 4),
                        Text(
                          'Configure the mobile app Concierge hero banner and interactive category tabs.',
                          style: AppTextStyles.subtitle.copyWith(color: colors.textSecondary),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () => _showMobilePreviewDialog(banner, categories),
                          icon: const Icon(Icons.smartphone_outlined, size: 18),
                          label: const Text('Live Mobile Preview'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: colors.textPrimary,
                            side: BorderSide(color: colors.border),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: () => context.go('/concierge/new'),
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Add Category'),
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

                // Hero Banner Configuration Card
                _buildBannerCard(context),
                const SizedBox(height: 28),

                // Category Tabs List Section Header & Search
                _buildCategoriesSection(context, categories, banner),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildBannerCard(BuildContext context) {
    final colors = context.colors;

    return LoadingOverlay(
      isLoading: _isSavingBanner,
      message: 'Saving concierge hero banner...',
      child: Container(
        padding: const EdgeInsets.all(24),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colors.primaryRed.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.view_carousel_outlined, color: colors.primaryRed, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Screen Hero Banner', style: AppTextStyles.headingSmall.copyWith(color: colors.textPrimary)),
                        Text('Prominent hero header shown at the top of the mobile Concierge screen.', style: AppTextStyles.subtitle.copyWith(color: colors.textSecondary)),
                      ],
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(_isBannerExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: colors.textSecondary),
                      onPressed: () => setState(() => _isBannerExpanded = !_isBannerExpanded),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: _handleSaveBanner,
                      icon: const Icon(Icons.save_outlined, size: 16),
                      label: const Text('Save Banner'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.primaryRed,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            if (_isBannerExpanded) ...[
              const SizedBox(height: 20),
              Divider(color: colors.border, height: 1),
              const SizedBox(height: 20),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 850;

                  if (isWide) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left: Banner Image
                        SizedBox(
                          width: 320,
                          child: ImageUploader(
                            label: 'Hero Banner Image',
                            initialImageUrl: _bannerImageUrl,
                            height: 180,
                            fit: BoxFit.cover,
                            storagePath: 'concierge_banner/hero',
                            onImageUploaded: (url) {
                              setState(() => _bannerImageUrl = url);
                            },
                          ),
                        ),
                        const SizedBox(width: 24),
                        // Right: Title & Subtitle localized inputs
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              LocalizedFieldTabs(
                                label: 'Hero Banner Title',
                                initialValue: _bannerTitle,
                                isRequired: true,
                                hint: 'e.g. Bespoke Luxury & Concierge Services',
                                onChanged: (val) => setState(() => _bannerTitle = val),
                              ),
                              const SizedBox(height: 16),
                              LocalizedFieldTabs(
                                label: 'Hero Banner Subtitle',
                                initialValue: _bannerSubtitle,
                                maxLines: 3,
                                hint: 'e.g. Seamless 5-star hotel reservations, private chauffeur transfers...',
                                onChanged: (val) => setState(() => _bannerSubtitle = val),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  } else {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ImageUploader(
                          label: 'Hero Banner Image',
                          initialImageUrl: _bannerImageUrl,
                          height: 180,
                          fit: BoxFit.cover,
                          storagePath: 'concierge_banner/hero',
                          onImageUploaded: (url) {
                            setState(() => _bannerImageUrl = url);
                          },
                        ),
                        const SizedBox(height: 16),
                        LocalizedFieldTabs(
                          label: 'Hero Banner Title',
                          initialValue: _bannerTitle,
                          isRequired: true,
                          hint: 'e.g. Bespoke Luxury & Concierge Services',
                          onChanged: (val) => setState(() => _bannerTitle = val),
                        ),
                        const SizedBox(height: 16),
                        LocalizedFieldTabs(
                          label: 'Hero Banner Subtitle',
                          initialValue: _bannerSubtitle,
                          maxLines: 3,
                          hint: 'e.g. Seamless 5-star hotel reservations, private chauffeur transfers...',
                          onChanged: (val) => setState(() => _bannerSubtitle = val),
                        ),
                      ],
                    );
                  }
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesSection(
    BuildContext context,
    List<ConciergeCategory> categories,
    ConciergeBanner banner,
  ) {
    final colors = context.colors;

    final filtered = categories.where((c) {
      if (_searchQuery.isEmpty) return true;
      return c.tabTitle.en.toLowerCase().contains(_searchQuery) ||
          c.title.en.toLowerCase().contains(_searchQuery) ||
          c.categoryTag.en.toLowerCase().contains(_searchQuery) ||
          c.slug.toLowerCase().contains(_searchQuery);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Table Header Card with Search
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
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 16,
            runSpacing: 12,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Service Categories (${categories.length})', style: AppTextStyles.headingSmall.copyWith(color: colors.textPrimary)),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: colors.surfaceElevatedHigher,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: colors.border),
                    ),
                    child: Text('Drag rows to reorder tabs', style: TextStyle(color: colors.textSecondary, fontSize: 11)),
                  ),
                ],
              ),
              SizedBox(
                width: 320,
                height: 40,
                child: TextField(
                  style: AppTextStyles.inputText.copyWith(color: colors.textPrimary, fontSize: 13),
                  onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
                  decoration: InputDecoration(
                    hintText: 'Search categories by name, tag, slug...',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    prefixIcon: Icon(Icons.search, size: 18, color: colors.textSecondary),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        if (filtered.isEmpty)
          Container(
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
              title: 'No concierge categories found',
              message: 'No categories match your search criteria or the collection is empty.',
              actionLabel: 'Add Category',
              onAction: () => context.go('/concierge/new'),
            ),
          )
        else
          Container(
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
                        // Table Column Headers
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
                              const SizedBox(width: 36),
                              SizedBox(
                                width: 75,
                                child: Text('IMAGE', style: TextStyle(color: colors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                              ),
                              Expanded(
                                flex: 3,
                                child: Text('TAB & HEADLINE', style: TextStyle(color: colors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text('CATEGORY TAG & SLUG', style: TextStyle(color: colors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                              ),
                              SizedBox(
                                width: 120,
                                child: Text('FEATURES', style: TextStyle(color: colors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                              ),
                              SizedBox(
                                width: 130,
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

                        // Reorderable Category Rows
                        ReorderableListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: filtered.length,
                          onReorder: (oldIdx, newIdx) => _onReorderCategories(filtered, oldIdx, newIdx),
                          buildDefaultDragHandles: false,
                          itemBuilder: (context, index) {
                            final cat = filtered[index];

                            return Container(
                              key: ValueKey(cat.id.isNotEmpty ? cat.id : 'cat_$index'),
                              decoration: BoxDecoration(
                                border: Border(bottom: BorderSide(color: colors.border)),
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () => context.go('/concierge/${cat.id}'),
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

                                        // Image Preview
                                        Container(
                                          width: 60,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: colors.surfaceElevatedHigher,
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(color: colors.border),
                                          ),
                                          clipBehavior: Clip.antiAlias,
                                          child: cat.imageUrl.isNotEmpty
                                              ? (cat.imageUrl.startsWith('http')
                                                  ? Image.network(
                                                      cat.imageUrl,
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (_, __, ___) => Icon(Icons.room_service, color: colors.textSecondary, size: 18),
                                                    )
                                                  : Image.asset(
                                                      cat.imageUrl,
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (_, __, ___) => Icon(Icons.room_service, color: colors.textSecondary, size: 18),
                                                    ))
                                              : Icon(Icons.room_service, color: colors.textSecondary, size: 18),
                                        ),
                                        const SizedBox(width: 16),

                                        // Tab Title & Headline
                                        Expanded(
                                          flex: 3,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    cat.tabTitle.en.isNotEmpty ? cat.tabTitle.en : 'Untitled Tab',
                                                    style: AppTextStyles.bodyMedium.copyWith(
                                                      color: colors.textPrimary,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                                    decoration: BoxDecoration(
                                                      color: colors.surfaceElevatedHigher,
                                                      borderRadius: BorderRadius.circular(4),
                                                      border: Border.all(color: colors.border),
                                                    ),
                                                    child: Text(
                                                      '#${cat.sortOrder}',
                                                      style: TextStyle(color: colors.textSecondary, fontSize: 10, fontWeight: FontWeight.bold),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              if (cat.title.en.isNotEmpty)
                                                Text(
                                                  cat.title.en,
                                                  style: AppTextStyles.bodySmall.copyWith(color: colors.textSecondary),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                            ],
                                          ),
                                        ),

                                        // Category Tag & Slug
                                        Expanded(
                                          flex: 2,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              if (cat.categoryTag.en.isNotEmpty)
                                                Text(
                                                  cat.categoryTag.en.toUpperCase(),
                                                  style: TextStyle(
                                                    color: colors.primaryRed,
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w700,
                                                    letterSpacing: 0.5,
                                                  ),
                                                ),
                                              Text(
                                                '/${cat.slug}',
                                                style: AppTextStyles.bodySmall.copyWith(color: colors.textMuted, fontSize: 11),
                                              ),
                                            ],
                                          ),
                                        ),

                                        // Features Count Chip
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
                                                Icon(Icons.checklist_outlined, size: 14, color: colors.textSecondary),
                                                const SizedBox(width: 6),
                                                Text(
                                                  '${cat.features.length} Features',
                                                  style: AppTextStyles.bodySmall.copyWith(color: colors.textPrimary, fontSize: 11),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),

                                        // Active Toggle & Badge
                                        SizedBox(
                                          width: 130,
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Transform.scale(
                                                scale: 0.8,
                                                child: Switch(
                                                  value: cat.isActive,
                                                  onChanged: (val) {
                                                    ref.read(conciergeServiceProvider).toggleCategoryStatus(cat.id, val);
                                                  },
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              StatusBadge.fromStatus(cat.isActive ? 'Active' : 'Inactive'),
                                            ],
                                          ),
                                        ),

                                        // Action buttons
                                        SizedBox(
                                          width: 130,
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: [
                                              IconButton(
                                                icon: Icon(Icons.edit_outlined, size: 18, color: colors.textPrimary),
                                                onPressed: () => context.go('/concierge/${cat.id}'),
                                                tooltip: 'Edit Category',
                                              ),
                                              IconButton(
                                                icon: Icon(Icons.copy_outlined, size: 18, color: colors.textSecondary),
                                                onPressed: () => _duplicateCategory(cat),
                                                tooltip: 'Duplicate Category',
                                              ),
                                              IconButton(
                                                icon: Icon(Icons.delete_outline, size: 18, color: colors.error),
                                                onPressed: () => _deleteCategory(cat),
                                                tooltip: 'Delete Category',
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
          ),
      ],
    );
  }
}
