import 'package:hive/hive.dart';

part 'hive_user_playlist.g.dart';

@HiveType(typeId: 4)
class HiveUserPlaylist {
  HiveUserPlaylist({
    required this.artistName,
    required this.coverImgPath,
    required this.songPath,
    required this.title,
    required this.musicStartupState,
  });

  @HiveField(0)
  List<String> title;
  @HiveField(1)
  List<String> artistName;
  @HiveField(2)
  List<String> songPath;
  @HiveField(3)
  List<String> coverImgPath;
  @HiveField(4, defaultValue: true)
  bool musicStartupState;
}
