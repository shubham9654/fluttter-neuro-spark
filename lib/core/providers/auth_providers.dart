import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';

/// Provider for AuthService
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

/// Provider for auth state changes stream
final authStateChangesProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

/// Provider to trigger user refresh (counter that increments on refresh)
class UserRefreshNotifier extends Notifier<int> {
  @override
  int build() => 0;
  
  void refresh() {
    state = state + 1;
  }
}

final _userRefreshTriggerProvider = NotifierProvider<UserRefreshNotifier, int>(() {
  return UserRefreshNotifier();
});

/// Provider for current user (reactive to auth state changes and user updates)
final currentUserProvider = Provider<User?>((ref) {
  // Watch auth state changes to react to sign in/out
  final authState = ref.watch(authStateChangesProvider);
  
  // Watch refresh trigger to force re-evaluation when user data is updated
  ref.watch(_userRefreshTriggerProvider);
  
  // Get current user - this will be updated when user.reload() is called
  final currentUser = FirebaseAuth.instance.currentUser;
  
  return authState.when(
    data: (user) => user ?? currentUser,
    loading: () => currentUser,
    error: (_, __) => currentUser,
  );
});

/// Helper function to refresh current user provider
void refreshCurrentUser(WidgetRef ref) {
  ref.read(_userRefreshTriggerProvider.notifier).refresh();
}

