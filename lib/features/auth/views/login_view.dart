import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_color_scheme.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/validators.dart';
import '../viewmodels/login_viewmodel.dart';

class LoginView extends ConsumerStatefulWidget {
  const LoginView({super.key});

  @override
  ConsumerState<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends ConsumerState<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(loginViewModelProvider.notifier).login(
          email: _emailController.text,
          password: _passwordController.text,
        );

    if (success && mounted) {
      context.go('/dashboard');
    }
  }

  void _showForgotPasswordDialog() {
    final colors = context.colors;
    final resetEmailController = TextEditingController(text: _emailController.text);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.surfaceElevated,
        title: Text('Reset Password', style: AppTextStyles.headingSmall.copyWith(color: colors.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter your administrator email to receive a password reset link.',
              style: AppTextStyles.subtitle.copyWith(color: colors.textSecondary),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: resetEmailController,
              keyboardType: TextInputType.emailAddress,
              style: AppTextStyles.inputText.copyWith(color: colors.textPrimary),
              decoration: InputDecoration(
                labelText: 'Admin Email',
                prefixIcon: Icon(Icons.email_outlined, size: 18, color: colors.textSecondary),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel', style: TextStyle(color: colors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(loginViewModelProvider.notifier).sendPasswordReset(resetEmailController.text);
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.primaryRed,
              foregroundColor: Colors.white,
            ),
            child: const Text('Send Reset Link'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final state = ref.watch(loginViewModelProvider);

    return Scaffold(
      backgroundColor: colors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Container(
              padding: const EdgeInsets.all(36.0),
              decoration: BoxDecoration(
                color: colors.surfaceElevated,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colors.border, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: colors.shadow,
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Brand Logo Top-Center
                    Center(
                      child: Image.asset(
                        'assets/slslogo.png',
                        width: 70,
                        height: 70,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          children: [
                            TextSpan(text: 'SWISS ', style: AppTextStyles.logoTitleRed),
                            TextSpan(text: 'LUXURY SERVICES', style: AppTextStyles.logoTitleWhite.copyWith(color: colors.textPrimary)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Center(
                      child: Text(
                        'ADMINISTRATION PORTAL',
                        style: AppTextStyles.logoSubtitle.copyWith(color: colors.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Error message banner
                    if (state.errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colors.errorBg,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: colors.error.withOpacity(0.5)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline, color: colors.error, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                state.errorMessage!,
                                style: AppTextStyles.bodySmall.copyWith(color: colors.error),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Success message banner
                    if (state.successMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colors.successBg,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: colors.success.withOpacity(0.5)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle_outline, color: colors.success, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                state.successMessage!,
                                style: AppTextStyles.bodySmall.copyWith(color: colors.success),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Email Field
                    Text('Email Address', style: AppTextStyles.fieldLabel.copyWith(color: colors.textPrimary)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: AppTextStyles.inputText.copyWith(color: colors.textPrimary),
                      validator: Validators.email,
                      decoration: InputDecoration(
                        hintText: 'admin@swissluxuryservices.ch',
                        prefixIcon: Icon(Icons.email_outlined, size: 18, color: colors.textSecondary),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Password Field
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Password', style: AppTextStyles.fieldLabel.copyWith(color: colors.textPrimary)),
                        InkWell(
                          onTap: _showForgotPasswordDialog,
                          child: Text(
                            'Forgot password?',
                            style: AppTextStyles.textButtonRed.copyWith(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      style: AppTextStyles.inputText.copyWith(color: colors.textPrimary),
                      validator: (val) => Validators.requiredField(val, 'Password is required'),
                      onFieldSubmitted: (_) => _handleLogin(),
                      decoration: InputDecoration(
                        hintText: '••••••••',
                        prefixIcon: Icon(Icons.lock_outline, size: 18, color: colors.textSecondary),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            size: 18,
                            color: colors.textSecondary,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Login Button
                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: state.isLoading ? null : _handleLogin,
                        child: state.isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text('Sign In to Admin Panel'),
                      ),
                    ),

                    const SizedBox(height: 24),
                    Center(
                      child: Text(
                        'Restricted Access • Authorized SLS Staff Only',
                        style: AppTextStyles.bodySmall.copyWith(fontSize: 11, color: colors.textMuted),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: InkWell(
                        onTap: () => context.push('/privacy-policy'),
                        borderRadius: BorderRadius.circular(4),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: Text(
                            'Privacy Policy',
                            style: AppTextStyles.bodySmall.copyWith(
                              fontSize: 12,
                              color: colors.textSecondary,
                              decoration: TextDecoration.underline,
                              decorationColor: colors.textMuted,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
