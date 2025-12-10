import 'package:hive_flutter/hive_flutter.dart';
import '../../features/task/data/models/task.dart';
import '../../features/gamification/data/models/game_stats.dart';
import '../../features/settings/data/models/user_preferences.dart';
import '../../features/onboarding/data/models/neurotype_profile.dart';
import '../../features/onboarding/data/models/energy_block.dart';
import 'constants.dart';

/// Hive Service
/// Manages local storage initialization and box access
class HiveService {
  static bool _initialized = false;

  /// Initialize Hive and register adapters
  static Future<void> init() async {
    if (_initialized) return;

    // Initialize Hive Flutter
    await Hive.initFlutter();

    // Register all type adapters
    Hive.registerAdapter(TaskAdapter());
    Hive.registerAdapter(TaskStatusAdapter());
    Hive.registerAdapter(TaskPriorityAdapter());
    Hive.registerAdapter(GameStatsAdapter());
    Hive.registerAdapter(UserPreferencesAdapter());
    Hive.registerAdapter(NeurotypeProfileAdapter());
    Hive.registerAdapter(StruggleTypeAdapter());
    Hive.registerAdapter(EnergyBlockAdapter());
    Hive.registerAdapter(EnergyLevelAdapter());
    Hive.registerAdapter(EnergyMapAdapter());

    // Open boxes
    await openBoxes();

    _initialized = true;
  }

  /// Open all Hive boxes
  static Future<void> openBoxes() async {
    await Hive.openBox<Task>(AppConstants.tasksBoxName);
    await Hive.openBox<GameStats>(AppConstants.gameStatsBoxName);
    await Hive.openBox<UserPreferences>(AppConstants.settingsBoxName);
    await Hive.openBox(AppConstants.userBoxName); // Generic box for user data
    await Hive.openBox(AppConstants.sessionsBoxName); // For focus sessions
  }

  /// Get Tasks Box
  static Box<Task> get tasksBox => Hive.box<Task>(AppConstants.tasksBoxName);

  /// Get Game Stats Box
  static Box<GameStats> get gameStatsBox =>
      Hive.box<GameStats>(AppConstants.gameStatsBoxName);

  /// Get Settings Box
  static Box<UserPreferences> get settingsBox =>
      Hive.box<UserPreferences>(AppConstants.settingsBoxName);

  /// Get User Box (for neurotype, energy map, etc.)
  static Box get userBox => Hive.box(AppConstants.userBoxName);

  /// Get Sessions Box
  static Box get sessionsBox => Hive.box(AppConstants.sessionsBoxName);

  /// Close all boxes
  static Future<void> closeBoxes() async {
    await Hive.close();
  }

  /// Clear all data (for testing or reset)
  static Future<void> clearAllData() async {
    await tasksBox.clear();
    await gameStatsBox.clear();
    await settingsBox.clear();
    await userBox.clear();
    await sessionsBox.clear();
  }

  /// Track and enforce per-user local data isolation.
  /// If the signed-in user changes, clear local caches that are user-specific.
  static Future<void> switchUser(String? userId) async {
    if (userId == null || userId.isEmpty) return;
    final box = userBox;
    final lastUserId =
        box.get(AppConstants.keyCurrentUserId, defaultValue: '') as String;
    if (lastUserId != userId) {
      await clearUserScopedData();
      await box.put(AppConstants.keyCurrentUserId, userId);
    }
  }

  /// Clear all data that should not leak between users.
  static Future<void> clearUserScopedData() async {
    await tasksBox.clear();
    await gameStatsBox.clear();
    await sessionsBox.clear();
    await settingsBox.clear();
    await userBox.clear();
  }


  /// Get or create default user preferences
  static Future<UserPreferences> getOrCreatePreferences() async {
    final box = settingsBox;
    if (box.isEmpty) {
      const defaultPrefs = UserPreferences();
      await box.put('preferences', defaultPrefs);
      return defaultPrefs;
    }
    return box.get('preferences', defaultValue: const UserPreferences())!;
  }

  /// Get or create default game stats
  static Future<GameStats> getOrCreateGameStats() async {
    final box = gameStatsBox;
    if (box.isEmpty) {
      final defaultStats = GameStats(lastActiveDate: DateTime.now());
      await box.put('stats', defaultStats);
      return defaultStats;
    }
    return box.get('stats',
        defaultValue: GameStats(lastActiveDate: DateTime.now()))!;
  }

  /// Check if onboarding is complete
  static bool isOnboardingComplete() {
    return userBox.get(AppConstants.keyOnboardingComplete, defaultValue: false);
  }

  /// Mark onboarding as complete
  static Future<void> completeOnboarding() async {
    await userBox.put(AppConstants.keyOnboardingComplete, true);
  }

  /// Save neurotype profile
  static Future<void> saveNeurotypeProfile(NeurotypeProfile profile) async {
    await userBox.put(AppConstants.keyNeurotypProfile, profile);
  }

  /// Get neurotype profile
  static NeurotypeProfile? getNeurotypeProfile() {
    return userBox.get(AppConstants.keyNeurotypProfile);
  }

  /// Save energy map
  static Future<void> saveEnergyMap(EnergyMap energyMap) async {
    await userBox.put(AppConstants.keyEnergyMap, energyMap);
  }

  /// Get energy map
  static EnergyMap? getEnergyMap() {
    return userBox.get(AppConstants.keyEnergyMap);
  }
}

