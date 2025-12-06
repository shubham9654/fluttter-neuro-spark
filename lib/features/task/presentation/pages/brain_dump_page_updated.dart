import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../common/theme/app_colors.dart';
import '../../../../common/theme/text_styles.dart';
import '../../../../common/utils/constants.dart';
import '../../../../common/utils/haptic_helper.dart';
import '../../../../core/providers/task_providers.dart';
import '../../../../core/services/speech_service.dart';
import '../../data/models/task.dart';

/// Brain Dump Page (Updated with Riverpod)
/// Quick capture inbox for all tasks and thoughts
class BrainDumpPageUpdated extends ConsumerStatefulWidget {
  const BrainDumpPageUpdated({super.key});

  @override
  ConsumerState<BrainDumpPageUpdated> createState() =>
      _BrainDumpPageUpdatedState();
}

class _BrainDumpPageUpdatedState extends ConsumerState<BrainDumpPageUpdated> {
  final _textController = TextEditingController();
  final _focusNode = FocusNode();
  final _speechService = SpeechService();
  bool _isListening = false;
  bool _isInitializing = false;

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
  }

  Future<void> _initializeSpeech() async {
    setState(() {
      _isInitializing = true;
    });
    await _speechService.initialize();
    setState(() {
      _isInitializing = false;
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    _speechService.dispose();
    super.dispose();
  }

  void _addTask() {
    if (_textController.text.trim().isEmpty) return;

    final createTask = ref.read(createTaskProvider);
    createTask(_textController.text.trim());

    _textController.clear();
    HapticHelper.lightImpact();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Task added to inbox!'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  Future<void> _toggleListening() async {
    if (_isListening) {
      await _speechService.stopListening();
      setState(() {
        _isListening = false;
      });
      HapticHelper.lightImpact();
    } else {
      // Stop any existing listening
      await _speechService.stopListening();
      
      HapticHelper.mediumImpact();
      
      final started = await _speechService.startListening(
        onResult: (text) {
          setState(() {
            _textController.text = text;
          });
        },
        onDone: () {
          setState(() {
            _isListening = false;
          });
          HapticHelper.lightImpact();
        },
      );

      // Don't show error immediately - speech service may still be initializing
      // The status callback will update _isListening when ready
      if (started) {
        setState(() {
          _isListening = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Listening...'),
            duration: Duration(seconds: 1),
          ),
        );
      } else {
        // Only show error if speech service explicitly says it's not available
        // Wait a moment to see if status callback updates
        await Future.delayed(const Duration(milliseconds: 1000));
        if (mounted && !_isListening) {
          // Check if speech service is actually available
          if (!_speechService.isAvailable) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Speech recognition not available. Please check microphone permissions.'),
                backgroundColor: AppColors.errorRed,
                duration: Duration(seconds: 3),
              ),
            );
          }
          // If it's available but just slow to start, don't show error
        }
      }
    }
  }

  void _moveToToday(Task task) {
    ref
        .read(tasksProvider.notifier)
        .updateTask(task.copyWith(status: TaskStatus.today));
    HapticHelper.mediumImpact();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Task added to today!'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final inboxTasks = ref.watch(inboxTasksProvider);

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
        title: const Text('Brain Dump'),
        actions: [
          TextButton.icon(
            onPressed: () => context.push('/sorter'),
            icon: const FaIcon(FontAwesomeIcons.sort, size: 16),
            label: const Text('Sort'),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Input Area
            Container(
              padding: const EdgeInsets.all(AppConstants.paddingM),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      focusNode: _focusNode,
                      decoration: InputDecoration(
                        hintText: _isListening ? 'Listening...' : 'What\'s on your mind?',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: _isListening 
                                ? AppColors.primary 
                                : AppColors.borderLight,
                            width: _isListening ? 2 : 1,
                          ),
                        ),
                        filled: true,
                        fillColor: _isListening 
                            ? AppColors.primary.withOpacity(0.05)
                            : AppColors.backgroundLight,
                        prefixIcon: Icon(
                          FontAwesomeIcons.brain,
                          size: 20,
                          color: _isListening 
                              ? AppColors.primary 
                              : AppColors.primary,
                        ),
                        suffixIcon: _isInitializing
                            ? const Padding(
                                padding: EdgeInsets.all(12),
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              )
                            : IconButton(
                                icon: Icon(
                                  _isListening 
                                      ? Icons.mic_rounded 
                                      : Icons.mic_none_rounded,
                                  color: _isListening 
                                      ? AppColors.errorRed 
                                      : AppColors.textMedium,
                                ),
                                onPressed: _toggleListening,
                                tooltip: _isListening 
                                    ? 'Stop listening' 
                                    : 'Start voice input',
                              ),
                      ),
                      onSubmitted: (_) => _addTask(),
                      textInputAction: TextInputAction.done,
                      enabled: !_isListening,
                    ),
                  ),
                  const SizedBox(width: AppConstants.paddingS),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: _addTask,
                      icon: const Icon(Icons.add_rounded, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),

            // Tasks List
            Expanded(
              child: inboxTasks.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.all(AppConstants.paddingM),
                      itemCount: inboxTasks.length,
                      itemBuilder: (context, index) {
                        final task = inboxTasks[index];
                        return _buildTaskCard(task);
                      },
                    ),
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/sorter'),
        icon: const FaIcon(FontAwesomeIcons.sort),
        label: const Text('Sort Tasks'),
        backgroundColor: AppColors.accentPurple,
      ),
    );
  }

  Widget _buildTaskCard(Task task) {
    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.horizontal,
      onDismissed: (direction) {
        if (direction == DismissDirection.startToEnd) {
          _moveToToday(task);
        } else {
          ref.read(tasksProvider.notifier).deleteTask(task.id);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Task deleted'),
              duration: Duration(seconds: 1),
            ),
          );
        }
      },
      background: Container(
        margin: const EdgeInsets.only(bottom: AppConstants.paddingM),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: AppColors.successGreen,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerLeft,
        child: const Row(
          children: [
            Icon(Icons.arrow_forward_rounded, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'Add to Today',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      secondaryBackground: Container(
        margin: const EdgeInsets.only(bottom: AppConstants.paddingM),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: AppColors.errorRed,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'Delete',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.delete_rounded, color: Colors.white),
          ],
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppConstants.paddingM),
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
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const FaIcon(
                FontAwesomeIcons.lightbulb,
                size: 20,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: AppConstants.paddingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: AppTextStyles.bodyLarge,
                  ),
                  if (task.description != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      task.description!,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textLight,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const Icon(
              Icons.drag_indicator_rounded,
              color: AppColors.textLight,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppConstants.paddingXL),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const FaIcon(
                FontAwesomeIcons.brain,
                size: 64,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppConstants.paddingL),
            Text(
              'Your Inbox is Empty',
              style: AppTextStyles.titleLarge,
            ),
            const SizedBox(height: AppConstants.paddingS),
            Text(
              'Dump all your thoughts here.\nNo need to organize yet!',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textLight,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.paddingL),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.swipe_right_rounded, color: AppColors.successGreen),
                SizedBox(width: 8),
                Text('Swipe right to add to today'),
              ],
            ),
            const SizedBox(height: AppConstants.paddingS),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.swipe_left_rounded, color: AppColors.errorRed),
                SizedBox(width: 8),
                Text('Swipe left to delete'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

