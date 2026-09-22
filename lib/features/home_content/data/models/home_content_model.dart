import '../../../../core/models/localized_text.dart';

class RouteCardAdminModel {
  final String id;
  final LocalizedText title;
  final LocalizedText category;
  final String duration;
  final String imageUrl;
  final LocalizedText overlayTag;

  const RouteCardAdminModel({
    required this.id,
    required this.title,
    required this.category,
    this.duration = '',
    required this.imageUrl,
    required this.overlayTag,
  });

  factory RouteCardAdminModel.fromMap(Map<String, dynamic> map) {
    return RouteCardAdminModel(
      id: map['id']?.toString() ?? '',
      title: LocalizedText.fromMap(map['title']),
      category: LocalizedText.fromMap(map['category']),
      duration: map['duration']?.toString() ?? '',
      imageUrl: map['imageUrl']?.toString() ?? '',
      overlayTag: LocalizedText.fromMap(map['overlayTag']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title.toMap(),
      'category': category.toMap(),
      'duration': duration,
      'imageUrl': imageUrl,
      'overlayTag': overlayTag.toMap(),
    };
  }

  RouteCardAdminModel copyWith({
    String? id,
    LocalizedText? title,
    LocalizedText? category,
    String? duration,
    String? imageUrl,
    LocalizedText? overlayTag,
  }) {
    return RouteCardAdminModel(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      duration: duration ?? this.duration,
      imageUrl: imageUrl ?? this.imageUrl,
      overlayTag: overlayTag ?? this.overlayTag,
    );
  }
}

class HomeStatAdminModel {
  final String count;
  final LocalizedText label;

  const HomeStatAdminModel({
    required this.count,
    required this.label,
  });

  factory HomeStatAdminModel.fromMap(Map<String, dynamic> map) {
    return HomeStatAdminModel(
      count: map['count']?.toString() ?? '',
      label: LocalizedText.fromMap(map['label']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'count': count,
      'label': label.toMap(),
    };
  }

  HomeStatAdminModel copyWith({
    String? count,
    LocalizedText? label,
  }) {
    return HomeStatAdminModel(
      count: count ?? this.count,
      label: label ?? this.label,
    );
  }
}

class HomeContentAdminModel {
  final List<RouteCardAdminModel> routeCards;
  final List<HomeStatAdminModel> stats;
  final DateTime? updatedAt;

  const HomeContentAdminModel({
    this.routeCards = const [],
    this.stats = const [],
    this.updatedAt,
  });

  factory HomeContentAdminModel.fromMap(Map<String, dynamic> data) {
    List<RouteCardAdminModel> cards = [];
    if (data['routeCards'] is List) {
      cards = (data['routeCards'] as List)
          .map((item) => RouteCardAdminModel.fromMap(Map<String, dynamic>.from(item as Map)))
          .toList();
    }

    List<HomeStatAdminModel> statsList = [];
    if (data['stats'] is List) {
      statsList = (data['stats'] as List)
          .map((item) => HomeStatAdminModel.fromMap(Map<String, dynamic>.from(item as Map)))
          .toList();
    }

    return HomeContentAdminModel(
      routeCards: cards,
      stats: statsList,
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] is DateTime
              ? data['updatedAt'] as DateTime
              : DateTime.tryParse(data['updatedAt'].toString()))
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'routeCards': routeCards.map((e) => e.toMap()).toList(),
      'stats': stats.map((e) => e.toMap()).toList(),
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }
}
