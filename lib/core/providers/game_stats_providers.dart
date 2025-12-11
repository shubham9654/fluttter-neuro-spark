import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../features/gamification/data/models/game_stats.dart';
import '../../common/utils/hive_service.dart';
import '../services/firestore_service.dart';

/// State notifier for game stats
class GameStatsNotifier extends Notifier<GameStats> {
  final _firestore = FirestoreService();
  StreamSubscription<DocumentSnapshot>? _statsSub;
  StreamSubscription<User?>? _authSub;

  @override
  GameStats build() {
    _initialize();
    return GameStats(lastActiveDate: DateTime.now());
  }

  void _initialize() {
    // React to auth changes to isolate stats per user
    _authSub ??= FirebaseAuth.instance.authStateChanges().listen((user) {
      _restartForUser(user);
    });
    ref.onDispose(() {
      _statsSub?.cancel();
      _authSub?.cancel();
    });

    // Start for current user on first build
    _restartForUser(FirebaseAuth.instance.currentUser);
  }

  Future<void> _restartForUser(User? user) async {
    await _statsSub?.cancel();
    _statsSub = null;
    // Load cached stats immediately for fast/offline UX
    await _loadLocalGameStats();
    if (user == null) return;

    // Keep Hive data isolated per user
    await HiveService.switchUser(user.uid);

    await _loadGameStatsFromFirestore();

    _statsSub = _firestore.watchGameStats().listen((snapshot) {
      try {
        if (snapshot.exists && snapshot.data() != null) {
          final data = snapshot.data() as Map<String, dynamic>;
          final stats = _gameStatsFromMap(data);
          state = stats;
          _saveLocalGameStats(stats);
        } else if (!snapshot.exists) {
          final defaultStats = GameStats(lastActiveDate: DateTime.now());
          state = defaultStats;
          _saveGameStatsToFirestore().catchError((e) {
            debugPrint('Error initializing game stats: $e');
          });
          _saveLocalGameStats(defaultStats);
        }
      } catch (e) {
        debugPrint('Error processing Firestore game stats updates: $e');
      }
    }, onError: (error) {
      debugPrint('Error listening to Firestore game stats: $error');
    });
  }

