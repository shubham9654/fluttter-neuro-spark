import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:confetti/confetti.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../common/theme/app_colors.dart';
import '../../../../common/theme/text_styles.dart';
import '../../../../common/utils/constants.dart';
import '../../../../common/widgets/themed_button.dart';
import '../../../../core/providers/game_stats_providers.dart';

/// Victory Page
/// Celebration screen after completing a focus session
class VictoryPage extends ConsumerStatefulWidget {
  const VictoryPage({super.key});

  @override
  ConsumerState<VictoryPage> createState() => _VictoryPageState();
}

class _VictoryPageState extends ConsumerState<VictoryPage>
    with SingleTickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );

    // Start animations
    Future.delayed(const Duration(milliseconds: 300), () {
      _confettiController.play();
      _scaleController.forward();
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameStats = ref.watch(gameStatsProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.paddingL),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Victory Animation
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                          ),
                          Container(
                            width: 100,
                            height: 100,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check_rounded,
                              size: 60,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: AppConstants.paddingXL),

                  // Victory Text
                  Text(
                    '🎉 Amazing Work!',
                    style: AppTextStyles.displaySmall,
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: AppConstants.paddingM),

                  Text(
                    'You completed a focus session!',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.textMedium,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: AppConstants.paddingXL),

                  // Rewards Card
                  Container(
                    padding: const EdgeInsets.all(AppConstants.paddingL),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.cardShadow,
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          'You earned:',
                          style: AppTextStyles.titleMedium.copyWith(
                            color: AppColors.textMedium,
                          ),
                        ),
                        const SizedBox(height: AppConstants.paddingL),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildRewardItem(
                              icon: FontAwesomeIcons.star,
                              value: '+25',
                              label: 'XP',
                              color: AppColors.accentYellow,
                            ),
                            _buildRewardItem(
                              icon: FontAwesomeIcons.coins,
                              value: '+10',
                              label: 'Coins',
                              color: AppColors.accentYellow,
                            ),
                            _buildRewardItem(
                              icon: FontAwesomeIcons.fire,
                              value: '+1',
                              label: 'Streak',
                              color: AppColors.warningOrange,
                            ),
                          ],
                        ),
                        const SizedBox(height: AppConstants.paddingL),
                        Container(
                          padding: const EdgeInsets.all(AppConstants.paddingM),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const FaIcon(
                                FontAwesomeIcons.trophy,
                                color: AppColors.primary,
                                size: 20,
                              ),
                              const SizedBox(width: AppConstants.paddingS),
                              Text(
                                'Level ${gameStats.level}',
                                style: AppTextStyles.titleMedium.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Actions
                  Column(
                    children: [
                      ThemedPrimaryButton(
                        text: 'Back to Dashboard',
                        onPressed: () => context.go('/dashboard'),
                        isExpanded: true,
                        icon: Icons.home_rounded,
                      ),
                      const SizedBox(height: AppConstants.paddingM),
                      TextButton(
                        onPressed: () => context.push('/shop'),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const FaIcon(
                              FontAwesomeIcons.shop,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Spend Coins in Shop',
                              style: AppTextStyles.labelMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              colors: const [
                AppColors.primary,
                AppColors.accentYellow,
                AppColors.accentPink,
                AppColors.accentPurple,
              ],
              numberOfParticles: 30,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: FaIcon(icon, color: color, size: 28),
        ),
        const SizedBox(height: AppConstants.paddingS),
        Text(
          value,
          style: AppTextStyles.titleLarge.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.textLight,
          ),
        ),
      ],
    );
  }
}

