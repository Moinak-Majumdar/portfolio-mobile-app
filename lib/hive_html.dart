import 'package:hive/hive.dart';
part 'hive_html.g.dart';

@HiveType(typeId: 1)
class HiveHtml {
  HiveHtml({required this.body});

  @HiveField(0)
  final String body;
}
