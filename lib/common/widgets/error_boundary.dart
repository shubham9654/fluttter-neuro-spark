import 'package:flutter/material.dart';

/// Error Boundary Widget
/// Catches errors and shows a friendly error screen
class ErrorBoundary extends StatelessWidget {
  final Widget child;
  final Widget? fallback;

  const ErrorBoundary({
    super.key,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        try {
          return child;
        } catch (e, stack) {
          debugPrint('❌ Widget Error: $e');
          debugPrint('📍 Stack: $stack');
          
          return fallback ??
              Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      const Text(
                        'Something went wrong',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          e.toString(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // Try to reload
                          Navigator.of(context).pushReplacementNamed('/');
                        },
                        child: const Text('Go Home'),
                      ),
                    ],
                  ),
                ),
              );
        }
      },
    );
  }
}

