import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_color_scheme.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/services/seed_data_service.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/loading_overlay.dart';
import '../data/models/settings_model.dart';
import '../data/repositories/settings_repository.dart';

class SettingsView extends ConsumerStatefulWidget {
  const SettingsView({super.key});

  @override
  ConsumerState<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends ConsumerState<SettingsView> {
  final _formKey = GlobalKey<FormState>();

  final _recipientEmailController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _supportEmailController = TextEditingController();
  final _supportPhoneController = TextEditingController();
  final _currencyController = TextEditingController();
  bool _maintenanceMode = false;

  bool _isLoading = true;
  bool _isSaving = false;
  bool _isSeeding = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _recipientEmailController.dispose();
    _companyNameController.dispose();
    _supportEmailController.dispose();
    _supportPhoneController.dispose();
    _currencyController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    try {
      final settings = await ref.read(settingsRepositoryProvider).getSettings();
      _recipientEmailController.text = settings.recipientEmail;
      _companyNameController.text = settings.companyName;
      _supportEmailController.text = settings.supportEmail;
      _supportPhoneController.text = settings.supportPhone;
      _currencyController.text = settings.currency;
      _maintenanceMode = settings.maintenanceMode;
    } catch (_) {}
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    final colors = context.colors;

    setState(() => _isSaving = true);

    try {
      final updated = SettingsModel(
        recipientEmail: _recipientEmailController.text.trim(),
        companyName: _companyNameController.text.trim(),
        supportEmail: _supportEmailController.text.trim(),
        supportPhone: _supportPhoneController.text.trim(),
        currency: _currencyController.text.trim(),
        maintenanceMode: _maintenanceMode,
      );

      await ref.read(settingsRepositoryProvider).saveSettings(updated);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text('Settings saved successfully!'), backgroundColor: colors.success),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving settings: $e'), backgroundColor: colors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _handleSeedData() async {
    final colors = context.colors;
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Seed Sample Catalog',
      message: 'This will seed sample Fleet Jets, Destinations, Blogs, and Home Content into Firestore. Continue?',
      confirmLabel: 'Seed Data',
    );

