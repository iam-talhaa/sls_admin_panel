import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_color_scheme.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/status_badge.dart';
import '../data/models/user_admin_model.dart';
import '../data/repositories/users_repository.dart';

class UserDetailView extends ConsumerStatefulWidget {
  final String userId;

  const UserDetailView({super.key, required this.userId});

  @override
  ConsumerState<UserDetailView> createState() => _UserDetailViewState();
}

class _UserDetailViewState extends ConsumerState<UserDetailView> {
  UserAdminModel? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await ref
        .read(usersRepositoryProvider)
        .getUserById(widget.userId);
    if (mounted) {
      setState(() {
        _user = user;
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleDisabled() async {
    if (_user == null) return;
    final colors = context.colors;
    final newDisabled = !_user!.disabled;

    final confirmed = await ConfirmDialog.show(
      context,
      title: newDisabled ? 'Disable User' : 'Enable User',
      message: newDisabled
          ? 'Are you sure you want to disable ${_user!.email.isNotEmpty ? _user!.email : _user!.displayName}?'
          : 'Are you sure you want to enable ${_user!.email.isNotEmpty ? _user!.email : _user!.displayName}?',
      confirmLabel: newDisabled ? 'Disable' : 'Enable',
      isDestructive: newDisabled,
    );

    if (confirmed && mounted) {
      await ref
          .read(usersRepositoryProvider)
          .setUserDisabled(_user!.uid, newDisabled);
      ref.invalidate(usersListFutureProvider);
      ref.invalidate(usersListStreamProvider);
      setState(() {
        _user = _user!.copyWith(disabled: newDisabled);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'User account ${newDisabled ? 'disabled' : 'enabled'} in Firebase',
            ),
            backgroundColor: colors.success,
          ),
        );
      }
    }
  }

  Future<void> _deleteUser() async {
    if (_user == null) return;
    final colors = context.colors;

    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Delete User Account',
      message:
          'Are you sure you want to permanently delete user ${_user!.email.isNotEmpty ? _user!.email : _user!.displayName} (${_user!.uid}) from Firebase?',
      confirmLabel: 'Delete Permanently',
      isDestructive: true,
    );

    if (confirmed && mounted) {
      await ref.read(usersRepositoryProvider).deleteUser(_user!.uid);
      ref.invalidate(usersListFutureProvider);
      ref.invalidate(usersListStreamProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('User account deleted from Firebase'),
            backgroundColor: colors.success,
          ),
        );
        context.go('/users');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    if (_isLoading) {
      return SizedBox(
        height: 400,
        child: Center(
          child: CircularProgressIndicator(color: colors.primaryRed),
        ),
      );
    }

    if (_user == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            Icon(Icons.person_off_outlined, size: 64, color: colors.textMuted),
            const SizedBox(height: 16),
            Text(
              'User not found.',
              style: AppTextStyles.headingSmall.copyWith(
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/users'),
              child: const Text('Back to Users'),
            ),
          ],
        ),
      );
    }

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
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back, color: colors.textPrimary),
                  onPressed: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/users');
                    }
                  },
                  tooltip: 'Back to Users',
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _user!.displayName.isNotEmpty
                          ? _user!.displayName
                          : 'Mobile App User',
                      style: AppTextStyles.headingMedium.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                    Text(
                      'UID: ${_user!.uid}',
                      style: AppTextStyles.subtitle.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                StatusBadge.fromStatus(_user!.disabled ? 'Disabled' : 'Active'),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _toggleDisabled,
                  icon: Icon(
                    _user!.disabled ? Icons.check_circle_outline : Icons.block,
                    size: 16,
                  ),
                  label: Text(
                    _user!.disabled ? 'Enable Account' : 'Disable Account',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _user!.disabled
                        ? colors.success
                        : colors.warning,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: _deleteUser,
                  icon: const Icon(Icons.delete_outline, size: 16),
                  label: const Text('Delete'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.error,
                    side: BorderSide(
                      color: colors.error.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 24),

        // User Details Card
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
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: colors.primaryRed.withValues(alpha: 0.15),
                    backgroundImage: _user!.photoUrl.isNotEmpty
                        ? NetworkImage(_user!.photoUrl)
                        : null,
                    child: _user!.photoUrl.isEmpty
                        ? Text(
                            _user!.displayName.isNotEmpty
                                ? _user!.displayName[0].toUpperCase()
                                : (_user!.email.isNotEmpty
                                      ? _user!.email[0].toUpperCase()
                                      : 'U'),
                            style: TextStyle(
                              color: colors.primaryRed,
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _user!.displayName.isNotEmpty
                              ? _user!.displayName
                              : 'No Name Provided',
                          style: AppTextStyles.headingSmall.copyWith(
                            color: colors.textPrimary,
                          ),
                        ),
                        Text(
                          _user!.email,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: colors.surfaceElevatedHigher,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: colors.border),
                    ),
                    child: Text(
                      'Role: ${_user!.role.toUpperCase()}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Divider(height: 1, color: colors.border),
              const SizedBox(height: 20),
              Text(
                'Account Details',
                style: AppTextStyles.headingSmall.copyWith(
                  color: colors.textPrimary,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              _buildRow('User UID', _user!.uid, colors),
              Divider(height: 24, color: colors.border),
              _buildRow(
                'Email Address',
                _user!.email.isNotEmpty ? _user!.email : 'Not provided',
                colors,
              ),
              Divider(height: 24, color: colors.border),
              _buildRow(
                'Display Name',
                _user!.displayName.isNotEmpty ? _user!.displayName : 'Not set',
                colors,
              ),
              Divider(height: 24, color: colors.border),
              _buildRow(
                'Phone Number',
                _user!.phoneNumber.isNotEmpty ? _user!.phoneNumber : 'Not set',
                colors,
              ),
              Divider(height: 24, color: colors.border),
              _buildRow(
                'Account Status',
                _user!.disabled ? 'Disabled / Suspended' : 'Active',
                colors,
              ),
              Divider(height: 24, color: colors.border),
              _buildRow(
                'Registration Date',
                _user!.createdAt != null
                    ? DateFormat('EEEE, dd MMMM yyyy • HH:mm')
                          .format(_user!.createdAt!)
                    : 'N/A',
                colors,
              ),
              Divider(height: 24, color: colors.border),
              _buildRow(
                'Last Sign-In Date',
                _user!.lastSignInAt != null
                    ? DateFormat('EEEE, dd MMMM yyyy • HH:mm')
                          .format(_user!.lastSignInAt!)
                    : 'Never',
                colors,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRow(String label, String value, dynamic colors) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.subtitle.copyWith(color: colors.textSecondary),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: AppTextStyles.bodyMedium.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
