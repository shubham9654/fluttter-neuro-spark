import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../common/theme/app_colors.dart';
import '../../../../common/theme/text_styles.dart';
import '../../../../common/widgets/themed_button.dart';
import '../../../../common/utils/constants.dart';
import '../../../../core/providers/auth_providers.dart';
import '../widgets/gradient_background.dart';

/// Login Page with Email/Password Authentication
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = ref.read(authServiceProvider);
      final result = await authService.signInWithEmail(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (mounted) {
        if (result != null && result.user != null) {
          // Wait a bit for auth state to update, then navigate
          await Future.delayed(const Duration(milliseconds: 300));
          if (mounted) {
            context.go('/dashboard');
          }
        } else {
          setState(() {
            _errorMessage = 'Invalid email or password. Please try again.';
            _isLoading = false;
          });
        }
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        String errorMsg = 'An error occurred. Please try again.';
        switch (e.code) {
          case 'user-not-found':
            errorMsg = 'No account found with this email. Please sign up.';
            break;
          case 'wrong-password':
            errorMsg = 'Incorrect password. Please try again.';
            break;
          case 'invalid-email':
            errorMsg = 'Invalid email address. Please check and try again.';
            break;
          case 'user-disabled':
            errorMsg = 'This account has been disabled. Please contact support.';
            break;
          case 'too-many-requests':
            errorMsg = 'Too many failed attempts. Please try again later.';
            break;
          case 'network-request-failed':
            errorMsg = 'Network error. Please check your connection and try again.';
            break;
          default:
            errorMsg = e.message ?? 'Failed to sign in. Please try again.';
        }
        setState(() {
          _errorMessage = errorMsg;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        debugPrint('Login error: $e');
        setState(() {
          _errorMessage = 'An unexpected error occurred. Please try again.';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Breathing gradient background
          const BreathingGradientBackground(),

          // Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.paddingL),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 40),

                    // Back button
                    Align(
                      alignment: Alignment.topLeft,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_rounded),
                        color: AppColors.textDark,
                        onPressed: () => context.pop(),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Title
                    Text(
                      'Welcome Back',
                      style: AppTextStyles.displayMedium.copyWith(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: AppConstants.paddingS),

                    // Subtitle
                    Text(
                      'Sign in to continue your journey',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textMedium,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: AppConstants.paddingXL),

                    // Email field
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        hintText: 'Enter your email',
                        prefixIcon: const Icon(Icons.email_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!value.contains('@')) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: AppConstants.paddingM),

                    // Password field
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _handleLogin(),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintText: 'Enter your password',
                        prefixIcon: const Icon(Icons.lock_outlined),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: AppConstants.paddingS),

                    // Forgot password
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          // TODO: Implement forgot password
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Forgot password coming soon!'),
                            ),
                          );
                        },
                        child: Text(
                          'Forgot Password?',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),

                    // Error message
                    if (_errorMessage != null) ...[
                      const SizedBox(height: AppConstants.paddingS),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.errorRed.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.errorRed),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: AppColors.errorRed,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.errorRed,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: AppConstants.paddingL),

                    // Login button
                    ThemedPrimaryButton(
                      text: 'Sign In',
                      onPressed: _handleLogin,
                      isExpanded: true,
                      isLoading: _isLoading,
                      icon: Icons.login_rounded,
                    ),

                    const SizedBox(height: AppConstants.paddingM),

                    // Sign up link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textMedium,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            context.push('/signup');
                          },
                          child: Text(
                            'Sign Up',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppConstants.paddingL),

                    // Divider
                    const Row(
                      children: [
                        Expanded(child: Divider(color: AppColors.borderLight)),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppConstants.paddingM,
                          ),
                          child: Text(
                            'OR',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textLight,
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: AppColors.borderLight)),
                      ],
                    ),

                    const SizedBox(height: AppConstants.paddingM),

                    // Google Sign In
                    OutlinedButton.icon(
                      onPressed: _isLoading
                          ? null
                          : () async {
                              final authService = ref.read(authServiceProvider);
                              final result = await authService
                                  .signInWithGoogle();
                              if (mounted && result != null) {
                                context.go('/dashboard');
                              }
                            },
                      icon: const Icon(Icons.g_mobiledata, size: 24),
                      label: const Text('Continue with Google'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(
                          color: AppColors.borderLight,
                          width: 2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
