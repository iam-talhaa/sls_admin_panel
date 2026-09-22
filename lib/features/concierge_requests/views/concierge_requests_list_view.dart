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
import '../data/models/concierge_request_model.dart';
import '../data/repositories/concierge_requests_repository.dart';

class ConciergeRequestsListView extends ConsumerStatefulWidget {
  const ConciergeRequestsListView({super.key});

  @override
  ConsumerState<ConciergeRequestsListView> createState() => _ConciergeRequestsListViewState();
}

class _ConciergeRequestsListViewState extends ConsumerState<ConciergeRequestsListView> {
  String _searchQuery = '';
  String _selectedStatus = 'ALL';

  void _exportCsv(List<ConciergeRequestModel> requests) {
    final colors = context.colors;
    final rows = <List<dynamic>>[
      ['ID', 'Name', 'Email', 'Phone', 'Status', 'Request Details', 'Admin Notes', 'Date Submitted'],
      ...requests.map((r) => [
            r.id,
            r.name,
            r.email,
            r.phone,
            r.status.label,
            r.requestDetails,
            r.adminNotes,
            r.createdAt != null ? DateFormat('yyyy-MM-dd HH:mm').format(r.createdAt!) : '',
          ]),
    ];

    CsvExportService.exportToCsv(
      fileName: 'sls_concierge_requests_${DateFormat('yyyyMMdd').format(DateTime.now())}.csv',
      rows: rows,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Concierge requests exported to CSV successfully!'),
        backgroundColor: colors.success,
      ),
    );
  }

  Future<void> _deleteRequest(ConciergeRequestModel req) async {
    final colors = context.colors;
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Delete Concierge Request',
      message: 'Are you sure you want to delete this concierge request from ${req.name}?',
      confirmLabel: 'Delete',
      isDestructive: true,
    );

    if (confirmed && mounted) {
      await ref.read(conciergeRequestsRepositoryProvider).deleteConciergeRequest(req.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text('Concierge request deleted'), backgroundColor: colors.success),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final requestsAsync = ref.watch(conciergeRequestsListStreamProvider);

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
                Text('VIP Concierge Requests', style: AppTextStyles.headingMedium.copyWith(color: colors.textPrimary)),
                const SizedBox(height: 4),
                Text('Review luxury ground handling, alpine helicopter transfers, and custom concierge requests.', style: AppTextStyles.subtitle.copyWith(color: colors.textSecondary)),
              ],
            ),
            requestsAsync.when(
              data: (requests) => ElevatedButton.icon(
                onPressed: requests.isEmpty ? null : () => _exportCsv(requests),
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
          ],
        ),
        const SizedBox(height: 24),

        // Data Table
        requestsAsync.when(
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
            child: Text('Error loading concierge requests: $err', style: TextStyle(color: colors.error)),
          ),
          data: (requests) {
            final filtered = requests.where((r) {
              final matchesQuery = _searchQuery.isEmpty ||
                  r.name.toLowerCase().contains(_searchQuery) ||
                  r.email.toLowerCase().contains(_searchQuery) ||
                  r.phone.toLowerCase().contains(_searchQuery) ||
                  r.requestDetails.toLowerCase().contains(_searchQuery);

              final matchesStatus = _selectedStatus == 'ALL' || r.status.value == _selectedStatus;

              return matchesQuery && matchesStatus;
            }).toList();

            return DataTableWidget<ConciergeRequestModel>(
              columns: const [
                TableColumnConfig(title: 'GUEST NAME', flex: 2),
                TableColumnConfig(title: 'CONTACT INFO', flex: 3),
                TableColumnConfig(title: 'CONCIERGE REQUIREMENTS', flex: 4),
                TableColumnConfig(title: 'DATE', width: 120),
                TableColumnConfig(title: 'STATUS', width: 120),
                TableColumnConfig(title: 'ACTIONS', width: 80, alignment: Alignment.centerRight),
              ],
              items: filtered,
              onRowTap: (req) => context.go('/concierge-requests/${req.id}'),
              onSearch: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
              searchHint: 'Search concierge requests...',
              filterWidget: DropdownButton<String>(
                value: _selectedStatus,
                dropdownColor: colors.surfaceElevated,
                style: AppTextStyles.bodyMedium.copyWith(color: colors.textPrimary),
                underline: const SizedBox(),
                items: const [
                  DropdownMenuItem(value: 'ALL', child: Text('All Statuses')),
                  DropdownMenuItem(value: 'new', child: Text('New')),
                  DropdownMenuItem(value: 'in_progress', child: Text('In Progress')),
                  DropdownMenuItem(value: 'resolved', child: Text('Resolved')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _selectedStatus = val);
                },
              ),
              rowBuilder: (context, req, index) {
                return [
                  Text(
                    req.name.isNotEmpty ? req.name : 'VIP Guest',
                    style: AppTextStyles.bodyMedium.copyWith(color: colors.textPrimary, fontWeight: FontWeight.w600),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(req.email, style: AppTextStyles.bodySmall.copyWith(color: colors.textPrimary)),
                      if (req.phone.isNotEmpty)
                        Text(req.phone, style: AppTextStyles.bodySmall.copyWith(color: colors.textSecondary, fontSize: 11)),
                    ],
                  ),
                  Text(
                    req.requestDetails,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySmall.copyWith(color: colors.textSecondary),
                  ),
                  Text(
                    req.createdAt != null ? DateFormat('dd MMM yyyy').format(req.createdAt!) : '-',
                    style: AppTextStyles.bodySmall.copyWith(color: colors.textSecondary),
                  ),
                  StatusBadge.fromStatus(req.status.value),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: Icon(Icons.delete_outline, size: 18, color: colors.error),
                        onPressed: () => _deleteRequest(req),
                        tooltip: 'Delete',
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
