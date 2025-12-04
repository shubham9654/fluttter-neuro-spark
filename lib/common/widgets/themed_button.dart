import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/text_styles.dart';
import '../utils/haptic_helper.dart';

/// Themed Primary Button with haptic feedback
/// Implements NFR-2: Extensive haptic feedback
class ThemedPrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isExpanded;
  final Color? backgroundColor;
  final Color? textColor;
  final EdgeInsetsGeometry? padding;
  
  const ThemedPrimaryButton({
    required this.text,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isExpanded = false,
    this.backgroundColor,
    this.textColor,
    this.padding,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: isExpanded ? double.infinity : null,
      child: ElevatedButton(
        onPressed: isLoading ? null : () async {
          await HapticHelper.mediumImpact();
          onPressed();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.primary,
          foregroundColor: textColor ?? Colors.white,
          padding: padding ?? const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          elevation: 8,
          shadowColor: AppColors.primaryShadow,
          disabledBackgroundColor: AppColors.disabledGray,
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: AppTextStyles.buttonText.copyWith(
                      color: textColor ?? Colors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Themed Secondary Button (Outlined style)
class ThemedSecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isExpanded;
  
  const ThemedSecondaryButton({
    required this.text,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isExpanded = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: isExpanded ? double.infinity : null,
      child: OutlinedButton(
        onPressed: isLoading ? null : () async {
          await HapticHelper.lightImpact();
          onPressed();
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 2),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: AppTextStyles.buttonText.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Icon Button with haptic feedback
class ThemedIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? iconColor;
  final double size;
  final String? tooltip;
  
  const ThemedIconButton({
    required this.icon,
    required this.onPressed,
    this.backgroundColor,
    this.iconColor,
    this.size = 48,
    this.tooltip,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final button = Material(
      color: backgroundColor ?? AppColors.primary.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () async {
          await HapticHelper.lightImpact();
          onPressed();
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          child: Icon(
            icon,
            color: iconColor ?? AppColors.primary,
            size: size * 0.5,
          ),
        ),
      ),
    );
    
    if (tooltip != null) {
      return Tooltip(
        message: tooltip!,
        child: button,
      );
    }
    
    return button;
  }
}

