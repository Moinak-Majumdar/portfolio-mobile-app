import 'package:hive/hive.dart';

part 'hive_music.g.dart';

@HiveType(typeId: 4)
class HiveMusic {
  HiveMusic({required this.startupMusic});

  @HiveField(0, defaultValue: true)
  bool startupMusic;
}
