import 'package:hive/hive.dart';
part 'hive_add_doc.g.dart';

@HiveType(typeId: 2)
class HiveAddDoc {
  HiveAddDoc({
    required this.cover,
    required this.description,
    required this.gitRepo,
    required this.img,
    required this.intro,
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
  final bool status;
  @HiveField(7)
  final String description;
  @HiveField(8)
  final String cover;
  @HiveField(9)
  final List<String> img;
  @HiveField(10)
  final List<String> tools;
  @HiveField(11)
  final String slug;
}
