import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../features/task/data/models/task.dart';
import '../services/firestore_service.dart';
import '../services/notification_service.dart';

/// State notifier for tasks
class TasksNotifier extends Notifier<List<Task>> {
  final _firestore = FirestoreService();

  @override
  List<Task> build() {
    // Load tasks from Firestore when provider is created
    _loadTasksFromFirestore();

    // Listen to real-time updates from Firestore
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _firestore
          .watchTasks()
          .listen((snapshot) {
            try {
              final tasks = snapshot.docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return _taskFromMap({'id': doc.id, ...data});
              }).toList();
              state = tasks;
            } catch (e) {
              debugPrint('Error processing Firestore task updates: $e');
            }
          })
          .onError((error) {
            debugPrint('Error listening to Firestore tasks: $error');
          });
    }

    return [];
  }

  /// Load tasks from Firestore
  Future<void> _loadTasksFromFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final tasksData = await _firestore.getTasks();
      final tasks = tasksData.map((data) => _taskFromMap(data)).toList();
      state = tasks;
    } catch (e) {
      debugPrint('Error loading tasks from Firestore: $e');
    }
  }

  /// Convert Firestore map to Task model
  Task _taskFromMap(Map<String, dynamic> data) {
    return Task(
      id: data['id'] as String,
      title: data['title'] as String,
      description: data['description'] as String?,
      status: TaskStatus.values.firstWhere(
        (e) => e.toString().split('.').last == data['status'],
        orElse: () => TaskStatus.inbox,
      ),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
      estimatedMinutes: data['estimatedMinutes'] as int? ?? 25,
      actualMinutes: data['actualMinutes'] as int?,
      priority: TaskPriority.values.firstWhere(
        (e) => e.toString().split('.').last == (data['priority'] ?? 'medium'),
        orElse: () => TaskPriority.medium,
      ),
      subtasks: (data['subtasks'] as List<dynamic>?)?.cast<String>() ?? [],
      isAIGenerated: data['isAIGenerated'] as bool? ?? false,
      scheduledFor: (data['scheduledFor'] as Timestamp?)?.toDate(),
    );
  }

  /// Convert Task model to Firestore map
  Map<String, dynamic> _taskToMap(Task task) {
    return {
      'title': task.title,
      'description': task.description,
      'status': task.status.toString().split('.').last,
      'createdAt': Timestamp.fromDate(task.createdAt),
      'completedAt': task.completedAt != null
          ? Timestamp.fromDate(task.completedAt!)
          : null,
      'estimatedMinutes': task.estimatedMinutes,
      'actualMinutes': task.actualMinutes,
      'priority': task.priority.toString().split('.').last,
      'subtasks': task.subtasks,
      'isAIGenerated': task.isAIGenerated,
      'scheduledFor': task.scheduledFor != null
          ? Timestamp.fromDate(task.scheduledFor!)
          : null,
    };
  }

  void addTask(Task task) {
    state = [...state, task];
    // Save to Firestore (non-blocking)
    _saveTaskToFirestore(task).catchError((e) {
      debugPrint('Error saving task to Firestore: $e');
    });
    // Send notification when task is created
    NotificationService().notifyTaskCreated(
      taskTitle: task.title,
      taskId: task.id,
    ).catchError((e) {
      debugPrint('Error sending task creation notification: $e');
    });
  }

  Future<void> _saveTaskToFirestore(Task task) async {
    try {
      final taskData = _taskToMap(task);
      await _firestore.createTaskWithId(task.id, taskData);
    } catch (e) {
      debugPrint('Error saving task to Firestore: $e');
    }
  }

  void updateTask(Task task) {
    final oldTask = state.firstWhere(
      (t) => t.id == task.id,
      orElse: () => task,
    );
    
    state = [
      for (final t in state)
        if (t.id == task.id) task else t,
    ];
    
    // Update in Firestore (non-blocking)
    _updateTaskInFirestore(task).catchError((e) {
      debugPrint('Error updating task in Firestore: $e');
    });
    
    // Send notification when task is added to "today"
    if (oldTask.status != TaskStatus.today && task.status == TaskStatus.today) {
      NotificationService().sendNotification(
        title: '📅 Task Added to Today',
        body: task.title,
        payload: task.id,
      ).catchError((e) {
        debugPrint('Error sending today notification: $e');
      });
    }
  }

  Future<void> _updateTaskInFirestore(Task task) async {
    try {
      final updates = _taskToMap(task);
      await _firestore.updateTask(task.id, updates);
    } catch (e) {
      debugPrint('Error updating task in Firestore: $e');
    }
  }

  void deleteTask(String id) {
    state = state.where((t) => t.id != id).toList();
    // Delete from Firestore (non-blocking)
    _deleteTaskFromFirestore(id).catchError((e) {
      debugPrint('Error deleting task from Firestore: $e');
    });
  }

  Future<void> _deleteTaskFromFirestore(String id) async {
    try {
      await _firestore.deleteTask(id);
    } catch (e) {
      debugPrint('Error deleting task from Firestore: $e');
    }
  }

  void completeTask(String id) {
    final updatedTask = state
        .firstWhere(
          (t) => t.id == id,
          orElse: () => throw Exception('Task not found'),
        )
        .copyWith(status: TaskStatus.completed, completedAt: DateTime.now());
    updateTask(updatedTask);
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
  return ref
      .watch(tasksProvider)
      .where((t) => t.status == TaskStatus.today)
      .toList();
});

/// Provider for inbox tasks
final inboxTasksProvider = Provider<List<Task>>((ref) {
  return ref
      .watch(tasksProvider)
      .where((t) => t.status == TaskStatus.inbox)
      .toList();
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
    // Add to local state and save to Firestore
    ref.read(tasksProvider.notifier).addTask(task);
    return task;
  };
});
