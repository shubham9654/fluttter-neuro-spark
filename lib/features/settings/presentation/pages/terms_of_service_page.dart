import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../common/theme/app_colors.dart';
import '../../../../common/theme/text_styles.dart';
import '../../../../common/utils/constants.dart';

/// Terms of Service Page
class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Terms of Service'),
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
                    'Terms of Service',
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
                    'Acceptance of Terms',
                    'By accessing and using NeuroSpark, you accept and agree to be bound by these Terms of Service. If you do not agree to these terms, please do not use the app.',
                  ),

                  _buildSection(
                    'Description of Service',
                    '''NeuroSpark is an ADHD-optimized productivity application that provides:

• Task management and organization tools
• Focus timer and tracking
• Gamification elements and rewards
• Progress tracking and analytics
• Cloud synchronization (optional)

The service is provided "as is" and we reserve the right to modify or discontinue features at any time.''',
                  ),

                  _buildSection(
                    'User Accounts',
                    '''When creating an account, you agree to:

• Provide accurate and complete information
• Maintain the security of your account credentials
• Be responsible for all activities under your account
• Notify us immediately of any unauthorized use
• Not share your account with others

We reserve the right to terminate accounts that violate these terms.''',
                  ),

                  _buildSection(
                    'User Conduct',
                    '''You agree NOT to:

• Use the app for any illegal purposes
• Attempt to hack, reverse engineer, or exploit the app
• Upload harmful code or malware
• Harass other users or staff
• Impersonate others
• Violate intellectual property rights
• Collect user data without permission

Violations may result in account suspension or termination.''',
                  ),

                  _buildSection(
                    'Content Ownership',
                    '''• Your Data: You retain all rights to the tasks, notes, and content you create in the app
• Our Content: NeuroSpark's design, features, and branding remain our intellectual property
• License: We grant you a limited, non-exclusive license to use the app
• Backup: While we backup data regularly, you're responsible for maintaining your own backups''',
                  ),

                  _buildSection(
                    'Subscription and Payments',
                    '''• Free tier available with core features
• Premium features may require subscription
• Payments processed securely through app stores
• Subscriptions auto-renew unless cancelled
• Refund policy follows platform guidelines (App Store/Play Store)
• We may change pricing with notice''',
                  ),

                  _buildSection(
                    'Limitation of Liability',
                    '''NeuroSpark is provided "as is" without warranties. We are not liable for:

• Service interruptions or data loss
• Indirect or consequential damages
• Third-party service failures
• User-generated content

Maximum liability limited to fees paid in the past 12 months.''',
                  ),

                  _buildSection(
                    'Health Disclaimer',
                    '''NeuroSpark is a productivity tool, not medical advice:

• Not a substitute for professional ADHD treatment
• Consult healthcare providers for medical decisions
• We make no medical claims or guarantees
• Use at your own discretion''',
                  ),

                  _buildSection(
                    'Privacy',
                    'Your use of NeuroSpark is also governed by our Privacy Policy. Please review it to understand how we collect and use your information.',
                  ),

                  _buildSection(
                    'Modifications to Terms',
                    'We may update these terms from time to time. Continued use of the app after changes constitutes acceptance of the new terms. We will notify users of significant changes.',
                  ),

                  _buildSection(
                    'Termination',
                    '''You may terminate your account at any time by:

• Using the "Delete Account" feature in settings
• Contacting support

We may terminate accounts that violate these terms.''',
                  ),

                  _buildSection(
                    'Governing Law',
                    'These terms are governed by applicable laws. Disputes will be resolved through binding arbitration.',
                  ),

                  _buildSection(
                    'Contact',
                    '''Questions about these terms?

Email: legal@neurospark.app
Website: neurospark.app/terms

We're here to help!''',
                  ),

                  const SizedBox(height: AppConstants.paddingL),

                  Container(
                    padding: const EdgeInsets.all(AppConstants.paddingM),
                    decoration: BoxDecoration(
                      color: AppColors.successGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.successGreen,
                        ),
                        const SizedBox(width: AppConstants.paddingM),
                        Expanded(
                          child: Text(
                            'Thank you for using NeuroSpark responsibly!',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.successGreen,
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

