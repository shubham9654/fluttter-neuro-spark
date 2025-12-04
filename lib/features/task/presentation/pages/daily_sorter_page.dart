import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../../common/theme/app_colors.dart';
import '../../../../common/theme/text_styles.dart';
import '../../../../common/widgets/themed_button.dart';
import '../../../../common/utils/constants.dart';
import '../../../../common/utils/haptic_helper.dart';
import '../../data/models/task.dart';
import '../../data/repositories/task_repository.dart';

/// Screen 5: Daily Sorter (The "3-Task Rule")
/// FR-B4: Users swipe to select max 3 tasks for today
class DailySorterPage extends StatefulWidget {
  const DailySorterPage({super.key});

  @override
  State<DailySorterPage> createState() => _DailySorterPageState();
}

class _DailySorterPageState extends State<DailySorterPage> {
  final _taskRepository = TaskRepository();
  final CardSwiperController _swiperController = CardSwiperController();
  
  List<Task> _inboxTasks = [];
  List<Task> _selectedTasks = [];
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  void _loadTasks() {
    setState(() {
      _inboxTasks = _taskRepository.getInboxTasks();
      _selectedTasks = _taskRepository.getTodayTasks();
    });
  }

  Future<void> _onSwipeLeft(int index) async {
    // Not Today
    await HapticHelper.lightImpact();
    final task = _inboxTasks[index];
    await _taskRepository.markTaskAsNotToday(task.id);
    
    setState(() {
      _currentIndex++;
    });
  }

  Future<void> _onSwipeRight(int index) async {
    // Do Today
    await HapticHelper.mediumImpact();
    final task = _inboxTasks[index];
    
    if (_selectedTasks.length >= 3) {
      // Already have 3 tasks
      _showMaxTasksDialog();
      // Return the card
      _swiperController.undo();
      return;
    }
    
    await _taskRepository.markTaskAsToday(task.id);
    
    setState(() {
      _selectedTasks.add(task);
      _currentIndex++;
    });

    // Check if we have 3 tasks
    if (_selectedTasks.length == 3) {
      _showCompleteDialog();
    }
  }

