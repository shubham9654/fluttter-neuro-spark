import 'package:flutter/material.dart';
import '../../../../common/theme/app_colors.dart';
import '../../../../common/theme/text_styles.dart';
import '../../../../common/utils/constants.dart';

/// Screen 6: The Now Dashboard (Placeholder)
/// Will be fully implemented in Phase 3
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingXL),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(AppConstants.paddingXL),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  size: 80,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: AppConstants.paddingXL),
              Text(
                '🎉 Welcome to NeuroSpark!',
                style: AppTextStyles.displaySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.paddingM),
              Text(
                'Onboarding complete!\nYour dashboard will be here soon.',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textMedium,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.paddingXL),
              Text(
                'Phase 1: Complete ✅\nPhase 2: Coming next...',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textLight,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

