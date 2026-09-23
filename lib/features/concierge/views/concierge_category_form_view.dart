import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_color_scheme.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/models/localized_text.dart';
import '../../../core/widgets/image_uploader.dart';
import '../../../core/widgets/loading_overlay.dart';
import '../../../core/widgets/localized_field_tabs.dart';
import '../data/models/concierge_model.dart';
import '../data/services/concierge_service.dart';
import 'widgets/concierge_mobile_preview.dart';

class ConciergeCategoryFormView extends ConsumerStatefulWidget {
  final String categoryId;

  const ConciergeCategoryFormView({super.key, required this.categoryId});

  @override
  ConsumerState<ConciergeCategoryFormView> createState() => _ConciergeCategoryFormViewState();
}

class _ConciergeCategoryFormViewState extends ConsumerState<ConciergeCategoryFormView> {
  final _formKey = GlobalKey<FormState>();
  final _slugController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;

  late String _id;
  int _sortOrder = 1;
  LocalizedText _tabTitle = LocalizedText.empty;
  LocalizedText _categoryTag = LocalizedText.empty;
  LocalizedText _title = LocalizedText.empty;
  LocalizedText _description = LocalizedText.empty;
  String _imageUrl = '';
  bool _isActive = true;
  List<ConciergeFeature> _features = [];

  // Banner for the mobile preview
  ConciergeBanner _banner = ConciergeBanner.empty;

  bool get isNew => widget.categoryId == 'new' || widget.categoryId.isEmpty;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _slugController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final service = ref.read(conciergeServiceProvider);
      _banner = await service.getBanner();

