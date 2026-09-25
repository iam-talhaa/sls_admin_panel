import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_color_scheme.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/models/localized_text.dart';
import '../../../core/widgets/image_uploader.dart';
import '../../../core/widgets/loading_overlay.dart';
import '../../../core/widgets/localized_field_tabs.dart';
import '../data/models/jet_admin_model.dart';
import '../data/repositories/fleet_repository.dart';

class JetFormView extends ConsumerStatefulWidget {
  final String jetId;

  const JetFormView({super.key, required this.jetId});

  @override
  ConsumerState<JetFormView> createState() => _JetFormViewState();
}

class _JetFormViewState extends ConsumerState<JetFormView> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  bool _isSaving = false;

  late String _id;
  int _order = 0;
  String _category = 'LIGHT JET';
  String _imageUrl = '';
  LocalizedText _name = LocalizedText.empty;
  LocalizedText _seating = const LocalizedText(en: 'SEATING : UP TO 4');
  LocalizedText _range = const LocalizedText(en: 'RANGE : UP TO 2.5 HOURS');
  LocalizedText _description = LocalizedText.empty;
  bool _isActive = true;

  bool get isNew => widget.jetId == 'new' || widget.jetId.isEmpty;

  @override
  void initState() {
    super.initState();
    _loadJetData();
  }

  Future<void> _loadJetData() async {
    if (isNew) {
      _id = 'jet_${DateTime.now().millisecondsSinceEpoch}';
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final jet = await ref.read(fleetRepositoryProvider).getJetById(widget.jetId);
      if (jet != null) {
        _id = jet.id;
        _order = jet.order;
        _category = jet.category;
        _imageUrl = jet.imageUrl;
        _name = jet.name;
        _seating = jet.seating;
        _range = jet.range;
        _description = jet.description;
        _isActive = jet.isActive;
      }
    } catch (e) {
      if (mounted) {
        final colors = context.colors;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading jet: $e'), backgroundColor: colors.error),
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
        SnackBar(
          content: const Text('Please complete all required fields.'),
          backgroundColor: colors.error,
        ),
      );
      return;
    }

    if (_name.en.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter an aircraft name in English.'),
          backgroundColor: colors.error,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final jet = JetAdminModel(
        id: isNew ? '' : _id,
        order: _order,
        category: _category,
        imageUrl: _imageUrl,
        name: _name,
        seating: _seating,
        range: _range,
        description: _description,
        isActive: _isActive,
      );

      await ref.read(fleetRepositoryProvider).saveJet(jet);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isNew ? 'Aircraft added to fleet successfully!' : 'Aircraft updated successfully!'),
            backgroundColor: colors.success,
          ),
        );
        context.go('/fleet');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving aircraft: $e'), backgroundColor: colors.error),
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
      message: 'Saving aircraft details...',
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
                          context.go('/fleet');
                        }
                      },
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(isNew ? 'Add New Aircraft' : 'Edit Aircraft Details', style: AppTextStyles.headingMedium.copyWith(color: colors.textPrimary)),
                        Text(isNew ? 'Create a new jet or helicopter profile' : 'ID: $_id', style: AppTextStyles.subtitle.copyWith(color: colors.textSecondary)),
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
                          context.go('/fleet');
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
                      label: Text(isNew ? 'Create Aircraft' : 'Save Changes'),
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

            // Form Layout
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 850;

                return Column(
                  children: [
                    // Main Information Card
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
                          Text('Aircraft Profile', style: AppTextStyles.headingSmall.copyWith(color: colors.textPrimary)),
                          const SizedBox(height: 20),

                          if (isWide)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: LocalizedFieldTabs(
                                    label: 'Aircraft Name',
                                    initialValue: _name,
                                    isRequired: true,
                                    hint: 'e.g. Light Jet, Pilatus PC-24',
                                    onChanged: (val) => _name = val,
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  flex: 2,
                                  child: _buildCategoryDropdown(colors),
                                ),
                              ],
                            )
                          else ...[
                            LocalizedFieldTabs(
                              label: 'Aircraft Name',
                              initialValue: _name,
                              isRequired: true,
                              hint: 'e.g. Light Jet, Pilatus PC-24',
                              onChanged: (val) => _name = val,
                            ),
                            const SizedBox(height: 16),
                            _buildCategoryDropdown(colors),
                          ],

                          const SizedBox(height: 20),
                          ImageUploader(
                            label: 'Aircraft Featured Image',
                            initialImageUrl: _imageUrl,
                            storagePath: 'jets/${isNew ? 'temp_${DateTime.now().millisecondsSinceEpoch}' : _id}',
                            onImageUploaded: (url) => _imageUrl = url,
                          ),

                          const SizedBox(height: 20),
                          if (isWide)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: LocalizedFieldTabs(
                                    label: 'Seating Capacity',
                                    initialValue: _seating,
                                    hint: 'e.g. SEATING : UP TO 4',
                                    onChanged: (val) => _seating = val,
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: LocalizedFieldTabs(
                                    label: 'Flight Range / Duration',
                                    initialValue: _range,
                                    hint: 'e.g. RANGE : UP TO 2.5 HOURS',
                                    onChanged: (val) => _range = val,
                                  ),
                                ),
                              ],
                            )
                          else ...[
                            LocalizedFieldTabs(
                              label: 'Seating Capacity',
                              initialValue: _seating,
                              hint: 'e.g. SEATING : UP TO 4',
                              onChanged: (val) => _seating = val,
                            ),
                            const SizedBox(height: 16),
                            LocalizedFieldTabs(
                              label: 'Flight Range / Duration',
                              initialValue: _range,
                              hint: 'e.g. RANGE : UP TO 2.5 HOURS',
                              onChanged: (val) => _range = val,
                            ),
                          ],

                          const SizedBox(height: 20),
                          LocalizedFieldTabs(
                            label: 'Overview Description',
                            initialValue: _description,
                            maxLines: 5,
                            hint: 'Detailed specifications, passenger amenities, cabin features...',
                            onChanged: (val) => _description = val,
                          ),

                          const SizedBox(height: 20),
                          Divider(color: colors.border),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Publish Status', style: AppTextStyles.fieldLabel.copyWith(color: colors.textPrimary)),
                                  Text('Active aircraft are immediately visible in the mobile app fleet list.', style: AppTextStyles.subtitle.copyWith(color: colors.textSecondary)),
                                ],
                              ),
                              Switch(
                                value: _isActive,
                                onChanged: (val) => setState(() => _isActive = val),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown(dynamic colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Category', style: AppTextStyles.fieldLabel.copyWith(color: colors.textPrimary)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _category,
          dropdownColor: colors.surfaceElevated,
          style: AppTextStyles.inputText.copyWith(color: colors.textPrimary),
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.category_outlined, size: 18, color: colors.textSecondary),
          ),
          items: const [
            DropdownMenuItem(value: 'LIGHT JET', child: Text('LIGHT JET')),
            DropdownMenuItem(value: 'MIDSIZE JET', child: Text('MIDSIZE JET')),
            DropdownMenuItem(value: 'HEAVY JET', child: Text('HEAVY JET')),
            DropdownMenuItem(value: 'HELICOPTER', child: Text('HELICOPTER')),
            DropdownMenuItem(value: 'SUPER MIDSIZE JET', child: Text('SUPER MIDSIZE JET')),
            DropdownMenuItem(value: 'TURBOPROP', child: Text('TURBOPROP')),
          ],
          onChanged: (val) {
            if (val != null) setState(() => _category = val);
          },
        ),
      ],
    );
  }
}
