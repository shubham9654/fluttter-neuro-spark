import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../../common/theme/app_colors.dart';
import '../../../../common/theme/text_styles.dart';
import '../../../../common/utils/constants.dart';
import '../../../../core/providers/auth_providers.dart';
import '../../../../core/providers/game_stats_providers.dart';
import '../../../../core/services/notification_service.dart';

/// Settings Page
/// Main settings hub with profile, preferences, and app settings
class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _darkMode = false;
  bool _notifications = true;
  bool _sounds = true;
  bool _haptics = true;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final gameStats = ref.watch(gameStatsProvider);
    final authService = ref.watch(authServiceProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: CustomScrollView(
        slivers: [
          // App Bar with Logo and Name
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const FaIcon(
                      FontAwesomeIcons.brain,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'NeuroSpark',
                    style: AppTextStyles.titleLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.accentPurple],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
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
                  // Profile Card
                  Container(
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
                    child: Row(
                      children: [
                        // Avatar
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primary,
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: user?.photoURL != null
                                ? ClipOval(
                                    child: Image.network(
                                      user!.photoURL!,
                                      width: 66,
                                      height: 66,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Text(
                                    (user?.displayName?[0] ?? 'N')
                                        .toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(width: AppConstants.paddingM),
                        // User Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user?.displayName ?? 'NeuroSpark User',
                                style: AppTextStyles.titleMedium.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (user?.email != null)
                                Text(
                                  user!.email!,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.textLight,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              const SizedBox(height: 8),
                              // Level Badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.accentPurple.withOpacity(
                                    0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const FaIcon(
                                      FontAwesomeIcons.bolt,
                                      size: 12,
                                      color: AppColors.accentPurple,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Level ${gameStats.level}',
                                      style: AppTextStyles.labelSmall.copyWith(
                                        color: AppColors.accentPurple,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Edit Icon
                        IconButton(
                          onPressed: () {
                            context.push('/settings/edit-profile');
                          },
                          icon: const FaIcon(
                            FontAwesomeIcons.penToSquare,
                            size: 20,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppConstants.paddingXL),

                  // Stats Section
                  Text('Your Stats', style: AppTextStyles.titleLarge),
                  const SizedBox(height: AppConstants.paddingM),
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
                          icon: FontAwesomeIcons.coins,
                          value: '${gameStats.coins}',
                          label: 'Coins',
                          color: AppColors.accentYellow,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.paddingM),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          icon: FontAwesomeIcons.checkCircle,
                          value: '${gameStats.tasksCompleted}',
                          label: 'Tasks Done',
                          color: AppColors.successGreen,
                        ),
                      ),
                      const SizedBox(width: AppConstants.paddingM),
                      Expanded(
                        child: _buildStatCard(
                          icon: FontAwesomeIcons.clock,
                          value: '${gameStats.totalFocusMinutes}m',
                          label: 'Focus Time',
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppConstants.paddingXL),

                  // App Settings
                  Text('App Settings', style: AppTextStyles.titleLarge),
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
                        _buildSwitchTile(
                          icon: FontAwesomeIcons.moon,
                          title: 'Dark Mode',
                          subtitle: 'Switch to dark theme',
                          value: _darkMode,
                          onChanged: (value) {
                            setState(() => _darkMode = value);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Dark mode coming soon!'),
                              ),
                            );
                          },
                        ),
                        const Divider(height: 1),
                        _buildSwitchTile(
                          icon: FontAwesomeIcons.bell,
                          title: 'Notifications',
                          subtitle: 'Task reminders & updates',
                          value: _notifications,
                          onChanged: (value) async {
                            if (value) {
                              // Request permission
                              final granted = await notificationService
                                  .requestPermissions();
                              if (granted) {
                                setState(() => _notifications = true);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Notifications enabled! 🔔',
                                      ),
                                      backgroundColor: AppColors.successGreen,
                                    ),
                                  );
                                }
                              } else {
                                if (context.mounted) {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Permission Required'),
                                      content: const Text(
                                        'Please enable notifications in your device settings to receive task reminders.',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            notificationService
                                                .openNotificationSettings();
                                          },
                                          child: const Text('Open Settings'),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              }
                            } else {
                              setState(() => _notifications = false);
                              await notificationService
                                  .cancelAllNotifications();
                            }
                          },
                        ),
                        const Divider(height: 1),
                        _buildSwitchTile(
                          icon: FontAwesomeIcons.volumeHigh,
                          title: 'Sounds',
                          subtitle: 'Audio feedback & effects',
                          value: _sounds,
                          onChanged: (value) {
                            setState(() => _sounds = value);
                          },
                        ),
                        const Divider(height: 1),
                        _buildSwitchTile(
                          icon: FontAwesomeIcons.mobile,
                          title: 'Haptic Feedback',
                          subtitle: 'Vibration on interactions',
                          value: _haptics,
                          onChanged: (value) {
                            setState(() => _haptics = value);
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppConstants.paddingXL),

                  // Premium & Subscription
                  Container(
                    padding: const EdgeInsets.all(AppConstants.paddingL),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryDark],
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Premium',
                              style: AppTextStyles.titleLarge.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppConstants.paddingM),
                        Text(
                          'Unlock premium features, remove ads, and support NeuroSpark',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                        const SizedBox(height: AppConstants.paddingL),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              context.push('/settings/subscription');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'View Plans',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppConstants.paddingXL),

                  // More Options
                  Text('More', style: AppTextStyles.titleLarge),
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
                          icon: FontAwesomeIcons.palette,
                          title: 'Theme Customization',
                          subtitle: 'Colors & appearance',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Coming soon!')),
                            );
                          },
                        ),
                        const Divider(height: 1),
                        _buildSettingsTile(
                          icon: FontAwesomeIcons.language,
                          title: 'Language',
                          subtitle: 'English (US)',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Coming soon!')),
                            );
                          },
                        ),
                        const Divider(height: 1),
                        _buildSettingsTile(
                          icon: FontAwesomeIcons.shield,
                          title: 'Privacy Policy',
                          subtitle: 'How we protect your data',
                          onTap: () {
                            context.push('/settings/privacy-policy');
                          },
                        ),
                        const Divider(height: 1),
                        _buildSettingsTile(
                          icon: FontAwesomeIcons.fileContract,
                          title: 'Terms of Service',
                          subtitle: 'App usage terms',
                          onTap: () {
                            context.push('/settings/terms-of-service');
                          },
                        ),
                        const Divider(height: 1),
                        _buildSettingsTile(
                          icon: FontAwesomeIcons.circleInfo,
                          title: 'About NeuroSpark',
                          subtitle: 'Version 1.0.0',
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
                                  'ADHD-optimized productivity app with low friction, high reward design.\n\nBuilt with ❤️ for the neurodivergent community.',
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
                            content: const Text(
                              'Are you sure you want to sign out?',
                            ),
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
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(
                          color: AppColors.errorRed,
                          width: 2,
                        ),
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

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      secondary: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: FaIcon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(
        title,
        style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textLight),
      ),
      value: value,
      onChanged: onChanged,
      activeThumbColor: AppColors.primary,
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
        style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textLight),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: AppColors.textLight,
      ),
    );
  }
}
