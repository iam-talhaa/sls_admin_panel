import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_color_scheme.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/status_badge.dart';
import '../data/models/concierge_request_model.dart';
import '../data/repositories/concierge_requests_repository.dart';

class ConciergeRequestDetailView extends ConsumerStatefulWidget {
  final String requestId;

  const ConciergeRequestDetailView({super.key, required this.requestId});

  @override
  ConsumerState<ConciergeRequestDetailView> createState() => _ConciergeRequestDetailViewState();
}

class _ConciergeRequestDetailViewState extends ConsumerState<ConciergeRequestDetailView> {
  final _notesController = TextEditingController();
  bool _isLoading = true;
  ConciergeRequestModel? _request;
  bool _isSavingNotes = false;

  @override
  void initState() {
    super.initState();
    _loadRequest();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadRequest() async {
    try {
      final req = await ref.read(conciergeRequestsRepositoryProvider).getConciergeRequestById(widget.requestId);
      if (req != null) {
        _request = req;
        _notesController.text = req.adminNotes;
      }
    } catch (_) {}
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _updateStatus(ConciergeRequestStatus newStatus) async {
    if (_request == null) return;
    final colors = context.colors;
    try {
      await ref.read(conciergeRequestsRepositoryProvider).updateStatus(_request!.id, newStatus);
      setState(() {
        _request = _request!.copyWith(status: newStatus);
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
    if (_request == null) return;
    final colors = context.colors;
    setState(() => _isSavingNotes = true);
    try {
      await ref.read(conciergeRequestsRepositoryProvider).updateAdminNotes(_request!.id, _notesController.text.trim());
      setState(() {
        _request = _request!.copyWith(adminNotes: _notesController.text.trim());
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

  Future<void> _deleteRequest() async {
    if (_request == null) return;
    final colors = context.colors;
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Delete Concierge Request',
      message: 'Are you sure you want to permanently delete this concierge request from ${_request!.name}?',
      confirmLabel: 'Delete',
      isDestructive: true,
    );

    if (confirmed && mounted) {
      await ref.read(conciergeRequestsRepositoryProvider).deleteConciergeRequest(_request!.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text('Concierge request deleted from Firebase'), backgroundColor: colors.success),
        );
        context.go('/concierge-requests');
      }
    }
  }

  Future<void> _launchEmail(String email) async {
    final uri = Uri.parse('mailto:$email?subject=Swiss Luxury Services Concierge Follow-Up');
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

    if (_request == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Concierge request not found.', style: AppTextStyles.headingSmall.copyWith(color: colors.textPrimary)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => context.go('/concierge-requests'),
              child: const Text('Back to Concierge Requests'),
            ),
          ],
        ),
      );
    }

    final hasServiceMeta = (_request!.serviceCategory != null && _request!.serviceCategory!.isNotEmpty) ||
        (_request!.preferredDate != null && _request!.preferredDate!.isNotEmpty);

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
                      context.go('/concierge-requests');
                    }
                  },
                  tooltip: 'Back to List',
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Concierge Request Details', style: AppTextStyles.headingMedium.copyWith(color: colors.textPrimary)),
                    Text('Document ID: ${_request!.id}', style: AppTextStyles.subtitle.copyWith(color: colors.textSecondary)),
                  ],
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                StatusBadge.fromStatus(_request!.status.value),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: colors.surfaceElevated,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: colors.border),
                  ),
                  child: DropdownButton<ConciergeRequestStatus>(
                    value: _request!.status,
                    dropdownColor: colors.surfaceElevated,
                    style: AppTextStyles.bodyMedium.copyWith(color: colors.textPrimary),
                    underline: const SizedBox(),
                    items: ConciergeRequestStatus.values.map((s) {
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
                  onPressed: _deleteRequest,
                  tooltip: 'Delete Request',
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Layout
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
                  Text('Guest Information', style: AppTextStyles.headingSmall.copyWith(color: colors.textPrimary)),
                  const SizedBox(height: 20),
                  _buildInfoRow('Guest Name', _request!.name.isNotEmpty ? _request!.name : 'VIP Guest', colors),
                  Divider(height: 24, color: colors.border),
                  _buildInfoRow(
                    'Email Address',
                    _request!.email.isNotEmpty ? _request!.email : 'Not provided',
                    colors,
                    trailing: _request!.email.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.email_outlined, size: 18, color: colors.primaryRed),
                            onPressed: () => _launchEmail(_request!.email),
                            tooltip: 'Send Email',
                          )
                        : null,
                  ),
                  Divider(height: 24, color: colors.border),
                  _buildInfoRow(
                    'Phone Number',
                    _request!.phone.isNotEmpty ? _request!.phone : 'Not provided',
                    colors,
                    trailing: _request!.phone.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.phone_outlined, size: 18, color: colors.primaryRed),
                            onPressed: () => _launchPhone(_request!.phone),
                            tooltip: 'Call Guest',
                          )
                        : null,
                  ),
                  Divider(height: 24, color: colors.border),
                  _buildInfoRow(
                    'Submitted At',
                    _request!.createdAt != null
                        ? DateFormat('EEEE, dd MMMM yyyy • HH:mm').format(_request!.createdAt!)
                        : 'Unknown',
                    colors,
                  ),
                  if (_request!.userId != null && _request!.userId!.isNotEmpty) ...[
                    Divider(height: 24, color: colors.border),
                    _buildInfoRow('User ID', _request!.userId!, colors),
                  ],
                ],
              ),
            );

            final detailsCard = Container(
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
                  Text('Concierge Service Requirements', style: AppTextStyles.headingSmall.copyWith(color: colors.textPrimary)),
                  const SizedBox(height: 16),

                  if (hasServiceMeta) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: colors.surfaceElevatedHigher,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: colors.border),
                      ),
                      child: Wrap(
                        spacing: 16,
                        runSpacing: 8,
                        children: [
                          if (_request!.serviceCategory != null && _request!.serviceCategory!.isNotEmpty)
                            _buildBadgeInfo('Service Type', _request!.serviceCategory!, colors),
                          if (_request!.preferredDate != null && _request!.preferredDate!.isNotEmpty)
                            _buildBadgeInfo('Preferred Date', _request!.preferredDate!, colors),
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
                      _request!.requestDetails.isNotEmpty ? _request!.requestDetails : 'No specific details provided.',
                      style: AppTextStyles.bodyMedium.copyWith(color: colors.textPrimary, height: 1.6),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Admin Notes
                  Text('Internal Concierge Notes', style: AppTextStyles.headingSmall.copyWith(color: colors.textPrimary)),
                  const SizedBox(height: 8),
                  Text('Private notes for concierge coordinators (persisted in Firestore).', style: AppTextStyles.subtitle.copyWith(color: colors.textSecondary)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _notesController,
                    maxLines: 4,
                    style: AppTextStyles.inputText.copyWith(color: colors.textPrimary),
                    decoration: const InputDecoration(
                      hintText: 'e.g. Arranged Maybach transfer from Samedan airport to Badrutt’s Palace Hotel.',
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
                  Expanded(flex: 3, child: detailsCard),
                ],
              );
            } else {
              return Column(
                children: [
                  clientCard,
                  const SizedBox(height: 20),
                  detailsCard,
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
