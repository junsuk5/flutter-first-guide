import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sensors_plus/sensors_plus.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 가로모드
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SensorApp(),
    );
  }
}

class SensorApp extends StatefulWidget {
  const SensorApp({Key? key}) : super(key: key);

  @override
  State<SensorApp> createState() => _SensorAppState();
}

class _SensorAppState extends State<SensorApp> {
  List<double> _accelerometerValues = [];
  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();

    _subscription = accelerometerEvents.listen((event) {
      setState(() {
        _accelerometerValues = [event.x, event.y, event.z];
      });
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final centerX = MediaQuery.of(context).size.width / 2 - 50;
    final centerY = MediaQuery.of(context).size.height / 2 - 50;

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            left: centerX + _accelerometerValues[1] * 20,
            top: centerY + _accelerometerValues[0] * 20,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              width: 100,
              height: 100,
            ),
          ),
        ],
      ),
    );
    ;
  }
}
