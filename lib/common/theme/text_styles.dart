import 'package:flutter/material.dart';
import 'app_colors.dart';

/// NeuroSpark Text Styles
/// Optimized for ADHD readability with clear hierarchy
class AppTextStyles {
  // Font families
  static const String defaultFont = 'Roboto';
  static const String dyslexicFont = 'OpenDyslexic';
  
  // Display Styles (Large headers)
  static const TextStyle displayLarge = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
    height: 1.2,
    color: AppColors.textDark,
  );
  
  static const TextStyle displayMedium = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
    height: 1.2,
    color: AppColors.textDark,
  );
  
  static const TextStyle displaySmall = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    letterSpacing: 0,
    height: 1.3,
    color: AppColors.textDark,
  );
  
  // Headline Styles (Section headers)
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    letterSpacing: 0,
    height: 1.3,
    color: AppColors.textDark,
  );
  
  static const TextStyle headlineMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
    height: 1.4,
    color: AppColors.textDark,
  );
  
  static const TextStyle headlineSmall = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
    height: 1.4,
    color: AppColors.textDark,
  );
  
  // Title Styles (Card headers, buttons)
  static const TextStyle titleLarge = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
    height: 1.4,
    color: AppColors.textDark,
  );
  
  static const TextStyle titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
    height: 1.5,
    color: AppColors.textDark,
  );
  
  static const TextStyle titleSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.5,
    color: AppColors.textDark,
  );
  
  // Body Styles (Main content)
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.5,
    height: 1.6,
    color: AppColors.textDark,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.25,
    height: 1.6,
    color: AppColors.textMedium,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.4,
    height: 1.5,
    color: AppColors.textMedium,
  );
  
  // Label Styles (Buttons, chips)
  static const TextStyle labelLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.4,
    color: AppColors.textDark,
  );
  
  static const TextStyle labelMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.4,
    color: AppColors.textDark,
  );
  
  static const TextStyle labelSmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.4,
    color: AppColors.textMedium,
  );
  
  // Special Styles
  static const TextStyle buttonText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.2,
    color: Colors.white,
  );
  
  static const TextStyle timerDisplay = TextStyle(
    fontSize: 64,
    fontWeight: FontWeight.bold,
    letterSpacing: -1,
    height: 1,
    color: AppColors.textDark,
    fontFeatures: [FontFeature.tabularFigures()],
  );
  
  static const TextStyle captionText = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.4,
    height: 1.4,
    color: AppColors.textLight,
  );
  
  static const TextStyle overlineText = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.5,
    height: 1.6,
    color: AppColors.textLight,
  );
  
  // Utility Methods
  static TextStyle withDyslexicFont(TextStyle style) {
    return style.copyWith(fontFamily: dyslexicFont);
  }
  
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }
}

