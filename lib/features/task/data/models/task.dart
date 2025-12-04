import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';

part 'task.g.dart';

/// Task Model
/// Represents a task in the NeuroSpark app
@HiveType(typeId: 0)
class Task extends Equatable {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String title;
  
  @HiveField(2)
  final String? description;
  
  @HiveField(3)
  final TaskStatus status;
  
  @HiveField(4)
  final DateTime createdAt;
  
  @HiveField(5)
  final DateTime? completedAt;
  
  @HiveField(6)
  final int estimatedMinutes;
  
  @HiveField(7)
  final int? actualMinutes;
  
  @HiveField(8)
  final TaskPriority priority;
  
  @HiveField(9)
  final List<String> subtasks;
  
  @HiveField(10)
  final bool isAIGenerated;
  
  @HiveField(11)
  final DateTime? scheduledFor;

  const Task({
    required this.id,
    required this.title,
    this.description,
    required this.status,
    required this.createdAt,
    this.completedAt,
    this.estimatedMinutes = 25,
    this.actualMinutes,
    this.priority = TaskPriority.medium,
    this.subtasks = const [],
    this.isAIGenerated = false,
    this.scheduledFor,
  });

  Task copyWith({
    String? id,
    String? title,
    String? description,
    TaskStatus? status,
    DateTime? createdAt,
    DateTime? completedAt,
    int? estimatedMinutes,
    int? actualMinutes,
    TaskPriority? priority,
    List<String>? subtasks,
    bool? isAIGenerated,
    DateTime? scheduledFor,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      actualMinutes: actualMinutes ?? this.actualMinutes,
      priority: priority ?? this.priority,
      subtasks: subtasks ?? this.subtasks,
      isAIGenerated: isAIGenerated ?? this.isAIGenerated,
      scheduledFor: scheduledFor ?? this.scheduledFor,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        status,
        createdAt,
        completedAt,
        estimatedMinutes,
        actualMinutes,
        priority,
        subtasks,
        isAIGenerated,
        scheduledFor,
      ];
}

@HiveType(typeId: 1)
enum TaskStatus {
  @HiveField(0)
  inbox, // In brain dump
  
  @HiveField(1)
  today, // Selected for today (part of Holy Trinity)
  
  @HiveField(2)
  notToday, // Swiped left in sorter
  
  @HiveField(3)
  inProgress, // Currently being worked on
  
  @HiveField(4)
  completed, // Done!
  
  @HiveField(5)
  archived, // Moved to archive
}

@HiveType(typeId: 2)
enum TaskPriority {
  @HiveField(0)
  low,
  
  @HiveField(1)
  medium,
  
  @HiveField(2)
  high,
  
  @HiveField(3)
  urgent,
}

