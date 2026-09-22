import 'package:flutter/material.dart';
import '../theme/app_color_scheme.dart';
import '../constants/app_text_styles.dart';
import '../models/localized_text.dart';

class LocalizedFieldTabs extends StatefulWidget {
  final String label;
  final String? hint;
  final LocalizedText initialValue;
  final ValueChanged<LocalizedText> onChanged;
  final int maxLines;
  final bool isRequired;
  final String? Function(String?)? validator;

  const LocalizedFieldTabs({
    super.key,
    required this.label,
    this.hint,
    required this.initialValue,
    required this.onChanged,
    this.maxLines = 1,
    this.isRequired = false,
    this.validator,
  });

  @override
  State<LocalizedFieldTabs> createState() => _LocalizedFieldTabsState();
}

class _LocalizedFieldTabsState extends State<LocalizedFieldTabs> {
  int _selectedTabIndex = 0;
  late final TextEditingController _enController;
  late final TextEditingController _frController;
  late final TextEditingController _deController;
  late final TextEditingController _arController;

  static const List<Map<String, String>> _languages = [
    {'code': 'en', 'label': 'EN', 'name': 'English'},
    {'code': 'fr', 'label': 'FR', 'name': 'Français'},
    {'code': 'de', 'label': 'DE', 'name': 'Deutsch'},
    {'code': 'ar', 'label': 'AR', 'name': 'العربية'},
  ];

  @override
  void initState() {
    super.initState();
    _enController = TextEditingController(text: widget.initialValue.en);
    _frController = TextEditingController(text: widget.initialValue.fr);
    _deController = TextEditingController(text: widget.initialValue.de);
    _arController = TextEditingController(text: widget.initialValue.ar);

    _enController.addListener(_notifyChange);
    _frController.addListener(_notifyChange);
    _deController.addListener(_notifyChange);
    _arController.addListener(_notifyChange);
  }

  @override
  void didUpdateWidget(covariant LocalizedFieldTabs oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue.en != _enController.text) {
      _enController.removeListener(_notifyChange);
      _enController.text = widget.initialValue.en;
      _enController.addListener(_notifyChange);
    }
    if (widget.initialValue.fr != _frController.text) {
      _frController.removeListener(_notifyChange);
      _frController.text = widget.initialValue.fr;
      _frController.addListener(_notifyChange);
    }
    if (widget.initialValue.de != _deController.text) {
      _deController.removeListener(_notifyChange);
      _deController.text = widget.initialValue.de;
      _deController.addListener(_notifyChange);
    }
    if (widget.initialValue.ar != _arController.text) {
      _arController.removeListener(_notifyChange);
      _arController.text = widget.initialValue.ar;
      _arController.addListener(_notifyChange);
    }
  }

  void _notifyChange() {
    widget.onChanged(LocalizedText(
      en: _enController.text,
      fr: _frController.text,
      de: _deController.text,
      ar: _arController.text,
    ));
  }

  @override
  void dispose() {
    _enController.removeListener(_notifyChange);
    _frController.removeListener(_notifyChange);
    _deController.removeListener(_notifyChange);
    _arController.removeListener(_notifyChange);
    _enController.dispose();
    _frController.dispose();
    _deController.dispose();
    _arController.dispose();
    super.dispose();
  }

  TextEditingController get _currentController {
    switch (_selectedTabIndex) {
      case 1:
        return _frController;
      case 2:
        return _deController;
      case 3:
        return _arController;
      case 0:
      default:
        return _enController;
    }
  }

  bool _hasContent(int index) {
    switch (index) {
      case 0:
        return _enController.text.trim().isNotEmpty;
      case 1:
        return _frController.text.trim().isNotEmpty;
      case 2:
        return _deController.text.trim().isNotEmpty;
      case 3:
        return _arController.text.trim().isNotEmpty;
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final currentLang = _languages[_selectedTabIndex];
    final isRtl = _selectedTabIndex == 3;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.label,
                  style: AppTextStyles.fieldLabel.copyWith(color: colors.textPrimary),
                ),
                if (widget.isRequired)
                  Text(
                    ' *',
                    style: TextStyle(color: colors.primaryRed, fontWeight: FontWeight.bold),
                  ),
              ],
            ),
            // Language selector tabs
            ListenableBuilder(
              listenable: Listenable.merge([
                _enController,
                _frController,
                _deController,
                _arController,
              ]),
              builder: (context, _) {
                return Container(
                  decoration: BoxDecoration(
                    color: colors.surfaceElevated,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: colors.border, width: 1),
                  ),
                  padding: const EdgeInsets.all(2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(_languages.length, (index) {
                      final isSelected = _selectedTabIndex == index;
                      final hasData = _hasContent(index);
                      final lang = _languages[index];

                      return InkWell(
                        onTap: () {
                          setState(() {
                            _selectedTabIndex = index;
                          });
                        },
                        borderRadius: BorderRadius.circular(4),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isSelected ? colors.primaryRed : Colors.transparent,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                lang['label']!,
                                style: AppTextStyles.badgeText.copyWith(
                                  color: isSelected
                                      ? Colors.white
                                      : (hasData ? colors.textPrimary : colors.textSecondary),
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                ),
                              ),
                              if (hasData && !isSelected) ...[
                                const SizedBox(width: 4),
                                Container(
                                  width: 5,
                                  height: 5,
                                  decoration: BoxDecoration(
                                    color: colors.success,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _currentController,
          maxLines: widget.maxLines,
          textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
          style: AppTextStyles.inputText.copyWith(color: colors.textPrimary),
          validator: (val) {
            if (_selectedTabIndex == 0 && widget.isRequired && widget.validator != null) {
              return widget.validator!(val);
            } else if (_selectedTabIndex == 0 && widget.isRequired && (val == null || val.trim().isEmpty)) {
              return '${widget.label} is required (English)';
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: widget.hint != null
                ? '${widget.hint} (${currentLang['name']})'
                : 'Enter ${widget.label.toLowerCase()} in ${currentLang['name']}...',
            prefixIcon: isRtl ? null : Icon(Icons.translate, size: 18, color: colors.textSecondary),
            suffixIcon: isRtl ? Icon(Icons.translate, size: 18, color: colors.textSecondary) : null,
          ),
        ),
      ],
    );
  }
}
