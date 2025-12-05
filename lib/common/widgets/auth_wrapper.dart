import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/auth_providers.dart';

/// Auth Wrapper that checks authentication state
/// Shows loading while checking, then redirects based on auth status
class AuthWrapper extends ConsumerWidget {
  final Widget child;
  
  const AuthWrapper({
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateChangesProvider);
    
    return authState.when(
      data: (user) {
        // User is authenticated, show the child
        return child;
      },
      loading: () {
        // Show loading while checking auth state
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
      error: (error, stack) {
        // On error, show child anyway (offline mode)
        return child;
      },
    );
  }
}

