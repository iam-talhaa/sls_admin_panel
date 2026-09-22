import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/admins/data/models/admin_user_model.dart';
import '../../features/auth/data/repositories/admin_auth_repository.dart';

final currentAdminProvider = StreamProvider<AdminUserModel?>((ref) {
  final authRepo = ref.watch(adminAuthRepositoryProvider);
  return Stream<AdminUserModel?>.multi((controller) {
    controller.add(authRepo.currentAdmin);
    final subscription = authRepo.authStateChanges().listen((admin) {
      controller.add(admin);
    });
    controller.onCancel = () => subscription.cancel();
  });
});
