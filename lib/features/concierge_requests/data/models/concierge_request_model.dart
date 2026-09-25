import 'package:cloud_firestore/cloud_firestore.dart';

enum ConciergeRequestStatus {
  isNew('new', 'New'),
  inProgress('in_progress', 'In Progress'),
  resolved('resolved', 'Resolved');

  final String value;
  final String label;
  const ConciergeRequestStatus(this.value, this.label);

  static ConciergeRequestStatus fromString(String? status) {
    final s = status?.toLowerCase().trim();
    if (s == 'in_progress' || s == 'inprogress' || s == 'contacted' || s == 'processing' || s == 'in progress') {
      return ConciergeRequestStatus.inProgress;
    }
    if (s == 'resolved' || s == 'closed' || s == 'completed' || s == 'confirmed') {
      return ConciergeRequestStatus.resolved;
    }
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
  final DateTime? updatedAt;
  final String? serviceCategory;
  final String? preferredDate;
  final String? userId;

  const ConciergeRequestModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.requestDetails,
    this.status = ConciergeRequestStatus.isNew,
    this.adminNotes = '',
    this.createdAt,
    this.updatedAt,
    this.serviceCategory,
    this.preferredDate,
    this.userId,
  });

  static DateTime? _parseDateTime(dynamic val) {
    if (val == null) return null;
    if (val is DateTime) return val;
    if (val is Timestamp) return val.toDate();
    try {
      return (val as dynamic).toDate();
    } catch (_) {}
    if (val is int) {
      return DateTime.fromMillisecondsSinceEpoch(val);
    }
    return DateTime.tryParse(val.toString());
  }

  factory ConciergeRequestModel.fromMap(Map<String, dynamic> data, [String id = '']) {
    final name = data['name']?.toString() ??
        data['clientName']?.toString() ??
        data['fullName']?.toString() ??
        data['guestName']?.toString() ??
        data['firstName']?.toString() ??
        '';

    final email = data['email']?.toString() ??
        data['userEmail']?.toString() ??
        data['contactEmail']?.toString() ??
        '';

    final phone = data['phone']?.toString() ??
        data['phoneNumber']?.toString() ??
        data['telephone']?.toString() ??
        '';

    final details = data['requestDetails']?.toString() ??
        data['message']?.toString() ??
        data['details']?.toString() ??
        data['notes']?.toString() ??
        data['requirements']?.toString() ??
        '';

    final adminNotes = data['adminNotes']?.toString() ??
        data['internalNotes']?.toString() ??
        data['adminComment']?.toString() ??
        '';

    return ConciergeRequestModel(
      id: id.isNotEmpty ? id : (data['id']?.toString() ?? ''),
      name: name,
      email: email,
      phone: phone,
      requestDetails: details,
      status: ConciergeRequestStatus.fromString(data['status']?.toString()),
      adminNotes: adminNotes,
      createdAt: _parseDateTime(data['createdAt'] ?? data['timestamp'] ?? data['submittedAt'] ?? data['date']),
      updatedAt: _parseDateTime(data['updatedAt']),
      serviceCategory: data['serviceCategory']?.toString() ?? data['category']?.toString() ?? data['categoryTitle']?.toString() ?? data['service']?.toString(),
      preferredDate: data['preferredDate']?.toString() ?? data['date']?.toString() ?? data['requestedDate']?.toString(),
      userId: data['userId']?.toString() ?? data['uid']?.toString(),
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
      if (serviceCategory != null && serviceCategory!.isNotEmpty) 'serviceCategory': serviceCategory,
      if (preferredDate != null && preferredDate!.isNotEmpty) 'preferredDate': preferredDate,
      if (userId != null && userId!.isNotEmpty) 'userId': userId,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
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
    DateTime? updatedAt,
    String? serviceCategory,
    String? preferredDate,
    String? userId,
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
      updatedAt: updatedAt ?? this.updatedAt,
      serviceCategory: serviceCategory ?? this.serviceCategory,
      preferredDate: preferredDate ?? this.preferredDate,
      userId: userId ?? this.userId,
    );
  }
}
