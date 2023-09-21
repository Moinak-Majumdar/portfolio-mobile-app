// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_music.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HiveMusicAdapter extends TypeAdapter<HiveMusic> {
  @override
  final int typeId = 4;

  @override
  HiveMusic read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveMusic(
      startupMusic: fields[0] == null ? true : fields[0] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, HiveMusic obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.startupMusic);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiveMusicAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
