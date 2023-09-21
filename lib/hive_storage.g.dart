// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_storage.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HiveStorageAdapter extends TypeAdapter<HiveStorage> {
  @override
  final int typeId = 3;

  @override
  HiveStorage read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveStorage(
      dir: fields[0] as String,
      imgName: fields[2] as String,
      localPath: fields[1] as String,
      url: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, HiveStorage obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.dir)
      ..writeByte(1)
      ..write(obj.localPath)
      ..writeByte(2)
      ..write(obj.imgName)
      ..writeByte(3)
      ..write(obj.url);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiveStorageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
