import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/text_styles.dart';
import '../utils/constants.dart';

/// Progress Header for Onboarding Flow
/// Shows current step and overall progress
class ProgressHeader extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final String title;
  final String? subtitle;
  final VoidCallback? onBack;
  
  const ProgressHeader({
    required this.currentStep,
    required this.totalSteps,
    required this.title,
    this.subtitle,
    this.onBack,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final progress = currentStep / totalSteps;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Back button and step indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (onBack != null)
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: onBack,
                color: AppColors.textDark,
              )
            else
              const SizedBox(width: 48), // Spacer for alignment
            
            Text(
              'Step $currentStep of $totalSteps',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textMedium,
              ),
            ),
            
            const SizedBox(width: 48), // Spacer for alignment
          ],
        ),
        
        const SizedBox(height: AppConstants.paddingM),
        
        // Progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.borderLight,
            color: AppColors.primary,
            minHeight: 6,
          ),
        ),
        
        const SizedBox(height: AppConstants.paddingL),
        
        // Title
        Text(
          title,
          style: AppTextStyles.displaySmall,
        ),
        
        if (subtitle != null) ...[
          const SizedBox(height: AppConstants.paddingS),
          Text(
            subtitle!,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textMedium,
            ),
          ),
        ],
      ],
    );
  }
}

/// Simple Progress Indicator (for loading states)
class AppProgressIndicator extends StatelessWidget {
  final double? size;
  final Color? color;
  final double? strokeWidth;
  
  const AppProgressIndicator({
    this.size,
    this.color,
    this.strokeWidth,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size ?? 40,
        height: size ?? 40,
        child: CircularProgressIndicator(
          color: color ?? AppColors.primary,
          strokeWidth: strokeWidth ?? 4,
        ),
      ),
    );
  }
}

/// Step Indicator Dots (alternative to progress bar)
class StepIndicatorDots extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final Color activeColor;
  final Color inactiveColor;
  
  const StepIndicatorDots({
    required this.currentStep,
    required this.totalSteps,
    this.activeColor = AppColors.primary,
    this.inactiveColor = AppColors.borderLight,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        totalSteps,
        (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: index + 1 == currentStep ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: index + 1 == currentStep ? activeColor : inactiveColor,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}

