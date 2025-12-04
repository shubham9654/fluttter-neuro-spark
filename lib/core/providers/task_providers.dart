import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../features/task/data/models/task.dart';

/// State notifier for tasks
class TasksNotifier extends Notifier<List<Task>> {
  @override
  List<Task> build() => [];

  void addTask(Task task) {
    state = [...state, task];
  }

  void updateTask(Task task) {
    state = [
      for (final t in state)
        if (t.id == task.id) task else t
    ];
  }

  void deleteTask(String id) {
    state = state.where((t) => t.id != id).toList();
  }

  void completeTask(String id) {
    state = [
      for (final t in state)
        if (t.id == id)
          t.copyWith(
            status: TaskStatus.completed,
            completedAt: DateTime.now(),
          )
        else
          t
    ];
  }

  List<Task> get todayTasks =>
      state.where((t) => t.status == TaskStatus.today).toList();

  List<Task> get inboxTasks =>
      state.where((t) => t.status == TaskStatus.inbox).toList();

  List<Task> get completedTasks =>
      state.where((t) => t.status == TaskStatus.completed).toList();
}

/// Provider for tasks
final tasksProvider = NotifierProvider<TasksNotifier, List<Task>>(() {
  return TasksNotifier();
});

/// Provider for today's tasks
final todayTasksProvider = Provider<List<Task>>((ref) {
  return ref.watch(tasksProvider).where((t) => t.status == TaskStatus.today).toList();
});

/// Provider for inbox tasks
final inboxTasksProvider = Provider<List<Task>>((ref) {
  return ref.watch(tasksProvider).where((t) => t.status == TaskStatus.inbox).toList();
});

/// Provider for creating new task
final createTaskProvider = Provider((ref) {
  return (String title, {String? description, int estimatedMinutes = 25}) {
    const uuid = Uuid();
    final task = Task(
      id: uuid.v4(),
      title: title,
      description: description,
      status: TaskStatus.inbox,
      createdAt: DateTime.now(),
      estimatedMinutes: estimatedMinutes,
    );
    ref.read(tasksProvider.notifier).addTask(task);
    return task;
  };
});

