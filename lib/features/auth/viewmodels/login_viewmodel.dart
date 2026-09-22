import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/admin_auth_repository.dart';

class LoginState {
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;

  const LoginState({
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
  });

  LoginState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }
}

final loginViewModelProvider = StateNotifierProvider<LoginViewModel, LoginState>((ref) {
  return LoginViewModel(ref.watch(adminAuthRepositoryProvider));
});

class LoginViewModel extends StateNotifier<LoginState> {
  final AdminAuthRepository _authRepository;

  LoginViewModel(this._authRepository) : super(const LoginState());

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await _authRepository.signInWithEmailPassword(
        email: email,
        password: password,
      );
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception:', '').trim(),
      );
      return false;
    }
  }

  Future<void> sendPasswordReset(String email) async {
    if (email.trim().isEmpty) {
      state = state.copyWith(errorMessage: 'Please enter your email to reset password.');
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await _authRepository.sendPasswordReset(email);
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Password reset link sent to your email.',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception:', '').trim(),
      );
    }
  }

  void clearMessages() {
    state = state.copyWith(errorMessage: null, successMessage: null);
  }
}
