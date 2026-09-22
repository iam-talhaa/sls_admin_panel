import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../../features/admins/data/models/admin_user_model.dart';

class NavItem {
  final String title;
  final String route;
  final IconData icon;
  final bool superAdminOnly;
  final int? badgeCount;

  const NavItem({
    required this.title,
    required this.route,
    required this.icon,
    this.superAdminOnly = false,
    this.badgeCount,
  });
}

class SidebarNav extends StatelessWidget {
  final String currentRoute;
  final AdminUserModel? currentAdmin;
  final bool isCollapsed;
  final VoidCallback? onItemClick;

  const SidebarNav({
    super.key,
    required this.currentRoute,
    this.currentAdmin,
    this.isCollapsed = false,
    this.onItemClick,
  });

  static const List<NavItem> navItems = [
    NavItem(
      title: 'Dashboard',
      route: '/dashboard',
      icon: Icons.dashboard_outlined,
    ),
    NavItem(
      title: 'Fleet',
      route: '/fleet',
      icon: Icons.flight_outlined,
    ),
    NavItem(
      title: 'Destinations',
      route: '/destinations',
      icon: Icons.location_on_outlined,
    ),
    NavItem(
      title: 'Blog',
      route: '/blog',
      icon: Icons.article_outlined,
    ),
    NavItem(
      title: 'Quote Requests',
      route: '/quote-requests',
      icon: Icons.receipt_long_outlined,
    ),
    NavItem(
      title: 'Concierge Requests',
      route: '/concierge-requests',
      icon: Icons.room_service_outlined,
    ),
    NavItem(
      title: 'Users',
      route: '/users',
      icon: Icons.people_outline,
    ),
    NavItem(
      title: 'Home Content',
      route: '/home-content',
      icon: Icons.view_quilt_outlined,
    ),
    NavItem(
      title: 'Admins',
      route: '/admins',
      icon: Icons.admin_panel_settings_outlined,
      superAdminOnly: true,
    ),
    NavItem(
      title: 'Settings',
      route: '/settings',
      icon: Icons.settings_outlined,
      superAdminOnly: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isSuperAdmin = currentAdmin?.isSuperAdmin ?? false;

    return Container(
      width: isCollapsed ? 74 : 260,
      decoration: const BoxDecoration(
        color: AppColors.sidebarSurface,
        border: Border(
          right: BorderSide(color: AppColors.sidebarBorder, width: 1),
        ),
      ),
      child: Column(
        children: [
          // Logo Header
          Container(
            height: 76,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.sidebarBorder, width: 1)),
            ),
            child: isCollapsed
                ? Image.asset('assets/slslogo.png', width: 32, height: 32, fit: BoxFit.contain)
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/slslogo.png', width: 36, height: 36, fit: BoxFit.contain),
                      const SizedBox(width: 12),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(text: 'SWISS ', style: AppTextStyles.logoTitleRed.copyWith(fontSize: 14)),
                                TextSpan(text: 'LUXURY', style: AppTextStyles.logoTitleWhite.copyWith(fontSize: 14)),
                              ],
                            ),
                          ),
                          Text(
                            'ADMIN PORTAL',
                            style: AppTextStyles.logoSubtitle.copyWith(
                              fontSize: 9,
                              color: AppColors.sidebarTextMuted,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
          ),

          // Navigation items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
              children: navItems.where((item) {
                if (item.superAdminOnly && !isSuperAdmin) {
                  return false;
                }
                return true;
              }).map((item) {
                final isSelected = currentRoute == item.route ||
                    (item.route != '/dashboard' && currentRoute.startsWith(item.route));

                return Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    child: InkWell(
                      onTap: () {
                        context.go(item.route);
                        if (onItemClick != null) onItemClick!();
                      },
                      borderRadius: BorderRadius.circular(8),
                      hoverColor: AppColors.sidebarSurfaceElevatedHigher,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isCollapsed ? 0 : 14,
                          vertical: 11,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primaryRedLight : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: isSelected
                              ? Border.all(color: AppColors.primaryRed.withOpacity(0.5), width: 1)
                              : null,
                        ),
                        child: isCollapsed
                            ? Center(
                                child: Tooltip(
                                  message: item.title,
                                  child: Icon(
                                    item.icon,
                                    size: 20,
                                    color: isSelected ? AppColors.primaryRed : AppColors.sidebarTextMuted,
                                  ),
                                ),
                              )
                            : Row(
                                children: [
                                  Icon(
                                    item.icon,
                                    size: 20,
                                    color: isSelected ? AppColors.primaryRed : AppColors.sidebarTextMuted,
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Text(
                                      item.title,
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: isSelected ? AppColors.sidebarText : AppColors.sidebarTextMuted,
                                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                        fontSize: 13.5,
                                      ),
                                    ),
                                  ),
                                  if (item.badgeCount != null && item.badgeCount! > 0)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryRed,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        '${item.badgeCount}',
                                        style: const TextStyle(
                                          color: AppColors.sidebarText,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // User Profile Card at Footer
          if (!isCollapsed && currentAdmin != null)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.sidebarSurfaceElevated,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.sidebarBorder, width: 1),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.primaryRed.withOpacity(0.2),
                    child: Text(
                      currentAdmin!.email.isNotEmpty ? currentAdmin!.email[0].toUpperCase() : 'A',
                      style: const TextStyle(color: AppColors.primaryRed, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          currentAdmin!.email,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.sidebarText,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          currentAdmin!.role.label,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: currentAdmin!.isSuperAdmin ? AppColors.primaryRed : AppColors.info,
                            fontSize: 10,
                          ),
                        ),
                      ],
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
