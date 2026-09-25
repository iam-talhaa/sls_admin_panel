import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_color_scheme.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/services/seed_data_service.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/status_badge.dart';
import '../data/repositories/dashboard_repository.dart';

class DashboardView extends ConsumerStatefulWidget {
  const DashboardView({super.key});

  @override
  ConsumerState<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends ConsumerState<DashboardView> {
  bool _isSeeding = false;

  Future<void> _handleSeedData() async {
    final colors = context.colors;
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Seed Sample Data',
      message:
          'This will populate Firestore with default Swiss Luxury Services sample catalog (jets, destinations, blogs, and home content) if empty. Continue?',
      confirmLabel: 'Seed Data',
    );

    if (confirmed && mounted) {
      setState(() {
        _isSeeding = true;
      });

      try {
        await ref.read(seedDataServiceProvider).seedInitialData();
        ref.invalidate(dashboardStatsProvider);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Sample catalog seeded successfully!'),
              backgroundColor: colors.success,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error seeding data: $e'),
              backgroundColor: colors.error,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isSeeding = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final statsAsync = ref.watch(dashboardStatsProvider);

    return statsAsync.when(
      loading: () => SizedBox(
        height: 400,
        child: Center(child: CircularProgressIndicator(color: colors.primaryRed)),
      ),
      error: (err, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              Text('Failed to load dashboard: $err', style: TextStyle(color: colors.error)),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => ref.invalidate(dashboardStatsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      data: (stats) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Welcome & Quick Actions Bar
            _buildWelcomeBar(colors),
            const SizedBox(height: 24),

            // Stat Cards Grid
            _buildStatCards(stats, colors),
            const SizedBox(height: 24),

            // Charts Section: 30-Day Line Chart + Donut Status Chart
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 960) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 3, child: _buildLineChartCard(stats, colors)),
                      const SizedBox(width: 20),
                      Expanded(flex: 2, child: _buildDonutChartCard(stats, colors)),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      _buildLineChartCard(stats, colors),
                      const SizedBox(height: 20),
                      _buildDonutChartCard(stats, colors),
                    ],
                  );
                }
              },
            ),
            const SizedBox(height: 24),

            // Recent Quote Requests Table
            _buildRecentQuotesSection(stats, colors),
          ],
        );
      },
    );
  }

  Widget _buildWelcomeBar(dynamic colors) {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 16,
        runSpacing: 12,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 650),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Welcome to SLS Luxury Fleet Management', style: AppTextStyles.headingMedium.copyWith(color: colors.textPrimary)),
                const SizedBox(height: 4),
                Text(
                  'Manage private jet charter content, concierge inquiries, and mobile app live configuration.',
                  style: AppTextStyles.subtitle.copyWith(color: colors.textSecondary),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: _isSeeding ? null : _handleSeedData,
            icon: _isSeeding
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.cloud_sync, size: 18),
            label: Text(_isSeeding ? 'Seeding...' : 'Seed Catalog Data'),
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.primaryRed,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCards(DashboardStats stats, dynamic colors) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 1200
            ? 6
            : (constraints.maxWidth > 800 ? 3 : 2);

        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: constraints.maxWidth > 1200 ? 1.6 : 1.5,
          children: [
            _buildStatCard(
              title: 'Fleet Jets',
              count: '${stats.totalJets}',
              icon: Icons.flight_outlined,
              color: colors.primaryRed,
              colors: colors,
              onTap: () => context.go('/fleet'),
            ),
            _buildStatCard(
              title: 'Destinations',
              count: '${stats.totalDestinations}',
              icon: Icons.location_on_outlined,
              color: colors.info,
              colors: colors,
              onTap: () => context.go('/destinations'),
            ),
            _buildStatCard(
              title: 'Published Blogs',
              count: '${stats.publishedBlogs}',
              icon: Icons.article_outlined,
              color: colors.success,
              colors: colors,
              onTap: () => context.go('/blog'),
            ),
            _buildStatCard(
              title: 'New Quotes (7d)',
              count: '${stats.newQuoteRequestsLast7Days}',
              icon: Icons.receipt_long_outlined,
              color: colors.warning,
              colors: colors,
              onTap: () => context.go('/quote-requests'),
            ),
            _buildStatCard(
              title: 'Total Inquiries',
              count: '${stats.totalQuoteRequests + stats.totalConciergeRequests}',
              icon: Icons.room_service_outlined,
              color: const Color(0xFFBF5AF2),
              colors: colors,
              onTap: () => context.go('/concierge-requests'),
            ),
            _buildStatCard(
              title: 'App Users',
              count: '${stats.totalUsers}',
              icon: Icons.people_outline,
              color: const Color(0xFF30D158),
              colors: colors,
              onTap: () => context.go('/users'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard({
    required String title,
    required String count,
    required IconData icon,
    required Color color,
    required dynamic colors,
    VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: colors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          hoverColor: colors.tableRowHover,
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: AppTextStyles.subtitle.copyWith(
                          color: colors.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(icon, size: 18, color: color),
                    ),
                  ],
                ),
                Text(
                  count,
                  style: AppTextStyles.headingLarge.copyWith(
                    color: colors.textPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLineChartCard(DashboardStats stats, dynamic colors) {
    final spots = <FlSpot>[];
    final sortedKeys = stats.quoteRequestsLast30Days.keys.toList()..sort();

    for (int i = 0; i < sortedKeys.length; i++) {
      final day = sortedKeys[i];
      final count = stats.quoteRequestsLast30Days[day] ?? 0;
      spots.add(FlSpot(i.toDouble(), count.toDouble()));
    }

    if (spots.isEmpty) {
      spots.add(const FlSpot(0, 0));
    }

    return Container(
      padding: const EdgeInsets.all(20),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Quote Inquiries (Last 30 Days)', style: AppTextStyles.headingSmall.copyWith(color: colors.textPrimary)),
              Text(
                'Total: ${stats.totalQuoteRequests}',
                style: AppTextStyles.bodySmall.copyWith(color: colors.primaryRed, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 220,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: colors.border,
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: AppTextStyles.bodySmall.copyWith(color: colors.textSecondary, fontSize: 10),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 24,
                      interval: 6,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx >= 0 && idx < sortedKeys.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 6.0),
                            child: Text(
                              DateFormat('dd MMM').format(sortedKeys[idx]),
                              style: AppTextStyles.bodySmall.copyWith(color: colors.textSecondary, fontSize: 10),
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    curveSmoothness: 0.35,
                    color: colors.primaryRed,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          colors.primaryRed.withOpacity(0.3),
                          colors.primaryRed.withOpacity(0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDonutChartCard(DashboardStats stats, dynamic colors) {
    final newCount = stats.quoteStatusDistribution['new'] ?? 0;
    final contactedCount = stats.quoteStatusDistribution['contacted'] ?? 0;
    final closedCount = stats.quoteStatusDistribution['closed'] ?? 0;
    final total = newCount + contactedCount + closedCount;

    return Container(
      padding: const EdgeInsets.all(20),
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
          Text('Quote Status Breakdown', style: AppTextStyles.headingSmall.copyWith(color: colors.textPrimary)),
          const SizedBox(height: 16),
          if (total == 0)
            SizedBox(
              height: 220,
              child: Center(
                child: Text('No quote requests yet', style: TextStyle(color: colors.textSecondary)),
              ),
            )
          else
            SizedBox(
              height: 220,
              child: Row(
                children: [
                  Expanded(
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 4,
                        centerSpaceRadius: 40,
                        sections: [
                          PieChartSectionData(
                            color: colors.warning,
                            value: newCount > 0 ? newCount.toDouble() : 0.001,
                            title: '',
                            radius: 35,
                          ),
                          PieChartSectionData(
                            color: colors.info,
                            value: contactedCount > 0 ? contactedCount.toDouble() : 0.001,
                            title: '',
                            radius: 35,
                          ),
                          PieChartSectionData(
                            color: colors.success,
                            value: closedCount > 0 ? closedCount.toDouble() : 0.001,
                            title: '',
                            radius: 35,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLegendItem('New', newCount, colors.warning, colors),
                      const SizedBox(height: 10),
                      _buildLegendItem('Contacted', contactedCount, colors.info, colors),
                      const SizedBox(height: 10),
                      _buildLegendItem('Closed', closedCount, colors.success, colors),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, int count, Color color, dynamic colors) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text('$label: ', style: AppTextStyles.bodySmall.copyWith(color: colors.textSecondary)),
        Text('$count', style: AppTextStyles.bodySmall.copyWith(color: colors.textPrimary, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildRecentQuotesSection(DashboardStats stats, dynamic colors) {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 8,
              children: [
                Text('Recent Quote Inquiries', style: AppTextStyles.headingSmall.copyWith(color: colors.textPrimary)),
                TextButton.icon(
                  onPressed: () => context.go('/quote-requests'),
                  icon: const Icon(Icons.arrow_forward, size: 16),
                  label: const Text('View All Quotes'),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: colors.border),
          if (stats.recentQuoteRequests.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32.0),
              child: EmptyState(
                title: 'No Quote Requests Yet',
                message: 'When users submit charter inquiries from the mobile app, they will appear here.',
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: stats.recentQuoteRequests.length,
              separatorBuilder: (_, __) => Divider(height: 1, color: colors.border),
              itemBuilder: (context, index) {
                final quote = stats.recentQuoteRequests[index];
                return ListTile(
                  hoverColor: colors.tableRowHover,
                  onTap: () => context.go('/quote-requests/${quote.id}'),
                  title: Text(
                    quote.firstName.isNotEmpty ? quote.firstName : quote.email,
                    style: AppTextStyles.bodyMedium.copyWith(color: colors.textPrimary, fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    quote.message.isNotEmpty ? quote.message : quote.phone,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySmall.copyWith(color: colors.textSecondary),
                  ),
                  trailing: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    children: [
                      StatusBadge.fromStatus(quote.status.value),
                      if (quote.createdAt != null)
                        Text(
                          DateFormat('dd MMM yyyy').format(quote.createdAt!),
                          style: AppTextStyles.bodySmall.copyWith(color: colors.textSecondary),
                        ),
                      Icon(Icons.chevron_right, size: 18, color: colors.textSecondary),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