    if (confirmed && mounted) {
      setState(() => _isSeeding = true);
      try {
        await ref.read(seedDataServiceProvider).seedInitialData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: const Text('Sample catalog seeded successfully!'), backgroundColor: colors.success),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error seeding: $e'), backgroundColor: colors.error),
          );
        }
      } finally {
        if (mounted) setState(() => _isSeeding = false);
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
      message: 'Saving configuration settings...',
      child: Form(
        key: _formKey,
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
                    Text('Global System Settings', style: AppTextStyles.headingMedium.copyWith(color: colors.textPrimary)),
                    const SizedBox(height: 4),
                    Text('Configure quote notification recipient emails, contact parameters, and database utilities.', style: AppTextStyles.subtitle.copyWith(color: colors.textSecondary)),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: _handleSave,
                  icon: const Icon(Icons.save_outlined, size: 18),
                  label: const Text('Save Settings'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primaryRed,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Notification Routing Card
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
                  Text('Notification & Inquiry Routing', style: AppTextStyles.headingSmall.copyWith(color: colors.textPrimary)),
                  const SizedBox(height: 8),
                  Text('The recipient email used when mobile app users submit flight charter quotes.', style: AppTextStyles.subtitle.copyWith(color: colors.textSecondary)),
                  const SizedBox(height: 20),

                  TextFormField(
                    controller: _recipientEmailController,
                    keyboardType: TextInputType.emailAddress,
                    style: AppTextStyles.inputText.copyWith(color: colors.textPrimary),
                    validator: Validators.email,
                    decoration: InputDecoration(
                      labelText: 'Quote Inquiries Recipient Email',
                      hintText: 'quote@swissluxuryservices.ch',
                      prefixIcon: Icon(Icons.mark_email_read_outlined, size: 18, color: colors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Company & Brand Details Card
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
                  Text('Company & Support Information', style: AppTextStyles.headingSmall.copyWith(color: colors.textPrimary)),
                  const SizedBox(height: 20),

                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth > 800;

                      if (isWide) {
                        return Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _companyNameController,
                                    style: AppTextStyles.inputText.copyWith(color: colors.textPrimary),
                                    validator: Validators.requiredField,
                                    decoration: InputDecoration(
                                      labelText: 'Company Legal Name',
                                      prefixIcon: Icon(Icons.business_outlined, size: 18, color: colors.textSecondary),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: TextFormField(
                                    controller: _currencyController,
                                    style: AppTextStyles.inputText.copyWith(color: colors.textPrimary),
                                    decoration: InputDecoration(
                                      labelText: 'Default Currency Code',
                                      hintText: 'CHF, EUR, USD',
                                      prefixIcon: Icon(Icons.attach_money, size: 18, color: colors.textSecondary),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _supportEmailController,
                                    style: AppTextStyles.inputText.copyWith(color: colors.textPrimary),
                                    validator: Validators.email,
                                    decoration: InputDecoration(
                                      labelText: 'Customer Support Email',
                                      prefixIcon: Icon(Icons.support_agent_outlined, size: 18, color: colors.textSecondary),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: TextFormField(
                                    controller: _supportPhoneController,
                                    style: AppTextStyles.inputText.copyWith(color: colors.textPrimary),
                                    decoration: InputDecoration(
                                      labelText: '24/7 VIP Hotline Phone Number',
                                      hintText: '+41 44 123 45 67',
                                      prefixIcon: Icon(Icons.phone_outlined, size: 18, color: colors.textSecondary),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      } else {
                        return Column(
                          children: [
                            TextFormField(
                              controller: _companyNameController,
                              style: AppTextStyles.inputText.copyWith(color: colors.textPrimary),
                              validator: Validators.requiredField,
                              decoration: InputDecoration(
                                labelText: 'Company Legal Name',
                                prefixIcon: Icon(Icons.business_outlined, size: 18, color: colors.textSecondary),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _currencyController,
                              style: AppTextStyles.inputText.copyWith(color: colors.textPrimary),
                              decoration: InputDecoration(
                                labelText: 'Default Currency Code',
                                hintText: 'CHF, EUR, USD',
                                prefixIcon: Icon(Icons.attach_money, size: 18, color: colors.textSecondary),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _supportEmailController,
                              style: AppTextStyles.inputText.copyWith(color: colors.textPrimary),
                              validator: Validators.email,
                              decoration: InputDecoration(
                                labelText: 'Customer Support Email',
                                prefixIcon: Icon(Icons.support_agent_outlined, size: 18, color: colors.textSecondary),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _supportPhoneController,
                              style: AppTextStyles.inputText.copyWith(color: colors.textPrimary),
                              decoration: InputDecoration(
                                labelText: '24/7 VIP Hotline Phone Number',
                                hintText: '+41 44 123 45 67',
                                prefixIcon: Icon(Icons.phone_outlined, size: 18, color: colors.textSecondary),
                              ),
                            ),
                          ],
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Database Utilities & Migration Card
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
                  Text('Database Utilities & Migration Tools', style: AppTextStyles.headingSmall.copyWith(color: colors.textPrimary)),
                  const SizedBox(height: 8),
                  Text('Initial seed tools to populate Firestore with sample fleet, destinations, and journal articles.', style: AppTextStyles.subtitle.copyWith(color: colors.textSecondary)),
                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Populate Sample SLS Catalog', style: AppTextStyles.fieldLabel.copyWith(color: colors.textPrimary)),
                          Text('Fills jets, destinations, blogs, and home content collections.', style: AppTextStyles.subtitle.copyWith(color: colors.textSecondary)),
                        ],
                      ),
                      ElevatedButton.icon(
                        onPressed: _isSeeding ? null : _handleSeedData,
                        icon: _isSeeding
                            ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.cloud_upload_outlined, size: 18),
                        label: Text(_isSeeding ? 'Seeding...' : 'Seed Catalog Data'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors.surfaceElevatedHigher,
                          foregroundColor: colors.textPrimary,
                        ),
                      ),
                    ],
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
