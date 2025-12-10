import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../../common/theme/app_colors.dart';
import '../../../../common/theme/text_styles.dart';
import '../../../../common/widgets/themed_button.dart';
import '../../../../common/utils/constants.dart';
import '../../../../core/providers/auth_providers.dart';
import '../widgets/gradient_background.dart';

/// Auth Landing Page - First screen with Google as the primary entry point
class AuthLandingPage extends ConsumerWidget {
  const AuthLandingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.watch(authServiceProvider);

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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo and branding
                      Column(
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryShadow,
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.psychology,
                              size: 60,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: AppConstants.paddingL),
                          Text(
                            AppConstants.appName,
                            style: AppTextStyles.displayLarge.copyWith(
                              color: AppColors.textDark,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: AppConstants.paddingS),
                          Text(
                            AppConstants.appTagline,
                            style: AppTextStyles.headlineSmall.copyWith(
                              color: AppColors.textMedium,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          const SizedBox(height: AppConstants.paddingS),
                          Text(
                            'ADHD-optimized productivity\nfor the beautifully neurodivergent',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: AppColors.textMedium,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppConstants.paddingXL),
                      // Buttons
                      Column(
                        children: [
                      _SocialLoginButton(
                        icon: FontAwesomeIcons.google,
                        label: 'Continue with Google',
                        onPressed: () async {
                          try {
                            final result =
                                await authService.signInWithGoogle();
                            if (context.mounted && result != null) {
                              context.go('/dashboard');
                            }
                          } on PlatformException catch (e) {
                            var message =
                                'Google Sign-In failed. Please try again.';
                            if (e.code == 'sign_in_failed' &&
                                e.message != null &&
                                e.message!.contains('ApiException: 10')) {
                              message =
                                  'Google Sign-In not configured. Add SHA-1 fingerprint in Firebase Console.';
                            }
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(message),
                                  backgroundColor: AppColors.errorRed,
                                  duration: const Duration(seconds: 5),
                                ),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                      Text('Google Sign-In failed: $e'),
                                  backgroundColor: AppColors.errorRed,
                                ),
                              );
                            }
                          }
                        },
                      ),
                          const SizedBox(height: AppConstants.paddingM),
                          ThemedSecondaryButton(
                            text: 'Continue with Email',
                            onPressed: () => context.push('/login'),
                            isExpanded: true,
                            icon: Icons.email_outlined,
                          ),
                          const SizedBox(height: AppConstants.paddingS),
                          TextButton(
                            onPressed: () => context.push('/signup'),
                            child: Text(
                              'New here? Create Account',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppConstants.paddingL),
                          Text(
                            'By continuing, you agree to our Terms & Privacy Policy',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.captionText,
                          ),
                        ],
                      ),
                    ],
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

/// Social Login Button for Google/Apple style CTAs
class _SocialLoginButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _SocialLoginButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        side: const BorderSide(color: AppColors.borderLight, width: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textDark,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FaIcon(icon, size: 20, color: AppColors.textDark),
          const SizedBox(width: 8),
          Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}
