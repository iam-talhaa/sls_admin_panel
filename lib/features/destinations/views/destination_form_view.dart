import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_color_scheme.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/models/content_block.dart';
import '../../../core/models/localized_text.dart';
import '../../../core/widgets/content_block_editor.dart';
import '../../../core/widgets/image_uploader.dart';
import '../../../core/widgets/loading_overlay.dart';
import '../../../core/widgets/localized_field_tabs.dart';
import '../data/models/destination_admin_model.dart';
import '../data/repositories/destinations_repository.dart';

class DestinationFormView extends ConsumerStatefulWidget {
  final String destinationId;

  const DestinationFormView({super.key, required this.destinationId});

  @override
  ConsumerState<DestinationFormView> createState() => _DestinationFormViewState();
}

class _DestinationFormViewState extends ConsumerState<DestinationFormView> {
  final _formKey = GlobalKey<FormState>();
  final _durationController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;

  late String _id;
  int _order = 0;
  LocalizedText _title = LocalizedText.empty;
  LocalizedText _category = LocalizedText.empty;
  String _imageUrl = '';
  LocalizedText _overlayTag = LocalizedText.empty;
  String _jetType = 'Light Jet';
  LocalizedText _seating = const LocalizedText(en: 'SEATING : UP TO 4');
  LocalizedText _range = const LocalizedText(en: 'RANGE : UP TO 2.5 HOURS');
  LocalizedText _route = LocalizedText.empty;
  LocalizedText _startingPrice = LocalizedText.empty;
  LocalizedText _description = LocalizedText.empty;
  List<LocalizedText> _whyTravelWithUs = [];
  List<ContentBlock> _contentBlocks = [];
  bool _isActive = true;

  bool get isNew => widget.destinationId == 'new' || widget.destinationId.isEmpty;

  @override
  void initState() {
    super.initState();
    _loadDestinationData();
  }

