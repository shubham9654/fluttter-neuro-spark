import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../common/theme/app_colors.dart';
import '../../../../common/theme/text_styles.dart';
import '../../../../common/utils/constants.dart';
import '../../../../common/widgets/themed_button.dart';
import '../../../../common/utils/haptic_helper.dart';
import '../../../../core/services/stripe_service.dart';
import '../../../../core/providers/auth_providers.dart';
import '../../../../core/services/firestore_service.dart';
import '../../data/models/premium_plan.dart';

/// Premium Plans Page with Stripe Integration
class PremiumPlansPage extends ConsumerStatefulWidget {
  const PremiumPlansPage({super.key});

  @override
  ConsumerState<PremiumPlansPage> createState() => _PremiumPlansPageState();
}

class _PremiumPlansPageState extends ConsumerState<PremiumPlansPage> {
  bool _isProcessing = false;
  final _firestore = FirestoreService();

  // Premium Plans
  static const List<PremiumPlan> _plans = [
    PremiumPlan(
      id: 'premium_monthly',
      name: 'Premium Monthly',
      description: 'Full access to all premium features',
      priceInCents: 999, // $9.99
      interval: 'month',
      features: [
        'Unlimited tasks per day',
        'Advanced analytics & insights',
        'Priority support',
        'Exclusive themes & sounds',
        'Cloud sync across devices',
        'Export & backup data',
        'Ad-free experience',
        'Early access to new features',
      ],
    ),
    PremiumPlan(
      id: 'premium_yearly',
      name: 'Premium Yearly',
      description: 'Best value - save 20%',
      priceInCents: 9599, // $95.99 (save ~$24/year)
      interval: 'year',
      features: [
        'Everything in Monthly',
        'Save \$24 per year',
        'Annual progress reports',
        'VIP community access',
        'Beta feature testing',
      ],
      isPopular: true,
    ),
  ];

  Future<void> _purchasePlan(PremiumPlan plan) async {
    if (_isProcessing) return;

    final user = ref.read(currentUserProvider);
    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please sign in to purchase premium'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
      return;
    }

    // Check if Stripe is initialized
    final isStripeInit = StripeService.isInitialized;
    debugPrint('🔍 Checking Stripe initialization status: $isStripeInit');
    
