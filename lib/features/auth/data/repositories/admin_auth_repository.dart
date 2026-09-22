import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../admins/data/models/admin_user_model.dart';

final adminAuthRepositoryProvider = Provider<AdminAuthRepository>((ref) {
  return AdminAuthRepository();
});

class AdminAuthRepository {
  AdminUserModel? _currentAdmin = const AdminUserModel(
    uid: 'admin_primary_01',
    email: 'admin@swissluxuryservices.ch',
    role: AdminRole.superAdmin,
  );

  final _authStreamController = StreamController<AdminUserModel?>.broadcast();

  AdminAuthRepository() {
    _authStreamController.add(_currentAdmin);
  }

  Stream<AdminUserModel?> authStateChanges() {
    return _authStreamController.stream;
  }

  AdminUserModel? get currentAdmin => _currentAdmin;

  Future<AdminUserModel> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final normalized = email.trim().toLowerCase();
    if (normalized.isEmpty) {
      throw 'Please enter a valid email address.';
    }

    final role = (normalized.contains('editor') || normalized.contains('staff'))
        ? AdminRole.editor
        : AdminRole.superAdmin;

    _currentAdmin = AdminUserModel(
      uid: 'admin_${normalized.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}',
      email: normalized,
      role: role,
      createdAt: DateTime.now(),
    );

    _authStreamController.add(_currentAdmin);
    return _currentAdmin!;
  }

  Future<void> sendPasswordReset(String email) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // Simulated password reset
  }

  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _currentAdmin = null;
    _authStreamController.add(null);
  }
}
