import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Import pages as they are created
// Auth
import 'package:neuro_spark/features/auth/presentation/pages/welcome_page.dart';
import 'package:neuro_spark/features/auth/presentation/pages/welcome_page_simple.dart';
import 'package:neuro_spark/features/auth/presentation/pages/login_page.dart';
import 'package:neuro_spark/features/auth/presentation/pages/signup_page.dart';
import 'package:neuro_spark/features/auth/presentation/pages/auth_landing_page.dart';
import 'go_router_refresh_stream.dart';
// Onboarding
import 'package:neuro_spark/features/onboarding/presentation/pages/neurotype_setup_page.dart';
import 'package:neuro_spark/features/onboarding/presentation/pages/energy_mapping_page.dart';
// Dashboard
import 'package:neuro_spark/features/dashboard/presentation/pages/dashboard_page_complete.dart';
// Task
import 'package:neuro_spark/features/task/presentation/pages/brain_dump_page_updated.dart';
import 'package:neuro_spark/features/task/presentation/pages/daily_sorter_page.dart';
// Focus
import 'package:neuro_spark/features/focus/presentation/pages/focus_session_page.dart';
import 'package:neuro_spark/features/focus/presentation/pages/victory_page.dart';
// Body Double
// import 'package:neuro_spark/features/body_double/presentation/pages/lobby_page.dart';
// import 'package:neuro_spark/features/body_double/presentation/pages/session_page.dart';
// Gamification
import 'package:neuro_spark/features/gamification/presentation/pages/dopamine_shop_page.dart';
// Settings
import 'package:neuro_spark/features/settings/presentation/pages/settings_page.dart';
import 'package:neuro_spark/features/settings/presentation/pages/edit_profile_page.dart';
import 'package:neuro_spark/features/settings/presentation/pages/privacy_policy_page.dart';
import 'package:neuro_spark/features/settings/presentation/pages/terms_of_service_page.dart';
import 'package:neuro_spark/features/settings/presentation/pages/subscription_page.dart';
import 'package:neuro_spark/common/widgets/main_scaffold.dart';

/// NeuroSpark App Router
/// Declarative navigation with deep linking support
class AppRouter {
  // Route Names
  static const String welcome = '/';
  static const String dopamineProfile = '/onboarding/neurotype';
  static const String energyMap = '/onboarding/energy';
  static const String dashboard = '/dashboard';
  static const String inbox = '/dashboard/inbox';
  static const String sorter = '/sorter';
  static const String focusActive = '/focus/:taskId';
  static const String victory = '/focus/victory';
  static const String lobby = '/lobby';
  static const String doubleSession = '/lobby/session';
  static const String shop = '/shop';
  static const String settingsSensory = '/settings/sensory';

