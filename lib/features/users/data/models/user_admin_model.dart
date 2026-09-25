import 'package:cloud_firestore/cloud_firestore.dart';

class UserAdminModel {
  final String uid;
  final String email;
  final String displayName;
  final String photoUrl;
  final String phoneNumber;
  final bool disabled;
  final String role;
  final DateTime? createdAt;
  final DateTime? lastSignInAt;
  final DateTime? updatedAt;

  const UserAdminModel({
    required this.uid,
    required this.email,
    this.displayName = '',
    this.photoUrl = '',
    this.phoneNumber = '',
    this.disabled = false,
    this.role = 'user',
    this.createdAt,
    this.lastSignInAt,
    this.updatedAt,
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

  factory UserAdminModel.fromMap(Map<String, dynamic> map, [String id = '']) {
    final uid = id.isNotEmpty
        ? id
        : (map['uid']?.toString() ??
            map['id']?.toString() ??
            map['userId']?.toString() ??
            map['user_id']?.toString() ??
            '');

    final email = map['email']?.toString() ??
        map['userEmail']?.toString() ??
        map['user_email']?.toString() ??
        map['mail']?.toString() ??
        '';

    String name = map['displayName']?.toString() ??
        map['name']?.toString() ??
        map['fullName']?.toString() ??
        map['full_name']?.toString() ??
        map['userName']?.toString() ??
        map['username']?.toString() ??
        '';

    if (name.isEmpty) {
      final first = map['firstName']?.toString() ?? map['first_name']?.toString() ?? '';
      final last = map['lastName']?.toString() ?? map['last_name']?.toString() ?? '';
      name = '$first $last'.trim();
    }

    final phone = map['phoneNumber']?.toString() ??
        map['phone']?.toString() ??
        map['phone_number']?.toString() ??
        map['telephone']?.toString() ??
        map['mobile']?.toString() ??
        map['contact']?.toString() ??
        map['contactNumber']?.toString() ??
        '';

    final photo = map['photoUrl']?.toString() ??
        map['photoURL']?.toString() ??
        map['photo_url']?.toString() ??
        map['profilePic']?.toString() ??
        map['profilePicture']?.toString() ??
        map['profile_picture']?.toString() ??
        map['profileImage']?.toString() ??
        map['profile_image']?.toString() ??
        map['avatar']?.toString() ??
        map['avatarUrl']?.toString() ??
        map['avatar_url']?.toString() ??
        map['imageUrl']?.toString() ??
        map['image_url']?.toString() ??
        '';

    final isDisabled = map['disabled'] == true ||
        map['isDisabled'] == true ||
        map['is_disabled'] == true ||
        map['isBlocked'] == true ||
        map['is_blocked'] == true ||
        map['status'] == 'disabled' ||
        map['status'] == 'inactive' ||
        map['status'] == 'blocked' ||
        map['status'] == 'suspended' ||
        map['isActive'] == false ||
        map['is_active'] == false;

    final role = map['role']?.toString() ??
        map['userRole']?.toString() ??
        map['user_role']?.toString() ??
        map['userType']?.toString() ??
        map['user_type']?.toString() ??
        'client';

    final createdAt = _parseDateTime(
      map['createdAt'] ??
          map['created_at'] ??
          map['timestamp'] ??
          map['registrationDate'] ??
          map['registration_date'] ??
          map['registeredAt'] ??
          map['registered_at'] ??
          map['joinedAt'] ??
          map['joined_at'] ??
          map['date_created'] ??
          map['dateCreated'] ??
          map['createdDate'],
    );

    final lastSignInAt = _parseDateTime(
      map['lastSignInAt'] ??
          map['last_sign_in_at'] ??
          map['lastLogin'] ??
          map['last_login'] ??
          map['lastActiveAt'] ??
          map['last_active_at'] ??
          map['lastActive'] ??
          map['last_active'] ??
          map['last_seen'] ??
          map['lastSeen'],
    );

    final updatedAt = _parseDateTime(map['updatedAt'] ?? map['updated_at']);

    return UserAdminModel(
      uid: uid,
      email: email,
      displayName: name,
      photoUrl: photo,
      phoneNumber: phone,
      disabled: isDisabled,
      role: role,
      createdAt: createdAt,
      lastSignInAt: lastSignInAt,
      updatedAt: updatedAt,
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
      'role': role,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'lastSignInAt': lastSignInAt != null ? Timestamp.fromDate(lastSignInAt!) : null,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  UserAdminModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoUrl,
    String? phoneNumber,
    bool? disabled,
    String? role,
    DateTime? createdAt,
    DateTime? lastSignInAt,
    DateTime? updatedAt,
  }) {
    return UserAdminModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      disabled: disabled ?? this.disabled,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      lastSignInAt: lastSignInAt ?? this.lastSignInAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
