import 'dart:async';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:flutter/foundation.dart';

/// Payment Service for managing in-app purchases
class PaymentService {
  static final InAppPurchase _iap = InAppPurchase.instance;
  static bool _isAvailable = false;
  static final StreamController<List<PurchaseDetails>> _purchaseUpdatedController =
      StreamController<List<PurchaseDetails>>.broadcast();
  
  static Stream<List<PurchaseDetails>> get purchaseUpdated => _purchaseUpdatedController.stream;
  
  // Product IDs - Replace with your actual product IDs from Google Play Console / App Store Connect
  static const String premiumMonthly = 'premium_monthly';
  static const String premiumYearly = 'premium_yearly';
  static const String removeAds = 'remove_ads';
  static const String coins100 = 'coins_100';
  static const String coins500 = 'coins_500';
  static const String coins1000 = 'coins_1000';

  /// Initialize the payment service
  static Future<void> initialize() async {
    _isAvailable = await _iap.isAvailable();
    
    if (_isAvailable) {
      // Listen to purchase updates
      _iap.purchaseStream.listen(
        (purchaseDetailsList) {
          _purchaseUpdatedController.add(purchaseDetailsList);
          _handlePurchaseUpdates(purchaseDetailsList);
        },
        onDone: () => _purchaseUpdatedController.close(),
        onError: (error) => debugPrint('Purchase stream error: $error'),
      );
      
      debugPrint('✅ In-App Purchase initialized');
    } else {
      debugPrint('⚠️ In-App Purchase not available');
    }
  }

  /// Get available products
  static Future<List<ProductDetails>> getProducts({
    required Set<String> productIds,
  }) async {
    if (!_isAvailable) {
      debugPrint('⚠️ In-App Purchase not available');
      return [];
    }

    try {
      final ProductDetailsResponse response = await _iap.queryProductDetails(productIds);
      
      if (response.error != null) {
        debugPrint('❌ Error querying products: ${response.error}');
        return [];
      }

      return response.productDetails;
    } catch (e) {
      debugPrint('❌ Exception querying products: $e');
      return [];
    }
  }

  /// Purchase a product
  static Future<bool> purchaseProduct(ProductDetails productDetails) async {
    if (!_isAvailable) {
      debugPrint('⚠️ In-App Purchase not available');
      return false;
    }

    try {
      final PurchaseParam purchaseParam = PurchaseParam(
        productDetails: productDetails,
      );

      if (productDetails.id == premiumMonthly || 
          productDetails.id == premiumYearly ||
          productDetails.id == removeAds) {
        // Subscription or non-consumable
        await _iap.buyNonConsumable(purchaseParam: purchaseParam);
      } else {
        // Consumable (coins, etc.)
        await _iap.buyConsumable(purchaseParam: purchaseParam);
      }

      return true;
    } catch (e) {
      debugPrint('❌ Error purchasing product: $e');
      return false;
    }
  }

  /// Restore purchases
  static Future<void> restorePurchases() async {
    if (!_isAvailable) {
      debugPrint('⚠️ In-App Purchase not available');
      return;
    }

    try {
      await _iap.restorePurchases();
      debugPrint('✅ Purchases restored');
    } catch (e) {
      debugPrint('❌ Error restoring purchases: $e');
    }
  }

  /// Handle purchase updates
  static void _handlePurchaseUpdates(List<PurchaseDetails> purchaseDetailsList) {
    for (final purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        debugPrint('⏳ Purchase pending: ${purchaseDetails.productID}');
      } else if (purchaseDetails.status == PurchaseStatus.purchased ||
                 purchaseDetails.status == PurchaseStatus.restored) {
        debugPrint('✅ Purchase successful: ${purchaseDetails.productID}');
        _handleSuccessfulPurchase(purchaseDetails);
        
        // Complete the purchase
        if (purchaseDetails.pendingCompletePurchase) {
          _iap.completePurchase(purchaseDetails);
        }
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        debugPrint('❌ Purchase error: ${purchaseDetails.error}');
      }
    }
  }

  /// Handle successful purchase
  static void _handleSuccessfulPurchase(PurchaseDetails purchaseDetails) {
    // Import Firestore service to save purchase
    // Note: This should be called from UI layer to access Riverpod providers
    
    switch (purchaseDetails.productID) {
      case premiumMonthly:
      case premiumYearly:
        // Grant premium subscription
        debugPrint('✅ Premium subscription activated: ${purchaseDetails.productID}');
        // TODO: Save to Firestore - users/{uid}/subscription
        break;
      case removeAds:
        // Remove ads
        debugPrint('✅ Ads removed');
        // TODO: Save to Firestore - users/{uid}/preferences/adsRemoved = true
        break;
      case coins100:
        // Add 100 coins
        debugPrint('✅ 100 coins added');
        // TODO: Update game stats - add 100 coins
        break;
      case coins500:
        // Add 500 coins
        debugPrint('✅ 500 coins added');
        // TODO: Update game stats - add 500 coins
        break;
      case coins1000:
        // Add 1000 coins
        debugPrint('✅ 1000 coins added');
        // TODO: Update game stats - add 1000 coins
        break;
    }
  }

  /// Check if user has premium subscription
  static Future<bool> hasPremiumSubscription() async {
    // TODO: Implement check from Firestore or local storage
    return false;
  }

  /// Check if ads are removed
  static Future<bool> areAdsRemoved() async {
    // TODO: Implement check from Firestore or local storage
    return false;
  }

  /// Dispose resources
  static void dispose() {
    _purchaseUpdatedController.close();
  }
}

