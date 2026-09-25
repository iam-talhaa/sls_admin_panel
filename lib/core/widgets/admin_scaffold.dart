import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../providers/current_admin_provider.dart';
import '../theme/app_color_scheme.dart';
import '../../features/auth/data/repositories/admin_auth_repository.dart';
import 'confirm_dialog.dart';
import 'sidebar_nav.dart';
import 'theme_toggle_button.dart';

class AdminScaffold extends ConsumerStatefulWidget {
  final Widget child;
  final String currentRoute;

  const AdminScaffold({
    super.key,
    required this.child,
    required this.currentRoute,
  });

  @override
  ConsumerState<AdminScaffold> createState() => _AdminScaffoldState();
}

class _AdminScaffoldState extends ConsumerState<AdminScaffold> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String _getPageTitle(String route) {
    if (route.startsWith('/fleet')) {
      if (route.contains('/new')) return 'Fleet / Add Jet';
      if (route.split('/').length > 2) return 'Fleet / Edit Jet';
      return 'Fleet Management';
    }
    if (route.startsWith('/destinations')) {
      if (route.contains('/new')) return 'Destinations / Add Destination';
      if (route.split('/').length > 2) return 'Destinations / Edit Destination';
      return 'Destinations Management';
    }
    if (route.startsWith('/blog')) {
      if (route.contains('/new')) return 'Blog / New Post';
      if (route.split('/').length > 2) return 'Blog / Edit Post';
      return 'Blog Posts';
    }
    if (route.startsWith('/quote-requests')) {
      if (route.split('/').length > 2) return 'Quote Request / Details';
      return 'Quote Requests';
    }
    if (route.startsWith('/concierge-requests')) {
      if (route.split('/').length > 2) return 'Concierge Request / Details';
      return 'Concierge Requests';
    }
    if (route.startsWith('/users')) {
      if (route.split('/').length > 2) return 'User / Details';
      return 'User Management';
    }
    if (route.startsWith('/home-content')) return 'Home Page Content';
    if (route.startsWith('/admins')) return 'Admin Team & Roles';
    if (route.startsWith('/settings')) return 'System Settings';
    return 'Dashboard Overview';
  }

  Future<void> _logout() async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Sign Out',
      message: 'Are you sure you want to sign out from the SLS Admin Portal?',
      confirmLabel: 'Sign Out',
      isDestructive: false,
    );

    if (confirmed && mounted) {
      await ref.read(adminAuthRepositoryProvider).signOut();
      if (mounted) {
        context.go('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1100;
    final isTablet = screenWidth >= 768 && screenWidth < 1100;
    final isMobile = screenWidth < 768;

    final adminAsync = ref.watch(currentAdminProvider);
    final adminUser = adminAsync.asData?.value;
    final colors = context.colors;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: colors.background,
      drawer: isMobile
          ? Drawer(
              backgroundColor: AppColors.sidebarBackground,
              child: SidebarNav(
                currentRoute: widget.currentRoute,
                currentAdmin: adminUser,
                isCollapsed: false,
                onItemClick: () => _scaffoldKey.currentState?.closeDrawer(),
              ),
            )
          : null,
      body: Row(
        children: [
          // Sidebar for Desktop & Tablet (stays dark luxury brand anchor in both modes)
          if (isDesktop)
            SidebarNav(
              currentRoute: widget.currentRoute,
              currentAdmin: adminUser,
              isCollapsed: false,
            )
          else if (isTablet)
            SidebarNav(
              currentRoute: widget.currentRoute,
              currentAdmin: adminUser,
              isCollapsed: true,
            ),

          // Main Page Area
          Expanded(
            child: Column(
              children: [
                // Top Header Bar
                Container(
                  height: 76,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    border: Border(
                      bottom: BorderSide(color: colors.border, width: 1),
                    ),
                  ),
                  child: Row(
                    children: [
                      if (isMobile) ...[
                        IconButton(
                          icon: Icon(Icons.menu, color: colors.textPrimary),
                          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                        ),
                        const SizedBox(width: 12),
                      ],
                      // Title & Breadcrumb
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getPageTitle(widget.currentRoute),
                              style: AppTextStyles.headingMedium.copyWith(
                                fontSize: 17,
                                color: colors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Swiss Luxury Services • Private Jet & Concierge Admin',
                              style: AppTextStyles.bodySmall.copyWith(
                                fontSize: 11,
                                color: colors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Right Header Actions
                      Row(
                        children: [
                          if (adminUser != null) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: adminUser.isSuperAdmin ? colors.primaryRedLight : colors.infoBg,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: adminUser.isSuperAdmin
                                      ? colors.primaryRed.withOpacity(0.5)
                                      : colors.info.withOpacity(0.5),
                                ),
                              ),
                              child: Text(
                                adminUser.role.label,
                                style: AppTextStyles.badgeText.copyWith(
                                  color: adminUser.isSuperAdmin ? colors.primaryRed : colors.info,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          const ThemeToggleButton(),
                          const SizedBox(width: 4),
                          IconButton(
                            icon: Icon(Icons.logout_rounded, color: colors.textSecondary, size: 20),
                            onPressed: _logout,
                            tooltip: 'Sign Out',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Page Content Area with smooth scrolling
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: widget.child,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
