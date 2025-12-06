import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../common/theme/app_colors.dart';
import '../../../../common/theme/text_styles.dart';
import '../../../../common/widgets/themed_button.dart';
import '../../../../common/utils/constants.dart';
import '../../../../core/providers/auth_providers.dart';
import '../widgets/gradient_background.dart';

/// Screen 1: Welcome / Sign In
/// Entry point with low friction authentication
class WelcomePage extends ConsumerWidget {
  const WelcomePage({super.key});

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
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.paddingL),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(height: 40),
                  
                  // Logo and branding
                  Column(
                    children: [
                      // App Icon/Logo (placeholder)
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
                          FontAwesomeIcons.brain,
                          size: 60,
                          color: AppColors.primary,
                        ),
                      ),
                      
                      const SizedBox(height: AppConstants.paddingL),
                      
                      // App name
                      Text(
                        AppConstants.appName,
                        style: AppTextStyles.displayLarge.copyWith(
                          color: AppColors.textDark,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      
                      const SizedBox(height: AppConstants.paddingS),
                      
                      // Tagline
                      Text(
                        AppConstants.appTagline,
                        style: AppTextStyles.headlineSmall.copyWith(
                          color: AppColors.textMedium,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      
                      const SizedBox(height: AppConstants.paddingS),
                      
                      // Description
                      Text(
                        'ADHD-optimized productivity\nfor the beautifully neurodivergent',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.textMedium,
                        ),
                      ),
                    ],
                  ),
                  
                  // Buttons
                  Column(
                    children: [
                      // Get Started button
                      ThemedPrimaryButton(
                        text: 'Get Started',
                        onPressed: () async {
                          try {
                            // Sign in anonymously for quick start
                            await authService.signInAnonymously();
                          } catch (e) {
                            // Continue anyway - offline mode
                            debugPrint('Auth failed, continuing offline: $e');
                          }
                          if (context.mounted) {
                            context.go('/onboarding/neurotype');
                          }
                        },
                        isExpanded: true,
                        icon: Icons.arrow_forward_rounded,
                      ),
                      
                      const SizedBox(height: AppConstants.paddingM),
                      
                      // Email/Password login button
                      ThemedSecondaryButton(
                        text: 'Sign in with Email',
                        onPressed: () {
                          context.push('/login');
                        },
                        isExpanded: true,
                        icon: Icons.email_outlined,
                      ),
                      
                      const SizedBox(height: AppConstants.paddingS),
                      
                      // Sign up link
                      TextButton(
                        onPressed: () {
                          context.push('/signup');
                        },
                        child: Text(
                          'Create Account',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: AppConstants.paddingM),
                      
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
                                letterSpacing: 0.5,
                                height: 1.4,
                                color: AppColors.textLight,
                              ),
                            ),
                          ),
                          Expanded(child: Divider(color: AppColors.borderLight)),
                        ],
                      ),
                      
                      const SizedBox(height: AppConstants.paddingM),
                      
                      // Social login buttons
                      Row(
                        children: [
                          Expanded(
                            child: _SocialLoginButton(
                              icon: FontAwesomeIcons.google,
                              label: 'Google',
                              onPressed: () async {
                                try {
                                  final result = await authService.signInWithGoogle();
                                  if (context.mounted && result != null) {
                                    await Future.delayed(const Duration(milliseconds: 300));
                                    if (context.mounted) {
                                      context.go('/dashboard');
                                    }
                                  }
                                } on PlatformException catch (e) {
                                  if (context.mounted) {
                                    String errorMsg = 'Google Sign-In failed. Please try again.';
                                    if (e.code == 'sign_in_failed' && 
                                        e.message != null && 
                                        e.message!.contains('ApiException: 10')) {
                                      errorMsg = 'Google Sign-In not configured. Please add SHA-1 fingerprint to Firebase Console.';
                                    }
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(errorMsg),
                                        backgroundColor: AppColors.errorRed,
                                        duration: const Duration(seconds: 5),
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Google Sign-In failed: ${e.toString()}'),
                                        backgroundColor: AppColors.errorRed,
                                      ),
                                    );
                                  }
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: AppConstants.paddingM),
                          Expanded(
                            child: _SocialLoginButton(
                              icon: FontAwesomeIcons.apple,
                              label: 'Apple',
                              onPressed: () {
                                // TODO: Implement Apple Sign In
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Apple Sign In coming soon!'),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: AppConstants.paddingL),
                      
                      // Terms and privacy
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
        ],
      ),
    );
  }
}

/// Social Login Button Widget
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
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

