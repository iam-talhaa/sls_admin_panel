import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_admin_model.dart';

final usersRepositoryProvider = Provider<UsersRepository>((ref) {
  return UsersRepository();
});

class UsersRepository {
  final List<UserAdminModel> _users = [
    UserAdminModel(
      uid: 'usr_ch_001',
      email: 'alex.wright@genevafinance.ch',
      displayName: 'Alexander Wright',
      phoneNumber: '+41 79 555 12 34',
      disabled: false,
      createdAt: DateTime.now().subtract(const Duration(days: 45)),
      lastSignInAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    UserAdminModel(
      uid: 'usr_de_002',
      email: 'sophie.berg@luxuryliving.de',
      displayName: 'Sophie Von Berg',
      phoneNumber: '+49 171 234 5678',
      disabled: false,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      lastSignInAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    UserAdminModel(
      uid: 'usr_fr_003',
      email: 'm.dumas@artparis.fr',
      displayName: 'Marc Dumas',
      phoneNumber: '+33 6 12 34 56 78',
      disabled: false,
      createdAt: DateTime.now().subtract(const Duration(days: 14)),
      lastSignInAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
  ];

  Future<List<UserAdminModel>> listUsers() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return List.unmodifiable(_users);
  }

  Future<void> setUserDisabled(String uid, bool disabled) async {
    final index = _users.indexWhere((u) => u.uid == uid);
    if (index >= 0) {
      _users[index] = _users[index].copyWith(disabled: disabled);
    }
  }
}
