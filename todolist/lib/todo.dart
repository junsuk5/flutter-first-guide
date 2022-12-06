import 'package:hive_flutter/hive_flutter.dart';

part 'todo.g.dart';

@HiveType(typeId: 0)
class Todo extends HiveObject {
  @HiveField(0)
  int? id;

  @HiveField(1)
  String title;

  @HiveField(2)
  int dateTime;

  @HiveField(3)
  bool isDone;

  Todo({
    this.id,
    required this.title,
    required this.dateTime,
    this.isDone = false,
  });
}
