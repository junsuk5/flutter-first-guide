import 'package:hive_flutter/hive_flutter.dart';

import '../domain/todo.dart';

class ListModel {
  final _todos = [
    Todo(
      id: 0,
      title: '청소',
      dateTime: 1111,
    ),
    Todo(
      id: 1,
      title: '빨래',
      dateTime: 1122,
    ),
  ];

  final Box<Todo> box;

  ListModel(this.box);

  // List<Todo> getTodoList() => box.values.toList();
  List<Todo> getTodoList() => _todos;
}
