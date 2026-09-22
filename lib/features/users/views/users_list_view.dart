import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_color_scheme.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/data_table_widget.dart';
import '../../../core/widgets/status_badge.dart';
import '../data/models/user_admin_model.dart';
import '../data/repositories/users_repository.dart';

final usersListFutureProvider = FutureProvider<List<UserAdminModel>>((ref) async {
  return ref.watch(usersRepositoryProvider).listUsers();
});

class UsersListView extends ConsumerStatefulWidget {
  const UsersListView({super.key});

  @override
  ConsumerState<UsersListView> createState() => _UsersListViewState();
}

class _UsersListViewState extends ConsumerState<UsersListView> {
  String _searchQuery = '';

  Future<void> _toggleUserDisabled(UserAdminModel user, bool newDisabled) async {
    final colors = context.colors;
    final confirmed = await ConfirmDialog.show(
      context,
      title: newDisabled ? 'Disable User Account' : 'Enable User Account',
      message: newDisabled
          ? 'Are you sure you want to disable ${user.email}? They will no longer be able to sign in.'
          : 'Are you sure you want to enable ${user.email}?',
      confirmLabel: newDisabled ? 'Disable Account' : 'Enable Account',
      isDestructive: newDisabled,
    );

    if (confirmed && mounted) {
      try {
        await ref.read(usersRepositoryProvider).setUserDisabled(user.uid, newDisabled);
        ref.invalidate(usersListFutureProvider);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('User account ${newDisabled ? 'disabled' : 'enabled'} successfully'),
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

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final usersAsync = ref.watch(usersListFutureProvider);

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
                Text('Manage mobile app client accounts and authentication status.', style: AppTextStyles.subtitle.copyWith(color: colors.textSecondary)),
              ],
            ),
            IconButton(
              icon: Icon(Icons.refresh, color: colors.textPrimary),
              onPressed: () => ref.invalidate(usersListFutureProvider),
              tooltip: 'Refresh Users',
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Info Banner about Cloud Functions
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: colors.infoBg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: colors.info.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: colors.info, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'User management connects to the listUsers Cloud Function to query Firebase Auth records securely.',
                  style: AppTextStyles.bodySmall.copyWith(color: colors.textPrimary),
                ),
              ),
            ],
          ),
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
              return _searchQuery.isEmpty ||
                  u.email.toLowerCase().contains(_searchQuery) ||
                  u.displayName.toLowerCase().contains(_searchQuery) ||
                  u.uid.toLowerCase().contains(_searchQuery);
            }).toList();

            return DataTableWidget<UserAdminModel>(
              columns: const [
                TableColumnConfig(title: 'USER', flex: 3),
                TableColumnConfig(title: 'UID', flex: 2),
                TableColumnConfig(title: 'REGISTERED', width: 140),
                TableColumnConfig(title: 'LAST SIGN IN', width: 140),
                TableColumnConfig(title: 'STATUS', width: 120),
                TableColumnConfig(title: 'ACTIONS', width: 90, alignment: Alignment.centerRight),
              ],
              items: filtered,
              onRowTap: (user) => context.go('/users/${user.uid}'),
              onSearch: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
              searchHint: 'Search users by name or email...',
              emptyTitle: 'No users found',
              emptyMessage: 'No user records found in Firebase Auth / Firestore users collection.',
              rowBuilder: (context, user, index) {
                return [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: colors.primaryRed.withOpacity(0.2),
                        child: Text(
                          user.email.isNotEmpty ? user.email[0].toUpperCase() : 'U',
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
                              user.displayName.isNotEmpty ? user.displayName : user.email,
                              style: AppTextStyles.bodyMedium.copyWith(color: colors.textPrimary, fontWeight: FontWeight.w600),
                            ),
                            if (user.displayName.isNotEmpty)
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
                    user.createdAt != null ? DateFormat('dd MMM yyyy').format(user.createdAt!) : 'N/A',
                    style: AppTextStyles.bodySmall.copyWith(color: colors.textPrimary),
                  ),
                  Text(
                    user.lastSignInAt != null ? DateFormat('dd MMM yyyy').format(user.lastSignInAt!) : 'Never',
                    style: AppTextStyles.bodySmall.copyWith(color: colors.textSecondary),
                  ),
                  StatusBadge.fromStatus(user.disabled ? 'Disabled' : 'Active'),
                  Switch(
                    value: !user.disabled,
                    onChanged: (enabled) => _toggleUserDisabled(user, !enabled),
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
