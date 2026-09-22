enum QuoteRequestStatus {
  isNew('new', 'New'),
  contacted('contacted', 'Contacted'),
  closed('closed', 'Closed');

  final String value;
  final String label;
  const QuoteRequestStatus(this.value, this.label);

  static QuoteRequestStatus fromString(String? status) {
    if (status == 'contacted') return QuoteRequestStatus.contacted;
    if (status == 'closed') return QuoteRequestStatus.closed;
    return QuoteRequestStatus.isNew;
  }
}

class QuoteRequestModel {
  final String id;
  final String firstName;
  final String email;
  final String phone;
  final String message;
  final QuoteRequestStatus status;
  final String adminNotes;
  final DateTime? createdAt;

  const QuoteRequestModel({
    required this.id,
    required this.firstName,
    required this.email,
    required this.phone,
    required this.message,
    this.status = QuoteRequestStatus.isNew,
    this.adminNotes = '',
    this.createdAt,
  });

  factory QuoteRequestModel.fromMap(Map<String, dynamic> data, [String id = '']) {
    return QuoteRequestModel(
      id: id.isNotEmpty ? id : (data['id']?.toString() ?? ''),
      firstName: data['firstName']?.toString() ?? '',
      email: data['email']?.toString() ?? '',
      phone: data['phone']?.toString() ?? '',
      message: data['message']?.toString() ?? '',
      status: QuoteRequestStatus.fromString(data['status']?.toString()),
      adminNotes: data['adminNotes']?.toString() ?? '',
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] is DateTime
              ? data['createdAt'] as DateTime
              : DateTime.tryParse(data['createdAt'].toString()))
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firstName': firstName,
      'email': email,
      'phone': phone,
      'message': message,
      'status': status.value,
      'adminNotes': adminNotes,
      'createdAt': (createdAt ?? DateTime.now()).toIso8601String(),
    };
  }

  QuoteRequestModel copyWith({
    String? id,
    String? firstName,
    String? email,
    String? phone,
    String? message,
    QuoteRequestStatus? status,
    String? adminNotes,
    DateTime? createdAt,
  }) {
    return QuoteRequestModel(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      message: message ?? this.message,
      status: status ?? this.status,
      adminNotes: adminNotes ?? this.adminNotes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
