import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../common/theme/app_colors.dart';
import '../../../../common/theme/text_styles.dart';
import '../../../../common/utils/constants.dart';
import '../../../../core/services/stripe_service.dart';
import '../../../../core/providers/auth_providers.dart';

/// Stripe Test Page - For debugging and verification
class StripeTestPage extends ConsumerStatefulWidget {
  const StripeTestPage({super.key});

  @override
  ConsumerState<StripeTestPage> createState() => _StripeTestPageState();
}

class _StripeTestPageState extends ConsumerState<StripeTestPage> {
  bool _isProcessing = false;
  String _status = 'Ready to test';
  final List<String> _logs = [];

  void _addLog(String message) {
    setState(() {
      _logs.add('${DateTime.now().toString().substring(11, 19)}: $message');
      if (_logs.length > 20) _logs.removeAt(0);
    });
  }

  Future<void> _testStripeInitialization() async {
    setState(() {
      _isProcessing = true;
      _status = 'Testing Stripe initialization...';
    });
    _addLog('Testing Stripe initialization...');

    try {
      // Check if Stripe is initialized
      final isInitialized = StripeService.isInitialized;
      final key = const String.fromEnvironment('STRIPE_PUBLISHABLE_KEY');
      
      _addLog('Stripe initialized status: $isInitialized');
      _addLog('Key from environment: ${key.isEmpty ? "NOT SET" : "SET"}');
      
      if (key.isEmpty) {
        _addLog('❌ STRIPE_PUBLISHABLE_KEY not set');
        _addLog('💡 Run: flutter run --dart-define=STRIPE_PUBLISHABLE_KEY=pk_test_...');
        setState(() {
          _status = '❌ Stripe key not configured';
        });
      } else {
        _addLog('✅ Stripe key found: ${key.substring(0, 20)}...');
        if (isInitialized) {
          _addLog('✅ Stripe is initialized and ready');
          setState(() {
            _status = '✅ Stripe initialized';
          });
        } else {
          _addLog('⚠️ Key is set but Stripe not initialized');
          _addLog('💡 Try reinitializing Stripe...');
          try {
            await StripeService.initialize(
              urlScheme: 'neuro_spark',
              merchantIdentifier: 'merchant.com.neurospark',
            );
            if (StripeService.isInitialized) {
              _addLog('✅ Stripe reinitialized successfully');
              setState(() {
                _status = '✅ Stripe initialized';
              });
            } else {
              _addLog('❌ Stripe initialization failed');
              setState(() {
                _status = '❌ Initialization failed';
              });
            }
          } catch (e) {
            _addLog('❌ Reinitialization error: $e');
            setState(() {
              _status = '❌ Error: $e';
            });
          }
        }
      }
    } catch (e) {
      _addLog('❌ Error: $e');
      setState(() {
        _status = '❌ Error: $e';
      });
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _testPaymentIntent() async {
    setState(() {
      _isProcessing = true;
      _status = 'Testing payment intent creation...';
    });
    _addLog('Testing payment intent creation...');

    try {
      final user = ref.read(currentUserProvider);
      if (user == null) {
        _addLog('❌ User not authenticated');
        setState(() {
          _status = '❌ Please sign in first';
        });
        return;
      }

      _addLog('✅ User authenticated: ${user.uid}');
      _addLog('Creating payment intent for \$9.99...');

      final clientSecret = await StripeService.createPaymentIntent(
        amount: 999, // $9.99
        currency: 'usd',
        metadata: {
          'test': 'true',
          'userId': user.uid,
        },
      );

      _addLog('✅ Payment intent created successfully');
      _addLog('Client secret: ${clientSecret.substring(0, 20)}...');
      setState(() {
        _status = '✅ Payment intent created';
      });
    } catch (e) {
      _addLog('❌ Error: $e');
      setState(() {
        _status = '❌ Error: $e';
      });
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _testEphemeralKey() async {
    setState(() {
      _isProcessing = true;
      _status = 'Testing ephemeral key creation...';
    });
    _addLog('Testing ephemeral key creation...');

    try {
      final user = ref.read(currentUserProvider);
      if (user == null) {
        _addLog('❌ User not authenticated');
        setState(() {
          _status = '❌ Please sign in first';
        });
        return;
      }

      _addLog('✅ User authenticated: ${user.uid}');
      _addLog('Creating ephemeral key...');

      final keys = await StripeService.createEphemeralKey();

      _addLog('✅ Ephemeral key created successfully');
      _addLog('Customer ID: ${keys['customerId']}');
      _addLog('Ephemeral key: ${keys['ephemeralKeySecret']?.substring(0, 20)}...');
      setState(() {
        _status = '✅ Ephemeral key created';
      });
    } catch (e) {
      _addLog('❌ Error: $e');
      setState(() {
        _status = '❌ Error: $e';
      });
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _testFullPayment() async {
    setState(() {
      _isProcessing = true;
      _status = 'Testing full payment flow...';
    });
    _addLog('Testing full payment flow...');

    try {
      final user = ref.read(currentUserProvider);
      if (user == null) {
        _addLog('❌ User not authenticated');
        setState(() {
          _status = '❌ Please sign in first';
        });
        return;
      }

      _addLog('✅ User authenticated: ${user.uid}');
      _addLog('Starting payment for \$9.99...');

      await StripeService.pay(
        amount: 999,
        currency: 'usd',
        metadata: {
          'test': 'true',
          'userId': user.uid,
        },
      );

      _addLog('✅ Payment completed successfully!');
      setState(() {
        _status = '✅ Payment successful';
      });
    } catch (e) {
      _addLog('❌ Payment failed: $e');
      setState(() {
        _status = '❌ Payment failed: $e';
      });
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stripe Integration Test'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Card
            Container(
              padding: const EdgeInsets.all(AppConstants.paddingL),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.cardShadow,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Status',
                    style: AppTextStyles.titleLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingM),
                  Text(
                    _status,
                    style: AppTextStyles.bodyLarge,
                  ),
                  if (user == null) ...[
                    const SizedBox(height: AppConstants.paddingM),
                    Container(
                      padding: const EdgeInsets.all(AppConstants.paddingM),
                      decoration: BoxDecoration(
                        color: AppColors.warningOrange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.warning,
                            color: AppColors.warningOrange,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Please sign in to test payments',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.warningOrange,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: AppConstants.paddingXL),

            // Test Buttons
            Text(
              'Test Functions',
              style: AppTextStyles.titleLarge.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.paddingM),

            _buildTestButton(
              '1. Test Stripe Initialization',
              _testStripeInitialization,
              icon: Icons.check_circle,
            ),
            const SizedBox(height: AppConstants.paddingM),
            _buildTestButton(
              '2. Test Payment Intent',
              _testPaymentIntent,
              icon: Icons.payment,
            ),
            const SizedBox(height: AppConstants.paddingM),
            _buildTestButton(
              '3. Test Ephemeral Key',
              _testEphemeralKey,
              icon: Icons.vpn_key,
            ),
            const SizedBox(height: AppConstants.paddingM),
            _buildTestButton(
              '4. Test Full Payment Flow',
              _testFullPayment,
              icon: Icons.shopping_cart,
              isPrimary: true,
            ),

            const SizedBox(height: AppConstants.paddingXL),

            // Logs
            Text(
              'Test Logs',
              style: AppTextStyles.titleLarge.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.paddingM),
            Container(
              padding: const EdgeInsets.all(AppConstants.paddingM),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(12),
              ),
              constraints: const BoxConstraints(maxHeight: 300),
              child: _logs.isEmpty
                  ? Center(
                      child: Text(
                        'No logs yet. Run a test to see results.',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    )
                  : ListView.builder(
                      reverse: true,
                      itemCount: _logs.length,
                      itemBuilder: (context, index) {
                        final log = _logs[_logs.length - 1 - index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            log,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: Colors.white,
                              fontFamily: 'monospace',
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestButton(
    String label,
    VoidCallback onPressed, {
    IconData? icon,
    bool isPrimary = false,
  }) {
    return ElevatedButton(
      onPressed: _isProcessing ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrimary ? AppColors.primary : Colors.white,
        foregroundColor: isPrimary ? Colors.white : AppColors.primary,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isPrimary ? Colors.transparent : AppColors.borderLight,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20),
            const SizedBox(width: 8),
          ],
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

