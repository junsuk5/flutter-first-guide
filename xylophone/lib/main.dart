import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';

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
  const XylophoneApp({super.key});

  @override
  State<XylophoneApp> createState() => _XylophoneAppState();
}

class _XylophoneAppState extends State<XylophoneApp> {
  final List<AudioPlayer> _audioPlayers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    initAudioPlayers();
  }

  @override
  void dispose() {
    for (final player in _audioPlayers) {
      player.dispose();
    }
    super.dispose();
  }

  Future<void> initAudioPlayers() async {
    final List<String> notes = [
      'do1.wav',
      're.wav',
      'mi.wav',
      'fa.wav',
      'sol.wav',
      'la.wav',
      'si.wav',
      'do2.wav'
    ];

    for (final note in notes) {
      final player = AudioPlayer();
      await player.setAsset('assets/$note');
      _audioPlayers.add(player);
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
    return Scaffold(
      appBar: AppBar(
        title: const Text('실로폰'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: gunban('도', Colors.red, index: 0),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  child: gunban('레', Colors.orange, index: 1),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32.0),
                  child: gunban('미', Colors.deepOrangeAccent, index: 2),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40.0),
                  child: gunban('파', Colors.green, index: 3),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 48.0),
                  child: gunban('솔', Colors.cyan, index: 4),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 56.0),
                  child: gunban('라', Colors.blue, index: 5),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 64.0),
                  child: gunban('시', Colors.purple, index: 6),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 72.0),
                  child: gunban('도', Colors.red, index: 7),
                ),
              ],
            ),
    );
  }

  Widget gunban(String text, Color color, {required int index}) {
    return GestureDetector(
      onTap: () {
        if (index < _audioPlayers.length) {
          _audioPlayers[index].seek(Duration.zero);
          _audioPlayers[index].play();
        }
      },
      child: Container(
        width: 50,
        height: double.infinity,
        color: color,
        child: Center(
          child: Text(
            text,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
