import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../common/theme/app_colors.dart';
import '../../../../common/theme/text_styles.dart';
import '../../../../common/utils/constants.dart';
import '../../../../core/providers/auth_providers.dart';
import '../../../../core/providers/game_stats_providers.dart';

/// Profile Page
/// User profile with stats, settings, and account management
class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final userProfileAsync = ref.watch(userProfileProvider);
    final gameStats = ref.watch(gameStatsProvider);
    final profileData = userProfileAsync.maybeWhen(
      data: (data) => data,
      orElse: () => null,
    );
    final hasProfileName =
        ((profileData?['displayName'] as String?)?.isNotEmpty ?? false);
    final hasProfileEmail =
        ((profileData?['email'] as String?)?.isNotEmpty ?? false);

    String displayName = user?.displayName ?? 'NeuroSpark User';
    String? email = user?.email;

    if (hasProfileName) {
      displayName = profileData?['displayName'] as String? ?? displayName;
    }
    if (hasProfileEmail) {
      email = profileData?['email'] as String?;
    }
    final emailDisplay = email ?? '';
    final hasEmail = emailDisplay.isNotEmpty;
    final authService = ref.watch(authServiceProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: CustomScrollView(
        slivers: [
          // App Bar with gradient
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.accentPurple],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      // Avatar
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Center(
                          child: user?.photoURL != null
                              ? ClipOval(
                                  child: Image.network(
                                    user?.photoURL ?? '',
                                    width: 92,
                                    height: 92,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Text(
                                  displayName.isNotEmpty
                                      ? displayName[0].toUpperCase()
                                      : 'N',
                                  style: TextStyle(
                                    fontSize: 40,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Name
                      Text(
                        displayName,
                        style: AppTextStyles.titleLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (hasEmail)
                        Text(
                          emailDisplay,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.paddingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats Cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          icon: FontAwesomeIcons.fire,
                          value: '${gameStats.currentStreak}',
                          label: 'Day Streak',
                          color: AppColors.warningOrange,
                        ),
                      ),
                      const SizedBox(width: AppConstants.paddingM),
                      Expanded(
                        child: _buildStatCard(
                          icon: FontAwesomeIcons.bolt,
                          value: 'Level ${gameStats.level}',
                          label: '${gameStats.totalXp} XP',
                          color: AppColors.accentPurple,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.paddingM),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          icon: FontAwesomeIcons.coins,
                          value: '${gameStats.coins}',
                          label: 'Coins',
                          color: AppColors.accentYellow,
                        ),
                      ),
                      const SizedBox(width: AppConstants.paddingM),
                      Expanded(
                        child: _buildStatCard(
                          icon: FontAwesomeIcons.checkCircle,
                          value: '${gameStats.tasksCompleted}',
                          label: 'Tasks Done',
                          color: AppColors.successGreen,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppConstants.paddingXL),

                  // Achievements Section
                  Text(
                    'Achievements',
                    style: AppTextStyles.titleLarge,
                  ),
                  const SizedBox(height: AppConstants.paddingM),
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
                      children: [
                        _buildAchievementRow(
                          icon: FontAwesomeIcons.trophy,
                          title: 'Focus Master',
                          description: '${gameStats.totalFocusMinutes} minutes focused',
                          color: AppColors.accentYellow,
                        ),
                        const Divider(height: 24),
                        _buildAchievementRow(
                          icon: FontAwesomeIcons.rocket,
                          title: 'Productivity Streak',
                          description: 'Longest: ${gameStats.longestStreak} days',
                          color: AppColors.warningOrange,
                        ),
                        const Divider(height: 24),
                        _buildAchievementRow(
                          icon: FontAwesomeIcons.star,
                          title: 'Task Warrior',
                          description: '${gameStats.tasksCompleted} tasks completed',
                          color: AppColors.accentPurple,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppConstants.paddingXL),

                  // Settings Section
                  Text(
                    'Settings',
                    style: AppTextStyles.titleLarge,
                  ),
                  const SizedBox(height: AppConstants.paddingM),
                  Container(
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
                      children: [
                        _buildSettingsTile(
                          icon: FontAwesomeIcons.bell,
                          title: 'Notifications',
                          subtitle: 'Manage your notifications',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Coming soon!')),
                            );
                          },
                        ),
                        const Divider(height: 1),
                        _buildSettingsTile(
                          icon: FontAwesomeIcons.palette,
                          title: 'Theme',
                          subtitle: 'Customize app appearance',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Coming soon!')),
                            );
                          },
                        ),
                        const Divider(height: 1),
                        _buildSettingsTile(
                          icon: FontAwesomeIcons.volumeHigh,
                          title: 'Sounds',
                          subtitle: 'Focus sounds & effects',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Coming soon!')),
                            );
                          },
                        ),
                        const Divider(height: 1),
                        _buildSettingsTile(
                          icon: FontAwesomeIcons.circleInfo,
                          title: 'About',
                          subtitle: 'App version & info',
                          onTap: () {
                            showAboutDialog(
                              context: context,
                              applicationName: 'NeuroSpark',
                              applicationVersion: '1.0.0',
                              applicationIcon: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  FontAwesomeIcons.brain,
                                  color: Colors.white,
                                  size: 32,
                                ),
                              ),
                              children: [
                                const Text(
                                  'ADHD-optimized productivity app with low friction, high reward design.',
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppConstants.paddingXL),

                  // Sign Out Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Sign Out'),
                            content: const Text('Are you sure you want to sign out?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                style: TextButton.styleFrom(
                                  foregroundColor: AppColors.errorRed,
                                ),
                                child: const Text('Sign Out'),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true && context.mounted) {
                          await authService.signOut();
                          // Navigation will be handled by auth state listener
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: AppColors.errorRed, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const FaIcon(
                            FontAwesomeIcons.rightFromBracket,
                            size: 18,
                            color: AppColors.errorRed,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Sign Out',
                            style: AppTextStyles.labelLarge.copyWith(
                              color: AppColors.errorRed,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: AppConstants.paddingXL),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingM),
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
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: FaIcon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
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
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementRow({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: FaIcon(icon, color: color, size: 24),
        ),
        const SizedBox(width: AppConstants.paddingM),
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
              Text(
                description,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textLight,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: FaIcon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(
        title,
        style: AppTextStyles.bodyLarge.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.textLight,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: AppColors.textLight,
      ),
    );
  }
}

