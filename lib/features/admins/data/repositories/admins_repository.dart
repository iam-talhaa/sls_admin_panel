import 'dart:async';
import 'dart:developer' as dev;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/admin_user_model.dart';

final adminsRepositoryProvider = Provider<AdminsRepository>((ref) {
  return AdminsRepository();
});

final adminsListStreamProvider = StreamProvider<List<AdminUserModel>>((ref) {
  return ref.watch(adminsRepositoryProvider).watchAdmins();
});

class AdminsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static final List<AdminUserModel> defaultAdmins = [
    AdminUserModel(
      uid: 'QR13LS9XkHTyH2ofeAjoOajH',
      email: 'sls@admin.com',
      displayName: 'SLS Super Admin',
      role: AdminRole.superAdmin,
      createdAt: DateTime.now().subtract(const Duration(days: 90)),
    ),
    AdminUserModel(
      uid: 'admin_primary_01',
      email: 'admin@swissluxuryservices.ch',
      displayName: 'Executive Admin',
      role: AdminRole.superAdmin,
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
    ),
  ];

  final List<AdminUserModel> _admins = [];
  final _streamController = StreamController<List<AdminUserModel>>.broadcast();
  bool _isSeeded = false;

  AdminsRepository() {
    _admins.addAll(defaultAdmins);
    _initFirestoreListener();
  }

  void _initFirestoreListener() {
    try {
      _firestore.collection('admins').snapshots().listen(
        (snapshot) {
          if (snapshot.docs.isNotEmpty) {
            _admins.clear();
            for (final doc in snapshot.docs) {
              _admins.add(AdminUserModel.fromMap(doc.data(), doc.id));
            }
            _notify();
          } else if (!_isSeeded) {
            _isSeeded = true;
            seedInitialAdmins();
          }
        },
        onError: (e) {
          dev.log('Firestore admins listener error: $e', name: 'AdminsRepository');
          _notify();
        },
      );
    } catch (e) {
      dev.log('Error initializing firestore admins: $e', name: 'AdminsRepository');
      _notify();
    }
  }

  Future<void> seedInitialAdmins({bool force = false}) async {
    try {
      if (!force) {
        final existing = await _firestore.collection('admins').limit(1).get();
        if (existing.docs.isNotEmpty) return;
      }

      final batch = _firestore.batch();
      for (final admin in defaultAdmins) {
        final docRef = _firestore.collection('admins').doc(admin.uid);
        batch.set(docRef, admin.toMap(), SetOptions(merge: true));
      }
      await batch.commit();
      dev.log('Initial admins seeded successfully to Firestore', name: 'AdminsRepository');
    } catch (e) {
      dev.log('Error seeding initial admins to Firestore: $e', name: 'AdminsRepository');
      if (_admins.isEmpty) {
        _admins.addAll(defaultAdmins);
        _notify();
      }
    }
  }

  void _notify() {
    _admins.sort((a, b) {
      if (a.role != b.role) {
        return a.isSuperAdmin ? -1 : 1;
      }
      return (b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0))
          .compareTo(a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0));
    });
    _streamController.add(List.unmodifiable(_admins));
  }

  Stream<List<AdminUserModel>> watchAdmins() {
    return Stream<List<AdminUserModel>>.multi((controller) {
      _notify();
      controller.add(List.unmodifiable(_admins));
      final sub = _streamController.stream.listen((data) {
        controller.add(data);
      });
      controller.onCancel = () => sub.cancel();
    });
  }

  List<AdminUserModel> get currentAdmins => List.unmodifiable(_admins);

  Future<List<AdminUserModel>> listAdmins() async {
    try {
      final snapshot = await _firestore.collection('admins').get();
      if (snapshot.docs.isNotEmpty) {
        _admins.clear();
        for (final doc in snapshot.docs) {
          _admins.add(AdminUserModel.fromMap(doc.data(), doc.id));
        }
        _notify();
      }
    } catch (e) {
      dev.log('Error listing admins from Firestore: $e', name: 'AdminsRepository');
    }
    return List.unmodifiable(_admins);
  }

  Future<void> addOrUpdateAdmin({
    required String uidOrEmail,
    required String email,
    required AdminRole role,
    String? displayName,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    final docId = uidOrEmail.trim().isNotEmpty
        ? uidOrEmail.trim()
        : 'admin_${cleanEmail.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}';

    final index = _admins.indexWhere((a) => a.uid == docId || a.email.toLowerCase() == cleanEmail);
    final now = DateTime.now();

    final newAdmin = AdminUserModel(
      uid: docId,
      email: cleanEmail,
      displayName: displayName?.trim() ?? (index >= 0 ? _admins[index].displayName : ''),
      role: role,
      createdAt: index >= 0 ? _admins[index].createdAt : now,
      updatedAt: now,
    );

    if (index >= 0) {
      _admins[index] = newAdmin;
    } else {
      _admins.add(newAdmin);
    }
    _notify();

    try {
      await _firestore.collection('admins').doc(docId).set(
        newAdmin.toMap(),
        SetOptions(merge: true),
      );
    } catch (e) {
      dev.log('Error adding/updating admin $docId in Firestore: $e', name: 'AdminsRepository');
      rethrow;
    }
  }

  Future<void> updateRole(String docId, AdminRole role) async {
    final index = _admins.indexWhere((a) => a.uid == docId);
    if (index >= 0) {
      _admins[index] = _admins[index].copyWith(role: role, updatedAt: DateTime.now());
      _notify();
    }

    try {
      await _firestore.collection('admins').doc(docId).set({
        'role': role.value,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      dev.log('Error updating admin role for $docId in Firestore: $e', name: 'AdminsRepository');
      rethrow;
    }
  }

  Future<void> removeAdmin(String docId) async {
    _admins.removeWhere((a) => a.uid == docId);
    _notify();

    try {
      await _firestore.collection('admins').doc(docId).delete();
    } catch (e) {
      dev.log('Error removing admin $docId from Firestore: $e', name: 'AdminsRepository');
      rethrow;
    }
  }
}
