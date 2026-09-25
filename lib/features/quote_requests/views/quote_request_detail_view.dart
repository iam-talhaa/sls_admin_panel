import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_color_scheme.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/status_badge.dart';
import '../data/models/quote_request_model.dart';
import '../data/repositories/quote_requests_repository.dart';

class QuoteRequestDetailView extends ConsumerStatefulWidget {
  final String requestId;

  const QuoteRequestDetailView({super.key, required this.requestId});

  @override
  ConsumerState<QuoteRequestDetailView> createState() => _QuoteRequestDetailViewState();
}

class _QuoteRequestDetailViewState extends ConsumerState<QuoteRequestDetailView> {
  final _notesController = TextEditingController();
  bool _isLoading = true;
  QuoteRequestModel? _quote;
  bool _isSavingNotes = false;

  @override
  void initState() {
    super.initState();
    _loadQuote();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadQuote() async {
    try {
      final quote = await ref.read(quoteRequestsRepositoryProvider).getQuoteRequestById(widget.requestId);
      if (quote != null) {
        _quote = quote;
        _notesController.text = quote.adminNotes;
      }
    } catch (_) {}
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _updateStatus(QuoteRequestStatus newStatus) async {
    if (_quote == null) return;
    final colors = context.colors;
    try {
      await ref.read(quoteRequestsRepositoryProvider).updateStatus(_quote!.id, newStatus);
      setState(() {
        _quote = _quote!.copyWith(status: newStatus);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Status updated to ${newStatus.label}'), backgroundColor: colors.success),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating status: $e'), backgroundColor: colors.error),
        );
      }
    }
  }

