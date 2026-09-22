class SettingsModel {
  final String recipientEmail;
  final String companyName;
  final String supportEmail;
  final String supportPhone;
  final String currency;
  final bool maintenanceMode;
  final DateTime? updatedAt;

  const SettingsModel({
    this.recipientEmail = 'quote@swissluxuryservices.ch',
    this.companyName = 'Swiss Luxury Services',
    this.supportEmail = 'info@swissluxuryservices.ch',
    this.supportPhone = '+41 44 123 45 67',
    this.currency = 'CHF',
    this.maintenanceMode = false,
    this.updatedAt,
  });

  factory SettingsModel.fromMap(Map<String, dynamic> data) {
    return SettingsModel(
      recipientEmail: data['recipientEmail']?.toString() ?? 'quote@swissluxuryservices.ch',
      companyName: data['companyName']?.toString() ?? 'Swiss Luxury Services',
      supportEmail: data['supportEmail']?.toString() ?? 'info@swissluxuryservices.ch',
      supportPhone: data['supportPhone']?.toString() ?? '+41 44 123 45 67',
      currency: data['currency']?.toString() ?? 'CHF',
      maintenanceMode: data['maintenanceMode'] == true,
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] is DateTime
              ? data['updatedAt'] as DateTime
              : DateTime.tryParse(data['updatedAt'].toString()))
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'recipientEmail': recipientEmail,
      'companyName': companyName,
      'supportEmail': supportEmail,
      'supportPhone': supportPhone,
      'currency': currency,
      'maintenanceMode': maintenanceMode,
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }

  SettingsModel copyWith({
    String? recipientEmail,
    String? companyName,
    String? supportEmail,
    String? supportPhone,
    String? currency,
    bool? maintenanceMode,
    DateTime? updatedAt,
  }) {
    return SettingsModel(
      recipientEmail: recipientEmail ?? this.recipientEmail,
      companyName: companyName ?? this.companyName,
      supportEmail: supportEmail ?? this.supportEmail,
      supportPhone: supportPhone ?? this.supportPhone,
      currency: currency ?? this.currency,
      maintenanceMode: maintenanceMode ?? this.maintenanceMode,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