  /// Load game stats from Firestore
  Future<void> _loadGameStatsFromFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final statsData = await _firestore.getGameStats();
      if (statsData != null) {
        final stats = _gameStatsFromMap(statsData);
        state = stats;
        _saveLocalGameStats(stats);
      } else {
        // No game stats exist yet - initialize with default values
        final defaultStats = GameStats(lastActiveDate: DateTime.now());
        state = defaultStats;
        // Save initial stats to Firestore
        await _saveGameStatsToFirestore();
        _saveLocalGameStats(defaultStats);
        debugPrint('✅ Initialized game stats in Firestore');
      }
    } catch (e) {
      debugPrint('Error loading game stats from Firestore: $e');
    }
  }

  /// Load stats from local cache (Hive) for offline/fast start
  Future<void> _loadLocalGameStats() async {
    try {
      final local = await HiveService.getOrCreateGameStats();
      state = local;
    } catch (e) {
      debugPrint('Error loading local game stats: $e');
    }
  }

  /// Save stats to local cache (non-blocking)
  Future<void> _saveLocalGameStats(GameStats stats) async {
    try {
      await HiveService.gameStatsBox.put('stats', stats);
    } catch (e) {
      debugPrint('Error saving local game stats: $e');
    }
  }

  /// Convert Firestore map to GameStats model
  GameStats _gameStatsFromMap(Map<String, dynamic> data) {
    return GameStats(
      totalXp: data['totalXp'] as int? ?? 0,
      level: data['level'] as int? ?? 1,
      coins: data['coins'] as int? ?? 0,
      currentStreak: data['currentStreak'] as int? ?? 0,
      longestStreak: data['longestStreak'] as int? ?? 0,
      lastActiveDate: (data['lastActiveDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      tasksCompleted: data['tasksCompleted'] as int? ?? 0,
      totalFocusMinutes: data['totalFocusMinutes'] as int? ?? 0,
      unlockedItems: (data['unlockedItems'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }

  /// Convert GameStats model to Firestore map
  Map<String, dynamic> _gameStatsToMap(GameStats stats) {
    return {
      'totalXp': stats.totalXp,
      'level': stats.level,
      'coins': stats.coins,
      'currentStreak': stats.currentStreak,
      'longestStreak': stats.longestStreak,
      'lastActiveDate': Timestamp.fromDate(stats.lastActiveDate),
      'tasksCompleted': stats.tasksCompleted,
      'totalFocusMinutes': stats.totalFocusMinutes,
      'unlockedItems': stats.unlockedItems,
    };
  }

  /// Save game stats to Firestore (non-blocking)
  Future<void> _saveGameStatsToFirestore() async {
    try {
      final statsData = _gameStatsToMap(state);
      await _firestore.updateGameStats(statsData);
    } catch (e) {
      debugPrint('Error saving game stats to Firestore: $e');
    }
  }

  void addXp(int xp) {
    final newTotalXp = state.totalXp + xp;
    final newLevel = (newTotalXp / 100).floor() + 1;

    state = state.copyWith(
      totalXp: newTotalXp,
      level: newLevel,
      lastActiveDate: DateTime.now(),
    );
    _saveLocalGameStats(state);
    // Save to Firestore (non-blocking)
    _saveGameStatsToFirestore().catchError((e) {
      debugPrint('Error saving game stats to Firestore: $e');
    });
  }

  void addCoins(int coins) {
    state = state.copyWith(
      coins: state.coins + coins,
      lastActiveDate: DateTime.now(),
    );
    _saveLocalGameStats(state);
    // Save to Firestore (non-blocking)
    _saveGameStatsToFirestore().catchError((e) {
      debugPrint('Error saving game stats to Firestore: $e');
    });
  }

  void completeTask() {
    state = state.copyWith(
      tasksCompleted: state.tasksCompleted + 1,
      lastActiveDate: DateTime.now(),
    );
    addXp(25); // 25 XP per task
    addCoins(10); // 10 coins per task
    // Note: addXp and addCoins already save to Firestore
  }

  void addFocusMinutes(int minutes) {
    state = state.copyWith(
      totalFocusMinutes: state.totalFocusMinutes + minutes,
      lastActiveDate: DateTime.now(),
    );
    _saveLocalGameStats(state);
    addXp(minutes); // 1 XP per minute
    // Note: addXp already saves to Firestore
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
    _saveLocalGameStats(state);
    // Save to Firestore (non-blocking)
    _saveGameStatsToFirestore().catchError((e) {
      debugPrint('Error saving game stats to Firestore: $e');
    });
  }

  void purchaseItem(String itemId, int price, {String? itemName}) async {
    // Check if already unlocked
    if (state.unlockedItems.contains(itemId)) {
      debugPrint('Item $itemId is already unlocked');
      return;
    }

    // Check if user has enough coins
    if (state.coins < price) {
      debugPrint('Not enough coins to purchase $itemId. Need $price, have ${state.coins}');
      return;
    }

    final newUnlockedItems = [...state.unlockedItems, itemId];
    state = state.copyWith(
      coins: state.coins - price,
      unlockedItems: newUnlockedItems,
      lastActiveDate: DateTime.now(),
    );
    _saveLocalGameStats(state);
    
    // Save to Firestore (non-blocking)
    _saveGameStatsToFirestore().catchError((e) {
      debugPrint('Error saving game stats to Firestore: $e');
    });
    
    // Save shop purchase to history
    try {
      await _firestore.saveShopPurchase(
        itemId: itemId,
        itemName: itemName ?? itemId,
        coinsSpent: price,
        purchaseDate: DateTime.now(),
      );
    } catch (e) {
      debugPrint('Error saving shop purchase to history: $e');
    }
    
    debugPrint('✅ Purchased item: $itemId for $price coins. Remaining: ${state.coins}');
  }
}

/// Provider for game stats
final gameStatsProvider = NotifierProvider<GameStatsNotifier, GameStats>(() {
  return GameStatsNotifier();
});