  // GoRouter Configuration
  static GoRouter createRouter() {
    return GoRouter(
      initialLocation: '/',
      debugLogDiagnostics: true,
      redirect: (context, state) {
        try {
          // Check current user directly from Firebase Auth (more reliable than stream)
          final currentUser = FirebaseAuth.instance.currentUser;
          final isAuthenticated = currentUser != null;
          
          final isAuthRoute = state.matchedLocation == '/' ||
              state.matchedLocation == '/login' ||
              state.matchedLocation == '/signup';
          
          // If user is authenticated and trying to access auth pages, redirect to dashboard
          if (isAuthenticated && isAuthRoute) {
            return '/dashboard';
          }
          
          // If user is not authenticated and trying to access protected pages, redirect to landing
          if (!isAuthenticated && !isAuthRoute) {
            return '/';
          }
        } catch (e) {
          // If there's an error, allow navigation (for initial load or errors)
          debugPrint('Auth redirect error: $e');
        }
        
        return null; // No redirect needed
      },
      refreshListenable: GoRouterRefreshStream(FirebaseAuth.instance.authStateChanges()),
      routes: [
        // Auth Landing Page (First screen)
        GoRoute(
          path: '/',
          name: 'auth_landing',
          pageBuilder: (context, state) => MaterialPage(
            key: state.pageKey,
            child: const AuthLandingPage(),
          ),
        ),
        
      // Welcome page as separate route for testing
      GoRoute(
        path: '/welcome',
        name: 'welcome',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const WelcomePageSimple(),
        ),
      ),

      // Welcome page full version
      GoRoute(
        path: '/welcome-full',
        name: 'welcome_full',
        pageBuilder: (context, state) =>
            MaterialPage(key: state.pageKey, child: const WelcomePage()),
      ),

      // Login page
      GoRoute(
        path: '/login',
        name: 'login',
        pageBuilder: (context, state) =>
            MaterialPage(key: state.pageKey, child: const LoginPage()),
      ),

      // Sign up page
      GoRoute(
        path: '/signup',
        name: 'signup',
        pageBuilder: (context, state) =>
            MaterialPage(key: state.pageKey, child: const SignUpPage()),
      ),

      // Onboarding Flow
      GoRoute(
        path: '/onboarding/neurotype',
        name: 'dopamine_profile',
        pageBuilder: (context, state) =>
            MaterialPage(key: state.pageKey, child: const NeuroTypeSetupPage()),
      ),
      GoRoute(
        path: '/onboarding/energy',
        name: 'energy_map',
        pageBuilder: (context, state) =>
            MaterialPage(key: state.pageKey, child: const EnergyMappingPage()),
      ),

      // Main Dashboard
      GoRoute(
        path: '/dashboard',
        name: 'dashboard',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const MainScaffold(
            currentIndex: 0,
            child: DashboardPageComplete(),
          ),
        ),
        routes: [
          // Inbox (Brain Dump) as sub-route
          GoRoute(
            path: 'inbox',
            name: 'inbox',
            pageBuilder: (context, state) => MaterialPage(
              key: state.pageKey,
              child: const MainScaffold(
                currentIndex: 1,
                child: BrainDumpPageUpdated(),
              ),
            ),
          ),
        ],
      ),

      // Task Sorter
      GoRoute(
        path: '/sorter',
        name: 'sorter',
        pageBuilder: (context, state) =>
            MaterialPage(key: state.pageKey, child: const DailySorterPage()),
      ),

      // Focus Session
      GoRoute(
        path: '/focus/:taskId',
        name: 'focus_active',
        pageBuilder: (context, state) {
          final taskId = state.pathParameters['taskId'] ?? '';
          return MaterialPage(
            key: state.pageKey,
            child: FocusSessionPage(taskId: taskId),
          );
        },
      ),
      GoRoute(
        path: '/focus/victory',
        name: 'victory',
        pageBuilder: (context, state) =>
            MaterialPage(key: state.pageKey, child: const VictoryPage()),
      ),

      // Body Doubling
      GoRoute(
        path: '/lobby',
        name: 'lobby',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const Placeholder(), // BodyDoubleLobbyPage(),
        ),
        routes: [
          GoRoute(
            path: 'session',
            name: 'double_session',
            pageBuilder: (context, state) => MaterialPage(
              key: state.pageKey,
              child: const Placeholder(), // BodyDoubleSessionPage(),
            ),
          ),
        ],
      ),

      // Dopamine Shop
      GoRoute(
        path: '/shop',
        name: 'shop',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const MainScaffold(currentIndex: 2, child: DopamineShopPage()),
        ),
      ),

      // Settings
      GoRoute(
        path: '/settings',
        name: 'settings',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const MainScaffold(currentIndex: 3, child: SettingsPage()),
        ),
        routes: [
          // Edit Profile
          GoRoute(
            path: 'edit-profile',
            name: 'edit_profile',
            pageBuilder: (context, state) => MaterialPage(
              key: state.pageKey,
              child: const EditProfilePage(),
            ),
          ),
          // Privacy Policy
          GoRoute(
            path: 'privacy-policy',
            name: 'privacy_policy',
            pageBuilder: (context, state) => MaterialPage(
              key: state.pageKey,
              child: const PrivacyPolicyPage(),
            ),
          ),
          // Terms of Service
          GoRoute(
            path: 'terms-of-service',
            name: 'terms_of_service',
            pageBuilder: (context, state) => MaterialPage(
              key: state.pageKey,
              child: const TermsOfServicePage(),
            ),
          ),
          // Subscription
          GoRoute(
            path: 'subscription',
            name: 'subscription',
            pageBuilder: (context, state) => MaterialPage(
              key: state.pageKey,
              child: const SubscriptionPage(),
            ),
          ),
        ],
      ),

      // Settings
      GoRoute(
        path: '/settings/sensory',
        name: 'settings_sensory',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const Placeholder(), // SensoryControlPage(),
        ),
      ),
    ],

    // Error handling
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error: ${state.error}',
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => GoRouter.of(context).go('/'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
  }
  
  // Static router instance
  static final GoRouter router = createRouter();
}
