import '../../../../core/models/localized_text.dart';

/// Single screen-level hero banner for the Concierge screen.
class ConciergeBanner {
  final LocalizedText title;
  final LocalizedText subtitle;
  final String imageUrl;

  const ConciergeBanner({
    this.title = LocalizedText.empty,
    this.subtitle = LocalizedText.empty,
    this.imageUrl = '',
  });

  static const empty = ConciergeBanner();

  factory ConciergeBanner.fromMap(Map<String, dynamic>? map) {
    if (map == null) return ConciergeBanner.empty;
    return ConciergeBanner(
      title: LocalizedText.fromMap(map['title']),
      subtitle: LocalizedText.fromMap(map['subtitle']),
      imageUrl: map['imageUrl']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title.toMap(),
        'subtitle': subtitle.toMap(),
        'imageUrl': imageUrl,
      };

  ConciergeBanner copyWith({
    LocalizedText? title,
    LocalizedText? subtitle,
    String? imageUrl,
  }) {
    return ConciergeBanner(
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}

/// Free-form repeatable feature item belonging to a concierge category.
class ConciergeFeature {
  final String id;
  final LocalizedText text;
  final int sortOrder;

  const ConciergeFeature({
    required this.id,
    this.text = LocalizedText.empty,
    this.sortOrder = 0,
  });

  factory ConciergeFeature.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return const ConciergeFeature(id: '');
    }
    return ConciergeFeature(
      id: map['id']?.toString() ?? '',
      text: LocalizedText.fromMap(map['text']),
      sortOrder: (map['sortOrder'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'text': text.toMap(),
        'sortOrder': sortOrder,
      };

  ConciergeFeature copyWith({
    String? id,
    LocalizedText? text,
    int? sortOrder,
  }) {
    return ConciergeFeature(
      id: id ?? this.id,
      text: text ?? this.text,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}

/// Category tab data entity for Concierge services.
class ConciergeCategory {
  final String id;
  final String slug;
  final int sortOrder;
  final LocalizedText tabTitle;
  final LocalizedText categoryTag;
  final LocalizedText title;
  final LocalizedText description;
  final String imageUrl;
  final bool isActive;
  final List<ConciergeFeature> features;

  const ConciergeCategory({
    required this.id,
    required this.slug,
    this.sortOrder = 0,
    this.tabTitle = LocalizedText.empty,
    this.categoryTag = LocalizedText.empty,
    this.title = LocalizedText.empty,
    this.description = LocalizedText.empty,
    this.imageUrl = '',
    this.isActive = true,
    this.features = const [],
  });

  static const empty = ConciergeCategory(
    id: '',
    slug: '',
    sortOrder: 0,
  );

  factory ConciergeCategory.fromMap(Map<String, dynamic>? map, [String? docId]) {
    if (map == null) return ConciergeCategory.empty;

    final rawFeatures = map['features'];
    List<ConciergeFeature> parsedFeatures = [];
    if (rawFeatures is List) {
      parsedFeatures = rawFeatures
          .map((item) => ConciergeFeature.fromMap(
                item is Map ? Map<String, dynamic>.from(item) : null,
              ))
          .toList();
    }

    return ConciergeCategory(
      id: docId ?? (map['id']?.toString() ?? ''),
      slug: map['slug']?.toString() ?? '',
      sortOrder: (map['sortOrder'] as num?)?.toInt() ?? 0,
      tabTitle: LocalizedText.fromMap(map['tabTitle']),
      categoryTag: LocalizedText.fromMap(map['categoryTag']),
      title: LocalizedText.fromMap(map['title']),
      description: LocalizedText.fromMap(map['description']),
      imageUrl: map['imageUrl']?.toString() ?? '',
      isActive: map['isActive'] as bool? ?? true,
      features: parsedFeatures,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'slug': slug,
        'sortOrder': sortOrder,
        'tabTitle': tabTitle.toMap(),
        'categoryTag': categoryTag.toMap(),
        'title': title.toMap(),
        'description': description.toMap(),
        'imageUrl': imageUrl,
        'isActive': isActive,
        'features': features.map((f) => f.toMap()).toList(),
      };

  ConciergeCategory copyWith({
    String? id,
    String? slug,
    int? sortOrder,
    LocalizedText? tabTitle,
    LocalizedText? categoryTag,
    LocalizedText? title,
    LocalizedText? description,
    String? imageUrl,
    bool? isActive,
    List<ConciergeFeature>? features,
  }) {
    return ConciergeCategory(
      id: id ?? this.id,
      slug: slug ?? this.slug,
      sortOrder: sortOrder ?? this.sortOrder,
      tabTitle: tabTitle ?? this.tabTitle,
      categoryTag: categoryTag ?? this.categoryTag,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
      features: features ?? this.features,
    );
  }
}
