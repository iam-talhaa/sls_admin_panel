import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/admin_user_model.dart';

final adminsRepositoryProvider = Provider<AdminsRepository>((ref) {
  return AdminsRepository();
});

final adminsListStreamProvider = StreamProvider<List<AdminUserModel>>((ref) {
  return ref.watch(adminsRepositoryProvider).watchAdmins();
});

class AdminsRepository {
  final List<AdminUserModel> _admins = [
    AdminUserModel(
      uid: 'admin_primary_01',
      email: 'admin@swissluxuryservices.ch',
      role: AdminRole.superAdmin,
      createdAt: DateTime.now().subtract(const Duration(days: 90)),
    ),
    AdminUserModel(
      uid: 'admin_editor_02',
      email: 'editor@swissluxuryservices.ch',
      role: AdminRole.editor,
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
    ),
  ];

  final _streamController = StreamController<List<AdminUserModel>>.broadcast();

  AdminsRepository() {
    _streamController.add(List.unmodifiable(_admins));
  }

  Stream<List<AdminUserModel>> watchAdmins() {
    return Stream<List<AdminUserModel>>.multi((controller) {
      controller.add(List.unmodifiable(_admins));
      final sub = _streamController.stream.listen((data) {
        controller.add(data);
      });
      controller.onCancel = () => sub.cancel();
    });
  }

  Future<void> addOrUpdateAdmin({
    required String uidOrEmail,
    required String email,
    required AdminRole role,
  }) async {
    final docId = uidOrEmail.isNotEmpty ? uidOrEmail : 'admin_${email.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}';
    final index = _admins.indexWhere((a) => a.uid == docId || a.email == email);

    if (index >= 0) {
      _admins[index] = _admins[index].copyWith(role: role);
    } else {
      _admins.add(AdminUserModel(
        uid: docId,
        email: email.trim(),
        role: role,
        createdAt: DateTime.now(),
      ));
    }
    _streamController.add(List.unmodifiable(_admins));
  }

  Future<void> updateRole(String docId, AdminRole role) async {
    final index = _admins.indexWhere((a) => a.uid == docId);
    if (index >= 0) {
      _admins[index] = _admins[index].copyWith(role: role);
      _streamController.add(List.unmodifiable(_admins));
    }
  }

  Future<void> removeAdmin(String docId) async {
    _admins.removeWhere((a) => a.uid == docId);
    _streamController.add(List.unmodifiable(_admins));
  }
}
