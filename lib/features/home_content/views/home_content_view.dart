import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_color_scheme.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/models/localized_text.dart';
import '../../../core/widgets/image_uploader.dart';
import '../../../core/widgets/loading_overlay.dart';
import '../../../core/widgets/localized_field_tabs.dart';
import '../data/models/home_content_model.dart';
import '../data/repositories/home_content_repository.dart';

class HomeContentView extends ConsumerStatefulWidget {
  const HomeContentView({super.key});

  @override
  ConsumerState<HomeContentView> createState() => _HomeContentViewState();
}

class _HomeContentViewState extends ConsumerState<HomeContentView> {
  bool _isLoading = true;
  bool _isSaving = false;

  List<RouteCardAdminModel> _routeCards = [];
  List<HomeStatAdminModel> _stats = [];

  @override
  void initState() {
    super.initState();
    _loadHomeContent();
  }

  Future<void> _loadHomeContent() async {
    try {
      final content = await ref.read(homeContentRepositoryProvider).getHomeContent();
      _routeCards = List.from(content.routeCards);
      _stats = List.from(content.stats);
    } catch (_) {}
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _handleSave() async {
    final colors = context.colors;
    setState(() => _isSaving = true);
    try {
      final updated = HomeContentAdminModel(
        routeCards: _routeCards,
        stats: _stats,
      );
      await ref.read(homeContentRepositoryProvider).saveHomeContent(updated);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Home page content saved successfully!'),
            backgroundColor: colors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving home content: $e'), backgroundColor: colors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _addRouteCard() {
    setState(() {
      _routeCards.add(RouteCardAdminModel(
        id: 'card_${DateTime.now().millisecondsSinceEpoch}',
        title: LocalizedText.empty,
        category: LocalizedText.empty,
        duration: '1 hr 10 min',
        imageUrl: 'assets/des1.jpg',
        overlayTag: const LocalizedText(en: 'FEATURED ROUTE'),
      ));
    });
  }

  void _addStat() {
    setState(() {
      _stats.add(const HomeStatAdminModel(
        count: '100+',
        label: LocalizedText(en: 'Private Jets Available'),
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    if (_isLoading) {
      return SizedBox(
        height: 400,
        child: Center(child: CircularProgressIndicator(color: colors.primaryRed)),
      );
    }

    return LoadingOverlay(
      isLoading: _isSaving,
      message: 'Saving home page content...',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Home Page Live Configuration', style: AppTextStyles.headingMedium.copyWith(color: colors.textPrimary)),
                  const SizedBox(height: 4),
                  Text('Control the route highlights carousel and counter stats displayed on the mobile app home screen.', style: AppTextStyles.subtitle.copyWith(color: colors.textSecondary)),
                ],
              ),
              ElevatedButton.icon(
                onPressed: _handleSave,
                icon: const Icon(Icons.save_outlined, size: 18),
                label: const Text('Save Home Content'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primaryRed,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Route Cards Section
          Container(
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
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Featured Route Cards Carousel (${_routeCards.length})', style: AppTextStyles.headingSmall.copyWith(color: colors.textPrimary)),
                        Text('Drag cards to change presentation order on mobile home view.', style: AppTextStyles.subtitle.copyWith(color: colors.textSecondary)),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: _addRouteCard,
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Add Route Card'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.surfaceElevatedHigher,
                        foregroundColor: colors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                if (_routeCards.isEmpty)
                  Text('No route cards defined yet. Click "+ Add Route Card" to start.', style: AppTextStyles.subtitle.copyWith(color: colors.textSecondary))
                else
                  ReorderableListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _routeCards.length,
                    onReorder: (oldIdx, newIdx) {
                      setState(() {
                        if (newIdx > oldIdx) newIdx -= 1;
                        final item = _routeCards.removeAt(oldIdx);
                        _routeCards.insert(newIdx, item);
                      });
                    },
                    buildDefaultDragHandles: false,
                    itemBuilder: (context, index) {
                      final card = _routeCards[index];
                      return Container(
                        key: ValueKey(card.id),
                        margin: const EdgeInsets.only(bottom: 20),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: colors.surfaceElevatedHigher,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: colors.border, width: 1),
                          boxShadow: [
                            BoxShadow(
                              color: colors.shadow,
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: LayoutBuilder(
                          builder: (context, cardConstraints) {
                            final isCardWide = cardConstraints.maxWidth > 780;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    ReorderableDragStartListener(
                                      index: index,
                                      child: MouseRegion(
                                        cursor: SystemMouseCursors.grab,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: colors.surfaceElevated,
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(color: colors.border, width: 0.8),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.drag_indicator, color: colors.textSecondary, size: 18),
                                              const SizedBox(width: 4),
                                              Text(
                                                'Card #${index + 1}',
                                                style: AppTextStyles.subtitle.copyWith(
                                                  color: colors.textPrimary,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    IconButton(
                                      icon: Icon(Icons.delete_outline, size: 20, color: colors.error),
                                      tooltip: 'Remove Card',
                                      onPressed: () {
                                        setState(() {
                                          _routeCards.removeAt(index);
                                        });
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                if (isCardWide)
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Full Look Proportional Image
                                      SizedBox(
                                        width: 320,
                                        child: ImageUploader(
                                          label: 'Card Image',
                                          initialImageUrl: card.imageUrl,
                                          height: 195,
                                          fit: BoxFit.cover,
                                          storagePath: 'home_cards/${card.id}',
                                          onImageUploaded: (url) {
                                            _routeCards[index] = card.copyWith(imageUrl: url);
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 24),
                                      // Clean Input Fields
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: TextFormField(
                                                    initialValue: card.title.en,
                                                    style: AppTextStyles.inputText.copyWith(color: colors.textPrimary),
                                                    decoration: InputDecoration(
                                                      labelText: 'Route Title',
                                                      hintText: 'e.g. Davos Ski Escape',
                                                      prefixIcon: Icon(Icons.title, size: 18, color: colors.textSecondary),
                                                    ),
                                                    onChanged: (val) {
                                                      _routeCards[index] = card.copyWith(
                                                        title: card.title.copyWith(en: val),
                                                      );
                                                    },
                                                  ),
                                                ),
                                                const SizedBox(width: 16),
                                                Expanded(
                                                  child: TextFormField(
                                                    initialValue: card.category.en,
                                                    style: AppTextStyles.inputText.copyWith(color: colors.textPrimary),
                                                    decoration: InputDecoration(
                                                      labelText: 'Category Tag',
                                                      hintText: 'e.g. SWISS ALPS',
                                                      prefixIcon: Icon(Icons.category_outlined, size: 18, color: colors.textSecondary),
                                                    ),
                                                    onChanged: (val) {
                                                      _routeCards[index] = card.copyWith(
                                                        category: card.category.copyWith(en: val),
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 16),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: TextFormField(
                                                    initialValue: card.overlayTag.en,
                                                    style: AppTextStyles.inputText.copyWith(color: colors.textPrimary),
                                                    decoration: InputDecoration(
                                                      labelText: 'Overlay Badge',
                                                      hintText: 'e.g. POPULAR ROUTE',
                                                      prefixIcon: Icon(Icons.local_offer_outlined, size: 18, color: colors.textSecondary),
                                                    ),
                                                    onChanged: (val) {
                                                      _routeCards[index] = card.copyWith(
                                                        overlayTag: card.overlayTag.copyWith(en: val),
                                                      );
                                                    },
                                                  ),
                                                ),
                                                const SizedBox(width: 16),
                                                Expanded(
                                                  child: TextFormField(
                                                    initialValue: card.duration,
                                                    style: AppTextStyles.inputText.copyWith(color: colors.textPrimary),
                                                    decoration: InputDecoration(
                                                      labelText: 'Flight Duration',
                                                      hintText: 'e.g. 1 hr 10 min',
                                                      prefixIcon: Icon(Icons.timer_outlined, size: 18, color: colors.textSecondary),
                                                    ),
                                                    onChanged: (val) {
                                                      _routeCards[index] = card.copyWith(duration: val);
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  )
                                else ...[
                                  ImageUploader(
                                    label: 'Card Image',
                                    initialImageUrl: card.imageUrl,
                                    height: 200,
                                    fit: BoxFit.cover,
                                    storagePath: 'home_cards/${card.id}',
                                    onImageUploaded: (url) {
                                      _routeCards[index] = card.copyWith(imageUrl: url);
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    initialValue: card.title.en,
                                    style: AppTextStyles.inputText.copyWith(color: colors.textPrimary),
                                    decoration: InputDecoration(
                                      labelText: 'Route Title',
                                      hintText: 'e.g. Davos Ski Escape',
                                      prefixIcon: Icon(Icons.title, size: 18, color: colors.textSecondary),
                                    ),
                                    onChanged: (val) {
                                      _routeCards[index] = card.copyWith(
                                        title: card.title.copyWith(en: val),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 14),
                                  TextFormField(
                                    initialValue: card.category.en,
                                    style: AppTextStyles.inputText.copyWith(color: colors.textPrimary),
                                    decoration: InputDecoration(
                                      labelText: 'Category Tag',
                                      hintText: 'e.g. SWISS ALPS',
                                      prefixIcon: Icon(Icons.category_outlined, size: 18, color: colors.textSecondary),
                                    ),
                                    onChanged: (val) {
                                      _routeCards[index] = card.copyWith(
                                        category: card.category.copyWith(en: val),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 14),
                                  TextFormField(
                                    initialValue: card.overlayTag.en,
                                    style: AppTextStyles.inputText.copyWith(color: colors.textPrimary),
                                    decoration: InputDecoration(
                                      labelText: 'Overlay Badge',
                                      hintText: 'e.g. POPULAR ROUTE',
                                      prefixIcon: Icon(Icons.local_offer_outlined, size: 18, color: colors.textSecondary),
                                    ),
                                    onChanged: (val) {
                                      _routeCards[index] = card.copyWith(
                                        overlayTag: card.overlayTag.copyWith(en: val),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 14),
                                  TextFormField(
                                    initialValue: card.duration,
                                    style: AppTextStyles.inputText.copyWith(color: colors.textPrimary),
                                    decoration: InputDecoration(
                                      labelText: 'Flight Duration',
                                      hintText: 'e.g. 1 hr 10 min',
                                      prefixIcon: Icon(Icons.timer_outlined, size: 18, color: colors.textSecondary),
                                    ),
                                    onChanged: (val) {
                                      _routeCards[index] = card.copyWith(duration: val);
                                    },
                                  ),
                                ],
                              ],
                            );
                          },
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Stats Counters Section
          Container(
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
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Key Statistics & Milestone Numbers (${_stats.length})', style: AppTextStyles.headingSmall.copyWith(color: colors.textPrimary)),
                        Text('Metrics displayed on the app introduction banner.', style: AppTextStyles.subtitle.copyWith(color: colors.textSecondary)),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: _addStat,
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Add Metric'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.surfaceElevatedHigher,
                        foregroundColor: colors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                if (_stats.isEmpty)
                  Text('No statistics configured.', style: AppTextStyles.subtitle.copyWith(color: colors.textSecondary))
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _stats.length,
                    itemBuilder: (context, index) {
                      final stat = _stats[index];
                      return LayoutBuilder(
                        builder: (context, statConstraints) {
                          final isStatWide = statConstraints.maxWidth > 600;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: isStatWide
                                ? Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: 140,
                                        child: TextFormField(
                                          initialValue: stat.count,
                                          style: AppTextStyles.inputText.copyWith(color: colors.textPrimary),
                                          decoration: const InputDecoration(
                                            labelText: 'Count / Value',
                                            hintText: '150+, 99.8%',
                                          ),
                                          onChanged: (val) {
                                            _stats[index] = stat.copyWith(count: val);
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: LocalizedFieldTabs(
                                          label: 'Metric Label',
                                          initialValue: stat.label,
                                          hint: 'e.g. Private Destinations, On-Time Departures',
                                          onChanged: (val) {
                                            _stats[index] = stat.copyWith(label: val);
                                          },
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.delete_outline, size: 18, color: colors.error),
                                        onPressed: () {
                                          setState(() {
                                            _stats.removeAt(index);
                                          });
                                        },
                                      ),
                                    ],
                                  )
                                : Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: TextFormField(
                                              initialValue: stat.count,
                                              style: AppTextStyles.inputText.copyWith(color: colors.textPrimary),
                                              decoration: const InputDecoration(
                                                labelText: 'Count / Value',
                                                hintText: '150+, 99.8%',
                                              ),
                                              onChanged: (val) {
                                                _stats[index] = stat.copyWith(count: val);
                                              },
                                            ),
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.delete_outline, size: 18, color: colors.error),
                                            onPressed: () {
                                              setState(() {
                                                _stats.removeAt(index);
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      LocalizedFieldTabs(
                                        label: 'Metric Label',
                                        initialValue: stat.label,
                                        hint: 'e.g. Private Destinations, On-Time Departures',
                                        onChanged: (val) {
                                          _stats[index] = stat.copyWith(label: val);
                                        },
                                      ),
                                    ],
                                  ),
                          );
                        },
                      );
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
