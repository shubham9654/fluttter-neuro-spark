// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_preferences.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserPreferencesAdapter extends TypeAdapter<UserPreferences> {
  @override
  final int typeId = 4;

  @override
  UserPreferences read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserPreferences(
      isDyslexicFontEnabled: fields[0] as bool,
      hapticIntensity: fields[1] as double,
      isBrownNoiseEnabled: fields[2] as bool,
      isBinauralBeatsEnabled: fields[3] as bool,
      audioVolume: fields[4] as double,
      selectedTheme: fields[5] as String,
      isAudioChimesEnabled: fields[6] as bool,
      defaultFocusDuration: fields[7] as int,
    );
  }

  @override
  void write(BinaryWriter writer, UserPreferences obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.isDyslexicFontEnabled)
      ..writeByte(1)
      ..write(obj.hapticIntensity)
      ..writeByte(2)
      ..write(obj.isBrownNoiseEnabled)
      ..writeByte(3)
      ..write(obj.isBinauralBeatsEnabled)
      ..writeByte(4)
      ..write(obj.audioVolume)
      ..writeByte(5)
      ..write(obj.selectedTheme)
      ..writeByte(6)
      ..write(obj.isAudioChimesEnabled)
      ..writeByte(7)
      ..write(obj.defaultFocusDuration);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserPreferencesAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