  Future<void> _saveAdminNotes() async {
    if (_quote == null) return;
    final colors = context.colors;
    setState(() => _isSavingNotes = true);
    try {
      await ref.read(quoteRequestsRepositoryProvider).updateAdminNotes(_quote!.id, _notesController.text.trim());
      setState(() {
        _quote = _quote!.copyWith(adminNotes: _notesController.text.trim());
        _isSavingNotes = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text('Admin notes saved to Firebase!'), backgroundColor: colors.success),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSavingNotes = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving notes: $e'), backgroundColor: colors.error),
        );
      }
    }
  }

  Future<void> _deleteQuote() async {
    if (_quote == null) return;
    final colors = context.colors;
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Delete Quote Request',
      message: 'Are you sure you want to permanently delete this quote request from ${_quote!.firstName.isNotEmpty ? _quote!.firstName : _quote!.email}?',
      confirmLabel: 'Delete',
      isDestructive: true,
    );

    if (confirmed && mounted) {
      await ref.read(quoteRequestsRepositoryProvider).deleteQuoteRequest(_quote!.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text('Quote request deleted from Firebase'), backgroundColor: colors.success),
        );
        context.go('/quote-requests');
      }
    }
  }

  Future<void> _launchEmail(String email) async {
    final uri = Uri.parse('mailto:$email?subject=Swiss Luxury Services - Quote Request Follow-Up');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchPhone(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
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

    if (_quote == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Quote request not found.', style: AppTextStyles.headingSmall.copyWith(color: colors.textPrimary)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => context.go('/quote-requests'),
              child: const Text('Back to Quotes'),
            ),
          ],
        ),
      );
    }

    final hasFlightDetails = (_quote!.departure != null && _quote!.departure!.isNotEmpty) ||
        (_quote!.destination != null && _quote!.destination!.isNotEmpty) ||
        (_quote!.departureDate != null && _quote!.departureDate!.isNotEmpty) ||
        (_quote!.passengers != null && _quote!.passengers!.isNotEmpty) ||
        (_quote!.jetType != null && _quote!.jetType!.isNotEmpty);

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
                      context.go('/quote-requests');
                    }
                  },
                  tooltip: 'Back to List',
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Quote Request Details', style: AppTextStyles.headingMedium.copyWith(color: colors.textPrimary)),
                    Text('Document ID: ${_quote!.id}', style: AppTextStyles.subtitle.copyWith(color: colors.textSecondary)),
                  ],
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                StatusBadge.fromStatus(_quote!.status.value),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: colors.surfaceElevated,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: colors.border),
                  ),
                  child: DropdownButton<QuoteRequestStatus>(
                    value: _quote!.status,
                    dropdownColor: colors.surfaceElevated,
                    style: AppTextStyles.bodyMedium.copyWith(color: colors.textPrimary),
                    underline: const SizedBox(),
                    items: QuoteRequestStatus.values.map((s) {
                      return DropdownMenuItem(value: s, child: Text(s.label));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) _updateStatus(val);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  icon: Icon(Icons.delete_outline, color: colors.error),
                  onPressed: _deleteQuote,
                  tooltip: 'Delete Request',
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 24),

        // 2-Column or Stacked Details Layout
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 900;

            final clientCard = Container(
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
                  Text('Client Information', style: AppTextStyles.headingSmall.copyWith(color: colors.textPrimary)),
                  const SizedBox(height: 20),
                  _buildInfoRow('Full Name', _quote!.firstName.isNotEmpty ? _quote!.firstName : 'Not specified', colors),
                  Divider(height: 24, color: colors.border),
                  _buildInfoRow(
                    'Email Address',
                    _quote!.email.isNotEmpty ? _quote!.email : 'Not provided',
                    colors,
                    trailing: _quote!.email.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.email_outlined, size: 18, color: colors.primaryRed),
                            onPressed: () => _launchEmail(_quote!.email),
                            tooltip: 'Send Email',
                          )
                        : null,
                  ),
                  Divider(height: 24, color: colors.border),
                  _buildInfoRow(
                    'Phone Number',
                    _quote!.phone.isNotEmpty ? _quote!.phone : 'Not provided',
                    colors,
                    trailing: _quote!.phone.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.phone_outlined, size: 18, color: colors.primaryRed),
                            onPressed: () => _launchPhone(_quote!.phone),
                            tooltip: 'Call Client',
                          )
                        : null,
                  ),
                  Divider(height: 24, color: colors.border),
                  _buildInfoRow(
                    'Submitted At',
                    _quote!.createdAt != null
                        ? DateFormat('EEEE, dd MMMM yyyy • HH:mm').format(_quote!.createdAt!)
                        : 'Unknown',
                    colors,
                  ),
                  if (_quote!.userId != null && _quote!.userId!.isNotEmpty) ...[
                    Divider(height: 24, color: colors.border),
                    _buildInfoRow('User ID', _quote!.userId!, colors),
                  ],
                ],
              ),
            );

            final messageCard = Container(
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
                  Text('Inquiry Details & Route Requirements', style: AppTextStyles.headingSmall.copyWith(color: colors.textPrimary)),
                  const SizedBox(height: 16),

                  if (hasFlightDetails) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: colors.surfaceElevatedHigher,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: colors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if ((_quote!.departure != null && _quote!.departure!.isNotEmpty) ||
                              (_quote!.destination != null && _quote!.destination!.isNotEmpty))
                            Row(
                              children: [
                                Icon(Icons.flight_takeoff, size: 18, color: colors.primaryRed),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '${_quote!.departure ?? 'Origin'} → ${_quote!.destination ?? 'Destination'}',
                                    style: AppTextStyles.bodyMedium.copyWith(color: colors.textPrimary, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 16,
                            runSpacing: 8,
                            children: [
                              if (_quote!.departureDate != null && _quote!.departureDate!.isNotEmpty)
                                _buildBadgeInfo('Departure', _quote!.departureDate!, colors),
                              if (_quote!.returnDate != null && _quote!.returnDate!.isNotEmpty)
                                _buildBadgeInfo('Return', _quote!.returnDate!, colors),
                              if (_quote!.passengers != null && _quote!.passengers!.isNotEmpty)
                                _buildBadgeInfo('Passengers', '${_quote!.passengers} Pax', colors),
                              if (_quote!.jetType != null && _quote!.jetType!.isNotEmpty)
                                _buildBadgeInfo('Aircraft', _quote!.jetType!, colors),
                              if (_quote!.tripType != null && _quote!.tripType!.isNotEmpty)
                                _buildBadgeInfo('Trip', _quote!.tripType!, colors),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colors.inputFill,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: colors.border),
                    ),
                    child: SelectableText(
                      _quote!.message.isNotEmpty ? _quote!.message : 'No detailed message provided.',
                      style: AppTextStyles.bodyMedium.copyWith(color: colors.textPrimary, height: 1.6),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Admin Internal Notes
                  Text('Internal Staff Notes', style: AppTextStyles.headingSmall.copyWith(color: colors.textPrimary)),
                  const SizedBox(height: 8),
                  Text('Private notes for charter agents (persisted in Firestore).', style: AppTextStyles.subtitle.copyWith(color: colors.textSecondary)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _notesController,
                    maxLines: 4,
                    style: AppTextStyles.inputText.copyWith(color: colors.textPrimary),
                    decoration: const InputDecoration(
                      hintText: 'e.g. Quoted Pilatus PC-24 at CHF 4,200. Followed up via phone on Monday.',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      onPressed: _isSavingNotes ? null : _saveAdminNotes,
                      icon: _isSavingNotes
                          ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.save, size: 16),
                      label: Text(_isSavingNotes ? 'Saving...' : 'Save Notes'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.primaryRed,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            );

            if (isWide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 2, child: clientCard),
                  const SizedBox(width: 20),
                  Expanded(flex: 3, child: messageCard),
                ],
              );
            } else {
              return Column(
                children: [
                  clientCard,
                  const SizedBox(height: 20),
                  messageCard,
                ],
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildBadgeInfo(String label, String val, dynamic colors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$label: ', style: AppTextStyles.bodySmall.copyWith(color: colors.textSecondary, fontSize: 11)),
          Text(val, style: AppTextStyles.bodySmall.copyWith(color: colors.textPrimary, fontWeight: FontWeight.bold, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, dynamic colors, {Widget? trailing}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTextStyles.subtitle.copyWith(color: colors.textSecondary, fontSize: 11)),
            const SizedBox(height: 4),
            Text(value, style: AppTextStyles.bodyMedium.copyWith(color: colors.textPrimary, fontWeight: FontWeight.w500)),
          ],
        ),
        if (trailing != null) trailing,
      ],
    );
  }
}
