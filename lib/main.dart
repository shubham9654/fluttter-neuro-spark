import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'common/theme/app_theme.dart';
import 'common/routes/app_router.dart';
import 'common/utils/hive_service.dart';
import 'common/utils/constants.dart';
import 'core/services/firebase_service.dart';
import 'core/services/notification_service.dart';

/// NeuroSpark Main Entry Point
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await FirebaseService.initialize();
  
  // Initialize local storage
  await HiveService.init();
  
  // Initialize notifications
  await notificationService.initialize();
  
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
    const ProviderScope(
      child: NeuroSparkApp(),
    ),
  );
}

/// NeuroSpark App Root Widget
class NeuroSparkApp extends StatelessWidget {
  const NeuroSparkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      
      // Theme
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      
      // Navigation
      routerConfig: AppRouter.router,
      
      // Builder for additional configuration
      builder: (context, child) {
        return child ?? const SizedBox.shrink();
      },
    );
  }
}
