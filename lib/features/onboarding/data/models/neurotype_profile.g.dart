// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'neurotype_profile.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NeurotypeProfileAdapter extends TypeAdapter<NeurotypeProfile> {
  @override
  final int typeId = 5;

  @override
  NeurotypeProfile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NeurotypeProfile(
      selectedStruggles: (fields[0] as List).cast<StruggleType>(),
      createdAt: fields[1] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, NeurotypeProfile obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.selectedStruggles)
      ..writeByte(1)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NeurotypeProfileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class StruggleTypeAdapter extends TypeAdapter<StruggleType> {
  @override
  final int typeId = 6;

  @override
  StruggleType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return StruggleType.paralysis;
      case 1:
        return StruggleType.overwhelm;
      case 2:
        return StruggleType.timeCeacuity;
      case 3:
        return StruggleType.procrastination;
      case 4:
        return StruggleType.hyperfocus;
      case 5:
        return StruggleType.motivation;
      default:
        return StruggleType.paralysis;
    }
  }

  @override
  void write(BinaryWriter writer, StruggleType obj) {
    switch (obj) {
      case StruggleType.paralysis:
        writer.writeByte(0);
        break;
      case StruggleType.overwhelm:
        writer.writeByte(1);
        break;
      case StruggleType.timeCeacuity:
        writer.writeByte(2);
        break;
      case StruggleType.procrastination:
        writer.writeByte(3);
        break;
      case StruggleType.hyperfocus:
        writer.writeByte(4);
        break;
      case StruggleType.motivation:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StruggleTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
