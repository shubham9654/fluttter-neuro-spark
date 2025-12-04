import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/gamification/data/models/game_stats.dart';

/// State notifier for game stats
class GameStatsNotifier extends Notifier<GameStats> {
  @override
  GameStats build() => GameStats(
        lastActiveDate: DateTime.now(),
      );

  void addXp(int xp) {
    final newTotalXp = state.totalXp + xp;
    final newLevel = (newTotalXp / 100).floor() + 1;

    state = state.copyWith(
      totalXp: newTotalXp,
      level: newLevel,
      lastActiveDate: DateTime.now(),
    );
  }

  void addCoins(int coins) {
    state = state.copyWith(
      coins: state.coins + coins,
      lastActiveDate: DateTime.now(),
    );
  }

  void completeTask() {
    state = state.copyWith(
      tasksCompleted: state.tasksCompleted + 1,
      lastActiveDate: DateTime.now(),
    );
    addXp(25); // 25 XP per task
    addCoins(10); // 10 coins per task
  }

  void addFocusMinutes(int minutes) {
    state = state.copyWith(
      totalFocusMinutes: state.totalFocusMinutes + minutes,
      lastActiveDate: DateTime.now(),
    );
    addXp(minutes); // 1 XP per minute
  }

  void updateStreak() {
    final now = DateTime.now();
    final lastActive = state.lastActiveDate;
    final daysDiff = now.difference(lastActive).inDays;

    if (daysDiff == 0) {
      // Same day, no change
      return;
    } else if (daysDiff == 1) {
      // Consecutive day, increment streak
      final newStreak = state.currentStreak + 1;
      state = state.copyWith(
        currentStreak: newStreak,
        longestStreak:
            newStreak > state.longestStreak ? newStreak : state.longestStreak,
        lastActiveDate: now,
      );
    } else {
      // Streak broken
      state = state.copyWith(
        currentStreak: 1,
        lastActiveDate: now,
      );
    }
  }

  void purchaseItem(String itemId, int price) {
    final newUnlockedItems = [...state.unlockedItems, itemId];
    state = state.copyWith(
      coins: state.coins - price,
      unlockedItems: newUnlockedItems,
      lastActiveDate: DateTime.now(),
    );
  }
}

/// Provider for game stats
final gameStatsProvider = NotifierProvider<GameStatsNotifier, GameStats>(() {
  return GameStatsNotifier();
});

