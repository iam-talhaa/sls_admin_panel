import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_color_scheme.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/services/csv_export_service.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/data_table_widget.dart';
import '../../../core/widgets/status_badge.dart';
import '../data/models/user_admin_model.dart';
import '../data/repositories/users_repository.dart';

class UsersListView extends ConsumerStatefulWidget {
  const UsersListView({super.key});

  @override
  ConsumerState<UsersListView> createState() => _UsersListViewState();
}

class _UsersListViewState extends ConsumerState<UsersListView> {
  String _searchQuery = '';
  String _selectedStatus = 'ALL';

  void _exportCsv(List<UserAdminModel> users) {
    final colors = context.colors;
    final rows = <List<dynamic>>[
      ['UID', 'Display Name', 'Email', 'Phone', 'Role', 'Status', 'Registration Date', 'Last Sign In'],
      ...users.map((u) => [
            u.uid,
            u.displayName,
            u.email,
            u.phoneNumber,
            u.role,
            u.disabled ? 'Disabled' : 'Active',
            u.createdAt != null ? DateFormat('yyyy-MM-dd HH:mm').format(u.createdAt!) : '',
            u.lastSignInAt != null ? DateFormat('yyyy-MM-dd HH:mm').format(u.lastSignInAt!) : '',
          ]),
    ];

    CsvExportService.exportToCsv(
      fileName: 'sls_mobile_users_${DateFormat('yyyyMMdd').format(DateTime.now())}.csv',
      rows: rows,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Users list exported to CSV successfully!'),
        backgroundColor: colors.success,
      ),
    );
  }

  Future<void> _toggleUserDisabled(UserAdminModel user, bool newDisabled) async {
    final colors = context.colors;
    final confirmed = await ConfirmDialog.show(
      context,
      title: newDisabled ? 'Disable User Account' : 'Enable User Account',
      message: newDisabled
          ? 'Are you sure you want to disable ${user.email.isNotEmpty ? user.email : user.displayName}? They will no longer be able to sign in to the mobile app.'
          : 'Are you sure you want to enable ${user.email.isNotEmpty ? user.email : user.displayName}?',
      confirmLabel: newDisabled ? 'Disable Account' : 'Enable Account',
      isDestructive: newDisabled,
    );

    if (confirmed && mounted) {
      try {
        await ref.read(usersRepositoryProvider).setUserDisabled(user.uid, newDisabled);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('User account ${newDisabled ? 'disabled' : 'enabled'} in Firebase'),
              backgroundColor: colors.success,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error updating user: $e'), backgroundColor: colors.error),
          );
        }
      }
    }
  }

  Future<void> _deleteUser(UserAdminModel user) async {
    final colors = context.colors;
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Delete User Account',
      message: 'Are you sure you want to permanently delete user ${user.email.isNotEmpty ? user.email : user.displayName} (${user.uid}) from Firebase?',
      confirmLabel: 'Delete',
      isDestructive: true,
    );

    if (confirmed && mounted) {
      try {
        await ref.read(usersRepositoryProvider).deleteUser(user.uid);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: const Text('User account deleted from Firebase'), backgroundColor: colors.success),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting user: $e'), backgroundColor: colors.error),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final usersAsync = ref.watch(usersListStreamProvider);

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
                Text('Registered Mobile App Users', style: AppTextStyles.headingMedium.copyWith(color: colors.textPrimary)),
                const SizedBox(height: 4),
                Text('Real-time database of mobile clients registered in Swiss Luxury Services.', style: AppTextStyles.subtitle.copyWith(color: colors.textSecondary)),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                usersAsync.when(
                  data: (users) => ElevatedButton.icon(
                    onPressed: users.isEmpty ? null : () => _exportCsv(users),
                    icon: const Icon(Icons.download, size: 18),
                    label: const Text('Export CSV'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.surfaceElevatedHigher,
                      foregroundColor: colors.textPrimary,
                      side: BorderSide(color: colors.border),
                    ),
                  ),
                  loading: () => const SizedBox(),
                  error: (_, __) => const SizedBox(),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.refresh, color: colors.textPrimary),
                  onPressed: () => ref.invalidate(usersListStreamProvider),
                  tooltip: 'Refresh Users',
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Data Table
        usersAsync.when(
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
            child: Text('Error loading users: $err', style: TextStyle(color: colors.error)),
          ),
          data: (users) {
            final filtered = users.where((u) {
              final matchesQuery = _searchQuery.isEmpty ||
                  u.email.toLowerCase().contains(_searchQuery) ||
                  u.displayName.toLowerCase().contains(_searchQuery) ||
                  u.phoneNumber.toLowerCase().contains(_searchQuery) ||
                  u.uid.toLowerCase().contains(_searchQuery);

              final matchesStatus = _selectedStatus == 'ALL' ||
                  (_selectedStatus == 'active' && !u.disabled) ||
                  (_selectedStatus == 'disabled' && u.disabled);

              return matchesQuery && matchesStatus;
            }).toList();

            return DataTableWidget<UserAdminModel>(
              columns: const [
                TableColumnConfig(title: 'USER', flex: 3),
                TableColumnConfig(title: 'UID', flex: 2),
                TableColumnConfig(title: 'PHONE', width: 140),
                TableColumnConfig(title: 'REGISTERED', width: 130),
                TableColumnConfig(title: 'LAST SIGN IN', width: 130),
                TableColumnConfig(title: 'STATUS', width: 110),
                TableColumnConfig(title: 'ACTIONS', width: 100, alignment: Alignment.centerRight),
              ],
              items: filtered,
              onRowTap: (user) => context.go('/users/${user.uid}'),
              onSearch: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
              searchHint: 'Search users by name, email, phone or UID...',
              emptyTitle: 'No users found',
              emptyMessage: 'No user records matching the filter in Firebase Firestore.',
              filterWidget: DropdownButton<String>(
                value: _selectedStatus,
                dropdownColor: colors.surfaceElevated,
                style: AppTextStyles.bodyMedium.copyWith(color: colors.textPrimary),
                underline: const SizedBox(),
                items: const [
                  DropdownMenuItem(value: 'ALL', child: Text('All Users')),
                  DropdownMenuItem(value: 'active', child: Text('Active Only')),
                  DropdownMenuItem(value: 'disabled', child: Text('Disabled Only')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _selectedStatus = val);
                },
              ),
              rowBuilder: (context, user, index) {
                return [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: colors.primaryRed.withOpacity(0.2),
                        child: Text(
                          user.displayName.isNotEmpty
                              ? user.displayName[0].toUpperCase()
                              : (user.email.isNotEmpty ? user.email[0].toUpperCase() : 'U'),
                          style: TextStyle(color: colors.primaryRed, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              user.displayName.isNotEmpty ? user.displayName : (user.email.isNotEmpty ? user.email : 'Mobile User'),
                              style: AppTextStyles.bodyMedium.copyWith(color: colors.textPrimary, fontWeight: FontWeight.w600),
                            ),
                            if (user.displayName.isNotEmpty && user.email.isNotEmpty)
                              Text(user.email, style: AppTextStyles.bodySmall.copyWith(fontSize: 11, color: colors.textSecondary)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Text(
                    user.uid,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySmall.copyWith(fontFamily: 'monospace', color: colors.textSecondary),
                  ),
                  Text(
                    user.phoneNumber.isNotEmpty ? user.phoneNumber : '-',
                    style: AppTextStyles.bodySmall.copyWith(color: colors.textPrimary),
                  ),
                  Text(
                    user.createdAt != null ? DateFormat('dd MMM yyyy').format(user.createdAt!) : 'N/A',
                    style: AppTextStyles.bodySmall.copyWith(color: colors.textSecondary),
                  ),
                  Text(
                    user.lastSignInAt != null ? DateFormat('dd MMM yyyy').format(user.lastSignInAt!) : 'Never',
                    style: AppTextStyles.bodySmall.copyWith(color: colors.textSecondary),
                  ),
                  StatusBadge.fromStatus(user.disabled ? 'Disabled' : 'Active'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Switch(
                        value: !user.disabled,
                        onChanged: (enabled) => _toggleUserDisabled(user, !enabled),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete_outline, size: 18, color: colors.error),
                        onPressed: () => _deleteUser(user),
                        tooltip: 'Delete User',
                      ),
                    ],
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
