import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../screens/display_screen.dart';

class CameraScreen extends StatefulWidget {
  final camera;
  const CameraScreen({Key? key, required this.camera}) : super(key: key);

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initControllerFuture;
  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.high,
    );
    _initControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Take a picture'),
      ),
      body: FutureBuilder<void>(
        future: _initControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return CameraPreview(_controller);
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.camera_alt),
        onPressed: () async {
          try {
            await _initControllerFuture;
            final image = await _controller.takePicture();
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => DisplayScreen(imagePath: image.path),
              ),
            );
          } catch (e) {
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const Text('There was a issue'),
              ),
            );
          }
        },
      ),
    );
  }
}
