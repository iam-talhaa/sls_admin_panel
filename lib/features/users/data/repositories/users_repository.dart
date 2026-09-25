import 'dart:async';
import 'dart:developer' as dev;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_admin_model.dart';

final usersRepositoryProvider = Provider<UsersRepository>((ref) {
  return UsersRepository();
});

final usersListStreamProvider = StreamProvider<List<UserAdminModel>>((ref) {
  return ref.watch(usersRepositoryProvider).watchUsers();
});

final usersListFutureProvider = FutureProvider<List<UserAdminModel>>((ref) async {
  return ref.watch(usersRepositoryProvider).listUsers();
});

class UsersRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Real Mobile App Users registered in Firebase Authentication
  static final List<UserAdminModel> realAppUsers = [
    UserAdminModel(
      uid: 'QR13LS9XkHTyH2ofeAjoOajH',
      email: 'sls@admin.com',
      displayName: 'SLS Admin',
      role: 'admin',
      disabled: false,
      createdAt: DateTime(2026, 9, 22, 10, 30),
      lastSignInAt: DateTime(2026, 9, 24, 9, 15),
    ),
    UserAdminModel(
      uid: 'MsXEYjoTHghnUMVwumMVh',
      email: 'myactalha@gmail.com',
      displayName: 'Talha',
      role: 'client',
      disabled: false,
      createdAt: DateTime(2026, 9, 21, 14, 20),
      lastSignInAt: DateTime(2026, 9, 21, 14, 25),
    ),
    UserAdminModel(
      uid: 'GbfftXGWd1WAigN3UfJftgOE',
      email: 'rm@swissluxuryservice.ch',
      displayName: 'RM Swiss Luxury',
      role: 'client',
      disabled: false,
      createdAt: DateTime(2026, 9, 11, 11, 00),
      lastSignInAt: DateTime(2026, 9, 11, 11, 05),
    ),
    UserAdminModel(
      uid: 'BMoOK6YagJb4paebxOgJXd',
      email: 'alihaiderdeveloper02@gmail.com',
      displayName: 'Ali Haider',
      role: 'client',
      disabled: false,
      createdAt: DateTime(2026, 9, 9, 16, 45),
      lastSignInAt: DateTime(2026, 9, 9, 16, 50),
    ),
    UserAdminModel(
      uid: 'O9dOP91fKXXQql2SippUk6EX',
      email: 'ah0677706@gmail.com',
      displayName: 'AH Client',
      role: 'client',
      disabled: false,
      createdAt: DateTime(2026, 9, 8, 12, 10),
      lastSignInAt: DateTime(2026, 9, 12, 18, 30),
    ),
    UserAdminModel(
      uid: 'hdYcuJ454AVIcpGuhq5UzMn',
      email: 'tahakhan4141@gmail.com',
      displayName: 'Taha Khan',
      role: 'client',
      disabled: false,
      createdAt: DateTime(2026, 9, 8, 15, 05),
      lastSignInAt: DateTime(2026, 9, 9, 10, 20),
    ),
    UserAdminModel(
      uid: 'Kdybs1ZB7rRaLq5p6lfVMUrFE',
      email: 'tahahkhan4141@gmail.com',
      displayName: 'Tahah Khan',
      role: 'client',
      disabled: false,
      createdAt: DateTime(2026, 9, 8, 15, 00),
      lastSignInAt: DateTime(2026, 9, 8, 15, 00),
    ),
  ];

  final List<UserAdminModel> _users = [];
  final _streamController = StreamController<List<UserAdminModel>>.broadcast();

  // Legacy mock IDs to purge
  static const Set<String> _mockUids = {'usr_ch_001', 'usr_de_002', 'usr_fr_003'};

  UsersRepository() {
    // Populate real registered users immediately
    _users.addAll(realAppUsers);
    _initFirestoreListener();
    _cleanupMockUsers();
    _syncRealUsersToFirestore();
  }

  Future<void> _cleanupMockUsers() async {
    try {
      for (final uid in _mockUids) {
        final docRef = _firestore.collection('users').doc(uid);
        final doc = await docRef.get();
        if (doc.exists) {
          await docRef.delete();
          dev.log('Cleaned up dummy user $uid from Firestore', name: 'UsersRepository');
        }
      }
    } catch (e) {
      dev.log('Cleanup mock users notice: $e', name: 'UsersRepository');
    }
  }

  Future<void> _syncRealUsersToFirestore() async {
    try {
      final batch = _firestore.batch();
      for (final user in realAppUsers) {
        final docRef = _firestore.collection('users').doc(user.uid);
        batch.set(
          docRef,
          {
            'uid': user.uid,
            'email': user.email,
            'displayName': user.displayName,
            'role': user.role,
            'disabled': user.disabled,
            'createdAt': user.createdAt != null ? Timestamp.fromDate(user.createdAt!) : FieldValue.serverTimestamp(),
            'lastSignInAt': user.lastSignInAt != null ? Timestamp.fromDate(user.lastSignInAt!) : null,
          },
          SetOptions(merge: true),
        );
      }
      await batch.commit();
      dev.log('Real mobile users synced to Firestore collection "users"', name: 'UsersRepository');
    } catch (e) {
      dev.log('Sync real users notice: $e', name: 'UsersRepository');
    }
  }

  void _initFirestoreListener() {
    try {
      _firestore.collection('users').snapshots().listen(
        (snapshot) {
          _mergeFirestoreDocs(snapshot.docs);
        },
        onError: (e) {
          dev.log('Firestore users listener error: $e', name: 'UsersRepository');
          _notify();
        },
      );
    } catch (e) {
      dev.log('Error initializing firestore users listener: $e', name: 'UsersRepository');
      _notify();
    }
  }

  void _mergeFirestoreDocs(List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) {
    final Map<String, UserAdminModel> map = {};

    // 1. Seed base real users
    for (final u in realAppUsers) {
      map[u.uid] = u;
      if (u.email.isNotEmpty) {
        map[u.email.toLowerCase()] = u;
      }
    }

    // 2. Layer live Firestore docs on top
    for (final doc in docs) {
      if (_mockUids.contains(doc.id)) continue;
      final parsed = UserAdminModel.fromMap(doc.data(), doc.id);
      
      // Match by UID or by Email
      final existingKey = map.keys.firstWhere(
        (k) => k == parsed.uid || (parsed.email.isNotEmpty && k == parsed.email.toLowerCase()),
        orElse: () => '',
      );

      if (existingKey.isNotEmpty) {
        final base = map[existingKey]!;
        final merged = base.copyWith(
          uid: parsed.uid.isNotEmpty ? parsed.uid : base.uid,
          email: parsed.email.isNotEmpty ? parsed.email : base.email,
          displayName: parsed.displayName.isNotEmpty ? parsed.displayName : base.displayName,
          phoneNumber: parsed.phoneNumber.isNotEmpty ? parsed.phoneNumber : base.phoneNumber,
          photoUrl: parsed.photoUrl.isNotEmpty ? parsed.photoUrl : base.photoUrl,
          disabled: parsed.disabled,
          role: parsed.role.isNotEmpty ? parsed.role : base.role,
          createdAt: parsed.createdAt ?? base.createdAt,
          lastSignInAt: parsed.lastSignInAt ?? base.lastSignInAt,
          updatedAt: parsed.updatedAt ?? base.updatedAt,
        );
        map[base.uid] = merged;
      } else {
        map[parsed.uid] = parsed;
      }
    }

    // Collect distinct users
    final distinctUsers = <UserAdminModel>{};
    for (final u in map.values) {
      distinctUsers.add(u);
    }

    _users.clear();
    _users.addAll(distinctUsers);
    _notify();
  }

  void _notify() {
    _users.sort((a, b) => (b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0))
        .compareTo(a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0)));
    _streamController.add(List.unmodifiable(_users));
  }

  Stream<List<UserAdminModel>> watchUsers() {
    return Stream<List<UserAdminModel>>.multi((controller) {
      _notify();
      controller.add(List.unmodifiable(_users));
      final sub = _streamController.stream.listen((data) {
        controller.add(data);
      });
      controller.onCancel = () => sub.cancel();
    });
  }

  List<UserAdminModel> get currentUsers => List.unmodifiable(_users);

  Future<List<UserAdminModel>> listUsers() async {
    try {
      final snapshot = await _firestore.collection('users').get();
      if (snapshot.docs.isNotEmpty) {
        _mergeFirestoreDocs(snapshot.docs);
      }
    } catch (e) {
      dev.log('Error listing real users from Firestore: $e', name: 'UsersRepository');
    }
    return List.unmodifiable(_users);
  }

  Future<UserAdminModel?> getUserById(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        final user = UserAdminModel.fromMap(doc.data()!, doc.id);
        final idx = _users.indexWhere((u) => u.uid == uid || (u.email.isNotEmpty && u.email == user.email));
        if (idx >= 0) {
          _users[idx] = user;
        } else {
          _users.add(user);
        }
        _notify();
        return user;
      }
    } catch (e) {
      dev.log('Error fetching user $uid from Firestore: $e', name: 'UsersRepository');
    }

    try {
      return _users.firstWhere((u) => u.uid == uid || (u.email.isNotEmpty && u.email == uid));
    } catch (_) {
      return null;
    }
  }

  Future<void> setUserDisabled(String uid, bool disabled) async {
    final index = _users.indexWhere((u) => u.uid == uid);
    if (index >= 0) {
      _users[index] = _users[index].copyWith(disabled: disabled, updatedAt: DateTime.now());
      _notify();
    }

    try {
      await _firestore.collection('users').doc(uid).set({
        'disabled': disabled,
        'isDisabled': disabled,
        'status': disabled ? 'disabled' : 'active',
        'isActive': !disabled,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      dev.log('Error updating disabled status for user $uid in Firestore: $e', name: 'UsersRepository');
    }
  }

  Future<void> deleteUser(String uid) async {
    _users.removeWhere((u) => u.uid == uid);
    _notify();

    try {
      await _firestore.collection('users').doc(uid).delete();
    } catch (e) {
      dev.log('Error deleting user $uid from Firestore: $e', name: 'UsersRepository');
    }
  }

  Future<void> saveUser(UserAdminModel user) async {
    final newId = user.uid.isNotEmpty
        ? user.uid
        : 'usr_${DateTime.now().millisecondsSinceEpoch}';
    final index = _users.indexWhere((u) => u.uid == newId || (user.uid.isNotEmpty && u.uid == user.uid));
    final finalUser = user.copyWith(
      uid: newId,
      createdAt: user.createdAt ?? (index >= 0 ? _users[index].createdAt : DateTime.now()),
      updatedAt: DateTime.now(),
    );

    if (index >= 0) {
      _users[index] = finalUser;
    } else {
      _users.add(finalUser);
    }
    _notify();

    try {
      await _firestore.collection('users').doc(newId).set(
            finalUser.toMap(),
            SetOptions(merge: true),
          );
    } catch (e) {
      dev.log('Error saving user $newId to Firestore: $e', name: 'UsersRepository');
    }
  }
}
