import 'package:flutter/material.dart';
import '../../../../common/theme/app_colors.dart';
import '../../data/models/task.dart';

/// Task Thought Bubble
/// Visual representation of a captured task in the jar
class TaskThoughtBubble extends StatelessWidget {
  final Task task;

  const TaskThoughtBubble({
    required this.task,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _getPriorityColor(task.priority),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        task.title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.urgent:
        return AppColors.errorRed;
      case TaskPriority.high:
        return AppColors.accentOrange;
      case TaskPriority.medium:
        return AppColors.primary;
      case TaskPriority.low:
        return AppColors.potatoHour;
    }
  }
}

