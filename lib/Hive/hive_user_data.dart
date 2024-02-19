import 'package:hive/hive.dart';

part 'hive_user_data.g.dart';

@HiveType(typeId: 1)
class HiveUserData {
  HiveUserData({required this.profileImgPath});

  @HiveField(0, defaultValue: '')
  String profileImgPath;
}
