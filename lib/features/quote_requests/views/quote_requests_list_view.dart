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
import '../data/models/quote_request_model.dart';
import '../data/repositories/quote_requests_repository.dart';

class QuoteRequestsListView extends ConsumerStatefulWidget {
  const QuoteRequestsListView({super.key});

  @override
  ConsumerState<QuoteRequestsListView> createState() => _QuoteRequestsListViewState();
}

class _QuoteRequestsListViewState extends ConsumerState<QuoteRequestsListView> {
  String _searchQuery = '';
  String _selectedStatus = 'ALL';
  DateTimeRange? _selectedDateRange;

  void _exportCsv(List<QuoteRequestModel> quotes) {
    final colors = context.colors;
    final rows = <List<dynamic>>[
      ['ID', 'Name', 'Email', 'Phone', 'Status', 'Message', 'Admin Notes', 'Date Submitted'],
      ...quotes.map((q) => [
            q.id,
            q.firstName,
            q.email,
            q.phone,
            q.status.label,
            q.message,
            q.adminNotes,
            q.createdAt != null ? DateFormat('yyyy-MM-dd HH:mm').format(q.createdAt!) : '',
          ]),
    ];

    CsvExportService.exportToCsv(
      fileName: 'sls_quote_requests_${DateFormat('yyyyMMdd').format(DateTime.now())}.csv',
      rows: rows,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Quote requests exported to CSV successfully!'),
        backgroundColor: colors.success,
      ),
    );
  }

  Future<void> _deleteQuote(QuoteRequestModel quote) async {
    final colors = context.colors;
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Delete Quote Request',
      message: 'Are you sure you want to delete this quote request from ${quote.firstName.isNotEmpty ? quote.firstName : quote.email}?',
      confirmLabel: 'Delete',
      isDestructive: true,
    );

    if (confirmed && mounted) {
      await ref.read(quoteRequestsRepositoryProvider).deleteQuoteRequest(quote.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text('Quote request deleted'), backgroundColor: colors.success),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final quotesAsync = ref.watch(quoteRequestsListStreamProvider);

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
                Text('Charter Quote Inquiries', style: AppTextStyles.headingMedium.copyWith(color: colors.textPrimary)),
                const SizedBox(height: 4),
                Text('Review incoming flight quote inquiries submitted by mobile users.', style: AppTextStyles.subtitle.copyWith(color: colors.textSecondary)),
              ],
            ),
            quotesAsync.when(
              data: (quotes) => ElevatedButton.icon(
                onPressed: quotes.isEmpty ? null : () => _exportCsv(quotes),
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
        quotesAsync.when(
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
            child: Text('Error loading quotes: $err', style: TextStyle(color: colors.error)),
          ),
          data: (quotes) {
            final filtered = quotes.where((q) {
              final matchesQuery = _searchQuery.isEmpty ||
                  q.firstName.toLowerCase().contains(_searchQuery) ||
                  q.email.toLowerCase().contains(_searchQuery) ||
                  q.phone.toLowerCase().contains(_searchQuery) ||
                  q.message.toLowerCase().contains(_searchQuery);

              final matchesStatus = _selectedStatus == 'ALL' || q.status.value == _selectedStatus;

              bool matchesDate = true;
              if (_selectedDateRange != null && q.createdAt != null) {
                matchesDate = q.createdAt!.isAfter(_selectedDateRange!.start.subtract(const Duration(days: 1))) &&
                    q.createdAt!.isBefore(_selectedDateRange!.end.add(const Duration(days: 1)));
              }

              return matchesQuery && matchesStatus && matchesDate;
            }).toList();

            return DataTableWidget<QuoteRequestModel>(
              columns: const [
                TableColumnConfig(title: 'CLIENT NAME', flex: 2),
                TableColumnConfig(title: 'CONTACT INFO', flex: 3),
                TableColumnConfig(title: 'INQUIRY MESSAGE', flex: 4),
                TableColumnConfig(title: 'DATE', width: 120),
                TableColumnConfig(title: 'STATUS', width: 110),
                TableColumnConfig(title: 'ACTIONS', width: 80, alignment: Alignment.centerRight),
              ],
              items: filtered,
              onRowTap: (quote) => context.go('/quote-requests/${quote.id}'),
              onSearch: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
              searchHint: 'Search by client, email, phone...',
              filterWidget: Row(
                children: [
                  DropdownButton<String>(
                    value: _selectedStatus,
                    dropdownColor: colors.surfaceElevated,
                    style: AppTextStyles.bodyMedium.copyWith(color: colors.textPrimary),
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: 'ALL', child: Text('All Statuses')),
                      DropdownMenuItem(value: 'new', child: Text('New')),
                      DropdownMenuItem(value: 'contacted', child: Text('Contacted')),
                      DropdownMenuItem(value: 'closed', child: Text('Closed')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedStatus = val);
                    },
                  ),
                  const SizedBox(width: 8),
                  if (_selectedDateRange != null)
                    InputChip(
                      label: Text(
                        '${DateFormat('dd MMM').format(_selectedDateRange!.start)} - ${DateFormat('dd MMM').format(_selectedDateRange!.end)}',
                        style: TextStyle(color: colors.textPrimary, fontSize: 12),
                      ),
                      onDeleted: () => setState(() => _selectedDateRange = null),
                    )
                  else
                    IconButton(
                      icon: Icon(Icons.date_range, size: 18, color: colors.textSecondary),
                      tooltip: 'Filter by date range',
                      onPressed: () async {
                        final picked = await showDateRangePicker(
                          context: context,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                          builder: (context, child) => Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: Theme.of(context).colorScheme.copyWith(
                                primary: colors.primaryRed,
                                surface: colors.surfaceElevated,
                              ),
                            ),
                            child: child!,
                          ),
                        );
                        if (picked != null) {
                          setState(() => _selectedDateRange = picked);
                        }
                      },
                    ),
                ],
              ),
              rowBuilder: (context, quote, index) {
                return [
                  Text(
                    quote.firstName.isNotEmpty ? quote.firstName : 'Anonymous',
                    style: AppTextStyles.bodyMedium.copyWith(color: colors.textPrimary, fontWeight: FontWeight.w600),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(quote.email, style: AppTextStyles.bodySmall.copyWith(color: colors.textPrimary)),
                      if (quote.phone.isNotEmpty)
                        Text(quote.phone, style: AppTextStyles.bodySmall.copyWith(color: colors.textSecondary, fontSize: 11)),
                    ],
                  ),
                  Text(
                    quote.message,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySmall.copyWith(color: colors.textSecondary),
                  ),
                  Text(
                    quote.createdAt != null ? DateFormat('dd MMM yyyy').format(quote.createdAt!) : '-',
                    style: AppTextStyles.bodySmall.copyWith(color: colors.textSecondary),
                  ),
                  StatusBadge.fromStatus(quote.status.value),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: Icon(Icons.delete_outline, size: 18, color: colors.error),
                        onPressed: () => _deleteQuote(quote),
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