  @override
  void dispose() {
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _loadDestinationData() async {
    if (isNew) {
      _id = 'dest_${DateTime.now().millisecondsSinceEpoch}';
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final dest = await ref.read(destinationsRepositoryProvider).getDestinationById(widget.destinationId);
      if (dest != null) {
        _id = dest.id;
        _order = dest.order;
        _title = dest.title;
        _category = dest.category;
        _durationController.text = dest.duration;
        _imageUrl = dest.imageUrl;
        _overlayTag = dest.overlayTag;
        _jetType = dest.jetType;
        _seating = dest.seating;
        _range = dest.range;
        _route = dest.route ?? LocalizedText.empty;
        _startingPrice = dest.startingPrice ?? LocalizedText.empty;
        _description = dest.description;
        _whyTravelWithUs = List.from(dest.whyTravelWithUs);
        _contentBlocks = List.from(dest.contentBlocks);
        _isActive = dest.isActive;
      }
    } catch (e) {
      if (mounted) {
        final colors = context.colors;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading destination: $e'), backgroundColor: colors.error),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleSave() async {
    final colors = context.colors;
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('Please complete all required fields.'), backgroundColor: colors.error),
      );
      return;
    }

    if (_title.en.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('Please enter a destination title in English.'), backgroundColor: colors.error),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final destination = DestinationAdminModel(
        id: isNew ? '' : _id,
        order: _order,
        title: _title,
        category: _category,
        duration: _durationController.text.trim(),
        imageUrl: _imageUrl,
        overlayTag: _overlayTag,
        jetType: _jetType,
        seating: _seating,
        range: _range,
        route: _route.isNotEmpty ? _route : null,
        startingPrice: _startingPrice.isNotEmpty ? _startingPrice : null,
        description: _description,
        whyTravelWithUs: _whyTravelWithUs,
        contentBlocks: _contentBlocks,
        isActive: _isActive,
      );

      await ref.read(destinationsRepositoryProvider).saveDestination(destination);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isNew ? 'Destination created successfully!' : 'Destination updated successfully!'),
            backgroundColor: colors.success,
          ),
        );
        context.go('/destinations');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving destination: $e'), backgroundColor: colors.error),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
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

    return LoadingOverlay(
      isLoading: _isSaving,
      message: 'Saving destination details...',
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
                      onPressed: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go('/destinations');
                        }
                      },
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(isNew ? 'Add Destination & Route' : 'Edit Destination', style: AppTextStyles.headingMedium.copyWith(color: colors.textPrimary)),
                        Text(isNew ? 'Create a new VIP travel destination' : 'ID: $_id', style: AppTextStyles.subtitle.copyWith(color: colors.textSecondary)),
                      ],
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    OutlinedButton(
                      onPressed: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go('/destinations');
                        }
                      },
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
                      label: Text(isNew ? 'Create Destination' : 'Save Changes'),
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

            // Main Info Card
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
                  Text('Basic Details & Route Info', style: AppTextStyles.headingSmall.copyWith(color: colors.textPrimary)),
                  const SizedBox(height: 20),

                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth > 850;

                      return Column(
                        children: [
                          if (isWide)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: LocalizedFieldTabs(
                                    label: 'Destination Title',
                                    initialValue: _title,
                                    isRequired: true,
                                    hint: 'e.g. WEF Davos, Art Basel',
                                    onChanged: (val) => _title = val,
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  flex: 2,
                                  child: LocalizedFieldTabs(
                                    label: 'Category Subtitle',
                                    initialValue: _category,
                                    hint: 'e.g. WORLD ECONOMIC FORUM',
                                    onChanged: (val) => _category = val,
                                  ),
                                ),
                              ],
                            )
                          else ...[
                            LocalizedFieldTabs(
                              label: 'Destination Title',
                              initialValue: _title,
                              isRequired: true,
                              hint: 'e.g. WEF Davos, Art Basel',
                              onChanged: (val) => _title = val,
                            ),
                            const SizedBox(height: 16),
                            LocalizedFieldTabs(
                              label: 'Category Subtitle',
                              initialValue: _category,
                              hint: 'e.g. WORLD ECONOMIC FORUM',
                              onChanged: (val) => _category = val,
                            ),
                          ],
                          const SizedBox(height: 20),

                          ImageUploader(
                            label: 'Cover / Hero Image',
                            initialImageUrl: _imageUrl,
                            storagePath: 'destinations/${isNew ? 'temp_${DateTime.now().millisecondsSinceEpoch}' : _id}',
                            onImageUploaded: (url) => _imageUrl = url,
                          ),
                          const SizedBox(height: 20),

                          if (isWide)
                            Row(
                              children: [
                                Expanded(
                                  child: LocalizedFieldTabs(
                                    label: 'Overlay Tag',
                                    initialValue: _overlayTag,
                                    hint: 'e.g. WEF • ~ 1 hr 10 min',
                                    onChanged: (val) => _overlayTag = val,
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: TextFormField(
                                    controller: _durationController,
                                    style: AppTextStyles.inputText.copyWith(color: colors.textPrimary),
                                    decoration: InputDecoration(
                                      labelText: 'Flight Duration',
                                      hintText: 'e.g. 1 hr 10 min',
                                      prefixIcon: Icon(Icons.timer_outlined, size: 18, color: colors.textSecondary),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          else ...[
                            LocalizedFieldTabs(
                              label: 'Overlay Tag',
                              initialValue: _overlayTag,
                              hint: 'e.g. WEF • ~ 1 hr 10 min',
                              onChanged: (val) => _overlayTag = val,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _durationController,
                              style: AppTextStyles.inputText.copyWith(color: colors.textPrimary),
                              decoration: InputDecoration(
                                labelText: 'Flight Duration',
                                hintText: 'e.g. 1 hr 10 min',
                                prefixIcon: Icon(Icons.timer_outlined, size: 18, color: colors.textSecondary),
                              ),
                            ),
                          ],
                          const SizedBox(height: 20),

                          if (isWide)
                            Row(
                              children: [
                                Expanded(
                                  child: LocalizedFieldTabs(
                                    label: 'Route Pair',
                                    initialValue: _route,
                                    hint: 'e.g. Zurich – Davos',
                                    onChanged: (val) => _route = val,
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: LocalizedFieldTabs(
                                    label: 'Starting Price Label',
                                    initialValue: _startingPrice,
                                    hint: 'e.g. From CHF 3,500',
                                    onChanged: (val) => _startingPrice = val,
                                  ),
                                ),
                              ],
                            )
                          else ...[
                            LocalizedFieldTabs(
                              label: 'Route Pair',
                              initialValue: _route,
                              hint: 'e.g. Zurich – Davos',
                              onChanged: (val) => _route = val,
                            ),
                            const SizedBox(height: 16),
                            LocalizedFieldTabs(
                              label: 'Starting Price Label',
                              initialValue: _startingPrice,
                              hint: 'e.g. From CHF 3,500',
                              onChanged: (val) => _startingPrice = val,
                            ),
                          ],
                          const SizedBox(height: 20),

                          LocalizedFieldTabs(
                            label: 'Destination Overview / Description',
                            initialValue: _description,
                            maxLines: 5,
                            hint: 'Complete description of the destination, airport transfer details, VIP experience...',
                            onChanged: (val) => _description = val,
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Why Travel With Us Section
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
                          Text('Why Travel With Us (Highlights)', style: AppTextStyles.headingSmall.copyWith(color: colors.textPrimary)),
                          Text('Bullet points highlighted on destination overview.', style: AppTextStyles.subtitle.copyWith(color: colors.textSecondary)),
                        ],
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _whyTravelWithUs.add(LocalizedText.empty);
                          });
                        },
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Add Highlight'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors.surfaceElevatedHigher,
                          foregroundColor: colors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  if (_whyTravelWithUs.isEmpty)
                    Text('No highlights added yet.', style: AppTextStyles.subtitle.copyWith(color: colors.textSecondary))
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _whyTravelWithUs.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 14, right: 8),
                                child: Text('•', style: AppTextStyles.headingMedium.copyWith(color: colors.primaryRed)),
                              ),
                              Expanded(
                                child: LocalizedFieldTabs(
                                  label: 'Highlight #${index + 1}',
                                  initialValue: _whyTravelWithUs[index],
                                  maxLines: 2,
                                  hint: 'e.g. Direct airport access to Samedan (SMV)...',
                                  onChanged: (val) {
                                    _whyTravelWithUs[index] = val;
                                  },
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete_outline, size: 18, color: colors.error),
                                onPressed: () {
                                  setState(() {
                                    _whyTravelWithUs.removeAt(index);
                                  });
                                },
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

            // Rich Content Blocks Section
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
              child: ContentBlockEditor(
                initialBlocks: _contentBlocks,
                onChanged: (blocks) => _contentBlocks = blocks,
              ),
            ),
            const SizedBox(height: 24),

            // Active Toggle
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
                      Text('Publish Status', style: AppTextStyles.fieldLabel.copyWith(color: colors.textPrimary)),
                      Text('Active destinations are immediately visible in the mobile app.', style: AppTextStyles.subtitle.copyWith(color: colors.textSecondary)),
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
        ),
      ),
    );
  }
}
