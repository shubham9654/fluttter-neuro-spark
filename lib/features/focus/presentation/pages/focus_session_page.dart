import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../common/theme/app_colors.dart';
import '../../../../common/theme/text_styles.dart';
import '../../../../common/utils/constants.dart';
import '../../../../common/utils/haptic_helper.dart';
import '../../../../common/widgets/themed_button.dart';
import '../../../../core/providers/task_providers.dart';
import '../../../../core/providers/game_stats_providers.dart';
import '../../../../core/services/notification_service.dart';
import '../../../task/data/models/task.dart';

/// Focus Session Page
/// Pomodoro-style focus timer with ADHD-optimized features
class FocusSessionPage extends ConsumerStatefulWidget {
  final String taskId;

  const FocusSessionPage({super.key, required this.taskId});

  @override
  ConsumerState<FocusSessionPage> createState() => _FocusSessionPageState();
}

class _FocusSessionPageState extends ConsumerState<FocusSessionPage>
    with SingleTickerProviderStateMixin {
  Timer? _timer;
  int _secondsRemaining = 25 * 60; // 25 minutes default
  bool _isRunning = false;
  final bool _isBreak = false;
  late AnimationController _pulseController;
  bool _nearEndNotificationSent = false;
  bool _completionNotificationSent = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _isRunning = true;
      _nearEndNotificationSent = false;
      _completionNotificationSent = false;
    });
    HapticHelper.mediumImpact();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
          
          // Send notification when 5 minutes remaining
          if (_secondsRemaining <= 5 * 60 && !_nearEndNotificationSent) {
            _nearEndNotificationSent = true;
            _sendNearEndNotification();
          }
          
          // Auto-complete if time ends and not marked
          if (_secondsRemaining == 0) {
            _onTimerComplete();
          }
        }
      });
    });
  }
  
  void _sendNearEndNotification() {
    final task = ref.read(tasksProvider).firstWhere(
      (t) => t.id == widget.taskId,
      orElse: () => throw Exception('Task not found'),
    );
    
    NotificationService().sendNotification(
      title: '⏰ Task Almost Complete!',
      body: '${task.title} - 5 minutes remaining. Update your progress?',
      payload: widget.taskId,
    ).catchError((e) {
      debugPrint('Error sending near-end notification: $e');
    });
  }

  void _pauseTimer() {
    setState(() => _isRunning = false);
    _timer?.cancel();
    HapticHelper.lightImpact();
  }

  void _resetTimer() {
    setState(() {
      _isRunning = false;
      _secondsRemaining = 25 * 60;
    });
    _timer?.cancel();
    HapticHelper.mediumImpact();
  }

  void _onTimerComplete() {
    _timer?.cancel();
    setState(() => _isRunning = false);
    HapticHelper.heavyImpact();

    if (!_isBreak) {
      // Focus session completed
      final task = ref
          .read(tasksProvider)
          .firstWhere((t) => t.id == widget.taskId);
      
      // Check if task is already completed
      if (task.status != TaskStatus.completed) {
        // Ask user if they want to mark as complete
        _showCompletionDialog(task);
      } else {
        // Already completed, just navigate
        ref.read(gameStatsProvider.notifier).addFocusMinutes(25);
        context.go('/focus/victory');
      }
    } else {
      // Break completed
      _showBreakCompleteDialog();
    }
  }
  
  void _showCompletionDialog(Task task) {
    if (_completionNotificationSent) return;
    _completionNotificationSent = true;
    
    // Send notification asking for update
    NotificationService().sendNotification(
      title: '✅ Task Time Complete!',
      body: '${task.title} - Mark as complete?',
      payload: widget.taskId,
    ).catchError((e) {
      debugPrint('Error sending completion notification: $e');
    });
    
    // Show dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Task Complete!'),
        content: Text('Time is up for "${task.title}". Would you like to mark it as complete?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Auto-complete after 30 seconds if no response
              Future.delayed(const Duration(seconds: 30), () {
                if (mounted) {
                  final currentTask = ref.read(tasksProvider).firstWhere(
                    (t) => t.id == widget.taskId,
                    orElse: () => task,
                  );
                  if (currentTask.status != TaskStatus.completed) {
                    ref.read(tasksProvider.notifier).completeTask(task.id);
                    ref.read(gameStatsProvider.notifier).addFocusMinutes(25);
                    ref.read(gameStatsProvider.notifier).completeTask();
                    if (mounted) {
                      context.go('/focus/victory');
                    }
                  }
                }
              });
            },
            child: const Text('Not Yet'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(tasksProvider.notifier).completeTask(task.id);
              ref.read(gameStatsProvider.notifier).addFocusMinutes(25);
              ref.read(gameStatsProvider.notifier).completeTask();
              context.go('/focus/victory');
            },
            child: const Text('Mark Complete'),
          ),
        ],
      ),
    );
  }

  void _showBreakCompleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Break Complete!'),
        content: const Text('Ready to start another focus session?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/dashboard');
            },
            child: const Text('Back to Dashboard'),
          ),
          ThemedPrimaryButton(
            text: 'Start Session',
            onPressed: () {
              Navigator.pop(context);
              _resetTimer();
            },
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final task = ref
        .watch(tasksProvider)
        .firstWhere((t) => t.id == widget.taskId);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Focus Session'),
        actions: [
          IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () => _showExitDialog(),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingL),
          child: Column(
            children: [
              // Task info
              Container(
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
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const FaIcon(
                        FontAwesomeIcons.bullseye,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: AppConstants.paddingM),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(task.title, style: AppTextStyles.titleMedium),
                          if (task.description != null)
                            Text(
                              task.description!,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textLight,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Timer Circle
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Container(
                    width: 280,
                    height: 280,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: _isRunning
                              ? AppColors.primary.withOpacity(
                                  0.3 * _pulseController.value,
                                )
                              : Colors.transparent,
                          blurRadius: 40,
                          spreadRadius: 20,
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 280,
                          height: 280,
                          child: CircularProgressIndicator(
                            value: 1 - (_secondsRemaining / (25 * 60)),
                            strokeWidth: 12,
                            backgroundColor: AppColors.borderLight,
                            valueColor: AlwaysStoppedAnimation(
                              _isRunning
                                  ? AppColors.primary
                                  : AppColors.borderMedium,
                            ),
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _formatTime(_secondsRemaining),
                              style: TextStyle(
                                fontSize: 56,
                                fontWeight: FontWeight.bold,
                                color: _isRunning
                                    ? AppColors.primary
                                    : AppColors.textMedium,
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
                              ),
                            ),
                            Text(
                              _isRunning ? 'Stay Focused' : 'Ready to Focus?',
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: AppColors.textLight,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),

              const Spacer(),

              // Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_isRunning || _secondsRemaining < 25 * 60)
                    IconButton(
                      onPressed: _resetTimer,
                      icon: const Icon(Icons.refresh_rounded),
                      iconSize: 32,
                      color: AppColors.textMedium,
                    ),
                  const SizedBox(width: AppConstants.paddingL),
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: _isRunning
                          ? AppColors.warningOrange
                          : AppColors.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color:
                              (_isRunning
                                      ? AppColors.warningOrange
                                      : AppColors.primary)
                                  .withOpacity(0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: _isRunning ? _pauseTimer : _startTimer,
                      icon: Icon(
                        _isRunning
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppConstants.paddingXL),

              // Tips
              Container(
                padding: const EdgeInsets.all(AppConstants.paddingM),
                decoration: BoxDecoration(
                  color: AppColors.accentYellow.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.lightbulb_outline_rounded,
                      color: AppColors.accentYellow,
                    ),
                    const SizedBox(width: AppConstants.paddingS),
                    Expanded(
                      child: Text(
                        'Take breaks every 25 minutes. Your brain needs rest!',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textMedium,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit Focus Session?'),
        content: const Text('Your progress won\'t be saved if you leave now.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Stay'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/dashboard');
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.errorRed),
            child: const Text('Leave'),
          ),
        ],
      ),
    );
  }
}
