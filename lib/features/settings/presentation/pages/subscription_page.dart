import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../common/theme/app_colors.dart';
import '../../../../common/theme/text_styles.dart';
import '../../../../common/widgets/themed_button.dart';
import '../../../../common/utils/constants.dart';
import '../../../../core/services/payment_service.dart';
import '../../../../core/providers/game_stats_providers.dart';
import '../../../../core/services/firestore_service.dart';

/// Subscription/Premium Page
class SubscriptionPage extends ConsumerStatefulWidget {
  const SubscriptionPage({super.key});

  @override
  ConsumerState<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends ConsumerState<SubscriptionPage> {
  List<ProductDetails> _products = [];
  bool _isLoading = true;
  bool _isPurchasing = false;

  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;

  @override
  void initState() {
    super.initState();
    _loadProducts();
    
    // Listen to purchase updates
    _purchaseSubscription = PaymentService.purchaseUpdated.listen((purchases) {
      debugPrint('📦 Received ${purchases.length} purchase updates');
      // Handle purchase updates
      for (var purchase in purchases) {
        debugPrint('Purchase status: ${purchase.status}, Product: ${purchase.productID}');
        if (purchase.status == PurchaseStatus.purchased ||
            purchase.status == PurchaseStatus.restored) {
          _handlePurchaseSuccess(purchase);
        } else if (purchase.status == PurchaseStatus.error) {
          debugPrint('❌ Purchase error: ${purchase.error}');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Purchase error: ${purchase.error?.message ?? "Unknown error"}'),
                backgroundColor: AppColors.errorRed,
              ),
            );
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _purchaseSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final productIds = {
        PaymentService.premiumMonthly,
        PaymentService.premiumYearly,
        PaymentService.removeAds,
        PaymentService.coins100,
        PaymentService.coins500,
        PaymentService.coins1000,
      };

      final products = await PaymentService.getProducts(productIds: productIds);
      
      debugPrint('✅ Loaded ${products.length} products');
      if (products.isEmpty) {
        debugPrint('⚠️ No products found. Make sure products are configured in store console.');
      }
      
      if (mounted) {
        setState(() {
          _products = products;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error loading products: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading products: ${e.toString()}'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    }
  }

  Future<void> _purchaseProduct(ProductDetails product) async {
    if (_isPurchasing) return;
    
    if (!mounted) return;
    
    setState(() {
      _isPurchasing = true;
    });

    try {
      debugPrint('🛒 Attempting to purchase: ${product.id}');
      final success = await PaymentService.purchaseProduct(product);
      
      if (!mounted) return;
      
      setState(() {
        _isPurchasing = false;
      });

      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Purchase failed. Please try again.'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      } else {
        debugPrint('✅ Purchase initiated successfully');
        // Purchase will be handled by _handlePurchaseSuccess when it completes
      }
    } catch (e) {
      debugPrint('❌ Error during purchase: $e');
      if (mounted) {
        setState(() {
          _isPurchasing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Purchase error: ${e.toString()}'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    }
  }

  Future<void> _restorePurchases() async {
    await PaymentService.restorePurchases();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Purchases restored!'),
          backgroundColor: AppColors.successGreen,
        ),
      );
    }
  }
  
  Future<void> _handlePurchaseSuccess(PurchaseDetails purchase) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      debugPrint('❌ Cannot handle purchase: User not authenticated');
      return;
    }
    
    final firestore = FirestoreService();
    
    try {
      // Parse transaction date
      DateTime? purchaseDate;
      String? transactionId = purchase.purchaseID ?? purchase.transactionDate;
      
      if (purchase.transactionDate != null) {
        final transactionDate = int.tryParse(purchase.transactionDate!);
        if (transactionDate != null) {
          purchaseDate = DateTime.fromMillisecondsSinceEpoch(transactionDate);
        }
      }
      purchaseDate ??= DateTime.now();
      
      // Save purchase to history
      await firestore.savePurchaseHistory(
        productId: purchase.productID,
        productType: _getProductType(purchase.productID),
        transactionId: transactionId ?? 'unknown',
        purchaseDate: purchaseDate,
        price: purchase.verificationData.source,
        metadata: {
          'purchaseID': purchase.purchaseID,
          'status': purchase.status.toString(),
        },
      );
      
      // Handle different purchase types
      switch (purchase.productID) {
        case PaymentService.coins100:
          ref.read(gameStatsProvider.notifier).addCoins(100);
          debugPrint('✅ Added 100 coins');
          break;
        case PaymentService.coins500:
          ref.read(gameStatsProvider.notifier).addCoins(500);
          debugPrint('✅ Added 500 coins');
          break;
        case PaymentService.coins1000:
          ref.read(gameStatsProvider.notifier).addCoins(1000);
          debugPrint('✅ Added 1000 coins');
          break;
        case PaymentService.premiumMonthly:
        case PaymentService.premiumYearly:
          // Save subscription to Firestore
          Timestamp? premiumUntil;
          premiumUntil = Timestamp.fromDate(
            purchaseDate.add(
              purchase.productID == PaymentService.premiumYearly
                  ? const Duration(days: 365)
                  : const Duration(days: 30),
            ),
          );
          
          final updates = <String, dynamic>{
            'isPremium': true,
            'premiumUntil': premiumUntil,
            'premiumProductId': purchase.productID,
            'premiumPurchaseDate': Timestamp.fromDate(purchaseDate),
          };
          
          await firestore.updateUserDocument(updates);
          debugPrint('✅ Premium subscription activated');
          break;
        case PaymentService.removeAds:
          // Save ads removed to Firestore
          await firestore.updateUserDocument({
            'adsRemoved': true,
            'adsRemovedDate': Timestamp.fromDate(purchaseDate),
          });
          debugPrint('✅ Ads removed');
          break;
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Purchase successful: ${purchase.productID} 🎉'),
            backgroundColor: AppColors.successGreen,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Error handling purchase: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error processing purchase: ${e.toString()}'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    }
  }
  
  String _getProductType(String productId) {
    if (productId == PaymentService.premiumMonthly || 
        productId == PaymentService.premiumYearly) {
      return 'subscription';
    } else if (productId == PaymentService.removeAds) {
      return 'non_consumable';
    } else {
      return 'consumable';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Premium & Subscriptions'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.paddingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(AppConstants.paddingXL),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary,
                          AppColors.primaryDark,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 64,
                          color: Colors.white,
                        ),
                        const SizedBox(height: AppConstants.paddingM),
                        Text(
                          'Unlock Premium Features',
                          style: AppTextStyles.headlineMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppConstants.paddingS),
                        Text(
                          'Get the most out of NeuroSpark',
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: Colors.white.withOpacity(0.9),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: AppConstants.paddingXL),
                  
                  // Show message if no products
                  if (_products.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(AppConstants.paddingXL),
                      decoration: BoxDecoration(
                        color: AppColors.warningOrange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.warningOrange),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            size: 48,
                            color: AppColors.warningOrange,
                          ),
                          const SizedBox(height: AppConstants.paddingM),
                          Text(
                            'No Products Available',
                            style: AppTextStyles.titleMedium.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: AppConstants.paddingS),
                          Text(
                            'Products need to be configured in Google Play Console or App Store Connect.',
                            style: AppTextStyles.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  
                  // Premium Subscriptions
                  if (_products.any((p) => p.id == PaymentService.premiumMonthly ||
                      p.id == PaymentService.premiumYearly)) ...[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Premium Subscriptions',
                          style: AppTextStyles.headlineSmall.copyWith(
                            color: AppColors.textDark,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppConstants.paddingM),
                        ..._products
                            .where((p) => p.id == PaymentService.premiumMonthly ||
                                p.id == PaymentService.premiumYearly)
                            .map((product) => _buildProductCard(
                                  product: product,
                                  isPremium: true,
                                )),
                      ],
                    ),
                    const SizedBox(height: AppConstants.paddingXL),
                  ],
                  
                  // Remove Ads
                  if (_products.any((p) => p.id == PaymentService.removeAds)) ...[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Remove Ads',
                          style: AppTextStyles.headlineSmall.copyWith(
                            color: AppColors.textDark,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppConstants.paddingM),
                        _buildProductCard(
                          product: _products.firstWhere(
                            (p) => p.id == PaymentService.removeAds,
                          ),
                          isPremium: false,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.paddingXL),
                  ],
                  
                  // Coins
                  if (_products.any((p) => p.id == PaymentService.coins100 ||
                      p.id == PaymentService.coins500 ||
                      p.id == PaymentService.coins1000)) ...[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Buy Coins',
                          style: AppTextStyles.headlineSmall.copyWith(
                            color: AppColors.textDark,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppConstants.paddingM),
                        ..._products
                            .where((p) => p.id == PaymentService.coins100 ||
                                p.id == PaymentService.coins500 ||
                                p.id == PaymentService.coins1000)
                            .map((product) => _buildProductCard(
                                  product: product,
                                  isPremium: false,
                                )),
                      ],
                    ),
                    const SizedBox(height: AppConstants.paddingXL),
                  ],
                  
                  const SizedBox(height: AppConstants.paddingXL),
                  
                  // Restore purchases
                  ThemedSecondaryButton(
                    text: 'Restore Purchases',
                    onPressed: _restorePurchases,
                    isExpanded: true,
                    icon: Icons.restore,
                  ),
                  
                  const SizedBox(height: AppConstants.paddingL),
                  
                  // Terms
                  Text(
                    'By purchasing, you agree to our Terms of Service and Privacy Policy. Subscriptions will auto-renew unless cancelled.',
                    style: AppTextStyles.captionText.copyWith(
                      color: AppColors.textMedium,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildProductCard({
    required ProductDetails product,
    required bool isPremium,
  }) {
    final isYearly = product.id == PaymentService.premiumYearly;
    
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingM),
      padding: const EdgeInsets.all(AppConstants.paddingL),
      decoration: BoxDecoration(
        color: isPremium ? AppColors.primary.withOpacity(0.1) : Colors.white,
        border: Border.all(
          color: isPremium ? AppColors.primary : AppColors.borderLight,
          width: isPremium ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isPremium)
                      Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isYearly ? 'Premium Yearly' : 'Premium Monthly',
                            style: AppTextStyles.titleMedium.copyWith(
                              color: AppColors.textDark,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      )
                    else
                      Text(
                        product.title,
                        style: AppTextStyles.titleMedium.copyWith(
                          color: AppColors.textDark,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      product.description,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textMedium,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                product.price,
                style: AppTextStyles.headlineSmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingM),
          ThemedPrimaryButton(
            text: 'Purchase',
            onPressed: _isPurchasing
                ? () {}
                : () => _purchaseProduct(product),
            isExpanded: true,
            isLoading: _isPurchasing,
          ),
        ],
      ),
    );
  }
}

