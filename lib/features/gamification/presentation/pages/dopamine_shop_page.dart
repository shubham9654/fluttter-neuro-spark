import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../common/theme/app_colors.dart';
import '../../../../common/theme/text_styles.dart';
import '../../../../common/utils/constants.dart';
import '../../../../common/utils/haptic_helper.dart';
import '../../../../core/providers/game_stats_providers.dart';
import 'package:go_router/go_router.dart';

/// Dopamine Shop Page
/// Reward store where users can spend coins
class DopamineShopPage extends ConsumerWidget {
  const DopamineShopPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameStats = ref.watch(gameStatsProvider);

    final shopItems = [
      ShopItem(
        id: 'theme_sunset',
        name: 'Sunset Theme',
        description: 'Warm colors for evening productivity',
        price: 100,
        icon: Icons.wb_twilight_rounded,
        color: AppColors.warningOrange,
        category: 'Themes',
      ),
      ShopItem(
        id: 'theme_ocean',
        name: 'Ocean Theme',
        description: 'Calming blues for focused work',
        price: 100,
        icon: Icons.water_rounded,
        color: Colors.blue,
        category: 'Themes',
      ),
      ShopItem(
        id: 'sound_rain',
        name: 'Rain Sounds',
        description: 'Gentle rain for concentration',
        price: 50,
        icon: FontAwesomeIcons.cloudRain,
        color: Colors.blueGrey,
        category: 'Sounds',
      ),
      ShopItem(
        id: 'sound_cafe',
        name: 'Café Ambience',
        description: 'Coffee shop background noise',
        price: 50,
        icon: FontAwesomeIcons.mugHot,
        color: Colors.brown,
        category: 'Sounds',
      ),
      ShopItem(
        id: 'avatar_1',
        name: 'Phoenix Avatar',
        description: 'Rise from procrastination',
        price: 200,
        icon: FontAwesomeIcons.fireFlameSimple,
        color: AppColors.warningOrange,
        category: 'Avatars',
      ),
      ShopItem(
        id: 'avatar_2',
        name: 'Dragon Avatar',
        description: 'Master of focus',
        price: 200,
        icon: FontAwesomeIcons.dragon,
        color: AppColors.accentPurple,
        category: 'Avatars',
      ),
      ShopItem(
        id: 'power_2x',
        name: '2x XP Boost',
        description: 'Double XP for 24 hours',
        price: 150,
        icon: FontAwesomeIcons.bolt,
        color: AppColors.accentYellow,
        category: 'Power-ups',
      ),
      ShopItem(
        id: 'power_streak',
        name: 'Streak Shield',
        description: 'Protect your streak for 1 day',
        price: 100,
        icon: FontAwesomeIcons.shield,
        color: AppColors.successGreen,
        category: 'Power-ups',
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(12),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              FontAwesomeIcons.brain,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
        title: const Text('Dopamine Shop'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: AppColors.accentYellow.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const FaIcon(
                  FontAwesomeIcons.coins,
                  size: 16,
                  color: AppColors.accentYellow,
                ),
                const SizedBox(width: 6),
                Text(
                  '${gameStats.coins}',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.all(AppConstants.paddingM),
                padding: const EdgeInsets.all(AppConstants.paddingL),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.accentYellow, AppColors.warningOrange],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accentYellow.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const FaIcon(
                            FontAwesomeIcons.shop,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              const FaIcon(
                                FontAwesomeIcons.coins,
                                size: 16,
                                color: AppColors.accentYellow,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${gameStats.coins}',
                                style: AppTextStyles.titleMedium.copyWith(
                                  color: AppColors.textDark,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.paddingM),
                    Text(
                      'Reward Yourself',
                      style: AppTextStyles.headlineLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'You\'ve earned it! 🎉',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Shop Items Grid
            SliverPadding(
              padding: const EdgeInsets.all(AppConstants.paddingM),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: AppConstants.paddingM,
                  mainAxisSpacing: AppConstants.paddingM,
                  childAspectRatio: 0.85,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = shopItems[index];
                    final canAfford = gameStats.coins >= item.price;
                    final isUnlocked =
                        gameStats.unlockedItems.contains(item.id);

                    return _buildShopItemCard(
                      context,
                      ref,
                      item,
                      canAfford,
                      isUnlocked,
                    );
                  },
                  childCount: shopItems.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShopItemCard(
    BuildContext context,
    WidgetRef ref,
    ShopItem item,
    bool canAfford,
    bool isUnlocked,
  ) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: canAfford && !isUnlocked
            ? () => _purchaseItem(context, ref, item)
            : null,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isUnlocked
                  ? AppColors.successGreen
                  : AppColors.borderLight,
              width: isUnlocked ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.cardShadow,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(AppConstants.paddingM),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: item.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        item.icon,
                        color: item.color,
                        size: 32,
                      ),
                    ),
                    const Spacer(),

                    // Name
                    Text(
                      item.name,
                      style: AppTextStyles.titleSmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Description
                    Text(
                      item.description,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textLight,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppConstants.paddingS),

                    // Price/Status
                    if (isUnlocked)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.successGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.check_circle_rounded,
                              size: 16,
                              color: AppColors.successGreen,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Owned',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.successGreen,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Row(
                        children: [
                          const FaIcon(
                            FontAwesomeIcons.coins,
                            size: 14,
                            color: AppColors.accentYellow,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${item.price}',
                            style: AppTextStyles.labelMedium.copyWith(
                              color: canAfford
                                  ? AppColors.textDark
                                  : AppColors.errorRed,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),

              // Lock overlay
              if (!canAfford && !isUnlocked)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: FaIcon(
                        FontAwesomeIcons.lock,
                        color: AppColors.textLight,
                        size: 32,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _purchaseItem(BuildContext context, WidgetRef ref, ShopItem item) {
    HapticHelper.mediumImpact();

    // Check if user has enough coins
    final gameStats = ref.read(gameStatsProvider);
    if (gameStats.coins < item.price) {
      // Not enough coins - offer to buy coins via IAP
      _showBuyCoinsDialog(context, ref, item.price - gameStats.coins);
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Purchase ${item.name}?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.description),
            const SizedBox(height: 16),
            Row(
              children: [
                const FaIcon(
                  FontAwesomeIcons.coins,
                  size: 16,
                  color: AppColors.accentYellow,
                ),
                const SizedBox(width: 8),
                Text(
                  '${item.price} coins',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Purchase item with coins
              final gameStats = ref.read(gameStatsProvider);
              if (gameStats.coins >= item.price) {
                ref.read(gameStatsProvider.notifier).purchaseItem(
                  item.id, 
                  item.price,
                  itemName: item.name,
                );

                Navigator.pop(context);
                HapticHelper.heavyImpact();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${item.name} unlocked! 🎉'),
                    backgroundColor: AppColors.successGreen,
                  ),
                );
              } else {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Not enough coins. Need ${item.price}, have ${gameStats.coins}'),
                    backgroundColor: AppColors.errorRed,
                  ),
                );
              }
            },
            child: const Text('Purchase'),
          ),
        ],
      ),
    );
  }
  
  void _showBuyCoinsDialog(BuildContext context, WidgetRef ref, int coinsNeeded) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Not Enough Coins'),
        content: Text(
          'You need ${coinsNeeded} more coins. Would you like to buy coins?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to subscription page to buy coins
              context.push('/settings/subscription');
            },
            child: const Text('Buy Coins'),
          ),
        ],
      ),
    );
  }
}

class ShopItem {
  final String id;
  final String name;
  final String description;
  final int price;
  final IconData icon;
  final Color color;
  final String category;

  ShopItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.icon,
    required this.color,
    required this.category,
  });
}

