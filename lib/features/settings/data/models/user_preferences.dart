import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';

part 'user_preferences.g.dart';

/// User Preferences Model
/// Stores user settings and customizations
@HiveType(typeId: 4)
class UserPreferences extends Equatable {
  @HiveField(0)
  final bool isDyslexicFontEnabled;
  
  @HiveField(1)
  final double hapticIntensity; // 0.0 to 1.0
  
  @HiveField(2)
  final bool isBrownNoiseEnabled;
  
  @HiveField(3)
  final bool isBinauralBeatsEnabled;
  
  @HiveField(4)
  final double audioVolume; // 0.0 to 1.0
  
  @HiveField(5)
  final String selectedTheme;
  
  @HiveField(6)
  final bool isAudioChimesEnabled;
  
  @HiveField(7)
  final int defaultFocusDuration; // minutes

  const UserPreferences({
    this.isDyslexicFontEnabled = false,
    this.hapticIntensity = 0.8,
    this.isBrownNoiseEnabled = false,
    this.isBinauralBeatsEnabled = false,
    this.audioVolume = 0.5,
    this.selectedTheme = 'default',
    this.isAudioChimesEnabled = true,
    this.defaultFocusDuration = 25,
  });

  UserPreferences copyWith({
    bool? isDyslexicFontEnabled,
    double? hapticIntensity,
    bool? isBrownNoiseEnabled,
    bool? isBinauralBeatsEnabled,
    double? audioVolume,
    String? selectedTheme,
    bool? isAudioChimesEnabled,
    int? defaultFocusDuration,
  }) {
    return UserPreferences(
      isDyslexicFontEnabled: isDyslexicFontEnabled ?? this.isDyslexicFontEnabled,
      hapticIntensity: hapticIntensity ?? this.hapticIntensity,
      isBrownNoiseEnabled: isBrownNoiseEnabled ?? this.isBrownNoiseEnabled,
      isBinauralBeatsEnabled: isBinauralBeatsEnabled ?? this.isBinauralBeatsEnabled,
      audioVolume: audioVolume ?? this.audioVolume,
      selectedTheme: selectedTheme ?? this.selectedTheme,
      isAudioChimesEnabled: isAudioChimesEnabled ?? this.isAudioChimesEnabled,
      defaultFocusDuration: defaultFocusDuration ?? this.defaultFocusDuration,
    );
  }

  @override
  List<Object?> get props => [
        isDyslexicFontEnabled,
        hapticIntensity,
        isBrownNoiseEnabled,
        isBinauralBeatsEnabled,
        audioVolume,
        selectedTheme,
        isAudioChimesEnabled,
        defaultFocusDuration,
      ];
}

