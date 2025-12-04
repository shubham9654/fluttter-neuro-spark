import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../utils/constants.dart';

/// Custom Card Widget
/// Reusable card with consistent styling across the app
class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final double? elevation;
  final VoidCallback? onTap;
  final double? borderRadius;
  final Border? border;
  final BoxShadow? customShadow;
  
  const CustomCard({
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.elevation,
    this.onTap,
    this.borderRadius,
    this.border,
    this.customShadow,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final cardContent = Container(
      padding: padding ?? const EdgeInsets.all(AppConstants.paddingM),
      decoration: BoxDecoration(
        color: color ?? Colors.white,
        borderRadius: BorderRadius.circular(borderRadius ?? AppConstants.cardBorderRadius),
        border: border,
        boxShadow: [
          customShadow ?? BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: elevation ?? AppConstants.cardElevation * 2,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );

    if (onTap != null) {
      return Container(
        margin: margin,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(borderRadius ?? AppConstants.cardBorderRadius),
            child: cardContent,
          ),
        ),
      );
    }

    return Container(
      margin: margin,
      child: cardContent,
    );
  }
}

/// Selection Card Widget (for Neurotype setup, etc.)
class SelectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? selectedColor;
  
  const SelectionCard({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    this.selectedColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: AppConstants.mediumAnimationDuration),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: isSelected ? (selectedColor ?? AppColors.primary).withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        border: Border.all(
          color: isSelected ? (selectedColor ?? AppColors.primary) : AppColors.borderLight,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          if (isSelected)
            BoxShadow(
              color: (selectedColor ?? AppColors.primary).withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            )
          else
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.paddingM),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 48,
                  color: isSelected ? (selectedColor ?? AppColors.primary) : AppColors.textMedium,
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected ? (selectedColor ?? AppColors.primary) : AppColors.textDark,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Glass Card with blur effect (for Brain Dump jar, modals)
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final double blur;
  final Color? backgroundColor;
  
  const GlassCard({
    required this.child,
    this.padding,
    this.borderRadius,
    this.blur = 10,
    this.backgroundColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius ?? AppConstants.cardBorderRadius),
      child: BackdropFilter(
        filter: ColorFilter.mode(
          backgroundColor ?? AppColors.glassWhite,
          BlendMode.srcOver,
        ),
        child: Container(
          padding: padding ?? const EdgeInsets.all(AppConstants.paddingM),
          decoration: BoxDecoration(
            color: (backgroundColor ?? AppColors.glassWhite).withOpacity(0.2),
            borderRadius: BorderRadius.circular(borderRadius ?? AppConstants.cardBorderRadius),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

