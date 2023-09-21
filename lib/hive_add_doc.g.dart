// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_add_doc.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HiveAddDocAdapter extends TypeAdapter<HiveAddDoc> {
  @override
  final int typeId = 2;

  @override
  HiveAddDoc read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveAddDoc(
      cover: fields[8] as String,
      description: fields[7] as String,
      gitRepo: fields[4] as String,
      img: (fields[9] as List).cast<String>(),
      intro: fields[3] as String,
      liveUrl: fields[5] as String,
      name: fields[0] as String,
      role: fields[2] as String,
      slug: fields[11] as String,
      status: fields[6] as bool,
      tools: (fields[10] as List).cast<String>(),
      type: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, HiveAddDoc obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.role)
      ..writeByte(3)
      ..write(obj.intro)
      ..writeByte(4)
      ..write(obj.gitRepo)
      ..writeByte(5)
      ..write(obj.liveUrl)
      ..writeByte(6)
      ..write(obj.status)
      ..writeByte(7)
      ..write(obj.description)
      ..writeByte(8)
      ..write(obj.cover)
      ..writeByte(9)
      ..write(obj.img)
      ..writeByte(10)
      ..write(obj.tools)
      ..writeByte(11)
      ..write(obj.slug);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiveAddDocAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
