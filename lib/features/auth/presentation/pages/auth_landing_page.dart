import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../common/theme/app_colors.dart';
import '../../../../common/theme/text_styles.dart';
import '../../../../common/widgets/themed_button.dart';
import '../../../../common/utils/constants.dart';
import '../widgets/gradient_background.dart';

/// Auth Landing Page - First screen with Sign In and Sign Up options
class AuthLandingPage extends StatelessWidget {
  const AuthLandingPage({super.key});

  @override
  Widget build(BuildContext context) {
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  
                  // Logo and branding
                  Column(
                    children: [
                      // App Icon/Logo
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
                  
                  const Spacer(),
                  
                  // Buttons
                  Column(
                    children: [
                      // Sign In button
                      ThemedPrimaryButton(
                        text: 'Sign In',
                        onPressed: () {
                          context.push('/login');
                        },
                        isExpanded: true,
                        icon: Icons.login_rounded,
                      ),
                      
                      const SizedBox(height: AppConstants.paddingM),
                      
                      // Sign Up button
                      ThemedSecondaryButton(
                        text: 'Create Account',
                        onPressed: () {
                          context.push('/signup');
                        },
                        isExpanded: true,
                        icon: Icons.person_add_rounded,
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

