// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_user_playlist.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HiveUserPlaylistAdapter extends TypeAdapter<HiveUserPlaylist> {
  @override
  final int typeId = 4;

  @override
  HiveUserPlaylist read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveUserPlaylist(
      artistName: (fields[1] as List).cast<String>(),
      coverImgPath: (fields[3] as List).cast<String>(),
      songPath: (fields[2] as List).cast<String>(),
      title: (fields[0] as List).cast<String>(),
      musicStartupState: fields[4] == null ? true : fields[4] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, HiveUserPlaylist obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.artistName)
      ..writeByte(2)
      ..write(obj.songPath)
      ..writeByte(3)
      ..write(obj.coverImgPath)
      ..writeByte(4)
      ..write(obj.musicStartupState);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiveUserPlaylistAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
