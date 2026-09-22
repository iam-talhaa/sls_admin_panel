class LocalizedText {
  final String en;
  final String fr;
  final String de;
  final String ar;

  const LocalizedText({
    this.en = '',
    this.fr = '',
    this.de = '',
    this.ar = '',
  });

  static const empty = LocalizedText(en: '', fr: '', de: '', ar: '');

  bool get isEmpty => en.isEmpty && fr.isEmpty && de.isEmpty && ar.isEmpty;
  bool get isNotEmpty => !isEmpty;

  factory LocalizedText.fromMap(dynamic map) {
    if (map == null) return LocalizedText.empty;
    if (map is String) return LocalizedText(en: map, fr: map, de: map, ar: map);
    if (map is Map) {
      return LocalizedText(
        en: map['en']?.toString() ?? '',
        fr: map['fr']?.toString() ?? '',
        de: map['de']?.toString() ?? '',
        ar: map['ar']?.toString() ?? '',
      );
    }
    return LocalizedText.empty;
  }

  Map<String, dynamic> toMap() => {
        'en': en,
        'fr': fr,
        'de': de,
        'ar': ar,
      };

  LocalizedText copyWith({
    String? en,
    String? fr,
    String? de,
    String? ar,
  }) {
    return LocalizedText(
      en: en ?? this.en,
      fr: fr ?? this.fr,
      de: de ?? this.de,
      ar: ar ?? this.ar,
    );
  }

  String getByLanguage(String lang) {
    switch (lang.toLowerCase()) {
      case 'fr':
        return fr.isNotEmpty ? fr : en;
      case 'de':
        return de.isNotEmpty ? de : en;
      case 'ar':
        return ar.isNotEmpty ? ar : en;
      case 'en':
      default:
        return en.isNotEmpty ? en : (fr.isNotEmpty ? fr : (de.isNotEmpty ? de : ar));
    }
  }

  @override
  String toString() => en.isNotEmpty ? en : (fr.isNotEmpty ? fr : (de.isNotEmpty ? de : ar));
}
