import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../common/theme/app_colors.dart';
import '../../../../common/theme/text_styles.dart';
import '../../../../common/widgets/themed_button.dart';
import '../../../../common/utils/constants.dart';
import '../../../../core/providers/auth_providers.dart';
import '../widgets/gradient_background.dart';

/// Sign Up Page with Email/Password Registration
class SignUpPage extends ConsumerStatefulWidget {
  const SignUpPage({super.key});

  @override
  ConsumerState<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends ConsumerState<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;
  bool _agreeToTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_agreeToTerms) {
      setState(() {
        _errorMessage = 'Please agree to the Terms & Privacy Policy';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = ref.read(authServiceProvider);
      final result = await authService.createAccountWithEmail(
        _emailController.text.trim(),
        _passwordController.text,
        displayName: _nameController.text.trim(),
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
            _errorMessage = 'Failed to create account. Please try again.';
            _isLoading = false;
          });
        }
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        String errorMsg = 'An error occurred. Please try again.';
        switch (e.code) {
          case 'email-already-in-use':
            errorMsg = 'This email is already registered. Please sign in instead.';
            break;
          case 'weak-password':
            errorMsg = 'Password is too weak. Please use a stronger password.';
            break;
          case 'invalid-email':
            errorMsg = 'Invalid email address. Please check and try again.';
            break;
          case 'operation-not-allowed':
            errorMsg = 'Email/password accounts are not enabled. Please contact support.';
            break;
          case 'network-request-failed':
            errorMsg = 'Network error. Please check your connection and try again.';
            break;
          default:
            errorMsg = e.message ?? 'Failed to create account. Please try again.';
        }
        setState(() {
          _errorMessage = errorMsg;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        debugPrint('Signup error: $e');
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
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppConstants.paddingL),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Title
                        Text(
                          'Create Account',
                          style: AppTextStyles.displayMedium.copyWith(
                            color: AppColors.textDark,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: AppConstants.paddingS),

                        // Subtitle
                        Text(
                          'Join NeuroSpark and start your journey',
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: AppColors.textMedium,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: AppConstants.paddingXL),

                        // Name field
                        TextFormField(
                          controller: _nameController,
                          keyboardType: TextInputType.name,
                          textInputAction: TextInputAction.next,
                          textCapitalization: TextCapitalization.words,
                          decoration: InputDecoration(
                            labelText: 'Full Name',
                            hintText: 'Enter your name',
                            prefixIcon: const Icon(Icons.person_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your name';
                            }
                            if (value.length < 2) {
                              return 'Name must be at least 2 characters';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: AppConstants.paddingM),

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
                            if (!value.contains('@') || !value.contains('.')) {
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
                          onFieldSubmitted: (_) => _handleSignUp(),
                          decoration: InputDecoration(
                            labelText: 'Password',
                            hintText: 'Create a password',
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
                              return 'Please enter a password';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: AppConstants.paddingM),

                        // Terms and conditions checkbox
                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppConstants.paddingS,
                            horizontal: AppConstants.paddingS,
                          ),
                          decoration: BoxDecoration(
                            color: _agreeToTerms
                                ? AppColors.primary.withOpacity(0.05)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _agreeToTerms
                                  ? AppColors.primary
                                  : AppColors.borderLight,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Checkbox(
                                value: _agreeToTerms,
                                onChanged: (value) {
                                  setState(() {
                                    _agreeToTerms = value ?? false;
                                    if (_agreeToTerms) {
                                      _errorMessage = null;
                                    }
                                  });
                                },
                                activeColor: AppColors.primary,
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _agreeToTerms = !_agreeToTerms;
                                      if (_agreeToTerms) {
                                        _errorMessage = null;
                                      }
                                    });
                                  },
                                  child: RichText(
                                    text: TextSpan(
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.textMedium,
                                      ),
                                      children: [
                                        const TextSpan(text: 'I agree to the '),
                                        TextSpan(
                                          text: 'Terms & Privacy Policy',
                                          style: AppTextStyles.bodySmall.copyWith(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.bold,
                                            decoration: TextDecoration.underline,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
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

                        // Sign up button
                        ThemedPrimaryButton(
                          text: 'Create Account',
                          onPressed: _handleSignUp,
                          isExpanded: true,
                          isLoading: _isLoading,
                          icon: Icons.person_add_rounded,
                        ),

                        const SizedBox(height: AppConstants.paddingM),

                        // Sign in link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Already have an account? ',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textMedium,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                context.pop();
                                context.push('/login');
                              },
                              child: Text(
                                'Sign In',
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

                        // Google Sign Up
                        OutlinedButton.icon(
                          onPressed: _isLoading
                              ? null
                              : () async {
                                  setState(() {
                                    _isLoading = true;
                                    _errorMessage = null;
                                  });

                                  try {
                                    final authService = ref.read(authServiceProvider);
                                    final result = await authService.signInWithGoogle();

                                    if (mounted) {
                                      if (result != null && result.user != null) {
                                        // Wait a bit for auth state to update
                                        await Future.delayed(const Duration(milliseconds: 300));
                                        if (mounted) {
                                          context.go('/dashboard');
                                        }
                                      } else {
                                        setState(() {
                                          _errorMessage = 'Google Sign-In was cancelled';
                                          _isLoading = false;
                                        });
                                      }
                                    }
                                  } on PlatformException catch (e) {
                                    if (mounted) {
                                      debugPrint('Google Sign-In PlatformException: ${e.code} - ${e.message}');
                                      String errorMsg = 'Google Sign-In failed. Please try again.';
                                      
                                      // Check for ApiException: 10 (SHA-1 not configured)
                                      if (e.code == 'sign_in_failed' && 
                                          e.message != null && 
                                          e.message!.contains('ApiException: 10')) {
                                        errorMsg = 'Google Sign-In not configured. Please add SHA-1 fingerprint to Firebase Console.\n\n'
                                            'Run: cd android && gradlew signingReport\n'
                                            'Then add SHA-1 to Firebase Console → Project Settings → Your Android App';
                                      }
                                      
                                      setState(() {
                                        _errorMessage = errorMsg;
                                        _isLoading = false;
                                      });
                                      
                                      // Show detailed error in snackbar
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(errorMsg),
                                          backgroundColor: AppColors.errorRed,
                                          duration: const Duration(seconds: 5),
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    if (mounted) {
                                      debugPrint('Google Sign-In error: $e');
                                      String errorMsg = 'Google Sign-In failed. Please try again.';
                                      
                                      if (e.toString().contains('SHA-1') || 
                                          e.toString().contains('ApiException: 10')) {
                                        errorMsg = 'Google Sign-In not configured. Please add SHA-1 fingerprint to Firebase Console.';
                                      }
                                      
                                      setState(() {
                                        _errorMessage = errorMsg;
                                        _isLoading = false;
                                      });
                                    }
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
            ),
          ),
        ],
      ),
    );
  }
}


