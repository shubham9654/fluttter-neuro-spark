import 'package:flutter/material.dart';

/// NeuroSpark Color Palette
/// Primary theme color: #00C4B4 (Vibrant, calming Cyan/Teal)
class AppColors {
  // Primary Theme Color: #00C4B4
  static const Color primary = Color(0xFF00C4B4);
  static const Color primaryLight = Color(0xFF33D0C2);
  static const Color primaryDark = Color(0xFF00A094);
  
  // Secondary Colors
  static const Color accentYellow = Color(0xFFFFC107);
  static const Color accentOrange = Color(0xFFFF9800);
  static const Color accentPink = Color(0xFFEC407A);
  static const Color accentPurple = Color(0xFF9C27B0);
  static const Color warningOrange = Color(0xFFFF9800);
  static const Color errorRed = Color(0xFFEF5350);
  static const Color successGreen = Color(0xFF66BB6A);
  
  // Neutral Palette (derived from Slate/Gray)
  static const Color backgroundLight = Color(0xFFF9FAFB); // gray-50
  static const Color backgroundMedium = Color(0xFFF3F4F6); // gray-100
  static const Color textDark = Color(0xFF1F2937); // slate-800
  static const Color textMedium = Color(0xFF6B7280); // slate-500
  static const Color textLight = Color(0xFF9CA3AF); // slate-400
  static const Color borderLight = Color(0xFFE5E7EB); // gray-200
  static const Color borderMedium = Color(0xFFD1D5DB); // gray-300
  
  // Gamification/Energy Colors
  static const Color goldenHour = Color(0xFFFFD700);
  static const Color potatoHour = Color(0xFF94A3B8); // slate-400
  static const Color xpPurple = Color(0xFF9C27B0);
  static const Color coinGold = Color(0xFFFFB300);
  
  // Doom Box Recovery (Urgency without shame)
  static const Color urgencyAmber = Color(0xFFFFB300);
  static const Color urgencyAmberLight = Color(0xFFFFD54F);
  
  // UI States
  static const Color selectedBlue = Color(0xFF2196F3);
  static const Color disabledGray = Color(0xFFBDBDBD);
  
  // Dark Theme Support (Optional for future)
  static const Color backgroundDark = Color(0xFF1F2937);
  static const Color surfaceDark = Color(0xFF374151);
  
  // Glass/Blur effects
  static const Color glassWhite = Color(0x40FFFFFF);
  static const Color glassBlack = Color(0x40000000);
  
  // Shadows (with opacity)
  static Color primaryShadow = primary.withOpacity(0.3);
  static Color cardShadow = Colors.black.withOpacity(0.1);
  static Color heavyShadow = Colors.black.withOpacity(0.25);
}

