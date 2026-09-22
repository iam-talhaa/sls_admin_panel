import 'package:flutter/material.dart';
import '../theme/app_color_scheme.dart';
import '../constants/app_text_styles.dart';
import 'empty_state.dart';

class TableColumnConfig {
  final String title;
  final double? width;
  final int flex;
  final Alignment alignment;
  final bool isSortable;
  final String? sortKey;

  const TableColumnConfig({
    required this.title,
    this.width,
    this.flex = 1,
    this.alignment = Alignment.centerLeft,
    this.isSortable = false,
    this.sortKey,
  });
}

class DataTableWidget<T> extends StatefulWidget {
  final List<TableColumnConfig> columns;
  final List<T> items;
  final List<Widget> Function(BuildContext context, T item, int index) rowBuilder;
  final void Function(T item)? onRowTap;
  final String? searchHint;
  final ValueChanged<String>? onSearch;
  final Widget? filterWidget;
  final Widget? actionWidget;
  final bool isLoading;
  final String emptyTitle;
  final String emptyMessage;
  final int rowsPerPage;
  final String? currentSortKey;
  final bool isAscending;
  final void Function(String sortKey, bool ascending)? onSort;

  const DataTableWidget({
    super.key,
    required this.columns,
    required this.items,
    required this.rowBuilder,
    this.onRowTap,
    this.searchHint,
    this.onSearch,
    this.filterWidget,
    this.actionWidget,
    this.isLoading = false,
    this.emptyTitle = 'No data found',
    this.emptyMessage = 'There are no records matching your criteria.',
    this.rowsPerPage = 10,
    this.currentSortKey,
    this.isAscending = true,
    this.onSort,
  });

  @override
  State<DataTableWidget<T>> createState() => _DataTableWidgetState<T>();
}

class _DataTableWidgetState<T> extends State<DataTableWidget<T>> {
  int _currentPage = 0;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  int get _totalPages {
    if (widget.items.isEmpty) return 1;
    return (widget.items.length / widget.rowsPerPage).ceil();
  }

