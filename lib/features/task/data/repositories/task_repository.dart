import 'package:uuid/uuid.dart';
import '../../../../common/utils/hive_service.dart';
import '../models/task.dart';

/// Task Repository
/// Handles all CRUD operations for tasks
class TaskRepository {
  final _uuid = const Uuid();

  /// Create a new task
  Future<Task> createTask({
    required String title,
    String? description,
    int estimatedMinutes = 25,
    TaskPriority priority = TaskPriority.medium,
  }) async {
    final task = Task(
      id: _uuid.v4(),
      title: title,
      description: description,
      status: TaskStatus.inbox,
      createdAt: DateTime.now(),
      estimatedMinutes: estimatedMinutes,
      priority: priority,
    );

    final box = HiveService.tasksBox;
    await box.put(task.id, task);

    return task;
  }

  /// Get all tasks
  List<Task> getAllTasks() {
    final box = HiveService.tasksBox;
    return box.values.toList();
  }

  /// Get tasks by status
  List<Task> getTasksByStatus(TaskStatus status) {
    final box = HiveService.tasksBox;
    return box.values.where((task) => task.status == status).toList();
  }

  /// Get inbox tasks (brain dump)
  List<Task> getInboxTasks() {
    return getTasksByStatus(TaskStatus.inbox);
  }

  /// Get today's tasks (Holy Trinity)
  List<Task> getTodayTasks() {
    return getTasksByStatus(TaskStatus.today);
  }

  /// Get not today tasks
  List<Task> getNotTodayTasks() {
    return getTasksByStatus(TaskStatus.notToday);
  }

  /// Get completed tasks
  List<Task> getCompletedTasks() {
    return getTasksByStatus(TaskStatus.completed);
  }

  /// Get task by ID
  Task? getTaskById(String id) {
    final box = HiveService.tasksBox;
    return box.get(id);
  }

  /// Update task
  Future<void> updateTask(Task task) async {
    final box = HiveService.tasksBox;
    await box.put(task.id, task);
  }

  /// Update task status
  Future<void> updateTaskStatus(String taskId, TaskStatus newStatus) async {
    final task = getTaskById(taskId);
    if (task == null) return;

    final updatedTask = task.copyWith(
      status: newStatus,
      completedAt: newStatus == TaskStatus.completed ? DateTime.now() : null,
    );

    await updateTask(updatedTask);
  }

  /// Mark task as today (add to Holy Trinity)
  Future<bool> markTaskAsToday(String taskId) async {
    // Check if we already have 3 tasks for today
    final todayTasks = getTodayTasks();
    if (todayTasks.length >= 3) {
      return false; // Cannot add more than 3 tasks
    }

    await updateTaskStatus(taskId, TaskStatus.today);
    return true;
  }

  /// Mark task as not today
  Future<void> markTaskAsNotToday(String taskId) async {
    await updateTaskStatus(taskId, TaskStatus.notToday);
  }

  /// Start task (mark as in progress)
  Future<void> startTask(String taskId) async {
    await updateTaskStatus(taskId, TaskStatus.inProgress);
  }

  /// Complete task
  Future<void> completeTask(String taskId, {int? actualMinutes}) async {
    final task = getTaskById(taskId);
    if (task == null) return;

    final updatedTask = task.copyWith(
      status: TaskStatus.completed,
      completedAt: DateTime.now(),
      actualMinutes: actualMinutes,
    );

    await updateTask(updatedTask);
  }

  /// Delete task
  Future<void> deleteTask(String taskId) async {
    final box = HiveService.tasksBox;
    await box.delete(taskId);
  }

  /// Archive task
  Future<void> archiveTask(String taskId) async {
    await updateTaskStatus(taskId, TaskStatus.archived);
  }

  /// Get task count by status
  int getTaskCount(TaskStatus status) {
    return getTasksByStatus(status).length;
  }

  /// Get total task count
  int getTotalTaskCount() {
    final box = HiveService.tasksBox;
    return box.length;
  }

  /// Clear all tasks (for testing)
  Future<void> clearAllTasks() async {
    final box = HiveService.tasksBox;
    await box.clear();
  }

  /// Get tasks scheduled for specific date
  List<Task> getTasksForDate(DateTime date) {
    final box = HiveService.tasksBox;
    return box.values.where((task) {
      if (task.scheduledFor == null) return false;
      return task.scheduledFor!.year == date.year &&
          task.scheduledFor!.month == date.month &&
          task.scheduledFor!.day == date.day;
    }).toList();
  }

  /// Breakdown task into subtasks (AI integration point)
  Future<Task> breakdownTask(Task task, List<String> subtasks) async {
    final updatedTask = task.copyWith(
      subtasks: subtasks,
      isAIGenerated: true,
    );

    await updateTask(updatedTask);
    return updatedTask;
  }
}

