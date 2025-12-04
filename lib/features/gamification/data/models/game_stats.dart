import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';

part 'game_stats.g.dart';

/// Game Stats Model
/// Tracks user's gamification progress (XP, coins, streaks)
@HiveType(typeId: 3)
class GameStats extends Equatable {
  @HiveField(0)
  final int totalXp;
  
  @HiveField(1)
  final int level;
  
  @HiveField(2)
  final int coins;
  
  @HiveField(3)
  final int currentStreak;
  
  @HiveField(4)
  final int longestStreak;
  
  @HiveField(5)
  final DateTime lastActiveDate;
  
  @HiveField(6)
  final int tasksCompleted;
  
  @HiveField(7)
  final int totalFocusMinutes;
  
  @HiveField(8)
  final List<String> unlockedItems;

  const GameStats({
    this.totalXp = 0,
    this.level = 1,
    this.coins = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    required this.lastActiveDate,
    this.tasksCompleted = 0,
    this.totalFocusMinutes = 0,
    this.unlockedItems = const [],
  });

  GameStats copyWith({
    int? totalXp,
    int? level,
    int? coins,
    int? currentStreak,
    int? longestStreak,
    DateTime? lastActiveDate,
    int? tasksCompleted,
    int? totalFocusMinutes,
    List<String>? unlockedItems,
  }) {
    return GameStats(
      totalXp: totalXp ?? this.totalXp,
      level: level ?? this.level,
      coins: coins ?? this.coins,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
      tasksCompleted: tasksCompleted ?? this.tasksCompleted,
      totalFocusMinutes: totalFocusMinutes ?? this.totalFocusMinutes,
      unlockedItems: unlockedItems ?? this.unlockedItems,
    );
  }
  
  // Calculate XP needed for next level
  int get xpForNextLevel => level * 100;
  
  // Calculate progress to next level (0.0 to 1.0)
  double get levelProgress {
    final xpInCurrentLevel = totalXp % xpForNextLevel;
    return xpInCurrentLevel / xpForNextLevel;
  }

  @override
  List<Object?> get props => [
        totalXp,
        level,
        coins,
        currentStreak,
        longestStreak,
        lastActiveDate,
        tasksCompleted,
        totalFocusMinutes,
        unlockedItems,
      ];
}

