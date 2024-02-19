// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_flutter_cache.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HiveFlutterCacheAdapter extends TypeAdapter<HiveFlutterCache> {
  @override
  final int typeId = 3;

  @override
  HiveFlutterCache read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveFlutterCache(
      badge: (fields[9] as List).cast<String>(),
      coverImg: fields[5] as String,
      coverImgName: fields[6] as String,
      description: fields[4] as String,
      gitRepo: fields[2] as String,
      intro: fields[1] as String,
      img: (fields[7] as List).cast<String>(),
      imgNames: (fields[8] as List).cast<String>(),
      libraries: (fields[12] as List).cast<String>(),
      release: fields[3] as String,
      name: fields[0] as String,
      slug: fields[10] as String,
      status: fields[11] as String,
    );
  }

  @override
  void write(BinaryWriter writer, HiveFlutterCache obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.intro)
      ..writeByte(2)
      ..write(obj.gitRepo)
      ..writeByte(3)
      ..write(obj.release)
      ..writeByte(4)
      ..write(obj.description)
      ..writeByte(5)
      ..write(obj.coverImg)
      ..writeByte(6)
      ..write(obj.coverImgName)
      ..writeByte(7)
      ..write(obj.img)
      ..writeByte(8)
      ..write(obj.imgNames)
      ..writeByte(9)
      ..write(obj.badge)
      ..writeByte(10)
      ..write(obj.slug)
      ..writeByte(11)
      ..write(obj.status)
      ..writeByte(12)
      ..write(obj.libraries);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiveFlutterCacheAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
