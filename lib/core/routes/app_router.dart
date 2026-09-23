import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/admins/views/admins_view.dart';
import '../../features/auth/views/login_view.dart';
import '../../features/blog/views/blog_form_view.dart';
import '../../features/blog/views/blog_list_view.dart';
import '../../features/concierge/views/concierge_category_form_view.dart';
import '../../features/concierge/views/concierge_view.dart';
import '../../features/concierge_requests/views/concierge_request_detail_view.dart';
import '../../features/concierge_requests/views/concierge_requests_list_view.dart';
import '../../features/dashboard/views/dashboard_view.dart';
import '../../features/destinations/views/destination_form_view.dart';
import '../../features/destinations/views/destinations_list_view.dart';
import '../../features/fleet/views/fleet_list_view.dart';
import '../../features/fleet/views/jet_form_view.dart';
import '../../features/home_content/views/home_content_view.dart';
import '../../features/quote_requests/views/quote_request_detail_view.dart';
import '../../features/quote_requests/views/quote_requests_list_view.dart';
import '../../features/settings/views/settings_view.dart';
import '../../features/users/views/user_detail_view.dart';
import '../../features/users/views/users_list_view.dart';
import '../providers/current_admin_provider.dart';
import '../widgets/admin_scaffold.dart';

// Stable key for the shell navigator — provides a proper Overlay
// to all pages inside ShellRoute, fixing "No Overlay widget found"
// errors on TextField tap (Flutter Web + go_router known issue).
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  final currentAdminAsync = ref.watch(currentAdminProvider);

  return GoRouter(
    initialLocation: '/dashboard',
    refreshListenable: _RiverpodRefreshStream(ref),
    redirect: (context, state) {
      final isLoading = currentAdminAsync.isLoading;
      if (isLoading) return null;

      final adminUser = currentAdminAsync.asData?.value;
      final isLoggingIn = state.matchedLocation == '/login';

      if (adminUser == null) {
        return isLoggingIn ? null : '/login';
      }

      if (isLoggingIn) {
        return '/dashboard';
      }

      if (adminUser.isEditor) {
        if (state.matchedLocation.startsWith('/admins') || state.matchedLocation.startsWith('/settings')) {
          return '/dashboard';
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => const NoTransitionPage(child: LoginView()),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return AdminScaffold(
            currentRoute: state.matchedLocation,
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: '/dashboard',
            pageBuilder: (context, state) => const NoTransitionPage(child: DashboardView()),
          ),
          // Fleet
          GoRoute(
            path: '/fleet',
            pageBuilder: (context, state) => const NoTransitionPage(child: FleetListView()),
            routes: [
              GoRoute(
                path: 'new',
                pageBuilder: (context, state) => const NoTransitionPage(child: JetFormView(jetId: 'new')),
              ),
              GoRoute(
                path: ':id',
                pageBuilder: (context, state) {
                  final id = state.pathParameters['id'] ?? '';
                  return NoTransitionPage(child: JetFormView(jetId: id));
                },
              ),
            ],
          ),
          // Destinations
          GoRoute(
            path: '/destinations',
            pageBuilder: (context, state) => const NoTransitionPage(child: DestinationsListView()),
            routes: [
              GoRoute(
                path: 'new',
                pageBuilder: (context, state) => const NoTransitionPage(child: DestinationFormView(destinationId: 'new')),
              ),
              GoRoute(
                path: ':id',
                pageBuilder: (context, state) {
                  final id = state.pathParameters['id'] ?? '';
                  return NoTransitionPage(child: DestinationFormView(destinationId: id));
                },
              ),
            ],
          ),
          // Blog
          GoRoute(
            path: '/blog',
            pageBuilder: (context, state) => const NoTransitionPage(child: BlogListView()),
            routes: [
              GoRoute(
                path: 'new',
                pageBuilder: (context, state) => const NoTransitionPage(child: BlogFormView(blogId: 'new')),
              ),
              GoRoute(
                path: ':id',
                pageBuilder: (context, state) {
                  final id = state.pathParameters['id'] ?? '';
                  return NoTransitionPage(child: BlogFormView(blogId: id));
                },
              ),
            ],
          ),
          // Quote Requests
          GoRoute(
            path: '/quote-requests',
            pageBuilder: (context, state) => const NoTransitionPage(child: QuoteRequestsListView()),
            routes: [
              GoRoute(
                path: ':id',
                pageBuilder: (context, state) {
                  final id = state.pathParameters['id'] ?? '';
                  return NoTransitionPage(child: QuoteRequestDetailView(requestId: id));
                },
              ),
            ],
          ),
          // Concierge Requests
          GoRoute(
            path: '/concierge-requests',
            pageBuilder: (context, state) => const NoTransitionPage(child: ConciergeRequestsListView()),
            routes: [
              GoRoute(
                path: ':id',
                pageBuilder: (context, state) {
                  final id = state.pathParameters['id'] ?? '';
                  return NoTransitionPage(child: ConciergeRequestDetailView(requestId: id));
                },
              ),
            ],
          ),
          // Users
          GoRoute(
            path: '/users',
            pageBuilder: (context, state) => const NoTransitionPage(child: UsersListView()),
            routes: [
              GoRoute(
                path: ':id',
                pageBuilder: (context, state) {
                  final id = state.pathParameters['id'] ?? '';
                  return NoTransitionPage(child: UserDetailView(userId: id));
                },
              ),
            ],
          ),
          // Home Content
          GoRoute(
            path: '/home-content',
            pageBuilder: (context, state) => const NoTransitionPage(child: HomeContentView()),
          ),
          // Concierge Services
          GoRoute(
            path: '/concierge',
            pageBuilder: (context, state) => const NoTransitionPage(child: ConciergeView()),
            routes: [
              GoRoute(
                path: 'new',
                pageBuilder: (context, state) => const NoTransitionPage(child: ConciergeCategoryFormView(categoryId: 'new')),
              ),
              GoRoute(
                path: ':id',
                pageBuilder: (context, state) {
                  final id = state.pathParameters['id'] ?? '';
                  return NoTransitionPage(child: ConciergeCategoryFormView(categoryId: id));
                },
              ),
            ],
          ),
          // Admins
          GoRoute(
            path: '/admins',
            pageBuilder: (context, state) => const NoTransitionPage(child: AdminsView()),
          ),
          // Settings
          GoRoute(
            path: '/settings',
            pageBuilder: (context, state) => const NoTransitionPage(child: SettingsView()),
          ),
        ],
      ),
    ],
  );
});

class _RiverpodRefreshStream extends ChangeNotifier {
  _RiverpodRefreshStream(Ref ref) {
    ref.listen(currentAdminProvider, (_, __) => notifyListeners());
  }
}
