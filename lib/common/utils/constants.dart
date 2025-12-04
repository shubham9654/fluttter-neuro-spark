/// NeuroSpark Constants
library;

/// App-wide constants and configuration values
class AppConstants {
  // App Info
  static const String appName = 'NeuroSpark';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'Low Friction, High Reward';
  
  // Animation Durations (in milliseconds)
  static const int shortAnimationDuration = 200;
  static const int mediumAnimationDuration = 300;
  static const int longAnimationDuration = 500;
  static const int breathingAnimationDuration = 3000;
  
  // Task Management
  static const int maxDailyTasks = 3; // The "3-Task Rule" (FR-B4)
  static const int maxBrainDumpTasks = 100;
  static const int taskNameMaxLength = 100;
  
  // Timer/Focus Session
  static const int defaultFocusDuration = 25; // minutes (Pomodoro default)
  static const int shortBreakDuration = 5; // minutes
  static const int longBreakDuration = 15; // minutes
  static const int doomBoxDuration = 2; // minutes (hard limit)
  
  // Audio Chimes (FR-C3) - percentage of timer completion
  static const List<double> chimeIntervals = [0.25, 0.50, 0.75, 0.90];
  
  // Gamification (FR-E)
  static const int baseXpPerTask = 100;
  static const int bonusXpOnTime = 50;
  static const int baseCoinsPerTask = 10;
  static const int maxCoinsPerTask = 25;
  static const int streakGracePeriodHours = 24; // Forgiving Streak (FR-E1)
  
  // Body Doubling (FR-D1)
  static const int maxRoomParticipants = 4;
  static const int quickMatchTimeout = 30; // seconds
  
  // Energy Mapping (FR-A2)
  static const int energyBlockMinDuration = 30; // minutes
  static const int energyBlockMaxDuration = 240; // minutes (4 hours)
  
  // UI/UX
  static const double cardBorderRadius = 16.0;
  static const double buttonBorderRadius = 16.0;
  static const double modalBorderRadius = 24.0;
  static const double cardElevation = 2.0;
  static const double buttonElevation = 8.0;
  
  // Padding/Spacing
  static const double paddingXS = 4.0;
  static const double paddingS = 8.0;
  static const double paddingM = 16.0;
  static const double paddingL = 24.0;
  static const double paddingXL = 32.0;
  
  // Assets Paths
  static const String imagesPath = 'assets/images/';
  static const String iconsPath = 'assets/icons/';
  static const String audioPath = 'assets/audio/';
  static const String fontsPath = 'assets/fonts/';
  
  // Audio Files
  static const String brownNoiseFile = '${audioPath}brown_noise.mp3';
  static const String binauralBeatsFile = '${audioPath}binaural_beats.mp3';
  static const String chimeFile = '${audioPath}chime.mp3';
  static const String victoryFile = '${audioPath}victory.mp3';
  
  // Local Storage Keys (Hive)
  static const String tasksBoxName = 'tasks';
  static const String userBoxName = 'user';
  static const String settingsBoxName = 'settings';
  static const String gameStatsBoxName = 'game_stats';
  static const String sessionsBoxName = 'sessions';
  
  // Shared Preferences Keys
  static const String keyOnboardingComplete = 'onboarding_complete';
  static const String keyNeurotypProfile = 'neurotype_profile';
  static const String keyEnergyMap = 'energy_map';
  static const String keyDyslexicFontEnabled = 'dyslexic_font_enabled';
  static const String keyHapticIntensity = 'haptic_intensity';
  static const String keyBrownNoiseEnabled = 'brown_noise_enabled';
  static const String keyBinauralBeatsEnabled = 'binaural_beats_enabled';
  static const String keySelectedTheme = 'selected_theme';
  
  // Feature Flags (for gradual rollout)
  static const bool featureBodyDoublingEnabled = true;
  static const bool featureAIBreakdownEnabled = true;
  static const bool featureDoomBoxEnabled = true;
  
  // Performance (NFR-1: 60 FPS target)
  static const int targetFPS = 60;
  static const int maxFrameTime = 16; // milliseconds (1000/60)
  
  // Accessibility (NFR-4)
  static const double minTouchTargetSize = 44.0; // iOS guideline
  static const double minTextSize = 12.0;
  static const double maxTextSize = 32.0;
}

