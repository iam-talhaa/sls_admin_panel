import 'localized_text.dart';

enum ContentBlockType {
  paragraph('paragraph', 'Paragraph'),
  subheading('subheading', 'Subheading'),
  bulletList('bulletList', 'Bullet List'),
  linkReference('linkReference', 'Link Reference');

  final String value;
  final String label;
  const ContentBlockType(this.value, this.label);

  static ContentBlockType fromString(String? type) {
    if (type == 'subheading') return ContentBlockType.subheading;
    if (type == 'bulletList') return ContentBlockType.bulletList;
    if (type == 'linkReference') return ContentBlockType.linkReference;
    return ContentBlockType.paragraph;
  }
}

class ContentBlock {
  final ContentBlockType type;
  final LocalizedText text;
  final List<LocalizedText> items; // For bullet lists
  final String linkUrl; // For linkReference

  const ContentBlock({
    required this.type,
    this.text = LocalizedText.empty,
    this.items = const [],
    this.linkUrl = '',
  });

  factory ContentBlock.fromMap(Map<String, dynamic> map) {
    final type = ContentBlockType.fromString(map['type']?.toString());
    final text = LocalizedText.fromMap(map['text']);

    List<LocalizedText> items = [];
    if (map['items'] is List) {
      items = (map['items'] as List)
          .map((item) => LocalizedText.fromMap(item))
          .toList();
    }

    return ContentBlock(
      type: type,
      text: text,
      items: items,
      linkUrl: map['linkUrl']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type.value,
      'text': text.toMap(),
      'items': items.map((e) => e.toMap()).toList(),
      'linkUrl': linkUrl,
    };
  }

  ContentBlock copyWith({
    ContentBlockType? type,
    LocalizedText? text,
    List<LocalizedText>? items,
    String? linkUrl,
  }) {
    return ContentBlock(
      type: type ?? this.type,
      text: text ?? this.text,
      items: items ?? this.items,
      linkUrl: linkUrl ?? this.linkUrl,
    );
  }
}
