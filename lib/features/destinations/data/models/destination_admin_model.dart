import '../../../../core/models/content_block.dart';
import '../../../../core/models/localized_text.dart';

class DestinationAdminModel {
  final String id;
  final int order;
  final LocalizedText title;
  final LocalizedText category;
  final String duration;
  final String imageUrl;
  final LocalizedText overlayTag;
  final String jetType;
  final LocalizedText seating;
  final LocalizedText range;
  final LocalizedText? route;
  final LocalizedText? startingPrice;
  final LocalizedText description;
  final List<LocalizedText> whyTravelWithUs;
  final List<ContentBlock> contentBlocks;
  final LocalizedText? heading;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const DestinationAdminModel({
    required this.id,
    this.order = 0,
    required this.title,
    required this.category,
    this.duration = '',
    required this.imageUrl,
    required this.overlayTag,
    this.jetType = 'Light Jet',
    this.seating = const LocalizedText(en: 'SEATING : UP TO 4'),
    this.range = const LocalizedText(en: 'RANGE : UP TO 2.5 HOURS'),
    this.route,
    this.startingPrice,
    this.description = LocalizedText.empty,
    this.whyTravelWithUs = const [],
    this.contentBlocks = const [],
    this.heading,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  static DateTime? _parseDateTime(dynamic val) {
    if (val == null) return null;
    if (val is DateTime) return val;
    try {
      return (val as dynamic).toDate();
    } catch (_) {}
    return DateTime.tryParse(val.toString());
  }

  factory DestinationAdminModel.fromMap(Map<String, dynamic> data, [String id = '']) {
    List<LocalizedText> whyList = [];
    if (data['whyTravelWithUs'] is List) {
      whyList = (data['whyTravelWithUs'] as List)
          .map((item) => LocalizedText.fromMap(item))
          .toList();
    }

    List<ContentBlock> blocks = [];
    if (data['contentBlocks'] is List) {
      blocks = (data['contentBlocks'] as List)
          .map((item) => ContentBlock.fromMap(Map<String, dynamic>.from(item as Map)))
          .toList();
    }

    return DestinationAdminModel(
      id: id.isNotEmpty ? id : (data['id']?.toString() ?? ''),
      order: (data['order'] is num) ? (data['order'] as num).toInt() : 0,
      title: LocalizedText.fromMap(data['title']),
      category: LocalizedText.fromMap(data['category']),
      duration: data['duration']?.toString() ?? '',
      imageUrl: data['imageUrl']?.toString() ?? '',
      overlayTag: LocalizedText.fromMap(data['overlayTag']),
      jetType: data['jetType']?.toString() ?? 'Light Jet',
      seating: LocalizedText.fromMap(data['seating']),
      range: LocalizedText.fromMap(data['range']),
      route: data['route'] != null ? LocalizedText.fromMap(data['route']) : null,
      startingPrice: data['startingPrice'] != null ? LocalizedText.fromMap(data['startingPrice']) : null,
      description: LocalizedText.fromMap(data['description']),
      whyTravelWithUs: whyList,
      contentBlocks: blocks,
      heading: data['heading'] != null ? LocalizedText.fromMap(data['heading']) : null,
      isActive: data['isActive'] == true || data['isActive'] == null,
      createdAt: _parseDateTime(data['createdAt']),
      updatedAt: _parseDateTime(data['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'order': order,
      'title': title.toMap(),
      'category': category.toMap(),
      'duration': duration,
      'imageUrl': imageUrl,
      'overlayTag': overlayTag.toMap(),
      'jetType': jetType,
      'seating': seating.toMap(),
      'range': range.toMap(),
      'route': route?.toMap(),
      'startingPrice': startingPrice?.toMap(),
      'description': description.toMap(),
      'whyTravelWithUs': whyTravelWithUs.map((e) => e.toMap()).toList(),
      'contentBlocks': contentBlocks.map((e) => e.toMap()).toList(),
      'heading': heading?.toMap(),
      'isActive': isActive,
      'createdAt': (createdAt ?? DateTime.now()).toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }

  DestinationAdminModel copyWith({
    String? id,
    int? order,
    LocalizedText? title,
    LocalizedText? category,
    String? duration,
    String? imageUrl,
    LocalizedText? overlayTag,
    String? jetType,
    LocalizedText? seating,
    LocalizedText? range,
    LocalizedText? route,
    LocalizedText? startingPrice,
    LocalizedText? description,
    List<LocalizedText>? whyTravelWithUs,
    List<ContentBlock>? contentBlocks,
    LocalizedText? heading,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DestinationAdminModel(
      id: id ?? this.id,
      order: order ?? this.order,
      title: title ?? this.title,
      category: category ?? this.category,
      duration: duration ?? this.duration,
      imageUrl: imageUrl ?? this.imageUrl,
      overlayTag: overlayTag ?? this.overlayTag,
      jetType: jetType ?? this.jetType,
      seating: seating ?? this.seating,
      range: range ?? this.range,
      route: route ?? this.route,
      startingPrice: startingPrice ?? this.startingPrice,
      description: description ?? this.description,
      whyTravelWithUs: whyTravelWithUs ?? this.whyTravelWithUs,
      contentBlocks: contentBlocks ?? this.contentBlocks,
      heading: heading ?? this.heading,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
