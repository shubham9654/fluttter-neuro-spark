// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_stats.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GameStatsAdapter extends TypeAdapter<GameStats> {
  @override
  final int typeId = 3;

  @override
  GameStats read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GameStats(
      totalXp: fields[0] as int,
      level: fields[1] as int,
      coins: fields[2] as int,
      currentStreak: fields[3] as int,
      longestStreak: fields[4] as int,
      lastActiveDate: fields[5] as DateTime,
      tasksCompleted: fields[6] as int,
      totalFocusMinutes: fields[7] as int,
      unlockedItems: (fields[8] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, GameStats obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.totalXp)
      ..writeByte(1)
      ..write(obj.level)
      ..writeByte(2)
      ..write(obj.coins)
      ..writeByte(3)
      ..write(obj.currentStreak)
      ..writeByte(4)
      ..write(obj.longestStreak)
      ..writeByte(5)
      ..write(obj.lastActiveDate)
      ..writeByte(6)
      ..write(obj.tasksCompleted)
      ..writeByte(7)
      ..write(obj.totalFocusMinutes)
      ..writeByte(8)
      ..write(obj.unlockedItems);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameStatsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
