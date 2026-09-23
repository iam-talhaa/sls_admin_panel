import 'package:flutter/material.dart';
import '../../../../core/theme/app_color_scheme.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/models/localized_text.dart';
import '../../data/models/concierge_model.dart';

class ConciergeMobilePreview extends StatefulWidget {
  final ConciergeBanner banner;
  final List<ConciergeCategory> categories;
  final ConciergeCategory? selectedCategory;
  final ValueChanged<ConciergeCategory>? onCategorySelected;
  final double scale;

  const ConciergeMobilePreview({
    super.key,
    required this.banner,
    required this.categories,
    this.selectedCategory,
    this.onCategorySelected,
    this.scale = 1.0,
  });

  @override
  State<ConciergeMobilePreview> createState() => _ConciergeMobilePreviewState();
}

class _ConciergeMobilePreviewState extends State<ConciergeMobilePreview> {
  String _selectedLang = 'en';
  int _activeCategoryIndex = 0;

  @override
  void initState() {
    super.initState();
    _syncSelectedCategoryIndex();
  }

  @override
  void didUpdateWidget(covariant ConciergeMobilePreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncSelectedCategoryIndex();
  }

  void _syncSelectedCategoryIndex() {
    if (widget.selectedCategory != null && widget.categories.isNotEmpty) {
      final index = widget.categories.indexWhere((c) => c.id == widget.selectedCategory!.id);
      if (index >= 0) {
        _activeCategoryIndex = index;
      }
    }
  }

