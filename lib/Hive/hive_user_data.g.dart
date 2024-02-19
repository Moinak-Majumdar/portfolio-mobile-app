// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_user_data.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HiveUserDataAdapter extends TypeAdapter<HiveUserData> {
  @override
  final int typeId = 1;

  @override
  HiveUserData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveUserData(
      profileImgPath: fields[0] == null ? '' : fields[0] as String,
    );
  }

  @override
  void write(BinaryWriter writer, HiveUserData obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.profileImgPath);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiveUserDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
