import 'package:flutter/material.dart';
import 'package:todolist/list/list_model.dart';

import 'domain/todo.dart';
import 'list/list_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';

late final Box<Todo> box;
late final ListModel listModel;

void main() async {
  await Hive.initFlutter();
  box = await Hive.openBox<Todo>('todolist.db');
  listModel = ListModel(box);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ListScreen(),
    );
  }
}