  ConciergeCategory? get _currentCategory {
    if (widget.categories.isEmpty) return widget.selectedCategory;
    if (_activeCategoryIndex >= 0 && _activeCategoryIndex < widget.categories.length) {
      return widget.categories[_activeCategoryIndex];
    }
    return widget.categories.first;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final currentCat = _currentCategory;

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: colors.shadow,
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Preview Top Toolbar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: colors.surfaceElevatedHigher,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
              border: Border(bottom: BorderSide(color: colors.border)),
            ),
            child: Row(
              children: [
                Icon(Icons.smartphone_outlined, size: 18, color: colors.primaryRed),
                const SizedBox(width: 8),
                Text(
                  'Live Mobile Preview',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                // Language Switcher
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: colors.border, width: 0.8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: ['en', 'fr', 'de', 'ar'].map((lang) {
                      final isSelected = _selectedLang == lang;
                      return InkWell(
                        onTap: () => setState(() => _selectedLang = lang),
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isSelected ? colors.primaryRed : Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            lang.toUpperCase(),
                            style: TextStyle(
                              color: isSelected ? Colors.white : colors.textSecondary,
                              fontSize: 11,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Phone Device Mockup Container
          Padding(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: Container(
                width: 360,
                height: 640,
                decoration: BoxDecoration(
                  color: const Color(0xFF0D0D11),
                  borderRadius: BorderRadius.circular(38),
                  border: Border.all(color: const Color(0xFF2C2D35), width: 7),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 30,
                      spreadRadius: 2,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    // Phone Status Bar / Notch
                    Container(
                      height: 28,
                      color: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '9:41',
                            style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                          Container(
                            width: 80,
                            height: 14,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E1E24),
                              borderRadius: BorderRadius.circular(7),
                            ),
                          ),
                          const Row(
                            children: [
                              Icon(Icons.wifi, color: Colors.white, size: 12),
                              SizedBox(width: 4),
                              Icon(Icons.battery_full, color: Colors.white, size: 12),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // App Navigation Header
                    Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      color: const Color(0xFF121218),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Icon(Icons.arrow_back_ios, color: Colors.white, size: 16),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                'assets/slslogo.png',
                                width: 18,
                                height: 18,
                                errorBuilder: (_, __, ___) => const SizedBox(),
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                'CONCIERGE',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ],
                          ),
                          const Icon(Icons.share_outlined, color: Colors.white, size: 16),
                        ],
                      ),
                    ),

                    // Scrollable Mobile Content
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Hero Banner
                            _buildMobileBanner(context),

                            // Category Tabs Bar
                            if (widget.categories.isNotEmpty)
                              _buildCategoryTabs(context),

                            // Selected Category Detail
                            if (currentCat != null)
                              _buildCategoryContent(context, currentCat)
                            else
                              const Padding(
                                padding: EdgeInsets.all(40),
                                child: Center(
                                  child: Text(
                                    'No category content',
                                    style: TextStyle(color: Colors.white54, fontSize: 13),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

                    // Bottom Floating CTA Button
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: const BoxDecoration(
                        color: Color(0xFF121218),
                        border: Border(top: BorderSide(color: Color(0xFF23242E))),
                      ),
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFE50914), Color(0xFF9E0B0F)],
                          ),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFE50914).withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.room_service, color: Colors.white, size: 16),
                              const SizedBox(width: 8),
                              Text(
                                _getLocalized(
                                  const LocalizedText(
                                    en: 'REQUEST THIS SERVICE',
                                    fr: 'DEMANDER CE SERVICE',
                                    de: 'DIESEN SERVICE ANFRAGEN',
                                    ar: 'طلب هذه الخدمة',
                                  ),
                                ),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileBanner(BuildContext context) {
    final title = _getLocalized(widget.banner.title);
    final subtitle = _getLocalized(widget.banner.subtitle);
    final img = widget.banner.imageUrl;

    return Container(
      height: 170,
      decoration: const BoxDecoration(
        color: Color(0xFF181920),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Banner Image
          if (img.isNotEmpty)
            _buildImage(img)
          else
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1D1F2A), Color(0xFF0F1017)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Icon(Icons.room_service_outlined, color: Colors.white24, size: 40),
            ),

          // Gradient Overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.8),
                  Colors.black.withOpacity(0.35),
                  Colors.black.withOpacity(0.9),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Banner Content
          Positioned(
            bottom: 14,
            left: 14,
            right: 14,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE50914),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'EXCLUSIVE CONCIERGE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 8.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  title.isNotEmpty ? title : 'Concierge Services',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 10,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs(BuildContext context) {
    return Container(
      height: 44,
      color: const Color(0xFF161720),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        itemCount: widget.categories.length,
        itemBuilder: (context, index) {
          final cat = widget.categories[index];
          final isSelected = index == _activeCategoryIndex;
          final tabText = _getLocalized(cat.tabTitle);

          return GestureDetector(
            onTap: () {
              setState(() {
                _activeCategoryIndex = index;
              });
              if (widget.onCategorySelected != null) {
                widget.onCategorySelected!(cat);
              }
            },
            child: Container(
              margin: const EdgeInsets.only(right: 6),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFE50914) : const Color(0xFF222430),
                borderRadius: BorderRadius.circular(20),
              ),
              alignment: Alignment.center,
              child: Text(
                tabText.isNotEmpty ? tabText : 'Category ${index + 1}',
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white70,
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryContent(BuildContext context, ConciergeCategory cat) {
    final tag = _getLocalized(cat.categoryTag);
    final title = _getLocalized(cat.title);
    final desc = _getLocalized(cat.description);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Red uppercase tag
          if (tag.isNotEmpty)
            Row(
              children: [
                Container(
                  width: 3,
                  height: 12,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE50914),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  tag.toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFFE50914),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          const SizedBox(height: 8),

          // Headline
          Text(
            title.isNotEmpty ? title : 'Category Headline',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 8),

          // Paragraph description
          if (desc.isNotEmpty)
            Text(
              desc,
              style: const TextStyle(
                color: Color(0xFFB0B3C2),
                fontSize: 11.5,
                height: 1.45,
              ),
            ),
          const SizedBox(height: 14),

          // Feature Image Card
          if (cat.imageUrl.isNotEmpty)
            Container(
              height: 130,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF2C2D38)),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildImage(cat.imageUrl),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.transparent, Colors.black.withOpacity(0.5)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Features Checklist Section
          if (cat.features.isNotEmpty) ...[
            const Text(
              'KEY PRIVILEGES & SERVICES',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 10),
            ...cat.features.map((feature) {
              final featureText = _getLocalized(feature.text);
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      margin: const EdgeInsets.only(top: 1),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE50914).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: const Color(0xFFE50914), width: 1),
                      ),
                      child: const Center(
                        child: Icon(Icons.check, size: 11, color: Color(0xFFE50914)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        featureText.isNotEmpty ? featureText : 'Feature detail',
                        style: const TextStyle(
                          color: Color(0xFFE0E2EC),
                          fontSize: 11,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildImage(String url) {
    if (url.startsWith('http')) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _imagePlaceholder(),
      );
    } else {
      return Image.asset(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _imagePlaceholder(),
      );
    }
  }

  Widget _imagePlaceholder() {
    return Container(
      color: const Color(0xFF1E202B),
      child: const Center(
        child: Icon(Icons.image_not_supported_outlined, color: Colors.white30, size: 24),
      ),
    );
  }

  String _getLocalized(LocalizedText text) {
    return text.getByLanguage(_selectedLang);
  }
}
