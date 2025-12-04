import 'package:flutter/material.dart';
import 'dart:ui';
import '../../../../common/theme/app_colors.dart';
import '../../../../common/utils/constants.dart';
import '../../data/models/task.dart';
import 'task_thought_bubble.dart';

/// Glass Jar Widget
/// Displays tasks in a frosted glass container with visual depth
class GlassJar extends StatelessWidget {
  final List<Task> tasks;
  final bool isAdding;
  final AnimationController animationController;

  const GlassJar({
    required this.tasks,
    required this.isAdding,
    required this.animationController,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final jarHeight = screenHeight * 0.5;

    return SizedBox(
      width: 300,
      height: jarHeight,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Glass jar container
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.4),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Task bubbles inside jar
          if (tasks.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(AppConstants.paddingM),
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: tasks.map((task) {
                    return TaskThoughtBubble(task: task);
                  }).toList(),
                ),
              ),
            ),

          // Flying task animation
          if (isAdding)
            AnimatedBuilder(
              animation: animationController,
              builder: (context, child) {
                final curvedValue = Curves.easeInOut.transform(
                  animationController.value,
                );
                
                return Positioned(
                  top: -50 + (jarHeight / 2) * curvedValue,
                  child: Transform.scale(
                    scale: 1.0 - (curvedValue * 0.3),
                    child: Opacity(
                      opacity: 1.0 - (curvedValue * 0.2),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

          // Empty state text inside jar
          if (tasks.isEmpty && !isAdding)
            Text(
              'Capture your\nthoughts here',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.primary.withOpacity(0.5),
              ),
            ),
        ],
      ),
    );
  }
}

