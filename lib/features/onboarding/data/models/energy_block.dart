import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';

part 'energy_block.g.dart';

/// Energy Block Model
/// Represents a time block with associated energy level (FR-A2)
@HiveType(typeId: 7)
class EnergyBlock extends Equatable {
  @HiveField(0)
  final int startHour; // 0-23
  
  @HiveField(1)
  final int startMinute; // 0-59
  
  @HiveField(2)
  final int endHour; // 0-23
  
  @HiveField(3)
  final int endMinute; // 0-59
  
  @HiveField(4)
  final EnergyLevel energyLevel;

  const EnergyBlock({
    required this.startHour,
    required this.startMinute,
    required this.endHour,
    required this.endMinute,
    required this.energyLevel,
  });

  EnergyBlock copyWith({
    int? startHour,
    int? startMinute,
    int? endHour,
    int? endMinute,
    EnergyLevel? energyLevel,
  }) {
    return EnergyBlock(
      startHour: startHour ?? this.startHour,
      startMinute: startMinute ?? this.startMinute,
      endHour: endHour ?? this.endHour,
      endMinute: endMinute ?? this.endMinute,
      energyLevel: energyLevel ?? this.energyLevel,
    );
  }
  
  // Get total minutes in this block
  int get durationMinutes {
    final startTotalMinutes = startHour * 60 + startMinute;
    final endTotalMinutes = endHour * 60 + endMinute;
    return endTotalMinutes - startTotalMinutes;
  }
  
  // Format time for display
  String get startTimeFormatted {
    final period = startHour >= 12 ? 'PM' : 'AM';
    final displayHour = startHour > 12 ? startHour - 12 : (startHour == 0 ? 12 : startHour);
    return '$displayHour:${startMinute.toString().padLeft(2, '0')} $period';
  }
  
  String get endTimeFormatted {
    final period = endHour >= 12 ? 'PM' : 'AM';
    final displayHour = endHour > 12 ? endHour - 12 : (endHour == 0 ? 12 : endHour);
    return '$displayHour:${endMinute.toString().padLeft(2, '0')} $period';
  }

  @override
  List<Object?> get props => [
        startHour,
        startMinute,
        endHour,
        endMinute,
        energyLevel,
      ];
}

@HiveType(typeId: 8)
enum EnergyLevel {
  @HiveField(0)
  high, // Golden hour - peak productivity
  
  @HiveField(1)
  low, // Potato hour - low energy
}

/// Energy Map Model
/// Collection of energy blocks for the user's day
@HiveType(typeId: 9)
class EnergyMap extends Equatable {
  @HiveField(0)
  final List<EnergyBlock> blocks;
  
  @HiveField(1)
  final DateTime createdAt;
  
  @HiveField(2)
  final DateTime? updatedAt;

  const EnergyMap({
    required this.blocks,
    required this.createdAt,
    this.updatedAt,
  });

  EnergyMap copyWith({
    List<EnergyBlock>? blocks,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EnergyMap(
      blocks: blocks ?? this.blocks,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [blocks, createdAt, updatedAt];
}

