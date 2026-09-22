class UserAdminModel {
  final String uid;
  final String email;
  final String displayName;
  final String photoUrl;
  final String phoneNumber;
  final bool disabled;
  final DateTime? createdAt;
  final DateTime? lastSignInAt;

  const UserAdminModel({
    required this.uid,
    required this.email,
    this.displayName = '',
    this.photoUrl = '',
    this.phoneNumber = '',
    this.disabled = false,
    this.createdAt,
    this.lastSignInAt,
  });

  factory UserAdminModel.fromMap(Map<String, dynamic> map) {
    return UserAdminModel(
      uid: map['uid']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      displayName: map['displayName']?.toString() ?? map['name']?.toString() ?? '',
      photoUrl: map['photoUrl']?.toString() ?? '',
      phoneNumber: map['phoneNumber']?.toString() ?? '',
      disabled: map['disabled'] == true,
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] is int
              ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'])
              : DateTime.tryParse(map['createdAt'].toString()))
          : null,
      lastSignInAt: map['lastSignInAt'] != null
          ? (map['lastSignInAt'] is int
              ? DateTime.fromMillisecondsSinceEpoch(map['lastSignInAt'])
              : DateTime.tryParse(map['lastSignInAt'].toString()))
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'phoneNumber': phoneNumber,
      'disabled': disabled,
      'createdAt': createdAt?.toIso8601String(),
      'lastSignInAt': lastSignInAt?.toIso8601String(),
    };
  }

  UserAdminModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoUrl,
    String? phoneNumber,
    bool? disabled,
    DateTime? createdAt,
    DateTime? lastSignInAt,
  }) {
    return UserAdminModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      disabled: disabled ?? this.disabled,
      createdAt: createdAt ?? this.createdAt,
      lastSignInAt: lastSignInAt ?? this.lastSignInAt,
    );
  }
}
