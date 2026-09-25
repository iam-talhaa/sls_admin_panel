import 'package:cloud_firestore/cloud_firestore.dart';

enum QuoteRequestStatus {
  isNew('new', 'New'),
  contacted('contacted', 'Contacted'),
  closed('closed', 'Closed');

  final String value;
  final String label;
  const QuoteRequestStatus(this.value, this.label);

  static QuoteRequestStatus fromString(String? status) {
    final s = status?.toLowerCase().trim();
    if (s == 'contacted' || s == 'in_progress' || s == 'in progress' || s == 'processing') {
      return QuoteRequestStatus.contacted;
    }
    if (s == 'closed' || s == 'completed' || s == 'resolved' || s == 'confirmed') {
      return QuoteRequestStatus.closed;
    }
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
  final DateTime? updatedAt;
  final String? departure;
  final String? destination;
  final String? departureDate;
  final String? returnDate;
  final String? passengers;
  final String? jetType;
  final String? tripType;
  final String? userId;

  const QuoteRequestModel({
    required this.id,
    required this.firstName,
    required this.email,
    required this.phone,
    required this.message,
    this.status = QuoteRequestStatus.isNew,
    this.adminNotes = '',
    this.createdAt,
    this.updatedAt,
    this.departure,
    this.destination,
    this.departureDate,
    this.returnDate,
    this.passengers,
    this.jetType,
    this.tripType,
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

  factory QuoteRequestModel.fromMap(Map<String, dynamic> data, [String id = '']) {
    final name = data['firstName']?.toString() ??
        data['name']?.toString() ??
        data['fullName']?.toString() ??
        data['clientName']?.toString() ??
        '';

    final email = data['email']?.toString() ??
        data['userEmail']?.toString() ??
        data['contactEmail']?.toString() ??
        '';

    final phone = data['phone']?.toString() ??
        data['phoneNumber']?.toString() ??
        data['telephone']?.toString() ??
        '';

    final msg = data['message']?.toString() ??
        data['inquiry']?.toString() ??
        data['details']?.toString() ??
        data['notes']?.toString() ??
        data['requestDetails']?.toString() ??
        '';

    final adminNotes = data['adminNotes']?.toString() ??
        data['internalNotes']?.toString() ??
        data['adminComment']?.toString() ??
        '';

    return QuoteRequestModel(
      id: id.isNotEmpty ? id : (data['id']?.toString() ?? ''),
      firstName: name,
      email: email,
      phone: phone,
      message: msg,
      status: QuoteRequestStatus.fromString(data['status']?.toString()),
      adminNotes: adminNotes,
      createdAt: _parseDateTime(data['createdAt'] ?? data['timestamp'] ?? data['submittedAt'] ?? data['date']),
      updatedAt: _parseDateTime(data['updatedAt']),
      departure: data['departure']?.toString() ?? data['origin']?.toString() ?? data['from']?.toString(),
      destination: data['destination']?.toString() ?? data['arrival']?.toString() ?? data['to']?.toString(),
      departureDate: data['departureDate']?.toString() ?? data['flightDate']?.toString() ?? data['date']?.toString(),
      returnDate: data['returnDate']?.toString(),
      passengers: data['passengers']?.toString() ?? data['passengerCount']?.toString() ?? data['pax']?.toString(),
      jetType: data['jetType']?.toString() ?? data['aircraftType']?.toString() ?? data['jet']?.toString() ?? data['category']?.toString(),
      tripType: data['tripType']?.toString() ?? data['flightType']?.toString(),
      userId: data['userId']?.toString() ?? data['uid']?.toString(),
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
      if (departure != null && departure!.isNotEmpty) 'departure': departure,
      if (destination != null && destination!.isNotEmpty) 'destination': destination,
      if (departureDate != null && departureDate!.isNotEmpty) 'departureDate': departureDate,
      if (returnDate != null && returnDate!.isNotEmpty) 'returnDate': returnDate,
      if (passengers != null && passengers!.isNotEmpty) 'passengers': passengers,
      if (jetType != null && jetType!.isNotEmpty) 'jetType': jetType,
      if (tripType != null && tripType!.isNotEmpty) 'tripType': tripType,
      if (userId != null && userId!.isNotEmpty) 'userId': userId,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
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
    DateTime? updatedAt,
    String? departure,
    String? destination,
    String? departureDate,
    String? returnDate,
    String? passengers,
    String? jetType,
    String? tripType,
    String? userId,
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
      updatedAt: updatedAt ?? this.updatedAt,
      departure: departure ?? this.departure,
      destination: destination ?? this.destination,
      departureDate: departureDate ?? this.departureDate,
      returnDate: returnDate ?? this.returnDate,
      passengers: passengers ?? this.passengers,
      jetType: jetType ?? this.jetType,
      tripType: tripType ?? this.tripType,
      userId: userId ?? this.userId,
    );
  }
}
