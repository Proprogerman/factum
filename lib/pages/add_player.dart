import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';

import 'input_player_data.dart';

class AddPlayerScreen extends StatefulWidget {
  const AddPlayerScreen({Key key}) : super(key: key);

  @override
  AddPlayerScreenState createState() => AddPlayerScreenState();
}

class AddPlayerScreenState extends State<AddPlayerScreen> {
  CameraController _controller;
  Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    initCamera();
  }

  void initCamera() async {
    final cameras = await availableCameras();
    final frontCamera = cameras[1];

    _controller = CameraController(
      frontCamera,
      ResolutionPreset.max,
    );

    setState(() {
      _initializeControllerFuture = _controller.initialize();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Сфотографируйся')),
      body: SafeArea(
        child: Builder(
          builder: (context) => SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height -
                Scaffold.of(context).appBarMaxHeight,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Center(
                child: FutureBuilder<void>(
                  future: _initializeControllerFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done &&
                        _controller.value != null &&
                        _controller.value.isInitialized) {
                      return ClipOval(
                        clipper: CameraCircleClipper(),
                        child: AspectRatio(
                            aspectRatio: _controller.value.aspectRatio,
                            child: CameraPreview(_controller)),
                      );
                    } else {
                      return Center(child: CircularProgressIndicator());
                    }
                  },
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        child: Icon(Icons.camera_alt),
        onPressed: () => _addPlayerAction(),
      ),
    );
  }

  void _addPlayerAction() async {
    try {
      await _initializeControllerFuture;
      final path = join(
        (await getTemporaryDirectory()).path,
        'Player${DateTime.now().toString()}.png',
      );
      await _controller.takePicture(path);
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, _, __) => InputPlayerDataScreen(
            inputMode: InputPlayerDataScreenMode.nameInput,
            image: Image.file(File(path)),
          ),
          transitionDuration: Duration(seconds: 0),
        ),
      );
    } catch (e) {
      print(e);
    }
  }
}
