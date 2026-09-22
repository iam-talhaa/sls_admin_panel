enum ConciergeRequestStatus {
  isNew('new', 'New'),
  inProgress('in_progress', 'In Progress'),
  resolved('resolved', 'Resolved');

  final String value;
  final String label;
  const ConciergeRequestStatus(this.value, this.label);

  static ConciergeRequestStatus fromString(String? status) {
    if (status == 'in_progress') return ConciergeRequestStatus.inProgress;
    if (status == 'resolved') return ConciergeRequestStatus.resolved;
    return ConciergeRequestStatus.isNew;
  }
}

class ConciergeRequestModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String requestDetails;
  final ConciergeRequestStatus status;
  final String adminNotes;
  final DateTime? createdAt;

  const ConciergeRequestModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.requestDetails,
    this.status = ConciergeRequestStatus.isNew,
    this.adminNotes = '',
    this.createdAt,
  });

  factory ConciergeRequestModel.fromMap(Map<String, dynamic> data, [String id = '']) {
    return ConciergeRequestModel(
      id: id.isNotEmpty ? id : (data['id']?.toString() ?? ''),
      name: data['name']?.toString() ?? '',
      email: data['email']?.toString() ?? '',
      phone: data['phone']?.toString() ?? '',
      requestDetails: data['requestDetails']?.toString() ?? '',
      status: ConciergeRequestStatus.fromString(data['status']?.toString()),
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
      'name': name,
      'email': email,
      'phone': phone,
      'requestDetails': requestDetails,
      'status': status.value,
      'adminNotes': adminNotes,
      'createdAt': (createdAt ?? DateTime.now()).toIso8601String(),
    };
  }

  ConciergeRequestModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? requestDetails,
    ConciergeRequestStatus? status,
    String? adminNotes,
    DateTime? createdAt,
  }) {
    return ConciergeRequestModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      requestDetails: requestDetails ?? this.requestDetails,
      status: status ?? this.status,
      adminNotes: adminNotes ?? this.adminNotes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
