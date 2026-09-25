import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../blog/data/models/blog_admin_model.dart';
import '../../../blog/data/repositories/blog_repository.dart';
import '../../../concierge_requests/data/models/concierge_request_model.dart';
import '../../../concierge_requests/data/repositories/concierge_requests_repository.dart';
import '../../../destinations/data/models/destination_admin_model.dart';
import '../../../destinations/data/repositories/destinations_repository.dart';
import '../../../fleet/data/models/jet_admin_model.dart';
import '../../../fleet/data/repositories/fleet_repository.dart';
import '../../../quote_requests/data/models/quote_request_model.dart';
import '../../../quote_requests/data/repositories/quote_requests_repository.dart';
import '../../../users/data/models/user_admin_model.dart';
import '../../../users/data/repositories/users_repository.dart';

class DashboardStats {
  final int totalJets;
  final int totalDestinations;
  final int publishedBlogs;
  final int newQuoteRequestsLast7Days;
  final int totalQuoteRequests;
  final int totalConciergeRequests;
  final int totalUsers;
  final Map<String, int> quoteStatusDistribution; // 'new', 'contacted', 'closed'
  final Map<DateTime, int> quoteRequestsLast30Days;
  final List<QuoteRequestModel> recentQuoteRequests;

  const DashboardStats({
    this.totalJets = 0,
    this.totalDestinations = 0,
    this.publishedBlogs = 0,
    this.newQuoteRequestsLast7Days = 0,
    this.totalQuoteRequests = 0,
    this.totalConciergeRequests = 0,
    this.totalUsers = 0,
    this.quoteStatusDistribution = const {'new': 0, 'contacted': 0, 'closed': 0},
    this.quoteRequestsLast30Days = const {},
    this.recentQuoteRequests = const [],
  });
}

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepository(
    ref.watch(fleetRepositoryProvider),
    ref.watch(destinationsRepositoryProvider),
    ref.watch(blogRepositoryProvider),
    ref.watch(quoteRequestsRepositoryProvider),
    ref.watch(conciergeRequestsRepositoryProvider),
    ref.watch(usersRepositoryProvider),
  );
});

final dashboardStatsProvider = Provider<AsyncValue<DashboardStats>>((ref) {
  final fleetRepo = ref.watch(fleetRepositoryProvider);
  final destsRepo = ref.watch(destinationsRepositoryProvider);
  final blogRepo = ref.watch(blogRepositoryProvider);
  final quotesRepo = ref.watch(quoteRequestsRepositoryProvider);
  final conciergeRepo = ref.watch(conciergeRequestsRepositoryProvider);
  final usersRepo = ref.watch(usersRepositoryProvider);

  // Watch real-time stream providers across the application
  final jetsAsync = ref.watch(fleetListStreamProvider);
  final destsAsync = ref.watch(destinationsListStreamProvider);
  final blogsAsync = ref.watch(blogListStreamProvider);
  final quotesAsync = ref.watch(quoteRequestsListStreamProvider);
  final conciergeAsync = ref.watch(conciergeRequestsListStreamProvider);
  final usersAsync = ref.watch(usersListStreamProvider);

  final jets = jetsAsync.valueOrNull ?? fleetRepo.currentJets;
  final dests = destsAsync.valueOrNull ?? destsRepo.currentDestinations;
  final blogs = blogsAsync.valueOrNull ?? blogRepo.currentBlogs;
  final quotes = quotesAsync.valueOrNull ?? quotesRepo.currentQuotes;
  final concierge = conciergeAsync.valueOrNull ?? conciergeRepo.currentRequests;
  final users = usersAsync.valueOrNull ?? usersRepo.currentUsers;

  final stats = ref.watch(dashboardRepositoryProvider).computeStats(
    jets: jets,
    dests: dests,
    blogs: blogs,
    quotes: quotes,
    concierge: concierge,
    users: users,
  );

  return AsyncData(stats);
});

class DashboardRepository {
  final FleetRepository _fleetRepo;
  final DestinationsRepository _destsRepo;
  final BlogRepository _blogRepo;
  final QuoteRequestsRepository _quotesRepo;
  final ConciergeRequestsRepository _conciergeRepo;
  final UsersRepository _usersRepo;

  DashboardRepository(
    this._fleetRepo,
    this._destsRepo,
    this._blogRepo,
    this._quotesRepo,
    this._conciergeRepo,
    this._usersRepo,
  );

  DashboardStats computeStats({
    required List<JetAdminModel> jets,
    required List<DestinationAdminModel> dests,
    required List<BlogAdminModel> blogs,
    required List<QuoteRequestModel> quotes,
    required List<ConciergeRequestModel> concierge,
    required List<UserAdminModel> users,
  }) {
    final statusMap = <String, int>{'new': 0, 'contacted': 0, 'closed': 0};
    final dailyQuotesMap = <DateTime, int>{};
    final recentQuotes = <QuoteRequestModel>[];

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final sevenDaysAgo = now.subtract(const Duration(days: 7));
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));

    // Initialize 30 days slots
    for (int i = 29; i >= 0; i--) {
      final day = today.subtract(Duration(days: i));
      dailyQuotesMap[day] = 0;
    }

    int newQuotes7Days = 0;

    // Sort quotes descending by createdAt
    final sortedQuotes = List<QuoteRequestModel>.from(quotes)
      ..sort((a, b) => (b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0))
          .compareTo(a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0)));

    for (int i = 0; i < sortedQuotes.length; i++) {
      final quote = sortedQuotes[i];

      if (i < 5) {
        recentQuotes.add(quote);
      }

      final s = quote.status.value;
      statusMap[s] = (statusMap[s] ?? 0) + 1;

      if (quote.createdAt != null) {
        if (quote.createdAt!.isAfter(sevenDaysAgo)) {
          newQuotes7Days++;
        }

        if (quote.createdAt!.isAfter(thirtyDaysAgo)) {
          final quoteDay = DateTime(
            quote.createdAt!.year,
            quote.createdAt!.month,
            quote.createdAt!.day,
          );
          if (dailyQuotesMap.containsKey(quoteDay)) {
            dailyQuotesMap[quoteDay] = (dailyQuotesMap[quoteDay] ?? 0) + 1;
          }
        }
      } else if (quote.status == QuoteRequestStatus.isNew) {
        newQuotes7Days++;
      }
    }

    return DashboardStats(
      totalJets: jets.length,
      totalDestinations: dests.length,
      publishedBlogs: blogs.where((b) => b.isPublished).length,
      newQuoteRequestsLast7Days: newQuotes7Days,
      totalQuoteRequests: quotes.length,
      totalConciergeRequests: concierge.length,
      totalUsers: users.length,
      quoteStatusDistribution: statusMap,
      quoteRequestsLast30Days: dailyQuotesMap,
      recentQuoteRequests: recentQuotes,
    );
  }

  Future<DashboardStats> fetchDashboardStats() async {
    final jets = _fleetRepo.currentJets;
    final dests = _destsRepo.currentDestinations;
    final blogs = _blogRepo.currentBlogs;
    final quotes = _quotesRepo.currentQuotes;
    final concierge = _conciergeRepo.currentRequests;
    final users = await _usersRepo.listUsers();

    return computeStats(
      jets: jets,
      dests: dests,
      blogs: blogs,
      quotes: quotes,
      concierge: concierge,
      users: users,
    );
  }
}

