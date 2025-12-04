// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'energy_block.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EnergyBlockAdapter extends TypeAdapter<EnergyBlock> {
  @override
  final int typeId = 7;

  @override
  EnergyBlock read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EnergyBlock(
      startHour: fields[0] as int,
      startMinute: fields[1] as int,
      endHour: fields[2] as int,
      endMinute: fields[3] as int,
      energyLevel: fields[4] as EnergyLevel,
    );
  }

  @override
  void write(BinaryWriter writer, EnergyBlock obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.startHour)
      ..writeByte(1)
      ..write(obj.startMinute)
      ..writeByte(2)
      ..write(obj.endHour)
      ..writeByte(3)
      ..write(obj.endMinute)
      ..writeByte(4)
      ..write(obj.energyLevel);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EnergyBlockAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class EnergyMapAdapter extends TypeAdapter<EnergyMap> {
  @override
  final int typeId = 9;

  @override
  EnergyMap read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EnergyMap(
      blocks: (fields[0] as List).cast<EnergyBlock>(),
      createdAt: fields[1] as DateTime,
      updatedAt: fields[2] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, EnergyMap obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.blocks)
      ..writeByte(1)
      ..write(obj.createdAt)
      ..writeByte(2)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EnergyMapAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class EnergyLevelAdapter extends TypeAdapter<EnergyLevel> {
  @override
  final int typeId = 8;

  @override
  EnergyLevel read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return EnergyLevel.high;
      case 1:
        return EnergyLevel.low;
      default:
        return EnergyLevel.high;
    }
  }

  @override
  void write(BinaryWriter writer, EnergyLevel obj) {
    switch (obj) {
      case EnergyLevel.high:
        writer.writeByte(0);
        break;
      case EnergyLevel.low:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EnergyLevelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
