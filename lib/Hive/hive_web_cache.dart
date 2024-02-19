import 'package:hive/hive.dart';

part 'hive_web_cache.g.dart';

@HiveType(typeId: 2)
class HiveWebCache {
  HiveWebCache({
    required this.coverImg,
    required this.coverImgName,
    required this.description,
    required this.gitRepo,
    required this.intro,
    required this.img,
    required this.imgNames,
    required this.liveUrl,
    required this.name,
    required this.role,
    required this.slug,
    required this.status,
    required this.tools,
    required this.type,
  });

  @HiveField(0)
  final String name;
  @HiveField(1)
  final String type;
  @HiveField(2)
  final String role;
  @HiveField(3)
  final String intro;
  @HiveField(4)
  final String gitRepo;
  @HiveField(5)
  final String liveUrl;
  @HiveField(6)
  final String status;
  @HiveField(7)
  final String description;
  @HiveField(8)
  final String coverImg;
  @HiveField(9)
  final String coverImgName;
  @HiveField(10)
  final List<String> img;
  @HiveField(11)
  final List<String> imgNames;
  @HiveField(12)
  final List<String> tools;
  @HiveField(13)
  final String slug;
}
