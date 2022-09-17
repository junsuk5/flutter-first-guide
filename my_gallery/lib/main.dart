import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void main() {
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
      home: const MyGalleryApp(),
    );
  }
}

class MyGalleryApp extends StatefulWidget {
  const MyGalleryApp({Key? key}) : super(key: key);

  @override
  State<MyGalleryApp> createState() => _MyGalleryAppState();
}

class _MyGalleryAppState extends State<MyGalleryApp> {
  final ImagePicker _picker = ImagePicker();
  List<XFile>? images;

  @override
  void initState() {
    super.initState();

    loadImages();
  }

  Future loadImages() async {
    images = await _picker.pickMultiImage();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final pageController = PageController();
    return Scaffold(
      appBar: AppBar(
        title: const Text('전자액자'),
      ),
      body: images == null
          ? const Center(child: Text('No Data'))
          : PageView(
              controller: pageController,
              children: images!.map((image) {
                return FutureBuilder<Uint8List>(
                  future: image.readAsBytes(),
                  builder: (context, snapshot) {
                    final data = snapshot.data;

                    if (data == null ||
                        snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    return Image.memory(
                      snapshot.data!,
                      width: double.infinity,
                    );
                  },
                );
              }).toList(),
            ),
    );
  }
}
