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
import 'users_list_view.dart';

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
    final users = await ref.read(usersRepositoryProvider).listUsers();
    try {
      _user = users.firstWhere((u) => u.uid == widget.userId);
    } catch (_) {}
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _toggleDisabled() async {
    if (_user == null) return;
    final colors = context.colors;
    final newDisabled = !_user!.disabled;

    final confirmed = await ConfirmDialog.show(
      context,
      title: newDisabled ? 'Disable User' : 'Enable User',
      message: newDisabled
          ? 'Are you sure you want to disable ${_user!.email}?'
          : 'Are you sure you want to enable ${_user!.email}?',
      confirmLabel: newDisabled ? 'Disable' : 'Enable',
      isDestructive: newDisabled,
    );

    if (confirmed && mounted) {
      await ref.read(usersRepositoryProvider).setUserDisabled(_user!.uid, newDisabled);
      ref.invalidate(usersListFutureProvider);
      setState(() {
        _user = _user!.copyWith(disabled: newDisabled);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('User account ${newDisabled ? 'disabled' : 'enabled'}'),
            backgroundColor: colors.success,
          ),
        );
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

    if (_user == null) {
      return Center(
        child: Column(
          children: [
            Text('User not found.', style: AppTextStyles.headingSmall.copyWith(color: colors.textPrimary)),
            const SizedBox(height: 12),
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back, color: colors.textPrimary),
                  onPressed: () => context.go('/users'),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('User Profile & Account Info', style: AppTextStyles.headingMedium.copyWith(color: colors.textPrimary)),
                    Text('UID: ${_user!.uid}', style: AppTextStyles.subtitle.copyWith(color: colors.textSecondary)),
                  ],
                ),
              ],
            ),
            Row(
              children: [
                StatusBadge.fromStatus(_user!.disabled ? 'Disabled' : 'Active'),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _toggleDisabled,
                  icon: Icon(_user!.disabled ? Icons.check_circle_outline : Icons.block, size: 16),
                  label: Text(_user!.disabled ? 'Enable Account' : 'Disable Account'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _user!.disabled ? colors.success : colors.error,
                    foregroundColor: Colors.white,
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
              Text('Account Information', style: AppTextStyles.headingSmall.copyWith(color: colors.textPrimary)),
              const SizedBox(height: 20),
              _buildRow('Email Address', _user!.email, colors),
              Divider(height: 24, color: colors.border),
              _buildRow('Display Name', _user!.displayName.isNotEmpty ? _user!.displayName : 'Not set', colors),
              Divider(height: 24, color: colors.border),
              _buildRow('Phone Number', _user!.phoneNumber.isNotEmpty ? _user!.phoneNumber : 'Not set', colors),
              Divider(height: 24, color: colors.border),
              _buildRow('Registration Date', _user!.createdAt != null ? DateFormat('EEEE, dd MMMM yyyy • HH:mm').format(_user!.createdAt!) : 'N/A', colors),
              Divider(height: 24, color: colors.border),
              _buildRow('Last Sign-In Date', _user!.lastSignInAt != null ? DateFormat('EEEE, dd MMMM yyyy • HH:mm').format(_user!.lastSignInAt!) : 'Never', colors),
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
        Text(label, style: AppTextStyles.subtitle.copyWith(color: colors.textSecondary)),
        Text(value, style: AppTextStyles.bodyMedium.copyWith(color: colors.textPrimary, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
