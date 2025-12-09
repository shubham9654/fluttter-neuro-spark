import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Stripe service integrated with Firebase Cloud Functions.
///
/// This service uses Firebase Functions to create PaymentIntents and ephemeral keys,
/// eliminating the need for a separate backend server.
class StripeService {
  static bool _isInitialized = false;
  static FirebaseFunctions? _functions;

  /// Initialize Stripe SDK and Firebase Functions.
  ///
  /// If [publishableKey] is null, the service will try to read the
  /// `STRIPE_PUBLISHABLE_KEY` dart-define. When no key is available we log and
  /// skip initialization so the app can continue to run.
  static Future<void> initialize({
    String? publishableKey,
    String? merchantIdentifier,
    String? urlScheme,
    FirebaseFunctions? functions,
  }) async {
    final key =
        publishableKey ??
        const String.fromEnvironment('STRIPE_PUBLISHABLE_KEY');

    if (key.isEmpty) {
      debugPrint('⚠️ Stripe publishable key missing; skipping initialization.');
      return;
    }

    Stripe.publishableKey = key;
    if (merchantIdentifier != null) {
      Stripe.merchantIdentifier = merchantIdentifier;
    }
    if (urlScheme != null) {
      Stripe.urlScheme = urlScheme;
    }

    await Stripe.instance.applySettings();
    _functions = functions ?? FirebaseFunctions.instance;
    _isInitialized = true;
    debugPrint('✅ Stripe initialized with Firebase Functions');
  }

  /// Create a payment intent via Firebase Function.
  ///
  /// Calls the `createPaymentIntent` Firebase Function with the amount and currency.
  /// Returns the payment intent client secret needed for the payment sheet.
  static Future<String> createPaymentIntent({
    required int amount, // Amount in cents (e.g., 1000 = $10.00)
    required String currency, // e.g., 'usd'
    Map<String, dynamic>? metadata,
  }) async {
    if (_functions == null) {
      throw Exception(
        'Firebase Functions not initialized. Call StripeService.initialize().',
      );
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User must be authenticated to create payment intent');
      }

      final callable = _functions!.httpsCallable('createPaymentIntent');
      final result = await callable.call({
        'amount': amount,
        'currency': currency,
        'customerId': user.uid,
        'metadata': metadata ?? {},
      });

      final data = result.data as Map<String, dynamic>;
      final clientSecret = data['clientSecret'] as String?;

      if (clientSecret == null) {
        throw Exception(
          'Failed to get payment intent client secret from Firebase Function',
        );
      }

      debugPrint('✅ Payment intent created: ${data['paymentIntentId']}');
      return clientSecret;
    } catch (e) {
      debugPrint('❌ Error creating payment intent: $e');
      rethrow;
    }
  }

  /// Create or retrieve a Stripe customer and get ephemeral key.
  ///
  /// Calls the `createEphemeralKey` Firebase Function to get an ephemeral key
  /// for the current user.
  static Future<Map<String, String>> createEphemeralKey() async {
    if (_functions == null) {
      throw Exception(
        'Firebase Functions not initialized. Call StripeService.initialize().',
      );
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User must be authenticated to create ephemeral key');
      }

      final callable = _functions!.httpsCallable('createEphemeralKey');
      final result = await callable.call({'customerId': user.uid});

      final data = result.data as Map<String, dynamic>;
      final customerId = data['customerId'] as String?;
      final ephemeralKeySecret = data['ephemeralKeySecret'] as String?;

      if (customerId == null || ephemeralKeySecret == null) {
        throw Exception(
          'Failed to get customer ID or ephemeral key from Firebase Function',
        );
      }

      debugPrint('✅ Ephemeral key created for customer: $customerId');
      return {
        'customerId': customerId,
        'ephemeralKeySecret': ephemeralKeySecret,
      };
    } catch (e) {
      debugPrint('❌ Error creating ephemeral key: $e');
      rethrow;
    }
  }

  /// Complete payment flow: create payment intent, get ephemeral key, and present payment sheet.
  ///
  /// This is a convenience method that handles the entire payment flow.
  static Future<void> pay({
    required int amount, // Amount in cents
    required String currency, // e.g., 'usd'
    String merchantDisplayName = 'NeuroSpark',
    Map<String, dynamic>? metadata,
  }) async {
    if (!_isInitialized) {
      throw Exception(
        'Stripe not initialized. Call StripeService.initialize().',
      );
    }

    try {
      // Step 1: Create payment intent
      debugPrint('📦 Creating payment intent...');
      final paymentIntentClientSecret = await createPaymentIntent(
        amount: amount,
        currency: currency,
        metadata: metadata,
      );

      // Step 2: Get ephemeral key
      debugPrint('🔑 Creating ephemeral key...');
      final keys = await createEphemeralKey();

      // Step 3: Present payment sheet
      debugPrint('💳 Presenting payment sheet...');
      await presentPaymentSheet(
        paymentIntentClientSecret: paymentIntentClientSecret,
        customerId: keys['customerId']!,
        customerEphemeralKeySecret: keys['ephemeralKeySecret']!,
        merchantDisplayName: merchantDisplayName,
      );

      debugPrint('✅ Payment completed successfully');
    } catch (e) {
      debugPrint('❌ Payment failed: $e');
      rethrow;
    }
  }

  /// Present the Stripe Payment Sheet.
  ///
  /// This method is used internally by [pay] but can also be called directly
  /// if you already have the payment intent and ephemeral key.
  static Future<void> presentPaymentSheet({
    required String paymentIntentClientSecret,
    required String customerId,
    required String customerEphemeralKeySecret,
    String merchantDisplayName = 'NeuroSpark',
  }) async {
    if (!_isInitialized) {
      throw Exception(
        'Stripe not initialized. Call StripeService.initialize().',
      );
    }

    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        merchantDisplayName: merchantDisplayName,
        paymentIntentClientSecret: paymentIntentClientSecret,
        customerId: customerId,
        customerEphemeralKeySecret: customerEphemeralKeySecret,
        style: ThemeMode.system,
      ),
    );

    await Stripe.instance.presentPaymentSheet();
  }
}
