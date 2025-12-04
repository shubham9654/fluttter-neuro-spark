// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TaskAdapter extends TypeAdapter<Task> {
  @override
  final int typeId = 0;

  @override
  Task read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Task(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String?,
      status: fields[3] as TaskStatus,
      createdAt: fields[4] as DateTime,
      completedAt: fields[5] as DateTime?,
      estimatedMinutes: fields[6] as int,
      actualMinutes: fields[7] as int?,
      priority: fields[8] as TaskPriority,
      subtasks: (fields[9] as List).cast<String>(),
      isAIGenerated: fields[10] as bool,
      scheduledFor: fields[11] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Task obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.status)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.completedAt)
      ..writeByte(6)
      ..write(obj.estimatedMinutes)
      ..writeByte(7)
      ..write(obj.actualMinutes)
      ..writeByte(8)
      ..write(obj.priority)
      ..writeByte(9)
      ..write(obj.subtasks)
      ..writeByte(10)
      ..write(obj.isAIGenerated)
      ..writeByte(11)
      ..write(obj.scheduledFor);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TaskStatusAdapter extends TypeAdapter<TaskStatus> {
  @override
  final int typeId = 1;

  @override
  TaskStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TaskStatus.inbox;
      case 1:
        return TaskStatus.today;
      case 2:
        return TaskStatus.notToday;
      case 3:
        return TaskStatus.inProgress;
      case 4:
        return TaskStatus.completed;
      case 5:
        return TaskStatus.archived;
      default:
        return TaskStatus.inbox;
    }
  }

  @override
  void write(BinaryWriter writer, TaskStatus obj) {
    switch (obj) {
      case TaskStatus.inbox:
        writer.writeByte(0);
        break;
      case TaskStatus.today:
        writer.writeByte(1);
        break;
      case TaskStatus.notToday:
        writer.writeByte(2);
        break;
      case TaskStatus.inProgress:
        writer.writeByte(3);
        break;
      case TaskStatus.completed:
        writer.writeByte(4);
        break;
      case TaskStatus.archived:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TaskPriorityAdapter extends TypeAdapter<TaskPriority> {
  @override
  final int typeId = 2;

  @override
  TaskPriority read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TaskPriority.low;
      case 1:
        return TaskPriority.medium;
      case 2:
        return TaskPriority.high;
      case 3:
        return TaskPriority.urgent;
      default:
        return TaskPriority.low;
    }
  }

  @override
  void write(BinaryWriter writer, TaskPriority obj) {
    switch (obj) {
      case TaskPriority.low:
        writer.writeByte(0);
        break;
      case TaskPriority.medium:
        writer.writeByte(1);
        break;
      case TaskPriority.high:
        writer.writeByte(2);
        break;
      case TaskPriority.urgent:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskPriorityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
