import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../common/theme/app_colors.dart';
import '../../../../common/theme/text_styles.dart';
import '../../../../common/widgets/themed_button.dart';
import '../../../../common/utils/constants.dart';
import '../../../../core/services/payment_service.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

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

  @override
  void initState() {
    super.initState();
    _loadProducts();
    
    // Listen to purchase updates
    PaymentService.purchaseUpdated.listen((purchases) {
      // Handle purchase updates
      for (var purchase in purchases) {
        if (purchase.status == PurchaseStatus.purchased ||
            purchase.status == PurchaseStatus.restored) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Purchase successful!'),
              backgroundColor: AppColors.successGreen,
            ),
          );
        }
      }
    });
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
    });

    final productIds = {
      PaymentService.premiumMonthly,
      PaymentService.premiumYearly,
      PaymentService.removeAds,
      PaymentService.coins100,
      PaymentService.coins500,
      PaymentService.coins1000,
    };

    final products = await PaymentService.getProducts(productIds: productIds);
    
    setState(() {
      _products = products;
      _isLoading = false;
    });
  }

  Future<void> _purchaseProduct(ProductDetails product) async {
    setState(() {
      _isPurchasing = true;
    });

    final success = await PaymentService.purchaseProduct(product);
    
    setState(() {
      _isPurchasing = false;
    });

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Purchase failed. Please try again.'),
          backgroundColor: AppColors.errorRed,
        ),
      );
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
                  
                  // Premium Subscriptions
                  if (_products.any((p) => p.id == PaymentService.premiumMonthly ||
                      p.id == PaymentService.premiumYearly))
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
                  
                  // Remove Ads
                  if (_products.any((p) => p.id == PaymentService.removeAds))
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
                            orElse: () => _products.first,
                          ),
                          isPremium: false,
                        ),
                      ],
                    ),
                  
                  const SizedBox(height: AppConstants.paddingXL),
                  
                  // Coins
                  if (_products.any((p) => p.id.startsWith('coins_')))
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
                            .where((p) => p.id.startsWith('coins_'))
                            .map((product) => _buildProductCard(
                                  product: product,
                                  isPremium: false,
                                )),
                      ],
                    ),
                  
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

