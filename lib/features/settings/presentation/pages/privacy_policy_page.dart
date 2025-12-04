import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../common/theme/app_colors.dart';
import '../../../../common/theme/text_styles.dart';
import '../../../../common/utils/constants.dart';

/// Privacy Policy Page
class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Privacy Policy'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(AppConstants.paddingL),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.cardShadow,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Privacy Policy',
                    style: AppTextStyles.displaySmall.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingS),
                  Text(
                    'Last updated: ${DateTime.now().year}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textLight,
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingL),

                  _buildSection(
                    'Introduction',
                    'Welcome to NeuroSpark. We respect your privacy and are committed to protecting your personal data. This privacy policy explains how we collect, use, and safeguard your information when you use our ADHD productivity app.',
                  ),

                  _buildSection(
                    'Information We Collect',
                    '''We collect the following types of information:

• Account Information: Name, email address, and profile photo when you sign in
• Usage Data: Tasks created, focus sessions, completion rates, and app interactions
• Device Information: Device type, operating system, and app version
• Analytics: App usage patterns to improve user experience

All data is encrypted and stored securely using Firebase services.''',
                  ),

                  _buildSection(
                    'How We Use Your Information',
                    '''Your data is used to:

• Provide and maintain the NeuroSpark service
• Personalize your productivity experience
• Track your progress and achievements
• Send notifications and reminders (if enabled)
• Improve app features and user experience
• Ensure app security and prevent fraud

We will never sell your personal information to third parties.''',
                  ),

                  _buildSection(
                    'Data Storage and Security',
                    '''Your data is stored securely on Firebase servers with:

• End-to-end encryption for sensitive data
• Secure authentication protocols
• Regular security audits and updates
• Compliance with industry standards

You have full control over your data and can delete it at any time.''',
                  ),

                  _buildSection(
                    'Third-Party Services',
                    '''NeuroSpark uses the following third-party services:

• Firebase: Authentication, database, and analytics
• Google Sign-In: Optional authentication method
• Audio libraries: For focus sounds and feedback

These services have their own privacy policies that we adhere to.''',
                  ),

                  _buildSection(
                    'Your Rights',
                    '''You have the right to:

• Access your personal data
• Correct inaccurate data
• Delete your account and data
• Export your data
• Opt-out of notifications
• Withdraw consent at any time

Contact us to exercise any of these rights.''',
                  ),

                  _buildSection(
                    'Children\'s Privacy',
                    'NeuroSpark is not intended for users under 13 years of age. We do not knowingly collect data from children under 13.',
                  ),

                  _buildSection(
                    'Changes to This Policy',
                    'We may update this privacy policy from time to time. We will notify you of significant changes through the app or via email.',
                  ),

                  _buildSection(
                    'Contact Us',
                    '''If you have questions about this privacy policy:

Email: privacy@neurospark.app
Website: neurospark.app

We typically respond within 48 hours.''',
                  ),

                  const SizedBox(height: AppConstants.paddingL),

                  Container(
                    padding: const EdgeInsets.all(AppConstants.paddingM),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.security_rounded,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: AppConstants.paddingM),
                        Expanded(
                          child: Text(
                            'Your privacy and data security are our top priorities.',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppConstants.paddingS),
          Text(
            content,
            style: AppTextStyles.bodyMedium.copyWith(
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

