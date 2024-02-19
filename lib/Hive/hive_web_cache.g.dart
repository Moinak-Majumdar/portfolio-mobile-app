// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_web_cache.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HiveWebCacheAdapter extends TypeAdapter<HiveWebCache> {
  @override
  final int typeId = 2;

  @override
  HiveWebCache read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveWebCache(
      coverImg: fields[8] as String,
      coverImgName: fields[9] as String,
      description: fields[7] as String,
      gitRepo: fields[4] as String,
      intro: fields[3] as String,
      img: (fields[10] as List).cast<String>(),
      imgNames: (fields[11] as List).cast<String>(),
      liveUrl: fields[5] as String,
      name: fields[0] as String,
      role: fields[2] as String,
      slug: fields[13] as String,
      status: fields[6] as String,
      tools: (fields[12] as List).cast<String>(),
      type: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, HiveWebCache obj) {
    writer
      ..writeByte(14)
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
      ..write(obj.coverImg)
      ..writeByte(9)
      ..write(obj.coverImgName)
      ..writeByte(10)
      ..write(obj.img)
      ..writeByte(11)
      ..write(obj.imgNames)
      ..writeByte(12)
      ..write(obj.tools)
      ..writeByte(13)
      ..write(obj.slug);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiveWebCacheAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
