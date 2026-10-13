import '../../../../core/constants/firebase_asset_urls.dart';
import '../../../../core/models/localized_text.dart';

class JetAdminModel {
  final String id;
  final int order;
  final String category;
  final String imageUrl;
  final LocalizedText name;
  final LocalizedText seating;
  final LocalizedText range;
  final LocalizedText description;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const JetAdminModel({
    required this.id,
    this.order = 0,
    required this.category,
    required this.imageUrl,
    required this.name,
    required this.seating,
    required this.range,
    required this.description,
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

  factory JetAdminModel.fromMap(Map<String, dynamic> data, [String id = '']) {
    String parsedCategory = 'LIGHT JET';
    if (data['category'] is Map) {
      parsedCategory = LocalizedText.fromMap(data['category']).en;
    } else if (data['category'] != null) {
      parsedCategory = data['category'].toString();
    }

    final parsedName = LocalizedText.fromMap(data['name'] ?? data['title']);

    LocalizedText parsedSeating;
    if (data['seating'] != null) {
      parsedSeating = LocalizedText.fromMap(data['seating']);
    } else if (data['seatingCapacity'] != null) {
      parsedSeating = LocalizedText(en: 'Up to ${data['seatingCapacity']} passengers');
    } else {
      parsedSeating = const LocalizedText(en: 'SEATING : UP TO 4');
    }

    LocalizedText parsedRange;
    if (data['range'] != null) {
      parsedRange = LocalizedText.fromMap(data['range']);
    } else if (data['rangeKm'] != null) {
      parsedRange = LocalizedText(en: '${data['rangeKm']} km');
    } else {
      parsedRange = const LocalizedText(en: 'RANGE : UP TO 2.5 HOURS');
    }

    return JetAdminModel(
      id: id.isNotEmpty ? id : (data['id']?.toString() ?? ''),
      order: (data['order'] is num) ? (data['order'] as num).toInt() : 0,
      category: parsedCategory.isNotEmpty ? parsedCategory : 'LIGHT JET',
      imageUrl: FirebaseAssetUrls.getUrl(data['imageUrl']?.toString() ?? ''),
      name: parsedName,
      seating: parsedSeating,
      range: parsedRange,
      description: LocalizedText.fromMap(data['description']),
      isActive: data['isActive'] == true || data['isActive'] == null,
      createdAt: _parseDateTime(data['createdAt']),
      updatedAt: _parseDateTime(data['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'order': order,
      'category': category,
      'imageUrl': imageUrl,
      'name': name.toMap(),
      'seating': seating.toMap(),
      'range': range.toMap(),
      'description': description.toMap(),
      'isActive': isActive,
      'createdAt': (createdAt ?? DateTime.now()).toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }

  JetAdminModel copyWith({
    String? id,
    int? order,
    String? category,
    String? imageUrl,
    LocalizedText? name,
    LocalizedText? seating,
    LocalizedText? range,
    LocalizedText? description,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return JetAdminModel(
      id: id ?? this.id,
      order: order ?? this.order,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      name: name ?? this.name,
      seating: seating ?? this.seating,
      range: range ?? this.range,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
