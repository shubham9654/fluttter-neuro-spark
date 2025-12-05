import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Simple Welcome Page - Minimal version for testing
class WelcomePageSimple extends StatelessWidget {
  const WelcomePageSimple({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFF00C4B4),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Icon(Icons.check, size: 60, color: Colors.white),
            ),
            const SizedBox(height: 24),
            const Text(
              'NeuroSpark',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Low Friction, High Reward',
              style: TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: () {
                context.go('/onboarding/neurotype');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00C4B4),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 48,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Get Started',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    context.push('/login');
                  },
                  child: const Text(
                    'Sign In',
                    style: TextStyle(fontSize: 14, color: Color(0xFF00C4B4)),
                  ),
                ),
                const Text(
                  ' | ',
                  style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                ),
                TextButton(
                  onPressed: () {
                    context.push('/signup');
                  },
                  child: const Text(
                    'Sign Up',
                    style: TextStyle(fontSize: 14, color: Color(0xFF00C4B4)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
