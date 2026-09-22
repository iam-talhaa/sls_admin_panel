import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

/// Listens to Firebase auth state and shows either the LoginScreen
/// or the admin app's home screen. Drop into lib/screens/auth_gate.dart.
///
/// Usage in main.dart:
///   home: AuthGate(homeBuilder: () => const AdminHomeScreen()),
class AuthGate extends StatelessWidget {
  final Widget Function() homeBuilder;

  const AuthGate({super.key, required this.homeBuilder});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService.instance.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _SplashLoader();
        }

        final user = snapshot.data;
        if (user == null) {
          return const LoginScreen();
        }

        // User is signed in — re-verify admin claim before showing app.
        // (Guards against a stale session for a user whose admin role
        // was revoked after they last signed in.)
        return FutureBuilder<bool>(
          future: AuthService.instance.isCurrentUserAdmin(),
          builder: (context, adminSnapshot) {
            if (adminSnapshot.connectionState == ConnectionState.waiting) {
              return const _SplashLoader();
            }

            if (adminSnapshot.data == true) {
              return homeBuilder();
            }

            // Not an admin — force sign out and show login again.
            AuthService.instance.signOut();
            return const LoginScreen();
          },
        );
      },
    );
  }
}

class _SplashLoader extends StatelessWidget {
  const _SplashLoader();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
