import '../../../../core/models/content_block.dart';
import '../../../../core/models/localized_text.dart';

class BlogAdminModel {
  final String id;
  final LocalizedText title;
  final LocalizedText excerpt;
  final String imageUrl;
  final List<ContentBlock> contentBlocks;
  final bool isPublished;
  final DateTime? publishedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const BlogAdminModel({
    required this.id,
    required this.title,
    required this.excerpt,
    required this.imageUrl,
    this.contentBlocks = const [],
    this.isPublished = false,
    this.publishedAt,
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

  factory BlogAdminModel.fromMap(Map<String, dynamic> data, [String id = '']) {
    List<ContentBlock> blocks = [];
    if (data['contentBlocks'] is List) {
      blocks = (data['contentBlocks'] as List)
          .map((item) => ContentBlock.fromMap(Map<String, dynamic>.from(item as Map)))
          .toList();
    }

    return BlogAdminModel(
      id: id.isNotEmpty ? id : (data['id']?.toString() ?? ''),
      title: LocalizedText.fromMap(data['title']),
      excerpt: LocalizedText.fromMap(data['excerpt']),
      imageUrl: data['imageUrl']?.toString() ?? '',
      contentBlocks: blocks,
      isPublished: data['isPublished'] == true,
      publishedAt: _parseDateTime(data['publishedAt']),
      createdAt: _parseDateTime(data['createdAt']),
      updatedAt: _parseDateTime(data['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title.toMap(),
      'excerpt': excerpt.toMap(),
      'imageUrl': imageUrl,
      'contentBlocks': contentBlocks.map((e) => e.toMap()).toList(),
      'isPublished': isPublished,
      'publishedAt': publishedAt?.toIso8601String(),
      'createdAt': (createdAt ?? DateTime.now()).toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }

  BlogAdminModel copyWith({
    String? id,
    LocalizedText? title,
    LocalizedText? excerpt,
    String? imageUrl,
    List<ContentBlock>? contentBlocks,
    bool? isPublished,
    DateTime? publishedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BlogAdminModel(
      id: id ?? this.id,
      title: title ?? this.title,
      excerpt: excerpt ?? this.excerpt,
      imageUrl: imageUrl ?? this.imageUrl,
      contentBlocks: contentBlocks ?? this.contentBlocks,
      isPublished: isPublished ?? this.isPublished,
      publishedAt: publishedAt ?? this.publishedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
