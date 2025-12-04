import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';

part 'neurotype_profile.g.dart';

/// Neurotype Profile Model
/// Stores user's ADHD-related struggles and preferences (FR-A1)
@HiveType(typeId: 5)
class NeurotypeProfile extends Equatable {
  @HiveField(0)
  final List<StruggleType> selectedStruggles;
  
  @HiveField(1)
  final DateTime createdAt;

  const NeurotypeProfile({
    required this.selectedStruggles,
    required this.createdAt,
  });

  NeurotypeProfile copyWith({
    List<StruggleType>? selectedStruggles,
    DateTime? createdAt,
  }) {
    return NeurotypeProfile(
      selectedStruggles: selectedStruggles ?? this.selectedStruggles,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [selectedStruggles, createdAt];
}

@HiveType(typeId: 6)
enum StruggleType {
  @HiveField(0)
  paralysis, // Task paralysis / Can't start
  
  @HiveField(1)
  overwhelm, // Too many things at once
  
  @HiveField(2)
  timeCeacuity, // Time blindness
  
  @HiveField(3)
  procrastination, // Chronic procrastination
  
  @HiveField(4)
  hyperfocus, // Can't stop once started
  
  @HiveField(5)
  motivation, // Low motivation / Dopamine issues
}

extension StruggleTypeExtension on StruggleType {
  String get displayName {
    switch (this) {
      case StruggleType.paralysis:
        return 'Task Paralysis';
      case StruggleType.overwhelm:
        return 'Overwhelm';
      case StruggleType.timeCeacuity:
        return 'Time Blindness';
      case StruggleType.procrastination:
        return 'Procrastination';
      case StruggleType.hyperfocus:
        return 'Hyperfocus';
      case StruggleType.motivation:
        return 'Low Motivation';
    }
  }
  
  String get description {
    switch (this) {
      case StruggleType.paralysis:
        return 'I freeze when faced with tasks';
      case StruggleType.overwhelm:
        return 'Too many things stress me out';
      case StruggleType.timeCeacuity:
        return 'I lose track of time easily';
      case StruggleType.procrastination:
        return 'I delay important tasks';
      case StruggleType.hyperfocus:
        return 'I can\'t stop once I start';
      case StruggleType.motivation:
        return 'Starting tasks feels impossible';
    }
  }
}

