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
  final AdminRole role;
  final DateTime? createdAt;

  const AdminUserModel({
    required this.uid,
    required this.email,
    required this.role,
    this.createdAt,
  });

  bool get isSuperAdmin => role == AdminRole.superAdmin;
  bool get isEditor => role == AdminRole.editor;

  factory AdminUserModel.fromMap(Map<String, dynamic> data, String uid) {
    return AdminUserModel(
      uid: uid,
      email: data['email'] ?? '',
      role: AdminRole.fromString(data['role']),
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] is DateTime
              ? data['createdAt'] as DateTime
              : DateTime.tryParse(data['createdAt'].toString()))
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'role': role.value,
      'createdAt': (createdAt ?? DateTime.now()).toIso8601String(),
    };
  }

  AdminUserModel copyWith({
    String? uid,
    String? email,
    AdminRole? role,
    DateTime? createdAt,
  }) {
    return AdminUserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
