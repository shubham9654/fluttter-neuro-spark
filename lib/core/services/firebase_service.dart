import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../../firebase_options.dart';

/// Firebase initialization service
class FirebaseService {
  static bool _isConfigured = false;
  
  static bool get isConfigured => _isConfigured;
  
  static Future<void> initialize() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      _isConfigured = true;
      debugPrint('✅ Firebase initialized successfully');
    } catch (e) {
      _isConfigured = false;
      debugPrint('⚠️ Firebase not configured: $e');
      debugPrint('📱 Running in offline mode - authentication disabled');
      rethrow;
    }
  }
}

