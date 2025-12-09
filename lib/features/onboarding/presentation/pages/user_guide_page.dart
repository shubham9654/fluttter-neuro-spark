import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../common/utils/hive_service.dart';
import 'package:go_router/go_router.dart';

import '../../../../common/theme/app_colors.dart';
import '../../../../common/theme/text_styles.dart';
import '../../../../common/utils/constants.dart';

class UserGuidePage extends StatelessWidget {
  const UserGuidePage({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    final steps = <_GuideStep>[
      _GuideStep(
        icon: FontAwesomeIcons.userPlus,
        title: 'Create your account',
        description:
            'Use email + password or Continue with Google to register quickly.',
      ),
      _GuideStep(
        icon: FontAwesomeIcons.idBadge,
        title: 'Set your profile',
        description: 'Update display name and bio in Settings → Edit Profile.',
      ),
      _GuideStep(
        icon: FontAwesomeIcons.penFancy,
        title: 'Create tasks (Brain Dump)',
        description:
            'Tap Brain Dump to add tasks quickly. Swipe right to add to Today, swipe left to delete.',
      ),
      _GuideStep(
        icon: FontAwesomeIcons.listCheck,
        title: 'Organize tasks',
        description:
            'Use the Sorter to move tasks between Today / Not Today. Keep Today lean (max 3 ideal).',
      ),
      _GuideStep(
        icon: FontAwesomeIcons.coins,
        title: 'Rewards & shop',
        description: 'Spend coins in the Dopamine Shop on items and themes.',
      ),
      _GuideStep(
        icon: FontAwesomeIcons.clock,
        title: 'Focus sessions',
        description:
            'Start a 25-minute focus timer; completing sessions earns XP and coins.',
      ),
      _GuideStep(
        icon: FontAwesomeIcons.bell,
        title: 'Enable notifications',
        description: 'Allow reminders for tasks and focus sessions.',
      ),
      _GuideStep(
        icon: FontAwesomeIcons.signOutAlt,
        title: 'Switch accounts safely',
        description:
            'Use Sign Out in Settings—your local data is cleared per user.',
      ),
      _GuideStep(
        icon: FontAwesomeIcons.circleQuestion,
        title: 'Troubleshooting',
        description:
            'Profile or coins not updating? Check connectivity, then refresh.',
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Welcome Guide'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppConstants.paddingM),
              Text(
                'Quick start for new users',
                style: AppTextStyles.titleLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppConstants.paddingS),
              Text(
                'Follow these steps to get productive fast.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textMedium,
                ),
              ),
              const SizedBox(height: AppConstants.paddingL),
              Expanded(
                child: ListView.separated(
                  itemCount: steps.length,
                  separatorBuilder: (_, __) => const SizedBox(
                    height: AppConstants.paddingS,
                  ),
                  itemBuilder: (context, index) {
                    final step = steps[index];
                    return _GuideCard(step: step, index: index + 1);
                  },
                ),
              ),
              const SizedBox(height: AppConstants.paddingM),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        if (userId != null) {
                          await HiveService.setUserGuideSeen(userId);
                        }
                        if (context.mounted) {
                          context.go('/dashboard/inbox');
                        }
                      },
                      icon: const Icon(Icons.playlist_add_rounded),
                      label: const Text('Go to Brain Dump'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: AppColors.primary, width: 2),
                        foregroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppConstants.paddingS),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        if (userId != null) {
                          await HiveService.setUserGuideSeen(userId);
                        }
                        if (context.mounted) {
                          context.go('/sorter');
                        }
                      },
                      icon: const Icon(Icons.tune_rounded),
                      label: const Text('Open Sorter'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: AppColors.primary, width: 2),
                        foregroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.paddingS),
              ElevatedButton.icon(
                onPressed: () async {
                  if (userId != null) {
                    await HiveService.setUserGuideSeen(userId);
                  }
                  if (context.mounted) {
                    context.go('/dashboard');
                  }
                },
                icon: const Icon(Icons.arrow_forward_rounded),
                label: const Text('Continue to Dashboard'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GuideCard extends StatelessWidget {
  const _GuideCard({required this.step, required this.index});

  final _GuideStep step;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingM),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primary.withOpacity(0.1),
            foregroundColor: AppColors.primary,
            child: Text(
              '$index',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: AppConstants.paddingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    FaIcon(step.icon, size: 16, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        step.title,
                        style: AppTextStyles.titleSmall.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  step.description,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textMedium,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GuideStep {
  const _GuideStep({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;
}

