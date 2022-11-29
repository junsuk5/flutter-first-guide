
import 'package:hive/hive.dart';

@HiveType(typeId: 0)
class Todo extends HiveObject {

  @HiveField(0)
  int? id;

  @HiveField(1)
  String title;

  @HiveField(2)
  int dateTime;

  Todo({
    this.id,
    required this.title,
    required this.dateTime,
  });
}