  List<T> get _paginatedItems {
    final start = _currentPage * widget.rowsPerPage;
    if (start >= widget.items.length) return [];
    final end = (start + widget.rowsPerPage).clamp(0, widget.items.length);
    return widget.items.sublist(start, end);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

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
          // Header Bar: Search + Filter + Actions
          if (widget.onSearch != null || widget.filterWidget != null || widget.actionWidget != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.onSearch != null)
                        SizedBox(
                          width: 260,
                          height: 40,
                          child: TextField(
                            controller: _searchController,
                            style: AppTextStyles.inputText.copyWith(color: colors.textPrimary, fontSize: 13),
                            onChanged: (val) {
                              setState(() {
                                _currentPage = 0;
                              });
                              widget.onSearch!(val);
                            },
                            decoration: InputDecoration(
                              hintText: widget.searchHint ?? 'Search...',
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                              prefixIcon: Icon(Icons.search, size: 18, color: colors.textSecondary),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear, size: 16),
                                      onPressed: () {
                                        _searchController.clear();
                                        widget.onSearch!('');
                                        setState(() {});
                                      },
                                    )
                                  : null,
                            ),
                          ),
                        ),
                      if (widget.filterWidget != null) ...[
                        const SizedBox(width: 12),
                        widget.filterWidget!,
                      ],
                    ],
                  ),
                  if (widget.actionWidget != null) widget.actionWidget!,
                ],
              ),
            ),

          if (widget.onSearch != null || widget.filterWidget != null || widget.actionWidget != null)
            Divider(height: 1, color: colors.border),

          // Table Header and Items in Horizontal Scroll container for overflow protection
          LayoutBuilder(
            builder: (context, constraints) {
              const double minTableWidth = 820;
              final effectiveWidth = constraints.maxWidth < minTableWidth ? minTableWidth : constraints.maxWidth;

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: effectiveWidth,
                  child: Column(
                    children: [
                      // Table Header
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: colors.surfaceElevatedHigher,
                        ),
                        child: Row(
                          children: widget.columns.map((col) {
                            Widget titleWidget = Text(
                              col.title.toUpperCase(),
                              style: AppTextStyles.tableHeader.copyWith(color: colors.textSecondary),
                            );

                            if (col.isSortable && col.sortKey != null && widget.onSort != null) {
                              final isSorted = widget.currentSortKey == col.sortKey;
                              titleWidget = InkWell(
                                onTap: () {
                                  final newAsc = isSorted ? !widget.isAscending : true;
                                  widget.onSort!(col.sortKey!, newAsc);
                                },
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    titleWidget,
                                    const SizedBox(width: 4),
                                    Icon(
                                      isSorted
                                          ? (widget.isAscending ? Icons.arrow_upward : Icons.arrow_downward)
                                          : Icons.unfold_more,
                                      size: 14,
                                      color: isSorted ? colors.primaryRed : colors.textSecondary,
                                    ),
                                  ],
                                ),
                              );
                            }

                            if (col.width != null) {
                              return SizedBox(
                                width: col.width,
                                child: Align(alignment: col.alignment, child: titleWidget),
                              );
                            }

                            return Expanded(
                              flex: col.flex,
                              child: Align(alignment: col.alignment, child: titleWidget),
                            );
                          }).toList(),
                        ),
                      ),
                      Divider(height: 1, color: colors.border),

                      // Content Area
                      if (widget.isLoading)
                        SizedBox(
                          height: 240,
                          child: Center(
                            child: CircularProgressIndicator(color: colors.primaryRed),
                          ),
                        )
                      else if (widget.items.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40.0),
                          child: EmptyState(
                            title: widget.emptyTitle,
                            message: widget.emptyMessage,
                          ),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _paginatedItems.length,
                          separatorBuilder: (context, index) => Divider(height: 1, color: colors.border),
                          itemBuilder: (context, index) {
                            final item = _paginatedItems[index];
                            final cells = widget.rowBuilder(context, item, index);

                            return Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: widget.onRowTap != null ? () => widget.onRowTap!(item) : null,
                                hoverColor: colors.tableRowHover,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  child: Row(
                                    children: List.generate(widget.columns.length, (colIndex) {
                                      final col = widget.columns[colIndex];
                                      final cell = colIndex < cells.length ? cells[colIndex] : const SizedBox();

                                      if (col.width != null) {
                                        return SizedBox(
                                          width: col.width,
                                          child: Align(alignment: col.alignment, child: cell),
                                        );
                                      }

                                      return Expanded(
                                        flex: col.flex,
                                        child: Align(alignment: col.alignment, child: cell),
                                      );
                                    }),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              );
            },
          ),

          // Pagination Footer
          if (widget.items.isNotEmpty) ...[
            Divider(height: 1, color: colors.border),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 12,
                runSpacing: 8,
                children: [
                  Text(
                    'Showing ${(_currentPage * widget.rowsPerPage) + 1} to ${((_currentPage + 1) * widget.rowsPerPage).clamp(0, widget.items.length)} of ${widget.items.length} entries',
                    style: AppTextStyles.bodySmall.copyWith(color: colors.textSecondary),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left, size: 20),
                        color: _currentPage > 0 ? colors.textPrimary : colors.textMuted,
                        onPressed: _currentPage > 0
                            ? () {
                                setState(() {
                                  _currentPage -= 1;
                                });
                              }
                            : null,
                      ),
                      Text(
                        'Page ${_currentPage + 1} of $_totalPages',
                        style: AppTextStyles.bodySmall.copyWith(color: colors.textPrimary),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right, size: 20),
                        color: _currentPage < _totalPages - 1 ? colors.textPrimary : colors.textMuted,
                        onPressed: _currentPage < _totalPages - 1
                            ? () {
                                setState(() {
                                  _currentPage += 1;
                                });
                              }
                            : null,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
