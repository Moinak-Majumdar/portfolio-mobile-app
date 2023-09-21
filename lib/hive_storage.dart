import 'package:hive/hive.dart';
part 'hive_storage.g.dart';

@HiveType(typeId: 3)
class HiveStorage {
  HiveStorage({
    required this.dir,
    required this.imgName,
    required this.localPath,
    required this.url,
  });

  @HiveField(0)
  final String dir;

  @HiveField(1)
  final String localPath;

  @HiveField(2)
  final String imgName;

  @HiveField(3)
  String url;
}