      if (isNew) {
        _id = 'cat_${DateTime.now().millisecondsSinceEpoch}';
        _features = [
          ConciergeFeature(
            id: 'feat_1',
            sortOrder: 1,
            text: const LocalizedText(en: 'Dedicated 24/7 VIP assistance and concierge'),
          ),
        ];
      } else {
        final cat = await service.getCategory(widget.categoryId);
        if (cat != null) {
          _id = cat.id;
          _slugController.text = cat.slug;
          _sortOrder = cat.sortOrder;
          _tabTitle = cat.tabTitle;
          _categoryTag = cat.categoryTag;
          _title = cat.title;
          _description = cat.description;
          _imageUrl = cat.imageUrl;
          _isActive = cat.isActive;
          _features = List.from(cat.features);
        }
      }
    } catch (e) {
      if (mounted) {
        final colors = context.colors;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading category data: $e'), backgroundColor: colors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  ConciergeCategory _buildCurrentCategory() {
    return ConciergeCategory(
      id: _id,
      slug: _slugController.text.trim(),
      sortOrder: _sortOrder,
      tabTitle: _tabTitle,
      categoryTag: _categoryTag,
      title: _title,
      description: _description,
      imageUrl: _imageUrl,
      isActive: _isActive,
      features: _features,
    );
  }

  void _addFeature() {
    setState(() {
      final newFeature = ConciergeFeature(
        id: 'feat_${DateTime.now().millisecondsSinceEpoch}',
        sortOrder: _features.length + 1,
        text: LocalizedText.empty,
      );
      _features.add(newFeature);
    });
  }

  void _removeFeature(int index) {
    setState(() {
      _features.removeAt(index);
      for (int i = 0; i < _features.length; i++) {
        _features[i] = _features[i].copyWith(sortOrder: i + 1);
      }
    });
  }

  Future<void> _handleSave() async {
    final colors = context.colors;

    if (_tabTitle.en.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a Tab Title in English.'),
          backgroundColor: colors.error,
        ),
      );
      return;
    }

    if (_title.en.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a Category Title in English.'),
          backgroundColor: colors.error,
        ),
      );
      return;
    }

    String slug = _slugController.text.trim();
    if (slug.isEmpty) {
      slug = _tabTitle.en.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-').replaceAll(RegExp(r'^-|-$'), '');
      _slugController.text = slug;
    }

    setState(() => _isSaving = true);

    try {
      final category = _buildCurrentCategory();
      final service = ref.read(conciergeServiceProvider);

      if (isNew) {
        await service.createCategory(category);
      } else {
        await service.updateCategory(category);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isNew ? 'Concierge category created successfully!' : 'Concierge category updated successfully!'),
            backgroundColor: colors.success,
          ),
        );
        context.go('/concierge');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving category: $e'), backgroundColor: colors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
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

    final currentCategory = _buildCurrentCategory();

    return LoadingOverlay(
      isLoading: _isSaving,
      message: 'Saving concierge category...',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Bar
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 12,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: colors.textPrimary),
                      onPressed: () => context.go('/concierge'),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isNew ? 'Add Concierge Category' : 'Edit Concierge Category',
                          style: AppTextStyles.headingMedium.copyWith(color: colors.textPrimary),
                        ),
                        Text(
                          isNew ? 'Create a new concierge service category tab' : 'Category ID: $_id',
                          style: AppTextStyles.subtitle.copyWith(color: colors.textSecondary),
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    OutlinedButton(
                      onPressed: () => context.go('/concierge'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colors.textSecondary,
                        side: BorderSide(color: colors.border),
                      ),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: _handleSave,
                      icon: const Icon(Icons.save_outlined, size: 18),
                      label: Text(isNew ? 'Create Category' : 'Save Changes'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.primaryRed,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Main Editor with Live Preview Layout
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 1050;

                if (isWide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left Side: Edit Form
                      Expanded(
                        flex: 6,
                        child: _buildFormFields(context),
                      ),
                      const SizedBox(width: 24),
                      // Right Side: Live Mobile Preview Sticky Panel
                      Expanded(
                        flex: 4,
                        child: ConciergeMobilePreview(
                          banner: _banner,
                          categories: [currentCategory],
                          selectedCategory: currentCategory,
                        ),
                      ),
                    ],
                  );
                } else {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildFormFields(context),
                      const SizedBox(height: 28),
                      Text(
                        'Mobile Layout Preview',
                        style: AppTextStyles.headingSmall.copyWith(color: colors.textPrimary),
                      ),
                      const SizedBox(height: 12),
                      ConciergeMobilePreview(
                        banner: _banner,
                        categories: [currentCategory],
                        selectedCategory: currentCategory,
                      ),
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormFields(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Basic Metadata Card
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
              Text('Tab Identity & Tag', style: AppTextStyles.headingSmall.copyWith(color: colors.textPrimary)),
              const SizedBox(height: 18),

              LocalizedFieldTabs(
                label: 'Category Tab Title',
                initialValue: _tabTitle,
                isRequired: true,
                hint: 'e.g. Hotel Booking, Chauffeur Services',
                onChanged: (val) => setState(() => _tabTitle = val),
              ),
              const SizedBox(height: 18),

              TextFormField(
                controller: _slugController,
                style: AppTextStyles.inputText.copyWith(color: colors.textPrimary),
                decoration: InputDecoration(
                  labelText: 'URL Slug / Identifier',
                  hintText: 'e.g. hotel-booking, chauffeur-services',
                  prefixIcon: Icon(Icons.link, size: 18, color: colors.textSecondary),
                  helperText: 'Unique machine-readable identifier for API/deep-links',
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 18),

              LocalizedFieldTabs(
                label: 'Category Header Tag (Red Eyebrow)',
                initialValue: _categoryTag,
                hint: 'e.g. LUXURY ACCOMMODATION, EXECUTIVE MOBILITY',
                onChanged: (val) => setState(() => _categoryTag = val),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Rich Content Card
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
              Text('Headline, Description & Media', style: AppTextStyles.headingSmall.copyWith(color: colors.textPrimary)),
              const SizedBox(height: 18),

              LocalizedFieldTabs(
                label: 'Category Headline / Main Title',
                initialValue: _title,
                isRequired: true,
                hint: 'e.g. Bespoke 5-Star Hotel & Private Chalet Reservations',
                onChanged: (val) => setState(() => _title = val),
              ),
              const SizedBox(height: 18),

              LocalizedFieldTabs(
                label: 'Detailed Description / Copy',
                initialValue: _description,
                maxLines: 4,
                hint: 'Describe the exclusive features, partnerships and bespoke advantages of this service category...',
                onChanged: (val) => setState(() => _description = val),
              ),
              const SizedBox(height: 20),

              ImageUploader(
                label: 'Category Showcase Image',
                initialImageUrl: _imageUrl,
                storagePath: 'concierge_categories/$_id',
                onImageUploaded: (url) {
                  setState(() => _imageUrl = url);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Repeatable Features Manager Card
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Privilege Checklist & Features (${_features.length})', style: AppTextStyles.headingSmall.copyWith(color: colors.textPrimary)),
                      const SizedBox(height: 4),
                      Text('Free-form bullet features displayed with checkmark icons.', style: AppTextStyles.subtitle.copyWith(color: colors.textSecondary)),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: _addFeature,
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Add Feature'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.surfaceElevatedHigher,
                      foregroundColor: colors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              if (_features.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: colors.surfaceElevatedHigher,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: colors.border),
                  ),
                  child: Center(
                    child: Text(
                      'No features added yet. Click "+ Add Feature" above to add checklist items.',
                      style: AppTextStyles.subtitle.copyWith(color: colors.textSecondary),
                    ),
                  ),
                )
              else
                ReorderableListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _features.length,
                  onReorder: (oldIndex, newIndex) {
                    setState(() {
                      if (newIndex > oldIndex) newIndex -= 1;
                      final item = _features.removeAt(oldIndex);
                      _features.insert(newIndex, item);
                      for (int i = 0; i < _features.length; i++) {
                        _features[i] = _features[i].copyWith(sortOrder: i + 1);
                      }
                    });
                  },
                  buildDefaultDragHandles: false,
                  itemBuilder: (context, index) {
                    final feature = _features[index];
                    return Container(
                      key: ValueKey(feature.id.isNotEmpty ? feature.id : 'feat_$index'),
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colors.surfaceElevatedHigher,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: colors.border, width: 1),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ReorderableDragStartListener(
                            index: index,
                            child: MouseRegion(
                              cursor: SystemMouseCursors.grab,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 10, right: 12),
                                child: Icon(Icons.drag_indicator, color: colors.textSecondary, size: 20),
                              ),
                            ),
                          ),
                          Expanded(
                            child: LocalizedFieldTabs(
                              label: 'Feature #${index + 1}',
                              initialValue: feature.text,
                              hint: 'e.g. Complimentary suite upgrade upon availability',
                              onChanged: (val) {
                                _features[index] = feature.copyWith(text: val);
                                setState(() {});
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: Icon(Icons.delete_outline, size: 18, color: colors.error),
                            tooltip: 'Remove Feature',
                            onPressed: () => _removeFeature(index),
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Active Status Card
        Container(
          padding: const EdgeInsets.all(20),
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Category Active Status', style: AppTextStyles.fieldLabel.copyWith(color: colors.textPrimary)),
                  const SizedBox(height: 4),
                  Text('Active categories appear in the mobile app category tabs.', style: AppTextStyles.subtitle.copyWith(color: colors.textSecondary)),
                ],
              ),
              Switch(
                value: _isActive,
                onChanged: (val) => setState(() => _isActive = val),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
