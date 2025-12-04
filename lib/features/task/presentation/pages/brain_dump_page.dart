import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../../common/theme/app_colors.dart';
import '../../../../common/theme/text_styles.dart';
import '../../../../common/utils/constants.dart';
import '../../../../common/utils/haptic_helper.dart';
import '../../../../common/widgets/bottom_nav_bar.dart';
import '../../data/models/task.dart';
import '../../data/repositories/task_repository.dart';
import '../widgets/glass_jar.dart';

/// Screen 4: The Brain Dump (Inbox)
/// FR-B1: Quick capture with minimal friction
class BrainDumpPage extends StatefulWidget {
  const BrainDumpPage({super.key});

  @override
  State<BrainDumpPage> createState() => _BrainDumpPageState();
}

class _BrainDumpPageState extends State<BrainDumpPage>
    with SingleTickerProviderStateMixin {
  final _taskRepository = TaskRepository();
  final _textController = TextEditingController();
  final _focusNode = FocusNode();
  
  List<Task> _tasks = [];
  late AnimationController _animationController;
  bool _isAdding = false;

  @override
  void initState() {
    super.initState();
    _loadTasks();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _loadTasks() {
    setState(() {
      _tasks = _taskRepository.getInboxTasks();
    });
  }

  Future<void> _addTask() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isAdding = true;
    });

    await HapticHelper.lightImpact();

    // Create task
    await _taskRepository.createTask(title: text);

    // Trigger animation
    await _animationController.forward();
    
    // Clear input
    _textController.clear();
    
    // Reload tasks
    _loadTasks();

    // Reset animation
    _animationController.reset();
    
    setState(() {
      _isAdding = false;
    });
  }

  void _navigateToSorter() async {
    await HapticHelper.mediumImpact();
    if (mounted) {
      context.push('/sorter');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_tasks.isEmpty) {
      // Show empty state (Screen 14)
      return _EmptyBrainDumpState(
        onNavigate: (index) {
          // Handle navigation
        },
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primary.withOpacity(0.05),
                  AppColors.backgroundLight,
                ],
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(AppConstants.paddingL),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Brain Dump',
                                style: AppTextStyles.displaySmall,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Just capture. Don\'t think.',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textMedium,
                                ),
                              ),
                            ],
                          ),
                          if (_tasks.isNotEmpty)
                            ElevatedButton.icon(
                              onPressed: _navigateToSorter,
                              icon: const Icon(Icons.sort_rounded, size: 18),
                              label: const Text('Sort'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Glass Jar with tasks
                Expanded(
                  child: Center(
                    child: GlassJar(
                      tasks: _tasks,
                      isAdding: _isAdding,
                      animationController: _animationController,
                    ),
                  ),
                ),

                // Task counter
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.paddingL,
                    vertical: AppConstants.paddingS,
                  ),
                  child: Text(
                    '${_tasks.length} ${_tasks.length == 1 ? "thought" : "thoughts"} captured',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textMedium,
                    ),
                  ),
                ),

                // Input field
                Container(
                  padding: const EdgeInsets.all(AppConstants.paddingL),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.cardShadow,
                        blurRadius: 8,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    top: false,
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _textController,
                            focusNode: _focusNode,
                            decoration: InputDecoration(
                              hintText: 'What\'s on your mind?',
                              filled: true,
                              fillColor: AppColors.backgroundLight,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            textInputAction: TextInputAction.send,
                            onSubmitted: (_) => _addTask(),
                            enabled: !_isAdding,
                          ),
                        ),
                        const SizedBox(width: AppConstants.paddingM),
                        IconButton(
                          onPressed: _isAdding ? null : _addTask,
                          icon: Icon(
                            _isAdding
                                ? Icons.hourglass_empty
                                : Icons.send_rounded,
                            color: _isAdding ? AppColors.textLight : AppColors.primary,
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.primary.withOpacity(0.1),
                            padding: const EdgeInsets.all(12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: 1,
        onTap: (index) {
          // Handle navigation
          if (index == 0) context.go('/dashboard');
          if (index == 2) context.push('/lobby');
          if (index == 3) context.push('/shop');
        },
      ),
    );
  }
}

/// Empty Brain Dump State (Screen 14)
class _EmptyBrainDumpState extends StatelessWidget {
  final Function(int) onNavigate;

  const _EmptyBrainDumpState({
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Stack(
        children: [
          // Gradient background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primary.withOpacity(0.05),
                  AppColors.backgroundLight,
                  AppColors.primaryLight.withOpacity(0.05),
                ],
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.paddingXL),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Zen illustration placeholder
                    Container(
                      padding: const EdgeInsets.all(AppConstants.paddingXL),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        FontAwesomeIcons.spa,
                        size: 80,
                        color: AppColors.primary,
                      ),
                    ),

                    const SizedBox(height: AppConstants.paddingXL),

                    Text(
                      'Your mind is clear',
                      style: AppTextStyles.displaySmall,
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: AppConstants.paddingM),

                    Text(
                      'Nothing captured yet.\nJust the sound of peaceful productivity.',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textMedium,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: AppConstants.paddingXL),

                    Text(
                      '💭 Tap below to capture your first thought',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textLight,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: 1,
        onTap: onNavigate,
      ),
    );
  }
}