  void _showMaxTasksDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Holy Trinity Complete!'),
        content: const Text(
          'You already have 3 tasks for today. The 3-Task Rule helps prevent overwhelm.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showCompleteDialog() {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('🎯 Perfect!'),
        content: const Text(
          'You\'ve selected your 3 tasks for today. Ready to focus?',
        ),
        actions: [
          ThemedPrimaryButton(
            text: 'Let\'s Go!',
            onPressed: () {
              Navigator.pop(context);
              context.go('/dashboard');
            },
          ),
        ],
      ),
    );
  }

  void _skipSorting() async {
    await HapticHelper.lightImpact();
    context.go('/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    if (_inboxTasks.isEmpty) {
      return _EmptySorterState(
        onBack: () => context.pop(),
      );
    }

    final remainingTasks = _inboxTasks.length - _currentIndex;
    final progress = _currentIndex / _inboxTasks.length;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // Header with progress
            Padding(
              padding: const EdgeInsets.all(AppConstants.paddingL),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: _skipSorting,
                      ),
                      Text(
                        '$remainingTasks left to sort',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.textMedium,
                        ),
                      ),
                      TextButton(
                        onPressed: _skipSorting,
                        child: const Text('Skip'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      backgroundColor: AppColors.borderLight,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),

            // Selected count
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingL,
                vertical: AppConstants.paddingM,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ..._buildDots(),
                ],
              ),
            ),

            // Swipe instructions
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingL,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.arrow_back,
                        color: AppColors.errorRed.withOpacity(0.6),
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Not Today',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.errorRed,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        'Do Today',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.successGreen,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward,
                        color: AppColors.successGreen.withOpacity(0.6),
                        size: 20,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppConstants.paddingL),

            // Card swiper
            Expanded(
              child: _currentIndex < _inboxTasks.length
                  ? CardSwiper(
                      controller: _swiperController,
                      cardsCount: _inboxTasks.length,
                      onSwipe: (previousIndex, currentIndex, direction) {
                        if (direction == CardSwiperDirection.left) {
                          _onSwipeLeft(previousIndex);
                        } else if (direction == CardSwiperDirection.right) {
                          _onSwipeRight(previousIndex);
                        }
                        return true;
                      },
                      cardBuilder: (context, index, horizontalOffset, verticalOffset) {
                        return _TaskCard(task: _inboxTasks[index]);
                      },
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.check_circle_rounded,
                            size: 80,
                            color: AppColors.primary,
                          ),
                          const SizedBox(height: AppConstants.paddingL),
                          Text(
                            'All sorted!',
                            style: AppTextStyles.displaySmall,
                          ),
                          const SizedBox(height: AppConstants.paddingM),
                          ThemedPrimaryButton(
                            text: 'Go to Dashboard',
                            onPressed: () => context.go('/dashboard'),
                          ),
                        ],
                      ),
                    ),
            ),

            // Bottom actions
            Padding(
              padding: const EdgeInsets.all(AppConstants.paddingL),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ActionButton(
                    icon: Icons.close,
                    label: 'Not Today',
                    color: AppColors.errorRed,
                    onPressed: () {
                      if (_currentIndex < _inboxTasks.length) {
                        _swiperController.swipe(CardSwiperDirection.left);
                      }
                    },
                  ),
                  _ActionButton(
                    icon: FontAwesomeIcons.wandMagicSparkles,
                    label: 'AI Break',
                    color: AppColors.accentYellow,
                    onPressed: () {
                      // TODO: Implement AI breakdown
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('AI breakdown coming in Phase 2.5!'),
                        ),
                      );
                    },
                  ),
                  _ActionButton(
                    icon: Icons.check,
                    label: 'Do Today',
                    color: AppColors.successGreen,
                    onPressed: () {
                      if (_currentIndex < _inboxTasks.length) {
                        _swiperController.swipe(CardSwiperDirection.right);
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildDots() {
    return List.generate(3, (index) {
      final isSelected = index < _selectedTasks.length;
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.borderLight,
          shape: BoxShape.circle,
        ),
      );
    });
  }

  @override
  void dispose() {
    _swiperController.dispose();
    super.dispose();
  }
}

/// Task Card Widget
class _TaskCard extends StatelessWidget {
  final Task task;

  const _TaskCard({required this.task});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.paddingL),
      padding: const EdgeInsets.all(AppConstants.paddingXL),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius * 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.heavyShadow,
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            task.title,
            style: AppTextStyles.headlineLarge,
            textAlign: TextAlign.center,
          ),
          if (task.description != null) ...[
            const SizedBox(height: AppConstants.paddingL),
            Text(
              task.description!,
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textMedium,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: AppConstants.paddingXL),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.timer_outlined,
                size: 20,
                color: AppColors.textLight,
              ),
              const SizedBox(width: 4),
              Text(
                '~${task.estimatedMinutes} min',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textLight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Action Button Widget
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IconButton(
          onPressed: onPressed,
          icon: Icon(icon, color: Colors.white),
          style: IconButton.styleFrom(
            backgroundColor: color,
            padding: const EdgeInsets.all(16),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(color: color),
        ),
      ],
    );
  }
}

/// Empty Sorter State
class _EmptySorterState extends StatelessWidget {
  final VoidCallback onBack;

  const _EmptySorterState({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.paddingXL),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.inbox_outlined,
                  size: 80,
                  color: AppColors.textLight,
                ),
                const SizedBox(height: AppConstants.paddingL),
                Text(
                  'Nothing to sort!',
                  style: AppTextStyles.displaySmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppConstants.paddingM),
                Text(
                  'Add some tasks to your inbox first',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textMedium,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppConstants.paddingXL),
                ThemedPrimaryButton(
                  text: 'Go to Inbox',
                  onPressed: onBack,
                  icon: Icons.arrow_back,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

