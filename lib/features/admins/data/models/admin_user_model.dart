import 'package:cloud_firestore/cloud_firestore.dart';

enum AdminRole {
  superAdmin('super_admin', 'Super Admin'),
  editor('editor', 'Editor');

  final String value;
  final String label;
  const AdminRole(this.value, this.label);

  static AdminRole fromString(String? role) {
    if (role == 'super_admin') return AdminRole.superAdmin;
    return AdminRole.editor;
  }
}

class AdminUserModel {
  final String uid;
  final String email;
  final String displayName;
  final AdminRole role;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const AdminUserModel({
    required this.uid,
    required this.email,
    this.displayName = '',
    required this.role,
    this.createdAt,
    this.updatedAt,
  });

  bool get isSuperAdmin => role == AdminRole.superAdmin;
  bool get isEditor => role == AdminRole.editor;

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

  factory AdminUserModel.fromMap(Map<String, dynamic> data, String uid) {
    final effectiveUid = uid.isNotEmpty
        ? uid
        : (data['uid']?.toString() ?? data['id']?.toString() ?? '');

    return AdminUserModel(
      uid: effectiveUid,
      email: data['email']?.toString() ?? '',
      displayName: data['displayName']?.toString() ?? data['name']?.toString() ?? '',
      role: AdminRole.fromString(data['role']?.toString()),
      createdAt: _parseDateTime(data['createdAt'] ?? data['timestamp'] ?? data['created_at']),
      updatedAt: _parseDateTime(data['updatedAt'] ?? data['updated_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'role': role.value,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  AdminUserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    AdminRole? role,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AdminUserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