    if (!isStripeInit) {
      debugPrint('⚠️ Stripe not initialized. Attempting to reinitialize...');
      try {
        const String testStripeKey = 'pk_test_51OfkBkSBUDEGpwtLKz9sZGh9c3Mrvpreu8ZVmvNklnIzNnOU1fpIn7V07oTIP9YFXD1PszX90UNAiE362WNuSJxJ00jbEpFe9t';
        await StripeService.initialize(
          publishableKey: testStripeKey,
          urlScheme: 'neuro_spark',
          merchantIdentifier: 'merchant.com.neurospark',
        );
        debugPrint('✅ Stripe reinitialized: ${StripeService.isInitialized}');
      } catch (e) {
        debugPrint('❌ Failed to reinitialize Stripe: $e');
      }
      
      // Check again after reinitialization attempt
      if (!StripeService.isInitialized) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Stripe not configured. Please restart the app.\n'
                'The key is set in code but initialization may have failed.',
              ),
              backgroundColor: AppColors.errorRed,
              duration: Duration(seconds: 5),
            ),
          );
        }
        return;
      }
    }

    setState(() => _isProcessing = true);
    HapticHelper.mediumImpact();

    try {
      // Process payment with Stripe
      await StripeService.pay(
        amount: plan.priceInCents,
        currency: plan.currency,
        metadata: {
          'planId': plan.id,
          'planName': plan.name,
          'interval': plan.interval,
          'userId': user.uid,
        },
      );

      // Payment successful - update user subscription in Firestore
      final now = DateTime.now();
      final expiresAt = plan.interval == 'year'
          ? now.add(const Duration(days: 365))
          : now.add(const Duration(days: 30));

      await _firestore.updateUserDocument({
        'isPremium': true,
        'premiumPlanId': plan.id,
        'premiumUntil': expiresAt.toIso8601String(),
        'premiumPurchaseDate': now.toIso8601String(),
        'premiumInterval': plan.interval,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Premium activated! Welcome to ${plan.name} 🎉',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.successGreen,
            duration: const Duration(seconds: 3),
          ),
        );

        // Navigate back after a short delay
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          context.pop();
        }
      }
    } catch (e) {
      debugPrint('❌ Payment error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment failed: ${e.toString()}'),
            backgroundColor: AppColors.errorRed,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Premium Plans'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
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
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryShadow,
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.star_rounded,
                      size: 48,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingM),
                  Text(
                    'Unlock Premium',
                    style: AppTextStyles.headlineMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingS),
                  Text(
                    'Get the most out of NeuroSpark with premium features',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppConstants.paddingXL),

            // Premium Plans
            ..._plans.map((plan) => _buildPlanCard(plan)),

            const SizedBox(height: AppConstants.paddingXL),

            // Features Comparison
            _buildFeaturesSection(),

            const SizedBox(height: AppConstants.paddingXL),

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

  Widget _buildPlanCard(PremiumPlan plan) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingL),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: plan.isPopular ? AppColors.primary : AppColors.borderLight,
          width: plan.isPopular ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: plan.isPopular
                ? AppColors.primaryShadow
                : AppColors.cardShadow,
            blurRadius: plan.isPopular ? 20 : 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Popular Badge
              if (plan.isPopular)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Text(
                    'MOST POPULAR',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

              Padding(
                padding: const EdgeInsets.all(AppConstants.paddingL),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Plan Name & Price
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                plan.name,
                                style: AppTextStyles.titleLarge.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (plan.savings.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.successGreen.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    plan.savings,
                                    style: AppTextStyles.labelSmall.copyWith(
                                      color: AppColors.successGreen,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              plan.formattedPrice,
                              style: AppTextStyles.headlineMedium.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              plan.interval == 'year' ? 'per year' : 'per month',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textMedium,
                              ),
                            ),
                            if (plan.interval == 'year') ...[
                              const SizedBox(height: 4),
                              Text(
                                plan.pricePerMonth,
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: AppColors.textLight,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: AppConstants.paddingL),

                    // Features List
                    ...plan.features.map((feature) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(top: 4, right: 12),
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check,
                                  size: 16,
                                  color: AppColors.primary,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  feature,
                                  style: AppTextStyles.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                        )),

                    const SizedBox(height: AppConstants.paddingL),

                    // Purchase Button
                    ThemedPrimaryButton(
                      text: _isProcessing ? 'Processing...' : 'Subscribe Now',
                      onPressed: _isProcessing
                          ? () {}
                          : () => _purchasePlan(plan),
                      isExpanded: true,
                      isLoading: _isProcessing,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingL),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
          Row(
            children: [
              const FaIcon(
                FontAwesomeIcons.star,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Premium Features',
                style: AppTextStyles.titleLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingL),
          _buildFeatureRow(
            icon: Icons.all_inclusive,
            title: 'Unlimited Tasks',
            description: 'No daily task limits',
          ),
          const Divider(height: 24),
          _buildFeatureRow(
            icon: Icons.analytics,
            title: 'Advanced Analytics',
            description: 'Track your productivity trends',
          ),
          const Divider(height: 24),
          _buildFeatureRow(
            icon: Icons.cloud_sync,
            title: 'Cloud Sync',
            description: 'Access your data anywhere',
          ),
          const Divider(height: 24),
          _buildFeatureRow(
            icon: Icons.palette,
            title: 'Exclusive Themes',
            description: 'Premium themes & sounds',
          ),
          const Divider(height: 24),
          _buildFeatureRow(
            icon: Icons.block,
            title: 'Ad-Free',
            description: 'Uninterrupted focus experience',
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primary, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.titleSmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textMedium,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

