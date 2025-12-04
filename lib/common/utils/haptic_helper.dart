import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

/// Haptic Feedback Helper
/// NFR-2: Extensive use of haptic feedback for physical confirmation
class HapticHelper {
  // Check if device supports vibration
  static Future<bool> get hasVibrator async {
    final result = await Vibration.hasVibrator();
    return result == true;
  }
  
  // Check if device supports custom vibrations
  static Future<bool> get hasCustomVibrationsSupport async {
    final result = await Vibration.hasCustomVibrationsSupport();
    return result == true;
  }
  
  /// Light tap - For selections, toggles
  static Future<void> lightImpact() async {
    await HapticFeedback.lightImpact();
  }
  
  /// Medium tap - For button presses, confirmations
  static Future<void> mediumImpact() async {
    await HapticFeedback.mediumImpact();
  }
  
  /// Heavy tap - For important actions (completing tasks, victories)
  static Future<void> heavyImpact() async {
    await HapticFeedback.heavyImpact();
  }
  
  /// Selection feedback - For scrolling through options
  static Future<void> selectionClick() async {
    await HapticFeedback.selectionClick();
  }
  
  /// Success pattern - For task completions
  static Future<void> success() async {
    if (await hasVibrator) {
      await Vibration.vibrate(pattern: [0, 100, 50, 100], intensities: [0, 128, 0, 255]);
    } else {
      await heavyImpact();
    }
  }
  
  /// Warning pattern - For Doom Box triggers
  static Future<void> warning() async {
    if (await hasVibrator) {
      await Vibration.vibrate(pattern: [0, 200, 100, 200], intensities: [0, 200, 0, 200]);
    } else {
      await mediumImpact();
    }
  }
  
  /// Error pattern - For validation errors
  static Future<void> error() async {
    if (await hasVibrator) {
      await Vibration.vibrate(pattern: [0, 50, 50, 50, 50, 50], intensities: [0, 128, 0, 128, 0, 128]);
    } else {
      await HapticFeedback.vibrate();
    }
  }
  
  /// Custom vibration with duration (milliseconds)
  static Future<void> vibrate({int duration = 100, int intensity = 128}) async {
    if (await hasCustomVibrationsSupport) {
      await Vibration.vibrate(duration: duration, amplitude: intensity);
    } else if (await hasVibrator) {
      await Vibration.vibrate(duration: duration);
    } else {
      await mediumImpact();
    }
  }
  
  /// Cancel any ongoing vibration
  static Future<void> cancel() async {
    await Vibration.cancel();
  }
}

