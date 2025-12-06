import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'common/theme/app_theme.dart';
import 'common/routes/app_router.dart';
import 'common/utils/constants.dart';
import 'common/utils/hive_service.dart';
import 'core/services/firebase_service.dart';
import 'core/services/ad_service.dart';
import 'core/services/payment_service.dart';
import 'core/services/notification_service.dart';

/// NeuroSpark Main Entry Point
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Enable error handling
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('🚨 Flutter Error: ${details.exception}');
    debugPrint('📍 Stack: ${details.stack}');
  };
  
  // Initialize Firebase (non-blocking - app will work offline)
  try {
    await FirebaseService.initialize();
  } catch (e) {
    debugPrint('⚠️ Firebase initialization failed: $e');
    debugPrint('📱 App will run in offline mode');
  }
  
  // Initialize Hive (non-blocking - app will work without local storage)
  try {
    await HiveService.init();
    debugPrint('✅ Hive initialized successfully');
  } catch (e) {
    debugPrint('⚠️ Hive initialization failed: $e');
    debugPrint('📱 App will run without local storage');
  }
  
  // Initialize AdMob (non-blocking)
  try {
    await AdService.initialize();
  } catch (e) {
    debugPrint('⚠️ AdMob initialization failed: $e');
  }
  
  // Initialize In-App Purchases (non-blocking)
  try {
    await PaymentService.initialize();
  } catch (e) {
    debugPrint('⚠️ Payment service initialization failed: $e');
  }

  // Initialize Notifications (non-blocking)
  try {
    await NotificationService().initialize();
  } catch (e) {
    debugPrint('⚠️ Notification service initialization failed: $e');
  }
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  
  runApp(
    ProviderScope(
      child: const NeuroSparkApp(),
    ),
  );
}

/// NeuroSpark App Root Widget
class NeuroSparkApp extends ConsumerWidget {
  const NeuroSparkApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      
      // Theme
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      
      // Navigation
      routerConfig: AppRouter.router,
    );
  }
}
