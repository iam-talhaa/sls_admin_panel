import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_color_scheme.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/data_table_widget.dart';
import '../../../core/widgets/status_badge.dart';
import '../data/models/admin_user_model.dart';
import '../data/repositories/admins_repository.dart';

class AdminsView extends ConsumerStatefulWidget {
  const AdminsView({super.key});

  @override
  ConsumerState<AdminsView> createState() => _AdminsViewState();
}

class _AdminsViewState extends ConsumerState<AdminsView> {
  String _searchQuery = '';

  void _showInviteAdminDialog() {
    final colors = context.colors;
    final formKey = GlobalKey<FormState>();
    final emailController = TextEditingController();
    final uidController = TextEditingController();
    AdminRole selectedRole = AdminRole.editor;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: colors.surfaceElevated,
          title: Text('Invite / Add Administrator', style: AppTextStyles.headingSmall.copyWith(color: colors.textPrimary)),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Grant access to the SLS Admin Portal. The user must have a Firebase Auth account using this email.',
                  style: AppTextStyles.subtitle.copyWith(color: colors.textSecondary),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: AppTextStyles.inputText.copyWith(color: colors.textPrimary),
                  validator: Validators.email,
                  decoration: InputDecoration(
                    labelText: 'Admin Email',
                    hintText: 'colleague@swissluxuryservices.ch',
                    prefixIcon: Icon(Icons.email_outlined, size: 18, color: colors.textSecondary),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: uidController,
                  style: AppTextStyles.inputText.copyWith(color: colors.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Firebase Auth UID (Optional)',
                    hintText: 'Leave blank to use email as identifier',
                    prefixIcon: Icon(Icons.badge_outlined, size: 18, color: colors.textSecondary),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<AdminRole>(
                  value: selectedRole,
                  dropdownColor: colors.surfaceElevated,
                  style: AppTextStyles.inputText.copyWith(color: colors.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Administrative Role',
                    prefixIcon: Icon(Icons.shield_outlined, size: 18, color: colors.textSecondary),
                  ),
                  items: AdminRole.values.map((r) {
                    return DropdownMenuItem(
                      value: r,
                      child: Text('${r.label} (${r == AdminRole.superAdmin ? 'Full Access' : 'Content Only'})'),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setDialogState(() => selectedRole = val);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel', style: TextStyle(color: colors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                final messenger = ScaffoldMessenger.of(context);
                Navigator.of(context).pop();

                try {
                  await ref.read(adminsRepositoryProvider).addOrUpdateAdmin(
                        uidOrEmail: uidController.text.trim(),
                        email: emailController.text.trim(),
                        role: selectedRole,
                      );
                  messenger.showSnackBar(
                    SnackBar(content: const Text('Admin added successfully!'), backgroundColor: colors.success),
                  );
                } catch (e) {
                  messenger.showSnackBar(
                    SnackBar(content: Text('Error adding admin: $e'), backgroundColor: colors.error),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primaryRed,
                foregroundColor: Colors.white,
              ),
              child: const Text('Grant Access'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _removeAdmin(AdminUserModel admin) async {
    final colors = context.colors;
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Revoke Admin Access',
      message: 'Are you sure you want to remove administrator privileges for ${admin.email}?',
      confirmLabel: 'Revoke Access',
      isDestructive: true,
    );

    if (confirmed && mounted) {
      await ref.read(adminsRepositoryProvider).removeAdmin(admin.uid);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text('Admin access revoked'), backgroundColor: colors.success),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final adminsAsync = ref.watch(adminsListStreamProvider);

    return Column(
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
                Text('Admin Team & Role Management', style: AppTextStyles.headingMedium.copyWith(color: colors.textPrimary)),
                const SizedBox(height: 4),
                Text('Manage staff credentials and access levels for the SLS Web Admin Portal.', style: AppTextStyles.subtitle.copyWith(color: colors.textSecondary)),
              ],
            ),
            ElevatedButton.icon(
              onPressed: _showInviteAdminDialog,
              icon: const Icon(Icons.person_add_outlined, size: 18),
              label: const Text('Add Administrator'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primaryRed,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Admins Table
        adminsAsync.when(
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
            child: Text('Error loading admins: $err', style: TextStyle(color: colors.error)),
          ),
          data: (admins) {
            final filtered = admins.where((a) {
              return _searchQuery.isEmpty ||
                  a.email.toLowerCase().contains(_searchQuery) ||
                  a.uid.toLowerCase().contains(_searchQuery);
            }).toList();

            return DataTableWidget<AdminUserModel>(
              columns: const [
                TableColumnConfig(title: 'ADMINISTRATOR', flex: 3),
                TableColumnConfig(title: 'ROLE & PERMISSIONS', flex: 2),
                TableColumnConfig(title: 'ADDED ON', width: 140),
                TableColumnConfig(title: 'ACTIONS', width: 80, alignment: Alignment.centerRight),
              ],
              items: filtered,
              onSearch: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
              searchHint: 'Search admin team by email...',
              rowBuilder: (context, admin, index) {
                return [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: (admin.isSuperAdmin ? colors.primaryRed : colors.info).withOpacity(0.2),
                        child: Text(
                          admin.email.isNotEmpty ? admin.email[0].toUpperCase() : 'A',
                          style: TextStyle(
                            color: admin.isSuperAdmin ? colors.primaryRed : colors.info,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(admin.email, style: AppTextStyles.bodyMedium.copyWith(color: colors.textPrimary, fontWeight: FontWeight.w600)),
                          Text(admin.uid, style: AppTextStyles.bodySmall.copyWith(fontSize: 11, fontFamily: 'monospace', color: colors.textSecondary)),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      StatusBadge.fromStatus(admin.role.value),
                      const SizedBox(width: 8),
                      DropdownButton<AdminRole>(
                        value: admin.role,
                        dropdownColor: colors.surfaceElevated,
                        underline: const SizedBox(),
                        items: AdminRole.values.map((r) {
                          return DropdownMenuItem(value: r, child: Text(r.label, style: TextStyle(color: colors.textPrimary, fontSize: 12)));
                        }).toList(),
                        onChanged: (newRole) {
                          if (newRole != null && newRole != admin.role) {
                            ref.read(adminsRepositoryProvider).updateRole(admin.uid, newRole);
                          }
                        },
                      ),
                    ],
                  ),
                  Text(
                    admin.createdAt != null ? DateFormat('dd MMM yyyy').format(admin.createdAt!) : 'N/A',
                    style: AppTextStyles.bodySmall.copyWith(color: colors.textSecondary),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete_outline, size: 18, color: colors.error),
                    onPressed: () => _removeAdmin(admin),
                    tooltip: 'Revoke Access',
                  ),
                ];
              },
            );
          },
        ),
      ],
    );
  }
}
