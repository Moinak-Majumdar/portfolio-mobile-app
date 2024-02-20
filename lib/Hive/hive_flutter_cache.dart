import 'package:hive/hive.dart';

part 'hive_flutter_cache.g.dart';

@HiveType(typeId: 3)
class HiveFlutterCache {
  HiveFlutterCache({
    required this.badgeNames,
    required this.coverImg,
    required this.coverImgName,
    required this.description,
    required this.gitRepo,
    required this.intro,
    required this.img,
    required this.imgNames,
    required this.libraries,
    required this.release,
    required this.name,
    required this.slug,
    required this.status,
  });

  @HiveField(0)
  final String name;
  @HiveField(1)
  final String intro;
  @HiveField(2)
  final String gitRepo;
  @HiveField(3)
  final String release;
  @HiveField(4)
  final String description;
  @HiveField(5)
  final String coverImg;
  @HiveField(6)
  final String coverImgName;
  @HiveField(7)
  final List<String> img;
  @HiveField(8)
  final List<String> imgNames;
  @HiveField(9)
  final List<String> badgeNames;
  @HiveField(10)
  final String slug;
  @HiveField(11)
  final String status;
  @HiveField(12)
  final List<String> libraries;
}
