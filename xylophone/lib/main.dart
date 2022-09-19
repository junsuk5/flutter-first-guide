import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const XylophoneApp(),
    );
  }
}

class XylophoneApp extends StatefulWidget {
  const XylophoneApp({Key? key}) : super(key: key);

  @override
  State<XylophoneApp> createState() => _XylophoneAppState();
}

class _XylophoneAppState extends State<XylophoneApp> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('실로폰'),
      ),
      body: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: gunban('도', Colors.red),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            child: gunban('레', Colors.orange),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32.0),
            child: gunban('미', Colors.deepOrangeAccent),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40.0),
            child: gunban('파', Colors.green),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 48.0),
            child: gunban('솔', Colors.cyan),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 56.0),
            child: gunban('라', Colors.blue),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 64.0),
            child: gunban('시', Colors.purple),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 72.0),
            child: gunban('도', Colors.red),
          ),

        ],
      ),
    );
  }

  Widget gunban(String text, Color color) {
    return Container(
      width: 50,
      height: double.infinity,
      color: color,
      child: Center(
        child: Text(
          text,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
