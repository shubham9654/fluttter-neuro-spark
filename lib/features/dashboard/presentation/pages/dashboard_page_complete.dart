import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:confetti/confetti.dart';
import '../../../../common/theme/app_colors.dart';
import '../../../../common/theme/text_styles.dart';
import '../../../../common/utils/constants.dart';
import '../../../../common/widgets/themed_button.dart';
import '../../../../core/providers/task_providers.dart';
import '../../../../core/providers/game_stats_providers.dart';
import '../../../../common/utils/hive_service.dart';
import '../../../../core/services/firestore_service.dart';
import '../../../../core/providers/auth_providers.dart';
import '../../../../core/services/ad_service.dart';
import '../../../task/data/models/task.dart';

/// Complete Dashboard Page
/// The main hub showing today's tasks, progress, and quick actions
class DashboardPageComplete extends ConsumerStatefulWidget {
  const DashboardPageComplete({super.key});

  @override
  ConsumerState<DashboardPageComplete> createState() =>
      _DashboardPageCompleteState();
}

class _DashboardPageCompleteState
    extends ConsumerState<DashboardPageComplete> {
  late ConfettiController _confettiController;
  bool _showCoach = false;
  int _coachIndex = 0;
  bool _coachChecked = false;
  final _firestore = FirestoreService();

  final List<_CoachTip> _coachTips = const [
    _CoachTip(
      icon: FontAwesomeIcons.penFancy,
      title: 'Add your first task',
      body: 'Open Brain Dump and type anything. Swipe right to move it into Today, swipe left to delete.',
      ctaLabel: 'Go to Brain Dump',
      ctaRoute: '/dashboard/inbox',
    ),
    _CoachTip(
      icon: FontAwesomeIcons.listCheck,
      title: 'Organize for focus',
      body: 'Use the Sorter to keep only 3 tasks in Today. Move the rest to Not Today.',
      ctaLabel: 'Open Sorter',
      ctaRoute: '/sorter',
    ),
    _CoachTip(
      icon: FontAwesomeIcons.clock,
      title: 'Start a focus session',
      body: 'Pick a Today task and start a 25-minute focus timer to earn XP and coins.',
      ctaLabel: 'Start Focus',
      ctaRoute: '/focus/quick',
    ),
    _CoachTip(
      icon: FontAwesomeIcons.coins,
      title: 'Use your rewards',
      body: 'Spend coins in the Dopamine Shop on themes and items for extra motivation.',
      ctaLabel: 'Open Shop',
      ctaRoute: '/shop',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 2));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _maybeShowCoach();
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _maybeShowCoach() async {
    final uid = ref.read(currentUserProvider)?.uid;
    if (uid == null) return;
    final doneLocal = HiveService.isCoachDone(uid);
    final doneRemote = await _firestore.isGuideShown();
    if (doneLocal || doneRemote) {
      // Sync local to true if remote is true
      if (doneRemote && !doneLocal) {
        await HiveService.setCoachDone(uid, true);
      }
      return;
    }
    // If step not set, start from zero
    if (HiveService.getCoachStep(uid) >= _coachTips.length) {
      await HiveService.setCoachStep(uid, 0);
      await HiveService.setCoachDone(uid, false);
    }
    final savedStep = HiveService.getCoachStep(uid);
    setState(() {
      _showCoach = true;
      _coachIndex = savedStep.clamp(0, _coachTips.length - 1);
    });
  }

  Future<void> _markCoachSeen() async {
    final uid = ref.read(currentUserProvider)?.uid;
    if (uid != null) {
      await HiveService.setCoachDone(uid, true);
      await _firestore.setGuideShown(shown: true);
    }
  }

  void _nextCoach() {
    if (_coachIndex < _coachTips.length - 1) {
      setState(() {
        _coachIndex += 1;
      });
      final uid = ref.read(currentUserProvider)?.uid;
      if (uid != null) {
        HiveService.setCoachStep(uid, _coachIndex);
      }
    } else {
      _closeCoach();
    }
  }

  Future<void> _closeCoach() async {
    await _markCoachSeen();
    if (mounted) {
      setState(() {
        _showCoach = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final todayTasks = ref.watch(todayTasksProvider);
    final gameStats = ref.watch(gameStatsProvider);
    final user = ref.watch(currentUserProvider);
    if (!_coachChecked && user != null) {
      _coachChecked = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _maybeShowCoach();
      });
    }

    final completedToday =
        todayTasks.where((t) => t.status == TaskStatus.completed).length;
    final totalToday = todayTasks.length;
    final progress = totalToday > 0 ? completedToday / totalToday : 0.0;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Stack(
        children: [
          SafeArea(
            child: CustomScrollView(
              slivers: [
                // App Bar
                SliverAppBar(
                  floating: true,
                  backgroundColor: Colors.white,
                  elevation: 0,
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
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getGreeting(),
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.textLight,
                        ),
                      ),
                      Text(
                        user?.displayName?.split(' ').first ?? 'Friend',
                        style: AppTextStyles.headlineMedium,
                      ),
                    ],
                  ),
                  actions: [
                    // XP Badge
                    Container(
                      margin: const EdgeInsets.only(right: 16),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const FaIcon(
                            FontAwesomeIcons.star,
                            size: 16,
                            color: AppColors.accentYellow,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${gameStats.totalXp} XP',
                            style: AppTextStyles.labelMedium.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Content
                SliverPadding(
                  padding: const EdgeInsets.all(AppConstants.paddingM),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Progress Card
                      _buildProgressCard(progress, completedToday, totalToday,
                          gameStats),
                      const SizedBox(height: AppConstants.paddingL),

                      // Quick Actions
                      _buildQuickActions(),
                      const SizedBox(height: AppConstants.paddingL),

                      // Today's Tasks Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Today's Focus",
                            style: AppTextStyles.titleLarge,
                          ),
                          TextButton(
                            onPressed: () => context.push('/dashboard/inbox'),
                            child: const Text('View Inbox'),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppConstants.paddingM),

                      // Tasks List
                      if (todayTasks.isEmpty)
                        _buildEmptyState()
                      else
                        ...todayTasks.map((task) => _buildTaskCard(task)),

                      const SizedBox(height: AppConstants.paddingL),
                      
                      // Ad Banner
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: AppConstants.paddingM),
                        alignment: Alignment.center,
                        child: const BannerAdWidget(),
                      ),

                      const SizedBox(height: AppConstants.paddingXL),
                    ]),
                  ),
                ),
              ],
            ),
          ),

          // Confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              colors: [
                AppColors.primary,
                AppColors.accentYellow,
                AppColors.accentPink,
                AppColors.accentPurple,
              ],
            ),
          ),

          if (_showCoach) _buildCoachOverlay(context),
        ],
      ),

      // Floating Action Button
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/dashboard/inbox'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Task'),
      ),
    );
  }

  Widget _buildProgressCard(
      double progress, int completed, int total, gameStats) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingL),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.accentPurple],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Today\'s Progress',
                style: AppTextStyles.titleMedium.copyWith(
                  color: Colors.white,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '$completed/$total',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingM),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: const AlwaysStoppedAnimation(Colors.white),
            ),
          ),
          const SizedBox(height: AppConstants.paddingM),
          Row(
            children: [
              _buildStatItem('🔥', '${gameStats.currentStreak}', 'Day Streak'),
              const SizedBox(width: AppConstants.paddingL),
              _buildStatItem('⚡', '${gameStats.level}', 'Level'),
              const SizedBox(width: AppConstants.paddingL),
              _buildStatItem('🪙', '${gameStats.coins}', 'Coins'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String emoji, String value, String label) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 6),
              Text(
                value,
                style: AppTextStyles.titleMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _QuickActionCard(
            icon: FontAwesomeIcons.brain,
            label: 'Brain Dump',
            color: AppColors.accentPink,
            onTap: () => context.push('/dashboard/inbox'),
          ),
        ),
        const SizedBox(width: AppConstants.paddingM),
        Expanded(
          child: _QuickActionCard(
            icon: FontAwesomeIcons.bullseye,
            label: 'Focus',
            color: AppColors.primary,
            onTap: () {
              final todayTasks = ref.read(todayTasksProvider);
              if (todayTasks.isNotEmpty) {
                context.push('/focus/${todayTasks.first.id}');
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Add tasks first!')),
                );
              }
            },
          ),
        ),
        const SizedBox(width: AppConstants.paddingM),
        Expanded(
          child: _QuickActionCard(
            icon: FontAwesomeIcons.shop,
            label: 'Shop',
            color: AppColors.accentYellow,
            onTap: () => context.push('/shop'),
          ),
        ),
      ],
    );
  }

  Widget _buildTaskCard(Task task) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingM),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => context.push('/focus/${task.id}'),
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.paddingM),
            child: Row(
              children: [
                // Checkbox
                GestureDetector(
                  onTap: () {
                    ref.read(tasksProvider.notifier).completeTask(task.id);
                    ref.read(gameStatsProvider.notifier).completeTask();
                    _confettiController.play();
                  },
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: task.status == TaskStatus.completed
                            ? AppColors.successGreen
                            : AppColors.borderMedium,
                        width: 2,
                      ),
                      color: task.status == TaskStatus.completed
                          ? AppColors.successGreen
                          : Colors.transparent,
                    ),
                    child: task.status == TaskStatus.completed
                        ? const Icon(Icons.check, size: 18, color: Colors.white)
                        : null,
                  ),
                ),
                const SizedBox(width: AppConstants.paddingM),

                // Task content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: AppTextStyles.bodyLarge.copyWith(
                          decoration: task.status == TaskStatus.completed
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      if (task.description != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          task.description!,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textLight,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),

                // Time estimate
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${task.estimatedMinutes}m',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingXL),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.check_circle_outline_rounded,
            size: 64,
            color: AppColors.textLight,
          ),
          const SizedBox(height: AppConstants.paddingM),
          Text(
            'No tasks for today',
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.textMedium,
            ),
          ),
          const SizedBox(height: AppConstants.paddingS),
          Text(
            'Add tasks to get started',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textLight,
            ),
          ),
          const SizedBox(height: AppConstants.paddingL),
          ThemedPrimaryButton(
            text: 'Add Your First Task',
            onPressed: () => context.push('/dashboard/inbox'),
            icon: Icons.add_rounded,
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  Widget _buildCoachOverlay(BuildContext context) {
    final tip = _coachTips[_coachIndex];
    final isLast = _coachIndex == _coachTips.length - 1;
    return Positioned(
      left: AppConstants.paddingM,
      right: AppConstants.paddingM,
      bottom: AppConstants.paddingL,
      child: Material(
        elevation: 10,
        borderRadius: BorderRadius.circular(18),
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(AppConstants.paddingM),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                    child: FaIcon(
                      tip.icon,
                      color: AppColors.primary,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: AppConstants.paddingS),
                  Expanded(
                    child: Text(
                      tip.title,
                      style: AppTextStyles.titleSmall.copyWith(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _closeCoach,
                    icon: const Icon(Icons.close, color: AppColors.textLight, size: 18),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.paddingS),
              Text(
                tip.body,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textMedium,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: AppConstants.paddingS),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_coachIndex + 1}/${_coachTips.length}',
                      style: AppTextStyles.captionText.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: _closeCoach,
                    child: Text(
                      'Skip',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textLight,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _nextCoach,
                    child: Text(
                      isLast ? 'Got it' : 'Next',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.paddingS),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    if (tip.ctaRoute != null) {
                      context.push(tip.ctaRoute!);
                    }
                  },
                  icon: const Icon(Icons.play_arrow_rounded, size: 18),
                  label: Text(tip.ctaLabel ?? 'Do this now'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: BorderSide(color: AppColors.primary.withOpacity(0.25)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
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
}

class _CoachTip {
  final IconData icon;
  final String title;
  final String body;
  final String? ctaLabel;
  final String? ctaRoute;

  const _CoachTip({
    required this.icon,
    required this.title,
    required this.body,
    this.ctaLabel,
    this.ctaRoute,
  });
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(AppConstants.paddingM),
          decoration: BoxDecoration(
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
                label,
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

