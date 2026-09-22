import 'package:flutter/material.dart';
import '../theme/app_color_scheme.dart';
import '../constants/app_text_styles.dart';

enum _StatusType {
  success,
  warning,
  inactive,
  superAdmin,
  editor,
  custom,
}

class StatusBadge extends StatelessWidget {
  final String label;
  final Color? color;
  final Color? backgroundColor;
  final bool isSuccess;
  final bool isWarning;
  final bool isError;
  final bool isInfo;
  final _StatusType _type;

  const StatusBadge({
    super.key,
    required this.label,
    this.color,
    this.backgroundColor,
    this.isSuccess = false,
    this.isWarning = false,
    this.isError = false,
    this.isInfo = false,
  }) : _type = _StatusType.custom;


  const StatusBadge.success({
    super.key,
    required this.label,
  })  : color = null,
        backgroundColor = null,
        isSuccess = false,
        isWarning = false,
        isError = false,
        isInfo = false,
        _type = _StatusType.success;

  const StatusBadge.warning({
    super.key,
    required this.label,
  })  : color = null,
        backgroundColor = null,
        isSuccess = false,
        isWarning = false,
        isError = false,
        isInfo = false,
        _type = _StatusType.warning;

  const StatusBadge.inactive({
    super.key,
    required this.label,
  })  : color = null,
        backgroundColor = null,
        isSuccess = false,
        isWarning = false,
        isError = false,
        isInfo = false,
        _type = _StatusType.inactive;

  const StatusBadge.superAdmin({
    super.key,
    this.label = 'Super Admin',
  })  : color = null,
        backgroundColor = null,
        isSuccess = false,
        isWarning = false,
        isError = false,
        isInfo = false,
        _type = _StatusType.superAdmin;

  const StatusBadge.editor({
    super.key,
    this.label = 'Editor',
  })  : color = null,
        backgroundColor = null,
        isSuccess = false,
        isWarning = false,
        isError = false,
        isInfo = false,
        _type = _StatusType.editor;

  factory StatusBadge.fromStatus(String status) {
    final s = status.toLowerCase().trim();
    if (s == 'active' || s == 'published' || s == 'closed' || s == 'resolved') {
      return StatusBadge.success(
        label: _capitalize(status),
      );
    } else if (s == 'new' || s == 'pending' || s == 'in_progress' || s == 'contacted') {
      return StatusBadge.warning(
        label: _formatStatus(status),
      );
    } else if (s == 'inactive' || s == 'draft' || s == 'disabled' || s == 'rejected') {
      return StatusBadge.inactive(
        label: _capitalize(status),
      );
    } else if (s == 'super_admin') {
      return const StatusBadge.superAdmin();
    } else if (s == 'editor') {
      return const StatusBadge.editor();
    }

    return StatusBadge.inactive(
      label: _capitalize(status),
    );
  }

  static String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }

  static String _formatStatus(String s) {
    return s.split('_').map((w) => _capitalize(w)).join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    Color fg;
    Color bg;

    if (color != null && backgroundColor != null) {
      fg = color!;
      bg = backgroundColor!;
    } else {
      switch (_type) {
        case _StatusType.success:
          fg = colors.success;
          bg = colors.successBg;
          break;
        case _StatusType.warning:
          fg = colors.warning;
          bg = colors.warningBg;
          break;
        case _StatusType.inactive:
          fg = colors.textSecondary;
          bg = colors.surfaceElevatedHigher;
          break;
        case _StatusType.superAdmin:
          fg = colors.primaryRed;
          bg = colors.primaryRedLight;
          break;
        case _StatusType.editor:
          fg = colors.info;
          bg = colors.infoBg;
          break;
        case _StatusType.custom:
          fg = color ??
              (isSuccess
                  ? colors.success
                  : isWarning
                      ? colors.warning
                      : isError
                          ? colors.error
                          : isInfo
                              ? colors.info
                              : colors.textSecondary);

          bg = backgroundColor ??
              (isSuccess
                  ? colors.successBg
                  : isWarning
                      ? colors.warningBg
                      : isError
                          ? colors.errorBg
                          : isInfo
                              ? colors.infoBg
                              : colors.surfaceElevatedHigher);
          break;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: fg.withOpacity(0.3), width: 0.8),
      ),
      child: Text(
        label,
        style: AppTextStyles.badgeText.copyWith(color: fg),
      ),
    );
  }
}
