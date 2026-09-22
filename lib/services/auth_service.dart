import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<User> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw AuthException('Login failed. Please try again.');
      }

      // Enforce admin-only access.
      final isAdmin = await _isAdminUser(user);
      if (!isAdmin) {
        await _auth.signOut();
        throw AuthException(
          'This account does not have admin access.',
        );
      }

      return user;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseError(e));
    }
  }

  Future<void> signOut() => _auth.signOut();

  /// Checks the `role` custom claim set on the user's ID token.
  /// Requires a backend (Cloud Function) to have set
  /// { role: "admin" } via the Firebase Admin SDK for this UID.
  Future<bool> _isAdminUser(User user) async {
    final tokenResult = await user.getIdTokenResult(true); // force refresh
    return tokenResult.claims?['role'] == 'admin';
  }

  /// Re-checks admin status for the currently signed-in user.
  /// Useful in the AuthGate to guard routes after app restart.
  Future<bool> isCurrentUserAdmin() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    return _isAdminUser(user);
  }

  String _mapFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
      case 'invalid-credential':
      case 'wrong-password':
        return 'Invalid email or password.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Check your connection.';
      default:
        return 'Login failed. Please try again.';
    }
  }
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message;
}
